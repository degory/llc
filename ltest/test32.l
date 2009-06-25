namespace Test32 { 
    class Main {
	static int a, b, c;

	void init() {
	    a = 1;
	    b = 2;
	    c = 3;

	    native.printf( `a = %d, b = %d, c = %d\n`, a, b, c );
	}
    }
}