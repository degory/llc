#K

import object;
import vector;

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System is
    /// A primitive array of non-Object values
    /// \deprecated non-functional, needs to be replaced with a template equivalent
    class Array extends Object is
	int length;

	StringBuffer toString() is
	    StringBuffer result;
	    result = "an Array of " + length + " elements";
	end

	Util.Iterator elements() is
	    throw new NotImplementedException("cannot iterate over non-Object Array");
	end

	Object[] toVec() is
	    throw new NotImplementedException("cannot convert non-Object Array to Object[]");
	end

	static ObjectArray makeArray( Util.Vector v ) is
	    int ptr ptr p = cast int ptr ptr( native.GC_malloc((v.getLength() + 2) * native.__get_word_size()) );
            // native.printf( `%p array\n`, p );
	    return cast ObjectArray(p);
	end

	static Object[] makeVec( Util.Vector v ) is
	    return makeArray(v).toVec();
	end

	static void copy( int[] from, int from_offset, int[] to, int to_offset, int len ) is
	    throw new NotImplementedException("FIXME: implement Array.copy()");
	end

	static void copy( Object[] from, int from_offset, Object[] to, int to_offset, int len ) is
	    throw new NotImplementedException("FIXME: implement Array.copy()");
	end
    end

    /// An iterator over an Array
    /// \deprecated non-functional, needs to be replaced with a template equivalent
    class ArrayIterator extends Util.Iterator is
	Object[] a;
	int i;

	void init( Object[] a ) is
	    super.init();

	    // native.printf(`ArrayIterator.init(): vec %p has %d elements\n`, a, a.length );
	    this.a = a;
	    i = 0;
	end

	bool hasMoreElements() is
	    // native.printf( `ArrayIterator.hasMoreElements(): %d < %d?\n`, i, a.length );
	    return i < a.length;
	end

	Object nextElement() is
	    Object result = a[i];
	    // native.printf( `ArrayIterator.nextElement(): index %d returning Object @ %X\n`, i, result );
	    i = i + 1;
	    return result;
	end
    end

    /// A primitive array of word values
    /// \deprecated non-functional, needs to be replaced with a template equivalent
    class WordArray extends Array is
    end

    /// A primitive array of byte values
    /// \deprecated non-functional, needs to be replaced with a template equivalent
    class ByteArray extends Array is
    end

    /// A primitive array of Object
    /// \deprecated non-functional, needs to be replaced with a template equivalent
    class ObjectArray extends Array is
	Util.Iterator elements() is
	    return new ArrayIterator(this.toVec() );
	end

	Object[] toVec() is

	    return cast Object[]( this );
	end
    end
end
