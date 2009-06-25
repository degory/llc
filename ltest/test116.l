
namespace Test116 {
    class Main {
	void init() {

	    /
	    native.printf( `test0: %d\n`, test0() );
	    native.printf( `test1: %d\n`, test1() );
	    native.printf( `test2: %d\n`, test2() );
	}

	int test0() {
	    return 0;
	}

	int test1() {
	    return 1;
	}

	int test2() {
	    return 2;
	}
    }
}