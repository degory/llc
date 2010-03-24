#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved


pragma NoWarnUnsafe, NoMarkUnsafe;

namespace IO {
    /// Wrapper around UNIX stat() 
    struct Stat {
	public int mtime;
	public int size;
	
	void init() {
	}

	/// Get information for a file
	/// \param name path to file
	bool stat( System.String name ) {
	    if( native.__stat_file2( name.toCString(), this ) != null ) {
		return false;
	    } else {
		return true;
	    }
	}
	
	/// Is mtime for this file after mtime for another file
	/// \param s other file
	bool after( Stat s ) {
	    return mtime > s.mtime;
	}
    }
}
