
namespace Test107 {
    class Main {
        void init() {
	    char c;
	    for( int i = 0; i < 100; i = i + 1 ) {
		c = cast char(i % 7);

		native.printf( `i: %d, c: %d\n`, i, c );
	    }
	}
    }
}