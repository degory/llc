// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import stream;
import container;
import type;

namespace Parse {
    class Quality extends System.Object {
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
	    if( quality == b.quality ) {
		return b.score - score;
	    } else {
		return b.quality - quality;
	    }
	}
    }

    class Symbol extends System.Object {
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
            MASK = 0xF0F,
            KIND_MASK = 0xF00,
            CLASS = 0x100,
            NAMESPACE = 0x200,
            CONST = 0x300,
            ENUM = 0x400,
	    TYPE = 0x500,
            ATTRIBUTE = 0x600,
            ATTRIBUTE_LENGTH = 0x700,
            ATTRIBUTE_ARRAY = 0x800,
            ATTRIBUTE_STRUCT = 0x900,
	    ATTRIBUTE_ADDRESS = 0xA00,
	    ATTRIBUTE_SIZE = 0xB00,
	    ATTRIBUTE_TYPE = 0xC00,
	    ATTRIBUTE_BOX = 0xD00,
	    ATTRIBUTE_PASS = 0xE00,
	    ATTRIBUTE_NONE = 0xF00;

        Container owner;
        bool is_address_valid;
	bool is_value_valid;
        bool is_referenced;
        int kind;
        int access;
        int address;
        int defined;
        System.String name;
        Type type;

        
        bool isParentOf( Container c ) {
            return false;
        }
        
        bool getIsStatic() {
            return kind == Symbol.CLASS || (kind & Symbol.FLAG_STATIC) != 0;
        }
        
        bool getIsInstance() {
            return (kind & Symbol.FLAG_CLASS) != 0 && (kind & Symbol.FLAG_STATIC) == 0;
        }

	bool getIsType() {
	    return kind == Symbol.CLASS || kind == Symbol.NAMESPACE || kind == Symbol.ENUM || kind == Symbol.TYPE;
	}
        
        bool getIsLocal() {
            return (access & Symbol.ACCESS_LOCAL) != 0;
        }
        
        bool getIsPrivate() {
            return (access & Symbol.ACCESS_PRIVATE) != 0;
        }
        
        bool getIsPublic() {
            return (access & Symbol.ACCESS_PUBLIC) != 0;
        }
        
        bool getIsProtected() {
            return (access & Symbol.ACCESS_PROTECTED) != 0;
        }

	bool getIsAccessor() {
	    return kind & FLAG_ACCESSOR != 0;
	}
        
        bool getIsFinal() {
            return true;
        }

	bool getIsInline() {
	    return false;
	}

	bool getIsMethod() {
	    return kind & FLAG_METHOD != 0;
	}

	bool getIsNative() {
	    return false;
	}

	bool getNeedsBody() {
	    return false;
	}

	bool getIsValueValid() {
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
        
        int getAccess() {
            return access;
        }

        void setAccess( int a ) {
            access = a;
        }
        
        void setDefined(int level) {
            defined = level;
	    // IO.Std.err.println( "set defined " + name + ": " + defined );
        }
        
        int getDefined() {
	    // IO.Std.err.println( "get defined " + name + ": " + defined );
            return defined;
        }

       
        Container getOverride() {
            return null;
        }

        void init( Container owner, System.String name, int kind, int access, Type type ) {
            super.init();
            this.owner = owner;
            this.name = name;
            this.kind = kind;
            this.access = access;
            this.type = type;
            is_address_valid = false;
            is_referenced = false;
            
            if( name == null ) {
                throw new System.Exception( "oops: symbol has null name\n" );
                name = "#unknown#";
            }
        }

        System.String getName() {
            return name;
        }

        void setOwner( Container owner ) {
            this.owner = owner;
        }

        void setType( Type type ) {
            this.type = type;
        }

        Type getType() {
            return type;
        }

        Container getOwner() {
            return owner;
        }

        void setOverride( Container s ) {
            throw new System.Exception( "overriding non-container: " + this + " with: " + s );
        }

        System.String getDecoratedName() {
            return getName();
        }

        System.String getQualifiedName() {
            return getName();
        }

	System.String getHumanName() {
	    return Name;
	}

	System.String getOwnerHumanName() {
	    if( owner == null ) {
		return "global";
	    } else {
		return Owner.HumanName;
	    }
	}
		

        Parse.SymbolList getScope() {
            if( type != null && type.getTypeKind() == Type.CLASS ) {
                return type.getScope();
            } else {
                return null;
            }
        }

        int getKind() {
            return kind;
        }

        int getSize() {
            throw new System.Exception( "oops: getSize() called for non class: " + getName() );
            return 0;
        }

        bool getIsAddressValid() {
            return is_address_valid;
        }

        void setAddress( int address ) {
            if( is_address_valid ) {
                throw new System.Exception( "overwriting valid address for symbol: " + getName() + " from " + this.address + " to " + address );
            }
            this.address = address;
            is_address_valid = true;
        }

	void clearAddressValid() {
	    is_address_valid = false;
	}

        int getAddress() {
            if( !is_address_valid ) {
                throw new System.Exception( "taking address of symbol: " + getName() + ": address is not valid" );
            }
            return address;
        }

	int getHash() {
	    return getAddress();
	}

        Symbol findSymbol( System.String name, bool want_type ) {
            throw new System.Exception( "oops: looking for symbol " + name + " in non-container symbol " + getQualifiedName() );
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
		throw new System.Exception( "unexpected symbol table search type " + find_what );
	    }
	}

        void setDecoratedName( System.String name ) {
            throw new System.Exception( "oops: shouldn't be trying to set decorated name for non method symbol: " + getName() );
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
                o = getOwner();
                if( o == null ) {
                    throw new System.Exception( "weird: private " + o.getQualifiedName() + " has no owner\n" );
                    return false;
                }
                
                // access to private symbols from a method is equivilent to accessing from owning class
                if( from.getKind() & Symbol.FLAG_METHOD != null ) {
                    from = from.getOwner();
                }
                
                owner_kind = o.getKind();
                if( owner_kind == Symbol.NAMESPACE ) {
                    // object owned by a namespace
                    // if context accessed from is same namespace
                    if( from.getKind() == Symbol.CLASS ) {
                        // if context is a class, equivilent here to accessing from that class's enclosing namespace
                        from = from.getOwner();
                    }
                    return from == o; // namespaces must match
                } else if( owner_kind == Symbol.CLASS ) {
                    // context must be same class
                    return from == o;
                }
                throw new System.Exception( "unexpected owner: " + o.getQualifiedName() );
                return false;
            } else if( access & Symbol.ACCESS_PROTECTED != 0 ) {
                if( from == null ) {
                    return false;
                }
                
                o = getOwner();
                if( o == null ) {
                    throw new System.Exception( "weird: private symbol " + o.getQualifiedName() + " has no owner" );
                    return false;
                }
                
                // access to protected symbols from a method is equivilent to accessing from owning class
                if( (from.getKind() & Symbol.FLAG_METHOD) != 0 ) {
                    from = from.getOwner();
                }
                
                owner_kind = o.getKind();
                if( owner_kind == Symbol.NAMESPACE ) {
                    // symbol is owned by a namespace. can be accessed from this namespace or from namespaces nested within it.
                    
                    if( from.getKind() == Symbol.CLASS ) {
                        // access context is within a class, equivilent to accessing from that classes enclosing namespace
                        from = from.getOwner();
                    }
                    
                    // see if the accessing context's or any enclosing namespace matches this object's owning namespace
                    while( from != null ) {
                        if( from == o ) {
                            // accessed from this namespace..
                            return true;
                        }
                        // or it's owners...
                        from = from.getOwner();
                    }
                    return false;
                } else if( owner_kind == Symbol.CLASS ) {
                    return o.isParentOf( from );
                }
                throw new System.Exception( "unexpected owner: " + o.getQualifiedName() );
            } else {
                throw new System.Exception( "oops: symbol " + getName() + " has no access from any context" );
                return false;
            }
        }

	System.String toString() {
	    System.StringBuffer b = new System.StringBuffer("Symbol(");
	    b.append( this.QualifiedName );
	    
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


    class SymbolList extends System.Object {
	const int MAX_LEN = 31;
        SymbolList parent;
	Generic.Vector<Symbol> list;
        Generic.Vector<Symbol>[] by_length; // one list per possible length of symbol upto maximum length, longer lengths stored in last bucket

        void init() {
            super.init();
	    list = new Generic.Vector<Symbol>();
            by_length = new Generic.Vector<Symbol>[MAX_LEN+1];
        }

        void dump() {
            IO.Std.err.println( "symbol list: " );
	    foreach( Symbol s; list.elements() ) {
		IO.Std.err.println( s.getName() + "/" + s.getQualifiedName() );
	    }
        }

        void stripDefined( int level ) {
	    foreach( Symbol s; list.elements() ) {
		if( s.Defined == level ) {
		    s.Defined = 0;
		}
	    }
        }
        
        void add( Symbol symbol ) {
	    System.String s = symbol.Name;
	    int l = s.Length;
	    if( l > MAX_LEN ) {
		l = MAX_LEN;
	    }

	    if( by_length[l] == null ) {
		by_length[l] = new Generic.Vector<Symbol>();
	    }
    
            by_length[l].add( symbol );
	    list.add( symbol );
	    // IO.Std.err.println( "list now: " + list );
        }

        void addAll( SymbolList l ) {
	    IO.Std.err.println( "fixme: SymbolList.addAll may be broken" );
	    foreach( Symbol s; l.list.elements() ) {
		if( s == null ) {
		    throw new System.Exception( "adding null symbol\n" );
		}
		add( s );
	    }
        }

	/*
        void useAll( SymbolList l ) {
            foreach( Symbol s; list.elements() ) {
                if( s == null ) {
                    throw new System.Exception( "adding null symbol\n" );
                }
            }
            IO.Std.err.print( "used all. list now: " );
            dump();
        }
	*/

	Symbol find( System.String name, int find_what ) {
	    return find(name, find_what, false);
	}

        Symbol find( System.String name, int find_what, bool use_list ) {
            if( name == null ) {
                throw new System.Exception( "oops: can't lookup null name in symbol list" );
            }

	    Generic.Vector<Symbol> v;
	    if( use_list ) {
		v = list;
	    } else {
		int l = name.Length;
		if( l > MAX_LEN ) {
		    l = MAX_LEN;
		}
		v = by_length[l];
	    }

	    if( v != null ) {
		// IO.Std.err.println( "search symbol '" + name + "' in length " + l + " bucket..." );

		foreach( Symbol s; v.elements() ) {
		    if( s == null ) {
			throw new System.Exception( "null symbol in list\n" );
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
	    } else {
		// IO.Std.err.println( "symbol '" + name + "': no length " + l + " bucket" );
	    }
            
            return null;
        }

        Symbol findDecorated( System.String name ) {
            if( name == null ) {
                throw new System.Exception( "oops: can't lookup null name in symbol list" );
            }

	    foreach( Symbol s; list.elements() ) {
		if( s.Kind & Symbol.FLAG_METHOD != 0 && name.equals( s.DecoratedName ) ) {
		    return s;
		}
	    }
            
            return null;
        }
        
        Symbol findQualified( System.String name ) {
            if( name == null ) {
                throw new System.Exception( "oops: can't lookup null name in symbol list" );
                return null;
            }

	    foreach( Symbol s; list.elements() ) {
		if( name.equals( s.QualifiedName ) ) {
		    return s;
		}
	    }

            return null;
        }


        Container findMethod( System.String name, Generic.Vector<Type> arguments, Quality result ) {
            if( name == null ) {
                throw new System.Exception( "oops: can't search for a null method name in symbol list" );
            }
            
            int best_score = -1;
            int best_quality = 0;
            
            Container best_match = null;

	    if( this == null ) {
		IO.Std.err.println( "can't find '" + name + "' in null symbol list" );
		throw new System.Exception( "can't find '" + name + "' in null symbol list" );
	    }

	    if( list == null ) {
		IO.Std.err.println( "can't find '" + name + "' in empty symbol list" );
		throw new System.Exception( "can't find '" + name + "' in empty symbol list" );
		return null;
	    }

	    int l = name.Length;
	    if( l > MAX_LEN ) {
		l = MAX_LEN;
	    }

	    var v = by_length[l];
            
	    if( v != null ) {
		foreach( Symbol s; v.elements() ) {
		    Quality q = new Quality();
		    if( s.Kind & Symbol.FLAG_METHOD != 0 ) {
			if( name.equals( s.Name ) ) {
			    Container class_symbol = cast<Container>(s);
			    
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
		}

		if( best_score > result.score ) {
		    result.quality = best_quality;
		    result.score = best_score;
		    return best_match;
		} 
	    }

	    return null;
        }

        Container findMethod( System.String name, Generic.Vector<Type> arguments, bool exact ) {
            if( name == null ) {
                throw new System.Exception( "oops: can't search for a null method name in symbol list" );
            }

	    int l = name.Length;
	    if( l > MAX_LEN ) {
		l = MAX_LEN;
	    }
	    var v = by_length[l];
            
	    if( v != null ) {
		foreach( Symbol s; v.elements() ) {
		    if( s.Kind & Symbol.FLAG_METHOD != 0 ) {
			if( name.equals( s.Name ) ) {                     
			    Container class_symbol = cast<Container>( s );
			    
			    if( class_symbol.matches( arguments, exact ) ) {
				return class_symbol;
			    }
			}
		    }
		}
            }
            
            return null;
        }

        void dumpActiveClasses( IO.Writer f ) {
	    foreach( Symbol s; list.elements() ) {
		bool generic = false;

		if( s.Kind == Symbol.CLASS && s.getAndClearIsReferenced() ) {
		    if( f != null ) {
			// fprintf( f, "%08X %s\n", ((Container *)symbol).getHash(), symbol.getQualifiedName() );
			f.write( "" + cast<Container>(s).Hash + " " + s.QualifiedName + "\n" );
			// } else {
			// fprintf( stderr, "cleared %s\n", symbol.getName() );
		    }
		} else if( s.Kind == Symbol.NAMESPACE ) {
		    cast<Container>(s).getScope().dumpActiveClasses( f );
		}
	    }
	}

	Symbol opGet( int index ) {
	    return cast<Symbol>(list[index]);
	}


	int getLength() {
	    return list.Length;
	}

        void setSuper( SymbolList parent ) {
            this.parent = parent;
        }
        
        Generic.Vector<Symbol> getSymbolList() {
            return list;
        }

	System.String toString() {
	    System.StringBuffer b = new System.StringBuffer("\n");
	    foreach( Symbol s; list.elements() ) {
		b.append( s );
		b.append( "\n" );
	    }
     	    return b;
	}
    }
}
