#C

import stream;
import thread;

namespace Test105 {
    class Main {
	void init() {
	    var t = new Test();

	    t.start();

	    native.sleep( 100 );
	}
    }

    class Test extends System.Thread {
	void init() {
	}

	void run() {
	    IO.Std.err.println( "Hello World" );
	}
    }
}