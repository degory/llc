#C


import stream;
import postgres;

namespace Test126 {
    class Main {
	void init() {
	    var c = new SQL.PostgreSQL.Connection( "" );
	    var s = c.prepare( "select * from test;" );
	    
	    while( s.next() ) {
		for( int i = 0; i < s.ColumnCount; i = i + 1 ) {
		    IO.Std.err.print( "" + s.Name[i] + ": " + s.String[i] + " " );
		}
		IO.Std.err.println();
	    }
	}       
    }
}