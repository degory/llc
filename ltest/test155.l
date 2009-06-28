

import stream;
import gvector;

namespace Test155 {
    use System;
    use Generic;
    class Main extends Object {
	void init() {
	    var v = new Vector<char>();

	    for( char c = 'A'; c <= 'Z'; c = c + cast char(1) ) {
		v.add( c );
	    }

	    foreach( char d; v.elements() ) {
		IO.Std.err.println( "have: " + c );
	    }
	}
    }
}