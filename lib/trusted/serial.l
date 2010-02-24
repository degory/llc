
namespace IO {
    use System.Object;
    use System.Class;
    use System.String;
    use System.Int;
    use System.Word;
    use System.Long;
    use System.Bool;
    use System.StringBuffer;
    use Generic.Map;
    use Generic.List;

    interface Serial {
	// when this method is called, object is expected to write a representation of itself to stream b
	void toSerial(SerialWriter b);

	// when this method is called, object is expected to initialize itself by reading its representation from stream b
	Object fromSerial(SerialReader b);
    }

    enum SerialToken {
	EOF,
        OPEN,
	CLOSE,
	REFERENCE,
	ASSIGN,
	STRING
    } 

    class SerialParser {
	static bool debug = false;

	Reader is;
	bool is_eof;
	char current_char;
	SerialToken current_token;
	String current_string;

	static set bool Debug = d {
	    debug = d;
	}

        static get bool Debug {
	    return debug;
	}

	void init(Reader is) {
	    this.is = is;
	    readChar();
	    readToken();
	}

	get bool AtEOF {
	    return is_eof;
	}

	get char CurrentChar {
	    return current_char;
	}
    
	get SerialToken CurrentToken {
	    return current_token;
	}

	get String CurrentString {
	    return current_string;
	}

	private char readChar() {
	    int c = is.read();

	    if( c != -1 ) {
		if( debug ) {
		    IO.Std.err.print( "" + cast char(c) );
		}
		current_char = cast char(c);
	    } else {
		if( debug ) {
		    IO.Std.err.println( "end of file" );
		}
		is_eof = true;
		current_char = ' ';
	    }
	    return current_char;
	}

	SerialToken readToken() {
	    while( !AtEOF && isSpace(CurrentChar) ) {
		readChar();
	    }

	    if( AtEOF ) {
		current_token = SerialToken.EOF;
		return current_token;
	    }

	    switch( CurrentChar ) {
	    case '{':
		readChar();
		readString();
		current_token = SerialToken.OPEN;

	    case '}':
		readChar();
		current_token = SerialToken.CLOSE;

	    case '*':
		readChar();
		readString();
		current_token = SerialToken.REFERENCE;

	    case ':':
		readChar();
		readString();
		current_token = SerialToken.ASSIGN;

	    case '"':
		readQuotedString();
		current_token = SerialToken.STRING;

	    default:
		readString();
		current_token = SerialToken.STRING;
	    }

	    // IO.Std.err.println( "read " + current_token + "/" + current_string );

	    return current_token;
	}

	private bool isSpace(char c) {
	    // IO.Std.err.println( "isSpace('" + c + "'?" );
	    return c == ' ' || c == '\t' || c == '\n' || c == '\r';
	}

	private String readString() {
	    var result = new StringBuffer();
	    // IO.Std.err.println( "reading string..." );
	    while( !AtEOF && !isSpace(CurrentChar) ) {
		// IO.Std.err.println( "appending '" + CurrentChar + "'" );
		result.append(CurrentChar);
		readChar();
	    }

	    // IO.Std.err.println( "returning string '" + result.toString() + "'" );

	    current_string = result;

	    return current_string;
	}

	private String readQuotedString() {
	    // IO.Std.err.println( "reading quoted string..." );
	    var b = new StringBuffer();

	    bool quoted = true;
	    for( readChar(); quoted && !this.AtEOF; ) {
		if( CurrentChar == '#' ) {
		    readChar();
		    int c = 0;
		    for( int i = 0; i < 3; i = i + 1 ) {
			c = c * 10 + cast int(CurrentChar - '0');
			readChar();
		    }
		    b.append( cast char(c) );
		} else if( CurrentChar == '"' ) {
		    quoted = !quoted;
		    readChar();
		    if( CurrentChar == '"' ) {
			b.append('"');
			quoted = !quoted;
			readChar();
		    }
		} else {
		    b.append(CurrentChar);
		    readChar();
		}
	    }

	    current_string = b;

	    return current_string;
	}
    }

