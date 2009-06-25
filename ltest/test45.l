import stream;

namespace Test45 {
    class Main {
        void init() {
	    try {
		IO.Std.err.println( "hello world!" );
	    } catch( System.Exception e ) {
		IO.Std.err.println( "problem: " + e );
	    }
	}
    }
}