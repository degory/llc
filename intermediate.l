// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved
import stream;
import generator;

namespace Gen {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;
    use Generic.Vector;
    use Generic.SortList;

    // non-thread-safe version:
    class TempFactory {
	static int next_temporary = Machine.FIRST_SOFT_REG;
	static int next_label = 0;

	void init( int nt, int nl ) {
	    // do nothing - needed by thread safe implementation
	}

	static void setInstance( TempFactory t ) {
	    // do nothing - needed by thread safe implementation
	}

	static void resetTemp(int n) {
	    next_temporary = n;
	}

	static void markUsedTemp(int t) {
	    if( t >= next_temporary ) {
		// IO.Std.err.println( "seen temp T" + t );
		resetTemp(t + 1);
	    }
	}

	static void resetTemp() {
	    resetTemp(Machine.FIRST_SOFT_REG);
	}

	static get int CurrentTemp {
	    return next_temporary;
	}

	static int nextTemp() {
	    int result = next_temporary;
	    next_temporary = next_temporary + 1;
	    return result;
	}

	static void resetLabel( int l ) {
	    // IO.Std.err.println( "current_label: " + next_label + "->" + l );
	    next_label = l;
	}
	
	static void markUsedLabel(int l) {
	    if( l >= next_label ) {
		resetLabel( l + 1 );
	    }
	}

	static get int CurrentLabel {
	    // IO.Std.err.println( "current label: " + next_label );
	    return next_label;
	}

	static int nextLabelNumber() {
	    int result = next_label;
	    next_label = next_label + 1;
	    return result;
	}

	static ILabel nextLabel() {
            return new ILabel( nextLabelNumber() );
        }
    }

    /*
    // thread safe version - keep one instance per thread in thread local storage:
    class TempFactory extends Object {
	int next_temporary;
	int next_label;

	void init() {
	    init( Machine.FIRST_SOFT_REG, 0 );
	}

	void init( int nt, int nl ) {
	    next_temporary = nt;
	    next_label = nl;
	}

	static TempFactory getInstance() {
	    Object o = System.Thread.getTLS1();
	    // IO.Std.err.println( "get instance: " + cast int(o) );
	    return cast TempFactory(o);
	}

	static void setInstance( TempFactory instance ) {
	    // IO.Std.err.println( "set instance: " + cast int(instance) );
	    System.Thread.setTLS1( instance );
	}

	void resetTempInstance(int n) {
	    next_temporary = n;
	}

	static void resetTemp( int n ) {
	    Instance.resetTempInstance( n );
	}

	static void resetTemp() {
	    Instance.resetTempInstance(Machine.FIRST_SOFT_REG);
	}


	void markUsedTempInstance(int t) {
	    if( t >= next_temporary ) {
		// IO.Std.err.println( "seen temp T" + t );
		resetTempInstance(t + 1);
	    }
	}
	
	static void markUsedTemp(int t) {
	    Instance.markUsedTempInstance(t);
	}

	int getCurrentTempInstance() {
	    return next_temporary;
	}

	static int getCurrentTemp() {
	    return Instance.getCurrentTempInstance();
	}

	int nextTempInstance() {
	    int result = next_temporary;
	    next_temporary = next_temporary + 1;
	    return result;
	}
	
	static int nextTemp() {
	    return getInstance().nextTempInstance();
	}

	void resetLabelInstance( int l ) {
	    // IO.Std.err.println( "current_label: " + next_label + "->" + l );
	    next_label = l;
	}

	static void resetLabel( int l ) {
	    Instance.resetLabelInstance( l );
	}
	
	void markUsedLabelInstance(int l) {
	    if( l >= next_label ) {
		resetLabel( l + 1 );
	    }
	}

	static void markUsedLabel( int l ) {
	    Instance.markUsedLabelInstance( l );
	}
	
	int getCurrentLabelInstance() {
	    // IO.Std.err.println( "current label: " + next_label );
	    return next_label;
	}

	static int getCurrentLabel() {
	    return Instance.CurrentLabelInstance;
	}

	int nextLabelNumberInstance() {
	    int result = next_label;
	    next_label = next_label + 1;
	    return result;
	}

	static int nextLabelNumber() {
	    return Instance.nextLabelNumberInstance();
	}

	ILabel nextLabelInstance() {
            return new ILabel( nextLabelNumberInstance() );
        }

	static ILabel nextLabel() {
	    return Instance.nextLabelInstance();
	}
    }
    */
    class ILocalUseCount extends Object {
	int offset;
	int temp;
	public int use_count;

	void init( int offset, int use_count ) {
	    super.init();

	    this.offset = offset;
	    this.use_count = use_count;
	}

	void count( int amount ) {
	    use_count = use_count + amount;
	    // IO.Std.err.println( "LLLLL: T" + temp + " += " + amount + "->" + use_count );
	}

	get int Offset {
	    return offset;
	}

	set int Temp = temp {
	    this.temp = temp;
	}

	get int Temp {
	    return temp;
	}

	get int Count {
	    return use_count;
	}


	int opCompare( ILocalUseCount cb ) {
	    return cb.Count - Count;
	}


	System.String toString() {
	    System.StringBuffer result =
		new System.StringBuffer("[ILocalUseCount offset:")
		.append(getOffset())
		.append(",temp:")
		.append(getTemp())
		.append(",count:")
		.append(getCount())
		.append("]");

	    return result;
	}
    }

    class ILocalUseCounter extends Object {
	MBitSet address_taken;
	Generic.Vector<ILocalUseCount> use_count;
	bool inline;

	void init(bool inline, MBitSet address_taken) {
	    super.init();
	    this.inline = inline;
	    this.address_taken = address_taken;
	    use_count = new Generic.Vector<ILocalUseCount>();
	}

	void count( int offset, int factor ) {
	    // shift offset so that both locals and parameters are counted 
	    int n = Parse.Container.mungStackOffset( offset );
	    // use_count.lengthen(n+1);

	    // IO.Std.err.println( "count local access offset offset " + offset + " mung slot #" + n );

	    // IO.Std.err.println( "counting local access at offset " + offset + " as local #" + n + " (" + offset + "/" + Machine.WORD + "=" + (offset / Machine.WORD) );

	    /*
	    if( address_taken != null ) {
		IO.Std.err.println( "address taken: " + address_taken );
	    }

	    if( n >= 0 && address_taken != null && n < address_taken.Length && address_taken[n] ) {
		IO.Std.err.println( "variable at offset " + offset + " mung slot #" + n + " cannot be stored in a register as it's address is taken" );
	    }
	    */

	    if( n < 0 || (address_taken != null && n < address_taken.Length && address_taken[n]) ) {
		// do not count variables whose address is taken:

		// note: mungStackOffset may return results less than zero for very large stack offsets
		// treat these offsets as address taken here and don't count them
		// stack offsets off the other end of the address_taken array can safely be assumed to 
		// not have their address taken (the address_taken array is only extended as much as needed
		// to accomodate highest address taken value)
		// IO.Std.err.println( "address taken: " + offset );
		return;
	    }

	    int i = use_count.Length;
	    if( i < n + 1 ) {
		use_count.Length = n + 1;
	    }

	    // IO.Std.err.println( "LLLLL count " + i + " versus " + n + "..." );

	    ILocalUseCount u = use_count[n];

	    if( u == null ) {
		u = new ILocalUseCount( offset, 0 );
		use_count[n] = u;
	    } else {
		if( u.Offset != offset ) {
		    IO.Std.err.println( "oops: mung slot #" + n + " aliases offsets " + offset + " and " + u.Offset );
		    return;
		}
	    }

	    u.count( factor );
	}

	void sort() {
	    // IO.Std.err.println( "sorting: " + use_count );

	    var v = new Generic.Vector<ILocalUseCount>();
	    foreach( ILocalUseCount k; use_count.elements() ) {
		if( k != null ) {
		    v.add(k);
		}
	    }

	    Generic.SortList<ILocalUseCount>.sort( v );
	    use_count = v;

	    // IO.Std.err.println( "sorted: " + use_count );

	    int count = Machine.NUM_REG_VAR;

	    int j = 0;
	    foreach( ILocalUseCount i; elements() ) {
		if( i == null || (!inline && count <= 0) ) {
		    break;
		}

		int t = ITree.nextTemp();

		// IO.Std.err.println( "LLLLL local at offset " + i.getOffset() + " will be stored in T" + t );
		i.setTemp( t );

		count = count - 1;
		j = j + 1;
	    }

	    use_count.setLength(j);
	}

