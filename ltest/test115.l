
import stream;

namespace Test115 {
    class Main {
        void init() {
	    int i;
	    int[] a = new int[100];

	    IO.Std.err.println( "a.length is: " + a.length );

	    for( i = 0; i < a.length; i = i + 1 ) {
		a[i] = i * 2;
		IO.Std.err.println( "setting a[" + i + "] to " + a[i] );		
	    }

	    for( i = 0; i < a.length; i = i + 1 ) {
		IO.Std.err.println( "getting a[" + i + "] is " + a[i] );		
	    }

	    IO.Std.err.println( "after get loop" );
        }
    }
}