#K

import object;
import iterator;

namespace Util is
    class ListException extends System.Exception is
	void init( System.String s ) is
	    super.init(s);
	end
    end

    private class ListIterator extends Iterator is
	RealList _head;
	void init( RealList h ) is
	    super.init();
	    _head = h;
	end

	bool hasMoreElements() is
	    return _head != null;
	end

	System.Object nextElement() is
	    if _head == null then
		return null;    
	    fi

	    System.Object result = _head.getValue();
	    _head = _head.getTail();

	    return result;
	end
    end

    /// A linked list of Objects.
    /// \deprecated Use Generic.LinkedList<T> instead
    class List extends System.Object is
	RealList list;
	void init() is
	    super.init();
	end

	void add( System.Object v ) is
	    if list == null then
		list = new RealList( v, null );
	    else
		list.append( v );
	    fi
	end

	void remove( System.Object v ) is
	    if list != null then
		list = list.remove(v);
	    else
		throw new ListException( "remove from empty List" );
	    fi
	end

	void push( System.Object v ) is
	    if list == null then
		list = new RealList( v, null );
	    else
		list.insert( v );
	    fi
	end

	bool isEmpty() is
	    return list == null;
	end

	System.Object pop() is
	    if list != null then
		System.Object result = list.getValue();
		list = list.getTail();
		return result;
	    else
		throw new ListException( "pop from empty List" );
	    fi
	end

	get System.Object Head is
	    if list != null then
		return list.getValue();
	    else
		return null;
	    fi
	end

	Iterator elements() is
	    return new ListIterator(list);
	end
    end

    /// A linked list of Objects.
    /// \deprecated Use Generic.RealList<T> instead
    class RealList extends System.Object is
	RealList tail;
	System.Object value;

	void init( System.Object v, RealList t ) is
	    super.init();
	    value = v;
	    tail = t;
	end

	void init() is
	    super.init();
	    value = null;
	    tail = null;
	end

	void insert( System.Object v ) is
	    tail = new RealList( value, tail );
	    value = v;
	end

	RealList remove( System.Object v ) is
	    if value == v then
		return tail;
	    else
		tail = tail.remove( v );
	    fi
	end

	get System.Object Value is
	    return value;
	end

	get RealList Tail is
	    return tail;
	end

	RealList append( System.Object v ) is
	    if tail == null then
		tail = new RealList(v, null);
		return tail;
	    else
		RealList result = tail.append( v );
		return result;
	    fi
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

	Iterator elements() is
	    return new ListIterator(this);
	end
    end
end
