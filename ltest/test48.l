import stream;

namespace Test48 {
    class Main {
	void init() {
	    TestA a = new TestA();

	    IO.Std.err.println( "test a = " + a.test() );
	}
    }

    class TestA {
	void init() {
	}

        int test() {
	    try {
		IO.Std.err.println( "hello world 1" );

		try {
		    IO.Std.err.println( "hello world 2" );
		    return 1;
		} catch( ETest g ) {
		    IO.Std.err.println( "problem e: " + e );
		} catch( System.Exception h ) {
		    IO.Std.err.println( "problem h: " + e );
		} finally {
		    return 2;
		}
	    } catch( ETest e ) {
		IO.Std.err.println( "problem e: " + e );
	    } catch( System.Exception f ) {
		IO.Std.err.println( "problem f: " + f );
		return 3;
	    } finally {
		IO.Std.err.println( "finished" );
	    }
	}
    }

    class ETest extends System.Exception {
	void init( System.String message ) {
	    super.init(message);
	}
    }
}