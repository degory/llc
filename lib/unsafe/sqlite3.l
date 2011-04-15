// Copyright 2004-2011 <degs@giantblob.com> all rights reserved


import stream;
import pointer;
import gmap;
import sql;
import "sqlite3";

namespace SQL is
    pragma NoMarkUnsafe, NoWarnUnsafe;

    use System.Object;
    use System.Int;
    use System.Long;
    use System.String;
    use Util.Pointer;
    use Generic.Map;

    namespace SQLite3 is
	/// SQLite3 error codes
	enum Result is
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
	si

	/// Thrown by SQLLite3 bindings on errors
	class Exception isa SQLException is
	    Result error;
	    void init( word connection, String message, Result error ) is
		super.init( message + " " + new String(cast char ptr(native.sqlite3_errmsg(connection))) );
		this.error = error;
	    si
	    
	    void init( String message ) is
		super.init( message );
	    si

	    get Result Error is
		return error;
	    si
	si

        class ResultSet isa SQL.ResultSet is
	    Map<String,int> column_map;
            Statement statement;
            word sqlite3_statement;
            bool dispose_statement;

            void init( Statement s, word s3s ) is
                IO.Std.err.println( "new result set..." );
                super.init();
                statement = s;
                sqlite3_statement = s3s;
            si

            get bool DisposeStatement is
                return dispose_statement;
            si

            set bool DisposeStatement = d is
                dispose_statement = d;
            si

            bool next() is
                IO.Std.err.println( "result set next..." );
                return statement._next();
            si

	    get int ColumnCount is
		return cast int(native.sqlite3_column_count(sqlite3_statement));
	    si

            get Object[int c] is
                IO.Std.err.println( "result set get " + c + "..." );
                var tc = Type[c];

                if tc == SQLType.NULL then
                    return null;
                elif tc == SQLType.INTEGER then
                    IO.Std.err.println( "result set get " + c + " int..." );
                    return new Long(cast long(native.sqlite3_column_int64(sqlite3_statement, c)));
                else
                    IO.Std.err.println( "result set get " + c + " string..." );
  		    return new String(cast char ptr(native.sqlite3_column_text(sqlite3_statement, c)));
                fi
            si

	    get String Name[int c] is
                IO.Std.err.println( "result set get " + c + " name..." );
		char ptr cname = cast char ptr(native.sqlite3_column_origin_name(sqlite3_statement, c));
		String name = new String(cname);

		return name;
	    si

	    get SQLType Type[int c] is
                IO.Std.err.println( "result set get " + c + " type..." );
		int itype = cast int(native.sqlite3_column_type(sqlite3_statement, c));
		return cast SQLType(itype);
	    si

	    get Map<String,int> ColumnMap is
                IO.Std.err.println( "result set get column map..." );
                if column_map == null then
  		    column_map = new Map<String,int>();
		    for int i = 0; i < ColumnCount; i = i + 1 do
		        String name = Name[i];

		        if name != null && name.Length > 0 then
			    column_map[name] = i + 1; // avoid 0 as Generic.Map<...,int> returns 0 on not found
		        fi
		    od
                fi

                return column_map;
	    si

	    get int ColumnIndex[String name] is
                IO.Std.err.println( "result set get " + name + " column index..." );
                var m = ColumnMap;
		int c = m[name];
		if c == 0 then
		    throw new Exception( "unknown column '" + name + "'" );
		else
		    return c - 1; // shift from 1-based to 0-based
		fi
	    si

            void dispose() is
                if dispose_statement && statement != null then
                    statement.dispose();
                    statement = null;
                    sqlite3_statement = 0w;
                fi
            si 
        si

	/// An SQLite3 Statement
        class Statement isa SQL.Statement is
	    word connection;
	    word statement;
	    Generic.Map<String,int> column_map;

	    /// Construct a new SQLite3.Statement
	    /// \param c pointer to libsqlite3 connection structure
	    /// \param s pointer to libsqlite3 statement structure
	    void init( word c, word s ) is
                IO.Std.err.println( "new statement..." );
                super.init();
		this.connection = c;
		this.statement = s;
	    si

	    void bind( int c, int i ) is
                IO.Std.err.println( "bind " + c + "<-" + i );

		var result = cast Result(native.sqlite3_bind_int( statement, c+1, i ));
		if result != Result.OK then
		    throw new Exception( connection, "bind " + c + " " + i, result );
		fi
	    si

	    void bind( int c, long l ) is
                IO.Std.err.println( "bind " + c + "<-" + l );

		var result = cast Result(native.sqlite3_bind_int64( statement, c+1, l ));
		if result != Result.OK then
		    throw new Exception( connection, "bind " + c + " " + l, result );
		fi
	    si

	    void bind( int c, String s ) is
                IO.Std.err.println( "bind " + c + "<-" + s );

                if s == null then
                    bindNull(c);
                    return;
                fi

		var result = cast Result(native.sqlite3_bind_text( statement, c+1, s.toCString(), s.Length, 0 ));

		if result != Result.OK then
		    throw new Exception( connection, "bind " + c + " " + s, result );
		fi
	    si

	    void bindNull( int c ) is
                IO.Std.err.println( "bind " + c + "<-" + null );

		var result = cast Result(native.sqlite3_bind_null( statement, c+1 ) );
		if result != Result.OK then
		    throw new Exception( connection, "bind " + c + " null", result );
		fi
	    si    

	    void bind( int c, Object v ) is
                IO.Std.err.println( "bind " + c + "<-" + v );

                if v == null then
                    bindNull(c);                
                elif isa String(v) then
                    bind(c, cast String(v));
                elif isa Int(v) then
                    bind(c, cast Int(v).Value);
                elif isa Long(v) then
		    bind(c, cast Long(v).Value);
                else
                    throw new SQL.SQLException( "bind value of unexpected type: " + v.Class );
                fi
	    si

            void bind( Object[] values ) is
                IO.Std.err.println( "bind all<-" + values );

                for var i = 0; i < values.length; i = i + 1 do
                    bind(i, values[i]);
                od
            si

	    bool _next() is
                IO.Std.err.println( "step..." );

		var result = cast Result(native.sqlite3_step(statement));

		if result == Result.ROW then
                    IO.Std.err.println( "step at row" );
		    return true;
		elif result == Result.DONE then
                    IO.Std.err.println( "step done" );
		    return false;
		else
		    throw new Exception( connection, "next", result );
		fi
	    si

	    void exec() is
                IO.Std.err.println( "exec..." );
		while _next() do 
		    ;
                od
	    si

            ResultSet fetch() is
                return new ResultSet(this, statement);
            si

	    void reset() is
		column_map = null;
		var result = cast Result(native.sqlite3_reset(statement));
		if result != Result.OK then
		    throw new Exception( connection, "reset", result );
		fi
	    si

	    void dispose() is
		if statement != 0W then
		    native.sqlite3_finalize( statement );
		    statement = 0W;
		fi
	    si
        si
    
	/// a Connection to a SQLite3 database
	class Connection isa SQL.Connection is
	    String name;
	    word connection;

	    /// Construct a new SQLite3Connection
	    /// \param name path to the SQLite3 database file to open
	    void init( String name ) is
                super.init();
		this.name = name;
		open();
	    si

	    /// Internal method. SQLite3Connections are opened when constructed
	    void open() is
		Pointer t = new Pointer();
		Result result = cast Result(native.sqlite3_open( name.toCString(), t ));
		if result != Result.OK then
		    throw new Exception( t.value, "open: " + name, result );
		fi
		connection = t.value;
	    si

	    void begin() is
		Statement s = prepare("begin");
		s.exec();
	    si

	    void commit() is
		Statement s = prepare("commit");
		s.exec();
	    si

	    void rollback() is
		Statement s = prepare("rollback");
		s.exec();
	    si

	    Statement prepare( String query ) is
		Pointer t = new Pointer();
		Pointer u = new Pointer();
	    
		Result result = cast Result(
					    native.sqlite3_prepare_v2(
								      connection,
								      query.toCString(),
								      query.Length+1,
								      t,
								      u
								      ) );
					      

		if result != Result.OK then
		    throw new Exception( connection, "prepare: " + query, result );
		fi

		return new Statement( connection, t.value );
	    si

            ResultSet fetch( String query, Object[] param ) is
                var s = prepare(query);

                s.bind(param);

                var r = s.fetch();
                r.DisposeStatement = true;
                return r;
            si

	    void dispose() is
		if connection != 0W then
		    native.sqlite3_close(connection);
		    connection = 0W;
		fi
	    si
	si
    si
si