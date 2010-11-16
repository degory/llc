#K

import stream;
import gvector;

namespace Test149 is
    class Main is
        void init() is
	    var v = new Generic.Vector<int>();
	    v.add(1);
	    v.add(2);
	    v.add(3);
	    v.add(4);
	    v.add(5);

	    Generic.Iterator<int> i = v.elements();

	    while i.hasMoreElements() do
	        IO.Std.err.println( "have: " + i.nextElement() );
	    od
	si
    si
si