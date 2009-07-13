
import stream;
import gvector;

namespace Test170 {
    use System.String;
    use Generic.Vector;
    use Generic.Array;

    class Test {
	void init() {
	    super.init();
	}

	String toString() {
	    return "hello world from: " + super.toString();
	}
    }
}