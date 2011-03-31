#C

import stream;
import map;

namespace Test78 {
    class Main {
        void init() {
	    Util.Map map = new Util.Map();

	    map["AAA"] = "111";
	    map["BBB"] = "222";
	    map["CCC"] = "333";

	    map["Hello"] = "World";

	    foreach( System.Object k; map.Keys ) {
		System.Object v = map[k];

		IO.Std.err.println( "map[" + k + "] -> " + v );
	    }
	}
    }
}