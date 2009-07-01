
import thread;

namespace Util {
    /// Internal structure holding a pthread mutex
    struct PThreadMutex {
    }

    /// Provides mutual exclusion between threads
    class Lock extends System.Object {
	public PThreadMutex _mutex;

	native PThreadMutex __mutex_alloc();
	native int pthread_mutex_lock(PThreadMutex m);
	native int pthread_mutex_unlock(PThreadMutex m);
	native void pthread_mutex_init(PThreadMutex m);
	native bool __mutex_lock_timed(PThreadMutex m, int seconds);
	native bool __mutex_lock(PThreadMutex m);

        /// Construct a new Lock. Locks are created in unlocked state
	void init() {
	    _mutex = __mutex_alloc();
	    pthread_mutex_init(_mutex);
	    // native.printf( `initialized lock %lp...\n`, m );
	}

	/// Attempt to acquire this Lock. Wait indefinitely unless interrupted. Behaviour is undefined if Lock is already owned
        /// by calling thread
        /// \return true if lock acquired false otherwise
	bool lock() {
	    // native.printf( `>>> locking %lp...\n`, m );
	    return __mutex_lock(_mutex);
	    // native.printf( `>>> locked %lp...\n`, m );
	}

        /// Attempt to acquire this Lock. Wait given number of seconds until lock acquired or interrupted.
        /// Behaviour is undefined if Lock is already owned by calling thread
        /// \param seconds seconds to wait before giving up
        /// \return true if lock acquired false otherwise
	bool lock(int seconds) {
	    return __mutex_lock_timed(_mutex, seconds);
	}

        /// Unlock this Lock. Behaviour is undefined if the lock is not currently owned by the
        /// calling thread
	void unlock() {
	    // native.printf( `<<< unlocking %lp...\n`, m );
	    pthread_mutex_unlock(_mutex);
	    // native.printf( `<<< unlocked %lp...\n`, m );
	}
    }

}