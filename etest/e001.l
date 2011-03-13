
namespace E001 is
    class Main is
	void init() is
	    try
		IO.Std.err.println( "Hello World!" );
	    catch System.Exception se 
		IO.Std.err.println( "Caught something" );
	    finally
		IO.Std.err.println( "Finally" );
	    yrt
	si
    si
si