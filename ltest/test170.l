
import stream;
import gvector;

namespace Test170 {
    use System.String;
    use Generic.Vector;
    use Generic.Array;

    class Main {
	void init() { 
	    var a = new int[10];

	    var b = a.box;
	    IO.Std.err.println( "a is: " + a );
	    IO.Std.err.println( "b is: " + b );
	    IO.Std.err.println( "length: " + b.Length );

	    var t = new Test();
	}
    }

    class Test {
	void init() {
	    super.init();
	}

	String toString() {
	    return "hello world from: " + super.toString();
	}
    }
}