	get int Length {
	    return use_count.Length;
	}

	ILocalUseCount opGet( int i ) {
	    return use_count[i];
	}

	Generic.Iterator<ILocalUseCount> elements() {
	    return use_count.elements();
	}
    }

    class ICompareLocalUseCount extends Util.Compare {
	public void init() {
	    super.init();
	}

	public int compare( Object a, Object b ) {
	    // IO.Std.err.println( "compare a: " + a + ", b: " + b );
	    if( a == null ) {
		if( b == null ) {
		    return 0;
		} else {
		    return 1;
		}
	    } else if( b == null ) {
		return -1;
	    }

	    ILocalUseCount ca = cast<ILocalUseCount>(a);
	    ILocalUseCount cb = cast<ILocalUseCount>(b);

	    return cb.Count - ca.Count;
	}
    }

    class IValue extends Object {
        void init() {
            super.init();
        }
        
        void dump( IO.Writer f ) {
            f.write(toString());
        }
        
        void cat( StringBuffer s ) {
            s.append(toString());
        }
        
        int valueIs( String compare, int t, int f ) {
            if( compare.equals( toString() ) ) {
                return t;
            } else {
                return f;
            }
        }

	get bool IsLabel {
	    return false;
	}
        
        get int Int {
            return getString().parseInt();
        }

        int calcHash() {
            throw new Exception( "implement me!" );
        }
        
        String toString() {
            return getString();
        }

        String getString() {
            throw new Exception( "implement me!" );
        }
        
        void catBytes( StringBuffer s ) {
            throw new Exception( "implement me!" );
        }
    }
    
    class INumber extends IValue {
	protected int n;

	void init( int n ) {
	    super.init();
	    this.n = n;
	}

        get int Int {
            return n;
        }

	get String String {
	    return "" + n;
	}
    }

    class ILabel extends INumber {
        void init( int n ) {
            super.init(n);
	    assert( n < 10000000, "crazy label number" );
        }
        
        get String String {
            return ".L" + n;
        }

	get bool IsLabel {
	    return true;
	}
    }
    
    class IString extends IValue {
        String string;
        
        void init( int n ) {
            super.init();
            string = "" + n;
        }
        
        void init( String s ) {
            super.init();
            string = s;
        }

        get String String {
            return string;
        }
    }


    class ITree extends Object {
	static int next_id = 0;
	static int kill_id = -1;

        IValue value;
        ITree left, right;

        Object state;

        // MSet rset_;
	// static bool allow_three_address = false;

        // int id;
        int op;
        int size;
        int reg;

        int line_number;
        // int block_number;
        
        // int ref_count;

        get State GenState {
            return cast<State>(state);

        }

	get int LineNumber {
	    return line_number;
	}

        get ReWrite.State ReWriteState {
            return cast<ReWrite.State>(state);
        }

	static set int KillAfter = k {
	    if( k > 0 ) {
		// IO.Std.err.println( "kill " + next_id + " + " + k + ": " + (next_id + k) );
		kill_id = next_id + k;
	    } else {
		kill_id = -1;
	    }
	}

	static int rawOp( int op ) {
	    // IO.Std.err.println( "raw op " + op + ": " + (op & ~3) );
	    return op & ~3;
	}

	static int getSizeMask( int size ) {
	    if( size == 0 ) {
		return 0;
	    } else if( size == 1 ) {
		return 1;
	    } else if( size == 4 ) {
		return 2;
	    } else if( size == 8 ) {
		return 3;
	    } else {
		throw new Exception( "bad operation size: " + size );
	    }
	}	    

	/*
	static set bool AllowThreeAddress = allow_three_address {
	    this.allow_three_address = allow_three_address;
	}
	*/

	get int RawOp {
	    return rawOp( getOperator() );
	}


	get int Size {
	    return size;
	}

	ITree rewrite() {
	    int goal = ReWrite.Selector.getReWriteGoal(op);
	    if( goal == 0 ) {
		throw new Exception( "cannot rewrite this without a goal: " + this );
	    }
	    // IO.Std.err.println( "internal rewrite goal: " + goal + ": " + this );
	    return rewrite(goal);
	}

	ITree rewrite(int goal) {
	    return PreGen.rewrite(goal, this);
	}

	void genInto(Util.Vector list) {
	    CodeGenerator.genInstructionInto( this, list );
	}

        set Gen.State State = state {
            this.state = state;
        }

        set ReWrite.State State = state {
            this.state = state;
        }

        get int Operator {
	    // IO.Std.err.println( "get operator: " + op );
            return op;
        }

	get int HighestTempUsed {
	    int lt, rt;
	    if( op == Op.TEMP_4 || op == Op.TEMP_1 ) {
		return value.Int;
	    }

	    if( left != null ) {
		lt = left.HighestTempUsed;
	    }
	    if( right != null ) {
		rt = right.HighestTempUsed;
	    }
	    if( lt > rt ) {
		return lt;
	    } else {
		return rt;
	    }
	}

	static int nextTemp() {
	    int result =  TempFactory.nextTemp();

	    return result;
	}

        void init( ITree copy ) {
            this.init(copy.line_number,copy.op,copy.size,null,null,copy.value);
	    if( this.op != copy.op ) {
		IO.Std.err.println( "oops: copy " + this.op + "-" + this.size + " != " + copy.op + "-" + copy.size + " from: " + new System.Backtrace() );
	    }

            if( copy.left != null ) {
                left = new ITree(copy.left);
            }
            if( copy.right != null ) {
                right = new ITree(copy.right);
		check(right);
            }
        }
            
        void dump( IO.Writer out, int indent ) {
            throw new Exception( "Implement me!");
        }

        get ITree Left {
            return left;
        }

        get ITree Right {
            return right;
        }

	set ITree Left = t {
	    left = t;
	}

	set ITree Right = t {
	    right = t;
	    check(right);
	}

        ITree clone() {
	    return new ITree(this);
            // throw new Exception( "implement me!" );
        }

	ITree copy() {
	    return new ITree(this);
	}

	ITree duplicateForInline(int temp_offset, int label_offset, int line_number, int[] inline_args ) {
	    ITree result = copy();
	    result.transformForInline( temp_offset, label_offset, line_number, inline_args );
	    //  IO.Std.err.println( "xfmd: " + result );

	    return result;
	}

	void replaceTempsWithRegVars() {
	    if( RawOp == Op.TEMP ) {
		op = op - Op.TEMP + Op.REG_VAR;
	    }

	    if( left != null ) {
		left.replaceTempsWithRegVars();
	    }
	    if( right != null ) {
		right.replaceTempsWithRegVars();
	    }
	}

