namespace Collections is
    // FIXME: inefficient - could add an additional generic parameter for the underlying type's iterator
    // and then could probably avoid any dynamic dispatch

    /// A pair of values with a key and its associate value. 
    /// \param K the type of this pair's key
    /// \param V the type of this pair's value
    class PAIR<K,V> is
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

    /// Iterates over an Iterator<PAIR<K,V>> returning each pair's key in turn.
    /// \param K the key type
    /// \param V the value type
    class PAIR_KEY_ITERATOR<K,V> do Iterator<K> is
        Iterator<PAIR<K,V>> _i;

        /// Construct a new PAIR_KEY_ITERATOR
        /// \param i the underlying Iterator<PAIR<K,V>> that iterates over PAIR<K,V>
        void init( Iterator<PAIR<K,V>> i ) is
            super.init();
            _i = i;
        si

        bool next() is
            return _i.next();
        si

        get K current is
            return _i.current.key;
        si
    si

    /// Iterates over an Iterator<PAIR<K,V>> returning each pair's value in in turn.
    /// \param K the key type
    /// \param V the value type
    class PAIR_VALUE_ITERATOR<K,V> do Iterator<V> is
        Iterator<PAIR<K,V>> _i;

        /// Construct a new PAIR_VALUE_ITERATOR
        /// \param i the underlying Iterator<PAIR<K,V>> that iterates over PAIR<K,V>
        void init( Iterator<PAIR<K,V>> i ) is
            _i = i;
        si

        bool next() is
            return _i.next();
        si

        get V current() is
            return _i.current.value;
        si
    si
si
