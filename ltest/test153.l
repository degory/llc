#K

import stream;
import gvector;

namespace Test153 is
    use Generic.List;
    use Generic.Vector;

    interface Whatever is
        void test();
    end

    class Test extends Vector<int> implements Whatever is
        void init() is
	    super.init();
        end
  
        void test() is
	    IO.Std.err.println( "test..." );
	end
    end
					      

    class Main is
        void init() is
	    List<int> l = new Test();

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