
import stream;
import gvector;

import test171;

namespace Test170 {
    use System.String;
    use Generic.Vector;
    use Generic.Array;

    class Test extends Dynamic.LoadTest {
	void init() {
	    super.init();
	}

	void barf() {
	    throw new System.Exception("barf");
	}

	String toString() {
	    try {
		barf();
	    } catch( System.Exception se ) {
		IO.Std.err.println( "oops: " + se );
	    }
	    return "hello world from: " + super.toString();
	}
    }
}