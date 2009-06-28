// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved
import symbol;
import compilestate;
import machine;
import hash;
import gset;

namespace Parse {
    use Gen.Machine;

    class Addresses extends System.Object {
        public int itable_offset;
        public int vtable_offset;
        public int hash;
        
        void init() {
            super.init();
            itable_offset = Machine.WORD;
            vtable_offset = Machine.WORD;
            hash = 0;
        }
    }

    class Container extends Symbol {
        Container parent;
	Container template;

	// Generic.Vector<Container> dependants;

        SymbolList members;

        bool needs_body;
        bool tables_valid;
	// bool is_leaf;
	bool cannot_inline;
        Container override;

	Generic.Vector<Identifier> arg_names;
	Generic.Vector<Type> arg_types;
	Util.Vector implements_list;
        int vtable_offset;
        int itable_offset;
        int stack_offset;
	int local_offset;
	int method_index;
        int hash;
        System.String decorated;
        System.String qualified;
        bool is_final;
        bool is_struct;
	bool is_generic;
	bool is_interface;
	Gen.IBlock inline_block;
	int label;
	bool is_native;
	bool already_parsed;
	Gen.MBitSet address_taken;

        void setup( Container parent ) {
	    if( this.parent != null ) {
		IO.Std.err.println( "HHHHHH: overwriting parent " + this.parent + " with " + parent + " from " + new System.Backtrace() );
	    }
            this.parent = parent;
            this.needs_body = true;
            this.override = null;
            this.tables_valid = false;
            this.stack_offset = Machine.WORD;      // FIXME: machine dependant
	    this.local_offset = -Machine.WORD;

            // this.arguments = null;
            this.hash = 0;
            this.is_final = true;
	    // this.is_leaf = true;
        }

        void init( Container parent, Container owner, System.String name ) {
           super.init( owner, name, Symbol.CLASS, 0, null );
            setup( parent );
            decorated = null;
            qualified = null;
            members = null;

            itable_offset = 0;
            vtable_offset = 0;
        }

        void init( Container parent, Container owner, System.String name, int kind, int access, Type type ) {
            super.init( owner, name, kind, access, type );
            setup( parent );

            decorated = null;
            qualified = null;
            members = null;
            
            itable_offset = 0;
            vtable_offset = 0;
            // this.arguments = arguments;
        }

        void init() {
            super.init();
            throw new System.Exception( "Container.init() called\n" );
        }

	void addImplements( Container c ) {
	    if( implements_list == null ) {
		implements_list = new Util.Vector();
	    }

	    implements_list.add( c );
	}

	get Util.Vector ImplementsList {
	    return implements_list;
	}
	
	get bool IsInterface {
	    return is_interface;
	}

	set bool IsInterface = i {
	    is_interface = i;
	}

        get bool IsObject {
	    if( is_interface ) {
		return false;
	    }

	    for( Container c = this; c != null; c = c.parent ) {
		if( c == ParseTree.ObjectClass ) {
		    return true;
		}
	    }

	    return false;
	}
	            
        bool getIsFinal() {
            return is_final;
        }

	bool getIsStatic() {
	    return Kind & Symbol.FLAG_STATIC != 0;
	}

	/*
	bool getIsLeaf() {
	    return is_leaf;
	}

	void setIsLeaf( bool l ) {
	    is_leaf = l;
	}
	*/

	bool getIsInline() {
	    return inline_block != null;
	}

	bool getIsNative() {
	    return is_native;
	}

	void setIsNative( bool n ) {
	    is_native = n;
	}

	bool getAlreadyParsed() {
	    return already_parsed;
	}

	void setAlreadyParsed( bool p ) {
	    already_parsed = p;
	}

	static int mungStackOffset( int offset ) {
	    return (offset / Machine.WORD) + 128;
	}

	void referenceSelf() {
	    markReferenced();

	    if( parent != null ) {
		parent.referenceSelf();
	    }

	    if( implements_list == null ) {
		return;
	    }

	    foreach( Container s; implements_list.elements() ) {
		s.referenceSelf();
	    }
	}

	void markAddressTaken( int offset ) {
	    int n = mungStackOffset( offset );
	    if( n < 0 ) {
		// out of range: address must be assumed taken:
		return;
	    }
	    if( address_taken == null ) {
		address_taken = new Gen.MBitSet( n * 2 );
	    } else {
		address_taken.reserve( n + 1 );
	    }	    
	    address_taken.mark( n );
	    // IO.Std.err.println( "address taken offset " + offset + " -> mark bit #" + n );
	}

	void clearAddressTaken() {
	    address_taken = null;
	}

	bool isAddressTaken( int offset ) {
	    offset = mungStackOffset( offset );
	    if( offset < 0 ) {
		return true;
	    }
	    if( address_taken == null || offset >= address_taken.Length ) {
		return false;
	    } else {
		return address_taken[offset];
	    }
	}

