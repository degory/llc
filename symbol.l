// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import stream;
import container;
import type;

namespace Parse {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;
    use Generic.Iterator;

    use Gen.IRBlock;

    class Quality {
	public int score;
	public int quality;

	void init() {
	    super.init();
	    score = 0;
	    quality = 0;
	}

	bool opEquals( Quality b ) {
	    return quality == b.quality && score == b.score; 
	}

	int opCompare( Quality b ) {
	    // IO.Std.err.println( "compare " + this + " versus " + b + " from " + new System.Backtrace() );
	    if( quality == b.quality ) {
		return score - b.score;
	    } else {
		return quality - b.quality;
	    }
	}

	String toString() { 
	    return "quality: " + quality + ", score: " + score;
	}
    }

    class Symbol extends Object {
        public const int
            FLAG_METHOD = 1,
            FLAG_CLASS = 2,
            FLAG_STATIC = 4,
            FLAG_VARIABLE = 8,
	    FLAG_ACCESSOR = 16,
	    FLAG_LOCAL = 0x10000;

	public const int
	    FIND_ANY = 1,
	    FIND_TYPE = 2,
	    FIND_NON_TYPE = 3,
	    FIND_NON_ACCESSOR = 4;
        
        public const int
            STATIC_VARIABLE = (FLAG_STATIC | FLAG_CLASS | FLAG_VARIABLE),
            INSTANCE_VARIABLE = (FLAG_CLASS | FLAG_VARIABLE),
            LOCAL_VARIABLE = (FLAG_VARIABLE),
            STATIC_METHOD = (FLAG_STATIC | FLAG_CLASS | FLAG_METHOD),
            INSTANCE_METHOD = (FLAG_CLASS | FLAG_METHOD),
	    ACCESSOR = FLAG_ACCESSOR;
        
        public const int
            ACCESS_LOCAL = 1,
            ACCESS_PRIVATE = 2,
            ACCESS_PROTECTED = 4,
            ACCESS_PUBLIC = 8,
            ACCESS_STATIC = 16,
            ACCESS_CONST = 32,
            ACCESS_MASK = 63;

        public const int
            MASK = 0xFF0F,
            KIND_MASK = 0xFF00,
            CLASS = 0x100,
            NAMESPACE = 0x200,
            CONST = 0x300,
            ENUM = 0x400,
	    TYPE = 0x500,
	    PROC = 0x600,
            ATTRIBUTE = 0x700,
            ATTRIBUTE_LENGTH =      0x0800,
            ATTRIBUTE_ARRAY =       0x0900,
            ATTRIBUTE_STRUCT =      0x0A00,
	    ATTRIBUTE_ADDRESS =     0x0B00,
	    ATTRIBUTE_SIZE =        0x0C00,
	    ATTRIBUTE_TYPE =        0x0D00,
	    ATTRIBUTE_BOX =         0x0E00,
	    ATTRIBUTE_PASS =        0x0F00,
	    ATTRIBUTE_NONE =        0x1000,
	    ATTRIBUTE_ISOBJECT =    0x1100,
	    ATTRIBUTE_ISREFERENCE = 0x1200;

        Container owner;
        String name;
        Type type;

	LLVM.Value llvm_value;

        int kind;
        int access;
        int address;
        int defined;

        bool is_address_valid;
	bool is_value_valid;
        bool is_referenced;

        bool isParentOf( Container c ) {
            return false;
        }
        
        get bool IsStatic {
            return kind == Symbol.CLASS || (kind & Symbol.FLAG_STATIC) != 0;
        }
        
        get bool IsInstance {
            return (kind & Symbol.FLAG_CLASS) != 0 && (kind & Symbol.FLAG_STATIC) == 0;
        }

	get bool IsType {
	    return kind == Symbol.CLASS || kind == Symbol.NAMESPACE || kind == Symbol.ENUM || kind == Symbol.TYPE;
	}
        
