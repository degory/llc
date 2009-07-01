

import stream;
import gvector;

namespace Test155 {
    use System;
    use Generic;
    /// Test doc comment for class
    class Main {
	/// Test doc comment for method
	void init() {

	    native.printf( `startup...\n` );
	    Bag<char> v = new Vector<char>();

	    for( char c = 'A'; c <= 'Z'; c = c + cast char(1) ) {
		IO.Std.err.println( "add: " + c );
		v.add( c );
	    }

	    foreach( char d; v.elements() ) {
		IO.Std.err.println( "have: " + d );
	    }
	}
    }
}