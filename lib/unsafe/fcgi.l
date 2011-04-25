#K

import stream;
import args;
import ifcgi; // imports fcgi.o, either 32 or 64 bit depending target
import envmap;
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
	    // IO.Std.err.println( "about to FCGI_fread..." );
            int bytes_read = cast int(native.FCGI_fread(buffer, 1, count, fcgi_stream));
	    if bytes_read < count then
	        is_at_end = true;
 	    fi
   	    // IO.Std.err.println( "read " + bytes_read + " bytes" );
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
            addTo( existing, environ );
        si

	static void addTo( Generic.Map<System.String,System.String> existing, char ptr ptr environ ) is
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



namespace FCGX is
    use IO.CharStream;
    use IO.Reader;
    use IO.Writer;
    use System.String;
    use Generic.Map;

    struct FCGX_Stream is si
    struct FCGX_Request is si

    class Request is
        native int FCGX_Init();
        native int FCGX_InitRequest(FCGX_Request r, int socket, int flags);
        native int FCGX_Accept_r(FCGX_Request r);
        native int FCGX_Finish_r(FCGX_Request r);

        native word GC_malloc(word size);
        native word __FCGX_get_sizeof_request();
        native FCGX_Stream __FCGX_get_in(FCGX_Request r);
        native FCGX_Stream __FCGX_get_out(FCGX_Request r);
        native FCGX_Stream __FCGX_get_err(FCGX_Request r);
        native char ptr ptr __FCGX_get_envp(FCGX_Request r);

        static bool _initialized;

        FCGX_Request _request;
        bool _finished;

        public Reader in;
        public Writer out;
        public Writer err;
        public Map<String,String> env;

        void init() is
            if !_initialized then
                checkResult(FCGX_Init());
                _initialized = true;
            fi
            _request = cast FCGX_Request(GC_malloc(__FCGX_get_sizeof_request()));
            checkResult(FCGX_InitRequest(_request, 0, 0));
        si

        bool accept() is
            checkResult(FCGX_Accept_r(_request));
            env = Util.ProgramEnvironment.Map;
            FCGI.Environment.addTo(env, __FCGX_get_envp(_request));
            in = new Reader(new Stream(__FCGX_get_in(_request)));
            out = new Writer(new Stream(__FCGX_get_out(_request)));
            err = new Writer(new Stream(__FCGX_get_err(_request)));

            return true;
        si

        void closeAll() is
            if in != null then
                in.dispose();
                in = null;
            fi
            if out != null then
                out.dispose();
                out = null;
            fi
            if err != null then
                err.dispose();
                err = null;
            fi

            env = null;
        si

        void finish() is
            closeAll();

            if !_finished then
                checkResult(FCGX_Finish_r(_request));
                _finished = true;
            fi
        si

        void checkResult(int e) is
            if e != 0 then
                throw new IO.IOException( "FCGX error " + e );
            fi
        si

        void dispose() is
            closeAll();
            _request = null;
        si
    si

    class Stream isa CharStream  is
        FCGX_Stream _stream;
        bool is_at_end;

        native int FCGX_GetStr(char ptr buffer, int n, FCGX_Stream s);
        native int FCGX_PutStr(char ptr buffer, int n, FCGX_Stream s);
        native int FCGX_FFlush(FCGX_Stream s);
        native int FCGX_FClose(FCGX_Stream s);

        void init( FCGX_Stream s ) is
	    _stream = s;
        si

	int read( char ptr buffer, int count ) is
            var bytes_read = FCGX_GetStr( buffer, count, _stream );

	    if bytes_read < count then
	        is_at_end = true;
 	    fi
            if bytes_read < 0 then
                throw new IO.IOException( "FCGX read error " + bytes_read );
            fi

   	    // IO.Std.err.println( "read " + bytes_read + " bytes" );
            return bytes_read;
        si

	int write( char ptr buffer, int count ) is 
            var bytes_written = FCGX_PutStr( buffer, count, _stream );

            if bytes_written < 0 then
                throw new IO.IOException( "FCGX write error " + bytes_written );
            elif bytes_written < count then
                throw new IO.IOException( "FCGX short write" );
            fi

            return bytes_written;
        si

	void close() is
            dispose();
	si

	bool isAtEnd() is
	    return is_at_end;
        si

	void flush() is
            FCGX_FFlush(_stream);
	si

        void dispose() is
            if _stream != null then
                FCGX_FClose(_stream);
                _stream = null;
            fi
        si
    si
si