	Gen.MBitSet getAddressesTaken() {
	    return address_taken;
	}

	/*
	void markNotLeaf() {
	    is_leaf = false;
	}
	*/

	bool opEquals( Container c ) {
	    return this == c;
	}

	int opCompare( Container c ) {
	    return DecoratedName.opCompare( c.DecoratedName );
	}

	Container nextMethodByIndex(System.String name) {
	    // IO.Std.err.println( "MMMMMM: next method by index looking for " + name + " from " + this + " start index: " + method_index );

	    for( int i = method_index; i < members.Length; i = i + 1 ) {

		Symbol s = members[i];

		if( s.IsMethod && !s.IsNative ) {
		    if( !s.Name.equals(name) ) {
			IO.Std.err.println( "MMMMMM: oops: expected " + name + " but got " + s.Name );
			return null;
		    }

		    method_index = i + 1;
		    // IO.Std.err.println( "MMMMMM: returning method: " + s );
		    
		    /*
		    if( method_index < members.Length ) {
			IO.Std.err.println( "next method will be at index: " + method_index + " ("  + members[method_index] + ")" );
		    } else {
			IO.Std.err.println( "no next method" );
		    }
		    */

		    return cast<Container>(s);
		} else {
		    if( s.Name.equals(name) ) {
			IO.Std.err.println( "OOOOOO: oops: found this: " + s + " looking for " + name );
		    }
		}

	    }

	    return null;
	}

	void resetMethodIndex() {
	    //IO.Std.err.println( "OOOOOO: reset method index from: " + new System.Backtrace() );
	    method_index = 0;
	}

	void setLastMethodIndex() {
	    // IO.Std.err.println( "OOOOOO: set last method method index to " + members.Length + " from: " + new System.Backtrace() );
	    method_index = members.Length;
	}

	void markCannotInline() {
	    cannot_inline = true;
	}

	bool getCannotInline() {
	    return cannot_inline;
	}

        void setIsStruct( bool b ) {
            is_struct = b;
        }
        
        bool getIsStruct() {
            return is_struct;
        }

        void setIsGeneric( bool b ) {
            is_generic = b;
        }
        
        bool getIsGeneric() {
            return is_generic;
        }

	int getCurrentLabel() {
	    return label;
	}

	void setCurrentLabel( int label ) {
	    this.label = label;
	}


	void setArgNames( Generic.Vector<Identifier> arg_names ) {
	    this.arg_names = arg_names;
	}

	Generic.Vector<Identifier> getArgNames() {
	    return arg_names;
	}

	void setArgTypes( Generic.Vector<Type> arg_types ) {
	    this.arg_types = arg_types;
	}

	Generic.Vector<Type> getArgTypes() {
	    return arg_types;
	}

	Container getTemplate() {
	    return template;
	}

	void setTemplate( Container template ) {
	    this.template = template;
	}

	int getTypeArgsRequiredLength() {
	    if( is_generic && arg_names != null ) {
		// IO.Std.err.println( "" + HumanName + ": is generic: " + is_generic + ", args_length: " + type_formal_args.Length );
		return arg_names.Length;
	    } else {
		// IO.Std.err.println( "" + HumanName + ": is generic: " + is_generic );
		return 0;
	    }
	}

	bool checkTypeArgs( Generic.Vector<Type> ta ) {
	    if( arg_types.Length != ta.Length ) {
		// IO.Std.err.println( "argument lists differ in length" );
		return false;
	    }

	    for( int i = 0; i < ta.Length; i = i + 1 ) {
		Type tt = arg_types[i];
		Type to = ta[i];

		// IO.Std.err.println( "compare instance type: " + tt );
		// IO.Std.err.println( "to required type:      " + to );

		if( !tt.equals(to) ) {
		    // IO.Std.err.println( "types differ: not a matching instance" );
		    return false;
		}
	    }

	    // IO.Std.err.println( "all types match: instance matches type expression" );
	    return true;
	}

        void setDecoratedName( System.String d ) {
            this.decorated = d;
        }


        Container getSuper() {
            return parent;
        }

        int getDepth() {
            if( parent == null ) {
                return 0;
            } else {
                return parent.Depth + 1;
            }
        }

	Gen.IBlock getInlineBlock() {
	    return inline_block;
	}

	void setInlineBlock( Gen.IBlock b ) {
	    this.inline_block = b;
	}

        bool isParentOf( Container c ) {
            while( c != null ) {
                if( c == this ) {
                    return true;
                } else {
                    c = c.parent;
                }
            }
            return false;
        }

        int alloc( int kind ) {
            int result = 0;
            
            if( kind & Symbol.FLAG_METHOD != 0 || kind & Symbol.FLAG_STATIC != 0 ) {
                throw new System.Exception( "oops: cannot allocate this sort of thing in a method: K" + kind );
            } else {
		if( kind & FLAG_LOCAL != 0 ) {
		    result = local_offset;

		    if( (result / Machine.WORD) * Machine.WORD != result ) {
			throw new System.Exception( "here: " + local_offset + "," + result + ": " + this );
		    }
		    local_offset = local_offset - Machine.WORD;
		    // IO.Std.err.println( "alloc local: " + result );
		} else {
		    result = stack_offset;    
		    stack_offset = stack_offset + Machine.WORD;
		    // IO.Std.err.println( "alloc normal: " + result );
		}
            }
            return result;
        }

