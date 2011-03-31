#K

import stream;

namespace Test142 is
    use IO.Std;

    class Main is 
        void init() is
  	    var count = 50;
	    do
	        Std.err.println( "" + count + " bottles of beer on the wall, " + count + " bottles of beer..." );
                count = count - 1;
		if count == 0 then
		    break;
		fi
  	    od
    	si
    si
si     
