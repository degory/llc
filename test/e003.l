
namespace E001 { 
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "Hello World!" );
		throw new System.Exception( "Oops" );
	    } catch( System.Exception se ) {
		IO.Std.err.println( "Caught something" );
	    }
	}

    }
}