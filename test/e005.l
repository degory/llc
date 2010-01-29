import "throw.o" ;

namespace E001 { 
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "Hello World!" );
		native._Unwind_RaiseException( new long[4].address );
	    } catch( System.Exception se ) {
		IO.Std.err.println( "Caught something" );
	    }
	}

    }
}