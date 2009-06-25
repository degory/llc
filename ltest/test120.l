
import integer;
import stream;

import generic;

namespace Test120 {
    class Main {
	void init() {
	    IO.Std.err.println( "hash of: " + 123 + " is: " + 123.hash() );
	    IO.Std.err.println( "toString of: " + 123 + " is: " + 123.toString() );
	    // IO.Std.err.println( "missing of: " + 123 + " is: " + 123.missing() );

	    var v = new Generic.Vector<System.Object>();

	    v.add( new System.Char( 'X' ) );

	    Test<char>.add( v, 'A' );
	    Test<char>.add( v, 'B' );

	    Test<int>.add( v, 123 );
	    Test<int>.add( v, 456 );
	    Test<int>.add( v, 789 );

	    Test<word>.add( v, 1001W );
	    Test<word>.add( v, 2002W );
	    Test<word>.add( v, 3003W );

	    Test<System.String>.add( v, "Hello" );
	    Test<System.String>.add( v, "World" );

	    foreach( System.Object i; v.elements() ) {
		IO.Std.err.println( "have: " + i + " of type: " + i.Class.Name );
	    }
	}

    }

    class Test<T> {
        static void add( Generic.Vector<System.Object> v, T t ) {
	    v.add( t.box );
	}
    }
}