        get bool IsLocal {
            return (access & Symbol.ACCESS_LOCAL) != 0;
        }
        
        get bool IsPrivate {
            return (access & Symbol.ACCESS_PRIVATE) != 0;
        }
        
        get bool IsPublic {
            return (access & Symbol.ACCESS_PUBLIC) != 0;
        }
        
        get bool IsProtected {
            return (access & Symbol.ACCESS_PROTECTED) != 0;
        }

	get bool IsAccessor {
	    return kind & FLAG_ACCESSOR != 0;
	}
        
        get bool IsFinal {
            return true;
        }

	get bool IsInline {
	    return false;
	}

	get bool IsMethod {
	    return kind & FLAG_METHOD != 0;
	}

	/*
	get bool IsPIC {
	    return false;
	}
	*/

	get bool IsNative {
	    return false;
	}

	get bool IsAnon {
	    return false;
	}

	get bool NeedsBody {
	    return false;
	}

	get bool IsValueValid {
	    return true;
	
	    /*    
      	    bool result = is_value_valid || !IsStatic || !ParseTree.inStaticInitializer();

	    IO.Std.err.println( "is value valid:       " + getDecoratedName() + ": " + result );
	    IO.Std.err.println( "is_value_valid:       " + is_value_valid );
	    IO.Std.err.println( "isStatic():           " + isStatic() );
	    IO.Std.err.println( "in static initalizer: " + ParseTree.inStaticInitializer() );

	    return result;
	    */
	}

	void markValueValid() {
	    is_value_valid = true;
	}
        
        void markReferenced() {
            is_referenced = true;
        }
        
        bool getAndClearIsReferenced() {
            bool result = is_referenced;
            is_referenced = false;
            return result;
        }

	set LLVM.Value LLVMValue = v {
	    llvm_value = v;
	}

        get LLVM.Value LLVMValue {
	    return llvm_value;
	}

	static String created_at;

	LLVM.Value getLocal(CompileState state, IRBlock into) {
	    if( llvm_value == null ) {
                llvm_value = into.AllocaEntry( Type.getLLVMType(state), Name );
	    }

	    return llvm_value;
	}

	LLVM.Value getStaticGlobal(CompileState state) {
	    //  IO.Std.err.println( "static decorated name would be: " + DecoratedName );

	    char ptr name = ("__static_" + Owner.DecoratedName + "_" + Name ).toCString();

	    LLVM.Value v = LLVM.Calls.LLVMGetNamedGlobal(state.Module, name);
	    if( v == null ) {
		v = LLVM.Calls.LLVMAddGlobal(state.Module,Type.getLLVMType(state), name);

		Owner.markHasStatic();

		if( Owner == state.CurrentClass ) {
		    Owner.hasStatic(v);
		    // IO.Std.err.println( "owner: " + Owner.HumanName );
		    // IO.Std.err.println( "current: " + state.CurrentClass.HumanName );
		    state.maybeLinkOnce(v);
		    // LLVM.Calls.LLVMSetLinkage(v, LLVM.LLVMLinkage.LLVMDLLExportLinkage);
		    LLVM.Calls.LLVMSetInitializer(v, Type.getLLVMNull(state));
		}
	    }
	    
	    return v;
	}

	LLVM.Value getFunctionGlobal(CompileState state) {
	    throw new System.Exception( "Symbol is not a function: " + HumanName );
	}
        
        get int Access {
            return access;
        }

        set int Access = a {
            access = a;
        }
        
        set int Defined = level {
            defined = level;
	    // IO.Std.err.println( "set defined " + name + ": " + defined );
        }
        
        get int Defined {
	    // IO.Std.err.println( "get defined " + name + ": " + defined );
            return defined;
        }
       
        get Container Override {
            return null;
        }

