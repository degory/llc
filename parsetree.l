// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import type;
import symbol;
import intermediate;
import operation;

import parsecall;
import parsecond;
import parsedef;
import parseexpr;
import parseident;
import parseloop;
import parsepackage;
import parsetry;
import parsetype;

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
    
    enum EDType {
	CATCH_RETURN = 0,
        CATCH_FINALLY = 1,
	CATCH_EXCEPTION = 2,
	THROW_RETURN = 3, 
	THROW_EXCEPTION = 4,
	THROW_FINALLY = 5,
	THROW_STOP = 6
    }

    class Printer extends Object {
	static String INDENT = "    ";

	IO.Writer out;
	int indent_level;
	int last_line;
	int state;
	public int expr_level;

	bool first;

	bool in_args;
	bool in_elif;
	bool one_line;
	bool no_semi_colon;
	
	void init( IO.Writer out ) {
	    this.out = out;
	    first = true;
	    last_line = -1;
	}

	void printIndent() {
	    if( first ) {
		for( int i = 0; i < indent_level; i = i + 1 ) {
		    out.print( INDENT );
		}
		first = false;	   
	    }
	}

	get bool InArgs {
	    return in_args;
	}

	set bool InArgs = v {
	    in_args = v;
	}

	get bool InElif {
	    return in_elif;
	}

	set bool InElif = v {
	    in_elif = v;
	}

	get bool OneLine {
	    return one_line;
	}

	set bool OneLine = v {
	    one_line = v;
	}

	get bool NoSemiColon {
	    return no_semi_colon;
	}

	void setNoSemiColon( bool v ) {
	    no_semi_colon = v;
	}

	void print( Object o ) {
	    printIndent();
	    out.print( o );
	}

	void println( Object o ) {
	    printIndent();
	    if( !one_line ) {
		out.println( o );
		first = true;
	    } else {
		out.print( o );
	    }
	}

	void indent() {
	    indent_level = indent_level + 1;
	}

	void outdent() {
	    indent_level = indent_level - 1;
	}

	void inparen() {
	    expr_level = expr_level + 1;
	}
	
	void outparen() {
	    expr_level = expr_level - 1;
	}

	void nl() {
	    if( !one_line && !first ) {
		println();
	    }
	}

	void println() {
	    if( !one_line ) {
		out.println();
		first = true;
	    }
	}

	void comment(String comment) {
	    if( comment != null ) {
		// IO.Std.out.println( "CCCCCC: output comment: " + comment );

		out.print( comment );
		first = comment.endsWith('\n');
	    }
	}

	int precedence( int op ) {
	    switch( op ) {
	    case Op.NEG:
		return 9;

	    case Op.NOT:
		return 8;

	    case Op.BOOL_NOT:
		return 2;

	    case Op.BOOL_AND, Op.BOOL_OR:
		return 1;
		
	    case Op.ADD, Op.SUB:
		return 6;
		
	    case Op.MUL, Op.DIV, Op.MOD:
		return 7;
		
	    case Op.SHL, Op.SHAR:
		return 5;
					    
	    case Op.AND, Op.OR, Op.XOR:
		return 4;
				    
	    case Op.EQ, Op.NE, Op.GT, Op.LT, Op.GE, Op.LE:
		return 3;

	    default:
		IO.Std.err.println( "unknown precedence for op: " + op );
		return 10;
	    }
	}
    }

    class CannotInlineException extends Exception {
	void init() {
	    // IO.Std.err.println( "creating cannot inline exception" );
	    super.init("cannot inline this construct");
	}
    }

    class NotLeafInlineException extends Exception {
	void init() {
	    // IO.Std.err.println( "creating not leaf inline exception" );
	    super.init();
	}
    }

    class ExceptionDescriptor extends Object {
	public EDType type;
	public ILabel descriptor_label;
	public ILabel code_label;

	void init( EDType type, ILabel dl, ILabel cl ) {
	    this.type = type;
	    descriptor_label = dl;
	    code_label = cl;
	}
    }

    class ParseTree extends Object {
	protected String comment;
        protected String file_name;
        protected int line_number;

        protected const int
            LOAD_FLAG_ADDRESS = 1,
            LOAD_FLAG_STATIC = 2,
            LOAD_FLAG_DISCARD = 4,
            LOAD_FLAG_REFERENCE = 8,
	    LOAD_FLAG_PROC_CALL = 16,

            EX_FRAME_SIZE = 24,
            EX_RETURN_OFFSET = 12;

	protected static String last_comment;

        protected static String current_file_name;
        // protected static bool in_finally = false;
        protected static bool public_fields = false;

        protected static bool errors_occurred;

        // protected static int block_level;
        // protected static bool seen_variables;

	// protected static bool in_static_initializer;

	public static int inline_method_count;
        public static int inline_call_count;

        protected static Type
            undefined_type = new Type( Type.ERROR ),
            string_type,
            object_type,
	    bool_type,
	    char_type,	    
            integer_type,
	    long_type,
	    word_type,
            iterator_type,
	// generic_iterator_type = null,
            array_type,
	    class_type,
	    type_type,
	    proc_type;

        protected static Symbol undefined_variable = new Symbol( null, "#undefined variable#",
                           Symbol.LOCAL_VARIABLE,
                           Symbol.ACCESS_PUBLIC | Symbol.ACCESS_STATIC,
                           undefined_type );

        protected static Container undefined_method = new Container( null, null, "#undefined method#", Symbol.INSTANCE_METHOD,
                        Symbol.ACCESS_PUBLIC | Symbol.ACCESS_STATIC,
                        undefined_type );

        protected static Container undefined_class = new Container( null, null, "#undefined class#" );

        protected static void parseFile( String file ) {
        }

        protected static void addAdditionalFile( String file ) {
            throw new Exception( "implement me" );
        }

	static void appendLastComment( String s ) {
	    if( last_comment == null ) {
		last_comment = s;
	    } else {
		last_comment = last_comment + s;
	    }
	}

	static set String LastComment = s {
	    last_comment = s;
	}	

	static get String LastComment {
	    var result = last_comment;
	    // last_comment = null;
	    return result;
	}

	static void resetLastComment() {
	    last_comment = null;
	}

	get String Comment {
	    return comment;
	}

	set String Comment = c {
	    comment = c;
	}

	static get Container ObjectClass {
	    return object_type.Clazz;
	}

	/*
	static void resetExceptionLevel() {
	    exception_level = 0;
	}
	*/

	/*
	protected ILabel getTopExceptionHandler() {
	    if( exception_level > 0 ) {
		return exception[exception_level-1].code_label;
	    }
	}

	protected ITree makeDummyExceptionHandlerJumpValue( IBlock into, ITree t, int size ) {
	    if( exception_level > 0 ) {
		int u = TempFactory.nextTemp();

		makeStoreTemporary( u, size, t );
		into.add( new ITree( 0, Op.DUMMY_JUMP, 8, exception[exception_level-1].code_label ) );
		return makeLoadTemporary( u, size );
	    } else {
		return t;
	    }
	}
	*/

	// load a value allowing for a jump from the run-time on null pointer to any active exception
	// handler:
	protected static ITree makeLoadIndirect( CompileState state, int line_number, IBlock into, int size, bool could_be_null, ITree t ) {
	    if( could_be_null && state.InExceptionHandler ) {
		int u = TempFactory.nextTemp();

		// ensure t is completely evaluated before it's dereferenced:
		into.add( makeStoreTemporary( u, size, new ITree( line_number, Op.INDIRECT, size, t ) ) );
		into.add( new ITree( line_number, Op.DUMMY_JUMP, 0, state.TopException.code_label ) );
		return makeLoadTemporary( u, size );
	    } else {
		return new ITree( line_number, Op.INDIRECT, size, t );
	    }
	}

	// store a value allowing for a jump from the run-time on null pointer to any active exception
	// handler:
	protected static void addStoreIndirect( CompileState state, int line_number, IBlock into, int size, bool could_be_null, ITree d, ITree s ) {
	    into.add( new ITree( line_number, Op.COPY, size,
				 new ITree( line_number, Op.INDIRECT, size, d ),
				 s )
		      );

	    if( could_be_null && state.InExceptionHandler ) {
		into.add( new ITree( line_number, Op.DUMMY_JUMP, 0, state.TopException.code_label ) );
	    }
	}

	/*
	// load a value allowing for a jump from the run-time on null pointer to any active exception
	// handler:
	protected void makeSafeCopy( int line_number, IBlock into, ITree dest, ITree t, int size ) {
	    into.add( new ITree( 0, Op.COPY, size, dest, t ) );
	    if( exception_level > 0 ) {
		into.add( new ITree( 0, Op.DUMMY_JUMP, 8, exception[exception_level-1].code_label ) );
	    }
	}
	*/

	// inserting a dummy jump instruction to the active exception handler so register allocator
	// understands live values must transfer from here to there:
	protected static void addDummyExceptionHandlerJump( CompileState state, int line_number, IBlock into ) {
	    if( state.InExceptionHandler ) {
		into.add( new ITree( line_number, Op.DUMMY_JUMP, 0, state.TopException.code_label ) );
	    }
	}


        protected static void resetTemporary() {
	    ITree.resetTemp();
            // IO.Std.err.println( "implement ParseTree.resetTemporary" );
        }

        static set String CurrentFileName = cfn {
            current_file_name = cfn;
        }

	public static bool didErrorsOccur() {
	    return errors_occurred;
	}

        static int getJumpOp( int op, bool jump ) {
            if( jump ) {
                switch ( op ) {
                case Op.EQ:return Op.EQ;
                case Op.NE:return Op.NE;
                case Op.GT:return Op.GT;
                case Op.LT:return Op.LT;
                case Op.GE:return Op.GE;
                case Op.LE:return Op.LE;
                }
            } else {
                switch ( op ) {
                case Op.EQ:return Op.NE;
                case Op.NE:return Op.EQ;
                case Op.GT:return Op.LE;
                case Op.LT:return Op.GE;
                case Op.GE:return Op.LT;
                case Op.LE:return Op.GT;
                }
            }
            throw new Exception( "unexpected jump operation: " + op );
        }

        static int getReverseJumpOp( int op, bool jump ) {
            if( jump ) {
                switch ( op ) {
                case Op.EQ: return Op.EQ;
                case Op.NE: return Op.NE;
                case Op.GT: return Op.LT;
                case Op.LT: return Op.GT;
                case Op.GE: return Op.LE;
                case Op.LE: return Op.GE;
                }
            } else {
                switch ( op ) {
                case Op.EQ: return Op.NE;
                case Op.NE: return Op.EQ;
                case Op.GT: return Op.GT;
                case Op.LT: return Op.LT;
                case Op.GE: return Op.GE;
                case Op.LE: return Op.LE;
                }
            }
            throw new Exception( "unexpected jump operation: " + op );
        }

	static Type getBoxType( CompileState state, Type type ) {
	    Type sub_type;
	    Vector<Type> args;

	    switch( type.TypeKind ) {
	    case Type.BOOL:
		return bool_type;
		
	    case Type.CHAR:
		return char_type;
		
	    case Type.INTEGER:
		return integer_type;
		
	    case Type.LONG:
		return long_type;
		
	    case Type.WORD:
		return word_type;

	    case Type.VECTOR:
		sub_type = type.SubType;
		/*
		if( sub_type.TypeKind == Type.VECTOR || sub_type.TypeKind == Type.PROC ) {
		    sub_type = sub_type.getBoxType(state);
		}
		*/
		args = new Vector<Type>();
		args.add(sub_type);
		type = state.findGeneric( array_type.Clazz, args, false );
		// IO.Std.err.println( "boxed array has type: " + type + ", " + type.Clazz );
		return type;

	    case Type.PROC:
		args = new Vector<Type>();
		args.add(type);
		type = state.findGeneric( proc_type.Clazz, args, false );
		return type;
	    }
	    return null;
	}
 
        static Type defineStandardClassType( CompileState state, String name, String super_name ) {
            Identifier super_ident = null;
            if( super_name != null ) {
                super_ident = new Identifier( 0, super_name );
            }
            ClassDef def = new ClassDef( 0, new Identifier( 0, name ), null, super_ident, null );
	    def.InternalDefinition = true;
            def.declareGlobalSymbols( state );
            Container c = cast<Container>(state.findSymbol( name, Symbol.FIND_TYPE ));
	    // IO.Std.err.println( "define standard class type " + name + " extends " + super_name + " -> " + c );
            return new Type( Type.CLASS, c );
        }
 
        static void initUndefinedSymbols( CompileState state ) {
            undefined_variable.Owner = undefined_method;
            undefined_method.Owner = undefined_class;
            undefined_method.DecoratedName = "undefined_method";
            undefined_type.SubType = undefined_type;
            undefined_variable.Address = 0;
            undefined_variable.Defined = 1;
            undefined_method.Address = 0;

	    // predefine some standard types that we expect to exist:
            Container system = state.declareNameSpace( null, "System" );
            Container util = state.declareNameSpace( null, "Util" );
	    Container generic = state.declareNameSpace( null, "Generic" );
            state.enterNameSpace( system );
            
            object_type = defineStandardClassType( state, "Object", null );
            string_type = defineStandardClassType( state, "String", "Object" );
	    bool_type = defineStandardClassType( state, "Bool", "Object" );
	    char_type = defineStandardClassType( state, "Char", "Object" );	    
            integer_type = defineStandardClassType( state, "Int", "Object" );
	    long_type = defineStandardClassType( state, "Long", "Object" );
	    word_type = defineStandardClassType( state, "Word", "Object" );
	    proc_type = defineStandardClassType( state, "Proc", "Proc" );
	    // type_type = defineStandardClassType( state, "Type", "Object" );
	    class_type = defineStandardClassType( state, "Class", "Object" );
            state.exitNameSpace( system );
            
            state.enterNameSpace( util );
            iterator_type = defineStandardClassType( state, "Iterator", "Object" );
            state.exitNameSpace( util );

	    state.enterNameSpace( generic );
	    array_type = defineStandardClassType( state, "Array", "Object" );

	    // generic_iterator_type = defineStandardClassType( state, "Iterator", "Object" );
	    state.exitNameSpace( generic );

	    // IO.Std.err.println( "defined string-type: " + string_type );
        }
        
        static String dumpArguments( Vector<Type> arguments ) {
            StringBuffer buffer = new StringBuffer();
            StringBuffer dummy = new StringBuffer();
            
            if( arguments != null ) {
                for( var i = arguments.elements(); i.hasMoreElements(); ) {
                    i.nextElement().dump( buffer, dummy );
                    if( i.hasMoreElements() ) {
                        buffer.append(',');
                    }
                }
            }
            
            return buffer;
        }

        // static int next_temporary = 0;

        static ITree makeLoadTemporary( int t, int size ) {
            return new ITree( 0, Op.REG_VAR, size, t );
        }
        
        static ITree makeStoreTemporary( int t, int size, ITree value ) {
            return new ITree( 0, Op.COPY, size, new ITree( 0, Op.REG_VAR, size, t ), value );
        }

        static ITree makeLoadThis( CompileState state, int line_number, IBlock into ) {
	    // no need to allow for a dummy jump to exception handler here. 
	    // this may be null if a final method is called on a null object but
	    // loading this cannot in itself cause a null pointer exception as
	    // this is either on the stack or will be assigned to register:

	    return makeLoadIndirect( state, line_number, into, Machine.WORD, false,
				     new ITree( line_number, Op.LOCAL,
						Machine.WORD, -Machine.THIS_OFFSET )
				     );


        }

        void init( int line_number ) {
            super.init();
	    // IO.Std.err.println( "initialize ParseTree..." );
            file_name = current_file_name;
            this.line_number = line_number;

	    comment = LastComment;
	    /*
	    if( comment != null ) {
		IO.Std.out.println( "CCCCCC: init comment: " + comment );
	    }
	    */
        }

        get int LineNumber {
            return line_number;
        }

	void clear( CompileState state ) {
	    IO.Std.err.println( "not clearing: " + this.Class.Name );
	}

	void checkTemplates( CompileState state ) {
	    // IO.Std.err.println( "not checking templates: " + this.Class.Name );
	}

        void declareSymbols( CompileState state ) {
            // IO.Std.err.println( "parsing: " + this );
        }

	void useTypes( CompileState state ) {
	}

	void prepareInline( CompileState state ) {
	}

	void checkInline( CompileState state ) {
	    state.countInline();
	}

	bool isProperty( CompileState state ) {
	    return false;
	}

	bool isIndexer( CompileState state ) {
	    return false;
	}

	void wantSetProperty( CompileState state, Expression value ) {
	}

	void wantIndexer( CompileState state, Expression value ) {
	}

	get MethodCall MethodCall {
	    throw new Exception( "does not have a method call: " + this.Class.Name );
	}

	/*
	void compileSetProperty( CompileState state, IBlock into, Expression value ) {
            error( "oops: can't compile set property: " + this );
	    throw new Exception("here");
	}
	*/

        void compile( CompileState state, IBlock into ) {
            // IO.Std.err.println( "compiling: " + this );
        }

	void print( CompileState state, Printer p ) {
	    p.print( "/* " + Class.Name + " */" );
	}

	void pl( Printer p ) {
	    // p.comment( comment );
	}
        
        void compile( CompileState state ) {
            error( "oops: can't compile: " + Class.Name + " from " + new System.Backtrace() );
            // IO.Std.err.println( "compiling: " + this + " results in ERROR" );
        }

        ITree compileValue( CompileState state, IBlock into ) {
            error( "oops: can't compile value" );
            return new ITree( line_number, Op.ERROR, 0 );
        }

        ITree compileAddress( CompileState state, IBlock into ) {
            error( "has no address" );
            return new ITree( line_number, Op.ERROR, 0 );
        }

        String dump( CompileState state ) {
            StringBuffer buffer = new StringBuffer();
            dump( state, buffer );
            return buffer;
        }

        void dump( CompileState state, StringBuffer buffer ) {
            buffer.append( "<unknown: " + ClassName + ">" );
        }

        void checkAccess( Symbol s, CompileState state ) {
	    if( s.Kind == Symbol.ACCESSOR ) {
		// just allow here, underlying method will be checked later:
		return;
	    }

            Container context = state.CurrentContext;
            if( s.canAccessFrom( context ) ) {
                return;
            }
    
            String access;
            if( s.IsLocal ) {
                access = "local";
            } else if( s.IsPrivate ) {
                access = "private";
            } else if( s.IsProtected ) {
                access = "protected";
            } else {
                access = "unexpected";
            }

            String c = "global context";
            if( context != null ) {
                c = context.HumanName;
            }

            error( "cannot access " + access + " " + s.HumanName + " from " + c );
        }

        void setFileName() {
            // in case we create any more parse trees - so they have correct file name for error reporting
            current_file_name = file_name;
        }

	static bool checked_is_tty = false;
	static bool err_is_tty = false;
	static bool need_newline = true;
	static int progress_state;
	static String progress_wheel = "|/-\\";
	static String backspace = "" + cast<char>(13);

	static void newline() {
	    if( !checked_is_tty ) {
		err_is_tty = IO.Std.err.IsTTY;
		checked_is_tty = true;
	    }
	    
	    if( err_is_tty && need_newline ) {
		IO.Std.err.print( backspace );
		need_newline = false;
	    }
	}

	static void progress() {
	    if( CompileState.WantJobs > 1 ) {
		return;
	    }

	    if( !checked_is_tty ) {
		err_is_tty = IO.Std.err.IsTTY;
		checked_is_tty = true;
	    }

	    if( err_is_tty ) {
		int time = cast int(native.__get_time());

		if( time != progress_state ) {
		    progress_state = time;

		    IO.Std.err.print( backspace + progress_wheel[progress_state & 3] );
		    IO.Std.err.flush();
		    need_newline = true;
		}
	    }
	}

	static void message( String msg ) {
	    newline();
            IO.Std.err.println( msg );
	}

	static void markError() { 
	    errors_occurred = true;
	}

	get String TemplateErrorString {
	    Container c = CompileState.Instance.CurrentClass;
	    if( c != null && c.Template != null ) {
		return " (in template " + c.HumanName + ")";
	    } else {
		return "";
	    }
	}

        void error( String msg ) {
	    // if( !CompileState.Instance.IsInline ) {
		newline();
		IO.Std.err.println( file_name + ": " + line_number + ": error: " + msg + TemplateErrorString );
		// } else {
		// IO.Std.err.println( "hiding inline error message: " + file_name + ": " + line_number + ": error: " + msg + TemplateErrorString );
		// }
	    errors_occurred = true;
        }

        void warn( String msg ) {
	    if( !CompileState.Instance.IsInline ) {
		newline();
		IO.Std.err.println( file_name + ": " + line_number + ": warn: " + msg + TemplateErrorString );
		//} else {
		//IO.Std.err.println( "hiding inline warning message: " + file_name + ": " + line_number + ": warn: " + msg + TemplateErrorString );
	    }
        }


	ITree castTo( int to_size, int from_size, ITree t ) {
	    if( to_size == from_size ) {
		return t;
	    } else if( from_size == 1 ) {
		return new ITree( line_number, Op.CAST_FROM1,
				  to_size,
				  t );
	    } else if( from_size == 4 ) {
		return new ITree( line_number, Op.CAST_FROM4,
				  to_size,
				  t );
	    } else if( from_size == 8 ) {
		return new ITree( line_number, Op.CAST_FROM8,
				  to_size,
				  t );
	    } else {
		error( "cast from unexpected size: " + from_size );
	    }
	}

	ITree loadGlobalTLS( CompileState state, String name, String name_pic ) {
	    if( state.WantPIC ) {
		// FIXME: TLS access with PIC required here:
		return new ITree( 0, Op.INDIRECT, Machine.WORD,
				  new ITree( 0, Op.GLOBAL, Machine.WORD, name_pic )
				  );
	    } else {
		return new ITree( 0, Op.GLOBAL, Machine.WORD, name );
	    }
	}

	ITree loadGlobal( CompileState state, String name, int offset ) {
	    if( state.WantPIC ) {
		/*
		if( offset == 0 ) {
		    return new ITree( 0, Op.INDIRECT, Machine.WORD,
				      new ITree( 0, Op.GLOBAL, Machine.WORD, name + "@GOTPCREL(%rip)" ) );
		} else {
		    return new ITree( 0, Op.ADD, Machine.WORD,
				      new ITree( 0, Op.INDIRECT, Machine.WORD,
						 new ITree( 0, Op.GLOBAL, Machine.WORD, name + "@GOTPCREL(%rip)" ) ),
				      new ITree( 0, Op.CONST, Machine.WORD, offset ) );

		}
		*/

		if( offset == 0 ) {
		    return new ITree( 0, Op.INDIRECT, Machine.WORD,
				      new ITree( 0, Op.GLOBAL, Machine.WORD, name + "@GOTPCREL(%rip)" ) );
		} else {
		    IO.Std.err.println( "load global '" + name + "' + " + offset );
		    return new ITree( 0, Op.ADD, Machine.WORD,
				      new ITree( 0, Op.INDIRECT, Machine.WORD,
						 new ITree( 0, Op.GLOBAL, Machine.WORD, name + "@GOTPCREL(%rip)" ) ),
				      new ITree( 0, Op.CONST, Machine.WORD, offset )
				      );
		}			
	    } else {
		if( offset == 0 ) {
		    return new ITree( 0, Op.GLOBAL, Machine.WORD, name );
		} else {
		    return new ITree( 0, Op.GLOBAL, Machine.WORD, name + "+" + offset );
		}
	    }
	}
    }

    class Pragma extends Statement {
	IdentifierList settings;

	void init( int line_number, IdentifierList s ) {
	    super.init( line_number );
	    settings = s;
	}

	void apply( CompileState state ) {
	    foreach( Identifier name; settings.List.elements() ) {
		apply( state, name );
	    }
	}

	void apply( CompileState state, Identifier name ) {
	    if( name.Name =~ "NoWarnHide" ) {
		state.WantWarnHide = false;
	    } else if( name.Name =~ "NoWarnResolve" ) {
		state.WantWarnResolve = false;
	    } else if( name.Name =~ "NoWarnUnsafe" ) {
		state.WantWarnUnsafe = false;
	    } else if( name.Name =~ "NoMarkUnsafe" ) {
		state.WantMarkUnsafe = false;
	    } else if( name.Name =~ "NoProfile" ) {
		state.WantProfile = false;
	    }
	}

        void declareGlobalSymbols( CompileState state ) {
	    apply( state );
        }

	void useTypes( CompileState state ) {
	    apply( state );
	}

	void declareClassSymbols( CompileState state ) {
	    apply( state );
	}

        void parseImports( CompileState state ) {
	    apply( state );
        }

	void checkTemplates( CompileState state ) {
	    apply( state );
	}
        
        void declareSymbols( CompileState state ) {
	    apply( state );
	}

	void checkInline( CompileState state ) {
	    apply( state );
	}

	void prepareInline( CompileState state ) {
	    apply( state );
	}
        
        void compile( CompileState state ) {
	    apply( state );
        }	
    }

    class DocComment extends ParseTree {
	void init( int line_number, String c ) {
	    comment = c;
	}

	get String Value {
	    return comment;
	}
    }

    class AccessSpecifier extends ParseTree {
        private int flags;
        
        void init( int line_number, int flags ) {
            super.init( line_number );
            this.flags = flags;
        }
        
        void add( int flags ) {
            this.flags = this.flags | flags;
        }
        
        get int Access {
            return flags;
        }
    }


    class Statement extends ParseTree {
        void init( int line_number ) {
            super.init( line_number );
        }
        
        bool isFirstStatementSuperConstructorCall( CompileState state ) {
            return false;
        }

        void declareGlobalSymbols( CompileState state ) {
        }	

	void declareClassSymbols( CompileState state ) {
	}

        void parseImports( CompileState state ) {
        }

        get String LoopName {
            return null;
        }

        set Identifier LoopName = l {
	    throw new Exception( "this Statement (" + this + ") cannot have a loop label" );
	}

	get bool IsLastReturn {
	    return false;
	}

	get bool IsEmpty {
	    return false;
	}

	void markLastReturns() {
	}

	get bool IsIf {
	    return false;
	}
    }


    class NullStatement extends Statement {
        void init( int line_number ) {
            super.init( line_number );
        }

	void clear( CompileState state ) {
	}

	void checkTemplates( CompileState state ) {
	}

	void compile( CompileState state ) {
	    // IO.Std.err.println( "compile null statement does nothing" );
	}

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    if( !p.NoSemiColon ) {
		p.println( ";" );
	    }
	}

	get bool IsEmpty {
	    return true;
	}
    }

    class AssertStatement extends Statement {
        Expression expression;    

        void init( int line_number, Expression expression ) {
            super.init( line_number );
            this.expression = expression;
        }

	void clear( CompileState state ) {
	    expression.clear(state);
	}

	void checkTemplates( CompileState state ) {
	    expression.checkTemplates( state );
	}

        void compile( CompileState state, IBlock into ) {
	    ILabel ok = TempFactory.nextLabel();

            expression.compileBoolean( state, into, ok, false );
            
            into.add( new ITree( line_number, Op.STATIC_CALL_DISCARD, 0, "__throw_assertexception" ) );
            into.add( new ITree( line_number, Op.LABEL, 0, ok ) );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    p.print( "assert " );
	    expression.print( state, p );
	    if( !p.NoSemiColon ) {
		p.println( ";" );
	    }
	}
    }

    class ReturnStatement extends Statement {
        Expression expression;
	bool no_code_after_return;

        void init( int line_number, Expression expression ) {
            super.init( line_number );
            this.expression = expression;
        }

	void clear( CompileState state ) {
	    // no_code_after_return = false;
	    if( expression != null ) {
		expression.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
	    if( expression != null ) {
		expression.checkTemplates( state );
	    }
	}

	void checkInline( CompileState state ) {
	    if( expression != null ) {
		expression.checkInline( state );
	    }
	}

	get bool IsLastReturn {
	    // IO.Std.err.println( "return statement: last is return" );
	    return true;
	}

	void markLastReturns() {
	    // IO.Std.err.println( "return statement: mark last returns" );
	    no_code_after_return = true;
	}

        void compile( CompileState state, IBlock into ) {
	    // IO.Std.err.println( "return, method: " + state.CurrentMethod );
	    Type method_type = state.CurrentMethod.Type;
	    // IO.Std.err.println( "return, type: " + method_type );

	    ITree t = null;

            if( expression != null ) {
                Type expr_type = expression.getType( state );

		if( expr_type == null ) {
		    throw new Exception( "weird: return expression: " + expression + " has null type" );
		}
                
                if( !method_type.isAssignableFrom( expr_type ) ) {
		    error( "cannot return value of type " + expr_type.dump() + " from method of type " + method_type.dump() );
                }
		
		int et_size = expr_type.RegSize;
		int mt_size = method_type.RegSize;

		t = expression.compileValue( state, into );

		if( et_size != mt_size ) {
		    t = castTo( mt_size, et_size, t );
		}
            } else {
                if( method_type.TypeKind != Type.VOID ) {
                    error( "method must return a value of type " + method_type.dump() );
                }
            }


            // return from within a try: 
            //   has a finally or within an out
            // need a throw return 
            // return from within a catch: need a throw return
            // return from within a finally: 
            //   inner finally:  need a throw return (there is always an outer finally to catch it)
            //   outermost finally: can return but need stack adjust
            
            // if we're in an exception handler, and we're not in an outermost finally, then we need to throw a return

            if( state.InExceptionHandler ) {
		ILabel return_label = null;

		ExceptionDescriptor ed = state.TopFinallyOrReturn;

		if( ed == null ) {
		    throw new Exception( "no finally or return handler found on exception handler stack" );
		}

		return_label = ed.code_label;

                if( expression != null ) {
		    into.add( new ITree( line_number,
					     Op.THROW_RETURN, Machine.WORD, 
					     t,
					     return_label ) );
                } else {
                    into.add( new ITree( line_number,
                                         Op.THROW_RETURN, Machine.WORD,
					 new ITree( line_number, Op.CONST, Machine.WORD, 0 ),
					 return_label ) );
                }
	    } else if( no_code_after_return ) {
		// IO.Std.err.println( "return statement: no jump to return label required" );
		// don't do any branch optimizations so if we don't do this, all method calls that return a result,
		// including all inlined calls, will require a jump to the return label even if no code between
		// the return statement and the function epilog:		
		if( expression != null ) {
		    into.add( new ITree( line_number,
					 Op.RESULT_F,
					 0,
					 t )
			      );
		    into.add( new ITree( line_number, Op.COMMENT, 0, "fall through to function exit here" ) );
		}
	    } else {
                // regular return
                if( expression != null ) {
		    into.add( new ITree( line_number,
					 Op.RESULT,
					 Machine.WORD,
					 t,
					 null, state.ReturnLabel
					 )
			      );
                } else {
                    into.add( new 
                              ITree( line_number, Op.JUMP, 0,
                                     state.ReturnLabel ) );
                }
		//    }
            
            //    into.add( new ITree( line_number, Op.LEAVE, 4 ) );
	    }
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    if( expression != null ) {
		p.print( "return " );
		expression.print( state, p );
		p.println( ";" );
	    } else {
		p.println( "return;" );
	    }
	}
    }


    class BlockStatement extends Statement {
        Vector<Statement> list;
	bool last_return;
        
        void init( int line_number ) {
            super.init( line_number );
            list = new Vector<Statement>();
        }

	void init( int line_number, Statement first ) {
	    init( line_number );
	    if( first != null ) {
		add( first );
	    }
	}

	void clear( CompileState state ) {
	    // last_return = false;
            foreach( Statement s; list.elements() ) {
                s.clear( state );
	    }
	}

	void checkTemplates( CompileState state ) {
            foreach( Statement s; list.elements() ) {
                s.checkTemplates( state );
	    }
	}

        void add( Statement next ) {
	    if( next == null ) {
		throw new Exception( "adding null statement to: " + this );
	    }
            list.add( next );
        }

        bool isFirstStatementSuperConstructorCall( CompileState state ) {
            return list.Length >= 1 && cast<Statement>(list[0]).isFirstStatementSuperConstructorCall( state );
        }

        void dump( CompileState state, StringBuffer  buffer ) {
            buffer.append( "{\n" );
            foreach( Statement s; list.elements() ) {
                s.dump( state, buffer );
            }
            buffer.append( "}\n" );
        }


        void parseImports( CompileState state ) {
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.parseImports( state );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }
        }

        void declareGlobalSymbols( CompileState state ) {
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.declareGlobalSymbols( state );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }
        }

	void useTypes( CompileState state ) {
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.useTypes( state );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }
	}

        void declareClassSymbols( CompileState state ) {
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.declareClassSymbols( state );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }
        }

        void declareSymbols( CompileState state ) {
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.declareSymbols( state );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }
        }


	void prepareInline( CompileState state ) {
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.prepareInline( state );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }
	}

	void checkInline( CompileState state ) {
	    state.enterBlock();
	    /*
	    if( !state.CurrentMethod != null && state.CurrentMethod.IsLeaf ) {
		return;
	    }
	    */
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.checkInline( state );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }

	    state.exitBlock();
	}

	get bool IsLastReturn {
	    last_return = false;
	    if( list != null && list.Length > 0 ) {
		Statement s = list[list.Length-1];
		last_return = s.IsLastReturn;
		/*
		if( last_return ) {
		    IO.Std.err.println( "block statement: last is return" );
		}
		*/
	    }
	    return last_return;
	}

	void markLastReturns() {
	    if( last_return ) {
		// IO.Std.err.println( "block statement: mark last return" );
	    
		list[list.Length-1].markLastReturns();
	    }
	}

	get bool IsEmpty {
	    foreach( Statement s; list.Iterator ) {
		if( !s.IsEmpty ) {
		    return false;
		}
	    }

	    return true;
	}

        void compile( CompileState state, IBlock into ) {
	    state.enterBlock();
            // block_level = block_level + 1;
            // seen_variables = false;
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.compile( state, into );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }
   
            if( /* seen_variables && */ state.CurrentMethod != null ) {
                state.CurrentMethod.stripDefined( state.BlockLevel );
            }
            // block_level = block_level - 1;
	    state.exitBlock();
        }
        
        void compile( CompileState state ) {
	    // IO.Std.err.println( "BlockStatement.compile from: " + new System.Backtrace() );
            foreach( Statement s; list.elements() ) {
                if( s != null ) {
                    s.compile( state );
                } else {
                    throw new Exception( "null statement\n" );
                }
            }
        }


        String toString() {
            StringBuffer result = new StringBuffer();

            result.append( "{" );
            foreach( Statement s; list.elements() ) {
                result.append( s );
            }
            result.append( "}" );

	    return result;
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

            foreach( Statement s; list.elements() ) {
		s.print( state, p );
	    }
	}
    }

    class EmptyBody extends BlockStatement {
        void init( int line_number ) {
	    super.init( line_number );
	    add( new Parse.NullStatement( line_number ) );
        }

	get bool IsEmpty {
	    return true;
	}
    }

    class Assignment extends Statement {
        Expression left_value;
        Expression right_value;

        void init( int line_number, Expression left_value, Expression right_value ) {
            super.init( line_number );
            this.left_value = left_value;
            this.right_value = right_value;

	    if( left_value == null ) {
		throw new Exception( "assignment: left value is null" );
	    }
	    if( right_value == null ) {
		throw new Exception( "assignment: right value is null" );
	    }
        }

        void dump( CompileState state, StringBuffer buffer ) {
            left_value.dump( state, buffer );
            buffer.append( '=' );
            right_value.dump( state, buffer );
        }

        String toString() {
            StringBuffer result = new StringBuffer();
            result.append( left_value );
            result.append( '=' );
            result.append( right_value );
            result.append( ';' );
            return result;
        }

	void clear( CompileState state ) {
	    /*
	    IO.Std.err.println( "clear assignment" );
	    IO.Std.err.println( "left value:  " + left_value );
	    IO.Std.err.println( "right value: " + right_value  );
	    */

	    left_value.clear(state);
	    right_value.clear(state);
	}

	void checkTemplates( CompileState state ) {
	    left_value.checkTemplates(state);
	    right_value.checkTemplates(state);
	}

        void declareSymbols( CompileState state ) {
        }

	void checkInline( CompileState state ) {
	    left_value.checkInline( state );
	    right_value.checkInline( state );
	}

        void compile( CompileState state, IBlock into ) {
	    left_value.wantSetProperty( state, right_value );
            Type tl = left_value.getType( state );
            Type tr = right_value.getType( state );

	    /*
	    IO.Std.err.println( "assign left value:  " + left_value + " type: " + tl );
	    IO.Std.err.println( "assign right value: " + right_value + " type: " + tr );
	    */

	    if( !left_value.isProperty(state) && !left_value.isLeftValue(state) ) {
		error( "cannot assign to non lvalue " + left_value.dump(state) );
	    }
		
	    if( left_value.isProperty(state) ) {
		left_value.compileValue( state, into );
	    } else {
		if( !tl.isAssignableFrom( tr ) && tl.TypeKind != Type.ERROR ) {
		    /*
		    IO.Std.err.println( "assign left value:  " + left_value + " type: " + tl );
		    IO.Std.err.println( "assign right value: " + right_value + " type: " + tr );
		    */
		    error( tl.dump() + " is not assignable from " + tr.dump() );
		}

		ITree l = left_value.compileAddress( state, into );
		ITree r = right_value.compileValue( state, into );
		addStoreIndirect( state, line_number, into, tl.RegSize, true, l, r );
	    }
	    // into.add( new ITree( line_number, Op.COPY, tl.getRegSize(), makeLoadIndirect( line_number, into, Op.INDIRECT, tl.getRegSize(), l ), r ) );
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    left_value.print( state, p );
	    p.print( " = " );
	    right_value.print( state, p );
	    if( !p.NoSemiColon ) {
		p.println(";");
	    }
	}
    }

    class VectorAccess extends LeftValue {
        Expression left_value;
        Expression right_value;
	MethodCall method_call;
	bool want_set_value;
	Expression set_value;

        void init( int line_number, Expression left_value, Expression right_value ) {
            super.init( line_number );
            this.left_value = left_value;
            this.right_value = right_value;
        }

	void clear( CompileState state ) {
	    // IO.Std.err.println( "clear vector access: " + left_value + "[" + right_value + "]" );
	    type = null;
	    method_call = null;
	    want_set_value = false;
	    set_value = null;
	    left_value.clear( state );
	    right_value.clear( state );
	}

	void checkTemplates( CompileState state ) {
	    left_value.checkTemplates( state );
	    right_value.checkTemplates( state );
	}


	bool isProperty(CompileState state) {
	    return method_call != null;
	}

	void wantSetProperty( CompileState state, Expression set_value ) {
	    want_set_value = true;
	    this.set_value = set_value;
	}
        
        void calcType( CompileState state ) {
	    left_value.wantIndexer( state, right_value );

	    if( want_set_value ) {
		left_value.wantSetProperty( state, set_value );
	    } 

            type = left_value.getType( state );
	    // IO.Std.err.println( "vector access calc type: " + type );

	    bool cast_generic_array = false;

	    // is the left value a specialization of Generic.Array<T>? If so we want to compile a direct array subscript on it
	    // rather than going through it's indexer:
	    if( type.TypeKind == Type.CLASS && type.Clazz.Template == array_type.Clazz ) {
		// IO.Std.err.println( "subscripting a Generic.Array: " + type );
	       
		Type t = type.getActualArgumentType(state, "T");
		cast_generic_array = true;
	    }

	    // if the left value is an indexer then we just defer to it's method call:
	    if( !cast_generic_array && left_value.isIndexer( state ) ) {
		if( want_set_value ) {
		    // method call will check supplied type, do not use type
		    // of left value as it will be 'void':
		    type = undefined_type;
		}
		method_call = left_value.MethodCall;

		// IO.Std.err.println( "left is indexer: " + left_value + " of type " + type + ", call: " + method_call );
		return;
	    } else if( type.TypeKind == Type.ERROR ) {
                return;

            // if the left value is an array then we'll want to compile a subscript on it:
            } else if( type.TypeKind == Type.VECTOR ) {
		// IO.Std.err.println( "left type is vector: " + left_value + ", " + type );
		if( !cast_generic_array ) {
		    type = type.SubType;
		}
		// IO.Std.err.println( "result type is: " + type );

		if( !right_value.getType( state ).isInteger() && right_value.getType(state).TypeKind != Type.ERROR ) {
		    error( "subscript expression must be integer" );
		}
            // if the left value is a class an it's not an indexer then we'll see if we can find an indexed accessor for it: 
	    } else if( type.TypeKind == Type.CLASS ) {
		// IO.Std.err.println( "left type is class: " + left_value + ", " + type );

		String n;

		if( want_set_value ) {
		    n = "opSet";
		} else {
		    n = "opGet";
		}

		Identifier name = new Identifier( line_number, n );
		ExpressionList arg = new ExpressionList( line_number );
		arg.add( right_value );
		if( want_set_value ) {
		    arg.add( set_value );
		}
	       
		method_call = new MethodCall( line_number, left_value, name, arg );

		// IO.Std.err.println( "method call is: " + method_call );
		type = method_call.getType(state);

		// IO.Std.err.println( "result type is: " + type );
            } else {
                error( "cannot subscript non-array" );
                type = undefined_type;
            }

	    // IO.Std.err.println( "vector access type is " + type + " element size is " + type.getRegSize() );
        }

        void dump( CompileState state, StringBuffer buffer ) {
            left_value.dump( state, buffer );
            buffer.append('[');
            right_value.dump( state, buffer );
            buffer.append(']');
        }
        
        void declareSymbols( CompileState state ) {
        }

	void checkInline( CompileState state ) {
	    left_value.checkInline(state);
	    right_value.checkInline(state);
	}
        
        ITree compileAddress( CompileState state, IBlock into ) {
            ITree cl, cr;

	    if( method_call != null ) {
		IO.Std.err.println( "oops: should not compileAddress for indexed object property access" );
		return new ITree( line_number, Op.ERROR, 0 );
	    }

            cl = left_value.compileValue(state, into);
            cr = right_value.compileValue(state, into);

	    int sr = right_value.getType(state).Size;

	    if( sr == 1 ) {		
		cr = new ITree( line_number, Op.CAST_FROM1, Machine.WORD, cr );
	    } else if( sr == 4 && sr != Machine.WORD ) { // FIXME: constant == constant does not compile...
		/*
		cr = new ITree( line_number, Op.CAST_FROM4, Machine.WORD, cr );
		*/

		// this is a cheat to avoid a movsx on every bounds check. It relies on
		// arrays being less than 2G elements long and amd64 clearing the top
		// half of registers on every 32bit operation. If the array index is a 
		// negative 32-bit number even without sign extension it will fail the 
		// bounds check because the unsigned 64bit comparison will view it as a very
		// large positive integer - larger than any bound up to 2G elements
		// the 2GB bound limit is required anyway as T[].sizeof has type int 
		cr = new ITree( line_number, Op.TREAT_AS, Machine.WORD, cr );
	    }
            // #ifdef CHECK_VECTOR_ACCESS

            cl = cl.foldConstants();
            cr = cr.foldConstants();

            if( !cl.isSimple() ) {
                int tl = TempFactory.nextTemp();
                into.add( makeStoreTemporary( tl, Machine.WORD, cl ) );
                cl = makeLoadTemporary( tl, Machine.WORD );
            }

            if( !cr.isSimple() ) {
                int tr = TempFactory.nextTemp();
                into.add( makeStoreTemporary( tr, Machine.WORD, cr ) );
                cr = makeLoadTemporary( tr, Machine.WORD );
            }

	    if( state.WantSplitBounds ) {
		ILabel bounds_label = TempFactory.nextLabel();

		into.add( new ITree( line_number, Op.BOUNDS_R, 0, cl, cr, bounds_label ) );
		into.addEpilog( new ITree( line_number, Op.BOUNDS_L, 0, bounds_label ) );
			  
	    } else {
		into.add( new ITree( line_number, Op.BOUNDS, 0 /* getType(state).getRegSize() */, cl, cr ) );
	    }
	    // let back end know jump to exception handler possible here:
	    addDummyExceptionHandlerJump( state, line_number, into );

            //#endif

	    int element_size = getType( state ).RegSize;

            if( element_size != 1 ) {
                cr = new ITree( line_number, Op.MUL, Machine.WORD, cr,
                                new ITree( line_number, Op.CONST, Machine.WORD, element_size ) );
            }

	    cl = new ITree( line_number, Op.ADD, Machine.WORD,
			    cl,
			    new ITree( line_number, Op.CONST, Machine.WORD, Machine.VECTOR_DATA_OFFSET )
			    );


	    ITree result = new ITree( line_number, Op.ADD, Machine.WORD, cl, cr );

	    // IO.Std.err.println( "array access: " + result );
	    return result;
            
        }

        ITree compileValue( CompileState state, IBlock into ) {
	    getType(state);
	    if( method_call == null ) {
		// IO.Std.err.println( "no method call: " + this + ", type: " + type );
		// cannot throw null pointer exception as if null then previous bounds check would already have done so:
		return makeLoadIndirect( state, line_number, into, getType(state).RegSize, false, compileAddress(state, into) );
	    } else {
		// IO.Std.err.println( "have method call: " + this + ", type: " + type );
		if( want_set_value ) {
		    // IO.Std.err.println( "array access setter method has no value here: " + new System.Backtrace() );
		    method_call.compileDiscardValue( state, into );
		    return new ITree( line_number, Op.ERROR, 0 );
		} else {
		    return method_call.compileValue( state, into );
		}
	    }
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    left_value.print( state, p );
	    p.print( "[" );
	    right_value.print( state, p );
	    p.print( "]" );
	}
    }

    class ExpressionStatement extends Statement {
        Expression left;

        void init( int line_number, Expression left ) {
            super.init( line_number );
            this.left = left;
        }

        bool isFirstStatementSuperConstructorCall( CompileState state ) {
            return left != null && left.isSuperConstructorCall( state );
        }

	get bool IsEmpty {
	    return left.IsEmpty;
	}

	void checkInline( CompileState state ) {
	    left.checkInline( state );
	}

	void checkTemplates( CompileState state ) {
	    left.checkTemplates( state );
	}

	void clear( CompileState state ) {
	    left.clear( state );
	}
        
        void compile( CompileState state, IBlock into ) {
            if( left != null ) {
                left.compileDiscardValue( state, into );
            }
        }

	void print( CompileState state, Printer p ) {
	    pl(p);

	    p.nl();
	    left.print( state, p );
	    if( !p.NoSemiColon ) {
		p.println(";");
	    }
	}
    }

    //#define EX_FRAME_SIZE     24
    //#define EX_RETURN_OFFSET  12

}

