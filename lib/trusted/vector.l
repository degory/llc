import object;
import exception;
import iterator;



namespace Util {
    pragma NoWarnUnsafe, NoMarkUnsafe;
    class VectorIterator extends Iterator {

	private Vector _v;
	private int _i;
 
	void init( Vector v ) {
	    super.init();
	    _v = v;
	    _i = 0;
	}

	bool hasMoreElements() {
	    return _i < _v.Length;
	}

	System.Object nextElement() {
	    System.Object result;
	    result = _v[_i];
	
	    _i = _i + 1;

	    return result;
	}
    }

    class VectorReverseIterator extends Iterator {
	private Vector _v;
	private int _i;

	void init( Vector v ) {
	    super.init();
	    _v = v;
	    _i = v.Length - 1;
	}

	bool hasMoreElements() {
	    return _i >= 0;
	}

	System.Object nextElement() {
	    System.Object result;
	    result = _v[_i];
	
	    _i = _i - 1;

	    return result;
	}
    }

    class VectorException extends System.Exception {
	pragma NoWarnHide;

	Vector vector;
	int index;
	void init( System.String message, Vector vector, int index ) {
	    super.init( message );
	    this.vector = vector;
	    this.index = index;
	}

	get Vector Vector {
	    return vector;
	}

	get int Index {
	    return index;
	}
    }

    class Vector extends System.Object {
	private int _length;
	private int _allocated_length;
	private System.Object ptr _values;

	private const int DEFAULT_SIZE = 5;
    
	void init( int l ) {
	    super.init();
	    _length = 0;
	    _allocated_length = 0;
	    _values = cast<System.Object ptr>(0);
	    reserve( l );
	}

	void init() {
	    init( DEFAULT_SIZE );
	}
    

	get int Length {
	    return _length;
	}

	void add( System.Object o ) {
	    reserve( _length + 1 );
	    // native.printf( `%p len %d vector add %d\n`, _values, _allocated_length, _length + 1 );
	    [_values + _length] = o;
	    _length = _length + 1;
	}

	System.Object pop() { 
	    if( _length > 0 ) {
		System.Object result = [_values + _length - 1];
		_length = _length - 1;
		return result;
	    } else {
		throw new VectorException( "Vector.pop() performed on empty Vector", this, 0 );
	    }
        }

	get System.Object Top {
	    if( _length > 0 ) {
		return [_values + _length - 1];
	    } else {
		throw new VectorException( "get System.Object Vector.Top performed on empty Vector", this, 0 );
	    }
	}

	set System.Object Top = o {
	    if( _length > 0 ) {
		// native.printf( `%p len %d vector set top %d\n`, _values, _allocated_length, _length - 1 );
		[_values + _length - 1] = o;
	    } else {
		throw new VectorException( "set System.Object Vector.Top performed on empty Vector", this, 0 );
	    }
	}

	void putTop( System.Object o ) {
	    Top = o;
	}

	get System.Object[int i] {
	    if( i >= 0 && i < _length ) {
		return [_values + i];
	    } else {
		throw new VectorException( "get Vector[] outside Vector bounds", this, i );
		return null;
	    }
	}

	/*
	System.Object get( int i ) {
	    return opGet(i);
	}
	*/

	set System.Object[int i] = o {
	    if( i < 0 ) {
		throw new VectorException( "set Vector[] outside Vector bounds", this, i );
	    }

	    reserve( i + 1 );
	    //  native.printf( `%p len %d vector set %d\n`, _values, _allocated_length, i );
	    [_values + i] = o;
	    if( i >= _length ) {
		_length = i + 1;
	    }
	}

	void put( int i, System.Object o ) {
	    opSet( i, o );
	}
    
	Iterator elements() {
	    return new VectorIterator( this );
	
	}

	Iterator reverseElements() {
	    return new VectorReverseIterator( this );
	}

	void setLength( int l ) {
	    reserve(l);
	    _length = l;
	}

	void lengthen( int l ) {
	    reserve(l);
	    if( l > _length ) {
		_length = l;
	    }
	}

	void reserve( int l ) {
	    int i;
	    System.Object ptr new_values;
	    if( l > _allocated_length ) {
		if( l > 1000000 ) {
		    native.printf( `very long vector allocation %s\n`, new System.Backtrace().toCString() );
		    native.__flush_stdout();
		}
		l = l * 2;
		_allocated_length = l;

		// new_values = cast<System.Object ptr>(native.GC_debug_malloc( l * 4 ));
		new_values = cast<System.Object ptr>(native.GC_malloc( l * System.Environment.WORD_BYTES ));
		// native.printf( `%p len %d vector\n`, new_values, l * System.Environment.WORD_BYTES );

		if( _values != null ) {
		    i = 0;
		    while( i < _length ) {
			[new_values + i] = [_values + i];
			i = i + 1;
		    }
		
		    while( i < l ) {
			[new_values + i] = null;
			i = i + 1;
		    }
		}
	    
		_values = new_values;
	    

	    }
	}

	Vector copy() {
	    Vector result = cast<Vector>(clone());
	    result.completeCopy();
	    return result;
	}

	void completeCopy() {
	    System.Object ptr v = cast<System.Object ptr>(native.GC_malloc( _allocated_length * System.Environment.WORD_BYTES ));
	    // native.printf( `%p len %d vector copy\n`, v, _allocated_length * _allocated_length * System.Environment.WORD_BYTES );
	    for( int i = 0; i < _allocated_length; i = i + 1 ) {
		[v + i] = [_values + i];
	    }
	    _values = v;
	}

	System.String toString() {
	    System.StringBuffer result;
	    if( _length > 0 ) {
		result = new System.StringBuffer( "[Vector: " );
	    } else {
		return "[Vector]";
	    }

	    for( int i = 0; i < _length; i = i + 1 ) {
		System.Object o = [_values+i];
		if( o == null ) {
		    result.append( "null" );
		} else {
		    result.append( o );
		}
		if( i < _length - 1 ) {
		    result.append( ',' );
		}
	    }

	    result.append(']');

	    return result;
	}
    }
}
