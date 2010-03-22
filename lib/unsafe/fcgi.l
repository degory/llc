#K

import stream;
import args;
import ifcgi; // imports fcgi.o, either 32 or 64 bit depending target
import "fcgi";

namespace FCGI is
    use IO.CharStream;
    use IO.Reader;
    use IO.Writer;

    class Stream isa CharStream  is
        word fcgi_stream;
	bool is_at_end;

        void init( word fcgi_stream ) is
	    this.fcgi_stream = fcgi_stream;
        si

	int read( char ptr buffer, int count ) is
	    IO.Std.err.println( "about to FCGI_fread..." );
            int bytes_read = cast int(native.FCGI_fread(buffer, 1, count, fcgi_stream));
	    if bytes_read < count then
	        is_at_end = true;
 	    fi
   	    IO.Std.err.println( "read " + bytes_read + " bytes" );
            return bytes_read;
        si

	int write( char ptr buffer, int count ) is 
	    return cast int(native.FCGI_fwrite(buffer, 1, count, fcgi_stream));    
        si

	void close() is
	    native.FCGI_fclose(fcgi_stream);
	si

	bool isAtEnd() is
	    return is_at_end;
        si

	static Reader _stdin;
	static Writer _stdout;
	static Writer _stderr;

	static get Reader in is
	    if _stdin == null then
	        _stdin = new Reader( new Stream( cast word(native.__get_FCGI_stdin()) ) );
            fi
            return _stdin;
	si

	static get Writer out is
	    if _stdout == null then
	        _stdout = new Writer( new Stream( cast word(native.__get_FCGI_stdout()) ) );
            fi
            return _stdout;
	si

	static get Writer err is
	    if _stderr == null then
	        _stderr = new Writer( new Stream( cast word(native.__get_FCGI_stderr()) ) );
            fi
            return _stderr;
	si

	void flush() is
	    native.FCGI_fflush(fcgi_stream);
	si

	static void flushAll() is
	    _stdin.Stream.flush();
	    _stdout.Stream.flush();
	    _stderr.Stream.flush();
	si

    si

    class Environment is 
	static void addTo( Generic.Map<System.String,System.String> existing ) is
	    char ptr ptr environ = cast char ptr ptr(native.__get_FCGI_environ());

	    System.String[] env = System.Arguments.makeStringArrayFromCStringList( environ );

	    Util.ProgramEnvironment.makeMap( existing, env );
        si
    si	


    class Loop is
	static bool accept() is
	    return cast int(native.FCGI_Accept()) >= 0;
	si

	static void exit() is
	    native.FCGI_Finish();
// native.FCGX_ShutdownPending();
        si
    si
si