	void checkAlign( int initial ) {
	    if( (initial / Machine.WORD) * Machine.WORD != initial ) {
		throw new System.Exception( "here: " + initial + ": " + this );
	    }
	}

        void clearStackOffset( int initial_stack, int initial_local ) {
	    checkAlign( initial_stack );
	    checkAlign( initial_local );

            stack_offset = initial_stack;
	    local_offset = -initial_local;
        }

        Container getOverride() {
            return override;
        }

        void setOverride( Container override ) {
            this.override = override;
        }

        void setIsFinal( bool final ) {
            is_final = final;
        }

	/*
	void addDependant( Container d ) {
	    if( d == this ) {
		return;
	    }
	    if( dependants == null ) {
		dependants = new Generic.Vector<Container>();
	    }
	    IO.Std.err.println( "add dependant: " + this + " must load before " + d );
	    dependants.add(d);
	}

	Generic.Vector<Container> getDependants() {
	    return dependants;
	}
	*/

        void calcHash() {
	    int h;

            if( hash == 0 ) {
                if( getSuper() != null ) {
                    hash = getSuper().getHash();

                    hash = Util.Hash.rotate(hash);
		    // IO.Std.err.println( HumanName + ": super hash " + hash );
                } else {
                    hash = Machine.NAME.hash();
		    // IO.Std.err.println( HumanName + ": root hash " + hash );
                }

		if( implements_list != null ) {
		    foreach( Container c; implements_list.elements() ) {
			hash = Util.Hash.rotate(hash) + c.Hash;
			// IO.Std.err.println( HumanName + ": implements " + c.HumanName + " hash " + h );
		    }
		}               

                foreach( Symbol current; members.SymbolList.elements() ) {
                    int m = current.Kind; //  & Symbol.MASK;
                    if( !current.IsFinal ) {
                        m = m | 32;
                    }
                    hash = Util.Hash.rotate(hash) + m;

                    if( current.getKind() == Symbol.ENUM ) {
			hash = Util.Hash.rotate(hash) + current.Hash;
		    } else {
                        hash = Util.Hash.rotate(hash) + current.Address;
                    }
                    
                    System.String s = current.DecoratedName;
                    hash = Util.Hash.rotate(hash) + Util.Hash.hash(s);

		    // IO.Std.err.println( HumanName + ": member " + s + "@" + current.Address + " hash " + hash );
                }

                if( hash == 0 ) {
                    hash = 1;
                }
                
		// IO.Std.err.println( HumanName + ": result hash " + hash );
                // fprintf( stderr, "calculated hash %08X for %s\n", hash, getName() );
            }
        }

        int getHash() {
            if( hash == 0 ) {
                calcHash();
            } 

	    /* else {
		var h = hash;
		calcHash();

		if( hash != h ) {
		    IO.Std.err.println( "hash changed for " + HumanName + ": " + h + "->" + hash + " from " + new System.Backtrace() );
		} else {
		    IO.Std.err.println( "hash unchanged for " + HumanName + ": " + hash );
		}
   	    } */
            
            return hash;
        }

        bool getNeedsBody()  {
            return needs_body;
        }

        void setNeedsBody( bool needs_body ) {
            this.needs_body = needs_body;
        }

        void setSuper( Container parent ) {
            setup( parent );
        }
        
        int getStackOffset() {
            return stack_offset;
        }

	int getLocalOffset() {
	    return local_offset;
	}

        bool isAssignableFrom( Container c ) {
            if( c == this ) {
                return true;
            }

	    if( c.getSuper() != null && isAssignableFrom( c.getSuper() ) ) {
		return true;
            }

	    // IO.Std.err.println( "not directly assignable: " + c + ", try interfaces: " + c.implements_list );

	    if( c.implements_list != null ) {
		// IO.Std.err.println( "implements list is " + c.implements_list );
		foreach( Container d; c.implements_list.elements() ) {
		    // IO.Std.err.println( "is assignable from: " + HumanName + " vs " + d.HumanName + "..." );
		    if( isAssignableFrom( d ) ) {
			// IO.Std.err.println( "is assignable from: " + HumanName + " vs " + d.HumanName + ": interface" );
			return true;
		    }
		    // IO.Std.err.println( "is assignable from: " + HumanName + " vs " + d.HumanName + ": no" );
		}
	    }
	    return false;
        }

