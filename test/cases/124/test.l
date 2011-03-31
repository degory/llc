#C

import stream;
import library;

namespace Test124 {
    class Main {
        void init() {
	    System.Class c = System.Library.findClassAll( "Test124.Main" );

	    IO.Std.err.println( "c is " + c );
	}
    }
}