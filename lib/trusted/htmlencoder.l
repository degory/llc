#C

namespace Web {
    use System.StringBuffer;
    use System.String;

    class HTMLEncoder {
	static String encode( char c ) {	         
	    switch( c ) {
	    case cast char(13):
		return "";

	    case '\n':
		return "<BR>";

		/*
		  case '\'':
		  return "&apos;";
		*/

	    case ' ':
		return "&nbsp;";

	    case '"':
		return "&quot;";

	    case '&':
		return "&amp;";

	    case '<':
		return "&lt;";

	    case '>':
		return "&gt;";

	    default:
		if( c > ' ' && c <= cast char(127) ) {
		    return "" + c;
		} else {
		    return "&#" + cast int(c) + ';';
		}
	    }
	}

	static String encodeLax( char c ) {
	    if( c == ' ' ) {
		return "" + c;
	    } else {
		return encode( c );
	    }
	}

	static String encodeTabbed( String s ) {
	    if( dontEncode( s ) ) {
		return s;
	    }

	    int col = 0;

	    StringBuffer result = new StringBuffer();
	    for( int i = 0; i < s.Length; i = i + 1 ) {
		var c = s[i];
		if( c == '\n' ) {
		    col = 0;
		    result.append( encode('\n' ) );
		} else if( c == '\t' ) {
		    while( col < 8 ) {
			result.append( encode(' ') );
			col = col + 1;
		    }
		    col = 0;

		} else {
		    result.append( encode(c) );
		    col = col + 1;
		    if( col >= 8 ) {
			col = 0;
		    }
		}
	    }
	    return result.toString();
	}

	static String encode( String s ) {
	    if( dontEncode( s ) ) {
		return s;
	    }

	    StringBuffer result = new StringBuffer();
	    for( int i = 0; i < s.Length; i = i + 1 ) {
		result.append( encode(s.charAt(i)) );
	    }
	    return result.toString();
	}



	static char[] encode( char[] s ) {
	    int i;
	    StringBuffer result = new StringBuffer();
	    for( i = 0; i < s.length; i = i + 1 ) {
		result.append( encode(s[i]) );
	    }
	    s = new char[result.Length];
	    for( i = 0; i < result.Length; i = i + 1 ) {
		s[i] = result[i];
	    }

	    return s;
	}
	 
	static String encodeLax( String s ) {
	    if( dontEncode( s ) ) {
		return s;
	    }
		
	    StringBuffer result = new StringBuffer();
	    for( int i = 0; i < s.Length; i = i + 1 ) {
		result.append( encodeLax( s.charAt( i ) ) );
	    }
	    return result;
	}

	private static bool dontEncode( String s ) {
	    if( s.Length == 0 || s[0] == '$' ) {
		return true;
	    } else {
		return false;
	    }
	}
    }
}