
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    use Gen.Machine;
    use Gen.IRBlock;

    class NewExpression extends Expression {
        protected TypeExpr left;
        protected Expression argument;    // if vector
        protected ExpressionList arguments;       // if class
        protected Container method;

        void init( int line_number, TypeExpr left, Expression argument ) {
            super.init( line_number );
            this.left = left;
            this.argument = argument;
            this.arguments = null;
        }

        void init( int line_number, TypeExpr left, ExpressionList arguments ) {
            super.init( line_number );
            this.left = left;
            this.argument = null;
            this.arguments = arguments;
        }

	void clear( CompileState state ) {
	    super.clear( state );
	    left.clear( state );
	    if( argument != null ) {
		argument.clear( state );
	    }
	    if( arguments != null ) {
		arguments.clear( state );
	    }
	    method = null;
	}


	void checkTemplates( CompileState state ) {
	    super.checkTemplates( state );

	    if( argument != null ) {
		argument.checkTemplates( state );
		// ensure generic array template is instantiated:
		new VectorType( line_number, left ).checkTemplates(state);
	    } else {
		left.checkTemplates( state );
	    }

	    if( arguments != null ) {
		arguments.checkTemplates( state );
	    }
	}


        void calcType( CompileState state ) {
            type = left.parseType( state );

            if( argument != null ) {
                type = new Type( Type.VECTOR, type );
                if( arguments != null ) {
                    error( "new for " + type.dump() + " cannot have arguments" );
                }

                if( !argument.getType( state ).isInteger() && argument.getType(state).TypeKind != Type.ERROR ) {
                    error( "element count for new " + type.dump() + " must be integer" );
                }
            } else if( type.TypeKind == Type.CLASS ) {
                Container class_symbol = type.Clazz;

                Vector<Type> arg_types = null;
                if( arguments != null ) {
                    arg_types = arguments.getTypes( state );
                }

                Quality quality = new Quality();
                method = class_symbol.findBestMethod( "init", arg_types, quality );

                if( method == null || method.Owner != class_symbol ) {
                    method = undefined_method;
                    String arg_string = dumpArguments( arg_types );

                    error( "class " + class_symbol.HumanName + " has no constructor init(" + arg_string + ")" );
                    
                    return;
                } else {
                    checkAccess( method, state );
                }
            } else {
                if( type.TypeKind != Type.ERROR ) { // avoid duplicate messages for undefined types
                    error( "cannot new type " + type.dump() );
                }
            }
        }

        LLVM.Value compileValue( CompileState state, IRBlock into ) {
            Container class_symbol = null;
            Type t = getType(state);

	    RuntimeFunction op;

	    LLVM.Value v;
	    LLVM.Value f;
	    LLVM.Value function;
	    LLVM.Value size;
	    LLVM.Value vtable;
	    LLVM.Value[] args;

            if( t.TypeKind == Type.VECTOR ) {
		/*
                Type st = t.SubType;
		if( st.isReference() ) {
		    op = RuntimeFunction.ALLOC_REF_ARRAY;
		} else {
		    // IO.Std.err.println( "new non reference array for: " + st );
		    op = RuntimeFunction.ALLOC_ARRAY;
		}

		Container c = t.getBoxType(state).Clazz;
		f = state.getRuntimeFunction( op );

		size = argument.compileValue( state, into );
		vtable = makeLoadVTable( state, c );

		IO.Std.err.print( "new array function: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( f );

		IO.Std.err.print( "new size: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( size );

		IO.Std.err.print( "new vtable: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( vtable );

		IO.Std.err.print( "new sub type: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( st.getLLVMType(state) );

		// PointerType on type here as ConstTypeSize will strip off one level of pointer and compute size of pointed to type:
		args = { size, LLVM.Calls.LLVMConstTypeSize(st.getLLVMType(state)), vtable };

		v = callOrInvoke( state, into, f, args );

		return into.PointerCast( v, getType(state).getLLVMType(state) );
		*/
		return makeAllocateArray( state, into, t, argument.compileValue(state,into) );
            } else if( t.TypeKind == Type.CLASS ) {
                // int temp = TempFactory.nextTemp();

                class_symbol = getType(state).Clazz;

		op = RuntimeFunction.ALLOC_OBJECT;

		if( class_symbol.IsStruct ) {
		    vtable = LLVM.Calls.LLVMConstPointerNull(LLVM.Calls.LLVMVTableType());
		} else {
		    vtable = makeLoadVTable( state, class_symbol );

		    // new ITree( line_number, Op.GLOBAL, Machine.WORD, 

		    // does this class override Object.finalize()? If so need to register it's 
		    // finalizer with the garbage collector:

		    Quality q = new Quality();
		    Container m = class_symbol.findBestMethod( "dispose", new Vector<Type>(), q );

		    if( m != null && m.Owner != object_type.Clazz ) {
			// dispose method found and it's not Object.dispose() - need to register finalizer
			op = RuntimeFunction.ALLOC_OBJECT_FINALIZE;
		    }
		}
		
		f = state.getRuntimeFunction( op );
		/*
		IO.Std.err.println( "about to emit call __alloc_object" ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue(f);
		*/

		// no PointerType on type here as class is already a pointer type and we want size of pointed to struct here:
		args = { LLVM.Calls.LLVMConstTypeSizeIndirect(getType(state).getLLVMType(state)), vtable };

		/*
		IO.Std.err.println( "args are:\n" ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue(args[0]);
		LLVM.Calls.LLVMDumpValue(args[1]);	       
		*/

		v = callOrInvoke( state, into, f, args );
		v = into.PointerCast( v, getType(state).getLLVMType(state) );
				
		args = ExpressionList.compilePush( arguments,
						   state,
						   v,
						   method.Owner.Type,
						   method.ArgTypes,
						   into,
						   true,
						   false );
		
		compileCall( state, into, null, Op.STATIC_CALL_DISCARD, method, method.DecoratedName, 0, null, args );
		// addDummyExceptionHandlerJump( state, line_number, into );
		    //} else {
		    // IO.Std.err.println( "not calling empty constructor " + method.HumanName + " (" + method.DecoratedName + ")" );
		    // }

		return v; 
            } else {
                if( type != undefined_type ) {
                    error( "cannot new type " + type.dump() + " (K" + getType( state ).TypeKind + ")" );
                } else {
		    error( "cannot new undefined type" );
                    // IO.Std.err.println( "newing undefined type" );
                }
		return ErrorValue( getType(state).getLLVMType(state) );
            }
        }

	get int Depth {
	    if( argument != null ) {
		return argument.Depth + 1;
	    } else if( arguments != null ) {
		return arguments.Depth + 1;
	    } else {
		return 1;
	    }
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "new " );
	    left.print( state, p );
	    if( argument != null ) {
		p.print( "[" );
		argument.print( state, p );
		p.print( "]" );
	    } else {
		p.print( "(" );
		if( arguments != null /* && arguments.Length > 0 */ ) {
		    p.print( " " );
		    arguments.print( state, p );
		    p.print( " " );
		}
		p.print( ")" );
	    }
	}
    }



    class NativeCall extends Expression {
        Identifier name;
        ExpressionList arguments;

	/*
	static String[] pointer_return = {
	    "alloco",
	    "__get_argv",
	    "__get_envp"
	};
	*/

        void init( int line_number, Identifier name, ExpressionList arguments ) {
            super.init( line_number );
            this.name = name;
            this.arguments = arguments;
        }

        void calcType( CompileState state ) {

	    type = new Type( Type.POINTER, new Type( Type.BYTE ) );
	    /*

	    String n = name.getName();
	    for( int i = 0; i < pointer_return.length; i = i + 1 ) {
		if( n.equals( pointer_return[i] ) ) {
		    type = new Type( Type.POINTER, new Type( Type.BYTE ) );			
		    return;
		}
	    }

	    type = new Type( Type.INTEGER );
	    */
        }

	void clear( CompileState state ) {
	    if( arguments != null ) {
		arguments.clear( state );
	    }
	}
	
	void checkTemplates( CompileState state ) {
	    if( arguments != null ) {
		arguments.checkTemplates( state );
	    }
	}

	LLVM.Value getFunction( CompileState state ) {
	    LLVM.Value v;
	    LLVM.Type ft;

	    char ptr n = name.Name.toCString();

	    v = LLVM.Calls.LLVMGetNamedFunction(state.Module, n );
	    if( v == null ) {
		var args = new LLVM.Type[0];
		ft = LLVM.Calls.LLVMFunctionType( LLVM.Calls.LLVMPointerType(LLVM.Calls.LLVMInt8Type() ,0), args.address, 0, 1 );

		v = LLVM.Calls.LLVMAddFunction(state.Module, n, ft);

		/*
		IO.Std.err.print( "NNNN: added native function: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( v );

		IO.Std.err.print( "NNNN: added function type: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( ft );
		*/
	    } else {
		/*
		IO.Std.err.print( "NNNN: existing native function: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpValue( v );

		ft = LLVM.Calls.LLVMTypeOf(v);

		IO.Std.err.print( "NNNN: existing function type: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( ft );
		*/
	    }

	    return v;
	}


        LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    // IO.Std.err.println( "call native function for value: " + name.getName() );
            
	    if( state.WantMarkUnsafe ) {
		state.markCodeUnsafe( CompileState.UNSAFE_NATIVE );
	    }
            if( state.WantWarnUnsafe ) {
                warn( "calling native function " + name.Name );
            }
            
	    var arg_values = ExpressionList.compilePush( arguments, state, null, null, null, into, false, true );
	    var function = getFunction( state );

	    addDummyExceptionHandlerJump( state, line_number, into );
	    return callOrInvoke( state, into, function, arg_values );
        }

        void compileDiscardValue( CompileState state, IRBlock into ) {
	    compileValue( state, into );
	}

	get int Depth {
	    if( arguments != null ) {
		return arguments.Depth + 1;
	    } else {
		return 1;
	    }
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "native." );
	    name.print( state, p );
	    p.print( "(" );
	    if( arguments != null ) {
		p.print( " " );
		arguments.print( state, p );
		p.print( " " );
	    }
	    p.print( ")" );	   
	}
    }


    class MethodCall extends Expression {
        Expression left_value;
        // Identifier name;
        ExpressionList arguments;
        Container method;
	bool compare_operation;
	bool not_result;
	bool super_call;
	Quality quality;
	MethodCall method_call;
	Type proc_type;

        void init( int line_number, Expression left_value, Identifier name, ExpressionList args ) {
            super.init( line_number );
            this.method = null;
            this.arguments = args;
            // this.name = name;
	    
	    if( left_value != null ) {
		// FIXME: sense of qualifies is probably backwards...
		name.qualifies( left_value );
	    }

            this.left_value = name;
        }

        void init( int line_number, Expression left_value, ExpressionList args ) {
            super.init( line_number );
            this.method = null;
            this.arguments = args;
            this.left_value = left_value;
        }



	void clear( CompileState state ) {
	    // IO.Std.err.println( "method call clear: " + name );
	    super.clear( state );
	    method = null;
	    compare_operation = false;
	    not_result = false;
	    super_call = false;
	    method_call = null;
	    proc_type = null;

	    /*
	    if( name != null ) {
		name.clear( state );
	    }
	    */

	    if( left_value != null ) {
		left_value.clear( state );
	    }

	    if( arguments != null ) {
		arguments.clear( state );
	    }

	    quality = null;
	}

	void checkTemplates( CompileState state ) {
	    /*
	    if( name != null ) {
		name.checkTemplates( state );
	    }
	    */

	    if( left_value != null ) {
		left_value.checkTemplates( state );
	    }

	    if( arguments != null ) {
		arguments.checkTemplates( state );
	    }
	}

        bool isSuperConstructorCall( CompileState state ) {
            // getType( state );
            
            // Expression left = name.LeftValue;
            
	    if( !left_value.isIdentifier(state) ) {
		return false;
	    }

	    var name = cast Identifier(left_value);

	    if( name.Name =~ "init" && left_value.isThis( state ) || left_value.isSuper( state ) ) {
		return true;
	    } else {
		return false;
	    }
        }

	get bool IsEmpty {
	    bool result = isSuperConstructorCall( CompileState.Instance );

	    return result;
	}

	void setIsCompareOperation( bool c ) {
	    compare_operation = c;
	}

	void setNotResult( bool nr ) {
	    not_result = nr;
	}

	get Quality Quality {
	    // get previously calculated overload match quality - for ArithExpression
	    return quality;
	}

	get Type Type {
	    // get previously calculated type - for ArithExpression
	    return type;
	}

	void calcType( CompileState state ) {
	    calcType( state, false );
	}

	void calcType( CompileState state, bool quiet ) {
	    if( left_value == null ) {
		IO.Std.err.println( "left value is null: " + this );
	    }
	   
	    // quiet => internally constructed method call and hence cannot be a proc reference
	    // otherwise check if left value refers to a method identifier (rather than a proc reference
	    // or some other kind of symbol):
	    if( quiet || left_value.isSuper(state) || left_value.isMethod(state) ) {
		calcTypeNormal( state, quiet );
	    } else {
		calcTypeProcReference( state );
	    }
	}

        void calcTypeNormal( CompileState state, bool quiet ) {
            Symbol symbol = null;
            String arg_string = null;
	    Type t;

            Vector<Type> arg_types = null;
            if( arguments != null ) {
                arg_types = arguments.getTypes( state );
                // IO.Std.err.println( "method call arguments: " + arg_types );
            }

	    var name = cast Identifier(left_value);
	    var left_value = name.LeftValue;
	    
            if( left_value != null && left_value.isThis( state ) ) {
                // IO.Std.err.println( "left value is this" );
                left_value = null;
            }

            /*
            if( left_value != null ) {
                IO.Std.err.println( "method call left_value: " + left_value.getType(state) );
            }
            */


	    quality = new Quality();
            if( left_value != null ) {
                type = left_value.getType( state );
		if( type.TypeKind == Type.SUPER ) {
		    super_call = true;
		} else if( type.CanTreatAsObject ) {
		    type = type.getBoxType(state);
		}

                if( type.TypeKind == Type.ERROR ) {
                    symbol = undefined_method;
                } else if( type.TypeKind != Type.CLASS && type.TypeKind != Type.SUPER ) {
                    ExpressionList wrap_arguments = new ExpressionList( line_number );
		    t = type.getBoxType(state);

                    if( t != null ) {
			wrap_arguments.add( left_value );

			if( arguments != null && arguments.List.Length > 0 ) {
			    foreach( Expression e; arguments.List.elements() ) {
				wrap_arguments.add(e);
			    }
			}
			left_value = new WrapTypeAsExpression(line_number,t);

                        method_call = new MethodCall( line_number, left_value, new Identifier(line_number,name.Name), wrap_arguments );

                        method_call.calcType( state, true );
                        type = method_call.Type;
                        quality = method_call.Quality;
                        if( quality == null ) {
                            method = undefined_method;
                            if( !quiet ) {
                                arg_string = dumpArguments( arg_types );
                                error( "method " + name.Name + "(" + arg_string + ") is not defined in " + type );
                            }
                            type = undefined_type;
                        }

                        return;
                    } else {
                        symbol = undefined_method;
                        quality = null;
                        type = undefined_type;
                        if( quiet ) {
                            return;
                        } else {
                            error( "cannot call method " + name.Name + " in " + type.dump() );
                            return;
                        }
                    }

                } else {
                    symbol = type.findBestMethod( name.Name, arg_types, quality );
                }
            } else {
                // IO.Std.err.println( "searching current class " + state.CurrentClass + " for best match: " + name.Name + "(" + arg_types + ")" );

                symbol = state.findBestMethod( name.Name, arg_types, quality );
            }

            if( symbol == null ) {
                quality = null;
                method = undefined_method;
                type = undefined_type;

                if( quiet ) {
                    return;
                }

                arg_string = dumpArguments( arg_types );

                if( left_value != null ) {
                    error( "method " + name.Name + "(" + arg_string + ") is not defined in " + left_value.getType( state ).dump() );
                } else {
                    error( "method " + name.Name + "(" + arg_string + ") is not defined in " + state.CurrentClass.HumanName );
                }

            } else if( symbol != null ) {
                if( symbol.Kind & Symbol.FLAG_METHOD == 0 ) {
                    type = undefined_type;
                    quality = null;
                    method = undefined_method;
                    if( quiet ) {
                        return;
                    }

                    error( name.Name + " is not a method" );
                } else {
                    method = cast<Container>( symbol );
                    if( method == null ) {
                        throw new Exception( "oops: method symbol " + symbol.HumanName + " is not a container" );
                    }
                    type = method.Type;
                }

                if( quality.quality < Type.QUALITY_GOOD ) {
                    arg_string = dumpArguments( arg_types );
                    String resolve_string = dumpArguments( method.ArgTypes );

                    if( !quiet && state.WantWarnResolve ) {
                        warn( "call to " + name.Name + "(" + arg_string +
                              ") resolves to " + method.HumanName + "(" + resolve_string + ") match quality " + quality.quality );
                    }
                }

                /*
                IO.Std.err.println( "method call resolves to: " + symbol );
                IO.Std.err.println( "IIIIII: kind is " + symbol.Kind + " versus " + Symbol.STATIC_METHOD );
                */
                checkAccess( symbol, state );
            }
	} 

    
	void calcTypeProcReference( CompileState state ) {
            Vector<Type> arg_types = null;
            if( arguments != null ) {
                arg_types = arguments.getTypes( state );
		// IO.Std.err.println( "method call arguments: " + arg_types );
            }

	    // IO.Std.err.println( "calling though something other than a method identifier, is it a proc reference? " + new System.Backtrace() );
	    // IO.Std.err.println( "" + line_number + ": left value is: " + left_value );

	    proc_type = left_value.getType( state );
	    
	    // IO.Std.err.println( "left value type is: " + proc_type );

	    if( proc_type.TypeKind != Type.PROC ) {
		if( proc_type.TypeKind == Type.CLASS && proc_type.Clazz.Template == ParseTree.proc_type.Clazz ) {
		    // IO.Std.err.println( "de-method on System.Proc<P>, attempt to determine proc type so we can call it..." );
		    
		    // what is type of P (proc ref) in this specialization of System.Proc?
		    proc_type = proc_type.getActualArgumentType( state, "P" );
		    
		    // IO.Std.err.println( "proc type now: " + proc_type );
		} else {
		    if( left_value.isIdentifier(state) ) {
			Identifier n = cast Identifier(left_value);
			Symbol s = n.getSymbol(state,false,Symbol.FIND_ANY);
			if( s != null ) {
			    int k = s.Kind;
			    
			    if( k & Symbol.FLAG_METHOD != 0 ) {
				error( "strange: " + s.OwnerHumanName + "." + s.Name + " is a method but cannot call it" );
			    } else {
				String kind_s = "";
				String scope_s = "";
				
				if( k & Symbol.FLAG_VARIABLE != 0 ) {
				    kind_s = "variable";
				} else if( k & Symbol.FLAG_CLASS != 0 ) {
				    kind_s = "container";
				} else if( k & Symbol.FLAG_ACCESSOR != 0 ) {
				    kind_s = "accessor";
				} else if( k > Symbol.ATTRIBUTE ) {
				    kind_s = "attribute";
				}
				
				if( k & Symbol.FLAG_STATIC != 0 ) {
				    scope_s = "static ";
				} else if( k & Symbol.FLAG_LOCAL != 0 ) {
				    scope_s = "local ";
				    
				}
				
				
				error( s.OwnerHumanName + "." + s.Name + " is a " + scope_s + kind_s + " not a method" );
			    }
			} else {
			    error( "" + proc_type + " is not a method" );
			}
		    } else {
			error( "" + proc_type + " is not a method" );
		    }
		    proc_type = null;
		    type = undefined_type;
		    return;
		}
	    }

	    if( !proc_type.Clazz.matches( arg_types, false ) ) {
                var arg_string = dumpArguments( arg_types );		
		error( "argument types do not match: " + proc_type + " vesus(" + arg_string + ")" );
		proc_type = null;
		type = undefined_type;
		return;
	    }

	    type = proc_type.Clazz.Type;
	    // IO.Std.err.println( "call through proc reference " + proc_type + " returns type " + type );
	}

        LLVM.Value compileValue( CompileState state, IRBlock into ) {
            return compileValue( state, into, true );
        }

        void compileDiscardValue( CompileState state, IRBlock into ) {
            compileValue( state, into, false );
        }

        LLVM.Value compileValue( CompileState state, IRBlock into, bool need_value ) {
	    int tt, ta, tr;

	    /*
	    IO.Std.err.println( "call method, current class: " + state.CurrentClass );
	    if( type != null ) {		
	    `IO.Std.err.println( "QQQQQQ: method call type not null on entry: " + type );
	    }
	    if( method != null ) {
		IO.Std.err.println( "QQQQQQ: method call method not null on entry: " + method );
	    }
	    */

            getType( state );

	    if( method_call != null ) {
		return method_call.compileValue( state, into, need_value );
	    }

            bool load_this = false;
	    bool proc_call = proc_type != null;

            if( method == undefined_method ) {
		return ErrorValue();
            } else if( method == null && !proc_call ) {
                // result of compile error
		error( "no method here" );
		return ErrorValue();
            }

	    Identifier name;
	    var left_value = this.left_value;

	    if( !proc_call ) {
		name = cast Identifier(left_value);
		left_value = name.LeftValue;
	    
		// IO.Std.err.println( "call method " + method.Owner.HumanName + " " + method.Name );

		if( !super_call && left_value != null && !left_value.isThis( state ) ) {
		    // IO.Std.err.println( "IIIIII: load this" );
		    load_this = true;
		}
	    }
            
            int size = 0;
	    /*
            if( method.getKind() == Symbol.INSTANCE_METHOD ) {
                size = 4;                       // FIXME: not always
            }
	    */
            
            int flags = LOAD_FLAG_ADDRESS;
            
            if( !need_value ) {
                flags = flags | LOAD_FLAG_DISCARD;
            }
            
            LLVM.Value t = null;

	    if( proc_call ) {
		flags = flags | LOAD_FLAG_PROC_CALL;
                t = left_value.compileValue( state, into );

		// IO.Std.err.println( "compile proc call on type: " + proc_type.SubType );
                t = compileLoad( state, into, null, null, arguments, proc_type.Clazz.Type, proc_type.Clazz.ArgTypes, t, flags, null );

		// IO.Std.err.println( "block now:\n" + into );

	    } else if( left_value != null && !left_value.isClass(state) /* && !left_value.isType(state) */ ) {
		// IO.Std.err.println( "call on non-class left value: " + left_value );
		/*

		if( left_value.isType(state) ) {
		    IO.Std.err.println( "will fail: left value is type: " + left_value );
		}
		*/

		if( !super_call ) {
		    t = left_value.compileValue( state, into );
		} else {
		    // avoid a redundant null check - let compileLoad load 'this' value, so it knows it's guaranteed non-null
		    t = null;
		}

		// FIXME: this is a bad place for this but MethodCall doesn't make it easy
		// to do this in the caller:
		if( compare_operation ) {
		    /*
		    lt = TempFactory.nextLabel();

		    tr = TempFactory.nextTemp();

		    var a = arguments[0].compileValue(state,into);

		    t = makeObjectEquals(t, a);
		    // don't not the result here - caller must do it:

		    into.add( new ITree( line_number, Op.OBJ_EQ, 0,
					 new ITree( line_number, Op.PAIR, Machine.WORD,
						    t, a ),
					 new ITree( line_number, Op.TEMP, 1, tr ),
					 lt
					 )
			      );
		    // }
		    */
		}

                Container super_class = null;
                if( super_call ) {
                    super_class = left_value.getType(state).Clazz;
		    // IO.Std.err.println( "super call..." );
                }

		/*
		IO.Std.err.println( "method call calling load: " + method );
		IO.Std.err.println( "IIIIII: kind is " + method.Kind + " versus " + Symbol.STATIC_METHOD );
		*/

		// IO.Std.err.println( "DDDD: arg types: " + method.ArgTypes );

                t = compileLoad( state, into, method, null, arguments, null, method.ArgTypes, t, flags, super_class );

		if( compare_operation ) {
		    /*
		    into.add( makeStoreTemporary( tr, 1, t ) );
		    into.add( new ITree( line_number, Op.LABEL, 0, lt ) );

		    t = makeLoadTemporary( tr, 1 );
		    */
		}
            } else if( left_value != null ) {
		// Std.err.println( "call B..." );

		// FIXME: probably should be method.IsStatic here:
                if( left_value.isClass( state ) ) {
                    flags = flags | LOAD_FLAG_STATIC;
		}

		if( left_value.isClass(state) != method.IsStatic ) {
		    IO.Std.err.println( "isClass probably wrong here: " + method.HumanName );
		}
		// IO.Std.err.println( "DDDD: arg types: " + method.ArgTypes );

                t = compileLoad( state, into, method, null, arguments, null, method.ArgTypes, null, flags, null );
            } else {
		// Std.err.println( "call C..." );
                if( state.CurrentMethod.IsStatic ) {
                    flags = flags | LOAD_FLAG_STATIC;
		}
		// IO.Std.err.println( "DDDD: arg types: " + method.ArgTypes );

                t = compileLoad( state, into, method, null, arguments, null, method.ArgTypes, t, flags, null );
            }
            
	    /*
            int temp = 0;
            if( need_value ) {
                temp = TempFactory.nextTemp();
                into.add( makeStoreTemporary( temp, Machine.WORD, t ) );
            } else {
                into.add( t );
            }
	    if( size > 0 ) {
		into.add( new ITree( line_number, Op.RELEASE, 0, size ) );
	    }
            if( need_value ) {
                return makeLoadTemporary( temp, getType( state ).RegSize );
            } else {
                return null;
            }
	    */
	    return t;
        }


        void dump( CompileState state, StringBuffer buffer ) {
	    if( left_value != null ) {
		left_value.dump( state, buffer );
	    } else {
		buffer.append( "<no left value>" );
	    }

            buffer.append( '(' );
            
            if( arguments != null ) {
                arguments.dump( state, buffer );
            }
            
            buffer.append( ')' );
        }

	/*
        void declareSymbols( CompileState state ) {
	    state.CurrentMethod.markNotLeaf();
        }
	*/

	String toString() {
	    StringBuffer result = new StringBuffer();
	    dump( CompileState.getInstance(), result );

	    return result;
	}

	get int Depth {
	    int result = left_value.Depth;
	    if( arguments != null ) {
		int d = arguments.Depth;
		if( d > result ) {
		    result = d;
		}
	    }

	    return result + 1;
	}

	void print( CompileState state, Printer p ) {
	    // getType(state);

	    pl(p);
	    /*
	      not needed - left value qualifies name after calcType called:
	    if( left_value != null ) {
		left_value.print( state, p );
		p.print( "." );
	    }
	    */
	    left_value.print( state, p );
	    p.print( "(" );
	    if( arguments != null ) {
		p.print( " " );
		arguments.print( state, p );
		p.print( " " );
	    }
	    p.print( ")" );	   
	}
    }

    class ProcRef extends Expression {
	Expression left;
	TypeExpr return_type;
	TypeExprList arguments;
	Container method;
	bool virtual_call;

	void init( int line_number, Expression left, TypeExpr return_type, TypeExprList arguments ) {
	    super.init( line_number );
	    this.left = left;
	    this.return_type = return_type;
	    this.arguments = arguments;
	}

	void clear( CompileState state ) {
	    super.clear(state);

	    method = null;
	    virtual_call = false;
	    left.clear(state);
	    return_type.clear(state);
	    arguments.clear(state);
	}

	void checkTemplates( CompileState state ) {
	    left.checkTemplates(state);
	    return_type.checkTemplates(state);
	    arguments.checkTemplates(state);
	    calcType(state, true);
	    if( type != null ) {
		type.getBoxType(state);
	    }
	    type = null;
	}

	void calcType( CompileState state ) {
	    calcType(state,false);
	}

	void calcType( CompileState state, bool quiet ) {
            var arg_types = arguments.getTypes( state ); // regular arguments
	    String arg_string;

	    type = state.findProcType( return_type.parseType(state), arg_types );

	    if( quiet ) {
		return;
	    }

	    if( left == null || !left.isMethod(state) ) {
		error( "proc must qualify a method name" );
		type = undefined_type;
		return;
	    }

	    IO.Std.err.println( "calc type: " + this );

	    Type t;

	    var name = cast Identifier(left);
	    var left_value = name.LeftValue;
	    Vector<Type> arg_types_s;

	    Symbol symbol;

            var q0 = new Quality();
	    var q1 = new Quality();
	    Container s0, s1;
	    Container c;

	    Type arg0_type = null;

	    // find first argument type and left-1 shifted arguments in order to search for a 
	    // virtual method that could match this proc type. For example Test Test.add(Test) would
	    // match Test proc add(Test,Test) this way. 
	    if( arg_types.Length > 0 ) {
		IO.Std.err.println( "preparing virtual method lookup arguments..." );

		arg_types_s = new Vector<Type>();
		foreach( Type u; arg_types.elements() ) {
		    if( arg0_type == null ) {
			// remove first argument from list. will use to attempt to locate virtual method
			arg0_type = u;
			IO.Std.err.println( "arg 0 is: " + arg0_type );
		    } else {
			// include subsequent arguments in list
			arg_types_s.add(u);
			IO.Std.err.println( "arg n is: " + u );
		    }
		}
	    }

            if( left_value != null ) {
                t = left_value.getType( state );
		IO.Std.err.println( "left value type is: " + t );
			
                if( t.TypeKind == Type.ERROR ) {
                    symbol = undefined_method;
		    return;
		} else if( t.TypeKind != Type.CLASS ) {
		    var r = t.getBoxType(state);
		    if( r == null ) {
			error( "cannot search for method " + name + " in " + t );
			type = undefined_type;
			return;
		    } else {
			t = r;
		    }
                }

		if( t != null ) {
		    IO.Std.err.println( "search for method " + name + " in " + t );
		    s0 = t.findBestMethod( name.Name, arg_types, q0 );

		    IO.Std.err.println( "result symbol: " + s0 );
		}		    
	    } else {
		IO.Std.err.println( "no left value, look up in current class..." );
		t = state.CurrentClass.Type;

		IO.Std.err.println( "left value type is: " + t );

                IO.Std.err.println( "searching current class " + state.CurrentClass + " for best match: " + name.Name + "(" + arg_types + ")" );

                s0 = state.findBestMethod( name.Name, arg_types, q0 );
            }

	    if( t != null && arg0_type != null ) {
		IO.Std.err.println( "XXXX: t is: " + t + ", arg0 is: " + arg0_type + "..." );

		if( arg0_type.isAssignableFrom(t) ) {
		    c = t.Clazz;
		    if( c == null ) {
			IO.Std.err.println( "type has no container, try box type: " );
		    
			c = t.getBoxType(state).Clazz;
		    }

		    if( c != null ) {
			IO.Std.err.println( "will consider virtual methods in " + c.HumanName + " with args: " + arg_types_s );
			s1 = c.findBestMethod( name.Name, arg_types_s, q1 );
			
			if( s1 != null && s1.IsStatic ) {
			    // IO.Std.err.println( "no good, is static" );
			    s1 = null;
			}
		    } else {
			IO.Std.err.println( "weird: assignable but no class in: " + t );
		    }
		}
	    }

	    var quality = q0;
	    if( s0 != null && s1 != null ) {
		// IO.Std.err.println( "compare " + s0.HumanName + " (" + q0 + ") and " + s1.HumanName + " (" + q1 + ")..." );
		if( q0 =~ q1 ) {
		    warn( "preferring " + s0.HumanName + " over " + s1.HumanName + " (" + q0 + "==" + q1 + ")"  );
		    symbol = s0;
		} else if( q0 > q1 ) {
		    // IO.Std.err.println( "choose: " + s0.HumanName + " (" + q0 + ">" + q1 + ")" );
		    symbol = s0;
		} else {
		    // IO.Std.err.println( "choose: " + s1.HumanName + " (" + q0 + "<=" + q1 + ")" );
		    symbol = s1;
		    quality = q1;
		}		    		    
	    } else if( s0 != null ) {
		// IO.Std.err.println( "only choice: " + s0.HumanName );
		symbol = s0;
	    } else {
		/*
		if( s1 != null ) {
		    IO.Std.err.println( "only choice: " + s1.HumanName );
		}
		*/
		symbol = s1;
		quality = q1;
	    }

	    virtual_call = symbol == s1;

	    // IO.Std.err.println( "virtual call: " + virtual_call );

            if( symbol == null ) {
                type = undefined_type;

                arg_string = dumpArguments( arg_types );

                if( left_value != null ) {
                    error( "method " + name.Name + "(" + arg_string + ") is not defined in " + left_value.getType( state ).dump() );
                } else {
                    error( "method " + name.Name + "(" + arg_string + ") is not defined in " + state.CurrentClass.HumanName );

                }
		return;
            } else if( symbol.Kind & Symbol.FLAG_METHOD == 0 ) {
		type = undefined_type;
		error( name.Name + " is not a method" );
		return;
            }

	    // IO.Std.err.println( "proc bound to " + symbol.HumanName );

	    method = cast<Container>( symbol );
	    if( method == null ) {
		throw new Exception( "oops: method symbol " + symbol.HumanName + " is not a container" );
	    }

	    if( quality.quality < Type.QUALITY_GOOD ) {
		arg_string = dumpArguments( arg_types );
		String resolve_string = dumpArguments( method.ArgTypes );
		
		if( state.WantWarnResolve ) {
		    warn( "reference to " + name.Name + "(" + arg_string +
			  ") resolves to " + method.HumanName + "(" + resolve_string + ") match quality " + quality.quality );
		}
	    }

	    /*
	      IO.Std.err.println( "method call resolves to: " + symbol );
	      IO.Std.err.println( "IIIIII: kind is " + symbol.Kind + " versus " + Symbol.STATIC_METHOD );
	    */
	    checkAccess( symbol, state );	    
	}

	LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    var ty = getType( state );

	    if( method == null || method == undefined_method ) {
		return ErrorValue(ty.getLLVMType(state));
	    }

	    // var load_this = false;
	    Identifier name;
	    var left_value = left;

	    name = cast Identifier(left_value);
	    left_value = name.LeftValue;

	    /*
	    if( left_value != null && !left_value.isThis( state ) && !left_value.isSuper( state ) ) {
		IO.Std.err.println( "IIIIII: load this" );
		load_this = true;
	    }
	    */
	    
	    
	    LLVM.Value t = null;

	    if( virtual_call ) {
		// IO.Std.err.println( "virtual call..." );
		t = compileLoadSlotRef( state, into, method, type );
	    } else if( !method.IsStatic ) { // !left_value.isClass( state ) && !left_value.isType(state) ) {
		// IO.Std.err.println( "call A: " + left_value + " (" + left_value.Class.Name + ")" );

		if( left_value != null ) {
		    Container scope = left_value.getType(state).Clazz;
		    Container super_class = null;
		    if( left_value.getType(state).TypeKind == Type.SUPER ) {
			warn( "proc reference to method in super class: may be broken, method is: " + method.HumanName );
			super_class = scope;
		    }

		    if( left_value.isClass(state) || left_value.isType(state) ) {
			error( "left value is not an object" );
			return ErrorValue();
		    }

		    t = left_value.compileValue( state, into );
		} else {
		    if( state.CurrentMethod == null || state.CurrentMethod.IsStatic ) {
			error( "cannot bind proc reference bound to 'this' here" );
			return ErrorValue();
		    }
		}

		
		/*
                IO.Std.err.println( "method call calling load: " + method );
                IO.Std.err.println( "IIIIII: kind is " + method.Kind + " versus " + Symbol.STATIC_METHOD );
		*/

                t = compileLoadProcRef( state, into, t, method, type /*, method.ArgTypes, t, instance, super_class */ );
            } else {

                // IO.Std.err.println( "call B..." );
                if( left_value != null && !left_value.isClass( state ) && !left_value.isType(state) ) {
		    // IO.Std.err.println( "left value is not class..." );
                    // if( method.IsStatic ) {
		    warn( "cannot bind " + left_value + " to static method " + method.HumanName );
			//    return ErrorValue();
			// }
			// t = left_value.compileValue( state, into );
                }

                t = compileLoadProcRef( state, into, null, method, type /*, method.ArgTypes, null, instance, null */);
            }
	
	    return t;
	}
	
    }
}