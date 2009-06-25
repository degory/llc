namespace Test49 {
    class Main extends System.Object {
	void init() {
	    test0();
	}

        void test0() {
	    for( int i = 0; i < 30; i = i + 1 ) {
		try {
		    test1();
		} catch( System.Exception e ) {
		    native.printf( `XXX caught %p, i is %d\n`, e, i );
		} finally {
		    native.printf( `XXX finally, i is %d\n`, i );
		}
	    }
	}



        void test1() {	    
	    for( int i = 0; i < 3; i = i + 1 ) {
		native.printf( `YYY before i %d\n`, i );
		try {
		    test2();
		} catch( System.Exception e ) {
		    native.printf( `YYY caught %p, i is %d\n`, e, i );
		} finally {
		    native.printf( `YYY finally, i is %d\n`, i );
		}
		native.printf( `YYY after i %d\n`, i );
	    }
	    throw new System.Exception( "test1" );
	}


        void test2() {
	    for( int i = 0; i < 30; i = i + 1 ) {
		native.printf( `ZZZ throw...\n` );
		throw new System.Exception( "test2" );
	    }
	}
    }
}