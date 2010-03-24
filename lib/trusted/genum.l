#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved


namespace System {
    /// This is the corresponding box class for values of enum type
    /// \param T the enum type this Enum<T> wraps
    class Enum<T> {
	T _value;

	/// Construct a new Enum<T> for an enum value
	/// \param v the enum value to box
	void init( T v ) {
	    // super.init();
	    _value = v;
	}

	/// accessor: get T Value
	/// Get the boxed enum value
	/// \return boxed enum value
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

	/// Reverse add operator. Allows enums to be appended to strings without
	/// having to implement this operator within System.String for every possible
	/// Enum<T> specialization.
	/// \param v the enum value to append
	/// \param s the string to append it to 
	static StringBuffer opAddRev(T v, System.String s) {
	    return new StringBuffer(s).append(cast int(v));
	}

	/// Forward add operator
	/// \param v the enum value to append
	/// \param s the string to append it to 
	static StringBuffer opAdd(T v, System.String s) { 
	    return "" + cast int(v) + s;
	}
	
	/// Implements .box attribute, which creates an instance of Enum<T> from an enum value of type T
	/// \param w the enum value to box
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

	/// bool operator=~( Enum<T> w )
	/// \param w the enum value to compare to
	bool operator=~( Enum<T> w ) {
	    return _value == w.Value;
	}

	/// static bool operator>( T b )
	/// \param b enum value to compare
	/// \param c other enum value to compare
	static int operator>( T b, T c ) {
	    if( b > c ) {
		return 1;
	    } else if( b < c ) {
		return -1;
	    } else {
		return 0;
	    }
	}

	/// int operator>( Enum<T> w )
	/// \param w enum value to compare
	int operator>( Enum<T> w ) {
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
