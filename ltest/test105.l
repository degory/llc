#C

import stream;
import thread;

namespace Test105 {
    class Main {
	void init() {
	    IO.Std.err.FlushOnPrintln = true;
	    var t = new Test();

	    t.start();

	    native.sleep( 10 );
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