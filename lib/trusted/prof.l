#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved


import gmap;
import unwind;

namespace Util {
    use System.String;
    use Generic.Map;

    pragma NoProfile;

    class Count {
	word last_time;
	word total_time;
	int count;
	int depth;

	void init() {
	}

	void enter() {
	    if( depth == 0 ) {
		last_time = cast word(native.__get_nanotime());
	    }

	    // IO.Std.err.println( "enter time: " + cast int(last_time) );
	    count = count + 1;
	    depth = depth + 1;
	}

	void exit(word now) {
	    depth = depth - 1;
	    if( depth != 0 || last_time == 0w ) {
		// in recursive call or stack underflow:
		return;
	    }

	    // IO.Std.err.println( "exit time: " + t );
	    total_time = total_time + (now - last_time);
	    // IO.Std.err.println( "total time: " + cast int(total_time) );
	    last_time = 0w;
	}

	String toString() {
	    return "" + count + cast char(9) + cast int(total_time/1000w);
	}
    }

    class Profiler {
	const int MAP_SIZE = 9973;

	static Map<word,Count> counts;

	static Profiler instance;

	void init() {
	}

	void dispose() {
	    native.__prof_stop();

	    var f = IO.File.openCreate( "prof.csv" );

	    foreach( var c; counts.pairs() ) {
		word address = c.key;
		word highest = 0w;

		for( var v = System.UnwindInfo.First; v != null; v = v.Next ) {
		    if( v.method_name == null ) {
			break;
		    }

		    if( v.method_start < highest ) {
			IO.Std.err.println( "not sorted" );
		    } else if( v.method_start > highest ) {
			highest = v.method_start;
		    }
		    
		    if( address >= v.method_start && address <= v.method_end ) {
			f.println( "\"" + v.method_name + "\"" + cast char(9) + c.value );
			break;
		    }
		}
	    }

	    f.close();
	}

	static void enter( word address ) {
	    if( counts == null ) {
		initialize();
	    }

	    Count c = counts[address];
	    if( c == null ) {
		c = new Count();
		counts[address] = c;
	    }

	    c.enter();
	}

	static void exit( word address ) {
	    word now = cast word(native.__get_nanotime());

	    Count c = counts[address];
	    if( c == null ) {
		c = new Count();
		counts[address] = c;
	    }

	    c.exit(now);
	}

	static void initialize() { 
	    counts = new Map<word,Count>(MAP_SIZE);
	    instance = new Profiler();
	    System.Exit.add(1,instance);
	    IO.Std.err.println( "profiler initialized" );
	}

	static void count( word address ) {

	}
    }
}