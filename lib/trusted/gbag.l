#K

import giterator;

namespace Generic is
    /// Interface. An unordered collection of values
    interface Bag<T> is
        /// Add a value to the Bag. Adding a duplicate value may or may not replace the existing value depending on the implementation
	/// \param v the value to add
        void add( T v );

	/// Remove a value from the Bag if it is present
	/// \param v the value to remove
	void remove( T v );

	/// Does this Bag contain a given value?
	/// \param v the value to look for
        bool contains( T v );

	/// Does this bag contain no values?
	bool isEmpty();

	/// Return the number of values in this bag
	get int Length;

	/// Return an Iterator over the values in this bag. The order values are returned in depends on the implementation
	Iterator<T> elements();
    end
end