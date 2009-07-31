#K

import primword;
import primlong;

pragma NoMarkUnsafe, NoWarnUnsafe;

namespace System is
    /// Object wrapper around primitive int type
    class Int extends Object is
	public static Int Zero = new Int(0);
	protected int _value;

	void init( int v ) is
	    // super.init();
	    _value = v;
	end

	get int Value is
	    return _value;
	end

	int toInt() is
	    return _value;
	end

	static int toInt(int value) is
	    return value;
	end

	bool toBool() is
	    return _value != 0;
	end

	static bool toBool(int value) is
	    return value != 0;
	end

	int hash() is
	    return _value;
	end

	static int hash(int i) is
	    return i;
	end

	static String toString(int i) is
	    return new StringBuffer().append(i);
	end

	static Int box(int i) is
	    return new Int(i);
	end

	bool equals( Object o ) is
	    if o == null then
		return false;
	    elif Zero.likeMe(o) then
		Int i = cast Int(o);
		return _value == i.Value;
	    fi

	    return false;
	end

	bool opEquals( Int i ) is
	    return _value == i.Value;
	end

	static int opCompare( int i, int j ) is
	    return j - i;
	end

	int opCompare( Int j ) is
	    return opCompare( _value, j._value );
	end

	String toString() is
	    return toString(_value);
	end

	static int random() is
	    return cast int(native.rand());
	end

	static void seedRandom( int seed ) is
	    native.srand( seed );
	end

	static void seedRandom() is
	    native.srand( native.__get_time() );
	end
    end

    class Bool extends Object is
	public static Bool False = new Bool(false);
	protected bool _value;

	void init( bool v ) is
	    // super.init();
	    _value = v;
	end

	get bool Value is
	    return _value;
	end

	int toInt() is
	    if _value then
		return 1;
	    else
		return 0;
	    fi
	end

	static int toInt(bool value) is
	    if value then
		return 1;
	    else
		return 0;
	    fi
	end

	bool toBool() is
	    return _value;
	end

	static bool toBool(bool value) is
	    return value;
	end

	int hash() is
	    return hash(_value);
	end

	static int hash(bool b) is
	    return toInt(b);
	end

	static String toString(bool b) is
	    if b then
		return "true";
	    else
		return "false";
	    fi
	end

	static Bool box(bool b) is
	    return new Bool(b);
	end

	bool equals( Object o ) is
	    if o == null then
		return false;
	    elif False.likeMe(o) then
		Bool b = cast Bool(o);
		return _value == b._value;
	    fi

	    return false;
	end

	bool opEquals( Bool b ) is
	    return _value == b._value;
	end

	static int opCompare( bool b, bool c ) is
	    if b == c then
		return 0;
	    elif b then
		return 1;
	    else
		return -1;
	    fi
	end

	int opCompare( Bool j ) is
	    return opCompare( _value, j._value );
	end

	String toString() is
	    return toString(_value);
	end
    end

    class Char extends Object is
	public static Char Zero = new Char(cast char(0));
	protected char _value;

	void init( char v ) is
	    // super.init();
	    _value = v;
	end

	get char Value is
	    return _value;
	end
	
	int hash() is
	    return hash(_value);
	end

	int toInt() is
	    return cast int(_value);
	end

	static int toInt(char c) is
	    return cast int(c);
	end

	static int hash(char c) is
	    return cast int(c);
	end

	static String toString(char c) is
	    return new StringBuffer().append(c);
	end

	static Char box(char c) is
	    return new Char(c);
	end

	bool equals( Object o ) is
	    if o == null then
		return false;
	    elif Zero.likeMe(o) then
		Char i = cast Char(o);
		return _value == i.Value;
	    fi

	    return false;
	end

	bool opEquals( Char c ) is
	    return _value == c.Value;
	end

        static int opCompare( char b, char c ) is
	    return cast int(c - b);
	end

	String toString() is
	    return toString(_value);
	end

        bool isSpace( char c ) is
	    return String.isSpace(c);
        end
    end
end
