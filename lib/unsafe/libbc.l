
// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import stream;
import library;

namespace System is
    /// A dynamically loaded shared object
    class BitcodeLibrary isa Library is
	/// construct and load a shared object
	/// \param so_name path to shared object to open
	/// \throw LibraryException if the library cannot be opened
	void init( String so_name ) is
            super.init();

	    if !so_name.endsWith(".bc") then
		so_name = so_name + ".bc";
	    fi

	    if !so_name.startsWith('/') then
		so_name = IO.File.WorkingDirectory + "/" + so_name;
	    fi

	    this.so_name = so_name;

	    native.__load_module(so_name.toCString());
	si

	/// locate a class in any shared object and return a Class object representing it
	/// \param class_name the fully qualified class name to load
	/// \return a Class object representing the requested class
	/// \throw LibraryException if the class cannot be found
	/// \attention template classes and specializations cannot be loaded by this method
	static Class findClassAll( String class_name ) is
	    if class_name == null then
		throw new LibraryException( "no class name supplied" );
	    fi

	    return findClassFromVTableNameAll( decorateVTable(class_name) );
	si

	/// locate a class in any shared object from its vtable function name and return a Class object representing it
	/// \param vtable_function the decorated get vtable function name for the class name to load
	/// \return a Class object representing the requested class, if present in the shared object or null otherwise
	/// \throw LibraryException if the vtable cannot be found
	static Class findClassFromVTableNameAll( String vtable_function ) is
	    int ptr ptr v = cast int ptr ptr( native.__call_function( vtable_function.toCString() ) );

	    if v != null then
		// create and return a new class from the vtable returned by the get vtable function:
		return new Class( v );
	    else

		// couldn't find the vtable in any loaded library:
		throw new LibraryException( "class " + vtable_function + " not found" );
	    fi
	si

	/// locate a class in this shared object and return a Class object representing it
	/// \param class_name the fully qualified class name to load
	/// \return a Class object representing the requested class
	/// \throw LibraryException if the class cannot be found
	/// \attention template classes and specializations cannot be loaded by this method
	Class findClass( String class_name ) is
	    return findClassAll( class_name );
	si
    si
si