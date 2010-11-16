#C

namespace Test117 {
    class Main {
	void init() {
	    native.printf( `test0(true): %d\n`, test0(true) );
	    native.printf( `test1(true): %d\n`, test1(true) );
	    native.printf( `test2(true): %d\n`, test2(true) );
	    native.printf( `test0(false): %d\n`, test0(false) );
	    native.printf( `test1(false): %d\n`, test1(false) );
	    native.printf( `test2(false): %d\n`, test2(false) );
	}

	int test0(bool b) {
	    if( b ) {
		return 100;
	    } else {
		return 200;
	    }
	}

	int test1(bool b) {
	    if( b ) {
		return 101;
	    } else {
		return 201;
	    }
	}

	int test2(bool b) {
	    if( b ) {
		return 102;
	    } else {
		return 202;
	    }
	}
    }
}