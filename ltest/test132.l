#C

import stream;
import gvector;

namespace Test132 {
    class Main {
        void init() {
	    var v = new Generic.Vector<System.String>();

	    int dummy = 12345678;
	    for( int i = 0; i < 100; i = i + 1 ) {
		IO.Std.err.println( "before test0, i = " + i );
		stackAddress( dummy ); 
		try {
		    for( int j = 0; j < 20; j = j + 1 ) { 
			v.add( "testing " + i + " * " + j + " = " + (i * j) );

			IO.Std.err.println( "before test0, j = " + j );
			test0( i * j );
		    }
		} catch( System.Exception se ) {
		    native.GC_enable();
		    IO.Std.err.println( "caught: " + se );
		    v.add( "caught: " + se );
		} finally {
		    IO.Std.err.println( "main finally" );
		}
		IO.Std.err.println( "after test0, i = " + i );
	    }

	    IO.Std.err.println( "v is: " + v );
	}

	void stackAddress( int ref p ) {
	    native.printf( `stack top is around %p sentinal %d\n`, cast word(p), p );
	}

	void test0( int v ) {
	    test1( v );
	}

	void test1( int v ) {
	    try {
		test2( v );
	    } finally {
		IO.Std.err.println( "test1 finally" );
	    }
	}

	void test2( int v ) {
	    IO.Std.err.println( "v is: " + System.String.hex(v) );
	    if( v & 0x80 != 0 ) {
		IO.Std.err.println( "test2 will throw" );
	    
		System.Object o;
		o.toInt();
	    } else {
		IO.Std.err.println( "test2 will not throw" );
	    }
	}
    }
}