#C

namespace T002 {
    class Main {
	void init() {
	    var err = new IO.Writer( new IO.FileStream(2) );
	    // err.FlushOnPrintln = true;

	    for( int i = 0; i < 30; i = i + 1 ) { 
		err.println( "Hello World!" );
	    }

	    err.flush();
	}
    }
}