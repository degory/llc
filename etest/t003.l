import args;

namespace T003 {
    class Main {
	void init() {
	    var err = new IO.Writer( new IO.FileStream(2) );
	    var a = System.Arguments.ProgramArguments;

	    for( int i = 0; i < a.length; i = i + 1 ) {
		err.println( a[i] );
	    }

	    err.flush();
	}
    }
}