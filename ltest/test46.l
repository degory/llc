import stream;

namespace Test46 {
    class Main {
        void init() {
	    try {
		IO.Std.err.println( "hello world!" );
	    } catch( ETest e ) {
		IO.Std.err.println( "problem: " + e );
	    } catch( System.Exception f ) {
		IO.Std.err.println( "problem: " + f );
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