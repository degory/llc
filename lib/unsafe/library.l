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
    class Library {
	/// path to file holding shared object
	protected String so_name;

	/// construct and load a shared object
	void init() {
	}

	/// convert a human readable class name to an internal get vtable function name. 
	/// \param class_name fully qualified class name 
	/// \return name of a get vtable function
	static String decorateVTable( String class_name ) {
	    // get vtable function name is the GCC 3.0 mangled class name, minus any _Z prefix, with
	    // __get_vtable_ prepended

	    // separate off all qualifiers:
	    var q = class_name.split('.');

	    var result = new StringBuffer( "__get_ctable_" );

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
    }
}