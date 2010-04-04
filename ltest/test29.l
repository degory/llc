#C

namespace Test29 {
    class Main {
        void init() {
	    char[] test = new char[10];

	    for( int i = 0; i < test.length-1; i = i + 1 ) {
		test[i] = cast char(65 + i);
	    }

	    test[test.length-1] = cast char(0);

	    native.printf( `about to print...\n` );

	    native.printf( `test is %s\n`, test.address );
	}
    }
}