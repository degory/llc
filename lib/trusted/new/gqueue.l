#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved


namespace Generic {
    use System.String;
    use System.Exception;
    use System.Object;

    /// Thrown on full or empty Queue
    class QueueException extends Exception {
        /// Construct a new QueueException
	/// \param message message to include in the exception
	void init( String message ) {
	    super.init(message);
	}
    }
    
    /// A circular buffer of values
    /// \param T the type of values the Queue holds
    class Queue<T> extends Object {
	T[] queue;
	int head;  // elements added here
	int tail;  // elements removed here

	/// Construct a new Queue
	/// \param size how many values the queue will hold
	void init( int size ) {
	    assert( size > 0 );
	    queue = new T[size];
	}

	/// Accessor: get bool IsEmpty
	/// Get is the queue empty
	/// \return true if the queue has no values in it, otherwise false 
	get bool IsEmpty {
	    return head == tail;
	}

	/// Internal method: get the next index wrapping around at the queue end
	/// \param index get the index of the value after this index
	/// \return if index < length - 1 then index + 1, else 0
	int next(int index) {
	    return (index + 1) % queue.length;
	}
	
	/// Accessor: get bool IsFull
	/// Get is the queue full?
	/// \return true if the queue has no more space for additional values, otherwise false
	get bool IsFull {
	    return next(head) == tail;
	}

	/// Add a new value to the write end of the queue
	/// \param v the value to add
	/// \throw QueueException if the queue is already full
	void add( T v ) {
	    int next_head = next(head);
	    if( next_head == tail ) {
		throw new QueueException( "add on full queue" );
	    } else {
		queue[head] = v;
		head = next_head;
	    }
	}

	/// Add a new value to the write end of the queue
	/// \param v the value to add
	/// \return true if value added, otherwise false if the queue is already full
	bool addQuiet( T v ) {
	    int next_head = next(head);
	    if( next_head == tail ) {
		return false;
	    } else {
		queue[head] = v;
		head = next_head;
		return true;
	    }
	}

	/// Remove and return the value from the read end of the queue
	/// \return the removed value
	/// \throw QueueException if the queue is already empty
	T remove() {
	    if( head == tail ) {
		throw new QueueException( "remove on empty queue" );
	    } else {
		T result = queue[tail];
		tail = next(tail);
		return result;
	    }
	}

	/// Remove and return the value from the read end of the queue
	/// \return the removed value if the queue was non-empty, otherwise T.none if the queue was empty
	/// \attention if T.none is ever stored in the queue then the return value of this method is ambiguous
	T removeQuiet() {
	    if( head == tail ) {
		// note for non-Object types this is ambiguous but caller has option
		// of checking IsEmpty first:
		return T.none;
	    } else {
		T result = queue[tail];
		tail = next(tail);
		return result;
	    }
	}
    }
}
