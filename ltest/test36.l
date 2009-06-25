import stream;

namespace Test36 {
    class Main {
	void init() {
	    System.String t = "Testing ";

	    for( int i = 1; i <= 3; i = i + 1 ) {
		t = t + i;
	    }

	    t = t + "\n";

	    IO.Std.err.println( t );

	    t = "Hello" + " " + "World!";

	    IO.Std.err.println( t );
	}
    }
}