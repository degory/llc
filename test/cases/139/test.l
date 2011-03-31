#C

import stream;

namespace Test139 {
    use IO.Std;

    class Main {
	void init() {
	    Test t = new Test(10);
	    int i;

	    for( i = 0; i < 10; i = i + 1 ) {
		t.Int[i] = i;
	    }

	    for( i = 0; i < 10; i = i + 1 ) {
		IO.Std.err.println( "at " + i + ": " + t.Int[i] );
	    }	   

	    for( i = 0; i < 10; i = i + 1 ) {
		t.String[i] = i.toString();
	    }

	    for( i = 0; i < 10; i = i + 1 ) {
		IO.Std.err.println( "at " + i + ": " + t.String[i] );
	    }	   
	}
    }

    class Test extends System.Object {
	int[] value;

	void init( int length ) {
	    value = new int[length];
	}
	int opGetInt( int i ) {
	    return value[i];
	}       

	void opSetInt( int i, int v ) {
	    value[i] = v;
	}

	System.String opGetString( int i ) {
	    return value[i].toString();
	}

	void opSetString( int i, System.String v ) {
	    value[i] = v.toInt();
	}       
    }
}