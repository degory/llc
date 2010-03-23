#K
import gllist.l;

namespace Generic is
    class SortedList<T> isa LinkedList<T> is
	int proc(T, T) compare;

	void init( int proc(T, T) compare ) is
	    super.init();
	    this.compare = compare;
	si

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
    si

    class SortedListNode<T> isa ListNode<T> is
        void init( T v, SortedListNode<T> t ) is
            super.init(v, t );
	si

	void init() is
	    super.init();
	si

	void insert( T v ) is
	    throw new System.NotImplementedException( "Sort order required: use " + Class.Name + ".insert(T v, int proc(T,T))" );
	si

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
    si
si