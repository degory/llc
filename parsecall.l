
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;

    use Gen.ITree;
    use Gen.IBlock;
    use Gen.ILabel;
    use Gen.IString;
    use Gen.Machine;
    use Gen.TempFactory;
    use Gen.MBitSet;

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

                Generic.Vector<Type> arg_types = null;
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

	void checkInline( CompileState state ) {
	    left.checkInline( state );
	    if( argument != null ) {
		argument.checkInline( state );
	    }
	    if( arguments != null ) {
		arguments.checkInline( state );
	    }
	}

        ITree compileValue( CompileState state, IBlock into ) {
            Container class_symbol = null;
            Type t = getType(state);

	    int op;

	    ITree vtable;

            if( t.TypeKind == Type.VECTOR ) {
                Type st = t.SubType;
		op = Op.NEW_GENERIC_ARRAY;

		Container c = t.getBoxType(state).Clazz;

		vtable = loadVTable( state, c );

		return new ITree( line_number, op, 0,
				  argument.compileValue( state,
							 into ),
				  vtable,
				  st.Size );

            } else if( t.TypeKind == Type.CLASS ) {
                // int temp = TempFactory.nextTemp();
		int result = TempFactory.nextTemp();

                class_symbol = getType(state).Clazz;

		into.add( new ITree( line_number, Op.COMMENT, 0, "new " + class_symbol.DecoratedName + " size " + class_symbol.Size + " into T" + result ) );

		op = Op.NEW;

		if( class_symbol.IsStruct ) {
		    vtable = new ITree( line_number, Op.CONST, Machine.WORD, "0" );
		} else {
		    vtable = loadVTable( state, class_symbol );

		    // new ITree( line_number, Op.GLOBAL, Machine.WORD, 

		    // does this class override Object.finalize()? If so need to register it's 
		    // finalizer with the garbage collector:

		    Quality q = new Quality();
		    Container m = class_symbol.findBestMethod( "dispose", new Generic.Vector<Type>(), q );

		    if( m != null && m.Owner != object_type.Clazz ) {
			// dispose method found and it's not Object.dispose() - need to register finalizer
			op = Op.NEW_FINALIZE;
		    }
		}

                into.add(
                         makeStoreTemporary( result, Machine.WORD,
                                             new ITree( line_number, op, 0,
							new ITree( line_number, Op.CONST, Machine.WORD, class_symbol.Size ),
                                                        vtable
                                                        )
                                             )
                         );

		/*
		into.add( new ITree( line_number, Op.COMMENT, 0, "save allocated object as T" + result ) );

		into.add( makeStoreTemporary( result, Machine.WORD, makeLoadTemporary( temp, Machine.WORD ) ) );
		*/
		// if( (arguments.List != null && arguments.List.Length > 0) || !method.AreAllOverridesEmpty ) {
		    ITree thiz = makeLoadTemporary( result, Machine.WORD );

		    // into.add( new ITree( line_number, Op.COMMENT, 0, "thiz: " + thiz ) );
		
		    int size = 0;

		    Util.IntVector inline_args;
		    if( state.InlineOK && method.IsInline ) {
			inline_args = new Util.IntVector();
		    }


		    size = ExpressionList.compilePush( arguments,
						       state,
						       thiz,
						       method.ArgTypes,
						       into,
						       true,
						       false,
						       inline_args);

		    into.add( new ITree( line_number, Op.COMMENT, 0, "constructor " + method.DecoratedName ) );
		    
		    compileCall( state, into, null, Op.STATIC_CALL_DISCARD, method, method.DecoratedName, 0, size, inline_args );
		    addDummyExceptionHandlerJump( state, line_number, into );
		    //} else {
		    // IO.Std.err.println( "not calling empty constructor " + method.HumanName + " (" + method.DecoratedName + ")" );
		    // }

		into.add( new ITree( line_number, Op.COMMENT, 0, "new result is T" + result ) );

		//// IO.Std.err.println( "CCCCCCC: new expression: " + into );

                return makeLoadTemporary( result, Machine.WORD );
            } else {
                if( type != undefined_type ) {
                    error( "cannot new type " + type.dump() + " (K" + getType( state ).TypeKind + ")" );
                } else {
		    error( "cannot new undefined type" );
                    // IO.Std.err.println( "newing undefined type" );
                }
                return new ITree( line_number, Op.ERROR, 0 );           
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

	void checkInline( CompileState state ) {
	    throw new CannotInlineException();
	}

        ITree compileValue( CompileState state, IBlock into ) {
            int count = 0;

	    // IO.Std.err.println( "call native function for value: " + name.getName() );
            
	    if( state.WantMarkUnsafe ) {
		state.markCodeUnsafe( CompileState.UNSAFE_NATIVE );
	    }
            if( state.WantWarnUnsafe ) {
                warn( "calling native function " + name.Name );
            }
            
	    count = ExpressionList.compilePush( arguments, state, null, null, into, false, true, null );
            
            int t = TempFactory.nextTemp();
            
            into.add( new ITree( line_number, Op.EXTERN, 0, name.Name ) );

	    return compileCall( state, into, null, Op.STATIC_CALL, null, name.Name, 0, count, null );
        }

        void compileDiscardValue( CompileState state, IBlock into ) {
            int count = 0;

	    // IO.Std.err.println( "call native function for value: " + name.getName() );
            
	    if( state.WantMarkUnsafe ) {
		state.markCodeUnsafe( CompileState.UNSAFE_NATIVE );
	    }
            if( state.WantWarnUnsafe ) {
                warn( "calling native function " + name.Name );
            }
            
	    count = ExpressionList.compilePush( arguments, state, null, null, into, false, true, null );
            
            into.add( new ITree( line_number, Op.EXTERN, 0, name.Name ) );

	    compileCall( state, into, null, Op.STATIC_CALL_DISCARD, null, name.Name, 0, count, null );
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

            Generic.Vector<Type> arg_types = null;
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
            Generic.Vector<Type> arg_types = null;
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

        ITree compileValue( CompileState state, IBlock into ) {
            return compileValue( state, into, true );
        }

        void compileDiscardValue( CompileState state, IBlock into ) {
            compileValue( state, into, false );
        }

        ITree compileValue( CompileState state, IBlock into, bool need_value ) {
	    int tt, ta, tr;
	    ILabel lt;
	    /*
	    IO.Std.err.println( "call method, current class: " + state.CurrentClass );
	    if( type != null ) {		
		IO.Std.err.println( "QQQQQQ: method call type not null on entry: " + type );
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
                return new ITree( line_number, Op.ERROR, 0 );
            } else if( method == null && !proc_call ) {
                // result of compile error
		error( "no method here" );
                return new ITree( line_number, Op.ERROR, 0 );
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
            
            ITree t = null;

	    if( proc_call ) {
		flags = flags | LOAD_FLAG_PROC_CALL;
                t = left_value.compileValue( state, into );

		// IO.Std.err.println( "compile proc call on type: " + proc_type );
                t = compileLoad( state, into, null, arguments, proc_type.Clazz.ArgTypes, t, Machine.WORD, flags, null );

		// IO.Std.err.println( "block now:\n" + into );

	    } else if( left_value != null && !left_value.isClass( state ) ) {
		// Std.err.println( "call A..." );
                t = left_value.compileValue( state, into );

		// FIXME: this is a bad place for this but MethodCall doesn't make it easy
		// to do this in the caller:
		if( compare_operation ) {
		    // check for null left and compare against first argument so
		    // null =~ value does not fault:
		    lt = TempFactory.nextLabel();

		    tr = TempFactory.nextTemp();

		    if( !t.isPrettySimple() ) {
			tt = TempFactory.nextTemp();
			into.add( makeStoreTemporary( tt, Machine.WORD, t ) );
			t = makeLoadTemporary( tt, Machine.WORD );
		    }

		    ITree a = arguments[0].compileValue(state,into);

		    if( !a.isPrettySimple() ) {
			ta = TempFactory.nextTemp();		    
			into.add( makeStoreTemporary( ta, Machine.WORD, a ) );
			arguments[0] = new LoadTemporary( line_number, arguments[0].getType(state), ta );
			a = makeLoadTemporary( ta, Machine.WORD );
		    }

		    into.add( new ITree( line_number, Op.COMMENT, 0,
					 "reference equality and null check prior to calling opEquals" ) );

		    // don't not the result here - caller must do it:
		    /*
		    if( not_result ) {
			into.add( new ITree( line_number, Op.OBJ_NE, 0,
					     new ITree( line_number, Op.PAIR, 8,
							t, a ),
					     new ITree( line_number, Op.TEMP, 1, tr ),
					     lt
					     )
				  );
              	    } else { */
		    into.add( new ITree( line_number, Op.OBJ_EQ, 0,
					 new ITree( line_number, Op.PAIR, Machine.WORD,
						    t, a ),
					 new ITree( line_number, Op.TEMP, 1, tr ),
					 lt
					 )
			      );
		    // }

		}

                Container super_class = null;
                if( super_call ) {
                    super_class = left_value.getType(state).Clazz;
                }

		/*
		IO.Std.err.println( "method call calling load: " + method );
		IO.Std.err.println( "IIIIII: kind is " + method.Kind + " versus " + Symbol.STATIC_METHOD );
		*/

                t = compileLoad( state, into, method, arguments, method.ArgTypes, t, Machine.WORD, flags, super_class );

		if( compare_operation ) {
		    into.add( makeStoreTemporary( tr, 1, t ) );
		    into.add( new ITree( line_number, Op.LABEL, 0, lt ) );

		    t = makeLoadTemporary( tr, 1 );
		}
            } else if( left_value != null ) {
		// Std.err.println( "call B..." );
                if( left_value.isClass( state ) ) {
                    flags = flags | LOAD_FLAG_STATIC;
		}

                t = compileLoad( state, into, method, arguments, method.ArgTypes, null, Machine.WORD, flags, null );
            } else {
		// Std.err.println( "call C..." );
                if( state.CurrentMethod.IsStatic ) {
                    flags = flags | LOAD_FLAG_STATIC;
		}

                t = compileLoad( state, into, method, arguments, method.ArgTypes, t, Machine.WORD, flags, null );
            }
            
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
	TypeExprList arguments;
	Container method;

	void init( int line_number, Expression left, TypeExprList arguments ) {
	    super.init( line_number );
	    this.left = left;
	    this.arguments = arguments;
	}

	void clear( CompileState state ) {
	    super.clear(state);

	    method = null;
	    left.clear(state);
	    arguments.clear(state);
	}

	void checkTemplates( CompileState state ) {
	    left.checkTemplates(state);
	    arguments.checkTemplates(state);

	}

	void calcType( CompileState state ) {
	    if( !left.isMethod(state) ) {
		error( ".proc() must qualify a method name" );
		type = undefined_type;
		return;
	    }

            var arg_types = arguments.getTypes( state );
	    String arg_string;

	    var name = cast Identifier(left);
	    var left_value = name.LeftValue;

	    Symbol symbol;

            var quality = new Quality();
            if( left_value != null ) {
                type = left_value.getType( state );

                if( type.TypeKind == Type.ERROR ) {
                    symbol = undefined_method;
		    return;
		} else if( type.TypeKind != Type.CLASS ) {
		    error( "cannot search for method " + name + " in " + type );
		    type = undefined_type;
		    return;
                }

		symbol = type.findBestMethod( name.Name, arg_types, quality );
            } else {
                // IO.Std.err.println( "searching current class " + state.CurrentClass + " for best match: " + name.Name + "(" + arg_types + ")" );

                symbol = state.findBestMethod( name.Name, arg_types, quality );
            }

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

	    method = cast<Container>( symbol );
	    if( method == null ) {
		throw new Exception( "oops: method symbol " + symbol.HumanName + " is not a container" );
	    }

	    type = state.findProcType( method.Type, method.ArgTypes );

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

        ITree compileValue( CompileState state, IBlock into ) {
            getType( state );

            if( method == null || method == undefined_method ) {
                return new ITree( line_number, Op.ERROR, 0 );
            }

	    var load_this = false;
	    Identifier name;
	    var left_value = left;

	    name = cast Identifier(left_value);
	    left_value = name.LeftValue;
	    

	    // IO.Std.err.println( "call method " + method.Owner.HumanName + " " + method.Name );

	    if( left_value != null && !left_value.isThis( state ) && !left_value.isSuper( state ) ) {
		// IO.Std.err.println( "IIIIII: load this" );
		load_this = true;
	    }
            
            int size = 0;
	    /*
            if( method.getKind() == Symbol.INSTANCE_METHOD ) {
                size = 4;                       // FIXME: not always
            }
	    */
            
	    bool instance = true;
                        
            ITree t = null;

	    if( left_value != null && !left_value.isClass( state ) ) {
		// Std.err.println( "call A..." );
                t = left_value.compileValue( state, into );

                Container scope = left_value.getType(state).Clazz;
                Container super_class = null;
                if( left_value.getType(state).TypeKind == Type.SUPER ) {
                    super_class = scope;
                }

		if( method.IsStatic ) {
		    error( "cannot make bound reference to static method here" );
		    return new ITree( 0, Op.ERROR, 0 );
		}

		/*
		IO.Std.err.println( "method call calling load: " + method );
		IO.Std.err.println( "IIIIII: kind is " + method.Kind + " versus " + Symbol.STATIC_METHOD );
		*/

                t = compileLoadProcRef( state, into, method, type, method.ArgTypes, t, instance, super_class );
            } else if( left_value != null ) {

		// Std.err.println( "call B..." );
                if( left_value.isClass( state ) ) {
		    instance = false;
		    if( !method.IsStatic ) {
			error( "cannot make bound reference to instance method here" );
			return new ITree( 0, Op.ERROR, 0 );
		    }
		} else {
		    if( method.IsStatic ) {
			error( "cannot make bound reference to static method here" );
			return new ITree( 0, Op.ERROR, 0 );
		    }
		}

                t = compileLoadProcRef( state, into, method, type, method.ArgTypes, null, instance, null );
            } else {
		if( state.CurrentMethod == null || state.CurrentMethod.IsStatic ) {
		    error( "cannot make bound reference to instance method here" );
		    return new ITree( 0, Op.ERROR, 0 );
		}
		// Std.err.println( "call C..." );
                if( method.IsStatic ) {
                    instance = false;
		}

                t = compileLoadProcRef( state, into, method, type, method.ArgTypes, t, instance, null );
            }
            
	    return t;
        }	
    }
}