#K

import object;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System is
    class Class extends Object is
	int ptr ptr _vtable;

	void init() is
	    super.init();
	    _vtable = null;
	end

	void init( Object o ) is
	    super.init();
	    _vtable = o._get_vtable();
	end

	void init( int ptr ptr vt ) is
	    super.init();
	
	    _vtable = vt;
	end

	set int ptr ptr VTable = vt is
	    _vtable = vt;
	end

	get int ptr ptr VTable is
	    return _vtable;
	end

	get int ObjectSize is
	    if _vtable != null then
		return cast int([_vtable - 1]);
	    else
		return 0;
	    fi
	end

	int ptr ptr  _parent() is
	    return cast int ptr ptr([_vtable]);
	end

	get Class Super is
	    Class result;
	    int ptr ptr vt = _parent();
	    if vt != null then
		return new Class( vt );
	    else
		return null;
	    fi
	end

	get word ptr TypeTable is
	    if _vtable != null then
		return cast word ptr([_vtable - 3]);
	    else
		return null;
	    fi
	end

	get char ptr NameC is
	    if _vtable != cast int ptr ptr(0) then
		return cast char ptr([_vtable - 2]);
	    else
		return `null`;
	    fi
	end

	get String Name is
	    return new String( getNameC() );
	end

	String toString() is
	    return "class " + getName();
	end


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
	end

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
	end

	static Class find( String name ) is
	    // IO.Std.err.println( "searching for class with name '" + name + "'" );

	    word ptr p = cast word ptr(native.__get_classes_info());

	    do
		char ptr compare = cast char ptr([p]);

		if compare == null then
		    return null;
		fi

		// native.printf( `comparing against class name '%s'...\n`, compare );

		if name =~ compare then
		    return new Class( cast int ptr ptr([p+1]) );
		fi
		p = p + 2;
	    od

	    return null;
	end

	static ClassIterator classes() is
	    return new ClassIterator(cast word ptr(native.__get_classes_info()));
	end

	static ClassNameIterator classNames() is
	    return new ClassNameIterator(cast word ptr(native.__get_classes_info()));
	end
    
	Object create() is
	    Object p = cast Object(native.GC_malloc(getObjectSize()));

	    [cast int ptr ptr ptr(p)] = _vtable;
	    p.init();
	    return p;
	end
    end

    // avoid linking rest of library here by not extending Iterator:
    class ClassNameIterator extends Object is
	word ptr current_record;

	void init( word ptr p ) is
	    current_record = p;
	end

	bool hasMoreElements() is
	    return [current_record] != null;
	end

	String nextElement() is
	    System.String result = new String( cast char ptr([current_record]) );
	    current_record = current_record + 2;
	end
    end

    class ClassIterator extends Object is
	word ptr current_record;

	void init( word ptr p ) is
	    current_record = p;
	end

	bool hasMoreElements() is
	    return [current_record] != null;
	end

	Class nextElement() is
	    Class result = new Class( cast int ptr ptr([current_record+1]) );
	    current_record = current_record + 2;
	    return result;
	end
    end
end
