
namespace E001 { 
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "Hello World!" );
	    } catch( System.Exception se ) {
		IO.Std.err.println( "Caught something" );
	    } finally {
		IO.Std.err.println( "Finally" );
	    }
	}

    }
}