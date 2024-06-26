#C

namespace Test8 {
    class Main {
	void init() {
	    native.puts( `starting up...` );

	    System.String s = "testing";

	    native.puts( `created string object...` );

	    native.printf( `string is %lx\n`, s );

	    native.printf( `cstr is '%s'\n`, s.toCString() );
	}
    }

    class TestA {
	void init() {
	    native.printf( `new TestA: %lx\n`, this );
	}

	void test( int p0, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9 ) {
	    native.printf( `testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   0, 1, 2, 3, 4, 5, 6, 7, 8, 9 );

	    native.printf( `testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );
	}
    }
}