    // the syntax of the protocol is dirt simple.
    // - there are three tokens: open bracket; close bracket and string.
    // - whitespace is not significant
    // - string is EITHER any sequence of non-white space chars not starting with '{' or '}' OR
    //   any sequence of characters (including whitespace and control characters) quoted with '"'
    // - within a quoted string quote chars must be doubled ("")


    // example
    // [ 1234 1234.5 11/05/05 wibble[wobble " contains spaces " [ sub-record ] ]

    

    class ListReader<T> {
	static void read(SerialReader r, List<T> l) {
	    r.open();
	    while( r.isOpen() ) {
		var o = r.read();
		if( "".likeMe(o) ) {
		    l.add( T.fromString(cast String(o)) );
		} else {
		    l.add( cast T(o) );
		}
	    }
	    r.close();
	}
    }

    class ListWriter<T> {
	static void write(SerialWriter w, List<T> l) {
	    w.open();
	    foreach( T v; l.elements() ) {
		w.add(v);
	    }
	}
    }

    class SerialReader {
	public static bool debug = false;

	static Map<String,Class> classes;
	static Map<Class,String> names;
	SerialParser parser;

	int level;
	Map<String,Object> references;

	Object current_reference;

	public void init(Reader is) {
	    parser = new SerialParser(is);
	    references = new Map<String,Object>();
	}

	public static bool register(Class c) {
	    return register(c.Name, c);
	}

	public static bool register(String key, Class c) {
	    if( classes == null ) {
		classes = new Map<String,Class>();
		names = new Map<Class,String>();
	    }
	    classes[key] = c;
	    names[c] = key;
	    if( debug ) {
		IO.Std.err.println( "registered " + key + " as " + c );
	    }
	    return true;
	}

	static String getTagForClass(Class c) {
	    return names[c];
	}

	static Class getClassForTag(String n) { 
	    return classes[n];
	}

	public get String CurrentString {
	    return parser.CurrentString;
	}

	public get SerialToken CurrentToken {
	    return parser.CurrentToken;
	}

	public bool isOpen() {
	    return parser.CurrentToken != SerialToken.CLOSE;
	}

	bool checkReference() {
	    if( parser.CurrentToken == SerialToken.ASSIGN ) {
		current_reference = readAssign();
		return true;
	    } else if( parser.CurrentToken == SerialToken.REFERENCE ) {
		if( parser.CurrentString.Length > 0 ) {
		    IO.Std.err.println( "look up: " + parser.CurrentString );
		    IO.Std.err.println( "in: " + references );
		    current_reference = references[parser.CurrentString];
		} else {
		    // IO.Std.err.println( "null reference" );
		    current_reference = null;
		}
		parser.readToken();
		return true;
	    } else if( parser.CurrentToken == SerialToken.CLOSE ) {
		// IO.Std.err.println( "close token - returning null reference" );
		current_reference = null;
		return true;
	    } else {
		// IO.Std.err.println( "not a reference" );
		return false;
	    }
	}

	public Object readAssign() {
	    // IO.Std.err.println( "read assign..." );
	    String r = parser.CurrentString;
	    parser.readToken();

	    // IO.Std.err.println( "reading value for assign '" + r + "'" );
	    Object value = read();
	    references[r] = value;
	    // IO.Std.err.println( "done assign..." );
	    return value;
	}

