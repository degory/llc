#C

import stream;

namespace Test160 {
    class Main {
	void init() {
	    var t = new Test();
	    var test0 = proc(int)(t.test0);
	    var test1 = proc(int)(t.test1);

	    for( int i = 0; i < 10; i = i + 1 ) {
		try {
		    test0(i);
		    test1(i);
		} catch( System.Exception se ) {
		    IO.Std.err.println( "caught: " + se );
		}
	    }
	}
    }

    class Test {
	void init() { }
	void test0(int n) {
	    IO.Std.err.println( "from: " + this + " test: " + n );
	}

	void test1(int n) {
	    throw new System.Exception( "from: " + this + " throw: " + n );
	}
    }
}