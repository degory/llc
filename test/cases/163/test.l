#C

import stream;

namespace Test163 {
    use Generic.List;

    class Main {
	void init() {
	    var a = new int[10];
	    var aa = new int[][10];
	    int i;

	    for( i = 0; i < a.length; i = i + 1 ) {
		a[i] = i;
		aa[i] = new int[10];
	    }

	    Generic.Array<int> b = a;

	    a = b;

	    IO.Std.err.println( "a is: " + a.toString() );
	    IO.Std.err.println( "b is: " + b );
	    foreach( var j; b.elements() ) {
		IO.Std.err.println( "b have: " + j );
	    }

	    for( i = 0; i < b.Length; i = i + 1 ) {
		IO.Std.err.println( "at b " + i + " have: " + b[i].toString() );
	    }

	    List<int> c = b;
	    for( i = 0; i < c.Length; i = i + 1 ) {
		IO.Std.err.println( "at c " + i + " have: " + c[i].toString() );
	    }

	    for( i = 0; i < aa.length; i = i + 1 ) {
		IO.Std.err.println( "at aa " + i + " have: " + aa[i] );
	    }
	}
    }
}