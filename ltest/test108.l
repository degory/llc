import stream;

namespace Test108 {
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "throwing..." );
		throw new System.Exception("test");
	    } finally {
		IO.Std.err.println( "finally" );
	    }
	    IO.Std.err.println( "should not get here" );
	}
    }
}