import stream;

namespace Test97 {
    class Wrong {

    }

    class Main {
	static void setExpectCall( bool ec ) {
	    // check static property access for template instances:
	    Test<int>.ExpectCall = ec;
	    Test<char>.ExpectCall = ec;
	    Test<Num>.ExpectCall = ec;
	}

	void init() {
	    Test<int> ti_a = new Test<int>(1);
	    Test<int> ti_b = new Test<int>(1);
	    Test<int> ti_c = new Test<int>(2);
	    Test<int> ti_n = null;

	    Test<char> tc_a = new Test<char>('A');
	    Test<char> tc_b = new Test<char>('A');
	    Test<char> tc_c = new Test<char>('B');
	    Test<char> tc_n = null;

	    Test<Wrong> tn_a = new Test<Wrong>(null);
	    Test<Wrong> tn_b = new Test<Wrong>(null);
	    Test<Wrong> tn_c = new Test<Wrong>(null);
	    Test<Wrong> tn_n = null;
	    /*
	    Test<Num> tn_a = new Test<Num>(new Num(1));
	    Test<Num> tn_b = new Test<Num>(new Num(1));
	    Test<Num> tn_c = new Test<Num>(new Num(2));
	    Test<Num> tn_n = null;
	    */
	    IO.Std.err.println( "equals operator value tests: " );

	    // Test<int>.ExpectCall = true;

	    ExpectCall = true;

	    IO.Std.err.println( "different objects same values: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ ti_b: " + (ti_a =~ ti_b) + " (expect true)" );
	    IO.Std.err.println( "    tc_a =~ tc_b: " + (tc_a =~ tc_b) + " (expect true)" );
	    IO.Std.err.println( "    tn_a =~ tn_b: " + (tn_a =~ tn_b) + " (expect true)" );

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ ti_b: " + (ti_a !~ ti_b) + " (expect false)");
	    IO.Std.err.println( "    tc_a !~ tc_b: " + (tc_a !~ tc_b) + " (expect false)" );
	    IO.Std.err.println( "    tn_a !~ tn_b: " + (tn_a !~ tn_b) + " (expect false)" );

	    IO.Std.err.println( "different objects different values: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ ti_c: " + (ti_a =~ ti_c) + " (expect false)" );
	    IO.Std.err.println( "    tc_a =~ tc_c: " + (tc_a =~ tc_c) + " (expect false)" );
	    IO.Std.err.println( "    tn_a =~ tn_c: " + (tn_a =~ tn_c) + " (expect false)" );

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ ti_c: " + (ti_a !~ ti_c) + " (expect true)" );
	    IO.Std.err.println( "    tc_a !~ tc_c: " + (tc_a !~ tc_c) + " (expect true)" );
	    IO.Std.err.println( "    tn_a !~ tn_c: " + (tn_a !~ tn_c) + " (expect true)" );

	    ExpectCall = false;
	    IO.Std.err.println( "compare object against itself: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ ti_a: " + (ti_a =~ ti_a) + " (expect true)" );
	    IO.Std.err.println( "    tc_a =~ tc_a: " + (tc_a =~ tc_a) + " (expect true)" );
	    IO.Std.err.println( "    tn_a =~ tn_a: " + (tn_a =~ tn_a) + " (expect true)" );

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ ti_a: " + (ti_a !~ ti_a) + " (expect false)" );
	    IO.Std.err.println( "    tc_a !~ tc_a: " + (tc_a !~ tc_a) + " (expect false)" );
	    IO.Std.err.println( "    tn_a !~ tn_a: " + (tn_a !~ tn_a) + " (expect false)" );


	    IO.Std.err.println( "compare objects against literal null: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ null: " + (ti_a =~ null) + " (expect false)" );
	    IO.Std.err.println( "    tc_a =~ null: " + (tc_a =~ null) + " (expect false)" );
	    IO.Std.err.println( "    tn_a =~ null: " + (tn_a =~ null) + " (expect false)" );

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ null: " + (ti_a !~ null) + " (expect true)");
	    IO.Std.err.println( "    tc_a !~ null: " + (tc_a !~ null) + " (expect true)" );
	    IO.Std.err.println( "    tn_a !~ null: " + (tn_a !~ null) + " (expect true)" );

	    IO.Std.err.println( "compare objects against literal null, reversed: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    null =~ ti_c: " + (null =~ ti_c) + " (expect false)" );
	    IO.Std.err.println( "    null =~ tc_c: " + (null =~ tc_c) + " (expect false)" );
	    IO.Std.err.println( "    null =~ tn_c: " + (null =~ tn_c) + " (expect false)" );

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    null !~ ti_c: " + (null !~ ti_c) + " (expect true)" );
	    IO.Std.err.println( "    null !~ tc_c: " + (null !~ tc_c) + " (expect true)" );
	    IO.Std.err.println( "    null !~ tn_c: " + (null !~ tn_c) + " (expect true)" );

	    IO.Std.err.println( "compare objects against null value: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ ti_n: " + (ti_a =~ ti_n) + " (expect false)" );
	    IO.Std.err.println( "    tc_a =~ tc_n: " + (tc_a =~ tc_n) + " (expect false)" );
	    IO.Std.err.println( "    tn_a =~ tn_n: " + (tn_a =~ tn_n) + " (expect false)" );

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ ti_n: " + (ti_a !~ ti_n) + " (expect true)");
	    IO.Std.err.println( "    tc_a !~ tc_n: " + (tc_a !~ tc_n) + " (expect true)" );
	    IO.Std.err.println( "    tn_a !~ tn_n: " + (tn_a !~ tn_n) + " (expect true)" );

	    IO.Std.err.println( "compare objects against null value, reversed: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_n =~ ti_c: " + (ti_n =~ ti_c) + " (expect false)" );
	    IO.Std.err.println( "    tc_n =~ tc_c: " + (tc_n =~ tc_c) + " (expect false)" );
	    IO.Std.err.println( "    tn_n =~ tn_c: " + (tn_n =~ tn_c) + " (expect false)" );

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_n !~ ti_c: " + (ti_n !~ ti_c) + " (expect true)" );
	    IO.Std.err.println( "    tc_n !~ tc_c: " + (tc_n !~ tc_c) + " (expect true)" );
	    IO.Std.err.println( "    tn_n !~ tn_c: " + (tn_n !~ tn_c) + " (expect true)" );


	    IO.Std.err.println( "equals operator conditional tests: " );
	    ExpectCall = true;

	    IO.Std.err.println( "different objects same values: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ ti_b: " );
	    if( ti_a =~ ti_b) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tc_a =~ tc_b: " );
	    if( tc_a =~ tc_b ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tn_a =~ tn_b: " );
	    if( tn_a =~ tn_b ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ ti_b: " );
	    if( ti_a !~ ti_b) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tc_a !~ tc_b: " );
	    if( tc_a !~ tc_b ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tn_a !~ tn_b: " );
	    if( tn_a !~ tn_b ) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "different objects different values: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ ti_c: " );
	    if( ti_a =~ ti_c) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tc_a =~ tc_c: " );
	    if( tc_a =~ tc_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tn_a =~ tn_c: " );
	    if( tn_a =~ tn_c ) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }


	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ ti_c: " );
	    if( ti_a !~ ti_c) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tc_a !~ tc_c: " );
	    if( tc_a !~ tc_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tn_a !~ tn_c: " );
	    if( tn_a !~ tn_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    ExpectCall = false;

	    IO.Std.err.println( "compare object against itself: " );
	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ ti_a: " );
	    if( ti_a =~ ti_a ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tc_a =~ tc_a: " );
	    if( tc_a =~ tc_a ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tn_a =~ tn_a: " );
	    if( tn_a =~ tn_a ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
 		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ ti_a: " );
	    if( ti_a !~ ti_a ) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tc_a !~ tc_a: " );
	    if( tc_a !~ tc_a ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tn_a !~ tn_a: " );
	    if( tn_a !~ tn_a ) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "compare objects against literal null: " );

	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ null: " );
	    if( ti_a =~ null) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tc_a =~ tc_c: " );
	    if( tc_a =~ null ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tn_a =~ tn_c: " );
	    if( tn_a =~ null ) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }


	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ null: " );
	    if( ti_a !~ null ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tc_a !~ null: " );
	    if( tc_a !~ null ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tn_a !~ null: " );
	    if( tn_a !~ null ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }


	    IO.Std.err.println( "compare objects against literal null, reversed: " );
	    IO.Std.err.println( "    null =~ ti_c: " );
	    if( null =~ ti_c) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    null =~ tc_c: " );
	    if( null =~ tc_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    null =~ tn_c: " );
	    if( null =~ tn_c ) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }


	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    null !~ ti_c: " );
	    if( null !~ ti_c) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    null !~ tc_c: " );
	    if( null !~ tc_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    null !~ tn_c: " );
	    if( null !~ tn_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "compare objects against null value: " );

	    IO.Std.err.println( "  test equals: " );
	    IO.Std.err.println( "    ti_a =~ ti_n: " );
	    if( ti_a =~ ti_n) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tc_a =~ tc_c: " );
	    if( tc_a =~ tc_n ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tn_a =~ tn_c: " );
	    if( tn_a =~ tn_n ) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }


	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_a !~ ti_n: " );
	    if( ti_a !~ ti_n ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tc_a !~ tc_n: " );
	    if( tc_a !~ tc_n ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tn_a !~ tn_n: " );
	    if( tn_a !~ tn_n ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }


	    IO.Std.err.println( "compare objects against null value, reversed: " );
	    IO.Std.err.println( "    ti_n =~ ti_c: " );
	    if( ti_n =~ ti_c) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tc_n =~ tc_c: " );
	    if( tc_n =~ tc_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }

	    IO.Std.err.println( "    tn_n =~ tn_c: " );
	    if( tn_n =~ tn_c ) {
		IO.Std.err.println( "      true (expect false)" );
	    } else {
		IO.Std.err.println( "      false (expect false)" );
	    }


	    IO.Std.err.println( "  test not equal: " );
	    IO.Std.err.println( "    ti_n !~ ti_c: " );
	    if( ti_n !~ ti_c) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tc_n !~ tc_c: " );
	    if( tc_n !~ tc_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }

	    IO.Std.err.println( "    tn_n !~ tn_c: " );
	    if( tn_n !~ tn_c ) {
		IO.Std.err.println( "      true (expect true)" );
	    } else {
		IO.Std.err.println( "      false (expect true)" );
	    }



	}
    }

    class Test<T> extends System.Object {
	static bool expect_call;
	T a;

	void init( T a ) {
	    IO.Std.err.println( "T.sizeof is: " + T.sizeof );
	    this.a = a;
	}

	static void setExpectCall( bool e ) {
	    expect_call = e;
	}

	int opCompare( Test<T> b ) {
	    if( a > b.a ) {
		return 1;
	    } else if( a < b.a ) {
		return -1;
	    } else {
		return 0;
	    }
	}

	bool opEquals( Test<T> b ) {
	    if( !expect_call ) {
		IO.Std.err.println( "did not expect opEquals call here: " + this.Class.Name + " opEquals " + this + " versus " + b + ": " + (a =~ b.a) );
	    }
	    return a =~ b.a;
	}

	System.String toString() {
	    return this.Class.Name + "(" + a + ")";
	}
    }

    class Num extends System.Object {
	int a;

	void init( int a ) {
	    this.a = a;
	}

	int opCompare( Num b ) {
	    IO.Std.err.println( "Num.opCompare(" + this + "," + b + ") -> " + (b.a - a) );
	    return b.a - a;
	}

	bool opEquals( Num b ) {
	    IO.Std.err.println( "Num.opEquals(" + this + "," + b + ") -> " + (b.a == a) );
	    return a == b.a;
	}

	System.String toString() {
	    return this.Class.Name + "(" + a + ")";
	}
    }
}