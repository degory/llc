#K

import object;
import iterator;

namespace Util is
    class ListException isa System.Exception is
	void init( System.String s ) is
	    super.init(s);
	si
    si

    private class ListIterator isa Iterator is
	ListNode _head;
	void init( ListNode h ) is
	    super.init();
	    _head = h;
	si

	bool hasMoreElements() is
	    return _head != null;
	si

	System.Object nextElement() is
	    if _head == null then
		return null;    
	    fi

	    System.Object result = _head.getValue();
	    _head = _head.getTail();

	    return result;
	si
    si

    /// A linked list of Objects.
    /// \deprecated Use Generic.LinkedList<T> instead
    class List is
	ListNode list;
	void init() is
	    super.init();
	si

	void add( System.Object v ) is
	    if list == null then
		list = new ListNode( v, null );
	    else
		list.append( v );
	    fi
	si

	void remove( System.Object v ) is
	    if list != null then
		list = list.remove(v);
	    else
		throw new ListException( "remove from empty List" );
	    fi
	si

	void push( System.Object v ) is
	    if list == null then
		list = new ListNode( v, null );
	    else
		list.insert( v );
	    fi
	si

	bool isEmpty() is
	    return list == null;
	si

	System.Object pop() is
	    if list != null then
		System.Object result = list.getValue();
		list = list.getTail();
		return result;
	    else
		throw new ListException( "pop from empty List" );
	    fi
	si

	get System.Object Head is
	    if list != null then
		return list.getValue();
	    else
		return null;
	    fi
	si

	Iterator elements() is
	    return new ListIterator(list);
	si
    si

    /// A linked list of Objects.
    /// \deprecated Use Generic.ListNode<T> instead
    class ListNode is
	ListNode tail;
	System.Object value;

	void init( System.Object v, ListNode t ) is
	    super.init();
	    value = v;
	    tail = t;
	si

	void init() is
	    super.init();
	    value = null;
	    tail = null;
	si

	void insert( System.Object v ) is
	    tail = new ListNode( value, tail );
	    value = v;
	si

	ListNode remove( System.Object v ) is
	    if value == v then
		return tail;
	    else
		tail = tail.remove( v );
	    fi
	si

	get System.Object Value is
	    return value;
	si

	get ListNode Tail is
	    return tail;
	si

	ListNode append( System.Object v ) is
	    if tail == null then
		tail = new ListNode(v, null);
		return tail;
	    else
		ListNode result = tail.append( v );
		return result;
	    fi
	si

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
	si

	System.String toString() is
	    System.StringBuffer result = new System.StringBuffer( "[ListNode:" );
	    cat( result );
	    result.append(']');
	    return result;
	si

	Iterator elements() is
	    return new ListIterator(this);
	si
    si
si
