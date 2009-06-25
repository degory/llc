import stream;

namespace Test42 {
    class Main {
	void init() {
	    TestA a = new TestA(123);
	    IO.Std.err.println( "a: " + a );

	    TestB b = new TestB(456,789);
	    IO.Std.err.println( "b: " + b );

	    TestA c = b;
	    IO.Std.err.println( "c: " + c );

	    TestB d = cast TestB(c);
	    IO.Std.err.println( "d: " + d );
	}
    }


    class TestA extends System.Object {
	protected int x;

	void init(int x) {
	    this.x = x;
	}

	System.String toString() {
	    return "TestA(" + x + ")";
	}
    }

    class TestB extends TestA {
	int y;

	void init(int x, int y) {
	    super.init(x);
	    this.y = y;
	}

	System.String toString() {
	    return "TestB(" + x + "," + y + ")";
	}
    }
}