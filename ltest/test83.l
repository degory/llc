import stream;

namespace Test83 {
    class Main {
	void init() {
	    int[] a;
	    Main b;
	    int ptr c;

	    try {
		a[0] = 0;
	    } catch( System.MemoryException m ) {
		IO.Std.err.println( "caught memory exception: " + m );
	    }

	    try {
		b.test();
	    } catch( System.NullPointerException n ) {
		IO.Std.err.println( "caught null pointer exception: " + n );
	    }

	    try {
		[c] = 0;
	    } catch( System.Exception e ) {
		IO.Std.err.println( "caught exception: " + e );
	    }
	}

	void test() {
	    IO.Std.err.println( "Main.test()" );
	}
    }

    class Test extends Main {
	void test() {
	    IO.Std.err.println( "Test.test()" );
	}
    }
}