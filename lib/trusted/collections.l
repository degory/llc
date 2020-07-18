namespace Collections is
    // Collections.IEnumerable`1
    interface Iterable<T> is
        // GetEnumerator
        Iterator<T> get_enumerator();
    si
si

namespace Collections is
    // Collections.IEnumerator`1
    interface Iterator<T> is
        // DotNET:
        bool move_next();
        get T current;

        // L
        bool hasMoreElements();
        T nextElement();
    si
si

namespace Collections is
    // Collections.IReadOnlyCollection`1
    interface Bag<T> isa Iterable<T> /*System.Collections.IEnumerable */ is
        // property Count
        get int count;

    si
si
namespace Collections is
    // Collections.ICollection`1
    interface MutableBag<T> isa Iterable<T> /*System.Collections.IEnumerable */ is
        // Add
        void add(T item);

        // Clear
        void clear();

        // Contains
        bool contains(T item);

        // CopyTo
        void copy_to(T[] array, int array_index);

        // Remove
        bool remove(T item);

        // property Count
        get int count;

        // property IsReadOnly
        get bool is_read_only;

    si
si
namespace Collections is
    // Collections.IReadOnlyList`1
    interface List<T> isa Bag<T> /*Iterable<T> System.Collections.IEnumerable */ is
        // indexer Item
        get T [int index];

    si
si
namespace Collections is
    // Collections.IList`1
    interface MutableList<T> isa MutableBag<T> /*Iterable<T> System.Collections.IEnumerable */ is
        // IndexOf
        int index_of(T item);

        // Insert
        void insert(int index, T item);

        // RemoveAt
        void remove_at(int index);

        // indexer Item
        get T [int index];
        set T [int index] = value;

    si
si
namespace Collections is
    // Collections.List`1
    class LIST<T> isa System.Object do MutableList<T>,MutableBag<T>,Iterable<T>,System.Collections.IEnumerable,System.Collections.IList,System.Collections.ICollection,List<T>,Bag<T> is
        // Add
        void add(T item) is si

        // AddRange
        void add_range(Iterable<T> collection) is si

        // AsReadOnly
        System.Collections.ObjectModel.ReadOnlyCollection<T> as_read_only() is si

        // BinarySearch
        int binary_search(int index, int count, T item, Comparer<T> comparer) is si

        // BinarySearch
        int binary_search(T item) is si

        // BinarySearch
        int binary_search(T item, Comparer<T> comparer) is si

        // Clear
        void clear() is si

        // Contains
        bool contains(T item) is si

        // LIST<TOutput> convert_all<TOutput>(System.Converter<T,TOutput> converter) is si

        // CopyTo
        void copy_to(T[] array) is si

        // CopyTo
        void copy_to(int index, T[] array, int array_index, int count) is si

        // CopyTo
        void copy_to(T[] array, int array_index) is si

        // Exists
        bool exists(System.Predicate<T> match) is si

        // Find
        T find(System.Predicate<T> match) is si

        // FindAll
        LIST<T> find_all(System.Predicate<T> match) is si

        // FindIndex
        int find_index(System.Predicate<T> match) is si

        // FindIndex
        int find_index(int start_index, System.Predicate<T> match) is si

        // FindIndex
        int find_index(int start_index, int count, System.Predicate<T> match) is si

        // FindLast
        T find_last(System.Predicate<T> match) is si

        // FindLastIndex
        int find_last_index(System.Predicate<T> match) is si

        // FindLastIndex
        int find_last_index(int start_index, System.Predicate<T> match) is si

        // FindLastIndex
        int find_last_index(int start_index, int count, System.Predicate<T> match) is si

        // ForEach
        void for_each(Ghul.ACTION_0<T> action) is si

        // GetEnumerator
        Collections.Enumerator<T> get_enumerator() is si

        // GetRange
        LIST<T> get_range(int index, int count) is si

        // IndexOf
        int index_of(T item) is si

        // IndexOf
        int index_of(T item, int index) is si

        // IndexOf
        int index_of(T item, int index, int count) is si

        // Insert
        void insert(int index, T item) is si

        // InsertRange
        void insert_range(int index, Iterable<T> collection) is si

        // LastIndexOf
        int last_index_of(T item) is si

        // LastIndexOf
        int last_index_of(T item, int index) is si

        // LastIndexOf
        int last_index_of(T item, int index, int count) is si

        // Remove
        bool remove(T item) is si

        // RemoveAll
        int remove_all(System.Predicate<T> match) is si

        // RemoveAt
        void remove_at(int index) is si

        // RemoveRange
        void remove_range(int index, int count) is si

        // Reverse
        void reverse() is si

        // Reverse
        void reverse(int index, int count) is si

        // Sort
        void sort() is si

        // Sort
        void sort(Comparer<T> comparer) is si

        // Sort
        void sort(int index, int count, Comparer<T> comparer) is si

        // Sort
        void sort(System.Comparison<T> comparison) is si

        // ToArray
        T[] to_array() is si

        // TrimExcess
        void trim_excess() is si

        // TrueForAll
        bool true_for_all(System.Predicate<T> match) is si

        // GetType
        System.Type get_type() is si

        // ToString
        System.String to_string() is si

        // Equals
        bool equals(System.Object obj) is si

        // GetHashCode
        int get_hash_code() is si

        // .ctor
        void init();
        // .ctor
        void init(int capacity);
        // .ctor
        void init(Iterable<T> collection);
        // property Capacity
        get int capacity is si
        set int capacity = value is si

        // property Count
        get int count is si

        // indexer Item
        get T [int index] is si
        set T [int index] = value is si

    si