	public Object read() {
	    if( checkReference() ) {
		return current_reference;
	    } else if( parser.CurrentToken == SerialToken.OPEN ) {
		/*
		if( !parser.CurrentString.equals("*") ) {
		*/
		if( classes == null ) {
		    // classes is null if no tags registered:
		    throw new IOException("undefined tag: '" + parser.CurrentString + "'" );
		}

		    Class c = classes[parser.CurrentString];
		    if( c != null ) {
			if( c.IsArray ) {
			    IO.Std.err.println( "is array: " + c.Name );
			}

			Object o;
			Serial p = null;
			try {
			    o = c.create();
			    if( isa Serial(o) ) {
				p = cast Serial(o);
				// IO.Std.err.println( "have: " + cast Object(p) );

				o = p.fromSerial(this);
			    } else {
				o = readObjectDefault(o);
			    }
			} catch( System.Exception e ) {
			    throw new IOException("problem instantiating: " + c + " (" + e + ")" );
			}
			return o;
		    } else {
			throw new IOException("undefined tag: '" + parser.CurrentString + "'" );
		    }
		    /*
		} else {
		    parser.readToken();
		    var v = new Vector<Object>();
		    while( parser.CurrentToken != SerialToken.CLOSE ) {
			v.add(read());
		    }
		    parser.readToken();
		    return v;
		}
		    */
	    } else if( parser.CurrentToken == SerialToken.STRING ) {
		// IO.Std.err.println( "read(): token Token.STRING..." );
		// no open bracket - read single string
		String result = parser.CurrentString;
		// IO.Std.err.println( "read(): token Token.STRING -> " + result );
		parser.readToken();
		// IO.Std.err.println( "done read() [string: '" + result + "']" );
		return result;
		/* } else if( parser.CurrentToken == SerialParser.INT ) {
		Integer result = new Integer(parser.CurrentString);
		parser.readToken();
		// IO.Std.err.println( "done read() [integer: " + result + "]" );
		return result; */
	    } else {
		throw new IOException( "unexpected token: " + cast int(parser.CurrentToken) + "/" + parser.CurrentString );
	    }
	}

	public void open() {
	    // IO.Std.err.println( "read open untagged" );
	    if( parser.CurrentToken == SerialToken.OPEN ) {
		parser.readToken();
	    } else {
		throw new IOException( "expected '{' reading untagged record" );
	    }
	}

	public void open( String tag ) {
	    // IO.Std.err.println( "read open:" + tag );
	    if( parser.CurrentToken == SerialToken.OPEN && parser.CurrentString.equals(tag) ) {
		parser.readToken();
	    } else {
		throw new IOException("expected tag: '{'" + tag + "'");
	    }
	}

	public void checkNull() {
	    if( current_reference != null ) {
		IO.Std.err.println( "cannot reference this - returning null" );
	    }
	}

	public long readLong() {
	    if( checkReference() ) {
		checkNull();
		return 0L;
	    } else if( parser.CurrentToken == SerialToken.STRING ) {
		long result = Long.fromString(parser.CurrentString);
		parser.readToken();
		return result;
	    } else {
		throw new IOException( "expected an integer, read: '" + parser.CurrentString + "'" );
	    }
	}

	public word readWord() {
	    if( checkReference() ) {
		checkNull();
		return 0W;
	    } else if( parser.CurrentToken == SerialToken.STRING ) {
		word result = Word.fromString(parser.CurrentString);
		parser.readToken();
		return result;
	    } else {
		throw new IOException( "expected an integer, read: '" + parser.CurrentString + "'" );
	    }
	}

	public int readInt() {
	    if( checkReference() ) {
		checkNull();
		return 0;
	    } else if( parser.CurrentToken == SerialToken.STRING ) {
		int result = Int.fromString(parser.CurrentString);
		parser.readToken();
		return result;
	    } else {
		throw new IOException( "expected an integer, read: '" + parser.CurrentString + "'" );
	    }
	}

	public String readString() {
	    if( checkReference() ) {
		checkNull();
		return null;
	    } else if( parser.CurrentToken == SerialToken.STRING ) {
		String result = parser.CurrentString;
		parser.readToken();
		return result;
	    } else {
		throw new IOException( "expected a string" );
	    }
	}

	public bool readBool() {
	    if( checkReference() ) {
		checkNull();
		return false;
	    } else if( parser.CurrentToken == SerialToken.STRING ) {
		bool result = Bool.fromString(parser.CurrentString);
		parser.readToken();
		return result;
	    } else {
		throw new IOException( "expected a bool" );
	    }
	}

	public char readChar() {
	    if( checkReference() ) {
		checkNull();
		return '\0';
	    } else if( parser.CurrentToken == SerialToken.STRING && parser.CurrentString.Length == 1 ) {
		char result = parser.CurrentString.charAt(0);
		parser.readToken();
		return result;
	    } else {
		throw new IOException( "expected a single character bure received '" + parser.CurrentString + "'");
	    }
	}

