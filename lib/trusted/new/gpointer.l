namespace System is
    /// Box type for T ptr
    class Pointer<T> is 
        @NoWarnUnsafe;
        T ptr _value;

	/// Construct a Pointer<T>
	/// \param v value for this Pointer<T>
	void init( T ptr v ) is
	    // super.init();
	    _value = v;
	si

	/// Construct a Pointer<T>. Called by compiler to implement .box attribute
	/// \param w value for this Pointer<T>
	static Pointer<T> box(T ptr w) is
	    return new Pointer<T>(w);
	si

	/// Get this Pointer<T>'s T ptr value
	get T ptr Value is
	    return _value;
	si

	/// Return a T ptr value converted to an int. Conversion of out of range values is not defined. Implements T ptr.toInt()
	/// \param w value to convert
	static int toInt(T ptr w) is
	    return cast int(w);
	si

	/// Return this Pointer<T>'s value converted to an int
	int toInt() is
	    return cast int(_value);
	si
       
	/// Return a T ptr value converted to a bool. Non zero values convert to true, zero converts to false. Implements T ptr.toBool()
	/// \param w value to convert
	static bool toBool(T ptr w) is 
	    return w != null;
	si

	/// Return this Pointer<T>'s value converted to a bool. Non zero values convert to true, zero converts to false. Implements T ptr.toBool()
	bool toBool() is
	    return _value != null;
	si
	
	/// Return this Pointer<T>'s hash value.
	int hash() is
	    return hash(_value);
	si


	/// Return the hash value of suppied T ptr. Implements T ptr.hash()
	static int hash(T ptr v) is
	    word w = cast word(v);
	    return cast int((w >> 32W) + (w & 0xFFFFFFFFW));
	si

	/// Return a human readable String representation of a supplied T ptr. Implements T ptr.toString()
	static String toString(T ptr w) is
	    return String.hex(cast word(w));
	si


	bool equals( Object o ) is
/*
	    if o == null then
		// return false;
	    elif o isa Pointer<T> then
		//Pointer<T> w = cast Pointer<T>(o);
		//return _value == w._value;
	    fi
*/
	    return false;
	si


	static int operator>( T ptr vw, T ptr vx ) is
	    var w = cast word(vw);
	    var x = cast word(vx);
	    if w > x then
		return 1;
	    elif w < x then
		return -1;
	    else
		return 0;
	    fi
	si

	int operator>( Pointer<T> x ) is
	    return opCompare( _value, x._value );
	si

	bool operator=~( Pointer<T> w ) is
	    return _value == w.Value;
	si

	String toString() is
	    return toString(_value);
	si

        static T ptr fromString(String s) is
            return cast T ptr(s.parseWord());
        si

    si
si
