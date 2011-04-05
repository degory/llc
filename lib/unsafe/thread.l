// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

pragma NoWarnUnsafe, NoMarkUnsafe;

import pointer;

namespace System is
    /// A thread of execution within a process.
    class Thread isa System.Object is
	word _pthread_id;
        ThreadState state; // keep status pinned by GC as TLS is not scanned
	
	/// Construct a new Thread
	void init() is
	si

	native void __thread_start(Thread t);
	native void __install_segv_handler();

	native void __set_tls1(Object o);
	native System.Object __get_tls1();

	native void __set_tls2(Object o);
	native System.Object __get_tls2();

        /// Start this Thread. A new operating system thread is created and it begins executing at this Thread's run() method.
        /// Behaviour is undefined if this method is called more than once
	void start() is
	    __thread_start(this);
	si

        /// Internal interface for determining thread id
        /// only use from within thread unless _pthread id known already set:
	word __get_pthread_id() is
	    // cannot rely on either setting this in newly created thread via run() or having creator
            // thread set it after pthread_create returns - either option alone results in a race if
            // non-setting thread immediately wants the id before the setting thread completes setting it.
	    
	    // I think this is safe without locking
	    // - word accesses should be atomic so reading + writing a constant without locking is OK
	    // - doesn't matter if the value changes under us as will only ever change from zero to 
	    //   the value we're about to write anyway: 

	    if _pthread_id == 0W then
		_pthread_id = cast word(native.pthread_self());
		// IO.Std.err.println( "self set pthread id is is " + cast int(_pthread_id) );
	    fi

	    // IO.Std.err.println( "get pthread id is is " + cast int(_pthread_id) );
	    return _pthread_id;
	si

	// called by runtime to set our id shortly after thread is created. If we need the id before then,
	// then we'll call pthread_self() in __get_pthread_id().
        /// Internal method: set pthread id
        void __set_pthread_id(word id) is
	    _pthread_id = id;
	    // IO.Std.err.println( "set pthread id is is " + cast int(_pthread_id) );
	si

        /// Internal method: entry point into newly started thread from runtime
	void __thread_entry() is
	    try
                state = ThreadState.Current;
		run();
	    catch System.Exception se
		native.printf( `uncaught exception %s in thread\n`, se.Class.Name.toCString() );
		native.printf( `\t%s\n`, se.Message.toCString() );
		native.printf( `%s\n`, se.Backtrace.toCString() );
		native.__flush_stdout();
	    yrt
	    native.pthread_exit();
	si	     

        /// Suspend execution for period of time
        /// \param n how many seconds to sleep for
	static void sleep( int n ) is
	    native.sleep(n);
	si

	/// Accessor: static set System.Object TLS1 = o
        /// Set thread local storage object 1 for currently executing Thread
        /// \param o object to place in thread local storage slot 1
	static set System.Object TLS1 = o is
	    // IO.Std.err.println( "set tls1: " + cast int(o) );
	    // IO.Std.err.println( "set tls1: " + o );
	    __set_tls1(o);
	si

	/// Accessor: static get System.Object TLS1
        /// Get thread local storage object 1 for currently executing Thread
        /// \returns last TLS1 object set or null if not previously set
	static get System.Object TLS1 is
	    System.Object o = __get_tls1();
	    // IO.Std.err.println( "get tls1: " + cast int(o) );
	    // IO.Std.err.println( "get tls1: " + o );
	    return o;
	si

	/// Accessor: static set System.Object TLS2 = o
        /// Set thread local storage object 2 for currently executing Thread
        /// \param o object to place in thread local storage slot 2
	static set System.Object TLS2 = o is
	    __set_tls2(o);
	si

	/// Accessor: static get System.Object TLS2
        /// Get thread local storage object 2 for currently executing Thread
        /// \returns last TLS2 object set or null if not previously set
	static get System.Object TLS2 is
	    return __get_tls2();
	si

        /// Wait for Thread to exit.
	word waitExit() is
	    Util.Pointer p = new Util.Pointer();
	    // native.GC_pthread_join(__get_pthread_id(),p);
	    native.pthread_join(__get_pthread_id(),p);
	    return p.value;
	si

        /// Entry point for newly created threads. Inherit from Thread and override run()
	void run() is
            @Virtual;
	si

	get ThreadState State is
            return state;
	si

        set ThreadState State = s is
            state = s;
        si
    si

    class ThreadState is
        // Coroutine current_coroutine;
        Thread current_thread;

        void init() is
        si

        static get ThreadState Current is
            var result = cast ThreadState(Thread.TLS1);
            if result == null then
                result = new ThreadState();
                Thread.TLS1 = result;
            fi
            return result;
        si

        static get Thread CurrentThread is
            var c = Current;
            if c.current_thread == null then
                c.current_thread = new Thread();
                c.current_thread.__get_pthread_id();
                c.current_thread.State = c;
            fi
            return c.current_thread;
        si

        // FIXME: not thread safe but combination of TLS + GC seems broken:
        static Coroutine current_coroutine;

        static get Coroutine CurrentCoroutine is
            /*
            var c = Current;
            if c.current_coroutine == null then
                c.current_coroutine = new Coroutine();
                c.current_coroutine.is_root = true;
            fi
            return c.current_coroutine;
            */
            if current_coroutine == null then
                current_coroutine = new Coroutine();
            fi
            return current_coroutine;
        si
    si
si
