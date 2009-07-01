
import gqueue;
import signal;

namespace Generic {
    use Util.Lock;
    use Util.Signal;

    /// A thread-safe multi-reader multi-writer Queue
    /// \param T the type of values queued
    class LockedQueue<T> extends Queue<T> {
	Lock lock;
	Signal not_full;
	Signal not_empty;

	/// Construct a new LockedQueue
	/// \param size the number of values the queue will hold
	void init( int size ) {
	    super.init(size);
	    
	    lock = new Lock();
	    not_full = new Signal(lock);
	    not_empty = new Signal(lock);
	}

	/// Wait for available space and then add a value to the write end of the queue
	/// \param v value to add to the queue
	void add( T v ) {
	    try {
		lock.lock();
		while( IsFull ) {
		    not_full.wait(3);
		}

		bool was_empty = IsEmpty;
		super.add( v );

		if( was_empty ) {
		    not_empty.signal();
		}
	    } finally {
		lock.unlock();
	    }
	}

	/// Wait for an available value and then remove a value from the read end of the queue
	T remove() {
	    try {
		lock.lock();
		while( IsEmpty ) {
		    not_empty.wait(3);
		}

		bool was_full = IsFull;

		T result = super.remove();

		if( was_full ) {
		    not_full.signal();
		}	

		return result;
	    } finally {
		lock.unlock();
	    }
	}      
    }
}