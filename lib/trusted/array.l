#K

import object;
import glist;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System is
    /// Values of native array types (type[]) can be cast or boxed to Array 
    class Array is
	int length;
        word values;
    end
end

namespace Generic is
    /// Values of native array types (type[]) can be cast or boxed to Array 
    class Array<T> implements List<T> is
	int length;
        T ptr values;

	void init() is
	end

	get T[int index] is
	    return cast T[](this)[index];
	end

	set T[int index] = v is
	    cast T[](this)[index] = v;
        end

	get List<T> List is
	    return cast List<T>(this);
	end

	get int Length is
	    return length;
	end

	void add( T v ) is
	    throw new System.NotImplementedException( "Generic.Array is fixed length" );
	end

	void remove( T v ) is
	    throw new System.NotImplementedException( "Generic.Array is fixed length" );
        end

	void lengthen( int l ) is
	    if l > length then
		throw new System.NotImplementedException( "Generic.Array is fixed length" );
	    fi
	end


	bool contains( T v ) is
	    for int i = 0; i < length; i = i + 1 do
	        if cast T[](this)[i] == v then
		    return true;
		fi
	    od

	    return false;
	end

	bool isEmpty() is
	    return length > 0;
	end

	ArrayIterator<T> elements() is
	    return new ArrayIterator<T>(cast T[](this));
	end
    end

    class ArrayIterator<T> implements Iterator<T> is
        T[] values;
	int index;

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
end
