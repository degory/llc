#C

import stream;
import gmap;

namespace Util {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use Generic.Map;

    class Properties {
	Generic.Map<String,String> values;

	void init( Generic.Map<String,String> v ) {
	    values = v;
	}

	void init( String file_name ) {
	    values = new Generic.Map<String,String>();
	    read(file_name);
	}

	void init() {
	    values = new Generic.Map<String,String>();
	}

	void clear() {
	    values.clear();
	}

	void read(String file_name) {
	    IO.Reader b = IO.File.openRead(file_name);
	    read(new PropertyTokenizer(b));
	}

	void read(IO.Reader b) {
	    read(new PropertyTokenizer( b ));
	}

	void read(PropertyTokenizer tokenizer) {
	    values.clear();

	    PropertyParser p = new PropertyParser( values, tokenizer );
	    p.read();
	}

	String opGet(String name) {
	    return values[name];
	}

	void opSet(String name, String value) {
	    values[name] = value;
	}

	void opSet(String name, int value) {
	    values[name] = "" + value;
	}

	String getString(String name) {
	    return values[name];
	}

	String getString(String name, String default_) { 
	    String value = values[name];
	    if( value != null ) {
		return value;
	    } else {
		return default_;
	    }
	}

	/*
	String[] getStrings() {
	    var result = new Generic.Vector<String>();
	    foreach( var v; values.pairs() ) {
		result.add( v.key + '=' + v.value );
	    }

	    return result.Array;
	}
	*/  
	int getInt(String name) {
	    return getInt(name,0);
	}

	int getInt(String name, int default_ ) {
	    String value = values[name];
	    if( value != null ) {
		return value.parseInt();
	    } else {
		return default_;
	    }
	}

	Generic.MapIterator<String,String> pairs() {
	    return values.pairs();
	}

	Generic.Iterator<String> keys() {
	    return values.keys();
	}

	Generic.Iterator<String> elements() {
	    return values.elements();
	}

	String toString() {
	    var seen_any = false;
	    var result = new StringBuffer();
	    foreach( var p; pairs() ) {
		result.append(p.key);
		result.append("=>");
		result.append(p.value);
		if( seen_any ) {
		    result.append(',');
		} else {
		    seen_any = true;
		}
	    }

	    return result;
	}
    }

    private class PropertyParser {
	PropertyTokenizer tokenizer;
	Map<String,String> values;
	char current_char;

	void init( Generic.Map<String,String> values, PropertyTokenizer tokenizer ) {
	    this.values = values;
	    this.tokenizer = tokenizer;
	}

	void read() {
	    tokenizer.nextToken();
	    while( readProperty() ) 
		;
	}

	bool readProperty() {
	    PropertyToken n;
	    String name;
	    String value;

	    n = tokenizer.Token;
	    if( n == PropertyToken.EOF ) {
		return false;
	    } else if( n != PropertyToken.IDENTIFIER && n != PropertyToken.STRING ) {
		throw new System.Exception( "unexpected token reading properties (" + cast int(n) + ")" );
	    }

	    name = tokenizer.Buffer;
	    n = tokenizer.nextToken();
	    if( n != PropertyToken.ASSIGN ) {
		value = "";
	    } else {
		n = tokenizer.nextToken();

		if( n == PropertyToken.EOF ) {
		    value = "";
		} else if( n == PropertyToken.STRING || n == PropertyToken.NUMBER ) {
		    value = tokenizer.Buffer;
		} else {
		    throw new System.Exception( "expected string or number reading properties (" + cast int(n) + ")" );
	        }

		tokenizer.nextToken();
	    }

	    values[name] = value;

	    return true;
	}
    }

    enum PropertyToken {
	IDENTIFIER,
	NUMBER,
	STRING,
        ASSIGN,
        UNKNOWN,
	EOF
    }


    class PropertyTokenizer extends Object {
	protected PropertyToken token;
	protected String token_string;
	protected IO.Reader input;
	protected bool want_string;
	protected bool end_of_file;
	protected char prev_char;
	    
	protected int line_number;

	    
	void init( IO.Reader i ) {
	    super.init();
		
	    end_of_file = false;
	    input = i;
	}
	    
	bool isEndOfFile() {
	    return end_of_file;
	}
	    
	char nextChar() {
	    char c;
	    if( prev_char != cast<char>(0) ) {
		c = prev_char;
		prev_char = cast<char>(0);
		// IO.Std.out.println( "next char: returning buffered: '" + c + "'" );
		return c;     
	    }
		
	    int c0 = input.read();
		
	    if( c0 == -1 ) {
		// IO.Std.out.println( "next char: returning eof" );
		end_of_file = true;
		return ' ';
	    }
	    c = cast<char>(c0);
	    // IO.Std.out.println( "next char: returning '" + c + "'" );
	    return c;
	}
	    
