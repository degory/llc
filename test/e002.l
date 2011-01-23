
namespace E002 is
    class Main is
	void init() is
	    try
		// native.GC_disable();
		IO.Std.err.println( "Hello World!" );
		var te = new System.Exception( "Oops" );
		native.printf( `AAA: te is %p\n`, te ); native.__flush_stdout();
		throw te;
	    catch System.Exception se
		IO.Std.err.println( "Caught something" );
		var ue = cast char ptr(se);

		for var i = 0; i < 40; i = i + 1 do
		    if (i & 7) == 0 then
			native.printf( `AAA: %p %02X:`, ue + i, i );
		    fi

		    native.printf( ` %02X`, [ue + i] );

		    if (i & 7) == 7 then
			native.printf( `\n` );
		    fi
		od

		native.__flush_stdout();

		native.printf( `AAA: se is %p, %p\n`, se, [ue] );
		IO.Std.err.println( "exception is: " + se.Class.Name );
		IO.Std.err.println( "caught: " + se );
	    finally
		IO.Std.err.println( "Finally" ); native.__flush_stdout();
	    yrt
	si
    si
si