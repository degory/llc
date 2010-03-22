#K
import string;

pragma NoWarnUnsafe, NoMarkUnsafe, NoWarnHide, NoWarnResolve;

namespace System is
    /// Generates an exception backtrace for debugging
    class Backtrace is
	String _backtrace;
	/// Construct a new Backtrace from the current stack frame
	void init() is
	    super.init();
	    try
		throw new Exception("backtrace");
	    catch System.Exception e
		_backtrace = e.Backtrace;
	    yrt
	si

	String toString() is
	    return _backtrace;
	si
    si    

    /// Root of Exception heirarchy. Runtime expects all thrown objects to inherit from Exception
    class Exception is
	const int MAX_BACKTRACE_DEPTH = 16;
        word ptr ptr _backtrace_info;  

	String _backtrace;
	String _message;

	int _backtrace_depth;

	/// Construct a new exception for the supplied frame
	/// \deprecated
	void init( int eip, int ebp ) is
	    super.init();
	si
    
	/// Construct a new exception with the supplied message
	/// \param m message text to include in this Exception
	void init( String m ) is
	    super.init();
            initBacktrace();
	    _message = m;
	si

	/// Construct a new exception with the supplied C-string message
	/// \param m C-string message text to include in this Exception
	void init( char ptr m ) is
	    super.init();
            initBacktrace();
	    _message = new String(m);
	si

        void initBacktrace() is
	    if System.Environment.WORD_BYTES == 8 then
	        _backtrace_info = cast word ptr ptr(native.malloc(MAX_BACKTRACE_DEPTH * System.Environment.WORD_BYTES));
 	        _backtrace_depth = cast int(native.backtrace(_backtrace_info, MAX_BACKTRACE_DEPTH));
            fi
	si 

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
	si

	/// Internal interface for runtime to get backtrace token
	word getBacktraceInfo() is
	    return cast word(_backtrace_info);
	si

	/// Internal interface for runtime to set backtrace token
	void setBacktraceInfo( word info ) is

	si

	/// Get the bracktrace string for this Exception
	get String Backtrace is
	    if _backtrace_info != null then
		var b = new System.StringBuffer();
	        char ptr ptr symbols = cast char ptr ptr(native.backtrace_symbols(_backtrace_info,_backtrace_depth));

		for var i = 0; i < _backtrace_depth; i = i + 1 do
		    b.append( [symbols + i] );
                    b.append( '\n' );
		od

  	        native.free( _backtrace_info );
		native.free( symbols );
                _backtrace = b;
		_backtrace_info = null;
	    fi

	    if _backtrace != null then
		return _backtrace;
	    else
		return "no backtrace available";
	    fi
	si

	/// Get the message string for this Exception
	get String Message is
	    return _message;
	si
    si   

    /// Root class for exceptions thrown by the runtime
    class RuntimeException isa Exception is
	void init() is
	    super.init();
	si

	void init( String s ) is
	    super.init( s );
	si

	void init( char ptr m ) is
	    super.init( m );
	si
    si

    /// Exception thrown when the runtime detects a memory protection fault
    class MemoryException isa RuntimeException is
	word address;

	void init( String m ) is
	    super.init( m );
	si

	void init( char ptr m ) is
	    super.init( m );
	si

	/// Set the faulting address
	/// \param a the memory address that caused the fault
	set word Address = a is
	    address = a;
	si

	/// Get the faulting address
	get word Address is
	    return address;
	si

        static void throwME() is
	    throw new MemoryException("invalid pointer dereference");
        si
    si

    /// Exception thrown when runtime detects a null pointer dereference
    class NullPointerException isa MemoryException is
	void init( String m ) is
	    // native.printf( `new null pointer exception %p\n`, this );
	    super.init( m );
	si

	void init( char ptr m ) is
	    // native.printf( `new null pointer exception %p\n`, this );
	    super.init( m );
	si

        static void throwNPE() is
	    throw new NullPointerException("null pointer dereference");
        si

	/// \deprecated
	void enableGC() is
	    native.GC_enable();
	si
    si

    /// Exception thrown when runtime detects a non-null memory protection fault
    class MemoryProtectionException isa MemoryException is
	void init( System.String m ) is
	    super.init( m );
	si

	void init( char ptr s ) is
	    super.init( s );
	si
    si

    /// Exception thrown on out of bounds List<T> index
    class BoundsException isa RuntimeException is
	void init( System.String m ) is
	    super.init( m );
	si

	void init( char ptr s ) is
	    super.init( s );
	si
    si

    /// Exception thrown when runtime detects an out of bounds array index
    class ArrayBoundsException isa BoundsException is
	void init( System.String m ) is
	    super.init( m );
	si

	void init( char ptr s ) is
	    super.init( s );
	si

        static void throwBounds() is
	    throw new ArrayBoundsException("array index out of bounds");
        si
    si

    /// Exception thrown when the runtime detects an invalid cast
    class CastException isa RuntimeException is
	void init( System.String m ) is
	    super.init( m );
	si

	void init( char ptr s ) is
	    super.init( s );
	si

        static void throwCast() is
	    throw new CastException("invalid cast");
	si
    si

    /// Exception thrown when an operation is not implemented
    class NotImplementedException isa Exception is
	void init( String message ) is
	    super.init( message );
	si

	void init() is
	    super.init( "method not implemented" );
	si
    si

    /// Exception thrown when an assertion (Object.assert()) fails 
    class AssertException isa Exception is
	void init( String message ) is
	    super.init( message );
	si

	void init() is
	    super.init( "Assertion failed exception" );
	si
    si
si
