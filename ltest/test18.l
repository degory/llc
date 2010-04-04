#C

namespace Test18 {
    class Main {
	void init() {
	    native.puts( `starting up...` );

	    TestA a = new TestA();

	    native.printf( `new TestA: %lx\n`, a );

	    a.test0( 0, 111, 222, 333, 444, 555, 666, 777, 888, 999 );
	    a.test0( 999, 888, 777, 666, 555, 444, 333, 222, 111, 0 );
	    a.test1( 0, 111, 222, 333, 444, 555, 666, 777, 888, 999 );
	    a.test1( 999, 888, 777, 666, 555, 444, 333, 222, 111, 0 );
	    a.test2( 0, 111, 222, 333, 444, 555, 666, 777, 888, 999 );
	    a.test2( 999, 888, 777, 666, 555, 444, 333, 222, 111, 0 );
	}
    }

    class TestA {
	void init() {
	    native.printf( `new TestA: %lx\n`, this );
	}
 
	void test0( int p0, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9 ) {
	    native.printf( `testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   0, 1, 2, 3, 4, 5, 6, 7, 8, 9 );

	    native.printf( `testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );
	}

	void test1( int p0, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9 ) {
	    native.printf( `testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );

	    native.printf( `testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   0, 1, 2, 3, 4, 5, 6, 7, 8, 9 );


	}

	void test2( int p0, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9 ) {
	    native.printf( `testing p0 %d\n`, p0 );
	    native.printf( `testing p1 %d\n`, p1 );
	    native.printf( `testing p2 %d\n`, p2 );
	    native.printf( `testing p3 %d\n`, p3 );
	    native.printf( `testing p4 %d\n`, p4 );
	    native.printf( `testing p5 %d\n`, p5 );
	    native.printf( `testing p6 %d\n`, p6 );
	    native.printf( `testing p7 %d\n`, p7 );
	    native.printf( `testing p8 %d\n`, p8 );
	    native.printf( `testing p9 %d\n`, p9 );
	}
    }
}