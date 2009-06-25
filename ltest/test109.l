
import stream;

namespace Test109 {
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "calling test" );
		test();
	    } finally {
		IO.Std.err.println( "finally" );
	    }

	    IO.Std.err.println( "should not reach here" );
	}

	void test() {
	    IO.Std.err.println( "throwing exception" );
	    throw new System.Exception( "test" );
	}
    }
}