
import stream;
import generic;

namespace Test119 {

    use System.String;
    use System.Integer;
    use Generic.Map;

    class Main {
	void init() {
	    int i;
	    var map = new Map<Integer,String>();

	    for( i = 0; i < 50; i = i + 1 ) {
		map[new Integer(i)] = "value " + i;
	    }

	    for( i = 49; i >= 0; i = i - 1 ) {
		IO.Std.err.println( "map[" + i + "] = '" + map[new Integer(i)] + "'" );
	    }
	}
    }
}

