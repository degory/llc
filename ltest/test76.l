import stream;

namespace Test76 {
    class Main {
        void init() {
	    TestA a = new TestA();
	    IO.Std.err.println( "A: " + a );
	
	    a.a = 123;

	    IO.Std.err.println( "A: " + a );

	    IO.Std.err.println( "a: " + a.a );
	}
    }

    class TestA extends System.Object {
	private int _a;

	void init() {
	    super.init();
	}

	int geta() {
	    return _a;
	}

	void seta( int v ) {
	    _a = v;
	}

	System.String toString() {
	    return "TestA(" + _a + ")";
	}
    }
}