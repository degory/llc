import args;

namespace N006 {
    class Main {
	void init() {
	    var err = new IO.Writer( new IO.FileStream( 2 ) );
	    err.FlushOnPrintln = true;

	    foreach( var a; System.Arguments.ProgramArguments.elements() ) {
		foreach( var b; System.Arguments.ProgramArguments.elements() ) {
		    err.println( "have: " + a + " " + b );
		}
 	    }
	}
    }
}