#K

import glist;
import giterator;

namespace Generic is
    class ListIterator<T> extends System.Object implements Iterator<T> is
	RealList<T> _head;
	void init( RealList<T> h ) is
	    super.init();
	    _head = h;
	end

	bool hasMoreElements() is
	    return _head != null;
	end

	T nextElement() is
	    if _head == null then
		return null;    
	    fi

	    T result = _head.Value;
	    _head = _head.Tail;

	    return result;
	end
    end

    class ListException extends System.Exception is
        void init( System.String message ) is
	    super.init(message);
	end
    end 

    class LinkedList<T> extends System.Object implements List<T> is
	RealList<T> list;
	void init() is
	    super.init();
	end

	void add( T v ) is
	    if list == null then
		list = new RealList<T>( v, null );
	    else
		list.append( v );
	    fi
	end

	void remove( T v ) is
	    if list != null then
		list = list.remove(v);
	    else
		throw new ListException( "remove from empty List" );
	    fi
	end

	bool contains( T v ) is
	    if list != null then
	        return list.contains(v);
	    else
	        return false;
	    fi
	end

	void lengthen( int l ) is	
	end

	void push( T v ) is
	    add(v);
	end

	get T[int index] is
	    if list == null then
	        throw new ListException( "index out of bounds" );
            else 
	        return list[index];
	    fi
	end

	set T[int index] = v is
	    if list == null || index < 0 then
	        throw new ListException( "index out of bounds" );
            else 
	        list[index] = v;
 	    fi
	end	 

	bool isEmpty() is
	    return list == null;
	end

	get int Length is
	    if list == null then
		return 0;
	    else
		return list.Length;
	    fi
	end

	T pull() is
	    if list != null then
		T result = list.Value;
		list = list.Tail;
		return result;
	    else
		throw new ListException( "pull from empty List" );
	    fi
	end

	T pop() is
	    if list != null then
		if list.Tail == null then
  		    T result = list.Value;
		    list = null;
		    return result;
		else
		    return list.pop();
		fi
	    else
		throw new ListException( "pop from empty List" );
	    fi
	end

	get T Head is
	    if list != null then
		return list.Value;
	    else
		return null;
	    fi
	end

	ListIterator<T> elements() is
	    return new ListIterator<T>(list);
	end
    end

    class RealList<T> extends System.Object is
	RealList<T> tail;
	T value;

	void init( T v, RealList<T> t ) is
	    super.init();
	    value = v;
	    tail = t;
	end

	void init() is
	    super.init();
	    value = null;
	    tail = null;
	end

	void insert( T v ) is
	    tail = new RealList<T>( value, tail );
	    value = v;
	end

	RealList<T> remove( T v ) is
	    if value == v then
		return tail;
	    else
		tail = tail.remove( v );
	    fi
	end

	bool contains( T v ) is
	    if value == v then
	        return true;
	    elif tail != null then
	        return tail.contains(v);
  	    else
	        return false;
	    fi
	end

	get T Value is
	    return value;
	end

	set T Value = v is
	    value = v;
	end

	get RealList<T> Tail is
	    return tail;
	end

	set RealList<T> Tail = t is
	    tail = t;
	end

	get T[int index] is 
	    if index == 0 then
	        return value;
	    elif tail == null then
	        throw new ListException( "index out of bounds" );
	    else
		return tail[index-1];
	    fi
	end

	set T[int index] = v is
	    if index == 0 then
	        value = v;
	    elif tail == null then
	        throw new ListException( "index out of bounds" );
	    else
		tail[index-1] = v;
	    fi
	end

	RealList<T> append( T v ) is
	    if tail == null then
		tail = new RealList<T>(v, null);
		return tail;
	    else
		RealList<T> result = tail.append( v );
		return result;
	    fi
	end

	T pop() is
	    if tail == null then
	        throw new ListException( "pop from empty list" );
	    elif tail.tail == null then
	        T result = tail.value;
		tail = null;
		return result;
	    else
	        return tail.pop();
	    fi	    
	end

	get int Length is
	    int result = 1;
	    RealList<T> t = tail;
	    while t != null do
		result = result + 1;
		t = t.tail;
	    od

	    return result;
	end

	private void cat( System.StringBuffer buffer ) is
	    if value != null then
		buffer.append(value);
	    else
		buffer.append("null");
	    fi

	    if tail != null then
		buffer.append(',');
		tail.cat(buffer);
	    fi
	end

	System.String toString() is
	    System.StringBuffer result = new System.StringBuffer( "[RealList:" );
	    cat( result );
	    result.append(']');
	    return result;
	end

	ListIterator<T> elements() is
	    return new ListIterator<T>(this);
	end
    end
end
