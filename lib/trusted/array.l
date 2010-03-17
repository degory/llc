#K

import object;
import glist;

pragma NoWarnUnsafe, NoMarkUnsafe, NoWarnHide;

namespace System is
    /// Original non-generic array class.
    /// \deprecated required by older versions of the compiler
    /// \see Generic.Array<T>
    class Array is
	int length;
        word values;
    end
end

namespace Generic is
    use System.Object;
    use System.String;
    use System.StringBuffer;
    /// Native arrays can be converted to and from specializations of this template class.
    /// Arrays are fixed length and bounds checked with valid indexes of 0 - length-1 inclusive. 
    /// \param T element type of the array
    class Array<T> implements List<T> is
	int length;

	/// indexer: get T[int index]
        /// \param index which array element to get
	/// \return array element at index
	/// \throw System.BoundsException if index is negative or greater than or equal to length
	get T[int index] is
	    return cast T[](this)[index];
	end

	/// indexer: set T[int index] = v
        /// \param index which array element to set
	/// \param v value to place in array at index
	/// \throw System.BoundsException if index is negative or greater than or equal to length
	set T[int index] = v is
	    cast T[](this)[index] = v;
        end

	/// accessor: get List<T> List
	/// \return this array as a List<T> interface
	get List<T> List is
	    return cast List<T>(this);
	end

	/// accessor: get int Length
	/// \return the number of values in this array
	get int Length is
	    return length;
	end

	/// accessor: get int ValueSize
	/// \return the size of each value in this array
	get int ValueSize is
	    return T.sizeof;
	end

	/// \attention not implemented
        /// \throw System.NotImplementedException
	void add( T v ) is
	    throw new System.NotImplementedException( "Generic.Array is fixed length" );
	end

	/// \attention: not implemented
        /// \throw System.NotImplementedException
	void add( Iterable<T> v ) is
	    throw new System.NotImplementedException( "Generic.Array is fixed length" );
	end

	/// \attention not implemented
        /// \throw System.NotImplementedException
	void remove( T v ) is
	    throw new System.NotImplementedException( "Generic.Array is fixed length" );
        end

	/// \attention partially implemented
        /// \throw System.NotImplementedException
	void lengthen( int l ) is
	    if l > length then
		throw new System.NotImplementedException( "Generic.Array is fixed length" );
	    fi
	end

	String toString() is
            var result = new StringBuffer();
            for int i = 0; i < length; i = i + 1 do
               if i != 0 then
	           result.append(',');			
               fi
 	       result.append(this[i].toString());
	    od

            return result;
        end

        /// \attention: checks reference equality only for reference types
	bool contains( T v ) is
	    for int i = 0; i < length; i = i + 1 do
 		if cast T[](this)[i] =~ v then
		    return true;
		fi
	    od

	    return false;
	end

	bool isEmpty() is
	    return length == 0;
	end

	/// accessor: get ArrayIterator<T> Iterator
        /// Return an ArrayIterator<T> over this array
        /// \return an ArrayIterator<T> that returns each element of this array in increasing index order
	get ArrayIterator<T> Iterator is
	    return new ArrayIterator<T>(cast T[](this));	    
	end

        /// Return an ArrayIterator<T> over this array
        /// \return an ArrayIterator<T> that returns each element of this array in increasing index order
	ArrayIterator<T> elements() is
	    return new ArrayIterator<T>(cast T[](this));
	end

	get T ptr Address is
	    return cast T ptr(cast word(this) + 16w);
        end

	get Object ptr ObjectValuesPointer is
	    if !T.isobject then
		return null;
            fi

	    return cast Object ptr(this) + 2;
	end

	get int ObjectValuesLength is
	    return length;
	end

	get int MemoryUse is 
	    return System.Environment.WORD_BYTES * 3 + T.sizeof * Length;
	end

/*
	String toString() is
            var result = new StringBuffer();
            for int i = 0; i < length; i = i + 1 do
 	        if i > 0 then
		    result.append(',');
                fi
                if this[i] != T.none then
		    result.append(this[i].toString());
		fi		    
	    od
        end
*/
	get bool IsArray is
	    return true;
        end

	ArrayRange<T> range(int from, int to) is
	    return new ArrayRange<T>(this, from, to); 
	end	   

	get ArrayRange<T>[System.RangeIterator<int> r] is
	    return new ArrayRange<T>(this, r.from, r.to);
	end
    end

    /// an Iterator<T> that returns each element of an array in increasing index order
    class ArrayIterator<T> implements Iterator<T> is
        T[] values;
	int index;

	/// Construct a new ArrayIterator<T> over an array
	/// \param values the array to iterate over
	void init( T[] values ) is
	    this.values = values;
	end

	bool hasMoreElements() is
	    return index < values.length;
	end

	T nextElement() is
	    T result = values[index];
	    index = index + 1;
	    return result;
	end
    end

    class ArrayRange<T> implements List<T>, Iterator<T> is
        T[] a;
        int i;
	int from, to;

	void init( T[] a, int from, int to ) is
	    this.a = a;
            i = from;
	    this.from = from;
	    this.to = to;
	end

	bool hasMoreElements() is
	    return i <= to;
	end

	T nextElement() is
	    T result = a[i];
	    i = i + 1;
	    return result;
	end

	get T[int index] is 
	    return a[from + index];
	end

	set T[int index] = v is
	    _read_only();
	end

	void _read_only() is 
	    throw new System.NotImplementedException( Class.Name + " is read only" );
	end

	/// accessor: get int Length
	/// \return the number of values in this array
	get int Length is
	    return from - to;
	end

	/// \attention: not implemented
        /// \throw System.NotImplementedException
	void add( T v ) is
	    _read_only();
	end

	/// \attention: not implemented
        /// \throw System.NotImplementedException
	void add( Iterable<T> v ) is
	    _read_only();
	end

	/// \attention: not implemented
        /// \throw System.NotImplementedException
	void remove( T v ) is
	    _read_only();
	    throw new System.NotImplementedException( Class.Name + "Generic.Array is fixed length" );
        end

	/// \attention: partially implemented
        /// \throw System.NotImplementedException
	void lengthen( int l ) is
	    if l > Length then
	        _read_only();
	    fi
	end

	String toString() is
            var result = new StringBuffer();
            for int i = from; i <= to; i = i + 1 do
               if i != 0 then
	           result.append(',');			
               fi
 	       result.append(this[i].toString());
	    od

            return result;
        end

        /// \attention: checks reference equality only for reference types
	bool contains( T v ) is
	    for int i = from; i <= to; i = i + 1 do
 		if cast T[](this)[i] =~ v then
		    return true;
		fi
	    od

	    return false;
	end

	bool isEmpty() is
	    return Length > 0;
	end

	get ArrayRange<T> Iterator is
	    return new ArrayRange<T>(a, from, to);
	end

	ArrayRange<T> elements() is
	    return new ArrayRange<T>(a, from, to);
	end

    end	
end