        bool matches( Generic.Vector<Type> arg_types, Quality result ) {
            result.quality = 0;
            result.score = -1;

	    /*
	    IO.Std.err.println( "compare: " + this.QualifiedName + "(" + this.arguments + ") versus" );
	    IO.Std.err.println( "(" + arguments + ")" );
            */

            bool this_no_args, that_no_args;
            
            this_no_args = this.arg_types == null || this.arg_types.getLength() == 0;
            that_no_args = arg_types == null || arg_types.getLength() == 0;
            
            if( this_no_args || that_no_args ) {
                if( this_no_args && that_no_args ) {
                    result.quality = Type.QUALITY_EXACT;
                    result.score = 1;
		    // IO.Std.err.println( "no args: exact match" );
                    return true;
                } else {
		    // IO.Std.err.println( "differing argument list lengths: cannot match" );
                    return false;
                }
            }
            
            if( this.arg_types.getLength() == arg_types.getLength() ) {
                result.quality = Type.QUALITY_EXACT;

                var i = this.arg_types.elements();
                var j = arg_types.elements();
                
                while( i.hasMoreElements() && j.hasMoreElements() ) {
                    Type tl = cast<Type>(i.nextElement());
                    Type tr = cast<Type>(j.nextElement());
                   
                    if( tl.getTypeKind() == Type.REFERENCE ) {
                        tl = tl.getSubType();
                    }
                    
                    // fprintf( stderr, "comparing: %s versus %s\n", tl.dump(), tr.dump() );
                    
                    int n = tl.matchScore(tr,false);

		    // IO.Std.err.println( "compare: " + tl + " to " + tr + ", score: " + n );
                    
                    if( n <= 0 ) {
			// IO.Std.err.println( "cannot match" );
                        result.quality = 0;
                        return false;
                    } else if( n <= Type.MATCH_NULL ) {
			// IO.Std.err.println( "null parameter - ambiguous match" );
                        result.quality = Type.QUALITY_AMBIG;
                    } else if( n < Type.MATCH_EXACT ) {
			// IO.Std.err.println( "inexact match" );
                        result.quality = Type.QUALITY_GOOD;
                    } else {
			// IO.Std.err.println( "exact match" );
		    }
                    
                    result.score = result.score + n;
                }
                
		// IO.Std.err.println( "match with score: " + result.score );
                return true;
            }
	    // IO.Std.err.println( "differing argument list lengths: cannot match" );
            return false;
        }
        
        bool matches( Generic.Vector<Type> arg_types, bool exact ) {
            bool this_no_args, that_no_args;
            
            this_no_args = this.arg_types == null || this.arg_types.getLength() == 0;
            that_no_args = arg_types == null || arg_types.getLength() == 0;
            
            if( this_no_args || that_no_args ) {
                return this_no_args && that_no_args;
            }
            
            if( this.arg_types.getLength() == arg_types.getLength() ) {
                var i = this.arg_types.elements();
                var j = arg_types.elements();
                
                while( i.hasMoreElements() && j.hasMoreElements() ) {
                    Type tl = cast<Type>(i.nextElement());
                    Type tr = cast<Type>(j.nextElement());
                    
                    if( !exact && tl.getTypeKind() == Type.REFERENCE ) {
                        tl = tl.getSubType();
                    }
                    
                    if( exact ) {
                        if( !tl.equals( tr ) ) {
                            return false;
                        }
                    } else {
                        if( !tl.isAssignableFrom( tr ) ) {
                            return false;
                        }
                    }
                }
                
                return true;
            }
            
            return false;
        }


        Container findBestMethod( System.String name, Generic.Vector<Type> arg_types, Quality quality ) {
            quality.score = -1;
            return findBestMethod( name, arg_types, quality, true );
        }
    
        Container findBestMethod( System.String name, Generic.Vector<Type> arg_types, Quality quality, bool recurse ) {
            Container result = null;
            
            if( members != null ) {
		// IO.Std.err.println( "about to search: " + members + " (" + System.String.hex(cast<int>(members)) + ") for: " + name );
                result = members.findMethod( name, arg_types, quality );
                if( result != null ) {
                    // fprintf( stderr, "found %s with score %d\n", result.getDecoratedName(), score );
                }
            }
            
            if( recurse && parent != null ) {
                int s = quality.score;
                Container r = parent.findBestMethod( name, arg_types, quality, true );
                if( result != null ) {
                    if( r != null && s > quality.score ) {
                        IO.Std.err.println( "found better match in parent: " + r.getDecoratedName() + " (" + s + ") versus " + result.getDecoratedName() + " (" + quality.score + ")" );
                    }
                } else {
                    result = r;
                }
            }
            
            return result;
        }
        
	Symbol getSymbolByIndex( int n ) {
	    return cast<Symbol>(members.SymbolList[n]);
	}

        Container findMethod( Container method ) {
            return findMethod( method.Name, method.ArgTypes, true );
        }

        Container findMethod( System.String name, Generic.Vector<Type> arg_types, bool exact ) {
            Container result = null;

            if( members != null ) {
                result = members.findMethod( name, arg_types, exact );
            }

            if( result == null && parent != null ) {
                result = parent.findMethod( name, arg_types, exact );
            }
            
            return result;
        }

