#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import object;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System {
    /// Represents a class in the program.
    class Class extends Object {
	int ptr ptr _vtable;

	/// Construct an empty Class
	void init() {
	    super.init();
	    _vtable = null;
	}

	/// Construct a Class representing the class of the supplied Object
	/// \param o Object to return a Class for
	void init( Object o ) {
	    super.init();
	    _vtable = o._get_vtable();
	}

	/// Construct a Class representing the class with the supplied VTable pointer
	/// \param vt pointer to VTable slot 0
	void init( int ptr ptr vt ) {
	    super.init();
	
	    _vtable = vt;
	}

	/// Set the VTable pointer for this Class
	/// \param vt pointer to VTable slot 0
	set int ptr ptr VTable = vt {
	    _vtable = vt;
	}

	/// Get the VTable pointer for this Class
	/// \return pointer to VTable slot 0
	int ptr ptr getVTable() {
	    return _vtable;
	}

	/// Get the number of bytes needed to store an instance of this Class
	get int ObjectSize {
	    if( _vtable != null ) {
		return cast<int>([_vtable - 1]);
	    } else {
		return 0;
	    }
	}

	/// Return a pointer to this Class's super class's VTable slot 0
	int ptr ptr  _parent() {
	    return cast<int ptr ptr>([_vtable]);
	}

	/// Get a Class representing this Class's super class
	/// \return a Class object if this Class has a super class, null otherwise
	get Class Super {
	    Class result;
	    int ptr ptr vt = _parent();
	    if( vt != null ) {
		return new Class( vt );
	    } else {
		return null;
	    }
	}


	/// Get this Class's fully qualified name as a C-string
	get char ptr NameC {
	    if( _vtable != cast<int ptr ptr>(0) ) {
		return cast<char ptr>([_vtable - 2]);
	    } else {
		return `null`;
	    }
	}

	/// Get this Class's fully qualified name
	get String Name {
	    return new String( getNameC() );
	}

	/// Return a String representation of this Class
	String toString() {
	    return "class " + getName();
	}

	/*
	bool superInstanceOf( Object o ) {
	    int ptr ptr p;
	    p = _parent();
	    return p != null && (p == o._get_vtable() || superInstanceOf(o));
	}
	*/

	/// Is this Class the same class as given Class or one of its super classes?
	/// \param c Class to compare
	bool likeMe( Class c ) {
	    if( this == null || c == null ) {
		return false;
	    }

	    // native.printf( `'%s' is instance of '%s'?\n`, toCString(), o.toCString() );

	    do {
		int ptr ptr vtable_c = c._vtable;
		if( _vtable == vtable_c ) {
		    return true;
		}
		c = c.Super;
	    } while( c != null );

	    return false;

	}

	/// Is this Class the same class as given Object or one of its super classes?
	/// \param c Object to compare
	bool likeMe( Object o ) {
	    if( this == null || o == null ) {
		return false;
	    }

	    // native.printf( `'%s' is instance of '%s'?\n`, toCString(), o.toCString() );

	    int ptr ptr vtable_o = o._get_vtable();

	    do {
		if( _vtable == vtable_o ) {
		    return true;
		}
		vtable_o = cast<int ptr ptr>([vtable_o]);
	    } while( vtable_o != null );

	    return false;
	}

	/// Return a Class representing the class with the supplied fully qualified name
	/// \param name program class to locate
	/// \return a new Class object if class found, null otherwise
	static Class find( String name ) {
	    // IO.Std.err.println( "searching for class with name '" + name + "'" );

	    word ptr p = cast word ptr(native.__get_classes_info());

	    do {
		char ptr compare = cast char ptr([p]);

		if( compare == null ) {
		    break;
		}

		// native.printf( `comparing against class name '%s'...\n`, compare );

		if( name =~ compare ) {
		    return new Class( cast int ptr ptr([p+1]) );
		}
		p = p + 2;
	    } while( true );

	    return null;
	}

	/// Return a ClassIterator that steps through all classes in program returning
	/// a Class object for each class in turn
	static ClassIterator classes() {
	    return new ClassIterator(cast word ptr(native.__get_classes_info()));
	}

	/// Return a ClassIterator that steps through all classes in program returning
	/// the fully qualified name of each class in turn
	static ClassNameIterator classNames() {
	    return new ClassNameIterator(cast word ptr(native.__get_classes_info()));
	}
    }

    /// Iterates over class names in program
    class ClassNameIterator extends Object {
	word ptr current_record;
	
	/// \param p pointer to class info table
	void init( word ptr p ) {	    
	    current_record = p;
	}

	/// Are there more class names?
	bool hasMoreElements() {
	    return [current_record] != null;
	}

	/// Return next class name
	String nextElement() {
	    System.String result = new String( cast char ptr([current_record]) );
	    current_record = current_record + 2;
	}
    }

    /// Iterates over classes in program
    class ClassIterator extends Object {
	word ptr current_record;

	/// \param p pointer to class info table
	void init( word ptr p ) {
	    current_record = p;
	}

	/// Are there more classes?
	bool hasMoreElements() {
	    return [current_record] != null;
	}

	/// Return the next Class
	Class nextElement() {
	    Class result = new Class( cast int ptr ptr([current_record+1]) );
	    current_record = current_record + 2;
	    return result;
	}
    }
}
