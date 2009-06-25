namespace Test17 {
    class Main {
        void init() {
	    System.StringBuffer b = new System.StringBuffer( `testing` );

	    native.printf( `XXXXX b is %lp: \n`, b );
	    char ptr c = ` testing`;

	    native.printf( `XXXXX c is %lp\n`, c );
	    native.printf( `XXXXX c is '%s'\n`, c );

	    b.append( c );

	    native.printf( `XXXXX after append b is %lp\n`, b );

	    native.printf( `XXXXX after append b is '%s'\n`, b.toCString() );

	    // System.String d = new System.String( c );
	    // b.opAdd( d );

	    b.opAdd( c );

	    native.printf( `XXXXX after b is %lp\n`, b );
	}
    }
}