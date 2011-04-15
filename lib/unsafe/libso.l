// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import stream;
import gproc;
import library;
import "dl";

namespace System is
    /// A dynamically loaded shared object
    class NativeLibrary isa Library is
	/// handle returned by dlopen for the shared object
	word h;
	static NativeLibrary self;

	/// construct and load a shared object
	/// \param so_name path to shared object to open
	/// \throw LibraryException if the library cannot be opened
	void init( String so_name ) is
            super.init();

	    if !so_name.endsWith(".so") then
		so_name = so_name + ".so";
	    fi

	    if !so_name.startsWith('/') then
		so_name = IO.File.WorkingDirectory + "/" + so_name;
	    fi

	    this.so_name = so_name;

	    h = cast word(native.dlopen(so_name.toCString(),257)); // 257 = lazy binding + make symbols global 

	    if h == 0w then
		throw new LibraryException( "could not open library " + so_name + ": " + dlerror() );
	    fi
	si

	private void init(word h) is
	    this.h = h;
	si

	static get NativeLibrary Self is
	    if self == null then
		self = new NativeLibrary(0w);
	    fi

	    return self;
	si

	/// locate a class in this shared object and return a Class object representing it
	/// \param class_name the fully qualified class name to load
	/// \return a Class object representing the requested class
	/// \attention template classes and specializations cannot be loaded by this method
	Class findClassQuiet( String class_name ) is
	    if class_name == null then
		throw new LibraryException( "no class name supplied" );
	    fi
	  
	    return findClassFromVTableName( decorateVTable(class_name), false );
	si

	/// locate a class in this shared object and return a Class object representing it
	/// \param class_name the fully qualified class name to load
	/// \return a Class object representing the requested class
	/// \throw LibraryException if the class cannot be found
	/// \attention template classes and specializations cannot be loaded by this method
	Class findClass( String class_name ) is
	    if class_name == null then
		throw new LibraryException( "no class name supplied" );
	    fi
	  
	    return findClassFromVTableName( decorateVTable(class_name), true );
	si

	/// locate a class in this shared object from its vtable function name and return a Class object representing it
	/// \param vtable the decorated get vtable function name for the class name to load
	/// \return a Class object representing the requested class, if present in the shared object or null otherwise
	/// \throw LibraryException if the vtable cannot be found
	Class findClassFromVTableName( String vtable, bool throw_if_not_found ) is
	    word v = 0w;

	    if h != 0w then
		// look up get vtable function in this library only first:
		v = cast word( native.dlsym( h, vtable.toCString() ) );
	    fi

	    if v == 0w then
		// failing that search all libraries:
		v = cast word( native.dlsym( 0, vtable.toCString() ) );
	    fi

	    if v != 0w then
		// make a new proc reference from the get vtable function that returns the slightly odd type
		// expected by System.Class.init():
		var p = new Proc<int ptr ptr proc()>(v);

		// create and return a new class from the vtable returned by the get vtable function:
		return new Class( p() );
	    elif throw_if_not_found then

		// couldn't find the vtable in any loaded library:
		throw new LibraryException( "no class " + vtable + " found in library " + so_name + ": " + dlerror() );
            else
                return null;
	    fi
	si

	/// get the last error reported by libdl as a string
	/// \return the error string reported by dlerror() or null if no error occurred
	static String dlerror() is
            // FIXME: is dlerror threadsafe?
	    char ptr s = cast char ptr(native.dlerror());
	    if s != null then
		return new String( s );
	    else
		return null;
	    fi
	si
    si
si