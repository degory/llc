#K
import object;
import integer;

import gsmap;
import giterator;

import serial;

namespace System is
    use Generic.SortedMap;
    use Generic.List;
    use Generic.Iterable;
    use Generic.Iterator;
    use Generic.Range;
    use Generic.Slice;

    @NoWarnUnsafe, NoMarkUnsafe;
   
    /// A string of characters. String is immutable, its child StringBuffer is not.
    class String do IO.Serial, List<char> is
	@NoWarnHide;

        protected char ptr _buffer;
	protected int _length;

        static SortedMap<String,String> pool = new SortedMap<String,String>();

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
	si

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
	si

	/// Format a string with a single argument
	static StringBuffer format( String s, int i ) is
	    return format( s, Object { new Int(i) } );
	si

	/// Format a string with a two arguments
	static StringBuffer format( String s, int i, int j ) is
	    return format( s, Object { new Int(i), new Int(i) } );
	si

	/// Format a string with a single argument
	static StringBuffer format( String s, Object i ) is
	    return format( s, { i } );
	si

	/// Format a string with a two arguments
	static StringBuffer format( String s, Object i, Object j ) is
	    return format( s, { i, j } );
	si

	// Construct a new String by copying the supplied C-string
	// \param s a C-string to copy. Must be terminated with cast char(0)
	void init( char ptr s ) is
	// System.Exit.check("S1");
	    super.init();

	    int i = 0;

	    if s == null then
		_buffer = null;
		_length = 0;
		return;
	    fi

	    _length = _c_getLength( s );

//  native.printf( `length of %s is %d\n`, s, _length ); native.__flush_stdout();
 	    _buffer = cast char ptr( native.GC_malloc_atomic( _length + 1) );
	    // native.printf( `%p len %d string\n`, _buffer, _length+1 );
	    while i <= _length do
			   // native.printf( `[%p+%d] <- %c\n`, _buffer, i, [s + i] ); native.__flush_stdout();

		[_buffer + i] = [s + i];
		i = i + 1;