        void init( Container owner, String name, int kind, int access, Type type ) {
            super.init();
            this.owner = owner;
            this.name = name;
            this.kind = kind;
            this.access = access;
            this.type = type;
            is_address_valid = false;
            is_referenced = false;
            
            if( name == null ) {
                throw new Exception( "oops: symbol has null name\n" );
                name = "#unknown#";
            }
        }

        get String Name {
            return name;
        }

        set Container Owner = owner {
            this.owner = owner;
	    // throw new System.Exception( "set owner " + HumanName ); 
        }

        set Type Type = type {
            this.type = type;
        }

        get Type Type {
            return type;
        }

        get Container Owner {
            return owner;
        }

        set Container Override = s {
            throw new Exception( "overriding non-container: " + this + " with: " + s );
        }

        get String DecoratedName {
            return Name;
        }

	get String HumanName {
	    return Name;
	}

	get String OwnerHumanName {
	    if( owner == null ) {
		return "global";
	    } else {
		return Owner.HumanName;
	    }
	}
		

        get Parse.SymbolList Scope {
            if( type != null && type.TypeKind == Type.CLASS ) {
                return type.Scope;
            } else {
                return null;
            }
        }

        get int Kind {
            return kind;
        }

        get int Size {
            throw new Exception( "oops: getSize() called for non class: " + Name );
            return 0;
        }

        get bool IsAddressValid {
            return is_address_valid;
        }


        set int Address = address {
            if( is_address_valid ) {
                throw new Exception( "overwriting valid address for symbol: " + getName() + " from " + this.address + " to " + address );
            }
            this.address = address;
            is_address_valid = true;
        }

	void clearAddressValid() {
	    is_address_valid = false;
	}

        get int Address {
            if( !is_address_valid ) {
		IO.Std.err.println( "address not valid: " + HumanName + " from: " + new System.Backtrace() ); IO.Std.err.flush();
            }
            return address;
        }

	get int Hash {
	    return Address;
	}

	bool populateGEPString( Symbol s, StringBuffer b ) {
	    IO.Std.err.println( "not a container: " + HumanName );
	}

	String getGEPString( Symbol from ) {
	    if( from == null ) {
		from = Owner;
	    }
	    var b = new StringBuffer("GEP: ");
	    from.populateGEPString(this, b);

	    b.append( Address );
	    b.append( " (" + HumanName + ")"  );

	    return b;
	}

        Symbol findSymbol( String name, bool want_type ) {
            throw new Exception( "oops: looking for symbol " + name + " in non-container symbol " + getHumanName() );
            return null;
        }

	bool matchFind( int find_what ) {
	    switch( find_what ) {
	    case FIND_ANY:
		return true;

	    case FIND_TYPE:
		return IsType;

	    case FIND_NON_TYPE:
		return !IsType;

	    case FIND_NON_ACCESSOR:
		return Kind != ACCESSOR;

	    default:
		throw new Exception( "unexpected symbol table search type " + find_what );
	    }
	}

        set String DecoratedName = name {
            throw new Exception( "oops: shouldn't be trying to set decorated name for non method symbol: " + Name );
        }

        int compareAccess( Symbol c ) {
            return access - c.access;
        }

        int compareAccess( int access ) {
            return this.access - access;
        }

