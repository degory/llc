#C

import gvector;
import stream;

namespace Test130 {
    class Main {
        void init() {
	    var v = new Generic.Vector<System.String>();

	    v.add( "Hello" );
	    v.add( " " );
	    v.add( "World" );
	    v.add( "!" );
	    v.add( "\n" );

	    foreach( var i; v.elements() ) {
		IO.Std.err.print( i );
	    }
        }
    }
}