#C
import stream;

namespace Test53 {
    class Main {
	void init() {
	    test0();
	}

	void test0() {
	    try {
		IO.Std.err.println( "YYYY: testing 0\n" );
		test1();
	    } catch( System.Exception se ) {
		IO.Std.err.println( "YYYY: caught 0\n" );
	    } finally {
		IO.Std.err.println( "YYYY: clean up 0\n" );
	    }

	}

	void test1() {
	    try {
		IO.Std.err.println( "XXXX: testing 1\n" );
		throw new System.Exception( "XXXX" );
	    } catch( ETest et ) {
		IO.Std.err.println( "XXXX: caught 1\n" );
	    } finally {
		IO.Std.err.println( "XXXX: clean up 1\n" );
	    }
	}
    }


    class ETest extends System.Exception {
	void init( System.String s ) {
	    super.init(s);
	}
    }
}