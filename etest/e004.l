import "throw.o" ;

namespace E004 { 
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "Hello World!" );
		native._Z10test_throwv();
	    } catch( System.Exception se ) {
		IO.Std.err.println( "Caught something" );
	    }
	}

    }
}