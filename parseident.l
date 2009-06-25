
namespace Parse {
    use Gen.ITree;
    use Gen.IBlock;
    use Gen.ILabel;
    use Gen.IString;
    use Gen.Machine;
    use Gen.TempFactory;
    use Gen.MBitSet;

    class Identifier extends LeftValue {
        protected System.String name;
        protected Expression left_value;
        protected Symbol symbol;
        protected bool reference;

	MethodCall method_call;
	Expression set_value;
	bool want_set_value;

	Expression indexer_value;
	bool want_indexer;
        
        void init( int ln, System.String name ) {
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
	    set_value = null;
	    want_set_value = false;
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
        
        void calcType( CompileState state ) {
	    System.String n;
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

		      System.String n;
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
		    // IO.Std.err.println( "have an accessor method: " + method_call );
		} else {
		    // IO.Std.err.println( "quality is null" );

		    type = null;
		    method_call = null;

		    // clear cached symbol otherwise getSymbol will just return it again here:
		    symbol = null;
		    // although we found an accessor name, we didn't find a matching method
		    // so look again ignoring accessors:
		    // IO.Std.err.println( "about to look for alternative symbol " + name + "..." );

		    if( want_indexer ) {
			// try again without indexed accessor:
			want_indexer = false;
			want_set_value = false;
			calcType(state);
			return;
		    }

		    symbol = getSymbol( state, name, false, Symbol.FIND_NON_ACCESSOR );

		    // IO.Std.err.println( "no matching accessor method " + name + " found, alternative symbol: " + symbol );
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
		error( "undefined symbol " + getQualifiedName(state) );
            }

	    // IO.Std.err.println( "\n" );
        }

