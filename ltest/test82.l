import stream;

namespace Test82 {
    class Main {

	void init() {
	    int[] a;
	    int i;
	    
	    try {
		a = new int[100];
		
		for( i = 0; i < 200; i = i + 1 ) {
		    a[i] = i;
		}
	    } catch( System.ArrayBoundsException e1 ) {
		IO.Std.err.println( "caught exception, i now " + i );
		IO.Std.err.println( e1 );	    
	    }
	    
	    try {
		for( i = 0; i < 200; i = i + 1 ) {
		    IO.Std.err.println( "a[" + i + "] = " + a[i] );
		}
	    } catch( System.Exception e2 ) {
		IO.Std.err.println( "caught exception, i now " + i );
		IO.Std.err.println( e2 ); 
	    }
	    
	    try {
		for( i = 50; i > -50; i = i - 1 ) {
		    IO.Std.err.println( "about to read a[" + i + "]..." );
		    IO.Std.err.println( "a[" + i + "] = " + a[i] );
		}
	    } catch( System.Exception e3 ) {
		IO.Std.err.println( "caught exception, i now " + i );
		IO.Std.err.println( e3 ); 
	    }

	    IO.Std.err.println( "done" );
	}

    }
}