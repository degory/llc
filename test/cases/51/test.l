#C
import stream;

namespace Test51 {
    class Main extends System.Object {
        void init() {
	    super.init();

	    try {
		IO.Std.err.println( "Hello world A!" );
	    } catch( System.Exception e ) {
		IO.Std.err.println( "Caught something A" );
	    } finally {
		IO.Std.err.println( "Clean up A" );
	    }

	    try {
		IO.Std.err.println( "Hello world B!" );
	    } catch( System.Exception f ) {
		IO.Std.err.println( "Caught something B" );
	    } finally {
		IO.Std.err.println( "Clean up B" );
	    }
	}
    }
}