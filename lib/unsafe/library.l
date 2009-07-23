

import stream;
import gproc;
import "dl";

namespace System {
    /// Thrown for errors with shared objects
    class LibraryException extends RuntimeException {
	/// construct a new LibraryException
	/// \param message the error message for this LibraryException
	void init( String message ) {
	    super.init( message );
	}
    }

    /// A dynamically loaded shared object
    class Library {
	/// handle returned by dlopen for the shared object
	word h;

	/// path to file holding shared object
	String so_name;

	/// construct and load a shared object
	/// \param so_name path to shared object to open
	/// \throw LibraryException if the library cannot be opened
	void init( String so_name ) {
	    if( !so_name.endsWith(".so") ) {
		so_name = so_name + ".so";
	    }

	    if( !so_name.startsWith('/') ) {
		so_name = IO.File.WorkingDirectory + "/" + so_name;
	    }

	    this.so_name = so_name;

	    h = cast word(native.dlopen(so_name.toCString(),257)); // 257 = lazy binding + make symbols global 

	    if( h == 0w ) {
		throw new LibraryException( "could not open library " + so_name + ": " + dlerror() );
	    }
	}

	/// convert a human readable class name to an internal get vtable function name. 
	/// \param class_name fully qualified class name 
	/// \return name of a get vtable function
	static String decorateVTable( String class_name ) {
	    // get vtable function name is the GCC 3.0 mangled class name, minus any _Z prefix, with
	    // __get_vtable_ prepended

	    // separate off all qualifiers:
	    var q = class_name.split('.');

	    var result = new StringBuffer( "__get_vtable_" );

	    // GCC decoration:
	    if( q.length == 0 ) {
		result.append( class_name.Length );
		result.append( class_name );
		return result;
	    }

	    result.append( 'N' );

	    foreach( var s; q.elements() ) {
		result.append( s.Length );
		result.append( s );
	    }

	    result.append( 'E' );

	    return result;
	}

	/// locate a class in this shared object and return a Class object representing it
	/// \param class_name the fully qualified class name to load
	/// \return a Class object representing the requested class
	/// \throw LibraryException if the class cannot be found
	/// \attention template classes and specializations cannot be loaded by this method
	Class loadClass( String class_name ) {
	    if( class_name == null ) {
		throw new LibraryException( "no class name supplied" );
	    }
	  
	    return loadClassFromVTableName( decorateVTable(class_name) );
	}

	/// locate a class in this shared object from its vtable function name and return a Class object representing it
	/// \param vtable_name the decorated get vtable function name for the class name to load
	/// \return a Class object representing the requested class, if present in the shared object or null otherwise
	/// \throw LibraryException if the vtable cannot be found
	Class loadClassFromVTableName( String vtable ) {
	    // look up get vtable function in this library only first:
	    word v = cast word( native.dlsym( h, vtable.toCString() ) );

	    if( v == 0w ) {
		// failing that search all libraries:
		v = cast word( native.dlsym( 0, vtable.toCString() ) );
	    }

	    if( v != 0w ) {
		// make a new proc reference from the get vtable function that returns the slightly odd type
		// expected by System.Class.init():
		var p = new Proc<int ptr ptr proc()>(v);

		// create and return a new class from the vtable returned by the get vtable function:
		return new Class( p() );
	    } else {

		// couldn't find the vtable in any loaded library:
		throw new LibraryException( "no class " + vtable + " found in library " + so_name + ": " + dlerror() );
	    }
	}

	/// get the last error reported by libdl as a string
	/// \return the error string reported by dlerror() or null if no error occurred
	String dlerror() {
	    char ptr s = cast char ptr(native.dlerror());
	    if( s != null ) {
		return new String( s );
	    } else {
		return null;
	    }
	}
    }
}