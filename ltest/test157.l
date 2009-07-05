import stream;

namespace Test157 {
    class Main {
	void init() {
	    int proc(int,int) compare;

	    compare = proc(int,int)(impl);

	    test(compare);
	}

	static int impl(int i, int j) { 
	    IO.Std.err.println( "i: " + i + ", j: " + j );
	    return i + j;
	}

	void test( int proc(int,int) c ) {
	    c(111,222);
	}
    }
}