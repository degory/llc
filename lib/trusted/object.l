#K

import klass;
import string;

pragma NoWarnUnsafe, NoMarkUnsafe, NoWarnHide, NoWarnResolve;

namespace System is
    class Object is
	// DO NOT MOVE: runtime depends on the _dispose() method occupying the first slot in the vtable:
	void _dispose() is
	    try 
	        dispose();
	    catch System.Exception se 
		Startup.uncaughtException( se );
	    yrt
	end

	void dispose() is
	end

	void init() is
	    word ptr vtable = [cast word ptr ptr(this)];
	    char ptr name = cast char ptr([vtable - 2]);
	    // native.printf( `%p %s alloc\n`, this, name );
	end

	Object clone() is
	    word ptr self = cast word ptr(this);
      	    int count = getObjectSize() >> System.Environment.WORD_TO_BYTE_SHIFT;
	    word ptr result = cast word ptr(native.GC_malloc(getObjectSize()));
            // native.printf( `%p object clone\n`, result );

	    word ptr save_result = result;

            while count > 0 do
		[result] = [self];

		result = result + 1;
		self = self + 1;
		count = count - 1;
	    od

	    return cast Object(save_result);
	end

	static void assert( bool v, String message ) is
	    if !v then
		throw new AssertException(message);
	    fi
	end

	static void assert( bool v ) is
	    assert( v, "assertion failed" );
        end

	static void assert( String message ) is
	    assert(false, message);
	end

	int hash() is
	    return cast int(this);
	end

	protected char ptr _get_ttable() is
	    int ptr ptr vtable = _get_vtable();
	
	    return cast char ptr([vtable-3]);
	end
   
	get int ObjectSize is
	    int ptr ptr vtable;
	    vtable = cast int ptr ptr(_get_vtable());
	    if vtable != null then
		return cast int([vtable - 1]);
	    else
		return 0;
	    fi
	end
    
	get char ptr ClassNameC is
	    int ptr ptr vtable = _get_vtable();
	    if vtable != null then
		return cast char ptr([vtable - 2]);
	    else
		return `null`;
	    fi
	end

	get word ptr TypeTable is
	    int ptr ptr _vtable = _get_vtable();
	    if _vtable != null then
		return cast word ptr([_vtable - 3]);
	    else
		return null;
	    fi
	end

	get String ClassName is
	    return new String( getClassNameC() );
	end

	String toString() is
	    StringBuffer result;
	    int i;
	    result = new StringBuffer( getClassNameC() );
	    result.append( ` @` );
	    result.append( hash(), 16 );
	
	    return result;
	end

	int toInt() is
	    throw new CastException( "cannot convert " + Class.Name + " to int" );
	end

	void print() is
	    if this == null then
		// called statically by exception handling in runtime so this could happen
		native.printf( `null` );
	    else
		char ptr p = this.toCString();
		native.printf( `%s`, p );
	    fi
	end
	
	char ptr toCString() is
	    return toString().toCString();
	end

	bool equals( Object o ) is
	    return cast word(this) == cast word(o);
	end

	static bool equals( Object o, Object p ) is
	    if o == null then
		return p == null;
	    else
		return o.equals(p);
	    fi
	end
    
	protected int ptr ptr _get_vtable() is
	    if this == null then
		return null;
	    else
		return [cast int ptr ptr ptr(this)];
	    fi
	end

	get Class Class is
	    return new Class(this);
	end

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
    end
end
