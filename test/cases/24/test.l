#C
namespace Test24 {
    class Main {
	void init() {
	    for( int i = 0; i < 25; i = i + 1 ) {
		for( int j = 0; j < 25; j = j + 1 ) {
		    native.printf( `%d x %d = %d\n`, i, j, i * j );
		}
	    }

	    test(1, 2, 3);
	}
	
	void test(int i, int j, int k) {
	    int a, b, c;
	    int x, y, z;

	    native.printf( `x = %d, y = %d, z = %d\n`, x, y, z );
	    native.printf( `x = %d, y = %d, z = %d\n`, x, y, z );
	    native.printf( `a = %d, b = %d, c = %d\n`, a, b, c );
	}
    }
}