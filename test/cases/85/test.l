#C

import stream;

namespace Test85 {
    class Main {
        void init() {
	    Number a = new Number(123);
	    Number b = new Number(456);

	    Number c = a + b;

	    IO.Std.err.println( "c = " + c );

	    if( c =~ 579 ) {
		IO.Std.err.println( "c = 579" );
	    }

	    if( 579 =~ c ) {
		IO.Std.err.println( "579 = c" );
	    }
	}
    }

    class Number extends System.Object {
	int value;

	void init( int v ) {
	    setValue(v);
	}

	int getValue() {
	    return value;
	}

	void setValue( int v ) {
	    value = v;
	}

	System.String toString() {
	    return "N(" + value + ")";
	}

	Number opAdd( Number b ) {
	    return new Number( this.Value + b.Value );
	}

	Number opAdd( int b ) {
	    return new Number( this.Value + b );	    
	}

	Number opAddRev( int b ) {
	    return new Number( this.Value + b );
	}

	Number opSub( Number b ) {
	    return new Number( this.Value - b.Value );
	}

	Number opSub( int b ) {
	    return new Number( this.Value - b );	    
	}

	Number opSubRev( int b ) {
	    return new Number( b - this.Value );
	}

	int opCompare( Number b ) {
	    return this.value - b.value;
	}

	int opCompare( int b ) {
	    return this.value - b;
	}

	int opCompareRev( Number b ) {
	    return b.value - this.value;
	}

	bool opEquals( Number b ) {
	    return this.value == b.value;
	}

	bool opEquals( int b ) {
	    return this.value == b;
	}

	bool opEqualsRev( int b ) {
	    return this.value == b;
	}
    }
}