import object;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System {
    class Class extends Object {
	int ptr ptr _vtable;

	void init() {
	    super.init();
	    _vtable = null;
	}

	void init( Object o ) {
	    super.init();
	    _vtable = o._get_vtable();
	}

	void init( int ptr ptr vt ) {
	    super.init();
	
	    _vtable = vt;
	}

	set int ptr ptr VTable = vt {
	    _vtable = vt;
	}

	int ptr ptr getVTable() {
	    return _vtable;
	}

	get int ObjectSize {
	    if( _vtable != null ) {
		return cast<int>([_vtable - 1]);
	    } else {
		return 0;
	    }
	}

	int ptr ptr  _parent() {
	    return cast<int ptr ptr>([_vtable]);
	}

	get Class Super {
	    Class result;
	    int ptr ptr vt = _parent();
	    if( vt != null ) {
		return new Class( vt );
	    } else {
		return null;
	    }
	}

	get char ptr NameC {
	    if( _vtable != cast<int ptr ptr>(0) ) {
		return cast<char ptr>([_vtable - 2]);
	    } else {
		return `null`;
	    }
	}

	get String Name {
	    return new String( getNameC() );
	}

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

	static ClassIterator classes() {
	    return new ClassIterator(cast word ptr(native.__get_classes_info()));
	}

	static ClassNameIterator classNames() {
	    return new ClassNameIterator(cast word ptr(native.__get_classes_info()));
	}
    }

    // avoid linking rest of library here by not extending Iterator:
    class ClassNameIterator extends Object {
	word ptr current_record;

	void init( word ptr p ) {
	    current_record = p;
	}

	bool hasMoreElements() {
	    return [current_record] != null;
	}

	String nextElement() {
	    System.String result = new String( cast char ptr([current_record]) );
	    current_record = current_record + 2;
	}
    }

    class ClassIterator extends Object {
	word ptr current_record;

	void init( word ptr p ) {
	    current_record = p;
	}

	bool hasMoreElements() {
	    return [current_record] != null;
	}

	Class nextElement() {
	    Class result = new Class( cast int ptr ptr([current_record+1]) );
	    current_record = current_record + 2;
	    return result;
	}
    }
}
