#C

namespace Util {
    class Format {
	static System.String bytes( int v ) {
	    return bytes( cast long(v) );
	}
	
	static System.String bytes( long v ) {
	    // var fraction = new System.StringBuffer();
	    // var value = new System.StringBuffer();
	    var suffix = { " B", " kB", " MB", " GB" };
	    int order = 0;
	    int fraction;

	    var sign = "";
	    if( v < 0L ) {
		sign = "-";
		v = -v;
	    }

	    if( v < 1024L ) {
		return sign + v + " B";
	    } else {
		do {
		    order = order + 1;
		    fraction = cast int(v & 1023L);
		    v = v >> 10L;
		} while( v > 1024L );
	    }

	    fraction = fraction * 1000 / 10240;

	    if( fraction > 99 ) {
		fraction = 99;
	    }

	    var b = new System.StringBuffer(3);
	    b[2] = cast char(fraction % 10) + '0';
	    b[1] = cast char((fraction / 10) % 10) + '0';
	    b[0] = '.';

	    return sign + v + b + suffix[order];
	}
    }
}