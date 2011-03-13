#C

import generic;
import gsort;
import stream;

namespace Test128 {
    use System.String;
    use System.Class;
    use Generic.MapPair;
    use Generic.Vector;
    use Generic.Sort;

    class Main {
        void init() {
	    Vector<MapPair<String,String>> v = new Vector<MapPair<String,String>>();

            foreach( Class c; Class.classes() ) {
		v.add( new MapPair<String,String>(c.Name,"something") );
	    }

	    Generic.Sort<MapPair<String,String>>.sort( v );

	    IO.Std.err.println( "classes: " + v );
	}
    }
}