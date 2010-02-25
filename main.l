// copyright (C) 2004-2009 degs <junk@giantblob.com> all rights reserved

import args;
import stream;

import compiler;
import compilestate;
// import mtree;

import gc;

import llvm;

namespace Parse { 
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    class Main {
	void init() {
	    // native.GC_init();
	    native.GC_disable();

	    var args = System.Arguments.ProgramArguments;

	    CompileState.resetStatic();

	    var c = new Compiler();

	    var result = c.run2(args);

	    IO.Std.err.flush();
	    System.Exit.exit( result );
	}
    }

    class Compiler extends System.Compiler {
	const int BUILD = 1226;

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
	    state.ProjectName = name;
	}

	void init() {

	}

	int run( String[] args ) {
	    var result = run2( args );
	    CompileState.resetStatic();
	}

        int run2( String[] args ) {
	    state = new CompileState();
	    bool first_file = true;
	    int i, j;

	    int max_heap = 0;

	    String name, t;
	    var input_files = new Vector<String>();

	    Gen.Machine.initOpNames();
            

	    state.OptimizeLevel = 1;
	    state.Want64BitTarget = true;
	    state.WantSharedStandardLibrary = true;
	    state.WantRegVars = false;
	    state.WantWarnResolve = false;
	    state.WantPack = true;
	    state.WantCastCheck = true;
	    state.WantBoundsCheck = true;
	    state.WantNullCheck = true;
	    state.WantLinkLibraries = true;
	    state.WantNativeExecutable = false;
	    state.WantNativeObjectFiles = false;

	    bool set_executable_name = false;
	    bool want_stats = false;
	    // bool want_standard_library = true;

            for( i = 1; i < args.length; i = i + 1 ) {
                name = args[i];
                if( name.Length >= 2 && name[0] == '-' ) { 
                    switch( name[1] ) {
		    case 'h', 'H', '?':
			usage( args[0] );
		        return 1;

		    case 'f':
			state.WantForceLink = true;

		    case 'j':
			if( name.Length > 2 ) {
			    CompileState.WantJobs = name.substring(2).toInt();
			} else {
			    i = i + 1;
			    CompileState.WantJobs = args[i].toInt();
			}		    		      

		    case 'l':
                        if( name.getLength() > 2 ) {
			    state.addLibrary( name.substring(2) );
                        } else {
                            i = i + 1;
			    state.addLibrary( args[i] );
                        }			

		    case 'D':
			state.WantPrintDeps = true;

		    case 'p':
			if( name.Length > 2 ) {
			    setProjectName( name.substring(2) );
			} else {
			    i = i + 1;
			    setProjectName( args[i] );
			}

		    case 'o':
			if( name.getLength() > 2 ) {
			    ExecutableName = name.substring(2);
			} else {
			    i = i + 1;
			    ExecutableName = args[i];
			}
			set_executable_name = true;

		    case 'v':
			state.WantVerbose = true;

		    case 'V':
			state.WantVeryVerbose = true;

		    case 's':
                        if( name.getLength() > 2 ) {
                            state.addSearchPath( name.substring(2) );
                        } else {
			    i = i + 1;
                            state.addSearchPath( args[i] );
                        }


		    case 'T':
			state.WantSafe = true;

		    case 'S':
			state.WantOneFile = true;

		    case 'U':
			state.WantLinkLibraries = true;

		    case 'u':
			state.WantLinkLibraries = false;

		    case 'W':
			state.WantSharedStandardLibrary = true;

		    case 'w':
			state.WantSharedStandardLibrary = false;

		    case 'm':
			j = 2;
			if( name.Length == 2 ) {
			    i = i + 1;
			    j = 0;
			    name = args[i];
			} else {
			    name = name.substring(2);
			}
			if( name =~ "64" ) {
			    state.Want64BitTarget = true;
			} else if( name =~ "32" ) {
			    state.Want64BitTarget = false;
			} else {
			    IO.Std.err.println( "unexpected model switch '" + name + "'" );
			    return 1;
			}			

		    case 'C':
			j = 2;
			if( name.Length == 2 ) {
			    i = i + 1;
			    j = 0;
			    name = args[i];
			}

			// IO.Std.err.println( "OOOO: option is: '" + name + "', j is: " + j + ", length is: " + name.Length  );

			for( ; j < name.Length; j = j + 1 ) {
			    // IO.Std.err.println( "OOOO: switch is: '" + name[j] + "'" );
			    switch( name[j] ) {
			    case 'N':
				state.WantNativeExecutable = true;
				
			    case 'n':
				state.WantNativeExecutable = false;
								
			    case 'B':
				state.WantNativeObjectFiles = true;
				
			    case 'b':
				state.WantNativeObjectFiles = false;

			    case 'P':
				state.WantPIC = true;

			    case 'p':
				state.WantPIC = false;

			    default:
				IO.Std.err.println( "unexpected output format option '" + name[j] + "'" );
				return 1;
			    }
			}

			// IO.Std.err.println( "OOOO: after '" + name + "', want native executable: " + state.WantNativeExecutable + ", want native object files: " + state.WantNativeObjectFiles + ", want PIC: " + state.WantPIC );

		    case 'O':
			j = 2;
			if( name.Length == 2 ) {
			    i = i + 1;
			    j = 0;
			    name = args[i];
			}

			for( ; j < name.Length; j = j + 1 ) {
			    switch( name[j] ) {
			    case '0', 'd':
				state.OptimizeLevel = 0;

			    case '1':
				state.OptimizeLevel = 1;

			    case '2':
				state.OptimizeLevel = 2;

			    case '3':
				state.OptimizeLevel = 3;
				
			    default:
				IO.Std.err.println( "unexpected code generation switch: '" + name[j] + "'" );
				return 1;
			    }
			}

		    case 'C':
			j = 2;
			if( name.Length == 2 ) {
			    i = i + 1;
			    j = 0;
			    name = args[i];
			}		      

			for( ; j < name.Length; j = j + 1 ) {
			    switch( name[j] ) {
			    case 'A':
				state.WantBoundsCheck = true;

			    case 'a':
				state.WantBoundsCheck = false;

			    case 'N':
				state.WantNullCheck = true;

			    case 'n':
				state.WantNullCheck = false;

			    case 'C':
				state.WantCastCheck = true;

			    case 'c':
				state.WantCastCheck = false;

			    default:
				IO.Std.err.println( "unexpected runtime check switch: '" + name[j] + "'" );
				return 1;
			    }
			}


			/*
		    case 'c':
			Gen.MFlow.MaxCoalesceCopies = name.substring(2).parseInt();
			*/

		    case 'W':
			j = 2;
			if( name.Length == 2 ) {
			    i = i + 1;
			    j = 0;
			    name = args[i];
			}

			for( ; j < name.Length; j = j + 1 ) {
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

			    default:
				IO.Std.err.println( "unexpected warning option: '" + name[1] + "'" );
				return 1;
			    }
			}

		    default:
			IO.Std.err.println( "unexpected option: '" + name[1] + "'" );
			return 1;
                    }

		    if( state.WantInline && !state.WantRegVars ) {
			IO.Std.err.println( "inline will not work without register variables: enabling them" );
			state.WantRegVars = true;
		    }
                } else {
		    if( first_file ) {
			first_file = false;
			if( !set_executable_name ) {
			    ExecutableName = args[i];
			}
		    }
		    input_files.add( args[i] );
                }
            }

