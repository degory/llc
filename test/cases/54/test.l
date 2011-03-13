#C
import stream;

namespace Test54 {
    class Main {
	void init() {
	    test0();
	}

	void test0() {
	    try {
		native.printf( `XXX: test0 A...\n` );
		test1();
		native.printf( `XXX: test0 B...\n` );
	    } catch( System.Exception se ) {
		native.printf( `XXX: test0 Catch...\n` );
	    } finally {
		native.printf( `XXX: test0 Finally...\n` );
	    }
	}

	void test1() {
	    try {
		native.printf( `XXX: test1 A...\n` );
		test2();
		native.printf( `XXX: test1 B...\n` );
	    } catch( ETest e ) {
		native.printf( `XXX: test1 Catch...\n` );
	    } finally {
		native.printf( `XXX: test1 Finally...\n` );
	    }
	}

	void test2() {
	    native.printf( `XXX: test2 A...\n` );
	    throw new System.Exception( "test2" );
	    native.printf( `XXX: test2 B...\n` );
	}
    }

    class ETest extends System.Exception {
	void init( System.String s ) {
	    super.init(s);
	}
    }
}