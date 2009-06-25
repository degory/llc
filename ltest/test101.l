
import stream;

namespace Test101 {
    class Main {
	void init() {
	    System.String s, t, u;

	    s = null;
	    t = "testing";
	    u = "testing";

	    IO.Std.err.println( "null - s =~ null: " + (s =~ null) );
	    IO.Std.err.println( "null - s !~ null: " + (s !~ null) );
	    IO.Std.err.println( "not null - t =~ null: " + (t =~ null) );
	    IO.Std.err.println( "not null - t !~ null: " + (t !~ null) );
	}
    }
}