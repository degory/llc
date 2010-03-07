
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;
    use Generic.List;

    use Gen.IRBlock;
    use Gen.Machine;

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
	    // IO.Std.err.println( "VectorList calcType in pass #" + cast int(state.Pass) );
	    // IO.Std.err.println( "list is: " + this );
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
		    if( t.isScalar() ) {
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

	void clear( CompileState state ) {
	    super.clear( state );
            foreach( Expression f; list.List.elements() ) {
		f.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
	    if( element_type != null ) {
		new VectorType( line_number, element_type ).checkTemplates( state );
	    }

            foreach( Expression f; list.List.elements() ) {
		f.checkTemplates( state );
	    }
	}

        LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    var t = getType(state);
            var l = list.List;

	    var a = makeAllocateArray(
				      state,
				      into,
				      getType(state),
				      LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),cast long(l.Length),0)
				      );

	    int i = 0;
	    foreach( Expression e; l.elements() ) {
		// Type tp = e.getType(state);

		var p = makeGetArrayDataPointer(
						state,
						line_number,
						into,
						a,
						LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),cast long(i),0)
						);
		
		addStoreIndirect( state, line_number, into, false, // FIXME: could be null but don't want null check on every element
				  p,
				  e.compileValue( state, into )
				  );

		i = i + 1;
	    }

	    return a;
	}
        
	get int Depth {
	    int result = 0;
	    return list.Depth + 1;
	}

	String toString() {
	    return "{" + list + "}";
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


    class IsA extends Expression {
	TypeExpr left;
	Expression right;
	bool requires_runtime_check;
	bool fixed_result;

        void init( int line_number, TypeExpr left, Expression right ) {
            super.init( line_number );
            this.left = left;
            this.right = right;
        }

        void calcType( CompileState state ) {
	    IO.Std.err.FlushOnPrintln = true;
	    type = new Type(Type.BOOL);

            Type t = left.parseType( state );
            Type from = right.getType(state);
	    bool cannot_check = false;
	    
            if( t.isAssignableFrom( from ) ) {
		warn( "isa " + t + " always evaluates to true here" );
		requires_runtime_check = false;
		fixed_result = true;
	    } else {
		if( t.TypeKind != Type.CLASS ) {
		    var u = t.getBoxType(state);
		    if( u != null ) {
			t = u;
		    }
		}

                int k = t.TypeKind;

		if( k == Type.CLASS ) {
		    if( t.isObject() || t.isInterface() ) {
			requires_runtime_check = true;
			if( !from.isObject() && !from.isInterface() ) {
			    if( state.WantMarkUnsafe ) {
				state.markCodeUnsafe( CompileState.UNSAFE_CAST );
			    }
			    if( state.WantWarnUnsafe ) {
				warn( "testing if type is " + t + " is unsafe (because " + from + " is not a trusted reference)" );
			    }
			}
		    } else {
			cannot_check = true;
		    }
		} else if( k == Type.POINTER ) {
		    cannot_check = true;
		}

		if( cannot_check ) {
		    requires_runtime_check = false;
		    fixed_result = false;
		    warn( "cannot test if type is " + t + " at runtime, isa will always return false" );
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

        LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    // IO.Std.err.println( "compile IsA: " + type );
            Type r = right.getType( state );
            
	    // IO.Std.err.println( "type r: " + r );

            if( requires_runtime_check ) {
		// IO.Std.err.println( "requires check" );
		var t = left.parseType(state);
		// IO.Std.err.println( "type t: " + t );
	       
		LLVM.Value v = makeLLVMCast( right.compileValue(state, into), t.getLLVMType(state), into );
		// IO.Std.err.println( "value v" );
		// LLVM.Calls.LLVMDumpValue( v );

		if( t.isObject() ) {
		    // IO.Std.err.println( "is object..." );
		    return makeObjectCastCheck(state, into, v, t.Clazz, false ); // makeLoadVTable(state, t.Clazz));
		} else if( t.isInterface() ) {
		    // IO.Std.err.println( "is interface..." );
		    return makeInterfaceCastCheck(state, into, v, t.Clazz, false ); // .getImplementsFunction(state) );
		} else {
		    // IO.Std.err.println( "is something odd: " + t );
		    error( "cannot test type of " + left + " at runtime" );
		    return ErrorValue();
		}
	    } else {
		// IO.Std.err.println( "no check" );
		long b = 0L;
		if( fixed_result ) {
		    b = 1L;
		}

		return
		    LLVM.Calls.LLVMConstInt(
					    LLVM.Calls.LLVMInt1Type(),
					    b,
					    0
					    );
            }
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
		    if( type.isObject() || type.isInterface() ) {
			requires_runtime_check = true;
			if( !from.isObject() && !from.isInterface() ) {
			    if( state.WantMarkUnsafe ) {
				state.markCodeUnsafe( CompileState.UNSAFE_CAST );
			    }
			    if( state.WantWarnUnsafe ) {
				warn( "cast from " + from.dump() + " to " + type.dump() + " is unsafe" );
			    }
			}
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


        LLVM.Value compileValue( CompileState state, IRBlock into ) {
            Type r = right.getType( state );
            
            if( requires_runtime_check ) {
		var t = getType(state);
		
		LLVM.Value v = makeLLVMCast( right.compileValue(state, into), t.getLLVMType(state), into );

		if( t.isObject() ) {
		    makeObjectCastCheck(state, into, v, t.Clazz, true ); // makeLoadVTable(state, t.Clazz));
		} else if( t.isInterface() ) {
		    makeInterfaceCastCheck(state, into, v, t.Clazz, true ); // .getImplementsFunction(state) );
		}

		return v;
	    } else {
		return makeLLVMCast( right.compileValue(state, into), getType(state).getLLVMType(state), into );
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
	bool indirect;
	LLVM.Value temporary;

        void init( int line_number, Type type, LLVM.Value temporary, bool indirect ) {
            super.init( line_number );
            this.type = type;
            this.temporary = temporary;
	    this.indirect = indirect;
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

        LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    if( indirect ) {
		return into.Load( temporary );
	    } else {
		return temporary;
	    }
        }
    }

    /// This
    class This extends Expression {
        void init( int line_number ) {
            super.init( line_number );
        }

	LLVM.Value compileValue( CompileState state, IRBlock into ) {
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
		var r = type.getBoxType(state);
		if( r != null ) {
		    type = r;
		}
	    }

            if( type.TypeKind != Type.CLASS ) {
                error( "cannot apply class<> to " + type + " which is not a class" );
		type = undefined_type;
            } else {
		c = type.Clazz;
		type = class_type;
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

	get int Depth {
	    return 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "class<" );
	    left.print( state, p );
	    p.print( ">" );
	}

	LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    if( c != null && type != undefined_type ) {
		return c.getClassGlobal(state);
	    } else {
		return ErrorValue();
	    }
	}
    }


    /// Super
    class Super extends Expression {
        void init( int line_number ) {
            super.init( line_number );
        }

	LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    return makeLoadThis( state, line_number, into );
	}

        void calcType( CompileState state ) {
            if( state.CurrentClass == null ) {
                error( "cannot access super outside of any class" );
                type = undefined_type;
            } else {
                Container c = state.CurrentClass.Super;
                if( c == null ) {
                    error( "class " + state.CurrentClass.HumanName + " doesn't have a super class" );
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
		} else if( (l < 2 || (value[1] != 'x' && value[1] != 'X')) && (last == 'c' || last == 'C') ) {
		    value = value.substring( 0, value.Length-1 );
		    this.type = new Type( Type.CHAR );
		} else {
		    // IO.Std.err.println( "regular int literal" );
		    this.type = new Type( type );
		}
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
            } else if( Type.isScalar(type) && value.Length > 2 && (value[1] == 'x' || value[1] == 'X') ) {
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

	LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    LLVM.Value v;
	    LLVM.Value g;
	    LLVM.Value[] elements;
	    if( type == string_type ) {
		// IO.Std.err.println( "const string" ); IO.Std.err.flush();
		elements = {
		    makeLoadVTable( state, type.Clazz ),
		    makeCStringConstant( state, value ),
		    LLVM.Calls.LLVMConstInt(
					    LLVM.Calls.LLVMInt32Type(),
					    cast long(value.Length),
					    0
					    )

		};

		v = LLVM.Calls.LLVMConstStruct(
						  elements.address,
						  elements.length,
						  0
						  );
		/*
		IO.Std.err.print( "const System.String:  " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( v );
		*/
		g = LLVM.Calls.LLVMAddGlobal( state.Module, LLVM.Calls.LLVMTypeOf(v), ("__string_" + string_number).toCString() );
		LLVM.Calls.LLVMSetLinkage(g, LLVM.LLVMLinkage.LLVMPrivateLinkage );
		LLVM.Calls.LLVMSetGlobalConstant(g, 1);

		string_number = string_number + 1;
		LLVM.Calls.LLVMSetInitializer( g, v );

		// IO.Std.err.println( "returning global var" );
		return g; 

		/*

		
		IO.Std.err.print( "global System.String: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( g );

		return LLVM.Calls.LLVMConstInBoundsGEP(
						       g,
						       elements.address,
						       2
						       );
		*/
	    } else if( type.TypeKind == Type.POINTER
                       && type.SubType.TypeKind == Type.CHAR ) {
	       
		return makeCStringConstant( state, value );

	    } else if( type.TypeKind == type.NONE || type.TypeKind == type.NULL ) {
		return LLVM.Calls.LLVMConstPointerNull(LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type(),0));
	    } else if( type.TypeKind == type.POINTER ) {
		if( !value.equals("0") ) {
		    IO.Std.err.println( "oops: non-null pointer constant: '" + value + "'" );
		}
		return LLVM.Calls.LLVMConstPointerNull(type.getLLVMType(state));
	    } else {
		return LLVM.Calls.LLVMConstIntOfString(
						       type.getLLVMType(state),
						       value.toCString(),
						       10C
						       );
	    }

	    IO.Std.err.println( "returning nothing" );

	}

	int getIntValue( CompileState state ) {
	    if( type.TypeKind != Type.INTEGER ) {
		return 0;
	    }

	    return value.parseInt();
	}

        String toString() {
            return print_value;
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
	    method_call = null;
	}

	get int Operation {
	    return operation;
	}

	void calcTypeBuiltIn( CompileState state, Type tl, Type tr, bool equals, bool comparison ) {
	    bool warn_pointer = false;
	    bool il = tl.isScalar();
	    bool pl = tl.isPointer();
            if( right != null ) {
		bool ir = tr.isScalar();
		bool pr = tr.isPointer();
				
		if( operation == Op.ADD ) {
		    if( il && ir ) {
			// add two integers, types must match:
			if( tl.equals(tr) ) {
			    type = tl;
			} else {
			    error( "scalar type mismatch " + tl + " + " + tr );
			    type = undefined_type;
			}
		    } if( pl && ir ) {
			// add integer to pointer:
			warn_pointer = true;
			type = tl;
		    } else if( il && pr ) {
			// add pointer to integer:
			warn_pointer = true;
			type = tr;
		    }	    
		} else if( operation == Op.SUB ) {
		    if( il && ir ) {
			// subtract integers, types must match:
			if( tl.equals(tr) ) {
			    type = tl;
			} else {
			    error( "scalar type mismatch " + tl + " - " + tr );
			    type = undefined_type;
			}
		    } else if( pl && ir ) {
			type = tl;
			warn_pointer = true;
		    } else if( pl && pr ) {
			if( tl.equals(tr) ) {
			    warn_pointer = true;
			    type = new Type(Type.WORD);
			} else {
			    error( "pointer type mismatch " + tl + " - " + tr );
			    type = undefined_type;
			}
		    } 
		} else if( comparison ) {
		    if( il && ir || (tl.isEnum() && tr.isEnum()) || (equals && tl.isBool() && tr.isBool()) ) {
			if( tl.equals(tr) ) {
			    type = new Type(Type.BOOL);
			} else {
			    error( "scalar type mismatch " + tl + " " + OpString + " " + tr );
			    type = undefined_type;
			}

		    } else if( pl || pr ) {
			if( pl && pr ) {
			    if( tl.equals(tr) ) {
				type = new Type(Type.BOOL);
			    } else {
				error( "pointer type mismatch " + tl + " " + OpString + " " + tr );
				type = undefined_type;
			    }
			} else {
			    if( tl.isNull() || tr.isNull() ) {
				type = new Type(Type.BOOL);
			    }
			}
		    } else if( equals && !object_equals ) {
			if( tl.equals(tr) ) {
			    type = new Type(Type.BOOL);
			} else if( tl.isAssignableFrom(tr) || tr.isAssignableFrom(tl) ) {
			    type = new Type(Type.BOOL);
			} else if( !object_equals) {  
			    error( "type mismatch " + tl + " " + OpString + " " + tr );
			}			
		    }
		} else if( (operation >= Op.MUL && operation <= Op.SHAR) ||
			   (operation >= Op.AND && operation <= Op.XOR)) {
		    if( il && ir ) {
			if( tl.equals(tr) ) {
			    type = tl;
			} else {
			    error( "scalar type mismatch " + tl + " " + OpString + " " + tr );
			    type = undefined_type;
			}
		    } else if( pl && pr ) {
			error( "illegal operation on pointers " + tl + " " + OpString + " " + tr );
			type = undefined_type;
		    } else if( operation >= Op.AND && operation <= Op.XOR &&
			       tl.isBool() && tr.isBool() ) {
			type = tl;
		    }
		} else if( operation >= Op.BOOL_OR && operation <= Op.BOOL_AND ) {
		    if( tl.isBool() && tr.isBool() ) {
			type = tl;
		    }
		}

		if( warn_pointer ) {
		    if( state.WantMarkUnsafe ) {
			state.markCodeUnsafe( CompileState.UNSAFE_POINTER );
		    }
                    if( state.WantWarnUnsafe ) {
                        warn( "pointer arithmetic" );
                    }
		}
            } else {
                type = tl;
            }
	}

	void calcTypeOperatorOverload( CompileState state, Type tl, Type tr, bool equals, bool comparison ) {
	    // need at least one object operand for operator method and either explicit object-equals operator or 
	    // an inequality or an arithmetic operator
	    
	    // note: no need to bother calling opEquals for =~ or !~ when at least one operand is literal null because
	    // the result can be determined directly by comparing the operands' addresses
	    
	    // look for an operator method if:
	    // operator is not equal or operator is object equals and neither operand is literal null AND
	    // at least one operand is an object:
	    
	    if( !equals || object_equals ) {

		/* && (tl.TypeKind != Type.NONE && tr.TypeKind != Type.NONE))
		     ) &&
		    (tl.TypeKind == Type.CLASS || tr.TypeKind == Type.CLASS) ) {
		*/
		MethodCall call_normal, call_reverse;
		// IO.Std.err.println( "operator overload call: " + tl + " op " + tr );
		Quality quality_normal, quality_reverse;
		Type type_normal, type_reverse;
		
		reverse = false;
		
		String op_string = null; // for error reporting
		String n;                // operator method name
		
		do {
		    // IO.Std.err.println( "at start reverse now: " + reverse );
		    // IO.Std.err.println( "searching " + tl + " operator " + tr + "..." );
		    
		    // loop at most twice, once for forward operation and once for reverse
		    
		    /*
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
		    */
		    
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
			
		    case Op.LT:
			op_string = "<";
			n = "opCompare";
			inequality = true;
			
		    case Op.GE:
			op_string = ">=";
			n = "opCompare";
			inequality = true;
			
		    case Op.LE:
			op_string = "<=";
			n = "opCompare";
			inequality = true;

		    case Op.RANGE:
			op_string = "..";
			n = "opRange";
			
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
			
			// IO.Std.err.println( "break..." );
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
			// IO.Std.err.println( "call normal: " + method_call );
		    } else {
			method_call = call_reverse;
			type = type_reverse;
			// IO.Std.err.println( "call reverse: " + method_call );
		    }
		}

		
		// IO.Std.err.println( "method call now: " + method_call );
		
		if( method_call == call_reverse && state.WantWarnResolve ) {
		    warn( "using reverse operator method '" + n + "' for " + tl + " " + op_string + " " + tr );
		}
	    }
	}

        void calcType( CompileState state ) {
	    bool comparison = operation >= Op.EQ && operation <= Op.LE;
	    bool equals = operation == Op.EQ || operation == Op.NE;

            Type tl = left.getType( state );
	    Type tr;
	    // IO.Std.err.println( "arith calc type op: " + operation );
	    // IO.Std.err.println( "object equals: " + object_equals );

            if( right != null ) {
		tr = right.getType( state );
	    }

	    calcTypeBuiltIn( state, tl, tr, equals, comparison );

	    if( type == null ) {
		// IO.Std.err.println( "no built in operation matched " + tl + " " + OpString + " " + tr + ", try operator methods..." );
		calcTypeOperatorOverload( state, tl, tr, equals, comparison );
	    }

	    if( type == null ) {
		// shouldn't happen - should be undefined_type if nothing found:
		if( tr != null ) {
		    error( "no built in operation or operator method found for " + tl + " " + OpString + " " + tr );
		} else {
		    error( "no built in operation or operator method found for " + OpString + "" + tl );
		}

		type = undefined_type;
            }

	    // IO.Std.err.println( "method call: " + method_call );
	    // IO.Std.err.println( "type: " + type );
        }

        void declareSymbols( CompileState  state ) {
        }


	void checkTemplates( CompileState state ) {
	    if( left != null ) {
		left.checkTemplates( state );
	    }

	    if( right != null ) {
		right.checkTemplates( state );
	    }
	}

        LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    int op = operation;
	    LLVM.Value t;

	    LLVM.Value cl;
	    LLVM.Value cr;

	    if( type == undefined_type ) {
		return ErrorValue();
	    }

	    // IO.Std.err.println( "ArithExpression.compileValue: " + this );
            if( method_call != null ) {
		// IO.Std.err.println( "compiling ArithExpression method call: " + method_call );

		t = method_call.compileValue( state, into );

		if( not_result ) {
		    return into.Not( t );
		} else if( inequality ) {
		    if( reverse ) {
			op = getReverseJumpOp( op, true );
		    }
		    
		    return makeComparison( op, t, LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 ), into );
		} else {
		    return t;
		}
            } else if( right != null ) {
                bool comparison = operation >= Op.EQ && operation <= Op.LE;
		
                cl = left.compileValue( state, into );
                cr = right.compileValue( state, into );
                
                getType( state );
                
                Type tl = left.getType( state );
                Type tr = right.getType( state );
		
                bool pl = tl.TypeKind == Type.POINTER;
                bool pr = tr.TypeKind == Type.POINTER;

		if( (pl || pr) && !comparison ) {
		    // IO.Std.err.println( "left: " + tl );
		    // IO.Std.err.println( "right: " + tr );
		    // IO.Std.err.println( "pointer expression, type: " + type + ", size: " + type.getRegSize() );
		    
		    if( op == Op.SUB ) {
			if( pl && pr ) {
			    return into.Sub( cl, cr );
			} else if( pr ) {
			    error( "cannot subtract pointer from non-pointer" );
			    return ErrorValue();
			} else {
			    cr = into.Neg(cr);
			    op = Op.ADD;
			}
		    }
			
		    if( op == Op.ADD ) {
			if( pr ) {
			    if( pl ) {
				error( "pointer addition: only one operand can be a pointer" );
				return ErrorValue();
			    }
			    			    
			    t = cr;
			    cr = cl;
			    cl = t;
			}

			/*
			IO.Std.err.println( "pointer add: " + Op.getOpName(op) );
			IO.Std.err.print( "left:  " ); IO.Std.err.flush();
			LLVM.Calls.LLVMDumpValue( cl );
			IO.Std.err.print( "type:  " ); IO.Std.err.flush();
			LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(cl) );
			
			IO.Std.err.print( "right:  " ); IO.Std.err.flush();
			LLVM.Calls.LLVMDumpValue( cr );
			IO.Std.err.print( "type:  " ); IO.Std.err.flush();
			LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(cr) );
			*/

			return into.GEP( cl, { cr } );
		    } else {
			error( "illegal operation on pointer" );
		    }
		    /*
		      } else if( !pl && !pr && tl.RegSize != tr.RegSize ) {
		      // IO.Std.err.println( "left: " + tl.getRegSize() + ", " + left );
		      // IO.Std.err.println( "right: " + tr.getRegSize() + ", " + right );
		      
		      error( "oops: arithmetic operands are different register sizes" );
		    */
                }
				

		if( comparison ) {
		    t = makeComparison( op, cl, cr, into );

		    if( not_result ) {
			t = into.Not( t );
		    }
		    return t;
		}

		/*
		IO.Std.err.println( "arith operator " + Op.getOpName(op) );
		IO.Std.err.print( "left:  " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( cl );
		IO.Std.err.print( "type:  " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(cl) );
		
		IO.Std.err.print( "right:  " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( cr );
		IO.Std.err.print( "type:  " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(cr) );
		*/

		switch( op ) {
		case Op.ADD:
		    return into.Add( cl, cr );
		    
		case Op.SUB:
		    return into.Sub( cl, cr );
		    
		case Op.MUL:
		    return into.Mul( cl, cr );
		    
		case Op.DIV:
		    return into.SDiv( cl, cr );
		    
		case Op.MOD:
		    // IO.Std.err.println( "FIXME: does URem = modulo?" );
		    return into.SRem( cl, cr );
		    
		case Op.SHL:
		    return into.Shl( cl, cr );
		    
		case Op.SHAR:
		    return into.AShr( cl, cr );
		    
		case Op.EQ:
		    t = into.ICmp( LLVM.LLVMIntPredicate.LLVMIntEQ, cl, cr );
		    if( not_result ) {
			t = into.Not( t );
		    }
		    return t;
		    
		case Op.NE:
		    t = into.ICmp( LLVM.LLVMIntPredicate.LLVMIntNE, cl, cr );
		    if( not_result ) {
			t = into.Not( t );
		    }
		    return t;
		    
		case Op.GT:
		    return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntSGT, cl, cr );
		    
		case Op.LT:
		    return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntSLT, cl, cr );
		    
		case Op.GE:
		    return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntSGE, cl, cr );
		    
		case Op.LE:
		    return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntSLE, cl, cr );
		    
		case Op.GTU:
		    return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntUGT, cl, cr );
		    
		case Op.LTU:
		    return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntULT, cl, cr );
		    
		case Op.GEU:
		    return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntUGE, cl, cr );
		    
		case Op.LEU:
		    return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntULE, cl, cr );
		    
		case Op.AND:
		    return into.And( cl, cr );
		    
		case Op.OR:
		    return into.Or( cl, cr );
		    
		case Op.XOR:
		    return into.Xor( cl, cr );
		    
		default:
		    throw new System.NotImplementedException( "unsupported binary operator: " + cast int(op) );
		}
		
		
	    } else {
                cl = left.compileValue( state, into );

		switch( op ) {
		case Op.NOT:
		    return into.Not( cl );
		    
		case Op.NEG:
		    return into.Neg( cl );
		    
		default:
		    throw new System.NotImplementedException( "unsupported unary operator: " + cast int(op) );
		}
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

        LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    getType(state);

	    if( type == undefined_type ) {
		return ErrorValue();
	    }

	    if( method_call != null || ( operation >= Op.EQ && operation <= Op.LE) ) {
		// Std.err.println( "boolean expression compile value operation overload method: " + method_call );

		// super.compileValue applies not result here:
                return super.compileValue( state, into );
            } else {
                LLVM.BasicBlock t = into.Block();
                LLVM.BasicBlock f = into.Block();
                LLVM.BasicBlock e = into.Block();
		// compileBoolean applies not_result here:
                compileBoolean( state, into, t, true );
		into.Label(f);

		// in block f:
		LLVM.Value value_false = LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),0L,0);
	
		into.JumpLabel(e,t);

		// in block t:
		LLVM.Value value_true = LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),1L,0);

		into.Label(e);

		LLVM.Value v = into.Phi(LLVM.Calls.LLVMInt1Type());

		into.AddIncoming(
				 v,
				 {value_false, value_true},
				 {f, t}
				 );

		return v;
            }
        }

        void compileBoolean( CompileState state, IRBlock into, LLVM.BasicBlock label, bool jump ) {
            LLVM.BasicBlock l2;

	    if( not_result ) {
		// if operation was !~ (i.e. objects not equal) applied to non-object operands then
		// we will see operation == Op.EQ here with not_result set and need to reverse the sense
		// of the test:
		jump = !jump;
	    }


            if( operation == Op.BOOL_AND ) {
                if( jump ) {
                    l2 = into.Block();
                    left.compileBoolean( state, into, l2, false );
                    right.compileBoolean( state, into, label, true );

		    into.Label(l2);
                } else {
                    left.compileBoolean( state, into, label, false );
                    right.compileBoolean( state, into, label, false );
                }
            } else if( operation == Op.BOOL_OR ) {
                if( jump ) {
                    left.compileBoolean( state, into, label, true );
                    right.compileBoolean( state, into, label, true );
                } else {
                    l2 = into.Block();
                    left.compileBoolean( state, into, l2, true );
                    right.compileBoolean( state, into, label, false );
		    into.Label(l2);
                }
            } else if( operation == Op.BOOL_NOT ) {
                left.compileBoolean( state, into, label, !jump );
            } else if( operation >= Op.EQ && operation <= Op.LE ) {
		int size;
		if( method_call != null ) {
		    size = method_type.RegSize;

		    int op;
		    if( operation == Op.EQ || operation == Op.NE ) {
			op = getJumpOp( operation, !jump );
			into.Branch(
				    makeComparison(
						   op,
						   method_call.compileValue( state, into ),
						   LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt1Type(), 0L, 0 ),
						   into
						   ),
				    label
				    );
			
		    } else {

			if( !reverse ) {
			    op = getReverseJumpOp( operation, jump );
			} else {
			    op = getJumpOp( operation, jump );
			}
			

			into.Branch(
				    makeComparison(
						   op,
						   method_call.compileValue( state, into ),
						   LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 ),
						   into
						   ),
				    label
				    );
		    }
		    
		} else {
		    LLVM.Value l = left.compileValue( state, into );
		    LLVM.Value r = right.compileValue( state, into );

		    into.Branch(
				makeComparison(
					       getJumpOp(operation, jump),
					       l,
					       r,
					       into
					       ),
				label
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

	/*
        LLVM.Value compileValue( CompileState state, IRBlock into, ILabel e, bool jump ) {
	    return left.compileValue(state, into, e, jump);
        }


        ITree compileValue( CompileState state, IBlock into ) {
	    return left.compileValue(state, into);
        }

        void compileDiscardValue( CompileState state, IBlock into ) {
	    left.compileDiscardValue(state, into);
        }

        void compileDiscardValue( CompileState state, IRBlock into ) {
	    left.compileDiscardValue(state, into);
        }
	*/

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

        bool isType( CompileState state ) {
	    return left.isType(state);
        }

	void calcType( CompileState state ) {
	    type = left.getType(state);
	}

	/*
        ITree compileAddress( CompileState state, IBlock into ) {
	    return left.compileAddress( state, into );
        }
	*/

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

	public static int type_misses;
	public static int type_lookups;
	public static int type_clears;

	void clear( CompileState state ) {
	    type = null;
	    type_clears = type_clears + 1;
	}

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "check templates just calculates type: " + this.Class.Name );
	    // calcType( state );
	}

        void qualifies( Expression left_value ) {
            error( "cannot qualify this" );
        }

        LLVM.Value compileValue( CompileState state, IRBlock into, LLVM.BasicBlock e, bool jump ) {
            error( "not a boolean expression: " + this );
	    return ErrorValue();
        }


        LLVM.Value compileValue( CompileState state, IRBlock into ) {
            error( "this thing doesn't have a value\n" );
	    return ErrorValue();
        }


        void compileDiscardValue( CompileState state, IRBlock into ) {
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

	bool isType( CompileState state ) {
	    return false;
	}

	bool isIdentifier( CompileState state ) {
	    return false;
	}

	// does this expression resolve to an identifier that refers to a method?
	bool isMethod( CompileState state ) {
	    return false;
	}

	get bool IsEmpty {
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
	    type_lookups = type_lookups + 1;

            if( type == null ) {
		type_misses = type_misses + 1;
                calcType( state );
                if( type == null ) {
                    throw new System.NotImplementedException( "no type calculated" );
                    type = undefined_type;
                }
	    }

	    type.markReferenced();

            return type;
        }

        void calcType( CompileState state ) {
            throw new Exception( "can't calcType for: " + this );
        }

        LLVM.Value compileAddress( CompileState state, IRBlock into ) {
            error( "expression has no address" );
	    return ErrorValue();
        }

	static LLVM.Value makeComparison( int op, LLVM.Value cl, LLVM.Value cr, IRBlock into ) {
	    /*
	    IO.Std.err.println( "make comparison op #" + op );

	    IO.Std.err.print( "left:  " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( cl );
	    IO.Std.err.print( "type:  " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(cl) );

	    IO.Std.err.print( "right:  " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( cr );
	    IO.Std.err.print( "type:  " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(cr) );
	    */
	    cr = makeLLVMCast( cr, LLVM.Calls.LLVMTypeOf(cl), into );

	    switch( op ) {			
	    case Op.EQ:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntEQ, cl, cr );
		
	    case Op.NE:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntNE, cl, cr );
		
	    case Op.GT:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntSGT, cl, cr );
		
	    case Op.LT:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntSLT, cl, cr );
		
	    case Op.GE:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntSGE, cl, cr );
		
	    case Op.LE:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntSLE, cl, cr );
		
	    case Op.GTU:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntUGT, cl, cr );
		
	    case Op.LTU:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntULT, cl, cr );
		
	    case Op.GEU:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntUGE, cl, cr );
		
	    case Op.LEU:
		return into.ICmp( LLVM.LLVMIntPredicate.LLVMIntULE, cl, cr );
		
	    default:
		throw new System.NotImplementedException( "unsupported comparison operator: " + cast int(op) );
	    }		    
	}


	static LLVM.Value makeGetArraySize( CompileState state, int line_number, IRBlock into, LLVM.Value a ) {
	    addNullCheck( state, into, a, line_number );
	    return 
		makeLoadIndirect( state, line_number, into, false,
				  into.InBoundsGEP(
						   a,
						   {
						       LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),0L,0),
						       LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),1L,0)
						   }
						   )
					  );
	}


	static LLVM.Value makeGetArrayDataPointer( CompileState state, int line_number, IRBlock into, LLVM.Value a ) {
	    return makeGetArrayDataPointer(
					   state,
					   line_number,
					   into,
					   a,
					   LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),0L,0)
					   );
	}

	static LLVM.Value makeGetConstArrayDataPointer( CompileState state, int line_number, LLVM.Value a, LLVM.Value i ) {
	    return
		LLVM.Calls.LLVMConstInBoundsGEP(
				 a,
				 {
				     LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),0L,0),
				     LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),2L,0),
				     i					 
  				     }.address,
				 3
				 );
	}

	static LLVM.Value makeGetArrayDataPointer( CompileState state, int line_number, IRBlock into, LLVM.Value a, LLVM.Value i ) {
	    return
		into.InBoundsGEP(
				 a,
				 {
				     LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),0L,0),
				     LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),2L,0),
				     i					 
				 }
				 );
	}

        void compileBoolean( CompileState state, IRBlock into, LLVM.BasicBlock label, bool jump ) {
            if( getType( state ).TypeKind != Type.BOOL ) {
                error( "not a boolean expression: " + this );
                return;
            }

            int op = getJumpOp( Op.NE, jump );

	    into.Branch(
			makeComparison(
				       op,
				       compileValue( state, into ),
				       LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),0L,0),
				       into
				       ),
			label
			);
	}


        void init( int line_number ) {
            super.init( line_number );
            type = null;
        }

        static LLVM.Value makeInstance( CompileState state, int line_number, IRBlock into, LLVM.Value t, Container from, Symbol symbol, bool want_const ) {
	    // IO.Std.err.println( "\n\nGGGG: make instance from " + from.HumanName + " . " + symbol.HumanName );

	    int gep_depth = from.getGEPDepth(symbol) + 1;

	    // IO.Std.err.println( "\n\nGGGG: resulting depth: " + gep_depth + "\n\n" );
	    var gep_indexes = new LLVM.Value[gep_depth];

	    for( int i = 0; i < gep_depth-1; i = i + 1 ) {
		gep_indexes[i] = LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 );

		/*
		IO.Std.err.print( "GEP[" + i + "]:   " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( gep_indexes[i] );
		*/
	    }

	    gep_indexes[i] = LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), cast long(symbol.Address), 0 );


	    /*
	    IO.Std.err.print( "GEP[" + i + "]:   " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( gep_indexes[i] );

	    LLVM.Type tt = LLVM.Calls.LLVMTypeOf(t);

	    IO.Std.err.print( "value this:   " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( t );
	    IO.Std.err.print( "type this:    " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType( tt );

	    if( tt != from.Type.getLLVMType(state) ) {
		IO.Std.err.println( "from type != t.LLVMType" );
		IO.Std.err.print( "from type:    " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType(from.Type.getLLVMType(state));
		IO.Std.err.println( "from: " + new System.Backtrace() );
	    }
	    */

	    LLVM.Value result;
	    if( want_const ) {
		result = LLVM.Calls.LLVMConstInBoundsGEP( t, gep_indexes.address, gep_indexes.length );
	    } else {
		result = into.InBoundsGEP( t, gep_indexes );
	    }
	    /*
	    IO.Std.err.println( "result is: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( result );
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(result) );
	    */
	    return result;
        }

	// v should reference an object, result is reference to function in vtable slot @ offset
	// caller needs to ensure that v cannot point to a null object
	LLVM.Value makeLoadVTableSlot( CompileState state, IRBlock into, LLVM.Value v, int offset ) {
	    // cast object reference to pointer to vtable:
	    v = into.PointerCast( v, LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMVTableType(),0) );

	    // do not need null check here - caller should have already issued one if required:
	    v = into.Load( v );
	    
	    v = into.InBoundsGEP(
				 v,
				 {
				     // LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(), 0L, 0),
				     LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(), cast long(offset), 0)
				 }
				 );
	    
	    // cannot fault:
	    v = into.Load( v );

	    return v;
	}


	LLVM.Value makeCrowbarCall(
			    CompileState state,
			    IRBlock into,
			    LLVM.Value v,
			    LLVM.Type rt,
			    LLVM.Value[] args
			    ) {
	    int i;
	    LLVM.Type[] arg_types;

	    arg_types = new LLVM.Type[args.length];
	    for( i = 0; i < args.length; i = i + 1 ) {
		arg_types[i] = LLVM.Calls.LLVMTypeOf(args[i]);
	    }

	    /*
	    IO.Std.err.print( "v is: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue(v);
	    LLVM.Calls.LLVMDumpType(LLVM.Calls.LLVMTypeOf(v));
	    */
	    var ft = LLVM.Calls.LLVMFunctionType(
						 rt,
						 arg_types.address,
						 arg_types.length,
						 0 );
	    /*
	    IO.Std.err.print( "function type: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType(ft);
	    */
	    var pft = LLVM.Calls.LLVMPointerType(
						 ft,
						 0		
						 );

	    /*								    
	    IO.Std.err.print( "pointer type: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType(pft);
	    */
	    v = into.PointerCast( v,
				  pft
				  );


	    // IO.Std.err.println( "call or invoke" ); IO.Std.err.flush();	    
	    return callOrInvoke( state, into, v, args );
	}

	LLVM.Value compileCall(
            CompileState state, 
	    IRBlock into, 
	    LLVM.Value from, 
	    int o, 
	    Symbol symbol, 
	    String name, 
	    int offset,
	    LLVM.Type rt, // only required for call through proc reference, otherwise symbol's type is used
	    LLVM.Value[] args)

	{
	    int i;
	    LLVM.Value v;
	    LLVM.Type[] arg_types;

	    LLVM.BasicBlock handler;

	    if( isError(from) ) {
		return ErrorValue();
	    }

	    foreach( var a; args.elements() ) {
		if( isError(a) ) {
		    return ErrorValue();
		}
	    }

	    /*
	    if( o < 0 ) {
		if( symbol != null ) {
		    IO.Std.err.println( "interface call: " + symbol.HumanName + " @ " + o );
		} else {
		    IO.Std.err.println( "interface call: unknown @ " + o );
		}
	    } else if( o > 0 ) {
		if( symbol != null ) {
		    IO.Std.err.println( "virtual call: " + symbol.HumanName + " @ " + o );
		} else {
		    IO.Std.err.println( "virtual call: unknown @ " + o );
		}
	    }
	    */

	    /*
	    for( i = 0; i < args.length; i = i + 1 ) {
		IO.Std.err.print( "arg " + i + ": " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( args[i] );
	    }
	    */

	    if( o == Op.ERROR ) {
		IO.Std.err.println( "oops: compiling call with op == Op.ERROR" );
	    }

	    if( args == null ) {
		IO.Std.err.println( "call args are null" ); IO.Std.err.flush();
	    }

	    switch( o ) {
	    case Op.STATIC_CALL, Op.STATIC_CALL_DISCARD:
		addDummyExceptionHandlerJump( state, line_number, into );
		if( symbol != null ) {
		    if( symbol == undefined_method ) {
			throw new AbortCompilingThisMethodException("call to undefined static method");
		    }
		    v = symbol.getFunctionGlobal(state);
		    /*
		    IO.Std.err.print( "func " + i + ": " ); IO.Std.err.flush();
		    LLVM.Calls.LLVMDumpValue(v);
		    */
		    return callOrInvoke( state, into, v, args );
		} else {
		    throw new System.NotImplementedException( "calling function by name instead of Symbol" );
		}

	    case Op.DYNAMIC_CALL, Op.DYNAMIC_CALL_DISCARD:
		// IO.Std.err.print( "actual dynamic call through " ); IO.Std.err.flush();
		// LLVM.Calls.LLVMDumpValue(from);

		/*
		addDummyExceptionHandlerJump( state, line_number, into );
		v = into.PointerCast( from, LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMVTableType(),0) );

		// do not need null check here - caller should have already issued one if required:
		v = makeLoadIndirect( state, line_number, into, false, v );

		v = into.InBoundsGEP(
				     v,
				     {
					 // LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(), 0L, 0),
					 LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(), cast long(offset), 0)
				     }
				     );
		
		// cannot fault:
		v = into.Load( v );
		*/

		v = makeLoadVTableSlot( state, into, from, offset );

		return makeCrowbarCall( state, into, v, symbol.Type.getLLVMType(state), args );

	    case Op.PROC_CALL, Op.PROC_CALL_DISCARD:
		// from had better be pointer to Proc object:
		v = into.InBoundsGEP(
				     from,
				     {
					 LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 ),
					 LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 1L, 0 )
				     }
				     );

		v = into.Load(v); // pointer to function as i8 *
		return makeCrowbarCall( state, into, v, rt, args );

	    }

	    throw new Exception( "bad call operation: " + o );
	}

	int proc_number;

	LLVM.Value makeProcRefThunk(
				    CompileState state,
				    Container method,
				    Type proc_type,
				    bool is_slot
				    ) {

	    // IO.Std.err.println( "make proc ref thunk: " + proc_type ); IO.Std.err.flush();

	    bool is_static = method.IsStatic;
	    bool is_final = method.CallAsFinal;

	    LLVM.Module m = state.Module;
	    var name = "__thunk_";

	    if( is_slot ) {
		name = name + "virtual_";
	    } else if( is_static ) {
		name = name + "static_";
	    } else {
		name = name + "bound_";
	    }

	    name = name + method.DecoratedName;
	    var f_thunk = LLVM.Calls.LLVMGetNamedFunction( m, name.toCString() );

	    if( f_thunk != null ) {
		/* IO.Std.err.println( "use existing thunk" ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( f_thunk );
		*/

		// FIXME: assuming that method is representative of methods that will be called via this
		// proc object (i.e. right number of params, param types compatible without casting) and so
		// one thunk will do for all. Should do this from proc_type instead somehow to ensure get
		// least specific param types?

		return f_thunk;
	    }

	    var return_type = method.Type.getLLVMType(state);

	    // function signature of target function we want to call is same as supplied method:
	    var ft_target = method.getLLVMFunctionType(state);

	    /* IO.Std.err.println( "target function type is: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType( ft_target );
	    */

	    int num_arg = LLVM.Calls.LLVMCountParamTypes(ft_target);
	    if( is_static || is_slot ) {
		// IO.Std.err.println( "static target function: allocate space for additional parameter in thunk" );
		// allocate one more arg to accomodate proc object parameter to thunk, which target is not expecting:
		num_arg = num_arg + 1;
	    }

	    var at = new LLVM.Type[num_arg]; 
	    var atp = at.address;

	    if( is_static || is_slot ) {
		// shift static functions arguments one to right to accomodate proc this param to thunk:
		atp = atp + 1;
	    }

	    // if target is a static function these args shifted one to right leaving space for proc arg as first param:
	    LLVM.Calls.LLVMGetParamTypes(ft_target, atp);

	    // save type of target function's 'this' parameter as we need to cast to it later (will be null for static function):
	    var t_this = at[0];

	    // thunk takes a reference to a Proc<> object as 'this' (param 0), other params as target function:
	    at[0] = proc_type.getLLVMType(state);

	    // IO.Std.err.println( "thunk argument types are: " + at );

	    var ft_thunk = LLVM.Calls.LLVMFunctionType(
	 				           return_type,
						   at.address,
						   at.length,
						   0
						   );

	    /*
	    IO.Std.err.println( "thunk function type is: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType( ft_thunk );
	    */

	    // add new function to current module that will be the new thunk:
	    f_thunk = LLVM.Calls.LLVMAddFunction( m, name.toCString(), ft_thunk );
	    LLVM.Calls.LLVMSetLinkage(f_thunk, LLVM.LLVMLinkage.LLVMLinkOnceODRLinkage );
	    
	    var into = new IRBlock( state, f_thunk );

	    // get thunk's 'this' value, which is in param #0:
	    var p = LLVM.Calls.LLVMGetParam(f_thunk,0);

	    /* IO.Std.err.println( "thunk param 0 is: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( p );
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(p) );
	    */

	    // this depends on layout of Generic.Proc<P>:

	    LLVM.Value o;
	    if( !is_static && !is_slot ) {
		// IO.Std.err.println( "compile load bound object value..." ); IO.Std.err.flush();
		// load address of bound object from proc object ready to use as 'this' in call to target function:
		o = into.InBoundsGEP(
					 p,
					 {
					     LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 ), // this[0]
					     LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 2L, 0 ) // &this[0].d == &bound object
					 }
					 );
		
		o = into.Load(o); // this.d == bound object

		o = makeLLVMCast(
				 o,
				 t_this,
				 into
				 );
	    }		

	    // IO.Std.err.println( "compile load target function" ); IO.Std.err.flush();
	    // load target function:

	    LLVM.Value g;
	    if( is_slot ) {
		g = makeLoadVTableSlot( state,
					into,
					LLVM.Calls.LLVMGetParam( f_thunk, 1 ),
					method.Address ); 

		g = into.PointerCast(g, LLVM.Calls.LLVMPointerType(ft_target,0)); // this.f1 as function ptr
	    } else if( is_final ) {
		g = method.getFunctionGlobal(state);
	    } else {
		g = into.InBoundsGEP(
				     p,
				     {
					 LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 ), // this[0]
					 LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 3L, 0 ) // &this[0].f1 == &target function
				     }
				     );

		/* IO.Std.err.println( "target function field address is (should be i8**): " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( g );
		LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(g) );
		*/
		
		// IO.Std.err.println( "load function from pointer (should be i8*): " ); IO.Std.err.flush();
		g = into.Load(g); // this.f1 == target function as char ptr

		/*
		LLVM.Calls.LLVMDumpValue( g );
		LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(g) );
		*/

		// IO.Std.err.println( "will cast to function pointer..." ); IO.Std.err.flush();
		g = into.PointerCast(g, LLVM.Calls.LLVMPointerType(ft_target,0)); // this.f1 as function ptr
		/*
		IO.Std.err.println( "have function pointer: "); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( g );
		LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(g) );
		*/
	    }

	    var av = new LLVM.Value[LLVM.Calls.LLVMCountParamTypes(ft_target)];

	    /*

	    static or slot:
	    thunk( proc, p0, p1, p2, p3, ... )
	    target( p0, p1, p2, p3, ... )

	    dynamic:
	    thunk( proc, p0, p1, p2, p3, ... )
	    target( this, p0, p1, p2, p3, ... )

	    i: thunk param index
	    j: target param index

	    i: 1..?
	    j: 0/1..?

	    */

	    int j = 0;

	    if( !is_static && !is_slot ) {
		// IO.Std.err.println( "param #0 is bound object" );
		av[j] = o;
		j = j + 1;
	    }

	    for( int i = 1; i < at.length; i = i + 1 ) {
		// IO.Std.err.println( "param thunk(" + i + ") -> target(" + j + ")..." );
		av[j] = LLVM.Calls.LLVMGetParam( f_thunk, i );
		// LLVM.Calls.LLVMDumpValue( av[j] );
		j = j + 1;
	    }

	    // IO.Std.err.println( "call arguments: " + av ); IO.Std.err.flush();

	    /*
	    foreach( LLVM.Value t; av.elements() ) {
		IO.Std.err.print( "have argument: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( t );
		IO.Std.err.print( "argument type: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(t) );
	    }
	    */

	    var r = into.Call( g, av ); 

	    if( LLVM.Calls.LLVMGetTypeKind(return_type) != LLVM.TypeKind.LLVMVoidTypeKind ) {
		/*
		IO.Std.err.println( "returning non void value: " ); IO.Std.err.flush();
		IO.Std.err.print( "have return: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( r );
		IO.Std.err.print( "return type: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(r) );
		*/
		into.Ret(r);
	    } else {
		/*
		IO.Std.err.println( "returning void value: " ); IO.Std.err.flush();
		IO.Std.err.print( "have return: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( r );
		IO.Std.err.print( "return type: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(r) );
		*/
		into.RetVoid();
	    }

	    into.Close();

	    /*
	    IO.Std.err.println( "made thunk: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( f_thunk );
	    */

	    return f_thunk;
	}


	LLVM.Value compileLoadSlotRef(
				      CompileState state,
				      IRBlock into,
				      Container method,
				      Type proc_type
				      ) {
	    LLVM.Type pi8 = LLVM.Calls.LLVMPointerType(
						       LLVM.Calls.LLVMInt8Type(),
						       0
						       );

	    // locate existing thunk or create one if not found:
	    var p = makeProcRefThunk(
				     state, 
				     method,
				     proc_type,
				     true
				     );


	    var elem = {
		makeLoadVTable(state, proc_type.getBoxType(state).Clazz),
		LLVM.Calls.LLVMConstPointerCast(
						p,
						pi8
						),
		LLVM.Calls.LLVMConstPointerNull(
						pi8
						),
		LLVM.Calls.LLVMConstPointerNull(
						pi8
						)
	    };

	    var c =
		LLVM.Calls.LLVMConstStruct(
					   elem.address,
					   elem.length,
					   0					   
					   );

	    var g = 
		LLVM.Calls.LLVMAddGlobal(
					 state.Module,
					 LLVM.Calls.LLVMTypeOf(c),
					 ("__proc_" + proc_number).toCString()
					 );
	    proc_number = proc_number + 1;

	    LLVM.Calls.LLVMSetInitializer(
					  g,
					  c
					  );

	    LLVM.Calls.LLVMSetLinkage(g, LLVM.LLVMLinkage.LLVMPrivateLinkage );

	    return
		makeLLVMCast(
			     g,
			     proc_type.getLLVMType(state),
			     into
			     );
	}


	LLVM.Value compileLoadProcRef(
				      CompileState state,
				      IRBlock into,
				      LLVM.Value from,
				      Container method,
				      Type proc_type
				      ) {
	    if( method.IsStatic ) {
		return compileLoadStaticProcRef(state, into, method, proc_type );
	    } else {
		return compileLoadDynamicProcRef(state, into, from, method, proc_type );
	    }
	}



	LLVM.Value compileLoadStaticProcRef(
					    CompileState state,
					    IRBlock into,
					    Container method,
					    Type proc_type
					    ) {
	    LLVM.Type pi8 = LLVM.Calls.LLVMPointerType(
						       LLVM.Calls.LLVMInt8Type(),
						       0
						       );

	    // locate existing thunk or create one if not found:
	    var p = makeProcRefThunk(
				     state, 
				     method,
				     proc_type,
				     false
				     );


	    var elem = {
		makeLoadVTable(state, proc_type.getBoxType(state).Clazz),
		LLVM.Calls.LLVMConstPointerCast(
						p,
						pi8
						),
		LLVM.Calls.LLVMConstPointerNull(
						pi8
						),
		LLVM.Calls.LLVMConstPointerCast(
						method.getFunctionGlobal(state),
						pi8
						)
	    };

	    var c =
		LLVM.Calls.LLVMConstStruct(
					   elem.address,
					   elem.length,
					   0					   
					   );

	    var g = 
		LLVM.Calls.LLVMAddGlobal(
					 state.Module,
					 LLVM.Calls.LLVMTypeOf(c),
					 ("__proc_" + proc_number).toCString()
					 );
	    proc_number = proc_number + 1;

	    LLVM.Calls.LLVMSetInitializer(
					  g,
					  c
					  );

	    LLVM.Calls.LLVMSetLinkage(g, LLVM.LLVMLinkage.LLVMPrivateLinkage );

	    return
		makeLLVMCast(
			     g,
			     proc_type.getLLVMType(state),
			     into
			     );
	}

	LLVM.Value compileLoadDynamicProcRef(
				      CompileState state,
				      IRBlock into,
				      LLVM.Value from,
				      Container method,
				      Type proc_type
				      ) {

	    // IO.Std.err.println( "load proc ref: " + proc_type + " from method: " + method.HumanName );

	    bool is_final = method.CallAsFinal;

	    if( from == null ) {
		// IO.Std.err.println( "instance method and no bound this supplied: bind this now" );
		from = makeLoadThis(state, line_number, into);
	    }

	    Container c = proc_type.getBoxType(state).Clazz;
	    var b = "__proc_" + proc_number;
	    proc_number = proc_number + 1;
	    
	    var f = state.getRuntimeFunction( RuntimeFunction.ALLOC_OBJECT );
	    // IO.Std.err.print( "alloc object function is: " ); IO.Std.err.flush();
	    // LLVM.Calls.LLVMDumpValue( f );

	    var vtable = makeLoadVTable(state, c);
	    var args = { LLVM.Calls.LLVMConstTypeSizeIndirect(proc_type.getLLVMType(state)), vtable };
	    var o = callOrInvoke( state, into, f, args );

	    // IO.Std.err.print( "call to alloc object is: " ); IO.Std.err.flush();
	    // LLVM.Calls.LLVMDumpValue( o );
	    // LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(o) );
	    
	    // IO.Std.err.print( "proc type is: " ); IO.Std.err.flush();
	    // LLVM.Calls.LLVMDumpType( proc_type.getLLVMType(state) );

	    o = into.PointerCast( o, proc_type.getLLVMType(state) );

	    // IO.Std.err.print( "allocated proc ref object: " ); IO.Std.err.flush();
	    // LLVM.Calls.LLVMDumpValue( o );

	    LLVM.Type pi8 = LLVM.Calls.LLVMPointerType(
						       LLVM.Calls.LLVMInt8Type(),
						       0
						       );

	    // calculate address of f0 (== thunk) field in Proc object:
	    var q = into.InBoundsGEP(
				     o,
				     {
					 LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 ), // this[0]
  			                 LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 1L, 0 ) // &this[0].f0 == &thunk
				     }
				     );

	    // IO.Std.err.print( "address of f0: "); IO.Std.err.flush();
	    // LLVM.Calls.LLVMDumpValue( q );
	    
	    // locate existing thunk or create one if not found:
	    var p = makeProcRefThunk(
				     state, 
				     method,
				     proc_type,
				     false
				     );

	    // IO.Std.err.print( "address of thunk: "); IO.Std.err.flush();
	    // LLVM.Calls.LLVMDumpValue( p );

	    // store the thunk in f0 field:
	    into.Store(
		       makeLLVMCast(
				    p,
				    pi8,
				    into
				    ),
		       q
		       );

	    if( from != null ) {
		// calculate address of d (== bound object) field in Proc object:
		q = into.InBoundsGEP(
				     o,
				     {
					 LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 ), // this[0]
					 LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 2L, 0 ) // &this[0].d == &bound object
				     }
				     );

		// store supplied 'this' value in d field:
		into.Store(
			   makeLLVMCast(
					from,
					pi8,
					into
					),
			   q
			   );
	    }

	    // calculate address of f1 (== target function) field in Proc object:
	    q = into.InBoundsGEP(
				 o,
				 {
				     LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 0L, 0 ), // this[0]
  			             LLVM.Calls.LLVMConstInt( LLVM.Calls.LLVMInt32Type(), 3L, 0 ) // &this[0].f1 == &target function
				 }
				 );
	    
	    if( is_final ) {
		// method is final so can simply store its address in the proc object:
		into.Store(
			   makeLLVMCast(
					method.getFunctionGlobal(state),
					pi8,
					into
					),
			   q
			   );

	    } else {
		// method is not final so need to do a vtable lookup to determine actual method to call:

		into.Store(
			   makeLLVMCast(
					makeLoadVTableSlot(
							   state,
							   into,
							   from,
							   method.Address
							   ),
					pi8,
					into
					),
			   q
			   );


	    }

	    return o;
	}


	/*
	ITree compileLoadStaticProcRef( CompileState state, IBlock into, Symbol symbol, Type proc_type ) {
	    var l = TempFactory.nextLabel();
	    into.add( new ITree( line_number, Op.RODATA, 0 ) );
	    into.add( new ITree( line_number, Op.LABEL, 0, l ) );
	    into.add( new ITree( line_number, Op.DEFINT, Machine.WORD, 
				 getVTableAsString( state, proc_type.getBoxType(state).Clazz ) ) );

	    into.add( new ITree( line_number, Op.DEFINT, Machine.WORD, symbol.DecoratedName ) );
	    
	    into.add( new ITree( line_number, Op.TEXT, 0 ) );

	    return loadGlobal( state, l.toString(), 0 ); 
	}

	ITree compileLoadDynamicProcRef(
	    CompileState state,
	    IBlock into,
	    ITree from,
	    Symbol symbol,
	    Type proc_type,
	    Vector<Type> arg_types,
	    bool no_vtable_lookup
	) {
	    int t = TempFactory.nextTemp();
	    int u = TempFactory.nextTemp();
	    addDummyExceptionHandlerJump( state, line_number, into );

	    // going to reference from more than once - copy it into a temporary unless it's a simple expression:
	    if( !from.isPrettySimple() ) {
		into.add( makeStoreTemporary( u, Machine.WORD, from ) );
		from = makeLoadTemporary( u, Machine.WORD );
	    }


	    int num_args;
	    if( arg_types != null ) {
		num_args = arg_types.Length;
	    }

	    if( num_args >= Machine.NUM_REG_PARAM ) {
		error( "instance proc with more than " + (Machine.NUM_REG_PARAM-1) + " arguments not supported" );
		return new ITree( line_number, Op.ERROR, 0 );
	    }

	    Container c = proc_type.getBoxType(state).Clazz;
	    var b = "__proc_thunk" + num_args;
	   
	    int r = TempFactory.nextTemp();

	    // allocate pointer to a proc ref structure and store it in temp r:
	    into.add( makeStoreTemporary( r, Machine.WORD, new ITree( line_number, Op.PROC_REF, 0 ) ) );

	    // store vtable in word 0 of proc ref structure:
	    into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				 new ITree( line_number, Op.INDIRECT, Machine.WORD,
					    new ITree( line_number, Op.ADD, Machine.WORD,
						       makeLoadTemporary( r, 8 ),
						       new ITree( line_number, Op.CONST, Machine.WORD, 0 * Machine.WORD )
						       )
					    ),
				 loadVTable( state, c )
				 )
		      );


	    // store thunk in word 1 of proc ref structure:
	    into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				 new ITree( line_number, Op.INDIRECT, Machine.WORD,
					    new ITree( line_number, Op.ADD, Machine.WORD,
						       makeLoadTemporary( r, 8 ),
						       new ITree( line_number, Op.CONST, Machine.WORD, 1 * Machine.WORD )
						       )
					    ),
				 new ITree( line_number, Op.GLOBAL, Machine.WORD, b )
				 // loadVTable( state, c )
				 )
		      );

	    // store this address in word 2 of proc ref structure:
	    into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				 new ITree( line_number, Op.INDIRECT, Machine.WORD,
					    new ITree( line_number, Op.ADD, Machine.WORD,
						       makeLoadTemporary( r, 8 ),
						       new ITree( line_number, Op.CONST, Machine.WORD, 2 * Machine.WORD )
						       )
					    ),
				 from
				 )
		      );


	    if( no_vtable_lookup ) {
		// IO.Std.err.println( "store method address: " + symbol.DecoratedName + " from " + symbol.HumanName );
		// store method address in word 3 of proc ref structure:
		into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						new ITree( line_number, Op.ADD, Machine.WORD,
							   makeLoadTemporary( r, 8 ),
							   new ITree( line_number, Op.CONST, Machine.WORD, 3 * Machine.WORD )
							   )
						),
				     loadGlobal( state, symbol.DecoratedName, 0 )
				     // new ITree( line_number, Op.CONST, Machine.WORD, symbol.DecoratedName )
				     )
			  );
	    } else {				     
		// IO.Std.err.println( "store method offset: " + symbol.Address + " from " + symbol.HumanName );
		// look up method address in vtable and store in word 3 of proc ref structure:
		into.add( new ITree( line_number, Op.COPY, Machine.WORD,
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						new ITree( line_number, Op.ADD, Machine.WORD,
							   makeLoadTemporary( r, 8 ),
							   new ITree( line_number, Op.CONST, Machine.WORD, 3 * Machine.WORD )
							   )
						),
				     
				     new ITree( line_number, Op.INDIRECT, Machine.WORD,
						new ITree( line_number, Op.ADD, Machine.WORD,
							   new ITree( line_number, Op.INDIRECT, Machine.WORD, from ),
							   new ITree( line_number, Op.CONST, Machine.WORD, symbol.Address )
							   )
						)
				     )
			  );


	    }
	    return makeLoadTemporary( r, Machine.WORD );
	}
	*/

        LLVM.Value compileLoad(
	    CompileState state,
	    IRBlock into,
	    Symbol symbol,
	    Container container,
	    ExpressionList arguments,
	    Type rt,
	    Vector<Type> argument_types,
	    LLVM.Value from,
	    int flags,
	    Symbol super_class ) {
	    LLVM.Value result = compileLoad2(
					    state,
					    into,
					    symbol,
					    container,
					    arguments,
					    rt,
					    argument_types,
					    from,
					    flags,
					    super_class );
	    /*
	    if( result != null ) {
		LLVM.Calls.LLVMDumpValue( result );
	    } else {
		IO.Std.err.println( "null from: " + new System.Backtrace() );
	    }
	    */
	    return result;
	}
	    

        LLVM.Value compileLoad2(
	    CompileState state,
	    IRBlock into,
	    Symbol symbol,
	    Container container,
	    ExpressionList arguments,
	    Type rt, // expected return type: required for proc calls, ignored otherwise
	    Vector<Type> argument_types,
	    LLVM.Value from,
	    int flags,
	    Symbol super_class
	) {
            LLVM.Value v;
            LLVM.Value t;
            int o, a, u;

	    if( isUndefined(symbol) || rt == undefined_type || isError(from) ) {
		return ErrorValue();
	    }
    
            bool address = flags & LOAD_FLAG_ADDRESS != 0;
            bool no_discard = flags & LOAD_FLAG_DISCARD == 0;
            bool reference = flags & LOAD_FLAG_REFERENCE != 0;
	    bool proc_call = flags & LOAD_FLAG_PROC_CALL != 0;

	    LLVM.Value[] arg_values;

	    // IO.Std.err.println( "EEEE: arg types: " + argument_types );

	    if( symbol != null ) {
		if( symbol.Kind == Symbol.TYPE ) {
		    IO.Std.err.println( "attempting to load value of type symbol " + symbol + " here" );
		    return ErrorValue();
		}
	    } else {
		if( !proc_call ) {
		    error( "oops: cannot load a null symbol" );
		    return ErrorValue();
		} 
	    }		
             
            if( from == null ) {
		// IO.Std.err.println( "compile load, from == null" );

                switch ( symbol.Kind ) {
		    		   
                case Symbol.CLASS:
		    // IO.Std.err.println( "compile load: class" );
		    error( "cannot use class " + symbol.HumanName + " here" );
		    return ErrorValue();
                    
                    
                case Symbol.STATIC_VARIABLE:
		    // IO.Std.err.println( "compile load: static variable" );
                    v = symbol.getStaticGlobal(state);
                    
                    if( reference ) {
			// can't throw null pointer exception:
                        // IO.Std.err.println( "loading static reference: " + symbol.HumanName );
			v = makeLoadIndirect( state, line_number, into, false, v );
                    }
                    
                    if( !address ) {
			/*
			if( !symbol.IsValueValid ) {
			    warn( "static variable " + symbol.HumanName + " may not be initialized here" );
			}
			*/
			// symbol.Owner.addDependant( state.CurrentClass );

			// can only throw null pointer exception if it's a reference:
			v = makeLoadIndirect( state, line_number, into, reference, v );
                    }

                    return v;
                    
                case Symbol.INSTANCE_VARIABLE:
		    // IO.Std.err.println( "compile load: instance variable" );
                    if( flags & LOAD_FLAG_STATIC != 0 ) {
			error( "cannot access instance variable " + symbol.HumanName + " from static context" );
			return ErrorValue(symbol.Type.getLLVMType(state));
                     } else {
			v = makeLoadThis( state, line_number, into );

                        v = makeInstance( state, line_number, into, v, container, symbol, false );
                        
                        if( reference ) {
                            // IO.Std.err.println( "loading instance reference: " + symbol.HumanName );
			    // could throw null pointer exception if this is null:
			    v = makeLoadIndirect( state, line_number, into, false, v );
                        }
                        
                        if( !address ) {
			    // could throw null pointer exception if this is null or if reference and reference is null:
			    v = makeLoadIndirect( state, line_number, into, reference, v );
                        }
                        
                        return v;
                    }
                    
                    
                case Symbol.LOCAL_VARIABLE:
                    // fprintf( stderr, "local %s size %d offset %d\n", symbol.getName(), size, symbol.getAddress() );

		    v = symbol.getLocal(state,into);

                    if( reference ) {
			// can't throw null pointer exception:

			v = makeLoadIndirect( state, line_number, into, false, v );
                    }
                    
                    if( !address ) {
			// can only throw null pointer exception if is a reference:

			v = makeLoadIndirect( state, line_number, into, reference, v );
                    }

                    return v;
                    
                case Symbol.STATIC_METHOD:
		    // IO.Std.err.println( "compile: static method call" );

                    if( no_discard ) {
                        o = Op.STATIC_CALL;
                    } else {
                        o = Op.STATIC_CALL_DISCARD;
                    }

		    arg_values = ExpressionList.compilePush( arguments, state, null, null, argument_types, into, false, false );
		    // IO.Std.err.println( "CCCC: static call, arg types: " + argument_types );

		    return compileCall( state, into, null, o, symbol, symbol.DecoratedName, 0, null, arg_values );
                    
                case Symbol.INSTANCE_METHOD:
		    // IO.Std.err.println( "compile: instance call" );

                    if( flags & LOAD_FLAG_STATIC != null ) {
                        if( symbol == undefined_method ) {
                            IO.Std.err.println( "calling undefined method" );
			    return ErrorValue();
                        }
                        error( "cannot call instance method " + symbol.HumanName + " from static context" );
			return ErrorValue();
                    }
                    
                    if( super_class != null ) {
                        // call dynamic method statically
                        if( no_discard ) {
                            o = Op.STATIC_CALL;
                        } else {
                            o = Op.STATIC_CALL_DISCARD;
                        }

			// this cannot be null:
			t = makeLoadThis(state, 0, into);

			arg_values = ExpressionList.compilePush(
								arguments,
								state,
								t,
								symbol.Owner.Type,
								argument_types,
								into,
								true,
								false
								);
			// IO.Std.err.println( "CCCC: static dynamic call, arg types: " + argument_types );

			return compileCall( state, into, t, o, symbol, symbol.DecoratedName, 0, null, arg_values );
                    } else if( cast<Container>(symbol).CallAsFinal ) {
                        if( no_discard ) {
                            o = Op.STATIC_CALL;
                        } else {
                            o = Op.STATIC_CALL_DISCARD;
                        }
			// this should not be null here so no null check:

			arg_values = ExpressionList.compilePush(
								arguments,
								state,
								makeLoadThis(state, 0, into),
								symbol.Owner.Type,
								argument_types,
								into,
								true,
								false );

			// IO.Std.err.println( "CCCC: static dynamic call, arg types: " + argument_types );

			// this cannot be null here:
			return compileCall( state, into, null, o, symbol, symbol.DecoratedName, 0, null, arg_values );
                    }  else {
                        if( no_discard ) {
                            o = Op.DYNAMIC_CALL;
                        } else {
                            o = Op.DYNAMIC_CALL_DISCARD;
                        }

			// this cannot be null here:
			t = makeLoadThis(state, 0, into);

			// this should not be null here so no null check

			arg_values = ExpressionList.compilePush( arguments, state, t, symbol.Owner.Type, argument_types, into, true, false );

		        a = symbol.Address;
			// IO.Std.err.println( "dynamic call to non-final method " + symbol.getDecoratedName() + " at offset " + a );

			// IO.Std.err.println( "CCCC: actual dynamic call, arg types: " + argument_types );

			return compileCall( state, into, t, o, symbol, null, symbol.Address, null, arg_values );
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
		    return ErrorValue(symbol.Type.getLLVMType(state));
                }
            } else {                    // from is source and into is destination
		// IO.Std.err.println( "compile load: from is not null" );
		if( proc_call ) {
		    // IO.Std.err.println( "compile: proc call" );

		    if( no_discard ) {
			o = Op.PROC_CALL;
		    } else {
			o = Op.PROC_CALL_DISCARD;
		    }
		    addNullCheck( state, into, from, line_number );
		    arg_values = ExpressionList.compilePush( arguments, state, from, null, argument_types, into, true, false );

		    return compileCall( state, into, from, o, null, null, 0, rt.getLLVMType(state), arg_values );
		} else
                switch ( symbol.Kind ) {
                case Symbol.STATIC_VARIABLE:
		    // IO.Std.err.println( "compile load: static variable" );
                    v = symbol.getStaticGlobal(state);

                    if( reference ) {
			// can't throw null pointer exception:
			v = makeLoadIndirect( state, line_number, into, false, v );
                    }

                    if( !address ) {
			/*
			if( !symbol.IsValueValid ) {
			    warn( "static variable " + symbol.HumanName + " may not be initialized here" );
			}
			*/
			// symbol.Owner.addDependant( state.CurrentClass );

			// can only throw null pointer exception if reference:
			v = makeLoadIndirect( state, line_number, into, reference, v );
                    }
                    
                    return v;
                    
                case Symbol.INSTANCE_VARIABLE:
		    // IO.Std.err.println( "compile load: instance variable" );

		    // from != this, so it could be null. check before makeInstance moves any null pointer away from zero:
		    addNullCheck(state, into, from, line_number);

		    v = makeInstance( state, line_number, into, from, container, symbol, false );
                        
		    if( reference ) {
			IO.Std.err.println( "loading instance reference: " + symbol.HumanName );
			// cannot be null - have already checked if from is null:
			v = makeLoadIndirect( state, line_number, into, false, v );
		    }
                    
		    if( !address ) {
			// could throw null pointer exception if this is null or if reference and reference is null:
			v = makeLoadIndirect( state, line_number, into, reference, v );
		    }
                        
		    return v;
                    
                case Symbol.LOCAL_VARIABLE:
                    throw new Exception( "oops: accessing local variable: '" + symbol.Name + "' from incorrect context" );
		    return ErrorValue(symbol.Type.getLLVMType(state));
                    
                case Symbol.STATIC_METHOD:
		    // IO.Std.err.println( "compile: static call" );

                    if( flags & LOAD_FLAG_STATIC == 0 && super_class == null ) {
			warn( "call to static method " + symbol.HumanName + " does not evaluate left value" );
		    }

		    if( no_discard ) {
			o = Op.STATIC_CALL;
		    } else {
			o = Op.STATIC_CALL_DISCARD;
		    }
		    
		    arg_values = ExpressionList.compilePush( arguments, state, null, null, argument_types, into, false, false );
		    IO.Std.err.println( "CCCC: static call, arg types: " + argument_types );
		    
		    return compileCall( state, into, null, o, symbol, symbol.DecoratedName, 0, null, arg_values );
			/*
                    }
                    
		    error( "calling static method " + symbol.HumanName + " dynamically" );
		    return ErrorValue();
			*/

                  
                case Symbol.INSTANCE_METHOD:
		    // IO.Std.err.println( "compile: instance call" );

                    if( !address ) {
                        error( "using method " + symbol.HumanName + " but not calling it" );
			return ErrorValue();
			// IO.Std.err.println( "here: " + new System.Backtrace() );
		    }
                    // source is object address
                    // into will whole call address
                    
                    // into now holds object address
                    
                    if( super_class != null ) {
                        // call dynamic method statically
                        if( no_discard ) {
                            o = Op.STATIC_CALL;
                        } else {
                            o = Op.STATIC_CALL_DISCARD;
                        }

			// from could be null:
			addNullCheck(state, into, from, line_number);

			arg_values = ExpressionList.compilePush( arguments, state, from, symbol.Owner.Type, argument_types, into, true, false );
			// IO.Std.err.println( "CCCC: static dynamic call, arg types: " + argument_types );

			return compileCall( state, into, from, o, symbol, symbol.DecoratedName, 0, null, arg_values );
                    } else if( cast<Container>(symbol).CallAsFinal ) {
                        if( no_discard ) {
                            o = Op.STATIC_CALL;
                        } else {
                            o = Op.STATIC_CALL_DISCARD;
                        }

			// although we're not going to call though it, still need to check from against null here
			// because called function expects this to be guarentee'd non-null:
			addNullCheck(state, into, from, line_number);

			arg_values = ExpressionList.compilePush( arguments, state, from, symbol.Owner.Type, argument_types, into, true, false );
			// IO.Std.err.println( "CCCC: final dynamic call, arg types: " + argument_types );

			return compileCall( state, into, from, o, symbol, symbol.DecoratedName, 0, null, arg_values );
                    } else {

		        a = symbol.Address;
			// IO.Std.err.println( "dynamic call to non-final method " + symbol.getDecoratedName() + " at offset " + a );

                        if( no_discard ) {
                            o = Op.DYNAMIC_CALL;
                        } else {
                            o = Op.DYNAMIC_CALL_DISCARD;
                        }
			arg_values = ExpressionList.compilePush( arguments, state, from, symbol.Owner.Type, argument_types, into, true, false );
			// IO.Std.err.println( "CCCC: actual dynamic call, arg types: " + argument_types );

			return compileCall( state, into, from, o, symbol, null, symbol.Address, null, arg_values );
                    }
                    
                default:
		    // IO.Std.err.println( "compile load: default" );

                    if( symbol.Kind == Symbol.CLASS ) {
                        error( "cannot use class " + symbol.HumanName + " here" );
                    } else if( symbol.Kind == Symbol.NAMESPACE ) {
                        error( "cannot use namespace " + symbol.HumanName + " here" );
                    } else if( symbol.Kind == Symbol.ENUM ) {
                        error( "cannot use enum " + symbol.HumanName + " here" );
                    } else {
                        error( "cannot use symbol " + symbol.HumanName + " here" );
                    }
		    return ErrorValue(symbol.Type.getLLVMType(state));
                }
            }

	    IO.Std.err.println( "compile load: fall through return null" );		    
        }

	get int Depth {
	    return 0;
	}

	get int Operation {
	    return Op.ERROR;
	}

	const int IMPLEMENTS_OFFSET = 3; // one more than FINALIZE_OFFSET in exception.c, places _implements after _dispose

	LLVM.Value makeInterfaceCastCheck( CompileState state, IRBlock into, LLVM.Value v, Container c, bool want_throw ) {
	    if( !state.WantCastCheck ) {
		return LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),1L,0);
	    }

	    var iface = c.getInterfaceGlobal(state);

	    var f = makeLoadVTableSlot( state, into, v, IMPLEMENTS_OFFSET );

	    /*
	    IO.Std.err.println( "vtable slot: " );
	    LLVM.Calls.LLVMDumpValue( f );
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(f) );
	    */

	    var ft = Container.getImplementsFunctionType();
	    /*
	    IO.Std.err.println( "cast to function type: " );
	    LLVM.Calls.LLVMDumpType( ft );
	    */

	    f = makeLLVMCast(
			     f,
			     LLVM.Calls.LLVMPointerType(ft,0),
			     into
			     );

	    /*
	    LLVM.Calls.LLVMDumpValue( f );
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(f) );

	    LLVM.Calls.LLVMDumpValue( v );
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(v) );
	    */

	    // note that though we've just done virtual despatch, this is not a proper virtual method
	    // call as no 'this' value is passed:
	    var ok = callOrInvoke( state, into, f, { c.getInterfaceGlobal(state) } );

	    if( !want_throw ) {
		return ok;
	    }
	    var throw_function = state.getRuntimeFunction( RuntimeFunction.THROW_CAST );

	    LLVM.BasicBlock x = into.Block();

	    into.Branch( ok, x );
	    callOrInvoke( state, into, throw_function, new LLVM.Value[0] );
	    into.Unreachable();

	    into.Label(x);	   

	    return null;
	}

	LLVM.Value makeObjectCastCheck( CompileState state, IRBlock into, LLVM.Value v, Container c, bool want_throw ) {
	    if( !state.WantCastCheck ) {
		return LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),1L,0);
	    }

	    var ppi8 =
		LLVM.Calls.LLVMPointerType(
					   LLVM.Calls.LLVMPointerType(
								      LLVM.Calls.LLVMInt8Type(),
								      0
								      ),
					   0
					   );

	    var vtable = makeLoadVTable( state, c );

	    var e = into.Block();
	    var m = into.Block();
	    var t = into.Block();
	    var b = into.Block();
	    var x = into.Block();

	    var throw_function = state.getRuntimeFunction( RuntimeFunction.THROW_CAST );

	    /*
	      e:
	      if v0 = null then goto x
	      m:
	      v1 = phi e->v, t->v1
	      v = *v 
	      if v == ctable goto x
	      t:
	      if v != null got o m
	      throw cast exception
	      unreachable
	      x:
	      // done

	    */

	    v = makeLLVMCast(
			     v,
			     ppi8,
			     into
			     );

	    into.Label(e);

	    // null can be cast to any object type:
	    into.BranchLabel(
			     into.ICmp(
				       LLVM.LLVMIntPredicate.LLVMIntEQ,
				       v,
				       LLVM.Calls.LLVMConstNull(
								ppi8
								)
				       ),
			     x,   // from e -> x
			     m
			     );

	    // loop from object's class over all super classes:
	    var v0 = into.Phi( ppi8 );
	    
	    // load vtable from object (if first pass) or parent from vtable (subsequent passes)
	    var v1 = into.Load(v0);

	    v1 = makeLLVMCast(
			     v1,
			     ppi8,
			     into
			     );

	    /*
	    IO.Std.err.println( "v, v1: "); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( v );
	    LLVM.Calls.LLVMDumpValue( v1 );
	    */

	    into.AddIncoming(
			     v0,
			     {v, v1},
			     {e, t}
			     );

	    // if current vtable matches expected vtable then cast is acceptable, jump to exit label:
	    into.BranchLabel(
			     into.ICmp(
				       LLVM.LLVMIntPredicate.LLVMIntEQ,
				       v1,
				       makeLLVMCast(
						    vtable,
						    ppi8,
						    into
						    )
				       
				       ),
			     x, // from m -> x
			     t
			);			


	    // if current vtable is null then none of the object's class or any ancestor class matched the
	    // supplied vtable, in this case fall through to the cast exception throw, otherwise jump
	    // back to loop start to try next ancestor:
	    if( want_throw ) {
		into.Branch(
			    into.ICmp(
				      LLVM.LLVMIntPredicate.LLVMIntNE,
				      v1,
				      LLVM.Calls.LLVMConstNull(
							       ppi8
							       )
				      ),
			    m
			    );

		// unacceptable cast, throw a CastException:
		callOrInvoke( state, into, throw_function, new LLVM.Value[0] );
		into.Unreachable();
		into.Label( x );
	    } else {
		into.BranchLabel(
			    into.ICmp(
				      LLVM.LLVMIntPredicate.LLVMIntNE,
				      v1,
				      LLVM.Calls.LLVMConstNull(
							       ppi8
							       )
				      ),
			    m,
			    x // from t -> x
			    );
	    }

	    if( !want_throw ) {
		var result = into.Phi( LLVM.Calls.LLVMInt1Type() );
		into.AddIncoming(
				 result,
				 {
				     LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),1L,0),
  				     LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),1L,0),
				     LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),0L,0),
				 },
				 {e, m, t}
				 );
		/*
		IO.Std.err.println( "result: " );
		LLVM.Calls.LLVMDumpValue(result);
		*/
		return result;
	    } else {
		return null;
	    }
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

	static LLVM.Value[] compilePush(
            ExpressionList l, 
	    CompileState state,
	    LLVM.Value thiz,
	    Type this_type,
	    Vector<Type> arg_types,
	    IRBlock into,
	    bool skip_this,
	    bool native_call)
	{
	    if( l == null ) {
		l = new ExpressionList( 0 );
	    }

	    return l.compilePush( state, thiz, this_type, arg_types, into, skip_this, native_call );
	}

        LLVM.Value[] compilePush(
            CompileState state,
	    LLVM.Value thiz,
	    Type this_type,
	    Vector<Type> arg_types,
	    IRBlock into,
	    bool skip_this,
	    bool native_call
	) {
	    // IO.Std.err.println( "AAAAAA: compilePush: " + this );
            int size = 0;
	    LLVM.Value v;
	    LLVM.Value param = null; 
	    LLVM.Value[] result;
            int s;
	    int temp;

	    bool seen_any_params = false;

	    int n = list.Length;

	    if( skip_this ) {
		n = n + 1;
	    }
	    bool simple;
	    // IO.Std.err.println( "pushing " + n + " arguments: " + arg_types  );

	    result = new LLVM.Value[n];

	    if( skip_this ) {
		if( this_type != null ) {
		    thiz = makeLLVMCast( thiz, this_type.getLLVMType(state), into );
		}
		result[0] = thiz;
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
		    v = e.compileAddress( state, into );
		} else {
		    // IO.Std.err.println( "compile value parameter: " + e + " type " + e.getType(state) );

		    v = e.compileValue( state, into );
                    
		    /*
		      if( s == 1 ) {
		      result = new ITree( line_number, Op.CAST_FROM1, 8, result );
		      } else if( s == 4 ) {
		      result = new ITree( line_number, Op.CAST_FROM4, 8, result );
		      }
		    */
		}

		if( v == null ) {
		    IO.Std.err.println( "compiling expression list go null element: " + this + " cause: " + e + " type: " + e.Class.Name );
		}

		if( t != null ) {
		    v = makeLLVMCast( v, t.getLLVMType(state), into );
		}
		
		n = n - 1;
		result[n] = v;
	    }


	    return result;
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

	String toString() {
	    var buffer = new StringBuffer();
            for( var i = list.elements(); i.hasMoreElements(); ) {
                Expression e = i.nextElement();
		buffer.append( e );
                
                if( i.hasMoreElements() ) {
                    buffer.append( ',' );
                }
	    }

	    return buffer;
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