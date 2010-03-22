#K

import gbag;

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
    si
si