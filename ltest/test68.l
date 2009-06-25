import stream;

namespace Test68 {
    class Main {
	void init() {
	    int[] a = new int[100];

	    for( int i = 0; i < a.length; i = i + 1 ) {
		a[i] = i;
		IO.Std.err.println( "set a[" + i + "] = " + a[i] );
	    }

	    foreach( int j; a ) {
		IO.Std.err.println( "j is: " + j );
	    }
	}
    }
}