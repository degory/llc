
import lock;

pragma NoWarnUnsafe;

namespace Util {
    /// Internal structure holding a pthread cond
    struct PThreadCond {
    }


    /// Allows threads to wait for and send a signal
    class Signal extends System.Object {
	PThreadCond cond;
	Lock lock;

        /// construct a new Signal with its own associated Lock
	void init() {
	    this.init( new Lock() );
	}

        /// construct a new Signal associated with supplied Lock
        /// \param lock Lock to associate with this Signal
	void init( Lock lock ) {
	    cond = cast<PThreadCond>(native.__cond_alloc());
	    this.lock = lock;
	}

        /// Lock this Signal's associated lock
	void lock() {
	    lock.lock();
	}

        /// Unlock this Signal's associated lock
	void unlock() {
	    lock.unlock();
	}

        /// Release this Thread's Lock, wait for another Thread to signal this signal then reacquire the Lock. Wait for signal indefinitely
        /// unless interrupted.
        /// Behaviour is undefined if Lock is not owned
        /// by calling thread.
        /// \return true if signal received, false otherwise
	bool wait() {
	    native.__cond_wait( cond, lock._mutex );
	}

        /// Release this Thread's Lock, wait for another Thread to signal this signal then reacquire the Lock. Wait given number of seconds
        /// for signal unless interrupted. Behaviour is undefined if Lock is not owned by calling thread.
        /// \return true if signal received, false otherwise
	bool wait( int seconds ) {
	    native.__cond_wait_timed( cond, lock._mutex, seconds );
	}

        /// Wake one Thread waiting for this Signal
	void signal() {
	    native.pthread_cond_signal( cond );
	}

        /// Wake all Threads waiting for this Signal
	void signalAll() {
	    native.pthread_cond_broadcast( cond );
	}
    }
}