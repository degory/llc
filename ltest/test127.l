#C

import stream;
import gsort;

namespace Test127 {
    class Main {
	void init() {
	    Generic.Vector<System.String> v = new Generic.Vector<System.String>();

	    v.add( "testing" );
	    v.add( "hello" );
	    v.add( "world" );
	    v.add( "foo" );
	    v.add( "bar" );
	    v.add( "flub" );
	    
	    Generic.Sort<System.String>.sort( v );
	    
	    int i = 0;
	    foreach( System.String s; v.elements() ) {
		IO.Std.err.println( "" + i + ": " + s );
		i = i + 1;
	    }   
	}
    }
}