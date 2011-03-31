#C
namespace Test23 {
    class Main {
	void init() {
	    test();
	}

	void test() {
	    char ptr c = `testing testing 1 2 3 4 5 6 7 8 9 0`;

	    while( [c] != '0' ) {
		native.putchar( [c] );

		c = c + 1;
	    }

	    native.putchar( '\n' );
	}
    }
}