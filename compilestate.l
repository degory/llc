// Copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import stream;
import oset;
import machine;
import symbol;
import container;
// import intermediate;
import parsetree;
import symboltable;
import needcompile;
import parser;
import exec;

import threadpool;

namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;

    use Generic.Vector;
    use Generic.Map;

    use Gen.IRBlock;
    use Gen.Machine;

    class LibraryHashFile {
        String name;

        Map<String,int> hashes;

        void init( String name, IO.Reader in ) {
            this.name = name;
            hashes = new Map<String,int>();

            var s = in.readAll().split(' ');

	    var last = s.length - 1;
            for( int i = 0; i < last; i = i + 2 ) {
                hashes[s[i]] = s[i+1].toInt();
            }
        }

        get String Name {
            return name;
        }

        get int Hash[ String name ] {
            return hashes[ name ];
        }
    }


    class Template extends Object {
	public State[] saved_state;
	public SymbolList[] saved_symbol;

	public Container clazz;
	public ClassDef def;

	void init( State[] saved_state, SymbolList[] saved_symbol, Container clazz, ClassDef def ) {
	    this.saved_state = saved_state;
	    this.saved_symbol = saved_symbol;
	    this.clazz = clazz;
	    this.def = def;
	}
    }

    class WriteHashFile extends Object {
	String file_name;
	int hash;

	void init( String file_name, int hash ) {
	    this.file_name = file_name;
	    this.hash = hash;
	}

	void write() {
	    var f = IO.File.openCreate( file_name + ".hash" );
	    f.println( "" + hash );
	    f.close();
	    
	    // IO.Std.err.println( "rename depend file: " + file_name + ".tmp to " + file_name + ".depend" );
	    
	    IO.File.rename( file_name + ".tmp", file_name + ".depend" );
	}

	static void write( Vector<WriteHashFile> hashes ) {
	    foreach( var f; hashes.elements() ) {
		f.write();
	    }
	}
    }

    /*
    // threaded version, no good as contention for Boehm GC prevents any parallel work
    // getting done:
    class CompileWork extends Util.Work {
	CompileState state;
	Package package;
	TempFactory temp_factory;

	void init( CompileState state, Package package, TempFactory temp_factory ) {
	    this.state = state.copy();

	    // IO.Std.err.println( "copied: " + state + "->" + this.state );
	    this.package = package;
	    this.temp_factory = temp_factory;
	}
	    
	void process() {
	    // IO.Std.err.println( "process, temp_factory: " + temp_factory );
	    TempFactory.Instance = temp_factory;
	    // IO.Std.err.println( "process: " + state );
	    package.compile2( state );
	}
    }
    */

    // forked version, packages
    class CompileWork extends Util.Work {
	CompileState state;
	Package package;
	// TempFactory temp_factory;

	void init( CompileState state, Package package ) {
	    this.state = state; // state.copy();

	    // IO.Std.err.println( "copied: " + state + "->" + this.state );
	    this.package = package;
	    // this.temp_factory = temp_factory;
	}
	    
	void process() {
	    // IO.Std.err.println( "process, temp_factory: " + temp_factory );
	    // TempFactory.Instance = temp_factory;
	    // IO.Std.err.println( "process: " + state );
	    package.compile2( state );
	}
    }


    // forked version, classes:
    class CompileClass extends Util.Work {
	CompileState state;
	ClassDef class_def;
	Container c;

	void init( CompileState state, ClassDef class_def, Container c ) {
	    this.state = state; // state.copy();
	    this.class_def = class_def;
	    this.c = c;
	}
	    
	void process() {
	    // IO.Std.err.println( "process, temp_factory: " + temp_factory );
	    // TempFactory.Instance = temp_factory;
	    // IO.Std.err.println( "process: " + c.HumanName );
	    class_def.compile2( state, c );
	}

	String toString() {
	    return c.HumanName;
	}
    }

    // passes of the compiler in order:
    enum CompilePass {
	PARSE_IMPORTS,
        DECLARE_GLOBAL_SYMBOLS,
        CHECK_TEMPLATES,
        DECLARE_CLASS_SYMBOLS,
        DECLARE_SYMBOLS,
        CHECK_INLINE,    
        PREPARE_INLINE,
        PRINT,
	COMPILE
    }

    enum RuntimeFunction {
	ALLOC_OBJECT,
        ALLOC_OBJECT_FINALIZE,
        ALLOC_ARRAY,
	ALLOC_REF_ARRAY,
        THROW_NULL,
        THROW_BOUNDS,
        THROW_CAST,
	GET_L_EXCEPTION
    }


    /*
    class NotWorkerException extends System.Exception {
	void init() {
	    super.init( "not worker" );
	}
    }
    */

    class ProcessPool extends Object {
	CompileState state;
	int count;
	int job_count;
	int job_number;
	int ticket;

	int size;
	int[] pid;
	int read_fd;
	int write_fd;
	int[] b;


	void init( CompileState state, int size, int job_count ) {
	    this.state = state;

	    this.size = size;                 // how many worker processes to create (<2 implies don't create any
	                                      // but instead process work in main thread)
	    this.job_count = job_count;       // how many pieces of work will be submitted to the worker processes
	                                      // in this pool?

	    if( size > 1 ) {
		if( state.WantVeryVerbose ) {
		    ParseTree.message( "creating process pool" );
		}
		pid = new int[size];              // process ids of worker processes
		b = new int[1];                   // buffer for reading or writing a single ticket number
		var fd = new int[2];              // pipe for passing ticket numbers to worker processes
	   
		// create the ticket number pipe:
		if( cast int(native.pipe(fd.address)) != 0 ) {
		    throw new Exception( "could not create pipe (" + cast int(native.__geterrno()) + ")" );		
		}

		// break the reade/write handles out of the newly created pipe:
		read_fd = fd[0];
		write_fd = fd[1];
	    }
	}

	// start the worker processes for this process pool:
	void start() {
	    // if multiple processes wanted:
	    if( size > 1 ) {
		// fork until we've created desired number of processes, caputuring each process
		// initialially waiting on the ticket pipe:

		for( int i = 0; i < size; i = i + 1 ) {
		    // IO.Std.err.println( "forking " + i + " of " + size + "..." );
		    word r = cast word(native.fork());

		    if( r == 0w ) {
			// note that we're in the child process
			CompileState.InChildProcess = true;

			// IO.Std.err.println( "in new child process #" + count + " of " + size );
			// child:
			job_number = 0; 

			// wait for the first job ticket:
			ticket = readTicketNumber();

			// IO.Std.err.println( "process #" + count + " first ticket #" + ticket );
			return;
		    } else if( r < 0w ) { 
			// oops: fork failed:
			throw new Exception( "fork failed" );
		    } else {
			// save the worker process pid for debugging purposes:

			// IO.Std.err.println( "in parent process" );
			pid[count] = cast int(r);
			
			// IO.Std.err.println( "parent, child #" + count + " pid is " + pid[count] );

			// count this worker process so each worker knows it's own number
			// for debugging purposes:
			count = count + 1;		   
		    }
		}

		// write the job numbers to the ticket pipe. Depending on pipe implementation and size of data this may
		// block until some or all work is complete but we'll explicitly wait on worker processes finishing later:
		writeTicketNumbers();
	    }
	}


	// 'submit' is misleading - we're actually taking a ticket number from the pipe and then seeing if it matches this
	// piece of work. If so we'll do the work, if not we'll discard it as someone else is assigned it:
	void submit( Util.Work w ) {
	    if( size > 1 ) {
		if( CompileState.InChildProcess ) {
		    // IO.Std.err.println( "looking for ticket #" + ticket );
		    if( job_number == ticket ) {
			// IO.Std.err.println( "process #" + count + " process job #" + job_number + ": " + w );
			w.process();
			ticket = readTicketNumber();
			// } else {
			// IO.Std.err.println( "process #" + count + " skip job #" + job_number + ": " + w );
		    }

		    job_number = job_number + 1;
		    //} else {
		    // IO.Std.err.println( "child processes running, ignoring submit: " + w );
		}
	    } else {
		// IO.Std.err.println( "less than two jobs: processing directly:" + w );
		w.process();
	    }
	}
	
	void close() {
	    native.close( read_fd );
	}

	int readTicketNumber() {	    
	    int r = cast int(native.read(read_fd,b.address,4));
	    if( r == 4 ) {
		// IO.Std.err.println( "process #" + count + " read ticket #" + b[0] );
		return b[0];
	    } else if( r == 0 ) {
		return -1;
	    } else {
		throw new Exception( "unexpected result (" + r + ") reading pipe (" + cast int(native.__geterrno()) + ")" );		
	    }		
	}

	void writeTicketNumbers() {
	    int r;
	    int l = job_count;
	    for( int i = 0; i < l; i = i + 1 ) {
		b[0] = i;

		r = cast int(native.write(write_fd,b.address,4));

		if( r <= 0 ) {
		    IO.Std.err.println( "failed to write pipe - assumine all child processes finished" );
		    //} else {
		    // IO.Std.err.println( "wrote ticket #" + i );
		}
	    }
	}

	void wait() {	
	    if( count > 0 ) {
		if( state.WantVeryVerbose ) {
		    ParseTree.message( "waiting for " + count + " processes to finish" );
		}
		var r = new Util.Pointer();
	    
		while( count > 0 ) {
		    if( cast int(native.wait( r )) >= 0) {
			if( r.value != 0w ) {
			    if( state.WantVeryVerbose ) {
				ParseTree.message( "child reports errors occurred" );
			    }
			    ParseTree.markError();
			}
			count = count - 1;
		    } else {
			throw new Exception( "wait for child process failed: " + cast int(native.__geterrno()) );
		    }
		}	   
		
		if( state.WantVeryVerbose ) {
		    ParseTree.message( "all children exited" );
		}
	    }
	}
    }

    class CompileState extends Object {
        public const int
            UNSAFE_POINTER = 1,
            UNSAFE_CAST = 2,
            UNSAFE_NATIVE = 4,
            UNSAFE_LINK = 8,
	    UNSAFE_BOUNDS = 16;

        public const int
            STATE_OUTSIDE_CLASS = 0,
            STATE_INSIDE_NAMESPACE = 1,
            STATE_INSIDE_CLASS = 2,
            STATE_INSIDE_METHOD = 3;

	const int 
	    WARN_UNSAFE = 0,
	    WARN_HIDE = 1,
	    WARN_RESOLVE = 2,
    	    MARK_UNSAFE = 3,
	    IS_TRUSTED = 4,
            WANT_DEBUG = 5,
	    WANT_CAST_CHECK = 6,
	    WARN_INIT = 7,
	    WANT_VIRTUAL = 8,
	    WANT_PACK = 9,
	    WANT_NULL_CHECK = 10,
	    WANT_BOUNDS_CHECK = 11;

	const int
	    DEFAULT_WARN_FLAGS = 13 | 32; // all warnings enabled, trusted flag not set

	public const int
	    INLINE_MAX = 25;    // approxiate maximum inline method size (in parse tree nodes)

	static String RUNTIME_VERSION = 
	    "0.2";

	static CompileState instance;

	LLVM.Module module;

	LLVM.BasicBlock null_throw;
	LLVM.BasicBlock bounds_throw;

	Generic.Vector<LLVM.Value>local_variables;

        SymbolList master_class_list;
        SymbolTable symbol_table;

	Vector<Template> generic_templates;
	Vector<Container> generic_instances;
	Vector<Type> proc_instances;

	Generic.Set<Container> interfaces_set;

        NeedCompile need_compile;

	Vector<WriteHashFile> write_hash_files;

        Vector<Package> to_compile_list;
        Vector<Container> to_build_tables_list;

	Vector<String> libraries;
        Generic.Set<String> to_link_set;

        Vector<String> search_path;
        Vector<String> visited_files;
	Vector<String> dependent_files;

	int active_processes;

        int sp;
        State[] state;

        LoopStack loop_stack;

	int block_level;

        CompilePass pass;
	bool in_last_inline_pass;
      
        int current_line;

        int seen_line_number;
        int last_line_number;
        
        int stack_offset;
        int alloc_direction;
	bool in_parameters;
	bool in_static_initializer;

	bool seen_exception_handler;

	static int want_jobs;
	static bool in_child_process;

	int optimize_level;

	bool want_one_file;
	bool want_force_link;
	bool want_verbose;
	bool want_very_verbose;
	bool want_coalesce;
	bool want_inline;
	bool want_regvars;
	bool want_return_jump_elim;
	bool want_split_bounds;
	bool want_cse;
	bool want_print;
	bool want_safe;
	bool want_line_numbers;
	bool want_shared_standard_library;
	bool want_link_libraries;
	bool want_statistics;
	bool want_native_executable;
	bool want_native_object_files;
	bool want_native_library_files;
	bool want_64bit_target;
	bool want_pic;
	bool want_export;
	bool want_print_deps;

	String target_isa;

	int default_warn_flags;


        int spill_label;

        IO.Writer output;
	public String last_cleared_output_at;
        
        int unsafe_flags;

	Container main_class;
        String main_class_name;
        String main_class_decorated;
	String main_class_init;

	String executable_name;
	IO.Writer library_hash_file;

	String project_name;

        int exception_level;
	ExceptionDescriptor[] exception;

        String lcache_dir;
        String runtime_dir;
        static String label_prefix = ".L";

	// ThreadPool pool;
	ProcessPool pool;

	int inline_count;

	int compile_class_count;

	Util.Walk walk_;

	CompileState copy() {
	    // IO.Std.err.println( "before copy, this is: " + System.String.hex(cast int(this)) );

	    CompileState result = cast CompileState(clone());

	    // IO.Std.err.println( "sp is: " + sp );

	    assert(exception_level == -1);

	    result.exception_level = -1;
	    result.exception = new ExceptionDescriptor[32];

	    assert(sp == 0);

	    /*
	    var new_state = new State[30];

	    for( int i = 0; i <= sp; i = i + 1 ) {
		new_state[i] = state[i];
	    }
	    */

	    result.runtime_dir = runtime_dir;
	    result.symbol_table = symbol_table.copy();

	    result.state = new State[30]; // new_state;

	    result.state[0] = state[0].copy();

	    result.loop_stack = new LoopStack();

	    // IO.Std.err.println( "copy is: " + System.String.hex(cast int(this)) );
	    return result;
	}
	

        void init() {
	    // no dependancy checking done on static initializers so need to do this here to
	    // be sure Machine.NAME is initialized:
	    lcache_dir = null;

	    target_isa = "x86";
	    RuntimeDir = "/usr/lib/lang/";

	    module = LLVM.Calls.LLVMModuleCreateWithName(`test`);
	    local_variables = new Generic.Vector<LLVM.Value>();

	    // FIXME: replace these stack arrays with vectors and make the stack pointers
	    // point at the stack tops rather than above them:
            sp = 0;
            state = new State[30];
            state[sp] = new State( STATE_OUTSIDE_CLASS, null, null, null, DEFAULT_WARN_FLAGS );

	    exception_level = -1;
	    exception = new ExceptionDescriptor[32];

	    loop_stack = new LoopStack();

            symbol_table = new SymbolTable();
            master_class_list = new SymbolList();

            need_compile = new NeedCompile(this);
	    write_hash_files = new Vector<WriteHashFile>();

            to_build_tables_list = new Vector<Container>();

            to_compile_list = new Vector<Package>();
	    libraries = new Vector<String>();
            to_link_set = new Generic.Set<String>();

            visited_files = new Vector<String>();
            search_path = new Vector<String>();
	    dependent_files = new Vector<String>();

	    generic_templates = new Vector<Template>();
	    generic_instances = new Vector<Container>();

	    proc_instances = new Vector<Type>();
	 
	    interfaces_set = new Generic.Set<Container>();
 
	    if( instance != null ) {
		IO.Std.err.println( "creating another compiler instance overwrites static values in previous instance" );
	    }
	    instance = this;

	    ParseTree.initUndefinedSymbols(this);

	    // walk_ = new Util.Walk( proc(Object)(dumpMemory) );
	    
	    // pool = new ThreadPool(2);
	    // pool.start();
	}

	get String RuntimeDir {
	    return runtime_dir;
	}

	set String RuntimeDir = s { 
	    if( !s.endsWith('/') ) {
		s = s + '/';
	    }

	    runtime_dir = s;
	}

	get LLVM.Value LocalVariable[int i] {
	    return local_variables[i];
	}

	set LLVM.Value LocalVariable[int i] = v {
	    local_variables[i] = v;
	}

	get LLVM.Value CurrentFunctionGlobal {
	    return CurrentMethod.getFunctionGlobal(this);
	}

	get String TargetISAName {
	    return target_isa;
	}

	get String TargetID {
	    if( Want64BitTarget ) {
		return "linux-" + TargetISAName + "-64";
	    } else {
		return "linux-" + TargetISAName + "-32";
	    }
	}

	void walk( Object o ) {
	    walk_.walk(o);
	}
	
	static void resetStatic() {
	    instance = null;
	    System.GC.collect();
	}

	void wait( int load ) {
	    // IO.Std.err.println( "wait " + active_processes + ", " + load );
	    Util.Pointer p = new Util.Pointer();
	    while( active_processes > load ) {
		// IO.Std.err.println( "wait " + active_processes + " > " + load );
		if( cast word(native.wait( p )) > 0w ) {
		    if( p.value != 0w ) { 
			ParseTree.markError();
		    }			
		    active_processes = active_processes - 1;
		} else {
		    throw new Exception( "oops: wait failed" );
		}
	    }
	}

	void submit( Util.Work w ) {
	    if( pool == null ) {
		IO.Std.err.flush();
		pool = new ProcessPool(this,WantJobs,master_class_list.Length);
		pool.start();
	    }

	    pool.submit(w);

	    // pool.submit( w );	    
	}

	void initSearchPaths( bool safe ) {
	    String llvm_lib;

	    if( !safe ) {
		addSearchPath( "./" );
	    }

	    addSearchPath( RuntimeDir + TargetID + "/" );
	    addSearchPath( RuntimeDir + TargetID + "/trusted/" );
	    addSearchPath( RuntimeDir + "trusted/" );

	    if( safe ) {
		addSearchPath( RuntimeDir + "safe/" );
	    } else {

		addSearchPath( RuntimeDir + TargetID + "/trusted/" );
		addSearchPath( RuntimeDir + TargetID + "/unsafe/" );
		addSearchPath( RuntimeDir + "unsafe/" );
	    }
	}

	bool isSourceFileTrusted( String name ) {
	    return
		name.startsWith( RuntimeDir + "trusted/" ) ||
		name.startsWith( RuntimeDir + "safe/" );
	}

	void countInline() {
	    if( State != STATE_INSIDE_METHOD ) {
		return;
	    }
	    inline_count = inline_count + 1;
	    if( inline_count > INLINE_MAX ) {
		if( WantVeryVerbose ) {
		    ParseTree.message( "too large to inline: " + CurrentMethod.HumanName );
		}
		throw new CannotInlineException();
	    }
	}

	void clearInlineCount() {
	    inline_count = 0;
	}

	static get CompileState Instance {
	    // IO.Std.err.println( "get instance is not thread safe, expect trouble: " + new Backtrace() );
	    return instance;
	}

	get LLVM.Module Module {
	    if( WantOneFile ) {
		return module;
	    } else if( CurrentClass != null ) {
		// IO.Std.err.println( "returning module for: " + CurrentClass.HumanName );
		return CurrentClass.LLVMModule;
	    } else {
		IO.Std.err.println( "oops: LLVM module requested outside of class" );
		return module;
	    }
	}

	get LLVM.BasicBlock ThrowNullBlock {
	    return null_throw;
	}

	set LLVM.BasicBlock ThrowNullBlock = b {
	    null_throw = b;
	}
	
	get LLVM.BasicBlock ThrowBoundsBlock {
	    return bounds_throw;
	}

	set LLVM.BasicBlock ThrowBoundsBlock = b {
	    bounds_throw = b;
	}

        void maybeLinkOnce( LLVM.Value v ) {
	    maybeLinkOnce( v, true );
	}

        void maybeLinkOnce( LLVM.Value v, bool odr ) {
	    if( want_export ) {
		if( odr ) {
		    LLVM.Calls.LLVMSetLinkage( v, LLVM.LLVMLinkage.LLVMWeakODRLinkage );
		} else {
		    LLVM.Calls.LLVMSetLinkage( v, LLVM.LLVMLinkage.LLVMWeakAnyLinkage );
		}
	    } else {
		if( odr ) {
		    LLVM.Calls.LLVMSetLinkage( v, LLVM.LLVMLinkage.LLVMLinkOnceODRLinkage );
		} else {
		    LLVM.Calls.LLVMSetLinkage( v, LLVM.LLVMLinkage.LLVMLinkOnceAnyLinkage );
		}
	    }
	}

	LLVM.Value getRuntimeFunction( RuntimeFunction f ) {
	    char ptr name;
	    LLVM.Module m = Module;
	    LLVM.Value v;

	    switch( f ) {
	    case RuntimeFunction.ALLOC_OBJECT:
		name = `__alloc_object`;

	    case RuntimeFunction.ALLOC_OBJECT_FINALIZE:
		name = `__alloc_object_finalize`;

	    case RuntimeFunction.ALLOC_ARRAY:
		name = `allocagn`;

	    case RuntimeFunction.ALLOC_REF_ARRAY:
		name = `allocago`;

	    case RuntimeFunction.THROW_NULL:
		name = `_ZN6System20NullPointerException8throwNPEEv`;

	    case RuntimeFunction.THROW_BOUNDS:
	        name = `_ZN6System20ArrayBoundsException11throwBoundsEv`;	    

	    case RuntimeFunction.THROW_CAST:
	        name = `_ZN6System13CastException9throwCastEv`;	    

	    case RuntimeFunction.GET_L_EXCEPTION:
		name = `__get_l_exception`;
		
	    default:
		throw new System.Exception( "unknown runtime function #" + cast int(f) );
	    }

	    v = LLVM.Calls.LLVMGetNamedFunction(m, name);

	    if( v == null ) {
		LLVM.Type[] args;
		LLVM.Type ret;
		    
		switch( f ) {
		case RuntimeFunction.ALLOC_OBJECT,
		    RuntimeFunction.ALLOC_OBJECT_FINALIZE:
		    ret = LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(),0);
		    args = {
			LLVM.Calls.LLVMInt32Type(),
			LLVM.Calls.LLVMVTableType()
		    };


		case RuntimeFunction.ALLOC_ARRAY,
		    RuntimeFunction.ALLOC_REF_ARRAY:

		    ret = LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(),0);
		    args = {
			LLVM.Calls.LLVMInt32Type(),
			LLVM.Calls.LLVMInt32Type(),
			LLVM.Calls.LLVMVTableType()
		    };

		case RuntimeFunction.THROW_NULL,
		    RuntimeFunction.THROW_BOUNDS,
		    RuntimeFunction.THROW_CAST:
		    ret = LLVM.Calls.LLVMVoidType();
		    args = new LLVM.Type[0];

		case RuntimeFunction.GET_L_EXCEPTION:
		    ret = LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(),0);
		    args = {
			LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(),0)
		    };
		    
		default:
		    throw new System.Exception( "unknown runtime function #" + cast int(f) );
		}

		v = LLVM.Calls.LLVMAddFunction(
					       m,
					       name,
					       LLVM.Calls.LLVMFunctionType(
									   ret,
									   args.address,
									   args.length,
									   0
									   )
					       );

	    }


	    return v;
	}

	get LoopStack Loops {
	    return loop_stack;
	}

	/*
	get String LCacheDir {
	    return lcache_dir;
	}
	*/

	// FIXME: this is mad - stack top is level - 1
	get int ExceptionLevel {
	    return exception_level;
	}

	set int ExceptionLevel = l {
	    exception_level = l;
	}

	void resetExceptionLevel() {
	    exception_level = -1;
	}

	get ExceptionDescriptor Exception[int n] {
	    return exception[n];
	}

	set ExceptionDescriptor Exception[int n] = e {
	    exception[n] = e;
	}

	void pushException(ExceptionDescriptor e) {
	    exception_level = exception_level + 1;
	    exception[exception_level] = e;
	}

	ExceptionDescriptor popException() {
	    var result = exception[exception_level];
	    exception_level = exception_level - 1;
	    return result;
	}

	get ExceptionDescriptor TopException {
	    // IO.Std.err.println( "get top exception: exception_level = " + exception_level );
	    return exception[exception_level];
	}

	get ExceptionDescriptor TopExceptionOrNull {
	    if( InExceptionHandler ) {
		return TopException;
	    } else {
		return null;
	    }
	}

	get bool InExceptionHandler {
	    // IO.Std.err.println( "in exception handler? exception_level = " + exception_level );
	    return exception_level >= 0;
	}

	get bool InBottomExceptionHandler {
	    return exception_level == 0;
	}

	get ExceptionDescriptor TopFinallyOrReturn {
	    for( int i = exception_level; i >= 0; i = i - 1 ) {
		if( exception[i].type == EDType.CATCH_FINALLY ||
		    exception[i].type == EDType.CATCH_RETURN ) {
		    return exception[i];
		}
	    }

	    return null;
	}

	get bool CurrentMethodHasIf {
	    var current_method = CurrentMethod;	    
	    return current_method != null && current_method.HasIf;
	}

	void markCurrentMethodHasIf() {
	    var current_method = CurrentMethod;
	    if( current_method != null ) {
		current_method.HasIf = true;
	    }
	}

	get bool InStaticInitializer {
	    return in_static_initializer;
	}

	static get bool InChildProcess {
	    return in_child_process;
	}

	static set bool InChildProcess = v {
	    in_child_process = v;
	}

	int enterBlock() {
            if( CurrentMethod != null ) {
                block_level = block_level + 1;
                return CurrentMethod.enterBlock();
            } else {
                return -1;
            }
	}

	void exitBlock(int st) {
            if( CurrentMethod != null ) {
                CurrentMethod.exitBlock(st);
                block_level = block_level - 1;
            }
	}

	get int BlockLevel {
	    return block_level;
	}

	get String CacheDir {
	    if( lcache_dir == null ) {
		if( project_name != null ) {
		    lcache_dir = "/tmp/lcache-" + project_name + "/";
		} else {
		    lcache_dir = "/tmp/lcache/";
		}
	    }

	    return lcache_dir;	       
	}

	// for debugging:
	get SymbolTable SymbolTable {
	    return symbol_table;
	}
	
        void pushState( int s, String source_file_name ) {
            Container current_class, current_method;
	    int warn_flags = WarnFlags;
            if( sp < 0 ) {
                current_class = null;
                current_method = null;
            } else {
                current_class = state[sp].CurrentClass;
                current_method = state[sp].CurrentMethod;
            }
            
            sp = sp + 1;
            state[sp] = new State( s, current_class, current_method, source_file_name, warn_flags );
        }

        void pushState( int s, Container current_class, Container current_method ) {
            String source_file_name;
	    int warn_flags = WarnFlags;
            if( sp < 0 ) {
                source_file_name = null;
            } else {
                source_file_name = state[sp].SourceFileName;
            }
            
            sp = sp + 1;
            
            state[sp] = new State( s, current_class, current_method, source_file_name, warn_flags );
        }

	get CompilePass Pass {
	    return pass;
	}

	set CompilePass Pass = p {
	    pass = p;
	}

	get SymbolList[] SymbolState {
	    return symbol_table.SymbolState;
	}

	set SymbolList[] SymbolState = s {
	    symbol_table.SymbolState = s;
	}

	get State[] SaveState {
	    // IO.Std.err.println( "get save state..." );

	    state[sp].Output = output;

	    State[] result = new State[sp+1];

	    for( int i = 0; i <= sp; i = i + 1 ) {
		// IO.Std.err.println( "save state #" + i + ": " + state[i] );
		result[i] = state[i];
	    }

	    return result;
	}

	set State[] SaveState = s {
	    state = new State[30];

	    for( sp = 0; sp < s.length; sp = sp + 1 ) {
		state[sp] = s[sp];
		// IO.Std.err.println( "restore state #" + sp + ": " + state[sp] );
	    }

	    sp = sp - 1;
	    output = state[sp].Output;
	}
        
        void popState() {
            sp = sp - 1;
        }

        void addSearchPath( String p ) {
            if( p[ p.Length-1 ] != '/' ) {
                p = p + '/';
            }
            search_path.add(p);
        }

        void addClass( Container c ) {
	    // IO.Std.err.println( "adding class to build: " + c );
            to_build_tables_list.add( c );
        }

        void addPackage( Package p ) {
            to_compile_list.add( p );
        }


	void addLibrary( String name ) {
	    if( !WantLinkLibraries ) {
		if( WantVerbose ) {
		    ParseTree.message( "ignoring library: " + name );
		}
	    } else {
		if( WantVerbose ) {
		    ParseTree.message( "adding library: " + name );
		}
		libraries.add( name );
	    }
	}

        void addLinkFile( String name ) {
	    // not sure why this is called repeatedly but avoid linking the same object file more than once:
	    if( to_link_set.contains(name) ) {
      		return;
	    }

	    if( name.endsWith("lang.bc" ) ) {
		IO.Std.err.println( "arg, from: " + new System.Backtrace() );
	    }

            to_link_set.add( name );
        }

	void addObject( Container c ) {
	    // IO.Std.err.println( "add object: " + c.HumanName );
	    if( !WantOneFile && !need_compile.isInLibrary( c.DecoratedName ) ) {
		// IO.Std.err.println( "need link: " + c.HumanName + " lcache_dir is: " + CacheDir );
		addLinkFile( getObjectFileName( c.DecoratedName ) );
	    }
	}

        void addHashFile( Container c, CompileStatus s ) {
	    var hash = c.Hash;
	    var name = c.DecoratedName;

	    if( s != CompileStatus.LIBRARY ) {
		// IO.Std.err.println( "writing to " + library_hash_file + ": '" + name + ' ' + hash + ' ' + "'" );
		library_hash_file.print( name + ' ' + hash + ' ' );

		foreach( Symbol t; c.Members.Iterator ) {
		    if( t.IsMethod ) {
			String u;
			if( t.IsStatic ) {
			    u = t.DecoratedName + " 0 ";
			} else {
			    u = t.DecoratedName + ' ' + t.Address + ' ';
			}

			library_hash_file.print( u );
		    }
		}
	    }

	    if( s == CompileStatus.STALE ) {
		write_hash_files.add( new WriteHashFile(lcache_dir + name, hash) );
	    }
        }

	void writeHashFiles() {
	    /*
	    foreach( Container c; master_class_list.SymbolList.elements() ) {
		c.getHash();
	    }
	    */
	    WriteHashFile.write( write_hash_files );
	    
	    library_hash_file.close();
	}

	void openLibraryHashFile() {
	    var file_name = ExecutableName;
	    var i = file_name.lastIndexOf('.');
	    if( i >= 0 ) {
		file_name = file_name.substring(0,i);
	    }

	    file_name = file_name + ".lh";

	    IO.File.deleteQuiet( file_name );
	    library_hash_file = IO.File.openAppend( file_name );
	}

	void printDeps() {
	    var file_name = ExecutableName;
	    var i = file_name.lastIndexOf('.');
	    if( i >= 0 ) {
		file_name = file_name.substring(0,i);
	    }

	    file_name = file_name + ".d";

	    var df = IO.File.openCreate( file_name );

	    df.print( ExecutableName + "_DEPS:=" );
	    
	    foreach( String s; dependent_files.elements() ) {
		// hack: make library files appear in ./lib in .d files:
		if( s.startsWith(RuntimeDir) ) {
		    s = "./lib/" + s.substring(RuntimeDir.Length);
		}
		df.print( s );
		df.print( " " );
	    }
	    
	    df.close();
	}


        void compilePending() {
            int i, j;
            Package p;

	    openLibraryHashFile();

	    // recursively visit all imported files building parse trees until every
	    // imported package has been parsed:
	    Pass = CompilePass.PARSE_IMPORTS;

	    if( WantVeryVerbose ) {
		ParseTree.message( "parsing files..." );
	    }

            // IO.Std.err.println( "parsing imports..." );
            for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
                p = cast<Package>(to_compile_list[i]);
                p.parseImports(this);
            }

	    if( want_print_deps ) {
		printDeps();
		return;
	    }

	    // create symbol table entries for namespaces down to contained enums and classes and
	    // stopping before declaring any symbols within classes:
	    Pass = CompilePass.DECLARE_GLOBAL_SYMBOLS;

	    if( WantVeryVerbose ) {
		ParseTree.message( "declaring global objects..." );
	    }

            // IO.Std.err.println( "parsing types..." );
            for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
                p = cast<Package>(to_compile_list[i]);
                p.declareGlobalSymbols(this);
            }


	    // create specific instances of all template classes:
	    Pass = CompilePass.CHECK_TEMPLATES;

            for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
                p = cast<Package>(to_compile_list[i]);
                p.useTypes(this);
	    }

	    if( WantVeryVerbose ) {
		ParseTree.message( "declaring template instances..." );
	    }

	    int instance_count;
	    do {
		instance_count = GenericInstanceCount;
		for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
		    p = cast<Package>(to_compile_list[i]);
		    p.checkTemplates(this);
		}

		// if we created any instances of template classes, go again here since those
		// new instances may contain references to as yet uninstantiated template classes
		// (for example instantiating Stack<T> { ... Vector<T> ...} as Stack<int> might then require Vector<int>)

		/*
		if( GenericInstanceCount > instance_count ) {
		    IO.Std.err.println( "EEEEEE: template instances created: need to rescan for additional template instances" );
		}
		*/
	    } while( GenericInstanceCount > instance_count );

	    // create symbol table entries for all symbols declared at the class level, including instance variables and
	    // method defintions including arguments but not method bodys:
            // IO.Std.err.println( "parsing definitions..." );
	    Pass = CompilePass.DECLARE_CLASS_SYMBOLS;
	    if( WantVeryVerbose ) {
		ParseTree.message( "declaring class symbols..." );
	    }
	    
            for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
                p = cast<Package>(to_compile_list[i]);
                p.declareClassSymbols(this);
            }

	    // symbols down to immediate contents of classes now declared so addresses of everything needed to build
	    // vtables etc. now fixed:
	    if( WantVeryVerbose ) {
		ParseTree.message( "building class tables..." );
	    }

            // IO.Std.err.println( "build tables..." );
            foreach( Container c; to_build_tables_list.elements() ) {
                c.buildClassTables( this );
            }

            foreach( Container d; to_build_tables_list.elements() ) {
                d.refineClassTypeHandle( this );
            }

	    // last symbol table construction pass, declare all remaining symbols within methods:
	    Pass = CompilePass.DECLARE_SYMBOLS;
	    if( WantVeryVerbose ) {
		ParseTree.message( "declaring symbols..." );
	    }

	    for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
		p = cast<Package>(to_compile_list[i]);
		p.declareSymbols(this);
	    }

	    if( WantVeryVerbose ) {
		ParseTree.message( "build interface tables..." );
	    }

	    Container.buildInterfaceTables( interfaces_set, master_class_list.SymbolList );

	    // symbol table is complete and it is now possible to compile methods in any order
	    // and we can attempt to prepare intermediate code versions of methods for inlining:


	    // actually compile:

            // IO.Std.err.println( "generate code..." );

	    Pass = CompilePass.COMPILE;	    
	    if( WantVeryVerbose ) {
		ParseTree.message( "compiling methods..." );
	    }

            for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
                p = cast<Package>(to_compile_list[i]);
                p.compile( this );
            }

	    /*
	    var w = new Util.Walk( proc(Object)(dumpMemory) );
	    w.walk( this );
	    */

	    if( WantJobs <= 1 && !InChildProcess ) {
		writeHashFiles();		
	    }	    

	    if( InChildProcess ) {
		writeHashFiles();
		pool.close();
		if( ParseTree.didErrorsOccur() ) {
		    System.Exit.exit(1);
		} else {
		    System.Exit.exit(0);
		}
	    } else if( ParseTree.didErrorsOccur() ) {
		ParseTree.message( "*** errors occurred ***" );
		return;
	    }

	    if( WantLinkLibraries ) {
		if( main_class_decorated != null ) {
		    // IO.Std.err.println( "writing out entry point for main class " + main_class_decorated );

		    emitEntryPoint();

		} else {
		    ParseTree.message( "*** no main class ***" );
		    return;
		}
	    }

	    // wait(0);
	    pool.wait();

	    if( WantVerbose ) {
		ParseTree.message( "linking objects..." );
	    }
	   
	    // LLVM.Calls.LLVMDumpModule( module );
	    // LLVM.Calls.LLVMWriteBitcodeToFile(Module, `test.bc`);


	    linkObjectFiles();

	    ParseTree.message( "done" );
        }

	void emitEntryPoint() {	       
	    var om = module;
	    var m = LLVM.Calls.LLVMModuleCreateWithName( `entry` );
	    module = m;

	    /*
	    var args_init = new LLVM.Type[0];
	   
	    var install_segv_handler =
		LLVM.Calls.LLVMAddFunction(
					   m,
					   `__install_segv_handler`,
					   LLVM.Calls.LLVMFunctionType(
								       LLVM.Calls.LLVMVoidType(),
								       args_init.address,
								       args_init.length,
								       0
								       )
					   );

	    */
	    var args_run1 = { ParseTree.object_type.getLLVMType(this) };

	    // System.Startup.run1(Object):
	    var run1_function = 
		LLVM.Calls.LLVMAddFunction(
					   m,
					   `_ZN6System7Startup4run1EN6System6ObjectE`,
					   LLVM.Calls.LLVMFunctionType(
								       LLVM.Calls.LLVMVoidType(),
								       args_run1.address,
								       args_run1.length,
								       0
								       )
					   );


	    var args_entry = new LLVM.Type[0];

	    clearThrowBlocks();
	    var entry_point_function = LLVM.Calls.LLVMAddFunction(
					       m,
					       `__entry_point`,
                                               LLVM.Calls.LLVMFunctionType(
                                                                           LLVM.Calls.LLVMVoidType(),
                                                                           args_entry.address,
                                                                           args_entry.length,
                                                                           0
                                                                           )
					       );

            var into = new IRBlock( this, entry_point_function );

	    // into.Call( install_segv_handler, new LLVM.Value[0] );

	    var op = RuntimeFunction.ALLOC_OBJECT;
	    var vtable = ParseTree.makeLoadVTable( this, main_class );

	    var alloc_function = getRuntimeFunction( op );

	    var v = into.Call(
			      alloc_function,
			      { LLVM.Calls.LLVMConstTypeSizeIndirect(main_class.Type.getLLVMType(this)), vtable }
			      );
	   
	    into.Call( run1_function, { ParseTree.makeLLVMCast( v, ParseTree.object_type.getLLVMType(this), into ) } );
	    into.RetVoid(); // LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),0L,0 ) );
	    into.Close();

	    writeOrAssembleBitcode( m, "entry" );

	    LLVM.Calls.LLVMDisposeModule(m);

	    module = om;


	    addLinkFile( getObjectFileName("entry") );
	}

	static void dumpMemory( Object o ) {
	    IO.Std.out.println( "\tAAAAA\t" + o.ClassName + "\t" + o.MemoryUse + "\t" );
	}

	void countCompiledClass() {
	    compile_class_count = compile_class_count + 1;
	}

	get int CompileClassCount {
	    return compile_class_count;
	}

	void linkObjectFiles() {

	    StringBuffer b = new StringBuffer();

	    var p = new Util.Process();
	    var v = new Vector<String>();

	    String exe;

	    if( !WantForceLink && CompileClassCount == 0 ) {
		var st = new IO.Stat();
		if( st.stat( executable_name ) ) {
		    if( WantVeryVerbose ) {
			ParseTree.message( "no classes were compiled and output '" + executable_name + "' exists: not linking" );
		    }
		    IO.Std.err.flush();

		    return;
		}
	    }

	    IO.Std.err.flush();

	    if( WantOneFile ) {
		LLVM.Calls.LLVMWriteBitcodeToFile(Module, "temp.bc".toCString() );
	    }

	    if( WantNativeObjectFiles ) {
		IO.Std.err.println( "link native object files" );
		if( !WantNativeExecutable ) {
		    throw new System.Exception( "cannot link bitcode executable from native object files" );
		}
		exe = "gcc";
		v.add( "gcc" );

		if( WantLinkLibraries ) {
		    v.add( RuntimeDir + TargetID + "/trusted/dummy.o" );
		}

		if( WantPIC ) {
		    v.add( "-shared" );
		}

		if( WantOneFile ) {
		    throw new System.Exception( "cannot link single file bitcode output from native object files" );
		}
	    } else {
		IO.Std.err.println( "link bitcode object files" );
		exe = "llvm-ldh";
		v.add( "llvm-ldh" );

		if( OptimizeLevel == 0 ) {
		    IO.Std.err.println( "linking with -disable-opt" );
		    v.add( "-disable-opt" );
		} else {
		    IO.Std.err.println( "default optimization level" );
		    // v.add( "-O" + OptimizeLevel );
		}
		v.add( "-export-dynamic" );

		if( WantNativeExecutable ) {
		    v.add( "-native" );
		    if( WantPIC ) {
			v.add( "-shared" );
			v.add( "-relocation-model=pic" );
			v.add( "-Xlinker" );
			v.add( "-shared" );
		    }

		    if( WantLinkLibraries ) {
			v.add( RuntimeDir + TargetID + "/trusted/dummy.o" );
		    }
		}

		if( WantOneFile ) {
		    v.add( "temp.bc" );
		}
	    }

	    v.add( "-Xlinker" );
	    v.add( "--export-dynamic" );

	    if( !WantLinkLibraries ) {
		v.add( "-L/usr/lang/lib/" + TargetID + "/" );
		v.add( "-L/usr/lang/lib/" );

		// v.add( RuntimeDir + "lrt-llvm-" + RUNTIME_VERSION + ".bc" );

		v.add( "-o" );

		v.add( executable_name );

	    } else {
		v.add( "-L/usr/lang/lib/" + TargetID + "/" );
		v.add( "-L/usr/lang/lib/" );

		if( WantNativeObjectFiles ) {
		    v.add( RuntimeDir + TargetID + "/lrt-llvm-" + RUNTIME_VERSION + ".o" );
		} else {
		    v.add( RuntimeDir + TargetID + "/lrt-llvm-" + RUNTIME_VERSION + ".bc" );
		}

		v.add( "-o" );
		v.add( executable_name );
	    }		


	    foreach( String s; to_link_set.elements() ) {
		v.add( s );
	    }

	    foreach( String u; libraries.elements() ) {
		if( u.endsWith( ".so" ) ) {
		    v.add( u );
		}
	    }
	    // v.add( "-nostartfiles" );

	    v.add( "-lgc" );
	    // v.add( "/usr/lang/lib/libgcX.a" );
	    v.add( "-ldl" );	    
	    // v.add( "-lpthread" );

	    foreach( String t; libraries.elements() ) {
		if( t.endsWith(".o") || t.endsWith(".bc") || t.endsWith( ".so" ) ) {
		    v.add( t ); 
		} else if( !t.endsWith(".so") ) {
		    v.add( "-l" + t );
		} else {
		    IO.Std.err.println( "oops: ignoring import file: " + t );		
		}
	    }

	    // v.add( "-shared" );

	    String[] args = new String[v.Length];
	    for( int i = 0; i < v.Length; i = i + 1 ) {
		b.append( v[i] );
		b.append( ' ' );
		args[i] = cast<String>(v[i]);
	    }

	    if( WantVeryVerbose ) {
		ParseTree.message( "linking: " + b );	    
	    }

	    int result = p.run( exe, args );
	    if( result != 0 ) {
		throw new Exception( "link failed with exit status " + result );
	    }
	}

        bool haveVisitedFile( String name ) {
	    // IO.Std.err.println( "have visited file " + name + "?" );
            foreach( String s; visited_files.elements() ) {
		// IO.Std.err.println( "checking: " + s );
                if( name.equals(s) ) {
		    // IO.Std.err.println( "yes" );
                    return true;
                }
            }
	    // IO.Std.err.println( "no" );
            return false;
        }

	IO.Reader tryOpen( String dir, String ref file_name, String extension ) {
	    try {
		String open_file_name = dir + file_name + extension;
		// IO.Std.err.println( "try open: " + open_file_name );

		var s = IO.File.openStream( open_file_name, IO.File.O_RDONLY, 0, true );
		if( s == null ) {
		    // IO.Std.err.println( "failed: " + open_file_name );
		    return null;
		}

		var in = new IO.Reader(s);
		file_name = open_file_name;

		// IO.Std.err.println( "success: " + file_name + ", " + in );

		return in;
	    } catch( IO.IOException ioe ) {
		// IO.Std.err.println( "failure: " + ioe );
		return null;
	    }
	}

        bool visitFile( String name ) {
            if( haveVisitedFile( name ) ) {
                return false;
            }

	    // IO.Std.err.println( "visit file: '" + name + "'" );

            // current_file_name = name;
            // current_input_line = 1;

            visited_files.add( name );

            String file_name;
            IO.Reader in = null;
	    Vector<String> search = search_path;

	    if( name[0] == '/' ) {
		search = new Vector<String>();
		search.add( "" );
	    }

	    // IO.Std.err.println( "search in: " + search );

	    var i = search.elements();

	    // IO.Std.err.println( "i is: " + i );

            foreach( String s; i /* search.elements() */ ) {
		// IO.Std.err.println( "try: " + s );
		if( !s.endsWith('/') ) {
		    s = s + '/';
		}

		if( name.endsWith(".l") || name.endsWith(".lh") ) {
		    // IO.Std.err.println( "l or ll extension, try open '" + name + "' directly" );
		    in = tryOpen( s, name, "" );
		    if( in != null ) {
			file_name = name;
			break;
		    }
		} else {
		    // IO.Std.err.println( "other extension, try open '" + name + "' + '.l'" );

		    in = tryOpen( s, name, ".l" );
		    if( in != null ) {
			file_name = name;
			break;
		    }
		    /*
		    IO.Std.err.println( "other extension, try open '" + name + "' + '.ll'" );

		    in = tryOpen( s, name, ".lh" );
		    if( in != null ) {
			file_name = name;
			break;
		    }
		    */
		}
            }

            if( in == null ) {
                throw new Exception( "could not open input file " + name + " in any of " + search + " lcache: " + this.CacheDir );
            }

	    //IO.Std.err.println( "input file: '" + file_name + "'" );

	    if( file_name.endsWith(".lh" ) ) {
		// IO.Std.err.println( "input file is a library hash file..." );
		addLibraryHashFile( name, in );
	    } else {
		parseFile( file_name, in );
	    }
            return true;
        }

	void addLibraryHashFile( String name, IO.Reader in ) {
	    if( name.endsWith( ".lh" ) ) {
		name = name.substring( 0, name.Length - 3 ); // + ".so";
	    }

	    var dir = "";
	    int l = name.lastIndexOf('/');
	    if( l >= 0 ) {
		dir = name.substring(0,l+1);
		name = name.substring(l+1,name.Length);
		// IO.Std.err.println( "split: " + dir + " : " + name );
	    }

	    /*
	    if( name.startsWith( "lib" ) ) {
		name = name.substring( 3 );
	    }
	    */

	    need_compile.addLibraryHashFile( new LibraryHashFile(name,in) );

	    if( WantVeryVerbose ) {
		ParseTree.message( "will link L library: " + name );
	    }
	    // libraries.add( dir + name + ".so" );
	    if( WantNativeExecutable ) {
		if( WantVeryVerbose ) {
		    ParseTree.message( "add shared library: " + dir + name + ".so" );
		}
		addLibrary( dir + name + ".so" );
	    } else if( want_native_library_files && IO.File.exists( dir + name + ".so" ) ) {
		addLibrary( dir + name + ".so"  );
	    } else {
		if( WantVeryVerbose ) {
		    ParseTree.message( "add bitcode library: " + dir + name + ".bc" );
		}
		addLibrary( dir + name + ".bc" );
	    }
	}

	set String ExecutableName = s {
	    executable_name = s;
	}

	get String ExecutableName {
	    return executable_name;
	}

	set String ProjectName = s {
	    project_name = s;
	}

        CompileStatus needCompile( String source_name, String class_name, int hash ) {
            var result = need_compile.needCompile( source_name, class_name, hash, WantOneFile );

	    // IO.Std.err.println( "need compile " + source_name + ": " + class_name + ": " + result );
	    return result;
        }

	get int Hash[String name] {
	    return need_compile.Hash[name];
	}

        void parseFile( String file_name, IO.Reader f ) {
	    dependent_files.add( file_name );

	    if( WantVeryVerbose ) {
		ParseTree.message( "parse file: " + file_name );
	    }
            Parser p = new Parser(file_name, f, this);
        }

	void assembleFile( System.String name ) {
	    System.String assembler_file = getObjectFileName( name, ".s" );
	    System.String object_file = getObjectFileName( name, ".o" );
	    
	    if( WantVeryVerbose ) {
		ParseTree.message( "assemble file: " + name );
	    }
	    
	    Util.Process assembler = new Util.Process();
	    int result = assembler.run(
				       "/usr/bin/as",
				       {
					   "/usr/bin/as",
					   cast<System.String>(assembler_file),
					   "-o", object_file
				       },
				       null
				       );

	    if( result != 0 ) {
		throw new System.Exception( "assembly of file " + assembler_file + " failed with exit status " + result );
	    }
	}

	void compileBitcode( System.String name ) {
	    System.String bitcode_file = getObjectFileName( name, ".bc" );
	    System.String assembler_file = getObjectFileName( name, ".s" );
	    
	    if( WantVeryVerbose ) {
		ParseTree.message( "compile bitcode to assembly: " + name );
	    }

	    String relocate;

	    if( WantPIC ) {
		relocate = "-relocation-model=pic";
	    } else {
		relocate = "-relocation-model=default";
	    }
	    
	    Util.Process llc = new Util.Process();
	    int result = llc.run(
				 "/usr/local/bin/llc",
				 {
				     "llc",
				     relocate,
				     "-f",
				     bitcode_file,
				     "-o",
				     cast<System.String>(assembler_file)
				 },
				 null
				 );
	    if( result != 0 ) {
		throw new System.Exception( "bitcode compilation of file " + bitcode_file + " failed with exit status " + result );
	    }
	}


	void writeOrAssembleBitcode(Container c) {
	    writeOrAssembleBitcode(c.LLVMModule, c.DecoratedName);
	}

	void writeOrAssembleBitcode(LLVM.Module module, String file_name) {
	    var bc_file_name = getObjectFileName(file_name, ".bc");
	    LLVM.Calls.LLVMWriteBitcodeToFile(module, bc_file_name.toCString() );
	    if( WantNativeObjectFiles ) {
		compileBitcode( file_name );
		assembleFile( file_name );
	    }
	}
	/*
        void addAssemblerFile( String s ) {
            to_assemble_list.add( s );
        }
	*/

        void catAssemblerFile( String f ) {
            throw new Exception( "implement me!" );
        }


        void beginPackage( String source_file_name, SymbolList n ) {
	    // IO.Std.err.println( "begin package: " + source_file_name + ", " + this );
            pushState( STATE_OUTSIDE_CLASS, source_file_name );
            
            output = null;
	    // last_cleared_output_at = "begin package: " + source_file_name + " from: " + new System.Backtrace().toString();
            current_line = -1;
            seen_line_number = -1;
            last_line_number = -1;
        }

        void endPackage() {
            popState();
            
            output = null;
	    // last_cleared_output_at = new System.Backtrace().toString();
            seen_line_number = -1;
            last_line_number = -1;
            current_line = -1;
        }


	Container nextMethodByIndex(String name) {
	    Container c = this.CurrentClass;
	    // IO.Std.err.println( "next method by index " + name + " from " + c );
	    if( c == null ) {
		IO.Std.err.println( "no current method" );
		return null;
	    }
	    return c.nextMethodByIndex(name);
	}

        Container declareNameSpace( ParseTree from, String name ) {
            Symbol symbol = findSymbol( name, Symbol.FIND_TYPE );
            Container class_symbol = null;
            
            if( symbol != null && symbol.Kind == Symbol.NAMESPACE ) {
                // FIXME: what if namespace is nested inside another with the same name?
                return cast<Container>(symbol);
            } else {
                Container current_namespace = CurrentNameSpace;

                class_symbol = new Container( null, current_namespace, name, Symbol.NAMESPACE, Symbol.ACCESS_PUBLIC, null );
                class_symbol.setType( new Type( Type.NAMESPACE, class_symbol ) );
                class_symbol.setDefined( 1 );
                
                symbol_table.add( class_symbol );
                symbol_table.enterScope();
                class_symbol.setSymbolList( symbol_table.CurrentScope );
                symbol_table.exitScope();

                if( symbol != null && WantWarnHide ) {
                    from.warn( "namespace " + class_symbol.HumanName + " hides symbol in outer scope " + symbol.HumanName );
                }               

            }
            
            return class_symbol;
        }

        void enterNameSpace( Container n ) {
	    // int ignore = State;

            if( this.State > STATE_INSIDE_NAMESPACE ) {
                throw new Exception( "oops: beginParseNameSpace from state " + State );
            }
            
            // alloc_direction = 1;
            
            if( n.Kind != Symbol.NAMESPACE ) {
                throw new Exception( "oops: redefining symbol " + n.Name + " as namespace" );
            }
            
            
            symbol_table.enterScope( n.Scope );
            
            pushState( STATE_INSIDE_NAMESPACE, n, null );
        }


        void exitNameSpace( Container n ) {
            if( n != CurrentClass ) {
                throw new Exception( "oops: misnested namespace " + n.Name + " != " + CurrentClass.Name );
            }
            
            CurrentClass.SymbolList = symbol_table.CurrentScope;
            symbol_table.exitScope();
            popState();
        }
        
        void enterClass( Container c ) {
            if( this.State > STATE_INSIDE_CLASS ) {
                throw new Exception( "oops: beginParseNameSpace from state " + this.State );
                return;
            }
            
            // alloc_direction = 1;

            if( c.Kind != Symbol.CLASS ) {
                throw new Exception( "oops: redefining symbol " + c.Name + " as class" );
                return;
            }

            symbol_table.enterScope( c.Scope );
            
            pushState( STATE_INSIDE_CLASS, c, null );
        }


        void exitClass( Container c ) {
            if( c != CurrentClass ) {
                throw new Exception( "oops: mis-nested classes\n" );
            }
            
            
            CurrentClass.SymbolList = symbol_table.CurrentScope;
            symbol_table.exitScope();
            popState();
        }
        
        void useNameSpace( ParseTree from, Container c ) {
	    for( int i = sp; i >= 0; i = i - 1 ) {
		if( state[sp].State == STATE_INSIDE_NAMESPACE ) {
		    state[sp].UseList.add( c );
		    break;
		}
	    }
        }


        void removeOutput( String name ) {

        }

	String getObjectFileName( String name ) {
	    if( WantNativeObjectFiles ) {
		return getObjectFileName( name, ".o" );
	    } else {
		return getObjectFileName( name, ".bc" );
	    }
	}

	String getObjectFileName( String name, String extension ) {
            StringBuffer file = new StringBuffer();
	    
	    file.append( CacheDir );
	    file.append( name );
	    file.append( extension );

	    return file;
	}

       
        void dumpActiveClasses( String name ) {
            IO.Writer wb = null;
            
            if( name != null ) {
                StringBuffer buffer = new StringBuffer();
                buffer.append( this.CacheDir );
                buffer.append( name );
                buffer.append( ".tmp" );

                wb = IO.File.openCreate( buffer ); 
            }
            master_class_list.dumpActiveClasses( wb );
            if( wb != null ) {
                wb.close();
            }
        }

	get Generic.Set<Container> InterfacesSet {
	    return interfaces_set;
	}

	get String MainClassNameDecorated {
	    return main_class_decorated;
	}

        void closeOutput() {
            if( output != null ) {
		output.println( "# closing output" );
                output.close();
                output = null;
		// last_cleared_output_at = new System.Backtrace().toString();
            }
        }

        get IO.Writer Output {
            if( output != null ) {
                return output;
            } else {
		if( CurrentMethod != null ) {
		    throw new System.Exception( "no output for: " + CurrentMethod.HumanName );
		}
		/*
		IO.Std.err.println( "oops: no output stream: " + new System.Backtrace() );
		IO.Std.err.println( "last cleared at: " + last_cleared_output_at + " from: " + new System.Backtrace() );
		*/
                return IO.Std.err;
            }
        }

	
        Symbol declareSymbol( ParseTree from, Container owner, String name, int kind, int access, int defined, Type type ) {
            Symbol existing = symbol_table.findInCurrentScope( name, Symbol.FIND_ANY );
            
            if( existing != null && kind & Symbol.FLAG_METHOD == 0 ) {
                from.error( "duplicate symbol declaration: " + name );
                return existing;
            }
            
            if( this.State == 0 ) {
                from.error( "oops: defining symbol outside of any scope: " + name );
                return null;
            } else {
                Symbol symbol;
                if( kind & Symbol.FLAG_METHOD != 0 ) {
                    symbol = new Container( null, owner, name, kind, access, type );
                } else {
                    symbol = new Symbol( owner, name, kind, access, type );
                }
                
                symbol.setDefined( defined );
                
                symbol_table.add( symbol );
                if( this.State == STATE_INSIDE_METHOD ) {
                    Container current_method = CurrentMethod;
                    if( current_method == null ) {
                        throw new Exception( "oops: current method is null" );
                    }
		    
		    int k = kind;
		    if( alloc_direction == -1 ) {
			k = k | Symbol.FLAG_LOCAL;
		    }

		    /*
		    IO.Std.err.println( "HHHH: local " + symbol.HumanName );
		    IO.Std.err.println( "HHHH: owner " + symbol.Owner.HumanName );
		    IO.Std.err.println( "HHHH: method " + CurrentMethod.HumanName );
		    IO.Std.err.println( "HHHH: class " + CurrentClass.HumanName );
		    */
		    /*
                    int address = current_method.alloc( k );
                    symbol.setAddress( address );
		    */
                    // IO.Std.err.println( "allocated symbol: " + symbol + ", address: " + symbol.getAddress() );
                } else if( this.State != STATE_INSIDE_CLASS ) {
                    throw new Exception( "oops: unexpected compile state (" + this.State + ") when declaring symbol" );
                }
                
                return symbol;
            }
        }

        Symbol declareVariable( ParseTree from, String name, int flags, int access, Type type ) {
            flags = flags & ~Symbol.FLAG_METHOD;
            if( flags != Symbol.CONST ) {
                flags = flags | Symbol.FLAG_VARIABLE;
            }
            if( this.State == STATE_INSIDE_CLASS ) {
                
                if( flags != Symbol.CONST ) {
                    flags = flags | Symbol.FLAG_CLASS;
                }
                if( type.TypeKind == Type.REFERENCE ) {
                    from.error( "cannot declare variable " + name + " of reference type " + type.dump() + " here" );
                }
                return declareSymbol( from, CurrentClass, name, flags, access, 1, type );
                
            } else if( this.State == STATE_INSIDE_METHOD ) {
                if( type.TypeKind == Type.REFERENCE && !in_parameters ) {
                    from.warn( "cannot declare variable " + name + " of reference type " + type.dump() + " here" );
                }
                int d;
                if( in_parameters ) {
                    d = -1;
                } else {
                    d = 0;
                }

                return declareSymbol( from, CurrentMethod, name, flags, access, d, type );
            } else {
                throw new Exception( "oops: cannot declare symbol " + name + " of kind K" + flags + " in state " + this.State );
                return null;
            }   
        }

	Symbol declareAccessor( ParseTree from, String name, String because ) {
	    Symbol symbol = null;
	    if( this.State != STATE_INSIDE_CLASS ) {
		from.error( "cannot define accessor " + name + " here" );
		return null;
	    }
	    Symbol s = findInCurrentScope( name, Symbol.FIND_ANY );
	    if( s != null ) {
		if( s.Kind == Symbol.ACCESSOR ) {
		    return s;
		} else {
		    from.error( "redefining " + name + " as an accessor (creating accessor from method " + because + ")" );
		}
	    } else {
		s = findSymbol( name, Symbol.FIND_NON_ACCESSOR );

		symbol = declareSymbol( from, CurrentClass, name, Symbol.FLAG_ACCESSOR, 0, 1, null );
		symbol.Address = 0;

		if( s != null && WantWarnHide ) {
                    from.warn( "accessor " + symbol.HumanName + " hides symbol in outer scope " + s.HumanName );
		}

	    }
	    return symbol;
	}

        Symbol declareMethod(
	    ParseTree from,
	    String name,
	    int flags, 
	    int access, 
	    Type type, 
	    Vector<Type> args,
	    String force_decorate )
	{
            flags = flags | Symbol.FLAG_METHOD | Symbol.FLAG_CLASS;

            if( this.State != STATE_INSIDE_CLASS ) {
                from.error( "cannot declare method " + name + " outside of a class" );
            }

	    var decorate = new StringBuffer();
	    var human = new StringBuffer();

	    type.dumpHuman( human );
	    human.append( ' ' );

	    human.append( CurrentClass.HumanName );
	    human.append( '.' );
	    human.append( name );
	    human.append( "(" );

	    decorate.append( "_Z" );
	    
	    decorate.append( CurrentClass.DecoratedName );
	    decorate.Length = decorate.Length - 1; // remove trailing 'E'
	    decorate.append( name.Length );
	    decorate.append( name );
	    decorate.append( 'E' );

	    if( args != null && args.Length > 0 ) {
		bool seen_any = false;
		foreach( Type u; args.elements() ) {
		    // IO.Std.err.println( "concrete type arg: " + u );
		    
		    if( seen_any ) {
			human.append(",");
		    } else {
			seen_any = true;
		    }
		    u.dump( human, decorate );
		}
	    } else {
		decorate.append( 'v' );
	    }

	    human.append( ")" );

	    if( force_decorate != null ) {
		decorate = new StringBuffer(force_decorate);
	    }

            Container current_class = CurrentClass;
            if( current_class.Scope.findMethodDecorated( decorate ) != null ) {
                from.error( "duplicate method definition " + human );
            }

            Container override = current_class.findMethod( name, args, false );
            if( override != null ) {
                if( !override.matches( args, true ) ) {
                    String this_args = ParseTree.dumpArguments( args );
                    String that_args = ParseTree.dumpArguments( override.ArgTypes );
		    if( WantWarnHide ) {
			if( override.Owner == current_class.Owner) {
			    from.warn( "method " + name + "(" + this_args + ") could hide " + override.Owner.HumanName + "." + name + "(" + that_args + ")" );                        
			} else {
			    from.warn( "method " + name + "(" + this_args + ") does not override " + name + "(" + that_args +")" );
			}
		    }
                }  else {
                    if( override.IsPrivate ) {
                        from.error( "cannot override private method " + override.Owner.HumanName + "." + name );
                    } else if( override.compareAccess( access ) != 0 ) {
                        from.error( "cannot override method " + override.Owner.HumanName + "." + name + " with reduced access" );
                    }
                } 
            }

            Container symbol = cast<Container>( declareSymbol( from, current_class, name, flags, access, 1, type ) );
            symbol.setDecoratedName( decorate );
	    symbol.setHumanName( human );
            symbol.setArgTypes( args );
	    CurrentClass.setLastMethodIndex();
            
            return symbol;
        }

        StringBuffer getNameSpaceQualifiers( String class_name ) {
            StringBuffer b = new StringBuffer();
            
            for( int i = 0; i <= sp; i = i + 1 ) {
                if( state[i].State == STATE_INSIDE_NAMESPACE ) {
                    b.append( state[i].CurrentClass.Name );
                    b.append( '.' );
                }
            }
            
            b.append( class_name );
            
            return b;
        }


	StringBuffer getNameSpaceDecorated( String name ) {
	    var b = new StringBuffer();
	    b.append( 'N');
	    populateNameSpaceDecorated( b, name );
	    b.append( 'E' );

	    return b;
	}

        void populateNameSpaceDecorated( StringBuffer b, String name ) {
            
            int qualifier_count = 0;
            int i;

            for( i = 0; i <= sp; i = i + 1 ) {
		var st = state[i].State;
                if( st == STATE_INSIDE_NAMESPACE || st == STATE_INSIDE_CLASS ) {            
                    String s = state[i].CurrentClass.Name;
                    b.append( s.Length );
                    b.append( s );
                }
            }
            
            b.append( name.Length );
            b.append( name );
        }

        Container declareClass( ParseTree from, Container parent, Container owner, String name, Vector<Type> args, int access, bool allow_redefine ) {
            Container class_symbol = null;

	    StringBuffer human, decorate;
	    String search_name = name;

	    if( args != null && args.Length > 0 ) {
		human = getNameSpaceQualifiers( name );
		decorate = new StringBuffer("N");
		populateNameSpaceDecorated( decorate, name );
		decorate.append( "I" );
		human.append( "<" );

		bool seen_any = false;
		foreach( Type u; args.elements() ) {
		    // IO.Std.err.println( "concrete type arg: " + u );
		    
		    if( seen_any ) {
			human.append(",");
		    } else {
			seen_any = true;
		    }
		    u.dump( human, decorate );
		}
		
		human.append( ">" );	    
		decorate.append( "EE" );

		search_name = name + human;
	    } else {
		human = getNameSpaceQualifiers(name);
		decorate = getNameSpaceDecorated(name);
	    }

            Symbol symbol = symbol_table.findInCurrentScope( search_name, Symbol.FIND_ANY );

            if( symbol != null ) {
		if( !(allow_redefine || symbol.NeedsBody) ) {
		    // FIXME: allow re-defining class as class because of predefined classes - need better solution
		    if( symbol.Kind != Symbol.CLASS ) {
			from.error( "redefining " + symbol.HumanName + " as class" );
			return null;
		    } else {
			from.error( "redefining class " + symbol.HumanName );
		    }

		}
                class_symbol = cast<Container>(symbol);
		
            } else {
                symbol = findSymbol(name, Symbol.FIND_ANY);

                class_symbol = new Container( parent, owner, name );
                class_symbol.setAccess( access );
                class_symbol.setType( new Type( Type.CLASS, class_symbol ) );
                
                master_class_list.add( class_symbol );
                symbol_table.add( class_symbol );
                symbol_table.enterScope();
                // fprintf( stderr, "declaring class %p %s, setting scope to %p\n", class_symbol, class_symbol.getName(), symbol_table.getCurrentScope() );
                class_symbol.setSymbolList( symbol_table.CurrentScope );
                symbol_table.exitScope();

                if( symbol != null && WantWarnHide ) {
                    from.warn( "class " + class_symbol.HumanName + " hides symbol in outer scope " + symbol.HumanName );
                }
            }

	    class_symbol.setDecoratedName( decorate );
	    class_symbol.setHumanName( human );

            class_symbol.setDefined( 1 );
            
            if( class_symbol.Name.equals("Main") ) {
                if( main_class_name == null ) {
		    main_class = class_symbol;
                    main_class_name = class_symbol.HumanName;
                    main_class_decorated = class_symbol.DecoratedName;
		    main_class_init = "_Z" + main_class_decorated.substring(0,main_class_decorated.Length-1) + "4initEv";
                } else if( WantLinkLibraries ) {
                    from.error( "duplicate Main class: " + class_symbol.HumanName + " versus " + main_class_name );
                }
            } 
            
            return class_symbol;
        }

        void middleParseClass( Container c ) {
            if( this.State != STATE_INSIDE_CLASS ) {
                throw new Exception( "oops: middleParseClass but not STATE_INSIDE_CLASS" );
            }
            
            if( CurrentClass != c ) {
                throw new Exception( "oops: middleParseClass but current class doesn't match" );
                return;
            }
            
            if( c == null ) {
                throw new Exception( "oops: middleParseClass but current class is null" );
            }
            
            
            c.setSymbolList( symbol_table.CurrentScope );
            symbol_table.exitScope();
            
        }

	void beginParseRegParams() {
	    // IO.Std.err.println( "begin parse reg params" );
	    in_parameters = true;
	    alloc_direction = -1;
	}

	void beginParseStackParams() {
	    // IO.Std.err.println( "begin parse stack params" );
	    in_parameters = true;
	    alloc_direction = 1;
	}

	/*
	void beginParseLocals() {
	    alloc_direction = -1;
	}
	*/

        void beginParseEnum( ParseTree from, Container enum_symbol ) {
            if( this.State > STATE_INSIDE_CLASS ) {
                throw new Exception( "oops: beginParseEnum from state " + this.State );
            }
            
            alloc_direction = 1;
            
            if( enum_symbol == null ) {
                throw new Exception( "oops: missing enum" );
            }
            
            if( !enum_symbol.NeedsBody ) {
                from.error( enum_symbol.HumanName + " already has a body" );
                return;
            }
            
            symbol_table.enterScope();
            enum_symbol.setSymbolList( symbol_table.CurrentScope );
            
            pushState(STATE_INSIDE_CLASS, enum_symbol, null );
        }
        
        void endParseEnum() {
            if( this.State != STATE_INSIDE_CLASS ) {
                throw new Exception( "oops: endParseEnum but not STATE_INSIDE_CLASS" );
            }
            
            symbol_table.exitScope();
            popState();
            closeOutput();
        }

        void declareEnumMember( ParseTree from, String name, LLVM.Value value ) {
            Container enum_symbol = CurrentClass;
            Symbol symbol = symbol_table.findInCurrentScope( name, Symbol.FIND_ANY );
            
            if( enum_symbol == null ) {
                throw new Exception( "oops: declaring enum member " + name + " outside any enum" );
            }
            
            if( symbol != null ) {
                from.error( "redefining existing enum member " + name );
                return;
            }
            
            symbol = declareSymbol( from, enum_symbol, name, Symbol.CONST, Symbol.ACCESS_PUBLIC, 1, enum_symbol.Type );

            symbol.LLVMValue = value;
        }

        Container declareEnum( ParseTree from, String name, int access ) {
            Container enum_symbol = null;
            Symbol symbol = symbol_table.findInCurrentScope( name, Symbol.FIND_ANY );
            
            Container owner = CurrentClass;
            if( owner == null ) {
                owner = CurrentNameSpace;
            }
            
            if( symbol != null ) {
                from.error( "redefining " + symbol.HumanName + " as enum" );
                return null;
            } else {
                symbol = findSymbol(name, Symbol.FIND_ANY);
                
                enum_symbol = new Container( null, owner, name, Symbol.ENUM, access, null );
                
                enum_symbol.setType( new  Type( Type.ENUM, enum_symbol ) );
                enum_symbol.setDefined( 1 );
                
                symbol_table.add( enum_symbol );
                
                enum_symbol.setHumanName( getNameSpaceQualifiers(name) );
                enum_symbol.setDecoratedName( getNameSpaceDecorated(name) );

                if( symbol != null && WantWarnHide ) {
                    from.warn( "enum " + enum_symbol.HumanName + " hides symbol in outer scope " + symbol.HumanName );
                }
                
                return enum_symbol;
            }
        }


        Container declareType( ParseTree from, String name, int access, Type type ) {
            Container type_symbol = null;
            Symbol symbol = symbol_table.findInCurrentScope( name, Symbol.FIND_ANY );
            
            Container owner = CurrentClass;
            if( owner == null ) {
                owner = CurrentNameSpace;
            }
            
            if( symbol != null ) {
                from.error( "redefining " + symbol.HumanName + " as a type" );
                return null;
            } else {
                symbol = findSymbol(name, Symbol.FIND_ANY);
               
                type_symbol = new Container( null, owner, name, Symbol.TYPE, access, null );

		// IO.Std.err.println( "defined type, kind is: " + type_symbol.Kind + " (0x" + String.hex(type_symbol.Kind) + ")" );
                
                type_symbol.setType( type );
                type_symbol.setDefined( 1 );
                
                symbol_table.add( type_symbol );
                
                type_symbol.setHumanName( getNameSpaceQualifiers(name) );
                type_symbol.setDecoratedName( getNameSpaceDecorated(name) );

		// FIXME: hash of type probably more appropriate?
		type_symbol.setAddress( 0 );

                if( symbol != null && WantWarnHide ) {
                    from.warn( "type " + type_symbol.HumanName + " hides symbol in outer scope " + symbol.HumanName );
                }


                return type_symbol;
            }
        }
  
        void beginParseClass( ParseTree from, Container parent, Container class_symbol, String name ) {
            if( this.State > STATE_INSIDE_NAMESPACE ) {
                throw new Exception( "oops: beginParseClass from state " + this.State );
            }
            
            alloc_direction = 1;
            
            if( class_symbol == null ) {
                throw new Exception( "missing class " + name );
            }
            
            if( !class_symbol.NeedsBody ) {
                from.error( name + " already has a body" );
                return;
            }

	    if( parent != null ) {
		if( class_symbol.Super == null ) {
		    // IO.Std.err.println( "HHHHHH: super class for " + class_symbol + " is not set, setting it now to " + parent );
		    class_symbol.setSuper( parent );
		    /*
		} else {

		    IO.Std.err.println( "WWWWWW: will not overwrite super class " + class_symbol.Super + " for " + class_symbol + " with " + parent + " from " + new System.Backtrace() );
		    */
		}
	    }
            symbol_table.enterScope( class_symbol.Scope );
            
            pushState( STATE_INSIDE_CLASS, class_symbol, null );
        }

        void endParseClass( Container c ) {
            if( this.State != STATE_INSIDE_CLASS ) {
                throw new Exception( "oops: endParseClass but not STATE_INSIDE_CLASS" );
            }
            
            popState();
            closeOutput();
        }
        
        void beginCompileClass( ParseTree from, Container class_symbol, String name ) {
            if( class_symbol == null ) {
                throw new Exception( "oops: cannot compile body for undefined class " + name );
            }
            
            if( class_symbol.Kind == Symbol.CLASS ) {
                Container current_class = cast<Container>(class_symbol);
                
                symbol_table.enterScope( current_class.Scope );
                
                pushState( STATE_INSIDE_CLASS, current_class, null );
            } else {
                throw new Exception( "oops: cannot compile body for non-class symbol " + name );
            }
            
            unsafe_flags = 0;
        }

        void markCodeUnsafe( int flags ) {
            unsafe_flags = unsafe_flags | flags;
        }

	/*
	void markNotLeaf() {
	    Container m = CurrentMethod;
	    if( m != null ) {
		m.markNotLeaf();
	    }
	}
	*/

        get int UnsafeFlags {
            return unsafe_flags;
        }
        
        void endCompileClass( Container c ) {
            symbol_table.exitScope();
            popState();
            closeOutput();
        }
        
        void beginCompileMethod( ParseTree from, Container method_class, String decorated_name ) {
            if( this.State > STATE_INSIDE_CLASS ) {
                throw new Exception( "oops: trying to beginCompileMethod: " + decorated_name + " from compile state " + this.State );
            }
            
            if( method_class == null ) {
                throw new Exception( "oops: cannot compile body for undefined method " + decorated_name );
            } else if( method_class.Kind & Symbol.FLAG_METHOD == 0 ) {
                throw new Exception( "oops: redefining symbol " + decorated_name + " as method" );
            }
            
            alloc_direction = 1;
            
	    // IO.Std.err.println( "begin compile: " + decorated_name );
	    // IO.Std.err.println( "return label initially: " + return_label );
            
            symbol_table.enterScope( method_class.Scope );

            pushState( STATE_INSIDE_METHOD, CurrentClass, method_class );

	    seen_exception_handler = false;
        }

	void clearThrowBlocks() {
	    ThrowNullBlock = null;
	    ThrowBoundsBlock = null;
	}

	bool seenExceptionHandler() {
	    return seen_exception_handler;
	}

	void markSeenExceptionHandler() {
	    seen_exception_handler = true;
	}

        void endCompileMethod( Container method_class ) {
            symbol_table.exitScope();

            popState();
        }

        void beginParseMethodArgs( ParseTree from, Container method ) {
            if( this.State != STATE_INSIDE_CLASS ) {
                throw new Exception( "oops: trying to beginParseMethodArgs from compile state " + this.State );
            }
            symbol_table.enterScope();
            
            pushState( STATE_INSIDE_METHOD, CurrentClass, method );
            
            // FIXME: this is not a good place for these constants
	    /*
            if( method.IsStatic ) {
                method.clearStackOffset( Machine.FIRST_ARGUMENT_OFFSET_STATIC, Machine.FIRST_LOCAL_OFFSET );
            } else {
                method.clearStackOffset( Machine.FIRST_ARGUMENT_OFFSET, Machine.FIRST_LOCAL_OFFSET );
            }
	    */
	    beginParseRegParams();
        }

        void endParseMethodArgs( Container method ) {
            if( this.State != STATE_INSIDE_METHOD ) {
                throw new Exception( "oops: trying to endParseMethodArgs from compile state " + this.State );
            }
            
            alloc_direction = 1;
	    in_parameters = false;
            
            method.SymbolList = symbol_table.CurrentScope;

            symbol_table.exitScope();
            
            popState();
        }
    
        void beginParseMethodBody( Container method ) {
            alloc_direction = -1;
        }

        void endParseMethodBody( Container method ) {
	    alloc_direction = 1;
        }

	void registerInterface( Container iface ) {
	    interfaces_set.add( iface );
	}

	void registerGeneric( State[] saved_state, SymbolList[] saved_symbol, Container clazz, ClassDef def ) {
	    generic_templates.add( new Template( saved_state, saved_symbol, clazz, def ) );
	}

	Type findGeneric( Container c, Vector<Type> arguments, bool find_only ) {
	    if( c.Template != null ) {
		throw new Exception( c.HumanName + "is already an specialization of " + c.Template.HumanName );
	    }

	    foreach( Container d; generic_instances.elements() ) {
		// IO.Std.err.println( "check " + d + " from template " + d.Template + " with arguments: " + d.TypeArgs );
		if( d.Template == c && d.checkTypeArgs( arguments ) ) {
		    // d.markReferenced();
		    // IO.Std.err.println( "returning this instance" );
		    return d.Type;
		    // return new Type( Type.CLASS, d );
		}
	    }

	    if( pass > CompilePass.CHECK_TEMPLATES ) {
		IO.Std.err.println( "find generic " + c + " " + arguments + ": wrong pass should have been done earlier" );
		throw new System.Exception( "find generic " + c + " " + arguments + ": wrong pass should have been done earlier" ); 
	    }

	    //	    if( !find_only ) {
	    Container e = makeConcrete( c, arguments );

	    if( c == ParseTree.array_type.Clazz ) {
		e.IsArray = true;
	    }

	    if( e == null ) {
		return ParseTree.UndefinedType;
	    }
	    // e.markReferenced();
	    // IO.Std.err.println( "created new instance: " + e + " from template " + e.Template );
	    
	    generic_instances.add( e );
	    return e.Type;
	    // return new Type( Type.CLASS, e );
	    //	    } else {
	    //	throw new Exception( "cannot make new generic class " + c + " here" );
	    //}
	}

	Type findProcType( Type want_return, Vector<Type> want_arguments ) {
	    // Not using existing code for matching methods here because:
	    // - only interested in exact match
	    // - want return 

	    int want_arguments_length;
	    if( want_arguments != null ) {
		want_arguments_length = want_arguments.Length;
	    }

	    foreach( Type d; proc_instances.elements() ) {
		// IO.Std.err.println( "existing proc type: " + d );

		if( !d.Clazz.matches( want_arguments, true ) ) {
		    // IO.Std.err.println( "arguments don't match" );
		    // IO.Std.err.println( "want: " + want_arguments );
		    // IO.Std.err.println( "have: " + d.Clazz.ArgTypes );
		    continue;
		}

		if( !d.Clazz.Type.equals( want_return ) ) {
		    // IO.Std.err.println( "return type doesn't match" );
		    // IO.Std.err.println( "want: " + want_return);
		    // IO.Std.err.println( "have: " + d.Clazz.Type );
		    continue;
		}

		// IO.Std.err.println( "return existing proc type " + d + " for " + want_return + " proc(" + want_arguments + ")" );
		return d;
	    }

	    // IO.Std.err.println( "need new proc type: " + want_return + " proc(" + want_arguments + ")" );

	    Container c = new Container( null, null, "proc", Symbol.PROC, 0, want_return );
	    c.ArgTypes = want_arguments;

	    var decorated = new StringBuffer();
	    var human = new StringBuffer();
            decorated.append( "F" );
            
	    want_return.dumpDecorate( decorated );
	    foreach( Type t; want_arguments.elements() ) {
		t.dumpDecorate( decorated );
	    }

	    decorated.append( "E" );

	    c.DecoratedName = "" + decorated;

	    want_return.dumpHuman( human );
	    human.append( " proc(" );
	    bool seen_any;
	    foreach( Type u; want_arguments.elements() ) {
		if( seen_any ) {
		    human.append( "," );
		}
		u.dumpHuman( human );
		seen_any = true;
	    }
	    human.append( ")" );

	    c.HumanName = human;

	    // IO.Std.err.println( "created proc container: " + c );
	    
	    Type r = new Type( Type.PROC, c );

	    // IO.Std.err.println( "created proc type: " + r );

	    proc_instances.add( r );
	    return r;
	}

	get int GenericInstanceCount {
	    return generic_instances.Length;
	}

	Container makeConcrete( Container c, Vector<Type> arguments ) {
	    foreach( Template t; generic_templates.elements() ) {
		if( t.clazz == c ) {
		    State[] saved_state = this.SaveState;
		    SymbolList[] saved_symbol = this.SymbolState;

		    this.SaveState = t.saved_state;
		    this.SymbolState = t.saved_symbol;

		    Container r = t.def.makeConcrete( this, arguments );

		    this.SaveState = saved_state;
		    this.SymbolState = saved_symbol;

		    return r;
		}
	    }	    
	}

        Symbol findSymbol( String name, int find_what ) {
            Symbol result = null;
            
            // search order:
            //   current method
            //   current class and all its super classes
            //   namespaces from innermost to outermost
            //     search order within namespace:
            //       members
            //       values from used namespaces
            //   global scope


	    for( int i = sp; i > 0; i = i - 1 ) {
		State s = state[i];

		if( s.CurrentMethod != null ) {
		    // IO.Std.err.println( "search level " + sp + " method: " + s.CurrentMethod.HumanName );
		    result = s.CurrentMethod.findSymbol( name, find_what );
		    if( result != null ) {
			return result;
		    }
		} else {
		    if( s.UseList != null ) {
			// IO.Std.err.println( "search level " + sp + " use list: " + s.UseList );
			result = s.UseList.find( name, find_what, true );
			if( result != null ) {
			    return result;
			}
		    }
		    if( s.CurrentClass != null ) {
			// IO.Std.err.println( "search level " + sp + " container: " + s.CurrentClass.HumanName );
			result = s.CurrentClass.findSymbol( name, find_what );
			if( result != null ) {
			    return result;
			}
		    }
		}
	    }

	    return symbol_table.findGlobal( name, find_what );

            // return result;
        }

        Container findClass( String qualified_name ) {
            return cast<Container>(master_class_list.findDecorated( qualified_name ));
        }

        Container findMethod( String name, Vector<Type> arguments, bool exact ) {
            // only classes can contain methods so search order is simply:
            //  current class and its superclasses

            // finds first match only - do not use unless exact
	    /*
	    Container current_method = CurrentMethod;
	    if( current_method != null ) {
		Container m = current_method.findMethod( name, arguments, exact );
		if( m != null ) {
		    return m;
		}
	    }
	    */

            Container current_class = CurrentClass;
            if( current_class != null ) {
                return current_class.findMethod( name, arguments, exact );
            }

            return null;
        }

        Container findBestMethod( String name, Vector<Type> arguments, Quality quality ) {
            // only classes can contain methods so search order is simply:
            //  current class and its superclasses

            Container current_class = CurrentClass;
            if( current_class != null ) {		
		// FIXME: this looks wrong:
		quality.score = 0;
                return current_class.findBestMethod( name, arguments, quality, true );
            }

	    return null;
        }
    
        Symbol findDecorated( String name ) {
            Container current_class = CurrentClass;
            if( current_class != null ) {
                return current_class.findDecorated( name );
            }
            
            return null;
        }
        

        Symbol findInCurrentScope( String name, int find_what ) {
            return symbol_table.findInCurrentScope( name, find_what );
        }


        get int State {
            return state[sp].State;
        }

	get bool WantPrintDeps {
	    return want_print_deps;
	}

	set bool WantPrintDeps = d {
	    want_print_deps = d;
	}

	get bool Want64BitTarget {
	    return want_64bit_target;
	}

	set bool Want64BitTarget = b { 
	    want_64bit_target = b;
	}

	get bool WantOneFile {
	    return want_one_file;
	}

	set bool WantOneFile = o {
	    want_one_file = o;
	}

	get bool WantForceLink {
	    return want_force_link;
	}

	set bool WantForceLink = f {
	    want_force_link = f;
	}

        get int OptimizeLevel {
	    return optimize_level;
	}

	set int OptimizeLevel = o {
	    optimize_level = o;
	}

	static get int WantJobs {
	    return want_jobs;
	}

	static set int WantJobs = j {
	    this.want_jobs = j;
	}

        get bool WantStatistics {
	    return want_statistics;
	}

	set bool WantStatistics = s {
	    want_statistics = s;
	}

        get bool WantSharedStandardLibrary {
	    return want_shared_standard_library;
	}

	set bool WantSharedStandardLibrary = s {
	    want_shared_standard_library = s;
	}

        get bool WantLinkLibraries {
	    return want_link_libraries;
	}

        set bool WantLinkLibraries = l {
	    want_link_libraries = l;
	}

	get bool WantNativeExecutable {
	    return want_native_executable;
	}

	set bool WantNativeExecutable = n {
	    want_native_executable = n;
	}

        get bool WantNativeObjectFiles {
	    return want_native_object_files;
        }

        set bool WantNativeObjectFiles = n {
	    want_native_object_files = n;
	}

        get bool WantNativeLibraryFiles {
	    return want_native_library_files;
	}
	
	set bool WantNativeLibraryFiles = l {
	    want_native_library_files = l;
	}

        get bool WantPIC {
	    return want_pic;
	}

	set bool WantPIC = p {
	    want_pic = p;
	}

        get bool WantExport {
	    return want_export;
	}

	set bool WantExport = e {
	    want_export = e;
	}

	get bool WantSafe {
	    return want_safe;
	}

	set bool WantSafe = v {
	    want_safe = v;
	}

	get bool WantVerbose {
	    return want_verbose;
	}

	set bool WantVerbose = v {
	    if( !v ) {
		want_very_verbose = false;
	    }
	    want_verbose = v;
	}

	get bool WantVeryVerbose {
	    return want_very_verbose;
	}

	set bool WantVeryVerbose = v {
	    if( v ) {
		want_verbose = true;
	    }
	    want_very_verbose = v;
	}

	get bool WantPrint {
	    return want_print;
	}

	set bool WantPrint = p {
	    want_print = p;
	}	    

	get bool WantBoundsCheck {
	    return WarnFlag[WANT_BOUNDS_CHECK];
	}

	set bool WantBoundsCheck = b {
	    WarnFlag[WANT_BOUNDS_CHECK] = b;
	}


	set int WarnFlags = bits {
	    if( sp < 0 ) {
		default_warn_flags = bits;
	    } else {
		state[sp].WarnFlags = bits;
	    }
	}

	get int WarnFlags {
	    if( sp < 0 ) {
		return default_warn_flags;
	    } else {
		return state[sp].WarnFlags;
	    }
	}	    

	set bool WarnFlag[int number] = v {
	    int warn_flags = WarnFlags;

	    if( v ) {
		warn_flags = warn_flags | (1 << number);
	    } else {
		warn_flags = warn_flags & ~(1 << number);
	    }

	    WarnFlags = warn_flags;
	}

	get bool WarnFlag[int number] {
	    int warn_flags = WarnFlags;

	    return warn_flags & (1 << number) != 0;
	}

	get bool WantWarnUnsafe {
	    return WarnFlag[WARN_UNSAFE];
	}

	set bool WantWarnUnsafe = w {
	    WarnFlag[WARN_UNSAFE] = w;
	}

	get bool WantWarnHide {
	    return WarnFlag[WARN_HIDE];
	}

	set bool WantWarnHide = w {
	    WarnFlag[WARN_HIDE] = w;
	}

	get bool WantWarnResolve {
	    return WarnFlag[WARN_RESOLVE];
	}

	set bool WantWarnResolve = w {
	    WarnFlag[WARN_RESOLVE] = w;
	}

	get bool WantMarkUnsafe {
	    // !trusted || want mark unsafe:
	    return !WarnFlag[IS_TRUSTED] || WarnFlag[MARK_UNSAFE];
	}

	set bool WantMarkUnsafe = w {
	    WarnFlag[MARK_UNSAFE] = w;
	}

	get bool Trusted {
	    return WarnFlag[IS_TRUSTED];
	}

	set bool Trusted = w {
	    WarnFlag[IS_TRUSTED] = w;
	}

	get bool WantLineNumbers {
	    return WarnFlag[WANT_DEBUG];
	}

	set bool WantLineNumbers = v {
	    WarnFlag[WANT_DEBUG] = v;
	}

        get bool WantCastCheck {
	    return WarnFlag[WANT_CAST_CHECK];
	}

	set bool WantCastCheck = p {
	    WarnFlag[WANT_CAST_CHECK] = p;
	}

        get bool WantWarnInit {
	    return WarnFlag[WARN_INIT];
        }

	set bool WantWarnInit = p {
	    WarnFlag[WARN_INIT] = p;
	}

        get bool WantPack {
	    return WarnFlag[WANT_PACK];
	}

	set bool WantPack = p {
	    WarnFlag[WANT_PACK] = p;
	}

	get bool WantNullCheck {
	    return WarnFlag[WANT_NULL_CHECK];
	}

	set bool WantNullCheck = z {
	    WarnFlag[WANT_NULL_CHECK] = z;
	}
        get bool WantVirtual {
	    return WarnFlag[WANT_VIRTUAL];
	}

	set bool WantVirtual = b {
	    WarnFlag[WANT_VIRTUAL] = b;
	}

	get bool WantInline {
	    // IO.Std.err.println( "want inline: " + want_inline );
	    return want_inline;
	}
	
	set bool WantInline = i {
	    want_inline = i;
	}

	get bool WantCoalesce {
	    // IO.Std.err.println( "want coalesce: " + want_coalesce );
	    return want_coalesce;
	}

	set bool WantCoalesce = c {
	    want_coalesce = c;
	}

	get bool WantRegVars {
	    // IO.Std.err.println( "want reg vars: " + want_regvars );
	    return want_regvars;
	}

	set bool WantRegVars = v {
	    want_regvars = v;
	}

	get bool WantReturnJumpElim {
	    // IO.Std.err.println( "want return jump elimination: " + want_return_jump_elim );
	    return want_return_jump_elim;
	}

	set bool WantReturnJumpElim = r {
	    want_return_jump_elim = r;
	}
	    
	get bool WantSplitBounds {
	    return want_split_bounds;
	}

	set bool WantSplitBounds = b {
	    want_split_bounds = b;
	}

	get bool WantCSE {
	    return want_cse;
	}

	set bool WantCSE = c {
	    want_cse = c;
	}

        get bool InLastInlinePass {
	    return in_last_inline_pass;
	}
 
	get bool IsInline {
	    return state[sp].IsInline;
	}

	set bool IsInline = b {
	    state[sp].IsInline = b;
	}

	get bool InlineOK {
	    return state[sp].InlineOK;
	}

	set bool InlineOK = b {
	    state[sp].InlineOK = b;
	}

	void notLeaf() {
	    if( IsInline ) {
		throw new NotLeafInlineException();
	    }
	}

        get String CurrentClassName {
            return state[sp].CurrentClass.Name;
        }

        get String CurrentSourceFileName {
            // IO.Std.err.println( "current source file name: " + state[sp].getSourceFileName() );
            return state[sp].SourceFileName;
        }

	get SymbolList UseList {
	    return state[sp].UseList;
	}

	set SymbolList UseList = u { 
	    state[sp].UseList = u;
	}

        get Container CurrentClass {
            return state[sp].CurrentClass;
        }

        get Container CurrentMethod {
            return state[sp].CurrentMethod;
        }
    
        get Container CurrentContext {
            Container context = CurrentMethod;
            if( context != null ) {
                return context;
            }

            context = CurrentClass;
            if( context != null ) {
                return context;
            }
     
            return CurrentNameSpace;
        }
    
        get Container CurrentNameSpace {
            for( int i = sp; i >= 0; i = i - 1 ) {
                if( state[i].State == STATE_INSIDE_NAMESPACE ) {
                    return state[i].CurrentClass;
                }
            }
            
            return null;
        }
    }

    class State extends System.Object {
        int state;
	bool inline;    // currently compiling intermediate code for an inline method
	bool inline_ok; // it's OK to inline a method here 
        Container current_class;
        Container current_method;
	SymbolList use_list; // saved symbol use list for template expansions
        String source_file_name;
	IO.Writer output;
	int warn_flags;

        void init( int s, Container c, Container m, String sfn, int wf ) {
            super.init();
            state = s;
            current_class = c;
            current_method = m;
            source_file_name = sfn;
	    warn_flags = wf;

	    // ParseTree.initUndefinedSymbols(this);
	    // ParseTree.initUndefinedSymbols(this);

            // IO.Std.err.println( "new State(" + c + "," + m + "," + sfn + ")" );
        }      

	State copy() {
	    return cast State(clone());
	}

	IO.Writer getOutput() {	    
	    return output;
	}

	void setOutput( IO.Writer o ) {
	    output = o;
	}

        int getState() {
            return state;
        }

	SymbolList getUseList() {
	    return use_list;
	}

	void setUseList( SymbolList u ) {
	    if( use_list != null && use_list != u ) {
		IO.Std.err.println( "oops: overwriting use list: " + new System.Backtrace() );
	    }
	    use_list = u;
	}

        Container getCurrentClass() {
            return current_class;
        }

        Container getCurrentMethod() {
            return current_method;
        }

        String getSourceFileName() {
            return source_file_name;
        }

	bool getIsInline() {
	    return inline;
	}

	void setIsInline( bool inline ) {
	    this.inline = inline;
	}

	bool getInlineOK() {
	    return inline_ok;
	}

	void setInlineOK( bool inline_ok ) {
	    this.inline_ok = inline_ok;
	}

	set int WarnFlags = wf {
	    warn_flags = wf;
	}

	get int WarnFlags {
	    return warn_flags;
	}
    }
}
