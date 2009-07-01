
import stream;
import pointer;
import gmap;

namespace SQL {
    pragma NoMarkUnsafe, NoWarnUnsafe;

    use System.String;

    /// Type numbers
    // SQL Lite 3 type numbers - other drivers must use these numbers:
    enum SQLType {
	INTEGER = 1,
        FLOAT = 2,
	TEXT = 3,
	BLOB = 4,
        NULL = 5
    }

    /// Root of SQLException heirarchy. Exceptions thrown by SQL drivers should inherit from this class
    class SQLException extends System.Exception {
	void init( System.String message ) {
	    super.init( message );
	}
    }

    /// Prepared statement/result set
    class Statement extends System.Object {
	void init() {
	}

	/// Bind integer value to parameter
	/// \param c parameter number to bind to
	/// \param i integer value to bind
	void bind( int c, int i ) {
	    // driver must override me
	}

	/// Bind string value to parameter
	/// \param c parameter number to bind to
	/// \param s string value to to bind
	void bind( int c, System.String s ) {
	    // driver override me
	}

	/// Bind boolean value to parameter
	/// \param c parameter number to bind to
	/// \param b boolean value to bind
	void bind( int c, bool b ) {
	    if( b ) {
		bind( c, 1 );
	    } else {
		bind( c, 0 );
	    }
	}

	/// Indexed accessor: set int Param[int c] = i
	/// Bind integer value to parameter
	/// \param c parameter number to bind to
	/// \param i integer value to bind
	set int Param[int c] = i {
	    bind( c, i );
	}

	/// Indexed accessor: set String Param[int c] = s
	/// Bind string value to parameter
	/// \param c parameter number to bind to
	/// \param s string value to to bind
	set String Param[int c] = s {
	    bind( c, s );
	}

	/// Indexed accessor: set bool Param[int c] = b
	/// Bind boolean value to parameter
	/// \param c parameter number to bind to
	/// \param b boolean value to bind
	set bool Param[int c] = b {
	    bind( c, b );
	}

	/// Advance to next row in result set
	/// \return true if positioned at a row, false if no more rows in result set
	bool next() {
	    // driver must override me
	}

	/// Execute prepared statement discarding any results
	void exec() {
	    while( next() ) 
		;
	}

	/// Accessor: get int ColumnCount
	/// Get number of columns in result set
	get int ColumnCount {
	    // driver must override me
	}

	/// Indexed accessor: get System.String Name[int c]
	/// Get name of column
	/// \param c index of column
	get System.String Name[int c] {
	    // driver must override me
	}

	/// Indexed accessor: get SQLType Type[int c]
	/// Get type of column
	/// \param c index of column
	get SQLType Type[int c] {
	    // driver must override me
	}

	/// Indexed accessor: get SQLType Type[System.String name]
	/// Get type of column
	/// \param name name of column
	get SQLType Type[System.String name] {
	    return Type[ColumnIndex[name]];
	}

	/// Indexed accessor: get System.String String[int c]
	/// Get value of column as a String
	/// \param c index of column
	get System.String String[int c] {
	    // driver must override me
	}

	/// Indexed accessor: get System.String String[System.String name]
	/// Get value of column as a String
	/// \param name name of column
	get System.String String[System.String name] {
	    return String[ColumnIndex[name]];
	}

	/// Indexed accessor: get int Int[int c]
	/// Get value of column as an integer
	/// \param c index of column
	get int Int[int c] {
	    // driver must override me
	}

	/// Indexed accessor: get int Int[System.String name]
	/// Get value of column as an integer
	/// \param name name of column
	get int Int[System.String name] {
	    return Int[ColumnIndex[name]];
	}

	/// Indexed accessor: get int ColumnIndex[System.String name]
	/// Get index of a column from name
	/// \param name name of column
	get int ColumnIndex[System.String name] {
	    // driver must override me
	}

	/// Indexer: get System.Object[System.String name]
	/// Get value of column as an Object
	/// \param name name of column
	get System.Object[System.String name] {
	    int c = ColumnIndex[name];
	    return opGet( c );
	}

	/// Indexer: get System.Object[int c] {
	/// Get value of column as an Object
	/// \param c index of column
	get System.Object[int c] {
	    var type = Type[c];
	    switch( type ) {
	    case SQLType.INTEGER:
		return Int[c].box;

	    case SQLType.FLOAT, SQLType.TEXT:
		return String[c];

	    case SQLType.BLOB:
		throw new SQLException("data is unsupported type (BLOB)");

	    case SQLType.NULL:
		return null;
	    }	    
	}

	/// Reset this Statement prior to reuse
	void reset() {
	    // driver must override me:
	}

	/// Free any resources held by this Statement
	void dispose() {
	    // driver must override me:
	}
    }

    /// A connection to a database
    class Connection extends System.Object {
	/// Construct a new Connection object
	void init() {
	}

	/// Begin a transaction
	void begin() {
	}

	/// Commit current transaction
	void commit() {
	}
       
	/// Roll back current transaction
	void rollback() {
	}
	
	/// Set auto commit mode
	void autocommit() {
	}

	/// Return a new Statement object that can subsequently be executed
	/// \param query the SQL query for this Statement
	Statement prepare( System.String query ) {
	    // driver must override me
	}

	/// Free any resources held by this Connection
	void dispose() {
	    // driver must override me
	}
    }
}