
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    use Gen.ITree;
    use Gen.IBlock;
    use Gen.ILabel;
    use Gen.IString;
    use Gen.Machine;
    use Gen.TempFactory;
    use Gen.MBitSet;

    /// Array literal
    class VectorList extends Expression {
        TypeExpr element_type;
        ExpressionList list;
        int element_kind;

        void init( int line_number, TypeExpr et, ExpressionList list ) {
            super.init( line_number );
            this.element_type = et;
            this.list = list;
        }

        void calcType( CompileState state ) {
            Type t, u;
            if( element_type != null ) {
                t = element_type.parseType(state);
                element_kind = t.TypeKind;
            } else if( list.List.Length == 0 ) {
		error( "cannot initialize array from zero length list with no type" );
		t = undefined_type;
	    } else {
                t = null;
                foreach( Expression e; list.List.elements() ) {
                    u = e.getType(state);
                    if( t == null && u.TypeKind != Type.NONE ) {
                        t = u;
                        element_kind = t.TypeKind;
                        break;
                    }
                }
		if( t == null ) {
		    error( "cannot initialize array from list with only null elements with no type" );
		    t = undefined_type;
		}
            }

            foreach( Expression f; list.List.elements() ) {
                u = f.getType(state);
		if( !t.isAssignableFrom( u ) ) {
		    if( t.isInteger() ) {
			error( "inconsitent types in array initializer: " + t.dump() + " and " + u.dump() );
			t = undefined_type;
			break;
		    } else if( u.isAssignableFrom( t ) ) { 
			t = u;
                    } else {
			t = object_type;
		    }
                }
            }

            type = new Type( Type.VECTOR, t );      
        }

        void declareSymbols( CompileState state ) {
            list.declareSymbols( state );
        }

	void checkInline( CompileState state ) {
            foreach( Expression f; list.List.elements() ) {
		f.checkInline( state );
	    }
	}

	void clear( CompileState state ) {
	    super.clear( state );
            foreach( Expression f; list.List.elements() ) {
		f.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
            foreach( Expression f; list.List.elements() ) {
		f.checkTemplates( state );
	    }
	}
        
        ITree compileValue( CompileState state, IBlock into ) {
            int t = TempFactory.nextTemp();
            Vector<Expression> l = list.List;

            int kind = getType(state).SubType.TypeKind;
            int size = getType(state).SubType.Size;
            if( kind == Type.CLASS || kind == Type.VECTOR ) {
                into.add( makeStoreTemporary( t, Machine.WORD,
                                              new ITree( line_number, Op.NEW_OBJ_ARRAY, 0,
                                                         new ITree( line_number, Op.CONST, Machine.WORD, l.Length ), null,
                                                         new IString( size ) ) ) );
            } else {
                into.add( makeStoreTemporary( t, Machine.WORD,
                                              new ITree( line_number, Op.NEW_ARRAY, 0,
                                                         new ITree( line_number, Op.CONST, Machine.WORD, l.Length ), null,
                                                         new IString( size ) ) ) );
            }
            int i = 0;
	    ITree tree;
            
	    if( l.Length < 5 ) {
		foreach( Expression e; l.elements() ) {
		    // Type tp = e.getType(state);
		    tree = e.compileValue( state, into );
		    
		    addStoreIndirect( state, line_number, into, size /*Machine.WORD*/, true, // could be null here? probably not actually 
				      new ITree( line_number, Op.ADD, Machine.WORD, 
						 makeLoadTemporary( t, Machine.WORD ),
						 new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_DATA_OFFSET + i * size )
						 ),
				      tree );
		    
		    i = i + 1;
		}
	    } else {
		// long list - keep address in temporary to avoid repeated address calculation:
		into.add( makeStoreTemporary( t, Machine.WORD,
					      new ITree( line_number, Op.ADD, Machine.WORD,
							 makeLoadTemporary( t, Machine.WORD ),
							 new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_DATA_OFFSET )
							 )
					      )
			  );

		foreach( Expression f; l.elements() ) {
		    tree = f.compileValue( state, into );

		    addStoreIndirect( state, line_number, into, size /*Machine.WORD*/, false, // cannot be null
 				      makeLoadTemporary( t, Machine.WORD ),
				      tree );
		    
		    into.add( makeStoreTemporary( t, Machine.WORD,
						  new ITree( line_number, Op.ADD, Machine.WORD,
							     makeLoadTemporary( t, Machine.WORD ),
							     new ITree( line_number, Op.CONST, Machine.WORD, size )
							     )
						  )
			      );
		}

		into.add( makeStoreTemporary( t, Machine.WORD,
					      new ITree( line_number, Op.SUB, Machine.WORD,
							 makeLoadTemporary( t, Machine.WORD ),
							 new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_DATA_OFFSET + l.Length * size )
							 )
					      )
			  );
	    }
            
            return makeLoadTemporary( t, Machine.WORD );
        }

	get int Depth {
	    int result = 0;
	    return list.Depth + 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    if( element_type != null ) {
		p.print( "new " );
		element_type.print( state, p );
		p.print( " " );
	    }
	    p.print("{");
	    list.print( state, p );
	    p.print("}");
	}
    }

    /// Cast
    class Cast extends Expression {
        TypeExpr left;
        Expression right;
        bool requires_runtime_check;

        void init( int line_number, TypeExpr left, Expression right ) {
            super.init( line_number );
            this.left = left;
            this.right = right;
            requires_runtime_check = false;
        }

        void calcType( CompileState state ) {
            type = left.parseType( state );
            Type from = right.getType(state);
	    bool should_warn = false;
	    
            if( type.isAssignableFrom( from ) ) {
                // fprintf( stderr, "redundant cast from %s -> %s. no run time check required\n", from.dump(), type.dump() );
            } else {
                int k = type.TypeKind;
		if( k == Type.CLASS ) {
		    if( type.isObject() ) {
			requires_runtime_check = true;
		    } else {
			should_warn = true;
		    }
		} else if( k == Type.POINTER ) {
		    should_warn = true;
		}

		if( should_warn ) {
		    if( state.WantMarkUnsafe ) {
			state.markCodeUnsafe( CompileState.UNSAFE_CAST );
		    }
                    if( state.WantWarnUnsafe ) {
                        warn( "cast from " + from.dump() + " to " + type.dump() + " cannot be checked at runtime" );
                    }
                }
            }
        }

	void clear( CompileState state ) {
	    super.clear( state );
	    left.clear( state );
	    right.clear( state );
	    requires_runtime_check = false;
	}

	void checkTemplates( CompileState state ) {
	    left.checkTemplates( state );
	    right.checkTemplates( state );
	}

	void checkInline( CompileState state ) {
	    right.checkInline(state);
	}

        ITree compileValue( CompileState state, IBlock into ) {
            Type r = right.getType( state );
            
            if( requires_runtime_check ) {

                String vtable = "vtable$__" + type.Clazz.DecoratedName;
                
                if( type.Clazz != state.CurrentClass ) {
                    into.add( new ITree(line_number, Op.EXTERN, 0, new IString(vtable) ) ); 
                }
		ITree tr = right.compileValue(state, into);
		if( !tr.isSimple() && state.InExceptionHandler ) { // make sure right completely evaluated before dummy jump to exception handler
		    int t = TempFactory.nextTemp();
		    into.add( makeStoreTemporary( t, Machine.WORD, tr ) );
		    tr = makeLoadTemporary( t, Machine.WORD );
		}
		addDummyExceptionHandlerJump( state, line_number, into );
                return new ITree( line_number, Op.CAST_CHECK, 0, tr, new IString(vtable));
            } else if( r.RegSize == getType(state).RegSize ) {
                return right.compileValue( state, into );
            } else {
		if( r.RegSize == 8 ) {
                    return new ITree( line_number, Op.CAST_FROM8,
                                      getType( state ).RegSize,
                                      right.compileValue( state, into ) );
		} else if( r.RegSize == 4 ) {
                    return new ITree( line_number, Op.CAST_FROM4,
                                      getType( state ).RegSize,
                                      right.compileValue( state, into ) );
                } else if( r.RegSize == 1 ) {
                    return new ITree( line_number, Op.CAST_FROM1,
                                      getType( state ).RegSize,
                                      right.compileValue( state, into ) );
                } else {
                    throw new Exception( "oops: cast from unexpected size: " + r.RegSize );
                    return right.compileValue( state, into );
                }
            }
        }
	
	get int Depth {
	    return right.Depth + 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "cast " );
	    left.print( state, p );
	    p.print( "(" );
	    right.print( state, p );
	    p.print( ")" );
	}
    }

    /// Load an intermediate code temporary as if it were a source expression
    class LoadTemporary extends Expression {
        int temporary;

        void init( int line_number, Type type, int temporary ) {
            super.init( line_number );
            this.type = type;
            this.temporary = temporary;
        }

        void calcType( CompileState state ) {
            // type = type_expr.parseType(state);
        }

	void clear( CompileState state ) {
	    IO.Std.err.println( "oops: load temporary clear type: this probably won't work" );
	}

	void checkTemplates( CompileState state ) {
	    IO.Std.err.println( "oops: load temporary check templates: this probably won't work" );
	}

        ITree compileValue( CompileState state, IBlock into ) {
            return makeLoadTemporary( temporary, type.Size );
        }

        void dump( CompileState state, StringBuffer buffer ) {
            buffer.append( "LoadTemporary #" + temporary );   
        }
    }

    /// This
    class This extends Expression {
        void init( int line_number ) {
            super.init( line_number );
        }
        
        ITree compileValue( CompileState state, IBlock  into ) {
            // return new ITree( line_number, Op.THIS, 8 );
            return makeLoadThis( state, line_number, into );
        }

        void calcType( CompileState state ) {
            type = state.CurrentClass.Type;
        }

	/* super class implementation is OK here:
	void clear( CompileState state ) {
	    type = null;
	}
	*/

	void checkTemplates( CompileState state ) {
	    // do nothing
	}


        bool isThis( CompileState state ) {
            return true;
        }

	get int Depth {
	    return 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "this" );
	}
    }

    /// Class qualifier (e.g. class Object)
    class ClassQualifier extends Expression {
        TypeExpr left;
	Container c;

        void init( int line_number,
                                  TypeExpr 
                                  left ) {
            super.init( line_number );
            this.left = left;
        }

        void calcType( CompileState  state ) {
            type = left.parseType( state );
            if( type.TypeKind != Type.CLASS ) {
                error( "cannot apply class<> to " + type + " which is not a class" );
            } else {
		c = type.Clazz;
	    }
        }

	void clear( CompileState state ) {
	    super.clear( state );
	    left.clear( state );
	    c = null;
	}

	void checkTemplates( CompileState state ) {
	    left.checkTemplates( state );
	}

        ITree compileValue( CompileState  state, IBlock into ) {
	    throw new Exception( "cannot compile class<>" );
	}

	get int Depth {
	    return 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "class<" );
	    left.print( state, p );
	    p.print( ">" );
	}
    }


    /// Super
    class Super extends Expression {
        void init( int line_number ) {
            super.init( line_number );
        }

        ITree compileValue( CompileState state, IBlock into ) {
            return makeLoadThis( state, line_number, into );
        }

        void calcType( CompileState state ) {
            if( state.CurrentClass == null ) {
                error( "cannot access super outside of any class" );
                type = undefined_type;
            } else {
                Container c = state.CurrentClass.Super;
                if( c == null ) {
                    error( "class " + state.CurrentClass.DecoratedName + " doesn't have a super class" );
                    type = undefined_type;
                }
                type = new Type( Type.SUPER, c );
            }
        }

        bool isSuper( CompileState state ) {
            return true;
        }

	get int Depth {
	    return 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "super" );
	}
    }

    class Constant extends Expression {
        String value;
	String print_value;

        void init( int line_number, int type, String value ) {
            super.init( line_number );
            if( type == Type.STRING ) {
                this.type = string_type;
		print_value = "\"" + escape(value, '"') + "\"";
		
            } else if( type == Type.CSTRING ) {
                this.type = new Type( Type.POINTER, new Type( Type.CHAR ) );
		print_value = "`" + escape(value, '`') + "`";
            } else if( type == Type.NULL ) {
                this.type = new Type( Type.NONE );
		print_value = "null";
            } else if( type == Type.INTEGER ) {
		// IO.Std.err.println( "int constant: '" + value + "'" );
		print_value = value;

		int l = value.Length;
		// IO.Std.err.println( "length: " + l );
		char last = value[l-1];
		// IO.Std.err.println( "last is: '" + last + "'" );
		if( last == 'w' || last == 'W' ) {
		    // IO.Std.err.println( "word literal..." );
		    value = value.substring( 0, value.Length-1 );
		    // IO.Std.err.println( "word literal: '" + value + "'" );
		    this.type = new Type( Type.WORD );
		} else if( last == 'l' || last == 'L' ) {
		    // IO.Std.err.println( "long literal..." );
		    value = value.substring( 0, value.Length-1 );
		    this.type = new Type( Type.LONG );
		    // IO.Std.err.println( "long literal: '" + value + "'" );
		} else if( last == 'c' || last == 'C' ) {
		    value = value.substring( 0, value.Length-1 );
		    this.type = new Type( Type.CHAR );
		} else {
		    // IO.Std.err.println( "regular int literal" );
		    this.type = new Type( type );
		}
		this.value = value;
            } else {
		print_value = value;

		this.type = new Type( type );
	    }		

	    if( type == Type.BOOL ) {
		if( value[0] == '1' ) {
		    print_value = "true";
		} else {
		    print_value = "false";
		}
		/*
		if( state.CurrentMethod != null ) {
		    IO.Std.err.println( state.CurrentMethod.HumanName + ": initialize bool literal '" + value + "'" );
		}
		*/
                this.value = value;
	    } else if( type == Type.CHAR ) {
		print_value = "'" + escape(value,'\'') + "'";		
                this.value = "" + cast<int>(value.charAt(0));
            } else if( Type.isInteger(type) && value.Length > 2 && (value[1] == 'x' || value[1] == 'X') ) {
                this.value = "" + value.substring(2).parseInt(16);
            } else {
                this.value = value;
            }
	    // IO.Std.err.println( "created: " + this );
        }

	void clear( CompileState state ) {
	    // do nothing - leave type intact
	}

	static String escape( String s, char quote ) {
	    int l = s.Length;
	    StringBuffer result = new StringBuffer(l);

	    for( int i = 0; i < l; i = i + 1 ) {
		char c = s[i];
		
		if( c == quote ) {
		    result.append( '\\' );
		    result.append( c );
		} else if( c == '\\' ) {
		    result.append( "\\\\" );
		} else if( c == '\n' ) {
		    result.append( "\\n" );
		} else if( c == '\t' ) {
		    result.append( "\\t" );
		} else if( c < ' ' || c > cast<char>(127) ) {
		    result.append( "\\0" );
		    result.append( cast<int>(c), 8 );
		} else {
		    result.append( c );
		}
	    }

	    return result;
	}

        void calcType( CompileState state ) {	    
            if( type.TypeKind == Type.STRING ) {
                IO.Std.out.println( "calcType for string constant gives: " + type );
            }
        }

        void dump( CompileState state, StringBuffer buffer ) {
            buffer.append( value );
        }
        
        void declareSymbols( CompileState  state ) {
        }

        ITree compileValue( CompileState state, IBlock into ) {
	    // IO.Std.err.println( "compiling constant: " + this );
            if( type == string_type ) {
		// IO.Std.err.println( "string constant" );
		// native.printf( `value is %X\n`, value );
		// IO.Std.err.println( "value: " + value );
		ITree t = new ITree( line_number, Op.CONST_STR, 0, value );
		// IO.Std.err.println( "result is: " + t );
		return t;
            } else if( type.TypeKind == Type.POINTER
                       && type.SubType.TypeKind == Type.CHAR ) {
		// IO.Std.err.println( "C String constant" );
                return new ITree( line_number, Op.CONST_CSTR, 0, value );
            } else {
		// IO.Std.err.println( "other constant: '" + value + "'" );
                return new ITree( line_number, Op.CONST,
                                  getType( state ).RegSize, value );
            }
        }

        ITree compileAddress( CompileState state, IBlock into ) {
            error( "constant has no address" );
            return new ITree( line_number, Op.ERROR, 0 );
        }

        String toString() {
            return "Constant(" + value + "," + type + ")";
        }

	get int Depth {
	    return 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( print_value );
	}
    }


    class ArithExpression extends Expression {
        protected int operation;
        protected MethodCall method_call;
        protected Expression left;
        protected Expression right;
	protected bool object_equals;
	protected bool not_result;
	protected bool inequality;
	protected bool reverse;

        void init( int line_number, int op, Expression left, Expression right ) {
            super.init( line_number );
	    // IO.Std.err.println( "ArithExpression: init: " + op + " versus " + Op.OBJ_EQ + " or " + Op.OBJ_NE );

	    if( op == Op.OBJ_EQ ) {
		object_equals = true;
		op = Op.EQ;
	    } else if( op == Op.OBJ_NE ) {
		object_equals = true;
		op = Op.EQ;
		not_result = true;
	    }

            this.operation = op;
            this.left = left;
            this.right = right;
            method_call = null;
        }
        
	void clear( CompileState state ) {
	    super.clear( state );
	    // object_equals = false;
	    // not_result = false;
	    inequality = false;
	    reverse = false;
	    left.clear( state );
	    if( right != null ) {
		right.clear( state );
	    }
	}

	get int Operation {
	    return operation;
	}

        void calcType( CompileState state ) {
	    type = undefined_type;

            Type tl = left.getType( state );
	    // IO.Std.err.println( "arith calc type op: " + operation );
	    // IO.Std.err.println( "object equals: " + object_equals );

            if( right != null ) {
                Type tr = right.getType( state );
                bool comparison = operation >= Op.EQ && operation <= Op.LE;
                bool equals = operation == Op.EQ || operation == Op.NE;

		// is either the operation not equals or was object equals explicitly requested?
		// is at least one operand an object? 

		/*
		if( tl.TypeKind == Type.CLASS || tr.TypeKind == Type.CLASS ) {
		    IO.Std.err.println( "op: " + operation + " versus " + Op.EQ );
		    IO.Std.err.println( "equals: " + equals );
		    IO.Std.err.println( "object_equals: " + object_equals );
		    IO.Std.err.println( "tl: " + tl );
		    IO.Std.err.println( "tr: " + tr );

		    if( operation == Op.EQ ) {
			IO.Std.err.println( "ZZZZZZ: equals operator: " + operation + " == " + Op.EQ + ", equals: " + equals );
		    }
		} else if( equals && object_equals) {
		    IO.Std.err.println( "ZZZZZZ: object equals operation on non-objects: " + tl + " =~ " + tr );
		}
		*/

		// need at least one object operand for operator method and either explicit object-equals operator or 
		// an inequality or an arithmetic operator

		// note: no need to bother calling opEquals for =~ or !~ when at least one operand is literal null because
		// the result can be determined directly by comparing the operands' addresses

		// look for an operator method if:
		// operator is not equal or operator is object equals and neither operand is literal null AND
		// at least one operand is an object:

		if( (
		     !equals || 
		     (object_equals && (tl.TypeKind != Type.NONE && tr.TypeKind != Type.NONE))
		     ) &&
		    (tl.TypeKind == Type.CLASS || tr.TypeKind == Type.CLASS) ) {
		    MethodCall call_normal, call_reverse;
		    // IO.Std.err.println( "operator overload call: " + tl + " op " + tr );
		    Quality quality_normal, quality_reverse;
		    Type type_normal, type_reverse;

		    reverse = false;

		    String op_string = null; // for error reporting
                    String n;                // operator method name
		    
		    do {
			/*
			IO.Std.err.println( "at start reverse now: " + reverse );
			IO.Std.err.println( "searching " + tl + " operator " + tr + "..." );
			*/

			// loop at most twice, once for forward operation and once for reverse

			if( !reverse ) {
			    if( tl.TypeKind != Type.CLASS ) {
				// cannot look for operator methods in non-class left operand:
				reverse = true;
			    }
			} else {
			    if( tr.TypeKind != Type.CLASS ) {
				// cannot look for reverse operator methods in non-class right operand:
				break;
			    }
			}

			switch( operation ) {
			case Op.ADD:
			    op_string = "+";
			    if( reverse ) {
				n = "opAddRev";
			    } else {
				n = "opAdd";
			    }
			    
			case Op.SUB:
			    op_string = "-";
			    if( reverse ) {
				n = "opSubRev";
			    } else {
				n = "opSub";
			    }
			    
			case Op.MUL:
			    op_string = "*";
			    if( reverse ) {
				n = "opMulRev";
			    } else {
				n = "opMul";
			    }
			    
			case Op.DIV:
			    op_string = "/";
			    if( reverse ) {
				n = "opDivRev";
			    } else {
				n = "opDiv";
			    }
			    
			case Op.MOD:
			    op_string = "%";
			    if( reverse ) {
				n = "opModRev";
			    } else {
				n = "opMod";
			    }
			    
			case Op.SHL:
			    op_string = "<<";
			    if( reverse ) {
				n = "opShlRev";
			    } else {
				n =  "opShl";
			    }
			    
			case Op.SHAR:
			    op_string = ">>";
			    if( reverse ) {
				n = "opSharRev";
			    } else {
				n = "opShar";
			    }
			    
			case Op.AND:
			    op_string = "&";
			    if( reverse ) {
				n = "opAndRev";
			    } else {
				n =   "opAnd";
			    }
			    
			case Op.OR:
			    op_string = "|";
			    if( reverse ) {
				n = "opOrRev";
			    } else {
				n = "opOr";
			    }
			    
			case Op.XOR:
			    op_string = "^";
			    if( reverse ) {
				n = "opXorRev";
			    } else {
				n = "opXor";
			    }
			    
			case Op.EQ:
			    op_string = "=~";
			    n = "opEquals";
			    /*			
						case Op.NE:
						n = "opEq";
						not_result = true;
			    */
			    
			case Op.GT:
			    op_string = ">";
			    n = "opCompare";
			    inequality = true;
			    if( reverse ) {
				operation = Op.LT;
			    }
			    
			case Op.LT:
			    op_string = "<";
			    n = "opCompare";
			    inequality = true;
			    if( reverse ) {
				operation = Op.GT;
			    }
			    
			case Op.GE:
			    op_string = ">=";
			    n = "opCompare";
			    inequality = true;
			    if( reverse ) {
				operation = Op.LE;
			    }
			    
			case Op.LE:
			    op_string = "<=";
			    n = "opCompare";
			    inequality = true;
			    if( reverse ) {
				operation = Op.GE;
			    }
			    
			default:
			    error( "cannot use this operator here" );			   
			    return;
			    // op_string = "unexpected operator";
			    // n = "<undefined operator " + operation + ">";
			}

			// IO.Std.err.println( "potential operator method: " + n );
			
			Identifier name = new Identifier( line_number, n );
			ExpressionList arg = new ExpressionList( line_number );
			if( reverse ) {
			    arg.add( left );
			    call_reverse = new MethodCall( line_number, right, name, arg );
			    // IO.Std.err.println( "will check reverse operation method: " + call_reverse );
			    if( object_equals && (tl.TypeKind == Type.CLASS || tl.TypeKind == Type.NONE) ) {
				// include null check:
				call_reverse.IsCompareOperation = true;
				call_reverse.NotResult = not_result;
			    }
			    call_reverse.calcType( state, true );
			    type_reverse = call_reverse.Type;
			    quality_reverse = call_reverse.Quality;

			    break;
			} else {
			    arg.add( right );
			    call_normal = new MethodCall( line_number, left, name, arg );
			    // IO.Std.err.println( "will check normal operation method: " + call_normal );
			    if( object_equals && (tr.TypeKind == Type.CLASS || tr.TypeKind == Type.NONE) ) {
				// include null check:
				call_normal.IsCompareOperation = true;
				call_normal.NotResult = not_result;
			    }
			    call_normal.calcType( state, true );
			    type_normal = call_normal.Type;
			    quality_normal = call_normal.Quality;
			    
			    reverse = true;
			}
		    } while( true );

		    if( quality_normal == null && quality_reverse == null ) {
			error( "no matching method found for operation " + tl + " " + op_string + " " + tr );
			method_call = null;
			type = undefined_type;
			return;
		    } else if( quality_reverse == null ) {
			method_call = call_normal;
			type = type_normal;
		    } else if( quality_normal == null ) {
			method_call = call_reverse;
			type = type_reverse;
		    } else {
			if( quality_normal >= quality_reverse ) {
			    method_call = call_normal;
			    type = type_normal;
			} else {
			    method_call = call_reverse;
			    type = type_reverse;
			}
		    }
		    

		    // IO.Std.err.println( "method call now: " + method_call );

		    if( method_call == call_reverse && state.WantWarnResolve ) {
			warn( "using reverse operator method '" + n + "' for " + tl + " " + op_string + " " + tr );
		    }

                } else if( !comparison && tl.TypeKind == Type.POINTER ) {
                    type = tl;
                    if( !tr.isInteger() ) {
                        error( "pointer arithmetic with non-integer type " + tr.dump() + " and " + tl.dump() );
                    }
		    if( state.WantMarkUnsafe ) {
			state.markCodeUnsafe( CompileState.UNSAFE_POINTER );
		    }
                    if( state.WantWarnUnsafe ) {
                        warn( "pointer arithmetic" );
                    }
                } else if( !comparison && tr.TypeKind == Type.POINTER ) {
                    type = tr;
                    if( !tl.isInteger() ) {
                        error( "pointer arithmetic with non-integer type " + tl.dump() + " and " + tr.dump() );
                    }
		    if( state.WantMarkUnsafe ) {
			state.markCodeUnsafe( CompileState.UNSAFE_POINTER );
		    }
                    if( state.WantWarnUnsafe ) {
                        warn( "pointer arithmetic" );
                    }
                } else if( tl.equals( tr ) ) {
                    if( comparison ) {
                        type = new Type( Type.BOOL );
                    } else {
                        type = tl;
                    }
                } else {
                    bool ok = false;

                    if( operation == Op.EQ || operation == Op.NE ) {
			// IO.Std.err.println( "check types for equals operator: " + tl + " versus " + tr );
                        // if( tl.isContainer() && tr.isContainer() ) {
			if( tl.TypeKind == Type.CLASS && tr.TypeKind == Type.CLASS ) {
                            if( tl.isAssignableFrom( tr ) || tr.isAssignableFrom( tl ) ) {
                                ok = true;
				type = new Type( Type.BOOL );
			    }
                        }

                        if( !ok ) {
                            error( "cannot compare " + tl.dump() + " to " + tr.dump() );
                        }
                    } else {
                        error( "type mismatch " + tl.dump() + " != " + tr.dump() );

                    }
                }
            } else {
                type = left.getType(state);
            }

	    // IO.Std.err.println( "method call: " + method_call );
	    // IO.Std.err.println( "type: " + type );
        }

        void declareSymbols( CompileState  state ) {
        }


	void checkInline( CompileState state ) {
	    if( left != null ) {
		left.checkInline( state );
	    }
	    if( right != null ) {
		right.checkInline( state );
	    }
	}

	void checkTemplates( CompileState state ) {
	    if( left != null ) {
		left.checkTemplates( state );
	    }

	    if( right != null ) {
		right.checkTemplates( state );
	    }
	}

        ITree compileValue( CompileState  state, IBlock into ) {
	    int op = operation;
	    ITree t;
	    // IO.Std.err.println( "ArithExpression.compileValue: " + this );
            if( method_call != null ) {
		// IO.Std.err.println( "compiling ArithExpression method call: " + method_call );
		int size = method_call.getType(state).RegSize;

		t = method_call.compileValue( state, into );

		if( not_result ) {
		    t = new ITree( line_number, Op.EQ, size, t, new ITree( line_number, Op.CONST, size, 0 ) );
		} else if( inequality ) {
		    if( reverse ) {
			op = getReverseJumpOp( op, true );
		    }
		    t = new ITree( line_number, op, size, t, new ITree( line_number, Op.CONST, size, 0 ) );
		}

		return t;
            } else if( right != null ) {
                bool comparison = operation >= Op.EQ && operation <= Op.LE;
                
                ITree cl = left.compileValue( state, into );
                ITree cr = right.compileValue( state, into );
                
                getType( state );
                
                Type tl = left.getType( state );
                Type tr = right.getType( state );

                bool pl = tl.TypeKind == Type.POINTER;
                bool pr = tr.TypeKind == Type.POINTER;

		if( (pl || pr) && !comparison ) {
		    int element_size = type.SubType.RegSize;

		    // IO.Std.err.println( "left: " + tl );
		    // IO.Std.err.println( "right: " + tr );
		    // IO.Std.err.println( "pointer expression, type: " + type + ", size: " + type.getRegSize() );
		    
		    if( pr ) {
		     	if( tl.Size == 1 ) {
			    cl = new ITree( line_number, Op.CAST_FROM1, Machine.WORD, cl );
			} else if( tl.Size == 4 ) {
			    cl = new ITree( line_number, Op.CAST_FROM4, Machine.WORD, cl );
			}

			if( element_size != 1 ) {
			    cl = new ITree( line_number, Op.MUL, Machine.WORD, cl,
					    new ITree( line_number,
						       Op.CONST, Machine.WORD,
						       element_size) );
			}
		    }

		    if( pl ) {
			if( tr.Size == 1 ) {
			    cr = new ITree( line_number, Op.CAST_FROM1, Machine.WORD, cr );
			} else if( tr.Size == 4 ) {
			    cr = new ITree( line_number, Op.CAST_FROM4, Machine.WORD, cr );
			}

			if( element_size  != 1 ) {
			    cr = new ITree( line_number, Op.MUL, Machine.WORD, cr,
					    new ITree( line_number,
						       Op.CONST, Machine.WORD,
						       element_size ) );
			}
		    }
		} else if( !pl && !pr && tl.RegSize != tr.RegSize ) {
		    // IO.Std.err.println( "left: " + tl.getRegSize() + ", " + left );
		    // IO.Std.err.println( "right: " + tr.getRegSize() + ", " + right );

                    error( "oops: arithmetic operands are different register sizes" );
                }


		if( not_result && op == Op.EQ ) {
		    t = new ITree( line_number, Op.NE,
                                     left.getType( state ).RegSize,
                                     cl, cr );
		} else {
		    t = new ITree( line_number, op,
                                     left.getType( state ).RegSize,
                                     cl, cr );
		    if( not_result ) {
			IO.Std.err.println( "VVVVVV: unexpected not result for non == operation" );

			t = new ITree( line_number, Op.NE, 1, t, new ITree( line_number, Op.CONST, 1, 0 ) );
		    }
		}
                return t;
            } else {
                return new ITree( line_number, operation,
                                  left.getType( state ).RegSize,
                                  left.compileValue( state, into ) );
            }

        }

        String toString() {
            StringBuffer result = new StringBuffer();
            if( right == null ) {
                result.append( "op" );
                result.append( cast<int>(operation) );
                result.append( ' ' );
                result.append( left );
            } else {
                result.append( left );
                result.append( " op" );
                result.append( cast<int>(operation) );
                result.append( ' ' );
                result.append( right );
            }
            return result;
        }

	get String OpString {
	    switch( operation ) {
	    case Op.NEG:
		return "-";

	    case Op.NOT:
		return "~";

	    case Op.BOOL_NOT:
		return "!";

	    case Op.BOOL_AND:
		return "&&";

	    case Op.BOOL_OR:
		return "||";
		
	    case Op.ADD:
		return "+";

	    case Op.SUB:
		return "-";
		
	    case Op.MUL:
		return "*";
		
	    case Op.DIV:
		return "/";
		
	    case Op.MOD:
		return "%";
		
	    case Op.SHL:
		return "<<";
		
	    case Op.SHAR:
		return ">>";
					    
	    case Op.AND:
		return "&";
			    
	    case Op.OR:
		return "|";
					    
	    case Op.XOR:
		return "^";
					    
	    case Op.EQ:
		if( object_equals ) {
		    if( not_result ) {
			return "!~";
		    } else {
			return "=~";
		    }
		} else {
		    if( not_result ) {
			return "!=";
		    } else {
			return "==";
		    }
		}

	    case Op.NE:
		return "!=";
			    
	    case Op.GT:
		return ">";
			    
	    case Op.LT:
	        return "<";
		
	    case Op.GE:
		return ">=";
		
	    case Op.LE:
		return "<=";

	    default:
		return "unknown-op";
	    }
	}

	get int Depth {
	    int result = left.Depth;
	    if( right != null ) {
		int d = right.Depth;
		if( d > result ) {
		    result = d;
		}
	    }

	    return result + 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    int d = Depth;
	    bool multi_line = false;

	    bool same_left = Operation == left.Operation;

	    if( d > 4 ) {
		multi_line = true;
		if( !same_left ) {
		    p.indent();
		}

		p.OneLine = false;
		p.nl();
	    }

	    if( right == null ) {
		p.print( OpString );
	    }

	    if( !same_left ) {
		p.inparen();
	    }

	    left.print( state, p );

	    if( !same_left ) {
		p.outparen();
	    }

	    if( right != null ) {
		bool same_right = Operation == right.Operation;


		if( p.expr_level <= 0 ) {
		    p.print( " " );
		}

		p.print( OpString );

		if( p.expr_level <= 0 ) {
		    p.print( " " );
		}

		if( !same_right ) {
		    p.inparen();
		}
		right.print( state, p );

		if( !same_right ) {
		    p.outparen();
		}
	    }

	    if( multi_line && !same_left ) {
		p.outdent();
		p.nl();
	    }
	}
    }


    class BooleanExpression extends ArithExpression {
	Type method_type;

        void init( int line_number, int operation, Expression left, Expression right ) {
            super.init( line_number, operation, left, right );
	    // Std.err.println( "BooleanExpression: init after: " + this.operation + " versus " + Op.OBJ_EQ + " or " + Op.OBJ_NE );
        }


        void calcType( CompileState state ) {
	    // Std.err.println( "BooleanExpression: calling super.calcType..." );
	    super.calcType( state );
	    if( method_call != null ) {
		method_type = type;
		type = new Type( Type.BOOL );
	    }
	}

	void clear( CompileState state ) {
	    super.clear( state );
	    method_type = null;
	}

        ITree compileValue( CompileState state, IBlock into ) {
	    getType(state);

	    if( method_call != null || ( operation >= Op.EQ && operation <= Op.LE) ) {
		// Std.err.println( "boolean expression compile value operation overload method: " + method_call );

		// super.compileValue applies not result here:
                return super.compileValue( state, into );
            } else {
                ILabel l = TempFactory.nextLabel();
                ILabel m = TempFactory.nextLabel();
                
                int t = TempFactory.nextTemp();
                
		// compileBoolean applies not_result here:
                compileBoolean( state, into, l, true );
                into.add( makeStoreTemporary( t, 1,
                                              new ITree( line_number,
                                                         Op.CONST, 1, 0 )
                                              )
                          );
                into.add( new ITree( line_number, Op.JUMP, 0, m ) );
                into.add( new ITree( line_number, Op.LABEL, 0, l ) );
                into.add( makeStoreTemporary( t, 1,
                                              new ITree( line_number,
                                                         Op.CONST, 1, 1 )
                                              )
                          );
                into.add( new ITree( line_number, Op.LABEL, 0, m ) );
                
                return makeLoadTemporary( t, 1 );
            }
        }

        void compileBoolean( CompileState state, IBlock into, ILabel label, bool jump ) {
	    getType(state);

            ILabel l2;

	    if( not_result ) {
		// if operation was !~ (i.e. objects not equal) applied to non-object operands then
		// we will see operation == Op.EQ here with not_result set and need to reverse the sense
		// of the test:
		jump = !jump;
	    }


            if( operation == Op.BOOL_AND ) {
                if( jump ) {
                    l2 = TempFactory.nextLabel();
                    left.compileBoolean( state, into, l2, false );
                    right.compileBoolean( state, into, label, true );
                    
                    into.add( new ITree( line_number, Op.LABEL, 0, l2 ) );
                } else {
                    left.compileBoolean( state, into, label, false );
                    right.compileBoolean( state, into, label, false );
                }
            } else if( operation == Op.BOOL_OR ) {
                if( jump ) {
                    left.compileBoolean( state, into, label, true );
                    right.compileBoolean( state, into, label, true );
                } else {
                    l2 = TempFactory.nextLabel();
                    left.compileBoolean( state, into, l2, true );
                    right.compileBoolean( state, into, label, false );
                    into.add( new ITree( line_number, Op.LABEL, 0, l2 ) );
                }
            } else if( operation == Op.BOOL_NOT ) {
                left.compileBoolean( state, into, label, !jump );
            } else if( operation >= Op.EQ && operation <= Op.LE ) {
		int size;
		if( method_call != null ) {
		    size = method_type.RegSize;

		    int op;
		    if( operation == Op.EQ ) {
			if( jump ) {
			    op = Op.BRANCHNZ;
			} else {
			    op = Op.BRANCHZ;
			}

			into.add( new ITree( line_number, op, size,
					     method_call.compileValue( state, into ),
					     label ) );
			
		    } else {

			if( !reverse ) {
			    op = getReverseJumpOp( operation, jump );
			} else {
			    op = getJumpOp( operation, jump );
			}
			
			
			into.add( new ITree( line_number, Op.BRANCH, 0,
					     new ITree( line_number,
							op, size,
							method_call.compileValue( state, into ),
							new ITree( line_number, Op.CONST, size, 0 )
							),
					     label ) );
		    }
		    
		} else {	    
		    size = left.getType(state).RegSize;
		    ITree l = left.compileValue( state, into );
		    ITree r = right.compileValue( state, into );
		    into.add( new ITree( line_number, Op.BRANCH, 0,
					 new ITree( line_number,
						    getJumpOp( operation,jump ), size, l, r ), label )
			      );
		}
            }
        }
    }

    class Parenthesis extends Expression {
	Expression left;

	void init( int line_number, Expression left ) {
	    super.init(line_number);
	    this.left = left;
	}

	void clear( CompileState state ) {
	    super.clear( state );
	    left.clear( state );
	}

	void checkTemplates( CompileState state ) {
	    left.checkTemplates( state );
	}

        void qualifies( Expression left_value ) {
	    left.qualifies(left_value);
        }

        ITree compileValue( CompileState state, IBlock into, ILabel e, bool jump ) {
	    return left.compileValue(state, into, e, jump);
        }


        ITree compileValue( CompileState state, IBlock into ) {
	    return left.compileValue(state, into);
        }

        void compileDiscardValue( CompileState state, IBlock into ) {
	    left.compileDiscardValue(state, into);
        }


        bool isSuperConstructorCall( CompileState state ) {
	    return left.isSuperConstructorCall(state);
        }

        bool isThis( CompileState state ) {
	    return left.isThis(state);
        }

        bool isSuper( CompileState state ) {
	    return left.isSuper(state);
        }

        bool isLeftValue( CompileState state ) {
            return false;
        }

        bool isClass( CompileState state ) {
	    return left.isClass(state);
        }

	void calcType( CompileState state ) {
	    type = left.getType(state);
	}

        ITree compileAddress( CompileState state, IBlock into ) {
	    return left.compileAddress( state, into );
        }

        void markAddressTaken( CompileState state ) {
	    left.markAddressTaken( state );
        }

	void print( CompileState state, Printer p ) {
	    p.print( "(" );
	    if( p.expr_level == 0 ) {
		p.print( " " );
	    }
	    left.print( state, p );
	    if( p.expr_level == 0 ) {
		p.print( " " );
	    }
	    p.print( ")" );
	}
    }

    class Expression extends ParseTree {
        protected Type type;

	void clear( CompileState state ) {
	    type = null;
	}

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "check templates just calculates type: " + this.Class.Name );
	    // calcType( state );
	}

        void qualifies( Expression left_value ) {
            error( "cannot qualify this" );
        }

        ITree compileValue( CompileState state, IBlock into, ILabel e, bool jump ) {
            error( "not a boolean expression: " + this );
            return new ITree( line_number, Op.ERROR, 0 );
        }


        ITree compileValue( CompileState state, IBlock into ) {
            error( "this thing doesn't have a value\n" );
            return new ITree( line_number, Op.ERROR, 0 );
        }

        void compileDiscardValue( CompileState state, IBlock into ) {
            error( "oops: can't compile discard value" );           
        }


        bool isSuperConstructorCall( CompileState state ) {
            return false;
        }

        bool isThis( CompileState state ) {
            return false;
        }

        bool isSuper( CompileState state ) {
            return false;
        }

        bool isLeftValue( CompileState state ) {
            return false;
        }

        bool isClass( CompileState state ) {
            return false;
        }

	bool isIdentifier( CompileState state ) {
	    return false;
	}

	// does this expression resolve to an identifier that refers to a method?
	bool isMethod( CompileState state ) {
	    return false;
	}

	/*
	set bool WantProc = p {
	    // do nothing
	}

        get bool WantProc {
	    return false;
	}
	*/

        Type getType( CompileState state ) {
            if( type == null ) {
                calcType( state );
                if( type == null ) {
                    throw new Exception( "shouldn't happen: calcType() didn't assign this parse node a type" );
                    type = undefined_type;
                }
            }
	    type.markReferenced();

            return type;
        }

        void calcType( CompileState state ) {
            throw new Exception( "can't calcType for: " + this );
        }

        ITree compileAddress( CompileState state, IBlock into ) {
            throw new Exception( "expression has no address" );
            return new ITree( line_number, Op.ERROR, 0 );
        }

        void markAddressTaken( CompileState state ) {
        }

        void compileBoolean( CompileState state, IBlock into, ILabel label, bool jump ) {
            if( getType( state ).TypeKind != Type.BOOL ) {
                error( "not a boolean expression: " + this );
                return;
            }

            int op;
            if( jump ) {
                op = Op.BRANCHNZ;
            } else {
                op = Op.BRANCHZ;
            }

            into.add( new ITree( line_number, op, getType( state ).RegSize, compileValue( state, into ), label ) );
        }


        void init( int line_number ) {
            super.init( line_number );
            type = null;
        }

        ITree makeInstance( CompileState state, int line_number, IBlock into, int offset ) {
            return new ITree( line_number, Op.ADD, Machine.WORD,
                              makeLoadThis( state, line_number, into ),
                              new ITree( line_number, Op.CONST,
                                         Machine.WORD, offset )
                              );
        }

	ITree compileCall(
            CompileState state, 
	    IBlock into, 
	    ITree from, 
	    int o, 
	    Symbol symbol, 
	    String name, 
	    int offset, 
	    int pop_size, 
	    Util.IntVector inline_args )
	{
	    int t;

	    if( inline_args != null ) {
		if( symbol == null ) {
		    IO.Std.err.println( "cannot call inline method with no symbol: " + name );
		}

		Container method = cast<Container>(symbol);
		IBlock b = method.InlineBlock;

		if( b != null ) {
		    String s = "";
		    if( state.IsInline ) {
			s = " nested";
		    }

		    if( state.WantVeryVerbose ) {
			message( "about to inline: " + method.HumanName );
		    }
		    inline_call_count = inline_call_count + 1;

		    into.add( new ITree( line_number, Op.COMMENT, 0, "begin" + s + " inline method " + method.HumanName ) );
		    t = TempFactory.nextTemp();

		    int[] v = new int[inline_args.Length + 1];

		    int j = 0;
		    for( int i = inline_args.Length-1; i >= 0; i = i - 1 ) {
			v[j] = inline_args[i];
			j = j + 1;
		    }
		    v[j] = t;

		    b.duplicateForInline( into, line_number, v );


		    into.add( new ITree( line_number, Op.COMMENT, 0, "end" + s + " inline method " + method.HumanName ) );

		    return makeLoadTemporary( t, Machine.WORD );
		} else {
		    IO.Std.err.println( "cannot call inline with no intermediate code body: " + method.HumanName );
		    state.notLeaf();
		}
	    } else {
		// IO.Std.err.println( "would call not leaf here for call to: " + symbol.Owner.HumanName + "." + symbol.Name + "..." );
		/*
		if( state.IsInline ) {
		    IO.Std.err.println( "attempting to inline call to: " + symbol.Owner.HumanName + "." + symbol.Name + "..." );
		}
		*/
		state.notLeaf();
	    }

	    switch( o ) {
	    case Op.STATIC_CALL:
		t = TempFactory.nextTemp();
		into.add( new ITree( line_number, o, 0, new ITree( line_number, Op.TEMP, Machine.WORD, t ), name ) );
		addDummyExceptionHandlerJump( state, line_number, into );

		if( pop_size > 0 ) {
		    into.add( new ITree( line_number, Op.RELEASE, 0, pop_size ) );
		}
		return new ITree( line_number, Op.TEMP, Machine.WORD, t );

	    case Op.STATIC_CALL_DISCARD:
		into.add( new ITree( line_number, o, 0, name ) );
		addDummyExceptionHandlerJump( state, line_number, into );

		if( pop_size > 0 ) {
		    into.add( new ITree( line_number, Op.RELEASE, 0, pop_size ) );
		}
		return new ITree( line_number, Op.COMMENT, 0, "discard call result" );

	    case Op.DYNAMIC_CALL:
		t = TempFactory.nextTemp();
		into.add( new ITree( line_number, o, 0, new ITree( line_number, Op.TEMP, Machine.WORD, t ), offset ) );
		addDummyExceptionHandlerJump( state, line_number, into );

		if( pop_size > 0 ) {
		    into.add( new ITree( line_number, Op.RELEASE, 0, pop_size ) );
		}
		return new ITree( line_number, Op.TEMP, Machine.WORD, t );

	    case Op.DYNAMIC_CALL_DISCARD:
		into.add( new ITree( line_number, o, 0, offset ) );
		addDummyExceptionHandlerJump( state, line_number, into );

		if( pop_size > 0 ) {
		    into.add( new ITree( line_number, Op.RELEASE, 0, pop_size ) );
		}
		return new ITree( line_number, Op.COMMENT, 0, "discard call result" );;

	    case Op.PROC_CALL:
		t = TempFactory.nextTemp();
		into.add( new ITree( line_number, o, 0, from, new ITree( line_number, Op.TEMP, Machine.WORD, t ) ) );
		addDummyExceptionHandlerJump( state, line_number, into );

		if( pop_size > 0 ) {
		    into.add( new ITree( line_number, Op.RELEASE, 0, pop_size ) );
		}
		return new ITree( line_number, Op.TEMP, Machine.WORD, t );
		
	    case Op.PROC_CALL_DISCARD:
		into.add( new ITree( line_number, o, 0, from ) );
		addDummyExceptionHandlerJump( state, line_number, into );

		if( pop_size > 0 ) {
		    into.add( new ITree( line_number, Op.RELEASE, 0, pop_size ) );
		}
		return new ITree( line_number, Op.COMMENT, 0, "proc call result" );;
	    }
	}

	ITree compileLoadStaticProcRef( CompileState state, IBlock into, Symbol symbol ) {
	    var l = TempFactory.nextLabel();
	    into.add( new ITree( line_number, Op.RODATA, 0 ) );
	    into.add( new ITree( line_number, Op.LABEL, 0, l ) );
	    into.add( new ITree( line_number, Op.DEFINT, Machine.WORD, symbol.DecoratedName ) );
	    
	    into.add( new ITree( line_number, Op.TEXT, 0 ) );

	    return new ITree( line_number, Op.GLOBAL, Machine.WORD, l );
	}

        ITree compileLoad( CompileState state, IBlock into, Symbol symbol, ExpressionList arguments, Vector<Type> argument_types, ITree from, int size, int flags, Symbol super_class ) {
            String buffer;
            ITree t;
            int o, a, u;
    
            bool address = flags & LOAD_FLAG_ADDRESS != 0;
            bool no_discard = flags & LOAD_FLAG_DISCARD == 0;
            bool reference = flags & LOAD_FLAG_REFERENCE != 0;
	    bool proc_call = flags & LOAD_FLAG_PROC_CALL != 0;
	    Util.IntVector inline_args;
	    if( symbol != null ) {
		if( symbol.IsInline /* && state.InlineOK */ ) {
		    inline_args = new Util.IntVector();
		}
		
		if( symbol.Kind == Symbol.TYPE ) {
		    IO.Std.err.println( "attempting to load value of type symbol " + symbol + " here" );
		}
	    } else {
		if( !proc_call ) {
		    error( "oops: cannot load a null symbol" );
		    return new ITree( line_number, Op.ERROR, 0 );
		} 
	    }		
             
            if( from == null ) {
                switch ( symbol.Kind ) {
		    		   
                case Symbol.CLASS:
		    error( "cannot use class " + symbol.HumanName + " here" );
		    return new ITree( line_number, Op.ERROR, 0 );
		    /*
                    buffer = "vtable$__" + symbol.DecoratedName;
                    if( address ) {
                        throw new Exception( "oops: cannot load address of class " + symbol.QualifiedName );
                        return new ITree( line_number, Op.ERROR, 0 );
                    } else {
			IO.Std.err.println( "compiling class " + symbol.QualifiedName + " value here: " + new System.Backtrace() );
                        if( symbol.Owner != state.CurrentClass ) {
                            into.add( new ITree( line_number, Op.EXTERN, 0, buffer ) );
                        }
                        return new ITree( line_number, Op.GLOBAL, Machine.WORD, buffer );
			}*/
                    
                    
                case Symbol.STATIC_VARIABLE:
                    buffer = "stable$__" + symbol.Owner.DecoratedName;
                    
                    if( symbol.Owner != state.CurrentClass ) {
                        into.add( new ITree( line_number, Op.EXTERN, 0, buffer ) );
                    }
                    t = new ITree( line_number, Op.ADD, Machine.WORD,
                                   new ITree( line_number,
                                              Op.GLOBAL, Machine.WORD,
                                              buffer ),
                                   new ITree( line_number,
                                              Op.CONST, Machine.WORD,
                                              symbol.Address )
                                   );
                    
                    if( reference ) {
			// can't throw null pointer exception:
                        IO.Std.err.println( "loading static reference: " + symbol.HumanName );
			t = makeLoadIndirect( state, line_number, into, Machine.WORD, false, t );
                    }
                    
                    if( !address ) {
			/*
			if( !symbol.IsValueValid ) {
			    warn( "static variable " + symbol.HumanName + " may not be initialized here" );
			}
			*/
			// symbol.Owner.addDependant( state.CurrentClass );

			// can only throw null pointer exception if it's a reference:
			t = makeLoadIndirect( state, line_number, into, size, reference, t );
                    }

                    return t;
                    
                case Symbol.INSTANCE_VARIABLE:
                    if( flags & LOAD_FLAG_STATIC != 0 ) {
			error( "cannot access instance variable " + symbol.HumanName + " from static context" );
                        return new ITree( line_number, Op.ERROR, 0 );
                    } else {
                        t = makeInstance( state, line_number, into, symbol.Address );
                        
                        if( reference ) {
                            IO.Std.err.println( "loading instance reference: " + symbol.HumanName );
			    // could throw null pointer exception if this is null:
			    t = makeLoadIndirect( state, line_number, into, Machine.WORD, true, t );
                        }
                        
                        if( !address ) {
			    // could throw null pointer exception if this is null or if reference and reference is null:
			    t = makeLoadIndirect( state, line_number, into, size, true, t );
                        }
                        
                        return t;
                    }
                    
                    
                case Symbol.LOCAL_VARIABLE:
                    // fprintf( stderr, "local %s size %d offset %d\n", symbol.getName(), size, symbol.getAddress() );
                    int s = size;
                    if( reference ) {
                        s = size;
                    }

                    t = new ITree( line_number, Op.LOCAL, s, symbol.Address );
                    
                    if( reference ) {
			// can't throw null pointer exception:

			t = makeLoadIndirect( state, line_number, into, Machine.WORD, false, t );
                    }
                    
                    if( !address ) {
			// can only throw null pointer exception if is a reference:

			t = makeLoadIndirect( state, line_number, into, size, reference, t );
                    }
                    return t;
                    
                case Symbol.STATIC_METHOD:
		    if( reference ) {
			// IO.Std.err.println( "want proc reference to static method: " + symbol.HumanName );
			return compileLoadStaticProcRef( state, into, symbol );
		    }

                    if( symbol.Owner != state.CurrentClass ) {
                        into.add( new ITree( line_number, Op.EXTERN, 0, symbol.DecoratedName ) );
                    }

                    if( no_discard ) {
                        o = Op.STATIC_CALL;
                    } else {
                        o = Op.STATIC_CALL_DISCARD;
                    }

		    size = ExpressionList.compilePush( arguments, state, null, argument_types, into, false, false, inline_args );

		    return compileCall( state, into, null, o, symbol, symbol.DecoratedName, 0, size, inline_args );
                    
                case Symbol.INSTANCE_METHOD:
		    if( reference ) {
			IO.Std.err.println( "want proc reference to instance method: " + symbol.HumanName );
                        return new ITree( line_number, Op.ERROR, 0 );
		    }

                    if( flags & LOAD_FLAG_STATIC != null ) {
                        if( symbol == undefined_method ) {
                            IO.Std.err.println( "calling undefined method" );
                            return new ITree( line_number, Op.ERROR, 0 );
                        }
                        error( "cannot call instance method " + symbol.HumanName + " from static context" );
			/*
			IO.Std.err.println( "IIIIII: symbol is: " + symbol );
			IO.Std.err.println( "IIIIII: kind is:                " + symbol.Kind );
			IO.Std.err.println( "IIIIII: versus instance method: " + Symbol.INSTANCE_METHOD );
			IO.Std.err.println( "calling instance method statically: " + new System.Backtrace() );
			*/
                        return new ITree( line_number, Op.ERROR, 0 );
                    }
                    
                    if( super_class != null ) {
                        throw new Exception( "oops: calling method in super with no from address" );
                        return new ITree( line_number, Op.ERROR, 0 );
                    } else if( cast<Container>(symbol).IsFinal ) {
                        if( symbol.Owner != state.CurrentClass ) {
                            into.add( new ITree( line_number, Op.EXTERN, 0, symbol.DecoratedName ) );
                        }
                        // fprintf( stderr, "static call to final method: %X %s %s\n", symbol, symbol.getOwner().getQualifiedName(), symbol.getDecoratedName() );
                        if( no_discard ) {
                            o = Op.STATIC_CALL;
                        } else {
                            o = Op.STATIC_CALL_DISCARD;
                        }

			size = ExpressionList.compilePush( arguments, state, makeLoadThis(state, 0, into), argument_types, into, true, false, inline_args );

			return compileCall( state, into, null, o, symbol, symbol.DecoratedName, 0, size, inline_args );
                    }  else {
                        if( no_discard ) {
                            o = Op.DYNAMIC_CALL;
                        } else {
                            o = Op.DYNAMIC_CALL_DISCARD;
                        }

			size = ExpressionList.compilePush( arguments, state, makeLoadThis(state, 0,into), argument_types, into, true, false, null );

		        a = symbol.Address;
			// IO.Std.err.println( "dynamic call to non-final method " + symbol.getDecoratedName() + " at offset " + a );
			if( a / Machine.WORD * Machine.WORD != a ) {
			    throw new Exception( "vtable is not "+ Machine.WORD + "-byte aligned" );
			}

			return compileCall( state, into, null, o, symbol, null, symbol.Address, size, null );
                    }
                    
                default:
                    if( symbol.Kind == Symbol.CLASS ) {
                        error( "cannot use class " + symbol.HumanName + " here" );
                    } else if( symbol.Kind == Symbol.NAMESPACE ) {
                        error( "cannot use namespace " + symbol.HumanName + " here" );
                    } else if( symbol.Kind == Symbol.ENUM ) {
                        error( "cannot use enum " + symbol.HumanName + " here" );
                    } else {
                        error( "cannot use symbol " + symbol.HumanName + " here" );
                    }
                    return new ITree( line_number, Op.ERROR, 0 );
                }
            } else {                    // from is source and into is destination

		if( proc_call ) {
		    if( no_discard ) {
			o = Op.PROC_CALL;
		    } else {
			o = Op.PROC_CALL_DISCARD;
		    }
		    size = ExpressionList.compilePush( arguments, state, null, argument_types, into, false, false, null );

		    return compileCall( state, into, from, o, null, null, 0, size, null );
		} else
                switch ( symbol.Kind ) {
                case Symbol.STATIC_VARIABLE:
                    buffer = "stable$__" + symbol.Owner.DecoratedName;
                    if( symbol.Owner != state.CurrentClass ) {
                        into.add( new ITree( line_number, Op.EXTERN, 0, buffer ) );
                    }
                    t = new ITree( line_number, Op.ADD, Machine.WORD,
                                   new ITree( line_number,
                                              Op.GLOBAL, Machine.WORD,
                                              buffer ),
                                   new ITree( line_number,
                                              Op.CONST, Machine.WORD,
                                              symbol.Address )
                                   );
                    
                    if( reference ) {
			// can't throw null pointer exception:
			t = makeLoadIndirect( state, line_number, into, Machine.WORD, false, t );
                    }

                    if( !address ) {
			/*
			if( !symbol.IsValueValid ) {
			    warn( "static variable " + symbol.HumanName + " may not be initialized here" );
			}
			*/
			// symbol.Owner.addDependant( state.CurrentClass );

			// can only throw null pointer exception if reference:
			t = makeLoadIndirect( state, line_number, into, size, reference, t );
                    }
                    
                    return t;
                    
                case Symbol.INSTANCE_VARIABLE:
                    t = new ITree( line_number, Op.ADD, Machine.WORD,
                                   from,
                                   new ITree( line_number,
                                              Op.CONST, Machine.WORD,
                                              symbol.Address )
                                   );
                    
                    if( reference ) {
			// can throw null pointer exception:
			t = makeLoadIndirect( state, line_number, into, Machine.WORD, true, t );
                    }
                    
                    if( !address ) {
			// can throw null pointer exception:
			t = makeLoadIndirect( state, line_number, into, size, true, t );
                    }
                    return t;
                    
                case Symbol.LOCAL_VARIABLE:
                    throw new Exception( "oops: accessing local variable: '" + symbol.Name + "' from incorrect context" );
                    return new ITree( line_number, Op.ERROR, 0 );
                    
                case Symbol.STATIC_METHOD:
		    if( reference ) {
			// IO.Std.err.println( "want proc reference to static method: " + symbol.HumanName );
			return compileLoadStaticProcRef( state, into, symbol );
		    }

                    if( flags & LOAD_FLAG_STATIC != 0 || super_class != null ) {
                        if( symbol.Owner != state.CurrentClass ) {
                            into.add( new ITree( line_number, Op.EXTERN, 0, symbol.DecoratedName ) );
                        }
                        if( no_discard ) {
                            o = Op.STATIC_CALL;
                        } else {
                            o = Op.STATIC_CALL_DISCARD;
                        }

			size = ExpressionList.compilePush( arguments, state, null, argument_types, into, false, false, inline_args );

			return compileCall( state, into, null, o, symbol, symbol.DecoratedName, 0, size, inline_args );
                    }
                    
                    IO.Std.err.println( "calling static method " + symbol.HumanName + " dynamically" );
                    
                    // else fall through
                    throw new Exception( "need to fall through here" );
                    
                case Symbol.INSTANCE_METHOD:
		    if( reference ) {
			IO.Std.err.println( "want proc reference to instance method: " + symbol.HumanName );
                        return new ITree( line_number, Op.ERROR, 0 );
		    }

                    if( !address ) {
                        error( "using method " + symbol.HumanName + " but not calling it" );
			IO.Std.err.println( "here: " + new System.Backtrace() );
		    }
                    // source is object address
                    // into will whole call address
                    
                    // into now holds object address
                    
                    if( super_class != null ) {
                        if( symbol.Owner != state.CurrentClass ) {
                            into.add( new ITree( line_number, Op.EXTERN, 0, symbol.DecoratedName ) );
                        }
                        // call dynamic method statically
                        if( no_discard ) {
                            o = Op.STATIC_CALL;
                        } else {
                            o = Op.STATIC_CALL_DISCARD;
                        }

			size = ExpressionList.compilePush( arguments, state, from, argument_types, into, true, false, inline_args );

			return compileCall( state, into, null, o, symbol, symbol.DecoratedName, 0, size, inline_args );
                    } else if( cast<Container>(symbol).IsFinal ) {
                        if( symbol.Owner != state.CurrentClass ) {
                            into.add( new ITree( line_number, Op.EXTERN, 0, symbol.DecoratedName ) );
                        }
                        if( no_discard ) {
                            o = Op.STATIC_CALL;
                        } else {
                            o = Op.STATIC_CALL_DISCARD;
                        }

			size = ExpressionList.compilePush( arguments, state, from, argument_types, into, true, false, inline_args );

			return compileCall( state, into, null, o, symbol, symbol.DecoratedName, 0, size, inline_args );
                    } else {

		        a = symbol.Address;
			// IO.Std.err.println( "dynamic call to non-final method " + symbol.getDecoratedName() + " at offset " + a );
			if( a / Machine.WORD * Machine.WORD != a ) {
			    throw new Exception( "vtable is not " + Machine.WORD + "-byte aligned" );
			}

                        if( no_discard ) {
                            o = Op.DYNAMIC_CALL;
                        } else {
                            o = Op.DYNAMIC_CALL_DISCARD;
                        }
			size = ExpressionList.compilePush( arguments, state, from, argument_types, into, true, false, null );

			return compileCall( state, into, null, o, symbol, null, symbol.Address, size, null );
                    }
                    break;
                    
                default:
                    if( symbol.Kind == Symbol.CLASS ) {
                        error( "cannot use class " + symbol.HumanName + " here" );
                    } else if( symbol.Kind == Symbol.NAMESPACE ) {
                        error( "cannot use namespace " + symbol.HumanName + " here" );
                    } else if( symbol.Kind == Symbol.ENUM ) {
                        error( "cannot use enum " + symbol.HumanName + " here" );
                    } else {
                        error( "cannot use symbol " + symbol.HumanName + " here" );
                    }
                    return new ITree( line_number, Op.ERROR, 0 );
                }
            }
        }

	get int Depth {
	    return 0;
	}

	get int Operation {
	    return Op.ERROR;
	}
    }

    class ExpressionList extends Expression {
        Vector<Expression> list;

        void init( int line_number ) {
            super.init( line_number );
            list = new Vector<Expression>();
        }

	void init( int line_number, Expression first ) {
	    init( line_number );
	    add( first );
	}

	void clear( CompileState state ) {
            foreach( Expression e; list.elements() ) {
		e.clear( state );
            }
	}

	void checkTemplates( CompileState state ){
            foreach( Expression e; list.elements() ) {
		e.checkTemplates( state );
            }
	}

        void calcType( CompileState state ) {
        }
        
        void declareSymbols( CompileState state ) {
        }
        
        void add( Expression next ) {
            list.add( next );
        }

        Vector<Type> getTypes( CompileState state ) {
            var result = new Vector<Type>( list.Length );
            foreach( Expression e; list.elements() ) {
                result.add( e.getType(state) );
            }
            return result;
        }

        get Vector<Expression> List {
            return list;
        }

	Expression opGet( int index ) {
	    return list[index];
	}

	void opSet( int index, Expression e ) {
	    list[index] = e;
	}

        void dump( CompileState state, StringBuffer buffer ) {
            for( var i = list.elements(); i.hasMoreElements(); ) {
                Expression e = i.nextElement();
                e.dump( state, buffer );
                
                if( i.hasMoreElements() ) {
                    buffer.append( ',' );
                }
	    }
        }

	static int compilePush(
            ExpressionList l, 
	    CompileState state,
	    ITree thiz,
	    Vector<Type> arg_types,
	    IBlock into,
	    bool skip_this,
	    bool native_call,
	    Util.IntVector inline_args )
	{
	    if( l == null ) {
		l = new ExpressionList( 0 );
	    }

	    int size = l.compilePush( state, thiz, arg_types, into, skip_this, native_call, inline_args );
	    /*
	    if( size > Machine.NUM_REG_PARAM ) {
		throw new Exception( "need to adjust stack to remove pushed arguments" );
	    }
	    */

	    return size;
	}

        int compilePush(
            CompileState state,
	    ITree thiz,
	    Vector<Type> arg_types,
	    IBlock into,
	    bool skip_this,
	    bool native_call,
	    Util.IntVector inline_args
	) {
	    // IO.Std.err.println( "AAAAAA: compilePush: " + this );
            int size = 0;
            ITree result;
	    ITree param = null; 
	    ITree r = null;
            int s;
	    int temp;
	    int thiz_temp;

	    int num_reg_param;

	    if( native_call ) {
		num_reg_param = Machine.NUM_REG_PARAM_NATIVE;
	    } else {
		num_reg_param = Machine.NUM_REG_PARAM;
	    }

	    bool seen_any_params = false;

	    int n = list.Length;

	    if( skip_this ) {
		n = n + 1;
	    }
	    bool simple;
	    // IO.Std.err.println( "pushing " + n + " arguments: " + arg_types  );

	    if( thiz != null && (!thiz.isPrettySimple() || inline_args != null) ) {
		thiz_temp = TempFactory.nextTemp();
		into.add( new ITree( 0, Op.COPY, Machine.WORD,
				  new ITree( 0, Op.TEMP, Machine.WORD, thiz_temp ),
				     thiz ) );

		thiz = new ITree( 0, Op.TEMP, Machine.WORD, thiz_temp );
		/*
		  if( inline_args != null ) {
		    IO.Std.err.println( "inline call: this T" + thiz_temp );
		}
		*/
	    }

	    Generic.Iterator<Type> j = null;

            if( arg_types != null ) {
		// IO.Std.err.println( "have argument types: support reference parameters" );
                j = arg_types.reverseElements();
	    }

	    foreach( Expression e; list.reverseElements() ) {
		Type t = null;

		if( j != null ) {
		    t = cast<Type>(j.nextElement());
		}

		if( t != null && t.TypeKind == Type.REFERENCE ) {
		    // IO.Std.err.println( "compile reference parameter: " + e );
		    result = e.compileAddress( state, into );
		    e.markAddressTaken( state );
		    
		    simple = result.isPrettySimple();
		} else {
		    // IO.Std.err.println( "compile value parameter: " + e + " type " + e.getType(state) );

		    s = e.getType(state).RegSize;
		    result = e.compileValue( state, into );
		    
		    simple = result.isPrettySimple();
                    
		    /*
		      if( s == 1 ) {
		      result = new ITree( line_number, Op.CAST_FROM1, 8, result );
		      } else if( s == 4 ) {
		      result = new ITree( line_number, Op.CAST_FROM4, 8, result );
		      }
		    */
		}
		
		// IO.Std.err.println( "register weight: " + result.getWeight() + "\n" + result );
		
		if( n > num_reg_param ) {
		    if( inline_args != null ) {
			throw new Exception( "cannot inline call with stack arguments" );
		    }
		    // IO.Std.err.println( "compiling stack parameter" );
		    into.add( new ITree( line_number, Op.PUSH, Machine.WORD, result ) );
		    size = size + Machine.WORD;		    
		} else {
		    
		    // IO.Std.err.println( "compiling register parameter #" + (n-1) );
		    // copy argument into appropriate register
		    
		    if( !simple || inline_args != null ) {
			temp = TempFactory.nextTemp();
			
			// IO.Std.err.println( "allocated T" + temp + " for register parameter" );
			
      			into.add( new ITree( line_number, Op.COPY, Machine.WORD,
					     new ITree( line_number, Op.TEMP, Machine.WORD, temp ),
					     result ) );
			result = new ITree( line_number, Op.TEMP, Machine.WORD, temp );
		    }
		    
		    
		    /* into.add( result );
		       
		       param.add( new ITree( line_number, Op.ARG0 + (n - 1) * 8, 8,
		       new ITree( line_number, Op.TEMP, 8, temp ) ) );
		    */

		    if( inline_args != null ) {
			inline_args.add(temp);
			// IO.Std.err.println( "inline call: arg T" + temp );
		    } else if( param == null ) {
		        param = new ITree( line_number, Op.ARG0 + (n - 1) * 8, Machine.WORD, result, null ); 
			r = param;
		    } else {
			r.Right = new ITree( line_number, Op.ARG0 + (n - 1) * 8, Machine.WORD, result, null );
			r = r.Right;
		    }
		}
		
		n = n - 1;
	    }

	    if( inline_args == null ) {
		if( thiz != null ) {
		    if( param == null ) {
			param = new ITree( 0, Op.ARG0, Machine.WORD, thiz, null );
			r = param;
		    } else {
			r.Right = new ITree( 0, Op.ARG0, Machine.WORD, thiz, null );
			r = r.Right;
		    } 
		}

		if( param != null ) {
		    r.Right = new ITree( line_number, Op.COMMENT, 0, "last arg" );
		    
		    // IO.Std.err.println( "AAAAAA: call args param tree: " + param );
		    
		    into.add( param );
		}
		//} else {
		// IO.Std.err.println( "inline args: " + inline_args );
	    } else if( thiz != null ) {
		inline_args.add( thiz_temp );
	    }
	    // IO.Std.err.println( "pushed " + size + " bytes of parameters" );

	    if( Machine.CALLEE_POPS_ARGUMENTS && !native_call) {
		// FIXME: assuming native functions never remove arguments from stack on return:
		return 0;
	    } else {
		return size;
	    }
        }

	get int Depth {
	    int result = 0;
            foreach( Expression e; list.elements() ) {
		int d = e.Depth;
		if( d > result ) {
		    result = d;
		}
	    }

	    return result + 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    bool seen_any;
	    bool multi_line = false;
	    if( list.Length > 4 ) {
		multi_line = true;
		p.OneLine = false;
		p.indent();
		p.nl();
	    }

            foreach( Expression e; list.elements() ) {
		if( seen_any ) {
		    p.print( ", " );
		    if( multi_line ) {
			p.println();
		    }
		}

		e.print( state, p );

		seen_any = true;
	    }

	    if( multi_line ) {
		p.outdent();
		p.nl();
	    }
	}
    }

    class LeftValue extends Expression {
        void init( int line_number ) {
            super.init( line_number );
        }

        bool isLeftValue( CompileState state ) {
            return true;
        }
    }

}