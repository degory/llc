
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
	    left.checkTemplates( state );
	    if( argument != null ) {
		argument.checkTemplates( state );
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

            if( t.TypeKind == Type.VECTOR ) {
                Type st = t.SubType;
                if( st.TypeKind == Type.CLASS || st.TypeKind == Type.VECTOR ) {
		    op = Op.NEW_OBJ_ARRAY;

                    return new ITree( line_number, op, 0,
                                      argument.compileValue( state,
                                                             into ), null,
                                      new IString( type.
                                                   SubType.
                                                   Size ) );
                } else {
		    op = Op.NEW_ARRAY;

                    return new ITree( line_number, op, 0,
                                      argument.compileValue( state,
                                                             into ), null,
                                      new IString( type.
                                                   SubType.
                                                   Size ) );
                }
            } else if( t.TypeKind == Type.CLASS ) {
                // int temp = TempFactory.nextTemp();
		int result = TempFactory.nextTemp();

                class_symbol = getType(state).Clazz;

                if( class_symbol != state.CurrentClass ) {
                    into.add( new ITree( line_number, Op.EXTERN, 0, "vtable$__" + class_symbol.DecoratedName ) );
                    into.add( new ITree( line_number, Op.EXTERN, 0, method.DecoratedName ) );
                }

		into.add( new ITree( line_number, Op.COMMENT, 0, "new " + class_symbol.DecoratedName + " size " + class_symbol.Size + " into T" + result ) );

		ITree vtable;
		op = Op.NEW;

		if( class_symbol.IsStruct ) {
		    vtable = new ITree( line_number, Op.CONST, Machine.WORD, "0" );
		} else {
		    vtable = new ITree( line_number, Op.GLOBAL, Machine.WORD, "vtable$__" + class_symbol.DecoratedName );

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
		// left value is not a method identifier - assume it's a proc reference or an error:
		calcTypeProcReference( state );
	    }
	}

        void calcTypeNormal( CompileState state, bool quiet ) {
            Symbol symbol = null;
            String arg_string = null;

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

                if( type.TypeKind == Type.ERROR ) {
                    symbol = undefined_method;
                } else if( type.TypeKind != Type.CLASS && type.TypeKind != Type.SUPER ) {
                    ExpressionList wrap_arguments = new ExpressionList( line_number );

                    Type t = getBoxType(type);;

                    if( t != null ) {
                        wrap_arguments.add( left_value );

                        if( arguments != null && arguments.List.Length > 0 ) {
                            foreach( Expression e; arguments.List.elements() ) {
                                wrap_arguments.add(e);
                            }
			}
                        method_call = new MethodCall( line_number, new WrapTypeAsExpression(line_number,t), new Identifier(line_number,name.Name), wrap_arguments );

                        method_call.calcType( state, true );
                        quality = method_call.Quality;
                        if( quality == null ) {
                            method = undefined_method;
                            if( !quiet ) {
                                arg_string = dumpArguments( arg_types );
                                error( "method " + name.Name + "(" + arg_string + ") is not defined in " + type );
                            }
                            type = undefined_type;
                        }
                        type = method_call.Type;
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

	    IO.Std.err.println( "calling though something other than a method identifier, is it a proc reference?" );

	    proc_type = left_value.getType( state );
	    
	    IO.Std.err.println( "left value type is: " + proc_type );

	    if( proc_type.TypeKind != Type.PROC ) {
		error( "cannot call though non proc value: " + proc_type );
		proc_type = null;
		type = undefined_type;
		return;
	    }

	    if( !proc_type.Clazz.matches( arg_types, false ) ) {
                var arg_string = dumpArguments( arg_types );		
		error( "argument types do not match: " + proc_type + " vesus(" + arg_string + ")" );
		proc_type = null;
		type = undefined_type;
		return;
	    }

	    type = proc_type.Clazz.Type;
	    IO.Std.err.println( "call through proc reference " + proc_type + " returns type " + type );
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
                return new ITree( line_number, Op.ERROR, 0 );
            }

	    Identifier name;
	    var left_value = this.left_value;

	    if( !proc_call ) {
		name = cast Identifier(left_value);
		left_value = name.LeftValue;
	    

		// IO.Std.err.println( "call method " + method.Owner.HumanName + " " + method.Name );

		if( left_value != null && !left_value.isThis( state ) && !left_value.isSuper( state ) ) {
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

		IO.Std.err.println( "compile proc call on type: " + proc_type );
                t = compileLoad( state, into, null, arguments, proc_type.Clazz.ArgTypes, t, Machine.WORD, flags, null );

		IO.Std.err.println( "block now:\n" + into );

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

                Container scope = left_value.getType(state).Clazz;
                Container super_class = null;
                if( left_value.getType(state).TypeKind == Type.SUPER ) {
                    super_class = scope;
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
}