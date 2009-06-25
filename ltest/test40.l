namespace Test40 {
    class Main {
        void init() {
            int i, j, k;

	    i = 111;
	    j = 222;
	    k = 333;

	    native.printf( `i = %d, j = %d, k = %d, i + j + k = %d\n`, i, j, k, (i + j + k) );
	}
    }
}