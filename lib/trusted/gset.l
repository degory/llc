#K

import gbag;
import gmap;

namespace Generic is
    use System.Object;
    use System.String;
    use System.StringBuffer;

    class Set<T> extends System.Object /* implements Bag<T> */ is
    	Map<T,bool> _map;

	void init( int size ) is
	    _map = new Map<T,bool>(size);
	end

	void init() is
	    init( 1021 );
	end

	get int Length is
	    return _map.Length;
        end

	void add( T o ) is
	    _map[o] = true;
	end

	bool contains( T o ) is
	    return _map[o];
	end

	bool isEmpty() is
	    return _map.isEmpty();
	end	    

        void remove( T o ) is
	    _map.remove(o);
        end

	Iterator<T> elements() is
	    return _map.keys();
	end

        String toString() is
	    StringBuffer result = new StringBuffer( "[Set" );
	    foreach T v; elements() do
	        result.append( ' ' );
	        result.append( v );
	    od
	    result.append(']');

 	    return result;
	end
    end
end