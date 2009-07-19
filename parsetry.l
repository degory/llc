
namespace Parse {
    use Gen.ITree;
    use Gen.IBlock;
    use Gen.ILabel;
    use Gen.IString;
    use Gen.Machine;
    use Gen.TempFactory;
    use Gen.MBitSet;
  
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
        ILabel label;

        void init( int line_number, VariableDef v, Statement s ) {
            super.init( line_number );
            match = v;
            statement = s;
            label = null;
        }

        ILabel getLabel( CompileState state ) {
            if( label == null ) {
                label = TempFactory.nextLabel();
            }
            return label;
        }


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
	    label = null;
	}

        void compile(
		     CompileState state, 
		     IBlock into, 
		     ILabel this_handler, 
		     ILabel next_handler, 
		     ILabel outer_descriptor,
		     int exception_type, 
		     int exception_value, 
		     bool first,
		     bool last ) {
            Type type = match.getType( state );
            
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

	    ILabel outer_label = state.TopException.descriptor_label;
	    ILabel outer_handler = state.TopException.code_label;
	    ILabel l = TempFactory.nextLabel();
	    ILabel m = TempFactory.nextLabel();

	    // ILabel descriptor_label = TempFactory.nextLabel();
	    // ILabel handler_label = TempFactory.nextLabel();

	    IO.Writer f = state.Output;

	    Machine.emitRoDataSegment( f );

	    // catch type: 2 (catch)
	    Machine.emitDefPointer( f, 2 );
	    // catch vtable: 
	    Machine.emitDefPointer( f, getVTableAsString( state, type.Clazz ) );
	    // catch handler:
	    Machine.emitDefPointerLabel( f, this_handler.getInt() );
	    // back link:
	    if( last ) {
		Machine.emitDefPointerLabel( f, outer_descriptor.getInt() );
	    } else {
		Machine.emitDefPointer( f, 0 );
	    }

	    // at this point it's definitely an exception, need to decide if we catch it or pass it on:

	    into.add( new ITree( 0, Op.COMMENT, 0, "catch " + type.Clazz.HumanName ) );

	    if( !first ) {
		// only emit label for this handler if not first handler in try because
		// first handler has additional tests on entry that are already compiled
		// with the label preceding them at this point:
		into.add( new ITree( line_number, Op.LABEL, 0, this_handler ) );
	    }

	    int vtable_temp = TempFactory.nextTemp();

	    // copy exception value to a temporary:
	    into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				 new ITree( line_number, Op.TEMP, Machine.WORD, vtable_temp ),
				 new ITree( line_number, Op.TEMP, Machine.WORD, exception_value )
				 )
		      );

	    into.add( new ITree( line_number, Op.LABEL, 0, m ) );
	    
	    // get vtable or super class vtable:
	    into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				 new ITree( line_number, Op.TEMP, Machine.WORD, vtable_temp ),
				 // should never be null:
				 new ITree( line_number, Op.INDIRECT, Machine.WORD,
					    new ITree( line_number, Op.TEMP, Machine.WORD, vtable_temp )
					    )
				 )
		      );
	    

	    if( !last ) {
		// if the exception vtable is now null, it did not match this handler,
		// jump to the next handler, which is another catch and where the data
		// flow is predictable so we do not need to explicitly move the exception
		// type and value into argument registers:
		into.add( new ITree( line_number, Op.BRANCH, 0,
				     new ITree( line_number, Op.EQ, Machine.WORD,
						new ITree( line_number, Op.TEMP, Machine.WORD, vtable_temp ),
						new ITree( line_number, Op.CONST, Machine.WORD, 0 )
						),
				     next_handler
				     )
			  );
	    } else {
		// same test but the next exception handler is our finally block which can be
		// entered from unpredictable sources so we need to force the exception type and
		// value into predictable registers. Need to reverse the sense of the above test
		// and jump around a call to the handler preceded by a call arguments instruction
		// otherwise temporaries might change registers before the jump is executed:

		// if vtable is not null then it's possible we're a match for this exception
		// jump around jump to next handler
		into.add( new ITree( line_number, Op.BRANCH, 0,
				     new ITree( line_number, Op.NE, Machine.WORD,
						new ITree( line_number, Op.TEMP, Machine.WORD, vtable_temp ),
						new ITree( line_number, Op.CONST, Machine.WORD, 0 )
						),
				     l
				     )
			  );
				    
		// otherwise arrange to pass exception arguments
		into.add( new ITree( line_number, Op.ARG1, Machine.WORD,
				     new ITree( line_number, Op.TEMP, Machine.WORD, exception_value ),					    
				     new ITree( line_number, Op.ARG0, Machine.WORD,
						new ITree( line_number, Op.TEMP, Machine.WORD, exception_type ),
						new ITree( line_number, Op.COMMENT, 0, "exception param" )
						)
				     )
			  );
		
		// jump to the finally with arguments in correct registers:
		into.add( new ITree( line_number, Op.JUMP, 0, next_handler ) );
		
		// otherwise continue searching:
		into.add( new ITree( line_number, Op.LABEL, 0, l ) );
	    }


	    // does the exception vtable match our catch? If not loop and test exception's super
	    // class vtable:
	    into.add( new ITree( line_number, Op.BRANCH, 0,
				 new ITree( line_number, Op.NE, Machine.WORD,
					    new ITree( line_number, Op.TEMP, Machine.WORD, vtable_temp ),					    
					    loadVTable( state, type.Clazz )
					    ),
				 m
				 )
		      );


	    // thrown exception matches this catch, prepare to enter the catch block

	    // restore the stack pointer:
            into.add( new ITree( line_number, Op.COPY, Machine.WORD,
                                 new ITree( line_number, Op.REGISTER, Machine.WORD, Machine.R_STACK ),
				 new ITree( line_number, Op.INDIRECT, Machine.WORD, 
					    loadGlobalTLS( state, into, Machine.EXCEPTION_RSP )
					    ) ) );

	    // set up outer exception handler:
            into.add( new ITree( line_number, Op.COPY, Machine.WORD,
                                 new ITree( line_number, Op.INDIRECT, Machine.WORD,
					    loadGlobalTLS( state, into, Machine.EXCEPTION_TOP )
					    ),
				 
				 loadGlobal( state, outer_descriptor.toString(), 0 )
				 )
		      );
	    
	    // copy exception value into local variable:
	    addStoreIndirect( state, line_number, into, Machine.WORD, false,
			      new ITree( line_number, Op.LOCAL, Machine.WORD, param.Address ),
			      new ITree( line_number, Op.TEMP, Machine.WORD, exception_value )
			      );
                              
	    
	    // exception caught - fall through into body of catch statement:
	    
            statement.compile( state, into );

	    // call finally handler with stop exception (exception type = 0):
	    into.add( new ITree( line_number, Op.ARG0, Machine.WORD,
				 new ITree( line_number, Op.CONST, Machine.WORD, 0 ),
				 new ITree( line_number, Op.COMMENT, 0, "exception param" )
				 )
		      );

	    // exception caught, jump to finally:
	    into.add( new ITree( 0, Op.JUMP, 0, outer_handler ) );
            
            // into.add( new ITree( line_number, Op.JUMP, 8, exit_label ) );
	    into.add( new ITree( 0, Op.COMMENT, 0, "end catch " + type.Clazz.HumanName ) );
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

        int compile( CompileState state, IBlock into, ILabel finally_descriptor, ILabel finally_handler, int exception_type, int exception_value ) {
	    ExceptionDescriptor ed;
            int offset = 0;
            ILabel skip_label = TempFactory.nextLabel();
	    state.enterBlock();

	    ILabel next_handler = TempFactory.nextLabel();
	    ILabel this_handler = TempFactory.nextLabel();
	    ILabel m = TempFactory.nextLabel();

            foreach( Catch c; catches.elements() ) {
                offset = offset + Machine.WORD;
                // c.enter( state, into );
            }

            bool outermost_frame = (state.ExceptionLevel == 1);

	    into.add( new ITree(line_number, Op.COMMENT, 0, "start catch block" ) );
	    into.add( new ITree(line_number, Op.LABEL, 0, this_handler ) );

	    /*    
            foreach( Catch d; catches.elements() ) {
                block.add( new ITree( line_number, Op.DUMMY_JUMP, 8, d.getLabel(state) ) );
            }
	    */


	    // receive exception parameters:
	    into.add( new ITree( line_number, Op.PARAM1, Machine.WORD,
				 new ITree( line_number, Op.TEMP, Machine.WORD, exception_value ),					    
				 new ITree( line_number, Op.PARAM0, Machine.WORD,
					    new ITree( line_number, Op.TEMP, Machine.WORD, exception_type ),
					    new ITree( line_number, Op.COMMENT, 0, "exception param" )
					    )
				 )
		      );            

	    // if this is an exception, jump to the first catch block:
	    into.add( new ITree( line_number, Op.BRANCH, 0,
				 new ITree( line_number, Op.EQ, Machine.WORD,
					    new ITree( line_number, Op.TEMP, Machine.WORD, exception_type ),
					    new ITree( line_number, Op.CONST, Machine.WORD, cast<int>(EDType.THROW_EXCEPTION ) )
					    ),
				 m
				 )
		      );

	    // otherwise arrange to pass exception arguments
	    into.add( new ITree( line_number, Op.ARG1, Machine.WORD,
				 new ITree( line_number, Op.TEMP, Machine.WORD, exception_value ),					    
				 new ITree( line_number, Op.ARG0, Machine.WORD,
					    new ITree( line_number, Op.TEMP, Machine.WORD, exception_type ),
					    new ITree( line_number, Op.COMMENT, 0, "exception param" )
					    )
				 )
		      );


	    // and jump to finally handler
	    into.add( new ITree( line_number, Op.JUMP, 0, finally_handler ) );

	    into.add( new ITree( line_number, Op.LABEL, 0, m ) );

    
            // block.add( new ITree( line_number, Op.DUMMY_JUMP, 8, exit_label ) );

	    bool first = true;
            // block.add( new ITree( line_number, Op.JUMP, 8, skip_label ) );
	    for( int i = 0; i < catches.Length; i = i + 1 ) {
		Catch e = cast<Catch>(catches[i]);

		/*
		int et = TempFactory.nextTemp();
		int ev = TempFactory.nextTemp();

		into.add( makeStoreTemporary( et, Machine.WORD, makeLoadTemporary(exception_type,Machine.WORD) ) );
		into.add( makeStoreTemporary( ev, Machine.WORD, makeLoadTemporary(exception_value,Machine.WORD) ) );
		*/

		bool last = i == catches.Length - 1;
		if( last ) {
		    next_handler = finally_handler;
		}
                // e.compile( state, into, this_handler, next_handler, finally_descriptor, et, ev, first, last );
		e.compile( state, into, this_handler, next_handler, finally_descriptor, exception_type, exception_value, first, last );
		this_handler = next_handler;
		next_handler = TempFactory.nextLabel();
		first = false;
            }

	    into.add( new ITree( line_number, Op.COMMENT, 0, "end catches" ) );
	    
	    
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

        void compile( CompileState state, IBlock into ) {
	    ExceptionDescriptor ed;
	    int old_exception_level = state.ExceptionLevel;

	    IO.Writer f = state.Output;
		
	    ILabel body_label = TempFactory.nextLabel();

	    ILabel back_label;

            ILabel finally_descriptor = TempFactory.nextLabel();
	    ILabel finally_handler = TempFactory.nextLabel();

	    ILabel exit_label;

	    int offset_exception_top;
	    int offset_exception_rsp;


	    // allocate temporaries for exception parameters. These are shared by all catches since the control
	    // flow into the block is predictable (it's only entered at the top and these temporaries can safely
	    // change register or go on the stack once they're received:

	    int exception_type = TempFactory.nextTemp();
	    int exception_value = TempFactory.nextTemp();

	    // state.markSeenExceptionHandler();

	    bool bottom_level = false;
	    if( state.ExceptionLevel == 0 ) {
		// outermost handler in this method. Any finally statement will be included in the return handler
		
		// clean up handler will be output at this label:
		bottom_level = true;

		// allocate local variables to hold caller's exception state:
		offset_exception_top = state.CurrentMethod.alloc( Symbol.FLAG_LOCAL );
		offset_exception_rsp = state.CurrentMethod.alloc( Symbol.FLAG_LOCAL );

		// copy caller's exception state onto stack:

		// FIXME: this often ends up in registers anyway - could just put it in temporaries and
		// let it spill if needed instead? This would waste less stack space in the in-register case
		into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						new ITree( line_number, Op.LOCAL, Machine.WORD, offset_exception_top )
						),
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						loadGlobalTLS( state, into, Machine.EXCEPTION_TOP )
						) ) );

		into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						new ITree( line_number, Op.LOCAL, Machine.WORD, offset_exception_rsp )
						),
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						loadGlobalTLS( state, into, Machine.EXCEPTION_RSP )
						) ) );


		// output a descriptor for return/finally handler:

		Machine.emitRoDataSegment( f );
		Machine.emitLabel( f, finally_descriptor.getInt() );
		// catch type: 0 (return)
		Machine.emitDefPointer( f, 0 );
		// catch vtable: null
		Machine.emitDefPointer( f, state.CurrentMethod.DecoratedName );
		// catch handler: return
		Machine.emitDefPointerLabel( f, finally_handler.getInt() );
		// back pointer: null
		Machine.emitDefPointer( f, 0 );

		// push descriptor for return cleanup handler:
		ed = new ExceptionDescriptor( EDType.CATCH_RETURN, finally_descriptor, finally_handler );
		state.pushException(ed);
		// exception[exception_level] = ed;
		// exception_level = exception_level + 1;
	    } else {
		// not at outer most nesting level, output a finally (which may be empty
		// of user code if no finally statement supplied:

		// output a descriptor for finally handler:
		Machine.emitRoDataSegment( f );
		Machine.emitLabel( f, finally_descriptor.getInt() );
		
		back_label = state.TopException.descriptor_label;

		// catch type: 1 (finally)
		Machine.emitDefPointer( f, 1 );
		// catch vtable: null
		Machine.emitDefPointer( f, 0 );
		// catch handler: 
		Machine.emitDefPointerLabel( f, finally_handler.getInt() );
		// back pointer:
		Machine.emitDefPointerLabel( f, back_label.getInt() );
		
		ed = new ExceptionDescriptor( EDType.CATCH_FINALLY, finally_descriptor, finally_handler );
		state.pushException( ed );
		// exception[exception_level] = ed;
		// exception_level = exception_level + 1;
	    }

	    // jump over code for catches to try body:
	    // FIXME: would be nice to avoid having to take this jump - ideally the no-exception case should
	    // be straight through. Could move catches block outside method body
	    into.add( new ITree( line_number, Op.JUMP, 0, body_label ) );

	    bool have_catches = false;

	    // compile catches, if any:
	    if( catches != null && catches.CatchCount > 0 ) {
		have_catches = true;
		ILabel catches_descriptor = TempFactory.nextLabel();
		ILabel catches_handler = TempFactory.nextLabel();
		into.add( new ITree( 0, Op.COMMENT, 0, "catch handlers" ) );

		// output label for the catches descriptor:
		Machine.emitRoDataSegment( f );
		Machine.emitLabel( f, catches_descriptor.getInt() );

		into.add( new ITree( line_number, Op.LABEL, 0, catches_handler ) );

		// exception handler stack contains at least return handler or finally plus outer handlers:
		// int compile( CompileState state, IBlock into, ILabel finally_descriptor, ILabel finally_handler, int exception_type, int exception_value )
                catches.compile( state, into, finally_descriptor, finally_handler, exception_type, exception_value );

		// previous_label = catches_label;

		// push an exception descriptor for the catches prior to compiling the try body statement
		// so code within the body sees catches, then any finally/return handler, then any outer
		// handlers from enclosing blocks:
		ed = new ExceptionDescriptor( EDType.CATCH_EXCEPTION, catches_descriptor, catches_handler );
		state.pushException( ed );
		// exception[exception_level] = ed;
		// exception_level = exception_level + 1;
            }

	    into.add( new ITree( 0, Op.COMMENT, 0, "try body statement" ) );
	    into.add( new ITree( line_number, Op.LABEL, 0, body_label ) );

	    // which handler should catch exceptions throw in this block first:
	    ILabel active_descriptor = state.TopException.descriptor_label; // exception[exception_level-1].descriptor_label;

	    // set up the active exception handler:
	    // into.add( new ITree( line_number, Op.TRY, 0, loadGlobal( state, active_descriptor.toString(), 0 ), loadGlobalTLS(Machine.EXCEPTION_TOP) ) );
	    into.add( 
		     new ITree( line_number, Op.COPY, Machine.WORD,
				new ITree( line_number, Op.INDIRECT, Machine.WORD,
					   loadGlobalTLS(state, into, Machine.EXCEPTION_TOP)
					   ),
				loadGlobal(state, active_descriptor.toString(), 0)
				)
		      );

	    // is this the outer most exception handler in this method?
	    if( bottom_level ) {
		// save the current stack pointer so it can be restored if an exception is caught
		into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				 new ITree( line_number, Op.INDIRECT, Machine.WORD,
					    loadGlobalTLS( state, into, Machine.EXCEPTION_RSP )
					    ),
				 new ITree( line_number, Op.REGISTER, Machine.WORD, Machine.R_STACK ) ) );
	    }

	    Machine.emitTextSegment( f );

	    // compile the body statement, any exceptions will be caught by the active handler set above
            try_statement.compile( state, into );

	    // pass a stop exception to the following finally block, which will cause it to execute and
	    // fall through without re-throwing:
	    into.add( new ITree( 0, Op.END_TRY, 0 ) );

	    // this is either a finally, a return or a combined finally/return handler.
	    // emit the handler label:
            into.add( new ITree( line_number, Op.LABEL, 0, finally_handler ) );

	    exception_type = TempFactory.nextTemp();
	    exception_value = TempFactory.nextTemp();

	    // prepare to accept the exception type and value parameters passed to this handler:
	    into.add( new ITree( line_number, Op.PARAM0, Machine.WORD,
				 new ITree( line_number, Op.TEMP, Machine.WORD, exception_type ),
				 new ITree( line_number, Op.PARAM1, Machine.WORD,
					    new ITree( line_number, Op.TEMP, Machine.WORD, exception_value ),
					    new ITree( line_number, Op.COMMENT, 0, "exception param" )
					    )
				 )
		      );
	    
	    // restore stack pointer:
	    into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				 new ITree( line_number, Op.REGISTER, Machine.WORD, Machine.R_STACK ),
				 new ITree( line_number, Op.INDIRECT, Machine.WORD,
					    loadGlobalTLS( state, into, Machine.EXCEPTION_RSP )
					    ) ) );
	   
            state.ExceptionLevel = old_exception_level; 
	    if( bottom_level ) {
		// outer most exception handler - restore active handler from the stack at runtime:

		into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						loadGlobalTLS( state, into, Machine.EXCEPTION_TOP )
						),
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						new ITree( line_number, Op.LOCAL, Machine.WORD, offset_exception_top )
						) ) );

		into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						loadGlobalTLS( state, into, Machine.EXCEPTION_RSP )
						),
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						new ITree( line_number, Op.LOCAL, Machine.WORD, offset_exception_rsp )
						) ) );
	    } else {
		// inner exception handler - restore active handler from compile time stack:
		active_descriptor = state.TopException.descriptor_label; // exception[exception_level-1].descriptor_label;
		exit_label = state.TopException.code_label; // exception[exception_level-1].code_label;

		into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						loadGlobalTLS( state, into, Machine.EXCEPTION_TOP )
						),
				     loadGlobal( state, active_descriptor.toString(), 0 ) ) );
	    }

	    if( finally_statement != null ) {
		finally_statement.compile( state, into );
	    }

	    if( bottom_level ) {
		exit_label = state.ReturnLabel;

		// either fall through out of the try {} finally {} construct, rethrow an unhandled
		// exception or throw a return:
		into.add( new ITree( 0, Op.END_FINALLY, 0,
				     new ITree( line_number, Op.TEMP, Machine.WORD, exception_type ),
				     new ITree( line_number, Op.TEMP, Machine.WORD, exception_value ),
				     exit_label
				     )
			  );
	    } else {
		exit_label = state.TopException.code_label; // exception[exception_level-1].code_label;

		// if any unhandled exception is pending, jump to the next handler, otherwise
		// fall through out of try/finally construct:
		into.add( new ITree( 0, Op.COND_RETHROW, 0,
				     new ITree( line_number, Op.TEMP, Machine.WORD, exception_type ),
				     new ITree( line_number, Op.TEMP, Machine.WORD, exception_value ),
				     exit_label )
			  );
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