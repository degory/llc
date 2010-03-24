#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved


import stream;
import pointer;
import gmap;
import sql;

import "pq";

namespace SQL {
    namespace PostgreSQL {
	pragma NoMarkUnsafe, NoWarnUnsafe;
	
	use System.String;
	use System.StringBuffer;
	
	class Exception extends SQLException {
	    void init( System.String message ) {
		super.init( message );
	    }
	}
	
	/// PostgreSQL error numbers
	enum Status {
	    EMPTY_QUERY = 0,          /* empty query string was executed */
		COMMAND_OK,                       /* a query command that doesn't return
						   * anything was executed properly by the
						   * backend */
		TUPLES_OK,                        /* a query command that returns tuples was
						   * executed properly by the backend, PGresult
						   * contains the result tuples */
		COPY_OUT,                         /* Copy Out data transfer in progress */
		COPY_IN,                          /* Copy In data transfer in progress */
		BAD_RESPONSE,                     /* an unexpected response was recv'd from the
						   * backend */
		NONFATAL_ERROR,           /* notice or warning message */
		FATAL_ERROR                       /* query failed */
		}

	/// A PostgreSQL result set structure
	struct Result {
	    // opaque and allocated by PostgreSQL
	}
	
	/// A PostgreSQL prepared statement and result set
	class Statement extends SQL.Statement {
	    word connection;
	    Result result_set;
	    
	    int current_row;
	    int column_count;
	    int row_count;
	    
	    System.String name;
	    char ptr[] values;
	    
	    static int next_statement;
	    
	    native Result PQprepare( word connection, char ptr name, char ptr query, int num_param, word ptr param_types );
	    native Result PQexec( word connection, char ptr query );
	    native Result PQexecPrepared(
					 word connection,
					 char ptr name,
					 int num_param,
					 char ptr ptr values,
					 int ptr param_lengths,
					 int ptr param_formats,
					 int result_format );
	    
	    native Status PQresultStatus( Result pg_result );
	    native char ptr PQresultErrorMessage( Result pg_result );
	    native void PQclear( Result pg_result );
	    
	    native int PQntuples( Result pg_result );
	    native int PQnfields( Result pg_result );
	    native int PQfnumber( Result pg_result, char ptr column_name );
	    native char ptr PQfname( Result pg_result, int column_index );
	    native int PQftype( Result pg_result, int column_index );
	    
	    native bool PQgetisnull( Result pg_result, int row_index, int column_index );
	    native char ptr PQgetvalue( Result pg_result, int row_index, int column_index );
	    
	    /// Construct a new PostgreSQLStatement
	    /// \param con a pointer to the PostgreSQL connection structure
	    /// \param query SQL query text for this Statement
	    void init( word con, System.String query ) {
		connection = con;
		
		name = "s" + next_statement;
		next_statement = next_statement + 1;
		
		var q = new StringBuffer( query.Length );
		var param_count = 0;
		
		for( var i = 0; i < query.Length; i = i + 1 ) {
		    var c = query[i];
		    if( c == '?' ) {
			if( i == query.Length-1 || query[i+1] != '?' ) {
			    param_count = param_count + 1;
			    q.append('$');
			    q.append( param_count );
			} else {
			    q.append( c );
			}
		    } else {
			if( c == '$' ) {
			    param_count = param_count + 1;
			}
			
			q.append( c );
		    }
		}
		

		// IO.Std.err.println( "about to prepare: " + q + " param count: " + param_count );
		var result = PQprepare( connection, name.toCString(), q.toCString(), param_count, null );
		
		checkResult( result );
		PQclear( result );
		
		values = new char ptr[param_count];
	    }
	    
	    /// Construct a new PostgreSQLStatement with no SQL query text
	    /// \param c a pointer to the PostgreSQL connection structure
	    void init( word c ) {
		// no prepared statement - only exec with explicit query is supported
		connection = c;
	    }
	    
	    void bind( int c, int i ) {
		values[c] = i.toString().toCString();
	    }
	    
	    void bind( int c, System.String s ) {
		values[c] = s.toCString();
	    }
	    
	    bool next() {
		if( result_set == null ) {
		    fetchResultSet();
		}
		
		current_row = current_row + 1;

		return current_row < row_count;
	    }
	    
	    /// Internal method: execute prepared statement, check result and determine size of result set
	    void fetchResultSet() {
		result_set = executePrepared();
		checkResult( result_set );
		
		row_count = PQntuples( result_set );
		column_count = PQnfields( result_set );
		current_row = -1;

		// IO.Std.err.println( "fetch: row count: " + row_count + ", column_count: " + column_count );
	    }

	    /// Internal method: execute prepared statement and check result
	    Result executePrepared() {
		if( name == null ) {
		    throw new Exception( "no prepared statement" );
		}

		/*
		IO.Std.err.println( "about to execute prepared " + name + ", " + values.length );

		for( var i = 0; i < values.length; i = i + 1 ) {
		    IO.Std.err.println( "param " + i + " = " + new System.String(values[i]) );
		}
		*/

		var result = PQexecPrepared( 
					    connection,
					    name.toCString(),
					    values.length,
					    values.address,
					    null,
					    null,
					    0 );
		
		checkResult( result );
		
		return result;
	    }
	    