// System.Exit.check("S3");
	    od

	    //System.Exit.check("S2");
	si

	/// Construct a new String by copying the supplied String
	void init( String s ) is
	    this.init( s.toCString() );
	si

	int hash() is
	    int result, i;
	    i = 0;
	    result = 5381;

	    while i < _length do
	        // result = result * 4 + cast int([_buffer + i]);
	        result = cast int([_buffer+i]) + (result << 6) + (result << 16) - result;
		i = i + 1;
	    od

   	    // native.printf( `hash %s -> %d\n`, toCString(), result );

	    return result;
	si

	/// Return character at supplied index
	/// \deprecated Use get char[int i] instead (\see opGet(int i))
	char charAt( int i ) is
	    return opGet(i);
	si

	/// Return character at supplied index
	/// \param i index of character to get
	get char[int i] is
	    // FIXME: not bounds checked!
	    return [_buffer + i];
	si

	String toString() is
	    return this;
	si

	/// Is supplied character white space?
	/// \param c character to test
	static bool isSpace( char c ) is
	    return c == ' ' || c == cast char(9) || c == '\n' || c == cast char(13);
	si

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
	si

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
	si
	    
        /// Return a String representing the supplied integer in base 8
	/// \param i the value to format in octal
	static String oct(int i) is
	    StringBuffer result = new StringBuffer();
	    result.append( i, 8 );
	    return result;
	si

        /// Return a String representing the supplied integer in base 16
	/// \param i the value to format in hex
	static String hex(int i) is
	    StringBuffer result = new StringBuffer();
	    result.append( i, 16 );
	    return result;
	si

        /// Return a String representing the supplied word in base 16
	/// \param i the value to format in hex
	static String hex(word i) is
	    StringBuffer result = new StringBuffer();
            result.append( cast long(i), 16 );
	    return result;
	si

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
	si

	/// Return the number of characters that comprise this String
	get int Length is
	    return _length;
	si

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
	si

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
	si

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
	si

	bool startsWith( char c ) is
	    return _length > 0 && [_buffer] == c;
	si

	/// Return true if the last character of this string equals the supplied character
	bool endsWith( char c ) is
	    return _length > 0 && [_buffer + _length - 1] == c;
	si

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
	si

	/// Return the first index where the supplied char appears in this String, or -1 if it
	/// does not appear
	int indexOf( char c ) is
	    for int i = 0; i < _length; i = i + 1 do
		if [_buffer+i] == c then
		    return i;
		fi
	    od

	    return -1;
	si

	/// Return the first index where the supplied char appears in this String, or -1 if it
	/// does not appear
	int indexOf( int i, char c ) is
	    for ; i < _length; i = i + 1 do
		if [_buffer+i] == c then
		    return i;
		fi
	    od

	    return -1;
	si

        /// Return the last index where the supplied char appears in this String, or -1 if it
	/// does not appear	
	int lastIndexOf( char c ) is
	    for int i = _length-1; i >= 0; i = i - 1 do
		if [_buffer+i] == c then
		    return i;
		fi
	    od

	    return -1;
	si

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
	si

	/// Return the first index where matches(s,index) is true
	int indexOf( System.String s ) is
	    for int i = 0; i < _length; i = i + 1 do
		if matches( s, i ) then
		    return i;
		fi
	    od
	    return -1;
	si


	/// Return the first index where matches(s,index) is true
        int indexOf( int i, System.String s ) is
	    for ; i < _length; i = i + 1 do
		if matches( s, i ) then
		    return i;
		fi
	    od
	    return -1;
	si

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
	si

	/// Equality operator
	/// \param t C-string to compare this String to
	bool opEquals( char ptr t ) is
	    int cl = _length;
	    int i;
	    for i = 0; i < cl; i = i + 1 do
 	        // char c = [t + i];
		if [_buffer+i] != [t + i] then
		    return false;
		fi
	    od

	    return [t + i] == cast char(0);
	si

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
		    int d = cast int(c) - cast int(ct);
		    // IO.Std.err.println( "'" + c + "'-'" + ct + "' mismatch result is: " + cast int(c - ct) );
		    return d;
		fi
	    od

	    // IO.Std.err.println( "tie result is: " + tie );
	    return tie;
	si

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
	si

	int toInt() is
	    if _length >= 2 && ([_buffer + 1] == 'x' || [_buffer + 1] == 'X') then
	        return parseInt(16);
            else
  	        return parseInt(10);
            fi
	si

	/// Parse this string as an integer
	/// \deprecated Use \see System.String.toInt() instead
	int parseInt() is
	    return toInt();
	si

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
	si

	long parseLong() is
	    return parseLong(10);
	si

        word parseWord() is
	    return cast word(parseLong(10));
        si

	/// Parse this string as an long of supplied base
	/// \param base radix to use for conversion. Must be between 1 and 36
	/// \throw Exception if this String cannot be parsed in supplied base
	long parseLong( int base ) is
            bool negative = false;
            long b = cast long(base);
	    int i;
	    if _length >= 1 && [_buffer] == '-' then
		negative = true;
		i = 1;
	    fi
	    long result = 0l;

	    char c;
	    if base <= 10 then
		for ; i < _length; i = i + 1 do
		    int n = cast int([_buffer + i] - '0');
		    if n >= 0 && n < base then
			result = result * b + cast long(n);
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
			result = result * b + cast long(c - '0');
		    elif c >= 'A' && c < 'A' + cast char(base-10) then
			result = result * b + 10L + cast long(c - 'A');
		    elif c >= 'a' && c < 'a' + cast char(base-10) then
			result = result * b + 10L + cast long(c - 'a');
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
	si

	/// Return the length in characters of supplied C-string
	/// \param s C-string to get the length of. Must be terminated with cast char(0)
	int _c_getLength( char ptr s ) is
	    int i;
	    for i = 0; [s + i] != cast char(0); i = i + 1 do
	        ;
	    od

	    return i;
	si

	/// Return a copy of this string.
	String copy() is
	    return this;
	si

	/// Returns a substring of this string comprised of characters from and including the supplied position up to and including the last character 
	/// in the string. If from is greater than or equal to length then result is an empty String. Behaviour is undefined if from is negative
	/// \param from index of first character to include in substring
	StringBuffer substring( int from ) is
	    return substring( from, _length );
	si

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
	si

        Slice<char> slice( int from, int to ) is
	    return new Slice<char>(this, from, to);
	si

	get String[Range<int> r] is
	    return substring(r.from, r.to+1);
        si

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
			t = new StringBuffer(16);
			result[j] = t;
		    else
			break;
		    fi
		else
		    t.append( c );
		fi
	    od

	    return result;
	si

	/// Implements + operator. 
	StringBuffer opAdd( String s ) is
	// System.Exit.check("A0");
	    return new StringBuffer( toCString() ).append( s );
	si

	/// Implements + operator. 
	StringBuffer opAdd( int i ) is
	// System.Exit.check("C1");
            var c = toCString();
