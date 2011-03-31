#K

import object;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System is
    /// Represents a class in the program.
    class Class is
	int ptr ptr _vtable;

        /// Construct an empty Class
	void init() is
	    super.init();
	    _vtable = null;
	si

        /// Construct a Class representing the class of the supplied Object
        /// \param o Object to return a Class for
	void init( Object o ) is
	    super.init();
	    _vtable = o._get_vtable();
	si

        /// Construct a Class representing the class with the supplied VTable pointer
        /// \param vt pointer to VTable slot 0
	void init( int ptr ptr vt ) is
	    super.init();
	
	    _vtable = vt;
	si

	/// Accessor: set int ptr ptr VTable = vt
        /// Set the VTable pointer for this Class
        /// \param vt pointer to VTable slot 0
	/// \attention this sets the VTable in this Class object, it does not affect the VTable of the underlying class that this Class object describes
	set int ptr ptr VTable = vt is
	    _vtable = vt;
	si

	/// Accessor: get int ptr ptr VTable
        /// Get the VTable pointer for this Class
        /// \return pointer to VTable slot 0
	get int ptr ptr VTable is
	    return _vtable;
	si

	/// Accessor: get int ObjectSize
        /// Get the number of bytes needed to store an instance of this class
	get int ObjectSize is
	    if _vtable != null then
		return cast int([_vtable - 1]);
	    else
		return 0;
	    fi
	si

        /// Return a pointer to this Class's super class's VTable slot 0
	int ptr ptr _parent() is
	    return cast int ptr ptr([_vtable]);
	si

	/// Accessor: get Class Super
        /// Get a Class representing this class's super class
        /// \return a Class object if this Class has a super class, null otherwise
	get Class Super is
	    Class result;
	    int ptr ptr vt = _parent();
	    if vt != null then
		return new Class( vt );
	    else
		return null;
	    fi
	si

	/// Accessor: get word ptr TypeTable
	/// Get a pointer to the type table for this class
	get int ptr TypeTable is
	    if _vtable != null then
		return cast int ptr([_vtable+1]);
	    else
		return null;
	    fi
	si

	/// Accessor: get char ptr NameC
        /// Get this class's fully qualified name as a C-string
	get char ptr NameC is
	    if _vtable != cast int ptr ptr(0) then
		return cast char ptr([_vtable - 2]);
	    else
		return `null`;
	    fi
	si

	/// Accessor: get String Name
        /// Get this Class's fully qualified name
	get String Name is
	    return new String( getNameC() );
	si

	String toString() is
	    return "class " + getName();
	si

        /// Is this Class the same class as given Class or one of its super classes?
        /// \param c Class to compare
	bool likeMe( Class c ) is
	    if this == null || c == null then
		return false;
	    fi

	    // native.printf( `'%s' is instance of '%s'?\n`, toCString(), o.toCString() );

	    do
		int ptr ptr vtable_c = c._vtable;
		if _vtable == vtable_c then
		    return true;
		fi
		c = c.Super;
		if c == null then return false; fi
	    od
	si

        /// Is this Class the same class as the class of supplied Object or one of its super classes?
        /// \param o Object to compare
	bool likeMe( Object o ) is
	    if this == null || o == null then
		return false;
	    fi

	    // native.printf( `'%s' is instance of '%s'?\n`, toCString(), o.toCString() );

	    int ptr ptr vtable_o = o._get_vtable();

	    do
		if _vtable == vtable_o then
		    return true;
		fi
		vtable_o = cast int ptr ptr([vtable_o]);

		if vtable_o == null then return false; fi
	    od
	si
    
	/// Create an instance of the class this Class represents.
	/// \attention the created object may not be completely constructed if its class does not implement init()
	/// and behaviour is undefined if the class does not inherit from Object
	/// \return a new instance of this class
	Object create() is
	    /// FIXME: original reason for these crazy pointer types was because 64 bit target had no
	    /// 64 bit integer type but had 64 bit pointers:
	    int ptr ptr ptr p = cast int ptr ptr ptr(native.GC_malloc(getObjectSize()));
            [p] = _vtable;

	    Object o = cast Object(p);
	    o.init();
	    return o;
	si

	get bool IsArray is
	    return Name.startsWith( "Generic.Array<" );
	si
    si
si
