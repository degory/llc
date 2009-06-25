
import stream;

namespace Test65 {
    class Main {
	void init() {
	    int i = 111, j = 222, k = 333;

	    i = j * 8 + k;

	    test( i, k );
	    IO.Std.err.println( "i: " + i );
	}

	void test(int ref p, int q) {
	    p = q;
	}
    }
}