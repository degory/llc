
import gllist.l;

namespace Generic {
    class SortedList<T> extends LinkedList<T> {
	int proc(T, T) compare;

	void init( int proc(T, T) compare ) {
	    super.init();
	    this.compare = compare;
	}

	void init() {
	    this.init( int proc(T, T)(T.opCompare) );
	}

        /// Append supplied value after last element in this LinkedList
        /// \param v the value to append
        void add( T v ) {
            if( list == null ) {
		list = new SortedRealList<T>( v, null );
            } else if( compare(v, list.Value) <= 0 ) {
		list = new SortedRealList<T>( v, cast SortedRealList<T>(list) );
	    } else {
                cast SortedRealList<T>(list).insert(v,compare);
	    }
	}
    }

    class SortedRealList<T> extends RealList<T> {
        void init( T v, SortedRealList<T> t ) {
            super.init(v, t );
	}

	void init() {
	    super.init();
	}

	void insert( T v ) {
	    throw new System.NotImplementedException( "Sort order required: use " + Class.Name + ".insert(T v, int proc(T,T))" );
	}

	void insert( T v, int proc(T,T) compare ) {
	    if( compare(v,value) <= 0 ) {
		throw new ListBoundsException( "value sorts before head of this list" );
	    }

	    if( tail == null ) {
		tail = new SortedRealList<T>(v, null);
	    } else if( compare(v,tail.value) <= 0 ) {
		tail = new SortedRealList<T>(v, cast SortedRealList<T>(tail));
	    } else {
		cast SortedRealList<T>(tail).insert( v, compare );
	    }
	}
    }
}