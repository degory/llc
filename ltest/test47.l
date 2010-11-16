#C
import stream;

namespace Test47 {
    class Main {
        void init() {
	    try {
		IO.Std.err.println( "hello world 1" );

		try {
		    IO.Std.err.println( "hello world 2" );
		} catch( ETest g ) {
		    IO.Std.err.println( "problem e: " + e );
		} catch( System.Exception h ) {
		    IO.Std.err.println( "problem h: " + e );
		}
	    } catch( ETest e ) {
		IO.Std.err.println( "problem e: " + e );
	    } catch( System.Exception f ) {
		IO.Std.err.println( "problem f: " + f );
	    } finally {
		IO.Std.err.println( "finished" );
	    }
	}
    }

    class ETest extends System.Exception {
	void init( System.String message ) {
	    super.init(message);
	}
    }
}