import glist;
import giterator;

namespace Collections is
    use System.String;

    /// An Iterator<T> over a LinkedList<T>
    class LINKED_LIST_ITERATOR<T> do Iterator<T> is
        LIST_NODE<T> _head;

        /// Construct a new LinkedListIterator referencing the supplied LIST_NODE
        void init( LIST_NODE<T> h ) is
            super.init();
            _head = h;
        si

        bool next() is
            _head = _head.Tail;

            return _head != null;
        si

        get T current is
            return _head.Value;
        si
    si

    /// Thrown if an out of bounds LinkedList index is referenced
    class LIST_BOUNDS_EXCEPTION isa System.BoundsException is
        void init( System.String message ) is
            super.init(message);
        si
    si 

    /// An ordered resizable list of values implemented as a linked list
    /// \param T the type of values in this list
    class LINKED_LIST<T> do List<T> is
        protected LINKED_LIST_NODE<T> list;

        void init() is
            super.init();
        si

        /// Append supplied value after last element in this LINKED_LIST
        /// \param v the value to append
        void add( T v ) is
            if list == null then
                list = new LINKED_LIST_NODE<T>( v, null );
            else
                list.append( v );
            fi
        si

        /// Append supplied values after last element in this LINKED_LIST
        /// \param v the values to append
        void add( Iterable<T> v ) is
            foreach var t; v.Iterator do
                add(t);
            od
        si              

        /// Remove first occurance, if any, of supplied value from this LINKED_LIST
        /// \param v the value to remove
        void remove( T v ) is
            if list != null then
                list = list.remove(v);
            else
                throw new ListBoundsException( "remove from empty List" );
            fi
        si

        /// Return true if this LINKED_LIST contains the supplied value
        /// \param v the value to look for
        bool contains( T v ) is
            if list != null then
                return list.contains(v);
            else
                return false;
            fi
        si

        void lengthen( int l ) is   
        si

        /// Indexer: get T[int index]
        /// \param index the index of the value to get
        /// \return value at index
        get T[int index] is
            if list == null then
                throw new ListBoundsException( "index out of bounds" );
            else 
                 return list[index];
            fi        
        si

        /// Indexer: set T[int index] = v
        /// \param index the index of the value to set
        /// \param v the value to set
        set T[int index] = v is
            if list == null || index < 0 then
                throw new ListBoundsException( "index out of bounds" );
            else 
                list[index] = v;
            fi
        si   
    
        /// Accessor: get int Length
        /// Get the length of the list
        /// \return number of values in the list
        get int length is
            if list == null then
                return 0;
            else
                return list.length;
            fi
        si

        /// Accessor: get T Head
        /// Get the first value in the list
        /// \return the first value in this LINKED_LIST or T.none if the list is empty
        get T head is
            if list != null then
                return list.Value;
            else
                return null;
            fi
        si

        /// Get iterator
        /// \return Iterator<T> that returns each element of this LINKED_LIST in turn from first to last
        LINKED_LIST_ITERATOR<T> elements() is
            return new LINKED_LIST_ITERATOR<T>(new LINKED_LIST_NODE<T>(T.none, list));
        si

        String to_string() is
            if list != null then
                return list.toString();
            else
                return "";
            fi
        si

        get Slice<T>[Range<int> r] is
            return new Slice<T>(this, r.from, r.to);
        si

        LINKED_LIST<T> copy() is
            var result = new LINKED_LIST<T>();
            if list != null then
                result.list = list.copy();
            fi

            return result;
        si
    si

    /// Internal linked list implementation for LINKED_LIST<T>
    class LINKED_LIST_NODE<T> is
        public LINKED_LIST_NODE<T> tail;
        public T value;

        void init( T v, LINKED_LIST_NODE<T> t ) is
            super.init();
            value = v;
            tail = t;
        si

        void init() is
            super.init();
            value = null;
            tail = null;
        si

        void insert( T v ) is
            tail = new LINKED_LIST_NODE<T>( value, tail );
            value = v;
        si

        LINKED_LIST_NODE<T> remove( T v ) is
            if value == v then
                return tail;
            else
                if tail != null then
                    tail = tail.remove( v );
                fi
                return this;
            fi
        si

        bool contains( T v ) is
            if value == v then
                return true;
            elif tail != null then
                return tail.contains(v);
            else
                return false;
            fi
        si

        get T[int index] is 
            if index == 0 then
                return value;
            elif tail == null then
                throw new ListBoundsException( "index out of bounds" );
            else
                return tail[index-1];
            fi
        si

        set T[int index] = v is
            if index == 0 then
                value = v;
            elif tail == null then
                throw new ListBoundsException( "index out of bounds" );
            else
                tail[index-1] = v;
            fi
        si

        LINKED_LIST_NODE<T> append( T v ) is
            if tail == null then
                tail = new LINKED_LIST_NODE<T>(v, null);
                return tail;
            else
                LINKED_LIST_NODE<T> result = tail.append( v );
                return result;
            fi
        si

        get int length is
            int result = 1;
            LINKED_LIST_NODE<T> t = tail;
            while t != null do
                result = result + 1;
                t = t.tail;
            od

            return result;
        si

        private void cat( System.StringBuffer buffer ) is
            if value != null then
                buffer.append(value.toString());
            else
                buffer.append("<null>");
            fi

            if tail != null then
                buffer.append(',');
                tail.cat(buffer);
            fi
        si

        System.String to_string() is
            System.StringBuffer result = new System.StringBuffer( "" );
            cat( result );
            return result;
        si

        /*
        LINKED_LIST_ITERATOR<T> elements() is
            return new LINKED_LIST_ITERATOR<T>(this);
        si
        */

        LINKED_LIST_NODE<T> copy() is
            if tail != null then
                return new LINKED_LIST_NODE<T>(value, tail.copy());
            else
                return new LINKED_LIST_NODE<T>(value, null);
            fi
        si
    si
si
