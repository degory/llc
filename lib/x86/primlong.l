
namespace System {
    /// Object wrapper around primitive long value
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

	static int hash(long i) {
	    return cast int(i);
	}

	static String toString(long i) {
	    return new StringBuffer().append(cast int(i));
	}

	static Long box(long i) {
	    return new Long(i);
	}

	bool equals( Object o ) {
	    if( o == null ) {
		return false;
	    } else if( Zero.likeMe(o) ) {
		Long i = cast<Long>(o);
		return _value == i.Value;
	    }

	    return false;
	}

	bool opEquals( Long i ) {
	    return _value == i.Value;
	}

	String toString() {
	    return toString(_value);
	}
    }
}