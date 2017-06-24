#K

import gbag;
import gmap;

pragma NoWarnHide;

namespace Generic is
    use System.Object;
    use System.String;
    use System.StringBuffer;

    /// A set of values that is natuarally sorted
    /// \param T the type of values in this set
    class SortedSet<T> do Bag<T> is
        /// SortedMap Red-black tree that represents this set:
    	SortedMap<T,bool> _map;

	/// Construct a new SortedSet
	void init( int size ) is
	    _map = new SortedMap<T,bool>();
	si

	/// Get the number of values in this Set
	get int Length is
	    return _map.Length;
        si

	/// Place the supplied value in the set. If an equal value is already in the set then it will be replaced by the new value.
	/// \param o the value to add
	void add( T o ) is
	    _map[o] = true;
	si

	/// Place the supplied values in the set. If an equal value is already in the set then it will be replaced by the new value.
	/// \param o the value to add
	void add( Iterable<T> o ) is
	    foreach var v; o.Iterator do
	        add( v );
	    od
	si

	/// Does this set contain a value equal to the supplied value?
	/// \param o the value to search for
	bool contains( T o ) is
	    return _map[o];
	si

	/// Return true if this Set contains no values, otherwise return false
	bool isEmpty() is
	    return _map.isEmpty();
	si	    

	/// If this Set contains a value equal to the supplied value then remove that value from this Set
        void remove( T o ) is
	    _map.remove(o);
        si

	/// Return a new Iterator over the values in this set. The Iterator returns each value in ascending key order
	Iterator<T> elements() is
	    return _map.keys();
	si

	/// Return a new Iterator over the values in this set. The Iterator returns each value in ascending key order
	get Iterator<T> Iterator is
	    return _map.keys();
        si

        String toString() is
	    StringBuffer result = new StringBuffer( "" );
	    bool seen_any = false;
	    foreach T v; elements() do
	        if seen_any then
		    result.append(',');
		fi
	        result.append( v );
		seen_any = true;
	    od

 	    return result;
	si
    si
si