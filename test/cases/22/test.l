#C
namespace Test22 {
    class Main {
	void init() {
	    test(100);
	}

	void test(int l) {
	    int i;
	    int[] a = new int[l];

	    for( i = 0; i < l; i = i + 1 ) {
		a[i] = i;
	    }

	    for( i = 0; i < l; i = i + 1 ) {
		native.printf( `a[%d] = %d\n`, i, a[i] );
		native.__flush_stdout();
	    }
	}
    }
}