	    /*
	    if( state.WantNativeObjectFiles ) {
		IO.Std.err.println( "OOOO: want native object files" );
	    } else {
		IO.Std.err.println( "OOOO: want bitcode object files" );
	    }
	    */

	    if( max_heap > 0 ) {
		System.GC.MaxHeapSize = max_heap * 1024 * 1024;
	    }

	    if( input_files.Length == 0 ) {
		usage( args[0] );
		return -1;
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

		bool visit_standard_library = state.WantSharedStandardLibrary;
		
		foreach( String s; input_files.elements() ) {
		    last_file = s;
		    state.visitFile( s );

		    if( s =~ "lang.lh" ) {
			visit_standard_library = false;			
		    }
		}

		if( visit_standard_library ) {
		    state.visitFile( "lang.lh" );
		}

		state.compilePending();

		// Gen.ICompileJob.wait();

		Parse.ParseTree.newline();

		/*
		if( Gen.MFlow.method_count != 0 && state.WantStatistics ) {
		    IO.Std.err.println( "        " + Parse.Expression.type_lookups + " type lookups" );
		    IO.Std.err.println( "        " + Parse.Expression.type_misses + " type misses" );
		    IO.Std.err.println( "        " + Parse.Expression.type_clears + " type clears" );
		    IO.Std.err.println( "        " + Type.box_lookups + " box lookups" );
		    IO.Std.err.println( "        " + Type.box_misses + " box misses" );

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
		*/
		if( ParseTree.didErrorsOccur() ) {
		    return 1;
		} else {
		    return 0;
		}
	    } catch( ParseException pe ) {
		ParseTree.newline();
		IO.Std.err.println( "*** unrecoverable parse error ***" );
		return 1;
	    } catch( Exception se ) {
		ParseTree.newline();
		IO.Std.err.println( "*** fatal error ***" );
		IO.Std.err.println( se );
		IO.Std.err.println( se.Backtrace );
		return 1;
	    }
        }

	void usage( String name ) {
	    IO.Std.err.println( "L-compiler build " + BUILD + " (C) 2004-2010 <degs@giantblob.com>" );
	    IO.Std.err.println( "    host: " + System.Environment.NAME );
	    IO.Std.err.println( "    target: " + Gen.Machine.NAME );
	    IO.Std.err.println( "    cache: " + CompileState.Instance.CacheDir );
	    IO.Std.err.println();
	    IO.Std.err.println( "usage: " + name + " [options] source-file..." );
	    IO.Std.err.println( "    -o <file name>   write the output executable to <file name>" );
	    IO.Std.err.println( "    -l <directory>   add <directory> to path to search for source files" );
	    IO.Std.err.println( "    -L <library>     link executable against <library>" );
	    IO.Std.err.println( "    -p <name>        set the project name - object files will be stored in /tmp/lcache-<name>" );
	    IO.Std.err.println( "    -j <jobs>        set number of parallel compile processes" );
	    IO.Std.err.println( "    -v               verbose output" );
	    IO.Std.err.println( "    -V               very verbose output" );
            IO.Std.err.println( "    -S               create sandboxed executable" );
	    IO.Std.err.println( "    -s               output code generation statistics" );
	    IO.Std.err.println( "    -d               do not generate debugging information" );
	    IO.Std.err.println( "    -M <heap size>   limit compiler heap size to <heap size> megabytes" );
	    IO.Std.err.println( "    -O1              shorthand for -OCVIBRZ" );
	    IO.Std.err.println( "    -O<code options> code generation options" );
	    IO.Std.err.println( "    -W<warn options> warning message options" );
	    IO.Std.err.println();
	    IO.Std.err.println( "code generation options:" );
	    IO.Std.err.println( "    A                check array subscripts are within bounds (default)" );
	    IO.Std.err.println( "    a                do not check array subscripts" );
	    IO.Std.err.println( "    B                faster bounds check sequence" );
            IO.Std.err.println( "    b                regular bounds check sequence (default)" );
	    IO.Std.err.println( "    C                coalesce redundant register moves" );
	    IO.Std.err.println( "    c                do not coalesce redundant register moves (default)" );
	    IO.Std.err.println( "    I                inline methods where possible" );
	    IO.Std.err.println( "    i                do not inline methods (default)" );
	    IO.Std.err.println( "    R                eliminate redundant return jumps" );
	    IO.Std.err.println( "    r                always jump to epilog on return (default)" );
	    IO.Std.err.println( "    S                build executable linked against shared standard library (default)" );
	    IO.Std.err.println( "    s                build statically linked executable" );
	    IO.Std.err.println( "    P                pack instance variables (default)" );
	    IO.Std.err.println( "    p                do not pack instance variables" );
	    IO.Std.err.println( "    Q                generate profiler calls on method entry and exit" );
	    IO.Std.err.println( "    q                do not generate profiler calls (default)" );
	    IO.Std.err.println( "    V                enable register variables" );
	    IO.Std.err.println( "    v                disable register variables (default)" );
	    IO.Std.err.println( "    Z                use stack red zone" );
	    IO.Std.err.println( "    z                do not use stack red zone" );

	    IO.Std.err.println();
	    IO.Std.err.println( "warning message options:" );
	    IO.Std.err.println( "    H                warn when definitions may hide other symbols" );
	    IO.Std.err.println( "    h                do not warn when definitions may hide other symbols" );
	    IO.Std.err.println( "    M                warn for unsafe constructs per class" );
	    IO.Std.err.println( "    m                do not warn for unsafe constructs per class" );
	    IO.Std.err.println( "    R                warn when method resolution is poor match" );
	    IO.Std.err.println( "    r                do not warn method resolution is poor match" );
	    IO.Std.err.println( "    S                warn for every unsafe construct encountered" );
	    IO.Std.err.println( "    s                do not warn for every unsafe construct" );
	    IO.Std.err.flush();
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