	    void exec() {
		result_set = null;
		var result = executePrepared();
		checkResult( result_set );
		PQclear( result_set );
	    }
	    
	    /// Execute SQL query immediately without preparing a statement first
	    void exec( String query ) {
		var result = PQexec( connection, query.toCString() );
		checkResult( result );
		PQclear( result );
	    }

	    /// Execute SQL query immediately and ignore any error result
	    void execQuiet( String query ) {
		var result = PQexec( connection, query.toCString() );
		PQclear( result );
	    }

	    /// Check the result of executing a query
	    /// \throw SQL.PostgreSQL.Exception
	    void checkResult( Result pg_result ) {
		var result = PQresultStatus(pg_result);

		if( result < Status.COMMAND_OK && result > Status.TUPLES_OK ) {
		    var error_string = new String( PQresultErrorMessage( pg_result ) );
		    IO.Std.err.println( "result is: " + cast int(result) + ", message: " + error_string );

		    if( cast int(result) == 7 ) {
			IO.Std.err.println( "result is: " + cast int(result) + " is this really an error?"  );
			return;
		    }

		    PQclear( pg_result );
		    
		    throw new Exception( error_string );
		}	   
	    }
	    
	    get int ColumnCount {
		return column_count;
	    }
	    
	    get String Name[int c] {
		return new String( PQfname(result_set,c) );
	    }
	    
	    get SQLType Type[int c] {
		// FIXME: this is completely wrong
		return cast SQLType( PQftype(result_set,c) );
	    }
	    
	    get String String[int c] {
		if( PQgetisnull(result_set,current_row,c) ) {
		    return null;
		} else {
		    return new String( PQgetvalue(result_set,current_row,c) );
		}
	    }
	    
	    get int Int[int c] {
		if( PQgetisnull(result_set,current_row,c) ) {
		    return 0;
		} else {
		    return new String( PQgetvalue(result_set,current_row,c) ).toInt();
		}
	    }
	    
	    get int ColumnIndex[String name] {
		return PQfnumber(result_set,name.toCString());
	    }
	    
	    void reset() {
		PQclear( result_set );
	    }
	    
	    void dispose() {
		if( result_set != null ) {
		    PQclear( result_set );
		    result_set = null;
		}

		if( name != null ) {
		    execQuiet( "deallocate " + name );
		    name = null;
		}
	    }
	}
	
	/// A Connection to a PostgreSQL database
	class Connection extends SQL.Connection {
	    word connection;
	    Statement ts;
	    
	    native word PQconnectdb(char ptr connect_string);
	    native word PQfinish( word connection );
	    native int PQstatus( word connection );
	    
	    /// Construct a new SQL.PostgreSQL.Connection
	    /// \param connect_string a PostgreSQL connect string describing the database to connect to
	    void init( System.String connect_string ) {
		IO.Std.err.println( "connecting to: " + connect_string );

		connection = PQconnectdb( connect_string.toCString() );

		// IO.Std.err.println( "connection is: " + cast int(connection) );
		checkStatus(connection);
	    }
	    
	    /// Internal method: check that we are connected to PostgreSQL
	    void checkStatus( word connection ) {
		// IO.Std.err.println( "check status..." );
		int result = PQstatus( connection );
		// IO.Std.err.println( "result is: " + result );
		if( result != 0 ) {
		    // IO.Std.err.println( "about to throw exception..." );
		    throw new Exception( "connection bad" );
		    dispose();
		}
	    }
	    
	    
	    void begin() {
		if( ts == null ) {
		    ts = new Statement(connection);
		}
		ts.exec("begin");
	    }
	    
	    void commit() {
		if( ts == null ) {
		    ts = new Statement(connection);
		}
		ts.exec("commit");
	    }
	    
	    void rollback() {
		if( ts == null ) {
		    ts = new Statement(connection);
		}
		ts.exec( "rollback" );
	    }

	    void autocommit() {
		if( ts == null ) {
		    ts = new Statement(connection);
		}
		ts.exec( "set autocommit to on" );
	    }
	    
	    Statement prepare( String query ) {
		return new Statement( connection, query );
	    }
	    
	    void dispose() {
		// IO.Std.err.println( "disposing PostgreSQL connection..." );
		if( ts != null ) {
		    // IO.Std.err.println( "disposing temporary statement: " + cast int(ts) );
		    ts.dispose();
		    ts = null;
		}

		if( connection != 0W ) {
		    // IO.Std.err.println( "disposing connection: " + cast int(connection) );
		    PQfinish(connection);
		    connection = 0W;
		}
		// IO.Std.err.println( "dispose complete" );
	    }
	}
    }
}