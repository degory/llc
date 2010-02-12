#K

import stream;
import args;
import ifcgi; // imports fcgi.o, either 32 or 64 bit depending target
import "fcgi";

namespace FCGI is
    use IO.CharStream;
    use IO.Reader;
    use IO.Writer;

    class Stream extends CharStream is
        word fcgi_stream;
	bool is_at_end;

        void init( word fcgi_stream ) is
	    this.fcgi_stream = fcgi_stream;
        end

	int read( char ptr buffer, int count ) is
	    IO.Std.err.println( "about to FCGI_fread..." );
            int bytes_read = cast int(native.FCGI_fread(buffer, 1, count, fcgi_stream));
	    if bytes_read < count then
	        is_at_end = true;
 	    fi
   	    IO.Std.err.println( "read " + bytes_read + " bytes" );
            return bytes_read;
        end

	int write( char ptr buffer, int count ) is 
	    return cast int(native.FCGI_fwrite(buffer, 1, count, fcgi_stream));    
        end

	void close() is
	    native.FCGI_fclose(fcgi_stream);
	end

	bool isAtEnd() is
	    return is_at_end;
        end

	static Reader _stdin;
	static Writer _stdout;
	static Writer _stderr;

	static get Reader in is
	    if _stdin == null then
	        _stdin = new Reader( new Stream( cast word(native.__get_FCGI_stdin()) ) );
            fi
            return _stdin;
	end

	static get Writer out is
	    if _stdout == null then
	        _stdout = new Writer( new Stream( cast word(native.__get_FCGI_stdout()) ) );
            fi
            return _stdout;
	end

	static get Writer err is
	    if _stderr == null then
	        _stderr = new Writer( new Stream( cast word(native.__get_FCGI_stderr()) ) );
            fi
            return _stderr;
	end

	void flush() is
	    native.FCGI_fflush(fcgi_stream);
	end

	static void flushAll() is
	    _stdin.Stream.flush();
	    _stdout.Stream.flush();
	    _stderr.Stream.flush();
	end

    end

    class Environment is 
	static void addTo( Generic.Map<System.String,System.String> existing ) is
	    char ptr ptr environ = cast char ptr ptr(native.__get_FCGI_environ());

	    System.String[] env = System.Arguments.makeStringArrayFromCStringList( environ );

	    Util.ProgramEnvironment.makeMap( existing, env );
        end
    end	


    class Loop is
	static bool accept() is
	    return cast int(native.FCGI_Accept()) >= 0;
	end

	static void exit() is
	    native.FCGI_Finish();
// native.FCGX_ShutdownPending();
        end
    end
end