        bool matches( Container method, bool exact ) {
            return matches( method.arg_types, exact );
        }
        
        void setSymbolList( SymbolList members ) {
            this.members = members;
        }
        
        int getSize() {
            return itable_offset;
        }

        System.String getDecoratedName() {
            if( decorated == null ) {
                IO.Std.err.println( "get decorated " + getQualifiedName() + ": null" );
                return getName();
            } else {
                return decorated;
            }
        }
        
        System.String getQualifiedName() {
            if( qualified == null ) {
		System.StringBuffer result = new System.StringBuffer();
		Symbol o = Owner; 
		if( o != null ) {
		    result.append( o.QualifiedName );
		    result.append( '.' );
		}
		result.append( Name );
		return result;
            } else {
                return qualified;
            }
        }

	System.String getHumanName() {
	    System.StringBuffer b = new System.StringBuffer();
	    System.String s = QualifiedName;
	    
	    for( int i = 0; i < s.Length; i = i + 1 ) {
		char c = s[i];

		if( c == '$' ) {
		    i = i + 1;
		    c = s[i];
		    if( c == 'L' ) {
			b.append( '<' );
		    } else if( c == 'R' ) {
			b.append( '>' );
		    } else if( c == 'C' ) {
			b.append( ',' );
		    }
		} else {
		    b.append( c );
		}
	    }

	    // IO.Std.err.println( "human name: '" + s + "' -> '" + b + "'" );
	    return b;
	}

	System.String getFileName() {
	    return QualifiedName;
	}
        
        void setQualifiedName( System.String qn ) {
            qualified = qn;
        }
        
        
        SymbolList getScope() {
            return members;
        }
        
        void stripDefined( int level ) {
            members.stripDefined( level );
        }
        
        Symbol findSymbol( System.String name, int find_what ) {
            Symbol result = null;

	    // IO.Std.err.println( "search " + HumanName + " for " + name + " (" + find_what + ")" );
            // search genuine members first
            if( members != null ) {
                result = members.find( name, find_what );
                if( result != null ) {
                    // fprintf( stderr, "found %s in %s members\n", result.getQualifiedName(), getQualifiedName() );
                    return result;
                }
            }
            
            if( getKind() == Symbol.NAMESPACE ) {
		// IO.Std.err.println( "not searching parent of namespace " + HumanName + " for " + name );
            } else if( parent != null ) {
                // not a namespace and have a parent class - search that instead#
		// IO.Std.err.println( "searching parent for: " + name + ", want types: " + want_types );
                return parent.findSymbol( name, find_what );
            }
            return null;
        }
        
        Symbol findDecoratedSymbol( System.String name )     {
            if( members == null ) {
                return null;
            }
            
            Symbol result = members.findDecorated( name );
            if( result != null ) {
                return result;
            } else if( parent != null ) {
                return parent.findDecoratedSymbol( name );
            } else {
                return null;
            }
        }
        
        void emitStaticTables( CompileState  state ) {
            foreach( Symbol current; members.getSymbolList().elements() ) {
                if( current.getKind() == Symbol.STATIC_VARIABLE ) {
                    Machine.emitDefLong( state.getOutput(), 0 );
                }
            }
        }

        void emitTypeTables( CompileState  state ) {
            if( parent != null ) {
                parent.emitTypeTables( state );
            }
        
            foreach( Symbol current; members.getSymbolList().elements() ) {
                if( current.getKind() == Symbol.INSTANCE_VARIABLE ) {
                    Type t = current.getType();
                    int value = 0;
                    if( t.getTypeKind() == Type.CLASS ) {
                        value = 1;
                    } else if( t.getTypeKind() == Type.VECTOR ) {
                        value = 2;
                    } else if( t.getTypeKind() == Type.POINTER ) {
                        value = 3;
                    }
                    Machine.emitDefByte( state.getOutput(), value );
                }
            }
        }

        void buildClassTables( CompileState state ) {
            if( !tables_valid ) {
                Addresses a = new Addresses();
		buildInterfaceTables( state, a );
                buildClassTables( state, a );
            }
        }

	void populateAllImplementedInterfaces( Generic.Vector<Container> all_implemented ) {
	    all_implemented.clear();

	    // IO.Std.err.println( "find all implemented interfaces for " + HumanName + "..." );

	    Container p = this;
	    do {
		// IO.Std.err.println( "interfaces in " + p.HumanName + "..." );

		if( p.implements_list != null ) {
		    foreach( Container ik; p.implements_list.elements() ) {
			Container q = ik;
			do {
			    if( !q.IsInterface ) {
				IO.Std.err.println( "oops: not an interface: " + p.HumanName );
				continue;
			    }

			    all_implemented.add( q );
			    // IO.Std.err.println( "implements: " + q.HumanName );
			    q = q.Super;
			} while( q != null );
		    }

		}
		 
		p = p.Super;
	    } while( p != null );
	}

