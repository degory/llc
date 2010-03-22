#K

pragma NoWarnUnsafe, NoMarkUnsafe;

namespace Util is
    /// A process that can fork and run other programs
    class Process is
	const int
	    EAGAIN = 11,
	    ENOMEM = 12,
	    EINTR = 4;

	int pid;
	bool child;

	/// Construct an empty Process
	void init() is
	    super.init();
	si

	/// Throw an Exception for the last operating system error encountered
	/// \param unix_call description of the operating system call that failed
	void throwUnixError( System.String unix_call ) is
	    int errno = cast int(native.__geterrno());
	    // IO.Std.err.println( "unix call failed: " + unix_call + ", errno: " + errno + ", " + cast<char ptr>(native.strerror()) );
	    throw new System.Exception(unix_call + ": " + cast char ptr(native.strerror()));
	si
 
        /// Fork this process
	/// \return true in child process, false in parent process
	/// \throw System.Exception
	bool fork() is
	    // int cpid = cast<int>(native.vfork());
	    int cpid = cast int(native.fork());
	    if cpid < 0 then
		int e = cast int(native.__geterrno());
		IO.Std.err.println( "fork failed: " + e );
		IO.Std.err.flush();

		if e == ENOMEM then
		    System.Thread.sleep(3);
		    return fork();
		elif e == EAGAIN || e == EINTR then
		    return fork();
		else
		    throwUnixError("fork");
		fi
	    else
		if cpid == 0 then
		    // IO.Std.err.println( "fork - in child..." );
		    child = true;
		else
		    // IO.Std.err.println( "fork - in parent, child is process " + cpid );
		    pid = cpid;
		fi
		return child;
	    fi
	si

        /// V-Fork this process
	/// \return true in child process, false in parent process
	/// \attention this is not safe because vfork() has tight restrictions on what the child process may do before it calls exec
	/// that this class does not adhere to
	/// \throw System.Exception
	bool vfork() is
	    // int cpid = cast<int>(native.vfork());
	    int cpid = cast int(native.fork());
	    if cpid < 0 then
		int e = cast int(native.__geterrno());
		IO.Std.err.println( "fork failed: " + e );
		if e == ENOMEM then
		    System.Thread.sleep(3);
		    return fork();
		elif e == EAGAIN || e == EINTR then
		    return fork();
		else 
		    throwUnixError("fork");
		fi
	    else
		if cpid == 0 then
		    // IO.Std.err.println( "fork - in child..." );
		    child = true;
		else
		    // IO.Std.err.println( "fork - in parent, child is process " + cpid );
		    pid = cpid;
		fi
		return child;
	    fi
	si

	/// Is this the child process?
	/// \return true in child process, false in parent process
	bool isChild() is
	    return child;
	si

	/// Return process id of child process
	/// \attention returned process id only correct in parent process
	get int PID is
	    return pid;
	si

	/// Wait for child process to exit
	/// \return exit status of child process
	/// \throw System.Exception
	int wait() is
	    int exit_status = 0;
	    // IO.Std.err.println( "wait for process " + pid + " to complete..." );
	    int result = cast int(native.waitpid(pid,exit_status.address,0));
	    if result != pid then
		IO.Std.err.println( "wait for process " + pid + " returned unexpected result: " + result );
		throwUnixError("wait");
		// throw new System.Exception("unexpected result " + result + " waiting for process #" + pid );
	    fi

	    return exit_status;
	si

	/// Replace running program with a new program
	/// \param name path to program to execute
	/// \param args program arguments in a C-array of C-strings 
	/// \param env program environment in a C-array of C-strings 
	void spawn( char ptr name, char ptr ptr args, char ptr ptr env ) is
	    if env != null then
		native.__set_environ(env);
	    fi

	    native.execvp( name, args );
	    native.fprintf( native.__get_stderr(), `Content-type: text/plain\r\n\r\nexec failed '%s'\n`, name );

	    throwUnixError("execvp: " + name );
	si

	/// Replace running program with a new program
	/// \param name path to program to execute
	/// \param args program arguments in an array of Strings
	/// \param env program environment in an array of Strings
	void spawn( System.String name, System.String[] args, System.String[] env ) is
	    char ptr ptr a = cast char ptr ptr(native.malloc(8 * (args.length + 1)));

	    int i;
	    for i = 0; i < args.length; i = i + 1 do
		[a + i] = args[i].toCString();
	    od
	    [a + i] = null;

	    char ptr ptr e = null;
	    if env != null then
		e = cast char ptr ptr(native.malloc(8 * (env.length + 1)));

		for i = 0; i < env.length; i = i + 1 do
		    [e + i] = env[i].toCString();
		od
		[e + i] = null;
	    fi
	    
	    spawn( name.toCString(), a, e );
	si

	/// Start a new program and optionally wait for it to complete
	/// \param name path to program to execute
	/// \param args program arguments in an array of Strings
	/// \param env program environment in an array of Strings
	/// \return child exit status if wait, otherwise zero
	int run( System.String name, System.String[] args, System.String[] env, bool want_wait ) is
	    native.GC_disable();
	    vfork();
	    if isChild() then
		spawn( name, args, env );
	    else
		native.GC_enable();
		if want_wait then
		    int result = wait();
		    // IO.Std.err.println( "spawned process finished, returning: " + result );
		    return result;
		else
		    return 0;
		fi
	    fi
	si

	/// Start a new program and wait for it to complete
	/// \param name path to program to execute
	/// \param args program arguments in an array of Strings
	/// \param env program environment in an array of Strings
	/// \return child exit status
	int run( System.String name, System.String[] args, System.String[] env ) is
	    return run( name, args, env, true ) >> 8;
	si

	/// Start a new program and wait for it to complete. New program receives a copy of the current program environment.
	/// \param name path to program to execute
	/// \param args program arguments in an array of Strings
	/// \return child exit status
	int run( System.String name, System.String[] args ) is
	    return run( name, args, null, true ) >> 8;
	si
    si
si
