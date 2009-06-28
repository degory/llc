
import stream;
import gllist;
import gvector;

namespace Test154 {
    use Generic.Vector;
    use Generic.List;
    use Generic.LinkedList;
    class Main {
	void init() {
	    test( new LinkedList<int>() );
	    test( new Vector<int>() );
	}

	void test( List<int> t ) {
	    System.Object o = cast System.Object(t);

	    IO.Std.err.println( "testing: " + o.Class.Name );

	    int i;
	    for( i = 0; i < 10; i = i + 1 ) {
		t.add(i);
	    }


	    for( i = 9; i >= 0; i = i - 1 ) {
		IO.Std.err.println( "@" + i + ": " + t[i] );
	    }

	    for( i = 0; i < 10; i = i + 1 ) {
		t[i] = i * i;
	    }
		
	    foreach( int j; t.elements() ) {
		IO.Std.err.println( "have: " + j );
	    }	    

	    IO.Std.err.println( "done" );
	}
    }
}