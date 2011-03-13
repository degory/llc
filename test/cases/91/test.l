#C
import stream;

namespace Generic {
    class Iterator<T>  extends System.Object {
	void init() {
	    super.init();
	}

	bool hasMoreElements() {
	}

	T nextElement() {
	}
    }

    class VectorIterator<T> extends Iterator<T> {
	private Vector<T> _v;
	private int _i;
 
	void init( Vector<T> v ) {
	    super.init();
	    _v = v;
	    _i = 0;
	}

	bool hasMoreElements() {
	    return _i < _v.getLength();
	}

	T nextElement() {
	    T result;
	    result = _v.opGet( _i );
	
	    _i = _i + 1;

	    return result;
	}
    }

    class VectorReverseIterator<T> extends Iterator<T> {
	private Vector<T> _v;
	private int _i;

	void init( Vector<T> v ) {
	    super.init();
	    _v = v;
	    _i = v.getLength() - 1;
	}

	bool hasMoreElements() {
	    return _i >= 0;
	}

	T nextElement() {
	    T result;
	    result = _v.opGet( _i );
	
	    _i = _i - 1;

	    return result;
	}
    }

    class VectorException extends System.Exception {
	void init( System.String message ) {
	    super.init( message );
	}
    }

    class Vector<T> extends System.Object {
	private int _length;
	private int _allocated_length;
	private T ptr _values;

	private const int DEFAULT_SIZE = 5;
    
	void init( int l ) {
	    super.init();
	    _length = 0;
	    _allocated_length = 0;
	    _values = null;
	    reserve( l );
	}

	void init() {
	    init( DEFAULT_SIZE );
	}
    

	int getLength() {
	    return _length;
	}

	void add( T o ) {
	    reserve( _length + 1 );
	    [_values + _length] = o;
	    _length = _length + 1;
	}

	T pop() { 
	    if( _length > 0 ) {
		T result = [_values + _length - 1];
		_length = _length - 1;
		return result;
	    } else {
		throw new VectorException( "Vector.pop() performed on empty Vector" ); 
	    }
        }

	T getTop() {
	    if( _length > 0 ) {
		return [_values + _length - 1];
	    } else {
		throw new VectorException( "Vector.top() performed on empty Vector" ); 
	    }
	}

	void setTop( T o ) {
	    if( _length > 0 ) {
		[_values + _length - 1] = o;
	    } else {
		throw new VectorException( "Vector.putTop() performed on empty Vector" );
	    }
	}

	void putTop( T o ) {
	    Top = o;
	}

	T opGet( int i ) {
	    if( i >= 0 && i < _length ) {
		return [_values + i];
	    } else {
		throw new VectorException( "Vector.get() outside Vector bounds" );
		return null;
	    }
	}

	T get( int i ) {
	    return opGet(i);
	}

	void opSet( int i, T o ) {
	    if( i < 0 ) {
		throw new VectorException( "Vector.put() outside Vector bounds" );
	    }

	    reserve( i + 1 );
	    [_values + i] = o;
	    if( i >= _length ) {
		_length = i + 1;
	    }
	}

	void put( int i, T t ) {
	    opSet( i, t );
	}
    
	Iterator<T> elements() {
	    return new VectorIterator<T>( this );
	
	}

	Iterator<T>  reverseElements() {
	    return new VectorReverseIterator<T>( this );
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
	    T ptr new_values;
	    if( l > _allocated_length ) {
		if( l > 1000000 ) {
		    native.printf( `very long vector allocation %s\n`, new System.Backtrace().toCString() );
		    native.__flush_stdout();
		}
		// new_values = cast<System.Object ptr>(native.GC_debug_malloc( l * 4 ));

		int t = T.sizeof;
		if( t == 8 ) {
		    new_values = cast T ptr(native.GC_malloc_ignore_off_page( l * 8 ));
		} else {
		    new_values = cast T ptr(native.GC_malloc_atomic_ignore_off_page( l * t ));
		}

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
	    
		_allocated_length = l;
	    }
	}

	Vector<T> copy() {
	    Vector<T> result = cast Vector<T>(clone());
	    result.completeCopy();
	    return result;
	}

	void completeCopy() {
	    T ptr v = cast T ptr(native.GC_malloc_ignore_off_page( _allocated_length * 8 ));
	    for( int i = 0; i < _allocated_length; i = i + 1 ) {
		[v + 1] = [_values + 1];
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
		T o = [_values+i];
		result.append( o );

		if( i < _length - 1 ) {
		    result.append( ',' );
		}
	    }

	    result.append(']');

	    return result;
	}
    }
}