	void transformForInline(int temp_offset, int label_offset, int line_number, int[] inline_args ) {
	    int o = RawOp;
	    int s;
	    int n;
	    ITree u;
	    int l;

	    this.line_number = line_number;
	    if( value != null && value.IsLabel ) {
		l = value.getInt() + label_offset;
		// IO.Std.err.println( "apply offset " + label_offset + ": .L" + value.getInt() + "->.L" + l );

		TempFactory.markUsedLabel( l );

		value = new ILabel(l);
	    }

	    if( o == Op.LOCAL ||
		/*
		o == Op.PUSH || o == Op.POP ||
		(o >= Op.CALL && op <= Op.STATIC_DYNAMIC_CALL_DISCARD) || */
		(o >= Op.TRY && op <= Op.END_TRY) ) { /* || 
						     (o >= Op.ARG0 && op <= Op.ARG5) ) { */
		throw new Exception( "cannot inline: " + this );
	    }


	    // IO.Std.err.println( "apply offset from " + new System.Backtrace() );
	    if( o == Op.TEMP || o == Op.REG_VAR ) {
		int t = value.getInt();
		if( temp_offset < 0 ) {
		    throw new Exception( "reference to temporary in block epilog" );
		}

		/*
		l = subst.Length - 1;
		bool found;

		for( int i = 0; i < l; i = i + 1 ) {
		    if( subst[i] == t ) {
			value = new INumber( inline_args[i] );
			found = true;
			break;
		    }
		}
		*/

		// if( !found ) {
		    t = t + temp_offset;
		    // IO.Std.err.println( "apply offset " + temp_offset + ": T" + value.getInt() + "->T" + t );
		    
		    TempFactory.markUsedTemp( t );

		    value = new INumber(t);
		    //}
	    } else if( o >= Op.PARAM0 && o <= Op.PARAM5 ) {
		s = getSize();
		if( s == 0 ) {
		    s = Machine.WORD;
		}
		n = (o - Op.PARAM0) / 8;
		left.transformForInline(temp_offset,label_offset,line_number,inline_args);

		left = new ITree( line_number, Op.COPY, s, left, new ITree( 0, Op.TEMP, s, inline_args[n] ) );

		op = Op.LIST;
		size = 0;

				 /*
		subst.lengthen(n+1);
		subst[n] = left.getInt();
				 */

		// left = new ITree( 0, Op.COMMENT, 0, "arg" );
		// IO.Std.err.println( "subst inline PARAM" + n + " <- copy T" + getInt() +",T" + inline_args[n] );

		right.transformForInline(temp_offset,label_offset,line_number,inline_args);

		// left.transformForInline(temp_offset,label_offset,inline_args);

		// u = left;
		// left = new ITree( line_number, Op.COPY, s, u, new ITree( line_number, Op.TEMP, s, inline_args[n] ) );
	    } else if( o == Op.RESULT ) { 
		s = getSize();
		n = inline_args.length-1;
		// IO.Std.err.println( "subst inline RESULT, value: " + value );
		op = Op.LIST;
		size = 0;
		left.transformForInline(temp_offset,label_offset,line_number,inline_args);

		left = new ITree( line_number, Op.COPY, s,
				  new ITree( line_number, Op.TEMP, s, inline_args[n] ),
				  left );

		right = new ITree( line_number, Op.JUMP, 0, value );
		check(right);
		value = null;
	    } else if( o == Op.RESULT_F ) {
		// IO.Std.err.println( "result_f: " + this );
		s = left.getSize();
		if( s == 0 ) {
		    s = Machine.WORD;
		}
		n = inline_args.length-1;
		// IO.Std.err.println( "subst inline RESULT_F" );
		op = Op.COPY | getSizeMask(s);
		size = s;
		right = left;
		check(right);
		right.transformForInline(temp_offset,label_offset,line_number,inline_args);
		left = new ITree( line_number, Op.TEMP, s, inline_args[n] );		
	    } else {
		// IO.Std.err.println( "" + o + " != " + Op.RESULT );
		if( left != null ) {
		    left.transformForInline(temp_offset,label_offset,line_number,inline_args);
		}
		if( right != null ) {
		    right.transformForInline(temp_offset,label_offset,line_number,inline_args);
		}
	    }
	}

	/*
	ITree rset(MSet rset) {
	    this.rset_ = rset;
	    if( op == Op.SEQ_8 || op == Op.SEQ_4 || op == Op.SEQ_1 ) {
		right.rset(rset);
	    }
	    return this;
	}

	get MSet Set {
	    return rset_;
	}
	*/

	static int iq_count;

        void init( int line_number, int op, int size, ITree left, ITree right, IValue value ) {
            super.init();

            this.line_number = line_number;
            this.op = rawOp(op);

	    if( this.op == Op.CONST && value == null ) {
		IO.Std.err.println( "creating CONST ITree with null value from " + new System.Backtrace() );
	    }

            this.size = size;
	    this.op = this.op | getSizeMask(size);

	    /*
	    if( op >= Op.GT && op < Op.AND ) {
		IO.Std.out.println( "inequality: " + Op.getOpName(op) );
		if( iq_count >= 49589 ) {
		    IO.Std.out.println( "from: " + new System.Backtrace() );
		}
		iq_count = iq_count + 1;
	    }
	    */

	    if( size > Machine.WORD ) {
		throw new Exception( "creating ITree op " + op + " of size " + size + " > " + Machine.WORD );
	    }
	    


            this.left = left;
            this.right = right;
	    check(right);
            this.value = value;

	    // this.id = next_id;
	    /*
	    if( id >= 125 && id < 130 ) {
		IO.Std.err.println( "from: " + new Exception("DDDDD: " + this ) );
	    }
	    */
	    next_id = next_id + 1;
	    if( kill_id > 0 && next_id > kill_id ) {

		throw new Parse.CannotInlineException();
	    }
        }

        void init( int line_number, int op, int size ) {
            this.init( line_number, op, size, null, null, null );
        }

        void init( int line_number, int op, int size, String s ) {
            this.init( line_number, op, size, null, null, new IString(s) );
        }

        void init( int line_number, int op, int size, IValue value ) {
            this.init( line_number, op, size, null, null, value );
        }

        void init( int line_number, int op, int size, ITree left, IValue value ) {
            this.init( line_number, op, size, left, null, value );
        }
        
        void init( int line_number, int op, int size, int v ) {
            this.init( line_number, op, size, null, null, new IString(v) );
        }

        void init( int line_number, int op, int size, ITree l ) {
            this.init( line_number, op, size, l, null, null );
        }

        void init( int line_number, int op, int size, ITree l, int v ) {
            this.init( line_number, op, size, l, null, new INumber(v) );
        }

        void init( int line_number, int op, int size, ITree l, String v ) {
            this.init( line_number, op, size, l, null, new IString(v) );
        }

        void init( int line_number, int op, int size, ITree l, ITree r ) {
            this.init( line_number, op, size, l, r, null );
        }

        void init( int line_number, int op, int size, ITree l, ITree r, int v ) {
            this.init( line_number, op, size, l, r, new INumber(v) );
        }

        void init( int line_number, int op, int size, ITree l, ITree r, String v ) {
            this.init( line_number, op, size, l, r, new IString(v) );
        }

	void init( int line_number, int op, int size, ITree a, ITree b, ITree c ) {
	    this.init( line_number, op, size, new ITree(0,op,size,a,b), c );
	}

	void init( int line_number, int op, int size, ITree a, ITree b, ITree c, ITree d ) {
	    this.init( line_number, op, size, new ITree(0, op, size, new ITree(0, op, size, a, b), c ), d );
	}

