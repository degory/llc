
namespace E003 is
    class Main is
	void init() is
	    try
		IO.Std.err.println( "Hello World!" );
		throw new System.Exception( "Oops" );
	    catch System.Exception se
		IO.Std.err.println( "Caught something" );
	    yrt
	si
    si
si