        bool canAccessFrom( Container from ) {
            Container o;
            int owner_kind;
            if( (access & Symbol.ACCESS_LOCAL) != 0 ) {
                // it's local - are we accessing it from the owning method?
                return from == getOwner();
            } else if( (access & Symbol.ACCESS_PUBLIC) != 0 ) {
                // it's public - always accessible 
                return true;
            } else if( (access & Symbol.ACCESS_PRIVATE) != 0 ) {
                
                // private
                // if symbol is owned by a class C then it can accessed from:
                //      that class C or
                //      methods owned by that class C
                // if symbol is owned by a namespace N then it can be accessed from:
                //      that namespace C
                //      classes owned by that namespace C
                //      methods owned by classes owned by that namespace C
    // enum members are owned by their owner's owner (class or namespace)
                if( from == null ) {
                    // global context never allowed for private accesses
                    return false;
                }
                
                // what class or namespace owns this object?
                o = Owner;
                if( o == null ) {
                    throw new Exception( "weird: private " + o.HumanName + " has no owner\n" );
                    return false;
                }
                
                // access to private symbols from a method is equivilent to accessing from owning class
                if( from.Kind & Symbol.FLAG_METHOD != null ) {
                    from = from.Owner;
                }
                
                owner_kind = o.Kind;
                if( owner_kind == Symbol.NAMESPACE ) {
                    // object owned by a namespace
                    // if context accessed from is same namespace
                    if( from.Kind == Symbol.CLASS ) {
                        // if context is a class, equivilent here to accessing from that class's enclosing namespace
                        from = from.Owner;
                    }
                    return from == o; // namespaces must match
                } else if( owner_kind == Symbol.CLASS ) {
                    // context must be same class
                    return from == o;
                }
                throw new Exception( "unexpected owner: " + o.HumanName );
                return false;
            } else if( access & Symbol.ACCESS_PROTECTED != 0 ) {
                if( from == null ) {
                    return false;
                }
                
                o = Owner;
                if( o == null ) {
                    throw new Exception( "weird: private symbol " + o.getHumanName() + " has no owner" );
                    return false;
                }
                
                // access to protected symbols from a method is equivilent to accessing from owning class
                if( (from.Kind & Symbol.FLAG_METHOD) != 0 ) {
                    from = from.Owner;
                }
                
                owner_kind = o.Kind;
                if( owner_kind == Symbol.NAMESPACE ) {
                    // symbol is owned by a namespace. can be accessed from this namespace or from namespaces nested within it.
                    
                    if( from.Kind == Symbol.CLASS ) {
                        // access context is within a class, equivilent to accessing from that classes enclosing namespace
                        from = from.Owner;
                    }
                    
                    // see if the accessing context's or any enclosing namespace matches this object's owning namespace
                    while( from != null ) {
                        if( from == o ) {
                            // accessed from this namespace..
                            return true;
                        }
                        // or it's owners...
                        from = from.Owner;
                    }
                    return false;
                } else if( owner_kind == Symbol.CLASS ) {
                    return o.isParentOf( from );
                }
                throw new Exception( "unexpected owner: " + o.HumanName );
            } else {
                throw new Exception( "oops: symbol " + Name + " has no access from any context" );
                return false;
            }
        }

	String toString() {
	    StringBuffer b = new StringBuffer("Symbol(");
	    b.append( this.HumanName );
	    
	    if( type != null ) {
		b.append( ": " );
		b.append( type );
	    }

	    b.append( ")" );

	    if( this.Owner != null ) {
		b.append( "->" );
		b.append( this.Owner );
	    }

	    return b;
	}
    }

    class SymbolSearchIterator implements Iterator<Symbol> {
        Vector<Symbol> list;
        int i;
        void init( Vector<Symbol> list, int stack_top ) {
            this.list = list;
            this.i = stack_top - 1;
        }

        bool hasMoreElements() {
            return i >= 0;
        }

        Symbol nextElement() {
            var result = list[i];
            i = i - 1;

            IO.Std.err.println( "search: " + result.HumanName );
            return result;
        }
    }

    class SymbolList extends Object {
	const int MAX_LEN = 15;
        // SymbolList parent;

        int stack_top;

	Vector<Symbol> list;
        /*
        Vector<Symbol>[] by_length; // one list per possible length of symbol upto maximum length, longer lengths stored in last bucket
        */

        void init() {
            super.init();
            stack_top = -1;
	    list = new Vector<Symbol>();
            /*
            by_length = new Vector<Symbol>[MAX_LEN+1];
            */
        }