	void init( int line_number, int op, int size, ITree a, ITree b, ITree c, ITree d, ITree e ) {
	    this.init( line_number, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, a, b), c ), d ), e );
	}

	void init( int line_number, int op, int size, ITree a, ITree b, ITree c, ITree d, ITree e, ITree f ) {
	    this.init( line_number, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, a, b), c ), d ), e ), f );
	}

	void init( int line_number, int op, int size, ITree a, ITree b, ITree c, ITree d, ITree e, ITree f, ITree g ) {
	    this.init( line_number, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, a, b), c ), d ), e ), f ), g );
	}

	void init( int line_number, int op, int size, ITree a, ITree b, ITree c, ITree d, ITree e, ITree f, ITree g, ITree h ) {
	    this.init( line_number, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, a, b), c), d), e), f), g), h);
	}

	void init( int line_number, int op, int size, ITree a, ITree b, ITree c, ITree d, ITree e, ITree f, ITree g, ITree h, ITree i ) {
	    this.init( line_number, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, new ITree(0, op, size, a, b), c), d), e), f), g), h), i);
	}

	static int next_temp = 0;
	static int next_label = 0;

	static void resetTemp() {
	    TempFactory.resetTemp();
	}

	static ILabel nextLabel() {
	    return TempFactory.nextLabel();
	}

	static int nextLabelNumber() {
	    return TempFactory.nextLabelNumber();
	}

        get IValue Value {
            return value;
        }

        int valueIs( String compare, int t, int f ) {
	    if( value == null ) {
		return f;
	    } else {
		return value.valueIs( compare, t, f );
	    }
	}

        get String String {
            return value.String;
        }

        get int Int {
            return value.Int;
        }

	get int TempNumber {
	    if( RawOp == Op.TEMP ) {
		return Int;
	    } else if( RawOp == Op.SEQ ) {
		return right.TempNumber;
	    } else {
		throw new Exception( "no temp value: " + this );
	    }
	}

	get ITree Temp {
	    if( RawOp == Op.TEMP ) {
		ITree result = new ITree(0,op,size,Int);
		// result.rset_ = rset_;
		return result;
	    } else if( RawOp == Op.SEQ ) {
		return right.Temp;
	    } else {
		throw new Exception( "no temp value: " + this );
	    }
	}

	get ITree SeqRight {
	    if( RawOp == Op.SEQ ) {
		return right.SeqRight;
	    } else {
		return this.copy();
	    }
	}


	String toString() {
	    return toString(0);
	}

	void makeIndent( StringBuffer b, int n ) {
	    for( int i = 0; i < n; i = i + 1 ) {
		b.append( "  " );		
	    }
	}

        String toString(int indent) {
	    /*
	    if( this == null || cast<word>(this) < 8192W ) {
		IO.Std.err.println( "ITree - this is corrupt" );
		return "<null: " + String.hex(cast<int>(this)) + ">";
	    }
	    */
            StringBuffer result = new StringBuffer();
	    makeIndent( result, indent );
            result.append( Op.getOpName(op) );
            if( value != null ) {
                result.append( ':' );
                result.append( value );
            }
	    result.append( " op #" );
	    result.append( op );
	    result.append( ' ' );

	    if( state != null ) {
		result.append( '[' );
		result.append( state );
		result.append( ']' );
	    } else {
		result.append( "*" );
	    }
	    if( left != null || right != null ) {
		result.append( "(\n" );

		if( left != null ) {
		    result.append( left.toString(indent+1) );
		}

		if( right != null ) {
		    if( left != null ) {
			result.append( ",\n" );
		    }
		    result.append( right.toString(indent+1) );
		    result.append( '\n' );
                }

		makeIndent(result,indent);
                result.append( ")\n" );
            }
            return result;
        }

        bool equals( ITree t ) {
            if( this == t ) {
                return true;
            }
            
            if( t == null ) {
                return false;
            }
            
            if( op != t.op ) {
                return false;
            }
            
            if( (left != null) != (t.left != null ) ||
                (right != null) != ( t.right != null) ) {
                return false;
            }
            
            if( left != null && !left.equals( t.left ) ) {
                return false;
            }
            
            if( right != null && !right.equals( t.right ) ) {
                return false;
            }
            
            if( value == t.value ) {
                return true;
            }
            
            if( value == null || t.value == null ) {
                return false;
            }
            
            if( value.getString().equals( t.value.getString() ) ) {
                return true;
            } else {
                return false;
            }
        }

	bool isConst1() {
	    if( value == null ) {
		return false;
	    } else if( value.Int == 1 ) {
		return true;
	    } else {
		return false;
	    }
	}

	bool isConst0() {
	    if( value == null ) {
		return false;
	    } else if( value.Int == 0 ) {
		return true;
	    } else {
		return false;
	    }
	}
	    

	bool isScale() {
	    if( value == null ) {
		return false;
	    }
	    int v = value.Int;
	    if( v == 1 || v == 2 || v == 4 || v == 8 ) {
		return true;
	    } else {
		return false;
	    }
	}

	bool isIndirect() {
	    return RawOp == Op.INDIRECT;

	}

	bool isRegVar() {
	    return RawOp == Op.REG_VAR;
	}

	bool isLValue() {
	    return isIndirect() || isRegVar();
	}

//        COPY                       this
//        /    \                    /    \
// INDIRECT    op                left    right
//   /        /  \              /       /     \
//addr INDIRECT  any   left.left   right.left 
//         /                         /     
//      addr                  right.left.left
       
	// FIXME: should be using COPY and INDIRECT
	bool mem2mem() {
	    // IO.Std.err.println( "mem2mem: " + this );

	    if( RawOp != Op.COPY ) {
		// IO.Std.err.println( "not copy: FALSE" );
		return false;
	    }
	    
	    if( left == null || /* left.left == null || */ right == null || right.left == null /* || right.left.left == null */ ) {
		// IO.Std.err.println( "missing child: FALSE" );
		return false;
	    }

	    if( !left.isLValue() ) { 
		return false;
	    }
	    
	    /*
	    if( !left.isIndirect() &&  || !right.left.isIndirect() ) {
		// IO.Std.err.println( "missing indirect: FALSE" );
		return false;
	    }
	    */
	    
	    if( left.equals( right.left ) ) {
		// IO.Std.err.println( "children match: TRUE" );
		return true;
	    } else {
		// IO.Std.err.println( "children do not match: FALSE" );
		return false;
	    }
	}

