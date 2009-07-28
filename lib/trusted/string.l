#K
import object;
import integer;

import gset;

namespace System is
    use Generic.Map;

    pragma NoWarnUnsafe, NoMarkUnsafe;
   
    /// A string of characters. String is immutable, its child StringBuffer is not.
    class String extends Object is
	pragma NoWarnHide;

	protected char ptr _buffer;
	protected int _length;

        static Map<String,String> pool = new Map<String,String>(65419);

	/// Return a formatted copy of supplied string with supplied arguments substituted for '%'
	static StringBuffer format( String s, Object[] args ) is
	    StringBuffer result = new StringBuffer(``);
	    int i = 0;
	    int p = 0;
	    int l = s.getLength();
	    while i < l do
		char c = s.charAt(i);
		if c == '%' then
		    i = i + 1;
		    result.append( args[p] );
		    p = p + 1;
		else
		    result.append( c );
		    i = i + 1;
		fi
	    od
	    return result;
	end

	/// Return a formatted copy of supplied string with supplied arguments substituted for '%'
	static StringBuffer format( String s, int[] args ) is
	    StringBuffer result = new StringBuffer(``);
	    int i = 0;
	    int p = 0;
	    int l = s.getLength();
	    while i < l do
		char c = s.charAt(i);
		if c == '%' then
		    i = i + 1;
		    result.append( args[p] );
		    p = p + 1;
		else
		    result.append( c );
		    i = i + 1;
		fi
	    od
	    return result;
	end

	/// Append every object int the supplied array into a new StringBuffer and return it
	static StringBuffer cat( Object[] args ) is
	    StringBuffer result = new StringBuffer(``);
	    for int i = 0; i < args.length; i = i + 1 do
		result.append( args[i] );
	    od
	    return result;
	end

	/// Format a string with a single argument
	static StringBuffer format( String s, int i ) is
	    return format( s, Object { new Int(i) } );
	end

	/// Format a string with a two arguments
	static StringBuffer format( String s, int i, int j ) is
	    return format( s, Object { new Int(i), new Int(i) } );
	end

	/// Format a string with a single argument
	static StringBuffer format( String s, Object i ) is
	    return format( s, { i } );
	end

	/// Format a string with a two arguments
	static StringBuffer format( String s, Object i, Object j ) is
	    return format( s, { i, j } );
	end

	// Construct a new String by copying the supplied C-string
	// \param s a C-string to copy. Must be terminated with cast char(0)
	void init( char ptr s ) is
	    super.init();

	    int i = 0;

	    if s == null then
		_buffer = null;
		_length = 0;
		return;
	    fi

	    _length = _c_getLength( s );

	    _buffer = cast char ptr( native.GC_malloc_atomic( _length + 1) );
	    // native.printf( `%p len %d string\n`, _buffer, _length+1 );
	    while i <= _length do
		[_buffer + i] = [s + i];
		i = i + 1;
	    od
	end

	/// Construct a new String by copying the supplied String
	void init( String s ) is
	    this.init( s.toCString() );
	end

	int hash() is
	    int result, i;
	    i = 0;
	    result = 0;

	    while i < _length do
		result = result * 4 + cast int([_buffer + i]);
		i = i + 1;
	    od
	
	    return result;
	end

	/// Return character at supplied index
	/// \deprecated Use get char[int i] instead (\see opGet(int i))
	char charAt( int i ) is
	    return opGet(i);
	end

	/// Return character at supplied index
	/// \param i index of character to get
	get char[int i] is
	    // FIXME: not bounds checked!
	    return [_buffer + i];
	end

	String toString() is
	    return this;
	end

	/// Is supplied character white space?
	/// \param c character to test
	static bool isSpace( char c ) is
	    return c == ' ' || c == cast char(9) || c == '\n' || c == cast char(13);
	end

	/// Return a copy of this string with leading an trailing white space trimmed
	String trim() is
	    int from, to;
	    System.StringBuffer result = new System.StringBuffer( _length );
	    
	    for from = 0; from < _length && isSpace( [_buffer + from] ); from = from + 1 do
		;
            od

	    for to = _length - 1; to > from && isSpace( [_buffer + to] ); to = to - 1 do
		;
            od

	    return substring( from, to + 1 );
	end

	/// Return a copy of this string with all instances of the supplied character removed
	/// \param c the character to strip
	String strip( char c ) is
	    System.StringBuffer result = new System.StringBuffer( _length );
	    int l = _length;

	    for int i = 0; i < l; i = i + 1 do
		char d = [_buffer + i];
		if d != c then
		    result.append( d );
		fi
	    od

	    return result;
	end
	    
        /// Return a String representing the supplied integer in base 8
	/// \param i the value to format in octal
	static String oct(int i) is
	    StringBuffer result = new StringBuffer();
	    result.append( i, 8 );
	    return result;
	end

        /// Return a String representing the supplied integer in base 16
	/// \param i the value to format in hex
	static String hex(int i) is
	    StringBuffer result = new StringBuffer();
	    result.append( i, 16 );
	    return result;
	end

        /// Return a String representing the supplied word in base 16
	/// \param i the value to format in hex
	static String hex(word i) is
	    StringBuffer result = new StringBuffer();
	    result.append( i, 16 );
	    return result;
	end

	/*
	static String hex(word w) {
	    StringBuffer result = new StringBuffer();
	    int i = cast<int>(w >> 32W);
	    result.append( i, 16 );

	    result.append(' ');
	    result.append( cast<int>(w), 16 );
	    return result;
	}
	*/

        /// Return a pointer to this String as a C-string.
	/// This method may not copy the internal buffer holding the characters that comprise this String but the contents of the
	/// returned C-string are immutable.
	public char ptr toCString() is
	    return _buffer;
	end

	/// Return the number of characters that comprise this String
	get int Length is
	    return _length;
	end

	/// Compare this String to the supplied C-string and return true if they are the same.
	/// \param s the C-string to compare to. Must be terminated with cast char(0)
	bool equals( char ptr s ) is
	    int i = 0;
	    while i < _length && [s + i] != cast char(0) do
		if [_buffer + i] != [s + i] then
		    return false;
		fi
		i = i + 1;
	    od
	    return i == _length && [s + i] == cast char(0);
	end

	/// Compare this String to the supplied Object and return true iff the Object is non-null,
	/// a String, it's length is equal to this String's length and the two String's buffers
	/// compare equal character for character
	bool equals( Object s ) is
	    if s == null then
		return false;
	    elif s == this then
		return true;
	    elif "".likeMe(s) then
		String t;
		t = cast String(s);
	    
		if _length != t._length then
		    return false;
		else
		    int i = 0;
		    while i < _length do
			if [_buffer + i] != [t._buffer + i] then
			    return false;
			fi
			i = i + 1;
		    od
		    return true;
		fi
	    else // not a string - maybe we should compare against s.toString() ?
		return false;
	    fi
	end

	/// Return true if supplied string is a prefix of or is equal to this String
	bool startsWith( System.String s ) is
	    int l = s._length;

	    if _length < l then
		return false;
	    else
		char ptr p = _buffer;
		char ptr q = s._buffer;
		while l > 0 do
		    if [p] != [q] then
			return false;
		    fi
		    p = p + 1w;
		    q = q + 1w;

		    l = l - 1;
		od

		return true;
	    fi
	end

	bool startsWith( char c ) is
	    return _length > 0 && [_buffer] == c;
	end

	/// Return true if the last character of this string equals the supplied character
	bool endsWith( char c ) is
	    return _length > 0 && [_buffer + _length - 1] == c;
	end

	/// Return true if the supplied string is a suffix of or is equal to this String
	bool endsWith( System.String s ) is
	    int l = s._length;
	    if _length < l then
		return false;
	    else
		char ptr p = _buffer + _length - 1;
		char ptr q = s._buffer + s._length - 1;
		while l > 0 do
		    if [p] != [q] then
			return false;
		    fi
		    p = p - 1w;
		    q = q - 1w;

		    l = l - 1;
		od

		return true;
	    fi
	end

	/// Return the first index where the supplied char appears in this String, or -1 if it
	/// does not appear
	int indexOf( char c ) is
	    for int i = 0; i < _length; i = i + 1 do
		if [_buffer+i] == c then
		    return i;
		fi
	    od

	    return -1;
	end

        /// Return the last index where the supplied char appears in this String, or -1 if it
	/// does not appear	
	int lastIndexOf( char c ) is
	    for int i = _length-1; i >= 0; i = i - 1 do
		if [_buffer+i] == c then
		    return i;
		fi
	    od

	    return -1;
	end

	/// Return true if the supplied string is a substring of this String beginning with the supplied index
	bool matches( System.String s, int index ) is
	    int l = s.Length;

	    if index + l > _length then
		return false;
	    fi

	    for int i = 0; i < l; i = i + 1 do
		if [_buffer + index + i] != [s._buffer + i] then
		    return false;
		fi
	    od
	    return true;
	end

	/// Return the first index where matches(s,index) is true
	int indexOf( System.String s ) is
	    for int i = 0; i < _length; i = i + 1 do
		if matches( s, i ) then
		    return i;
		fi
	    od
	    return -1;
	end

	/// Equality operator
	/// \param t String to compare this String to
	bool opEquals( System.String t ) is
	    int cl = _length;
	    if cl != t._length then
		return false;
	    else
		for int i = 0; i < cl; i = i + 1 do
		    if [_buffer+i] != [t._buffer+i] then
			return false;
		    fi
		od
		return true;
	    fi
	end

	/// Equality operator
	/// \param t C-string to compare this String to
	bool opEquals( char ptr t ) is
	    int cl = _length;
	    int i;
	    for i = 0; i < cl; i = i + 1 do
		char c = [t + i];

		if [_buffer+i] != [t + i] then
		    return false;
		fi
	    od

	    return [t + i] == cast char(0);
	end

	/// Inequality operator
	/// \param t String to compare this String to
	/// \return negative, zero or positive integer depending on the ordering of this String relative to supplied String
	int opCompare( System.String t ) is
	    // IO.Std.err.println( "compare " + this + " to " + t );
	    int cl = _length;
	    int tie = 1;
	    if t._length < cl then
		cl = t._length;
		tie = -1;
	    elif t._length == cl then
		tie = 0;
	    fi

	    for int i = 0; i < cl; i = i + 1 do
		char c = [_buffer+i];
		char ct = [t._buffer+i];

		if c != ct then
		    int d = cast int(ct) - cast int(c);
		    // IO.Std.err.println( "'" + c + "'-'" + ct + "' mismatch result is: " + cast int(c - ct) );
		    return d;
		fi
	    od

	    // IO.Std.err.println( "tie result is: " + tie );
	    return tie;
	end

	/// \deprecated Use =~ operator instead (\see String.opEquals(String))
	static bool equals( System.String s, System.String t ) is
	    if s == t then
		return true;
	    elif s == null || t == null then
		return false;
	    elif s._length != t._length then
		return false;
	    else
		int i = 0;
		while i < s._length do
		    if [s._buffer + i] != [t._buffer + i] then
			return false;
		    fi
		    i = i + 1;
		od
		return true;
	    fi
	end

	int toInt() is
	    if _length >= 2 && ([_buffer + 1] == 'x' || [_buffer + 1] == 'X') then
	        return parseInt(16);
            else
  	        return parseInt(10);
            fi
	end

	/// Parse this string as an integer
	/// \deprecated Use \see System.String.toInt() instead
	int parseInt() is
	    return toInt();
	end

	/// Parse this string as an integer of supplied base
	/// \param base radix to use for conversion. Must be between 1 and 36
	/// \throw Exception if this String cannot be parsed in supplied base
	int parseInt( int base ) is
            bool negative = false;
	    int i;
	    if _length >= 1 && [_buffer] == '-' then
		negative = true;
		i = 1;
	    fi
	    int result = 0;

	    char c;
	    if base <= 10 then
		for ; i < _length; i = i + 1 do
		    int n = cast int([_buffer + i] - '0');
		    if n >= 0 && n < base then
			result = result * base + n;
		    elif i == 0 then
		        // IO.Std.err.println( "about to throw cannot parse: '" + this + " as base " + base );
			throw new Exception( "cannot parse: '" + this + "' as base " + base + " integer" );
		    else
			break;
		    fi
		od
	    else
		for ; i < _length; i = i + 1 do
		    c = [_buffer + i];
		    if c >= '0' && c <= '9' then
			result = result * base + cast int(c - '0');
		    elif c >= 'A' && c < 'A' + cast char(base-10) then
			result = result * base + 10 + cast int(c - 'A');
		    elif c >= 'a' && c < 'a' + cast char(base-10) then
			result = result * base + 10 + cast int(c - 'a');
		    elif i == 0 then
		        // IO.Std.err.println( "about to throw cannot parse: '" + this + " as base " + base );
			throw new Exception( "cannot parse: '" + this + "' as base " + base + " integer" );
	            else
		        break;
		    fi
		od
	    fi

	    if negative then
		return -result;
	    else
		return result;
	    fi
	end

	/// Return the length in characters of supplied C-string
	/// \param s C-string to get the length of. Must be terminated with cast char(0)
	int _c_getLength( char ptr s ) is
	    for int i = 0; [s + i] != cast char(0); i = i + 1 do
	        ;
	    od

	    return i;
	end

	/// Return a copy of this string.
	String copy() is
	    return this;
	end

	/// Returns a substring of this string comprised of characters from and including the supplied position up to and including the last character 
	/// in the string. If from is greater than or equal to length then result is an empty String. Behaviour is undefined if from is negative
	/// \param from index of first character to include in substring
	StringBuffer substring( int from ) is
	    return substring( from, _length );
	end

	/// Returns a substring of this string comprised of characters from and including the supplied to position up to and not including the supplied from
	/// position. If from is greater than or equal to length then result is an empty String. If to is greater than or equal to length then the result is
	/// the same as String.substring(from). Behaviour is undefined if from is negative
	/// \param from index of first character to include in substring
	/// \param to index of character after last character to include in substring
	StringBuffer substring( int from, int to ) is
	    StringBuffer result = new StringBuffer();
	    for int i = from; i < to && i < _length; i = i + 1 do
		result.append( charAt(i) );
	    od
	    return result;
	end

	/// Splits this String at each point where the supplied delimiter character is found into an array of substrings
	/// \param delim character at which to split this String 
	String[] split( char delim ) is
	    int i;
	    int parts = 1;
	    for i = 0; i < _length; i = i + 1 do
		if [_buffer + i] == delim then
		    parts = parts + 1;
		fi
	    od

	    StringBuffer t = new StringBuffer(_length);
	    String[] result = new String[parts];
	    result[0] = t;

	    int j = 0;

	    for i = 0; i < _length; i = i + 1 do
		char c = [_buffer + i];
		if c == delim then
		    result[j] = t;
		    j = j + 1;
		    if j < parts then
			t = new StringBuffer(_length);
			result[j] = t;
		    else
			break;
		    fi
		else
		    t.append( c );
		fi
	    od

	    return result;
	end

	/// Implements + operator. 
	StringBuffer opAdd( String s ) is
	    return new StringBuffer( toCString() ).append( s );
	end

	/// Implements + operator. 
	StringBuffer opAdd( int i ) is
	    return new StringBuffer( toCString() ).append( i );
	end

	/// Implements + operator. 
	StringBuffer opAdd( word w ) is
	    return new StringBuffer( toCString() ).append( w );
	end

	/// Implements + operator. 
	StringBuffer opAdd( char c ) is
	    return new StringBuffer( toCString() ).append( c );
	end

	/// Implements + operator. 
	StringBuffer opAdd( bool b ) is
	    if b then
		return new StringBuffer( toCString() ).append( `true` );
	    else
		return new StringBuffer( toCString() ).append( `false` );
	    fi
	end

	/// Implements + operator. 
	StringBuffer opAdd( char ptr s ) is
	    return new StringBuffer( toCString() ).append( s );
	end

	/// Implements + operator. 
	StringBuffer opAdd( Object o ) is
	    return new StringBuffer( toCString() ).append( o );
	end

	/// Return a copy of this string with all ASCII upper case characters converted to lower case equivalents. This
	/// method converts only 'A' - 'Z', no other letters are affected.
	get StringBuffer LowerCase is
	    StringBuffer result = new StringBuffer(_length);
	    for int i = 0; i < _length; i = i + 1 do
		char c = [_buffer + i];
		if c >= 'A' && c <= 'Z' then
		    result.append( c + ('a' - 'A') );
		else
		    result.append( c );
		fi
	    od
	    return result;
	end

	/// Return a copy of this string with all ASCII lower case characters converted to upper case equivalents. This
	/// method converts only 'a' - 'z', no other letters are affected.
	get StringBuffer UpperCase is
	    StringBuffer result = new StringBuffer(_length);
	    for int i = 0; i < _length; i = i + 1 do
		char c = [_buffer + i];
		if c >= 'a' && c <= 'a' then
		    result.append( c + ('A' - 'a') );
		else
		    result.append( c );
		fi
	    od
	    return result;
	end

	get int MemoryUse is 
	    return ObjectSize + _length;
	end

	get String Freeze is
	    var f = pool[this];
	    if f == null then
	        f = this.copy();
		pool[f] = f;
	    fi
	    return f;
	end
    end

    /// A variable length modifyible string of characters. 
    class StringBuffer extends String is
	private int _allocated_length;

	void init( char ptr s ) is
	    super.init(s);
	    _allocated_length = _length;
	end

	void init( String s ) is
	    if s != null then
		init( s.toCString() );
	    else
		init( 16 );
	    fi
	end

	void init( int l ) is
	    super.init(cast char ptr(null));
	    _reserve(l);
	end

	void init() is
	    init( 16 );
	end

	void _copy_from( char ptr s, int l ) is
	    if s == null then
		return;
	    fi

	    int i;
	    i = 0;

	    while i < l do
		[_buffer + i] = [s + i];
	    
		i = i + 1;
	    od
	end

	void _reserve( int l ) is
	    char ptr new_buffer, old_buffer;

	    if l > _allocated_length then
		old_buffer = _buffer;

		// allocation is slow and memory is cheap.
		// FIXME: may be worth constraining to powers of two to make allocation
		// faster:
		_allocated_length = l * 2;

		_buffer = cast char ptr( native.GC_malloc_atomic( _allocated_length ) );
		// native.printf( `%p len %d stringbuffer\n`, _buffer, _length );
		if old_buffer != null then
		    _copy_from( old_buffer, _length );
		fi
	    fi
	end

	void putCharAt( int i, char c ) is
	    opSet( i, c );
	end

	set char[int i] = c is
	    _reserve( i + 1 );

	    [_buffer + i] = c;
	    if i >= _length then
		_length = i + 1;
	    fi
	end
    
	char ptr toCString() is
	    _reserve( _length + 1 );

	    [_buffer + _length] = cast char( 0 );

	    return _buffer;
	end

        StringBuffer append( bool b ) is
	    if b then
	        append( "true" );
  	    else
	        append( "false" );
	    fi
        end
	        

	StringBuffer append( char c ) is
	    _reserve( _length + 1 );

	    [_buffer + _length] = c;
	    _length = _length + 1;

	    return this;
	end

	StringBuffer append( char ptr s ) is
	    _reserve( _length + _c_getLength( s ) );

	    while [s] != cast char(0) do
		[_buffer + _length] = [s];
		_length = _length + 1;
		s = s + 1;
	    od

	    return this;
	end

	set int Length = new_length is
	    if new_length >= 0 then
		_reserve( new_length + 1 );
		_length = new_length;
	    fi
	end

	StringBuffer append( int v, int b, int l, char pad ) is
	    StringBuffer t = new StringBuffer( l );
	    bool negative = false;
	    if v < 0 then
		negative = true;
		v = -v;
		t.append( '-' ); // FIXME: not really right
	    fi

	    t.append( v, b );

	    int nl = l - t.Length;

	    while nl > 0 do
		append( pad );
		nl = nl - 1;
	    od
	    return append( t );
	end

	StringBuffer append( int v, int b ) is
	    int m, n, i;
	    char c;
	    char ptr digit = `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ`;

	    // native.printf( `entry v is %d...\n`, v );
                
	    if b > 36 then
		append( "#base>36#" );
	    fi

	    i = 0;

	    if v < 0 then
		opSet( _length, cast char(45) );
		v = 0-v;
		i = 1;
	    elif v == 0 then
		opSet( _length, cast char(48) );
		return this;
	    fi

	    // native.printf( `before v is %d, b is %d...\n`, v, b );

	    i = 0;
	    m = v;
	    while m > 0 do
		// native.printf( `before m is %d...\n`, m );
		m = m / b;
		// native.printf( `after m is %d...\n`, m );
		i = i + 1;
	    od

	    // native.printf( `number %d length is %d chars\n`, v, i );

	    _reserve( i + _length ); // avoid repeated mallocs

	
	    i = i + _length;
	    while v > 0 do
		i = i - 1;
	    
		c = [digit + v % b];
		v = v / b;
	    
		opSet( i, c );
	    
	    od

	    return this;
	end

	StringBuffer append( word v, int ib ) is
            word b = cast word(b);
	    word m, n;
	    int i;
	    char c;
	    char ptr digit = `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ`;

	    // native.printf( `entry v is %d...\n`, v );
                
	    if ib > 36 then
		append( "#base>36#" );
	    fi

	    i = 0;

	    if v < 0w then
		opSet( _length, cast char(45) );
		v = 0w-v;
		i = 1;
	    elif v == 0w then
		opSet( _length, cast char(48) );
		return this;
	    fi

	    // native.printf( `before v is %d, b is %d...\n`, v, b );

	    i = 0;
	    m = v;
	    while m > 0w do
		// native.printf( `before m is %d...\n`, m );
		m = m / b;
		// native.printf( `after m is %d...\n`, m );
		i = i + 1;
	    od

	    // native.printf( `number %d length is %d chars\n`, v, i );

	    _reserve( i + _length ); // avoid repeated mallocs

	
	    i = i + _length;
	    while v > 0w do
		i = i - 1;
	    
		c = [digit + v % b];
		v = v / b;
	    
		opSet( i, c );
	    
	    od

	    return this;
	end

	/*
	StringBuffer append( word v, int b ) is
	    append( cast long(v), b );

	    return this;
	end
	*/

	StringBuffer append( int n ) is
	    return append( n, 10 );
	end
	

	StringBuffer append( word n ) is
	    return append( n, 10 );
	end

	StringBuffer append( String s ) is
	    if s != null then
		return append( s.toCString() );
	    else
		return append( `<null>` );
	    fi
	end

	
	StringBuffer append( Object o ) is
	    if o != null then
		return append( o.toString() );
	    else
		return append( `<null>` );
	    fi
	end


	StringBuffer copy() is
	    StringBuffer result;
	    result = new StringBuffer( toCString() );
	    return result;
	end

	get int MemoryUse is 
	    return ObjectSize + _allocated_length;
	end
    end

    class ConstString extends String is
	void init( char ptr s ) is
	    super.init( null );
	    if s != null then
		_buffer = s;
		_length = _c_getLength(s);
	    fi
	end
    end
end
