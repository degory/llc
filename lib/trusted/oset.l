#K

import map;

namespace Util is
    use System.Object;
    /// A set of Objects.
    /// \deprecated Use Generic.Set<T>
    class Set is
	Map _map;

	void init( int size ) is
	    _map = new Map(size);
	si

	void init() is
	    init( 1021 );
	si

	void add( System.Object o ) is
	    _map.put( o, o );
	si

	bool contains( System.Object o ) is
	    return _map[o] != null;
	si

	Iterator elements() is
	    return _map.elements();
	si
    si
si