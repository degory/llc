#K

import klass;
import string;

pragma NoWarnUnsafe, NoMarkUnsafe, NoWarnHide, NoWarnResolve;

namespace System is
    /// Root of the standard L class heirarchy

    class Object is
        public const char
	    TYPE_UNKNOWN = 0c,
	    TYPE_1BYTE = 1c,
	    TYPE_4BYTE = 4c,
	    TYPE_8BYTE = 8c,
	    TYPE_OBJECT = 128c,
	    TYPE_ARRAY = 129c,
	    TYPE_POINTER = 130c;

        /// Internal interface for garbage collector. Ensures that any exceptions thrown by dispose() are caught
	// DO NOT MOVE: runtime depends on the _dispose() method occupying the first slot in the vtable:
        
	void _dispose() is
	    @Virtual;
 
	    if this == null then
	        // FIXME: is this a GC issue?
	        return;
	    fi

	    try 
	        dispose();
	    catch System.Exception se 
		Startup.uncaughtException( se );
	    yrt
	end

	// DO NOT MOVE: runtime depends on the _implements() method occupying the second slot in the vtable
	bool _implements(char ptr v) is
	    @Virtual;

	    throw new System.Exception("internal error: Object._implements() called");
	end

        /// Override dispose() to deallocate any resources held by this object. Can be called explicitly as well as by garbage collector when Object is
	/// deallocated. As a result, implementers should be prepared for dispose() to be called repeatedly
	void dispose() is    	    
	end

        /// Constructor
	void init() is
	end

	/// Returns a shallow copy
        Object clone() is
	    word ptr self = cast word ptr(this);
      	    int count = getObjectSize() >> System.Environment.WORD_TO_BYTE_SHIFT;
	    word ptr result = cast word ptr(native.GC_malloc(getObjectSize()));
            // native.printf( `%p Object clone\n`, result );

	    word ptr save_result = result;

            while count > 0 do
		[result] = [self];

		result = result + 1;
		self = self + 1;
		count = count - 1;
	    od

	    return cast Object(save_result);
	end

	/// Check that supplied bool argument is true otherwise throw an AssertException with supplied message
	/// \param v value asserted to be true
	/// \param message message included in thrown exception if asserted value is false
        /// \throw AssertException
	static void assert( bool v, String message ) is
	    if !v then
		throw new AssertException(message);
	    fi
	end

        /// Check that supplied bool argument is true otherwise throw an AssertException with a standard message
        /// \param v value asserted to be true
        /// \throw AssertException
	static void assert( bool v ) is
	    assert( v, "assertion failed" );
        end

        /// Throw an AssertException with supplied message
        /// \param message message displayed
        /// \throw AssertException
	static void assert( String message ) is
	    assert(false, message);
	end

	/// Return a hash value for this Object. Hash values must be equal for equal Objects and should differ for unequal Objects	    
	int hash() is
	    return cast int(this);
	end

	/// Return a pointer to this Object's type table
	protected char ptr _get_ttable() is
	    int ptr ptr vtable = _get_vtable();
	
	    return cast char ptr([vtable-3]);
	end

	/// Return the size of this Object in bytes   
	get int ObjectSize is
	    int ptr ptr vtable;
	    vtable = cast int ptr ptr(_get_vtable());
	    if vtable != null then
		return cast int([vtable - 1]);
	    else
		return 0;
	    fi
	end
    
	/// return this Object's class name as a C-string
	get char ptr ClassNameC is
	    int ptr ptr vtable = _get_vtable();
	    if vtable != null then
		return cast char ptr([vtable - 2]);
	    else
		return `null`;
	    fi
	end

	/// Return a pointer to this Object's type table
	get char ptr TypeTable is
	    int ptr ptr _vtable = _get_vtable();
	    if _vtable != null then
		return cast char ptr([_vtable - 3]);
	    else
		return null;
	    fi
	end

	/// Return this Object's class name
	get String ClassName is
	    return new String( getClassNameC() );
	end

	/// Return a human readable string representing this Object
	String toString() is
	    StringBuffer result;
	    int i;
	    result = new StringBuffer();
	    result.append( getClassNameC() );
	    // result = new StringBuffer( getClassNameC() );
	    result.append( ` @` );
	    result.append( hash(), 16 );
	
	    return result;
	end

	/// Attempt to convert this Object to an int. Throws CastException.
	int toInt() is
	    throw new CastException( "cannot convert " + Class.Name + " to int" );
	end

	/// Print this Object's string representation to C standard output
	void print() is
	    if this == null then
		// called statically by exception handling in runtime so this could happen
		native.printf( `null` );
	    else
		char ptr p = this.toCString();
		native.printf( `%s`, p );
	    fi
	end

	/// Return a human readable C-string representing this Object
	char ptr toCString() is
	    return toString().toCString();
	end

	/// compare this Object to Object o and return true if they refer to the same object.
	/// \param o Object to compare this Object to
	bool equals( Object o ) is
	    return cast word(this) == cast word(o);
	end

        bool opEquals( Object o ) is
	    return cast word(this) == cast word(o);
	end

	int opCompare( Object o ) is
	    word a = cast word(this);
	    word b = cast word(o);

	    if a > b then
	        return 1;
	    elif b > a then
	        return -1;
	    else
	        return 0;
	    fi	        
	end

	/// compare Object o to Object p and return true if they compare equal.
	/// \param o Object to compare
	/// \param p Object to compare
	static bool equals( Object o, Object p ) is
	    if o == null then
		return p == null;
	    else
		return o.equals(p);
	    fi
	end
    	
	/// return a pointer to this Object's vtable
	protected int ptr ptr _get_vtable() is
	    if this == null then
		return null;
	    else
		return [cast int ptr ptr ptr(this)];
	    fi
	end
	
	/// return a Class representing this Object's class
	get Class Class is
	    return new Class(this);
	end

	/// return true if Object o is an instance of the same class as or a sub-class of this Object's class
	/// \param o Object to test if instance
	bool likeMe(Object o) is
	    if this == null || o == null then
		//native.printf( `null is instance of anything\n` );
		//native.__flush_stdout();
		return true;
	    fi

	    //native.printf( `'%s' is instance of '%s'?\n`, toCString(), o.toCString() );

	    int ptr ptr vtable_this = _get_vtable();
	    int ptr ptr vtable_o = o._get_vtable();

	    while true do
		if vtable_this == vtable_o then
		    //native.printf( `'%s' is instance of '%s': YES\n`, toCString(), o.toCString() );
		    //native.__flush_stdout();
		    return true;
		fi
		vtable_o = cast int ptr ptr([vtable_o]);
		if vtable_o == null then break; fi
	    od

	    //native.printf( `'%s' is instance of '%s': NO\n`, toCString(), o.toCString() );
	    //native.__flush_stdout();
	    return false;
	end

	/// accessor: get Object ptr ObjectValuesPointer
	/// internal method used by Util.Walk to obtain a pointer to the list of values in a collection that is implemented with pointers
	/// \return a pointer to this object's value list
	get Object ptr ObjectValuesPointer is
	    return null;
        end

	/// accessor: get Object ptr ObjectValuesPointer
	/// internal method used by Util.Walk to obtain the length of the list of values in a collection that is implemented with pointers
	get int ObjectValuesLength is
	    return 0;
	end

	/// get memory used by this object
	/// \return number of bytes occupied by this object not including any referenced objects
	get int MemoryUse is
	    return ObjectSize;
	end
    end
end
