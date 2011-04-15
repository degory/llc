// Copyright 2004-2011 <degs@giantblob.com> all rights reserved


import stream;
import pointer;
import gmap;

namespace SQL is
    pragma NoMarkUnsafe, NoWarnUnsafe;

    use System.String;

    /// Type numbers
    // SQL Lite 3 type numbers - other drivers must use these numbers:
    enum SQLType is
	INTEGER = 1,
        FLOAT = 2,
	TEXT = 3,
	BLOB = 4,
        NULL = 5
    si

    /// Root of SQLException heirarchy. Exceptions thrown by SQL drivers should inherit from this class
    class SQLException isa System.Exception is
	void init( System.String message ) is
	    super.init( message );
	si
    si

    class ResultSet is
        void init() is
        si

	/// Indexer: get System.Object[int c] {
	/// Get value of column as an Object
	/// \param c index of column
	get System.Object[int c] is
            @Virtual; // override me
        si

	/// Indexer: get System.Object[System.String name]
	/// Get value of column as an Object
	/// \param name name of column
	get System.Object[System.String name] is
            @Virtual; // override me
            return this[ColumnIndex[name]];
	si

	/// Accessor: get int ColumnCount
	/// Get number of columns in result set
	get int ColumnCount is
            @Virtual; // override me
	si

	/// Indexed accessor: get System.String Name[int c]
	/// Get name of column
	/// \param c index of column
	get String Name[int c] is
            @Virtual; // override me
	si

	/// Indexed accessor: get SQLType Type[int c]
	/// Get type of column
	/// \param c index of column
	get SQLType Type[int c] is
            @Virtual; // override me
	si

	/// Indexed accessor: get SQLType Type[System.String name]
	/// Get type of column
	/// \param name name of column
	get SQLType Type[String name] is
            @Virtual;
	    return Type[ColumnIndex[name]];
	si

	/// Indexed accessor: get int ColumnIndex[System.String name]
	/// Get index of a column from name
	/// \param name name of column
	get int ColumnIndex[System.String name] is
            @Virtual;
	    // driver must override me
	si

        bool hasMoreElements() is
            @Virtual; // override me
        si        

        ResultSet nextElement() is
            @Virtual; // override me
        si

	/// Reset this Statement prior to reuse
	void reset() is
            @Virtual;
	    // driver must override me:
	si

        void dispose() is
            @Virtual;
        si
    si

    /// Prepared statement/result set
    class Statement is
	void init() is
	si

        get int ParamIndex[String name] is
            @Virtual;
        si

	/// Bind integer value to parameter
	/// \param c parameter number to bind to
	/// \param i integer value to bind
	void bind( int c, int i ) is
            @Virtual;
	    // driver must override me
	si

	/// Bind integer value to parameter
	/// \param c parameter number to bind to
	/// \param l long value to bind
	void bind( int c, long l ) is
            @Virtual;
	    // driver must override me
	si

	/// Bind string value to parameter
	/// \param c parameter number to bind to
	/// \param s string value to to bind
	void bind( int c, System.String s ) is
            @Virtual;
	    // driver override me
	si

	/// Bind boolean value to parameter
	/// \param c parameter number to bind to
	/// \param b boolean value to bind
	void bind( int c, bool b ) is
            @Virtual;
	    if b then
		bind( c, 1 );
	    else
		bind( c, 0 );
	    fi
	si

	/// Indexed accessor: set int Param[int c] = i
	/// Bind integer value to parameter
	/// \param c parameter number to bind to
	/// \param i integer value to bind
	set int[int c] = i is
            @Virtual;
	    bind( c, i );
	si

	/// Indexed accessor: set int Param[int c] = i
	/// Bind integer value to parameter
	/// \param c parameter number to bind to
	/// \param l long value to bind
	set long[int c] = l is
            @Virtual;
	    bind( c, l );
	si

	/// Indexed accessor: set String Param[int c] = s
	/// Bind string value to parameter
	/// \param c parameter number to bind to
	/// \param s string value to to bind
	set String[int c] = s is
            @Virtual;
	    bind( c, s );
	si

	/// Indexed accessor: set bool Param[int c] = b
	/// Bind boolean value to parameter
	/// \param c parameter number to bind to
	/// \param b boolean value to bind
	set bool[int c] = b is
            @Virtual;
	    bind( c, b );
	si

	/// Indexed accessor: set int Param[int c] = i
	/// Bind integer value to parameter
	/// \param name parameter name to bind to
	/// \param i integer value to bind
	set int[String name] = i is
            @Virtual;
	    bind( ParamIndex[name], i );
	si

	/// Indexed accessor: set int Param[int c] = i
	/// Bind integer value to parameter
	/// \param name parameter name to bind to
	/// \param l long value to bind
	set long[String name] = l is
            @Virtual;
	    bind( ParamIndex[name], l );
	si

	/// Indexed accessor: set String Param[int c] = s
	/// Bind string value to parameter
	/// \param name parameter name to bind to
	/// \param s string value to to bind
	set String[String name] = s is
            @Virtual;
	    bind( ParamIndex[name], s );
	si

	/// Indexed accessor: set bool Param[int c] = b
	/// Bind boolean value to parameter
	/// \param name parameter name to bind to
	/// \param b boolean value to bind
	set bool[String name] = b is
            @Virtual;
	    bind( ParamIndex[name], b );
	si

	/// Free any resources held by this Statement
	void dispose() is            
            @Virtual;
	    // driver must override me:
	si

        ResultSet fetch() is

        si
    si

    /// A connection to a database
    class Connection is
	/// Construct a new Connection object
	void init() is
	si

	/// Begin a transaction
	void begin() is
	si

	/// Commit current transaction
	void commit() is
	si
       
	/// Roll back current transaction
	void rollback() is
	si
	
	/// Set auto commit mode
	void autocommit() is
	si

	/// Return a new Statement object that can subsequently be executed
	/// \param query the SQL query for this Statement
	Statement prepare( System.String query ) is
            @Virtual;
	    // driver must override me
	si

        ResultSet fetch( String query ) is
            @Virtual;
	    // driver must override me
        si

	/// Free any resources held by this Connection
	void dispose() is
            @Virtual;
	    // driver must override me
	si
    si
si