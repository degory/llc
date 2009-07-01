// Copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import stream;
import oset;
import machine;
import symbol;
import container;
import intermediate;
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

    use Gen.ILabel;
    use Gen.IString;
    use Gen.ITree;
    use Gen.Machine;
    use Gen.MBitSet;
    use Gen.TempFactory;
    // use Util.ThreadPool;

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

	void init( CompileState state, Package package, TempFactory temp_factory ) {
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
	    // IO.Std.err.println( "process: " + state );
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
            UNSAFE_LINK = 8;

        public const int
            STATE_OUTSIDE_CLASS = 0,
            STATE_INSIDE_NAMESPACE = 1,
            STATE_INSIDE_CLASS = 2,
            STATE_INSIDE_METHOD = 3;

	private const int
	    DEFAULT_WARN_FLAGS = 15 | 32; // all warnings enabled, trusted flag not set

	static CompileState instance;

        SymbolList master_class_list;
        SymbolTable symbol_table;

	Vector<Template> generic_templates;
	Vector<Container> generic_instances;

	Generic.Set<Container> interfaces_set;

        NeedCompile need_compile;

	Vector<WriteHashFile> write_hash_files;

        Vector<Package> to_compile_list;
        Vector<Container> to_build_tables_list;

	Vector<String> libraries;
        Generic.Set<String> to_link_set;

        Vector<String> search_path;
        Vector<String> visited_files;

	int active_processes;

        int sp;
        State[] state;

        LoopStack loop_stack;

	int block_level;

        CompilePass pass;
      
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

	int default_warn_flags;

	int max_inline_count;

        int spill_label;

        ILabel return_label;

        IO.Writer output;
        
        int unsafe_flags;

        String main_class_name;
        String main_class_decorated;
	String executable_name;
	String project_name;

        int exception_level;
	ExceptionDescriptor[] exception;

        String lcache_dir;
        static String LIBRARY_DIR = "/usr/lang/lib/";
        static String label_prefix = ".L";
        static bool one_file = false;

	// ThreadPool pool;
	ProcessPool pool;

	CompileState copy() {
	    // IO.Std.err.println( "before copy, this is: " + System.String.hex(cast int(this)) );

	    CompileState result = cast CompileState(clone());

	    // IO.Std.err.println( "sp is: " + sp );

	    assert(exception_level == 0);

	    result.exception_level = 0;
	    result.exception = new ExceptionDescriptor[32];

	    assert(sp == 0);

	    /*
	    var new_state = new State[30];

	    for( int i = 0; i <= sp; i = i + 1 ) {
		new_state[i] = state[i];
	    }
	    */

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

	    // FIXME: replace these stack arrays with vectors and make the stack pointers
	    // point at the stack tops rather than above them:
            sp = 0;
            state = new State[30];
            state[sp] = new State( STATE_OUTSIDE_CLASS, null, null, null, DEFAULT_WARN_FLAGS );

	    exception_level = 0;
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

	    generic_templates = new Vector<Template>();
	    generic_instances = new Vector<Container>();
	 
	    interfaces_set = new Generic.Set<Container>();
 
	    ParseTree.initUndefinedSymbols(this);
	    if( instance == null ) {
		instance = this;
	    } else {
		throw new Exception( "attempting to create second CompileState instance" );
	    }

	    // pool = new ThreadPool(2);
	    // pool.start();
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
		pool = new ProcessPool(this,WantJobs,master_class_list.Length);
		pool.start();
	    }

	    pool.submit(w);

	    // pool.submit( w );	    
	}

	void initSearchPaths( bool safe ) {
	    if( safe ) {
		addSearchPath( LIBRARY_DIR + Machine.NAME + "/" );
		addSearchPath( LIBRARY_DIR + "trusted/" );
		addSearchPath( LIBRARY_DIR + "safe/" );
	    } else {
		addSearchPath( "./" );
		addSearchPath( LIBRARY_DIR + Machine.NAME + "/" );
		addSearchPath( LIBRARY_DIR + "trusted/" );
		addSearchPath( LIBRARY_DIR + "unsafe/" );
	    }
	}

	bool isSourceFileTrusted( String name ) {
	    return
		name.startsWith( LIBRARY_DIR + "trusted/" ) ||
		name.startsWith( LIBRARY_DIR + "safe/" );
	}

	static get CompileState Instance {
	    // IO.Std.err.println( "get instance is not thread safe, expect trouble: " + new Backtrace() );
	    return instance;
	}

	get LoopStack Loops {
	    return loop_stack;
	}

	get String LCacheDir {
	    return lcache_dir;
	}

	// FIXME: this is mad - stack top is level - 1
	get int ExceptionLevel {
	    return exception_level;
	}

	set int ExceptionLevel = l {
	    exception_level = l;
	}

	void resetExceptionLevel() {
	    exception_level = 0;
	}

	get ExceptionDescriptor Exception[int n] {
	    return exception[n];
	}

	set ExceptionDescriptor Exception[int n] = e {
	    exception[n] = e;
	}

	void pushException(ExceptionDescriptor e) {
	    exception[exception_level] = e;
	    exception_level = exception_level + 1;
	}

	ExceptionDescriptor popException() {
	    exception_level = exception_level - 1;
	    return exception[exception_level];
	}

	get ExceptionDescriptor TopException {
	    return exception[exception_level-1];
	}

	get bool InExceptionHandler {
	    return exception_level > 0;
	}

	get ExceptionDescriptor TopFinallyOrReturn {
	    for( int i = exception_level-1; i >= 0; i = i - 1 ) {
		if( exception[i].type == EDType.CATCH_FINALLY ||
		    exception[i].type == EDType.CATCH_RETURN ) {
		    return exception[i];
		}
	    }

	    return null;
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

	void enterBlock() {
	    block_level = block_level + 1;
	}

	void exitBlock() {
	    block_level = block_level - 1;
	}

	get int BlockLevel {
	    return block_level;
	}

	get String CacheDir {
	    if( lcache_dir == null ) {
		if( project_name != null ) {
		    lcache_dir = "/tmp/lcache-" + project_name + "/";
		} else {
		    lcache_dir = "/tmp/lcache-" + Machine.NAME + "/";
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
	    if( WantVerbose ) {
		ParseTree.message( "adding library: " + name );
	    }
	    libraries.add( name );
	}

        void addLinkFile( String name ) {
	    // not sure why this is called repeatedly but avoid linking the same object file more than once:
	    if( to_link_set.contains(name) ) {
      		return;
	    }
            to_link_set.add( name );
        }

        void addHashFile( String file_name, int hash ) {
            write_hash_files.add( new WriteHashFile(lcache_dir + file_name, hash) );
        }

	void writeHashFiles() {
	    /*
	    foreach( Container c; master_class_list.SymbolList.elements() ) {
		c.getHash();
	    }
	    */
	    WriteHashFile.write( write_hash_files );	  
	}

        void compilePending() {
            int i, j;
            Package p;

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
		ParseTree.message( "declaring templace instances..." );
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
		ParseTree.message( "declaring class objects..." );
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

            // IO.Std.err.println( "parsing definitions..." );
	    if( WantInline ) {
		Pass = CompilePass.CHECK_INLINE;

		if( WantVeryVerbose ) {
		    ParseTree.message( "checking inline methods..." );
		}
		// determine which methods can potentially be inlined (no exception handling,
		// register only parameters etc.):
		
		// IO.Std.err.println( "parsing definitions..." );
		for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
		    p = cast<Package>(to_compile_list[i]);
		    p.checkInline(this);
		}

		// attempt to prepare inlineable intermediate code for any methods that:
		//    were not marked as not inlineable by check-inline pass
		//    are leaves (do not call other methods, except inlined methods)
		//    are final (not overridden)

		// this process is repeated as methods may initially be non-leaf but
		// become leaf as methods they call are inlined:

		Pass = CompilePass.PREPARE_INLINE;
		for( j = 0; j < Machine.INLINE_DEPTH; j = j + 1 ) {
		    // IO.Std.err.println( "start inline pass: " + i + " file " + file_name );
		    if( WantVeryVerbose ) {
			ParseTree.message( "preparing inline methods pass " + (j+1) + "..." );
		    }
		    
		    for( i = 0; i < to_compile_list.Length; i = i + 1 ) {
			p = cast<Package>(to_compile_list[i]);
			p.prepareInline(this);
		    }
		}
	    }

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

	    if( WantJobs <= 1 && !InChildProcess ) {
		writeHashFiles();
	    }

	    if( InChildProcess ) {
		writeHashFiles();
		pool.close();
		if( ParseTree.didErrorsOccur() ) {
		    native.exit(1);
		} else {
		    native.exit(0);
		}
	    } else if( ParseTree.didErrorsOccur() ) {
		ParseTree.message( "*** errors occurred ***" );
		return;
	    }

	    if( main_class_decorated != null ) {
		// IO.Std.err.println( "writing out entry point for main class " + main_class_decorated );
		
		IO.Writer f = IO.File.openCreate( this.CacheDir + "entry.s" );

		Machine.emitEntryPoint( f, main_class_decorated );

		f.close();
		assembleFile( "entry" );
		addLinkFile( getObjectFileName("entry", ".o") );
	    } else {
		ParseTree.message( "*** no main class ***" );
		return;
	    }

	    // wait(0);
	    pool.wait();

	    if( WantVerbose ) {
		ParseTree.message( "linking objects..." );
	    }
	    linkObjectFiles();

	    ParseTree.message( "done" );
        }

	void linkObjectFiles() {
	    StringBuffer b = new StringBuffer();

	    var p = new Util.Process();
	    var v = new Vector<String>();
	    // IO.Std.err.println( "going to link. output: '" + executable_name + "'" );
	    v.add( "gcc" );
	    v.add( Machine.GCC_SWITCH );
	    v.add( "-L/usr/lang/lib/" );
	    if( !WantLineNumbers ) {
	    	v.add( "-s" );
	    }

	    v.add( "-o" );
	    v.add( executable_name );
	    v.add( LIBRARY_DIR + "lrt-" + Machine.NAME + ".o" );
	    foreach( String s; to_link_set.elements() ) {
		v.add( s );
	    }
	    // v.add( "-nostartfiles" );

	    v.add( "-lgc" );
	    v.add( "-ldl" );

	    foreach( String t; libraries.elements() ) {
		if( t.endsWith(".o") ) {
		    v.add( t ); 
		} else {
		    v.add( "-l" + t );
		}
	    }
	    String[] args = new String[v.Length];
	    for( int i = 0; i < v.Length; i = i + 1 ) {
		b.append( v[i] );
		b.append( ' ' );
		args[i] = cast<String>(v[i]);
	    }

	    // IO.Std.err.println( "linking: " + b );
		
	    int result = p.run( "gcc", args );
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
		IO.Reader in = IO.File.openRead( open_file_name );
		if( in != null ) {
		    // IO.Std.err.println( "success: " + in );
		    file_name = open_file_name;
		}
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

            foreach( String s; search.elements() ) {
		if( !s.endsWith('/') ) {
		    s = s + '/';
		}

		if( name.endsWith(".l") ) {
		    in = tryOpen( s, name, "" );
		    if( in != null ) {
			file_name = name;
			break;
		    }
		} else {
		    in = tryOpen( s, name, ".l" );
		    if( in != null ) {
			file_name = name;
			break;
		    }
		}
            }

            if( in == null ) {
                throw new Exception( "could not open input file " + name + " in any of " + search + " lcache: " + this.CacheDir );
            }

            parseFile( file_name, in );
            return true;
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

        bool needCompile( String source_name, String class_name, int hash ) {
            bool result = need_compile.needCompile( source_name, class_name, hash );

	    // IO.Std.err.println( "need compile " + source_name + ": " + class_name + ": " + result );
	    return result;
        }

        void parseFile( String file_name, IO.Reader f ) {
	    if( WantVeryVerbose ) {
		ParseTree.message( "parse file: " + file_name );
	    }
            Parser p = new Parser(file_name, f, this);
        }


	/*
        void addAssemblerFile( String s ) {
            to_assemble_list.add( s );
        }
	*/

        void catAssemblerFile( String f ) {
            throw new Exception( "implement me!" );
        }

	void markAddressTaken( int offset ) {
	    if( State == STATE_INSIDE_CLASS ) { 
		CurrentClass.markAddressTaken( offset );
	    } else if( State == STATE_INSIDE_METHOD ) {
		CurrentMethod.markAddressTaken( offset );
	    } else {
		throw new Exception( "mark address taken " + offset + " from unexpected state " + State );
	    }
	}

	get Gen.MBitSet AddressesTaken {
	    Gen.MBitSet result;
	    if( State == STATE_INSIDE_CLASS ) { 
		result = CurrentClass.AddressesTaken;
	    } else if( State == STATE_INSIDE_METHOD ) {
		result = CurrentMethod.AddressesTaken;
	    } else {
		throw new Exception( "get addresses taken from unexpected state " + State );
	    }
	    /*
	    if( result != null ) {
		IO.Std.err.println( "compilestate, address taken: " + result );
	    }
	    */
	    return result;
	}

        void beginPackage( String source_file_name, SymbolList n ) {
	    // IO.Std.err.println( "begin package: " + source_file_name + ", " + this );
            pushState( STATE_OUTSIDE_CLASS, source_file_name );
            
            output = null;
            current_line = -1;
            seen_line_number = -1;
            last_line_number = -1;
        }

        void endPackage() {
            popState();
            
            output = null;
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
                // fprintf( stderr, "extend name space %s in scope %d\n", symbol.getQualifiedName(), sp );
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

            // fprintf( stderr, "enter class %p %s scope %p\n", c, c.getQualifiedName(), c.getScope() );
            symbol_table.enterScope( c.Scope );
            
            pushState( STATE_INSIDE_CLASS, c, null );
        }


        void exitClass( Container c ) {
            if( c != CurrentClass ) {
                throw new Exception( "oops: mis-nested classes\n" );
            }
            
            // fprintf( stderr, "exit class %s scope %p/%p\n", c.getQualifiedName(), c.getScope(), symbol_table.getCurrentScope() );
            
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

        void openOutput( String name, bool append ) {
            StringBuffer buffer = new StringBuffer();

            int hash = Util.Hash.hash( name );
            label_prefix = "" + hash;
            // fprintf( stderr, "label prefix is now '%s'\n", label_prefix );
            
            // fprintf( stderr, "opening output: '%s'\n", name );
            
            buffer.append( this.CacheDir );
            buffer.append( name );
            if( !one_file ) {
                buffer.append( ".s" );
            } else {
                buffer.append( ".e" );
            }
            closeOutput();

            if( append ) {
		output = IO.File.openAppend( buffer );
            } else {
		output = IO.File.openCreate( buffer );
            }
           
            if( !append ) {
                Machine.emitFile( output, CurrentSourceFileName );
                Machine.emitTextSegment( output );
            }
        }

        void removeOutput( String name ) {
	    // FIXME: what are we trying to do here?
            if( one_file ) {
                StringBuffer buffer = new StringBuffer();
                
                buffer.append( this.CacheDir );
                buffer.append( name );
                if( !one_file ) {
                    buffer.append( ".s" );
                } else {
                    buffer.append( ".e" );
                }
                native.unlink(buffer.toCString() );
            }
        }

	String getObjectFileName( String name, String extension ) {
            StringBuffer file = new StringBuffer();
	    
	    file.append( CacheDir );
	    file.append( name );
	    file.append( extension );

	    return file;
	}

        
        void assembleFile( String name ) {
            String assembler_file = getObjectFileName( name, ".s" );
	    String object_file = getObjectFileName( name, ".o" );
            
	    if( WantVeryVerbose ) {
		ParseTree.message( "assemble file: " + name );
	    }
            
            closeOutput();
            
	    Util.Process assembler = new Util.Process();
	    int result = assembler.run( "/usr/bin/as", String { "/usr/bin/as", Machine.AS_SWITCH, cast<String>(assembler_file), "-o", object_file }, null);
	    if( result != 0 ) {
		throw new Exception( "assembly of file " + assembler_file + " failed with exit status " + result );
	    }
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
                output.close();
                output = null;
            }
        }

        get IO.Writer Output {
            if( output != null ) {
                return output;
            } else {
                return IO.Std.err;
            }
        }

	
        Symbol declareSymbol( ParseTree from, Container owner, String name, int kind, int access, int defined, Type type ) {
            Symbol existing = symbol_table.findInCurrentScope( name, Symbol.FIND_ANY );
            
            if( existing != null && kind & Symbol.FLAG_METHOD == 0 ) {
                from.error( "oops: duplicate symbol declaration: " + name );
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

                    int address = current_method.alloc( k );
                    symbol.setAddress( address );
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
		    from.error( "redefining " + name + " as an accessor (creating accessor for method " + because + ")" );
		}
	    } else {
		s = findSymbol( name, Symbol.FIND_NON_ACCESSOR );

		symbol = declareSymbol( from, CurrentClass, name, Symbol.FLAG_ACCESSOR, 0, 1, null );
		symbol.Address = 0;

		if( s != null && WantWarnHide ) {
                    from.warn( "property " + symbol.HumanName + " hides symbol in outer scope " + s.HumanName );
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
	    Vector<Type> arguments,
	    String decorate )
	{
            flags = flags | Symbol.FLAG_METHOD | Symbol.FLAG_CLASS;

            if( this.State != STATE_INSIDE_CLASS ) {
                from.error( "cannot declare method " + name + " outside of a class" );
            }
            
            Container current_class = CurrentClass;
            if( current_class.Scope.findDecorated( decorate ) != null ) {
                from.error( "duplicate method definition " + decorate );
            }

            Container override = current_class.findMethod( name, arguments, false );
            if( override != null ) {
                if( !override.matches( arguments, true ) ) {
                    String this_args = ParseTree.dumpArguments( arguments );
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
            symbol.setArgTypes( arguments );
	    CurrentClass.setLastMethodIndex();
            
            return symbol;
        }

        String getNameSpaceQualifiers( String class_name ) {
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


        String getNameSpaceDecorated( String class_name ) {
            StringBuffer b = new StringBuffer();
            
            int qualifier_count = 0;
            int i;
            for( i = 0; i <= sp; i = i + 1 ) {
                if( state[i].State == STATE_INSIDE_NAMESPACE ) {
                    qualifier_count = qualifier_count + 1;
                }
            }
            
            if( qualifier_count == 0 ) {
                b.append( class_name.Length );
                b.append( class_name );
                return b;
            }
            
            qualifier_count = qualifier_count + 1;
            
            if( qualifier_count < 9 ) {
                b.append( 'Q' );
                b.append( qualifier_count );
            } else {
                b.append( "Q_" );
                b.append( qualifier_count );
                b.append( '_' );
            }
            
            for( i = 0; i <= sp; i = i + 1 ) {
                if( state[i].State == STATE_INSIDE_NAMESPACE ) {
                    String s = state[i].CurrentClass.Name;
                    b.append( s.Length );
                    b.append( s );
                }
            }
            
            b.append( class_name.Length );
            b.append( class_name );
            
            return b;
        }
        
        Container declareClass( ParseTree from, Container parent, Container owner, String name, int access, bool allow_redefine ) {
            Container class_symbol = null;
            Symbol symbol = symbol_table.findInCurrentScope( name, Symbol.FIND_ANY );
            
            if( symbol != null ) {
		if( !(allow_redefine || symbol.NeedsBody) ) {
		    // FIXME: allow re-defining class as class because of predefined classes - need better solution
		    if( symbol.Kind != Symbol.CLASS ) {
			from.error( "redefining " + symbol.QualifiedName + " as class" );
			return null;
		    } else {
			from.error( "redefining class " + symbol.QualifiedName );
		    }
		    /*
		    } else if(  symbol.Access != access ) {
			from.error( "access for class " + symbol.QualifiedName + " has changed to " + access );
			return null;
			} */
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
                // fprintf( stderr, "declare %s in %s at scope %d\n", name, owner ? owner.getQualifiedName() : "global scope", sp );
            
            class_symbol.setQualifiedName( getNameSpaceQualifiers(name) );
            class_symbol.setDecoratedName( getNameSpaceDecorated(name) );
            class_symbol.setDefined( 1 );
            
            if( class_symbol.Name.equals("Main") ) {
                if( main_class_name == null ) {
                    // fprintf( stderr, "main class is %s\n", class_symbol.getQualifiedName() );
                    main_class_name = class_symbol.QualifiedName;
                    main_class_decorated = class_symbol.DecoratedName;
                } else {
                    from.error( "duplicate Main class: " + class_symbol.QualifiedName + " versus " + main_class_name );
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
                from.error( enum_symbol.QualifiedName + " already has a body" );
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

        void declareEnumMember( ParseTree from, String name, int value ) {
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

            symbol.setAddress( value );
        }

        Container declareEnum( ParseTree from, String name, int access ) {
            Container enum_symbol = null;
            Symbol symbol = symbol_table.findInCurrentScope( name, Symbol.FIND_ANY );
            
            Container owner = CurrentClass;
            if( owner == null ) {
                owner = CurrentNameSpace;
            }
            
            if( symbol != null ) {
                from.error( "redefining " + symbol.QualifiedName + " as enum" );
                return null;
            } else {
                symbol = findSymbol(name, Symbol.FIND_ANY);
                
                enum_symbol = new Container( null, owner, name, Symbol.ENUM, access, null );
                
                enum_symbol.setType( new  Type( Type.ENUM, enum_symbol ) );
                enum_symbol.setDefined( 1 );
                
                symbol_table.add( enum_symbol );
                
                enum_symbol.setQualifiedName( getNameSpaceQualifiers(name) );
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
                
                type_symbol.setQualifiedName( getNameSpaceQualifiers(name) );
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
            
            return_label = Gen.TempFactory.nextLabel();
	    // IO.Std.err.println( "begin compile: " + decorated_name );
	    // IO.Std.err.println( "return label initially: " + return_label );
            
            symbol_table.enterScope( method_class.Scope );
            
            pushState( STATE_INSIDE_METHOD, CurrentClass, method_class );

	    seen_exception_handler = false;
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

	    /*
            ILabel l = Gen.TempFactory.nextLabel();
            Machine.emitLabel( Output, l.getInt() );
	    */
        }
    
        void beginParseMethodArgs( ParseTree from, Container method ) {
            if( this.State != STATE_INSIDE_CLASS ) {
                throw new Exception( "oops: trying to beginParseMethodArgs from compile state " + this.State );
            }
            symbol_table.enterScope();
            
            pushState( STATE_INSIDE_METHOD, CurrentClass, method );
            
            // FIXME: this is not a good place for these constants
            if( method.IsStatic ) {
                method.clearStackOffset( Machine.FIRST_ARGUMENT_OFFSET_STATIC, Machine.FIRST_LOCAL_OFFSET );
            } else {
                method.clearStackOffset( Machine.FIRST_ARGUMENT_OFFSET, Machine.FIRST_LOCAL_OFFSET );
            }
	    beginParseRegParams();
        }

        void endParseMethodArgs( Container method ) {
            if( this.State != STATE_INSIDE_METHOD ) {
                throw new Exception( "oops: trying to endParseMethodArgs from compile state " + this.State );
            }
            
            alloc_direction = 1;
	    in_parameters = false;
            
            method.SymbolList = symbol_table.CurrentScope;
            // method.clearStackOffset( Machine.FIRST_LOCAL_OFFSET );
            symbol_table.exitScope();
            
            popState();
        }
    
        void beginParseMethodBody( Container method ) {
            alloc_direction = -1;
            // getCurrentMethod().clearStackOffset( Machine.FIRST_LOCAL_OFFSET );
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
	    // IO.Std.err.println( "searching for instance of template " + c + " with arguments: " + arguments );

	    if( c.Template != null ) {
		IO.Std.err.println( "is already an instance??: " + c + ", " + c.Template );
		return new Type( Type.CLASS, c );
	    }

	    foreach( Container d; generic_instances.elements() ) {
		// IO.Std.err.println( "check " + d + " from template " + d.Template + " with arguments: " + d.TypeArgs );
		if( d.Template == c && d.checkTypeArgs( arguments ) ) {
		    // d.markReferenced();
		    // IO.Std.err.println( "returning this instance" );
		    return new Type( Type.CLASS, d );
		}
	    }

	    //	    if( !find_only ) {
	    Container e = makeConcrete( c, arguments );
	    // e.markReferenced();
	    // IO.Std.err.println( "created new instance: " + e + " from template " + e.Template );
	    generic_instances.add( e );
	    return new Type( Type.CLASS, e );
	    //	    } else {
	    //	throw new Exception( "cannot make new generic class " + c + " here" );
	    //}
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
            return cast<Container>(master_class_list.findQualified( qualified_name ));
        }

        Container findMethod( String name, Vector<Type> arguments, bool exact ) {
            // only classes can contain methods so search order is simply:
            //  current class and its superclasses

            // finds first match only - do not use unless exact

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
		quality.score = 0;
                return current_class.findBestMethod( name, arguments, quality, true );
            }
            
            return null;
        }
    
        Symbol findDecoratedSymbol( String name ) {
            Container current_class = CurrentClass;
            if( current_class != null ) {
                return current_class.findDecoratedSymbol( name );
            }
            
            return null;
        }
        

        Symbol findInCurrentScope( String name, int find_what ) {
            return symbol_table.findInCurrentScope( name, find_what );
        }


        get int State {
            return state[sp].State;
        }

	get int MaxInlineCount {
	    return max_inline_count;
	}

	set int MaxInlineCount = m {
	    max_inline_count = m;
	}

	static get int WantJobs {
	    return want_jobs;
	}

	static set int WantJobs = j {
	    this.want_jobs = j;
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
	    return WarnFlag[0];
	}

	set bool WantWarnUnsafe = w {
	    WarnFlag[0] = w;
	}

	get bool WantWarnHide {
	    return WarnFlag[1];
	}

	set bool WantWarnHide = w {
	    WarnFlag[1] = w;
	}

	get bool WantWarnResolve {
	    return WarnFlag[2];
	}

	set bool WantWarnResolve = w {
	    WarnFlag[2] = w;
	}

	get bool WantMarkUnsafe {
	    // !trusted || want mark unsafe:
	    return !WarnFlag[4] || WarnFlag[3];
	}

	set bool WantMarkUnsafe = w {
	    WarnFlag[3] = w;
	}

	get bool Trusted {
	    return WarnFlag[4];
	}

	set bool Trusted = w {
	    WarnFlag[4] = w;
	}

	get bool WantLineNumbers {
	    return WarnFlag[5];
	}

	set bool WantLineNumbers = v {
	    WarnFlag[5] = v;
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

        get ILabel ReturnLabel {
	    // IO.Std.err.println( "return label now: " + return_label );
            return return_label;
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
