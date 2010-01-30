
namespace Parse {
    use Gen.ITree;
    use Gen.IBlock;
    use Gen.ILabel;
    use Gen.IString;
    use Gen.Machine;
    use Gen.TempFactory;
    use Gen.MBitSet;
    use Gen.IRBlock;
  
    class ThrowStatement extends Statement {
        Expression expression;

        void init( int line_number, Expression expression ) {
            super.init( line_number );
            this.expression = expression;
        }

	void clear( CompileState state ) {
	    expression.clear( state );
	}

	void checkTemplates( CompileState state ) {
	    expression.checkTemplates( state );
	}

	void checkInline( CompileState state ) {
	    expression.checkInline( state );
	    // throw new CannotInlineException();
	}

	void compile( CompileState state, IRBlock into ) {
            Type type = expression.getType( state );

            if( type.TypeKind != Type.CLASS && type != undefined_type ) {
                error( "throw can only throw objects" );
                return;
            }

	    LLVM.Value f = getThrowFunction( state );

	    callOrInvoke(
			 state,
			 into,
			 f,
			 { makeLLVMCast( expression.compileValue(state, into),  LLVM.Calls.LLVMPointerType( LLVM.Calls.LLVMInt8Type(), 0 ), into ) }
			 );
	}

	static LLVM.Value getThrowFunction( CompileState state ) {
            var v = LLVM.Calls.LLVMGetNamedFunction(state.Module, `__throw_exception`);
            if( v == null ) {
                var at = { LLVM.Calls.LLVMPointerType( LLVM.Calls.LLVMInt8Type(), 0 ) };
                var ft = LLVM.Calls.LLVMFunctionType( LLVM.Calls.LLVMVoidType(), at.address, at.length, 0);

                v = LLVM.Calls.LLVMAddFunction(state.Module, `__throw_exception`, ft);
            }

	    return v;
	}

        void compile( CompileState state, IBlock into ) {
            Type type = expression.getType( state );

            if( type.TypeKind != Type.CLASS && type != undefined_type ) {
                error( "throw can only throw objects" );
                return;
            }

            into.add( new 
                      ITree( line_number, Op.THROW, Machine.WORD,
                             expression.compileValue( state, into ) ) );
            return;
        }

