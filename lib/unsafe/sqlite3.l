
import stream;
import pointer;
import gmap;
import "sqlite3";

namespace SQL {
    pragma NoMarkUnsafe, NoWarnUnsafe;

    use Util.Pointer;

    /// SQLite3 error codes
    enum SQLResult {
	OK = 0,   /* Successful result */
	    /* beginning-of-error-codes */
        ERROR = 1,   /* SQL error or missing database */
	INTERNAL = 2,   /* Internal logic error in SQLite */
        PERM = 3,   /* Access permission denied */
	ABORT = 4,   /* Callback routine requested an abort */
	BUSY = 5,   /* The database file is locked */
	LOCKED = 6,   /* A table in the database is locked */
	NOMEM = 7,   /* A malloc() failed */
	READONLY = 8,   /* Attempt to write a readonly database */
	INTERRUPT = 9,   /* Operation terminated by sqlite3_interrupt()*/
	IOERR = 10,   /* Some kind of disk I/O error occurred */
	CORRUPT = 11,   /* The database disk image is malformed */
	NOTFOUND = 12,   /* NOT USED. Table or record not found */
	FULL = 13,   /* Insertion failed because database is full */
	CANTOPEN = 14,   /* Unable to open the database file */
	PROTOCOL = 15,   /* NOT USED. Database lock protocol error */
	EMPTY = 16,   /* Database is empty */
	SCHEMA = 17,   /* The database schema changed */
	TOOBIG = 18,   /* String or BLOB exceeds size limit */
	CONSTRAINT = 19,   /* Abort due to constraint violation */
	MISMATCH = 20,  /* Data type mismatch */
	MISUSE = 21,  /* Library used incorrectly */
	NOLFS = 22,   /* Uses OS features not supported on host */
	AUTH = 23,   /* Authorization denied */
	FORMAT = 24,   /* Auxiliary database format error */
	RANGE = 25,   /* 2nd parameter to sqlite3_bind out of range */
	NOTADB = 26,   /* File opened that is not a database file */
	ROW = 100,  /* sqlite3_step() has another row ready */
	DONE = 101  /* sqlite3_step() has finished executing */
    }

    /// Thrown by SQLLite3 bindings on errors
    class SQLLite3Exception extends SQLException {
	SQLResult error;
	void init( word connection, System.String message, SQLResult error ) {
	    super.init( message + " " + new System.String(cast char ptr(native.sqlite3_errmsg(connection))) );
	    this.error = error;
	}

	void init( System.String message ) {
	    super.init( message );
	}       
    }

    /// A SQLite3 Statement
    class SQLite3Statement extends Statement {
	word connection;
	word statement;
	Generic.Map<System.String,int> column_map;

	/// Construct a new SQLite3Statement
	/// \param c pointer to libsqlite3 connection structure
	/// \param s pointer to libsqlite3 statement structure
	void init( word c, word s ) {
	    this.connection = c;
	    this.statement = s;
	}

	void bind( int c, int i ) {
	    var result = cast SQLResult(native.sqlite3_bind_int( statement, c+1, i ));
	    if( result != SQLResult.OK ) {
		throw new SQLException( connection, "bind " + c + " " + i, result );
	    }
	}

	void bind( int c, System.String s ) {
	    // IO.Std.err.println( "binding '" + s + "'..." );
	    var result = cast SQLResult(native.sqlite3_bind_text( statement, c+1, s.toCString(), s.Length, 0 ));
	    if( result != SQLResult.OK ) {
		throw new SQLException( connection, "bind " + c + " " + s, result );
	    }
	}

	bool next() {
	    var result = cast SQLResult(native.sqlite3_step(statement));

	    if( result == SQLResult.ROW ) {
		return true;
	    } else if( result == SQLResult.DONE ) {
		return false;
	    } else {
		throw new SQLException( connection, "next", result );
	    }
	}

	void exec() {
	    while( next() ) 
		;
	}

	get int ColumnCount {
	    return cast int(native.sqlite3_column_count(statement));
	}

	get System.String Name[int c] {
	    char ptr cname = cast char ptr(native.sqlite3_column_origin_name(statement, c));
	    System.String name = new System.String(cname);

	    return name;
	}

	get SQLType Type[int c] {
	    int itype = cast int(native.sqlite3_column_type(statement, c));
	    return cast SQLType(itype);
	}

	get System.String String[int c] {
	    return new System.String(cast char ptr(native.sqlite3_column_text(statement, c)));
	}

	get int Int[int c] {
	    return cast int(native.sqlite3_column_int(statement, c));
	}

	void initColumnMap() {
	    column_map = new Generic.Map<System.String,int>();
	    for( int i = 0; i < ColumnCount; i = i + 1 ) {
		System.String name = Name[i];

		if( name != null && name.Length > 0 ) {
		    column_map[name] = i + 1; // avoid 0 as Generic.Map<...,int> returns 0 on not found
		}
	    }
	}

	get int ColumnIndex[System.String name] {
	    if( column_map == null ) {
		initColumnMap();
	    }
	    int c = column_map[name];
	    if( c == 0 ) {
		throw new SQLException( "unknown column '" + name + "'" );
	    } else {
		return c - 1; // shift from 1-based to 0-based
	    }
	}

	void reset() {
	    column_map = null;
	    var result = cast SQLResult(native.sqlite3_reset(statement));
	    if( result != SQLResult.OK ) {
		throw new SQLException( connection, "reset", result );
	    }
	}

	void dispose() {
	    if( statement != 0W ) {
		native.sqlite3_finalize( statement );
		statement = 0W;
	    }
	}
    }

    /// a Connection to a SQLite3 database
    class SQLite3Connection extends Connection {
	System.String name;
	word connection;

	/// Construct a new SQLite3Connection
	/// \param name path to the SQLite3 database file to open
	void init( System.String name ) {
	    this.name = name;
	    open();
	}

	/// Internal method. SQLite3Connections are opened when constructed
        void open() {
	    Pointer t = new Pointer();
	    SQLResult result = cast SQLResult(native.sqlite3_open( name.toCString(), t ));
	    if( result != SQLResult.OK ) {
		throw new SQLException( t.value, "open: " + name, result );
	    }
	    connection = t.value;
	}

	void begin() {
	    Statement s = prepare("begin");
	    s.exec();
	}

	void commit() {
	    Statement s = prepare("commit");
	    s.exec();
	}

	void rollback() {
	    Statement s = prepare("rollback");
	    s.exec();
	}

	Statement prepare( System.String query ) {
	    Pointer t = new Pointer();
	    Pointer u = new Pointer();
	    
	    SQLResult result = cast SQLResult(
		native.sqlite3_prepare_v2(
					  connection,
					  query.toCString(),
					  query.Length+1,
					  t,
					  u
					  ) );
					      

	    if( result != SQLResult.OK ) {
		throw new SQLException( connection, "prepare: " + query, result );
	    }

	    return new SQLite3Statement( connection, t.value );
	}

	void dispose() {
	    if( connection != 0W ) {
		native.sqlite3_close(connection);
		connection = 0W;
	    }
	}
    }
}