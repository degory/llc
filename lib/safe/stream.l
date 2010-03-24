#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import string;
import thread;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace IO {
    /// Holds Reader on standard input and Writers on standard output and standard error streams
    class Std extends System.Object {
	static FileStream in_stream = new FileStream(0);
	static FileStream out_stream = new FileStream(1);
	static FileStream err_stream = new FileStream(2);

	/// Standard input
	public static Reader in = new Reader(in_stream);
	/// Standard output
	public static Writer out = new Writer(out_stream);
	/// Standard error
	public static Writer err = new Writer(err_stream);

	/// Replace standard input, standard output and standard error with thread safe versions
	public static void makeThreadSafe() {
	    out.flush();
	    err.flush();
	    
	    // FIXME: anything buffered here is lost:
	    in = new LockedReader( in_stream );
	    
	    out = new LockedWriter( out_stream );
	    err = new LockedWriter( err_stream );
	}
    }

    /// Thrown on IO failures
    class IOException extends System.Exception {
	int os_error;

	/// Construct an IOException for the given operating system error number and message
	void init( int os_error, System.String message ) {
	    super.init( message );
	    this.os_error = os_error;
	}

	/// Construct an IOException for the given operating system error number and C-string message
	void init( int os_error, char ptr message ) {
	    super.init( message );
	    this.os_error = os_error;
	}
    }

    /// A thread-safe Reader
    class LockedReader extends Reader {
	const int DEFAULT_CAPACITY = 1024;
	System.Lock lock;

	/// Construct a LockedReader
	/// \param s CharStream to read
	/// \param c size of buffer to allocate in chars
	void init( CharStream s, int c ) {
	    super.init( s, c );
	    lock = new System.Lock();
	}

	/// Construct a LockedReader with default buffer size
	/// \param s CharStream to read
	void init( CharStream s ) {
	    init( s, DEFAULT_CAPACITY );
	}
	
	int read() {
	    try {
		lock.lock();

		return _readUnlocked();
	    } finally {
		lock.unlock();
	    }
	}

	/*
	int read() {
	    int result = -1;
	    // native.printf( `ReadBuffer.lock() this = %lp\n`, this );
	    try {
		lock.lock();
		result = _read();
	    } finally {
		lock.unlock();
	    }

	    return result;
	}
	*/

	void unRead( int c ) {
	    try {
	    	lock.lock();
		_unReadUnlocked(c);
	    } finally {
		lock.unlock();
	    }
	}

	void readAll( System.StringBuffer b ) {
	    try {
		lock.lock();
		_readAllUnlocked( b );
	    } finally {
		lock.unlock();
	    }
	}

	int readInt() {
	    try {
		lock.lock();
		return _readIntUnlocked();
	    } finally {
		lock.unlock();
	    }
	}

	void close() {
	    try {
		lock.lock();
		_closeUnlocked();
	    } finally {
		lock.unlock();
	    }
	}
    }

    /// A thread-safe Writer
    class LockedWriter extends Writer {
	private System.Lock lock;

	/// Construct a LockedWriter
	/// \param s CharStream to write to
	/// \param c size of buffer to allocate in chars
	void init( CharStream s, int c ) {
	    super.init( s, c );
	    lock = new System.Lock();
	}

	/// Construct a LockedWriter with default buffer size
	/// \param s CharStream to write to
	void init( CharStream s ) {
	    init( s, 1024 );
	}

	void flush() {
	    try {
		lock.lock();
		_flushUnlocked();
	    } finally {
		lock.unlock();
	    }
	}

	void close() {
	    try {
		lock.lock();
		_closeUnlocked();
	    } finally {
		lock.unlock();
	    }
	}

	/// Cast supplied int to a char and then write it.
	/// \throw IOException
	void write( int i ) {
	    try {
		lock.lock();
		_writeUnlocked( i );
	    } finally {
		lock.unlock();
	    }
	}
	
	/// Write supplied char. If the buffer is full, flush it then append the char to the buffer
	/// \param b char to write
	/// \throw IOException
	void write( char b ) {
	    try {
		lock.lock();
		_writeUnlocked( b );
	    } finally {
		lock.unlock();
	    }
	}

	/// Write supplied C char array. Flush the buffer and then write the supplied characters directly to the underlying CharStream
	/// \throw IOException
	void write( char ptr b, int len ) {
	    try {
		lock.lock();
		_writeUnlocked( b, len );
	    } finally {
		lock.unlock();
	    }
	}
    }

    /// Reads from a CharStream through a buffer
    class Reader extends System.Object {
	const int DEFAULT_CAPACITY = 1024;

	CharStream stream;
	char[] buffer;
	int capacity;
	int position;
	int size;
	bool is_at_end;

	/// Construct a Reader
	/// \param s CharStream to read
	/// \param c size of buffer to allocate in chars
	void init( CharStream s, int c ) {
	    super.init();
	    stream = s;
	    buffer = new char[c];
	    capacity = c;
	    position = 0;
	    size = 0;
	}

	/// Construct a Reader with default buffer size
	/// \param s CharStream to read
	void init( CharStream s ) {
	    init( s, DEFAULT_CAPACITY );
	}

	/// Have all characters available in the underlying CharStream been read
	bool isAtEnd() {
	    return is_at_end;
	}

	/// Internal method for LockedReader
	int _readUnlocked() {
	    if( position >= size ) {
		position = 0;
		size = stream.read(buffer.address, capacity);
		if( size <= 0 ) {
		    is_at_end = true;
		    return -1;
		}
	    }
	    int result = cast<int>(buffer[position]);
	    position = position + 1;
	    return result;
	}

	/// Read a character and return it, cast to an int. If the buffer is empty, fill the buffer from the underlying CharStream. If buffer is
	/// not empty, return the next available character from the buffer as an int, otherwise return -1
	/// \throw IOException
	int read() {
	    return _readUnlocked();
	}

	/// Internal method for LockedReader
	void _unReadUnlocked( int c ) {
	    //try {
	    //	lock.lock();
		position = position -1;
		if( position >= 0 && position < size ) {
		    buffer[position] = cast<char>(c);
		} else {
		    throw new IOException(0, "no space in buffer to unRead" );
		}
		//} finally {
		//	lock.unlock();
		// }
	}

	/// Push supplied character back into the buffer.
	/// \throw IOException if insufficient space in the buffer
	void unRead( int c ) {
	    _unReadUnlocked( c );
	}

	/// Internal method for LockedReader
	void _readAllUnlocked( System.StringBuffer b ) {
	    while( true ) {
		int c = _readUnlocked();
		if( c == -1 ) {
		    return;
		}
		b.append( cast<char>(c) );
	    }
	}

	/// Read all remaining characters and append to supplied StringBuffer
	/// \param b StringBuffer to read into
	/// \throw IOException
	void readAll( System.StringBuffer b ) {
	    _readAllUnlocked( b );
	}

	/// Read all remaining characters into a new StringBuffer and return it
	/// \throw IOException
	System.StringBuffer readAll() {
	    System.StringBuffer result = new System.StringBuffer();
	    readAll(result);
	    return result;
	}

	/// Internal method for LockedReader
	int _readIntUnlocked() {
	    int r = 0;
	    bool negative;

	    // first non-numeric char delimits number, including end-of-file, but insist on at least one genuine digit

	    int c = read();
	    if( isAtEnd() ) {
		// throw new IOException( 0, "end of file" );
		return 0;
	    }
	    
	    if( c == cast<int>('-') ) {
		negative = true;
		c = _readUnlocked();
	    }

	    if( c < cast<int>('0') || c > cast<int>('9') ) {
		throw new IOException( 0, "not a number" );
	    }

	    while(true) {
		if( c >= cast<int>('0') && c <= cast<int>('9') ) {
		    r = r * 10 + c - cast<int>('0');
		} else {
		    if( c != -1 ) {
			_unReadUnlocked(c);
		    }

		    if( negative ) {
			r = -r;
		    }
		    // IO.Std.err.println( "read integer: " + result );
		    return r;
		}
		c = _readUnlocked();
	    }
	}

	/// Parse an integer from input and return it.
	/// \throw IOException
	int readInt() {
	    return _readIntUnlocked();
	}


	/// Parse an integer from input into supplied reference
	/// \param result reference to read integer into
	/// \return true on success, false on any failure
	bool readInt(int ref result) {
	    try {
		result = readInt();
		return true;
	    } catch( IOException ie ) {
		result = 0;
		return false;
	    }

	}

	/// Internal method for LockedReader
	void _closeUnlocked() {
	    stream.close();
	}

	/// Discard buffered input and close underlying CharStream
	/// \throw IOException
	void close() {
	    _closeUnlocked();
	}
    }

    /// Writes to a CharStream through a buffer
    class Writer extends System.Object {
	private CharStream stream;
	private char[] buffer;
	private int capacity;
	private int position;
	private bool seen_newline;

	/// Construct a Writer
	/// \param s CharStream to write to
	/// \param c size of buffer to allocate in chars
	void init( CharStream s, int c ) {
	    super.init();
	    stream = s;
	    buffer = new char[c];

	    capacity = c;
	    position = 0;
	    seen_newline = false;
	}

	/// Construct a Writer with default buffer size
	/// \param s CharStream to write to
	void init( CharStream s ) {
	    this.init( s, 1024 );
	}

	/// Get is the underlying CharString a terminal?
	get bool IsTTY {
	    return stream.IsTTY;
	}

	/// Internal method for LockedWriter
	void _flushUnlocked() {
	    if( position > 0 ) {
		stream.write( buffer.address, position );

		position = 0;
	    }
	}

	/// Write all buffered characters to underlying CharStream
	/// \throw IOException
	void flush() {
	    _flushUnlocked();
	}

	/// Internal method for LockedWriter
	void _closeUnlocked() {
	    _flushUnlocked();
	    stream.close();
	}

	/// Write all buffered characters to underlying CharStream and close it
	/// \throw IOException
	void close() {
	    _closeUnlocked();
	}

	/// Internal method for LockedWriter
	void _writeUnlocked( int i ) {
	    _writeUnlocked( cast<char>(i) );
	}

	void write( int i ) {
	    _writeUnlocked( i );
	}
	
	void _writeUnlocked( char b ) {
	    if( position < capacity ) {
		buffer[position] = b;
		position = position + 1;
	    }

	    if( position >= capacity ) {
		_flushUnlocked();
	    }
	}

	void write( char b ) {
	    _writeUnlocked( b );
	}

	void _writeUnlocked( char ptr b, int len ) {
	    _flushUnlocked();
	    stream.write( b, len );
	    /*
	    if( len > capacity ) {

	    } else {
		int p = 0;


		while( len > 0 ) {
		    while( position < capacity && len > 0 ) {
			char c = [b + p];
			if( c == '\n' ) {
			    seen_newline = true;
			}

			buffer[position] = c;
			position = position + 1;
			p = p + 1;
			len = len - 1;
		    }
		    if( position >= capacity ) {
			_flushUnlocked();
		    }
		}
	    }
	    */
	}

	void write( char ptr b, int len ) {
	    _writeUnlocked( b, len );
	}

	void write( System.String s ) {
	    write( s.toCString(), s.getLength() );
	}

	void print( System.Object o ) {
	    write( o.toString() );
	    if( seen_newline ) {
		seen_newline = false;
		flush();
	    }
	}

	void print( System.String s ) {
	    write( s );
	    if( seen_newline ) {
		seen_newline = false;
		flush();
	    }
	}

	void println( System.Object o ) {
	    if( this == null ) {
		native.printf( `println: this is null\n` );
		return;
	    }

	    if( o != null ) {
		write( o.toString() );
	    } else {
		write( "<null>" );
	    }
	    write( '\n' );
	    flush();
	}

	void println( System.String s ) {
	    if( this == null ) {
		native.printf( `println: this is null\n` );
		return;
	    }

	    write( s );
	    write( '\n' );
	    flush();
	}

	void println() {
	    if( this == null ) {
		native.printf( `println: this is null\n` );
	    }

	    write( '\n' );
	    flush();
	}
    }


    class CharStream extends System.Object { // abstract
	void init() { super.init(); }
	get bool IsTTY { return false; }

	get int LastError { return 0; }
	int read( char ptr buffer, int count ) {
	    throw new System.NotImplementedException( "CharStream is abstract" );
	}
	int write( char ptr buffer, int count ) {
	    throw new System.NotImplementedException( "CharStream is abstract" );
	}
	void close() {
	    throw new System.NotImplementedException( "CharStream is abstract" );
	}
	bool isAtEnd() {
	    throw new System.NotImplementedException( "CharStream is abstract" );
	}
    }

    class StringStream extends CharStream {
	protected System.String string;
	protected int position;

	void init( System.String s ) {
	    super.init();
	    string = s;
	    position = 0;
	}

	int read( char ptr buffer, int size ) {
	    int i = 0, l = string.getLength();
	    while( i < size && position < l ) {
		[buffer + i] = string.charAt(position);
		i = i + 1;
		position = position + 1;
	    }

	    return i;
	}

	int write( char ptr buffer, int size ) {
	    throw new IOException( 0, "cannot write to StringStream" );
	}
    }	

    class StringBufferStream extends StringStream {
	void init( System.StringBuffer s ) {
	    super.init(s);
	}

	int write( char ptr buffer, int size ) {
	    System.StringBuffer s = cast<System.StringBuffer>(string);
	    for( int i = 0; i < size; i = i + 1 ) {
		s.append( [buffer + i] );
	    }
	    return i;
	}
    }

    class FileStream extends CharStream {
	private int handle;
	private System.String path;
	private bool is_at_end;

	static get int LastError {
	    return cast<int>(native.__geterrno());
	}
        
	static void throwIOException( System.String string, int error, System.String path ) {
	    System.StringBuffer b = new System.StringBuffer(string);
	    b.append( ` \"` );
	    b.append( path );
	    b.append( '\"' );
	    if( error >= 0 ) {	
		b.append( `: ` );
		b.append( cast<char ptr>(native.strerror(error)) );
	    }

	    throw new IOException( error, b );
	}

	void throwIOException( System.String string, int error ) {
	    throwIOException( string, error, path );
	}

	void init( System.String path ) {
	    super.init();
	    Path = path;
	}

	get bool IsTTY {
	    return cast int(native.isatty(handle)) != 0;
	}

	set System.String Path = path {
	    this.path = path;
	}

	get System.String Path {
	    return path;
	}

	void init( int handle ) {
	    super.init();
	    if( handle < 0 || handle > 2 ) {
		throw new IOException( 0, "sandboxed IO.FileStream only operates on stdin,stdout and stderr" );
	    }

	    this.path = "handle #" + handle;
	    this.handle = handle;
	}

	System.String toString() {
	    return "IO.FileStream on " + path;
	}

	bool isAtEnd() {
	    return is_at_end;
	}

	void checkResult( char ptr message, int r ) {
	    // native.printf( `check result %s %d\n`, message, r );
	    if( r < 0 ) {
		throwIOException( new System.String( message ), r );
	    }
	}

	void checkOpen( char ptr message ) {
	    if( handle < 0 ) {
		throwIOException( new System.String(message), 0 );
	    }
	}

	void close() {
	    checkOpen( `closing closed FileStream` );
	    int r = cast<int>(native.close( handle ));
	    if( r != 0 ) {
		throwIOException( "close", getLastError() );
	    }
	}

	int read( char ptr buffer, int size ) {
	    // native.printf( `read %p %d...\n`, buffer, size );
	    checkOpen( `read closed FileByteStream` );
	    int r = cast<int>(native.read( handle, buffer, size ));
	    // native.printf( `read result %d\n`, r );
	    if( r < size ) {
		is_at_end = true;
	    }

	    /*
	    for( int i = 0; i < r; i = i + 1 ) {
		native.printf( `%c`, [buffer + i] );
	    }

	    if( r == -1 ) {
		native.printf( `read returned -1 - not an error?\n` );
		return r;
	    }
	    */
	    checkResult( `read`, r );
	    return r;
	}

	int write( char ptr buffer, int size ) {
	    checkOpen( `write closed FileByteStream` );
	    int r = cast<int>(native.write( handle, buffer, size ));
	    checkResult( `write`, r );
	    return r;
	}

	get int Handle {
	    return handle;
	}
    }
}
