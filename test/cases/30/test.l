#C
import vector;

namespace Test30 {
    class Main {
        void init() {
	    Util.Vector v = new Util.Vector();

	    v.add( "testing " );
	    v.add( "testing " );
	    v.add( "1 2 3" );

	    foreach( var o; v.elements() ) {
		native.printf( `next is: %s\n`, o.toCString() );
	    }
	}
    }
}