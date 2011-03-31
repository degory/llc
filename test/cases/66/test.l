#C
import stream;

namespace Test66 {
    class Main {
	void init() {
	    DTest[] d = new DTest[4096];

	    for( int j = 0; j < 100; j = j + 1 ) {
		for( int i = 0; i < d.length; i = i + 1 ) {
		    d[i] = new DTest(i);
		}
	    }
	}
    }


    class DTest extends System.Object {
	int i;

	void init(int i) {
	    IO.Std.err.println( "new DTest " + i + "..." );
	    this.i = i;
	}

	void dispose() {
	    IO.Std.err.println( "dispose DTest " + i + "..." );
	}
    }
}