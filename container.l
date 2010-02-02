// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved
import symbol;
import compilestate;
import machine;
import hash;
import mbitset;
import gsort;
import gset;

namespace Parse {
    use Gen.Machine;
    use Gen.MBitSet;
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;

    class Addresses extends System.Object {
        public int itable_offset;
        public int vtable_offset;
	//  public int hash;
        
        void init() {
            super.init();
            itable_offset = 1;
            vtable_offset = 2; // one word for super-class pointer, one word for reference bits
        }
    }

    class Container extends Symbol {
	const int INTERFACE_OFFSET = 4;

        Container parent;
	Container template;
        SymbolList members;
        Container override;

	Vector<Identifier> arg_names;
	Vector<Type> arg_types;
	Vector<Container> implements_list;
        String decorated;
        String human;

	CompileStatus compile_status;

	LLVM.Module llvm_module;
	// LLVM.Value global;
	// LLVM.Value static_global;
	LLVM.Value this_pointer;
	// LLVM.Value return_value;

	public LLVM.Value first_static, last_static;

	word ref_bits;

        int vtable_offset;
        int itable_offset;
	int stable_offset;
        int stack_offset;
	int local_offset;
	int method_index;
	int iface_offset;
        int hash_;
	int label;

        bool is_final;
        bool is_struct;
	bool is_generic;
	bool is_interface;
	bool is_native;
	bool already_parsed;
        bool needs_body;
        bool tables_valid;
	bool cannot_inline;
	bool want_pack;
	bool has_if;
	bool has_static;

	LLVM.TypeHandle llvm_opaque_type_handle;
	LLVM.TypeHandle llvm_struct_type_handle;

        void setup( Container parent ) {
	    if( this.parent != null ) {
		IO.Std.err.println( "HHHHHH: overwriting parent " + this.parent + " with " + parent + " from " + new System.Backtrace() );
	    }
	    if( parent == this ) {
		throw new System.Exception( "class " + HumanName + " cannot be its own superclass" );
	    }
            this.parent = parent;
            this.needs_body = true;
            this.override = null;
            this.tables_valid = false;
            this.stack_offset = 1;      // FIXME: clearly not referenced
	    this.local_offset = -1;

            // this.arguments = null;
            this.hash_ = 0;
            this.is_final = true;
	    // this.is_leaf = true;
        }

        void init( Container parent, Container owner, String name ) {
	    super.init( owner, name, Symbol.CLASS, 0, null );
            setup( parent );
            decorated = null;
            human = null;
            members = null;

            itable_offset = 0;
            vtable_offset = 0;
	    iface_offset = -1; // not yet calculated

	    llvm_opaque_type_handle = LLVM.Calls.LLVMCreateTypeHandle(LLVM.Calls.LLVMOpaqueType());
        }

        void init( Container parent, Container owner, String name, int kind, int access, Type type ) {
            super.init( owner, name, kind, access, type );
            setup( parent );

            decorated = null;
            human = null;
            members = null;
            
            itable_offset = 0;
            vtable_offset = 0;
	    iface_offset = -1;
            // this.arguments = arguments;
        }

        void init() {
            super.init();
            throw new Exception( "Container.init() called\n" );
        }

	get word ReferenceBits {
	    // IO.Std.err.println( HumanName + " ref bits " + String.hex(ref_bits) );
	    return ref_bits;
	}

	void addImplements( Container c ) {
	    if( implements_list == null ) {
		implements_list = new Vector<Container>();
	    }

	    implements_list.add( c );

	    // IO.Std.err.println( "add interface " + c.HumanName + " to " + HumanName + ": " + implements_list );
	}

	get LLVM.Module LLVMModule {
	    // IO.Std.err.println( "get module for: " + HumanName );
	    if( llvm_module == null ) {
		// IO.Std.err.println( "creating new module: " + DecoratedName );
		llvm_module = LLVM.Calls.LLVMModuleCreateWithName( DecoratedName.toCString() );
	    }
	    // IO.Std.err.println( "module for " + HumanName + " is " + cast int(llvm_module) );
	    return llvm_module;
	}

	set LLVM.Module LLVMModule = m {
	    if( llvm_module != null ) {
		IO.Std.err.println( "oops: overwriting existing LLVM module" );
	    }
	    llvm_module = m;
	}

	get LLVM.Type LLVMType {
	    // IO.Std.err.println( "get LLVMType for " + HumanName );
	    
	    if( llvm_opaque_type_handle != null ) {
		// IO.Std.err.println( "opaque type handle is not null" );
		// IO.Std.err.flush();
		return LLVM.Calls.LLVMResolveTypeHandle(llvm_opaque_type_handle);
	    } else {
		// IO.Std.err.println( "opaque type handle is null" );
		// IO.Std.err.flush();
		if( llvm_struct_type_handle != null ) {
		    // IO.Std.err.println( "struct type handle is not null" );
		    // IO.Std.err.flush();
		    return LLVM.Calls.LLVMResolveTypeHandle(llvm_struct_type_handle);
		} else {
		    IO.Std.err.println( "struct type handle is null: " + HumanName );
		    // IO.Std.err.flush();
		    return null;
		}
	    }
	}

	get Vector<Container> ImplementsList {
	    return implements_list;
	}

	get bool HasIf {
	    return has_if;
	}

	set bool HasIf = i {
	    has_if = i;
	}
	
	get bool IsInterface {
	    return is_interface;
	}

