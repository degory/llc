
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    use Gen.IRBlock;
    use Gen.Machine;

    class Identifier extends LeftValue {
        protected String name;
        protected Expression left_value;
        protected Symbol symbol;

	Container container;
	MethodCall method_call;
	Expression set_value;
	Expression indexer_value;

	bool want_indexer;
	bool want_set_value;
	bool want_call;
        protected bool reference;
        
        void init( int ln, String name ) {
            super.init( ln );
	    // IO.Std.err.println( "initialize identifier: " + this );
            symbol = null;
            left_value = null;
            this.name = name;
            reference = false;
        }

	void clear( CompileState state ) {	    
	    type = null;
	    symbol = null;
	    method_call = null;
	    container = null;
	    set_value = null;
	    want_set_value = false;
	    // indexer_value = null;
	    want_call = false;
	    if( left_value != null ) {
		left_value.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
	    if( left_value != null ) {
		left_value.checkTemplates( state );
	    }
	}

	bool isIndexer(CompileState state) {
	    return want_indexer && method_call != null;
	}

	bool isIdentifier(CompileState state) {
	    return true;
	}

	void wantIndexer( CompileState state, Expression indexer_value ) {
	    want_indexer = true;
	    this.indexer_value = indexer_value;
	}

	bool isProperty(CompileState state) {
	    return method_call != null;
	}

	void wantSetProperty( CompileState state, Expression set_value ) {
	    want_set_value = true;
	    this.set_value = set_value;
	}        

	MethodCall getMethodCall() {
	    return method_call;
	}

	bool isSuper(CompileState state) {
	    return left_value != null && left_value.isSuper(state);
	}

	bool isLeft(CompileState state) {
	    return left_value != null && left_value.isThis(state);
	}

	// assuming we trying to call this identifier as a method, could it be one?
	bool isMethod(CompileState state) {
	    // note that we want to call this identifier as a method or generate a proc reference to it. If this is not
	    // set we'll issue an error later if the value is loaded:
	    want_call = true;

	    Symbol s = getSymbol( state, name, false, Symbol.FIND_ANY );
	    if( s == null ) {
		// caller want's it to be a method and we've found nothing to contradict that:
		return true;
	    }

	    int k = s.Kind;
	    if( k & Symbol.FLAG_METHOD != 0 || k > Symbol.ATTRIBUTE ) {
		return true;
	    } else {
		// IO.Std.err.println( "not method: " + this + ", symbol: " + s );
		return false;
	    }
	}
        
        void calcType( CompileState state ) {
	    String n;
	    bool want_method = false;

	    // IO.Std.err.println( "XXXXXX: identifier calc type: " + this + "," + left_value + ", getting symbol..." );

	    // nothing found is not an error and looking for any symbols including types here:
            symbol = getSymbol( state, name, false, Symbol.FIND_ANY );

	    if( /* symbol == null || */ symbol != null && symbol.Kind == Symbol.ACCESSOR ) {
		want_method = true;
		if( want_indexer ) {
		    if( want_set_value ) {
			n = "opSet" + name;
		    } else {
			n = "opGet" + name;
		    }
		} else {
		    if( want_set_value ) {
			n = "set" + name;
		    } else {
			n = "get" + name;
		    }
		}

		// IO.Std.err.println( "have accessor " + symbol + ", will look for method: " + n );

		/*
		symbol = getSymbol( state, n, false );

		if( symbol != null ) {
		    if( symbol.Kind & Symbol.FLAG_METHOD != 0 ) {
			// FIXME: 
			want_method = true;
		    } else {
			warn( "symbol " + symbol.HumanName + " is named like a property but is not a method" );
			symbol = null;
		    }
		}

		      String n;
		      if( want_set_value ) {
		      n = "set" + name;
		      } else {
		      n = "get" + name;
		      }
		    */

		// IO.Std.err.println( "property method: " + n + " -> " + symbol );
		
		Identifier ident = new Identifier( line_number, n );
		ExpressionList arg = new ExpressionList( line_number );

		if( want_indexer ) {
		    arg.add( indexer_value );
		}
		
		if( want_set_value ) {
		    arg.add( set_value );
		}
		
		method_call = new MethodCall( line_number, left_value, ident, arg );

		// IO.Std.err.println( "will try method call: " + method_call );

		// look for a matching set/get method but do not complain if not found:
		method_call.calcType(state,true);
		if( method_call.Quality != null ) {
		    // IO.Std.err.println( "quality is not null" );

		    type = method_call.Type;		   
		    symbol = null;
		} else {
		    // IO.Std.err.println( "quality is null" );

		    type = null;
		    method_call = null;

		    // clear cached symbol otherwise getSymbol will just return it again here:
		    symbol = null;
		    // although we found an accessor name, we didn't find a matching method
		    // so look again ignoring accessors:

		    if( want_indexer ) {
			// try again without indexed accessor:
			want_indexer = false;
			want_set_value = false;
			calcType(state);
			return;
		    }

		    symbol = getSymbol( state, name, false, Symbol.FIND_NON_ACCESSOR );
		}

		/*
		IO.Std.err.println( "after check method call, method call is: " + method_call + ", symbol is: " + symbol );
	    } else {

		IO.Std.err.println( "no accessor found, symbol is: " + symbol );
		*/
	    }
            
	    if( symbol != null ) {
		// IO.Std.err.println( "didn't find method, have symbol: " + symbol.HumanName );
		type = symbol.Type;
		
		if( type == null ) {
		    // IO.Std.err.println( "symbol has no type" );
		    type = undefined_type;
		    
		    // don't look any futher to avoid confusing or inaccurate error messages here:
		    return;
		}
		    
		if( symbol.Kind < Symbol.ATTRIBUTE ) {
		    // checkAccess( symbol, 0, state );
		    
		    if( symbol.IsInstance && state.CurrentMethod.IsStatic && 
			( left_value == null || left_value.isThis( state ) /* || !left_value.isClass( state )*/ ) ) {
			error( "cannot access instance member " + symbol.Name + " from static method " + state.CurrentMethod.Name );
		    }
		}
		if( type.TypeKind == Type.REFERENCE ) {
		    reference = true;
		    type = type.SubType;
		}
	    } else if( method_call == null ) {
		// IO.Std.err.println( "no symbol and no method call found for " + name );
		type = undefined_type;
		symbol = null;
		error( "undefined symbol " + getHumanName(state) );
            }

	    // IO.Std.err.println( "\n" );
        }
        
        bool isLeftValue( CompileState state ) {
            getType( state );
            
            if( symbol == null || (symbol.Kind & Symbol.FLAG_VARIABLE) != 0 || (method_call != null && want_set_value)) {
                return true;
            } else {
                return false;
            }
        }
        
        bool isClass( CompileState  state ) {
            getType( state );
            
            if( symbol != null && symbol.Kind == Symbol.CLASS ) {
                return true;
            } else {
                return false;
            }
        }
        
        void qualifies( Expression left_value ) {
            if( this.left_value != null ) {
                this.left_value.qualifies( left_value );
            }
            this.left_value = left_value;

	    if( left_value == this ) {
		IO.Std.err.println( "qualifying self here: " + name );
	    }
        }
        
        void dump( CompileState state, StringBuffer buffer ) {
            if( left_value != null ) {
                left_value.dump( state, buffer );
                buffer.append('.');
            }
            buffer.append(name);
        }

        String toString() {
	    if( left_value == this ) {
		throw new Exception( "oops: left value is this: " + name );
		return name;
	    }
            StringBuffer result = new StringBuffer();
            if( left_value != null ) {
                result.append( left_value );
                result.append( '.' );
            }
            result.append( name );
            return result;
        }
                

        String getName() {
            return name;
        }
        
        String getHumanName( CompileState state ) {
            StringBuffer buffer = new StringBuffer();
            dump( state, buffer );
            return buffer;
        }
        
        void declareSymbols( CompileState state ) {
        }

        Expression getLeftValue() {
            return left_value;
        }

        Expression getInitializer() {
            return null;
        }

	Symbol getSymbol( CompileState state, bool complain, int find_what) {
	    // IO.Std.err.println( "get symbol: " + name );
	    return getSymbol( state, name, complain, find_what );
	}

        Symbol getSymbol( CompileState state, String name, bool complain, int find_what ) {
	    // IO.Std.err.println( "YYYYYY: get symbol: " + this );
            if( symbol != null ) {
		// IO.Std.err.println( "returning cached symbol: " + symbol.HumanName );

                return symbol;
		//} else {
		// IO.Std.err.println( "YYYYYY: must look for " + this );
	    }

            Symbol result = null;
            if( left_value != null ) {
                Type t = left_value.getType( state );
		Type at;
		// IO.Std.err.println( "looking for " + this + " in type " + t );

                container = null;
		if( t.TypeKind == Type.ERROR ) {
                    return null;
		} else if( name =~ "sizeof" ) {		    
		    return new Symbol( null, name, Symbol.ATTRIBUTE_SIZE, Symbol.ACCESS_PUBLIC, new Type(Type.INTEGER) );
		} else if( name =~ "box" ) {
		    at = t.getBoxType(state);
		    if( at != null ) {			
			if( t.CanTreatAsObject ) {
			    // value is already an object we just need a silent cast to it's boxed type:
			    return new Symbol( null, name, Symbol.ATTRIBUTE_PASS, Symbol.ACCESS_PUBLIC, at );
			} else {
			    // equivalent boxed type found - return box attribute:
			    return new Symbol( null, name, Symbol.ATTRIBUTE_BOX, Symbol.ACCESS_PUBLIC, at );
			}
		    } else {			    
			// not a boxable value - pass left value unchanged:
			return new Symbol( null, name, Symbol.ATTRIBUTE_PASS, Symbol.ACCESS_PUBLIC, t );
		    }
		} else if( name =~ "none" ) {
		    return new Symbol( null, name, Symbol.ATTRIBUTE_NONE, Symbol.ACCESS_PUBLIC, t );
		} else if( name =~ "isobject" ) {
		    return new Symbol( null, name, Symbol.ATTRIBUTE_ISOBJECT, Symbol.ACCESS_PUBLIC, new Type(Type.BOOL) );
		} else if( name =~ "isreference" ) {
		    return new Symbol( null, name, Symbol.ATTRIBUTE_ISREFERENCE, Symbol.ACCESS_PUBLIC, new Type(Type.BOOL) );
		} else if( t.TypeKind == Type.VECTOR ) {
		    if( name =~ "length" ) {
			return new Symbol( null, name, Symbol.ATTRIBUTE_LENGTH, Symbol.ACCESS_PUBLIC, new Type(Type.INTEGER) );
		    } else if( name =~ "array" ) {
			return new Symbol( null, name, Symbol.ATTRIBUTE_ARRAY, Symbol.ACCESS_PUBLIC, array_type );
		    } else if( name =~ "address" ) {
			if( state.WantMarkUnsafe ) {
			    state.markCodeUnsafe( CompileState.UNSAFE_POINTER );
			}
			if( state.WantWarnUnsafe ) {
			    warn( "taking address" );
			}
			return new Symbol( null, name, Symbol.ATTRIBUTE_ADDRESS, Symbol.ACCESS_PUBLIC, new Type(Type.POINTER, t.SubType) );
		    } else {
			if( complain ) {
			    error( "attribute " + name + " is not defined in " + t.dump() );
			}
			return null;
		    }
		} else if( !t.isContainer() ) {
		    if( name =~ "address" ) {
			if( state.WantMarkUnsafe ) {
			    state.markCodeUnsafe( CompileState.UNSAFE_POINTER );
			}
			if( state.WantWarnUnsafe ) {
			    warn( "taking address" );
			}
			return new Symbol( null, name, Symbol.ATTRIBUTE_ADDRESS, Symbol.ACCESS_PUBLIC, new Type(Type.POINTER, t) );
		    } else {
			if( complain ) {
			    error( "attribute " + name + " is not defined in " + left_value.dump( state ) + " of type " + t );
			}
			return null;
		    }
		} else if( name =~ "address" ) {

		}

		container = t.Clazz;
		    
		result = container.findSymbol( name, find_what );
                
		// IO.Std.err.println( "result " + result );
		
		if( result != null ) {
		    checkAccess( result, state );
		} else {
		    if( complain ) {
			error( "undefined symbol " + getHumanName(state) );
		    }
		}

            } else {
		// IO.Std.err.println( "searching scopes for " + this );
                result = state.findSymbol( name, find_what );
		// IO.Std.err.println( "result is: " + result );
                if( result != null ) {
		    /*
		    IO.Std.err.println( "result is: " + result.HumanName );
		    if( result.Owner != null ) {
			IO.Std.err.println( " with owner " + result.Owner.HumanName );
		    }
		    */
                    checkAccess( result, state );
                } else {
		    if( complain ) {
			error( "undefined symbol " + name /*getName()*/ );
		    }
                }
            }
            
            symbol = result;
            if( symbol != null && symbol.Defined == 0 && state.Pass > CompilePass.DECLARE_SYMBOLS ) {
		IO.Std.err.println( "symbol is: " + symbol + ", pass is: " + cast int(state.Pass) );
                error( symbol.HumanName + " is not valid here" );
            }

	    // IO.Std.err.println( "YYYYYY: returning: " + result );
            return result;
        }

	LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    /*
	    IO.Std.err.println( "XXXXX: compile value, before get type for " + this );
	    IO.Std.err.println( "XXXXX: type initiallly: " + type );
	    IO.Std.err.println( "XXXXX: symbol initially: " + symbol );
	    IO.Std.err.println( "XXXXX: symbol initially: " + cast int(symbol) );
	    */

            getType( state ); // ensure any property method is initialized

	    if( method_call != null ) {
		// IO.Std.err.println( "identifier is property: " + this );
		if( want_set_value ) {		    
		    // warn( "property setter method has no value here: " + this + ", from: " + new System.Backtrace() );
		    method_call.compileDiscardValue( state, into );
		    return QuietErrorValue();
		} else {
		    return method_call.compileValue( state, into );
		}
	    }

            if( symbol == null ) {
		return ErrorValue();
            }

            int k = symbol.Kind;
            
            int ref_flag = 0;
            if( reference ) {
                ref_flag = LOAD_FLAG_REFERENCE;
            } 
            
	    Type at;
            LLVM.Value result = null;
	    if( k & Symbol.FLAG_METHOD != 0 ) {
		error( "not calling method " + symbol.HumanName + " here" );
		return ErrorValue();
	    } else if( k == Symbol.ATTRIBUTE_LENGTH ) {
		at = left_value.getType(state);

		return
		    makeGetArraySize( state, line_number, into, left_value.compileValue(state,into) );
						      							       		
            } else if( k == Symbol.ATTRIBUTE_ARRAY ) {
		return
		    makeGetArrayDataPointer( state, line_number, into, left_value.compileValue(state,into) );

		/*
                return new ITree( line_number, Op.ADD, Machine.WORD,
                                  left_value.compileValue(state,into),
                                  new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_OBJECT_OFFSET )
                                  );
		*/
		return ErrorValue();
            } else if( k == Symbol.ATTRIBUTE_STRUCT ) {
		/*
                return new ITree( line_number, Op.ADD, Machine.WORD,
                                  left_value.compileValue(state,into),
                                  new ITree( line_number, Op.CONST, Machine.WORD, Machine.WORD )
                                  );
		*/
		return ErrorValue();
	    } else if( k == Symbol.ATTRIBUTE_ADDRESS ) {
                at = left_value.getType( state );

		if( at.TypeKind == Type.VECTOR ) {
		    // FIXME: this is stupid, .address should have a consistent meaning:
		    return
			makeGetArrayDataPointer( state, line_number, into, left_value.compileValue(state,into) );

		} else if( !at.isContainer() ) {
		    return left_value.compileAddress(state,into);
		} else {
		    error( "cannot take address of " + left_value );
		    return ErrorValue();
		}

	    } else if( k == Symbol.ATTRIBUTE_SIZE ) {
		at = left_value.getType( state );

		/*
		IO.Std.err.println( "size of type: " + at );
		IO.Std.err.print( "LLVM type: " ); IO.Std.err.flush();
		LLVM.Calls.LLVMDumpType( at.getLLVMType(state) );
		*/

		return LLVM.Calls.LLVMConstTypeSize( at.getLLVMType(state) );
	    } else if( k == Symbol.ATTRIBUTE_BOX ) {
		at = getType(state);
		// IO.Std.err.println( "attribute type is: " + at );
		// IO.Std.err.println( "attribute type is: " + at + "," + at.Clazz );
		// does boxed type contain a box method?
		Symbol bm = at.findSymbol( "box", Symbol.FIND_ANY );
		if( bm != null && bm.Kind == Symbol.STATIC_METHOD ) {
		    // compile '.box' attribute into a static call to type.box(left_value) - for example:
		    // System.Int.box(123)
		    MethodCall box_call =
			new MethodCall(
				       line_number,
				       new WrapTypeAsExpression(line_number, at),
				       new Identifier(line_number, "box"),
				       new ExpressionList(line_number, left_value)
				       );
		    return box_call.compileValue( state, into );
		} else {
		    // compile '.box' attribute into an unchecked cast:
		    return left_value.compileValue( state, into );
		}
	    } else if( k == Symbol.ATTRIBUTE_PASS ) {
		return left_value.compileValue( state, into );
	    } else if( k == Symbol.ATTRIBUTE_NONE ) {
		return getType(state).getLLVMNull(state);
	    } else if( k == Symbol.ATTRIBUTE_ISOBJECT ) {
		at = left_value.getType( state );
		k = at.TypeKind;
		if( k == Type.CLASS || k == Type.VECTOR ) {
		    return LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),0L,0);
		} else {
		    return LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),1L,0);
		}
	    } else if( k == Symbol.ATTRIBUTE_ISREFERENCE ) {
		at = left_value.getType( state );
		if( at.isReference() ) {
		    return LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),0L,0);
		} else {
		    return LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt1Type(),1L,0);
		}
            } else if( k == Symbol.CONST ) {
		// IO.Std.err.println( "FIXME: store LLVM.Value in const symbol" );
		return symbol.LLVMValue;
		// return LLVM.Calls.LLVMConstInt(getType(state).getLLVMType(state), cast long(symbol.Address), 1);
            } else if( ( k & Symbol.FLAG_STATIC ) == 0 ) {
		/*
		IO.Std.err.println( "ident compile load, container is: " + container );
		IO.Std.err.println( "ident compile load, left value is: " + left_value );
		*/

		// IO.Std.err.println( "GGGG: this is: " + this );

                if( left_value == null ) {
		    /*
		    IO.Std.err.println( "GGGG: compile load ident " + symbol.HumanName );
		    if( symbol.Owner != null ) {
			IO.Std.err.println( "GGGG: symbol owner is: " + symbol.Owner.HumanName );
		    }
		    IO.Std.err.println( "GGGG: current class is: " + state.CurrentClass.HumanName );
		    IO.Std.err.println( "GGGG: current method is: " + state.CurrentMethod.HumanName );
		    */
                    result = compileLoad( state, into, symbol, state.CurrentClass, null, null, null, null, ref_flag, null );
                    
                    return result;
                } else {
		    if( container == null ) {
			throw new System.Exception( "instance variable access with no container: " + symbol.HumanName );
		    }

		    LLVM.Value t = left_value.compileValue( state, into );
		    /*
		    IO.Std.err.println(	"GGGG: compile load ident " + symbol.HumanName );
		    IO.Std.err.println( "GGGG: container is: " + state.CurrentClass.HumanName );
		    IO.Std.err.println( "GGGG: left value.Type.Clazz is: " + left_value.getType(state).Clazz.HumanName );


		    IO.Std.err.println( "FIXME: relying on container being correct here, left_value.getType(state).Clazz might be better?" );
		    */
                    result = compileLoad( state, into, symbol, container, null, null, null, t, ref_flag, null );
                    
                    return result;
                }
            } else {
		// IO.Std.err.println( "FIXME: static or local - container not needed here" );
                return compileLoad( state, into, symbol, container, null, null, null, null, LOAD_FLAG_STATIC, null );
            }
	}

        LLVM.Value compileAddress( CompileState state, IRBlock into ) {
	    /*
	    IO.Std.err.println( "XXXXX: compile address, before get type for " + this );
	    IO.Std.err.println( "XXXXX: type initiallly: " + type );
	    IO.Std.err.println( "XXXXX: symbol initially: " + symbol );
	    IO.Std.err.println( "XXXXX: symbol initially: " + cast int(symbol) );
	    */
	    getType(state);

	    if( method_call != null ) {
		IO.Std.err.println( "oops: should not compile address for property here" + new System.Backtrace() );
		return ErrorValue( LLVM.Calls.LLVMPointerType(getType(state).getLLVMType(state),0) );
	    }

            if( symbol == null ) {
		return ErrorValue( LLVM.Calls.LLVMPointerType(getType(state).getLLVMType(state),0) );
            }

            int ref_flag;
            if( reference ) {
                ref_flag = LOAD_FLAG_ADDRESS | LOAD_FLAG_REFERENCE;
            } else {
                ref_flag = LOAD_FLAG_ADDRESS;
            }

	    int k = symbol.Kind;

	    if( k >= Symbol.ATTRIBUTE ) {
		error( "cannot take address of attribue " + symbol.HumanName );
		return ErrorValue( LLVM.Calls.LLVMPointerType(getType(state).getLLVMType(state),0) );
	    } else if( k == Symbol.CONST ) {
                error( "cannot take address of constant " + symbol.HumanName );
		return ErrorValue( LLVM.Calls.LLVMPointerType(getType(state).getLLVMType(state),0) );
            } else if( (k & Symbol.FLAG_STATIC) == 0 ) {
                if( left_value == null ) {
                    return compileLoad( state, into, symbol, state.CurrentClass, null, null, null, null, ref_flag, null );
                } else {
		    // IO.Std.err.println( "FIXME: relying on container being correct here, left_value.getType(state).Clazz might be better?" );
                    LLVM.Value t = left_value.compileValue( state, into );
                    return compileLoad( state, into, symbol, container, null, null, null, t, ref_flag, null );
                }
            } else {
		// IO.Std.err.println( "FIXME: static or local - container not needed here" );
                return compileLoad( state, into, symbol, container, null, null, null, null, LOAD_FLAG_ADDRESS | LOAD_FLAG_STATIC, null );
            }
        }


	int getDepth() {
	    if( left_value != null ) {
		return left_value.getDepth() + 1;
	    } else {
		return 1;
	    }
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    if( left_value != null ) {
		left_value.print( state, p );
		p.print( "." );
	    }
	    p.print( name );
	}
    }



    class IdentifierAssign extends Identifier {
        Expression right;
        
        void init( int line_number, Identifier left, Expression right ) {
            super.init( line_number, left.name );
            left_value = left.left_value;
            this.right = right;
        }

	void clear( CompileState state ) {
	    super.clear( state );
	    if( right != null ) {
		right.clear( state );
	    }
	}
	
	void checkTemplates( CompileState state ) {
	    super.checkTemplates( state );
	    if( right != null ) {
		right.checkTemplates( state );
	    }
	}
        
        Expression getInitializer() {
            return right;
        }

	void print( CompileState state, Printer p ) {
	    // pl(p);

	    super.print( state, p );

	    /*
	    if( right != null ) {
		p.print( " = " );
		right.print( state, p );
	    }
	    */
	}       
    }

    class AtExpression extends LeftValue {
        Expression left;

        void init( int line_number, Expression left ) {
            super.init( line_number );
            this.left = left;
        }

        void calcType( CompileState state ) {
            type = left.getType( state );
            
            if( type.TypeKind != Type.ERROR ) {
                if( type.TypeKind != Type.POINTER ) {
                    error( "cannot de-reference non-pointer: " + type );
                    type = undefined_type;
                } else {
                    type = type.SubType;
                }
            }
        }

	void clear( CompileState state ) {
	    super.clear( state );
	    left.clear( state );
	}

	void checkTemplates( CompileState state ) {
	    super.checkTemplates( state );
	    left.checkTemplates( state );
	}

        LLVM.Value compileValue( CompileState state, IRBlock into ) {
	    // need to allow for null pointer exception to be thrown here but null test is too narrow to be much use here:
            return makeLoadIndirect( state, line_number, into, false,
				     left.compileValue( state, into )
				     );
        }

        LLVM.Value compileAddress( CompileState  state, IRBlock into ) {
            return left.compileValue( state, into );
        }

        bool isLeftValue( CompileState state ) {
            return true;
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "[" );
	    p.inparen();
	    left.print( state, p );
	    p.outparen();
	    p.print( "]" );
	}
    }

    
    class IdentifierList extends ParseTree {
        Vector<Identifier> list;
        
        void init( int ln ) {
            super.init( ln );
	    // IO.Std.err.println( "IdentifierList.init()..." );
            list = new Vector<Identifier>();
        }

	void init( int ln, Identifier first ) {
	    init( ln );
	    if( first != null ) {
		// IO.Std.err.println( "initialize identifier list" );
		add( first );
	    }
	}

	void clear( CompileState state ) {
	    foreach( Identifier i; list.elements() ) {
		i.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
	    foreach( Identifier i; list.elements() ) {
		i.checkTemplates( state );
	    }
	}
        
        void add( Identifier next ) {
	    // IO.Std.err.println( "IdentifierList.add()..." );
	    // IO.Std.err.println( "add next: " + next );
            list.add( next );
        }
        
        void dump( CompileState state, StringBuffer human ) {
            for( var i = list.elements(); i.hasMoreElements(); ) {
                Identifier e = i.nextElement();
                e.dump( state, human );
                if( i.hasMoreElements() ) {
                    human.append(',');
                }
            }
        }

        String toString() {
	    // IO.Std.err.println( "IdentifierList.toString()..." );
            StringBuffer result = new StringBuffer();

            for( var i = list.elements(); i.hasMoreElements(); ) {
                Identifier e = i.nextElement();
                result.append( e );
                if( i.hasMoreElements() ) {
                    result.append(',');
                }
            }

            return result;
        }

	int getLength() {
	    return list.Length;
	}

        Vector<Identifier> getList() {
            return list;
        }

	Identifier opGet( int i ) {
	    return list[i];
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    bool multi_line = false;
	    if( list.Length > 4 ) {
		multi_line = true;
		p.OneLine = false;
		p.indent();
		p.nl();
	    }

	    bool seen_any = false;
	    foreach( Identifier i; list.elements() ) {
		if( seen_any ) {
		    p.print( ", " );
		    if( multi_line ) {
			p.println();
		    }
		}

		i.print( state, p );

		seen_any = true;
	    }

	    if( multi_line ) {
		p.outdent();
		p.nl();
	    }
	}
    }
}