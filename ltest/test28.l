#C
import stream;

namespace Test28 {
    class Main {
	void init() {
	    System.String s = "testing testing";

	    native.printf( `string is: %s\n`, s.toCString() );

	    System.StringBuffer b = new System.StringBuffer( s );

	    native.printf( `buffer is: %s\n`, b.toCString() );

	    b.append( " testing " );

	    native.printf( `after append buffer is: %s\n`, b.toCString() );

	    b.append( 0 );

	    native.printf( `after number buffer is: %s\n`, b.toCString() );

	    IO.Std.err.println( s );
	}
    }
}