#K

import gbag;
import gslice;

namespace Generic is
    /// Interface. An ordered list of values accessible with array syntax
    interface List<T> isa Bag<T> is
        /// Make this List as long as supplied length if it is not already longer
	/// \param l new minimum length
	void lengthen(int l);

	/// accessor get T[int index]
	/// Get value at supplied index
	/// \param index index of value to get
        get T[int index];

	/// accessor set T[int index] = v
	/// Set value at supplied index
	/// \param index index of value to set
	/// \param v new value
	set T[int index] = v;

	/// Get a slice of this List<T>
	/// \param from index of first element to include in slice
	/// \param to index of last element to include in slice
	/// \return a read only view of a list consisting of elements from..to.
	Slice<T> slice(int from, int to);

	/// Get a read only subsection of this List<T> 
	/// \param range range of elements to include in slice
	/// \return a read only view of a list consisting of elements from..to.
	/// \attention implementations may return either a read only view of the
	/// underlying list or a copy. If !isa<Slice<T>>(result) then caller may
	/// assume that either the result is a copy or the underlying object is
	/// immutable.
        get List<T>[Range<int> r];

        /// Get a copy of this List<T> that will not change if the original list
	/// is altered. If the original list is immutable then this method
	/// may simply return the same list
	get List<T> Freeze;
    si
si