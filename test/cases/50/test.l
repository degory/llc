#C
namespace Test50 {
    class Main {
	void init() {
	    try {
		native.puts( `aaaa` );
	    } catch( System.Exception e ) {
		return x;

		try {
		    native.puts( `bbbb` );
		} catch( System.Exception f ) {
		    native.puts( `bbbb` );
		} catch( System.Exception g ) {
		    native.puts( `bbbb` );

		    return; // throw return
		}

		throw continue;
	    } finally {
		// catch return
		return y; // throw return

		throw continue;
	    }

	    /* catch continue */
	        // do nothing
	    /* catch return  */
   	        // return object
	}
    }
}