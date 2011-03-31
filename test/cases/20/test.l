#C
namespace Test20 {
    class Main {
        void init() {
	    test0( 100, 101, 102, 103, 104, 105, 106, 107, 108, 109 );
	    test1( 100, 101, 102, 103, 104, 105, 106, 107, 108, 109 );
	    test0( 999, 888, 777, 666, 555, 444, 333, 222, 111, 000 );
	    test1( 999, 888, 777, 666, 555, 444, 333, 222, 111, 000 );

	    test2( 100, 101, 102, 103, 104, 105, 106, 107, 108, 109 );
	    test3( 100, 101, 102, 103, 104, 105, 106, 107, 108, 109 );
	    test2( 999, 888, 777, 666, 555, 444, 333, 222, 111, 000 );
	    test3( 999, 888, 777, 666, 555, 444, 333, 222, 111, 000 );
	}

	void test0(
			  int p0, 
			  int p1, 
			  int p2, 
			  int p3, 
			  int p4, 
			  int p5, 
			  int p6, 
			  int p7, 
			  int p8, 
			  int p9 ) {

	    native.printf( `p0 %d\n`, p0 );
	    native.printf( `p1 %d\n`, p1 );
	    native.printf( `p2 %d\n`, p2 );
	    native.printf( `p3 %d\n`, p3 );
	    native.printf( `p4 %d\n`, p4 );
	    native.printf( `p5 %d\n`, p5 );
	    native.printf( `p6 %d\n`, p6 );
	    native.printf( `p7 %d\n`, p7 );
	    native.printf( `p8 %d\n`, p8 );
	    native.printf( `p9 %d\n`, p9 );

	    native.printf( `p0, %d\n`, p0 );
	    native.printf( `p0, p1 %d, %d\n`, p0, p1 );
	    native.printf( `p0, p1, p2 %d, %d, %d\n`, p0, p1, p2 );
	    native.printf( `p0, p1, p2, p3 %d, %d, %d, %d\n`, p0, p1, p2, p3 );
	    native.printf( `p0, p1, p2, p3, p4 %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4 );
	    native.printf( `p0, p1, p2, p3, p4, p5 %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6 %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7 %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7, p8, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7, p8 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );

	}

	void test1(
			  int p0, 
			  int p1, 
			  int p2, 
			  int p3, 
			  int p4, 
			  int p5, 
			  int p6, 
			  int p7, 
			  int p8, 
			  int p9 ) {

	    native.printf( `p0 %d\n`, p0 );
	    native.printf( `p1 %d\n`, p1 );
	    native.printf( `p2 %d\n`, p2 );
	    native.printf( `p3 %d\n`, p3 );
	    native.printf( `p4 %d\n`, p4 );
	    native.printf( `p5 %d\n`, p5 );
	    native.printf( `p6 %d\n`, p6 );
	    native.printf( `p7 %d\n`, p7 );
	    native.printf( `p8 %d\n`, p8 );
	    native.printf( `p9 %d\n`, p9 );

	    native.printf( `p0, %d\n`, p0 );
	    native.printf( `p0, p1 %d, %d\n`, p0, p1 );
	    native.printf( `p0, p1, p2 %d, %d, %d\n`, p0, p1, p2 );
	    native.printf( `p0, p1, p2, p3 %d, %d, %d, %d\n`, p0, p1, p2, p3 );
	    native.printf( `p0, p1, p2, p3, p4 %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4 );
	    native.printf( `p0, p1, p2, p3, p4, p5 %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6 %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7 %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7, p8, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7, p8 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );

	}

	void test2(
		   int p9,
		   int p8,
		   int p7,
		   int p6,
		   int p5,
		   int p4,
		   int p3,
		   int p2,
		   int p1,
		   int p0 ) {

	    native.printf( `p0 %d\n`, p0 );
	    native.printf( `p1 %d\n`, p1 );
	    native.printf( `p2 %d\n`, p2 );
	    native.printf( `p3 %d\n`, p3 );
	    native.printf( `p4 %d\n`, p4 );
	    native.printf( `p5 %d\n`, p5 );
	    native.printf( `p6 %d\n`, p6 );
	    native.printf( `p7 %d\n`, p7 );
	    native.printf( `p8 %d\n`, p8 );
	    native.printf( `p9 %d\n`, p9 );

	    native.printf( `p0, %d\n`, p0 );
	    native.printf( `p0, p1 %d, %d\n`, p0, p1 );
	    native.printf( `p0, p1, p2 %d, %d, %d\n`, p0, p1, p2 );
	    native.printf( `p0, p1, p2, p3 %d, %d, %d, %d\n`, p0, p1, p2, p3 );
	    native.printf( `p0, p1, p2, p3, p4 %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4 );
	    native.printf( `p0, p1, p2, p3, p4, p5 %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6 %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7 %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7, p8, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7, p8 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );

	}

	void test3(
		   int p9,
		   int p8,
		   int p7,
		   int p6,
		   int p5,
		   int p4,
		   int p3,
		   int p2,
		   int p1,
		   int p0 ) {

	    native.printf( `p0 %d\n`, p0 );
	    native.printf( `p1 %d\n`, p1 );
	    native.printf( `p2 %d\n`, p2 );
	    native.printf( `p3 %d\n`, p3 );
	    native.printf( `p4 %d\n`, p4 );
	    native.printf( `p5 %d\n`, p5 );
	    native.printf( `p6 %d\n`, p6 );
	    native.printf( `p7 %d\n`, p7 );
	    native.printf( `p8 %d\n`, p8 );
	    native.printf( `p9 %d\n`, p9 );

	    native.printf( `p0, %d\n`, p0 );
	    native.printf( `p0, p1 %d, %d\n`, p0, p1 );
	    native.printf( `p0, p1, p2 %d, %d, %d\n`, p0, p1, p2 );
	    native.printf( `p0, p1, p2, p3 %d, %d, %d, %d\n`, p0, p1, p2, p3 );
	    native.printf( `p0, p1, p2, p3, p4 %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4 );
	    native.printf( `p0, p1, p2, p3, p4, p5 %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6 %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7 %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7, p8, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7, p8 );
	    native.printf( `p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n`, p0, p1, p2, p3, p4, p5, p6, p7, p8, p9 );

	}

    }
}