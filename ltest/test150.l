#K

import stream;
import gvector;

namespace Test150 is
    use Generic.List;
    use Generic.Vector;

    class Main is
        void init() is
	    List<int> l = new Vector<int>();

	    int i;
	    for i = 0; i < 10; i = i + 1 do
	        l.add(i);
	    od

	    foreach int j; l.elements() do
	        IO.Std.err.println( "have: " + j );
	    od
	end
    end
end