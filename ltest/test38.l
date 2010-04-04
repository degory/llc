#C
import stream;

namespace Test38 {
    class Main {
	void init() {
	    test();
	}

	static void test() {
	    int i = 1234567;
	    int j = 100;
	    int k = i % j;
	    int l = i / j;

	    IO.Std.err.println( "" + i + " % " + j + " = " + k + "," + l );
	    native.printf( `%d %% %d = %d,%d\n`, i, j, k, l );
	}
    }
}