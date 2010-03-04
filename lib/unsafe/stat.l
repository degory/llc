
pragma NoWarnUnsafe, NoMarkUnsafe;

namespace IO {
    /// Wrapper around UNIX stat() 
    struct Stat {
	public int mtime;
	public int size;
	
	void init() {
	}

	bool stat( System.String name ) {
	    if( native.__stat_file2( name.toCString(), this ) != null ) {
		return false;
	    } else {
		return true;
	    }
	}

	bool after( Stat s ) {
	    return mtime > s.mtime;
	}
    }
}
