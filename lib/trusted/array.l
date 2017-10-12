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
    si
si

namespace Generic is
    use System.Object;
    use System.String;
    use System.StringBuffer;
    /// Native arrays can be converted to and from specializations of this template class.
    /// Arrays are fixed length and bounds checked with valid indexes of 0 - length-1 inclusive. 
    /// \param T element type of the array
    class Array<T> do List<T> is
        int length;

        /// indexer: get T[int index]
        /// \param index which array element to get
        /// \return array element at index
        /// \throw System.BoundsException if index is negative or greater than or equal to length
        get T[int index] is
            return cast T[](this)[index];
        si

        /// indexer: set T[int index] = v
        /// \param index which array element to set
        /// \param v value to place in array at index
        /// \throw System.BoundsException if index is negative or greater than or equal to length
        set T[int index] = v is
            cast T[](this)[index] = v;
        si

        /// accessor: get List<T> List
        /// \return this array as a List<T> interface
        get List<T> List is
            return cast List<T>(this);
        si

        /// accessor: get int Length
        /// \return the number of values in this array
        get int Length is
            return length;
        si

        /// accessor: get int ValueSize
        /// \return the size of each value in this array
        get int ValueSize is
            return T.sizeof;
        si

        /// \attention not implemented
        /// \throw System.NotImplementedException
        void add( T v ) is
            throw new System.NotImplementedException( "Generic.Array is fixed length" );
        si

        /// \attention: not implemented
        /// \throw System.NotImplementedException
        void add( Iterable<T> v ) is
            throw new System.NotImplementedException( "Generic.Array is fixed length" );
        si

        /// \attention not implemented
        /// \throw System.NotImplementedException
        void remove( T v ) is
            throw new System.NotImplementedException( "Generic.Array is fixed length" );
        si

        /// \attention partially implemented
        /// \throw System.NotImplementedException
        void lengthen( int l ) is
            if l > length then
                throw new System.NotImplementedException( "Generic.Array is fixed length" );
            fi
        si

        String toString() is
            var result = new StringBuffer();
            for int i = 0; i < length; i = i + 1 do
                if i != 0 then
                    result.append(',');			
                fi

                var current = this[i];

                if T.reference && current == null then
                    result.append("null");
                else
                    result.append(this[i].toString());
                fi
            od

            return result;
        si

        /// \attention: checks reference equality only for reference types
        bool contains( T v ) is
            for int i = 0; i < length; i = i + 1 do
                 if cast T[](this)[i] =~ v then
                    return true;
                fi
            od

            return false;
        si

        bool isEmpty() is
            return length == 0;
        si

        /// accessor: get ArrayIterator<T> Iterator
        /// Return an ArrayIterator<T> over this array
        /// \return an ArrayIterator<T> that returns each element of this array in increasing index order
        get ArrayIterator<T> Iterator is
            return new ArrayIterator<T>(cast T[](this));	    
        si

        /// Return an ArrayIterator<T> over this array
        /// \return an ArrayIterator<T> that returns each element of this array in increasing index order
        ArrayIterator<T> elements() is
            return new ArrayIterator<T>(cast T[](this));
        si

        get T ptr Address is
            return cast T ptr(cast T[](this).address);
        si

        get Object ptr ObjectValuesPointer is
            if !T.isobject then
                return null;
            fi

            return cast Object ptr(this) + 2;
        si

        get int ObjectValuesLength is
            return length;
        si

        get int MemoryUse is 
            return System.Environment.WORD_BYTES * 3 + T.sizeof * Length;
        si

        get bool IsArray is
            return true;
        si

        Slice<T> slice(int from, int to) is
            return new Slice<T>(this, from, to); 
        si	   

        get Slice<T>[Range<int> r] is
            return new Slice<T>(this, r.from, r.to);
        si

        T[] copy() is
            var result = new T[length];
            for var i = 0; i < length; i = i + 1 do
                result[i] = this[i];
            od

            return result;
        si

        get T[] Freeze is
            return copy();
        si
    si

    /// an Iterator<T> that returns each element of an array in increasing index order
    class ArrayIterator<T> do Iterator<T> is
        T[] values;
        int index;

        /// Construct a new ArrayIterator<T> over an array
        /// \param values the array to iterate over
        void init( T[] values ) is
            this.values = values;
        si

        bool hasMoreElements() is
            return index < values.length;
        si

        T nextElement() is
            T result = values[index];
            index = index + 1;
            return result;
        si

        get ArrayIterator<T> Iterator is
            return this;
        si
    si
si