si
namespace Collections is
    class PAIR<TKey,TValue> is
        public TKey key;
        public TValue value;

        void init(TKey key, TValue value) is
            this.key = key;
            this.value = value;
        si
    si

    // Collections.IReadOnlyDictionary`2
    interface Map<TKey,TValue> isa Bag<PAIR<TKey,TValue>> /*Iterable<Collections.KeyValuePair<TKey,TValue>> System.Collections.IEnumerable */ is
        // ContainsKey
        bool contains_key(TKey key);

        // TryGetValue
        bool try_get_value(TKey key, TValue ref value);

        // indexer Item
        get TValue [TKey key];

        // property Keys
        get Iterable<TKey> keys;

        // property Values
        get Iterable<TValue> values;

    si
si
namespace Collections is
    // Collections.IDictionary`2
    interface MutableMap<TKey,TValue> isa MutableBag<Collections.KeyValuePair<TKey,TValue>> /*Iterable<Collections.KeyValuePair<TKey,TValue>> System.Collections.IEnumerable */ is
        // ContainsKey
        bool contains_key(TKey key);

        // Add
        void add(TKey key, TValue value);

        // Remove
        bool remove(TKey key);

        // TryGetValue
        bool try_get_value(TKey key, TValue ref value);

        // indexer Item
        get TValue [TKey key];
        set TValue [TKey key] = value;

        // property Keys
        get MutableBag<TKey> keys;

        // property Values
        get MutableBag<TValue> values;

    si