	set bool IsInterface = i {
	    is_interface = i;
	}

        get bool IsObject {
	    if( is_interface || is_struct ) {
		return false;
	    }

	    return true;
	    /*

	    for( Container c = this; c != null; c = c.parent ) {
		if( c == ParseTree.ObjectClass ) {
		    return true;
		}
	    }

	    return false;
	    */
	}
	            
        get bool IsFinal {
            return is_final;
        }

	get bool IsStatic {
	    return Kind & Symbol.FLAG_STATIC != 0;
	}

	get int StaticSize {
	    return stable_offset;
	}
       
	get int VTableSize {
	    return vtable_offset;
	}

	get bool HasStatic {
	    return has_static;
	}

	void markHasStatic() {
	    has_static = true;
	}

	void hasStatic( LLVM.Value v ) {
	    if( first_static == null ) {
		first_static = v;
	    }
	    last_static = v;
	}

	LLVM.Value getFunctionGlobal(CompileState state) {
	    LLVM.Value v;
	    /*
	    LLVM.Value v = LLVMValue;
	    if( v != null ) {
		return v;
		}*/

	    // IO.Std.err.println( "get function global: " + DecoratedName + " " + HumanName + " in module " + cast int(state.Module) );

	    char ptr name = DecoratedName.toCString();

	    v = LLVM.Calls.LLVMGetNamedFunction(state.Module, name);
	    if( v == null ) {
		int l = 0;
		if( arg_types != null ) {
		    l = arg_types.Length;
		}

		var at = new Generic.Vector<LLVM.Type>(l+1);
		if( !IsStatic ) {
		    at.add(Owner.Type.getLLVMType(state));
		}

		for( int i = 0; i < l; i = i + 1 ) {
		    at.add(arg_types[i].getLLVMType(state));
		}

		var ata = at.Array;

		var ft = LLVM.Calls.LLVMFunctionType(Type.getLLVMType(state), ata.address, ata.length, 0);

		v = LLVM.Calls.LLVMAddFunction(state.Module, name, ft);
	    }
	    
	    return v;
	}

	LLVM.Value getCTableGlobal(CompileState state) {
	    LLVM.Value v;
	    /*
	    LLVM.Value v = LLVMValue;
	    if( v != null ) {
		return v;
		}*/

	    char ptr name = ("__ctable_" + DecoratedName).toCString();

	    v = LLVM.Calls.LLVMGetNamedGlobal(state.Module, name);
	    if( v == null ) {
		v = LLVM.Calls.LLVMAddGlobal(state.Module, LLVM.Calls.LLVMArrayType(LLVM.Calls.LLVMVTableFunctionType(), VTableSize + IFaceOffset + 3), name);
	    }

	    LLVMValue = v;
	    
	    return v;
	}

	void allocaLocals(CompileState state, Gen.IRBlock into) {
	    foreach( Symbol s; members.SymbolList.elements() ) {
		if( s.IsLocal ) {
		    s.LLVMValue = into.AllocaEntry( s.Type.getLLVMType(state), s.Name );
		}
	    }
	}

	LLVM.Value getLocalVariable(CompileState state) {
	    return LLVMValue;
	}

	get LLVM.Value ThisPointer {
	    return this_pointer;
	}

	set LLVM.Value ThisPointer = v {
	    this_pointer = v;
	}


	/*
        bool hasReturnValue() {
	    return return_value != null;
	}

        LLVM.Value getReturnValue( CompileState state, IRBlock into ) {
	    if( return_value == null ) {
		var t = Type.getLLVMType(state);
		return_value = into.AllocaEntry( t );
	    }

	    return return_value;
	}
	*/

	get int IFaceOffset {
	    if( iface_offset < 0 ) {
		// if iface offset not yet calculated, calculate it now:
		iface_offset = calcIFaceOffset();
	    }

	    return iface_offset;
	}

	get CompileStatus CompileStatus {
	    return compile_status;
	}

	set CompileStatus CompileStatus = s {
	    IO.Std.err.println( "compile status for class: " + HumanName + " is " + cast int(s) );
	    compile_status = s;
	}

	/*
	bool getIsLeaf() {
	    return is_leaf;
	}

	void setIsLeaf( bool l ) {
	    is_leaf = l;
	}
	*/


	get bool IsNative {
	    return is_native;
	}

	set bool IsNative = n {
	    is_native = n;
	}

	/*
        get bool AreAllOverridesEmpty {
	    if( !is_empty ) {
		// IO.Std.err.println( "call to " + HumanName + " cannot be skipped" ); 
		return false;
	    } else if( override == null ) {
		// IO.Std.err.println( "call to " + HumanName + " can be skipped" ); 
		return true;
	    } else {
		// IO.Std.err.println( "call to " + HumanName + " check override" ); 
		return override.AreAllOverridesEmpty;
	    }
	}

	get bool IsEmpty {
	    return is_empty;
	}

	set bool IsEmpty = e {
	    is_empty = e;
	}
	*/

	get bool AlreadyParsed {
	    return already_parsed;
	}

	set bool AlreadyParsed = p {
	    already_parsed = p;
	}


