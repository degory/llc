#C
namespace Test33 {
    class Main {
        void init() {
	    int a = 1, b = 2, c = 3;
	    test( (a+a) * (a+a), (b+b) * (b+b), (c+c) * (c+c) );

	}

	void test(int i, int j, int k) { 
	    native.printf( `test i: %d, j: %d, k: %d\n` );
	}
    }
}