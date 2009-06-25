
import stream;

namespace Test92 { 
    class Main {
	void init() {
	    Test0<System.String> t0_s;
	    Test0<int> t0_i;
	    Test1<System.String> t1_s;
	    Test1<int> t1_i;

	    t0_s = new Test0<System.String>("testing t0_s");
	    t0_i = new Test0<int>( 12345 );
	    t1_s = new Test1<System.String>("testing t1_s" );
	    t1_i = new Test1<int>( 67890 );

	    int a = 123, b = 456;

	    Swap<int>.swap( a, b );

	    IO.Std.err.println( "swapped, a: " + a + ", b: " + b );

	}
    }


    class Test0<T> extends System.Object {
	Test1<T> t1;

	void init( T t ) {
	    IO.Std.err.println( "value is: " + t );
	    t1 = new Test1<T>( t );
	}
    }

    class Test1<T> extends System.Object {
	Test0<T> t0;

	void init( T t ) {
	    IO.Std.err.println( "value is: " + t );
	}
    }

    class Swap<T> extends System.Object {
	static void swap( T ref a, T ref b ) {
	    T t = a;
	    a = b;
	    b = t;
	}
    }
}