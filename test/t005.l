import args;

namespace T005 {
    class Main {
	void init() {
	    var err = new IO.Writer( new IO.FileStream(2) );
	    var a = new Generic.Vector<System.String>();

	    a.add( "A" );
	    a.add( "B" );
	    a.add( "C" );
	    a.add( "D" );
	    a.add( "E" );

	    foreach( var v; a.elements() ) {
		err.println( v );
	    }

	    err.flush();
	}
    }
}