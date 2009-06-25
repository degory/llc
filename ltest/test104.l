
import stream;
import gvector;

namespace Test104 {
    use IO.Std;

    namespace Test {
	use Generic.Vector;
	use System;

	class Main extends Object {
	    void test( String s ) {
		IO.Std.err.println( s );
	    }

	    void init() {
		var vs = new Vector<String>();
		var vi = new Vector<int>();
		var vt = new Vector<Test>();

		String u = "test";
		
		for( var i = 0; i < 10; i = i + 1 ) {
		    vs.add( "element #" + i );
		    vi.add( i );
		    vt.add( new Test("test #" + i) );
		}

		foreach( String s; vs.elements() ) {
		    Std.err.println( "string is: " + s );
		}

		foreach( int j; vi.elements() ) {
		    Std.err.println( "int is: " + j );
		}

		foreach( Test t; vt.elements() ) {
		    Std.err.println( t );
		    Std.err.println( "test is: " + t.Test );
		}

		IO.Std.err.println( "vs[5]: " + vs[5] );
		IO.Std.err.println( "vi[5]: " + vi[5] );
		IO.Std.err.println( "vt[5]: " + vt[5] );
	    }
	}

	class Test extends Object {
	    String test;

	    void init( String v ) {
		Test = v;
	    }

	    String toString() {
		return Test;
	    }

	    String getTest() {
		return test;
	    }

	    void setTest( String v ) {
		test = v;
	    }
	}
    }
}