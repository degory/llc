#K

import stream;

namespace Test144 is
    use System.String;
    use System.Object;
    use IO.Std;

    class Main is
        void init() is
 	    var number = 0;
	    var t = new Test[1000];	   
	    do
		for var i = 0; i < t.length; i = i + 1 do
		    t[i] = new Test( "test " + number );
		    number = number + 1;
		od
	    od
	si
    si

    class Test isa System.Object is
    	String name;

        void init( String name ) is
	    this.name = name;
	si

	void throwException() is
	    throw new System.Exception( "exception in dispose" );
	si

	void dispose() is
	    try 
		throwException();
            catch System.Exception se
	        IO.Std.err.println( "caught: " + se );
            yrt
	si
    si
si