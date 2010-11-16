#C


import stream;
import glist;

namespace Test162 {
    use System.Object;
    use Generic.List;

    class Main {
	void init() {
	    var test = new int[10];
	    var list = cast List<int>(test);

	    for( int i = 0; i < 10; i = i + 1 ) {
		list[i] = i;
	    }

	    IO.Std.err.println( "list is: " + cast Object(list) );

	    foreach( int j; list.elements() ) {
		IO.Std.err.println( "have: " + j );
	    }
	}
    }
}