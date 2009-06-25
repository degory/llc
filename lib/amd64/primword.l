namespace System {
    class Word extends Object {
	public static Word Zero = new Word(0W);
	protected word _value;

	void init( word v ) {
	    // super.init();
	    _value = v;
	}

	static Word box(word w) {
	    return new Word(w);
	}

	get word Value {
	    return _value;
	}

	static int toInt(word w) {
	    return cast int(w);
	}

	int toInt() {
	    return cast int(_value);
	}
       
	static bool toBool(word w) { 
	    return w != 0w;
	}

	bool toBool() {
	    return _value != 0w;
	}
	
	int hash() {
	    return hash(_value);
	}

	static int hash(word w) {
	    return cast int((w >> 32W) + (w & 0xFFFFFFFFW));
	}

	static String toString(word w) {
	    return new StringBuffer().append(w);
	}

	bool equals( Object o ) {
	    if( o == null ) {
		return false;
	    } else if( Zero.likeMe(o) ) {
		Word w = cast<Word>(o);
		return _value == w.Value;
	    }

	    return false;
	}

	bool opEquals( Word w ) {
	    return _value == w.Value;
	}

	String toString() {
	    return toString(_value);
	}
    }
}
