
import stream;

namespace Test57 {
    class Main {
	void init() {
	    try {
		test0();
	    } catch( System.Exception e ) {
		IO.Std.err.println( "caught: " + e );
	    } finally {
		IO.Std.err.println( "clean up 2" );
	    }
	}

	void test0() {
      	    IO.Std.err.println( "test0..." );
	    test1();
	}

	void test1() {
	    IO.Std.err.println( "test1..." );
	    try {
		test2();
	    } catch( System.Exception e ) {
		IO.Std.err.println( "caught: " + e );
		throw e;
	    } finally {
		IO.Std.err.println( "clean up 1" );
	    }
	}

	void test2() {
	    IO.Std.err.println( "test2..." );
	    throw new System.Exception( "testing..." );
	}
    }
}