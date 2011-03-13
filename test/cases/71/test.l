#C
import stream;
import vector;

namespace Test70 {
    class Main {
	void init() {
	    Util.Vector v = new Util.Vector();

	    v.add( "testing " );
	    v.add( "testing " );
	    v.add( "1 " );
	    v.add( "2 " );
	    v.add( "3 " );
	    
	    IO.Std.err.println( "v is: " + v );

	    IO.Std.err.println( "elements: " + v.getLength() );

	    int i = 0;
	    foreach( System.Object o; v.elements() ) {
		IO.Std.err.println( "#" + i + ": " + o );
	    }
	}
    }
}