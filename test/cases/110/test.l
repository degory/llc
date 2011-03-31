#C
import stream;

namespace Test110 {
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "throwing..." );
		throw new System.Exception("test");
	    } catch( System.Exception e ) {
		IO.Std.err.println( "caught: " + e );
	    }
	}
    }
}