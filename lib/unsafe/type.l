
namespace System {
    class Type extends System.Object {
	enum Kind {
	    NONE = 0,
	    VOID = 1,
	    BOOL = 2,
	    BYTE = 3,
	    CHAR = 4,
	    SHORT = 5,
	    INTEGER = 6,
	    WORD = 7,
	    LONG = 8,
	    FLOAT = 9,
	    DOUBLE = 10,
	    ARRAY = 11,
	    REFERENCE = 12,
	    POINTER = 13,
	    CLASS = 14,
	    ENUM = 15,
   	    NULL = 20,
	    STRUCT = 21,
	    OPAQUE = 22,
	    ERROR = 22
	}

	Kind kind;
	Class class_;
	Type sub_type;

	static System.String name = {
	    "none",
	    "int",
	    "void",
	    "bool",
	    "byte",
	    "char",
	    "short",
	    "int",
	    "word",
	    "long",
	    "float",
	    "double",
	    "[]",
	    " ref",
	    " ptr",
	    "class",
	    "enum",
	    "null",
	    "struct",
	    "opaque",
	    "error"
	}; 

	public void init( Kind k ) {
	    init( k, null, null );
	}

	public void init( Kind k, Type sub_type, Class c ) {
	    this.kind = k;
	    this.sub_type = sub_type;
	    this.class_ = c;
	}

	public void init( Kind k, System.Object o ) {
	    this.kind = k;
	    this.sub_type = null;
	    if( o != null ) {
		this.class_ = o.Class;
	    } else {
		o = class<System.Object>;
	    }
	}

	public String toString() {
	    if( class_ != null ) {
		return class_.Name;
	    }

	    StringBuffer b = new StringBuffer();

	    if( sub_type != null ) {
		b.append( sub_type.toString() );
	    }

	    b.append( name[cast<int>(kind) ];
	}

    }
}