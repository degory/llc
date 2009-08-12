import stream;
import gc;

namespace Test83 {
    class Main {
	const int MAX = 1000;

	void init() {
	    int[] a;
	    Main b;
	    int ptr c;

	    for( int i = 0; i < 1000; i = i + 1 ) {
		try {
		    busy();
		    a[0] = 0;
		} catch( System.MemoryException m ) {
		    System.GC.enable();
		    busy();
		    IO.Std.err.println( m );
		    IO.Std.err.println( "A" + i + ": caught memory exception: " + m );
		} catch( System.Exception me ) {
		    IO.Std.err.println( "oops: wrong exception: " + me );
		    return;
		}

		busy();

		try {
		    busy();
		    b.test();
		} catch( System.NullPointerException n ) {
		    System.GC.enable();
		    busy();
		    IO.Std.err.println( n );
		    IO.Std.err.println( "B" + i + ": caught null pointer exception: " + n );
		} catch( System.Exception ne ) {
		    IO.Std.err.println( "oops: wrong exception: " + ne );
		    return;
		}

		busy();

		try {
		    busy();
		    [c] = 0;
		} catch( System.CastException ce ) {
		    IO.Std.err.println( "oops: wrong exception: " + ce );
		    return;
		} catch( System.RuntimeException e ) {
		    System.GC.enable();
		    busy();
		    IO.Std.err.println( e );
		    IO.Std.err.println( "C" + i + ": caught exception: " + e );
		} catch( System.Exception ee ) {
		    IO.Std.err.println( "oops: wrong exception: " + ee );
		    return;
		}

		busy();
	    }
	}

	void test() {
	    IO.Std.err.println( "Main.test()" );
	}

	void busy() { 
	    int[][] a = new int[][MAX];
	    for( int i = 0; i < a.length; i = i + 1 ) {
		a[i] = new int[MAX];
	    }
	    // System.GC.collect();
	}
    }

    class Test extends Main {
	void test() {
	    IO.Std.err.println( "Test.test()" );
	}
    }
}