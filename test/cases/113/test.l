#C
import stream;

namespace Test113 {
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "throwing..." );
		throw new System.Exception("test");
	    } catch( System.CastException ce ) {
		IO.Std.err.println( "should not reach here" );
	    } catch( System.Exception e ) {
		IO.Std.err.println( "caught: " + e );
	    }
	    IO.Std.err.println( "finished" );
	}
    }
}