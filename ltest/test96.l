#C

import stream;
import generic;

namespace Test96 {
    use Other.Test0;
    use Other.Test1;

    class Main {
	void init() {
	    Test0 r, s, t;

	    r = new Test0( "Hello " );
	    s = new Test0( "World" );

	    t = r + s;

	    IO.Std.err.println( "result is: " + t );

	    Generic.Vector<Test0> v = new Generic.Vector<Test0>();

	    v.add( new Test0( "123" ) );
	    v.add( new Test0( "456" ) );
	    v.add( new Test0( "789" ) );
	    v.add( new Test1<int>( "ABC", 111 ) );
	    v.add( new Test1<int>( "DEF", 222 ) );
	    v.add( new Test1<int>( "GHI", 333 ) );
	    v.add( new Test1<System.String>( "JKL", "XXX" ) );
	    v.add( new Test1<System.String>( "MNO", "YYY" ) );
	    v.add( new Test1<System.String>( "PQR", "ZZZ" ) );

	    foreach( Test0 u; v.elements() ) {
		IO.Std.err.println( "have: " + u );
	    }
	}
    }
}

namespace Other {
    class Test0 extends System.Object {
	System.String s;

	void init( System.String s ) {
	    this.s = s;
	}

	System.String toString() {
	    return s;
	}

	Test0 opAdd( Test0 t ) {
	    System.StringBuffer result = new System.StringBuffer( t.toString() );
	    result.append( toString() );
	    return new Test0( result );
	}

	System.StringBuffer opAdd( System.String t ) {
	    System.StringBuffer result = new System.StringBuffer( toString() );
	    result.append( toString() );
	    return result;
	}

	System.StringBuffer opAddRev( System.String t ) {
	    System.StringBuffer result = new System.StringBuffer( toString() );
	    result.append( toString() );
	    return result;
	}
    }

    class Test1<T> extends Test0 {
	T t;

	void init( System.String s, T t ) {
	    super.init( s );

	    this.t = t;
	}

	System.String toString() {
	    return "(" + super.toString() + "," + t + ")";
	}
    }
}