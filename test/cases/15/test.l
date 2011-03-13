#C
namespace Test15 {
    class Main {
        void init() {
	    System.StringBuffer b = new System.StringBuffer( `testing` );
	    System.StringBuffer c = new System.StringBuffer( ` testing` );

	    native.printf( `b.opAdd b is %lp: \n`, b );
	    b.opAdd( `testing 1` );
	    native.printf( `c.opAdd c is %lp: \n`, c );
	    c.opAdd( `testing 2` );

	    native.printf( `plus operator, b is %lp, c is %lp: \n`, b, c );

	    System.String d = b + c;

	    native.printf( `after d is %lp\n`, d );
	}
    }
}