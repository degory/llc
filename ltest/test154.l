#C

import stream;
import gllist;
import gvector;

namespace Test154 {
    // test Generic.List<T> interface

    use System.Object;
    use Generic.Vector;
    use Generic.List;
    use Generic.Bag;
    use Generic.LinkedList;

    class Main extends Object {
	void init() {
	    test( new LinkedList<int>() );
	    test( new Vector<int>() );
	}

	void test( List<int> t ) {
	    System.Object o = cast Object(t);

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

	    test( cast Bag<int>(t) );

	    IO.Std.err.println( "done" );

	}

	void test( Bag<int> t ) {
	    int i;
	    for( i = 10; i < 20; i = i + 1 ) {
		t.add( i );
	    }

	    for( i = -10; i < 30; i = i + 1 ) {
		IO.Std.err.println( "contains " + i + ": " + t.contains(i) );
	    }

	    try {
		for( i = 10; i < 30; i = i + 1 ) {
		    t.remove( i );
		    IO.Std.err.println( "removed " + i );
		}
	    } catch( System.Exception se ) {
		IO.Std.err.println( "caught: " + se );
	    }
	}
    }
}