	int getGEPDepth( Symbol s ) {
	    /*
	    IO.Std.err.println( "GGGG: symbol: " + s );
	    IO.Std.err.println( "GGGG: owner: " + s.Owner );
	    IO.Std.err.println( "GGGG: container: " + this );
	    IO.Std.err.println( "GGGG: parent: " + parent );
	    IO.Std.err.println( "GGGG: owner: " + Owner );

	    IO.Std.err.println( "GGGG: GEP depth: " + s.HumanName + ", owner: " + s.Owner.HumanName + ", from: " + HumanName + "..." );
	    */

	    if( this == null ) {
		IO.Std.err.println( "GGGG: getGEPDepth: " + s.HumanName + " null owner from: " + new System.Backtrace() );
	    } else if( s.Owner == this ) {
		// IO.Std.err.println( "GGGG: GEP: " + HumanName + "." + s.Name );
		return 1;
	    } else if( parent == null ) {
		IO.Std.err.println( "GGGG: getGEPDepth: " + s.HumanName + " not found from: " + new System.Backtrace() );
		throw new System.NotImplementedException( "GEP not owner: " + s.HumanName );
	    } else {
		
		// IO.Std.err.println( "GGGG: GEP: strip " + HumanName );
		var result = parent.getGEPDepth(s) + 1;
		// IO.Std.err.println( "GGGG: GEP: returning " + result );
		return result;
	    }
	}

