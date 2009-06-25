
import stream;

namespace Test146 {
    class Interface {
        void print() { }
    }

    class Implement extends System.Object implements Interface {
	void init() {
	}

	void print() {
	    IO.Std.err.println( "print: " + this );
	}
    }

    class Main {
	void init() {
	    Implement imp = new Implement();
	    Interface inf = imp;

	    imp.print();
	    inf.print();
	}
    }
}