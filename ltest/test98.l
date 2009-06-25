
import stream;

namespace Test98 {
    class Main {
	void init() {
	    System.String s = "hello";
	    System.String t = "world";

	    if( s =~ "hello" ) {
		IO.Std.err.println( "s =~ 'hello' (expected)" );
	    } else {
		IO.Std.err.println( "s !~ 'hello' (not expected)" );
	    }

	    if( s !~ "hello" ) {
		IO.Std.err.println( "s !~ 'hello' (not expected)" );
	    } else {
		IO.Std.err.println( "s =~ 'hello' (expected)" );
	    }

	    if( s =~ t ) {
		IO.Std.err.println( "s =~ t (not expected)" );
	    } else {
		IO.Std.err.println( "s !~ t (expected)" );
	    }

	    if( s !~ t ) {
		IO.Std.err.println( "s !~ t (expected)" );
	    } else {
		IO.Std.err.println( "s =~ t (not expected)" );
	    }

	    if( s >= "hello" ) {
		IO.Std.err.println( "s >= 'hello' (expected)" );
	    } else {
		IO.Std.err.println( "s < 'hello' (not expected)" );
	    }

	    if( t <= "world" ) {
		IO.Std.err.println( "t <= 'world' (expected)" );
	    } else {
		IO.Std.err.println( "t > 'world' (not expected)" );
	    }

	    if( s > t ) {
		IO.Std.err.println( "s > t (not expected)" );
	    } else {
		IO.Std.err.println( "s <= t (expected)" );
	    }

	    if( s < t ) {
		IO.Std.err.println( "s < t (expected)" );
	    } else {
		IO.Std.err.println( "s >= t (not expected)" );
	    }
	}
    }
}