//        STORE                    this
//        /   \                  /    \
//     addr    op              left    right
//            /  \                    /     \
//          any  LOAD                    right.right
//               /                        /
//            addr                  right.right.left
	bool mem2memR() {
	    // IO.Std.err.println( "mem2mem: " + this );

	    return false;
	    /*
	    if( getRawOp() != Op.COPY ) {
		// IO.Std.err.println( "not copy: FALSE" );
		return false;
	    }
	    
	    if( left == null || left.right == null || right == null || right.left == null || right.left.left == null ) {
		// IO.Std.err.println( "missing child: FALSE" );
		return false;
	    }
	    
	    if( !left.isIndirect() || !right.left.isIndirect() ) {
		// IO.Std.err.println( "missing indirect: FALSE" );
		return false;
	    }
	    
	    if( left.left.equals( right.left.left ) ) {
		// IO.Std.err.println( "children match: TRUE" );
		return true;
	    } else {
		// IO.Std.err.println( "children do not match: FALSE" );
		return false;
		} */
	}

	
	int mem2mem( int t, int f ) {
	    if( mem2mem() ) {
		// IO.Std.err.println( "mem2mem: TRUE: returning " + t );
		return t;
	    } else {
		// IO.Std.err.println( "mem2mem: FALSE: returning " + f );
		return f;
	    }
	}

	static int wantPIC( int t, int f ) {
	    if( Parse.CompileState.Instance.WantPIC ) {
		return t;
	    } else {
		return f;
	    }
	}

	/*static*/ /* int a3( int t) {
	    if( allow_three_address ) {
		return t;
	    } else {
		return 32768;
	    }
        } */

	int const0( int t, int f ) {
	    if( isConst0() ) {
		return t;
	    } else {
		return f;
	    }
	}

	int scale( int t, int f ) {
	    if( isScale() ) {
		return t;
	    } else {
		return f;
	    }
	}

	int scaleLeft( int t, int f ) {
	    if( left != null ) {
		return left.scale( t, f );
	    } else {
		return f;
	    }
	}

	int scaleRight( int t, int f ) {
	    if( right != null ) {
		return right.scale( t, f );
	    } else {
		return f;
	    }
	}

	int mem2memR( int t, int f ) {
	    if( mem2memR() ) {
		// IO.Std.err.println( "mem2memR: TRUE: returning " + t );
		return t;
	    } else {
		// IO.Std.err.println( "mem2memR: FALSE: returning " + f );
		return f;
	    }
	}		

	int mem2memEither( int t, int f ) {
	    if( mem2mem() | mem2memR() ) {
		// IO.Std.err.println( "mem2memEither: TRUE: returning " + t );
		return t;
	    } else {
		// IO.Std.err.println( "mem2memEither: FALSE: returning " + f );
		return f;
	    }
	}		

	
	// is evaluation of this tree very unlikely to require allocation of a temporary?
        bool isSimple() {
            if( getRawOp() == Op.CONST || getRawOp() == Op.LOCAL ) {
                return true;
            } else if( getRawOp() == Op.INDIRECT ) {
                return left.isSimple();
            } else {
		return false; // (left == null || left.getRawOp() == Op.CONST) && (right == null && right.getRawOp() == Op.CONST);
            }
        }

	// is evaluation of this tree very unlikely to require allocation of more than a single temporary?
	bool isPrettySimple() {
	    if( isSimple() ) {
		return true;
	    } else if( right != null && !right.isSimple() ) {
		// IO.Std.err.println( "not pretty simple, right not simple: " + this );
		return false;
	    }

	    int o = getRawOp();

	   
	    if( o == Op.ADD || o == Op.SUB || o == Op.INDIRECT || o == Op.REG_VAR || o == Op.CONST_STR ) {		
		return left == null || left.isPrettySimple();
	    } else {
		// IO.Std.err.println( "not pretty simple, bad op: " + this );
		return false;
	    }
		
	}

	// get approximate number of temporaries needed to evaluate 
	get int Weight {
	    if( isSimple() ) {
		return 0;
	    } else if( isPrettySimple() ) {
		return 1;
	    } else {
		int w = 1;
		if( left != null ) {
		    w = w + left.Weight;
		}
		if( right != null ) {
		    w = w + right.Weight;
		}
		return w;
	    }
	}


        bool isConstant() {
            return RawOp == Op.CONST;
        }

        ITree makeConstant( int size, int value ) {
            ITree t;
            if( size == 1 ) {
                t = new ITree( line_number, Op.CONST, 1, value & 255 );
            } else if( size == 4 ) {
                t = new ITree( line_number, Op.CONST, 4, value );
            } else if( size == 8 ) {
		t = new ITree( line_number, Op.CONST, 8, value );
	    }
            return t;
        }

        ITree foldConstants() {
            if( left != null ) {
                left = left.foldConstants();
            }
            
            if( right != null ) {
                right = right.foldConstants();
		check(right);
            }
            
            if( op < Op.ELIGIBLE_CSE && left != null && left.isConstant()
                && ( right == null || right.isConstant() ) ) {
                int lv = left.getInt();
                int rv = 0;
                if( right != null ) {
                    rv = right.getInt();
                }
                
                switch ( op ) {
		case Op.ADD_8:
		    return makeConstant( 8, lv + rv );

                case Op.ADD_4:
                    return makeConstant( 4, lv + rv );
                    
                case Op.ADD_1:
                    return makeConstant( 1, lv + rv );

		case Op.SUB_8:
		    return makeConstant( 8, lv - rv );
                    
                case Op.SUB_4:
                    return makeConstant( 4, lv - rv );
                    
                case Op.SUB_1:
                    return makeConstant( 1, lv - rv );

		case Op.MUL_8:
		    return makeConstant( 8, lv * rv );

                case Op.MUL_4:
                    return makeConstant( 4, lv * rv );
                    
                case Op.MUL_1:
                    return makeConstant( 1, lv * rv );

		case Op.DIV_8:
		    return makeConstant( 8, lv / rv );
                    
                case Op.DIV_4:
                    return makeConstant( 4, lv / rv );
                    
                case Op.DIV_1:
                    return makeConstant( 1, lv / rv );

		case Op.MOD_8:
		    return makeConstant( 8, lv % rv );
                    
                case Op.MOD_4:
                    return makeConstant( 4, lv % rv );
                    
                case Op.MOD_1:
                    return makeConstant( 1, lv % rv );

		case Op.SHL_8:
		    return makeConstant( 8, lv << rv );
                    
                case Op.SHL_4:
                    return makeConstant( 4, lv << rv );
                    
//              case Op.SHL_1:
//                  return makeConstant( 1, lv << rv );

		case Op.SHAR_8:
		    return makeConstant( 8, lv >> rv );
                    
                case Op.SHAR_4:
                    return makeConstant( 4, lv >> rv );
                    
//              case Op.SHAR_1:
//                  return makeConstant( 4, lv >> rv );
                    

		case Op.EQ_8, Op.EQ_4, Op.EQ_1:
                    return makeConstant( 1, cast<int>(lv == rv) );
                    
                case Op.NE_8, Op.EQ_4, Op.EQ_1:
                    return makeConstant( 1, cast<int>(lv != rv) );
                    
                case Op.GT_8, Op.GT_4, Op.GT_1:
                    return makeConstant( 1, cast<int>(lv > rv) );
                    
                case Op.LT_8, Op.LT_4, Op.LT_1:
                    return makeConstant( 1, cast<int>(lv < rv) );
                    
                case Op.GE_8, Op.GE_4, Op.LT_1:
                    return makeConstant( 1, cast<int>(lv >= rv) );
                    
                case Op.LE_8, Op.LE_4, Op.LE_1:
                    return makeConstant( 1, cast<int>(lv <= rv) );

                case Op.AND_8:
                    return makeConstant( 8, lv & rv );

                case Op.AND_4:
                    return makeConstant( 4, lv & rv );
                    
                case Op.AND_1:
                    return makeConstant( 1, lv & rv );
                    
                case Op.OR_8:
                    return makeConstant( 8, lv | rv );

                case Op.OR_4:
                    return makeConstant( 4, lv | rv );
                    
                case Op.OR_1:
                    return makeConstant( 1, lv | rv );
                    
//              case Op.XOR_4:
//                  return makeConstant( 4, lv ^ rv );
                    
//              case Op.XOR_1:
//                  return makeConstant( 1, lv ^ rv );
                    
                case Op.NOT_8:
                    return makeConstant( 8, ~lv );

                case Op.NOT_4:
                    return makeConstant( 4, ~lv );
                    
                case Op.NOT_1:
                    return makeConstant( 1, ~lv );
                    
                case Op.NEG_8:
                    return makeConstant( 8, -lv );

                case Op.NEG_4:
                    return makeConstant( 4, -lv );
                    
                case Op.NEG_1:
                    return makeConstant( 1, -lv );
                    
                case Op.CAST_FROM1_4:
                    return makeConstant( 4, lv );
                    
		case Op.CAST_FROM1_8:
		    return makeConstant( 8, lv );

                case Op.CAST_FROM4_1:
                    return makeConstant( 1, lv );

		case Op.CAST_FROM4_8:
		    return makeConstant( 4, lv );

		case Op.CAST_FROM8_1:
		    return makeConstant( 1, lv );

		case Op.CAST_FROM8_4:
		    return makeConstant( 4, lv );
                    
                default:
                    return this;
                }
            } else {
                return this;
            }
        }

	void check( ITree t ) {
	    if( cast<word>(t) > 0W && cast<word>(t) < 8192W ) {
		throw new Exception( "here" );
	    }
	}
    }


    class IBlock extends Object {
        Util.Vector list;
	Util.Vector epilog;

	bool want_line_numbers;

        void init() {
	    init( new Util.Vector() );
        }

	void init( Util.Vector v ) {
	    super.init();
	    list = v;
	}

	void setWantLineNumbers( bool w ) {
	    this.want_line_numbers = w;
	}
        
        void add( ITree t ) {
	    if( t == null ) {
		IO.Std.err.println( "adding null intermediate tree here: " + new System.Backtrace() );
	    } else {
		list.add( t );
	    }
	    // t.from = new Exception("treecode").toString();
        }

	void addEpilog( ITree t ) {
	    if( epilog == null ) {
		epilog = new Util.Vector();
	    }
	    epilog.add( t );
	}

	void add( Util.Vector v ) {
	    foreach( ITree t; v.elements() ) {
		add( t );
	    }
	}

	void mergeEpilog() {
	    if( epilog != null ) {
		add( epilog );
		epilog = null;
	    }
	}

	get Util.Vector List {
	    mergeEpilog();
	    return list;
	}

	/*
        void insert( int i, ITree t ) {
            throw new Exception( "Implement me!" );
        }

        void replace( int i, ITree t ) {
            throw new Exception( "Implement me!" );
        }

        ITree toTree() {
            throw new Exception( "Implement me!" );
        }
	*/


        get int Length {
            return list.Length;
        } 

	void prepareForInline() {
	    list = allocateTempsForLocals( list, true, null );
	}

	void duplicateForInline( IBlock into, int line_number, int[] inline_args ) {
	    // FIXME: off by one here?
	    TempFactory.nextTemp();
	    TempFactory.nextTemp();

	    int temp_offset = TempFactory.CurrentTemp - Machine.FIRST_SOFT_REG;
	    int label_offset = TempFactory.CurrentLabel;
	    /*
	    IO.Std.err.println( "next temporary initially: " + TempFactory.CurrentTemp );
	    IO.Std.err.println( "will apply offset: " + temp_offset );
	    */
	    foreach( ITree t; list.elements() ) {
		if( t != null ) {
		    into.add( t.duplicateForInline(temp_offset,label_offset,line_number,inline_args) );
		} else {
		    IO.Std.err.println( "odd: null tree duplicating intermediate code block" );
		}
	    }

	    if( epilog != null ) {
		foreach( ITree u; epilog.elements() ) {
		    if( t != null ) {
			into.addEpilog( u.duplicateForInline(-1,label_offset,line_number,inline_args) );
		    } else {
			IO.Std.err.println( "odd: null tree duplicating intermediate code block epilog" );
		    }
		}
	    }

	    // FIXME: off by one here?
	    TempFactory.nextTemp();
	    TempFactory.nextTemp();

	    // IO.Std.err.println( "next temporary now: " + TempFactory.CurrentTemp );

	}

	ILocalUseCounter countLocals( Util.Vector v, bool inline, MBitSet address_taken ) {
	    // IO.Std.err.println( "LLLLL count locals" );
	    ILocalUseCounter c = new ILocalUseCounter(inline, address_taken);

	    int factor = 1;

	    foreach( ITree t; v.elements() ) {
		// IO.Std.err.println( "LLLLL count locals: " + t );
		if( t.RawOp == Op.ENTER_LOOP ) {
		    // IO.Std.err.println( "enter loop" );
		    factor = factor * 8;
		} else if( t.RawOp == Op.LEAVE_LOOP ) {
		    // IO.Std.err.println( "leave loop" );
		    factor = factor / 8;
		} else {
		    // IO.Std.err.println( "instruction: " + t );
		    countLocals( t, c, factor );
		}
	    }

	    // IO.Std.err.println( "LLLLL sorting" );	    

	    c.sort();

	    // IO.Std.err.println( "result: " + c );

	    return c;
	}

	ITree replaceLocalWithTemp( ITree t, int offset, int temp ) {
	    // IO.Std.err.println( "LLLLL replace local " + offset + "," + temp + ": " + t );

	    if( t.RawOp == Op.INDIRECT ) {
		// IO.Std.err.println( "indirect" );
		if( t.Left != null && t.Left.RawOp == Op.LOCAL ) {
		    int n = t.Left.Int;

		    // IO.Std.err.println( "local" );

		    if( n == offset ) {
			// IO.Std.err.println("LLLLL substitute local at " + offset + " with T" + temp );
			return new ITree( 0, Op.REG_VAR, t.getSize(), temp );
		    } else {
			// IO.Std.err.println( "offset differs" );
			return t;
		    }
		}
	    }

	    // IO.Std.err.println( "no match" );

	    ITree l = t.Left;
	    ITree r = t.Right;

	    t = t.copy();

	    if( l != null ) {
		t.Left = replaceLocalWithTemp( l, offset, temp );
	    }
	    if( r != null ) {
		t.Right = replaceLocalWithTemp( r, offset, temp );
	    }
	    
	    // IO.Std.err.println( "result: " + t );

	    return t;
	}


	Util.Vector allocateTempsForLocals( Util.Vector v, bool inline, MBitSet address_taken ) {
	    // return v;

	    // IO.Std.err.println( "LLLLL allocate temps for locals..." );
	    ILocalUseCounter c = countLocals( v, inline, address_taken );

	    // IO.Std.err.println( "LLLLL counted: " + c );
	    
	    Util.Vector r = new Util.Vector();

	    foreach( ITree t; v.elements() ) {
		// IO.Std.err.println( "LLLLL before: " + t );
		for( int j = 0; j < c.Length; j = j + 1 ) {
		    // IO.Std.err.println( "j: " + j );
		    ILocalUseCount i = c[j];
		    // IO.Std.err.println( "o: " + o );
		    if( i != null ) {
			// IO.Std.err.println( "use count: " + i );
			t = replaceLocalWithTemp( t, i.Offset, i.Temp );
		    }
		}
		r.add( t );


		if( t.Operator == Op.ENTER ) {
		    foreach( ILocalUseCount k; c.elements() ) {
			// stack parameter rather than local or register param
			if( k.Offset > 0 ) {
			    r.add( new ITree( 0, Op.COPY, Machine.WORD,
					      new ITree( 0, Op.REG_VAR, Machine.WORD, k.Temp ),
					      new ITree( 0, Op.INDIRECT, Machine.WORD,
							 new ITree( 0, Op.LOCAL, Machine.WORD, k.Offset )
							 )
					      )
				   );
			}
		    }

		}
		// IO.Std.err.println( "LLLLL after: " + t );
	    }



	    return r;
	}
	
        static ITree flattenTree( ITree t, Util.Vector v ) {
	    // IO.Std.err.println( "flatten: " + t );
            t = flattenTree2( t, v );
            if( t != null && t.RawOp != Op.TEMP ) {
		// IO.Std.err.println( "flatten result: " + t );
                v.add( t );
            }
        }

	static ITree flattenTree2( ITree t, Util.Vector v ) {
            // IO.Std.err.println( "flatten tree: " + t );
            int o = t.RawOp;
            // IO.Std.err.println( "op: " + o );
            ITree l = t.Left;
            // IO.Std.err.println( "left: " + l );
            ITree r = t.Right;
            // IO.Std.err.println( "right: " + r );

            if( o == Op.LIST ) {
                // IO.Std.err.println( "flatten LIST: " + t );

                if( l != null ) {
                    l = flattenTree2( l, v );
                    if( l != null ) {
                        v.add( l );
                    }
                }

                if( r != null ) {
                    r = flattenTree2( r, v );
                    if( r != null ) {
                        v.add( r );
                    }
                }

                return null;
            } else if( o == Op.SEQ ) {
                // IO.Std.err.println( "flatten SEQ: " + t );
                if( l != null ) {
                    l = flattenTree2( l, v );
                    if( l != null ) {
                        v.add( l );
                    }
                }

                r = r.getSeqRight();

                // IO.Std.err.println( "SEQ result is: " + r );
                return r;
            } else {
                // IO.Std.err.println( "flatten other: " + t );

                if( l != null ) {
                    l = flattenTree2( l, v );
                }

                if( r != null ) {
                    r = flattenTree2( r, v );
                }

                t.setLeft( l );
                t.setRight( r );

                // IO.Std.err.println( "other result is: " + t );
                return t;
            }
        }   

	private void countLocals( ITree t, ILocalUseCounter use_count, int factor ) {
	    if( t.RawOp == Op.LOCAL ) {
		int offset = t.Int;
		use_count.count( offset, factor);		
	    } else {
		ITree l = t.Left;
		ITree r = t.Right;

		if( l != null ) {
		    countLocals( l, use_count, factor );
		}

		if( r != null ) {
		    countLocals( r, use_count, factor );
		}
	    }
	}



// 	// does the intermediate code tree t reference any temporaries in the supplied bit-set?
// 	// if so, add Integers holding their temp number to the supplied vector (possibly multiple
// 	// times)
//         private bool anySpilledTemps( ITree t, MBitSet spilled, Util.Vector temps ) {
// 	    // IO.Std.err.println( "any d " + t );
// 	    // IO.Std.err.println( "set: " + spilled );
// 	    // IO.Std.err.println( "op " + t.getRawOp() + "==" + Op.TEMP + "?..." );

//             if( t.getRawOp() == Op.TEMP ) {
//                 int n = t.getInt();

//                 // IO.Std.err.println( "is temp T" + n );
//                 // IO.Std.err.println( "spilled.getLength: " + spilled.getLength() );

//                 if( n < spilled.getLength() && spilled.get(n) ) {
//                     IO.Std.err.println( "QQQQQ match spilled" );
// 		    temps.add( new System.Integer(n) );
//                     return true;
// 		    IO.Std.err.println( "QQQQQ: " + temps );
//                 } else {
//                     return false;
//                 }
//             } else {
//                 bool result = false;

//                 ITree l = t.getLeft();
//                 ITree r = t.getRight();

//                 if( l != null && anySpilledTemps( l, spilled, temps ) ) {
//                     result = true;
//                 }
//                 if( r != null && anySpilledTemps( r, spilled, temps ) ) {
//                     result = true;
//                 }

//                 return result;
//             }
//         }

// 	private ITree replaceTempWithMemory( ITree t, Util.Vector spilled_regs ) {
// 	    foreach( System.Integer i; spilled_regs.elements() ) {
// 		t = replaceTempWithMemory( t, i.getValue() );
// 	    }

// 	    return t;
// 	}


 	static ITree replaceTempWithMemory( ITree t, int spilled_reg, int offset ) {
 	    if( t.RawOp == Op.TEMP ) {
 		int n = t.Int;

 	        if( n == spilled_reg ) {
 		    // IO.Std.err.println( "QQQQQ substitute spilled" );
 		    return new ITree( 0, Op.INDIRECT, t.Size, 
 				      new ITree( 0, Op.ADD, Machine.WORD,
 						 new ITree( 0, Op.CONST, Machine.WORD, offset ),
 						 new ITree( 0, Op.REGISTER, Machine.WORD, Machine.R_FRAME ) ) );
 		} else {
 		    return t;
 		}
 	    } else {
 		ITree l = t.Left;
 		ITree r = t.Right;

 		t = t.copy();

 		if( l != null ) {
 		    t.Left = replaceTempWithMemory( l, spilled_reg, offset );
 		}
 		if( r != null ) {
 		    t.Right = replaceTempWithMemory( r, spilled_reg, offset );
 		}

 		return t;
 	    }
 	}

// 	private void allocateTempsForSplit( int count, Util.Vector replace_temps ) {
// 	    IO.Std.err.print( "allocate " + count + " temps for split:" );
// 	    for( int i = 0; i < count; i = i + 1 ) {
// 		int t = ITree.nextTemp();

// 		IO.Std.err.print( " T" + t );
// 		replace_temps.add( new System.Integer(t) );
// 	    }
// 	    IO.Std.err.println();
// 	}

// 	private ITree replaceSplitTemps( ITree t, Util.Vector split_temps, Util.Vector replace_temps ) {
// 	    int l = split_temps.getLength();

// 	    IO.Std.err.println( "replace split temps" );
// 	    IO.Std.err.println( "split: " + split_temps );
// 	    IO.Std.err.println( "replace: " + replace_temps );
// 	    IO.Std.err.println( "tree: " + t );

// 	    for( int i = 0; i < l; i = i + 1 ) {
// 		int st = cast<System.Integer>(split_temps.get(i)).getValue();
// 		int nr = cast<System.Integer>(replace_temps.get(i)).getValue();

// 		t = replaceSplitTemp( t, st, nr );
// 	    }

// 	    IO.Std.err.println( "replaced: "+ t );
// 	    return t;
// 	}


 	static ITree replaceSplitTemp( ITree t, int split_temp, int new_temp ) {
 	    // IO.Std.err.println( "replace split " + t );
 	    // IO.Std.err.println( "substitute T" + split_temp + " for T" + new_temp );
 	    if( t.RawOp == Op.TEMP ) {
 		int n = t.Int;

 	        if( n == split_temp ) {
 		    // IO.Std.err.println( "QQQQQ substitute split T" + split_temp + " with T" + new_temp );
 		    return new ITree( 0, t.RawOp, t.Size, new_temp );
 		} else {
 		    return t;
 		}
 	    } else {
 		ITree l = t.Left;
 		ITree r = t.Right;

 		t = t.copy();

 		if( l != null ) {
 		    t.Left = replaceSplitTemp( l, split_temp, new_temp );
 		}
 		if( r != null ) {
 		    t.Right = replaceSplitTemp( r, split_temp, new_temp );
 		}

 		return t;
 	    }
 	}

// 	private ITree getSpillSource( int n, MBitSet spilled, MBitSet split, Util.Vector to_split ) {
// 	    int temp = cast<System.Integer>(to_split.get(n)).getValue();

// 	    IO.Std.err.println( "spill source is T" + temp );

// 	    ITree result;

// 	    if( spilled.get(temp) ) {
// 	        result = new ITree( 0, Op.INDIRECT, 8, 
// 			       new ITree( 0, Op.ADD, 8,
// 					  new ITree( 0, Op.CONST, 8, 8 * temp ), // FIXME: correct temporary offset here
// 					  new ITree( 0, Op.REGISTER, 8, 7 ) ) );		
// 	    } else if( split.get(temp) ) {
// 		result = new ITree( 0, Op.TEMP, 8, temp );
// 	    } else {
// 		throw new Exception( "no spill source for T" + temp + ": not spilled or split" );
// 	    }

// 	    IO.Std.err.println( "MMMM source is: " + result );
// 	    return result;
// 	}

// 	int getIntVector( Util.Vector v, int i ) {
// 	    return cast<System.Integer>(v.get(i)).getValue();
// 	}

// 	private ITree getSpillDest( int n, Util.Vector to_replace, MBitSet mark_split ) {
// 	    int temp_replace = cast<System.Integer>(to_replace.get(n)).getValue();

// 	    IO.Std.err.println( "spill dest is T" + temp_replace );

// 	    ITree result = new ITree( 0, Op.TEMP, 8, temp_replace );

// 	    mark_split.set( temp_replace );

// 	    IO.Std.err.println( "MMMM dest is: " + result );

// 	    return result;
// 	}

// 	void markSplit( int original_temp, int split_temp, Util.Map map, MBitSet mark_all ) {
// 	    System.Integer k = new System.Integer( split_temp );
// 	    Object o = map.get( k );

// 	    if( o != null ) {
// 		int t = cast<System.Integer>(o).getValue();
// 		if( t != original_temp ) {
// 		    throw new Exception( "split register has changed from T" + t + " to T" + original_temp );
// 		}
// 	    } else {
// 		map.put( k, new System.Integer(original_temp) );
// 	    }

// 	    mark_all.set( split_temp );
// 	}

// 	private void generateWithSpills( 
// 					CodeGenerator gen,
// 					Util.Vector w, 
// 					ITree t, 
// 					MBitSet spilled, 
// 					MBitSet split, 
// 					MBitSet mark_split,
// 					Util.Map mark_map,
// 					Util.Vector to_spill, 
// 					Util.Vector to_split, 
// 					Util.Vector to_replace ) {

// 	    int i, j, k, l, m;
// 	    ITree s, d, y, c;
// 	    bool memory = false;

// 	    to_spill.setLength(0);
// 	    to_split.setLength(0);
// 	    to_replace.setLength(0);

// 	    bool emitted = false;

// 	    if( spilled != null ) {
// 		if( anySpilledTemps( t, spilled, to_spill ) ) {
// 		    IO.Std.err.println( "spills required: " + t );
// 		    y = replaceTempWithMemory( t, to_spill );
		    
// 		    IO.Std.err.println( "test is valid instruction: " + y );
// 		    if( gen.isValidInstruction( y.copy() ) ) {
// 			IO.Std.err.println( "memory direct" );
// 			t = y;
// 			memory = true;
// 		    } else {
// 			IO.Std.err.println( "memory via split" );
// 		    }
// 		}
		
// 		if( anySpilledTemps( t, split, to_split ) ) {
// 		    IO.Std.err.println( "split required: " + t );
// 		    allocateTempsForSplit( to_split.getLength(), to_replace );
		    
// 		    t = replaceSplitTemps( t, to_split, to_replace );
		    
// 		    l = to_split.getLength();

// 		    for( j = 0; j < l; j = j + 1 ) {
// 			k = getIntVector( to_split, j );
// 			m = getIntVector( to_replace, j );
// 			markSplit( k, m, mark_map, mark_split );

// 			IO.Std.err.println( "to split: " + k + " -> " + m );

// 			c = new ITree( 0, Op.COMMENT, 8, "fill" );

// 			w.add( c.copy() );
// 			gen.gen( c );
// 			IO.Std.err.println( "issued fill comment" );
			
// 			s = getSpillSource( j, spilled, split, to_split );
// 			d = getSpillDest( j, to_replace, mark_split );

// 			y = new ITree( 0, Op.COPY, 8, d, s );
// 			IO.Std.err.println( "fill: " + y );

// 			w.add( y.copy() );
// 			gen.gen( y );
// 		    }
		    
// 		    if( memory ) {
// 			c = new ITree( 0, Op.COMMENT, 8, "memory operation T" + i );
// 			w.add( c.copy() );
// 			gen.gen( c );
// 			IO.Std.err.println( "issued memory operation comment" );
// 		    }

// 		    c = new ITree( 0, Op.COMMENT, 8, "inst" );
// 		    w.add( c.copy() );
// 		    gen.gen( c );

// 		    IO.Std.err.println( "inst: " + t );
// 		    w.add( t.copy() );
// 		    gen.gen( t );

// 		    emitted = true;

// 		    for( j = to_split.getLength() - 1; j >= 0; j = j - 1 ) {
// 			c = new ITree( 0, Op.COMMENT, 8, "spill" );
// 			w.add( c.copy() );
// 			gen.gen( c );
// 			IO.Std.err.println( "issued spill comment" );
			
// 			s = getSpillSource( j, spilled, split, to_split );
// 			d = getSpillDest( j, to_replace, mark_split );

// 			y = new ITree( 0, Op.COPY, 8, s, d );
// 			IO.Std.err.println( "spill: " + y );
// 			w.add( y.copy() );
// 			gen.gen( y );  
// 		    }

// 		    IO.Std.err.println( "completed spill" );
// 		}
// 	    }

// 	    if( !emitted ) {
// 		if( memory ) {
// 		    c = new ITree( 0, Op.COMMENT, 8, "memory operation T" + i );
// 		    w.add( c.copy() );
// 		    gen.gen( c );
// 		    IO.Std.err.println( "issued memory operation comment" );

// 		    IO.Std.err.println( "memory operation: " + t );
// 		}
		
// 		// no split required:
// 		IO.Std.err.println( "generate: " + t );

// 		w.add( t.copy() );
// 		gen.gen( t );
// 	    }
// 	}


	void flatten( Util.Vector list, Util.Vector v, bool rewrite ) {
 	    int last_line = 0;

	    bool debug = false;

	    foreach( ITree t; list.elements() ) {
		ITree original = t;
		
		// IO.Std.err.println( "set: " + spilled );
		
		// if this tree has a different line number to the previous one, output a
		// line number instruction for debugging purposes:

		if( want_line_numbers ) {
		    int ln = t.LineNumber;
		    if( ln > 0 && ln != last_line ) {
			last_line = ln;
			ITree l = new ITree( last_line, Op.LINE, 0, ln );
			if( rewrite ) {
			    l = l.rewrite(1);
			    // IO.Std.err.println( "line number now: " + last_line + ", issuing: " + l + "->" + lm );
			}
			v.add( l );
			// gen.gen(lm);
		    }
		}

		// String f = t.from;
		// IO.Std.out.println( "fold constants: " + t );
		
		// reduce wholly constant sub expression trees to single constants:
		t = t.foldConstants();
		// IO.Std.out.println( "rewrite: " + t );
		
		try {
		    if( rewrite ) {
			if( debug ) {
			    IO.Std.err.println( "rewriting: " + t );
			}
			// transform the tree to form where it can be cut into sub-trees each corresponding
			// exactly to valid machine instructions:
			t = PreGen.rewrite( 1, t );
			
			if( debug ) {
			    IO.Std.err.println( "after rewrite: " + t );
			} 
		    }
		    // extract sub trees corresponding to whole machine instructions and add them to the
		    // working list of intermediate code instruction trees:
		    flattenTree( t, v );
		} catch( Exception er ) {
		    IO.Std.err.println( "caught: " + er + " rewrite: " + original );
		    throw er;
		}
	    }
	}

	bool genMethod(
		       int attempt,
		       IO.Writer out, 
		       String decorated_name, 
		       String method_name, 
		       int local_depth,
		       MBitSet address_taken,
		       int ref frame_flags
		       ) {
 	    // IO.Std.err.println( "compile: " + decorated_name );

	    // IO.Std.err.println( "list: " + list );

            CodeGenerator gen = new CodeGenerator(out);

 	    // IO.Std.err.println( "alloc mbitset " + TempFactory.getCurrentTemp() );

 	    Util.Vector v = new Util.Vector();

 	    bool debug = false;

	    /*
	    if( decorated_name != null && decorated_name.equals("makeSaveCallee__Q23Gen7Machineiii" ) ) {
		debug = true;
	    }
	    */

	    int i, len;

	    if( debug ) {
		IO.Std.err.println( "list:\n" + list );
	    }

	    mergeEpilog();

	    // IO.Std.err.println( "LLLLL allocate...." );

	    if( attempt & MFlow.GEN_REGVARS != 0 ) {
		list = allocateTempsForLocals( list, false, address_taken );
	    }
	    // IO.Std.err.println( "LLLLL list now: " + list );


	    /*
	    bool optimize = true;
   
	    
	    if( optimize ) {
		flatten( list, v, false );

		IBlock to_optimize = new IBlock( v );
		optimize( to_optimize );

		v = new Util.Vector();
    	    }
	    */

	    // if we're going to do common sub-expression elimination then
	    // the code generator needs to emit more risc style instructions 
	    // (we'll convert them to machine instructions later if needed)


	    /*
	    if( attempt & MFlow.GEN_CSE != 0 ) {
		ITree.AllowThreeAddress = true;
	    } else {
		ITree.AllowThreeAddress = false;
	    }
	    */

 	    // rewrite the intermediate code tree using the PreGen code generator
	    // this allocates temporary registers and transforms the tree into a form
 	    // where it can be subsequently be exactly and completely tiled with
 	    // matching valid machine instructions

	    // also convert the line numbers stored in the trees to explict line number
	    // instructions



	    flatten( list, v, true );

	    // transform intermediate code tree instruction representation to machine tree representation and
	    // perform register allocation.
	    
	    // FIXME: foreach over v here doesn't terminate - why?
	    i = 0;
	    len = v.Length;
	    
	    // for each intermediate representation machine instruction:
	    while( i < len ) {
		ITree u = cast<ITree>(v[i]);
		if( debug ) {
		    IO.Std.err.println( u );
		}
		// generate machine representation for this instruction
		gen.gen( u );
		
		i = i + 1;
	    }
	    // we now have a complete list of machine instructions for this code block. Have the register
	    // allocator attempt to assign registers and emit assembler. If this fails caller will need to
	    // retry with either simplified code or simpilfied code generation options:
	    
	    return gen.genMethod(attempt,local_depth,frame_flags);
	}


	String toString() {
	    StringBuffer result = new StringBuffer();

	    foreach( ITree t; list.elements() ) {
		result.append( t );
	    }

	    return result;
	}
    }

    class PreGen {
        static ReWrite.Selector is = new ReWrite.Selector();

        static ITree walk( int goal, ITree t ) {
            int ern = is.rule( t.ReWriteState, goal );
	    // IO.Std.err.println( "walk goal " + goal + " for " + t + " gives rule: " + ern );

            if( ern == 0 ) {
		throw new Exception( "no rewrite for: " + t );
            }

            int[] nts = is.getNTS( ern );
            
	    // IO.Std.err.println( "calling kids for " + t + " goal " + ern );
            ITree[] children = is.kids( t, ern );
            ITree[] itree;

            if( children.length > 0 ) {
                // IO.Std.err.println( "children: " + children.length + "..." );
                itree = new ITree[children.length];
                for( int i = 0; i < nts.length; i = i + 1 ) {
                    // IO.Std.err.println( "child #" + i + "-> " + children[i] );
                    itree[i] = walk( nts[i], children[i] );
                    // IO.Std.err.println( "child #" + i + "<- " + itree[i] );
                }
            } else {
                itree = new ITree[1];
                itree[0] = t;
                //IO.Std.err.println( "only child: " + t );
            }
            
	    // IO.Std.err.println( "getResult("+ern+","+t+")" ); 
            ITree result = is.getResult( ern, t, itree );
            
            // IO.Std.err.println( "pregen: " + t + "->" + result );
            return result;
        }

        static ITree rewrite( int goal, ITree t ) {
            // IO.Std.out.println( "labelling..." );
            is.label(t);
            //IO.Std.out.println( "labelled gives: " + t + "\nwalking goal: " + goal );
            ITree result = walk( goal, t );
            // IO.Std.err.println( "done: " + result );

            return result;
        }       
    }
}
