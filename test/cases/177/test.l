#C

import stream;

namespace Test177 {
    use System.Exception;

    class Main {
	void init() {
	    var a = new int[0];
	    try {
		for( int i = 0; i < 1; i = i + 1 ) {
		    a[i] = i;
		}
	    } catch( Exception e ) {
		IO.Std.err.println( "caught: " + e );
	    }
	}
    }
}