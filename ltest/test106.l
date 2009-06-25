
import stream;

namespace Test106 {
    class Main {
	void init() {
	    IO.Std.makeThreadSafe();

	    IO.Std.err.println( "hello world" );

	    var lwb = new IO.LockedWriter( new IO.FileStream(1) );

	    lwb.println( "hello locked world" );

	    var test0 = new Test0();
	    test0.start();

	    var test1 = new Test1();
	    test1.start();

	    try {
		throw new System.Exception( "thrown from main" );
	    } catch( System.Exception e ) {
		IO.Std.err.println( "caught in main: " + e );
	    }

	    System.Thread.sleep( 10 );
	}
    }

    class Test0 extends System.Thread {
	void init() {
	    IO.Std.err.println( "created test0..." );
	}

	void run() {
	    IO.Std.err.println( "hello threaded world" );
	}
    }

    class Test1 extends System.Thread {
	void init() {
	    IO.Std.err.println( "created test1..." );
	}

	void run() {
	    throw new System.Exception( "thrown from: " + this );
	}
    }
}