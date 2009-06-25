import stream;

namespace Test62 {
    class Main {
	const int DX = 100, DY = 100, DZ = DX * DY;
	static char ptr x = null;

	void init() {
	    int i, j, k;
	    int[][] a;
	    int[][] b;

	    a = new int[][DX];
	    b = new int[][DX*20];

	    x = cast char ptr(a);

	    for( i = 0; i < DX; i = i + 1 ) {
		a[i] = new int[DY];
		b[i] = new int[DY*20];
	    }

	    for( i = 0; i < DX; i = i + 1 ) {
		b[i] = null;
		b[i*2] = new int[DY];
		b[i*3] = new int[DY*30];
		// IO.Std.err.println( "i: " + i );
		for( j = 0; j < DY; j = j + 1 ) {
		    // IO.Std.err.println( "j: " + j );
		    for( k = 0; k < DZ; k = k + 1 ) {
			test0( a, i, j, k );
		    }
		}
	    }

	    for( i = 0; i < DX; i = i + 1 ) {
		for( j = 0; j < DY; j = j + 1 ) {
		    if( a[i][j] != 0 ) {
			b[i*2] = new int[DY];
			b[i] = null;
			// IO.Std.err.println( "" + i + " * " + j + " = " + a[i][j] );
		    }
		}
	    }
	}

	void test0( int[][] a, int i, int j, int k ) { 
	    if( cast<char ptr>(a) != x ) {
		native.printf( `XXXX a is %p\n`, a );
		native.__flush_stdout();
		//} else {
		// native.printf( `a %p = %p\n`, x, a );
	    }
	    test1( a, i, j, k );
	}

	void test1( int[][] a, int i, int j, int k ) { 
	    //native.printf( `a is %p\n`, a );
	    //native.__flush_stdout();
	    //native.printf( `a[i] is %p\n`, a[i] );
	    //native.__flush_stdout();
	    if( i * j == k ) {
		// IO.Std.err.println( "caught: " + se );
		a[i][j] = k;
	    }
	}

    }
}