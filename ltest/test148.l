#K

import stream;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace Test148 is
    class Iterator<T> is
	bool hasMoreElements() is
	end

	T nextElement() is
	end
    end


    class List<T> is
        void add(T v) is
	end

	Iterator<T> elements() is
	end
    end

    class VectorIterator<T> extends System.Object implements Iterator<T> is
	private Vector<T> _v;
	private int _i;
 
	void init( Vector<T> v ) is
	    super.init();
	    _v = v;
	    _i = 0;
	end

	bool hasMoreElements() is
	    // IO.Std.err.println( this.Class.Name + ": has more index: " + _i + " versus length: " + _v.getLength() );
	    return _i < _v.getLength();
	end

	T nextElement() is
	    T result;
	    // IO.Std.err.println( this.Class.Name + ": calling op get index: " + _i );
	    result = _v.opGet( _i );
	
	    _i = _i + 1;

	    return result;
	end
    end

    class VectorReverseIterator<T> extends System.Object implements Iterator<T> is
	private Vector<T> _v;
	private int _i;

	void init( Vector<T> v ) is
	    super.init();
	    _v = v;
	    _i = v.getLength() - 1;
	end

	bool hasMoreElements() is
	    return _i >= 0;
	end

	T nextElement() is
	    T result;
	    result = _v[_i];
	
	    _i = _i - 1;

	    return result;
	end
    end

    class VectorException extends System.Exception is
	void init( System.String message ) is
	    super.init( message );
	end
    end

    class Vector<T> extends System.Object implements List<T> is
	private int _length;
	private int _allocated_length;
	private T ptr _values;

	private const int DEFAULT_SIZE = 5;
    
	void init( int l ) is
	    super.init();

	    // IO.Std.err.println( this.Class.Name + ": new vector length " + l );

	    _length = 0;
	    _allocated_length = 0;
	    _values = null;
	    reserve( l );
	end

	void init() is
	    init( DEFAULT_SIZE );
	end

	get int Length is
	    return _length;
	end

	void add( T o ) is
	    reserve( _length + 1 );
	    [_values + _length] = o;
	    _length = _length + 1;
	end

	T pop() is
	    if _length > 0 then
		T result = [_values + _length - 1];
		_length = _length - 1;
		return result;
	    else
		throw new VectorException( "Vector.pop() performed on empty Vector" ); 
	    fi
        end

	get T Top is
	    if _length > 0 then
		return [_values + _length - 1];
	    else
		throw new VectorException( "Vector.top() performed on empty Vector" ); 
	    fi
	end

	get T[] Array is
	    T[] result = new T[_length];
	    for int i = 0; i < _length; i = i + 1 do
		result[i] = [_values + i];
	    od
	    return result;
	end

	set T Top = o is
	    if _length > 0 then
		[_values + _length - 1] = o;
	    else
		throw new VectorException( "Vector.putTop() performed on empty Vector" );
	    fi
	end

	void putTop( T o ) is
	    Top = o;
	end

	// indexed property get - allows ... some_vector[i] ...
	get T[int i] is
	    if i >= 0 && i < _length then
		// IO.Std.err.println( this.Class.Name + ": getting element index: " + i + " [[" + [_values + i] + "]]" );
		return [_values + i];
	    else
		throw new VectorException( "Vector.get() outside Vector bounds" );
		return null;
	    fi
	end

	// indexed property set - allows some_vector[i] = ....
	set T[int i] = o is
	    if i < 0 then
		throw new VectorException( "Vector.put() outside Vector bounds" );
	    fi

	    reserve( i + 1 );
	    [_values + i] = o;

	    // IO.Std.err.println( this.Class.Name + ": set element index: " + i + " [[" + [_values + i] + "]]" );
	    if i >= _length then
		_length = i + 1;
	    fi
	end

	T removeIndex( int i ) is
	    if i < 0 || i >= _length then
		throw new VectorException( "Vector.remove() outside Vector bounds" );
	    fi

	    T result = [_values + i];

	    while i < _length do
		[_values + i] = [_values + i + 1];
		i = i + 1;
	    od

	    _length = _length - 1;

	    return result;
	end

	T pull() is
	    return removeIndex(0);
	end

	VectorIterator<T> elements() is
	    return new VectorIterator<T>( this );
	end

	VectorReverseIterator<T> reverseElements() is
	    return new VectorReverseIterator<T>( this );
	end

	set int Length = l is
	    reserve(l);
	    _length = l;
	end

	void lengthen( int l ) is
	    reserve(l);
	    if l > _length then
		_length = l;
	    fi
	end

	void reserve( int l ) is
	    int i;
	    T ptr new_values;
	    if l > _allocated_length then
		if l > 1000000 then
		    native.printf( `very long vector allocation %d %s\n`, l, new System.Backtrace().toCString() );
		    native.__flush_stdout();
		fi

		l = l * 2;
		// new_values = cast System.Object ptr(native.GC_debug_malloc( l * 4 ));

		// IO.Std.err.println( this.Class.Name + ": reserve: " + l + " -> allocate: " + (l * T.sizeof) );

		new_values = cast T ptr(native.GC_malloc( l * T.sizeof ));
		// native.printf( `%p len %d gvector\n`, new_values, l * T.sizeof );

		if _values != null then
		    i = 0;
		    while i < _length do
			[new_values + i] = [_values + i];
			i = i + 1;
		    od
		
		    while i < l do
			[new_values + i] = null;
			i = i + 1;
		    od
		fi
	    
		_values = new_values;
	    
		_allocated_length = l;
	    fi
	end

	Vector<T> copy() is
	    Vector<T> result = cast Vector<T>(clone());
	    result.completeCopy();
	    return result;
	end

	void completeCopy() is
	    T ptr v = cast T ptr(native.GC_malloc( _allocated_length * T.sizeof ));
	    // native.printf( `%p len %d gvector copy\n`, v, _allocated_length * T.sizeof );
	    for int i = 0; i < _allocated_length; i = i + 1 do
		[v + 1] = [_values + 1];
	    od
	    _values = v;
	end

	System.String toString() is
	    System.StringBuffer result;
	    if _length > 0 then
		result = new System.StringBuffer( "[Vector: " );
	    else
		return "[Vector]";
	    fi

	    for int i = 0; i < _length; i = i + 1 do
		T o = [_values+i];
		result.append( o );

		if i < _length - 1 then
		    result.append( ',' );
		fi
	    od

	    result.append(']');

	    return result;
	end
    end

    class Main is
        void init() is 
	    List<int> t = new Vector<int>();

	    int i;
	    for i = 0; i < 10; i = i + 1 do
	      	t.add(i);  
	    od

	    foreach int j; t.elements() do
	        IO.Std.err.println( "have: " + j );
	    od
	end
    end
end

