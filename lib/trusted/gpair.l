#K

namespace Generic is
    /// A pair of values with a key and its associate value. 
    /// \param K the type of this pair's key
    /// \param V the type of this pair's value
    class Pair<K,V> is
        /// this pair's key	
        public K key;
	
	/// this pair's value
	public V value;

	/// construct a new key
	/// \param k the key for this new pair
	/// \param v the value for this new pair
        void init(K k, V v) is
	    key = k;
	    value = v;
 	si
    si

    /// Iterates over an Iterator<Pair<K,V>> returning each pair's key in turn.
    /// \param K the key type
    /// \param V the value type
    class PairKeyIterator<K,V> do Iterator<K> is
	Iterator<Pair<K,V>> _i;

        /// Construct a new PairKeyIterator
        /// \param i the underlying Iterator<Pair<K,V>> that iterates over Pair<K,V>
	void init( Iterator<Pair<K,V>> i ) is
    	    super.init();
	    _i = i;
        si

	bool hasMoreElements() is
            return _i.hasMoreElements();
        si

	K nextElement() is
            return _i.nextElement().key;
        si

	get Iterator<K> Iterator is
	    return this;
	si
    si

    /// Iterates over an Iterator<Pair<K,V>> returning each pair's value in in turn.
    /// \param K the key type
    /// \param V the value type
    class PairValueIterator<K,V> do Iterator<V> is
        Iterator<Pair<K,V>> _i;

        /// Construct a new PairValueIterator
        /// \param i the underlying Iterator<Pair<K,V>> that iterates over Pair<K,V>
        void init( Iterator<Pair<K,V>> i ) is
            _i = i;
        si

        bool hasMoreElements() is
            return _i.hasMoreElements();
        si

        V nextElement() is
            return _i.nextElement().value;
        si

	get Iterator<V> Iterator is
	    return this;
	si
    si
si