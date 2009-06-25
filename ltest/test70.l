import stream;

namespace Test70 {
    class Main {
	void init() {
	    int a, b, c, d, e;

	    a = 111;
	    b = 222;
	    c = 333;
	    d = 444;
	    e = 555;

	    int f = (a + b) * (c + d) + e;

	    IO.Std.err.println( "f: " + f );
	}
    }
}