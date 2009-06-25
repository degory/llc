
import stream;

namespace Test100 {
    struct Test {
	int a, b;

	void init( int a, int b ) {
	    this.a = a;
	    this.b = b;
	}

	int getA() {
	    return a;
	}

	int getB() {
	    return b;
	}

	System.String getS() {
	    return "Test(" + A + "," + B + ")";
	}
    }

    class Main extends System.Object {
	void init() {
	    super.init();

	    Test t, u;

	    t = new Test(111,222);
	    u = new Test(333,444);

	    IO.Std.err.println( "t: " + t.S );
	    IO.Std.err.println( "u: " + u.S );
	}
    }
}