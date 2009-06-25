
import stream;
import gvector;

namespace Test152 {
    class Vector extends Generic.Vector<System.Object> {
	void init() {
	    super.init();
	}

	void init( int size ) {
	    super.init( size );
	}	   
    }

    class Main {
	void init() {
	    Vector test = new Vector(10);
	    int i;

	    for( i = 0; i < 10; i = i + 1 ) {
		test.add(i.box);
	    }

	    foreach( var o; test.elements() ) {
		IO.Std.err.println( "have: " + o );
	    }
	}
    }
}