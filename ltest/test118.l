
import stream;
import gmap;

namespace Test118 {
    class Main {
	void init() {
	    // Generic.Map<System.String,System.String>
	    var map = new Generic.Map<System.String,System.String>();

	    map["0"] = "hello";
	    map["1"] = " ";
	    map["2"] = "world";
	    map["3"] = "!";
	    map["4"] = "\n";

	    for( int i = 0; i < 5; i = i + 1 ) {
		IO.Std.err.print( map["" + i] );
	    }
	}
    }
}