// System.Exit.check("C2");
            var b = new StringBuffer( c );
//            System.Exit.check("C3");
            var r = b.append(i);
//            System.Exit.check("C4");
            return r;
// return new StringBuffer( toCString() ).append( i );
	si

	/// Implements + operator. 
	StringBuffer opAdd( word w ) is
	    return new StringBuffer( toCString() ).append( w );
	si

	StringBuffer opAdd( long l ) is
	    return new StringBuffer( toCString() ).append( l );
        si

	/// Implements + operator. 
	//StringBuffer opAdd( long l ) is
	//    return new StringBuffer( toCString() ).append( cast word(l) );
	//si

	/// Implements + operator. 
	StringBuffer opAdd( char c ) is
	//	    System.Exit.check("A2");

	    return new StringBuffer( toCString() ).append( c );
	si

	/// Implements + operator. 
	StringBuffer opAdd( bool b ) is
	    if b then
		return new StringBuffer( toCString() ).append( `true` );
	    else
		return new StringBuffer( toCString() ).append( `false` );
	    fi
	si

	/// Implements + operator. 
	StringBuffer opAdd( char ptr s ) is
	    //	    System.Exit.check("A3");

	    return new StringBuffer( toCString() ).append( s );
	si

	/// Implements + operator. 
	StringBuffer opAdd( Object o ) is
	//	    System.Exit.check("A4");

	    return new StringBuffer( toCString() ).append( o );
	si

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
	si

	/// Return a copy of this string with all ASCII lower case characters converted to upper case equivalents. This
	/// method converts only 'a' - 'z', no other letters are affected.
	get StringBuffer UpperCase is
	    StringBuffer result = new StringBuffer(_length);
	    for int i = 0; i < _length; i = i + 1 do
		char c = [_buffer + i];
		if c >= 'a' && c <= 'z' then
		    result.append( c + ('A' - 'a') );
		else
		    result.append( c );
		fi
	    od
	    return result;
	si

	get int MemoryUse is 
	    return ObjectSize + _length;
	si

	get String Freeze is
	    return this;

	    var f = pool[this];
	    if f == null then
	        f = this.copy();
		pool[f] = f;
	    fi
	    return f;
	si

	get StringIterator Iterator is
	    return new StringIterator(this);
	si

        StringBuffer replace(char c, char d) is
	    var result = new StringBuffer(Length);

            foreach var i; Iterator do
	        if i == c then
		    result.append(d);
		else
		    result.append(i);
		fi
	    od

	    return result;
        si

        void toSerial( IO.SerialWriter w ) is
	    // IO.Std.err.println( "String.toSerial '" + this + "'" );
	    w.add(this);
	si

	Object fromSerial( IO.SerialReader r ) is
	    init(r.readString());
            return this;
	si

        void add(char c) is
            throw new NotImplementedException("System.String is read only");
	si

        void add(Iterable<char> c) is
            throw new NotImplementedException("System.String is read only");
	si

	void lengthen(int len) is
	    if len > _length then
	        throw new NotImplementedException("System.String is read only");
	    fi
	si

	void remove(char c) is
            throw new NotImplementedException("System.String is read only");	    
	si

	bool contains(char c) is
	    return indexOf(c) >= 0;
	si

	bool isEmpty() is
	    return _length == 0;
	si

	StringIterator elements() is
	    return Iterator;
        si

	set char[int index] = c is
            throw new NotImplementedException("System.String is read only");	    
        si
    si

    class StringIterator do Iterator<char> is
        String s;
        int index;

	void init( String s ) is
	    this.s = s;	    
	si

	bool hasMoreElements() is
	    return index < s.Length;
	si

	char nextElement() is
	    var result = s[index];
	    index = index + 1;
	    return result;
	si

	get StringIterator Iterator is
	    return this;
	si
    si

				  
    /// A variable length modifyible string of characters. 
    class StringBuffer isa String is
	const int INITIAL_LENGTH = 16;
	const int MAX_DOUBLE_LENGTH = 65536;
	const int LENGTH_INCREMENT = 16384;

        static bool in_check;

	private int _allocated_length;

	void init( char ptr s ) is
	/*
	    if s != null then
   	        native.printf( `new string buffer from [%s]\n`, s );
            else
		native.printf( `new string buffer from null\n` );
	    fi
	*/
	    super.init(s);
            _allocated_length = _length;
	si

	void init( String s ) is
	    @NoWarnInit;
	    if s != null then
		init( s.toCString() );
	    else
		init( INITIAL_LENGTH );
	    fi	    
	si

	void init( int l ) is
	    super.init(cast char ptr(null));
	    _reserve(l);
	si

	void init() is
	    init( INITIAL_LENGTH );
	si

	void _copy_from( char ptr s, int l ) is
	    if s == null then
		return;
	    fi

	    int i;
	    i = 0;

	    while i < l do
	        // checkIndex(i);

		[_buffer + i] = [s + i];
	    
		i = i + 1;
	    od
	    // check();
	si

	void _reserve( int l ) is
	    char ptr new_buffer, old_buffer;

	    if l > _allocated_length then
		old_buffer = _buffer;

                int a = l; // _allocated_length;

		if a < MAX_DOUBLE_LENGTH then
		    a = a * 2;
		else 
		    a = a + LENGTH_INCREMENT;
		fi

		if a < l then
		    a = l;
		fi

		_buffer = cast char ptr( native.GC_malloc_atomic( a ) );

		_allocated_length = a;

                // mark();

		// native.printf( `%p len %d stringbuffer\n`, _buffer, _length );
		if old_buffer != null then
		    _copy_from( old_buffer, _length );
		fi

	    fi
	si

		/*
	void mark() is
            if !in_check then
                [_buffer + _allocated_length] = 254c;

		bool ic = in_check;
		in_check = true;

		in_check = ic;
		   
		// check();
	    fi
	si
		*/
	void putCharAt( int i, char c ) is
	    opSet( i, c );
	si

	set char[int i] = c is
	    if i < 0 then
		throw new BoundsException( "string index out of range" );
	    fi

	    _reserve( i + 1 );
            if i >= _length then
		_length = i + 1;
	    fi

            // checkIndex(i);	
	    [_buffer + i] = c;

	    // check();
	si
    
	char ptr toCString() is
	    _reserve( _length + 1 );

            // checkIndex(_length);
	    [_buffer + _length] = cast char( 0 );

            // check();

	    return _buffer;
	si

        StringBuffer append( bool b ) is
	    if b then
	        append( "true" );
  	    else
	        append( "false" );
	    fi
        si
	        

	StringBuffer append( char c ) is
	    //	    System.Exit.check( "E" );
	    _reserve( _length + 1 );

	    // checkIndex(_length);
	    [_buffer + _length] = c;
	    _length = _length + 1;

	    // check();
