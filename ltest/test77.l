
import stream;

namespace Test77 {
    class Main {
	void init() {
	    int i;

	    System.String s = "Hello World!";

	    for( i = 0; i < s.Length; i = i + 1 ) {
		IO.Std.err.println( "s[" + i + "]: " + s[i] );
	    }


	    System.String[] t = { "Hello World" };

	    if( t[0][0] == 'H' ) {
		IO.Std.err.println( "yes" ) ;
	    } else {
		IO.Std.err.println( "no" );
	    }

	    for( i = 0; i < t[0].Length; i = i + 1 ) {
		IO.Std.err.println( "t[0][" + i + "]: " + t[0][i] );
	    }

	}
    }
}