#K

import object;
import exception;
// import iterator;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace Util is
    class IntVectorException extends System.Exception is
	IntVector vector;
	int index;
	void init( System.String message, IntVector vector, int index ) is
	    super.init( message );
	    this.vector = vector;
	    this.index = index;
	end

	get IntVector Vector is
	    return vector;
	end

	get int Index is
	    return index;
	end
    end


    class IntVector extends System.Object is
	private int _length;
	private int _allocated_length;
	private int ptr _values;

	private const int DEFAULT_SIZE = 5;
    
	void init( int l ) is
	    super.init();
	    reserve( l );
	end

	void init() is
	    init( DEFAULT_SIZE );
	end
    
	get int Length is
	    return _length;
	end

	void add( int o ) is
	    reserve( _length + 1 );
	    [_values + _length] = o;
	    _length = _length + 1;
	end

	int pop() is
	    if _length > 0 then
		int result = [_values + _length - 1];
		_length = _length - 1;
		return result;
	    else
		throw new IntVectorException( "IntVector.pop() performed on empty IntVector", this, 0 );
	    fi
        end

	get int Top is
	    if _length > 0 then
		return [_values + _length - 1];
	    else
		throw new IntVectorException( "IntVector.top() performed on empty IntVector", this, 0 );
	    fi
	end

	set int Top = o is
	    if _length > 0 then
		[_values + _length - 1] = o;
	    else
		throw new IntVectorException( "IntVector.putTop() performed on empty IntVector", this, 0 );
	    fi
	end

	get int[int i] is
	    if i >= 0 && i < _length then
		return [_values + i];
	    else
		throw new IntVectorException( "IntVector.get() outside IntVector bounds", this, i );
		return null;
	    fi
	end

	set int[int i] = o is
	    if i < 0 then
		throw new IntVectorException( "IntVector.put() outside IntVector bounds", this, i );
	    fi

	    reserve( i + 1 );
	    [_values + i] = o;
	    if i >= _length then
		_length = i + 1;
	    fi
	end

	/*    
	Iterator elements() {
	    return new IntVectorIterator( this );
	
	}

	Iterator reverseElements() {
	    return new IntVectorReverseIterator( this );
	}
	*/

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
	    int ptr new_values;
	    if l > _allocated_length then
		l = l * 2;
		// new_values = cast System.Object ptr(native.GC_debug_malloc( l * 4 ));
		new_values = cast int ptr(native.GC_malloc_atomic( l * System.Environment.INT_BYTES ));
		// native.printf( `%p len %d intvector\n`, new_values, l );
	    
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

	System.String toString() is
	    System.StringBuffer result;
	    if _length > 0 then
		result = new System.StringBuffer( "[IntVector: " );
	    else
		return "[IntVector]";
	    fi

	    for int i = 0; i < _length; i = i + 1 do
		int o = [_values+i];
		result.append( o );

		if i < _length - 1 then
		    result.append( ',' );
		fi
	    od

	    result.append(']');

	    return result;
	end

	get int[] Array is
	    int[] result = new int[_length];

	    for int i = 0; i < _length; i = i + 1 do
		[result.address + i] = [_values+i];
	    od

	    return result;
	end

	IntVector copy() is
	    IntVector result = cast IntVector(clone());
	    result.completeCopy();
	    return result;
	end

	void completeCopy() is
	    int ptr v = cast int ptr(native.GC_malloc_atomic( _allocated_length * System.Environment.WORD_BYTES ));
	    // native.printf( `%p len %d intvector copy\n`, v, _allocated_length );
	    for int i = 0; i < _allocated_length; i = i + 1 do
		[v + 1] = [_values + 1];
	    od
	    _values = v;
	end
    end
end