        void markAddressTaken( CompileState state ) {
            getType(state);
            
            if( symbol.Kind == Symbol.LOCAL_VARIABLE ) {
		state.notLeaf();

		if( method_call != null ) {
		    error( "cannot pass property " + name + " by reference" );
		} else {
		    // IO.Std.err.println( "mark address taken: " + symbol.Address );
		    state.markAddressTaken( symbol.Address );
		}
            }
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
        
        void dump( CompileState state, System.StringBuffer buffer ) {
            if( left_value != null ) {
                left_value.dump( state, buffer );
                buffer.append('.');
            }
            buffer.append(name);
        }

        System.String toString() {
	    if( left_value == this ) {
		throw new System.Exception( "oops: left value is this: " + name );
		return name;
	    }
            System.StringBuffer result = new System.StringBuffer();
            if( left_value != null ) {
                result.append( left_value );
                result.append( '.' );
            }
            result.append( name );
            return result;
        }
                

        System.String getName() {
            return name;
        }
        
        System.String getQualifiedName( CompileState state ) {
            System.StringBuffer buffer = new System.StringBuffer();
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

        Symbol getSymbol( CompileState state, System.String name, bool complain, int find_what ) {
	    // IO.Std.err.println( "YYYYYY: get symbol: " + this );
            if( symbol != null ) {
		// IO.Std.err.println( "returning cached symbol: " + symbol );

		/*
		if( symbol.Kind == Symbol.ATTRIBUTE_SIZE ) {
		    IO.Std.err.println( "returning cached sizeof attribute symbol " + symbol.QualifiedName + " for lookup " + name );
		}
		*/		
                return symbol;
            }
            
	    // IO.Std.err.println( "looking for " + this );

            Symbol result = null;
            if( left_value != null ) {
                Type t = left_value.getType( state );
		Type at;
		// IO.Std.err.println( "looking for " + this + " in type " + t );

                Container container = null;
		if( t.TypeKind == Type.ERROR ) {
                    return null;
		} else if( name =~ "sizeof" ) {		    
		    return new Symbol( null, name, Symbol.ATTRIBUTE_SIZE, Symbol.ACCESS_PUBLIC, new Type(Type.INTEGER) );
		} else if( name =~ "box" ) {
		    at = getBoxType(t);
		    if( at != null ) {
			// boxable value - will compile a call to box method:
			return new Symbol( null, name, Symbol.ATTRIBUTE_BOX, Symbol.ACCESS_PUBLIC, at );
		    } else {
			// not a boxable value - pass left value unchanged:
			return new Symbol( null, name, Symbol.ATTRIBUTE_PASS, Symbol.ACCESS_PUBLIC, t );
		    }
		} else if( name =~ "none" ) {
		    return new Symbol( null, name, Symbol.ATTRIBUTE_NONE, Symbol.ACCESS_PUBLIC, t );
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
		}

		container = t.Clazz;
		    
		result = container.findSymbol( name, find_what );
                
		// IO.Std.err.println( "result " + result );
		
		if( result != null ) {
		    checkAccess( result, state );
		} else {
		    if( complain ) {
			error( "undefined symbol " + getQualifiedName(state) );
		    }
		}

            } else {
		// IO.Std.err.println( "searching scopes for " + this );
                result = state.findSymbol( name, find_what );
		// IO.Std.err.println( "result is: " + result );
                if( result != null ) {
                    checkAccess( result, state );
                } else {
		    if( complain ) {
			error( "undefined symbol " + name /*getName()*/ );
		    }
		    // IO.Std.err.println( "undefined symbol " + getQualifiedName(state) );
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

        ITree compileValue( CompileState state, IBlock into ) {
            getType( state ); // ensure any property method is initialized

	    if( method_call != null ) {
		// IO.Std.err.println( "identifier is property: " + this );
		if( want_set_value ) {
		    // IO.Std.err.println( "property setter method has no value here: " + new System.Backtrace() );
		    method_call.compileDiscardValue( state, into );
		    return new ITree( line_number, Op.ERROR, 0 );
		} else {
		    return method_call.compileValue( state, into );
		}
	    }

            int size = getType( state ).RegSize;

            if( symbol == null ) {
                return new ITree( line_number, Op.ERROR, 0 );
            }

            int k = symbol.Kind;
            
            int ref_flag = 0;
            if( reference ) {
                ref_flag = LOAD_FLAG_REFERENCE;
            } 
            
	    Type at;
            ITree result = null;
            if( k == Symbol.ATTRIBUTE_LENGTH ) {
		// need to allow for null pointer exception to be thrown here:
		return makeLoadIndirect( state, line_number, into, Machine.WORD, true,
					 new ITree( line_number, Op.ADD, Machine.WORD, 
						    left_value.compileValue(state,into),
						    new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_LENGTH_OFFSET )
						    )
					 );
            } else if( k == Symbol.ATTRIBUTE_ARRAY ) {
                return new ITree( line_number, Op.ADD, Machine.WORD,
                                  left_value.compileValue(state,into),
                                  new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_OBJECT_OFFSET )
                                  );
            } else if( k == Symbol.ATTRIBUTE_STRUCT ) {
                return new ITree( line_number, Op.ADD, Machine.WORD,
                                  left_value.compileValue(state,into),
                                  new ITree( line_number, Op.CONST, Machine.WORD, Machine.WORD )
                                  );
	    } else if( k == Symbol.ATTRIBUTE_ADDRESS ) {
                at = left_value.getType( state );
		if( at.TypeKind == Type.VECTOR ) {
		    return new ITree( line_number, Op.ADD, Machine.WORD,
				      left_value.compileValue(state,into),
				      new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_DATA_OFFSET )
				      );
		} else if( !at.isContainer() ) {
		    left_value.markAddressTaken(state);
		    return left_value.compileAddress(state,into);
		} else {
		    error( "cannot take address of " + left_value );
		}
	    } else if( k == Symbol.ATTRIBUTE_SIZE ) {
		at = left_value.getType( state );
		// IO.Std.err.println( "sizeof: " + left_value + ", type: " + at + " reg size: " + at.RegSize );

		// FIXME: size should probably be a word but word type not well supported and objects with sizes
		// larger than 2 Gig not likely (especially since we're returning the *register* size here...) 
		return new ITree( line_number, Op.CONST, 4, at.RegSize );
	    } else if( k == Symbol.ATTRIBUTE_BOX ) {
		at = getType(state);

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
	    } else if( k == Symbol.ATTRIBUTE_PASS ) {
		return left_value.compileValue( state, into );
	    } else if( k == Symbol.ATTRIBUTE_NONE ) {
		return new ITree( line_number, Op.CONST, size, 0 );
            } else if( k == Symbol.CONST ) {
                return new ITree( line_number, Op.CONST, size, symbol.Address );
            } else if( ( k & Symbol.FLAG_STATIC ) == 0 ) {
                if( left_value == null ) {
                    result = compileLoad( state, into, symbol, null, null, null, size, ref_flag, null );
                    
                    return result;
                } else {
		    ITree t = left_value.compileValue( state, into );
                    result = compileLoad( state, into, symbol, null, null, t, size, ref_flag, null );
                    
                    return result;
                }
            } else {
                return compileLoad( state, into, symbol, null, null, null, size,
                                    LOAD_FLAG_STATIC, null );
            }
        }

        ITree compileAddress( CompileState state, IBlock into ) {
	    if( method_call != null ) {
		IO.Std.err.println( "oops: should not compile address for property here" + new System.Backtrace() );
		return new ITree( line_number, Op.ERROR, 0 );
	    }
            int size = getType( state ).RegSize;

            if( symbol == null ) {
                return new ITree( line_number, Op.ERROR, 0 );
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
	    } else if( k == Symbol.CONST ) {
                error( "cannot take address of constant " + symbol.HumanName );
                return new ITree( line_number, Op.ERROR, 0 );
            } else if( (k & Symbol.FLAG_STATIC) == 0 ) {
                if( left_value == null ) {
                    return compileLoad( state, into, symbol, null, null, null, size, ref_flag, null );
                } else {
                    ITree t = left_value.compileValue( state, into );
                    int s = size;
                    if( reference ) {
                        s = Machine.WORD;
                    }
                    ITree result = compileLoad( state, into, symbol, null, null, t, s, ref_flag, null );
                    return result;
                }
            } else {
                return compileLoad( state, into, symbol, null, null, null, size, LOAD_FLAG_ADDRESS | LOAD_FLAG_STATIC, null );
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

	    if( right != null ) {
		p.print( " = " );
		right.print( state, p );
	    }
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

	void checkInline( CompileState state ) {
	    left.checkInline( state );
	}
        
        ITree compileValue( CompileState state, IBlock into ) {
	    // need to allow for null pointer exception to be thrown here:
            return makeLoadIndirect( state, line_number, into, getType( state ).RegSize, true,
				     left.compileValue( state, into )
				     );
        }

        ITree compileAddress( CompileState  state, IBlock into ) {
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
        Util.Vector list;
        
        void init( int ln ) {
            super.init( ln );
	    // IO.Std.err.println( "IdentifierList.init()..." );
            list = new Util.Vector();
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
        
        void dump( CompileState state, System.StringBuffer human ) {
            for( Util.Iterator i = list.elements(); i.hasMoreElements(); ) {
                Identifier e = cast<Identifier>(i.nextElement());
                e.dump( state, human );
                if( i.hasMoreElements() ) {
                    human.append(',');
                }
            }
        }

        System.String toString() {
	    // IO.Std.err.println( "IdentifierList.toString()..." );
            System.StringBuffer result = new System.StringBuffer();

            for( Util.Iterator i = list.elements(); i.hasMoreElements(); ) {
                Identifier e = cast<Identifier>(i.nextElement());
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

        Util.Vector getList() {
            return list;
        }

	Identifier opGet( int i ) {
	    return cast<Identifier>(list[i]);
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