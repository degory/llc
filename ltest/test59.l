import stream;

namespace Test59 {
    class Main {
	const int DX = 10, DY = 10, DZ = DX * DY;

	void init() {
	    int i, j, k;
	    int[][] a;

	    a = new int[][DX];

	    for( i = 0; i < 10; i = i + 1 ) {
		a[i] = new int[DY];
	    }

	    for( i = 0; i < DX; i = i + 1 ) {
		IO.Std.err.println( "i: " + i );
		for( j = 0; j < DY; j = j + 1 ) {
		    IO.Std.err.println( "j: " + j );
		    for( k = 0; k < DZ; k = k + 1 ) {
			test0( a, i, j, k );
		    }
		}
	    }

	    for( i = 0; i < DX; i = i + 1 ) {
		for( j = 0; j < DY; j = j + 1 ) {
		    if( a[i][j] != 0 ) {
			IO.Std.err.println( "" + i + " * " + j + " = " + a[i][j] );
		    }
		}
	    }
	}

	void test0( int[][] a, int i, int j, int k ) { 
	    try {
		test1( i, j, k );
	    } catch( System.Exception se ) {
		IO.Std.err.println( "caught: " + se );
		a[i][j] = k;
	    }
	}

	void test1( int i, int j, int k ) {
	    IO.Std.err.println( "i: " + i + ", j: " + j + ", k: " + k );

	    if( i * j == k ) {
		IO.Std.err.println( "throw..." );
		throw new System.Exception( "" + i + " * " + j + " = " + k );
	    }
	}
    }
}