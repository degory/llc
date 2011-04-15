namespace Web is
    use System.StringBuffer;
    use System.String;

    class URLEncoder is
        static String encode( char c ) is
	    if (c >= '0' && c <= '9') || 
	       (c >= 'A' && c <= 'Z') ||
	       (c >= 'a' && c <= 'z') ||
	       "-_.~".indexOf(c) >= 0
	    then
	        return "" + c;
	    else
	        return new StringBuffer(3)
                    .append('%')
                    .append(cast int(c), 16, 2, '0');
	    fi
	si

	static String encode( String s ) is
	    var result = new StringBuffer();
	    for var i = 0; i < s.Length; i = i + 1 do
	        result.append( encode(s[i]) );
	    od

            return result;
	si
    si

    class HTMLEncoder is
	static String encode( char c ) is
	    case c
	    is cast char(13):
		return "";

	    is '\n':
		return "<BR>";

		/*
		  case '\'':
		  return "&apos;";
		*/

	    is ' ':
		return "&nbsp;";

	    is '"':
		return "&quot;";

	    is '&':
		return "&amp;";

	    is '<':
		return "&lt;";

	    is '>':
		return "&gt;";

	    default:
		if c > ' ' && c <= cast char(127) then
		    return "" + c;
		else
		    return "&#" + cast int(c) + ';';
		fi
	    esac
	si

	static String encodeLax( char c ) is
	    if c == ' ' then
		return "" + c;
	    else
		return encode( c );
	    fi
	si

	static String encodeTabbed( String s ) is
	    if dontEncode( s ) then
		return s;
	    fi

            int col;
	    int ti = 0;

	    StringBuffer result = new StringBuffer();
	    for int i = 0; i < s.Length; i = i + 1 do
		var c = s[i];
		if c == '\n' then
		    ti = 0;
		    col = 0;
		    result.append( encode('\n' ) );
		elif c == '\t' then
		    while ti < 8 do
			result.append( encode(' ') );
			ti = ti + 1;
			col = col + 1;
		    od
		    ti = 0;
		else
		    result.append( encode(c) );
		    ti = ti + 1;
		    col = col + 1;
		    if ti >= 8 then
			ti = 0;
		    fi
		fi

		if col > 40 then
		    result.append( "&#8203;" );
		fi
	    od

	    return result.toString();
	si

	static String encode( String s ) is
	    if dontEncode( s ) then
		return s;
	    fi

	    StringBuffer result = new StringBuffer();
	    for int i = 0; i < s.Length; i = i + 1 do
		result.append( encode(s[i]) );
	    od
	    return result.toString();
	si

	static char[] encode( char[] s ) is
	    int i;
	    StringBuffer result = new StringBuffer();
	    for i = 0; i < s.length; i = i + 1 do
		result.append( encode(s[i]) );
	    od
	    s = new char[result.Length];
	    for i = 0; i < result.Length; i = i + 1 do
		s[i] = result[i];
	    od

	    return s;
        si
	 
	static String encodeLax( String s ) is
	    if dontEncode( s ) then
		return s;
	    fi
		
	    StringBuffer result = new StringBuffer();
	    for int i = 0; i < s.Length; i = i + 1 do
		result.append( encodeLax( s[i] ) );
	    od
	    return result;
	si

	private static bool dontEncode( String s ) is
	    if s.Length == 0 || s[0] == '$' then
		return true;
	    else
		return false;
	    fi
	si
    si
si