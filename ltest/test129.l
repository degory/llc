import stream;

namespace test129 {
    class Main {
        void init() {
	    var a = "hello world";
	    var b = a;
	    var c = a.Length;

	    IO.Std.err.println( "b is: " + b );
        }
    }
}