namespace Test19 {
    class Main {
        void init() {
	    test0( 100, 101, 102, 103, 104, 105, 106, 107, 108, 109 );
	}

	static void test0(
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
	    native.printf( `p6 %d\n`, p6 );
	    native.printf( `p6 %d\n`, p6 );
	    native.printf( `p6 %d\n`, p6 );
	    native.printf( `p6 %d\n`, p6 );

	    native.printf( `p7 %d\n`, p7 );

	    native.printf( `p8 %d\n`, p8 );

	    native.printf( `p9 %d\n`, p9 );
	}
    }
}