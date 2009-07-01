#K

pragma NoWarnUnsafe, NoMarkUnsafe;

import giterator;
import glist;

namespace Generic is
    use System.String;
    use System.StringBuffer;
    use System.Object;
    use System.Exception;
    use System.Backtrace;

    /// An Iterator over Vector<T>
    class VectorIterator<T> extends Object implements Iterator<T> is
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

    /// A reverse Iterator over Vector<T>
    class VectorReverseIterator<T> extends Object implements Iterator<T> is
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

    /// Thrown for out of bounds Vector<T> indexes 
    class VectorException extends Exception is
	void init( String message ) is
	    super.init( message );
	end
    end
    
    /// A resizeable array of parameterised type.  
    class Vector<T> extends Object implements List<T> is
	private int _length;
	private int _allocated_length;
	private T ptr _values;

	private const int DEFAULT_SIZE = 5;

	/// Construct a new Vector with enough space for at least l values
	/// \param l initial capactity     
	void init( int l ) is
	    super.init();

	    // IO.Std.err.println( this.Class.Name + ": new vector length " + l );

	    _length = 0;
	    _allocated_length = 0;
	    _values = null;
	    reserve( l );
	end

	/// Construct a new Vector with default initial capacity
	void init() is
	    init( DEFAULT_SIZE );
	end

	get int Length is
	    return _length;
	end

	/// Append a new value to the end of this Vector immediately after the current last element
	void add( T o ) is
	    reserve( _length + 1 );
	    [_values + _length] = o;
	    _length = _length + 1;
	end

	/// Remove and return the current last value from the end of this Vector
	T pop() is
	    if _length > 0 then
		T result = [_values + _length - 1];
		_length = _length - 1;
		return result;
	    else
		throw new VectorException( "Vector.pop() performed on empty Vector" ); 
	    fi
        end

	/// Return the current last value of this Vector
	get T Top is
	    if _length > 0 then
		return [_values + _length - 1];
	    else
		throw new VectorException( "Vector.top() performed on empty Vector" ); 
	    fi
	end

	/// Return a copy of this Vector as an array 
	get T[] Array is
	    T[] result = new T[_length];
	    for int i = 0; i < _length; i = i + 1 do
		result[i] = [_values + i];
	    od
	    return result;
	end

	/// Replace the current last value of this Vector with the supplied value
	/// \param o the new last value to set
	set T Top = o is
	    if _length > 0 then
		[_values + _length - 1] = o;
	    else
		throw new VectorException( "Vector.putTop() performed on empty Vector" );
	    fi
	end

	/// Replace the current last value of this Vector with the supplied value
	/// \param o the new last value to set
	/// deprecated use accessor String.Top (\see String.setTop(T))
	void putTop( T o ) is
	    Top = o;
	end

	/// Indexed get. Allows use of array subscript syntax on this Vector
	/// \param i index of the value to get
	get T[int i] is
	    if i >= 0 && i < _length then
		// IO.Std.err.println( this.Class.Name + ": getting element index: " + i + " [[" + [_values + i] + "]]" );
		return [_values + i];
	    else
		throw new VectorException( "Vector.get() outside Vector bounds" );
		return null;
	    fi
	end

	/// Indexed set. Allows use of array subscript syntax on this Vector
	/// \param i index of the value to set
	/// \param o value to set
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

	/// Return the index of the first element in this Vector with supplied value. Return -1 if no
	/// matching value found
	/// \param v value to search for
	int indexOf( T v ) is
	    for int i = 0; i < _length; i = i + 1 do
	        if [_values + i] == v then
		    return i;
		fi
	    od

	    return -1;
	end

	/// Return true if this Vector contains no values, otherwise return false
        bool isEmpty() is
	    return _length == 0;
	end

	/// Return true if the supplied value appears at least once in this Vector, otherwise return false
	bool contains( T v ) is
	    return indexOf(v) >= 0;
	end

	/// If the supplied value appears in this Vector then remove the first instance of it, otherwise do nothing
	void remove( T v ) is
	    int i = indexOf(v);
	    if i >= 0 then
	        removeIndex(i);
	    fi
	end

	/// Remove the value at the supplied index, shifting any later values left one place to close the gap
	/// \param i the index of the value to remove
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
	
	/// Remove and return the first value in this Vector
	T pull() is
	    return removeIndex(0);
	end

	/// Return a new Iterator that returns each element in the Vector from first to last in turn. Behaviour is undefined if the Vector is altered
	/// before Iterator<T>.nextElement() returns false 
	VectorIterator<T> elements() is
	    return new VectorIterator<T>( this );
	end

	/// Return a new Iterator that returns each element in the Vector from last to first in turn. Behaviour is undefined if the Vector is altered
	/// before Iterator<T>.nextElement() returns false 
	VectorReverseIterator<T> reverseElements() is
	    return new VectorReverseIterator<T>( this );
	end

	/// Set the length of this Vector to the supplied value. If the new length is shorter than the exisiting length then values beyond the new last
	/// value are discarded as if they had been removed with Vector<T>.remove(T). If the new length is longer than the existing length then the new
	/// values are populated as if they had been added with Vector<T>.add(T.none)
	set int Length = l is
	    reserve(l);
	    _length = l;
	end

	/// Remove all elements in this Vector making new length equal to zero
        void clear() is
	    Length = 0;
	end

	/// if supplied length is longer than the existing length then set length to the supplied length, filling new values with T.none, otherwise, if
	/// supplied length is equal to or shorter than existing length, then do nothing
	void lengthen( int l ) is
	    reserve(l);
	    if l > _length then
		_length = l;
	    fi
	end

	/// if supplied length is longer than the existing capacity then allocate additional space so that the total capacity is at least l values.
	/// Note reserve(int) does not affect length, just the reserved capacity that enables values to be added with allocating additional memory
	void reserve( int l ) is
	    int i;
	    T ptr new_values;
	    if l > _allocated_length then
		if l > 1000000 then
		    native.printf( `very long vector allocation %d %s\n`, l, new Backtrace().toCString() );
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

	/// Return a copy of this Vector
	Vector<T> copy() is
	    Vector<T> result = cast Vector<T>(clone());
	    result.completeCopy();
	    return result;
	end

	/// Internal method supporting copy()
	void completeCopy() is
	    T ptr v = cast T ptr(native.GC_malloc( _allocated_length * T.sizeof ));
	    // native.printf( `%p len %d gvector copy\n`, v, _allocated_length * T.sizeof );
	    for int i = 0; i < _allocated_length; i = i + 1 do
		[v + 1] = [_values + 1];
	    od
	    _values = v;
	end

	String toString() is
	    StringBuffer result;
	    if _length > 0 then
		result = new StringBuffer( "[Vector: " );
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
end

