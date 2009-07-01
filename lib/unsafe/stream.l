import string;
import thread;
import lock;

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
	public static Writer out = cast Writer(System.Exit.add(new Writer(out_stream)));
	/// Standard error
	public static Writer err = cast Writer(System.Exit.add(new Writer(err_stream)));

        /// Replace standard input, standard output and standard error with thread safe versions
 	public static void makeThreadSafe() {
	    out.flush();
	    err.flush();
	    
	    // FIXME: anything buffered here is lost:
	    in = new LockedReader( in_stream );
	    
	    out = cast Writer(System.Exit.add(new LockedWriter( out_stream )));
	    err = cast Writer(System.Exit.add(new LockedWriter( err_stream )));
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
	Util.Lock lock;

        /// Construct a LockedReader
        /// \param s CharStream to read
        /// \param c size of buffer to allocate in chars
	void init( CharStream s, int c ) {
	    super.init( s, c );
	    lock = new Util.Lock();
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
	private Util.Lock lock;

        /// Construct a LockedWriter
        /// \param s CharStream to write to
        /// \param c size of buffer to allocate in chars
	void init( CharStream s, int c ) {
	    super.init( s, c );
	    lock = new Util.Lock();
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

	void write( int i ) {
	    try {
		lock.lock();
		_writeUnlocked( i );
	    } finally {
		lock.unlock();
	    }
	}
	
	void write( char b ) {
	    try {
		lock.lock();
		_writeUnlocked( b );
	    } finally {
		lock.unlock();
	    }
	}

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

	// Get the underlying CharStream
	get CharStream Stream {
	    return stream;
	}

	// Get the operating system handle from the underlying CharStream
	get int Handle {
	    return stream.Handle;
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
	    close();
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
	private bool flush_on_println;

        /// Construct a Writer
        /// \param s CharStream to write to
        /// \param c size of buffer to allocate in chars
	void init( CharStream s, int c ) {
	    super.init();
	    stream = s;
	    buffer = new char[c];

	    capacity = c;
	    position = 0;
	}

        /// Construct a Writer with default buffer size
        /// \param s CharStream to write to
	void init( CharStream s ) {
	    this.init( s, 1024 );
	    // native.printf( `new writer on %s from %s\n`, s.toCString(), new System.Backtrace().toCString() );
	}

	void dispose() {
	    _flushUnlocked();
	    stream.dispose();
	}

	// Get the underlying CharStream
	get CharStream Stream {
	    return stream;
	}

        // Get the operating system handle from the underlying CharStream
	get int Handle {
	    return stream.Handle;
	}

        /// Get is the underlying CharString a terminal?
	get bool IsTTY {
	    return stream.IsTTY;
	}

	/// Get should flush on every println?
	get bool FlushOnPrintln {
	    return flush_on_println;
	}

	/// Set should flush on every println
	/// \param f should always flush?
	set bool FlushOnPrintln = f {
	    flush_on_println = f;
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

	// Internal method for LockedWriter
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

	/// Convert supplied int to char and write it.
	/// \param i integer to write as character. Behaviour is not defined if supplied int is not representable as a char.
	void write( int i ) {
	    _writeUnlocked( i );
	}
	
	/// Internal method for LockedWriter
	void _writeUnlocked( char b ) {
	    if( position < capacity ) {
		buffer[position] = b;
		position = position + 1;
	    }

	    if( position >= capacity ) {
		_flushUnlocked();
	    }
	}

	/// Write supplied char. Char is appended to the buffer and if the buffer is full then the buffer
	/// is flushed.  Behaviour is not defined if supplied int is not representable as a char.
	/// \param b char to write
	void write( char b ) {
	    _writeUnlocked( b );
	}

	/// Internal method for LockedWriter
	void _writeUnlocked( char ptr b, int len ) {
	    int remain = capacity - position;
	    if( remain < len ) {
		_flushUnlocked();
		stream.write( b, len );
	    } else {
		while( len > 0 ) {
		    char c = [b];
		    _writeUnlocked( c );
		    b = b + 1;
		    len = len - 1;
		}
	    }
	}

        /// Write supplied C char array. If there is sufficient space then write the characters to the buffer, otherwise flush the buffer and then write the
	/// characters directly to the underlying CharStream 
	/// \param b C char array to write. Must be at least len characters long
	/// \param len how many characters to write
        /// \throw IOException
	void write( char ptr b, int len ) {
	    _writeUnlocked( b, len );
	}

	/// Write the supplied String
	/// \param s string to write
        /// \throw IOException
	void write( System.String s ) {
	    write( s.toCString(), s.getLength() );
	}

	/// Write the supplied Object as a String. The Object is converted to a String and then written
	/// \param o the Object to write.
        /// \throw IOException
	void print( System.Object o ) {
	    if( o != null ) {
		write( o.toString() );
	    } else {
		write( "<null>" );
	    }
	}

	/// Write the supplied String.
	/// \param s the String to write.
	/// \throw IOException
	void print( System.String s ) {
	    write( s );
	}

	/// Write the supplied Object as a String. The Object is converted to a String and then written followed by a newline.
	/// If FlushOnPrintln is set then the buffer is flushed after the newline is written.
	/// \param o the Object to write.
        /// \throw IOException
	void println( System.Object o ) {
	    if( this == null ) {
		native.printf( `println: this Writer is null %s\n`, new System.Backtrace().toCString() );
		return;
	    }

	    if( o != null ) {
		write( o.toString() );
	    } else {
		write( "<null>" );
	    }
	    write( '\n' );

	    if( flush_on_println ) {
		flush();
	    }
	}

	/// Write the supplied String.
	/// If FlushOnPrintln is set then the buffer is flushed after the newline is written.
	/// \param s the String to write.
        /// \throw IOException
	void println( System.String s ) {
	    if( this == null ) {
		native.printf( `println: this Writer is null %s\n`, new System.Backtrace().toCString() );
		return;
	    }

	    write( s );
	    write( '\n' );

	    if( flush_on_println ) {
		flush();
	    }
	}

	/// Write a newline.
	/// If FlushOnPrintln is set then the buffer is flushed after the newline is written.
        /// \throw IOException
	void println() {
	    if( this == null ) {
		native.printf( `println: this Writer is null %s\n`, new System.Backtrace().toCString() );
	    }

	    write( '\n' );
	    if( flush_on_println ) {
		flush();
	    }
	}
    }


    /// A stream of characters, simplex or duplex depending on implementation.
    /// \abstract
    class CharStream extends System.Object {
	/// Construct a new CharStream
	/// \abstract
	void init() { super.init(); }

	/// Does this Stream refer to a terminal?
	get bool IsTTY { return false; }

	/// Get the underlying operating system handle for this CharStream
	get int Handle { return -1; }

	/// Get the last operating system error number for this CharString
	get int LastError { return 0; }

	/// Read characters into supplied buffer
	/// \param buffer pointer to buffer that characters will be read into. Must have space for at least count characters
	/// \param count number of characters to read
	/// \return number of characters read.
	int read( char ptr buffer, int count ) {
	    throw new System.NotImplementedException( "read not implemented in " + this );
	}

	/// Write characters from supplied buffer
	/// \param buffer pointer to buffer that characters will be written from. Must contain at least count characters
	/// \param count number of characters to write. 
	/// \return number of characters written.
	int write( char ptr buffer, int count ) {
	    throw new System.NotImplementedException( "write not implemented in " + this );
	}

	/// Close this CharStream
	void close() {
	    throw new System.NotImplementedException( "close not implemented in " + this );
	}

	/// Return has all available input been read?
	bool isAtEnd() {
	    throw new System.NotImplementedException( "isAtEnd not implemented in " + this );
	}

	/// Move the read/write position to supplied offset relative to start of file
	/// \param offset new read/write position in characters from start of file
	void seekSet( long offset ) {
	    throw new System.NotImplementedException( "seekSet not implemented in " + this );
	}

	/// Move the read/write position to supplied offset relative to current position
	/// \param offset new read/write position in characters from current position
	void seekCur( long offset ) {
	    throw new System.NotImplementedException( "seekCur not implemented in " + this );
	}

	/// Move the read/write position to supplied offset relative to end of file
	/// \param offset new read/write position in characters from end of file
	void seekEnd( long offset ) {
	    throw new System.NotImplementedException( "seekEnd not implemented in " + this );
	}

	/// If underlying stream output is buffered then flush all buffered output, otherwise
	/// do nothing
	void flush() {
	}
    }

    /// A read only CharStream over a String
    class StringStream extends CharStream {
	protected System.String string;
	protected int position;

	/// Construct a new StringStream
	/// \param s the String this StringStream will read 
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

	/// \attention StringStream is read only
	int write( char ptr buffer, int size ) {
	    throw new IOException( 0, "cannot write to StringStream" );
	}
    }	

    /// A read write CharStream over a StringBuffer
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

    /// A read write CharStream over an operating system handle (typically a file handle but can be a pipe etc.)
    class FileStream extends CharStream {
	private int handle;
	private System.String path;
	private bool is_at_end;

	const int
	    SEEK_SET = 0,
	    SEEK_CUR = 1,
	    SEEK_END = 2;

	static get int LastError {
	    return cast int(native.__geterrno());
	}

	/// Throws an IOException with message text appropriate for supplied operating system error
	static void throwIOException( System.String string, int error, System.String path ) {
	    System.StringBuffer b = new System.StringBuffer(string);
	    b.append( ` \"` );
	    b.append( path );
	    b.append( '\"' );
	    if( error != 0 ) {	
		b.append( `: ` );
		b.append( cast<char ptr>(native.strerror(error)) );
		b.append( ` (` );
  	        b.append( error );
		b.append( `)` );
	    }

	    throw new IOException( error, b );
	}

	/// Throws an IOException with message text appropriate for supplied operating system error
	void throwIOException( System.String string, int error ) {
	    throwIOException( string, error, path );
	}

	/// Construct a FileStream with Path set to supplied String. Note: Path is used only for error reporting. 
	/// Callers need to also set an operating system handle before a FileStream can be used
	void init( System.String path ) {
	    super.init();
	    Path = path;
	}

	// Construct a FileStream over the supplied handle.
	void init( int handle ) {
	    super.init();

	    this.path = "handle #" + handle + " from " + new System.Backtrace();
	    this.handle = handle;
	}


	get bool IsTTY {
	    return cast int(native.isatty(handle)) != 0;
	}

	/// Set the path name used for error reporting
	set System.String Path = path {
	    this.path = path;
	}

	/// Get the path name used for error reporting
	get System.String Path {
	    return path;
	}


	System.String toString() {
	    return "IO.FileStream on " + path;
	}

	bool isAtEnd() {
	    return is_at_end;
	}

	/// Ensure that the supplied result is not an error (is not negative), otherwise throw an IOException
	/// \throw IOException
	void checkResult( char ptr message, int r ) {
	    // native.printf( `check result %s %d\n`, message, r );
	    if( r < 0 ) {
		throwIOException( new System.String( message ), LastError );
	    }
	}

	/// Check that this FileStream is open (has a valid handle), otherwise throw an IOException
	void checkOpen( char ptr message ) {
	    if( handle < 0 ) {
		throwIOException( "closed: " + new System.String(message), 0 );
	    }
	}

	void close() {
	    checkOpen( `closing closed FileStream` );
	    int r = cast<int>(native.close( handle ));
	    if( r != 0 ) {
		throwIOException( "close", LastError );
	    }
	    handle = -1;
	}

	/// Close this stream without checking result for error
	void closeQuiet() {
	    native.close(handle);	    
	}

	/// Dispose of this FileStream. Close the handle if it's open.
	void dispose() {
	    if( handle >= 0 ) {
		closeQuiet();
		handle = -1;
	    }
	}

	int read( char ptr buffer, int size ) {
	    checkOpen( `read closed FileStream` );

	    int r;

	    do {
		r = cast<int>(native.read( handle, buffer, size ));
		if( r < 0 ) {
		    var l = LastError;
		    if( l == File.EINTR || l == File.EAGAIN ) {
			continue;
		    } else {
			throwIOException( "read", l );
		    }
		} else if( r < size ) {
		    is_at_end = true;
		}
	    } while( false );

	    return r;
	}

	int write( char ptr buffer, int size ) {
	    checkOpen( `write closed FileStream` );

	    int r;

	    do {
		r = cast<int>(native.write( handle, buffer, size ));
		if( r < 0 ) {
		    var l = LastError;
		    if( l == File.EINTR || l == File.EAGAIN ) {
			continue;
		    } else {
			throwIOException( "write", l );
		    }
		} else if( r < size ) {
		    is_at_end = true;
		}
	    } while( false );

	    return r;
	}

	get int Handle {
	    return handle;
	}

	void seekSet( long offset ) {
	    checkOpen( `seek closed FileStream` );
	    var result = cast long(native.lseek( handle, offset, SEEK_SET ));
	    if( result < 0L ) {
		throwIOException( "seekSet", LastError );
	    }
	}

	void seekCur( long offset ) {
	    checkOpen( `seek closed FileStream` );
	    var result = cast long(native.lseek( handle, offset, SEEK_CUR ));
	    if( result < 0L ) {
		throwIOException( "seekCur", LastError );
	    }
	}

	void seekEnd( long offset ) {
	    checkOpen( `seek closed FileStream` );
	    var result = cast long(native.lseek( handle, offset, SEEK_END ));
	    /*
	    if( result < 0L ) {
		throwIOException( "seekEnd", LastError );
	    }
	    */
	}
    }

    /// Provides methods for opening files as FileStream objects and utility methods relating to paths, files and directories
    class File extends System.Object {
	const int
	    O_RDONLY = 0,
	    O_WRONLY = 1,
	    O_RDWR = 2,

	    M_RDWR = 3,

	    O_APPEND = 0x400,
	    O_CREAT =   0x40,
            O_EXCL =    0x80,
            O_TRUNC =  0x200;

	const int
	    DEFAULT_PROT = 438, // octal 666
	    DEFAULT_MODE = O_RDONLY;

	public const int
	    EINTR = 4,
	    EAGAIN = 11,
	    EINVAL = 22;

	bool mode_set;    // has a mode been explicitly set?
	bool read, write; // UNIX modes are not sane so store read + write separately
	private int mode; // append, creat, excl, trunc
	private int prot;
	private System.String path;

	/// Construct a File object with the supplied path
	/// \param path a path name, either absolute or relative to current working directory
	void init( System.String path ) {
	    Path = path;
	    read = true;
	    prot = DEFAULT_PROT;
	}

	/// Set this File's path
	set System.String Path = path {
	    this.path = path;
	}

	/// Get this File's path
	get System.String Path {
	    return path;
	}

	/// Set permission bits.
	/// \param prot any new files created from this File object will get these permission bits
	set int Prot = prot {
	    this.prot = prot;
	}

	/// Set want read mode.
	/// \param read if true, FileStreams created from this File will be readable (provided file system permissions allow it)
	set bool Read = read {
	    mode_set = true;
	    this.read = read;
	}

	/// Get want read mode.
	get bool Read {
	    return read;
	}

	/// Set want write mode.
	/// \param write if true, FileStreams created from this File will be writeable (provided file system permissions allow it)
	set bool Write = write {
	    mode_set = true;
	    this.write = write;
	}

	/// Get want write mode.
	get bool Write {
	    return write;
	}

	/// Get the underlying UNIX open()/creat() mode bits that will be specified for FileStreams opened from this file
	get int Mode {
	    int m = mode;
	    if( read ) {
		if( write ) {
		    m = m | O_RDWR;
		} else {
		    m = m | O_RDONLY;
		}
	    } else {
		if( write ) {
		    m = m | O_WRONLY;
		} else {
		    // actually neither:
		    m = m | O_RDONLY;
		}
	    }

	    return m;
	}

	/// Set the underlying UNIX open()/creat() mode bits that will be specified for FileStreams opened from this file
	/// \param mode UNIX mode bits suitible for passing to open()/creat()
	set int Mode = mode {
	    mode_set = true;
	    int m = mode & ~M_RDWR;
	    int rw = mode & M_RDWR;
	    if( rw == O_RDWR ) {
		read = true;
		write = true;
	    } else if( rw == O_RDONLY ) {
		read = true;
		write = false;
	    } else if( rw == O_WRONLY ) {
		read = false;
		write = true;
	    } else {
		throw new IOException( 0, "bad file mode: " + System.String.hex(mode) );
	    }

	    this.mode = m;
	}

	/// Check that no mode bits have been explicitly set, otherwise throw IOException
	/// \throw IOException
	void checkNoModeSet() {
	    if( mode_set ) { 
		throw new IOException(0,"a mode is set for file '" + path + "': use IO.File.open()" );
	    }
	}

	System.String toString() {
	    if( path != null ) {
		return "IO.File '" + path + "'";
	    } else {
		return "IO.File";
	    }
	}

	/// Return a new Reader on a read-only FileStream for the supplied path
	/// \param path path to the file to open
	static Reader openRead( System.String path ) {
	    return new Reader( openReadStream( path ) );
	}

	/// Return a new Reader on a read-only FileStream for current path
	Reader openRead() {
	    return new Reader( openReadStream() );
	}

	/// Return a new Writer on a write-only FileStream for the supplied path
	/// \param path path to the file to open
	static Writer openWrite( System.String path ) {
	    return new Writer( openWriteStream(path) );
	}

	/// Return a new Writer on a write-only FileStream for current path
	Writer openWrite() {
	    return new Writer( openWriteStream() );
	}

	/// Return a new Writer on an append-only FileStream for the supplied path
	static Writer openAppend( System.String path ) {
	    return new Writer( openAppendStream(path) );
	}

	/// Return a new Writer on an append-only FileStream for the current path
	Writer openAppend() {
	    return new Writer( openAppendStream() );
	}

	/// Return a new Writer on a write-only FileStream for a newly created file at the supplied path
	static Writer openCreate( System.String path ) {
	    return new Writer( openCreateStream(path) );
	}

	/// Return a new Writer on a write-only FileStream for a newly created file at the current path
	Writer openCreate() {
	    return new Writer( openCreateStream() );
	}

	/// Return a new read-write FileStream for a newly created temporary file at the supplied path
	static FileStream openTemp( System.String path ) {
	    int l = path.Length;
	    char ptr s = cast char ptr(native.GC_malloc_atomic(l + 7));

	    int i;
	    for( i = 0; i < l; i = i + 1 ) {
		[s + i] = path[i];
	    }

	    for( i = 0; i < 6; i = i + 1 ) {
		[s + l + i] = 'X';
	    }

	    [s + l + 7] = cast char(0);
	    var handle = cast int(native.mkstemp(s));
	    if( handle < 0 ) {
		FileStream.throwIOException( "mkstemp", FileStream.LastError, path );
	    }

	    var result = new FileStream(handle);

	    result.Path = new System.String(s);

	    return result;
	}

	/// Return a new FileStream for a file at the supplied path
	/// \param path path to file to open or create
	/// \param mode UNIX open mode
	/// \param prot UNIX file protection bits
	/// \param quiet if true, return null on failure, otherwise throw IOException on failure
	/// \throw IOException
	static FileStream openStream( System.String path, int mode, int prot, bool quiet ) {
	    // native.printf( `mode %o prot %o\n`, mode, prot );
	    // IO.Std.err.println( "opening '" + path + "' mode: " + System.String.oct(mode) + ", prot: " + System.String.oct(prot) );
	    
	    int handle = cast<int>(native.open( path.toCString(), mode, prot ));

	    if( handle < 0 ) {
		if( quiet ) {
		    return null;
		} else {
		    FileStream.throwIOException( "open", FileStream.LastError, path );
		}
	    }

	    return new FileStream( handle );
	}

	/// Return a new FileStream for a file at the supplied path
	/// \param path path to file to open or create
	/// \param mode UNIX open mode
	/// \param prot UNIX file protection bits
	/// \throw IOException
	static FileStream openStream( System.String path, int mode, int prot ) {
	    return openStream( path, mode, prot, false );
	}

	/// Return a new FileStream for a file at the current path using currently set UNIX open mode and UNIX file protection bits
	/// \throw IOException
	FileStream openStream() {
	    return openStream( path, mode, prot, false );
	}

	/// Return a new read-only FileStream for a file at the supplied path, which must exist
	/// \param path path to the file to open
	static FileStream openReadStream( System.String path ) {
	    return openStream( path, O_RDONLY, 0, false );
	}

	/// Return a new read-only FileStream for a file at the current path, which must exist
	FileStream openReadStream() {
	    checkNoModeSet();
	    return openStream( path, O_RDONLY, 0, false );
	}

	/// Return a new write-only FileStream for a file at the supplied path. The file is created with default UNIX
	/// protection bits if it does not exist. Existing files are not truncated.
	/// \param path path to file to open or create
	/// \throw IOException
	static FileStream openWriteStream( System.String path ) {
	    return openStream( path, O_WRONLY | O_CREAT, DEFAULT_PROT, false );
	}

	/// Return a new write-only FileStream for a file at the current path. The file is created with current UNIX
	/// protection bits if it does not exist. Existing files are not truncated
	/// \throw IOException
	FileStream openWriteStream() {
	    checkNoModeSet();
	    return openStream( path, O_WRONLY | O_CREAT, prot, false );
	}

	/// Return a new read-write FileStream for a file at the supplied path. The file is created with default UNIX
	/// protection bits if it does not exist. Existing files are not truncated
	/// \param path path to file to open or create
	/// \throw IOException
	static FileStream openReadWriteStream( System.String path ) {
	    return openStream( path, O_RDWR | O_CREAT, DEFAULT_PROT, false );
	}

	/// Return a new read-write FileStream for a file at the current path. The file is created with current UNIX
	/// protection bits if it does not exist. Existing files are not truncated
	/// \throw IOException
	FileStream openReadWriteStream() {
	    checkNoModeSet();
	    return openStream( path, O_RDWR | O_CREAT, prot, false );
	}

	/// Return a new append-only FileStream for a file at the supplied path. The file is created with default UNIX
	/// protection bits if it does not exist. Existing files are not truncated.
	/// \param path path to file to open or create
	/// \throw IOException
	static FileStream openAppendStream( System.String path ) {
	    // IO.Std.err.println( "open append: " + System.String.oct(O_RDWR | O_CREAT | O_APPEND) + " prot: " + System.String.oct(DEFAULT_PROT) );
	    return openStream( path, O_WRONLY | O_CREAT | O_APPEND, DEFAULT_PROT, false );
	}

	/// Return a new append-only FileStream for a file at the current path. The file is created with current UNIX
	/// protection bits if it does not exist. Existing files are not truncated
	/// \throw IOException	FileStream openAppendStream() {
	FileStream openAppendStream() {
	    checkNoModeSet();
	    return openStream( path, O_WRONLY | O_CREAT | O_APPEND, prot, false );
	}

	/// Return a new write-only FileStream for a file at the supplied path. The file is created with default UNIX
	/// protection bits if it does not exist. Existing files are truncated.
	/// \param path path to file to open or create
	/// \throw IOException
	// create -> create if not present, truncate if present, write only
	static FileStream openCreateStream( System.String path ) {
	    return openStream( path, O_WRONLY | O_CREAT | O_TRUNC, DEFAULT_PROT, false );
	}

	/// Return a new write-only FileStream for a file at the current path. The file is created with current UNIX
	/// protection bits if it does not exist. Existing files are truncated
	/// \throw IOException
	FileStream openCreateStream() {
	    checkNoModeSet();
	    return openStream( path, O_WRONLY | O_CREAT | O_TRUNC, prot, false );
	}

	/// Return a new write-only FileStream for a file at the supplied path. The file is created with default UNIX
	/// protection bits if it does not exist. If the file already exists null is returned
	/// \param path path to file to open or create
	/// \return FileStream on success, null if the file already exists
	/// \throw IOException
	static FileStream openCreateLockStream( System.String path ) {
	    return openStream( path, O_WRONLY | O_CREAT | O_TRUNC | O_EXCL, DEFAULT_PROT, true );
	}

	/// Return a new write-only FileStream for a file at the current path. The file is created with current UNIX
	/// protection bits if it does not exist. If the file already exists null is returned
	/// \return FileStream on success, null if the file already exists
	/// \throw IOException
	FileStream openCreateLockStream() {
	    checkNoModeSet();
	    return openStream( path, O_WRONLY | O_CREAT | O_TRUNC | O_EXCL, prot, true );
	}

	/// Rename a file, return success or failure
	/// \param from path to existing file
	/// \param to path to rename file to
	/// \return true on success, otherwise false
	static bool renameQuiet( System.String from, System.String to ) {
	    int result = cast int(native.rename(from.toCString(), to.toCString()));
	    /*
	    if( result != 0 ) {
		System.StringBuffer cause = "rename failed " + from + "->" + to + " failed: ";
		cause.append( cast char ptr(native.strerror(FileStream.LastError)) );
		IO.Std.err.println( cause );
	    }
	    */

	    return result == 0;
	}
	

	/// Rename a file
	/// \param from path to existing file
	/// \param to path to rename file to
	/// \throw IOException
	static void rename( System.String from, System.String to ) {
	    if( !renameQuiet(from, to) ) {
		FileStream.throwIOException( "rename to " + to, FileStream.LastError, from );
	    }
	}
	
	/// Delete file with supplied path, return success or failure
	/// \param file path to file to delete
	/// \return true on success, otherwise false
	static bool deleteQuiet( System.String file ) {
	    int result = cast int(native.unlink(file.toCString()));
	    return result == 0;
	}

	// Delete file with current path, return success or failure
	// \return true on success, otherwise false
	bool deleteQuiet() {
	    return deleteQuiet( path );
	}

	/// Delete file with supplied path
	/// \param file path to file to delete
	/// \throw IOException
	static void delete( System.String file ) {
	    if( !deleteQuiet(file) ) {
		FileStream.throwIOException( "delete", FileStream.LastError, file );
	    }
	}

	/// Delete file with supplied path
	/// \throw IOException
	void delete() {
	    delete( path );
	}

	/// Touch the supplied file. If the file exists its last modified time is set to the current time. If the file doesn't exist then
	/// it is created and its creation time is set to the current time.
	/// \param file path to the file to touch
	/// \throw IOException
	static void touch( System.String file ) {
	    FileStream f = File.openWriteStream(file);
	    f.close();
	}

	/// Touch the file at the current path. If the file exists its last modified time is set to the current time. If the file doesn't exist then
	/// it is created and its creation time is set to the current time.
	/// \param file path to the file to touch
	/// \throw IOException
	void touch() {
	    touch( path );
	}

	/// Touch the supplied file, return success or failure. If the file exists its last modified time is set to the current time. If the
	/// file doesn't exist then it is created and its creation time is set to the current time.
	/// \param file path to the file to touch
	/// \return true on success, otherwise false
	static bool touchQuiet( System.String file ) {
	    try {
		touch( file );
		return true;
	    } catch( IO.IOException ioe ) {
		return false;
	    }
	}

	/// Touch the file at the current path, return success or failure. If the file exists its last modified time is set to the current time. If the
	/// file doesn't exist then it is created and its creation time is set to the current time.
	/// \return true on success, otherwise false
	bool touchQuiet() {
	    return touchQuiet( path );
	}

	const int MAX_PATH_LENGTH = 512;

	/// Get the path to the current working directory.
	static get System.String WorkingDirectory {
	    char ptr buffer = cast char ptr( native.GC_malloc_atomic( MAX_PATH_LENGTH ) );
            // native.printf( `%p working directory\n`, buffer );
	    char ptr r = cast char ptr( native.getcwd( buffer, MAX_PATH_LENGTH) );

	    if( r != buffer ) {
		throw new IOException( FileStream.LastError, "get working directory" );
	    } else {
		return new System.String( buffer ); 
	    }
	}

	/// Read a symbolic link and return the path it refers to, optionally suppress exceptions on error.
	/// \param file path to the link to read
	/// \param quiet if true do not throw IOException if the link cannot be read but instead return null
	/// \return if file refers to a symbollic link, return the referenced path; if file refers to a regular
	/// file return its path otherwise if quiet then return null, otherwise throw IOException
	/// \throw IOException
	static System.String readLink( System.String file, bool quiet ) {
	    char ptr buffer = cast char ptr( native.GC_malloc_atomic( MAX_PATH_LENGTH ) );
            // native.printf( `%p read link\n`, buffer );
	    int result = cast int( native.readlink( file.toCString(), buffer, MAX_PATH_LENGTH-1 ) );
	    
	    if( result < 0 ) {
		if( quiet ) {
		    if( FileStream.LastError == EINVAL ) {
			// not a link - return file itself:
			return file;
		    } else {
			return null;
		    }
		}
		throw new IOException( FileStream.LastError, "read link: " + file + " (" + FileStream.LastError + ")" );
	    } else {
		[buffer+result] = '\0';
		return new System.String( buffer );
	    }		   
	}

	/// Read a symbolic link and return the path it refers to.
	/// \param file path to the link to read
	/// \return if file refers to a symbollic link, return the referenced path; if file refers to a regular
	/// file return its path otherwise throw IOException
	/// \throw IOException
	static System.String readLink( System.String file ) {
	    return readLink( file, false );
	}

	/// Read a symbolic link and return the path it refers to.
	/// \param file path to the link to read
	/// \param quiet if true do not throw IOException if the link cannot be read but instead return null
	/// \return if file refers to a symbollic link, return the referenced path; if file refers to a regular
	/// file return its path otherwise return null
	static System.String readLinkQuiet( System.String file ) {
	    return readLink( file, true );
	}
    }
}
