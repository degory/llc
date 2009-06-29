// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import args;
import stream;

import compilestate;
import mtree;

namespace Parse { 
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    class Main {
	const int BUILD = 1140;

	CompileState state;

	set String ExecutableName = name {
	    int i;
	    for( i = name.getLength() - 1; i >= 0; i = i - 1 ) {
		if( name.charAt(i) == '.' ) {
		    name = name.substring(0, i);
		    break;
		}
	    }
	    state.ExecutableName = name;
	}

	set String ProjectName = name {
	    IO.Std.err.println( "project name: '" + name + "'" );
	    state.ProjectName = name;
	}

	static Gen.TempFactory temp_factory;

	void initForThreads() {
	    native.GC_set_max_heap_size(512*1024*1024);
	    // native.GC_expand_hp(512*1024*1024);

	    // native.GC_enable_incremental();
	    IO.Std.makeThreadSafe();
	    temp_factory = new Gen.TempFactory( Gen.Machine.FIRST_SOFT_REG, 0 );
	    // IO.Std.err.println( "setting temp factory: " + temp_factory + "..." );
	  
	    Gen.TempFactory.setInstance( temp_factory );
	}

        void init() {
	    // initForThreads();

	    state = new CompileState();
	    bool first_file = true;
	    int i, j;
	    String name;
	    var input_files = new Vector<String>();

	    Gen.Machine.initOpNames();
            
            String[] args = System.Arguments.ProgramArguments;

	    state.WantRegVars = true;
	    state.WantWarnResolve = false;

	    bool set_executable_name = false;
	    bool want_stats = false;

            for( i = 1; i < args.length; i = i + 1 ) {
                name = args[i];
                if( name.Length >= 2 && name[0] == '-' ) { 
                    switch( name[1] ) {
		    case 'h', 'H', '?':
			usage( args[0] );
		        return;

		    case 'j':
			if( name.Length > 2 ) {
			    CompileState.WantJobs = name.substring(2).toInt();
			} else {
			    i = i + 1;
			    CompileState.WantJobs = args[i].toInt();
			}
		    		       
                    case 'l':
                        if( name.getLength() > 2 ) {
                            state.addSearchPath( name.substring(2) );
                        } else {
                            i = i + 1;
                            state.addSearchPath( args[i] );
                        }

		    case 'L':
                        if( name.getLength() > 2 ) {
			    state.addLibrary( name.substring(2) );
                        } else {
                            i = i + 1;
			    state.addLibrary( args[i] );
                        }			

		    case 'D':
			state.WantLineNumbers = true;

		    case 'd':
			state.WantLineNumbers = false;

		    case 'p':
			if( name.Length > 2 ) {
			    setProjectName( name.substring(2) );
			} else {
			    i = i + 1;
			    setProjectName( args[i] );
			}

		    case 'P':
			state.WantPrint = true;

		    case 'o':
			if( name.getLength() > 2 ) {
			    setExecutableName( name.substring(2) );
			} else {
			    i = i + 1;
			    setExecutableName( args[i] );
			}
			set_executable_name = true;

		    case 'v':
			state.WantVerbose = true;

		    case 'V':
			state.WantVeryVerbose = true;

		    case 'S':
			state.WantSafe = true;

		    case 's':
			want_stats = true;

		    case 'O':
			if( name.Length == 2 ) {
			    name = name + '1';
			}

			for( j = 2; j < name.Length; j = j + 1 ) {
			    switch( name[j] ) {
			    case 'C':
				state.WantCoalesce = true;

			    case 'c':
				state.WantCoalesce = false;

			    case 'I':
				state.WantInline = true;

			    case 'i':
				state.WantInline = false;

			    case 'V':
				state.WantRegVars = true;

			    case 'v':
				state.WantRegVars = false;

			    case 'R':
				state.WantReturnJumpElim = true;

			    case 'r':
				state.WantReturnJumpElim = false;

			    case 'B':
				state.WantSplitBounds = true;

			    case 'b':
				state.WantSplitBounds = false;

			    case 'E':
				state.WantCSE = true;

			    case 'e':
				state.WantCSE = false;
				    
			    case '1':
				// state.WantCoalesce = true;
				state.WantInline = true;
				state.WantRegVars = true;
				state.WantReturnJumpElim = true;
				state.WantSplitBounds = true;

			    case '0', 'd':
				state.WantCoalesce = false;
				state.WantInline = false;
				state.WantRegVars = false;
				state.WantReturnJumpElim = false;
				state.WantSplitBounds = false;
				
			    default:
				IO.Std.err.println( "unexpected code generation switch: '" + name[j] );
				return;
			    }
			}

		    case 'i':
			state.MaxInlineCount = name.substring(2).parseInt();

		    case 'c':
			Gen.MFlow.MaxCoalesceCopies = name.substring(2).parseInt();

		    case 'W':
			if( name.Length == 2 ) {
			    name = name + '1';
			}

			for( j = 2; j < name.Length; j = j + 1 ) {
			    switch( name[j] ) {
			    case 'S':
				state.WantWarnUnsafe = true;

			    case 's':
				state.WantWarnUnsafe = false;

			    case 'M':
				state.WantMarkUnsafe = true;

			    case 'm':
				state.WantMarkUnsafe = false;

			    case 'H':
				state.WantWarnHide = true;
			    
			    case 'h':
				state.WantWarnHide = false;

			    case 'R':
				state.WantWarnResolve = true;

			    case 'r':
				state.WantWarnResolve = false;
			    }
			}

		    default:
			IO.Std.err.println( "unexpected switch: '" + name[1] );
			return;
                    }

		    if( state.WantInline && !state.WantRegVars ) {
			IO.Std.err.println( "inline will not work without register variables: enabling them" );
			state.WantRegVars = true;
		    }
                } else {
		    if( first_file ) {
			first_file = false;
			if( !set_executable_name ) {
			    setExecutableName( args[i] );
			}
		    }
		    input_files.add( args[i] );
                }
            }

	    if( input_files.Length == 0 ) {
		usage( args[0] );
		return;
	    }

	    if( state.WantVerbose ) {
		StringBuffer options = new StringBuffer();
		if( state.WantSafe ) {
		    options.append( "safe " );
		}

		if( state.WantInline ) {
		    options.append( "inline " );
		}
		
		if( state.WantRegVars ) { 
		    options.append( "regvars " );
		}
		
		if( state.WantReturnJumpElim ) {
		    options.append( "retjmp " );
		}
		
		if( state.WantCoalesce ) {
		    options.append( "coalesce " );
		}
		
		if( state.WantSplitBounds ) { 
		    options.append( "splitbound " );
		}		

		IO.Std.err.println( "build: " + BUILD );
		IO.Std.err.println( "options: " + options );
		IO.Std.err.println( "output executable: " + state.ExecutableName );
	    }

	    String last_file;
	    try {
		last_file = "lang.l";

		state.initSearchPaths(state.WantSafe);

		state.visitFile( "lang.l" );
		
		foreach( String s; input_files.elements() ) {
		    last_file = s;
		    state.visitFile( s );
		}

		state.compilePending();

		// Gen.ICompileJob.wait();

		Parse.ParseTree.newline();
		if( Gen.MFlow.method_count != 0 && want_stats ) {
		    IO.Std.err.println( "        " + Gen.MFlow.method_count + " methods compiled" );
		    if( Parse.ParseTree.inline_method_count > 0 ) {
			IO.Std.err.println( "        " + Parse.ParseTree.inline_method_count + " methods prepared for inline" );
			IO.Std.err.println( "        " + Parse.ParseTree.inline_call_count + " methods calls inlined" );
		    }
		    IO.Std.err.println( "        " + Gen.MFlow.instruction_count + " machine instructions output" );
		    IO.Std.err.println( "        " + fixedPoint( Gen.MFlow.instruction_count * 100 / Gen.MFlow.method_count ) + " instructions per method (average)");
		    
		    if( Gen.MFlow.coalesce_count > 0 ) {
			IO.Std.err.println( "        " + Gen.MFlow.coalesce_count + " copy coalesce passes" );
			IO.Std.err.println( "        " + fixedPoint( Gen.MFlow.coalesce_count * 100 / Gen.MFlow.method_count ) + " copy coalesce passes per method (average)");
		    }
		    IO.Std.err.println( "        " + Gen.MFlow.color_count + " graph color passes" );
		    IO.Std.err.println( "        " + fixedPoint( Gen.MFlow.color_count * 100 / Gen.MFlow.method_count ) + " color passes per method (average)");	    
		    IO.Std.err.println( "        " + Gen.MFlow.temporary_count + " temporary registers used" );
		    IO.Std.err.println( "        " + fixedPoint( Gen.MFlow.temporary_count * 100 / Gen.MFlow.method_count ) + " temporary registers per method (average)");	    
		    
		    IO.Std.err.println( "        " + Gen.MInst.copy_number + " redundant copies eliminated" );
		    IO.Std.err.println( "        " + Gen.MInst.split_number + " temporary references split" );
		    IO.Std.err.println( "        " + Gen.MInst.indirect_number + " total memory references" );
		    IO.Std.err.println( "        " + Gen.MInst.spill_number + " total spills generated" );
		    IO.Std.err.println( "        " + Gen.MInst.mem_number + " spills converted to direct memory references" );
		}
		if( ParseTree.didErrorsOccur() ) {
		    native.exit(1);
		} else {
		    native.exit(0);
		}
	    } catch( ParseException pe ) {
		ParseTree.newline();
		IO.Std.err.println( "*** unrecoverable parse error ***" );
		native.exit(1);
	    } catch( Exception se ) {
		ParseTree.newline();
		IO.Std.err.println( "*** fatal error ***" );
		IO.Std.err.println( se );
		native.exit(1);
	    }
        }

	void usage( String name ) {
	    IO.Std.err.println( "L-compiler build " + BUILD + " (C) 2009 <degs@giantblob.com>" );
	    IO.Std.err.println( "    host: " + System.Environment.NAME );
	    IO.Std.err.println( "    target: " + Gen.Machine.NAME );
	    IO.Std.err.println( "    cache: " + CompileState.Instance.CacheDir );
	    IO.Std.err.println();
	    IO.Std.err.println( "usage: " + name + " [options] source-file..." );
	    IO.Std.err.println( "    -o <file name>   write the output executable to <file name>" );
	    IO.Std.err.println( "    -l <directory>   add <directory> to path to search for source files" );
	    IO.Std.err.println( "    -p <name>        set the project name - object files will be stored in /tmp/lcache-<name>" );
	    IO.Std.err.println( "    -j <jobs>        set number of parallel compile processes" );
	    IO.Std.err.println( "    -v               verbose output" );
	    IO.Std.err.println( "    -V               very verbose output" );
            IO.Std.err.println( "    -S               create sandboxed executable" );
	    IO.Std.err.println( "    -s               output code generation statistics" );
	    IO.Std.err.println( "    -d               do not generate debugging information" );
	    IO.Std.err.println( "    -O               shorthand for -OVIBR" );
	    IO.Std.err.println( "    -O<code options> code generation options" );
	    IO.Std.err.println( "    -W<warn options> warning message options" );
	    IO.Std.err.println();
	    IO.Std.err.println( "code generation options:" );
	    IO.Std.err.println( "    V                enable register variables (default)" );
	    IO.Std.err.println( "    v                disable register variables" );
	    IO.Std.err.println( "    I                inline methods where possible" );
	    IO.Std.err.println( "    i                do not inline methods (default)" );
	    IO.Std.err.println( "    C                coalesce redundant register moves" );
	    IO.Std.err.println( "    c                do not coalesce redundant register moves (default)" );
	    IO.Std.err.println( "    B                faster bounds check sequence" );
            IO.Std.err.println( "    b                regular bounds check sequence (default)" );
	    IO.Std.err.println( "    R                eliminate redundant return jumps" );
	    IO.Std.err.println( "    r                always jump to epilog on return (default)" );
	    IO.Std.err.println();
	    IO.Std.err.println( "warning message options:" );
	    IO.Std.err.println( "    S                warn for every unsafe construct encountered" );
	    IO.Std.err.println( "    s                do not warn for every unsafe construct" );
	    IO.Std.err.println( "    M                warn for unsafe constructs per class" );
	    IO.Std.err.println( "    m                do not warn for unsafe constructs per class" );
	    IO.Std.err.println( "    H                warn when definitions may hide other symbols" );
	    IO.Std.err.println( "    h                do not warn when definitions may hide other symbols" );
	    IO.Std.err.println( "    R                warn when method resolution is poor match" );
	    IO.Std.err.println( "    r                do not warn method resolution is poor match" );
	}

	static String fixedPoint( int n ) {
	    StringBuffer result = new StringBuffer();
	    result.append( n / 100 );
	    result.append( '.' );
	    
	    n = n % 100;
	    if( n < 10 ) {
		result.append( '0' );
	    }
	    result.append( n );

	    return result;
	}
    }
}
