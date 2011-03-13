#C

import stream;

namespace Test75 {
    class Main {
        void init() {
	    Util.Vector v = new Util.Vector();

	    v.lengthen( 5 );

	    v[0] = "testing";
	    v[1] = " testing";
	    v[2] = " 1 2 3";

	    IO.Std.err.println( "v[0] is: " + v[0] );
	    IO.Std.err.println( "v[1] is: " + v[1] );
	    IO.Std.err.println( "v[2] is: " + v[2] );
	}
    }
}