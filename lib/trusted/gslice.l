import glist;
import giterator;
import gvector;

namespace Generic is
    use System.BoundsException;
    use System.String;
    use System.StringBuffer;

    /// A read-only sub-view of a List<T>. A slice reflects changes to the underlying list and
    /// is also a forward iterator over the sub-list.
    /// Taking a slice is a lightweight operation that does not make a copy of the list.
    /// \param T the element type of the underlying list
    class Slice<T> do List<T>, Iterator<T> is
        /// The underlying list that is sliced
        List<T> a;

	/// The index of the next element to be returned by the iterator
        int i;

	/// The indexes of the first and last elements in the underlying list
	int from, to;

	/// Construct a new Slice
	/// \param a the list to create a slice of
	/// \param from the first element of a to include in this slice
	/// \param to the last element of a to include in this slice
	void init( List<T> a, int from, int to ) is
	    if from < 0 || to >= a.Length then
	        throw new BoundsException( "Slice range out of bounds" );
	    fi

	    this.a = a;
            i = from;
	    this.from = from;
	    this.to = to;

            if Length < 0 then
                throw new BoundsException( "Slice range is reversed" );
            fi
        si

	bool hasMoreElements() is
	    return i <= to;
	si

	T nextElement() is
	    T result = a[i];
	    i = i + 1;
	    return result;
	si

	get T[int index] is 
	    if index < 0 || index > to then
	        throw new BoundsException( "Slice index out of bounds" );
	    fi
	    return a[from + index];
	si

	set T[int index] = v is
	    _read_only();
	si

	void _read_only() is 
	    throw new System.NotImplementedException( Class.Name + " is read only" );
	si

	get int Length is
	    return 1 + to - from;
	si

	/// \attention: not implemented
        /// \throw System.NotImplementedException
	void add( T v ) is
	    _read_only();
	si

	/// \attention: not implemented
        /// \throw System.NotImplementedException
	void add( Iterable<T> v ) is
	    _read_only();
	si

	/// \attention: not implemented
        /// \throw System.NotImplementedException
	void remove( T v ) is
	    _read_only();
        si

	/// \attention: partially implemented
        /// \throw System.NotImplementedException
	void lengthen( int l ) is
	    if l > Length then
	        _read_only();
	    fi
	si

	String toString() is
            var result = new StringBuffer();
            for int i = from; i <= to; i = i + 1 do
               if i != from then
	           result.append(',');			
               fi
 	       result.append(a[i].toString());
	    od

            return result;
        si

	bool contains( T v ) is
	    for int i = from; i <= to; i = i + 1 do
 		if a[i] =~ v then
		    return true;
		fi
	    od

	    return false;
	si

	bool isEmpty() is
	    return Length > 0;
	si

	Slice<T> slice(int f, int t) is
	    return new Slice<T>(a, from + f, from + t);
	si

	get Slice<T>[Range<int> r] is
	    return new Slice<T>(a, from + r.from, from + r.to);
	si

	get Slice<T> Iterator is
	    return new Slice<T>(a, from, to);
	si

	Slice<T> elements() is
	    return new Slice<T>(a, from, to);
	si

	get List<T> Freeze is
	    var result = new Vector<T>(Length);
	    i = 0;

            foreach var v; this do
	        result.add(v);
	    od

	    return result;
        si
    si	
si
