#C
import stream;

namespace Test79 {
    class Vector<T> extends System.Object {
	void init(int x, int y) {
	    IO.Std.err.println( "arse" );
	}

	void test(int i, int j) {
	    IO.Std.err.println( "arse" );
	}

	void copy(Vector<T> t) {
	    IO.Std.err.println( "arse" );
	}
    }

    class Main {
        void init() {
	    Vector<int> a;
	    Vector<int[]> b;
	    Vector<int[][]> c;
	    Vector<Test<Vector>> d;

	    System.Object o;

	    Vector<System.String> v = cast Vector<System.String>(o);

	    Vector w = cast Vector(o);

	    w = w.copy(v);
	}
    }
}