namespace Test91 {
    class Main {
	void init() {
	    Vector<System.String> v = new Vector<System.String>();

	    v.add( "Hello" );
	    v.add( " " );
	    v.add( "world" );
	    v.add( "!" );
	    v.add( "\n" );

	    for(
		Iterator<System.String> i = v.elements();
		i.hasMoreElements();
		) {
		System.String s = i.nextElement();	       

		IO.Std.err.print( s );
	    }
	}
    }

    class Iterator<T>  extends System.Object {
	void init() {
	    super.init();
	}

	bool hasMoreElements() {
	}

	T nextElement() {
	}
    }

    class VectorIterator<T> extends Iterator<T> {
	private Vector<T> _v;
	private int _i;
 
	void init( Vector<T> v ) {
	    super.init();
	    _v = v;
	    _i = 0;
	}

	bool hasMoreElements() {
	    return _i < _v.getLength();
	}

	T nextElement() {
	    T result;
	    result = _v.opGet( _i );
	
	    _i = _i + 1;

	    return result;
	}
    }

    class VectorReverseIterator<T> extends Iterator<T> {
	private Vector<T> _v;
	private int _i;

	void init( Vector<T> v ) {
	    super.init();
	    _v = v;
	    _i = v.getLength() - 1;
	}

	bool hasMoreElements() {
	    return _i >= 0;
	}

	T nextElement() {
	    T result;
	    result = _v.opGet( _i );
	
	    _i = _i - 1;

	    return result;
	}
    }

    class VectorException extends System.Exception {
	void init( System.String message ) {
	    super.init( message );
	}
    }

    class Vector<T> extends System.Object {
	private int _length;
	private int _allocated_length;
	private T ptr _values;

	private const int DEFAULT_SIZE = 5;
    
	void init( int l ) {
	    super.init();
	    _length = 0;
	    _allocated_length = 0;
	    _values = null;
	    reserve( l );
	}

	void init() {
	    init( DEFAULT_SIZE );
	}
    

	int getLength() {
	    return _length;
	}

	void add( T o ) {
	    reserve( _length + 1 );
	    [_values + _length] = o;
	    _length = _length + 1;
	}

	T pop() { 
	    if( _length > 0 ) {
		T result = [_values + _length - 1];
		_length = _length - 1;
		return result;
	    } else {
		throw new VectorException( "Vector.pop() performed on empty Vector" ); 
	    }
        }

	T getTop() {
	    if( _length > 0 ) {
		return [_values + _length - 1];
	    } else {
		throw new VectorException( "Vector.top() performed on empty Vector" ); 
	    }
	}

	void setTop( T o ) {
	    if( _length > 0 ) {
		[_values + _length - 1] = o;
	    } else {
		throw new VectorException( "Vector.putTop() performed on empty Vector" );
	    }
	}

	void putTop( T o ) {
	    Top = o;
	}

	T opGet( int i ) {
	    if( i >= 0 && i < _length ) {
		return [_values + i];
	    } else {
		throw new VectorException( "Vector.get() outside Vector bounds" );
		return null;
	    }
	}

	T get( int i ) {
	    return opGet(i);
	}

	void opSet( int i, T o ) {
	    if( i < 0 ) {
		throw new VectorException( "Vector.put() outside Vector bounds" );
	    }

	    reserve( i + 1 );
	    [_values + i] = o;
	    if( i >= _length ) {
		_length = i + 1;
	    }
	}

	void put( int i, T t ) {
	    opSet( i, t );
	}
    
	Iterator<T> elements() {
	    return new VectorIterator<T>( this );
	
	}

	Iterator<T> reverseElements() {
	    return new VectorReverseIterator<T>( this );
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
	    T ptr new_values;
	    if( l > _allocated_length ) {
		if( l > 1000000 ) {
		    native.printf( `very long vector allocation %s\n`, new System.Backtrace().toCString() );
		    native.__flush_stdout();
		}
		// new_values = cast<System.Object ptr>(native.GC_debug_malloc( l * 4 ));

		int t = T.sizeof;
		if( t == 8 ) {
		    new_values = cast T ptr(native.GC_malloc_ignore_off_page( l * 8 ));
		} else {
		    new_values = cast T ptr(native.GC_malloc_atomic_ignore_off_page( l * t ));
		}

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
	    
		_allocated_length = l;
	    }
	}

	Vector<T> copy() {
	    Vector<T> result = cast Vector<T>(clone());
	    result.completeCopy();
	    return result;
	}

	void completeCopy() {
	    T ptr v = cast T ptr(native.GC_malloc_ignore_off_page( _allocated_length * 8 ));
	    for( int i = 0; i < _allocated_length; i = i + 1 ) {
		[v + 1] = [_values + 1];
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
		T o = [_values+i];
		result.append( o );

		if( i < _length - 1 ) {
		    result.append( ',' );
		}
	    }

	    result.append(']');

	    return result;
	}
    }
}
