#C

import stream;
import gvector;

namespace Test164 {
    use Generic.Vector;

    class Main {
	void init() {
	    IO.Std.err.println( "startup..." );
	    var t0 = new Test0();
	}
    }   

    class Test0 {
	void init() {
	    IO.Std.err.println( "enter Test0.init()" );
	    IO.Std.err.FlushOnPrintln = true;

	    int proc(int)[] f;

	    f = new int proc(int)[10];

	    int i;
	    for( i = 0; i < 10; i = i + 1 ) {
		IO.Std.err.println( "setting " + i );
		if( i & 1 == 0 ) {
		    f[i] = proc(int)(test0);
		} else {
		    f[i] = proc(int)(test1);
		}
		IO.Std.err.println( "at " + i + " proc is: " + cast int(f[i]) );
	    }

	    for( i = 0; i < f.length; i = i + 1 ) {
		f[i](i);

		int k = f[i](i); 

		IO.Std.err.println( "Test0, g " + i + ": " + f[i](i) + " or " + k );
	    }

	    var j = f.elements();
	    while( j.hasMoreElements() ) {
		IO.Std.err.println( "have: " + j.nextElement() );
	    }

	    i = 0;
	    while( j.hasMoreElements() ) {
		IO.Std.err.println( "have: " + j.nextElement()(i) );
		i = i + 1;
	    }

	    i = 0;
	    foreach( var g; f.elements() ) {		
		IO.Std.err.println( "Test0, g " + i + ": " + f[i](i) );

		i = i + 1;
	    }

	    var l = f.box;
	    for( i = 0; i < l.Length; i = i + 1 ) {
		IO.Std.err.println( "Test0, l " + i + ": " + l[i](i) );
	    }
	}

	int test0(int i) {
	    IO.Std.err.println( "test0: " + i );
	    return i * i;
	}

	int test1(int i) { 
	    IO.Std.err.println( "test1: " + i );
	    return i * i * i;
	}
    }
}