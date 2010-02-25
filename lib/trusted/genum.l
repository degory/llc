
namespace System {
    class Enum<T> {
	T _value;

	void init( T v ) {
	    // super.init();
	    _value = v;
	}

	get T Value {
	    return _value;
	}
	
	int hash() {
	    return hash(_value);
	}

	static int hash(T w) {
	    return cast int(w);
	}

	static int toInt(T w) { 
	    return cast int(w);
	}

	int toInt() {
	    return cast int(_value);
	}

	static bool toBool(T w) { 
	    return w != T.none;
	}

	bool toBool() {
	    return _value != T.none;
	}

	static String toString(T w) {
	    return new StringBuffer().append(cast int(w));
	}

	static Enum<T> box(T w) {
	    return new Enum<T>(w);
	}

	bool equals( Object o ) {
	    if( o == null ) {
		return false;
	    } else if( isa Enum<T>(o) ) {
		var w = cast Enum<T>(o);
		return _value == w.Value;
	    }

	    return false;
	}

	bool opEquals( Enum<T> w ) {
	    return _value == w.Value;
	}

	int opCompare( T b, T c ) {
	    if( b > c ) {
		return 1;
	    } else if( b < c ) {
		return -1;
	    } else {
		return 0;
	    }
	}

	int opCompare( Enum<T> w ) {
	    return opCompare( _value, w._value );
	}

	String toString() {
	    return toString(_value);
	}

	static T fromString( String s ) {
	    return cast T(s.parseInt());
	}
    }
}
