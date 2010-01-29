
namespace T008 {
    class Main {
	void init() {
	    IO.Std.err = new IO.Writer( new IO.FileStream(2) );
	    IO.Std.err.FlushOnPrintln = true;

	    IO.Std.err.println( "Hello World!" );
	}
    }
}