	void prevChar( char c ) {
	    prev_char = c;
	}
	    
	String getBuffer() {
	    return token_string;
	}
	    
	int getLineNumber() {
	    return line_number;
	}
	    
	char readEscape() {
	    char c = nextChar();
		
	    // IO.Std.out.println( "readEscape: '" + c + "'..." );
	    int result = 0;
	    if( c == 't' ) {
		// IO.Std.out.println( "escape tab" );
		return cast<char>(9);
	    } else if( c == 'n' ) {
		// IO.Std.out.println( "escape newline" );
		return '\n';
	    } else if( c == '\\' ) {
		// IO.Std.out.println( "escape backslash" );
		return '\\';
	    } else if( c >= '0' && c <= '7' ) {
		// IO.Std.out.println( "escape octal" );
		while( c >= '0' && c <= '7' ) {
		    result = 8 * result + cast<int>(c);
		    c = nextChar();
		}
		prevChar(c);
		return cast<char>(result);
	    } else {
		// IO.Std.out.println( "escape literal: '" + c + "'" );
		return c;
	    }
	}
	    
	PropertyToken getToken() {
	    return token;
	}
	    
	PropertyToken nextToken() {
	    token = readToken();
		
	    return token;
	}
	    
	PropertyToken readToken() {
	    char c;
	    bool want_string_now = want_string;
	    want_string = false;

	    do {
		c = nextChar();
		if( c == '#' ) {
		    do {
			c = nextChar();
		    } while( c != '\n' && !end_of_file );
		}
		// IO.Std.out.println( "white space: '" + c + "'?" );
		if( c == '\n' ) {
		    line_number = line_number + 1;
		}
	    } while( !end_of_file && (c == ' ' || c == cast<char>(9) || (!want_string_now && c == '\n')) );
		
	    if( end_of_file ) {
		return PropertyToken.EOF;
	    }
		
		
	    StringBuffer buffer;
		
		
	    if( c >= '0' && c <= '9' ) {
		// IO.Std.out.println( "number: '" + c + "'" );
		buffer = new StringBuffer();
		while( c >= '0' && c <= '9' ) {
		    buffer.append(c);
		    c = nextChar();
		}
		token_string = buffer;
		prevChar(c);
		return PropertyToken.NUMBER;
	    } else if( c != '"' && want_string_now ) {
		buffer = new StringBuffer();
		bool in_comment = false;
		while( !end_of_file && c != '\n' ) {
		    if( c == '#' ) {
			in_comment = true;
		    }
			
		    if( !in_comment ) {
			buffer.append( c );
		    }
		    c = nextChar();		    
		}
		    
		line_number = line_number + 1;
		    
		token_string = buffer.trim();
		return PropertyToken.STRING;
		    
	    } else if( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' ) {
		// IO.Std.out.println( "letter: '" + c + "'" );
		buffer = new StringBuffer();
		while( (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' ) {
		    buffer.append(c);
		    c = nextChar();
		}
		token_string = buffer;
		prevChar(c);
		return PropertyToken.IDENTIFIER;
	    }
		
	    token_string = new StringBuffer("");
		
	    switch( c ) {
	    case cast<char>(34): // double quote
		buffer = new StringBuffer();
		c = nextChar(); 
		while( c != cast<char>(34) ) {
		    if( c == cast<char>(92) ) { // backslash
			c = readEscape();
			buffer.append(c);
			c = nextChar();
		    } else {
			buffer.append(c);
			c = nextChar();
		    }
		}
		token_string = buffer;
		return PropertyToken.STRING;
		    
		/*
		  case cast<char>(39): // single quote
		  buffer = new StringBuffer();
		  c = nextChar();
		  while( c != cast<char>(39) ) {
		  if( c == cast<char>(92) ) { // backslash
		  c = readEscape();
		  buffer.append(c);
		  c = nextChar();
		  } else {
		  buffer.append(c);
		  c = nextChar();
		  }
		  }
		  token_string = buffer;
		  return Token.CHARACTER;
		*/
  
	    case '=':
		want_string = true;
		return PropertyToken.ASSIGN;

	    case '#':
		do {
		    c = nextChar();
		} while( !end_of_file && c != '\n' );
		return readToken();
	    }

	    return PropertyToken.UNKNOWN;
	}
    }
}
