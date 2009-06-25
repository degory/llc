import stream;

namespace Test43 {
    class Main {
	void init() {
	    TestA a = new TestA(new TestX(123));
	    IO.Std.err.println( "a: " + a );

	    TestB b = new TestB(new TestX(456), new TestX(789));
	    IO.Std.err.println( "b: " + b );

	    TestA c = b;
	    IO.Std.err.println( "c: " + c );

	    TestB d = cast TestB(c);
	    IO.Std.err.println( "d: " + d );
	}
    }

    class TestX extends System.Object {
	int x;
	void init(int x) {
	    super.init();
	    this.x = x;
	}

	System.String toString() {
	    return "TestX(" + x + ")";
	}
    }

    class TestA extends System.Object {
	protected TestX x;

	void init(TestX x) {
	    super.init();
	    this.x = x;
	}

	System.String toString() {
	    return "TestA(" + x + ")";
	}
    }

    class TestB extends TestA {
	TestX y;

	void init(TestX x, TestX y) {
	    super.init(x);
	    this.y = y;
	}

	System.String toString() {
	    return "TestB(" + x + "," + y + ")";
	}
    }
}
 