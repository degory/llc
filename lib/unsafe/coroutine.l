
import "pcl";

namespace System is
    struct coroutine_t is
    si

    class Coroutine is
    	const int DEFAULT_STACK_SIZE = 32 * 1024;
	coroutine_t _coroutine;

        native int co_thread_init();
        native void co_thread_cleanup();
	native coroutine_t co_create(char ptr func, Coroutine data, char ptr stack, int stacksize);
	native void co_delete(coroutine_t co);
	native void co_call(coroutine_t co);
	native void co_resume();
	native void co_exit_to(coroutine_t co);
	native void co_exit();
	native coroutine_t co_current();
	native char ptr co_get_data(coroutine_t co);
	native char ptr co_set_data(coroutine_t co, char ptr data); 

        native char ptr __get_coroutine_entry();
	native char ptr GC_malloc(int s);

	void init(int stack_size) is
            _coroutine = co_create(__get_coroutine_entry(), this, GC_malloc(stack_size), stack_size);
	si

	void init() is
	    init(DEFAULT_STACK_SIZE);
	si

        void start() is
	    // this.call();
        si

        void __coroutine_entry() is
            try
	        run();
	    catch System.Exception se
                native.printf( `uncaught exception %s in thread\n`, se.Class.Name.toCString() );
                native.printf( `\t%s\n`, se.Message.toCString() );
                native.printf( `%s\n`, se.Backtrace.toCString() );
                native.__flush_stdout();	    
 	    yrt

	    co_exit();
        si

	void run() is
	    @Virtual;
	si

	void call() is
	    co_call(_coroutine);
	si

	void resume() is
	    co_resume();
	si
    si
si