	get Generic.Vector<Container> AllImplementedInterfaces {
	    var result = new Generic.Vector<Container>();

	    populateAllImplementedInterfaces( result );

	    return result;
	}

	static void buildInterfaceTables( Generic.Set<Container> interfaces_set, Generic.Vector<Symbol> symbol_list ) {
	    int j, size = interfaces_set.Length;
	    if( size == 0 ) {
		return;
	    }

	    var interfaces = new Generic.Vector<Container>(size);

	    // IO.Std.err.println( "build interface tables for " + size + " interfaces: " + interfaces_set );

	    var matrix = new Gen.MBitSet[size];


	    foreach( var js; interfaces_set.elements() ) {
		// IO.Std.err.println( "interface " + is.HumanName + " interface #" + j + " out of " + matrix.length );

		interfaces.add( js );
	    }

	    // sort interfaces list so that compile order does not affect addresses assigned by selector coloring:
	    Generic.Sort<Container,Generic.Vector<Container>>.sort(interfaces);

	    j = 0;
	    foreach( var is; interfaces.elements() ) {
		is.Address = j;
		matrix[j] = new Gen.MBitSet(size);
		j = j + 1;
	    }

	    /*
	    foreach( var js; interfaces_set.elements() ) {
		for( Container q = js.Super; q != null; q = q.Super ) {
		    matrix[q.Address].mark(js.Address);
		    matrix[js.Address].mark(q.Address);
		    IO.Std.err.println( "interface " + q.HumanName + " interferes with " + js.HumanName );
		}
	    }
	    */

	    var all_implemented = new Generic.Vector<Container>();

	    foreach( var si; symbol_list.elements() ) {
		var ci = cast Container(si);
		if( ci.implements_list == null ) {
		    continue;
		}

		all_implemented.clear();

		// IO.Std.err.println( "calculate interference for interface " + ci.HumanName + "..." );

		Container p = ci;

		ci.populateAllImplementedInterfaces( all_implemented );

	        foreach( Container ii; all_implemented.elements() ) {
		    var ai = ii.Address;
		    
		    foreach( Container ij; all_implemented.elements() ) {
			if( ii == ij ) {
			    continue;
			}
			
			// IO.Std.err.println( "interface " + ii.HumanName + " interferes with " + ij.HumanName );
			
			var aj = ij.Address;
			
			matrix[ai].mark(aj);
			matrix[aj].mark(ai);
		    }
		    ii = ii.Super;
		}
	    }

	    allocateInterfaceSlots( interfaces, matrix );
	}

	static void allocateInterfaceSlots( Generic.Vector<Container> interfaces, Gen.MBitSet[] matrix ) {
	    var slots = new Generic.Vector<Generic.Vector<Container>>();
	    foreach( var ii; interfaces.elements() ) {
		allocateInterfaceSlots( interfaces, ii, slots, matrix );
	    }
	}

	static void allocateInterfaceSlots(
	    Generic.Vector<Container> interfaces,
	    Container ii,
	    Generic.Vector<Generic.Vector<Container>> slots,
	    Gen.MBitSet[] matrix
	) {
	    int slot_index = -1;
	    var i = interfaces.elements();

	    var address = ii.Address;
	    var m = matrix[address];

	    foreach( Symbol s; ii.members.SymbolList.elements() ) {
		if( !s.IsMethod ) {
		    if( !s.IsType && !s.IsAccessor ) { 
			IO.Std.err.println( "weird: interface member '" + s.Owner.HumanName + " " + s.HumanName + "' is not a method" );
		    }
		    continue;
		}

		var c = cast Container(s);

		if( !c.IsFinal ) {
		    continue;
		}		

		bool found_free;
		do {
		    found_free = true;

		    slot_index = slot_index + 1;

		    // IO.Std.err.println( "trying slot #" + slot_index + " for " + c.HumanName + "..." );

		    if( slot_index >= slots.Length ) {
			slots.lengthen(slot_index+1);
		    }

		    if( slots[slot_index] == null ) {
			// IO.Std.err.println( "nothing yet in slot #" + slot_index );

			slots[slot_index] = new Generic.Vector<Container>();
			break;
		    }

		    foreach( var j; slots[slot_index].elements() ) {
			if( j == ii ) {
			    IO.Std.err.println( "weird slot is already occupied by " + ii.HumanName );
			    continue;
			}

			if( m[j.Address] ) {
			    // IO.Std.err.println( "cannot use slot #" + slot_index + " for " + s.HumanName + " interferes with (at least) " + j.HumanName );
			    found_free = false;
			    break;
			}
		    }
		} while( !found_free );

		slots[slot_index].add( c.Owner );

		c.clearAddressValid();
		c.IsFinal = false;

		// IO.Std.err.println( "final now: " + c.IsFinal + " for " + c.HumanName );

		c.Address = -(Machine.INTERFACE_OFFSET + Machine.WORD * slot_index);
		// IO.Std.err.println( "interface slot #" + slot_index + ": " + c.HumanName + " @ " + c.Address );

		Container o = c.Override;
		if( o != null ) {
		    o.clearAddressValid();
		    o.Address = c.Address;
		}
	    }
	}

