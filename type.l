// Copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import vector;
import container;

namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    class Type extends Object {
        private Container c;
        private Type sub_type;
        private int type_kind;

        public const int
            MATCH_NONE = 0,
            MATCH_NULL = 100,
            MATCH_EXACT = 1000;

        public const int
            NONE = 0,
            VOID = 1,
            BOOL = 2,
            BYTE = 3,
            CHAR = 4,
            SHORT = 5,
            INTEGER = 6,
	    WORD = 7,
            LONG = 8,
            FLOAT = 9,
            DOUBLE = 10,
            SIMPLE = DOUBLE,
            VECTOR = 11,
            REFERENCE = 12,
            POINTER = 13,
            CLASS = 14,
            ENUM = 15,
            NAMESPACE = 16,
            STRING = 17,
            CSTRING = 18,
            SUPER = 19,
            NULL = 20,
            STRUCT = 21,
	    INFER = 22,
            ERROR = 22;

        public const int 
            QUALITY_EXACT = 5,
            QUALITY_GOOD = 4,
            QUALITY_AMBIG = 3,
            QUALITY_BETTER_IN_OUTER_SCOPE = 2,
            QUALITY_NO_MATCH = 0;


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

        bool isScalar() {
            return type_kind == Type.LONG || type_kind == Type.WORD || type_kind == Type.INTEGER || type_kind == Type.CHAR;
        }

	static bool isInteger(int type_kind) {
            return type_kind == Type.LONG || type_kind == Type.WORD || type_kind == Type.INTEGER;
	}

	bool isObject() {
	    if( type_kind != Type.CLASS ) {
		return false;
	    }
	    return c.IsObject;
	}

        bool isInteger() {
	    return isInteger(type_kind);
        }

        get Type SubType {
            if( sub_type == null ) {
                throw new Exception( "oops: getSubType() but sub_type is null" );
            }
            return sub_type;
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
            } else {
                throw new Exception( "oops: cannot look for method " + name + " in non class type" );
            }
        }

        Container findBestMethod( String name, Vector<Type> arguments, Quality quality ) {
            if( c != null ) {
                return c.findBestMethod( name, arguments, quality );
            } else {
                throw new Exception( "oops: cannot look for method " + name + " in non class type" );
            }
        }

        Symbol findSymbol( String name, bool types_only ) {
            if( c != null ) {
                return c.findSymbol( name, types_only );
            } else {
                return null;
            }
        }

        get Container Clazz {
            if( c == null ) {
                throw new Exception( "oops: cannot return class for type without one" );
            }
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

	String dumpTemplate() {
	    StringBuffer b = new StringBuffer();

	    dumpHuman(b, true);

	    return b;
	}

	void dumpHuman( StringBuffer human ) {
	    dumpHuman( human, false );
	}

        void dumpHuman( StringBuffer human, bool template ) {
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
                sub_type.dumpHuman( human, template );
                human.append( "[]" );

            case Type.REFERENCE:
                sub_type.dumpHuman( human, template );
                human.append( " ref" );

            case Type.POINTER:
                sub_type.dumpHuman( human, template );
                human.append( " ptr" );

            case Type.CLASS,Type.STRUCT,Type.ENUM:
		// IO.Std.err.println( "dumping class, get qualified name..." );
		if( template ) {
		    human.append( c.QualifiedName );
		} else {
		    human.append( c.HumanName );
		}

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
		decorate.append( 'l' );

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
                decorate.append( 'P' );
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

	    case Type.NONE,Type.NULL,Type.WORD,Type.LONG,Type.VECTOR,Type.REFERENCE,Type.POINTER,Type.CLASS:
		return Gen.Machine.WORD;

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
            if( u.type_kind == Type.ERROR ) {
		// IO.Std.err.println( "null match" );
                return MATCH_NULL;
            } else if( u.type_kind == Type.NONE ) {
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
            } else if( TypeKind == Type.CLASS ) {
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
                return result;
            } else {
		IO.Std.err.println( "weird comparison: " + dump() + " versus " + u.dump() );
                return null;
            }
        }

        bool isAssignableFrom( Type u ) {
	    if( type_kind == Type.NONE ) {
		return false;
	    }
	    // IO.Std.err.println( "is " + this + " assignable-from " + u );
            return matchScore( u, true ) > 0;
        }

        bool equals( Type u ) {
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
            } else if( type_kind == Type.CLASS ) {
		// IO.Std.err.println( "identical class: " + (c == u.c) );
                return c == u.c;
            } else {
		// IO.Std.err.println( "identical sub-types?" );
                if( sub_type == null ) {
                    throw new Exception( "oops: cannot compare null sub-types" );
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


