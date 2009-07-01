#K

import object;
import glist;
import gllist;
import gvector;
import giterator;

import stream;

namespace Generic is
    class MapIterator<K,T> extends System.Object is
	Map<K,T> _map;            // the Map we're iterating over
	int _i;              // the index of the hash chain we're currently iterating over
	LinkedListIterator<MapPair<K,T>> _j;   // iterator over the current hash chain
	MapPair<K,T> _next; // the map value that we will return as nextElement()	
	bool _keys;          // iterate over keys rather than values
	bool _more_elements; // is _next valid? or have we already enumerated all values in Map

	void init( Map<K,T> m, bool keys ) is
	    super.init();
	    _keys = keys;
	    _map = m;
	    _i = 0-1;
	    _j = null;
	    _go_next();
	end

	void init( Map<K,T> m ) is
	    this.init( m, false );
	end

	void _go_next() is
	    // IO.Std.out.println( "_go_next: " + _map );
	    _more_elements = true;
	    RealList<MapPair<K,T>> l;

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
	end

	bool hasMoreElements() is
	    return _more_elements;
	end

	MapPair<K,T> nextElement() is
	    MapPair<K,T> result = _next;
	    _go_next();
	    return result;
	end
    end

    class MapPair<K,T> extends System.Object is
	public K key;
	public T value;

	void init( K k, T v ) is
	    super.init();
	    key = k;
	    value = v;
	    // IO.Std.err.println( "new MapPair: " + k + "," + v + ": " + this );
	end

	bool _matches( K k, int h ) is
	    return key == k || (k.hash() == h && k =~ key);
	end

	int opCompare( MapPair<K,T> v ) is
	    return key.opCompare(v.key);
	end

	System.String toString() is
	    return "[MapPair: " + key + "," + value + "]";
	end
    end

    class MapKeyIterator<K,T> extends System.Object implements Iterator<K> is
	MapIterator<K,T> _i;

	void init( MapIterator<K,T> i ) is
	    _i = i;
	end

	bool hasMoreElements() is
	    return _i.hasMoreElements();
	end

	K nextElement() is
	    return _i.nextElement().key;
	end
    end

    class MapValueIterator<K,T> extends System.Object implements Iterator<T> is
	MapIterator<K,T> _i;

	void init( MapIterator<K,T> i ) is
	    _i = i;
	end

	bool hasMoreElements() is
	    return _i.hasMoreElements();
	end

	T nextElement() is
	    return _i.nextElement().value;
	end
    end

    class Map<K,T> extends System.Object is
	public RealList<MapPair<K,T>>[] _values;

	void init( int size ) is
	    super.init();
	    if size <= 0 then
		throw new System.Exception( "oops: map length is " + size );
	    fi

	    _values = new RealList<MapPair<K,T>>[size];
	end

	void init() is
	    init(53);
	end

	void hashOf( K key, int ref k, int ref h ) is
	    int t = key.hash();
	    k = t;
	    
	    if k < 0 then
		h = -t % _values.length;
	    else
		h = t % _values.length;
	    fi
	end

	set T[K key] = value is
	    int k;
	    int h;
	    RealList<MapPair<K,T>> chain;
	    hashOf(key,k,h);

	    // IO.Std.out.print( "Map.put(" + key + "," + value + ")\n" );

	    MapPair<K,T> match = _find_pair( key, h, k, false);

	    if match == null then
		match = new MapPair<K,T>( key, value );

		// IO.Std.out.print( "putting MapPair " + match + " at " + h + "\n" );

		chain =_values[h];

		RealList<MapPair<K,T>> c = new RealList<MapPair<K,T>>(match,chain);
		// IO.Std.out.print( "putting RealList " + c + " at " + h + "\n" );
	  
		_values[h] = c;
	    else
		match.value = value;
	    fi
	end

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
	end

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
	end

	bool isEmpty() is
	    for int i = 0; i < _values.length; i = i + 1 do
	        if _values[i] != null then
		    return false;
		fi
	    od

	    return true;
	end

	get int Length is
	    int result = 0;

	    for int i = 0; i < _values.length; i = i + 1 do
		RealList<MapPair<K,T>> l = _values[i];
		if l != null then
		    result = result + l.Length;
		fi
	    od

	    return result;
	end

	void clear() is
	    for int i = 0; i < _values.length; i = i + 1 do
		_values[i] = null;
	    od
	end

	MapPair<K,T> _find_pair( K key, int h, int k, bool remove ) is
    // IO.Std.out.println( "_find_pair: " + key + "," + h + "," + k + "..." );
	    RealList<MapPair<K,T>> head = _values[h], prev = null;

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
	end

	System.String toString() is
	    var b = new System.StringBuffer( "[Map" );
	    foreach MapPair<K,T> i; new MapIterator<K,T>(this) do
		b.append( ' ' );
		b.append( i );
	    od
	    b.append( "]" );

	    return b;
	end

	get MapValueIterator<K,T> Elements is
	    return elements();
	end

	get MapKeyIterator<K,T> Keys is
	    return keys();
	end

	get MapIterator<K,T> Pairs is
	    return pairs();
	end

	MapIterator<K,T> pairs() is
	    return new MapIterator<K,T>(this);
	end

	MapValueIterator<K,T> elements() is
	    // IO.Std.out.print( "Map.elements for " + this + "\n" );
	    return new MapValueIterator<K,T>(pairs());
	end

	MapKeyIterator<K,T> keys() is
	    return new MapKeyIterator<K,T>(pairs());
	end
    end
end
