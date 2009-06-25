
import stream;

namespace Test111 {
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "calling test" );
		test();
	    } catch( System.Exception e ) {
		IO.Std.err.println( "caught: " + e );
	    }
	}

	void test() {
	    IO.Std.err.println( "throwing exception" );
	    throw new System.Exception( "test" );
	}
    }
}