
namespace System is
    use IO.Std;

    class Coroutine is
        pragma NoWarnUnsafe;

        const int DEFAULT_STACK_SIZE = 32 * 1024;
        
        // FIXME: not thread safe:
        static Coroutine _current;

        char ptr _context;
        public bool is_root;
        Coroutine _caller;

        native char ptr __alloc_ucontext(Coroutine o, int stack_size);
        native int swapcontext(char ptr old_context, char ptr new_context);
        native void GC_capture_current_sp();
        native void GC_clear_current_sp();

        void init(int stack_size) is
            _context = __alloc_ucontext(this, stack_size);
            // _caller = Current;
        si

        void init() is
            _context = __alloc_ucontext(this, DEFAULT_STACK_SIZE);
            // _caller = Current;
        si

        void __coroutine_entry() is
            try
                run();
                if _caller != null then
                    call_(_caller);
                fi
            catch System.Exception se
                native.printf( `uncaught exception %s in coroutine\n`, se.Class.Name.toCString() );
                native.printf( `\t%s\n`, se.Message.toCString() );
                native.printf( `%s\n`, se.Backtrace.toCString() );
                native.__flush_stdout();	    
             yrt
        si

        void run() is
            @Virtual;
        si

/*
        static void call(Coroutine callee) is
            Current.call_(callee);
        si
*/
        void call() is
            Current.call_(this);
        si

        void call_(Coroutine callee) is
            callee._current = this;

            if is_root then               
                // call out of root coroutine: save stack top
                GC_capture_current_sp();
            fi

            // FIXME: should probably be atomic:

            // also, is this actually needed? should return from swapcontext
            // and immediately set _current = this (which will be callee);
            _current = callee; 

            swapcontext(_context, callee._context);

            _current = this;

            if is_root then
                // call into root coroutine: clear stack top
                GC_clear_current_sp();
            fi
        si
  
        get Coroutine Caller is
            return _caller;
        si

        set Coroutine Caller = c is
            _caller = c;
        si

        static get Coroutine Current is
            if _current == null then
                _current = new Coroutine();
                _current.is_root = true;
            fi
            return _current;
        si
    si
si