#K
import string;

pragma NoWarnUnsafe, NoMarkUnsafe, NoWarnHide, NoWarnResolve;

namespace System is
    class Backtrace extends Object is
	String _backtrace;
	void init() is
	    super.init();
	    try
		throw new Exception("backtrace");
	    catch System.Exception e
		_backtrace = e.Backtrace;
	    yrt
	end

	String toString() is
	    return _backtrace;
	end
    end    

    class Exception extends Object is
	word _backtrace_info;
	String _backtrace;
	String _message;

	void init( int eip, int ebp ) is
	    super.init();
	end
    
	void init( String m ) is
	    super.init();
	    _message = m;
	end

	void init( char ptr m ) is
	    super.init();
	    _message = new String(m);
	end

	String toString() is
	    getBacktrace();

	    if _message != null then
		if _backtrace != null then
		    return getClassName() + ": " + _message + "\n" + _backtrace;
		else
		    return getClassName() + ": " + _message + "\n";
		fi
	    else
		if _backtrace != null then
		    return getClassName() + "\n" + _backtrace;
		else
		    return getClassName();
		fi
	    fi
	end

	word getBacktraceInfo() is
	    return _backtrace_info;
	end

	void setBacktraceInfo( word info ) is
	    this._backtrace_info = info;
	end

	get String Backtrace is
	    // run time does not produce a human readable backtrace at exception throw time as
	    // it's an expensive operation and the results might not be needed
	    // instead it buffers the information required to determine line numbers
	    // at a later point and stores a token (in fact buffer address) in 
	    // _backtrace_info. If token is set then call runtime to have it render
	    // the human readable backtrace:

	    if _backtrace_info != 0w then
		_backtrace = new System.StringBuffer();
		native.__find_line_numbers( _backtrace, _backtrace_info );

		// clear pointer to allow buffer to be reclaimed:
		_backtrace_info = 0w;
	    fi

	    if _backtrace != null then
		return _backtrace;
	    else
		return "no backtrace available";
	    fi
	end

	get String Message is
	    return _message;
	end
    end   

    class RuntimeException extends Exception is
	void init() is
	    super.init();
	end

	void init( String s ) is
	    super.init( s );
	end

	void init( char ptr m ) is
	    super.init( m );
	end
    end

    class MemoryException extends RuntimeException is
	word address;

	void init( String m ) is
	    super.init( m );
	end

	void init( char ptr m ) is
	    super.init( m );
	end

	set word Address = a is
	    address = a;
	end

	get word Address is
	    return address;
	end
    end

    class NullPointerException extends MemoryException is
	void init( String m ) is
	    // native.printf( `new null pointer exception %p\n`, this );
	    super.init( m );
	end

	void init( char ptr m ) is
	    // native.printf( `new null pointer exception %p\n`, this );
	    super.init( m );
	end

	void enableGC() is
	    native.GC_enable();
	end
    end

    class MemoryProtectionException extends MemoryException is
	void init( System.String m ) is
	    super.init( m );
	end

	void init( char ptr s ) is
	    super.init( s );
	end
    end

    class ArrayBoundsException extends RuntimeException is
	void init( System.String m ) is
	    super.init( m );
	end

	void init( char ptr s ) is
	    super.init( s );
	end
    end

    class CastException extends RuntimeException is
	void init( System.String m ) is
	    super.init( m );
	end

	void init( char ptr s ) is
	    super.init( s );
	end
    end

    class CannotCloneException extends Exception is
	void init( String message ) is
	    super.init( message );
	end

	void init( char ptr message ) is
	    super.init( message );
	end
    end

    class NotImplementedException extends Exception is
	void init( String message ) is
	    super.init( message );
	end

	void init() is
	    super.init( "Not implemented exception" );
	end
    end

    class AssertException extends Exception is
	void init( String message ) is
	    super.init( message );
	end

	void init() is
	    super.init( "Assertion failed exception" );
	end
    end
end
