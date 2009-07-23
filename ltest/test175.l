
import stream;
import gvector;

namespace Test175 {
    use System.Object;
    use Generic.Vector;
    use Generic.List;
    use Generic.Array;

    class Main {
	void init() {
	    int i;
	    List<int> li = new Vector<int>();

	    for( i = 0; i < 10; i = i + 1 ) {
		li.add( i );
	    }	   
	    IO.Std.err.println( "li is: " + cast Object(li) );

	    for( i = 0; i < 10; i = i + 1 ) {
		IO.Std.err.println( "li[" + i + "]: " + li[i] );
	    }
	}
    }
}