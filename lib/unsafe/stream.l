import string;
import thread;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace IO {
    class Std extends System.Object {
	static FileStream in_stream = new FileStream(0);
	static FileStream out_stream = new FileStream(1);
	static FileStream err_stream = new FileStream(2);

	public static Reader in = new Reader(in_stream);
	public static Writer out = new Writer(out_stream);
	public static Writer err = new Writer(err_stream);

	public static void makeThreadSafe() {
	    out.flush();
	    err.flush();
	    
	    // FIXME: anything buffered here is lost:
	    in = new LockedReader( in_stream );
	    
	    out = new LockedWriter( out_stream );
	    err = new LockedWriter( err_stream );
	}
    }

    class IOException extends System.Exception {
	int os_error;
    
	void init( int os_error, System.String message ) {
	    super.init( message );
	    this.os_error = os_error;
	}

	void init( int os_error, char ptr message ) {
	    super.init( message );
	    this.os_error = os_error;
	}
    }

    class LockedReader extends Reader {
	const int DEFAULT_CAPACITY = 1024;
	System.Lock lock;

	void init( CharStream s, int c ) {
	    super.init( s, c );
	    lock = new System.Lock();
	}

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

    class LockedWriter extends Writer {
	private System.Lock lock;

	void init( CharStream s, int c ) {
	    super.init( s, c );
	    lock = new System.Lock();
	}

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

    class Reader extends System.Object {
	const int DEFAULT_CAPACITY = 1024;

	CharStream stream;
	char[] buffer;
	int capacity;
	int position;
	int size;
	bool is_at_end;

	void init( CharStream s, int c ) {
	    super.init();
	    stream = s;
	    buffer = new char[c];
	    capacity = c;
	    position = 0;
	    size = 0;
	}

	void init( CharStream s ) {
	    init( s, DEFAULT_CAPACITY );
	}

	get CharStream Stream {
	    return stream;
	}

	get int Handle {
	    return stream.Handle;
	}

	bool isAtEnd() {
	    return is_at_end;
	}

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

	int read() {
	    return _readUnlocked();
	}

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

	void unRead( int c ) {
	    _unReadUnlocked( c );
	}

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

	void readAll( System.StringBuffer b ) {
	    _readAllUnlocked( b );
	}

	System.StringBuffer readAll() {
	    System.StringBuffer result = new System.StringBuffer();
	    readAll(result);
	    return result;
	}

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

	int readInt() {
	    return _readIntUnlocked();
	}

	bool readInt(int ref result) {
	    try {
		result = readInt();
		return true;
	    } catch( IOException ie ) {
		result = 0;
		return false;
	    }

	}


	void _closeUnlocked() {
	    stream.close();
	}

	void close() {
	    _closeUnlocked();
	}
    }

    class Writer extends System.Object {
	private CharStream stream;
	private char[] buffer;
	private int capacity;
	private int position;
	private bool seen_newline;

	void init( CharStream s, int c ) {
	    super.init();
	    stream = s;
	    buffer = new char[c];

	    capacity = c;
	    position = 0;
	    seen_newline = false;
	}

	get CharStream Stream {
	    return stream;
	}

	get int Handle {
	    return stream.Handle;
	}

	get bool IsTTY {
	    return stream.IsTTY;
	}

	void init( CharStream s ) {
	    this.init( s, 1024 );
	    // native.printf( `new writer on %s from %s\n`, s.toCString(), new System.Backtrace().toCString() );
	}

	void _flushUnlocked() {
	    if( position > 0 ) {
		stream.write( buffer.address, position );

		position = 0;
	    }
	}

	void flush() {
	    _flushUnlocked();
	}

	void _closeUnlocked() {
	    _flushUnlocked();
	    stream.close();
	}

	void close() {
	    _closeUnlocked();
	}

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
		native.printf( `println: this Writer is null %s\n`, new System.Backtrace().toCString() );
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
		native.printf( `println: this Writer is null %s\n`, new System.Backtrace().toCString() );
		return;
	    }

	    write( s );
	    write( '\n' );
	    flush();
	}

	void println() {
	    if( this == null ) {
		native.printf( `println: this Writer is null %s\n`, new System.Backtrace().toCString() );
	    }

	    write( '\n' );
	    flush();
	}
    }


    class CharStream extends System.Object { // abstract
	void init() { super.init(); }
	get bool IsTTY { return false; }
	get int Handle { return -1; }
	get int LastError { return 0; }

	int read( char ptr buffer, int count ) {
	    throw new System.NotImplementedException( "read not implemented in " + this );
	}
	int write( char ptr buffer, int count ) {
	    throw new System.NotImplementedException( "write not implemented in " + this );
	}
	void close() {
	    throw new System.NotImplementedException( "close not implemented in " + this );
	}
	bool isAtEnd() {
	    throw new System.NotImplementedException( "isAtEnd not implemented in " + this );
	}

	void seekSet( long offset ) {
	    throw new System.NotImplementedException( "seekSet not implemented in " + this );
	}

	void seekCur( long offset ) {
	    throw new System.NotImplementedException( "seekCur not implemented in " + this );
	}

	void seekEnd( long offset ) {
	    throw new System.NotImplementedException( "seekEnd not implemented in " + this );
	}

	void flush() {
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

	const int
	    SEEK_SET = 0,
	    SEEK_CUR = 1,
	    SEEK_END = 2;

	static get int LastError {
	    return cast int(native.__geterrno());
	}
        
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

	    this.path = "handle #" + handle + " from " + new System.Backtrace();
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
		throwIOException( new System.String( message ), LastError );
	    }
	}

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

	void closeQuiet() {
	    native.close(handle);	    
	}

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

	void init( System.String path ) {
	    Path = path;
	    read = true;
	    prot = DEFAULT_PROT;
	}

	set System.String Path = path {
	    this.path = path;
	}

	get System.String Path {
	    return path;
	}

	set int Prot = prot {
	    this.prot = prot;
	}

	set bool Read = read {
	    mode_set = true;
	    this.read = read;
	}

	get bool Read {
	    return read;
	}

	set bool Write = write {
	    mode_set = true;
	    this.write = write;
	}

	get bool Write {
	    return write;
	}

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

	static Reader openRead( System.String path ) {
	    return new Reader( openReadStream( path ) );
	}

	Reader openRead() {
	    return new Reader( openReadStream() );
	}

	static Writer openWrite( System.String path ) {
	    return new Writer( openWriteStream(path) );
	}

	Writer openWrite() {
	    return new Writer( openWriteStream() );
	}

	static Writer openAppend( System.String path ) {
	    return new Writer( openAppendStream(path) );
	}

	Writer openAppend() {
	    return new Writer( openAppendStream() );
	}

	static Writer openCreate( System.String path ) {
	    return new Writer( openCreateStream(path) );
	}

	Writer openCreate() {
	    return new Writer( openCreateStream() );
	}

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

	static FileStream openStream( System.String path, int mode, int prot ) {
	    return openStream( path, mode, prot, false );
	}

	FileStream openStream() {
	    return openStream( path, mode, prot, false );
	}

	// read -> fail if not present, read only
	static FileStream openReadStream( System.String path ) {
	    return openStream( path, O_RDONLY, 0, false );
	}

	FileStream openReadStream() {
	    checkNoModeSet();
	    return openStream( path, O_RDONLY, 0, false );
	}

        // write -> create if not present, no truncate, write only - is this useful?
	static FileStream openWriteStream( System.String path ) {
	    return openStream( path, O_WRONLY | O_CREAT, DEFAULT_PROT, false );
	}

	FileStream openWriteStream() {
	    checkNoModeSet();
	    return openStream( path, O_WRONLY | O_CREAT, prot, false );
	}

        // read,write -> create if not present, no truncate, read/write
	static FileStream openReadWriteStream( System.String path ) {
	    return openStream( path, O_RDWR | O_CREAT, DEFAULT_PROT, false );
	}

	FileStream openReadWriteStream() {
	    checkNoModeSet();
	    return openStream( path, O_RDWR | O_CREAT, prot, false );
	}

        // append -> create if not present, no truncate, write only
	static FileStream openAppendStream( System.String path ) {
	    // IO.Std.err.println( "open append: " + System.String.oct(O_RDWR | O_CREAT | O_APPEND) + " prot: " + System.String.oct(DEFAULT_PROT) );
	    return openStream( path, O_WRONLY | O_CREAT | O_APPEND, DEFAULT_PROT, false );
	}

	FileStream openAppendStream() {
	    checkNoModeSet();
	    return openStream( path, O_WRONLY | O_CREAT | O_APPEND, prot, false );
	}

	// create -> create if not present, truncate if present, write only
	static FileStream openCreateStream( System.String path ) {
	    return openStream( path, O_WRONLY | O_CREAT | O_TRUNC, DEFAULT_PROT, false );
	}

	FileStream openCreateStream() {
	    checkNoModeSet();
	    return openStream( path, O_WRONLY | O_CREAT | O_TRUNC, prot, false );
	}

	// create lock -> create only if not present, don't truncate, write only, quiet failure:
	static FileStream openCreateLockStream( System.String path ) {
	    return openStream( path, O_WRONLY | O_CREAT | O_TRUNC | O_EXCL, DEFAULT_PROT, true );
	}

	FileStream openCreateLockStream() {
	    checkNoModeSet();
	    return openStream( path, O_WRONLY | O_CREAT | O_TRUNC | O_EXCL, prot, true );
	}
       
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

	static void rename( System.String from, System.String to ) {
	    if( !renameQuiet(from, to) ) {
		FileStream.throwIOException( "rename to " + to, FileStream.LastError, from );
	    }
	}
	
	static bool deleteQuiet( System.String file ) {
	    int result = cast int(native.unlink(file.toCString()));
	    return result == 0;
	}

	bool deleteQuiet() {
	    return deleteQuiet( path );
	}

	static void delete( System.String file ) {
	    if( !deleteQuiet(file) ) {
		FileStream.throwIOException( "delete", FileStream.LastError, file );
	    }
	}

	void delete() {
	    delete( path );
	}

	static void touch( System.String file ) {
	    FileStream f = File.openWriteStream(file);
	    f.close();
	}

	void touch() {
	    touch( path );
	}

	static bool touchQuiet( System.String file ) {
	    try {
		touch( file );
		return true;
	    } catch( IO.IOException ioe ) {
		return false;
	    }
	}

	bool touchQuiet() {
	    return touchQuiet( path );
	}

	const int MAX_PATH_LENGTH = 512;
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

	static System.String readLink( System.String file ) {
	    return readLink( file, false );
	}

	static System.String readLinkQuiet( System.String file ) {
	    return readLink( file, true );
	}
    }
}