	void buildInterfaceTables( CompileState state, Addresses address ) {
	    if( implements_list != null ) {
		foreach( Container c; implements_list.elements() ) {
		    IO.Std.err.println( "reference interface tables for: " + c );
		}
	    }
	}

        void buildClassTables( CompileState state, Addresses address ) {
            if( tables_valid ) {
                address.vtable_offset = vtable_offset;
                address.itable_offset = itable_offset;
                return;
            } else if( parent != null ) {
                parent.buildClassTables( state, address );
            }

            if( is_struct ) {
                address.itable_offset = 0;
            }

            int stable_offset = 0;
        
            if( members == null ) {
                throw new System.Exception( "weird: build class tables for class with no member list: " + getQualifiedName() );
            }
        
            foreach( Symbol current; members.getSymbolList().elements() ) { 
		int k = current.Kind;
                if( current == null ) {
                    throw new System.Exception( "oops: cannot build vtable slot for null member" );
                } else if( k & Symbol.FLAG_METHOD != 0 ) {
                    Container ancestor = null;
                    if( parent != null ) {
                        ancestor = parent.findMethod( cast<Container>(current) );
                    }
                
                    if( ancestor == null ) {
                        // not defined in parent-class - gets its own vtable offset
                    
                        if( current.IsAddressValid ) {
                            throw new System.Exception( "oops: " + current.getName() + " already has an address" );
                        }
                    
                        current.Address = address.vtable_offset;
                        address.vtable_offset = address.vtable_offset + Machine.WORD;
                    } else {
                        ancestor.IsFinal = false;
                        // fprintf( stderr, "overrides %s in %s\n", ancestor.getDecoratedName(), ancestor.getOwner().getQualifiedName() );
                        Container t = ancestor.Owner.Super;
                        while( t != null ) {
                            t = t.findMethod( ancestor );
                            if( t != null ) {
                                // fprintf( stderr, "overrides %s in %s\n", t.getDecoratedName(), t.getOwner().getQualifiedName() );
                                ancestor = t;
                                ancestor.IsFinal = false;
                                t = t.Owner.Super;
                            }
                        }
                    
                        current.Override = cast<Container>(ancestor);
                    
                        if( !ancestor.IsAddressValid ) {
                            throw new System.Exception( "oops: " + current.Name + " inherits its address but the method it overrides has no address" );
                        } else {
                            current.Address = ancestor.Address;
                        }
                    }
                } else if( k == Symbol.STATIC_VARIABLE ) {
                    if( current.IsAddressValid ) {
                        throw new System.Exception( "weird: static variable " + current.HumanName + " already has an address" );
                    }
                
                    current.Address = stable_offset;
                    stable_offset = stable_offset + Machine.WORD;
                } else if( k == Symbol.INSTANCE_VARIABLE ) {
                    if( current.IsAddressValid ) {
                        throw new System.Exception( "weird: instance variable " + current.HumanName + " already has an address" );
                    }
                
                    current.Address = address.itable_offset;
                    address.itable_offset = address.itable_offset + Machine.WORD;
                } else if( k == Symbol.CONST || k == Symbol.ENUM || k == Symbol.ACCESSOR || k == Symbol.TYPE ) {
                    ; // do nothing - occupies no space
                } else {
		    IO.Std.err.println( "weird: ignoring symbol " + current.Name + " of kind " + current.Kind );
                    // throw new System.Exception( "weird: ignoring symbol " + current.Name + " of kind " + current.Kind );
                }
            }
        
            itable_offset = address.itable_offset;
            vtable_offset = address.vtable_offset;
        
            tables_valid = true;
        }

