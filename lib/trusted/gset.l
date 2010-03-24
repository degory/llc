#K

import gbag;
import gmap;

pragma NoWarnHide;

namespace Generic is
    use System.Object;
    use System.String;
    use System.StringBuffer;

    /// A set of values
    /// \param T the type of values in this set
    class Set<T> do Bag<T> is
    	Map<T,bool> _map;

	/// Construct a new Set with capacity reserved for specified number of values
	/// \param size number of slots in the Set's hash table. Size should be prime. The hash table size is
        /// not adjustable after the Map is constructed.
        /// \attention Performance will degrade if the number of elements
        /// stored greatly excedes this size.
	void init( int size ) is
	    _map = new Map<T,bool>(size);
	si

	/// Construct a new Set with default initial capacity
	void init() is
	    init( 1021 );
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

	/// Return a new Iterator over the values in this set. The Iterator returns each value in the set in turn in no particular order.
	Iterator<T> elements() is
	    return _map.keys();
	si

	get Iterator<T> Iterator is
	    return _map.keys();
        si

        String toString() is
	    StringBuffer result = new StringBuffer( "[Set" );
	    foreach T v; elements() do
	        result.append( ' ' );
	        result.append( v );
	    od
	    result.append(']');

 	    return result;
	si
    si
si