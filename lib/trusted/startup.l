#K
pragma NoWarnUnsafe, NoMarkUnsafe;

namespace System is
    /// Program startup. Sets up exception handler for all unhandled exceptions and calls user program entry point.
    class Startup is
	public static bool http_mode;

        /// Handle an uncaught exception. Calls C-library to display backtrace in case L runtime is in an unstable state and
        /// then exits program
        /// \param se uncaught exception to handle
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

	/// L-code entry point. Called by assembler runtime after Main class instance created. Calls generated
	/// function __main_init in entry.S which in turn calls Main.init(). This is needed to support Main
	/// classes that do not inherit from Object
	/// \param main instance of Main class to call method init() on
	static void run(System.Object main) is
	    try
		// not safe to call main.init(), main may not actually be an Object and who knows
		// what method, if any, might be in that VTable slot. Instead call thunk in entry.S
		// that knows the mangled name of Main.init() and jumps to it for us:
		native.__main_init(main);
	    catch System.Exception se
	        uncaughtException( se );
	    yrt
	end

        /// Alternative L-code entry point.
        /// \deprecated only safe for classes that inherit from Object
	static void run1(System.Object main) is
	    try
		main.init();
	    catch System.Exception se
	        uncaughtException( se );
	    yrt
	end
    end
end