	get bool IsLastReturn {
	    // doesn't return at all
	    return true;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "throw " );
	    expression.print( state, p );
	    p.println(";");
	}
    }

    class Catch extends Statement {
        VariableDef match;
        Statement statement;
	// LLVM.BasicBlock label;

        void init( int line_number, VariableDef v, Statement s ) {
            super.init( line_number );
            match = v;
            statement = s;
            // label = null;
        }

	/*
        LLVM.BasicBlock getLabel( IRBlock into) {
            if( label == null ) {
                label = into.Block();
            }
            return label;
        }
	*/


        void declareSymbols( CompileState state ) {
            match.declareSymbols( state );
            statement.declareSymbols( state );
        }

	void checkTemplates( CompileState state ) {
	    match.checkTemplates( state );
	    statement.checkTemplates( state );
	}

	void clear( CompileState state ) {
	    match.clear( state );
	    statement.clear( state );
	    // label = null;
	}

        void compile(
		     CompileState state, 
		     IRBlock into, 
		     LLVM.BasicBlock this_handler, 
		     LLVM.BasicBlock next_handler, 
		     LLVM.BasicBlock exit_label,
		     // LLVM.BasicBlock outer_descriptor,
		     LLVM.Value exception_type, 
		     LLVM.Value exception_object, 
		     bool first,
		     bool last ) {
            Type type = match.getType( state );
	    IO.Std.err.println( "TTTT: compile catch" );
            
            if( type == null || type.TypeKind != Type.CLASS ) {
                error( "catch must be an object" );
                return;
            }
            
            System.String match_name = match.FirstName;

            if( match_name == null ) {
                error( "oops: catch match has null parameter name\n" );
                return;
            }

            Symbol param = state.findInCurrentScope( match.FirstName, Symbol.FIND_ANY );

            if( param == null ) {
                error( "oops: cannot locate exception parameter " + match_name );
                return;
            }

            param.Defined = state.BlockLevel;

	    // LLVM.BasicBlock outer_landing_pad = state.TopException.landing_pad;
	    // LLVM.BasicBlock outer_handler = state.TopException.handler;
	    LLVM.BasicBlock l = into.Block();
	    LLVM.BasicBlock m = into.Block();
	    
	    // ILabel descriptor_label = TempFactory.nextLabel();
	    // ILabel handler_label = TempFactory.nextLabel();

	    if( !first ) {
		// only emit label for this handler if not first handler in try because
		// first handler has additional tests on entry that are already compiled
		// with the label preceding them at this point:
		into.Label( this_handler );
	    }

	    LLVM.Type ptr_8 = LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(),0);
	    LLVM.Type ptr_ptr_8 = LLVM.Calls.LLVMPointerType(ptr_8,0);
	    
	    LLVM.Value vtable_temp = into.AllocaEntry(ptr_ptr_8, ".ex_vtable");

	    into.Store(
		       makeLLVMCast(
				    into.Load(exception_object),
				    ptr_ptr_8,
				    into
				    ),
		       vtable_temp
		       );

	    into.Label( m );

	    // get vtable or super class vtable:
	    into.Store(
		       makeLLVMCast(
				    into.Load(
					      into.Load(vtable_temp)
					      ),
				    ptr_ptr_8,
				    into
				    ),
		       vtable_temp
		       );

	    // if( !last ) {

	    if( next_handler == null ) {
		throw new System.Exception( "next handler is null compiling: " + this );
	    }

	    // if vtable is null then jump to next handler:
	    into.Branch(
			into.ICmp(
				  LLVM.LLVMIntPredicate.LLVMIntEQ,
				  into.Load(vtable_temp),
				  LLVM.Calls.LLVMConstPointerNull(ptr_ptr_8)
				  ),
			next_handler
			);

	    // if vtable doesn't match loop:
	    into.Branch(
			into.ICmp(
				  LLVM.LLVMIntPredicate.LLVMIntNE,
				  into.Load(vtable_temp),
				  makeLLVMCast(
					       makeLoadVTable( state, type.Clazz ),
					       ptr_ptr_8,
					       into
					       )
				  ),
			m
			);

	    // exception caught - fall through into body of catch statement:

	    into.Store(
		       makeLLVMCast(
				    into.Load(exception_object),
				    param.Type.getLLVMType(state),
				    into
				    ),
		       param.getLocal(state,into)
		       );

            statement.compile( state, into );


	    // call finally handler with stop exception (exception type = 0):

	    into.Store(
		       LLVM.Calls.LLVMConstInt(
					       LLVM.Calls.LLVMInt64Type(),
					       1L, // exception caught
					       0
					       ),
		       exception_type
		       );
					                                     

	    into.Jump( exit_label );
        }

        void dump( CompileState state, System.StringBuffer  buffer ) {
            buffer.append( "catch(" );
            match.dump( state, buffer );
            buffer.append( ") " );
            statement.dump( state, buffer );
            buffer.append( '\n' );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "catch " );
	    p.InArgs = true;
	    p.OneLine = true;
	    match.print( state, p );
	    p.InArgs = false;
	    p.OneLine = false;
	    p.println();
	    p.indent();
	    statement.print( state, p );
	    p.outdent();
	}
    }



    class Catches extends Statement {
        Generic.Vector<Catch> catches;

        void init( int line_number ) {
            super.init( line_number );
            catches = new Generic.Vector<Catch>();
        }

        void init( int line_number, Catch first ) {
            super.init( line_number );
            catches = new Generic.Vector<Catch>();
            add( first );
        }

        void add( Catch next ) {
            catches.add( next );
        }

	void checkTemplates( CompileState state ) {
	    foreach( Catch c; catches.elements() ) {
		c.checkTemplates( state );
	    }
	}

	void clear( CompileState state ) {
	    foreach( Catch c; catches.elements() ) {
		c.clear( state );
	    }
	}

        int compile(
		    CompileState state,
		    IRBlock into,
		    LLVM.BasicBlock finally_handler,
		    LLVM.Value exception_type,
		    LLVM.Value exception_object
		    ) {
	    ExceptionDescriptor ed;
            int offset = 0;

	    state.enterBlock();

	    LLVM.BasicBlock next_handler; // = into.Block();
	    LLVM.BasicBlock this_handler = into.Block();
	    LLVM.BasicBlock m = into.Block();

            bool outermost_frame = (state.ExceptionLevel == 1);

	    IO.Std.err.println( "TTTT: compile catches" );

	    into.Label( this_handler );

	    into.Branch(
			into.ICmp(
				  LLVM.LLVMIntPredicate.LLVMIntNE,
				  into.Load(exception_type),
				  // 2 == 'uncaught exception':
				  LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt64Type(),2L,0)
				  ),
			finally_handler
			);


	    /*    
            foreach( Catch d; catches.elements() ) {
                block.add( new ITree( line_number, Op.DUMMY_JUMP, 8, d.getLabel(state) ) );
            }
	    */

	    bool first = true;
            // block.add( new ITree( line_number, Op.JUMP, 8, skip_label ) );
	    for( int i = 0; i < catches.Length; i = i + 1 ) {
		Catch e = cast<Catch>(catches[i]);

		bool last = i == catches.Length - 1;
		if( last ) {
		    next_handler = finally_handler;
		} else {
		    next_handler = into.Block(".catch");
		}

		IO.Std.err.println( "last: " + last + ", i: " + i + ", catches.Length: " + catches.Length );
		IO.Std.err.println( "compile: " + e + ", next handler: " + cast int(next_handler) );
                // e.compile( state, into, this_handler, next_handler, finally_descriptor, et, ev, first, last );
		e.compile( state, into, this_handler, next_handler, finally_handler, exception_type, exception_object, first, last );
		if( !last ) {
		    this_handler = next_handler;		
		}

		first = false;
            }	    
	    
	    // block.add( new ITree( line_number, Op.LABEL, 8, exit_label ) ) ;

            
            // block.add( new ITree( line_number, Op.LABEL, 8, skip_label ) );
            
	    state.exitBlock();
            return offset;
        }

        void declareSymbols( CompileState state ) {
            foreach( Catch c; catches.elements() ) {
                c.declareSymbols( state );
            }
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

            foreach( Catch c; catches.elements() ) {
		c.print( state, p );
	    }
	}

	int getCatchCount() {
	    return catches.Length;
	}
    }

    class TryStatement extends Statement {
        Statement try_statement;
        Catches catches;
        Statement finally_statement;

        void init( int line_number, Statement try_statement, Catches catches, Statement finally_statement ) {
            super.init( line_number );
            this.try_statement = try_statement;
            this.catches = catches;
            this.finally_statement = finally_statement;
        }

        void declareSymbols( CompileState state ) {
            if( catches != null ) {
                catches.declareSymbols( state );
            }
            try_statement.declareSymbols( state );
            if( finally_statement != null ) {
                finally_statement.declareSymbols( state );
            }
        }

	void checkInline( CompileState state ) {
	    throw new CannotInlineException();
	}

	void checkTemplates( CompileState state ) {
	    if( catches != null ) {
		catches.checkTemplates( state );
	    }
	    try_statement.checkTemplates( state );
	    if( finally_statement != null ) {
		finally_statement.checkTemplates( state );
	    }
	}

	void clear( CompileState state ) {
	    if( catches != null ) {
		catches.clear( state );
	    }
	    try_statement.clear( state );
	    if( finally_statement != null ) {
		finally_statement.clear( state );
	    }
	}

	static LLVM.Value getUnwindOrRethrowFunction( CompileState state ) {
	    char ptr n = `_Unwind_RaiseException`;

	    var v = LLVM.Calls.LLVMGetNamedFunction(state.Module, n);

	    if( v == null ) {
		var args = { LLVM.Calls.LLVMInt64Type() };
		var ft = LLVM.Calls.LLVMFunctionType( LLVM.Calls.LLVMVoidType(), args.address, args.length, 0 );
		
		v = LLVM.Calls.LLVMAddFunction(state.Module, n, ft);				
	    }
	    
	    return v;
	}



	void rethrowOrReturn(
			     CompileState state,
			     IRBlock into,
			     LLVM.Value exception_type,
			     LLVM.Value exception_unwind
			   ) {
	    var exit = into.Block();
	    var return_ = into.Block();
	    var rethrow = into.Block();	    
	    
	    LLVM.Value s = into.Switch( into.Load(exception_type), rethrow, 2 );

	    // 1 == 'exception caught'
	    into.AddCase( s, LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt64Type(), 1L, 0 ), exit );

	    // 3 == 'throw return'
	    into.AddCase( s, LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt64Type(), 3L, 0 ), return_ );

	    into.Label( rethrow );
	    into.Call(
		      getUnwindOrRethrowFunction(state), { into.PtrToInt(into.Load(exception_unwind),LLVM.Calls.LLVMInt64Type()) }
		      );
	    // into.Unreachable();

	    into.Label( return_ );
	    if( !state.CurrentMethod.Type.isVoid() ) {
		into.Ret(
			 makeLLVMCast(
				      into.Load(exception_unwind),
				      state.CurrentMethod.Type.getLLVMType(state),
				      into
				      )
			 );
	    } else {
		into.RetVoid();
	    }
	    
	    into.Label(exit);
	}

	void rethrowOrDone(
			   CompileState state,
			   IRBlock into,
			   LLVM.Value exception_type,
			   LLVM.Value exception_object,
			   ExceptionDescriptor next
			   ) {

	    var l = into.Block();
	    
	    into.Branch(
			into.ICmp(
				  LLVM.LLVMIntPredicate.LLVMIntEQ,
				  into.Load( exception_type ),
				  // 1 == 'exception caught'
				  LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt64Type(),1L,0)
				  ),
			l
			);


	    into.Store(
		       into.Load(exception_type),
		       next.exception_type );

	    into.Store(
		       into.Load(exception_object),
		       next.exception_object );

	    into.JumpLabel( next.handler, l );
	}



        void compile( CompileState state, IRBlock into ) {
	    IO.Std.err.println( "TTTT: compile try" );

	    ExceptionDescriptor ed;
	    int old_exception_level = state.ExceptionLevel;

	    IO.Writer f = state.Output;

	    LLVM.Value exception_unwind = into.AllocaEntry( LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(),0), ".ex_unwind" );
	    LLVM.Value exception_object = into.AllocaEntry( LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(),0), ".ex_object" );
	    LLVM.Value exception_type = into.AllocaEntry( LLVM.Calls.LLVMInt64Type(), ".ex_type" );
		
	    LLVM.BasicBlock body_label = into.Block(".try_body");

            LLVM.BasicBlock finally_pad;
	    LLVM.BasicBlock finally_handler;

	    LLVM.BasicBlock exit_label;

	    // allocate temporaries for exception parameters. These are shared by all catches since the control
	    // flow into the block is predictable (it's only entered at the top and these temporaries can safely
	    // change register or go on the stack once they're received:

	    // state.markSeenExceptionHandler();

	    bool bottom_level = false;
	    if( state.ExceptionLevel == 0 ) {
		bottom_level = true;
	    }

	    if( finally_statement != null ) {
		finally_pad = into.Block(".finally_pad");
		finally_handler = into.Block(".finally_handler");

		// push descriptor for return cleanup handler:
		ed = new ExceptionDescriptor( EDType.CATCH_RETURN, finally_pad, finally_handler, exception_type, exception_unwind, exception_object );
		state.pushException(ed);
		// exception[exception_level] = ed;
		// exception_level = exception_level + 1;
	    } else {
		finally_handler = into.Block(".done");
	    }

	    // jump over code for catches to try body:
	    // FIXME: would be nice to avoid having to take this jump - ideally the no-exception case should
	    // be straight through. Could move catches block outside method body
	    into.Jump( body_label );

	    bool have_catches = false;	    

	    // compile catches, if any:
	    if( catches != null && catches.CatchCount > 0 ) {
		have_catches = true;
		LLVM.BasicBlock catches_pad = into.Block(".catches_pad");
		LLVM.BasicBlock catches_handler = into.Block(".catches_handler");

		addLandingPad(
			      state,
			      into,
			      exception_type,
			      exception_unwind,
			      exception_object,
			      catches_pad,
			      catches_handler,
			      false
			      );

		// exception handler stack contains at least return handler or finally plus outer handlers:
		// int compile( CompileState state, IBlock into, ILabel finally_descriptor, ILabel finally_handler, int exception_type, int exception_value )
                catches.compile( state, into, finally_handler, exception_type, exception_object );

		// previous_label = catches_label;

		// push an exception descriptor for the catches prior to compiling the try body statement
		// so code within the body sees catches, then any finally/return handler, then any outer
		// handlers from enclosing blocks:
		ed = new ExceptionDescriptor( EDType.CATCH_EXCEPTION, catches_pad, catches_handler, exception_type, exception_unwind, exception_object );
		state.pushException( ed );
		// exception[exception_level] = ed;
		// exception_level = exception_level + 1;
            }

	    into.Label( body_label );

	    into.Store(
		       LLVM.Calls.LLVMConstInt(
					       LLVM.Calls.LLVMInt64Type(),
					       1L,
					       0
					       ),
		       // 1 == 'exception caught' or stop after finally
		       exception_type
		       );

	    // IO.Std.err.println( "TTTT: compile body: " + try_statement );

	    // compile the body statement, any exceptions will be caught by the active handler set above
            try_statement.compile( state, into );

	    into.Jump( finally_handler );

	    // IO.Std.err.println( "TTTT: compiled body: " + try_statement );

	    var ex_args = new LLVM.Value[0];

	    /*

	    into.Store(
		       LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt64Type(), 0L, 0 ),
		       exception_type
		       );

	    into.Store(
		       LLVM.Calls.LLVMConstPointerNull( LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(), 0) ),
		       exception_value
		       );
	    */


	    if( have_catches ) {
		state.popException();
	    }

	    if( finally_statement != null ) {
		state.popException();

		addLandingPad(
			      state,
			      into,
			      exception_type,
			      exception_unwind,
			      exception_object,
			      finally_pad,
			      finally_handler,
			      true 
			      );
	    } else {
		into.Label( finally_handler );
	    }

	    /*
	    if( bottom_level ) {
		// outer most exception handler - restore active handler from the stack at runtime:
		// do nothing?
	    } else {
		// inner exception handler - restore active handler from compile time stack:
		exit_label = state.TopException.handler; // exception[exception_level-1].code_label;

	    }
	    */

	    if( finally_statement != null ) {
		finally_statement.compile( state, into );
	    }

	    ExceptionDescriptor fd;
	    
	    if( state.InExceptionHandler ) {
		fd = state.TopException;
	    }

	    if( fd != null ) {
		rethrowOrDone( state, into, exception_type, exception_object, fd );
	    } else {
		rethrowOrReturn( state, into, exception_type, exception_unwind );
	    }
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.println( "try" );
	    p.indent();
	    try_statement.print( state, p );
	    p.outdent();

	    if( catches != null ) {
		catches.print( state, p );
	    }

	    if( finally_statement != null ) {
		p.nl();
		p.println( "finally" );
		p.indent();
		finally_statement.print( state, p );
		p.outdent();
	    }

	    p.println( "yrt" );
	}
    }
}