
namespace E001 { 
    class Main {
	void init() {
	    try {
		IO.Std.err.println( "AAA" );
		try {
		    IO.Std.err.println( "Hello World!" );
		    var te = new System.Exception( "Oops" );
		    native.printf( `AAA: te is %p\n`, te ); native.__flush_stdout();
		    throw te;
		} catch( System.MemoryException me ) {
		    IO.Std.err.println( "Wrong catch" );
		} finally {
		    IO.Std.err.println( "Inner finally" );
		}
		IO.Std.err.println( "BBB" );
	    } catch( System.Exception se ) {
		IO.Std.err.println( "Caught something" );

		IO.Std.err.println( "exception is: " + se.Class.Name );

	    } finally {
		IO.Std.err.println( "Finally" ); native.__flush_stdout();
	    }
	    IO.Std.err.println( "CCC" );
	}

    }
}