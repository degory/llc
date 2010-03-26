#K

import grange;
import primword;
import primlong;

pragma NoMarkUnsafe, NoWarnUnsafe;

namespace System is
    use Generic.Iterator;
    use Generic.Range;

    /// Object wrapper around primitive int type
    class Int is
	public static Int Zero = new Int(0);
	protected int _value;

	void init( int v ) is
	    // super.init();
	    _value = v;
	si

	get int Value is
	    return _value;
	si

	int toInt() is
	    return _value;
	si

	static int toInt(int value) is
	    return value;
	si

	bool toBool() is
	    return _value != 0;
	si

	static bool toBool(int value) is
	    return value != 0;
	si

	int hash() is
	    return _value;
	si

	static int hash(int i) is
	    return i;
	si

	static String toString(int i) is
	    return new StringBuffer().append(i);
	si

	static Int box(int i) is
	    return new Int(i);
	si

	bool equals( Object o ) is
	    if o == null then
		return false;
	    elif Zero.likeMe(o) then
		Int i = cast Int(o);
		return _value == i.Value;
	    fi

	    return false;
	si

	bool opEquals( Int i ) is
	    return _value == i.Value;
	si

	static int opCompare( int i, int j ) is
	    return i - j;
	si

	int opCompare( Int j ) is
	    return opCompare( _value, j._value );
	si

	String toString() is
	    return toString(_value);
	si

        static int fromString(String s) is
	    return s.parseInt();
        si

	static int random() is
	    return cast int(native.rand());
	si

	static void seedRandom( int seed ) is
	    native.srand( seed );
	si

	static void seedRandom() is
	    native.srand( native.__get_time() );
	si

	static int next(int i) is
	    return i + 1;
	si

	static Range<int> opRange(int from, int to) is
	    return new Range<int>(from, to);
	si	
    si

    class Bool is
	public static Bool False = new Bool(false);
	protected bool _value;

	void init( bool v ) is
	    // super.init();
	    _value = v;
	si

	get bool Value is
	    return _value;
	si

	int toInt() is
	    if _value then
		return 1;
	    else
		return 0;
	    fi
	si

	static int toInt(bool value) is
	    if value then
		return 1;
	    else
		return 0;
	    fi
	si

	bool toBool() is
	    return _value;
	si

	static bool toBool(bool value) is
	    return value;
	si

	int hash() is
	    return hash(_value);
	si

	static int hash(bool b) is
	    return toInt(b);
	si

	static String toString(bool b) is
	    if b then
		return "true";
	    else
		return "false";
	    fi
	si

	static Bool box(bool b) is
	    return new Bool(b);
	si

	bool equals( Object o ) is
	    if o == null then
		return false;
	    elif False.likeMe(o) then
		Bool b = cast Bool(o);
		return _value == b._value;
	    fi

	    return false;
	si

	bool opEquals( Bool b ) is
	    return _value == b._value;
	si

	static int opCompare( bool b, bool c ) is
	    if b == c then
		return 0;
	    elif b then
		return 1;
	    else
		return -1;
	    fi
	si

	int opCompare( Bool j ) is
	    return opCompare( _value, j._value );
	si

	String toString() is
	    return toString(_value);
	si

        static bool fromString(String s) is
	    if s == null || s.Length == 0 then
	        return false;
            elif s.Length == 1 then
	        return s[0] - '0' != 0c;
            else
		return s !~ "false";
	    fi
        si
    si

    class Char is
	public static Char Zero = new Char(cast char(0));
	protected char _value;

	void init( char v ) is
	    // super.init();
	    _value = v;
	si

	get char Value is
	    return _value;
	si
	
	int hash() is
	    return hash(_value);
	si

	int toInt() is
	    return cast int(_value);
	si

	static int toInt(char c) is
	    return cast int(c);
	si

	static int hash(char c) is
	    return cast int(c);
	si

	static String toString(char c) is
	    return new StringBuffer().append(c);
	si

	static Char box(char c) is
	    return new Char(c);
	si

	bool equals( Object o ) is
	    if o == null then
		return false;
	    elif Zero.likeMe(o) then
		Char i = cast Char(o);
		return _value == i.Value;
	    fi

	    return false;
	si

	bool opEquals( Char c ) is
	    return _value == c.Value;
	si

        static int opCompare( char b, char c ) is
	    return cast int(b - c);
	si

	String toString() is
	    return toString(_value);
	si

        bool isSpace( char c ) is
	    return String.isSpace(c);
        si

        static char fromString( String s ) is
	    return s[0];
	si

	static char next(char i) is
	    return i + 1c;
	si

	static Range<char> opRange(char from, char to) is
	    return new Range<char>(from, to);
	si	
    si
si
