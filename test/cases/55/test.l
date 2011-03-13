#C

import stream;

namespace Test55 {
    class Main {
        void init() {
	    int t = test0();

	    IO.Std.err.println( "test0 returns " + t );
	}

	int test0() {
	    IO.Std.err.println( "test0 before try" );
	    try {
		IO.Std.err.println( "test0 return" );
		return 12345;
	    } catch( System.Exception se ) {
		IO.Std.err.println( "test0 catch" );
	    } finally {
		IO.Std.err.println( "test0 finally" );
	    }

	    IO.Std.err.println( "test0 after try" );		 
	}
    }
}