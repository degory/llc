
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

	/// Indexed accessor bind integer value to parameter
	/// \param c parameter number to bind to
	/// \param i integer value to bind
	set int Param[int c] = i {
	    bind( c, i );
	}

	/// Indexed accessor bind string value to parameter
	/// \param c parameter number to bind to
	/// \param s string value to to bind
	set String Param[int c] = s {
	    bind( c, s );
	}

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

	/// 
	void exec() {
	    while( next() ) 
		;
	}

	get int ColumnCount {
	    // driver must override me
	}

	get System.String Name[int c] {
	    // driver must override me
	}

	get SQLType Type[int c] {
	    // driver must override me
	}

	get SQLType Type[System.String name] {
	    return Type[ColumnIndex[name]];
	}

	get System.String String[int c] {
	    // driver must override me
	}

	get System.String String[System.String name] {
	    return String[ColumnIndex[name]];
	}

	get int Int[int c] {
	    // driver must override me
	}

	get int Int[System.String name] {
	    return Int[ColumnIndex[name]];
	}

	get int ColumnIndex[System.String name] {
	    // driver must override me
	}

	get System.Object[System.String name] {
	    int c = ColumnIndex[name];
	    return opGet( c );
	}

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

	void reset() {
	    // driver must override me:
	}

	void dispose() {
	    // driver must override me:
	}
    }

    class Connection extends System.Object {
	void init() {
	}

	void begin() {
	}

	void commit() {
	}

	void rollback() {
	}

	void autocommit() {
	}

	Statement prepare( System.String query ) {
	    // driver must override me
	}

	void dispose() {
	    // driver must override me
	}
    }
}