        void dump() {
            IO.Std.err.println( "symbol list: " );
	    foreach( Symbol s; list.elements() ) {
		IO.Std.err.println( s.getName() + "/" + s.getHumanName() );
	    }
        }

        int enterBlock() {
            return list.Length;
        }

        void exitBlock(int st) {
	    list.Length = st;
        }
        
        void add( Symbol symbol ) {
	    String s = symbol.Name;
            /*
	    int l = s.Length;
	    if( l > MAX_LEN ) {
		l = MAX_LEN;
	    }

	    if( by_length[l] == null ) {
		by_length[l] = new Vector<Symbol>();
	    }
    
            by_length[l].add( symbol );
            */
	    list.add( symbol );
	    // IO.Std.err.println( "list now: " + list );
        }

        Iterator<Symbol> getSearchList() {
            // if( stack_top < 0 ) {
            // IO.Std.err.println( "will search: " + list );
                return list.elements();
                //} else {
                // return new SymbolSearchIterator( list, stack_top );
                //}
        }

        void addAll( SymbolList l ) {
	    IO.Std.err.println( "fixme: SymbolList.addAll may be broken" );
	    foreach( Symbol s; l.list.elements() ) {
		if( s == null ) {
		    throw new Exception( "adding null symbol\n" );
		}
		add( s );
	    }
        }

	/*
        void useAll( SymbolList l ) {
            foreach( Symbol s; list.elements() ) {
                if( s == null ) {
                    throw new Exception( "adding null symbol\n" );
                }
            }
            IO.Std.err.print( "used all. list now: " );
            dump();
        }
	*/

	Symbol find( String name, int find_what ) {
	    return find(name, find_what, false);
	}

        Symbol find( String name, int find_what, bool use_list ) {
            if( name == null ) {
                throw new Exception( "oops: can't lookup null name in symbol list" );
            }
            /*
	    Vector<Symbol> v;
            Iterator i;

	    if( use_list ) {
		i = getSearchList();
	    } else {
		int l = name.Length;
		if( l > MAX_LEN ) {
		    l = MAX_LEN;
		}
		v = by_length[l];
	    }

	    if( v != null ) {
 		// IO.Std.err.println( "search symbol '" + name + "' in length " + l + " bucket..." );
                */

		foreach( Symbol s; getSearchList() ) {
		    if( s == null ) {
			throw new Exception( "null symbol in list\n" );
		    }
		    int k = s.Kind;
		    if( use_list && k == Symbol.NAMESPACE ) {
			// IO.Std.err.println( "searching within used name space " + s.HumanName + " for " + name );
			Symbol t = cast Container(s).findSymbol( name, find_what );
			if( t != null && t.matchFind(find_what) ) {
			    // IO.Std.err.println( "found: " + t.HumanName );
			    return t;
			}
			// IO.Std.err.println( "nothing found" );
		    } else if( name.equals( s.Name ) ) {
			/*
			if( k == Symbol.CLASS ) {
			    s.markReferenced();
			    // fprintf( stderr, "reference: %s of kind %X versus %X\n", s.getName(), s.getKind(), Symbol.CLASS );
			}
			*/
			if( s.matchFind(find_what) ) {
			    return s;
			}
		    }

		}
                /*
	    } else {
		// IO.Std.err.println( "symbol '" + name + "': no length " + l + " bucket" );
	    }
                */
            return null;
        }

        Symbol findMethodDecorated( String name ) {
            if( name == null ) {
                throw new Exception( "oops: can't lookup null name in symbol list" );
            }

	    foreach( Symbol s; getSearchList() ) {
		if( s.Kind & Symbol.FLAG_METHOD != 0 && name.equals( s.DecoratedName ) ) {
		    return s;
		}
	    }
            
            return null;
        }
        
