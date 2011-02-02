#C 

namespace System {

    class Info extends System.Object {
        static Util.Properties getMemInfo() {
	    IO.Reader meminfo_file = IO.File.openRead( "/proc/meminfo" );
	    Util.Properties meminfo = new Util.Properties();
	    meminfo.read( new ProcInfoTokenizer( meminfo_file ) );

	    return meminfo;
	}

	static System.String getLoadAvg() {
	    IO.Reader loadavg = IO.File.openRead( "/proc/loadavg" );
	    return loadavg.readAll();
	}

	static System.String getKernelVersion() {
	    IO.Reader version = IO.File.openRead( "/proc/version" );
	    return version.readAll();
	}
    }

    private class ProcInfoTokenizer extends Util.PropertyTokenizer {
	void init( IO.Reader i ) {
	    super.init(i);
	}
	    
	Util.PropertyToken readToken() {
	    char c;
	    bool want_string_now = want_string;
	    want_string = false;

	    // IO.Std.err.println( "read proc info token..." );

	    do {
		c = nextChar();

		// IO.Std.err.println( "white space?" );
	    } while( !end_of_file && (c == ' ' || c == cast<char>(9)) ); // || (!want_string_now && c == '\n')) );
		
	    if( end_of_file ) {
		// IO.Std.err.println( "end of file" );
		return Util.PropertyToken.EOF;
	    }	
		
	    System.StringBuffer buffer = new System.StringBuffer();

	    if( c == ':' ) {
		want_string_now = true;
		// IO.Std.err.println( "assign token (:)" );
		return Util.PropertyToken.ASSIGN;
	    }
		
	    do {
		if( c == ':' ) {
		    // IO.Std.err.println( "assign terminates string" );
		    prevChar(c);
		}
		if( end_of_file || c == '\n' || c == ':' ) {
		    // IO.Std.err.println( "eof or assign terminates string, returning: '" + buffer + "'" );
		    if( buffer.Length > 0 && buffer[buffer.Length-1] == cast char(13) ) {
			buffer.Length = buffer.Length - 1;
		    }
		    if( buffer.Length > 0 && buffer[buffer.Length-1] == cast char(10) ) {
			buffer.Length = buffer.Length - 1;
		    }
		    token_string = buffer;
		    return Util.PropertyToken.STRING;
		} else {
		    buffer.append( c );
		}
		c = nextChar();
	    } while( true );
	}

    }
    
}