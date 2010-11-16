#C

namespace Test7 {
    class Main {
	void init() {
	    native.puts( `starting up...` );

	    TestA a = new TestA();

	    native.printf( `new TestA: %lx\n`, a );

	    a.test0( 0, 111, 222, 333, 444, 555, 666, 777, 888, 999 );
	    a.test0( 999, 888, 777, 666, 555, 444, 333, 222, 111, 0 );
	    a.test1( 0, 111, 222, 333, 444, 555, 666, 777, 888, 999 );
	    a.test1( 999, 888, 777, 666, 555, 444, 333, 222, 111, 0 );
	}
    }

    class TestA {
	void init() {
	    native.printf( `new TestA: %lx\n`, this );
	}
 
	void test0( int p0, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9 ) {
	    native.printf( `A.0.0: testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   0, 1, 2, 3, 4, 5, 6, 7, 8, 9 );

	    native.printf( `A.0.1: testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );
	}

	void test1( int p0, int p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9 ) {
	    native.printf( `A.1.0: testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );

	    native.printf( `A.1.1: testing %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`,
			   0, 1, 2, 3, 4, 5, 6, 7, 8, 9 );


	}

    }
}