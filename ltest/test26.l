namespace Test26 {
    class Main {
        void init() {
	    System.String s = "testing testing 1 2 3";
	    int i = 1, j = 2, k = 3;

	    int a, b, c;

	    a = 111;
	    b = 222;
	    c = 333;

	    native.printf( `string: %s\n`, s.toCString() );
	}
    }
}