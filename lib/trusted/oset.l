#K

import map;

namespace Util is
    use System.Object;
    /// A set of Objects.
    /// \deprecated Use Generic.Set<T>
    class Set extends System.Object is
	Map _map;

	void init( int size ) is
	    _map = new Map(size);
	end

	void init() is
	    init( 1021 );
	end

	void add( System.Object o ) is
	    _map.put( o, o );
	end

	bool contains( System.Object o ) is
	    return _map[o] != null;
	end

	Iterator elements() is
	    return _map.elements();
	end
    end
end