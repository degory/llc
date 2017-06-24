import object;
import gpair;
import gdict;
import glist;
import gllist;
import gvector;
import giterator;

import stream;

pragma NoWarnHide;

namespace Collections is
    use System.String;
    use System.StringBuffer;

    /// Iterates over a Map<K,V> and returns each Pair<K,V> comprising the map in turn. Returns values in no particular order 
    /// \param K the key type
    /// \param V the value type
    class HASH_MAP_ITERATOR<K,V> do Iterator<Pair<K,V>> is
        Map<K,V> _map;            // the Map we're iterating over
        LinkedListIterator<MapPair<K,V>> _j;   // iterator over the current hash chain
        int _i;              // the index of the hash chain we're currently iterating over
        // bool _more_elements; // is _next valid? or have we already enumerated all values in Map

        /// Construct a new HASH_MAP_ITERATOR over map m
        /// \param m the Map to iterate over
        void init( Map<K,V> m ) is
            super.init();
            _map = m;
            _i = 0-1;
            _j = null;
            // _go_next();
        si

        public bool next() is
            LINKED_LIST_NODE<MapPair<K,V>> l;

            // try to find a non-null hash chain that has some elements in it
            while _j == null || !_j.next() do
                _i = _i + 1;
                if _i >= _map._values.length then
                    return false;
                fi

                l = _map._values[_i];
                if l != null then
                    _j = l.elements();
                fi
            od

            return true;
        si

        /// Return the next value in the Map. Behaviour is undefined if nextElement() is called after hasMoreElements() has returned false
        get HASH_MAP_PAIR<K,V> current is
            return _j.current;
        si
    si

    /// Holds a key-value pair. 
    /// \param the key type
    /// \param the value type
    class HASH_MAP_PAIR<K,V> isa PAIR<K,V> is
        /// Construct a new HASH_MAP_PAIR
        /// \param k the key
        /// \param v the value
        void init( K k, V v ) is
            super.init();
            key = k;
            value = v;
            // IO.Std.err.println( "new HASH_MAP_PAIR: " + k + "," + v + ": " + this );
        si

        /// Internal method. Does this HASH_MAP_PAIR match key k with hash h
        /// \param k the key to compare
        /// \param h the hash to compare
        bool _matches( K k, int h ) is
            return key == k || (k.hash() == h && k =~ key);
        si

        /// Implements inequality operators.
        /// \param v the HASH_MAP_PAIR to compare to for ordering
        int opCompare( HASH_MAP_PAIR<K,V> v ) is
            return key.opCompare(v.key);
        si

        String toString() is
            return "" + key + "=>" + value;
        si
    si

    /// An associative array implemented as a hash table. 
    /// \param K type of keys in the Map. K must implement int hash() method and =~ operator (bool opEquals(K)). 
    /// \param V type of values in the Map.
    class Map<K,V> do Dict<K,V> is
        public LINKED_LIST_NODE<HASH_MAP_PAIR<K,V>>[] _values;

        /// Construct a new Map
        /// \param size number of slots in the Map's hash table. Size should be prime. The hash table size is
        /// not adjustable after the Map is constructed.
        /// \attention Performance will degrade if the number of elements
        /// stored greatly excedes this size.
        void init( int size ) is
            super.init();
            if size <= 0 then
                throw new System.Exception( "oops: map length is " + size );
            fi

            _values = new LINKED_LIST_NODE<HASH_MAP_PAIR<K,V>>[size];
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

        /// Indexed accessor: set V[K key] = value
        /// \param key the key to set
        /// \param value the value to give this key
        set V[K key] = value is
            int k;
            int h;
            LINKED_LIST_NODE<HASH_MAP_PAIR<K,V>> chain;

            hashOf(key,k,h);

            // IO.Std.out.print( "Map.put(" + key + "," + value + ")\n" );

            var match = _find_pair( key, h, k, false);

            if match == null then
                match = new HASH_MAP_PAIR<K,V>( key, value );

                // IO.Std.out.print( "putting HASH_MAP_PAIR " + match + " at " + h + "\n" );

                chain =_values[h];

                var c = new LINKED_LIST_NODE<HASH_MAP_PAIR<K,V>>(match,chain);
                // IO.Std.out.print( "putting LINKED_LIST_NODE " + c + " at " + h + "\n" );
      
                _values[h] = c;
            else
                match.value = value;
            fi
        si

        /// Indexed accessor: get V[K key]
        /// \param key the key to get
        /// \return the value associated with key
        get V[K key] is
            int k;
            int h;

            if key == null then
                return null;
            fi

            hashOf(key,k,h);

            var match = _find_pair(key, h, k, false);

            if match == null then
                return null;
            else
                return match.value;
            fi
        si

        /// Remove value associated with key from the Map if it is present, otherwise return V.none
        /// \param key key to remove
        /// \return value of key removed if present, otherwise V.none
        V remove( K key ) is
            int k;
            int h;
        
            if key == null then
                return null;
            fi

            hashOf(key,k,h);

            var match = _find_pair(key, h, k, true);        

            if match == null then
                return null;
            else
                return match.value;
            fi
        si

        bool contains( K key ) is
            int k;
            int h;

            if key == null then
                return false;
            fi

            hashOf(key,k,h);

            var match = _find_pair(key, h, k, false);

            return match != null;
        si

        /// Accessor: get int Length
        /// Return the number of values in this Map
        get int length is
            int result = 0;

            for int i = 0; i < _values.length; i = i + 1 do
                var l = _values[i];
                if l != null then
                    result = result + l.length;
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
        HASH_MAP_PAIR<K,V> _find_pair( K key, int h, int k, bool remove ) is
            var head = _values[h];
            HASH_MAP_PAIR<K,V> prev = null;

            while head != null do
                // IO.Std.out.println( "loop..." );
                var match = head.Value;

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
            var seen_any = false;
            foreach var i; new HASH_MAP_ITERATOR<K,V>(this) do
                if seen_any then
                    b.append( ',' );
                else
                    seen_any = true;
                fi
                b.append( i );
            od

            return b;
        si

        /// Return a new Iterator that returns each key in the Map in turn
        PAIR_KEY_ITERATOR<K,V> keys() is
            return new PAIR_KEY_ITERATOR<K,V>(pairs());
        si

        /// Return a new Iterator that returns each key-value pair in the Map in turn
        HASH_MAP_ITERATOR<K,V> pairs() is
            return new HASH_MAP_ITERATOR<K,V>(this);
        si

        /// Return a new Iterator that returns each value in the Map in turn
        PAIR_VALUE_ITERATOR<K,V> elements() is
            return new PAIR_VALUE_ITERATOR<K,V>(pairs());
        si
    si
si
