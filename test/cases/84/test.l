#C
import stream;

namespace Test84 {
    class Main {
	void init() {
	    Test a, b, c;

	    a = new Test(100);
	    b = new Test(200);
	    c = new Test(200);

	    if( a =~ b ) {
		IO.Std.err.println( "=~ not expected" );
	    } else {
		IO.Std.err.println( "!~ expected" );
	    }

	    IO.Std.err.println( "=~ gives: " + (a =~ b) + " (false expected)" );

	    if( a !~ b ) {
		IO.Std.err.println( "!~ expected" );
	    } else {
		IO.Std.err.println( "=~ not expected" );
	    }

	    IO.Std.err.println( "!~ gives: " + (a !~ b) + " (true expected)" );

	    if( a > b ) {
		IO.Std.err.println( "> not expected" );
	    } else {
		IO.Std.err.println( "<= expected" );
	    }

	    IO.Std.err.println( "> gives: " + (a > b) + " (false expected)" );

	    if( a < b ) {
		IO.Std.err.println( "< expected" );
	    } else {
		IO.Std.err.println( ">= not expected" );
	    }

	    IO.Std.err.println( "< gives: " + (a < b) + " (true expected)" );

	    if( null =~ a ) {
		IO.Std.err.println( "null =~ a not expected" );
	    } else {
 		IO.Std.err.println( "null !~ a expected" );
	    }

	    if( null !~ b ) {
		IO.Std.err.println( "null !~ b expected" );
	    } else {
		IO.Std.err.println( "null =~ b not expected" );
	    }

	    if( a =~ null ) {
		IO.Std.err.println( "a =~ null not expected" );
	    } else {
 		IO.Std.err.println( "a !~ null expected" );
	    }

	    if( b !~ null ) {
		IO.Std.err.println( "b !~ null expected" );
	    } else {
		IO.Std.err.println( "b =~ null not expected" );
	    }


	    if( b =~ c ) {
		IO.Std.err.println( "=~ expected" );
	    } else {
		IO.Std.err.println( "!~ not expected" );
	    }

	    IO.Std.err.println( "=~ gives: " + (b =~ c) + " (true expected)" );

	    if( b !~ c ) {
		IO.Std.err.println( "!~ not expected" );
	    } else {
		IO.Std.err.println( "=~ expected" );
	    }

	    IO.Std.err.println( "!~ gives: " + (b !~ c) + " (false expected)" );

	    if( b >= c ) {
		IO.Std.err.println( ">= expected" );
	    } else {
		IO.Std.err.println( "< not expected" );
	    }

	    IO.Std.err.println( ">= gives: " + (b >= c) + " (true expected)" );

	    if( b < c ) {
		IO.Std.err.println( "< not expected" );
	    } else {
		IO.Std.err.println( ">= expected" );
	    }

	    IO.Std.err.println( "< gives: " + (b < c) + " (false expected)" );

	}
    }

    class Test extends System.Object {
	int a;

	void init( int a ) {
	    this.a = a;
	}

	int opCompare( Test b ) {
	    // IO.Std.err.println( "test compare " + a + "-" + b.a + "->" + (a - b.a) );
	    return a - b.a;
	}

	bool opEquals( Test b ) {
	    // IO.Std.err.println( "test compare " + a + "=" + b.a + "->" + (a == b.a) );
	    return a == b.a;
	}

	System.String toString() {
	    return "Test(" + a + ")";
	}
    }

}