	bool populateGEPString( Symbol s, StringBuffer b ) {
	    bool result;

	    if( s.Owner == this ) {
		return true;
	    }

	    b.append( "0, " );

	    if( parent != null ) {
		return parent.populateGEPString( s, b );
	    } else {
		IO.Std.err.println( "oops: symbol parent not found: " + s.HumanName );
		return false;
	    }
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

	Container nextMethodByIndex(String name) {
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

	get Vector<Symbol> Members {
	    return members.SymbolList;
	}

	void markCannotInline() {
	    cannot_inline = true;
	}

	get bool CannotInline {
	    return cannot_inline;
	}

	set bool WantPack = p { 
	    want_pack = p;
	}

        get bool WantPack {
	    return want_pack;
	}

        set bool IsStruct = b {
            is_struct = b;
        }
        
        get bool IsStruct {
            return is_struct;
        }

        set bool IsGeneric = b {
            is_generic = b;
        }
        
        get bool IsGeneric {
            return is_generic;
        }

	get int CurrentLabel {
	    return label;
	}

	set int CurrentLabel = label {
	    this.label = label;
	}

        set Vector<Identifier> ArgNames = arg_names {
	    this.arg_names = arg_names;
	}

	get Vector<Identifier> ArgNames {
	    return arg_names;
	}

	set Vector<Type> ArgTypes = arg_types {
	    this.arg_types = arg_types;
	}

	get Vector<Type> ArgTypes {
	    return arg_types;
	}

	get Container Template {
	    return template;
	}

	set Container Template = template {
	    if( this.template == null ) {
		this.template = template;
	    } else {
		throw new Exception( "overwriting template: " + this.HumanName + " template " + this.template.HumanName + " <- " + template.HumanName );
	    }
	}

	get int TypeArgsRequiredLength {
	    if( is_generic && arg_names != null ) {
		// IO.Std.err.println( "" + HumanName + ": is generic: " + is_generic + ", args_length: " + type_formal_args.Length );
		return arg_names.Length;
	    } else {
		// IO.Std.err.println( "" + HumanName + ": is generic: " + is_generic );
		return 0;
	    }
	}

	bool checkTypeArgs( Vector<Type> ta ) {
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

        set String DecoratedName = d {
	    if( d.indexOf(' ') > 0 ) { 
		throw new System.Exception( "set borken decorated name: " + d );
	    }
            this.decorated = d;
        }

        get Container Super {
            return parent;
        }

        get int Depth {
            if( parent == null ) {
                return 0;
            } else {
                return parent.Depth + 1;
            }
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

	/*
        int alloc( int kind ) {
            int result = 0;
            
            if( kind & Symbol.FLAG_METHOD != 0 || kind & Symbol.FLAG_STATIC != 0 ) {
                throw new Exception( "oops: cannot allocate this sort of thing in a method: K" + kind );
            } else {
		if( kind & FLAG_LOCAL != 0 ) {
		    result = local_offset;

		    local_offset = local_offset + 1;
		    // IO.Std.err.println( "alloc local: " + result );
		} else {
		    result = stack_offset;    
		    stack_offset = stack_offset + Machine.WORD;
		    // IO.Std.err.println( "alloc normal: " + result );
		}
            }
            return result;
        }
	*/

	/*
	void checkAlign( int initial ) {
	    if( (initial / Machine.WORD) * Machine.WORD != initial ) {
		throw new Exception( "here: " + initial + ": " + this );
	    }
	}

	
        void clearStackOffset( int initial_stack, int initial_local ) {
	    checkAlign( initial_stack );
	    checkAlign( initial_local );

            stack_offset = initial_stack;
	    local_offset = -initial_local;
        }
	*/

        get Container Override {
            return override;
        }

        set Container Override = override {
            this.override = override;
        }

        set bool IsFinal = final {
            is_final = final;
        }

	/*
	void addDependant( Container d ) {
	    if( d == this ) {
		return;
	    }
	    if( dependants == null ) {
		dependants = new Vector<Container>();
	    }
	    IO.Std.err.println( "add dependant: " + this + " must load before " + d );
	    dependants.add(d);
	}

	Vector<Container> getDependants() {
	    return dependants;
	}
	*/

        void calcHash() {
	    int h;

            if( hash_ == 0 ) {
                if( Super != null ) {
                    hash_ = Super.Hash;

                    hash_ = Util.Hash.rotate(hash_);
		    // IO.Std.err.println( HumanName + ": super hash " + hash );
                } else {
                    hash_ = Machine.NAME.hash();
		    // IO.Std.err.println( HumanName + ": root hash " + hash );
                }

		if( implements_list != null ) {
		    foreach( Container c; implements_list.elements() ) {
			hash_ = Util.Hash.rotate(hash_) + c.Hash;
			// IO.Std.err.println( HumanName + ": implements " + c.HumanName + " hash " + h );
		    }
		}               

                foreach( Symbol current; members.SymbolList.elements() ) {
                    int m = current.Kind; //  & Symbol.MASK;
                    if( !current.IsFinal ) {
                        m = m + 1 << 15;
                    }
		    /*
		    if( current.IsPIC ) {
			m = m + 1 << 16;
		    }
		    */

                    hash_ = Util.Hash.rotate(hash_) + m;

                    if( current.Kind == Symbol.ENUM ) {
			hash_ = Util.Hash.rotate(hash_) + current.Hash;
		    } else if( current.IsAddressValid ) {
                        hash_ = Util.Hash.rotate(hash_) + current.Address;
                    } else {
			var v = current.LLVMValue;
			if( v != null ) {
			    if( LLVM.Calls.LLVMIsConstant(v) != 0 ) {
				var ch = cast int(LLVM.Calls.LLVMGetConstValue(v));
				// IO.Std.err.println( "using " + ch + " as hash value for " + current.Name + " when calculating hash for " + HumanName );
				hash_ = Util.Hash.rotate(hash_) + ch;
			    } else {
				IO.Std.err.println( "ignoring " + current.Name + " with non const LLVM.Value when calculating hash for " + HumanName );
			    } 
			} else {
			    IO.Std.err.println( "ignoring " + current.Name + " with no valid address when calculating hash for " + HumanName );
			}
		    }
                    
                    String s = current.DecoratedName;
                    hash_ = Util.Hash.rotate(hash_) + Util.Hash.hash(s);

		    // IO.Std.err.println( HumanName + ": member " + s + "@" + current.Address + " hash " + hash_ );
                }

                if( hash_ == 0 ) {
                    hash_ = 1;
                }
                
		// IO.Std.err.println( HumanName + ": result hash " + hash );
                // fprintf( stderr, "calculated hash %08X for %s\n", hash, getName() );
            }
        }

        get int Hash {
            if( hash_ == 0 ) {
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
            
            return hash_;
        }

        get bool NeedsBody  {
            return needs_body;
        }

        set bool NeedsBody = needs_body {
            this.needs_body = needs_body;
        }

        set Container Super = parent {
            setup( parent );
        }
        
	/*
        get int StackOffset {
            return stack_offset;
        }

	get int LocalOffset {
	    return local_offset;
	}
	*/

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

        bool matches( Vector<Type> arg_types, Quality result ) {
            result.quality = 0;
            result.score = -1;

            bool this_no_args, that_no_args;
            
            this_no_args = this.arg_types == null || this.arg_types.Length == 0;
            that_no_args = arg_types == null || arg_types.Length == 0;
            
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
            
            if( this.arg_types.Length == arg_types.Length ) {
                result.quality = Type.QUALITY_EXACT;

                var i = this.arg_types.elements();
                var j = arg_types.elements();
                
                while( i.hasMoreElements() && j.hasMoreElements() ) {
                    Type tl = cast<Type>(i.nextElement());
                    Type tr = cast<Type>(j.nextElement());
                   
                    if( tl.TypeKind == Type.REFERENCE ) {
                        tl = tl.SubType;
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
        
        bool matches( Vector<Type> arg_types, bool exact ) {
            bool this_no_args, that_no_args;
            
            this_no_args = this.arg_types == null || this.arg_types.Length == 0;
            that_no_args = arg_types == null || arg_types.Length == 0;
            
            if( this_no_args || that_no_args ) {
                return this_no_args && that_no_args;
            }
            
            if( this.arg_types.Length == arg_types.Length ) {
                var i = this.arg_types.elements();
                var j = arg_types.elements();
                
                while( i.hasMoreElements() && j.hasMoreElements() ) {
                    Type tl = cast<Type>(i.nextElement());
                    Type tr = cast<Type>(j.nextElement());
                    
                    if( !exact && tl.TypeKind == Type.REFERENCE ) {
                        tl = tl.SubType;
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


        Container findBestMethod( String name, Vector<Type> arg_types, Quality quality ) {
            quality.score = -1;
            return findBestMethod( name, arg_types, quality, true );
        }
    
        Container findBestMethod( String name, Vector<Type> arg_types, Quality quality, bool recurse ) {
            Container result = null;
            
            if( members != null ) {
		// IO.Std.err.println( "about to search: " + members + " (" + String.hex(cast<int>(members)) + ") for: " + name );
                result = members.findMethod( name, arg_types, quality );
		
                if( result != null && quality.score == Type.QUALITY_EXACT ) {
		    return result;
                    // fprintf( stderr, "found %s with score %d\n", result.getDecoratedName(), score );
                }		
            }
            
            if( recurse && parent != null ) {
                int s = quality.score;
                Container r = parent.findBestMethod( name, arg_types, quality, true );
                if( result != null ) {
                    if( r != null && s > quality.score ) {
                        IO.Std.err.println( "found better match in parent: " + r.DecoratedName + " (" + s + ") versus " + result.DecoratedName + " (" + quality.score + ")" );
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

        Container findMethod( String name, Vector<Type> arg_types, bool exact ) {
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
        
        get int Size {
            return itable_offset;
        }

        get String DecoratedName {
            if( decorated == null ) {
                IO.Std.err.println( "get decorated " + HumanName + ": null" );
                return Name;
            } else {
                return decorated;
            }
        }
        
        get String HumanName {
            if( human == null ) {
		StringBuffer result = new StringBuffer();
		Symbol o = Owner; 
		if( o != null ) {
		    result.append( o.HumanName );
		    result.append( '.' );
		}
		result.append( Name );
		return result;
            } else {
                return human;
            }
        }

	get String FileName {
	    return DecoratedName;
	}
        
        set String HumanName = hn {
	    human = hn;
        }
        
        
        get SymbolList Scope {
            return members;
        }
        
        void stripDefined( int level ) {
            members.stripDefined( level );
        }
        
        Symbol findSymbol( String name, int find_what ) {
            Symbol result = null;

	    // IO.Std.err.println( "search " + HumanName + " for " + name + " (" + find_what + ")" );
            // search genuine members first
            if( members != null ) {
                result = members.find( name, find_what );
                if( result != null ) {
                    return result;
                }
            }
            
            if( Kind == Symbol.NAMESPACE ) {
		// IO.Std.err.println( "not searching parent of namespace " + HumanName + " for " + name );
            } else if( parent != null ) {
                // not a namespace and have a parent class - search that instead#
		// IO.Std.err.println( "searching parent for: " + name + ", want types: " + want_types );
                return parent.findSymbol( name, find_what );
            }
            return null;
        }
        
        Symbol findDecorated( String name )     {
            if( members == null ) {
                return null;
            }
            
            Symbol result = members.findDecorated( name );
            if( result != null ) {
                return result;
            } else if( parent != null ) {
                return parent.findDecorated( name );
            } else {
                return null;
            }
        }

        void emitTypeTables( CompileState  state ) {
	    // FIXME: type tables
	    /*
            if( parent != null ) {
                parent.emitTypeTables( state );
            }

            foreach( Symbol current; members.SymbolList.elements() ) {
                if( current.Kind == Symbol.INSTANCE_VARIABLE ) {
                    Type t = current.Type;

                    char value;
                    if( t.TypeKind == Type.CLASS ) {
                        value = Object.TYPE_OBJECT;
                    } else if( t.TypeKind == Type.VECTOR ) {
                        value = Object.TYPE_ARRAY;
                    } else if( t.TypeKind == Type.POINTER ) {
                        value = Object.TYPE_POINTER;
                    } else {
			value = cast char(t.Size);
		    }
                    // Machine.emitDefByte( state.Output, cast int(value) );
                }
            }
	    */
        }

        void buildClassTables( CompileState state ) {
            if( !tables_valid ) {
                Addresses a = new Addresses();
                buildClassTables( state, a );
            }
        }

	void populateAllImplementedInterfaces( Vector<Container> all_implemented ) {
	    all_implemented.clear();

	    // IO.Std.err.println( "find all implemented interfaces for " + HumanName + "..." );

	    Container p = this;
	    do {
		if( p.implements_list != null ) {
		    foreach( Container ik; p.implements_list.elements() ) {
			Container q = ik;
			do {
			    if( !q.IsInterface ) {
				IO.Std.err.println( "oops: not an interface: " + p.HumanName );
				continue;
			    }

			    all_implemented.add( q );
			    q = q.Super;
			} while( q != null );
		    }

		}
		 
		p = p.Super;
	    } while( p != null );
	}

	get Vector<Container> AllImplementedInterfaces {
	    var result = new Vector<Container>();

	    populateAllImplementedInterfaces( result );

	    return result;
	}

	static void buildInterfaceTables( Generic.Set<Container> interfaces_set, Vector<Symbol> symbol_list ) {
	    int j, size = interfaces_set.Length;
	    if( size == 0 ) {
		return;
	    }

	    var interfaces = new Vector<Container>(size);

	    // IO.Std.err.println( "build interface tables for " + size + " interfaces: " + interfaces_set );

	    var matrix = new Gen.MBitSet[size];


	    foreach( var js; interfaces_set.elements() ) {
		// IO.Std.err.println( "interface " + is.HumanName + " interface #" + j + " out of " + matrix.length );

		interfaces.add( js );
	    }

	    // sort interfaces list so that compile order does not affect addresses assigned by selector coloring:
	    Generic.SortList<Container>.sort(interfaces);

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

	    var all_implemented = new Vector<Container>();

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

	static void allocateInterfaceSlots( Vector<Container> interfaces, Gen.MBitSet[] matrix ) {
	    var slots = new Vector<Vector<Container>>();
	    foreach( var ii; interfaces.elements() ) {
		allocateInterfaceSlots( interfaces, ii, slots, matrix );
	    }
	}

	static void allocateInterfaceSlots(
	    Vector<Container> interfaces,
	    Container ii,
	    Vector<Vector<Container>> slots,
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

			slots[slot_index] = new Vector<Container>();
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

		c.Address = -(INTERFACE_OFFSET + slot_index);
		if( CompileState.Instance.WantVeryVerbose ) {
		    ParseTree.message( "interface slot #" + slot_index + ": " + c.HumanName + " @ " + c.Address );
		}

		Container o = c.Override;
		if( o != null ) {
		    o.clearAddressValid();
		    o.Address = c.Address;
		}
	    }
	}

        void buildClassTables( CompileState state, Addresses address ) {
	    word ref_bits;

            if( tables_valid ) {
		// IO.Std.err.println( "tables already valid: " + HumanName );
                address.vtable_offset = vtable_offset;
                address.itable_offset = itable_offset;
                return;
            } else if( parent != null ) {
		// IO.Std.err.println( "build super tables: " + HumanName );
                parent.buildClassTables( state, address );
		ref_bits = parent.ref_bits;
            }

            if( is_struct ) {
                address.itable_offset = 0;
            }

	    // IO.Std.err.println( "build class tables: " + HumanName );

            int stable_offset = 0;
        
            if( members == null ) {
                throw new Exception( "weird: build class tables for class with no member list: " + HumanName );
            }

	    bool want_pack = state.WantPack;

	    var llvm_fields = new LLVM.Type[members.Length+2];

	    if( parent == null ) {
		llvm_fields[0] = LLVM.Calls.LLVMVTableType();
	    } else {
		llvm_fields[0] = LLVM.Calls.LLVMResolveTypeHandle(parent.llvm_opaque_type_handle);
	    }

	    var llvm_fields_i = 1;
        
            foreach( Symbol current; members.SymbolList.elements() ) { 
		int k = current.Kind;
                if( current == null ) {
                    throw new Exception( "oops: cannot build vtable slot for null member" );
                } else if( k & Symbol.FLAG_METHOD != 0 ) {
                    Container ancestor = null;
                    if( parent != null ) {
                        ancestor = parent.findMethod( cast<Container>(current) );
                    }
                
                    if( ancestor == null ) {
                        // not defined in parent-class - gets its own vtable offset
                    
                        if( current.IsAddressValid ) {
                            throw new Exception( "oops: " + current.Name + " already has an address" );
                        }
                    
                        current.Address = address.vtable_offset;

			// IO.Std.err.println( "BBBB: method " + current.HumanName + " @ " + address.vtable_offset );

			// method doesn't override anything - it needs its own vtable slot:
                        address.vtable_offset = address.vtable_offset + 1;
                    } else {
                        ancestor.IsFinal = false;

                        Container t = ancestor.Owner.Super;
                        while( t != null ) {
                            t = t.findMethod( ancestor );
                            if( t != null ) {
                                ancestor = t;
                                ancestor.IsFinal = false;
                                t = t.Owner.Super;
                            }
                        }
                    
                        current.Override = cast<Container>(ancestor);
                    
                        if( !ancestor.IsAddressValid ) {
                            throw new Exception( "oops: " + current.Name + " inherits its address but the method it overrides has no address" );
                        } else {
                            current.Address = ancestor.Address;
                        }

			// IO.Std.err.println( "BBBB: override " + current.HumanName + " @ " + current.Address );
                    }
                } else if( k == Symbol.STATIC_VARIABLE ) {
                    if( current.IsAddressValid ) {
                        throw new Exception( "weird: static variable " + current.HumanName + " already has an address" );
                    }
                
                    current.Address = stable_offset;
                    stable_offset = stable_offset + 1;
                } else if( k == Symbol.INSTANCE_VARIABLE ) {
                    if( current.IsAddressValid ) {
                        throw new Exception( "weird: instance variable " + current.HumanName + " already has an address" );
                    }

		    /*

		    int s;
		    if( want_pack ) {
			s = current.Type.Size;
			// IO.Std.err.println( "size of " + current.HumanName + " is " + s );
			if( s != 1 && s != 4 && s != Machine.WORD ) {
			    throw new System.Exception( "instance variable " + current.HumanName + " has bad size: " + s + " from type " + current.Type );
			}
		    } else {
			s = Machine.WORD;
		    }
		    var a = align(address.itable_offset,s);
		    current.Address = a;

		    */

		    current.Address = llvm_fields_i;

		    // IO.Std.err.println( "address for " +  HumanName + "." + current.Name + " @ " + a );

		    /*
		    if( current.Type.isReference() ) {
			var l = a + Machine.WORD;
			if( l > Machine.ALLOC_BITMAP_BYTES ) {
			    ref_bits = cast word(l);
			} else {
			    ref_bits = ref_bits | (1w << cast word(Machine.ALLOC_BITMAP_MAX - (a >> Machine.WORD_LOG2))) | 1w;
			}
		    }
		    */

		    llvm_fields[llvm_fields_i] = current.Type.getLLVMType(state);
		    llvm_fields_i = llvm_fields_i + 1;
		    // address.itable_offset = a + s;
                } else if( k == Symbol.CONST || k == Symbol.ENUM || k == Symbol.ACCESSOR || k == Symbol.TYPE ) {
                    ; // do nothing - occupies no space
                } else {
		    IO.Std.err.println( "weird: ignoring symbol " + current.Name + " of kind " + current.Kind );
                    // throw new Exception( "weird: ignoring symbol " + current.Name + " of kind " + current.Kind );
                }
            }
	    
	    llvm_struct_type_handle = LLVM.Calls.LLVMCreateTypeHandle( LLVM.Calls.LLVMStructType(llvm_fields.address, llvm_fields_i, 0 ) );
			       
	    // address.itable_offset = align(address.itable_offset,Machine.WORD);
        
            itable_offset = address.itable_offset;
            vtable_offset = address.vtable_offset;

	    this.stable_offset = stable_offset;
	    this.ref_bits = ref_bits;

	    // IO.Std.err.println( "ref bits now: " + ref_bits );
	    
	    // IO.Std.err.println( "BBBB: vtable size now: " + VTableSize );
	    
            tables_valid = true;
        }

	static int align(int a, int s) {
	    int m = s - 1;

	    var r = (a + m) & ~m;

	    /// IO.Std.err.println( "align " + a + " to " + s + " -> " + r );

	    /*
	    if( r < a ) {
		throw new Exception( "bad instance table address: " + r + " < " + a );
	    }
	    */
	    return r;
	}

	void emitTables( CompileState state, ParseTree from ) {

	    var buffer = new Generic.Vector<LLVM.Value>();

	    emitInterfaceTables( state, from, buffer );

	    // FIXME: type table
	    buffer.add( LLVM.Calls.LLVMConstPointerNull( LLVM.Calls.LLVMVTableFunctionType() ) );

	    // name
	    buffer.add(
		       LLVM.Calls.LLVMConstBitCast(
						   ParseTree.makeCStringConstant( state, HumanName ),
						   LLVM.Calls.LLVMVTableFunctionType()
						   )
		       );

	    // size
	    buffer.add(
		       LLVM.Calls.LLVMConstIntToPtr(
						   LLVM.Calls.LLVMConstInt(
									   LLVM.Calls.LLVMInt64Type(),
									   cast long(Size),
									   0
									   ),
						   LLVM.Calls.LLVMVTableFunctionType()
						   )
		       );
	    
	    // super class vtable 
	    if( Super != null ) {
		buffer.add(
			   LLVM.Calls.LLVMConstPointerCast(
							   ParseTree.makeLoadVTable( state, Super ),
							   LLVM.Calls.LLVMVTableFunctionType()
							   )
			   );
	    } else {
		buffer.add( LLVM.Calls.LLVMConstPointerNull( LLVM.Calls.LLVMVTableFunctionType() ) );
	    }

	    // FIXME: reference bits:
	    buffer.add( LLVM.Calls.LLVMConstPointerNull( LLVM.Calls.LLVMVTableFunctionType() ) );

	    emitClassTables( state, this, buffer );

	    var v = buffer.Array;

	    var a = LLVM.Calls.LLVMConstArray(
					      LLVM.Calls.LLVMVTableFunctionType(),
					      v.address,
					      v.length
					      );	    

	    /*
	    IO.Std.err.print( "ctable initializer value is: " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( a );
	    IO.Std.err.print( "ctable initializer type is:  " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf( a ) );
	    */
	    var ct = getCTableGlobal(state);

	    /*
	    IO.Std.err.print( "ctable global variable is:   " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpValue( ct );
	    IO.Std.err.print( "ctable global type is:       " ); IO.Std.err.flush();
	    LLVM.Calls.LLVMDumpType( LLVM.Calls.LLVMTypeOf( ct ) );
	    */
	    LLVM.Calls.LLVMSetInitializer(
					  ct,
					  // ParseTree.makeLLVMConstCast( a, LLVM.Calls.LLVMGetElementType(LLVM.Calls.LLVMTypeOf(ct)) )
					  a
					  );

	    LLVM.Calls.LLVMSetGlobalConstant(ct, 1);

	    //LLVM.Calls.LLVMAddTypeName( state.Module, HumanName.toCString(), Type.getLLVMType(state) );
	}

	void emitInterfaceTables( CompileState state, ParseTree from, Generic.Vector<LLVM.Value> buffer ) {
	    // IO.Std.err.println( "BBBB: emit interface tables " + HumanName + " expect to need " + iface_offset + " slots" );
	    if( implements_list == null ) {
		// IO.Std.err.println( "BBBB: no interfaces implemented" );
		// Machine.emitWeak( state.Output, "__ctable__" + DecoratedName );
		return;
	    }

	    var slots = new Vector<Container>();
	    var implemented = new Vector<Container>();
	    populateAllImplementedInterfaces( implemented );

	    Container i;

	    foreach( Container c; implemented.elements() ) {
		foreach( Symbol s; c.members.SymbolList.elements() ) {
		    if( !s.IsMethod ) {
			if( !s.IsType && !s.IsAccessor ) { 
			    from.error( "interface member " + s.Owner.HumanName + " " + s.HumanName + " is not a method" );
			}
			continue;
		    }

		    Container e = cast Container(s);
		    var slot = (-e.Address - INTERFACE_OFFSET);
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
				   i.HumanName + " cannot implement " + e.HumanName + " with incompatible return type" );
			continue;
		    }
		    
		    slots.lengthen(slot+1);
		    
		    if( slots[slot] != null ) {
			IO.Std.err.println( "weird: already implemented: " + slots[slot].HumanName + " versus " + i.HumanName );
		    }
		    
		    // IO.Std.err.println( "BBBB: implement slot #" + slot + ": " + i.HumanName );
		    slots[slot] = i;
		}
	    }

	    int total_ctable_size = iface_offset + 3 + VTableSize;
	    buffer.reserve(total_ctable_size);

	    // When Linux loader dynamically loads a shared library it does not appear to place global symbols consecutively in memory even if they
	    // are consecutive in the object file. This completely stuffs up implementation of combined interface + virtual method dispatch tables
	    // and class name and type information. To get around this define the entire class table for one class as a single shared symbol. As a
	    // result client code now needs to know the offset of the vtable given the interface table address:
	    // Machine.emitWeak( state.Output, "__ctable__" + DecoratedName );
	    // Machine.emitGlobalData( state.Output, "__ctable_" + DecoratedName, total_ctable_size );
	    // Machine.emitLabel( state.Output, "__ctable_" + DecoratedName );

	    foreach( Container d; slots.reverseElements() ) {
		if( d == null ) {
		    buffer.add( LLVM.Calls.LLVMConstPointerNull(LLVM.Calls.LLVMVTableFunctionType()) );
		} else {

		    // IO.Std.err.println( "" + d.HumanName + " @ " + d.Address );
		    /*
		    if( d.owner != this ) {
			Machine.emitExtern( state.Output,
					    d.DecoratedName );
		    }
		    */

		    buffer.add(
			       LLVM.Calls.LLVMConstPointerCast(
							       d.getFunctionGlobal(state),
							       LLVM.Calls.LLVMVTableFunctionType()
							       )
			       );
		}
	    }

	}

	int calcIFaceOffset() {
	    if( implements_list == null || implements_list.Length == 0 ) {
		return 0;
	    }

	    var implemented = new Vector<Container>();
	    populateAllImplementedInterfaces( implemented );

	    Container i;
	    int io = -1;

	    // IO.Std.err.println( "BBBB: calc iface offset for " + HumanName );

	    foreach( Container c; implemented.elements() ) {
		foreach( Symbol s; c.members.SymbolList.elements() ) {
		    if( !s.IsMethod ) {
			continue;
		    }

		    Container e = cast Container(s);
		    var slot = -e.Address - INTERFACE_OFFSET;
		    // IO.Std.err.println( "looking for method: " + s.HumanName + "..." );

		    if( slot > io ) {
			// IO.Std.err.println( "BBBB: largest slot so far is " + slot );
			io = slot;
		    }
		}
	    }

	    // IO.Std.err.println( "BBBB: result is " + io + 1 );
	    return io + 1;
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

	void refineClassTypeHandle( CompileState state ) {
	    // IO.Std.err.println( "about to refine: " + HumanName );
	    // IO.Std.err.flush();

	    if( llvm_opaque_type_handle != null ) {
		LLVM.Calls.LLVMRefineType( LLVM.Calls.LLVMResolveTypeHandle( llvm_opaque_type_handle ), LLVM.Calls.LLVMResolveTypeHandle( llvm_struct_type_handle ) );
		// LLVM.Calls.LLVMAddTypeName( state.Module, HumanName.toCString(), LLVM.Calls.LLVMResolveTypeHandle( llvm_struct_type_handle ) );

		llvm_opaque_type_handle = null;
	    }
	}

        void emitClassTables( CompileState state, Container for_class, Generic.Vector<LLVM.Value> buffer ) {
            if( !tables_valid ) {
                IO.Std.err.println( "skipping class with invalid tables: " + HumanName );
                return;
            }

            if( parent != null ) {
		// IO.Std.err.println( "BBBB: parent methods @ " + buffer.Length );
                parent.emitClassTables( state, for_class, buffer );
            }

	    int ca = 0, sa = 0;

	    // IO.Std.err.println( "BBBB: first non override method @ " + buffer.Length );

            foreach( Symbol current; members.SymbolList.elements() ) { 
                if( current == null ) {
                    throw new Exception( "oops: cannot emit vtable slot for missing member" );
                } else if( current.Kind & Symbol.FLAG_METHOD != 0 ) {
                    Symbol candidate = for_class.findMethod( cast<Container>(current) );
                
                    if( candidate == null ) {
                        throw new Exception( "strange: member missing: " + current.Name );
                        // Machine.emitDefPointer( state.Output, 0 );
                    } else {
                        Container owner = candidate.Owner;
                    
                        if( owner == null ) {
                            throw new Exception( "oops: cannot emit vtable entry for method with no owning class\n" );
                        } else {
                            Container o = candidate.Override;
                        
                            if( o != null ) {
                                o = o.Owner;
                            }
                        
                            if( o == null || o == this ) {
				/*
                                if( owner != for_class ) {
                                    Machine.emitExtern( state.Output,
                                                        candidate.DecoratedName );
                                } else {
                                    Machine.emitGlobalFunction( state.Output,
                                                        candidate.DecoratedName );
                                }
				// state.Output.println( "# ca: " + ca + ", sa: " + candidate.Address );
				*/
				// IO.Std.err.println( "BBBB: buffer[" + buffer.Length + " (" + (buffer.Length-(3+IFaceOffset)) + ")] = " + candidate.HumanName + " @ " + candidate.Address );

				buffer.add(
					   LLVM.Calls.LLVMConstPointerCast(
									   candidate.getFunctionGlobal(state),
									   LLVM.Calls.LLVMVTableFunctionType()
									   )
					   );


                                // Machine.emitDefPointer( state.Output, candidate.DecoratedName );
                            }
                        }
                    }
                } else if( current.Kind == Symbol.INSTANCE_VARIABLE ) {
                
                } else if( current.Kind != Symbol.STATIC_VARIABLE && current.Kind != Symbol.CONST && current.Kind != Symbol.ENUM &&
			   current.Kind != Symbol.TYPE && current.Kind != Symbol.ACCESSOR ) {
                    throw new Exception( "oops: member " + current.Name + " is weird kind: " + current.Kind );
                }
		ca = ca + 1; // FIXME: not referenced
            }
        }

	String toString() {
	    StringBuffer b = new StringBuffer("Container(");
	    b.append( this.HumanName );

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
