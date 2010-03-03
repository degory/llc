
namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    use Gen.IRBlock;
    use Gen.Machine;

    class ArgumentsDef extends Statement {
        Vector<VariableDef> list;
        
        void init( int line_number ) {
            super.init( line_number );
	    list = new Vector<VariableDef>();
        }

	void init( int line_number, VariableDef first ) {
	    init( line_number );
	    if( first != null ) {
		add( first );
	    }
	}

	void clear( CompileState state ) {
	    foreach( VariableDef v; list.elements() ) {
		v.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
	    foreach( VariableDef v; list.elements() ) {
		v.checkTemplates( state );
	    }
	}
        
        void dump( CompileState state, StringBuffer human, StringBuffer decorate ) {
            for( var i = list.elements(); i.hasMoreElements(); ) {
                VariableDef v = i.nextElement();
                v.getType( state ).dump( human, decorate );
                
                if( i.hasMoreElements() ) {
                    human.append( ',' );
                }
            }
        }
        
        void dump( StringBuffer human, StringBuffer decorate ) {
	    // IO.Std.err.println( "no state dump called: " + new System.Backtrace() );
            for( var i = list.elements(); i.hasMoreElements(); ) {
                VariableDef v = cast<VariableDef>(i.nextElement());
                v.dump( human, decorate );
                
                if( i.hasMoreElements() ) {
                    human.append( ',' );
                }
                
            }
        }
        
        void add( VariableDef next ) {
            list.add( next );
        }
        
        Vector<Type> getTypes( CompileState state ) {
            var result = new Vector<Type>(list.Length);
            foreach( VariableDef v; list.elements() ) {
                result.add( v.getType( state ) );
            }
            
            return result;
        }

	get Vector<TypeExpr> TypeExprs {
	    var result = new Vector<TypeExpr>(list.Length);
            foreach( VariableDef v; list.elements() ) {
                result.add( v.TypeExpr );
            }

	    return result;
	}
         
        void declareSymbols( CompileState state, bool skip_this ) {
	    state.beginParseStackParams();

	    // IO.Std.err.println( "reg params" );

            foreach( VariableDef s; list.elements() ) {
                if( s != null ) {
                    s.declareSymbols( state );
                } else {
                    error( "oops: null argument definition" );
                }
            }
        }
        

	void print( CompileState state, Printer p ) {
	    // pl(p);

	    bool seen_any = false;
            foreach( VariableDef v; list.elements() ) {
		if( seen_any ) {
		    p.print( ", " );
		}
		v.print( state, p );
		seen_any = true;
	    }
	}

	String toString() {
	    var result = new StringBuffer();
	    bool seen_any;
            foreach( VariableDef v; list.elements() ) {
		if( seen_any ) {
		    result[result.Length-1] = ',';
		}
		result.append( v );

		seen_any = true;
	    }
	    if( seen_any ) {
		result[result.Length-1] = ' ';
	    }
	    return result;
	}
    }

    class ImportDef extends Statement {
        Identifier name;

        void init( int line_number, Identifier name ) {
            super.init( line_number );
            this.name = name;
        }

	void clear( CompileState state ) {
	}

	void checkTemplates( CompileState state ) {
	}

	void compile( CompileState state ) {
	    // IO.Std.err.println( "compile import-def does nothing" );
	}

        void parseImports( CompileState state ) {
	    state.visitFile( name.Name );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "#include <" );
	    name.print( state, p );
	    p.println( ".h>" );
	}
    }


    class LibraryDef extends Statement {
        Constant name;
        
        void init( int line_number, Constant name ) {
            super.init( line_number );
            this.name = name;
        }
        
        void parseImports( CompileState state ) {
            StringBuffer b = new StringBuffer();
            name.dump(state,b);
            state.addLibrary(b);
        }
        
        void compile( CompileState state ) {
	    if( state.WantMarkUnsafe ) {
		state.markCodeUnsafe( CompileState.UNSAFE_LINK );
	    }
            if( state.WantWarnUnsafe ) {
                StringBuffer b = new StringBuffer();
                name.dump(state,b);
                warn( "additional linker option: '" + b + "'" );
            }
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "import " );
	    name.print( state, p );
	    p.println( ";" );
	}
    }

    class AccessDef extends Statement {
        private int access;

        set int Access = access {
            this.access = access;
        }

        set AccessSpecifier Access = a {
            if( a != null ) {
                Access = a.Access;
            }
        }

        get int Access {
            return access;
        }

        void init( int line_number ) {
            super.init( line_number );
            access = 0;
        }

	void print( CompileState state, Printer p) {
	    pl(p);

	    p.nl();

	    bool is_public = true;

	    if( !p.InArgs ) {
		if( access & Symbol.ACCESS_PRIVATE != 0 ) {
		    p.print( "private: " );
		    is_public = false;
		}
		
		if( access & Symbol.ACCESS_PROTECTED != 0 ) {
		    p.print( "protected: " );
		    is_public = false;
		}

		if( is_public || access & Symbol.ACCESS_PUBLIC != 0 ) {
		    p.print( "public: " );
		}
	    }
	    if( access & Symbol.ACCESS_STATIC != 0 ) {
		p.print( "static " );
	    }

	    if( access & Symbol.ACCESS_CONST != 0 ) {
		p.print( "const " );
	    }
	}
    }

    class EnumDef extends AccessDef {
        Identifier name;
        IdentifierList members;
        Container e;

        void init( int line_number, Identifier name, IdentifierList members ) {
            super.init( line_number );
            this.name = name;
            this.members = members;

            e = null;
        }

        void declare( CompileState state ) {
            int a = Access;
            if( a == 0 ) {
                a = Symbol.ACCESS_PUBLIC;
            }
            e = state.declareEnum( this, name.Name, a );
            // fprintf( stderr, "EnumDef parse class definitions: %s %X...\n", name.getName(), e );
        }

	void declareGlobalSymbols( CompileState state ) {
	    declare( state );	    
	}

	void declareClassSymbols( CompileState state ) {
	    if( state.State == CompileState.STATE_INSIDE_CLASS ) {
		declare( state );
	    }
	}   

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "check templates for enum: " + e + ", " + e.Type );
	    var t = e.Type.getBoxType(state);
	    // IO.Std.err.println( "result is: " + t );
	}

        void declareSymbols( CompileState state ) {
            // fprintf( stderr, "EnumDef parse: %s %X...\n", name.getName(), e );
            if( members != null ) {
                LLVM.Value next_enum_value = LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),0L,0);
                state.beginParseEnum( this, e );
                var list = members.List;
                foreach( Identifier m; list.elements() ) {
                    Expression ex = m.Initializer;
		    LLVM.Value address;
                    
                    if( ex != null ) {
                        if( !ex.getType(state).isInteger() ) {
                            error( "initializer for " + e.HumanName + "." + m.Name + " must be integer" );
                        } else {
			    var d = getDummyIRBlock(state);
                            LLVM.Value t = ex.compileValue( state, d );
			    if( LLVM.Calls.LLVMIsConstant(t) == 0 ) {
                                error( "initializer for " + e.HumanName + "." + e.Name + " must be constant" );
                            } else {
                                address = t;
                                next_enum_value = LLVM.Calls.LLVMConstAdd( t, LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),1L,0) );
                            }
                        }
                    } else {
                        address = next_enum_value;
                        next_enum_value = LLVM.Calls.LLVMConstAdd( next_enum_value, LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(),1L,0) );
                    }
                    state.declareEnumMember( this, m.Name, address );
                }
                state.endParseEnum();
            }
        }

        void compile( CompileState state ) {
            // do nothing
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "enum " );
	    name.print( state, p );
	    p.println( " {" );
	    members.print( state, p );
	    p.println( "};" );
	}
    }


    class ClassDef extends AccessDef {
        Identifier super_ident;
        Identifier name;
	IdentifierList arguments;     // formal arguments to this class - names of types that will be given specific type values when class is used
	TypeExprList super_arguments; // actual arugments to super class - specified now (although may be references to formal arguments)
	TypeExprList implements_list;      // implemented interfaces
        BlockStatement body;
        Container c;
	int next_index;

	bool is_internal_definition; // class definition created for compiler's internal use (e.g for Object) - this
	                             // class must be allowed to be redefined by the runtime library
	bool is_super_class_concrete;

	bool is_generic;
	Vector<Container> generic_instances;
	static int generic_count;
	
	get bool IsStruct {
	    return false;
	}

	get bool IsInterface {
	    return false;
	}

	set bool InternalDefinition = v {
	    is_internal_definition = v;
	}

	/*

	  FIXME: needs proper testing

	These should all work:

	class X extends Z;
        class X extends Y.Z;
        class X<T> extends Z;
	class X<T> extends Y.Z;
        class X<T> extends Z<T>
	class X<T> extends Y.Z<T>
	class X<T,U> extends Z;
	class X<T,U> extends Y.Z;
	class X<T,U> extends Z<T>;
	class X<T,U> extends Y.Z<T>;
	class X extends Z<W>
	class X extends Y.Z<W>
	class X<T> extends Z<W>
	class X<T> extends Y.Z<W>
        class X<T> extends Z<T,W>
	class X<T> extends Y.Z<T,W>
	class X<T,U> extends Z<W>;
	class X<T,U> extends Y.Z<W>;
	class X<T,U> extends Z<T,W>;
	class X<T,U> extends Y.Z<T,W>;

	*/

        void init( int line_number, Identifier name, IdentifierList arguments, Identifier super_ident, TypeExprList super_arguments ) {
            super.init( line_number );
            this.super_ident = super_ident;
            this.name = name;
	    this.arguments = arguments;
	    if( super_arguments != null && super_arguments.List.Length > 0 ) {
		this.super_arguments = super_arguments;
	    }
	    generic_instances = new Vector<Container>();
            body = null;
            c = null;
        }

        void init(
		  int line_number,
		  Identifier name,
		  IdentifierList arguments,
		  Identifier super_ident,
		  TypeExprList super_arguments,
		  TypeExprList implements_list,
		  BlockStatement body ) {
            super.init( line_number );
            this.super_ident = super_ident;
            this.name = name;
	    this.arguments = arguments;
	    if( super_arguments != null && super_arguments.List.Length > 0 ) {
		this.super_arguments = super_arguments;
	    }
	    this.implements_list = implements_list;
            this.body = body;
	    generic_instances = new Vector<Container>();

	    if( body == null ) {
		throw new Exception( "cannot declare class " + name + " with null body" );
	    }

            c = null;
        }

        void declareGlobalSymbols( CompileState state ) {
            int a = Access;
            if( a == 0 ) {
                a = Symbol.ACCESS_PUBLIC;
            }

            c = state.declareClass( this, null, state.CurrentNameSpace, name.Name, null, a, is_internal_definition );
	    // IO.Std.err.println( "declared class: " + c );
            c.IsStruct = IsStruct;
	    c.IsInterface = IsInterface;

            state.addClass( c );                

            if( body != null ) {
                state.enterClass( c );
		if( arguments != null && arguments.List.Length > 0 ) {
		    addArguments( state );
		}

                body.declareGlobalSymbols( state );
		c.BodyStatement.declareGlobalSymbols( state );
                state.exitClass( c );

		if( is_generic ) {
		    state.registerGeneric( state.SaveState, state.SymbolState, c, this );
		}
	    } else {
		// IO.Std.err.println( "no class body: " + c );
	    }
        }

	void addArguments( CompileState state ) {
	    // IO.Std.err.println( "add arguments: " + arguments.List + ", length: " + arguments.List.Length );
	    // IO.Std.err.println( "marking is generic: " + c  );
	    is_generic = true;
	    c.IsGeneric = true;

	    // this will cause declareClass to give an error if a generic class is redefined. Otherwise
	    // because generic classes never get a body, declareClass assumes they're internally defined
	    // like Object.
	    // c.NeedsBody = false;

	    var arg_names = new Vector<Identifier>();
	    foreach( Identifier i; arguments.List.elements() ) {
		arg_names.add( i );
	    }

	    c.ArgNames = arg_names;
	}
        
	Container makeConcrete( CompileState state, Vector<Type> args ) {
	    if( !is_generic ) {
		throw new Exception( "cannot make concrete version of non template class " + c );
	    }

	    // IO.Std.err.println( "make concrete: " + c );
	    
            int a = Access;
            if( a == 0 ) {
                a = Symbol.ACCESS_PUBLIC;
            }
	    /*
	    StringBuffer b = new StringBuffer();
	    b.append(" of<");

	    
	    bool seen_any = false;
	    foreach( Type t; args.elements() ) {
		if( seen_any ) {
		    b.append(',');
		}
		b.append( t ); 
		seen_any = true;
	    }
	    b.append( '>' );
	    */

	    Container super_class = findSuperClass( state );
	    
	    /*
	    n.append('$');
	    n.append( generic_count );
	    */    

	    Container concrete = state.declareClass( this, null, state.CurrentNameSpace, name.Name, args, a, false );
            c.IsStruct = IsStruct;
	    concrete.Template = c;

	    concrete.IsInterface = IsInterface;

	    // generic_count = generic_count + 1;

	    // IO.Std.err.println( state.symbol_table );

	    body.clear( state );

	    state.addClass( concrete );
	    state.enterClass( concrete );
	    addConcreteArguments( state, concrete, args );
	    generic_instances.add( concrete );

	    makeImplementsConcrete( state );
	    // try {
		makeSuperClassConcrete( state, concrete, super_class );
		// } catch( System.Exception se ) {
		// error( "problem with superclass " + concrete.HumanName + " " + super_class.HumanName );
		// throw se;
		// }

	    body.declareGlobalSymbols( state );
	    concrete.BodyStatement.declareGlobalSymbols(state);
	    state.exitClass( concrete );
	    // declareSymbols( state, concrete );

	    // IO.Std.err.println( "made concrete: " + concrete ); // + " return to: " + new System.Backtrace());

	    concrete.Type = new Type( Type.CLASS, concrete );

	    return concrete;
	}

	void makeImplementsConcrete( CompileState state ) {
	    // IO.Std.err.println( "make implements complete..." );
	    if( implements_list != null ) { 
		foreach( TypeExpr t; implements_list.List.elements() ) {
		    t.checkTemplates( state );
		}
	    }
	}

	void makeSuperClassConcrete( CompileState state, Container clazz, Container super_class ) {
	    if( super_arguments != null ) {

		if( super_class == null ) {
		    IO.Std.err.println( "oops: arguments supplied but super class is null: " + clazz + ", " + this + " from: " + new System.Backtrace() );
		}

		GenericType gst = new GenericType( line_number, new Type( Type.CLASS, super_class ), super_arguments );
		// GenericType gst = new GenericType( line_number, new NamedType( line_number, super_ident), super_arguments );

		gst.checkTemplates( state );

		// this could recurse but not indefinitely?
		Type st = gst.parseType( state );

		clazz.Super = st.Clazz;
	    } else {		
		clazz.Super = super_class;
	    }
     	}

	void addConcreteArguments( CompileState state, Container c, Vector<Type> args ) {
	    c.ArgTypes = args;

	    for( int i = 0; i < args.Length; i = i + 1 ) {
		Type t = args[i];
		String n = arguments[i].Name;

		state.declareType( this, n, Symbol.ACCESS_PRIVATE, t );
	    }
	}

	void declareClassSymbols( CompileState state ) {
	    if( !is_generic ) {
		declareClassSymbols( state, c );
	    } else {
		foreach( Container d; generic_instances.elements() ) {
		    body.clear(state);
		    declareClassSymbols( state, d );
		}
	    }
	}

        void declareClassSymbols( CompileState state, Container c ) {
            Container super_class = c.Super;

	    if( super_class == null ) {
		// provisional super class - may change if it turns out to be a template:
		super_class = findSuperClass( state ); // , c.HumanName );
	    }

	    // IO.Std.err.println( "declare class symbols: " + c.HumanName );
		
	    if( body != null ) {
		if( c.NeedsBody ) {
		    state.beginParseClass( this, super_class, c, name.Name );
		    // IO.Std.err.println( "begin parse class: c: " + c + ", super_class: " + super_class + ", c.Super: " + c.Super );
			    
		    body.declareClassSymbols( state );
		    c.BodyStatement.declareClassSymbols(state);
		    state.middleParseClass( c );
		    
		    state.endParseClass( c );
		    
		    c.NeedsBody = false;
		} else {
		    error( "class " + c.HumanName + " already has a body" );
		}
	    } else {
		error( "class definition for " + c.HumanName + " with no body" );
		state.declareClass( this, super_class, null, name.Name, null, Access, false );
	    }

	    if( !IsInterface ) {
		state.addObject( c );
	    }
	}

	Container findSuperClass( CompileState state ) { // , String class_name ) {
	    if( super_ident != null ) {
		// do not report errors and only look for types:
		Symbol super_symbol = super_ident.getSymbol( state, false, Symbol.FIND_TYPE );
		
		if( super_symbol != null && super_symbol.Kind == Symbol.CLASS ) {
		    Container super_class = cast Container(super_symbol);
		    TypeExpr.checkTypeArgsLength( this, super_class, super_arguments );

		    if( IsInterface ) {
			if( !super_class.IsInterface ) {
			    error( "super interface " + super_class.HumanName + " is a class" );
			    return null;
			}
		    } else {
			if( super_class.IsInterface ) {
			    error( "super class " + super_class.HumanName + " is an interface" );
			    return null;
			}
		    }
		    
		    return cast<Container>(super_symbol);
		} else {
		    error( "super class " + super_ident + " is not defined" );
		}
	    } else if( c == ObjectClass /* || IsInterface */ || IsStruct ) {
		return null;
	    } else {
		// warn( c.HumanName + "does not inherit from System.Object" );
		// return null;
		return ObjectClass;
	    }
	}

	void checkTemplates( CompileState state ) {
	    if( !is_generic ) {	       
		// even if this is not a template class, it's parent may be - if so make parent concrete now:
		if( !is_super_class_concrete ) {
		    // super class may not be set in container yet so need to look it up here:
		    Container super_class = findSuperClass( state ); // , state.CurrentNameSpace.HumanName + "." + name.Name );

		    makeImplementsConcrete(state);
		    makeSuperClassConcrete(state, c, super_class);
		    is_super_class_concrete = true;
		}

		checkTemplates( state, c );
	    } else {
		// IO.Std.err.println( "EEEEEE: creating generic instances from index: " + next_index + " : " + c );
		int i = 0;
		int l = generic_instances.Length;
		// IO.Std.err.println( "EEEEEE: creating generic instances from index: " + next_index + " to index: " + (l-1) + " : " + c );

		for( i = next_index; i < l; i = i + 1 ) {
		    Container d = cast<Container>(generic_instances[i]);
		    body.clear( state );
		    checkTemplates( state, d );
		}

		next_index = i;
		
		/*
		if( i < generic_instances.Length ) {
		    IO.Std.err.println( "EEEEEE: at least one additional generic instance created within this class - another template expansion pass needed" );
		}
		*/

	    }
	}

	void checkTemplates( CompileState state, Container c ) {
	    // IO.Std.err.println( "check template: " + c );
	    state.enterClass( c );
	    body.checkTemplates( state );
	    c.BodyStatement.checkTemplates(state);

	    state.exitClass( c );
	}

	void declareSymbols( CompileState state ) {
	    if( !is_generic ) {
		// IO.Std.err.println( "check inline: " + c );
		declareSymbols( state, c );
	    } else {
		foreach( Container d; generic_instances.elements() ) {
		    body.clear( state );	    	    
		    // IO.Std.err.println( "check inline instance: " + d );
		    declareSymbols( state, d );
		}
	    }
	}

	void declareSymbols( CompileState state, Container c ) {
	    state.beginCompileClass( this, c, name.Name );

	    addImplementedInterfaces( state, c );

	    c.resetMethodIndex();
	    body.declareSymbols( state );
	    c.BodyStatement.declareSymbols(state);

	    state.endCompileClass( c );
	}

	void addImplementedInterfaces( CompileState state, Container c ) {
	    // IO.Std.err.println( "add implemented interfaces: " + implements_list );
	    if( implements_list != null ) { 
		foreach( TypeExpr te; implements_list.List.elements() ) {
		    // IO.Std.err.println( "type expr:   " + te );
		    Type t = te.parseType( state );
		    // IO.Std.err.println( "parsed type: " + t );
		    if( t.TypeKind != Type.CLASS ) {
			error( "cannot implement non-class type: " + t );
		    } else {		      
			Container p = t.Clazz;

			if( !p.IsInterface ) {
			    error( "cannot implement non-interface: " + t );
			    continue;
			}

			c.addImplements( p );

			do {			    
			    // IO.Std.err.println( "interface: " + p.HumanName );
			    state.registerInterface( p );
			    p = p.Super;
			} while( p != null && p != object_type.Clazz );
		    }
		}
	    }
	}

	void compile( CompileState state ) {
	    if( !is_generic ) {
		// IO.Std.err.println( "compile: " + c );
		compile( state, c );
	    } else {
		foreach( Container d; generic_instances.elements() ) {
		    body.clear( state );
		    // IO.Std.err.println( "compile generic instance: " + d );
		    compile( state, d );
		}
	    }
	}

	void compile( CompileState state, Container c ) {
	    var work = new CompileClass( state, this, c );
	    state.submit( work );
	}

	void compileGetCTable( CompileState state, Container c ) {
	    var pi8 = LLVM.Calls.LLVMPointerType( LLVM.Calls.LLVMInt8Type(), 0 );
	    var ft = LLVM.Calls.LLVMFunctionType(
						 LLVM.Calls.LLVMVTableType(),
						 new LLVM.Type[0].address,
						 0,
						 0
						 );

	    var f =
		LLVM.Calls.LLVMAddFunction(
					   state.Module, 
					   ("__get_ctable_" + c.DecoratedName).toCString(),
					   ft
					   );

	    state.maybeLinkOnce(f);

	    state.clearThrowBlocks();
	    var into = new IRBlock( state, f );

	    into.Ret( makeLoadVTable( state, c ) );

	    into.AtEnd();

	    into.Close();
	}

	void compileBody( CompileState state, Container c ) {
	    state.clearThrowBlocks();

	    var g = LLVM.Calls.LLVMAddGlobal(
					     state.Module,
					     LLVM.Calls.LLVMInt1Type(),
					     ("__init_done_" + c.DecoratedName).toCString()
					     );

	    LLVM.Calls.LLVMSetInitializer(
					  g,
					  LLVM.Calls.LLVMConstInt(
								  LLVM.Calls.LLVMInt1Type(),
								  0L,
								  0
								  )
					  );

	    var ft = LLVM.Calls.LLVMFunctionType(
						 LLVM.Calls.LLVMVoidType(),
						 new LLVM.Type[0].address,
						 0,
						 0
						 );
	    
	    var f =
		LLVM.Calls.LLVMAddFunction(
					   state.Module,
					   ("__static_init_" + c.DecoratedName).toCString(),
					   ft
					   );

	    state.maybeLinkOnce(f);

	    state.clearThrowBlocks();
	    var into = new IRBlock( state, f );
	    var pi8 = LLVM.Calls.LLVMPointerType( LLVM.Calls.LLVMInt8Type(), 0 );

	    var d =
		LLVM.Calls.LLVMAddFunction(
					   state.Module,
					   `__debug_init`,
					   LLVM.Calls.LLVMFunctionType(
								       LLVM.Calls.LLVMVoidType(),
	                                                               {
									   pi8,
								       }.address,
								       1,
								       0
								       )
					   );

	    LLVM.BasicBlock l = into.Block();

	    into.Call(
		      d,
		      { makeCStringConstant(state, c.HumanName ) }
		      );
	    
	    into.Branch(
			into.Load(g),
			l
			);

	    into.Store(
		       LLVM.Calls.LLVMConstInt(
					       LLVM.Calls.LLVMInt1Type(),
					       1L,
					       0
					       ),
		       g
		       );

	    into.Call(
		      d,
		      { makeCStringConstant(state, "static init...") }
		      );


	    var gcar =
		LLVM.Calls.LLVMAddFunction(
					   state.Module,
					   `__add_root`,
					   LLVM.Calls.LLVMFunctionType(
								       LLVM.Calls.LLVMVoidType(),
	                                                               {
									   pi8
								       }.address,
								       1,
								       0
								       )
					   );

	    foreach( Symbol s; c.Members.elements() ) {
		if( s.IsStatic && !s.IsMethod ) {
		    into.Call(
			      d,
			      { makeCStringConstant(state, s.HumanName) }
			      );
		    // IO.Std.err.println( "SSSS: static var: " + c.HumanName + " . " + s.Name ); IO.Std.err.flush();
		    into.Call(
			      gcar,
			      {
				  LLVM.Calls.LLVMConstPointerCast( s.getStaticGlobal(state), pi8 )
			      }
			      );
		}
			  
	    }		

	    body.compile( state, into );

	    into.Label( l );

	    into.RetVoid();

	    into.AtEnd();

	    into.Close();

	    var pft = LLVM.Calls.LLVMStructType(
						{ LLVM.Calls.LLVMInt32Type(),
						  LLVM.Calls.LLVMPointerType(ft,0) }.address,
						2,
						0
						);

	    var v = LLVM.Calls.LLVMAddGlobal(
				     state.Module,
				     LLVM.Calls.LLVMArrayType(pft,1),
				     `llvm.global_ctors`
				     );

	    LLVM.Calls.LLVMSetLinkage(
				      v,
				      LLVM.LLVMLinkage.LLVMAppendingLinkage
				      );

	    var fa = {
		LLVM.Calls.LLVMConstStruct( { LLVM.Calls.LLVMConstInt(LLVM.Calls.LLVMInt32Type(), 0L, 0),
					f }.address, 2, 0 )
	    };

	    LLVM.Calls.LLVMSetInitializer(
					  v,
					  LLVM.Calls.LLVMConstArray(
								    pft,
								    fa.address,
								    1
								    )
					  );

	}


	void compileImplements( CompileState state, Container c ) {
	    var ppi8 = LLVM.Calls.LLVMPointerType(
						  LLVM.Calls.LLVMPointerType(
									     LLVM.Calls.LLVMInt8Type(),
									     0
									     ),
						  0
						  );

	    var fi = c.getImplementsFunction(state);

	    var il = c.AllImplementedInterfaces;

	    IO.Std.err.FlushOnPrintln = true;

	    state.clearThrowBlocks();
	    var into = new IRBlock( state, fi );

	    if( il == null || il.Length == 0 ) {
		into.Ret(
			 LLVM.Calls.LLVMConstInt(
						 LLVM.Calls.LLVMInt1Type(),
						 0L,
						 0
						 )
			 );
		into.Close();

		return;
	    } 
		
	    var match = into.Block();

	    var p = LLVM.Calls.LLVMGetParam(fi,0);

	    foreach( Container i; il.elements() ) {
		// IO.Std.err.println( "add implements: " + i.HumanName );
		var ig = i.getInterfaceGlobal(state);
		// IO.Std.err.println( "compare:" );

		into.Branch(
			    into.ICmp(
				      LLVM.LLVMIntPredicate.LLVMIntEQ,
				      p,
				      ig
				      ),
			    match
			    );
	    }

	    into.Ret(
		     LLVM.Calls.LLVMConstInt(
					     LLVM.Calls.LLVMInt1Type(),
					     0L,
					     0
					     )
		     );

	    into.Label(match);
	    into.Ret(
		     LLVM.Calls.LLVMConstInt(
					     LLVM.Calls.LLVMInt1Type(),
					     1L,
					     0
					     )
		     );


	    into.Close();
	}

	void compileClassGlobal(CompileState state, Container c) {
	    IO.Std.err.FlushOnPrintln = true;

	    var ppi32 = LLVM.Calls.LLVMPointerType(
						  LLVM.Calls.LLVMPointerType(
									     LLVM.Calls.LLVMInt32Type(),
									     0
									     ),
						  0
						  );
	    var g = c.getClassGlobal(state);

	    state.maybeLinkOnce(g);

	    var i =
 	        LLVM.Calls.LLVMConstStruct(
	            {
		    	makeLoadVTable( state, ParseTree.class_type.Clazz )
  		    }.address,
		    1,
		    0
                );


	    var s =
	    	LLVM.Calls.LLVMConstStruct(
                    {
			i,
		        LLVM.Calls.LLVMConstPointerCast(	
			    makeLoadVTable( state, c ),
			    ppi32
			)
 		    }.address,
		    2,
		    0
		);

	    /*
	    IO.Std.err.println( "global: " );
	    LLVM.Calls.LLVMDumpValue( g );
	    IO.Std.err.println( "type: " );
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf(g) );
	    IO.Std.err.println( "struct: " );
	    LLVM.Calls.LLVMDumpValue( s );
	    */

	    LLVM.Calls.LLVMSetInitializer(
					  g,
					  s
					  );

	    /*
	    IO.Std.err.println( "result: " );
	    LLVM.Calls.LLVMDumpValue( g );
	    */
	}


        void compile2( CompileState state, Container c ) {
	    if( IsInterface ) {
		return;
	    }

	    c.resetMethodIndex();
            if( body != null ) {
		// IO.Std.err.println( "GGGG: begin compile class " + c.HumanName );

                state.beginCompileClass( this, c, name.Name );
                // c.buildClassTables( state );

		// c.referenceSelf();

                var s = state.needCompile( state.CurrentSourceFileName, c.FileName, c.Hash );

		if( s == CompileStatus.BAD_HASH ) {
		    warn( "class " + c.HumanName + " in library not may not be compatible with source definition" );

		    for( var ci = c; ci != null; ci = ci.Super ) {
			// IO.Std.err.println( "check " + ci.HumanName + ": sc: " + ci.Hash + " lc: " + state.Hash[ci.DecoratedName] );

			foreach( Symbol si; ci.Members.Iterator ) {
			    if( si.IsMethod ) {
				int la = state.Hash[si.DecoratedName];
				if( la == 0 ) {
				    if( !si.IsStatic ) {
					warn( "no library hash found for method " + si.HumanName );
				    }
				} else if( si.Address != la ) {
				    error( "class source definition does not match compiled library class for method " + si.HumanName + " (" + si.Address + " != " + la + ")" );
				    // IO.Std.err.println( "BAD: " + si.HumanName + ": sa: " + si.Address + " la: " + la );
				    //} else {
				    // IO.Std.err.println( " ok: " + si.HumanName + ": sa: " + si.Address + " la: " + la );
				}
			    }
			}
		    }
		}

		if( s == CompileStatus.STALE /* || s == CompileStatus.BAD_HASH */ ) {
		    if( state.WantVerbose ) {
			message( "compile class: " + c.HumanName );
		    }
                    
                    state.dumpActiveClasses( null );
                    
		    int frame_flags;

		    c.emitTables( state, this );

		    if( c.StaticSize > 0 && !c.HasStatic ) {
			throw new System.Exception( "oops: " + c.HumanName + " needs GC roots added" );
		    }

		    compileGetCTable( state, c );

		    if( c.HasStatic ) {
			compileBody( state, c );
		    }

		    compileImplements( state, c );

		    compileClassGlobal( state, c );

		    // block.WantLineNumbers = state.WantLineNumbers;
		    state.InlineOK = false;

                    
		    // IO.Std.err.println( "GGGG: begin compile class body " + c.HumanName );
                    body.compile( state );
		    // IO.Std.err.println( "GGGG: end compile class body " + c.HumanName );

		    c.BodyStatement.compile(state);


                    int unsafe_flags = state.UnsafeFlags;
                    if( unsafe_flags != 0 ) {
			bool want_safe = state.WantSafe;
			bool want_warn = state.WantWarnUnsafe;
			bool is_safe = true;
                        if( unsafe_flags & CompileState.UNSAFE_POINTER != 0 ) {
			    if( want_warn ) {
				warn( c.HumanName + " is unsafe: pointer arithmetic" );
			    }
			    is_safe = false;
                        }
                        if( unsafe_flags & CompileState.UNSAFE_CAST != 0 ) {
			    if( want_warn ) {
				warn( c.HumanName + " is unsafe: uncheckable casts" );
			    }
			    is_safe = false;
                        }
                        if( unsafe_flags & CompileState.UNSAFE_NATIVE != 0 ) {
			    if( want_warn ) {
				warn( c.HumanName + " is unsafe: calls native code" );
			    }
			    is_safe = false;
                        }
			if( unsafe_flags & CompileState.UNSAFE_BOUNDS != 0 ) {
			    if( want_warn ) {
				warn( c.HumanName + " is unsafe: unchecked array subscripts" );
			    }
			    is_safe = false;
			}
			if( unsafe_flags & CompileState.UNSAFE_LINK != 0 ) {
			    if( want_warn ) {
				warn( c.HumanName + " is unsafe: linker options" );
			    }
			    is_safe = false;
                        }

			if( want_safe && !is_safe ) {
			    error( "unsafe code not allowed: " + c.HumanName );
			}
                    }
                    
                    if( !errors_occurred ) {
			char ptr msg;

			if( LLVM.Calls.LLVMVerifyModule( state.Module, LLVM.LLVMVerifierFailureAction.LLVMPrintMessageAction, msg.address ) != 0 ) {
			    error( "failed to module verify " + c.HumanName + ": " + new String(msg) );
			}

		        // IO.Std.err.println( "assembling: " + c.getHumanName() );
                        // state.assembleFile( c.FileName );

			/*		    
			IO.Std.err.println( "ZZZZ: compiled: " + c.HumanName + ", try write module " + cast int(c.LLVMModule) + " to file..." ); IO.Std.err.flush();

			LLVM.Calls.LLVMDumpModule(c.LLVMModule);
			*/

			state.writeOrAssembleBitcode(c);

			state.dumpActiveClasses( c.FileName );
                    } else {
		        // IO.Std.err.println( "removing output file: " + c.getHumanName() );
                        // state.removeOutput( c.FileName );
                    }
		    state.countCompiledClass();
		}

		if( !errors_occurred ) {
		    state.addHashFile( c, s );
		}
		
		// IO.Std.err.println( "compilation complete: " + c.getHumanName() );

                state.endCompileClass( c );


            } else {
		IO.Std.err.println( "compile " + c.HumanName + ": null body" );
	    }
        }

        String toString() {
            StringBuffer result = new StringBuffer();
            result.append( "class " );
            result.append( name );
            if( super_ident != null ) {
                result.append( " extends " );
                result.append( super_ident );
            }
            result.append( body );

	    return result;
        }

	void print( CompileState state, Printer p ) {
	    state.beginCompileClass( this, c, name.Name );
	    
	    p.comment( comment );

	    super.print( state, p );

	    if( IsStruct ) {
		p.print( "struct " );
		/*
	    } else if( IsInterface ) {
		p.print( "interface " );
		*/
	    } else {
		p.print( "class " );
	    }
	    name.print( state, p );
	    p.print( " " );

	    if( is_generic ) {
		p.print( "<" );
		arguments.print( state, p );
		p.print( "> " );
	    }

	    bool any_supers = false;

	    if( super_ident != null ) {
		any_supers = true;
		p.print( ": " );
		super_ident.print( state, p );
		if( super_arguments != null ) {
		    p.print( "<" );
		    super_arguments.print( state, p );
		    p.print( ">" );
		}
		p.print( " " );
	    } else if( !IsInterface && !IsStruct ) {
		IO.Std.err.println( "no super ident: " + name + ", " + name.Name + ", " + (name.Name !~ "Object") );
		if( name.Name !~ "Object" ) {
		    any_supers = true;
		    p.print( ": System.Object " );
		}
	    }

	    if( implements_list != null ) {
		if( !any_supers ) { 
		    p.print( ": /* implements */ " );
		} else {
		    p.print( ", /* implements */ " );
		} 
		implements_list.print( state, p );
		p.print( " " );
	    }

	    p.println( "{" );

	    if( body != null ) {
		p.indent();
		body.print( state, p );
		p.outdent();
	    }

	    p.println( "};" );

	    state.endCompileClass( c );
	}
    }



    class StructDef extends ClassDef {
        // Identifier name;
        // BlockStatement body;
        // Container c;

	get bool IsStruct {
	    return true;
	}

        void init( int line_number, Identifier name, BlockStatement  body ) {
            super.init( line_number, name, null, null, null, null, body  );
        }
    }

    class InterfaceDef extends ClassDef {
        void init(
		  int line_number,
		  Identifier name,
		  IdentifierList arguments,
		  Identifier super_ident,
		  TypeExprList super_arguments,
		  BlockStatement body
	) {
	    super.init(
		       line_number,
		       name,
		       arguments,
		       super_ident,
		       super_arguments,
		       null,
		       body
		       );
        }

	get bool IsInterface {
	    return true;
	}
    }

    class VariableDef extends AccessDef {
        IdentifierList list;
        TypeExpr type_expr;
        int kind;

        void init( int line_number, Identifier name, int access, TypeExpr type ){
            super.init( line_number );
            this.list = new IdentifierList( line_number );
            this.list.add( name );
            this.type_expr = type;
        }

        void init( int line_number, IdentifierList list, int access, TypeExpr type ) {
            super.init( line_number );
            this.list = list;
            this.type_expr = type;
        }

	void clear( CompileState state ) {
	    // super.clear( state );
	    kind = 0;

	    type_expr.clear( state );
	    list.clear( state );
	}

	void checkTemplates( CompileState state ) {
	    type_expr.checkTemplates( state );
	    list.checkTemplates( state );
	}

	void declareClassSymbols( CompileState state ) {
	    if( state.State == CompileState.STATE_INSIDE_CLASS ) {
		declare( state );
	    }
	}

	void declareSymbols( CompileState state ) {
	    if( state.State > CompileState.STATE_INSIDE_CLASS ) {
		declare( state );
	    }
	}

        void declare( CompileState state ) {
	    int actual_access = Access;
            if( actual_access & Symbol.ACCESS_CONST != 0 ) {
                kind = Symbol.CONST;
            } else if( actual_access & Symbol.ACCESS_STATIC != 0 ) {
                kind = Symbol.FLAG_STATIC;
            }
            actual_access = actual_access & ~(Symbol.ACCESS_STATIC | Symbol.ACCESS_CONST);

	    if( state.CurrentMethod != null ) {
		if( actual_access == 0 ) {
                    actual_access = Symbol.ACCESS_LOCAL;
                } else {
		    error( "cannot give access specifier here" );
		}
	    } else if( actual_access == 0 ) {
		// variables default to private access:
		actual_access = Symbol.ACCESS_PRIVATE;
	    }

            var v = list.List;

            Type parsed_type = type_expr.parseType( state );

            foreach( Identifier ident; v.elements() ) {
		/*
		IO.Std.err.println( "about to declare variable: " + ident + ", type expr: " + type_expr );
		IO.Std.err.println( "symbol table: " + state.symbol_table );
		IO.Std.err.println( "about to declare variable: " + ident + ", parsed type: " + parsed_type );
		*/

		Expression e = ident.Initializer;
		Type use_type = parsed_type;
		if( parsed_type.TypeKind == Type.INFER ) {
		    if( e != null ) {
			use_type = e.getType( state );
		    } else {
			error( "variable " + ident.Name + " without explit type must be initialized here" );
			use_type = undefined_type;
		    }
		}

                Symbol symbol = state.declareVariable( this, ident.Name, kind, actual_access, use_type );

                if( kind == Symbol.CONST ) {
                    if( e == null ) {
                        error( "const " + symbol.HumanName + " has no initializer" );
                        continue;
                    }
                    
                    IRBlock d = getDummyIRBlock(state);
                    LLVM.Value t = e.compileValue( state, d );

		    if( LLVM.Calls.LLVMIsConstant(t) == 0 ) { 
                        error( "initializer for " + symbol.HumanName + " must be constant" );
		    } else {
                        symbol.LLVMValue = t;
                    }
                } else if( kind == Symbol.FLAG_STATIC ) {
		    // FIXME: initialize LLVM global value
		    symbol.getStaticGlobal(state);
		}
            }
        }

	void compile( CompileState state ) {
	    // IO.Std.err.println( "compile variable-def does nothing" );
	}

        void compile( CompileState state, IRBlock into ) {
            // seen_variables = true;
            Assignment a;

	    // IO.Std.err.println( "compile variable def, symbol table: " + state.symbol_table );

	    bool first = true;
            var v = list.List;
            foreach( Identifier ident; v.elements() ) {
                String name = ident.Name;
                                
                Symbol symbol = state.findSymbol( name, Symbol.FIND_ANY );
		if( symbol == null ) {
		    IO.Std.err.println( "looking for " + name );
		    IO.Std.err.flush();

		    error( "could not find previous defitition of " + name );
		    if( state.CurrentClass != null ) {
			error( "in class " + state.CurrentClass.HumanName );
		    }
		    if( state.CurrentMethod != null ) {
			error( "in method " + state.CurrentMethod.HumanName );
		    }
		    IO.Std.err.flush();
		    continue;
		}

                symbol.Defined = state.BlockLevel;

                if( ident.Initializer != null ) {
                    a = new Assignment( line_number, ident, ident.Initializer );                    
                    if( symbol.Kind == Symbol.CONST ) {
                        continue;
                    } else if( symbol.IsStatic ) {
			// in_static_initializer = true;

                        a.compile( state, into );
			// in_static_initializer = false;
                    } else if( symbol.IsLocal ) {
                        a.compile( state, into );
                    } else {
                        error( "cannot initialize " + symbol.HumanName + " in this context" );
                    }
                } else if( state.CurrentMethod != null ) {
                    a = new Assignment( line_number, ident, new Constant( line_number, Type.NULL, "0" ) );
                    a.compile( state, into );
                }

		symbol.markValueValid();
            }
        }

	get TypeExpr TypeExpr {
	    return type_expr;
	}
        
        Type getType( CompileState state ) {
            return type_expr.parseType( state );
        }

        get String FirstName {
            var v = list.List;
            
            if( v.Length >= 1 ) {
                return v[0].Name;
            } else {
                return null;
            }
        }


        void dump( StringBuffer human, StringBuffer decorate ) {
	    IO.Std.err.println( "no state dump called: " + new System.Backtrace() );
            if( type_expr != null ) {
                type_expr.dump( human, decorate );
            }
        }

        void dump( CompileState state, StringBuffer human, StringBuffer decorate ) {
            Type t = null;
            if( type_expr != null ) {
                t = type_expr.parseType( state );
            }
            if( t != null ) {
                t.dump( human, decorate );
            } else {
                human.append( "<null type>" );
                decorate.append( 'v' );
            }
            human.append( ' ' );
            
            if( list != null ) {
                list.dump( state, human );
            } else {
                human.append( "<empty>" );
            }
        }

        void dump( CompileState state, StringBuffer human ) {
	    IO.Std.err.println( "no state dump called: " + new System.Backtrace() );
            StringBuffer dummy;
            type_expr.parseType( state ).dump( human, dummy );
            human.append( ' ' );
            list.dump( state, human );
        }

        String toString() {
            StringBuffer result = new StringBuffer();
            result.append( type_expr );
            result.append( ' ' );
            result.append( list );
            result.append( ';' );

	    return result;
        }

	void print( CompileState state, Printer p ) {
	    super.print( state, p );
	    type_expr.print( state, p );
	    p.print( " " );
	    list.print( state, p );
	    if( !p.InArgs && !p.NoSemiColon ) {
		p.println( ";" );
	    }
	}
    }

    class MethodDef extends AccessDef {
        TypeExpr type;
        Identifier name;
        ArgumentsDef args;
        BlockStatement body;
        Container m;
	bool last_return;
	// bool is_empty;

	static int next_anon;

        void init( int line_number, Identifier name, int access, TypeExpr type, ArgumentsDef args, BlockStatement  body ) {
            super.init( line_number );

            this.name = name;
            this.type = type;
            this.args = args;
            this.body = body;
            this.m = null;

	    if( body == null ) {
		IO.Std.err.println( "no body for: " + name );
	    }
	   
	    // is_empty = body.IsEmpty;
        }

	set Identifier Name = n {
	    name = n;
	}

	get Identifier Name {
	    return name;
	}

	get TypeExpr ReturnTypeExpr {
	    return type;
	}

	get Vector<TypeExpr> ArgTypeExprs {
	    return args.TypeExprs;
	}

	Type getReturnType( CompileState state ) {
	    return type.parseType(state);
	}

	Vector<Type> getArgTypes( CompileState state ) {
	    if( args != null ) {
		return args.getTypes(state);
	    } else {
		return new Vector<Type>();
	    }
	}
       
	void clear( CompileState state ) {
	    // IO.Std.err.println( "method def clear: " + m );
	    m = null;

	    // last_return = false;
	
	    if( args != null ) {
		args.clear( state );
	    }
	    body.clear( state );
	}

	void checkTemplates( CompileState state ) {
	    if( args != null ) {
		args.checkTemplates( state );
	    }
	    body.checkTemplates( state );
	}

	// declare just the externally visible symbols for this method at this point (i.e.
	// the method itself plus its arguments):
        void declareClassSymbols( CompileState state ) {
            // IO.Std.err.println( "method def declare class symbols: " + name + " type: " + type );


	    /*
	    m = state.nextMethodByIndex( name.Name );
	    if( m != null ) {
		IO.Std.err.println( "MMMMMM: appear to have already parsed: " + m.HumanName );
		return;
	    }
	    */
            
            int kind = 0;
            bool skip_this = true;
            if( Access & Symbol.ACCESS_STATIC != 0 ) {
                kind = Symbol.FLAG_STATIC;
                skip_this = false;
            }

            int actual_access = Access & ~Symbol.ACCESS_STATIC;
            if( actual_access == 0 ) {
                if( state.CurrentMethod != null ) {
                    actual_access = Symbol.ACCESS_LOCAL;
                } else {
                    actual_access = Symbol.ACCESS_PUBLIC;
                }
            }
            
            Vector<Type> arg_types = null;
            if( args != null ) {
                arg_types = args.getTypes( state );
            }

	    String n = name.Name;
            m = cast<Container>( state.declareMethod( this, n, kind, actual_access, type.parseType(state), arg_types, null ) );

	    // m.IsEmpty = is_empty;

	    // m.IsPIC = state.WantPIC;

	    if( state.WantVirtual ) {
		m.IsFinal = false;
		warn( "force not final: " + m.HumanName );
	    }
	   
	    if( n.Length > 3 ) {
		if( n.startsWith( "get" ) || n.startsWith( "set" ) ) {
		    // IO.Std.err.println( "AAAAAA: declaring accessor method: " + n.substring(3) );
		    
		    // insert an entry in the symbol table for the accessor name to prevent symbol table look ups for it
		    // finding symbols in outer scopes before accessor methods are searched in Identifier.getType():
		    /* Symbol s =*/
		    state.declareAccessor( this, n.substring(3), n );
		    // IO.Std.err.println( "declared accessor: " + s + " because: " + m.HumanName + ", " + m );
		} else if( n.Length > 5 &&
			   (n.startsWith( "opGet" ) || n.startsWith( "opSet" ) ) ) {
		    state.declareAccessor( this, n.substring(5), n );
		}
	    }

            state.beginParseMethodArgs( this, m );

            // IO.Std.err.println( "method scope: " + m.Scope );

            if( args != null ) {
                args.declareSymbols( state, skip_this );
            }

            state.endParseMethodArgs( m );
            // IO.Std.err.println( "method def parsed: " + m );
        }

	int compileArguments( CompileState state, IRBlock into, bool include_this ) {
	    Vector<Type> a = m.ArgTypes;

	    int num_args = 0;
	    if( a != null ) {
		num_args = a.Length;
	    }

	    if( include_this ) {
		num_args = num_args + 1;
	    }

	    /*
	    if( Machine.CALLEE_POPS_ARGUMENTS && num_args > Machine.NUM_REG_PARAM ) {
		to_pop = (num_args - Machine.NUM_REG_PARAM) * Machine.WORD;
	    }
	    */

	    int i;

	    LLVM.Value f = m.getFunctionGlobal(state);
	    
	    for( i = 0; i < num_args; i = i + 1 ) {
		int j;

		if( include_this ) {
		    j = i - 1;
		} else {
		    j = i;
		}

		LLVM.Value v;

		if( j >= 0 ) {
		    Symbol sy = m.getSymbolByIndex( j );

		    // IO.Std.err.println( "BBBBBB: param " + i + " is " + sy + " at offset " + sy.getAddress() );

		    v = sy.getLocal(state, into);
		} else {
		    v = into.AllocaEntry( m.Owner.Type.getLLVMType(state), "this" );
		    state.CurrentMethod.ThisPointer = v;
		}

		addStoreIndirect( state, line_number, into, false, v, LLVM.Calls.LLVMGetParam( f, i ) );
	    }

	    return 0;
	}


	void checkOverride( CompileState state ) {
	    Container override = m.Override;

	    if( override != null ) {
		Type ot = override.Type;
		Type mt = m.Type;

		if( ot.TypeKind != mt.TypeKind ) {
		    error( "overriding method " + ot + " " + override.HumanName + " with " + mt + " " + m.HumanName + ": different return type" );
		} else if( ot.TypeKind == Type.CLASS && !ot.isAssignableFrom( mt ) ) {
		    error( "overriding method " + ot + " " + override.HumanName + " with " + mt + " " + m.HumanName + ": non assignable return type" );
		}
	    }
	}

	void declareSymbols( CompileState state ) {
	    // IO.Std.err.println( "declare symbols: " + name );

	    m = state.nextMethodByIndex( name.Name );

	    checkOverride( state );

            var decorated = m.DecoratedName;

            state.beginCompileMethod( this, m, decorated );
	    /*
	    IO.Std.err.println( "HHHH: declare symbols for: " + m.HumanName );
	    IO.Std.err.println( "HHHH: owner: " + m.Owner.HumanName );
	    IO.Std.err.println( "HHHH: current method: " + state.CurrentMethod.HumanName );
	    IO.Std.err.println( "HHHH: current class: " + state.CurrentClass.HumanName );
	    */
            state.IsInline = true;

            // IO.Std.err.println( "return label is: " + state.ReturnLabel );
            
            // IBlock into = new IBlock();
            
            state.beginParseMethodBody(m);            

	    if( state.WantReturnJumpElim && body.IsLastReturn ) {
		// IO.Std.err.println( "method def: inline, last is return" );
                
		last_return = true;
		body.markLastReturns();
	    }


	    body.declareSymbols( state );
            // IO.Std.err.println( "local depth A: " + m.getLocalOffset() );

            state.endParseMethodBody(m);
	    state.endCompileMethod(m);
	}


        void compile( CompileState state ) {
	    m = state.nextMethodByIndex( name.Name );
	    // IO.Std.err.println( "GGGG: compile method " + m.HumanName + " in class " + m.Owner.HumanName );

	    progress();

            var human = m.HumanName;
            var decorated = m.DecoratedName;

	    var fg = m.getFunctionGlobal(state);
	    state.maybeLinkOnce(fg);

	    LLVM.Calls.LLVMSetFunctionCallConv(fg, LLVM.LLVMCallConv.LLVMCCallConv);
	    

	    var into = new IRBlock( state, fg );	   
	    state.clearThrowBlocks();

            if( m == null ) {
                throw new Exception( "couldn't find previous definition for " + human + " (" + decorated + ")" );
                return;
            }

	    m.allocaLocals( state, into );

	    if( state.WantVeryVerbose ) {
		message( "compile method: " + human );
            }

            state.beginCompileMethod( this, m, decorated );

	    // IO.Std.err.println( "GGGG: current method " + state.CurrentMethod.HumanName + " in class " + state.CurrentClass.HumanName );
                      
            // state.beginParseMethodBody(m);            

	    // args.compile( state, into );

            if( m.Owner.Super != null && m.Owner.Super != object_type.Clazz && state.WantWarnInit && m.Name =~ "init" &&
                !body.isFirstStatementSuperConstructorCall( state ) ) {
                warn( "first statement in " + human + " is not a call to super.init() or this.init()" );
            }

	    /*
	    // FIXME: don't think template parameters can affect last return - it's a fixed property of
	    // the parse tree and probably doesn't need to be clear()'d
	    if( state.WantReturnJumpElim && body.IsLastReturn ) {
		last_return = true;
		body.markLastReturns();
		// IO.Std.err.println( "method def: compile " + m.HumanName + " last is return: " + last_return );
	    }
	    */


	    // IO.Std.err.println( "local depth B: " + m.getLocalOffset() );


	    bool success = false;
	    int i;
	    int frame_flags;
	    int[] attempt;

	    if( state.WantInline ) {
		i = 0;
		state.InlineOK = true;
	    } else {
		i = 1;
		state.InlineOK = false;
	    }

	    state.endParseMethodBody(m);
	    // into.WantLineNumbers = state.WantLineNumbers;                
	    
	   
	    compileArguments(state, into, !m.IsStatic);

	    try {
		// IO.Std.err.println( "GGGG: start compile body method " + state.CurrentMethod.HumanName + " in class " + state.CurrentClass.HumanName );
		body.compile( state, into );
		// IO.Std.err.println( "GGGG: end compile body method " + state.CurrentMethod.HumanName + " in class " + state.CurrentClass.HumanName );

		if( m.Type.isVoid() ) {
		    into.RetVoid();
		} else {
		    into.Ret(m.Type.getLLVMNull(state));
		}
		into.AtEnd();
		
		into.Close();		
		success = true;
	    } catch( System.NotImplementedException nie ) {
		into.AtEnd();

		into.Close();
		LLVM.Calls.LLVMRemoveFunction(fg);
		// LLVM.Calls.LLVMDeleteFunction(fg);
		IO.Std.err.println( "" + m.HumanName + ": not implemented" );
		if( state.WantVeryVerbose ) {
		    IO.Std.err.println( "cause: " + nie );
		}
		success = false;
	    } catch( AbortCompilingThisMethodException ae ) {
		error( "" + m.HumanName + ": unrecoverable error" );
		if( state.WantVeryVerbose ) {
		    IO.Std.err.println( "cause: " + nie );
		}
		success = false;
	    }

	    // IO.Std.err.println( "method def: compile B last is return: " + last_return );
	    
	    if( m.Type.TypeKind != Type.VOID ) {
		if( last_return ) {
		    // IO.Std.err.println( "last return - no fall through return needed: " + last_return );
		    // into.add( new ITree( line_number, Op.COMMENT, 0, "no fall through return here" ) );
		} else {
		    // IO.Std.err.println( "not last return - fall through return is needed: " + last_return );
		    // into.add( new ITree( line_number, Op.COMMENT, 0, "may not explictly return - fall through return here" ) );
		    // not certain if all possible paths through function end with return statements - emit fall through result of zero/null
		    
		    
		    // into.add( new ITree( line_number, Op.RESULT_F, 0, new ITree( line_number, Op.CONST, Machine.WORD, 0 ) ) );
		}
		// } else {
		// IO.Std.err.println( "void return" );
	    }
                
	    // into.add( new ITree( line_number, Op.LABEL, 0, state.ReturnLabel ) );
	    // into.add( new ITree( line_number, Op.LEAVE, 0 ) );
	    
	    
	    // into.add( new ITree( line_number, Op.RET, 0, to_pop ) );
            
	    /*
	      if( !errors_occurred ) {
	      if( i == 0 ) {
	      attempt = attempt_inline;
	      } else {
	      attempt = attempt_no_inline;
	      }
	      // IO.Std.err.println( "gen method: " + human );
	      Gen.MBitSet address_taken = state.AddressesTaken;
	      // IO.Std.err.println( "gen method " + m.HumanName + ", address taken: " + address_taken );
	      
	      if( genMethod( state, into, decorated, human, attempt, address_taken, frame_flags ) ) {
	      // IO.Std.err.println( "success" );
	      success = true;
	      break;
	      }
	      } else {
	      // i.e. don't try again and don't throw an exception - we've successfully compiled it
	      // in that we've found a user error and reported it
	      success = true;
	      break;
	      }
	      
	      if( i == 0 ) {
	      IO.Std.err.println( "try compiling " + human + " again without inlined calls" );
	      }

	    */
	    

	    state.InlineOK = false;
	    
	    // message( human );

	    if( success ) {
		LLVM.Calls.LLVMCleanUpFunction(fg);
		if (!didErrorsOccur() ) {
		    // LLVM.Calls.LLVMDumpValue( fg );
		    
		    if( LLVM.Calls.LLVMVerifyFunction( fg, LLVM.LLVMVerifierFailureAction.LLVMPrintMessageAction ) != 0 ) {
			error( "failed to function verify: " + human );
			IO.Std.err.println( "VVVV: AA failed to function verify: " + human ); IO.Std.err.flush();
			
			LLVM.Calls.LLVMDumpValue( fg );
		    }
		   
		}
	    }
	    /*
	    // IO.Std.err.println( "finished compile: " + human );
	    Machine.emitEndUnwindInfo( state.Output, decorated, human, state.WantLineNumbers, frame_flags, ro_start, ro_end );
	    
	    Machine.emitRoDataSegment( f );
	    Machine.emitLabel( f, ro_end.Int );
	    Machine.emitTextSegment( f );
	    */
	    state.resetExceptionLevel();            
            state.endCompileMethod(m);

	    // clear(state);
        }

	/*
        void dump( CompileState state, StringBuffer human, StringBuffer decorated ) {
            decorated.append( name.Name );
            decorated.append( "__" );
            
            // StringBuffer dummy = new StringBuffer();
            
            var class_type = new Type( Type.CLASS, state.CurrentClass );
            class_type.dumpDecorate( decorated );

	    var return_type = type.parseType( state );
	    return_type.dumpHuman( human );
            
            human.append( ' ' );
	    class_type.dumpHuman( human );
                    
            human.append( '.' );
            human.append( name.Name );
            human.append( '(' );
            
            if( args != null ) {
                args.dump( state, human, decorated );
            }
            
            human.append( ')' );
        }
	*/

        String toString() {
            StringBuffer result = new StringBuffer();
            result.append( type );
            result.append( ' ' );
            result.append( name );
            result.append( "()" );
            result.append( body );

            return result;
        }

	void print( CompileState state, Printer p ) {
	    p.comment( comment );
	    super.print( state, p );
	    type.print( state, p );
	    p.print( " " );
	    name.print( state, p );
	    p.print( "(" );
	    if( args != null ) {
		p.InArgs = true;
		p.OneLine = true;
		p.print( " " );
		args.print( state, p );
		p.print( " " );
		p.OneLine = false;
		p.InArgs = false;
	    }
	    p.print( ")" );
	    if( state.CurrentClass.IsInterface ) {
		p.println( ";" );
	    } else {
		p.println( " {}" );
	    }
	}
    }

    class NativeDef extends AccessDef {
        TypeExpr type;
        Identifier name;
        ArgumentsDef args;
        Container m;

        void init( int line_number, Identifier name, int access, TypeExpr type, ArgumentsDef  args ) {
            super.init( line_number );

            this.name = name;
            this.type = type;
            this.args = args;
            this.m = null;
       }

	void clear( CompileState state ) {
	    error( "cannot define native method " + name + " within template class" );

	    IO.Std.err.println( "NNNNNN: clearing native method def - this will break later. from: " + new System.Backtrace() );
	    m = null;
	    if( args != null ) {
		args.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
	    if( args != null ) {
		args.checkTemplates( state );
	    }
	}
        
        void declareClassSymbols( CompileState state ) {
	    // IO.Std.err.println( "declare class symbols native def: " + name );
            int kind = Symbol.FLAG_STATIC;
            int actual_access = Access & ~Symbol.ACCESS_STATIC;
            if( actual_access == 0 ) {
                if( state.CurrentMethod != null ) {
                    actual_access = Symbol.ACCESS_LOCAL;
                } else {
                    actual_access = Symbol.ACCESS_PUBLIC;
                }
            }
            
            Vector<Type> arg_types = null;
            if( args != null ) {
                arg_types = args.getTypes( state );
            }
            
            m = cast<Container>(
				state.declareMethod( this, name.Name, kind, actual_access, type.parseType( state ), arg_types, name.Name  )
                    );

	    if( m == null ) {
		// inside template - error message already issued
		return;
	    }

	    // IO.Std.err.println( "declare class symbols native def: " + m );

	    m.IsNative = true;

            state.beginParseMethodArgs( this, m );
            
            if( args != null ) {
                args.declareSymbols( state );
            }
            
            state.endParseMethodArgs( m );    
        }

        void compile( CompileState state ) {
	    if( m == null ) {
		// inside template - error message already issued
		return;
	    }

	    if( state.WantMarkUnsafe ) {
		state.markCodeUnsafe( CompileState.UNSAFE_NATIVE );
	    }
            if( state.WantWarnUnsafe ) {
                warn( "declaring native method " + m.Name );
            }
        }

	void print( CompileState state, Printer p ) {
	    /*
	    super.print( state, p );
	    p.print( "native " );

	    type.print( state, p );
	    p.print( " " );
	    name.print( state, p );
	    p.print( "(" );
	    if( args != null ) {
		p.print( " " );
		p.InArgs = true;
		args.print( state, p );
		p.InArgs = false;
		p.print( " " );
	    }
	    p.println( ");" );
	    */
	}
    }
}