//  	    System.Exit.check( "F" );

	    return this;
	si

	StringBuffer append( char ptr s ) is
	//  	    System.Exit.check( "G" );
	    _reserve( _length + _c_getLength( s ) );

	    while [s] != cast char(0) do
	        // checkIndex(_length);
		[_buffer + _length] = [s];
		_length = _length + 1;
//  	        System.Exit.check( "I" );
		s = s + 1;
	    od

	    // native.printf( `%p: will check at %d (%d)\n`, this, _allocated_length, _length );

	    // check();

	    //  	    System.Exit.check( "H" );

	    return this;
	si

	set int Length = new_length is
	    if new_length >= 0 then
		_reserve( new_length + 1 );
		_length = new_length;
	    fi
	si

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
	si

	StringBuffer append( int v, int b ) is
	    int m, n, i;
	    char c;
	    char ptr digit = `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ`;

	    // native.printf( `entry v is %d...\n`, v );

//            System.Exit.check("M");
                
	    if b > 36 then
		append( "#base>36#" );
	    fi

	    i = 0;

	    if v < 0 then
		opSet( _length, cast char(45) );
		v = 0-v;
		i = 1;
//                System.Exit.check("N");
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
	    //  	    System.Exit.check( "J" );
	    _reserve( i + _length ); // avoid repeated mallocs

	
	    i = i + _length;
	    while v > 0 do
		i = i - 1;
	    
		c = [digit + v % b];
		v = v / b;
	    
		this[i] = c;
	    
	    od
	    //  	    System.Exit.check( "K" );
	    // check();

	    return this;
	si

	StringBuffer append( long v, int ib ) is
            long b = cast long(ib);
	    long m, n;
	    int i;
	    char c;
	    char ptr digit = `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ`;

