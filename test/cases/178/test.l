#C


import stream;

namespace Test178 {
    use System.Object;
    use System.Exception;
    use System.String;
    use System.StringBuffer;
    use System.CastException;

    class Main {
	void init() {
	    var s = "testing testing";

	    try {
		var sb = cast StringBuffer(s);
	    } catch( CastException ce ) {
		IO.Std.err.println( "caught: " + ce );
	    }
	}
    }
}