	void emitInterfaceTables( CompileState state, ParseTree from ) {
	    if( implements_list == null ) {
		return;
	    }

	    var slots = new Generic.Vector<Container>();
	    var implemented = new Generic.Vector<Container>();
	    populateAllImplementedInterfaces( implemented );

	    Container i;

	    // IO.Std.err.println( "emit interface dispatch table for: " + HumanName + "..." );

	    foreach( Container c; implemented.elements() ) {
		// IO.Std.err.println( "find methods implementing interface: " + c.HumanName + "..." );

		foreach( Symbol s; c.members.SymbolList.elements() ) {
		    if( !s.IsMethod ) {
			if( !s.IsType && !s.IsAccessor ) { 
			    from.error( "interface member " + s.Owner.HumanName + " " + s.HumanName + " is not a method" );
			}
			continue;
		    }

		    Container e = cast Container(s);

		    // IO.Std.err.println( "looking for method: " + s.HumanName + "..." );
			
		    if( e.IsFinal ) {
			IO.Std.err.println( "weird: interface member '" + e.HumanName + "' is final" );			
		    } 
		    
		    i = findImplementedMethod(e);
		    if( i == null ) { 
			from.error( HumanName + " must implement " + e.HumanName );
			continue;
		    }
		    
		    if( i.IsStatic ) {
			from.error( "static " + i.HumanName + " cannot implement " + e.HumanName );
			continue;
		    }
		    
		    if( !e.Type.isAssignableFrom( i.Type ) ) {
			from.error(
				   "" + i.Type + " " + i.HumanName + " cannot implement "
				   + e.Type + " " + e.HumanName + " with incompatible return type" );
			continue;
		    }
		    
		    var slot = (-e.Address - Machine.INTERFACE_OFFSET) / Machine.WORD;
		    
		    slots.lengthen(slot+1);
		    
		    if( slots[slot] != null ) {
			IO.Std.err.println( "weird: already implemented: " + slots[slot].HumanName + " versus " + i.HumanName );
		    }

		    // IO.Std.err.println( "implement slot #" + slot + ": " + i.HumanName );
		    slots[slot] = i;
		}
	    }

	    foreach( Container d; slots.reverseElements() ) {
		if( d == null ) {
		    Machine.emitDefPointer( state.Output, "0" );
		} else {
		    // IO.Std.err.println( "" + d.HumanName + " @ " + d.Address );
		    /*
		    if( d.owner != this ) {
			Machine.emitExtern( state.Output,
					    d.DecoratedName );
		    }
		    */

		    Machine.emitDefPointer( state.Output, d.DecoratedName );
		}
	    }
	}

	Container findImplementedMethod( Container interface_method ) {
	    Container result = members.findMethod( interface_method.Name, interface_method.ArgTypes, true );
	    if( result != null ) {
		return result;
	    } else if( parent != null ) {
		return parent.findImplementedMethod( interface_method );
	    } else {
		return null;
	    }
	}

        void emitClassTables( CompileState state, Container for_class ) {
	    // IO.Std.err.println( "emit class tables " + for_class.HumanName );

            if( !tables_valid ) {
                IO.Std.err.println( "skipping class with invalid tables: " + HumanName );
                return;
            }

            if( parent != null ) {
                parent.emitClassTables( state, for_class );
            }
        
	    int ca = 0, sa = 0;

            foreach( Symbol current; members.SymbolList.elements() ) { 
                if( current == null ) {
                    throw new System.Exception( "oops: cannot emit vtable slot for missing member" );
                } else if( current.getKind() & Symbol.FLAG_METHOD != 0 ) {
                    Symbol candidate = for_class.findMethod( cast<Container>(current) );
                
                    if( candidate == null ) {
                        throw new System.Exception( "strange: member missing: " + current.Name );
                        Machine.emitDefPointer( state.Output, 0 );
                    } else {
                        Container owner = candidate.Owner;
                    
                        if( owner == null ) {
                            throw new System.Exception( "oops: cannot emit vtable entry for method with no owning class\n" );
                        } else {
                            Container o = candidate.Override;
                        
                            if( o != null ) {
                                o = o.Owner;
                            }
                        
                            if( o == null || o == this ) {
                                if( owner != for_class ) {
                                    Machine.emitExtern( state.Output,
                                                        candidate.DecoratedName );
                                } else {
                                    Machine.emitGlobal( state.Output,
                                                        candidate.DecoratedName );
                                }
				state.Output.println( "# ca: " + ca + ", sa: " + candidate.Address );

                                Machine.emitDefPointer( state.Output, candidate.DecoratedName );
                            }
                        }
                    }
                } else if( current.Kind == Symbol.INSTANCE_VARIABLE ) {
                
                } else if( current.Kind != Symbol.STATIC_VARIABLE && current.Kind != Symbol.CONST && current.Kind != Symbol.ENUM &&
			   current.Kind != Symbol.TYPE && current.Kind != Symbol.ACCESSOR ) {
                    throw new System.Exception( "oops: member " + current.Name + " is weird kind: " + current.Kind );
                }
		ca = ca + Machine.WORD;
            }
        }

	System.String toString() {
	    System.StringBuffer b = new System.StringBuffer("Container(");
	    b.append( this.QualifiedName );

	    if( this.Type != null ) {
		b.append( ": " );
		b.append( this.Type );
	    }

	    if( arg_names != null ) { 
		b.append( " arg names(" );
		b.append( arg_names );
		b.append (")" );
	    }

	    if( arg_types != null ) {
		b.append( " args types(" );
		b.append( arg_types );
		b.append (")" );
	    }

	    if( parent != null ) {
		b.append( " parent(" );
		b.append( parent );
		b.append( ")" );
	    }

	    b.append( ")" );

	    if( this.Owner != null ) {
		b.append( "->" );
		b.append( this.Owner );
	    }

	    return b;
	}
    }
}
