#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved



import stream;
import gproc;
import "dl";

namespace System {
    /// A dynamically loaded shared object
    class NativeLibrary extends Library {
	/// handle returned by dlopen for the shared object
	word h;

	/// path to file holding shared object
	String so_name;

	static Library self;

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

	private void init(word h) {
	    this.h = h;
	}

	static get NativeLibrary Self {
	    if( self == null ) {
		self = new NativeLibrary(0w);
	    }

	    return self;
	}

	/// locate a class in this shared object and return a Class object representing it
	/// \param class_name the fully qualified class name to load
	/// \return a Class object representing the requested class
	/// \throw LibraryException if the class cannot be found
	/// \attention template classes and specializations cannot be loaded by this method
	Class findClass( String class_name ) {
	    if( class_name == null ) {
		throw new LibraryException( "no class name supplied" );
	    }
	  
	    return findClassFromVTableName( decorateVTable(class_name) );
	}

	/// locate a class in this shared object from its vtable function name and return a Class object representing it
	/// \param vtable the decorated get vtable function name for the class name to load
	/// \return a Class object representing the requested class, if present in the shared object or null otherwise
	/// \throw LibraryException if the vtable cannot be found
	Class findClassFromVTableName( String vtable ) {
	    word v = 0w;

	    if( h != 0w ) {
		// look up get vtable function in this library only first:
		v = cast word( native.dlsym( h, vtable.toCString() ) );
	    }

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
	static String dlerror() {
	    char ptr s = cast char ptr(native.dlerror());
	    if( s != null ) {
		return new String( s );
	    } else {
		return null;
	    }
	}
    }
}