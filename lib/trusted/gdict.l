#K

import giterator;
import gpair;

namespace Generic is
    /// An associative array, indexed by one type and storing values of a second type
    /// \param K the key type
    /// \param V the value type    
    interface Dict<K,V> /* isa Iterable<V> */ is
        /// accessor: get int Length
	/// \return the number of key=>value pairs stored in the Dict<K,V>
        get int Length;

	/// remove all pairs
	void clear();

	/// does this Dict contain at least one key=>value pair?
	bool isEmpty();

	/// does this Dict contain a pair with key==k?
	bool contains(K k);

	/// locate the pair with key==k and remove and return it
	/// \returns removed element if found, V.none otherwise
	V remove(K k);

	/// indexed accessor: get V[K index]
	/// locate the pair with key==index and return the associated value
	/// \returns removed element if found, V.none otherwise
	get V[K index];

	/// indexed accessor: set V[K index] = v
	/// if a pair with k==index is found then set this pair's value to
	/// v. Otherwise insert a new pair index=>v
	set V[K index] = v;

	/// accessor: get Iterator<Pair<K,V>> Pairs
	/// return an interator that iterates over all the pairs in this Dict<K,V>
	/// returning each exactly once in no particular order
	get Iterator<Pair<K,V>> Pairs;

	/// accessor: get Iterator<Pair<K,V>> Iterator
	/// return an iterator that iterates over all the keys in this Dict<K,V>
	/// returning each exactly once in no particular order
	get Iterator<K> Keys;

	/// accessor: get Iterator<Pair<K,V>> Iterator
	/// return an iterator that iterates over all the values in this Dict<K,V>
	/// returning each exactly once in no particular order
	get Iterator<V> Iterator;
    si
si