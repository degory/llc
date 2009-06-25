#K

import giterator;

namespace Generic is
    interface Bag<T> is
        void add( T v );
	void remove( T v );
        bool contains( T v );
	bool isEmpty();
	get int Length;
	Iterator<T> elements();
    end
end