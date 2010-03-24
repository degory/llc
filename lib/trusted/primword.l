#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

namespace System {
    /// Object wrapper around primitive word type
    class Word extends Object {
	public static Word Zero = new Word(0W);
	protected word _value;

	/// Construct a Word
	/// \param v value for this Word
	void init( word v ) {
	    // super.init();
	    _value = v;
	}

	/// Construct a Word. Called by compiler to implement .box attribute
	/// \param w value for this Word
	static Word box(word w) {
	    return new Word(w);
	}

	/// Get this Word's word value
	get word Value {
	    return _value;
	}

	/// Return a word value converted to an int. Conversion of out of range values is not defined. Implements word.toInt()
	/// \param w value to convert
	static int toInt(word w) {
	    return cast int(w);
	}

	/// Return this Word's value converted to an int
	int toInt() {
	    return cast int(_value);
	}
       
	/// Return a word value converted to a bool. Non zero values convert to true, zero converts to false. Implements word.toBool()
	/// \param w value to convert
	static bool toBool(word w) { 
	    return w != 0w;
	}

	/// Return this Word's value converted to a bool. Non zero values convert to true, zero converts to false. Implements word.toBool()
	bool toBool() {
	    return _value != 0w;
	}
	
	/// Return this Word's hash value.
	int hash() {
	    return hash(_value);
	}

	/// Return the hash value of suppied word. Implements word.hash()
	static int hash(word w) {
	    return cast int((w >> 32W) + (w & 0xFFFFFFFFW));
	}

	/// Return a human readable String representation of a supplied word. Implements word.toString()
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

	static int operator>( word w, word x ) {
	    if( w > x ) { 
		return 1;
	    } else if( w < x ) {
		return -1;
	    } else {
		return 0;
	    }
	}

	int operator>( Word x ) {
	    return opCompare( _value, x._value );
	}

	bool operator=~( Word w ) {
	    return _value == w.Value;
	}

	String toString() {
	    return toString(_value);
	}

        static word fromString(String s) {
            return s.parseWord();
        }

    }
}
