
import stream;

namespace Test74 {
    class Main {
	void init() {
	    int[] test = new int[100];

	    int j = 0;
	    foreach( int ref i; test ) {
		i = j;
		IO.Std.err.println( "k: " + i+ ", test.length: " + test.length );
		j = j + 1;
	    }

	    foreach( int ref k; test ) {
		IO.Std.err.println( "k: " + k + ", test.length: " + test.length );
	    }
	}
    }
}