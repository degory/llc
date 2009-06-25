#K
pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System is
    class Startup is
	public static bool http_mode;

        static void uncaughtException( System.Exception se ) is
	    if http_mode then
	        native.printf( `Content-type: text/plain\n` );
	    fi
            if se != null then
		native.printf( `uncaught exception %s\n`, se.Class.Name.toCString() );
		native.printf( `\t%s\n`, se.Message.toCString() );
		native.printf( `%s\n`, se.Backtrace.toCString() );
            else
	        native.printf( `null exception\n` );
	    fi
   	    native.__flush_stdout();
	    native.exit(1);
	end

	static void run(System.Object main) is
	    try
		// old entry point code fails to initialize main class vtable
		// so cannot dynamically call main.init() here:
		native.__main_init(main);
	    catch System.Exception se
	        uncaughtException( se );
	    yrt
	end

	static void run1(System.Object main) is
	    try
		main.init();
	    catch System.Exception se
	        uncaughtException( se );
	    yrt
	end
    end
end