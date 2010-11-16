#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import gmap;
import stream;

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

    pragma NoWarnUnsafe, NoMarkUnsafe, NoWarnHide, NoWarnResolve;

    /// Classes that cannot be serialized by the standard serializer (for instance if they contain pointers to regions of unknown size or pointers to the
    /// interior of regions) can implement this interface and serialize/deserialize themselves in response to calls to toSerial/fromSerial
    interface Serial {
	// when this method is called, object is expected to write a representation of itself to stream b
	void toSerial(SerialWriter b);

	// when this method is called, object is expected to initialize itself by reading its representation from stream b
	Object fromSerial(SerialReader b);
    }

    /// Tokens used by the serializer protocol
    enum SerialToken {
	EOF,
        OPEN,
	CLOSE,
	REFERENCE,
	ASSIGN,
	STRING
    } 

    /// Parses the serializer protocol. This is an internal class. Use SerialReader to deserialze objects
    class SerialParser {
	static bool debug = false;

	Reader is;
	bool is_eof;
	char current_char;
	SerialToken current_token;
	String current_string;

	/// accessor: static set bool Debug = d
	/// \param d if set then debug output enabled when parsing serializer protocol
	static set bool Debug = d {
	    debug = d;
	}

	/// accessor: static get bool Debug
	/// \return true if debug output enabled
        static get bool Debug {
	    return debug;
	}

	/// construct a new SerialParser
	/// \param is where to read serialized objects from
	void init(Reader is) {
	    this.is = is;
	    readChar();
	    readToken();
	}

	/// accessor: get bool AtEOF
	/// \return true if at end of reader
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

    /// Reads and recreates serialized objects from an IO.Reader
    class SerialReader {
	public static bool debug = false;

	/// Map from class names in stream to classes to deserialize
	static Map<String,Class> classes;

	/// Map from classes to serialize to class names in stream
	static Map<Class,String> names;

	/// Parser used to parse seralized object prototcol
	SerialParser parser;

	/// Map from reference ids in stream to previously deserialized objects
	Map<String,Object> references;

	/// Object referred to by most recently read reference id
	Object current_reference;

	/// Construct a new SerialReader from a CharStream
	/// \param s the stream that objects will be read from
	void init(CharStream s) {
	    init(new Reader(s));
	}

	/// Construct a new SerialReader from a Reader
	/// \param is the stream that objects will be read from
	public void init(Reader is) {
	    parser = new SerialParser(is);
	    references = new Map<String,Object>();
	}

	/// Internal method
	static void lazyInit() {
	    if( classes == null ) {
		classes = new Map<String,Class>();
		names = new Map<Class,String>();
	    }
	}

	/// Get the map of class names to classes
        static get Map<String,Class> Classes {
	    return classes;
	}

	/// Get the map of classes to class names
        static get Map<Class,String> Names {
	    return names;
	}

	/// Register a class with the serializer
	/// \param c the class to register. The class's fully qualified name will
	/// be used to identify its instances in serialized streams
	/// \return true. Allows use in static initializers (e.g. static bool dummy=SerialReader.register(class<ThisClass>))
	public static bool register(Class c) {
	    return register(c.Name, c);
	}

	/// Register a class with the serializer
	/// \param key the string that will be used to identify instances of this class in serialized streams
	/// \param c the class to register.
	/// \return true. Allows use in static initializers (e.g. static bool dummy=SerialReader.register(class<ThisClass>))
	public static bool register(String key, Class c) {
	    lazyInit();

	    classes[key] = c;
	    names[c] = key;
	    if( debug ) {
		IO.Std.err.println( "registered " + key + " as " + c );
	    }
	    return true;
	}

	/// Get the tag used to identifiy a class
	/// \param c the class to get the tag for
	/// \return the string used to identify this class
	static String getTagForClass(Class c) {
	    lazyInit();
	    return names[c];
	}

	/// Get the class identified by a given tag
	/// \param n the tag to get the class for
	/// \return the class identified by this tag
	static Class getClassForTag(String n) { 
	    lazyInit();
	    return classes[n];
	}

	/// Get the last string read by the parser
	public get String CurrentString {
	    return parser.CurrentString;
	}

	/// Get the last token read by the parser
	public get SerialToken CurrentToken {
	    return parser.CurrentToken;
	}
	
	/// Was the last tag read by the parser an open block token?
	/// \return true if the last tag was an OPEN token, false otherwise
	public bool isOpen() {
	    return parser.CurrentToken != SerialToken.CLOSE;
	}

	/// Check if the current object either references a previous id or
	/// defines a new reference id and set the current reference object
	/// accordingly
	/// \return true if the current object is a reference
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

	/// Read an assignment to an object id
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

	/// Read an object. This could be a reference to a previous object by id,
	/// a new object with or without an id assignment or a null reference
	public Object read() {
	    if( checkReference() ) {
		return current_reference;
	    } else if( parser.CurrentToken == SerialToken.OPEN ) {
		/*
		if( !parser.CurrentString.equals("*") ) {
		*/
		lazyInit();
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

	// Check next token is an OPEN token for any tag and discard it
	public void open() {
	    // IO.Std.err.println( "read open untagged" );
	    if( parser.CurrentToken == SerialToken.OPEN ) {
		parser.readToken();
	    } else {
		throw new IOException( "expected '{' reading untagged record" );
	    }
	}

	/// Check next token is an OPEN token for a particular tag and discard it
	/// \param tag expected tag
	public void open( String tag ) {
	    // IO.Std.err.println( "read open:" + tag );
	    if( parser.CurrentToken == SerialToken.OPEN && parser.CurrentString.equals(tag) ) {
		parser.readToken();
	    } else {
		throw new IOException("expected tag: '{'" + tag + "'");
	    }
	}

	/// Check current object is not a reference and issue a warning if it is
	public void checkNull() {
	    if( current_reference != null ) {
		IO.Std.err.println( "cannot reference this - returning null" );
	    }
	}

	/// Read a long integer value
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

	/// Read a word integer value
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

	/// Read an integer value
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

	/// Read a string value
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

	/// Read a boolean value
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

	/// Read a character value
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

	/// Read and discard tokens until a CLOSE token is read 
	public void close() {
	    while( parser.CurrentToken != SerialToken.CLOSE ) {
		read();
	    }
	    parser.readToken();
	}
	
	/// Have all available objects been read
	/// \return true if no more objects available
	public get bool AtEOF {
	    return parser.AtEOF;
	}

	/// Read an array
	/// \param t template object used to determine vtable for new array
	/// \param offset offset in bytes of first element relative to this
	/// \param length number of element in array
	/// \param type type of array elements
	/// \return an object that can be cast to the appropriate array type
	Object readArray( Object t, int offset, int length, int type ) {
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

/*
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
*/

	/// Read a list of values, previously serialized from a pointer, into a buffer
	/// \param type type of each value
	/// \param length number of values
	/// \return a pointer to the read values that can be cast to the appropriate type
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

	/// Read a field type and offset from a class's type table
	/// \param tp pointer to current type in type table, will be updated to next type
	/// \param type receives field type
	/// \param offset receives field offset
	/// \return true if a type and offset read or false if no more fields remain in class 
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

	/// Populate fields in an object from serialized object stream using the default deserializer
	/// \param o the object to populate. Must have been pre-allocated of correct size and with
	/// correct vtable pointer
	/// \return deserialized object (which may not be the passed in object in case of arrays)
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
		    result = readArray( o, offset, l, type );
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

    /// Serializes objects to a stream
    public class SerialWriter {
    	/// Block indent for pretty printing in debug mode
	const int MAX_INDENT = 4;
 
	/// If true then output will be indented to make it more readable and echoed to the console
	public static bool debug = false;

	/// Stream to write serialized objects to
	Writer os;

	/// Current indent level for pretty printing
	public int indent_;

	/// Whether to send reference ids for objects
	bool[] by_reference;

	/// Map from objects to reference ids
	Map<Object,int> references;
	int handle;

	/// Create a new SerialWriter
	/// \param s stream to write serialized objects to
	void init(CharStream s) {
	    init(new Writer(s));
	}

	/// Create a new SerialWriter
	/// \param os stream to write serialized objects to
	void init(Writer os) {
	    this.os = os;
	    indent_ = 0;
	    handle = 1;

	    by_reference = new bool[64];
	    references = new Map<Object,int>();
	}

	/// Flush the underlying stream
	void flush() {
	    os.flush();
	}

	void dispose() {
	    os.close();
	}

	/// Append a char to the output stream directly with no quoting
	/// \param c char to write
	void append( char c ) {
	    if( debug ) {
		IO.Std.err.print( "" + c );
	    }
	    os.print(c);
	}

	/// Append an integer to the output stream directly with no quoting
	/// \param i the integer to write
	void append( int i ) {
	    if( debug ) {
		IO.Std.err.print( "" + i );
	    }
	    os.print(i);
	}

	/// Append a word to the output stream directly with no quoting
	/// \param i the word to write
	void append( word i ) {
	    if( debug ) {
		IO.Std.err.print( "" + i );
	    }
	    os.print(i);
	}

	/// Append a long to the output stream directly with no quoting
	/// \param i the long to write
	void append( long i ) {
	    if( debug ) {
		IO.Std.err.print( "" + i );
	    }
	    os.print(i);
	}

	/// Append a string to the output stream directly with no quoting
	/// \param s the 
	void append( String s ) {
	    if( debug ) {
		IO.Std.err.print( s );
	    }
	    os.print(s);
	}
	
	/// quote a string for writing to the output stream
	/// \param t the string to quote
	/// \return the string quoted so it's 7-bit clean with all characters significant to serializer, below 32 or over 127 escaped or quoted
	static String quote( String t ) {
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

	/// If debug mode and indentation level doesn't exceed maximum then write spaces to indent the current line
	/// according to current block nesting level
	private void indent() {
	    if( debug && indent_ < MAX_INDENT ) {
		for( int i = 0; i < indent_; i = i + 1 ) {
		    append( ' ' );
		    append( ' ' );
		}
	    }
	}

	/// If debug mode and indentation level doesn't exceed maximum then write spaces to indent the current line
	/// according to enclosing block nesting level
	private void undent() {
	    if( debug && indent_ < MAX_INDENT ) {
		for( int i = 0; i < indent_-1; i = i + 1 ) {
		    append( ' ' );
		    append( ' ' );
		}
	    }
	}

	/// If debug mode and indentation level doesn't exceed maximum then write a newline
	private void newline() {
	    if( debug && indent_ < MAX_INDENT ) {
		append( ' ' );
		append( '\n' );
	    } else {
		append( ' ' );
	    }
	}

	/// Pass subsequent objects found within this object by reference
	void reference() {
	    by_reference[indent_] = true;
	}

	/// Should objects in this object be passed by reference
	/// \return true if pass by reference enabled
	bool isByReference() {
	    return by_reference[indent_];
	}

	/// Open a block for an object
	/// \param s tag for this object
	void open(String s) {
	    indent();
	    bool r = by_reference[indent_];
	    indent_ = indent_ + 1;
	    by_reference[indent_] = r; // true;

	    append( '{' );
	    append( s );
	    newline();
	}

	/// Open a block for an object
	/// \param n tag for this object
	void open(int n) {
	    open( "" + n );
	}

	/// Open a block for an object with no tag (deserializer will need to know
	/// exactly what type of object to expect)
	void open() {
	    open( "*" );
	}

	/// Close current object
	void close() {
	    undent();
	    indent_ = indent_ - 1;
	    append( '}' );
	    newline();
	}

	/// Write object to serialization stream by reference. If the object has previously been
	/// written and we have a stored reference id for it, just write that id. If not then
	/// generate a new reference id and write an assignment to that id plus the object's 
	/// value
	/// \param r the object to write by reference
	void addReference( Object r ) {
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

	/// Write an object to the serialization stream. If reference is set then it will be written by
	/// reference, otherwise by value.
	/// \param o the object to write
	public void add(Object o) {
	    IO.Std.err.println( "add(Object): " + o );
	    if( isByReference() ) {
		addReference(o);
	    } else {
		addValue(o);
	    }
	}

	/// Write a string to the serialization stream.
	/// \param s the string to write
	public void add(String s) {
	    if( s == null ) {
		addNull();
	    } else {
		indent();
		append( quote(s) );
		newline();
	    }
	}

	/// Write a null to the serialization stream
	public void addNull() {
	    indent();
	    append( '*' );
	    newline();
	}

	/// Write a char to the serialization stream
	/// \param c the char to write 
	public void add(char c) {
	    add( "" + c );
	}

	/// Write a long to the serialization stream
	/// \param i the long to write
	public void add(long i) {
	    indent();
	    append( i );
	    newline();
	}

	/// Write a word to the serialization stream
	/// \param w the word to write
	public void add(word w) {
	    indent();
	    append( w );
	    newline();
	}

	/// Write an int to the serialization stream
	/// \param i the int to write
	public void add(int i) {
	    indent();
	    append( i );
	    newline();
	}

	/// Write a word to the serialization stream
	/// \param b the bool to write
	public void add(bool b) {
	    indent();
	    if( b ) {
		append('1');
	    } else {
		append('0');
	    }
	    newline();
	}

	/// Write an array of integers to the serialization stream
	/// \param v the array to write
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

	/// Write an array of booleans to the serialization stream
	/// \param v the array to write
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

	/// Write an array of Objects to the serialization stream
	/// \param v the array to write
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

	/// Write an Object to the serialization stream by value
	/// \param o the Object to write
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

	/// Write a list of values to the serialization stream
	/// \param p pointer to the list of values to write
	/// \param type type of each element
	/// \param length number of elements to write
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
	   
	/// Write an Object to the serialization stream using the default serializer
	/// \param o the object to write
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