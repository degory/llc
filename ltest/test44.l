#C
import stream;

namespace Test44 {
    class Main {
        void init() {

	    IO.Std.err.println( "open buffer..." );
	    IO.Reader b = IO.File.openRead( "/usr/lang/lib/lang.l" );

	    IO.Std.err.println( "buffer now: " + b );
	    
	    for( int c = b.read(); c != -1; c = b.read() ) {
		IO.Std.err.write( cast char(c) );
	    }


	    IO.Std.err.flush();

	    b.close();
	}
    }
}