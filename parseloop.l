
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    use Gen.ITree;
    use Gen.IBlock;
    use Gen.IRBlock;
    use Gen.ILabel;
    use Gen.IString;
    use Gen.Machine;
    use Gen.TempFactory;
    use Gen.MBitSet;

    class Loop extends Object {
        public LLVM.BasicBlock break_label;
        public LLVM.BasicBlock continue_label;
        public String name;
        
        void init( String name, LLVM.BasicBlock bl, LLVM.BasicBlock cl ) {
            super.init();
            this.name = name;
            break_label = bl;
            continue_label = cl;
        }
    }

    class LoopStack {
        Vector<Loop> label;
        
        void init() {
            label = new Vector<Loop>();
        }

        void pushLoop( String name, LLVM.BasicBlock break_label, LLVM.BasicBlock exit_label ) {
            label.add( new Loop(name,break_label,exit_label));
        }

	void pushLoop( String name, ILabel break_label, ILabel exit_label ) {
	    label.add( new Loop(name, null, null) );
	}

        void popLoop() {
            label.pop();
        }

        get Loop TopLoop {
            return label.Top;
        }

        Loop findLoop( String s ) {
            for( int i = label.Length-1; i >= 0; i = i - 1 ) {
                Loop l = cast<Loop>(label[i]);
                if( l != null && l.name != null && l.name.equals(s) ) {
                    return label[i];
                }
            }
            return null;
        }
    }

    class LoopStatement extends Statement {
        String loop_name;

        void init( int line_number ) {
            super.init( line_number );
            loop_name = null;
        }
        
        set Identifier LoopName = l {
            loop_name = l.Name;
        }
        
        get String LoopName {
            return loop_name;
        }
    }


    class BreakStatement extends LoopStatement {
        void init( int line_number ) {
            super.init( line_number );
        }
        
        void compile( CompileState state, IRBlock into ) {
            String label = LoopName;
            Loop loop;
            if( label == null ) {
                loop = state.Loops.TopLoop;
            } else {
                loop = state.Loops.findLoop( label );
            }
            
            if( loop != null ) {
                if( loop.break_label == null ) {
                    error( "cannot break out of this construct" );
                } else if( state.InExceptionHandler ) {
                    error( "break with exception handlers active: not implemented" );
                } else {
		    into.Jump( loop.break_label );
                }
            } else {
                if( label != null ) {
                    error( "undefined loop label '" + label + "' in break" );
                } else {
                    error( "break outside of loop" );
                }
            }
        }

        void dump( CompileState state, StringBuffer into ) {
            into.append( "break;" );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

            String label = LoopName;
	    p.nl();
	    if( label != null ) {
		p.print( "break " );
		p.print( label );
		p.println( ";" );
	    } else {
		p.println( "break;" );
	    }
	}
    }
        
    class ContinueStatement extends LoopStatement {
        void init( int line_number ) {
            super.init( line_number );
        }
        
        void compile( CompileState state, IRBlock into ) {
            String label = LoopName;
            Loop loop;
            if( label == null ) {
                loop = state.Loops.TopLoop;
            } else {
                loop = state.Loops.findLoop( label );
            }
            
            if( loop != null ) {
                if( loop.continue_label == null ) {
                    error( "cannot continue this construct" );
                } else if( state.InExceptionHandler ) {
                    error( "break with exception handlers active: not implemented" );
                } else {
		    into.Jump( loop.continue_label );
                }
            } else {
                if( label != null ) {
                    error( "undefined loop label '" + label + "' in continue" );
                } else {
                    error( "break outside of loop" );
                }
            }
        }
        
        void dump( CompileState state, StringBuffer into ) {
            into.append( "continue" );
        }

	void print( CompileState state, Printer p ) {
	    p.nl();
            String label = LoopName;
	    if( label != null ) {
		p.print( "continue " );
		p.print( label );
		p.println( ";" );
	    } else {
		p.println( "continue;" );
	    }
	}
    }




    class DoWhileStatement extends LoopStatement {
        Expression expression;
        Statement block;

        void init( int line_number, Expression expression, Statement block ) {
            super.init( line_number );
            this.expression = expression;
            this.block = block;
        }
  
        void declareSymbols( CompileState state ) {
            block.declareSymbols(state);
        }

	void clear( CompileState state ) {
	    if( expression != null ) {
		expression.clear(state);
	    }
	    block.clear(state);
	}

	void checkTemplates( CompileState state ) {
	    if( expression != null ) {
		expression.checkTemplates(state);
	    }
	    block.checkTemplates(state);
	}

	void checkInline( CompileState state ) {
	    // throw new CannotInlineException();
	    if( expression != null ) {
		expression.checkInline(state);
	    }
	    block.checkInline( state );
	}

        void compile( CompileState state, IRBlock into ) {
            LLVM.BasicBlock t = into.Block();
            LLVM.BasicBlock e = into.Block();
            
            state.Loops.pushLoop( LoopName, e, t );

	    into.Label( t );
            
            // if( block != null ) {
                block.compile( state, into );
		// }

	    if( expression != null ) {
		expression.compileBoolean( state, into, t, true );
		into.Label( e );
	    } else {
		into.JumpLabel( t, e );
	    }

            state.Loops.popLoop();
        }

        void dump( CompileState state, StringBuffer into ) {
            into.append( "do " );
            block.dump( state, into );
            into.append( "while(" );
	    if( expression != null ) {
		expression.dump( state, into );
	    }
            into.append( ");" );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
            String label = LoopName;
	    if( label != null ) {
		p.print( label );
		p.print( ": " );
	    }

	    p.println( "do" );

	    p.indent();
	    block.print( state, p );

	    p.outdent();

	    if( expression != null ) {
		p.nl();
		p.print( "while " );
		p.print( expression );
		p.print( " " );
	    }

	    p.println( "od" );
	}
    }


    class WhileStatement extends LoopStatement {
        Expression expression;
        Statement block;
        void init( int line_number, Expression expression, Statement block ) {
            super.init( line_number );
            this.expression = expression;
            this.block = block;
        }
        
        void declareSymbols( CompileState state ) {
            block.declareSymbols( state );
        }

	void clear( CompileState state ) {
	    expression.clear(state);
	    block.clear(state);
	}

	void checkTemplates( CompileState state ) {
	    expression.checkTemplates(state);
	    block.checkTemplates(state);
	}

	void checkInline( CompileState state ) {
	    expression.checkInline( state );
	    block.checkInline( state );
	}

        
        void compile( CompileState state, IRBlock into ) {
            LLVM.BasicBlock t = into.Block();
            LLVM.BasicBlock c = into.Block();
            LLVM.BasicBlock e = into.Block();
            
            state.Loops.pushLoop( LoopName, e, c );

	    Type u = expression.getType(state); 
	    if( u.TypeKind != Type.BOOL ) {
	        error( "while condition is not bool: " + u );
	    } else {
		expression.compileBoolean( state, into, e, false );
	    }
	    into.Label(t);
            block.compile( state, into );
            expression.compileBoolean( state, into, t, true );
	    into.Label(e);
            state.Loops.popLoop();
        }
        
        void dump( CompileState state, StringBuffer  buffer ) {
            buffer.append( "while(" );
            expression.dump( state, buffer );
            buffer.append( ") " );;
            block.dump( state, buffer );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
            String label = LoopName;
	    if( label != null ) {
		p.print( label );
		p.print( ": " );
	    }

	    p.print( "while " );
	    expression.print( state, p );	   
	    p.println( " do" );

	    p.indent();
	    block.print( state, p );
	    p.outdent();

	    p.nl();
	    p.println( "od" );
	}
    }


    class ForEachStatement extends LoopStatement {
        TypeExpr type_expr;
        Identifier ident;
        Expression expr;
        Statement statement;

        void init( int line_number, TypeExpr type_expr, Identifier ident, Expression expr, Statement statement ) {
            super.init( line_number );
            this.type_expr = type_expr;
            this.ident = ident;
            this.expr = expr;
            this.statement = statement;
        }

	void checkInline( CompileState state ) {
	    throw new CannotInlineException();
	}
	
        void declareSymbols( CompileState state ) {	   
	    var te = type_expr;
	    var t = type_expr.parseType( state );
	    if( t.TypeKind == Type.INFER ) {
		te = inferElementTypeExpr( state );
	    }

            VariableDef vd_ident = new VariableDef( line_number, ident, 0, te ); // new ReferenceType( line_number, type_expr ) );

            vd_ident.declareSymbols(state);
            
            statement.declareSymbols( state );
        }

	void clear( CompileState state ) {
	    type_expr.clear(state);
	    ident.clear(state);
	    expr.clear(state);
	    statement.clear(state);
	}

	void checkTemplates( CompileState state ) {
	    type_expr.checkTemplates(state);
	    ident.checkTemplates(state);
	    expr.checkTemplates(state);
	    statement.checkTemplates(state);
	}

	TypeExpr inferElementTypeExpr( CompileState state ) {
            Type t = expr.getType(state);
            if( t.TypeKind == Type.VECTOR ) {
                return new WrapTypeAsTypeExpr( line_number, t.SubType ); 
            } else if( iterator_type.isAssignableFrom(t) ) {
		// may not be useful - cannot infer a more specific type here than Object
		return new WrapTypeAsTypeExpr( line_number, object_type );
	    } else {
		MethodCall next_element_call =
		    new MethodCall(
				   line_number,
				   new LoadTemporary( line_number, t, null, true ),  // spoof a 'this' for the call
				   new Identifier( line_number, "nextElement" ),
				   null );

		next_element_call.calcType(state,true);
		if( next_element_call.Quality != null ) {
		    return new WrapTypeAsTypeExpr( line_number, next_element_call.Type );
		} else {
		    return new WrapTypeAsTypeExpr( line_number, undefined_type );
		}
            }

	}

        void compile( CompileState state, IRBlock into ) {
            LLVM.BasicBlock exit = into.Block();
            LLVM.BasicBlock top = into.Block();
            LLVM.BasicBlock cont = into.Block();
            // bool is_vector = false;
	    LLVM.Value temp;
            Assignment assignment;

	    Cast next_element_cast;
	    MethodCall has_more_elements_call, next_element_call;
            
            state.Loops.pushLoop( LoopName, exit, cont );
            
            Symbol s = state.findSymbol( ident.Name, Symbol.FIND_ANY );
            if( s != null ) {
                s.Defined = state.BlockLevel;
            } else {
		IO.Std.err.println( "weird: foreach variable '" + ident.Name + "' is not defined here\n" );
		return;
	    }
             
            // MethodCall *elements_call = new MethodCall( line_number, expr, new Identifier( line_number, "elements" ), 0 );
            Type t = expr.getType(state);
	    /*
            if( t.TypeKind == Type.VECTOR ) {
		bool reference;
		Type it = type_expr.parseType(state);
                Type et = t.SubType;
		if( !it.isAssignableFrom(et) ) {
		    if( it.TypeKind == Type.REFERENCE ) {
			Type tt = it.SubType;
			if( tt.isAssignableFrom(et) ) {
			    it = tt;
			    reference = true;
			} else {
			    error( "for each variable " + s.HumanName + " of type " + tt + " is not assignable from " + et + " ref" );
			    it = undefined_type;
			}
		    } else {
			error( "for each variable " + s.HumanName + " of type " + it + " is not assignable from " + et );
			it = undefined_type;
		    }
		}

		int address = temp;
                int count = TempFactory.nextTemp();
                // int  = TempFactory.nextTemp();
                
                into.add( makeStoreTemporary( address, Machine.WORD, expr.compileValue( state, into ) ) );
                // into.add( makeStoreTemporary( temp1, 8, new ITree( line_number, Op.CONST, 8, 0 ) ) );
		into.add( makeStoreTemporary( count, Machine.WORD, 
					      makeLoadIndirect( state, line_number, into, Machine.WORD, true, // could throw null pointer exception  
								new ITree( line_number, Op.ADD, Machine.WORD,
									   makeLoadTemporary( address, Machine.WORD ),
									   new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_LENGTH_OFFSET )
									   )
								)
					      )
			  );
               
                // exit loop if array has zero elements...
		into.add( new ITree( line_number, Op.BRANCH, 0,
                                     new ITree( line_number, Op.LT, Machine.WORD,
                                                makeLoadTemporary( count, Machine.WORD ),
						new ITree( line_number, Op.CONST, Machine.WORD, 0 )
						),
				     exit
				     )
			  );
		
		into.add( makeStoreTemporary( address, Machine.WORD,
				    new ITree( line_number, Op.ADD, Machine.WORD,
					       makeLoadTemporary( address, Machine.WORD ),
					       new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_DATA_OFFSET )
					       )
				    )
			  );
                
                into.add( new ITree( line_number, Op.LABEL, 0, top ) );

		if( reference ) {
		    addStoreIndirect( state, line_number, into, Machine.WORD, false,
				      new ITree( line_number, Op.LOCAL, Machine.WORD, s.Address ),
				      makeLoadTemporary( address, Machine.WORD )
				      );
		} else {
		    addStoreIndirect( state, line_number, into, et.Size, false,
				      new ITree( line_number, Op.LOCAL, et.Size, s.Address ),
				      makeLoadIndirect( state, line_number, into, et.Size, false, 
							makeLoadTemporary( address, Machine.WORD )
							)
				      );
		}


                statement.compile( state, into );
                
                // into.add( new ITree( line_number, Op.LABEL, Machine, count ) );
                
                into.add( makeStoreTemporary( address, Machine.WORD,
					      new ITree( line_number, Op.ADD, Machine.WORD,
							 makeLoadTemporary( address, Machine.WORD ),
							 new ITree( line_number, Op.CONST, Machine.WORD, et.Size)
							 ) ) );

		into.add( new ITree( line_number, Op.DECBNN, Machine.WORD, makeLoadTemporary( count, Machine.WORD ), top ) );
                
                into.add( new ITree( line_number, Op.LABEL, 0, exit ) );
                
		} else*/
	    Type et;
	    LLVM.Type let;

	    if( iterator_type.isAssignableFrom(t) ) {
		et = type_expr.parseType(state);
		let = type_expr.parseType(state).getLLVMType(state);
		temp = into.AllocaEntry( let, ".iterator" );
		into.Store(
			   makeLLVMCast(
					expr.compileValue( state, into ),
					let,
					into
					),
			   temp
			   );
			   
                has_more_elements_call = new MethodCall(
							line_number,
							new LoadTemporary( line_number, iterator_type, temp, true ),
							new Identifier( line_number, "hasMoreElements" ), null );
                
                has_more_elements_call.compileBoolean( state, into, exit, false ); // exit loop

		into.Label( top );
                
                next_element_cast = new Cast(
					     line_number,
					     type_expr,
					     new MethodCall(
							    line_number,
							    new LoadTemporary( line_number, iterator_type, temp, true ),
							    new Identifier( line_number, "nextElement" ), null ) );
                
                assignment = new Assignment( line_number, ident, next_element_cast );
                assignment.compile( state, into );
                
                statement.compile( state, into );
 
		into.Label( cont );

                has_more_elements_call.compileBoolean( state, into, top, true ); // exit loop

		into.Label( exit );
            } else {
		// IO.Std.err.println( "QQQQQQ: iterator type is: " + type_expr );
		et = t;

		let = et.getLLVMType(state);
		temp = into.AllocaEntry( let, ".iterator" );
		into.Store(
			   makeLLVMCast(
					expr.compileValue( state, into ),
					let,
					into
					),
			   temp
			   );

		has_more_elements_call =
		    new MethodCall(
				   line_number,
				   new LoadTemporary( line_number, t, temp, true ),
				   new Identifier( line_number, "hasMoreElements" ),
				   null );
		
		Type hme = has_more_elements_call.getType(state);
		if( hme != undefined_type && hme.TypeKind != Type.BOOL ) {
		    error( "iterator nextElement() method must return bool" );
		}
		
		has_more_elements_call.compileBoolean( state, into, exit, false ); // exit loop

		into.Label( top );
		
		next_element_call =
		    new MethodCall(
				   line_number,
				   new LoadTemporary( line_number, t, temp, true ),
				   new Identifier( line_number, "nextElement" ),
				   null );
		
		assignment = new Assignment( line_number, ident, next_element_call );
		assignment.compile( state, into );
		
		statement.compile( state, into );

		into.Label( cont );

		has_more_elements_call.compileBoolean( state, into, top, true ); // exit loop

		into.Label( exit );
            }
            
            state.Loops.popLoop();
        }
        
        void dump( CompileState state, StringBuffer buffer ) {
            buffer.append("foreach()");
            statement.dump(state,buffer);
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
            String label = LoopName;
	    if( label != null ) {
		p.print( label );
		p.print( ": " );
	    }

	    p.print( "foreach " );
	    p.OneLine = true;
	    type_expr.print( state, p );
	    p.print( " " );
	    ident.print( state, p );
	    p.print( "; " );
	    expr.print( state, p );
	    p.OneLine = false;
	    p.println( " do" );
	    p.indent();
	    statement.print( state, p );
	    p.outdent();
	    p.println( "od" );
	}
    }

    class ForStatement extends LoopStatement {
        Statement initializer;
        Expression condition;
        Statement increment;
        Statement statement;

        void init( int line_number, Statement initializer, Expression condition, Statement increment, Statement statement ) {
            super.init( line_number );
            this.initializer = initializer;
            this.condition = condition;
            this.increment = increment;
            this.statement = statement;
        }

	void checkInline( CompileState state ) {
            if( initializer != null ) {
                initializer.checkInline( state );
            }

            if( increment != null ) {
                increment.checkInline( state );
            } 

            statement.checkInline( state );	    
	}

        void declareSymbols( CompileState state ) {
            if( initializer != null ) {
                initializer.declareSymbols( state );
            }

            if( increment != null ) {
                increment.declareSymbols( state );
            } 

            statement.declareSymbols( state );
        }

	void clear( CompileState state ) {
            if( initializer != null ) {
                initializer.clear( state );
            }

	    if( condition != null ) {
		condition.clear( state );
	    }

            if( increment != null ) {
                increment.clear( state );
            } 

            statement.clear( state );
	}

	void checkTemplates( CompileState state ) {
            if( initializer != null ) {
                initializer.checkTemplates( state );
            }

	    if( condition != null ) {
		condition.checkTemplates( state );
	    }

            if( increment != null ) {
                increment.checkTemplates( state );
            } 

            statement.checkTemplates( state );	
	}

	/*
	void checkInline( CompileState state ) {
	    throw new CannotInlineException();
	}
	*/
  
        void compile( CompileState state, IRBlock into ) {
            LLVM.BasicBlock top = into.Block();
            LLVM.BasicBlock cont = into.Block();
            LLVM.BasicBlock exit = into.Block();
            
            state.Loops.pushLoop( LoopName, exit, cont );
            
            if( initializer != null ) {
                initializer.compile( state, into );
            }
            
            if( condition != null ) {
		Type t = condition.getType( state );
		if( t.TypeKind != Type.BOOL ) {	    
		    error( "for loop condition is not bool: " + t );
		} else {   
		    condition.compileBoolean( state, into, exit, false ); // jump to exit on condition failed
		}
            }

	    into.Label( top );
            
            statement.compile( state, into );
            
	    into.Label( cont );

            if( increment != null ) {
                increment.compile( state, into );
            }
            
            if( condition != null ) {
                condition.compileBoolean( state, into, top, true ); // jump to top on condition true
		into.Label( exit );
            } else {
		into.JumpLabel( top, exit );
            }
                         
            state.Loops.popLoop();
        }    
        
        void dump( CompileState state, StringBuffer  buffer ) {
            buffer.append( "for(" );
            if( initializer != null ) {
                initializer.dump( state, buffer );
            }
            buffer.append( ';' );
            if( condition != null ) {
                condition.dump( state, buffer );
            }
            buffer.append( ';' );
            if( increment != null ) {
                increment.dump( state, buffer );
            }
            buffer.append( ';' );
            statement.dump( state, buffer );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
            String label = LoopName;
	    if( label != null ) {
		p.print( label );
		p.print( ": " );
	    }

	    p.print( "for " );
	    p.OneLine = true;
	    if( initializer != null ) {
		initializer.print( state, p );
	    } else {
		p.print( "; " );
	    }

	    if( condition != null ) {
		condition.print( state, p );
	    }

	    p.print( "; " );

	    if( increment != null ) {
		p.NoSemiColon = true;
		increment.print( state, p );
		p.NoSemiColon = false;
	    }

	    p.OneLine = false;
	    p.println( " do" );
	    p.indent();
	    statement.print( state, p );
	    p.outdent();
	    p.println( "od" );
	}
    }
}