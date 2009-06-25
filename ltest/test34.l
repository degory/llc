import stream;

namespace Test34 {
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "hello world!" );
	    } catch( System.Exception e ) {
		IO.Std.err.println( "caught: " + e );
	    }
	}
    }
}