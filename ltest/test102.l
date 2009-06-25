
import stream;
import gvector;

namespace Test102 {
    use System.String;
    use Generic.Vector;
    use IO.Std;

    class Main { 
	System.String t;
	void init() {
	    var a = 123, b = "hello world";
	    var v = new Vector<String>();
	    var u = t;

	    Std.err.println( "a is: " + a );
	    Std.err.println( "b is: " + b );
	    Std.err.println( "u is: " + u );

	    v.add( "hello" );
	    v.add( " " );
	    v.add( "world" );

	    Std.err.println( v );

	    foreach( String s; v.elements() ) {
		Std.err.println( "have: " + s );
	    }

	    for( var i = 0; i < 10; i = i + 1 ) {
		Std.err.println( "loop: " + i );
	    }	       
	}
    }
}