#C
import stream;

namespace Test89 {
    class Main {
	void init() {
	    int a = 12345, b = 67890, c;

	    int ptr pa = a.address;
	    int ptr pb = b.address;
	    IO.Std.err.println( "a = " + a + ", [a.address] = " + [pa] );
	    IO.Std.err.println( "a = " + b + ", [b.address] = " + [pb] );
	}
    }
}