

import stream;
import gvector;

namespace Test155 {
    use System;
    use Generic;
    /// Test doc comment for class
    class Main extends Object {
	/// Test doc comment for method
	void init() {
	    Bag<char> v = new Vector<char>();

	    for( char c = 'A'; c <= 'Z'; c = c + cast char(1) ) {
		v.add( c );
	    }

	    foreach( char d; v.elements() ) {
		IO.Std.err.println( "have: " + d );
	    }
	}
    }
}