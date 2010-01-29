namespace T001 {
    class Main {
	void init() {
	    var err = new IO.Writer( new IO.FileStream(2) );
	    err.FlushOnPrintln = true;

	    err.println( "Hello World!\n" );
	}
    }
}