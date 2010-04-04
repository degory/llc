#C
import stream;

namespace Test131 {
    use IO.File;

    class Main { 
        void init() {
	    var f = File.openCreate( "/tmp/test" );

	    f.println( "Hello World" );

	    var g = File.openRead( "/tmp/test" );
	    
	    IO.Std.err.print( g.readAll() );
	    IO.Std.err.close();
	    File.delete( "/tmp/test" );
	}
    }
}