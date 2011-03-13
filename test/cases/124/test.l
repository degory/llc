#C

import stream;

namespace Test124 {
    class Main {
        void init() {
	    System.Class c = System.Class.find( "Test124.Main" );

	    IO.Std.err.println( "c is " + c );
	}
    }
}