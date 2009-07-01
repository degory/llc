#K

import gbag;

namespace Generic is
    /// Interface. An ordered list of values accessible with array syntax
    interface List<T> extends Bag<T> is
        /// Make this List as long as supplied length if it is not already longer
	/// \param l new minimum length
	void lengthen(int l);

	/// Get value at supplied index
	/// \param index index of value to get
        get T[int index];

	/// Set value at supplied index
	/// \param index index of value to set
	/// \param v new value
	set T[int index] = v;
    end
end
