import stream;

namespace Test52 {
    class Main {
        void init() {
	    try {
		test0();
	    } catch( ETest e ) {
		IO.Std.err.println( "XXX: caught ETest: " + e );
	    } catch( System.Exception f ) {
		IO.Std.err.println( "XXX: caught Exception: " + f );
	    } finally {
		IO.Std.err.println( "XXX: finally" );
	    }
	}

	void test0() {
	    IO.Std.err.println( "XXX: in test 0..." );
	    // throw new ETest( "XXX: ETest exception" );
	    throw new System.Exception( "XXX: Exception" );
	}
    }

    class ETest extends System.Exception {
	void init( System.String s ) {
	    super.init( s );
	}
    }
}