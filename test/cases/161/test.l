#C

import gvector;
import stream;

namespace Test161 {
    use Generic.Vector;

    class Event0<P> {
	Vector<P> list;

	void init() {
	    list = new Vector<P>();
	}

	void add( P p ) {
	    list.add(p);
	}

	void call() {
	    foreach( P p; list.elements() ) {
		p();
	    }
	}
    }

    class Main {
	void init() {
	    var e = new Event0<void proc()>();

	    void proc() p;

	    p = proc()(test0);
	    IO.Std.err.println( "p is: " + p.box );

	    e.add( proc()(test0) );
	    e.add( proc()(test1) );
	    e.add( proc()(test2) );

	    e.call();
	}

	void test0() {
	    IO.Std.err.println( "test0 from: " + this );
	}

	void test1() {
	    IO.Std.err.println( "test1 from: " + this );
	}

	void test2() {
	    IO.Std.err.println( "test2 from: " + this );
	}
    }
}