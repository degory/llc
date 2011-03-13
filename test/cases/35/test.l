#C
import stream;

namespace Test35 {
    class Main {
        void init() {
	    int a, b, c, d, e, f, g, h, i, j, k, l, m, n;

	    for( int x = 0; x < 33; x = x + 1 ) {
		for( int y = 0; y < 33 y = y + 1 ) {
		    for( int z = 0; z < 33; z = z + 1 ) {
			IO.Std.err.println( "x: " + x + ", y: " + y + ", z: " + z + ": " + (x * y * z) );

			d = ((((d + e) * (f + g)) * ((h + i) * (h + j)) * ((k + l) * (m * n))) *
			     (((d + e) * (f + g)) * ((h + i) * (h + j)) * ((k + l) * (m * n)))) *
			    ((((d + e) * (f + g)) * ((h + i) * (h + j)) * ((k + l) * (m * n))) *
			     (((d + e) * (f + g)) * ((h + i) * (h + j)) * ((k + l) * (m * n)))) *

			    ((((d + e) * (f + g)) * ((h + i) * (h + j)) * ((k + l) * (m * n))) *
			     (((d + e) * (f + g)) * ((h + i) * (h + j)) * ((k + l) * (m * n)))) *
			    ((((d + e) * (f + g)) * ((h + i) * (h + j)) * ((k + l) * (m * n))) *
			     (((d + e) * (f + g)) * ((h + i) * (h + j)) * ((k + l) * (m * n))));

			IO.Std.err.println( "d: " + d );
		    }
		}
	    }
	}
    }
}