#C

// Copyright (C) 2004-2010 degs <junk@giantblob.com> all rights reserved

import vector;
import container;

namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Gen.Machine;
    use Generic.Vector;

    class Type extends Object {
        private Container c;
        private Type sub_type;
	private Type box_type;
        private int type_kind;
	private LLVM.Type llvm_type;

        public const int
            MATCH_NONE = 0,
            MATCH_NULL = 100,
            MATCH_EXACT = 1000;

        public const int
            NONE = 0,
            VOID = 1,
            BOOL = 3,
            BYTE = 4,
            CHAR = 5,
            SHORT = 6,
            INTEGER = 7,
	    WORD = 8,
            LONG = 9,
            FLOAT = 10,
            DOUBLE = 11,
            SIMPLE = DOUBLE,
            VECTOR = 12,
            REFERENCE = 13,
            POINTER = 14,
            CLASS = 15,
            ENUM = 16,
            NAMESPACE = 17,
            STRING = 18,
            CSTRING = 19,
            SUPER = 20,
            NULL = 21,
            STRUCT = 22,
	    PROC = 23,
	    INFER = 24,
            ERROR = 25;

        public const int 
            QUALITY_EXACT = 5,
            QUALITY_GOOD = 4,
            QUALITY_AMBIG = 3,
            QUALITY_BETTER_IN_OUTER_SCOPE = 2,
            QUALITY_NO_MATCH = 0;

	public static int box_lookups;
	public static int box_misses;

        get int RegSize {
	    return Size;
        }

        bool isContainer() {
            // fprintf( stderr, "typekind %d == %d,%d,%d?\n", type_kind, Type.CLASS, Type.ENUM, Type.NAMESPACE );
            return type_kind == Type.CLASS || type_kind == Type.ENUM || type_kind == Type.NAMESPACE;
        }

        void init( int type_kind ) {
            super.init();
            this.type_kind = type_kind;
            this.c = null;
            this.sub_type = null;
        }

        void init( int type_kind, Type sub_type ) {
            super.init();
            this.type_kind = type_kind;
            this.sub_type = sub_type;
            this.c = null;
        }

        void init( int type_kind, Container c ) {
            super.init();
            this.type_kind = type_kind;
            this.c = c;
            this.sub_type = null;
        }

        get int TypeKind {
            if( type_kind == Type.CLASS && c == null ) {
                throw new Exception( "wierd: type is Type.CLASS but class is null" );
            }
            return type_kind;
        }

        static bool isScalar(int t) {
            return t == Type.LONG || t == Type.WORD || t == Type.INTEGER || t == Type.CHAR;
        }	

        bool isScalar() {
	    return isScalar(type_kind);
        }

	bool isEnum() {
	    return type_kind == Type.ENUM;
	}

	bool isPointer() {
	    return type_kind == Type.POINTER;
	}
	
	bool isNull() {
	    return type_kind == Type.NONE;
	}

	bool isBool() {
	    return type_kind == Type.BOOL;
	}

	static bool isInteger(int type_kind) {
            return type_kind == Type.LONG || type_kind == Type.WORD || type_kind == Type.INTEGER;
	}

	static bool isVoid(int type_kind) {
	    return type_kind == Type.VOID;
	}

	bool isObject() {
	    if( type_kind != Type.CLASS ) {
		return false;
	    }
	    return c.IsObject;
	}

	bool isInterface() {
	    if( type_kind != Type.CLASS ) {
		return false;
	    }
	    return c.IsInterface;
	}

	bool isReference() {
	    if( type_kind == CLASS || type_kind == STRUCT || type_kind == PROC || type_kind == VECTOR || type_kind == POINTER || type_kind == REFERENCE ) {
		return true;
	    }

	    // IO.Std.err.println( "not a reference: " + this );
	    return false;
	}

        bool isInteger() {
	    return isInteger(type_kind);
        }

	bool isVoid() {
	    return isVoid(type_kind);
	}

	static bool warned_bits;

	LLVM.Type getLLVMType(CompileState state) {
            switch ( type_kind ) {
            case Type.NONE, Type.VOID:
		return LLVM.Calls.LLVMVoidType();

            case Type.BOOL:
		return LLVM.Calls.LLVMInt1Type();
                
            case Type.BYTE:
		return LLVM.Calls.LLVMInt8Type();
                
            case Type.CHAR:
		return LLVM.Calls.LLVMInt8Type();
                
            case Type.INTEGER:
		return LLVM.Calls.LLVMInt32Type();

	    case Type.LONG:
		return LLVM.Calls.LLVMInt64Type();

	    case Type.WORD:
		if( state.Want64BitTarget ) {
		    if( !warned_bits && state.WantVeryVerbose ) {
			IO.Std.err.println( "target is 64 bit" );
		    }
		    warned_bits = true;
		    return LLVM.Calls.LLVMInt64Type();
		} else {		    
		    if( !warned_bits && state.WantVeryVerbose ) {
			IO.Std.err.println( "target is 32 bit" );
		    }
		    warned_bits = true;
		    return LLVM.Calls.LLVMInt32Type();
		}
		/*
		if( Gen.Machine.WORD == 8 ) {
		    decorate.append( 'l' );
		} else if( Gen.Machine.WORD == 4 ) {
		    decorate.append( 'i' );
		} else {
		    throw new Exception( "unexpected word length: " + Gen.Machine.WORD );
		}
		*/
		   
                
            case Type.VECTOR:
		var et = {
		    LLVM.Calls.LLVMVTableType(),
		    LLVM.Calls.LLVMInt32Type(),  // length should maybe be word sized?
		    LLVM.Calls.LLVMArrayType(sub_type.getLLVMType(state), 0)
		};

		return LLVM.Calls.LLVMPointerType(
						  LLVM.Calls.LLVMStructType(et.address, et.length,0),
						  0 );
                
            case Type.REFERENCE:
		return LLVM.Calls.LLVMPointerType( sub_type.getLLVMType(state), 0 );
                
            case Type.POINTER:
		return LLVM.Calls.LLVMPointerType( sub_type.getLLVMType(state), 0 );

            case Type.CLASS:
		return LLVM.Calls.LLVMPointerType( c.LLVMType, 0 );

            case Type.STRING:
		return LLVM.Calls.LLVMPointerType( LLVM.Calls.LLVMInt8Type(), 0 );

	    case Type.PROC:
		// IO.Std.err.println( "want LLVM type for proc type: " + this + " c is: " + c );
		var t = getBoxType(state);
		var l = t.getLLVMType(state);

		// IO.Std.err.print( "box type: " + t + " -> LLVM type: " ); IO.Std.err.flush();
		// LLVM.Calls.LLVMDumpType(l);

		return l;


	    case Type.ENUM:
		return LLVM.Calls.LLVMInt32Type();

	    case Type.ERROR:
		return LLVM.Calls.LLVMInt32Type();		

            default:
		throw new System.Exception( "unexpected type: " + this );
            }
        }

	LLVM.Value getLLVMNull(CompileState state) {
            switch ( type_kind ) {
            case Type.NONE, Type.VOID:
		throw new System.Exception( "cannot create LLVM null of this type" );

            case Type.BOOL,
		Type.BYTE,
		Type.CHAR,
		Type.INTEGER,
		Type.LONG,
		Type.WORD,
		Type.ENUM,
		Type.ERROR:
		return LLVM.Calls.LLVMConstInt( getLLVMType(state), 0L, 0 );

		/*
		if( Gen.Machine.WORD == 8 ) {
		    decorate.append( 'l' );
		} else if( Gen.Machine.WORD == 4 ) {
		    decorate.append( 'i' );
		} else {
		    throw new Exception( "unexpected word length: " + Gen.Machine.WORD );
		}
		*/
		   
                
            case Type.VECTOR,
		Type.REFERENCE,
		Type.POINTER,
		Type.CLASS,
		Type.STRING,
		Type.PROC:		
		return LLVM.Calls.LLVMConstPointerNull( getLLVMType(state) );

            default:
		throw new System.Exception( "unexpected type: " + this );
            }
        }

        get Type SubType {
            if( sub_type == null ) {
                throw new Exception( "oops: getSubType() but sub_type is null" );
            }
            return sub_type;
        }

	Type getBoxType( CompileState state ) {
	    box_lookups = box_lookups + 1;
	    if( box_type == null ) {
		box_misses = box_misses + 1;
		box_type = ParseTree.getBoxType(state, this);
	    }
	    return box_type;
	}

	/// given a type, which should be a specialization generic class and the name of one of its format type arguments
	/// return the actual type of that argument
	Type getActualArgumentType( CompileState state, String type_name ) {
	    Symbol s = c.findSymbol( type_name, Symbol.FIND_ANY );
	    if( s.Kind == Symbol.TYPE ) {
		return s.Type;
	    }

	    IO.Std.err.println( "strange: no actual type argument " + this + "." + type_name + ", symbol: " + s );
	    return null;
	}

	get bool CanTreatAsObject {
	    var tk = TypeKind;
	    return tk == VECTOR || tk == PROC;
	}

	void markReferenced() {
	    if( c != null ) {
		c.markReferenced();
	    }
	}

        set Type SubType = new_sub_type {
            if( sub_type != null ) {
                throw new Exception( "oops: setSubType() this type already has a sub-type" );
            }

            this.sub_type = new_sub_type;
        }

        Container findMethod( String name, Vector<Type> arguments, bool exact ) {
            if( c != null ) {
                return c.findMethod( name, arguments, exact );
            } else if( TypeKind == ERROR ) {
		return null;
	    } else {
                throw new Exception( "oops: cannot look for method " + name + " in non class type" );
            }
        }

        Container findBestMethod( String name, Vector<Type> arguments, Quality quality ) {
            if( c != null ) {
                return c.findBestMethod( name, arguments, quality );
            } else if( TypeKind == ERROR ) {
		return null;
            } else {
                throw new Exception( "oops: cannot look for method " + name + " in non class type" );
            }
        }

        Symbol findSymbol( String name, int find_what ) {
            if( c != null ) {
                return c.findSymbol( name, find_what );
            } else {
                return null;
            }
        }

        get Container Clazz {
            if( c == null ) {
                throw new Exception( "oops: cannot return class for type without one: " + this );
            }
            return c;
        }

	get Container ClazzOrNull {
	    return c;
	}

        void dump( StringBuffer human, StringBuffer decorate ) {
	    if( this == null ) {
		IO.Std.err.println( "null type: " + new System.Backtrace() );
		human.append( "NULL TYPE" );
		return;
	    }

            dumpHuman( human );
            dumpDecorate( decorate );
        }

	void addCForwardStructs(Generic.Set<String> c_forward_structs) {
	    if (type_kind == Type.CLASS || type_kind == Type.STRUCT) {
		c_forward_structs.add(
				      c.QualifiedName.replace('.', '_')
				      );
	    } else if(
		      type_kind == Type.VECTOR ||
		      type_kind == Type.REFERENCE ||
		      type_kind == Type.POINTER ||
		      type_kind == Type.PROC) {
		sub_type.addCForwardStructs(c_forward_structs);
	    }
	}

	get String CType {
	    // IO.Std.err.println( "dumping type to: " + human );
            switch ( type_kind ) {
            case Type.NONE:
		return "void";
                
            case Type.VOID:
		return "void";

            case Type.BOOL:
		return "int";

            case Type.BYTE:
		return "char";

            case Type.CHAR:
		return "char";

	    case Type.ENUM, Type.INTEGER:
		return "int";

	    case Type.WORD:
		return "long";

	    case Type.LONG:
		return "long";

            case Type.VECTOR:
		return sub_type.CType + " *";

            case Type.REFERENCE:
		return sub_type.CType + " *";

            case Type.POINTER:
		return sub_type.CType + " *";

	    case Type.PROC:
		return sub_type.CType + "(*)()";

            case Type.CLASS,Type.STRUCT:
		return "struct " + c.QualifiedName.replace('.', '_') + " *";

            case Type.STRING:
		return "System_String *";

	    case Type.INFER:
		return "undefined";

            case Type.ERROR:
                return "undefined";

            default:
		return "<unknown: " + TypeKind + ">";
            }	
	}

	get String CTypeNoClass {
	    // IO.Std.err.println( "dumping type to: " + human );
            switch ( type_kind ) {
            case Type.NONE:
		return "void";
                
            case Type.VOID:
		return "void";

            case Type.BOOL:
		return "int";

            case Type.BYTE:
		return "char";

            case Type.CHAR:
		return "char";

	    case Type.ENUM, Type.INTEGER:
		return "int";

	    case Type.WORD:
		return "long";

	    case Type.LONG:
		return "long";

            case Type.VECTOR:
		return sub_type.CType + " *";

            case Type.REFERENCE:
		return sub_type.CType + " *";

            case Type.POINTER:
		return sub_type.CType + " *";

	    case Type.PROC:
		return sub_type.CType + "(*)()";

            case Type.CLASS, Type.STRUCT:
		return "void *";

            case Type.STRING:
		return "System_String *";

	    case Type.INFER:
		return "undefined";

            case Type.ERROR:
                return "undefined";

            default:
		return "<unknown: " + TypeKind + ">";
            }	
	}

	void dumpHuman( StringBuffer human ) {
	    // IO.Std.err.println( "dumping type to: " + human );
            switch ( type_kind ) {
            case Type.NONE:
                human.append( "null value" );
                
            case Type.VOID:
                human.append( "void" );

            case Type.BOOL:
                human.append( "bool" );

            case Type.BYTE:
                human.append( "byte" );

            case Type.CHAR:
                human.append( "char" );

            case Type.INTEGER:
                human.append( "int" );

	    case Type.WORD:
		human.append( "word" );

	    case Type.LONG:
		human.append( "long" );

            case Type.VECTOR:
                sub_type.dumpHuman( human );
		human.append( "[]" );

            case Type.REFERENCE:
                sub_type.dumpHuman( human );
		human.append( " ref" );

            case Type.POINTER:
                sub_type.dumpHuman( human );
		human.append( " ptr" );

            case Type.CLASS,Type.STRUCT,Type.ENUM,Type.PROC:
		human.append( c.HumanName );

            case Type.STRING:
                human.append( "string" );

	    case Type.INFER:
		human.append( "undefined" );

            case Type.ERROR:
                human.append( "undefined" );

            default:
                human.append( "<unknown: " + TypeKind + ">" );

            }
        }

        void dumpDecorate( StringBuffer decorate ) {
            switch ( type_kind ) {
            case Type.NONE:
                decorate.append( 'v' );
                
            case Type.VOID:
                decorate.append( 'v' );

            case Type.BOOL:
                decorate.append( 'b' );
                
            case Type.BYTE:
                decorate.append( 'c' );
                
            case Type.CHAR:
                decorate.append( 'c' );
                
            case Type.INTEGER:
                decorate.append( 'i' );

	    case Type.LONG:
		decorate.append( 'l' );

	    case Type.WORD:
		decorate.append( "u4word" );

		/*
		if( Gen.Machine.WORD == 8 ) {
		    decorate.append( 'l' );
		} else if( Gen.Machine.WORD == 4 ) {
		    decorate.append( 'i' );
		} else {
		    throw new Exception( "unexpected word length: " + Gen.Machine.WORD );
		}
		*/
		   
                
            case Type.VECTOR:
                decorate.append( "A_" );
                sub_type.dumpDecorate( decorate );
                
            case Type.REFERENCE:
                decorate.append( 'R' );
                sub_type.dumpDecorate( decorate );
                
            case Type.POINTER:
                decorate.append( 'P' );
                sub_type.dumpDecorate( decorate );

            case Type.CLASS,Type.ENUM:
                String n = c.DecoratedName;
                decorate.append( n );

            case Type.STRING:
                decorate.append( "Pc" );

	    case Type.PROC:		
                decorate.append( 'P' );
		decorate.append( c.DecoratedName );

            default:
                decorate.append( 'v' );
            }
        }

        String dump() {
            StringBuffer result = new StringBuffer();
            dumpHuman( result );
            return result;
        }


        get int Size {

            switch( TypeKind ) {
            case Type.VOID:
		IO.Std.err.println( "returning size 0 for type: " + this + " of kind " + cast<int>(TypeKind) + " from: " + new System.Backtrace() );
                return 0;

            case Type.BOOL,Type.BYTE,Type.CHAR:
                return 1;

            case Type.INTEGER,Type.ENUM,Type.ERROR:
                return 4;

	    case Type.LONG:
		return 8;

	    case Type.NONE,Type.NULL,Type.WORD,Type.VECTOR,Type.REFERENCE,Type.POINTER,Type.CLASS,Type.PROC:
		IO.Std.err.println( "type size for type of unknown size called from: " + new System.Backtrace() );
		return 8;		

            default:
                throw new Exception( "oops: unknown type-kind " + cast<int>(getTypeKind()) + " in Type.getSize() on: " + this );
            }
        }

        get SymbolList Scope {
            if( TypeKind == Type.CLASS ) {
                if( c == null ) {
                    throw new Exception( "strange: class is null" );
                }
                return c.getScope();
            } else {
                return null;
            }
        }

	int matchScore( Type u, bool assign ) {
	    int s;
	    int result = matchScore2( u, assign );
	    if( /* !assign || */ result == MATCH_EXACT ) {
		return result;
	    }

	    var state = CompileState.Instance;
	    int tk = TypeKind;
	    int uk = u.TypeKind;
	    if( (tk != VECTOR && tk != PROC && tk != CLASS) ||
		(uk != VECTOR && uk != PROC && uk != CLASS) ) {
		return result;
	    }

	    Type t = u.getBoxType( state );
	    if( t != null ) {
		s = matchScore2( t, assign ) - 1;
		if( s > result ) { 
		    // IO.Std.err.println( "" + this + " vs " + t + "/" + u + " from: " + new System.Backtrace() );
		    result = s;
		}
	    }

	    t = this.getBoxType( state );
	    if( t != null ) {
		s = t.matchScore2( u, assign ) - 1;
		if( s > result ) {
		    // IO.Std.err.println( "" + this + "/" + t + " vs " + u + " from: " + new System.Backtrace() );
		    result = s;
		}
	    }

	    return result;
	}

        int matchScore2( Type u, bool assign ) {
	    // IO.Std.err.println( "match score 2: " + this + " versus " + u );
            if( u.type_kind == Type.ERROR ) {
		// IO.Std.err.println( "null match" );
                return MATCH_NULL;
            } else if( u.type_kind == Type.NONE ) {
		// IO.Std.err.println( "none match" );
                Type t;
                if( type_kind == Type.VECTOR || type_kind == Type.POINTER ) {
		    return MATCH_NULL;
		} else if( type_kind == Type.REFERENCE ) {    
                    return SubType.matchScore( u, assign );
                } else if( type_kind == Type.CLASS ) {
                    return MATCH_NULL - Clazz.Depth;
                } else if( assign ) {
		    return MATCH_NULL;
		} else {
                    return MATCH_NONE;
                }
                // IO.Std.err.println( "null match 2" );
            } else if( TypeKind != u.TypeKind ) {
                // IO.Std.err.println( "no match: 0" );
                return MATCH_NONE;
            } else if( equals( u ) ) {
                // IO.Std.err.println( "equal match: 100" );
                return MATCH_EXACT;
            } else if( TypeKind == Type.CLASS || TypeKind == Type.PROC ) {
                Container this_class = Clazz;
                Container that_class = u.Clazz;
		// IO.Std.err.println( "is assignable from: " + this_class.HumanName + " vs " + that_class.HumanName );
                if( this_class.isAssignableFrom( that_class ) ) {
                    int this_depth = this_class.Depth;
                    int that_depth = that_class.Depth;
                    
                    
                    return MATCH_EXACT - (that_depth - this_depth);
                } else {
                    // IO.Std.err.println( "not assignable: 0\n" );
                    return MATCH_NONE;
                }
            } else if( TypeKind == Type.VECTOR || TypeKind == Type.POINTER || TypeKind == Type.REFERENCE ) {
		// IO.Std.err.println( "comparing sub-types..." );
                int result = SubType.matchScore( u.SubType, assign );
		if( TypeKind == Type.VECTOR && result != MATCH_EXACT && result != MATCH_NONE ) {
		    // non-exact match between T[] and U[] array types is currently unsafe even if
		    // T is assignable from U because corresponding Generic.Array<T> expansion may
		    // static call methods defined in T and overridden in U (e.g. operator =~, operator <)
		    // nothing in compiler depends on this working so removing support for it here:
		    return MATCH_NONE;
		}
                return result;
            } else {
		// IO.Std.err.println( "weird comparison: " + dump() + " versus " + u.dump() );
                return null;
            }
        }

	/*
        bool isAssignableFrom( Type u ) {
	    if( type_kind == Type.NONE ) {
		return false;
	    }
	    // IO.Std.err.println( "is " + this + " assignable-from " + u );
            return matchScore( u, true ) > 0;
        }
	*/


        bool isAssignableFrom( Type u ) {
	    // IO.Std.err.println( "is " + this + " assignable-from " + u );
	    if( type_kind == Type.NONE ) {
		return false;
	    }

            return matchScore( u, true ) > 0;
        }

        bool equals( Type u ) {
	    //IO.Std.err.println( "" + this + " equals " + u + "?" );

            if( u == null ) {
                throw new Exception( "oops: cannot compare type to null type" );
            }

	    // IO.Std.err.println( "" + this + " equals " + u + "?" );
            
            if( this == u ) {
		// IO.Std.err.println( "yes: identical reference" );
                return true;
            }

            if( type_kind == Type.NONE || u.type_kind == Type.NONE || type_kind == Type.ERROR || u.type_kind == Type.ERROR ) {    
		// IO.Std.err.println( "yes: error or no type" );
                return true;
            }
            
            if( type_kind != u.type_kind ) {
		// IO.Std.err.println( "no: different type kinds (" + type_kind + " versus " + u.type_kind + ")" );
                return false;
            }

	    // IO.Std.err.println( "type kinds the same. simple type?" );
            
            if( type_kind <= Type.SIMPLE ) {
		// IO.Std.err.println( "yes: simple type" );
                return true;
            } else if( type_kind == Type.CLASS || type_kind == Type.STRUCT || type_kind == Type.PROC || type_kind == Type.ENUM ) {
		// IO.Std.err.println( "identical class: " + (c == u.c) );
                return c == u.c;
            } else {
		// IO.Std.err.println( "this tk: " + type_kind + ", that tk: " + u.type_kind );
		// IO.Std.err.println( "identical sub-types?" );
                if( sub_type == null ) {
                    throw new Exception( "oops: cannot compare null sub-types: " + this + " versus " + u );
                }
                return sub_type.equals( u.sub_type );
            }
        }

        String toString() {
            StringBuffer buffer = new StringBuffer();
            dumpHuman( buffer );
            return buffer;
        }
    }
}


