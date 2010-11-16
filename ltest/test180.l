#C

import stream;

namespace Test180 {
    use System.Class;
    use System.Object;
    use System.String;

    class Main {
	void init() {
	    Class c = System.Class.find( "Test180.Test" );

	    Object o = c.create();

	    IO.Std.err.println( "o is: " + o );
	}
    }


    class Test {
	void init() { 
	}
    }
}