pragma NoWarnUnsafe, NoMarkUnsafe;

import pointer;

namespace System {
    /// A thread of execution within a process.
    class Thread extends System.Object {	
	word _pthread_id;

	/// Constructor
	void init() {
	}

	native void __thread_start(Thread t);
	native void __install_segv_handler();

	native void __set_tls1(Object o);
	native System.Object __get_tls1();

	native void __set_tls2(Object o);
	native System.Object __get_tls2();

	/// Start this Thread. A new operating system thread is created and it begins executing at this Thread's run() method.
	/// Behaviour is undefined if this method is called more than once
	void start() {
	    __thread_start(this);
	}

	/// Internal interface for determining thread id
	/// only use from within thread unless _pthread id known already set:
	word __get_pthread_id() {
	    // cannot rely on either setting this in newly created thread via run() or having creator
            // thread set it after pthread_create returns - either option alone results in a race if
            // non-setting thread immediately wants the id before the setting thread completes setting it.
	    
	    // I think this is safe without locking
	    // - word accesses should be atomic so reading + writing a constant without locking is OK
	    // - doesn't matter if the value changes under us as will only ever change from zero to 
	    //   the value we're about to write anyway: 

	    if( _pthread_id == 0W ) {
		_pthread_id = cast word(native.pthread_self());
		IO.Std.err.println( "self set pthread id is is " + cast int(_pthread_id) );
	    }

	    IO.Std.err.println( "get pthread id is is " + cast int(_pthread_id) );
	    return _pthread_id;
	}

	// called by runtime to set our id shortly after thread is created. If we need the id before then,
	// then we'll call pthread_self() in __get_pthread_id().
	/// Internal interface for setting thread id
        void __set_pthread_id(word id) {
	    _pthread_id = id;
	    IO.Std.err.println( "set pthread id is is " + cast int(_pthread_id) );
	}

	/// Internal entry point into newly started thread from runtime
	void __thread_entry() {
	    try {
		run();
	    } catch( System.Exception se ) {
		native.printf( `uncaught exception %s in thread\n`, se.Class.Name.toCString() );
		native.printf( `\t%s\n`, se.Message.toCString() );
		native.printf( `%s\n`, se.Backtrace.toCString() );
		native.__flush_stdout();
	    }
	    native.pthread_exit();
	}	     

	/// Sleep for a given number of seconds
	/// \param n how many seconds to sleep for
	static void sleep( int n ) {
	    native.sleep(n);
	}

	/// Set thread local storage object 1 for currently executing Thread to supplied Object
	/// \param o object to place in thread local storage slot 1
	static set System.Object TLS1 = o {
	    // IO.Std.err.println( "set tls1: " + cast int(o) );
	    // IO.Std.err.println( "set tls1: " + o );
	    __set_tls1(o);
	}

	/// Get thread local storage object 1 for currently executing Thread
	/// \returns null if object 1 not previously set
	static get System.Object TLS1 {
	    System.Object o = __get_tls1();
	    // IO.Std.err.println( "get tls1: " + cast int(o) );
	    // IO.Std.err.println( "get tls1: " + o );
	    return o;
	}

	/// Set thread local storage object 2 for currently executing Thread to supplied Object
	/// \param o object to place in thread local storage slot 2
	static set System.Object TLS2 = o {
	    __set_tls2(o);
	}

	/// Get thread local storage object 1 for currently executing Thread
	/// \returns null if object 1 not previously set
	static get System.Object TLS2 {
	    return __get_tls2();
	}

	/// Wait for given Thread to exit.
	word waitExit() {
	    Util.Pointer p = new Util.Pointer();
	    native.GC_pthread_join(__get_pthread_id(),p);
	    return p.value;
	}

	/// Entry point for newly created threads. Inherit from Thread and override run()
	void run() {
	    // override me
	}
    }

    /// Internal structure holding a pthread mutex
    struct PThreadMutex {
    }

    /// Internal structure holding a pthread cond
    struct PThreadCond {
    }

    /// Provides mutual exclusion between threads
    class Lock extends System.Object {
	/// Underlying pthread mutex
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

    /// Allows threads to wait for and send a signal
    class Signal extends System.Object {
	/// pthread condition implementing this Signal
	PThreadCond cond;

	/// lock must be held before waiting on Signal
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

	/// Wake one Thread waiting for this signal 
	void signal() {
	    native.pthread_cond_signal( cond );
	}

	/// Wake all Threads waiting for this signal 
	void signalAll() {
	    native.pthread_cond_broadcast( cond );
	}
    }
}
