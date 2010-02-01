pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System {
    class Exit {

	const int NUM_LEVEL = 3;

	static Object[][] shutdown_objects;
	static int[] next_index;

	static Object add( int level, Object o ) { 
	    if( shutdown_objects == null ) {
		next_index = new int[NUM_LEVEL];
		shutdown_objects = new Object[][NUM_LEVEL];
		for( int i = 0; i < NUM_LEVEL; i = i + 1 ) {
		    shutdown_objects[i] = new Object[32];
		}
	    }

	    int ni = next_index[level];
	    shutdown_objects[level][ni] = o;
	    next_index[level] = ni + 1;

	    return o;
	}

	static String last_check = "none";
	/*
	static void check(String s) {
	    //	    return;

	    if( shutdown_objects != null ) {
		if( shutdown_objects[2].length != 32 ) {
		    native.printf( `%s->%s: level 2 length is %d\n`, last_check.toCString(), s.toCString(), shutdown_objects[2].length ); native.__flush_stdout();
		    char ptr p;
		    [p] = 'x';
		}
		last_check = s;
	    }
	}
	*/

	static Object add( Object o ) {
	    return add( 0, o );
	}

	static void exit(int status) { 
	    shutdown();
	    native.exit(status);
	}

	static void shutdown() {
	    if( shutdown_objects == null ) {
		return;
	    }

	    for( int j = NUM_LEVEL-1; j >= 0; j = j - 1 ) {
		Object[] so = shutdown_objects[j];

		for( int i = so.length-1; i >= 0; i = i - 1 ) {
		    Object o = so[i];

		    if( o != null ) {
			try {
			    o.dispose();
			} catch( System.Exception e ) {
			    native.printf( `caught %s\n`, e.Class.Name.toCString() ); native.__flush_stdout();
			    // do nothing
			}
		    }
		}
	    }
	}
    }
}