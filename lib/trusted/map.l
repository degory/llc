#K

import object;
import list;
import vector;
import iterator;

namespace Util is
    private class MapIterator extends Iterator is
	Map _map;            // the Map we're iterating over
	int _i;              // the index of the hash chain we're currently iterating over
	Iterator _j;         // iterator over the current hash chain
	System.Object _next; // the map value that we will return as nextElement()	
	bool _keys;          // iterate over keys rather than values
	bool _more_elements; // is _next valid? or have we already enumerated all values in Map

	void init( Map m, bool keys ) is
	    super.init();
	    _keys = keys;
	    _map = m;
	    _i = 0-1;
	    _j = null;
	    _go_next();
	end

	void init( Map m ) is
	    this.init( m, false );
	end

	void _go_next() is
	    // IO.Std.out.println( "_go_next: " + _map );
	    _more_elements = true;
	    RealList l;

	    // try to find a non-null hash chain that has some elements in it
	    while _j == null || !_j.hasMoreElements() do
		_i = _i + 1;
		if _i >= _map._values.Length then
		    // IO.Std.out.print( "end of vector - no more elements\n" );
		    _more_elements = false;
		    _next = null;
		    return;
		fi

		l = cast RealList(_map._values[_i]);
		if l != null then
		    _j = l.elements();
		fi
	    od

	    if _j != null then
		_next = _j.nextElement();
		if _next != null then
		    if _keys then
			_next = cast MapPair(_next).key;
		    else
			_next = cast MapPair(_next).value;
		    fi
		fi
	    fi
	    // IO.Std.out.println( "_next: " + _next );
	end

	bool hasMoreElements() is
	    return _more_elements;
	end

	System.Object nextElement() is
	    System.Object result = _next;
	    _go_next();
	    return result;
	end
    end

    private class MapPair extends System.Object is
	public System.Object key;
	public System.Object value;

	void init( System.Object k, System.Object v ) is
	    super.init();
	    key = k;
	    value = v;
	    // IO.Std.err.println( "new MapPair: " + k + "," + v + ": " + this );
	end

	bool _matches( System.Object k, int h ) is
	    return key == k || (k.hash() == h && k.equals(key) );
	end

	System.String toString() is
	    return "[MapPair: " + key + "," + value + "]";
	end
    end

    // An associative array
    // \deprecated Use Generic.Map<K,V> instead
    class Map extends System.Object is
	public Vector _values;

	void init( int size ) is
	    super.init();
	    if size <= 0 then
		throw new System.Exception( "oops: map length is " + size );
	    fi

	    _values = new Vector(size);

	    int i = 0;
	    while i < size do
		_values.put( i, null );
		i = i + 1;
	    od
	end

	void init() is
	    init(53);
	end

	set System.Object[int key] = value is
	    opSet( key.box, value );
	end

        set System.Object[System.Object key] = value is
	    int k;
	    int h;
	    RealList chain;
	    k = key.hash();
	    int l = _values.Length;
	    if l == 0 then
		IO.Std.err.println( "oops: map length is 0" );
		throw new System.Exception( "oops: map length is 0" );
	    fi

	    if k < 0 then
		h = (-k) % _values.Length;
	    else
		h = k % _values.Length;
	    fi

	    if key == null then
		return;
	    fi

	    // IO.Std.out.print( "Map.put(" + key + "," + value + ")\n" );

	    MapPair match = _find_pair( key, h, k);

	    if match == null then
		match = new MapPair( key, value );

		// IO.Std.out.print( "putting MapPair " + match + " at " + h + "\n" );

		chain = cast RealList(_values[h]);

		RealList c = new RealList(match,chain);
		// IO.Std.out.print( "putting RealList " + c + " at " + h + "\n" );
	  
		_values.put(h, c);
	    else
		match.value = value;
	    fi
	end

	get System.Object[int key] is
	    return opGet( key.box );
	end

	get System.Object[System.Object key] is
	    int k;
	    int h;
	    MapPair match;
	    k = key.hash();
	    int l = _values.Length;
	    if l == 0 then
		IO.Std.err.println( "oops: map length is 0" );
		throw new System.Exception( "oops: map length is 0" );
	    fi

	    if k < 0 then
		h = (-k) % _values.Length;
	    else
		h = k % _values.Length;
	    fi

	    if key == null then
		return null;
	    fi

	    match = _find_pair(key, h, k);

	    if match == null then
		return null;
	    else
		return match.value;
	    fi
	end

	void put( System.Object key, System.Object value ) is
	    opSet( key, value );
	end

	MapPair _find_pair( System.Object key, int h, int k ) is
	    // IO.Std.out.println( "_find_pair: " + key + "," + h + "," + k + "..." );
	    RealList head;
	    System.Object v = _values[h];
	    if v == null then
		return null;
	    fi
	    // IO.Std.out.println( "v: " + v );
	    head = cast RealList( v );
	    // IO.Std.out.println( "head: " + head );

	    while head != null do
		// IO.Std.out.println( "loop..." );
		MapPair match = cast MapPair(head.getValue());
		// IO.Std.out.println( "match: " + match );
		if match == null then
		    throw new System.Exception( "oops: null map pair for key " + k + " chain " + h );
		    return null;
		fi

		if match._matches(key, k) then
		    return match;
		fi
		head = head.getTail();
	    od

	    return null;
	end

	System.String toString() is
	    return "[Map " + _values + "]";
	end

	get Iterator Elements is
	    return elements();
	end

	get Iterator Keys is
	    return keys();
	end

	Iterator elements() is
	    // IO.Std.out.print( "Map.elements for " + this + "\n" );
	    return new MapIterator(this,false);
	end

	Iterator keys() is
	    return new MapIterator(this,true);
	end
    end
end
