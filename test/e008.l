
namespace E001 { 
    class Main {
	void init() {
	    try {
		try {
		    IO.Std.err.println( "Hello World!" );
		    throw new System.Exception( "Oops" );
		} catch( System.Exception se ) {
		    IO.Std.err.println( "Caught something" );
		}
	    } finally {
		IO.Std.err.println( "finally" );
	    }
	}

    }
}