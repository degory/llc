pragma NoWarnUnsafe, NoMarkUnsafe;

import pointer;

namespace System {
    class Thread extends System.Object {	
	word _pthread_id;
	
	void init() {
	}

	native void __thread_start(Thread t);
	native void __install_segv_handler();

	native void __set_tls1(Object o);
	native System.Object __get_tls1();

	native void __set_tls2(Object o);
	native System.Object __get_tls2();

	void start() {
	    __thread_start(this);
	}

	// only use from within thread unless _pthread id known already set:
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
		// IO.Std.err.println( "self set pthread id is is " + cast int(_pthread_id) );
	    }

	    // IO.Std.err.println( "get pthread id is is " + cast int(_pthread_id) );
	    return _pthread_id;
	}

	// called by runtime to set our id shortly after thread is created. If we need the id before then,
	// then we'll call pthread_self() in __get_pthread_id().

        void __set_pthread_id(word id) {
	    _pthread_id = id;
	    // IO.Std.err.println( "set pthread id is is " + cast int(_pthread_id) );
	}

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

	static void sleep( int n ) {
	    native.sleep(n);
	}

	static set System.Object TLS1 = o {
	    // IO.Std.err.println( "set tls1: " + cast int(o) );
	    // IO.Std.err.println( "set tls1: " + o );
	    __set_tls1(o);
	}

	static get System.Object TLS1 {
	    System.Object o = __get_tls1();
	    // IO.Std.err.println( "get tls1: " + cast int(o) );
	    // IO.Std.err.println( "get tls1: " + o );
	    return o;
	}

	static set System.Object TLS2 = o {
	    __set_tls2(o);
	}

	static get System.Object TLS2 {
	    return __get_tls2();
	}

	word waitExit() {
	    Util.Pointer p = new Util.Pointer();
	    native.GC_pthread_join(__get_pthread_id(),p);
	    return p.value;
	}

	void run() {

	}
    }

    struct PThreadMutex {
    }

    struct PThreadCond {
    }

    class Lock extends System.Object {
	public PThreadMutex _mutex;

	native PThreadMutex __mutex_alloc();
	native int pthread_mutex_lock(PThreadMutex m);
	native int pthread_mutex_unlock(PThreadMutex m);
	native void pthread_mutex_init(PThreadMutex m);
	native bool __mutex_lock_timed(PThreadMutex m, int seconds);
	native bool __mutex_lock(PThreadMutex m);

	void init() {
	    _mutex = __mutex_alloc();
	    pthread_mutex_init(_mutex);
	    // native.printf( `initialized lock %lp...\n`, m );
	}

	bool lock() {
	    // native.printf( `>>> locking %lp...\n`, m );
	    return __mutex_lock(_mutex);
	    // native.printf( `>>> locked %lp...\n`, m );
	}

	bool lock(int seconds) {
	    return __mutex_lock_timed(_mutex, seconds);
	}

	void unlock() {
	    // native.printf( `<<< unlocking %lp...\n`, m );
	    pthread_mutex_unlock(_mutex);
	    // native.printf( `<<< unlocked %lp...\n`, m );
	}
    }

    class Signal extends System.Object {
	PThreadCond cond;
	Lock lock;

	void init() {
	    this.init( new Lock() );
	}

	void init( Lock lock ) {
	    cond = cast<PThreadCond>(native.__cond_alloc());
	    this.lock = lock;
	}

	void lock() {
	    lock.lock();
	}

	void unlock() {
	    lock.unlock();
	}

	bool wait() {
	    native.__cond_wait( cond, lock._mutex );
	}

	bool wait( int seconds ) {
	    native.__cond_wait_timed( cond, lock._mutex, seconds );
	}

	void signal() {
	    native.pthread_cond_signal( cond );
	}

	void signalAll() {
	    native.pthread_cond_broadcast( cond );
	}
    }
}