	public void close() {
	    while( parser.CurrentToken != SerialToken.CLOSE ) {
		read();
	    }
	    parser.readToken();
	}
	
	public get bool AtEOF {
	    return parser.AtEOF;
	}

	Object readElements( Object t, int offset, int length, int type ) {
	    word ptr result;

	    switch( type ) {
	    case TYPE_BOOL:
		bool b;		
		result = cast word ptr(native.GC_malloc(offset + b.sizeof * length));
		[cast int ptr(result+1)] = length;
		var bp = cast bool ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [bp] = readBool();
		    length = length - 1;
		    bp = bp + 1;
		}
		
	    case TYPE_CHAR:
		char c;
		result = cast word ptr(native.GC_malloc(offset + c.sizeof * length));
		[cast int ptr(result+1)] = length;
		var cp = cast char ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [cp] = readChar();
		    length = length - 1;
		    cp = cp + 1;
		}
		
	    case TYPE_LONG:
		long l;
		result = cast word ptr(native.GC_malloc(offset + l.sizeof * length));
		[cast int ptr(result+1)] = length;
		var lp = cast long ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [lp] = readLong();
		    length = length - 1;
		    lp = lp + 1;
		}

	    case TYPE_WORD:
		word w;
		result = cast word ptr(native.GC_malloc(offset + w.sizeof * length));
		[cast int ptr(result+1)] = length;
		var wp = cast word ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [wp] = readWord();
		    length = length - 1;
		    wp = wp + 1;
		}
	       		       
	    case TYPE_INTEGER:
		int i;
		result = cast word ptr(native.GC_malloc(offset + i.sizeof * length));
		[cast int ptr(result+1)] = length;
		var ip = cast int ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [ip] = readInt();
		    length = length - 1;
		    ip = ip + 1;
		}
		
	    case TYPE_CLASS,
		TYPE_VECTOR:
		Object o;
		result = cast word ptr(native.GC_malloc(offset + o.sizeof * length));
		[cast int ptr(result+1)] = length;
		var op = cast Object ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    IO.Std.err.println( "read into " + cast long(op) + ", " + length + " elements to go..." );
		    [op] = read();
		    length = length - 1;
		    op = op + 1;
		}

	    default:
		throw new IOException( "cannot read array element of type " + type );				
	    }

	    // copy vtable:
	    [result] = [cast word ptr(t)];

	    return cast Object(result);
	}

	Object readArray( Class klass ) {
	    int type;
	    int offset;
	    int ptr pt = klass.TypeTable;

	    if( !readType( pt, type, offset ) ) {
		throw new System.Exception( "expected int length field reading array: " + klass.Name );
	    }

	    int length = readInt();

	    if( !readType( pt, type, offset ) ) {
		throw new System.Exception( "expected array element type reading array: " + klass.Name );
	    }

	    word ptr result;

	    open();

	    switch( type ) {
	    case TYPE_BOOL:
		bool b;		
		result = cast word ptr(native.GC_malloc(offset + b.sizeof * length));
		[cast int ptr(result+1)] = length;
		var bp = cast bool ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [bp] = readBool();
		    length = length - 1;
		    bp = bp + 1;
		}
		
	    case TYPE_CHAR:
		char c;
		result = cast word ptr(native.GC_malloc(offset + c.sizeof * length));
		[cast int ptr(result+1)] = length;
		var cp = cast char ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [cp] = readChar();
		    length = length - 1;
		    cp = cp + 1;
		}
		
	    case TYPE_LONG:
		long l;
		result = cast word ptr(native.GC_malloc(offset + l.sizeof * length));
		[cast int ptr(result+1)] = length;
		var lp = cast long ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [lp] = readLong();
		    length = length - 1;
		    lp = lp + 1;
		}

	    case TYPE_WORD:
		word w;
		result = cast word ptr(native.GC_malloc(offset + w.sizeof * length));
		[cast int ptr(result+1)] = length;
		var wp = cast word ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [wp] = readWord();
		    length = length - 1;
		    wp = wp + 1;
		}
		       
	    case TYPE_INTEGER:
		int i;
		result = cast word ptr(native.GC_malloc(offset + i.sizeof * length));
		[cast int ptr(result+1)] = length;
		var ip = cast int ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    [ip] = readInt();
		    length = length - 1;
		    ip = ip + 1;
		}

	    case TYPE_CLASS,
		TYPE_VECTOR:
		Object o;
		result = cast word ptr(native.GC_malloc(offset + o.sizeof * length));
		[cast int ptr(result+1)] = length;
		var op = cast Object ptr(cast char ptr(result)+offset);

		while( length > 0 ) {
		    IO.Std.err.println( "read into " + cast long(op) + ", " + length + " elements to go..." );
		    [op] = read();
		    length = length - 1;
		    op = op + 1;
		}

	    default:
		throw new IOException( "cannot read array element of type " + type );				
	    }

	    close();

	    // copy vtable:
	    [result] = [cast word ptr(klass.VTable)];

	    return cast Object(result);
	}


	char ptr readPointer(int type, int length) {
	    char ptr result;

	    switch( type ) {
	    case TYPE_BOOL:
		bool b;		
		var bp = cast bool ptr(native.GC_malloc(b.sizeof * length));
		result = cast char ptr(bp);

		while( length > 0 ) {
		    [bp] = readBool();
		    length = length - 1;
		    bp = bp + 1;
		}
		
	    case TYPE_CHAR:
		char c;
		var cp = cast char ptr(native.GC_malloc(c.sizeof * length));
		result = cast char ptr(cp);

		while( length > 0 ) {
		    [cp] = readChar();
		    length = length - 1;
		    cp = cp + 1;
		}
		
	    case TYPE_LONG:
		long l;
		var lp = cast long ptr(native.GC_malloc(l.sizeof * length));
	        result = cast char ptr(lp);

		while( length > 0 ) {
		    [lp] = readLong();
		    length = length - 1;
		    lp = lp + 1;
		}

	    case TYPE_WORD:
		word w;
		var wp = cast word ptr(native.GC_malloc(w.sizeof * length));
	        result = cast char ptr(wp);

		while( length > 0 ) {
		    [wp] = readWord();
		    length = length - 1;
		    wp = wp + 1;
		}
		       
	    case TYPE_INTEGER:
		int i;
		var ip = cast int ptr(native.GC_malloc(i.sizeof * length));
		result = cast char ptr(ip);

		while( length > 0 ) {
		    [ip] = readInt();
		    length = length - 1;
		    ip = ip + 1;
		}

	    case TYPE_CLASS,
		TYPE_VECTOR:
		Object o;
		var op = cast Object ptr(native.GC_malloc(o.sizeof * length));
		result = cast char ptr(op);

		while( length > 0 ) {
		    IO.Std.err.println( "read into " + cast long(op) + ", " + length + " elements to go..." );
		    [op] = read();
		    length = length - 1;
		    op = op + 1;
		}

	    default:
		throw new IOException( "cannot read array element of type " + type );				
	    }

	    return result;
	}


	static bool readType( int ptr ref tp, int ref type, int ref offset ) {
	    int ct = [tp];
	    if( ct == 0 ) {
		return false;
	    }

	    tp = tp + 1;

	    offset = ct & 0xFFFF;
	    type = (ct >> 16) & 0xFFFF;

	    return true;
	}

	Object readObjectDefault( Object o ) {
	    int ptr pt = o.TypeTable;
	    var result = o;

	    // IO.Std.err.println( "type table: " + cast long(pt) );

	    bool is_array = o.IsArray;
	    int l;
	    int n = 0;

	    open();

	    do {
		int offset, type;

		if( !readType( pt, type, offset ) ) {
		    break;
		}

		char ptr p = cast char ptr(o) + offset;

		if( is_array && l > 0 ) {
		    // if object is an array then first integer field is length and following field specifies offset of
		    // element data and its type:
		    IO.Std.err.println( "should read " + l + " array elements starting at offset " + offset );
		    result = readElements( o, offset, l, type );
		    break;
		}

		/*
		IO.Std.err.println( "offset: " + offset );
		IO.Std.err.println( "type: " + type );
		IO.Std.err.println( "field address: " + cast long(p) );
		*/

		switch( type ) {
		case TYPE_BOOL:
		    // IO.Std.err.println( "read bool..." );
		    [cast bool ptr(p)] = readBool();

		case TYPE_CHAR:
		    // IO.Std.err.println( "read char..." );
		    [cast char ptr(p)] = readChar();

		case TYPE_LONG:
		    // IO.Std.err.println( "read long..." );
		    [cast long ptr(p)] = readLong();

		case TYPE_WORD:
		    [cast word ptr(p)] = readWord();

		case TYPE_INTEGER:
		    // IO.Std.err.println( "read int..." );
		    l = readInt();
		    [cast int ptr(p)] = l; // readInt();

		case TYPE_POINTER:
		    if( !readType( pt, type, offset ) ) {
			throw new IO.IOException( "expected sub type in type table " + o.Class.Name + " writing pointer @ " + offset );
		    }
		    l = o._get_PointerLength(n);		    

		    [cast word ptr(p)] = cast word(readPointer(type, l));
		    n = n + 1;

		case TYPE_CLASS,
		    TYPE_VECTOR:
		    // IO.Std.err.println( "read object..." );
		    [cast Object ptr(p)] = read();

		default:
		    throw new IOException( "cannot read " + o.Class.Name + " field @ " + offset + " of type " + type );
		}
	    } while(true);

	    close();

	    return result;
	}
    }

    public class SerialWriter {
	const int MAX_INDENT = 4;
	public static bool debug = false;

	bool optional;
	Writer os;
	public int indent_;
	bool[] by_reference;
	Map<Object,int> references;
	int handle;

	public void init(Writer os) {
	    this.os = os;
	    indent_ = 0;
	    handle = 1;

	    by_reference = new bool[64];
	    references = new Map<Object,int>();
	}

	public void append( char c ) {
	    if( debug ) {
		IO.Std.err.print( "" + c );
	    }
	    os.print(c);
	}

	public void append( int i ) {
	    if( debug ) {
		IO.Std.err.print( "" + i );
	    }
	    os.print(i);
	}

	public void append( word i ) {
	    if( debug ) {
		IO.Std.err.print( "" + i );
	    }
	    os.print(i);
	}

	public void append( long i ) {
	    if( debug ) {
		IO.Std.err.print( "" + i );
	    }
	    os.print(i);
	}

	public void append( String s ) {
	    if( debug ) {
		IO.Std.err.print( s );
	    }
	    os.print(s);
	}

	public static String quote( String t ) {
	    if( t != null ) {
		StringBuffer result = new StringBuffer(t.Length + 2);
		result.append( '"' );
		bool seen_dodgy = t.Length == 0 || (t.charAt(0) == '-' || (t.charAt(0) >= '0' && t.charAt(0) <= '9'));

		for( int j = 0; j < t.Length; j = j + 1 ) {
		    char c = t.charAt( j );
		    if( c < ' ' || c == '#' ) {
			result.append('#');
			String s = c.toString();
			if( s.Length < 3 ) {
			    result.append('0');
			}
			if( s.Length < 2 ) {
			    result.append('0');
			}
			result.append(s);
			// IO.Std.err.println( "write escape char #" + (int)c );
			seen_dodgy = true;
			continue;
		    } else if( (j == 0 && (c == '{' || c == '}' || c == '*' || c == '@')) || c == ' ' || c == '\n' || c == '\t' ) {
			seen_dodgy = true;
		    } else if( c == '"' ) {
			seen_dodgy = true;
			result.append( '"' );
		    }
		    result.append( c );
		}

		result.append( '"' );

		if( seen_dodgy ) {
		    return result;
		} else {
		    return t;
		}
	    } else {
		// nulls can occur in newly created task records for fields we can't fill in.
		return null;
	    }
	}

	private void indent() {
	    if( debug && indent_ < MAX_INDENT ) {
		for( int i = 0; i < indent_; i = i + 1 ) {
		    append( ' ' );
		    append( ' ' );
		}
	    }
	}

	private void undent() {
	    if( debug && indent_ < MAX_INDENT ) {
		for( int i = 0; i < indent_-1; i = i + 1 ) {
		    append( ' ' );
		    append( ' ' );
		}
	    }
	}

	private void newline() {
	    if( debug && indent_ < MAX_INDENT ) {
		append( ' ' );
		append( '\n' );
	    } else {
		append( ' ' );
	    }
	}


	public void reference() {
	    by_reference[indent_] = true;
	}

	public bool isByReference() {
	    return by_reference[indent_];
	}

	public void open(String s) {
	    indent();
	    bool r = by_reference[indent_];
	    indent_ = indent_ + 1;
	    by_reference[indent_] = r; // true;

	    append( '{' );
	    append( s );
	    newline();
	}

	public void open(int n) {
	    open( "" + n );
	}

	public void open() {
	    open( "*" );
	}

	public void close() {
	    undent();
	    indent_ = indent_ - 1;
	    append( '}' );
	    newline();
	}

	public void addReference( Object r ) {
	    IO.Std.err.println( "add reference: " + r );
	    if( r == null ) {
		append( "* " );
	    } else {
		IO.Std.err.println( "search references: " + r );
		int p = references[r];
		IO.Std.err.println( "result: " + p );
		if( p != 0 ) {
		    IO.Std.err.println( "add existing" );
		    append( '*' );
		    append( p );
		    append( ' ' );
		} else {
		    IO.Std.err.println( "store at: " + handle );
		    int h = handle;
		    handle = handle + 1;
		    references[r] = h;
		    append( ':' );
		    append( h );
		    append( ' ' );
		    IO.Std.err.println( "will add value: " + r );
		    addValue( r );
		}
	    }
	}

	public void add(Object o) {
	    IO.Std.err.println( "add(Object): " + o );
	    if( isByReference() ) {
		addReference(o);
	    } else {
		addValue(o);
	    }
	}

	public void add(String s) {
	    if( s == null ) {
		addNull();
	    } else {
		indent();
		append( quote(s) );
		newline();
	    }
	}

	public void addNull() {
	    indent();
	    append( '*' );
	    newline();
	}

	public void add(char c) {
	    add( "" + c );
	}

	public void add(long i) {
	    indent();
	    append( i );
	    newline();
	}

	public void add(word w) {
	    indent();
	    append( w );
	    newline();
	}

	public void add(int i) {
	    indent();
	    append( i );
	    newline();
	}

	public void add(bool b) {
	    indent();
	    if( b ) {
		append('1');
	    } else {
		append('0');
	    }
	    newline();
	}

	/*
	  public void add(java.util.Date d) {
	  if( d == null ) {
	  addNull();
	  } else {
	  add( uk.co.innate.locale.InternalConversionBundle.getBundle().formatDateSQL(d).substring(1,20) );
	  }
	  newline();
	  }
	*/

	public void addValue( int[] v ) {
	    if( v == null ) {
		addNull();
	    } else {
		open();
		for( int i = 0; v != null && i < v.length; i = i + 1 ) {
		    add( v[i] );
		}
		close();
	    }
	}

	public void addValue( bool[] v ) {
	    if( v == null ) {
		addNull();
	    } else {
		open();
		for( int i = 0; v != null && i < v.length; i = i + 1 ) {
		    add( v[i] );
		}
		close();
	    }

	}

	public void addValue( Object[] v ) {
	    if( v == null ) {
		addNull();
	    } else {
		open();
		for( int i = 0; v != null && i < v.length; i = i + 1) {
		    add( v[i] );
		}
		close();
	    }
	}

	void addValue( Object o ) {
	    IO.Std.err.println( "add value: " + o + " (" + o.Class.Name + ")" );
	    if( isa Serial(o) ) {
		IO.Std.err.println( "is serial" );
		var s = cast Serial(o);

		IO.Std.err.println( "have: " + cast Object(s) );

		IO.Std.err.println( "call to serial" );
		s.toSerial(this);
	    } /* else if( o.IsArray ) {
		addValueArray(o);
		} */
	    else  {
		IO.Std.err.println( "use default serializer" );
		addValueDefault(o);
	    }
	}

	public void optional() {
	}

	public void required() {
	}

	void writeElements( char ptr p, int type, int length ) {
	    IO.Std.err.println( "writeElements(" + cast long(p) + "," + type + "," + length + ")..." );

	    switch( type ) {
	    case TYPE_BOOL:
		IO.Std.err.println( "elements are bool..." );
		var bp = cast bool ptr(p);
		while( length > 0 ) {
		    add([bp]);
		    length = length - 1;
		    bp = bp + 1;
		}
		
	    case TYPE_CHAR:
		IO.Std.err.println( "elements are char..." );
		var cp = cast char ptr(p);
		while( length > 0 ) {
		    add([cp]);
		    length = length - 1;
		    cp = cp + 1;
		}
		
	    case TYPE_LONG:
		IO.Std.err.println( "elements are long..." );
		var lp = cast long ptr(p);
		while( length > 0 ) {
		    add([lp]);
		    length = length - 1;
		    lp = lp + 1;
		}

	    case TYPE_WORD:
		IO.Std.err.println( "elements are words..." );
		var wp = cast word ptr(p);
		while( length > 0 ) {
		    add([wp]);
		    length = length - 1;
		    wp = wp + 1;
		}
		       
	    case TYPE_INTEGER:
		IO.Std.err.println( "elements are integers..." );
		var ip = cast int ptr(p);
		while( length > 0 ) {
		    add([ip]);
		    length = length - 1;
		    ip = ip + 1;
		}
		
	    case TYPE_CLASS,
		TYPE_VECTOR:
		IO.Std.err.println( "elements are objects..." );
		var op = cast Object ptr(p);
		while( length > 0 ) {
		    IO.Std.err.println( "will add: " + [op] );

		    add([op]);
		    length = length - 1;
		    op = op + 1;
		}

	    default:
		throw new IOException( "cannot write array element of type " + type );	
	    }

	    IO.Std.err.println( "writeElements finished" );
	}
	   

	void addValueDefault( Object o ) {
	    int ptr pt = o.TypeTable;

	    String tag = SerialReader.getTagForClass(o.Class);

	    if( tag == null ) {
		throw new IO.IOException( "unregistered class " + o.Class.Name );
	    }

	    open(tag);
	    
	    bool is_array = o.IsArray;
	    int l = 0;
	    int n = 0;

	    do {
		int offset;
		int type;

		if( !SerialReader.readType( pt, type, offset ) ) {		
		    break;
		}

		IO.Std.err.println( "@" + cast long(pt) + " type: " + type );

		char ptr p = cast char ptr(o) + offset;

		if( is_array ) {
		    if( l > 0 ) {
			writeElements( p, type, l );
			break;
		    }
		}
		/*
		IO.Std.err.println( "offset: " + offset );
		IO.Std.err.println( "type: " + type );
		IO.Std.err.println( "field address: " + cast long(p) );
		*/
		switch( type ) {
		case TYPE_BOOL:
		    // IO.Std.err.println( "write bool..." );
		    add([cast bool ptr(p)]);

		case TYPE_CHAR:
		    // IO.Std.err.println( "write char..." );
		    add([cast char ptr(p)]);

		case TYPE_LONG:
		    // IO.Std.err.println( "write long..." );
		    add([cast long ptr(p)]);

		case TYPE_WORD:
		    add([cast word ptr(p)]);

		case TYPE_INTEGER:
		    // IO.Std.err.println( "write int..." );
		    l = [cast int ptr(p)];
		    add( l );

		case TYPE_POINTER:
		    if( !SerialReader.readType( pt, type, offset ) ) {
			throw new IO.IOException( "expected sub type in type table " + o.Class.Name + " writing pointer @ " + offset );
		    }
		    // IO.Std.err.println( "pointer type, sub-type is: " + type );

		    l = o._get_PointerLength(n);
		    writeElements([cast char ptr ptr(p)], type, l );
		    n = n + 1;

		case TYPE_CLASS,
		    TYPE_VECTOR:
		    // IO.Std.err.println( "write object: " + [cast Object ptr(p)] );
		    add([cast Object ptr(p)]);

		default:
		    throw new IOException( "cannot write " + o.Class.Name + " field @ " + offset + " of type " + type );
		}
	    } while(true);

	    close();
	}
    }
}