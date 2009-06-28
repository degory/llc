namespace Parse {
    use Gen.ITree;
    use Gen.IBlock;
    use Gen.ILabel;
    use Gen.IString;
    use Gen.Machine;
    use Gen.TempFactory;
    use Gen.MBitSet;

    class WrapTypeExprAsExpression extends Expression {
	TypeExpr type_expr;

	void init( int line_number, TypeExpr type_expr ) {
	    super.init( line_number );

	    this.type_expr = type_expr;
	}

	void clear( CompileState state ) {
	    super.clear( state );
	}

	void checkTemplates( CompileState state ) {
	    type_expr.checkTemplates( state );
	}

	void calcType( CompileState state ) {
	    type = type_expr.parseType( state );
	}

	ITree compileValue( CompileState state, IBlock into ) {
	    throw new System.Exception( "type " + type_expr + " has no value" );
	}

	bool isClass( CompileState state ) {
	    return true;
	}

	int getDepth() {
	    return 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    type_expr.print( state, p );
	}
    }


    class WrapTypeAsExpression extends Expression {
	Type wrapped_type;

	void init( int line_number, Type wrapped_type ) {
	    super.init( line_number );

	    this.wrapped_type = wrapped_type;
	}

	void clear( CompileState state ) {
	    super.clear( state );
	}

	void checkTemplates( CompileState state ) {
	}

	void calcType( CompileState state ) {
	    this.type = wrapped_type;
	}

	ITree compileValue( CompileState state, IBlock into ) {
	    throw new System.Exception( "type " + type + " has no value" );
	}

	bool isClass( CompileState state ) {
	    return true;
	}

	int getDepth() {
	    return 1;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( type.toString() );
	}
    }

    class WrapTypeAsTypeExpr extends TypeExpr {
	Type type;

	void init( int line_number, Type type ) {
	    super.init( line_number );
	    this.type = type;
	}

	Type parseType( CompileState state ) {
	    return type;
	}
	
	void checkTemplates( CompileState state ) {
	    // do nothing
	}

	void clear( CompileState state ) {
	    // do nothing
	}

	System.String toString() {
	    return type.toString();
	}

	void print( CompileState state, Printer p ) {
	    p.print( type );
	}
    }


    class TypeExpr extends ParseTree {
	// TypeExprList arguments;
	
        void init( int line_number ) {
            super.init( line_number );
        }

        Type parseType( CompileState state, TypeExprList type_arguments ) {
	    error( "this type does not expect arguments" );
        }

	Type parseType( CompileState state ) {
            error( "oops: cannot parse type" );
            return undefined_type;
        }
	/*
	void setArguments( TypeExprList a ) {
	    if( arguments == null ) {
		arguments = a;
	    } else {
		throw new System.Exception( "type already has arguments: " + this );
	    }
	}

	TypeExprList getArguments() {
	    return arguments;
	    }*/

	void checkTemplates( CompileState state ) {
	    throw new System.Exception( "not checking templates: " + this.Class.Name );
	}

        void dump( CompileState  state, System.StringBuffer  buffer ) {
            buffer.append("<unknown type>");
        }

        void dump( System.StringBuffer  human, System.StringBuffer  decorate ) {
            human.append("<unknown type>");
            decorate.append('v');
        }

	System.String toString() {
	    System.StringBuffer b = new System.StringBuffer();
	    System.StringBuffer d = new System.StringBuffer();

	    dump( b, d );
	    return b;
	}

	static void checkTypeArgsLength( ParseTree from, Container clazz, TypeExprList supplied_args ) {
	    int supplied_args_length = 0;
	    if( supplied_args != null ) {
		supplied_args_length = supplied_args.List.Length;
	    }
	    
	    if( clazz.TypeArgsRequiredLength != supplied_args_length ) {
		from.warn(
			  "class " + clazz.HumanName +
			  " requires " + clazz.TypeArgsRequiredLength +
			  " arguments but " + supplied_args_length + " arguments given" );
		IO.Std.err.println( "check called from: " + new System.Backtrace() );
	    }
	}
    }

    class InferTypeExpr extends TypeExpr {
	void init( int line_number ) {
	    super.init( line_number );
	}

	Type parseType( CompileState state ) {
	    return new Type( Type.INFER );
	}

	void checkTemplates( CompileState state ) {
	    // do nothing
	}

	void clear( CompileState state ) {
	    // do nothing
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.print( "var" );
	}
    }

    class TypeExprList extends ParseTree {
	Generic.Vector<TypeExpr> list;

	void init( int line_number ) {
	    super.init( line_number );
	    list = new Generic.Vector<TypeExpr>();
	}

	Generic.Vector<TypeExpr> getList() {
	    return list;
	}

	void add( TypeExpr t ) {
	    list.add( t );
	}

	void clear( CompileState state ) {
	    foreach( TypeExpr t; list.elements() ) {
		t.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
	    foreach( TypeExpr t; list.elements() ) {
		t.checkTemplates( state );
	    }
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    bool seen_any = false;
	    foreach( TypeExpr t; list.elements() ) {
		if( seen_any ) {
		    p.print( ", " );
		}
		t.print( state, p );
		seen_any = true;
	    }
	}
    }


    class NamedType extends TypeExpr {
        Identifier name;

        void init( int line_number, Identifier name ) {
            super.init( line_number );

            this.name = name;
        }

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "named type: " + name + " not a template" );
	}

	void clear( CompileState state ) {
	    name.clear( state );
	}

	Type parseType( CompileState state ) {
	    return parseType( state, null );
	}

        Type parseType( CompileState state, TypeExprList type_arguments ) {
	    if( name == null ) {
		throw new System.Exception( "parse named type: identifier is null" );
	    }

	    // IO.Std.err.println( "before parsing type: " + name.getQualifiedName(state) );
	    name.clear( state );

            // IO.Std.err.println( "parsing type: " + name.getQualifiedName(state) );
	    // IO.Std.err.println( "symbol table: " + state.SymbolTable );

	    // do not report errors and only search for type symbols here:
            Symbol type_symbol = name.getSymbol(state, false, Symbol.FIND_TYPE);
            // IO.Std.err.println( "done" );
            
            if( type_symbol != null ) {
		int k = type_symbol.Kind;
		if( type_symbol.IsType && k != Symbol.NAMESPACE ) {
		    Type type = type_symbol.Type;
		    if( type != null && type.isContainer() && type.Clazz != null ) {
			// IO.Std.err.println( "about to check args for: " + type + " (" + type.Clazz + ")" );
			checkTypeArgsLength( this, type.Clazz, type_arguments );
			return type;
		    } else {
			// can happen for template parameters:
			// IO.Std.err.println( "weird: class or type symbol has no type: " + name.Name );
			return type;
		    }
		} else {
		    error( "" + type_symbol.HumanName + " is not a type" );
		    // error( "type %s is not defined", name.getName() );
		    return undefined_type;
		}
	    } else {
		error( "type " + name.getQualifiedName(state) + " is not defined" );
		return undefined_type;
	    }
        }
        
        void dump( System.StringBuffer  human, System.StringBuffer decorate ) {
            System.String n = name.Name;
            human.append( n );
            decorate.append( n.Length );
            decorate.append( n );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    name.print( state, p );
	}

    }

    class BaseType extends TypeExpr {
        int type;

        void init( int line_number, int type ) {
            super.init( line_number );
            this.type = type;
        }

        Type parseType( CompileState state ) {
            Type result = new Type( type );
            return result;
        }

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "base type " + this + " is not a template" );
	}

	void clear( CompileState state ) {
	}

        void dump( System.StringBuffer human, System.StringBuffer decorate ) {
            Type t = new Type( type );
            t.dump( human, decorate );
        }

        System.String toString() {
            System.StringBuffer h = new System.StringBuffer();
            System.StringBuffer d = new System.StringBuffer();
            dump( h, d );
            return h;
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    switch( type ) {

            case Type.NONE:
		p.print( "null value" );
                
            case Type.VOID:
		p.print( "void" );

            case Type.BOOL:
                p.print( "bool" );

            case Type.BYTE:
                p.print( "byte" );

            case Type.CHAR:
                p.print( "char" );

            case Type.INTEGER:
                p.print( "int" );

	    case Type.WORD:
		p.print( "word" );

	    case Type.LONG:
		p.print( "long" );

            case Type.VECTOR:
                p.print( "[]" );

            case Type.REFERENCE:
		p.print( " ref" );

            case Type.POINTER:
		p.print( " ptr" );

	    case Type.INFER:
		p.print( "var" );

            case Type.ERROR:
		p.print( "undefined" );

            default:
                p.print( "unknown" );
	    }
	}	
    }

    class GenericType extends TypeExpr {
	Type type;
	TypeExpr type_expr;
	TypeExprList arguments;

	void init( int line_number, TypeExpr type_expr, TypeExprList arguments ) {
	    super.init( line_number );
	    this.type_expr = type_expr;
	    this.arguments = arguments;
	}

	void init( int line_number, Type type, TypeExprList arguments ) {
	    super.init( line_number );
	    this.type = type;
	    this.arguments = arguments;
	}

	Type parseType( CompileState state ) {
	    return parseType( state, true );
	}
	
	Type parseType( CompileState state, bool find_only ) {
	    Type t;
	    if( type_expr != null ) {
		// IO.Std.err.println( "parse generic type expression: " + type_expr );
		t = type_expr.parseType( state, arguments );
	    } else {
		// IO.Std.err.println( "parse generic type expr, using supplied type: " + type );
		t = type;
	    }

	    /*
	    IO.Std.err.println( "template is: " + t );
	    IO.Std.err.println( "symbol table is: " + state.symbol_table );
	    */

	    if( t == null ) {
		error( "generic sub type is null" );
		return undefined_type;
	    } else if( t.TypeKind != Type.CLASS ) {
		error( "cannot specify type arguments for type " + t );
		return undefined_type;
	    } 
	    Container c = t.Clazz;
	    
	    var a = new Generic.Vector<Type>();
	    foreach( TypeExpr e; arguments.List.elements() ) {
		t = e.parseType( state );
		// IO.Std.err.println( "type argument: " + t + " from " + e );
		a.add( t );
	    }
	    
	    t = state.findGeneric( c, a, find_only );
	    // IO.Std.err.println( "result is: " + t );

	    t.Clazz.markReferenced();

	    return t;
	}

	void checkTemplates( CompileState state ) {
	    if( arguments != null ) {
		arguments.checkTemplates(state);
	    }
	    if( type_expr != null ) {
		type_expr.checkTemplates(state);
	    }
	    parseType( state, false );
	}

	void clear( CompileState state ) {
	    if( type_expr != null ) {
		type_expr.clear( state );
	    }
	}

	System.String toString() {
	    System.StringBuffer b = new System.StringBuffer();
	    if( type_expr != null ) {
		b.append( type_expr );
	    } else {
		b.append( type );
	    }
	    b.append( '<' );
	    bool seen_any = false;
	    foreach( TypeExpr e; arguments.List.elements() ) {
		if( seen_any ) {
		    b.append(',');
		}
		b.append( e.toString() );		
	    }	    
	    b.append( '>' );

	    return b;
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    if( type_expr != null ) {
		type_expr.print( state, p );
	    } else {
		p.print( type );
	    }
	    p.print( "<" );
	    bool seen_any = false;
	    foreach( TypeExpr e; arguments.List.elements() ) {
		if( seen_any ) {
		    p.print(",");
		}
		e.print( state, p );
	    }	    
	    p.print( ">" );
	}
    }
    
    class VectorType extends TypeExpr {
        TypeExpr type;

        void init( int line_number, TypeExpr type ) {
            super.init( line_number );
            this.type = type;
        }

        Type parseType( CompileState state ) {
            if( type != null ) {
                Type sub_type = type.parseType( state );
                if( sub_type == null ) {
                    error( "oops: vector sub type is null" );
                    return undefined_type;
                }
                return new Type( Type.VECTOR, sub_type );
            } else {
                error( "vector of invalid type" );
                return undefined_type;
            }
        }

	void clear( CompileState state ) {
	    type.clear( state );
	}

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "vector type expression " + this + " could be a template" );
	    type.checkTemplates( state );
	}

        void dump( System.StringBuffer human, System.StringBuffer decorate ) {
            decorate.append('P');
            type.dump( human, decorate );
            human.append("[]");
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    type.print(state, p);
	    p.print( "[]" );
	}
    }
    

    class ReferenceType extends TypeExpr {
        TypeExpr type;
        void init( int line_number, TypeExpr type ) {
            super.init( line_number );
            this.type = type;
        }

        Type parseType( CompileState state ) {
            return new Type( Type.REFERENCE, type.parseType( state ) );
        }

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "reference type expression " + this + " could be a template" );
	    type.checkTemplates( state );
	}

	void clear( CompileState state ) {
	    type.clear( state );
	}
        
        void dump( System.StringBuffer  human, System.StringBuffer  decorate ) {
            decorate.append( 'R' );
            type.dump( human, decorate );
            human.append( " ref" );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    type.print(state, p);
	    p.print( " ref" );
	}
    }

    class PointerType extends TypeExpr {
        TypeExpr type;
        
        void init( int line_number, TypeExpr type ) {
            super.init( line_number );
            this.type = type;
        }

        Type parseType( CompileState state ) {
            return new Type( Type.POINTER, type.parseType( state ) );
        }

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "pointer type expression " + this + " could be a template" );
	    type.checkTemplates( state );
	}

	void clear( CompileState state ) {
	    type.clear( state );
	}

        void dump( System.StringBuffer  human, System.StringBuffer  decorate ) {
            decorate.append( 'P' );
            type.dump( human, decorate );
            human.append( " ptr" );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    type.print(state, p);
	    p.print( " ptr" );
	}
    }
}