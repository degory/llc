import args;

namespace T004 {
    class Main {
	void init() {
	    var err = new IO.Writer( new IO.FileStream(2) );
	    var a = System.Arguments.ProgramArguments;

	    foreach( var v; a.elements() ) {
		err.println( v );
	    }

	    err.flush();
	}
    }
}