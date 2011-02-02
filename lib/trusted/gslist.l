#K
import gllist;

namespace Generic is
    /// A LinkedList<T> which is kept in sorted order either in the natural order of the elements or ordered by a supplied compare function
    /// \param T the element type of the SortedList<T>
    class SortedList<T> isa LinkedList<T> is
        /// the comparison function used to keep the list in order
	int proc(T, T) compare;

	/// Construct a new SortedList<T> with a specified ordering
	/// \param compare 
	void init( int proc(T, T) compare ) is
	    super.init();
	    this.compare = compare;
	si

	/// Construct a new SortedList<T> with natural ordering
	void init() is
	    this.init( int proc(T, T)(T.opCompare) );
	si

        /// Append supplied value after last element in this LinkedList
        /// \param v the value to append
        void add( T v ) is
            if list == null then
		list = new SortedListNode<T>( v, null );
            elif compare(v, list.Value) <= 0 then
		list = new SortedListNode<T>( v, cast SortedListNode<T>(list) );
	    else
                cast SortedListNode<T>(list).insert(v,compare);
	    fi
	si

	SortedList<T> copy() is
	    var result = new SortedList<T>();
            if list != null then
                result.list = list.copy();
            fi

            return result;
        si

        get SortedList<T> Freeze is
   	    return copy();
        si
    si

    /// A node in a sorted linked list
    /// \param T the element type of the list
    class SortedListNode<T> isa ListNode<T> is
        /// Construct a new SortedListNode<T>
 	/// \param v the new node's value
	/// \param t the new node's tail
        void init( T v, SortedListNode<T> t ) is
            super.init(v, t );
	si

	/// Construct a new empty ListNode<T>
	void init() is
	    super.init();
	si

	/// \attention not implemented
	void insert( T v ) is
	    throw new System.NotImplementedException( "Sort order required: use " + Class.Name + ".insert(T v, int proc(T,T))" );
	si
	
	/// Insert a value into this list at appropriate position
	/// \param v value to insert
	/// \param compare sort order to apply
	void insert( T v, int proc(T,T) compare ) is
	    if compare(v,value) <= 0 then
		throw new ListBoundsException( "value sorts before head of this list" );
	    fi

	    if tail == null then
		tail = new SortedListNode<T>(v, null);
	    elif compare(v,tail.value) <= 0 then
		tail = new SortedListNode<T>(v, cast SortedListNode<T>(tail));
	    else
		cast SortedListNode<T>(tail).insert( v, compare );
	    fi
	si

	SortedListNode<T> copy() is
            if tail != null then
                return new SortedListNode<T>(value, cast SortedListNode<T>(tail).copy());
            else
                return new SortedListNode<T>(value, null);
            fi
        si

    si
si