        Symbol findDecorated( String name ) {
            if( name == null ) {
                throw new Exception( "oops: can't lookup null name in symbol list" );
                return null;
            }

	    foreach( Symbol s; getSearchList() ) {
		if( name.equals( s.DecoratedName ) ) {
		    return s;
		}
	    }

            return null;
        }


        Container findMethod( String name, Vector<Type> arguments, Quality result ) {
            if( name == null ) {
                throw new Exception( "oops: can't search for a null method name in symbol list" );
            }
            
            int best_score = -1;
            int best_quality = 0;
            
            Container best_match = null;

	    if( this == null ) {
		IO.Std.err.println( "can't find '" + name + "' in null symbol list" );
		throw new Exception( "can't find '" + name + "' in null symbol list" );
	    }

	    if( list == null ) {
		IO.Std.err.println( "can't find '" + name + "' in empty symbol list" );
		throw new Exception( "can't find '" + name + "' in empty symbol list" );
		return null;
	    }

            /*

	    int l = name.Length;
	    if( l > MAX_LEN ) {
		l = MAX_LEN;
	    }

	    var v = by_length[l];
            
	    if( v != null ) {
            */
                foreach( Symbol s; getSearchList() ) {

		    Quality q = new Quality();
		    if( s.Kind & Symbol.FLAG_METHOD != 0 && name.equals( s.Name ) ) {
			Container class_symbol;

			class_symbol = cast<Container>(s);

			q.score = 0;
			q.quality = 0;
			if( class_symbol.matches( arguments, q ) ) {

			    if( q.score > best_score ) {
				best_score = q.score;
				best_match = class_symbol;
				best_quality = q.quality;				    
			    } else if( best_score == result.score ) {
				IO.Std.err.println( "ambiguous method protocols found looking for " + name + ": " + best_match.getDecoratedName() + " versus " + class_symbol.getDecoratedName() );
				result.quality = Type.QUALITY_AMBIG;
				return null;
			    }
			}
		    }
		}

		if( best_score > result.score ) {
		    result.quality = best_quality;
		    result.score = best_score;
		    return best_match;
		} 
                // }

	    return null;
        }

        Container findMethod( String name, Vector<Type> arguments, bool exact ) {
            if( name == null ) {
                throw new Exception( "oops: can't search for a null method name in symbol list" );
            }
            /*

	    int l = name.Length;
	    if( l > MAX_LEN ) {
		l = MAX_LEN;
	    }
	    var v = by_length[l];
            
	    if( v != null ) {
            */
		foreach( Symbol s; getSearchList() ) {
		    if( s.Kind & Symbol.FLAG_METHOD != 0 ) {
			if( name.equals( s.Name ) ) {                     
			    Container class_symbol = cast<Container>( s );
			    
			    if( class_symbol.matches( arguments, exact ) ) {
				return class_symbol;
			    }
			}
		    }
		}
                // }
            
            return null;
        }

        void dumpActiveClasses( IO.Writer f ) {
	    foreach( Symbol s; list.elements() ) {
		bool generic = false;

		if( s.Kind == Symbol.CLASS && s.getAndClearIsReferenced() ) {
		    if( f != null ) {
			f.write( "" + cast<Container>(s).Hash + " " + s.DecoratedName + "\n" );
			// } else {
			// fprintf( stderr, "cleared %s\n", symbol.getName() );
		    }
		} else if( s.Kind == Symbol.NAMESPACE ) {
		    cast<Container>(s).getScope().dumpActiveClasses( f );
		}
	    }
	}

	Symbol opGet( int index ) {
	    return list[index];
	}


	get int Length {
	    return list.Length;
	}

        /*
        void setSuper( SymbolList parent ) {
            this.parent = parent;
        }
        */        

        get Vector<Symbol> SymbolList {
            return list;
        }

	String toString() {
	    StringBuffer b = new StringBuffer("\n");
	    foreach( Symbol s; list.elements() ) {
		b.append( s );
		b.append( "\n" );
	    }
     	    return b;
	}
    }
}
