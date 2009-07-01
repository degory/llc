
namespace System {
    class Exit {
	static Object[] shutdown_objects;
	static int next_index;

	static Object add( Object o ) { 
	    if( shutdown_objects == null ) {
		shutdown_objects = new Object[64];
	    }

	    shutdown_objects[next_index] = o;
	    next_index = next_index + 1;

	    return o;
	}

	static void exit(int status) { 
	    shutdown();
	    native.exit(status);
	}

	static void shutdown() {
	    if( shutdown_objects == null ) {
		return;
	    }

	    for( int i = 0; i < shutdown_objects.length; i = i + 1 ) {
		Object o = shutdown_objects[i];
		if( o != null ) {
		    try {
			shutdown_objects[i].dispose();
		    } catch( System.Exception e ) {
			// do nothing
		    }
		}
	    }
	}
    }
}