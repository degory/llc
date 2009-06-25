import stream;

namespace Test137 {
    class Main {
	void init() {
	    int a = 100;
	    int b = 200;
	    int c = 300;

	    int d = c - b - a;

	    IO.Std.err.println( "d is: " + d );
	}
    }
}