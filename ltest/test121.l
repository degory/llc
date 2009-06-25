
import stream;
import generic;

namespace Test121 {
    class Main {
	void init() {
	    var v = new Generic.Map<int,int>();

	    for( int i = 0; i < 100; i = i + 1 ) {
		v[i] = i * i;
	    }
	    

	    foreach( int j; v.keys() ) {
		IO.Std.err.println( "v[" + j + "] = " + v[j] );
	    }

	    IO.Std.err.println( "v is: " + v );
	}
    }
}