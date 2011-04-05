#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import stream;
// import gproc;

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
    class BitcodeLibrary extends Library {
	/// path to file holding shared object
	String so_name;

	BitcodeLibrary self;

	/// construct and load a shared object
	/// \param so_name path to shared object to open
	/// \throw LibraryException if the library cannot be opened
	void init( String so_name ) {
            if( so_name == null ) {
                 return;
            }

	    if( !so_name.endsWith(".bc") ) {
		so_name = so_name + ".bc";
	    }

	    if( !so_name.startsWith('/') ) {
		so_name = IO.File.WorkingDirectory + "/" + so_name;
	    }

	    this.so_name = so_name;

	    native.__JIT_load_module(so_name.toCString());
	}

	/// locate a class in any shared object and return a Class object representing it
	/// \param class_name the fully qualified class name to load
	/// \return a Class object representing the requested class
	/// \throw LibraryException if the class cannot be found
	/// \attention template classes and specializations cannot be loaded by this method
	static Class findClassAll( String class_name ) {
	    if( class_name == null ) {
		throw new LibraryException( "no class name supplied" );
	    }

	    return findClassFromVTableNameAll( decorateVTable(class_name) );
	}

	/// locate a class in any shared object from its vtable function name and return a Class object representing it
	/// \param vtable_function the decorated get vtable function name for the class name to load
	/// \return a Class object representing the requested class, if present in the shared object or null otherwise
	/// \throw LibraryException if the vtable cannot be found
	static Class findClassFromVTableNameAll( String vtable_function ) {
	    int ptr ptr v = cast int ptr ptr( native.__JIT_call_function( vtable_function.toCString() ) );

	    if( v != null ) {
		// create and return a new class from the vtable returned by the get vtable function:
		return new Class( v );
	    } else {

		// couldn't find the vtable in any loaded library:
		throw new LibraryException( "class " + vtable_function + " not found" );
	    }
	}

	/// locate a class in this shared object and return a Class object representing it
	/// \param class_name the fully qualified class name to load
	/// \return a Class object representing the requested class
	/// \throw LibraryException if the class cannot be found
	/// \attention template classes and specializations cannot be loaded by this method
	Class findClass( String class_name ) {
	    return findClassAll( class_name );
	}

 	static get BitcodeLibrary Self {
	    if( self == null ) {
		self = new BitcodeLibrary(null);
	    }

	    return self;
	}

    }
}