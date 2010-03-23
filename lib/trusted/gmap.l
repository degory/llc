#K

import object;
import glist;
import gllist;
import gvector;
import giterator;

import stream;

pragma NoWarnHide;

namespace Generic is
    use System.String;
    use System.StringBuffer;

    /// Iterates over a Map and returns each MapPair comprising the Map in turn. Returns values in no particular order 
    /// \param K the key type
    /// \param T the value type
    class MapIterator<K,T> do Iterator<MapPair<K,T>> is
	Map<K,T> _map;            // the Map we're iterating over
	LinkedListIterator<MapPair<K,T>> _j;   // iterator over the current hash chain
	MapPair<K,T> _next; // the map value that we will return as nextElement()	
	int _i;              // the index of the hash chain we're currently iterating over
	bool _more_elements; // is _next valid? or have we already enumerated all values in Map

	/// Construct a new MapIterator over map m
	/// \param m the Map to iterate over
	void init( Map<K,T> m ) is
	    super.init();
	    _map = m;
	    _i = 0-1;
	    _j = null;
	    _go_next();
	si

	/// Internal method 
	void _go_next() is
	    // IO.Std.out.println( "_go_next: " + _map );
	    _more_elements = true;
	    ListNode<MapPair<K,T>> l;

	    // try to find a non-null hash chain that has some elements in it
	    while _j == null || !_j.hasMoreElements() do
		_i = _i + 1;
		if _i >= _map._values.length then
		    // IO.Std.out.print( "end of vector - no more elements\n" );
		    _more_elements = false;
		    _next = null;
		    return;
		fi

		l = _map._values[_i];
		if l != null then
		    _j = l.elements();
		fi
	    od

	    if _j != null then
		_next = _j.nextElement();
	    fi
	    // IO.Std.out.println( "_next: " + _next );
	si

	/// Return true if this MapIterator has more values to return, otherwise return false
	bool hasMoreElements() is
	    return _more_elements;
	si

	/// Return the next value in the Map. Behaviour is undefined if nextElement() is called after hasMoreElements() has returned false
	MapPair<K,T> nextElement() is
	    MapPair<K,T> result = _next;
	    _go_next();
	    return result;
	si
    si

    /// Holds a key-value pair. 
    /// \param the key type
    /// \param the value type
    class MapPair<K,T> is
	public K key;
	public T value;

	/// Construct a new MapPair
	/// \param k the key
	/// \param v the value
	void init( K k, T v ) is
	    super.init();
	    key = k;
	    value = v;
	    // IO.Std.err.println( "new MapPair: " + k + "," + v + ": " + this );
	si

	/// Internal method. Does this MapPair match key k with hash h
	/// \param k the key to compare
	/// \param h the hash to compare
	bool _matches( K k, int h ) is
	    return key == k || (k.hash() == h && k =~ key);
	si

	/// Implements inequality operators.
	/// \param v the MapPair to compare to for ordering
	int opCompare( MapPair<K,T> v ) is
	    return key.opCompare(v.key);
	si

	String toString() is
	    return "" + key + "=>" + value;
	si
    si

    /// Iterates over a Map returning each key in the map in turn. Returns keys in no particular order
    /// \param K the key type
    /// \param T the value type
    class MapKeyIterator<K,T> do Iterator<K> is
	MapIterator<K,T> _i;
	
	/// Construct a new MapKeyIterator
	/// \param i the underlying MapIterator that iterates over the MapPairs comprising the Map
	void init( MapIterator<K,T> i ) is
	    super.init();
	    _i = i;
	si

	bool hasMoreElements() is
	    return _i.hasMoreElements();
	si

	K nextElement() is
	    return _i.nextElement().key;
	si
    si

    /// Iterates over a Map returning each value in the Map in turn. Returns values in no particular order
    /// \param K the key type
    /// \param T the value type
    class MapValueIterator<K,T> do Iterator<T> is
	MapIterator<K,T> _i;

	/// Construct a new MapValueIterator
	/// \param i the underlying MapIterator that iterates over the MapPairs comprising the Map
	void init( MapIterator<K,T> i ) is
	    _i = i;
	si

	bool hasMoreElements() is
	    return _i.hasMoreElements();
	si

	T nextElement() is
	    return _i.nextElement().value;
	si
    si

    /// An associative array
    /// \param K type of keys in the Map. K must implement int hash() method and =~ operator (bool opEquals(K)). 
    /// \param T type of values in the Map.
    class Map<K,T> do Iterable<T> is
	public ListNode<MapPair<K,T>>[] _values;

	/// Construct a new Map
	/// \param size number of slots in the Map's hash table. Size should be prime.
	void init( int size ) is
	    super.init();
	    if size <= 0 then
		throw new System.Exception( "oops: map length is " + size );
	    fi

	    _values = new ListNode<MapPair<K,T>>[size];
	si

	/// Construct a new Map with default hash table size
	void init() is
	    init(53);
	si

	/// Internal method
	void hashOf( K key, int ref k, int ref h ) is
	    int t = key.hash();
	    k = t;
	    
	    if k < 0 then
		h = -t % _values.length;
	    else
		h = t % _values.length;
	    fi
	si

	/// Indexed accessor: set T[K key] = value
	/// \param key the key to set
	/// \param value the value to give this key
	set T[K key] = value is
	    int k;
	    int h;
	    ListNode<MapPair<K,T>> chain;
	    hashOf(key,k,h);

	    // IO.Std.out.print( "Map.put(" + key + "," + value + ")\n" );

	    MapPair<K,T> match = _find_pair( key, h, k, false);

	    if match == null then
		match = new MapPair<K,T>( key, value );

		// IO.Std.out.print( "putting MapPair " + match + " at " + h + "\n" );

		chain =_values[h];

		ListNode<MapPair<K,T>> c = new ListNode<MapPair<K,T>>(match,chain);
		// IO.Std.out.print( "putting ListNode " + c + " at " + h + "\n" );
	  
		_values[h] = c;
	    else
		match.value = value;
	    fi
	si

	/// Indexed accessor: get T[K key]
	/// \param key the key to get
	/// \return the value associated with key
	get T[K key] is
	    int k;
	    int h;
	    MapPair<K,T> match;

	    if key == null then
		return null;
	    fi

	    hashOf(key,k,h);

	    match = _find_pair(key, h, k, false);

	    if match == null then
		return null;
	    else
		return match.value;
	    fi
	si

	/// Remove and value associated with key from the Map if it is present, otherwise return T.none
	/// \key key to remove
	/// \return value of key removed if present, otherwise T.none
	T remove( K key ) is
	    int k;
	    int h;
	    MapPair<K,T> match;

	    if key == null then
		return null;
	    fi

	    hashOf(key,k,h);

	    match = _find_pair(key, h, k, true);	    

	    if match == null then
		return null;
	    else
		return match.value;
	    fi
	si

 	bool containsKey( K key ) is
	    int k;
	    int h;
	    MapPair<K,T> match;

	    if key == null then
		return null;
	    fi

	    hashOf(key,k,h);

	    match = _find_pair(key, h, k, false);

            return match != null;
	si

	/// Return true if this Map contains no values, otherwise return false
	bool isEmpty() is
	    for int i = 0; i < _values.length; i = i + 1 do
	        if _values[i] != null then
		    return false;
		fi
	    od

	    return true;
	si

	/// Accessor: get int Length
	/// Return the number of values in this Map
	get int Length is
	    int result = 0;

	    for int i = 0; i < _values.length; i = i + 1 do
		ListNode<MapPair<K,T>> l = _values[i];
		if l != null then
		    result = result + l.Length;
		fi
	    od

	    return result;
	si

	/// Remove all existing values from this Map leaving length at zero
	void clear() is
	    for int i = 0; i < _values.length; i = i + 1 do
		_values[i] = null;
	    od
	si

	/// Internal method
	MapPair<K,T> _find_pair( K key, int h, int k, bool remove ) is
    // IO.Std.out.println( "_find_pair: " + key + "," + h + "," + k + "..." );
	    ListNode<MapPair<K,T>> head = _values[h], prev = null;

	    while head != null do
		// IO.Std.out.println( "loop..." );
		MapPair<K,T> match = head.Value;
		// IO.Std.out.println( "match: " + match );
		if match == null then
		    throw new System.Exception( "oops: null map pair for key " + k + " chain " + h );
		    return null;
		fi

		if match._matches(key, k) then
		    if remove then
			if prev != null then
			    _values[h] = _values[h].Tail;
			else
			    prev.Tail = head.Tail;
			fi
		    fi

		    return match;
		fi
		prev = head;
		head = head.Tail;
	    od

	    return null;
	si

	String toString() is
	    var b = new StringBuffer();
	    bool seen_any;
	    foreach MapPair<K,T> i; new MapIterator<K,T>(this) do
	        if seen_any then
		    b.append( ',' );
		else
		    seen_any = true;
		fi
		b.append( i );
	    od

	    return b;
	si

	/// Accessor: get MapValueIterator<K,T> Iterator
	/// Get a new Iterator that returns each value in the Map in turn
	get MapValueIterator<K,T> Iterator is
	    return elements();
	si

	/// Accessor: get MapKeyIterator<K,T> Keys
	/// Get a new Iterator that returns each key in the Map in turn
	get MapKeyIterator<K,T> Keys is
	    return keys();
	si

	/// Accessor: get MapIterator<K,T> Pairs
	/// Get a new Iterator that returns each key-value pair in the Map in turn
	get MapIterator<K,T> Pairs is
	    return pairs();
	si

	/// Return a new Iterator that returns each key-value pair in the Map in turn
	MapIterator<K,T> pairs() is
	    return new MapIterator<K,T>(this);
	si

	/// Return a new Iterator that returns each value in the Map in turn
	MapValueIterator<K,T> elements() is
	    // IO.Std.out.print( "Map.elements for " + this + "\n" );
	    return new MapValueIterator<K,T>(pairs());
	si

	/// Return a new Iterator that returns each key in the Map in turn
	MapKeyIterator<K,T> keys() is
	    return new MapKeyIterator<K,T>(pairs());
	si
    si
si