si
namespace Collections is
    // Collections.Dictionary`2
    class MAP<TKey,TValue> isa System.Object do MutableMap<TKey,TValue>,MutableBag<Collections.KeyValuePair<TKey,TValue>>,Iterable<Collections.KeyValuePair<TKey,TValue>>,System.Collections.IEnumerable,System.Collections.IDictionary,System.Collections.ICollection,Map<TKey,TValue>,Bag<Collections.KeyValuePair<TKey,TValue>>,System.Runtime.Serialization.ISerializable,System.Runtime.Serialization.IDeserializationCallback is
        // Add
        void add(TKey key, TValue value) is si

        // Clear
        void clear() is si

        // ContainsKey
        bool contains_key(TKey key) is si

        // ContainsValue
        bool contains_value(TValue value) is si

        // GetEnumerator
        Collections.Enumerator<TKey,TValue> get_enumerator() is si

        // GetObjectData
        void get_object_data(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context) is si

        // OnDeserialization
        void on_deserialization(System.Object sender) is si

        // Remove
        bool remove(TKey key) is si

        // Remove
        bool remove(TKey key, TValue ref value) is si

        // TryGetValue
        bool try_get_value(TKey key, TValue ref value) is si

        // TryAdd
        bool try_add(TKey key, TValue value) is si

        // EnsureCapacity
        int ensure_capacity(int capacity) is si

        // TrimExcess
        void trim_excess() is si

        // TrimExcess
        void trim_excess(int capacity) is si

        // GetType
        System.Type get_type() is si

        // ToString
        System.String to_string() is si

        // Equals
        bool equals(System.Object obj) is si

        // GetHashCode
        int get_hash_code() is si

        // .ctor
        void init();
        // .ctor
        void init(int capacity);
        // .ctor
        void init(EqualityComparer<TKey> comparer);
        // .ctor
        void init(int capacity, EqualityComparer<TKey> comparer);
        // .ctor
        void init(MutableMap<TKey,TValue> dictionary);
        // .ctor
        void init(MutableMap<TKey,TValue> dictionary, EqualityComparer<TKey> comparer);
        // .ctor
        void init(Iterable<Collections.KeyValuePair<TKey,TValue>> collection);
        // .ctor
        void init(Iterable<Collections.KeyValuePair<TKey,TValue>> collection, EqualityComparer<TKey> comparer);
        // property Comparer
        get EqualityComparer<TKey> comparer is si

        // property Count
        get int count is si

        // property Keys
        get Collections.KeyCollection<TKey,TValue> keys is si

        // property Values
        get Collections.ValueCollection<TKey,TValue> values is si

        // indexer Item
        get TValue [TKey key] is si
        set TValue [TKey key] = value is si

    si
si
namespace Collections is
    // Collections.KeyValuePair`2
    class KeyValuePair<TKey,TValue> isa System.ValueType is
        // ToString
        System.String to_string() is si

        // Deconstruct
        void deconstruct(TKey ref key, TValue ref value) is si

        // Equals
        bool equals(System.Object obj) is si

        // GetHashCode
        int get_hash_code() is si

        // GetType
        System.Type get_type() is si

        // .ctor
        void init(TKey key, TValue value);
        // property Key
        get TKey key is si

        // property Value
        get TValue value is si

    si
si
namespace Collections is
    // Collections.IReadOnlySet`1
    interface IReadOnlySet<T> isa Bag<T> /*Iterable<T> System.Collections.IEnumerable */ is
        // Contains
        bool contains(T item);

        // IsProperSubsetOf
        bool is_proper_subset_of(Iterable<T> other);

        // IsProperSupersetOf
        bool is_proper_superset_of(Iterable<T> other);

        // IsSubsetOf
        bool is_subset_of(Iterable<T> other);

        // IsSupersetOf
        bool is_superset_of(Iterable<T> other);

        // Overlaps
        bool overlaps(Iterable<T> other);

        // SetEquals
        bool set_equals(Iterable<T> other);

    si
si
namespace Collections is
    // Collections.ISet`1
    interface MutableSet<T> isa MutableBag<T> /*Iterable<T> System.Collections.IEnumerable */ is
        // Add
        bool add(T item);

        // UnionWith
        void union_with(Iterable<T> other);

        // IntersectWith
        void intersect_with(Iterable<T> other);

        // ExceptWith
        void except_with(Iterable<T> other);

        // SymmetricExceptWith
        void symmetric_except_with(Iterable<T> other);

        // IsSubsetOf
        bool is_subset_of(Iterable<T> other);

        // IsSupersetOf
        bool is_superset_of(Iterable<T> other);

        // IsProperSupersetOf
        bool is_proper_superset_of(Iterable<T> other);

        // IsProperSubsetOf
        bool is_proper_subset_of(Iterable<T> other);

        // Overlaps
        bool overlaps(Iterable<T> other);

        // SetEquals
        bool set_equals(Iterable<T> other);

    si