// native.printf( `entry v is %ld...\n`, v );
                
	    if ib > 36 then
		append( "#base>36#" );
	    fi

	    i = 0;

	    if v < 0l then
		opSet( _length, cast char(45) );
		v = 0l-v;
		i = 1;
	    elif v == 0l then
		opSet( _length, cast char(48) );
		return this;
	    fi

	    // native.printf( `before v is %d, b is %d...\n`, v, b );

	    i = 0;
	    m = v;
	    while m > 0l do
		// native.printf( `before m is %d...\n`, m );
		m = m / b;
		// native.printf( `after m is %d...\n`, m );
		i = i + 1;
	    od

	    // native.printf( `number %d length is %d chars\n`, v, i );

	    _reserve( i + _length ); // avoid repeated mallocs

	
	    i = i + _length;
	    while v > 0l do
		i = i - 1;
	    
		c = [digit + v % b];
		v = v / b;
	    
		this[i] = c;
	    
	    od

	    // check();

	    return this;
	si

	/*
	StringBuffer append( word v, int b ) is
	    append( cast long(v), b );

	    return this;
	si
	*/

	StringBuffer append( int n ) is
	    return append( n, 10 );
	si
	
	StringBuffer append( long n ) is
	    return append( n, 10 );
        si

	StringBuffer append( word n ) is
	    return append( cast long(n), 10 );
	si

	StringBuffer append( String s ) is
	    if s != null then
		return append( s.toCString() );
	    else
		return append( `<null>` );
	    fi
	si

	
	StringBuffer append( Object o ) is
	    if o != null then
		return append( o.toString() );
	    else
		return append( `<null>` );
	    fi
	si


	StringBuffer copy() is
	    return new StringBuffer( toCString() );
	si

	get int MemoryUse is 
	    return ObjectSize + _allocated_length;
	si

	/*
	void checkFail() is

	    native.printf( `%p: checking at %d (%d) char is '%c' (%02x)\n`, this, _allocated_length, _length, [_buffer + _allocated_length], cast int([_buffer + _allocated_length]) );	

	    native.printf( `string buffer is '%s'\n`, _buffer );
            native.__flush_stdout();
	    throw new System.Exception( "corrupt string buffer: " + this );
	si

	void checkIndex(int i) is
	    if in_check then
		if i < 0 || i >= _allocated_length then
		    native.printf( `out of bounds index within string check %d versus %d\n`, i, _allocated_length );
	        fi

		//		if i >= _length then
		//   native.printf( `suspicious string index within string check %d versus %d\n`, i, _length );
		//fi
	        return;
            fi

	    if i < 0 || i >= _allocated_length then
	        in_check = true;
		throw new BoundsException("out of bounds string index: " + i + " in " + this );
 	    fi
	    //
	    //if i >= _length then
	    //		native.printf( `suspicious string index %d versus %d\n`, i, _length );
	    //fi
	si

        void check() is
            if in_check then
	        return;
            fi

	    in_check = true;
	    if [_buffer + _allocated_length] != 254c then
	        checkFail();
	    fi

	    in_check = false;
	si
	*/

        void add(char c) is
            append(c);
	si

        void add(Iterable<char> b) is
	    foreach var c; b.Iterator do
	        append(c);
	    od
	si
    si

    class ConstString isa String is
	void init( char ptr s ) is
	    super.init( null );
	    if s != null then
		_buffer = s;
		_length = _c_getLength(s);
	    fi
	si
    si
si
