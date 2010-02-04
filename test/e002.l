
namespace E002 { 
    class Main {
	void init() {
	    try {
		// native.GC_disable();
		IO.Std.err.println( "Hello World!" );
		var te = new System.Exception( "Oops" );
		native.printf( `AAA: te is %p\n`, te ); native.__flush_stdout();
		throw te;
	    } catch( System.Exception se ) {
		IO.Std.err.println( "Caught something" );
		var ue = cast char ptr(se);

		for( int i = 0; i < 40; i = i + 1 ) {
		    if( (i & 7) == 0 ) {
			native.printf( `AAA: %p %02X:`, ue + i, i );
		    }

		    native.printf( ` %02X`, [ue + i] );

		    if( (i & 7) == 7 ) {
			native.printf( `\n` );
		    }
		}

		native.__flush_stdout();

		native.printf( `AAA: se is %p, %p\n`, se, [ue] );
		IO.Std.err.println( "exception is: " + se.Class.Name );
		IO.Std.err.println( "caught: " + se );
	    } finally {
		IO.Std.err.println( "Finally" ); native.__flush_stdout();
	    }
	}

    }
}