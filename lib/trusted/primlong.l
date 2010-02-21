namespace System {
    /// Object wrapper around primitive word type
    class Long extends Object {
	public static Long Zero = new Long(0L);
	protected long _value;

	void init( long v ) {
	    // super.init();
	    _value = v;
	}

	get long Value {
	    return _value;
	}
	
	int hash() {
	    return hash(_value);
	}

	static int hash(long w) {
	    return cast int((w >> 32L) + (w & 0xFFFFFFFFL));
	}

	static int toInt(long w) { 
	    return cast int(w);
	}

	int toInt() {
	    return cast int(_value);
	}

	static bool toBool(long w) { 
	    return w != 0l;
	}

	bool toBool() {
	    return _value != 0l;
	}

	static String toString(long w) {
	    return new StringBuffer().append(cast word(w));
	}

	static Long box(long w) {
	    return new Long(w);
	}

	bool equals( Object o ) {
	    if( o == null ) {
		return false;
	    } else if( Zero.likeMe(o) ) {
		Long w = cast<Long>(o);
		return _value == w.Value;
	    }

	    return false;
	}

	bool opEquals( Long w ) {
	    return _value == w.Value;
	}

	int opCompare( long b, long c ) {
	    if( b > c ) {
		return 1;
	    } else if( b < c ) {
		return -1;
	    } else {
		return 0;
	    }
	}

	int opCompare( Long w ) {
	    return opCompare( _value, w._value );
	}

	String toString() {
	    return toString(_value);
	}

	static long fromString( String s ) {
	    return s.parseLong();
	}
    }
}
