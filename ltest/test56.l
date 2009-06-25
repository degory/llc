
import stream;

namespace Test56 {
    class Main {
        void init() {
	    int t = test0();

	    IO.Std.err.println( "test0 returns " + t );
	}

	int test1() {
	    try {
		IO.Std.err.println( "test1 return" );
		return 67890;
		// } catch( System.Exception e ) {
	    } finally {
		IO.Std.err.println( "test1 finally" );
	    }
	}

	int test0() {
	    IO.Std.err.println( "test0 before try" );
	    try {
		IO.Std.err.println( "test0 call test1" );
		return test1();
	    } catch( System.Exception se ) {
		IO.Std.err.println( "test0 catch: " + se );
	    } finally {
		IO.Std.err.println( "test0 finally" );
	    }

	    IO.Std.err.println( "test0 after try" );		 
	}
    }
}