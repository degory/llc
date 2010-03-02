#K

import glist;
import giterator;

namespace Generic is
    use System.String;

    /// An Iterator<T> over a LinkedList<T>
    class LinkedListIterator<T> implements Iterator<T> is
	RealList<T> _head;

        /// Construct a new LinkedListIterator referencing the supplied RealList
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

    /// Thrown if an out of bounds LinkedList index is referenced
    class ListBoundsException extends System.BoundsException is
        void init( System.String message ) is
	    super.init(message);
	end
    end 

    /// An ordered resizable list of values implemented as a linked list
    /// \param T the type of values in this list
    class LinkedList<T> implements List<T> is
	protected RealList<T> list;
	void init() is
	    super.init();
	end

	/// Append supplied value after last element in this LinkedList
	/// \param v the value to append
	void add( T v ) is
	    if list == null then
		list = new RealList<T>( v, null );
	    else
		list.append( v );
	    fi
	end

	/// Append supplied values after last element in this LinkedList
	/// \param v the value to append
	void add( Iterator<T> v ) is
	    foreach var t; v.Iterator do
	        add(t);
	    od
	end              

	/// Remove first occurance, if any, of supplied value from this LinkedList
	/// \param v the value to remove
	void remove( T v ) is
	    if list != null then
		list = list.remove(v);
	    else
		throw new ListBoundsException( "remove from empty List" );
	    fi
	end

	/// Return true if this LinkedList contains the supplied value
	/// \param v the value to look for
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
	
	/// Indexer: get T[int index]
	/// \param index the index of the value to get
	/// \return value at index
	get T[int index] is
	    if list == null then
	        throw new ListBoundsException( "index out of bounds" );
            else 
	        return list[index];
	    fi
	end

	/// Indexer: set T[int index] = v
	/// \param index the index of the value to set
	/// \param v the value to set
	set T[int index] = v is
	    if list == null || index < 0 then
	        throw new ListBoundsException( "index out of bounds" );
            else 
	        list[index] = v;
 	    fi
	end	 
	
	/// Is this list empty?
        /// \return true if list contains no values, false otherwise
	bool isEmpty() is
	    return list == null;
	end

	/// Accessor: get int Length
	/// Get the length of the list
	/// \return number of values in the list
	get int Length is
	    if list == null then
		return 0;
	    else
		return list.Length;
	    fi
	end

	/// Remove and return the first value in this LinkedList
	/// \return removed value
	/// \throw ListException if list is empty
	T pull() is
	    if list != null then
		T result = list.Value;
		list = list.Tail;
		return result;
	    else
		throw new ListBoundsException( "pull from empty List" );
	    fi
	end

	/// Remove and return the last value in this LinkedList
	/// \return removed value
	/// \throw ListException if list is empty
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
		throw new ListBoundsException( "pop from empty List" );
	    fi
	end

	/// Accessor: get T Head
	/// Get the first value in the list
	/// \return the first value in this LinkedList or T.none if the list is empty
	get T Head is
	    if list != null then
		return list.Value;
	    else
		return null;
	    fi
	end

	/// Get iterator
	/// \return Iterator<T> that returns each element of this LinkedList in turn from first to last
	LinkedListIterator<T> elements() is
	    return new LinkedListIterator<T>(list);
	end

	/// Get iterator
	/// \return Iterator<T> that returns each element of this LinkedList in turn from first to last
	get LinkedListIterator<T> Iterator is
	    return new LinkedListIterator<T>(list);
	end

        String toString() is
	    if list != null then
	        return list.toString();
	    else
	        return "";
	    fi
	end
    end

    /// Internal linked list implementation for LinkedList<T>
    class RealList<T> is
	protected RealList<T> tail;
	protected T value;

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
		if tail != null then
		    tail = tail.remove( v );
                fi
		return this;
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
	        throw new ListBoundsException( "index out of bounds" );
	    else
		return tail[index-1];
	    fi
	end

	set T[int index] = v is
	    if index == 0 then
	        value = v;
	    elif tail == null then
	        throw new ListBoundsException( "index out of bounds" );
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
	        throw new ListBoundsException( "pop from empty list" );
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
  	        buffer.append(value.toString());
	    else
		buffer.append("null");
	    fi

	    if tail != null then
		buffer.append(',');
		tail.cat(buffer);
	    fi
	end

	System.String toString() is
	    System.StringBuffer result = new System.StringBuffer( "" );
	    cat( result );
	    return result;
	end

	LinkedListIterator<T> elements() is
	    return new LinkedListIterator<T>(this);
	end
    end
end
