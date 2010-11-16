#C
import stream;

namespace Test114 {
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "throwing..." );
		throw new System.Exception("test");
	    } catch( System.CastException ce ) {
		IO.Std.err.println( "should not reach here A" );
	    } catch( System.ArrayBoundsException e ) {
		IO.Std.err.println( "should not reach here B" );
	    }
	    IO.Std.err.println( "should not reach here C" );
	}
    }
}