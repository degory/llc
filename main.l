#C

// Copyright 2004-2011 <degs@giantblob.com> all rights reserved

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
	const int BUILD = 1263;

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
	    state.Want64BitTarget = System.Environment.WORD_BITS == 64;
	    state.WantSharedStandardLibrary = false;
	    state.WantRegVars = false;
	    state.WantWarnResolve = false;
	    state.WantWarnSelectorCollision = false;
	    state.WantWarnInit = true;
	    state.WantPack = false;
	    state.WantCastCheck = true;
	    state.WantBoundsCheck = true;
	    state.WantNullCheck = true;
	    state.WantLinkLibraries = true;
	    state.WantNativeExecutable = true;
	    state.WantNativeObjectFiles = false;
	    state.WantColorInterfaceSelectors = false;
	    state.WantSelectorHashParameter = true;

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

		    case 'R':
                        if( name.getLength() > 2 ) {
			    state.RuntimeDir = name.substring(2);
                        } else {
                            i = i + 1;
			    state.RuntimeDir = args[i];
                        }	

		    case 'X':
			state.WantPrint = true;

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

		    case 'N':
			state.WantSharedStandardLibrary = true;

		    case 'n':
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

		    case 'F':
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

			    case 'E':
				state.WantExport = true;

			    case 'e':
				state.WantExport = false;

			    case 'L':
				state.WantNativeLibraryFiles = true;

			    case 'l':
				state.WantNativeLibraryFiles = false;

			    case 'C':
				state.WantColorInterfaceSelectors = true;

			    case 'c':
				state.WantColorInterfaceSelectors = false;

			    case 'S':
				state.WantSelectorHashParameter = true;

			    case 's':
				state.WantSelectorHashParameter = false;

			    case 'T':
				state.WantForceInterfaceThunk = true;

			    case 't':
				state.WantForceInterfaceThunk = false;

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

			    case 'I':
				state.WantWarnInit = true;

			    case 'i':
				state.WantWarnInit = false;

			    case 'C':
				state.WantWarnSelectorCollision = true;

			    case 'c':
				state.WantWarnSelectorCollision = false;

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

	    if( !state.WantNativeExecutable ) {
		state.WantNativeLibraryFiles = false;
	    }

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
		last_file = CompileState.RUNTIME_NAME + ".l";

		state.initSearchPaths(state.WantSafe);

		state.visitFile( CompileState.RUNTIME_NAME + ".l" );

		bool visit_standard_library = state.WantSharedStandardLibrary;
		
		foreach( String s; input_files.elements() ) {
		    last_file = s;
		    state.visitFile( s );

		    if( s =~ CompileState.RUNTIME_NAME + ".lh" ) {
		        IO.Std.err.println( "linking shared standard library (A)" );
			visit_standard_library = false;	
		    }
		}

		if( visit_standard_library ) {
		    IO.Std.err.println( "linking shared standard library (B)" );
		    state.visitFile( CompileState.RUNTIME_NAME + ".lh" );
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
	    } catch( AbortCompilingThisProjectException ae ) {
		ParseTree.newline();
		IO.Std.err.println( "*** unrecoverable compile error ***" );
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
	    IO.Std.out.println( "L-compiler build " + BUILD + " (C) 2004-2011 <degs@giantblob.com>" );
	    IO.Std.out.println( "    host: " + System.Environment.NAME );
	    IO.Std.out.println( "    target: " + Gen.Machine.NAME );
	    IO.Std.out.println( "    cache: " + CompileState.Instance.CacheDir );
	    IO.Std.out.println();
	    IO.Std.out.println( "usage: " + name + " [options] source-file..." );
	    IO.Std.out.println( "    -h, -H, -?         display this message" );
	    IO.Std.out.println( "    -o <file name>     write the output executable to <file name>" );
	    IO.Std.out.println( "    -s <directory>     add <directory> to path to search for source files" );
	    IO.Std.out.println( "    -l <library>       link executable against <library>" );
	    IO.Std.out.println( "    -j <N>             compile intermediate code using N threads" );
	    IO.Std.out.println( "    -f                 force link output" );
	    IO.Std.out.println( "    -R <directory>     use L runtime library in <directory>" );
	    IO.Std.out.println( "    -X                 pretty print" );
	    IO.Std.out.println( "    -D                 output import dependancies in make format" );
            IO.Std.out.println( "    -p <name>          set project name" );
	    IO.Std.out.println( "    -v -V              verbose/very verbose output" );
	    IO.Std.out.println( "    -T                 disallow unsafe code" );
	    IO.Std.out.println( "    -S                 single file assembly output" );
	    IO.Std.out.println( "    -N -n              do/do not link against shared L runtime library" );
	    IO.Std.out.println( "    -U -u              do/do not link against libraries" );
	    IO.Std.out.println( "    -m64 -m32          select 64/32 bit output" );
	    IO.Std.out.println( "    -d                 do not generate debugging information" );
	    IO.Std.out.println( "    -F<output options> code generation options" );
	    IO.Std.out.println( "    -W<warn options>   warning message options" );
	    IO.Std.out.println( "    -C<check options>  run-time check options" );
	    IO.Std.out.println();
	    IO.Std.out.println( "output options:" );
	    IO.Std.out.println( "    -FN -Fn            generate native/bitcode executable" );
	    IO.Std.out.println( "    -FB -Fb            generate native/bitcode object files" );
	    IO.Std.out.println( "    -FP -Fp            generate position independant/absolute code" );
	    IO.Std.out.println( "    -FC -Fc            use graph coloring/hashing to allocate interface method vtable slots" );
	    IO.Std.out.println( "    -FE -Fe            export/do not export all symbols from exectuable" );
	    // IO.Std.out.println( "    -FL -Fl            probably not functional" );
	    IO.Std.out.println();
	    IO.Std.out.println( "check generation options:" );
	    IO.Std.out.println( "    -CA -Ca          check/do not check array subscripts are within bounds" );
	    IO.Std.out.println( "    -CN -Cn          check/do not check dereferences are not null" );
	    IO.Std.out.println( "    -CC -Cc          check/do not type check object down casts" );
	    IO.Std.out.println();
	    IO.Std.out.println( "warning message options:" );
	    IO.Std.out.println( "    -WH -Wh          warn/do not warn when definitions may hide other symbols" );
	    IO.Std.out.println( "    -WM -Wm          warn/do not warn for unsafe constructs per class" );
	    IO.Std.out.println( "    -WR -Wr          warn/do not warn when method resolution is poor match" );
	    IO.Std.out.println( "    -WS -Ws          warn/do not warn for every unsafe construct encountered" );
	    IO.Std.out.println( "    -WI -Wi          warn/do not warn if constructor does not call this or superclass constructor" );
	    IO.Std.out.flush();
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
