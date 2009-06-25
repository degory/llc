
namespace System {
    class Word extends Object {
	public static Word Zero = new Word(0W);
	protected word _value;

	void init( word v ) {
	    // super.init();
	    _value = v;
	}

	get word Value {
	    return _value;
	}
	
	int hash() {
	    return hash(_value);
	}

	static int hash(word w) {
	    return cast int(w);
	}

	static String toString(word w) {
	    return new StringBuffer().append(w);
	}

	static Word box(word w) {
	    return new Word(w);
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