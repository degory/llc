import stream;

namespace Test80 {
    class Main {
        void init() {
	    IO.Std.err.println( "0: " + test0(1,2,3,4) );
	    IO.Std.err.println( "1: " + test1(1,2,3,4) );
	    IO.Std.err.println( "2: " + test2(1,2,3,4) );
	    IO.Std.err.println( "3: " + test3(1,2,3,4) );
	    IO.Std.err.println( "4: " + test4(1,2,3,4) );
	}

	static int test0(int i, int j, int k, int l) {
	    return l;
	}

	int test1(int i, int j, int k, int l) {
	    return i;
	}

	int test2(int i, int j, int k, int l) {
	    return j;
	}

	int test3(int i, int j, int k, int l) {
	    return k;
	}

	int test4(int i, int j, int k, int l) {
	    return l;
	}

    }
}
	