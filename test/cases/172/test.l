#C

import stream;
import gvector;

import test171;

namespace Test172 {
    use System.Object;
    use System.String;
    use Generic.Vector;
    use Generic.Array;

    class Test extends Dynamic.LoadTest {
	void init() {
	    super.init();
	}

	get Object Value {
	    // reference template that will not be present in program loading this class:
	    var v = new Vector<Test>();
	    v.add(this);

	    return v;
	}

	String toString() {
	    return "hello world from: " + super.toString();
	}
    }
}