si
namespace Collections is
    // Collections.HashSet`1
    class SET<T> isa System.Object do MutableBag<T>,Iterable<T>,System.Collections.IEnumerable,MutableSet<T>,Bag<T>,Collections.IReadOnlySet<T>,System.Runtime.Serialization.ISerializable,System.Runtime.Serialization.IDeserializationCallback is
        // Clear
        void clear() is si

        // Contains
        bool contains(T item) is si

        // Remove
        bool remove(T item) is si

        // GetEnumerator
        Collections.Enumerator<T> get_enumerator() is si

        // GetObjectData
        void get_object_data(System.Runtime.Serialization.SerializationInfo info, System.Runtime.Serialization.StreamingContext context) is si

        // OnDeserialization
        void on_deserialization(System.Object sender) is si

        // Add
        bool add(T item) is si

        // TryGetValue
        bool try_get_value(T equal_value, T ref actual_value) is si

        // UnionWith
        void union_with(Iterable<T> other) is si

        // IntersectWith
        void intersect_with(Iterable<T> other) is si

        // ExceptWith
        void except_with(Iterable<T> other) is si

        // SymmetricExceptWith
        void symmetric_except_with(Iterable<T> other) is si

        // IsSubsetOf
        bool is_subset_of(Iterable<T> other) is si

        // IsProperSubsetOf
        bool is_proper_subset_of(Iterable<T> other) is si

        // IsSupersetOf
        bool is_superset_of(Iterable<T> other) is si

        // IsProperSupersetOf
        bool is_proper_superset_of(Iterable<T> other) is si

        // Overlaps
        bool overlaps(Iterable<T> other) is si

        // SetEquals
        bool set_equals(Iterable<T> other) is si

        // CopyTo
        void copy_to(T[] array) is si

        // CopyTo
        void copy_to(T[] array, int array_index) is si

        // CopyTo
        void copy_to(T[] array, int array_index, int count) is si

        // RemoveWhere
        int remove_where(System.Predicate<T> match) is si

        // EnsureCapacity
        int ensure_capacity(int capacity) is si

        // TrimExcess
        void trim_excess() is si

        // CreateSetComparer
        static EqualityComparer<SET<T>> create_set_comparer() is si

        // GetType
        System.Type get_type() is si

        // ToString
        System.String to_string() is si

        // Equals
        bool equals(System.Object obj) is si

        // GetHashCode
        int get_hash_code() is si

        // .ctor
        void init();
        // .ctor
        void init(EqualityComparer<T> comparer);
        // .ctor
        void init(int capacity);
        // .ctor
        void init(Iterable<T> collection);
        // .ctor
        void init(Iterable<T> collection, EqualityComparer<T> comparer);
        // .ctor
        void init(int capacity, EqualityComparer<T> comparer);
        // property Count
        get int count is si

        // property Comparer
        get EqualityComparer<T> comparer is si

    si
si
namespace System is
    // System.IComparable`1
    interface IComparable<T> is
        // CompareTo
        int compare_to(T other);

    si
si
namespace Collections is
    // Collections.IComparer`1
    interface Comparer<T> is
        // Compare
        int compare(T x, T y);

    si
si
namespace Collections is
    // Collections.IEqualityComparer`1
    interface EqualityComparer<T> is
        // Equals
        bool equals(T x, T y);

        // GetHashCode
        int get_hash_code(T obj);

    si
si
namespace System is
    // System.IEquatable`1
    interface IEquatable<T> is
        // Equals
        bool equals(T other);

    si
si
namespace System.Collections is
    interface  IEnumerable is
    si
si

namespace System is
    interface  IConvertible is
    si
si
namespace System is
    interface  IComparable is
    si
si

namespace System is
    interface  IFormattable is
    si
si

namespace System is
    class Converter<TInput,TOutput> isa System.MulticastDelegate do System.ICloneable,System.Runtime.Serialization.ISerializable is
    si
si
namespace System is
    interface  ICloneable is
    si
si

namespace System is
    class Predicate<T> isa System.MulticastDelegate do System.ICloneable,System.Runtime.Serialization.ISerializable is
    si
si
namespace System is
    class ACTION_0<T> isa System.MulticastDelegate do System.ICloneable,System.Runtime.Serialization.ISerializable is
    si
si
namespace System is
    class Comparison<T> isa System.MulticastDelegate do System.ICloneable,System.Runtime.Serialization.ISerializable is
    si
si
namespace System is
    class ValueType isa System.Object is
    si
si
