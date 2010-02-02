
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    use Gen.IRBlock;
    use Gen.Machine;

    class CaseStatement extends LoopStatement {
        Expression expression;
        Vector<Case> cases;
        BlockStatement default_block;

        void init( int line_number ) {
            super.init( line_number );
            this.expression = null;
	    cases = new Vector<Case>();
        }

        void add( Case c ) {
            cases.add( c );
        }

        void setDefault( BlockStatement block ) {
            this.default_block = block;
        }

        void setExpression( Expression expression ) {
            this.expression = expression;
        }

	void clear( CompileState state ) {
	    foreach( Case c; cases.elements() ) {
                c.clear( state );
            }
        }

	void checkTemplates( CompileState state ) {
	    foreach( Case c; cases.elements() ) {
                c.checkTemplates( state );
            }
        }

        void declareSymbols( CompileState state ) {
            foreach( Case c; cases.elements() ) {
                c.declareSymbols( state );
            }
        }

        void compile( CompileState state, IRBlock into ) {
            LLVM.BasicBlock e = into.Block();
            state.Loops.pushLoop( LoopName, e, null );
            
            Type type = expression.getType(state);
            
            LLVM.Value temp = expression.compileValue(state,into);

            foreach( Case c; cases.elements() ) {
                c.compile( state, into, temp, type, e );
            }
            
            if( default_block != null ) {
                default_block.compile( state, into );
            }
            
	    into.Label(e);
            state.Loops.popLoop();
        }


        void dump( CompileState state, StringBuffer into ) {
            into.append( "switch(" );
            expression.dump(state,into);
            into.append( ") {\n" );
            foreach( Case c; cases.elements() ) {
                c.dump( state, into );
            }

            if( default_block != null ) {
                into.append( "default: " );
                default_block.dump( state, into );
            }
            into.append( "}\n" );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    String label = LoopName;
	    if( label != null ) {
		p.print( label );
		p.print( ": " );
	    }

	    p.print( "case " );
	    expression.print( state, p );

	    foreach( Case c; cases.elements() ) {
		c.print( state, p );
	    }

	    if( default_block != null ) {
		p.nl();
		p.println( "default:" );
		p.indent();
		default_block.print( state, p );
		p.outdent();
	    }

	    p.println( "esac" );
	}
    }

    class Case extends Statement {
        ExpressionList expression_list;
        BlockStatement block;
        
        void init( int line_number, ExpressionList expression_list, BlockStatement block ) {
            super.init( line_number );
            this.expression_list = expression_list;
            this.block = block;
        }
        
        void declareSymbols( CompileState state ) {
            block.declareSymbols( state );
        }

	void clear( CompileState state ) {
	    expression_list.clear(state);
	    block.clear(state);
	}

	void checkTemplates( CompileState state ) {
	    expression_list.checkTemplates(state);
	    block.checkTemplates(state);
	}

        
        void compile( CompileState state, IRBlock into, LLVM.Value temp, Type type, LLVM.BasicBlock exit ) {
            Vector<Expression> list = expression_list.List;
            LLVM.BasicBlock next = into.Block();

            if( list.Length == 1 ) {
                Expression expression = list[0];
                if( !type.isAssignableFrom(expression.getType(state)) ) {
                    error( "AA: case expression " + expression.dump(state) + " of type " + expression.getType(state).dump() + " not compatible with switch expression of type " + type.dump() );
                } else {

		    into.Branch(
				into.ICmp(
					  LLVM.LLVMIntPredicate.LLVMIntNE, 
					  temp,
					  expression.compileValue(state,into)
					  ),
				
				next
				);
			
                }
                block.compile( state, into );
            } else {
		LLVM.BasicBlock match = into.Block();
                
                foreach( Expression e; list.elements() ) {
                    if( !type.isAssignableFrom(e.getType(state)) ) {
                        error( "BB: case expression " + e.dump(state) + " of type " + e.getType(state).dump() + " not compatible with switch expression of type " + type.dump() );                  
                    } else {
			into.Branch(
				    into.ICmp(
					      LLVM.LLVMIntPredicate.LLVMIntEQ, 
					      temp,
					      e.compileValue(state, into)
					      ),
				    
				    match
				    );
                    }
                }


		into.JumpLabel( next, match );

                block.compile( state, into );
            }

            if( exit != null ) {
		into.JumpLabel( exit, next );
            } else {
		IO.Std.err.println( "FIXME: looks wrong - case may be falling through here" );
		into.Label( next );
	    }
        }

        
        void dump( CompileState state, StringBuffer into ) {
            into.append( "case " );
            expression_list.dump(state,into);
            into.append( ": " );
            block.dump( state, into );
            into.append( "\n" );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "is " );
	    expression_list.print( state, p );
	    p.println( ":" );
	    p.indent();
	    block.print( state, p );
	    p.outdent();

	}
    }

    class IfStatement extends Statement {
        Expression expression;
        Statement true_block;
        Statement false_block;
	bool last_return;

        void init( int line_number, Expression expression, Statement true_block, Statement false_block ) {
            super.init( line_number );
            this.expression = expression;
            this.true_block = true_block;
            this.false_block = false_block;
        }

        void init( int line_number, Expression expression, Statement true_block ) {
            super.init( line_number );
            this.expression = expression;
            this.true_block = true_block;
            this.false_block = null;
        }

	void clear( CompileState state ){
	    // last_return = false;
	    expression.clear( state );
	    true_block.clear( state );
	    if( false_block != null ) {
		false_block.clear( state );
	    }
	}

	void checkTemplates( CompileState state ){
	    // last_return = false;
	    expression.checkTemplates( state );
	    true_block.checkTemplates( state );
	    if( false_block != null ) {
		false_block.checkTemplates( state );
	    }
	}

        void declareSymbols( CompileState state ) {
            true_block.declareSymbols( state );
            if( false_block != null ) {
                false_block.declareSymbols( state );
            }
        }

        void compile( CompileState state, IRBlock into ) {
            LLVM.BasicBlock f = into.Block();

	    Type t = expression.getType(state); 
	    if( t.TypeKind != Type.BOOL ) {
	        error( "if condition is not bool: " + t );
	    } else {
		expression.compileBoolean( state, into, f, false );
	    }

            true_block.compile( state, into );
            
            if( false_block != null ) {
		LLVM.BasicBlock e = into.Block();
	    
		into.JumpLabel( e, f );

                false_block.compile( state, into );
                
		into.Label( e );
            } else {
		into.Label( f );
            }
        }


	get bool IsLastReturn {
	    bool result = true_block.IsLastReturn;
	    if( false_block != null ) {
		result = result && false_block.IsLastReturn;
	    }
	    /*
	    if( result ) {
		IO.Std.err.println( "if statement: last is return" );
	    }
	    */
	    last_return = result;
	    return result;
	}

	void markLastReturns() {    
	    if( last_return ) {
		true_block.markLastReturns();
		if( false_block != null ) {
		    false_block.markLastReturns();
		}
	    }
	}

	get bool IsIf {
	    return true;
	}

        void dump( CompileState state, StringBuffer  buffer ) {
            buffer.append( "if(" );
            expression.dump( state, buffer );
            buffer.append( ")" );
            true_block.dump( state, buffer );
            if( false_block != null ) {
                buffer.append( " else " );
                false_block.dump( state, buffer );
            }
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    if( p.InElif ) {
		p.InElif = false;
		p.print( "elif " );
	    } else {
		p.print( "if " );
	    }
	    expression.print( state, p );
	    p.println( " then" );
	    p.indent();
	    true_block.print( state, p );
	    p.outdent();
	    if( false_block != null ) {
		if( false_block.IsIf ) {
		    p.InElif = true;
		    false_block.print( state, p );
		} else {
		    p.println( "else" );
		    p.indent();
		    false_block.print( state, p );
		    p.outdent();
		    p.println( "fi" );
		}
	    } else {
		p.println( "fi" );
	    }
	}
    }
}