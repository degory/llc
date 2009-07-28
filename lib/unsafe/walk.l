
import gset;

namespace Util {
    use System.Object;
    use System.String;
    use Generic.Set;

    /// Walks all objects reachable from a given starting object visiting each once
    class Walk {
	/// masked addresses of previously visited objects
	Set<word> seen;

	/// method that will be called once for each reachable object
	void proc(Object) visit;

	/// construct a new Walk object
	/// \param v a method that will be called for each reachable object with that object as its argument
	/// \param size size of hash table used to store addresses of visited objects
	/// \attention size should be a prime number
	void init( void proc(Object) v, int size ) {
	    seen = new Set<word>(size);
	    visit = v;
	}

	/// construct a new Walk object.
	/// the default size hash table is used to store addresses of visited objects
	/// \param v a method that will be called for each reachable object with that object as its argument
	/// \param size size of hash table used to store addresses of visited objects
	void init( void proc(Object) v ) {
	    init( v, 32749 );
	}

	/// visit all objects reachable from supplied object exactly once with the method reference supplied when this Walk object was constructed.
	/// \param o the object to start the walk from
	/// \attention o itself is not visited
	/// \attention objects visited by previous calls to this function will not be visited again.
	void walk( Object o ) {
	    if( o == null ) {
		return;
	    }

	    // avoid confusing garbage collector: store unrecognisable value rather than pointer in the set:
	    word h = -cast word(o);

	    if( seen.contains(h) ) {
		// IO.Std.err.println( "already seen " + o.ClassName );
		return;
	    }

	    seen.add(h);

	    char ptr p = cast char ptr(o);

	    visit(o);

	    Object ptr ov = o.ObjectValuesPointer;
	    if( ov != null ) {
		var l = o.ObjectValuesLength;
		// IO.Std.err.println( "walk " + l + " pointer values for " + o.ClassName );

		walkValues( ov, o.ObjectValuesLength );
	    }

	    char ptr type = o.TypeTable;

	    int s = o.ObjectSize;
	    word inc;

	    do {
		char t = [type];
		if( t == 0c ) {
		    break;
		}

		// FIXME: assuming class is packed here:
		switch( t ) {
		case TYPE_1BYTE:
		    p = p + 1;

		case TYPE_4BYTE:
		    p = align(p,4) + 4;

		case TYPE_8BYTE:
		    p = align(p,8) + 8;
		    
		case TYPE_OBJECT,TYPE_ARRAY:
		    p = align(p,8);
		    walk( cast Object([p]) );
		    p = p + 8;

		case TYPE_POINTER:
		    p = align(p,8) + 8;

		default:
		    throw new System.Exception( "unexpected type " + cast int(t) );
		}
		
		type = type + 1;

	    } while(true);
	}

	/// return the next address aligned to a given size
	/// \param a address to align
	/// \param s storage size to align to
	/// \return next address greater than or equal to a that is evenly divisible by s
        static char ptr align(char ptr a, int s) {
            var m = cast word(s) - 1w;
            var r = (cast word(a) + m) & ~m;

            return cast char ptr(r);
        }
	
	/// visit every object referenced by or reachable from a list of objects
	/// \param p pointer to an list of objects
	/// \param l number of objects in the list
	void walkValues( Object ptr p, int l ) {
	    while( l > 0 ) {
		// IO.Std.err.println( "walk " + l + "..." );
		Object o = [p];
		if( o != null ) {
		    walk( o );
		    // } else {
		    // IO.Std.err.println( "null" );
		}
		p = p + 1;
		
		l = l - 1;
	    }
	}
    }   
}