 // copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import stream;
import vector;
import machine;
import mflow;

namespace Gen {
    use System.Object;
    use System.String;
    use System.StringBuffer;
    use System.Exception;

    class MTreeWalker extends Object {
        void init() {
            super.init();
        }

        MTree rewrite( MTree m ) {
            return m;
        }

        void process( MTree m ) {
        }
    }

    class MTree extends Object {
	protected int op;
	protected MTree dest, left, right;
	
	void init( int op, MTree dest, MTree left, MTree right ) {
	    super.init();
	    this.op = op;
	    
	    this.dest = dest;
	    this.left = left;
	    this.right = right;
	}
	
	void addName( int t ) {
	}
	
	void initOperands() {
	}
	
	get int Reg {
	    return 0;
	}
	
	get int Temp {
	    return 0;
	}

	get int Int {
	    return 0;
	}

	get int Operation {
	    return op;
	}

        get int RawOp {
	    return ITree.rawOp( Operation );
	}

	int hash() {
	    int result = op;
	    /*
	      if( dest != null ) {
	      result = Util.Hash.hash(result,dest.hash());
	      }
	    */
	    
	    
	    if( left != null ) {
		result = Util.Hash.hash(result,left.hash());
	    }
	    
	    if( right != null ) {
		result = Util.Hash.hash(result,right.hash());
	    }

	    return result;
	}

	get int Size {
	    int s = Operation & 3;
	    if( s == 0 ) {
		return 0;
	    } else if( s == 1 ) {
		return 1;
	    } else if( s == 2 ) {
		return 4;
	    } else if( s == 3 ) {
		return 8;
	    } else {
		throw new Exception( "unexpected size operator = " + Operation );
	    }
	}

	/*
	MTree find( Util.Map m, int hash ) {
	    for( int i = 0; i < in.length; i = i + 1 ) {
		MTree t = in[i];
		if( t != null && t.hash() == hash ) {
		    return new MReg( t, MSet.General );
		}
	    }
	}
	*/

	set int Size = s {
	    //	    IO.Std.err.println( "assigning to Size does nothing" );
	}

	void initSize() {
	    initSize(0);
	}

	void initSize(int s) {
	    if( op != 0 ) {
		s = Size;
	    } else {
		Size = s;
	    }

	    if( dest != null ) {
		dest.initSize(s);
	    }
	    if( left != null ) {
		left.initSize(s);
	    }
	    if( right != null ) {
		right.initSize(s);
	    }
	}

	get MTree Dest {
	    return dest;
	}

	get MTree Left {
	    return left;
	}

	get MTree Right {
	    return right;
	}

	bool needRegen() {
	    return false;
	}

	bool writesMemory() {
	    if( dest != null ) {
		return dest.isMemory();
	    }
	}

	bool readsMemory() {
	    if( left != null && left.isMemory() ) {
		return true;
	    }

	    if( right != null && right.isMemory() ) {
		return true;
	    }
	}

	bool isMemory() {
	    return false;
	}	

        void markLive( int u, MBitSet seen, MBitSet[] matrix ) {
	    // do nothing
	}

	static bool compareRHS( MTree u, MTree v, MExpressionTable expressions ) {	    
	    if( u == null ) {
		return v == null;
	    } else {
		return u.compareRHS(v, expressions );
	    }
	}

	bool compareValues( MTree t ) {
	    // return getValue() =~ t.getValue();
	    bool result = String.equals( getValue(), t.getValue() );
	    // IO.Std.err.println( "compare values: /" + getValue() + "/ versus /" + t.getValue() + " -> " + result );
	    return result;

	}

	bool compareRHS( MTree t, MExpressionTable expressions ) {
	    bool debug = false;

	    if( this.RawOp == Op.ADD ) {
		debug = true;
	    }
	    if( debug ) {
		IO.Std.err.println( "CSE add: " + this );
		IO.Std.err.println( "versus:  " + t );
	    }

	    if( t == null ) {
		if( debug ) {
		    IO.Std.err.println( "valencys differ" );
		}
		return false;
	    }
	    
	    if( Operation != t.Operation ) {
		if( debug ) {
		    IO.Std.err.println( "ops differ" );
		}
		return false;
	    }

	    if( !compareValues( t ) ) {
		if( debug ) {
		    IO.Std.err.println( "values differ" );
		}
		return false;
	    }

	    if( !compareRHS( getLeft(), t.getLeft(), expressions ) ) {
		if( debug ) {
		    IO.Std.err.println( "left operands differ" );
		}
		return false;
	    }
	    
	    if( !compareRHS( getRight(), t.getRight(), expressions ) ) {
		if( debug ) {
		    IO.Std.err.println( "right operands differ" );
		}
		return false;
	    }

	    if( debug ) {
		IO.Std.err.println( "CSE compare: " + this + " versus " + t + ": equal" );	    
	    }
	    return true;
	}
        
        set String Value = s {
 	   // do nothing
        }
        
	set int Value = v {
	    // do nothing
	}

	get String Value {
	    return null;
	}

	set int Mode = mode {
	}

	MTree rset( MSet rset ) {
	    // IO.Std.err.println( "setting register set " + setName(rset) + " has no effect on: " + this );
	    return this;
	}


	bool isPhi() {
	    return false;
	}


	bool clearIneffectivePhi(int s) {
	    throw new Exception( "not a phi: " + this );
	}

	bool isCSE() {
	    int o = this.RawOp;
	    bool result = o > 0 && o < Op.ELIGIBLE_CSE; 
	    /*
	    if( o == Op.ADD ) {
		IO.Std.err.println( "add instruction eligible CSE: " + result );
	    }
	    */
	    return result;
	}

	set int TempName[int j] = n {
	    throw new Exception( "not a phi" );
	}

	get int TempName[int i] {
	    throw new Exception( "not a phi" );
	}

	bool isCall() {
	    return false;
	}

	bool isJump() {
	    return false;
	}

	bool isUnconditionalJump() {
	    return false;
	}

	bool isLabel() {
	    return false;
	}
	
	bool isCopy() {
	    return false;
	}

	/*
	bool dontCoalesce() {
	    return false;
	}
	*/

	bool isReg() {
	    return false;
	}
	
	bool isConstantZero() {
	    return false;
	}

	bool isConstantOne() {
	    return false;
	}

	bool isConstantMinusOne() {
	    return false;
	}

	bool isEnterLoop() {
	    return false;
	}

	bool isLeaveLoop() {
	    return false;
	}

	void setITree( ITree t ) {
	    // do nothing - only instructions have an associated intermediate tree
	}

	String getLabel() {
	    throw new Exception("this MTree has no label");
	}
	
	String toArgString() {
	    return "";
	}

	String getByteList() {
	    String s = toString();
	    StringBuffer result = new StringBuffer();
	    for( int i = 0; i < s.getLength(); i = i + 1 ) {
		result.append( cast<int>(s.charAt(i)) );
		if( i < s.getLength() - 1 ) {
		    result.append(',');
		}
	    }
	    return result;
	}

    
	static String opString( int op ) {
	    // if( op == 0 ) {
	    //	throw new Exception("op is zero");
	    // }
	    return Op.getAsName(op);
	}

	void assignSegment( Util.Vector stack ) {
	    // do nothing
	}

        void process( MTreeWalker tw ) {
            // IO.Std.err.println( "process ITree op: " + op + " with " + tw );

            if( dest != null ) {
                // IO.Std.err.println( "recurse dest" );
                dest.process(tw);
            }
            if( left != null ) {
                // IO.Std.err.println( "recurse left" );
                left.process(tw);
            }
            if( right != null ) {
                // IO.Std.err.println( "recurse right" );
                right.process(tw);
            }

            // IO.Std.err.println( "process this" );
            tw.process( this );
        }

        MTree rewrite( MTreeWalker tw ) {
            if( dest != null ) {
                dest = dest.rewrite(tw);
            }
            if( left != null ) {
                left = left.rewrite(tw);
                // if( left == null ) {
                //    IO.Std.err.println( new Exception( "rewrite has made left null: " + this ) );
                // }
            }
            if( right != null ) {
                right = right.rewrite(tw);
            }
            return tw.rewrite( this );
        }


	MTree copy() {
	    return cast<MTree>(this.clone());
	}


	MTree flatten( MFlatten f ) {
	    if( this == null ) {
		throw new Exception( "flattening null tree" );
	    }
	    return this;
	}

	void replaceTemp( int temp, int replace ) {
	    // do nothing
	}

	void calcFrameSize( MFrame m ) {
	    // do nothing
	}

	String toString() {
	    return dump();
	}

	String toString(MSet rset) {
	    return toString();
	}

	String dump() {
	    return "MTree()";
	}

	void addOperand(Util.Vector v, int mode, int reg, int temp, MSet rset, int size, MReg r) {
	    foreach( MOperand o; v.elements() ) {
		if( (temp != 0 && o.temp == temp) || (reg != 0 && o.reg == reg) ) {
		    o.mode = o.mode | mode;
		    o.temp = temp;
		    if( reg != 0 ) {
			o.reg = reg;
		    }
		    if( o.rset != rset ) {
			// IO.Std.err.println( "register set changes within instruction for T" + temp + " from " + Machine.getSetName(o.rset) + " to " + Machine.getSetName(rset) );
			rset = Machine.getRegSetIntersection( o.rset, rset );

			// IO.Std.err.println( "using intersection register set " + Machine.getSetName(rset) );
			// throw new Exception( "register set changes for T" + temp  );
		    }
		    /*
		    if( o.size != size ) {
			IO.Std.err.println( "register size changes within instruction for T" + temp + " from " + o.size + " to " + size );
			if( size > o.size ) {
			    o.size = size;
			}
		    }
		    */
		    o.rset = rset;
		    o.add(r);
		    // IO.Std.err.println( "adding reference to T" + temp );
		    return;
		}
	    }
	    v.add( new MOperand(mode, reg, temp, rset, size, r) );
	}

	void findOperands(Util.Vector v) {
	    // do nothing
	}

	void adjustFrameOffset(MAdjustFrameOffset m) {
	    // do nothing
	}
    }

    class MStack extends MTree {
	void init( int op, MTree left ) {
	    super.init( op, null, left, null );
	    if( op == Op.POP ) {
		left.Mode = Mode.WRITE;
	    } else {
		left.Mode = Mode.READ;
	    }
	}

	bool compareRHS( MTree t, MExpressionTable expressions ) {
	    return false;
	}

	String toString() {
	    return opString(op) + ' ' + left;
	}
    
	String dump() {
	    String sl = "<null>";
	    if( left != null ) {
		sl = left.dump();
	    }
	    return "MStack(" + opString(op) + ' ' + sl + ")";
	}    

	void calcFrameSize( MFrame m ) {
	    m.seenStack();
	}
    }

    class MAny extends MTree {
	String text;
	void init( String text ) {
	    this.text = text;
	}

	String toString() {
	    return text;
	}
    }

    class MPhi extends MTree {
	Util.IntVector names;
	int temp;
	bool effective;

	void init( int t ) {
	    super.init( 0, new MReg( t, MSet.General ), null, null );
	    dest.Mode = Mode.WRITE;
	    temp = t;
	    names = new Util.IntVector( 10 );
	}

	int getTemp() {
	    return dest.getTemp();
	}

	int getReg() {
	    return dest.getReg();
	}

	bool compareRHS( MTree t, MExpressionTable expressions ) {
	    if( !likeMe(t) ) {
		return false;
	    }

	    MPhi p = cast<MPhi>(t);
	    int l = names.Length;

	    if( l != p.names.Length ) {
		return false;
	    }
	    
	    for( int i = 0; i < l; i = i + 1 ) {
		if( names[i] != p.names[i] ) {
		    return false;
		}
	    }

	    return true;
	}

	set int TempName[int j] = n {
	    IO.Std.err.println( "MPhi set temp name #" + j + "," + n );
	    	   
	    names.lengthen(j+1);
	    names[j] = n;
	    IO.Std.err.println( "names is now: " + names );
	}

	get int TempName[int j] {
	    return names[j];
	}
	    
	bool isPhi() {
	    return true;
	}

	bool isCSE() {
	    return false;
	}

	bool clearIneffectivePhi( int s ) {
	    effective = false;

	    int l = names.Length;
	    for( int i = 0; i < l; i = i + 1 ) {
		if( names[i] != s ) {
		    effective = true;
		}
	    }

	    return effective;
	}

	String toString() {
	    StringBuffer b = new StringBuffer();
	    if( effective ) {
		b.append( "required " );
	    }
	    b.append( "T" );
	    b.append( temp );
	    b.append( "=phi(" );
	    int l = names.Length;

	    for( int i = 0; i < l; i = i + 1 ) {
		b.append( "T" + temp );
		b.append( '.' );
		b.append( names[i] );
		if( i < l-1 ) {
		    b.append( ' ' );
		}
	    }

	    b.append(')');

	    return b;
	}
    }


    class MData extends MTree {
	void init( int op, MTree left, MTree right ) {
	    super.init( op, null, left, right );
	}

	void init( int op, MTree left ) {
	    super.init( op, null, left, null );
	}

	void init( int op ) {
	    super.init( op, null, null, null );
	}

	void assignSegment( Util.Vector stack ) {
	    char quote = '"';
	    switch( op ) {
	    case Op.STATIC:
		stack.Top = "x_static_init," + quote + "ax" + quote;
	    case Op.UNWIND:
		stack.Top = "w_line_info," + quote + "a" + quote;
	    case Op.TEXT:
		stack.Top = ".text";
	    case Op.DATA:
		stack.Top = ".data";
	    case Op.RODATA:
		stack.Top = ".rodata";	    
	    case Op.PUSHSEG:
		// IO.Std.err.println( "pushseg..." );
		stack.add(null);
	    case Op.POPSEG:
		// IO.Std.err.println( "popseg..." );
		stack.pop();
		left = new MConst(cast<String>(stack.Top));
	    }
	}

	String toString() {
	    StringBuffer result = new StringBuffer();
	    result.append( opString(op) );
	    if( left != null ) {
		result.append( ' ' );
		if( op == Op.CONST_STR ) {
		    result.append( left.getByteList() );
		} else if( op == Op.CONST_CSTR ) {
		    String s = left.getByteList();
		    result.append( s );
		    if( s.getLength() > 0 ) {
			result.append(',');
		    }
		    result.append('0');
		} else {
		    result.append( left );                    
		}
	    }
	    if( right != null ) {
		result.append( ',' );
		result.append( right );
	    }
	    return result;
	}

	String dump() {
	    StringBuffer result = new StringBuffer();
	    result.append( "MData(" );
	    result.append( opString(op) );
	    if( left != null ) {
		result.append( ' ' );
		result.append( left.dump() );
	    }
	    if( right != null ) {
		result.append( ',' );
		result.append( right.dump() );
	    }
	    result.append( ')' );
	}
    }



    class MList extends MTree {
	void init( MTree left, MTree right ) {
	    super.init( Op.LIST, null, left, right );
	    // IO.Std.err.println( "new MList(" + left + "," + right + ") gives: " + this );
	}

	MTree flatten( MFlatten f ) {
	    // IO.Std.err.println( "flatten: " + this );
	    if( this == null ) {
		throw new Exception( "flatten null sequence" );
	    }

	    if( left != null ) {
		f.add( left );
	    }
	    if( right != null ) {
		f.add( right );
	    }
	    // IO.Std.err.println( "flatten list returns null" );
	    return null;
	}

	String toString() {
	    return "[" + left + "," + right + "]\n";
	}
    
	String dump() {
	    String sl = "<null>";
	    String sr = "<null>";
	    if( left != null ) {
		sl = left.dump();
	    }
	    if( right != null ) {
		sr = right.dump();
	    }
	    return "MList(" + sl + "," + sr + ")";
	}
    }

    class MSeq extends MTree {
	void init( MTree left, MTree right ) {
	    super.init( Op.SEQ, null, left, right );
	}

	get int Temp {
	    return right.Temp;
	}

	get int Reg {
	    return right.Reg;
	}

	set int Mode = mode {
	    right.Mode = mode;
	}

	MTree rset( MSet rset ) {
	    // IO.Std.err.println( "assigning register set " + setString(rset) + " to seq right: " + right );
	    right.rset(rset);
	    return this;
	}

	MTree flatten( MFlatten f ) {
	    if( this == null ) {
		throw new Exception( "flatten null sequence" );
	    }

	    // IO.Std.err.println( "flattening: " + this.dump() + " gives: " + right );

	    if( left != null ) {
		f.add( left );
	    }

//	    if( right == null ) {
//		throw new Exception( "flattening: " + this + " gives null result" );
//	    }
	    return right;
	}

	String toString() {
	    return "[" + left + "]" + right + "\n";
	}
    
	String dump() {
	    String sl = "<null>";
	    String sr = "<null>";
	    if( left != null ) {
		sl = left.dump();
	    }
	    if( right != null ) {
		sr = right.dump();
	    }
	    return "MSeq(" + sl + "," + sr + ")";
	}
    }

    class MTreatAs extends MTree {
	public MSet rset;
	
	void init( MTree left, MSet rset ) {
	    super.init(0,null,left,null);
	    this.rset = rset;
	}

	String toString() {
	    return left.toString(rset);
	}
    }

    class MReg extends MTree {
	public MSet rset;
	public int size;
	public int mode;
	public int temp;
	public int reg;

	void init( MSet rset ) {
	    this.init(0,rset);
	}

	void init( int t, MSet rset ) {
	    super.init(0, null, null, null);

	    this.rset = rset;
	    // IO.Std.err.println( "setting register set to " + Machine.getSetName(rset) + " for " + this + " from: " + new Exception("here"));
	    this.temp = t;
	    this.reg = 0;
	    this.size = Machine.WORD;
	    this.mode = Mode.READ;
	}

	void init( int r ) {
	    super.init(0, null, null, null);
	    this.temp = 0;
	    this.reg = r;
	    this.rset = MSet.None;
	    this.size = Machine.WORD;
	    // IO.Std.err.println( "setting register set to " + Machine.getSetName(rset) + " for " + this + " from: " + new Exception("here"));
	    this.mode = Mode.READ;
	}

	set int Mode = mode {
	    this.mode = mode;
	}

	set int Temp = temp {
	    this.temp = temp;
	}

	set int Size = size {
	    if( size == 0 ) {
		size = Machine.WORD;
	    }
	    this.size = size;
	}
    
	get int Temp {
	    return temp;
	}
    
	get int Reg {
	    return reg;
	}

	bool isReg() {
	    return true;
	}

	bool compareRHS( MTree t, MExpressionTable expressions ) {
	    bool result = t != null && Temp == t.Temp;
	    if( !result ) {
		if( Temp < Machine.FIRST_SOFT_REG || t.Temp < Machine.FIRST_SOFT_REG ) {
		    result = false;
		} else if( expressions.matchTemps( Temp, t.Temp ) ) {
		    IO.Std.err.println( "" + this + " does not match " + t + " directly but matches a copy" );
		    result = true;
		}
	    }

	    /*
	    if( t.isReg() ) {
		IO.Std.err.println( "compare temps: " + this + " versus " + t + "->" + result );
	    }
	    */
	    return result; 
	}

	MTree rset( MSet rset ) {
	    // noinline();
	    /*
	    if( this.rset != MSet.None && this.rset != rset && this.rset != MSet.Int8 && this.rset != MSet.Int4 && this.rset != MSet.Int1 ) {
		IO.Std.err.println( "setting register set to " + Machine.getSetName(rset) + " for " + this + " overwrites set " + Machine.getSetName(this.rset) );
	    }
	    */

	    this.rset = rset;
	    return this;
	}

	String toString() {
	    return toString(size);
	}

	String toString(int as_size) {
	    StringBuffer b = new StringBuffer();
	    if( reg != 0 ) {
		b.append( Machine.getRegName(reg,as_size) );
	    } else {
		b.append( 'T' );
		b.append( temp );
	    }

	    return b;
	}

	String dump() {
	    return "MReg(" + temp + ")";
	}

	void replaceTemp( int temp, int replace ) {
	    if( this.temp == temp ) {
		this.temp = replace;
	    }
	}

	void findOperands(Util.Vector v) {
	    addOperand(v,mode,reg,temp,rset,size,this);
	    // IO.Std.err.println( "MReg: find operands: " + v );
	}

	void calcFrameSize( MFrame m ) {
	    if( Machine.CALL_PRESERVE & (1 << reg) != 0 ) {
		m.seenCallPreserveRegister(reg);
		//	    } else if( reg == Machine.R_FRAME ) {
		//m.seenFramePointer();
	    } else if( reg == Machine.R_STACK ) {
		m.seenStack();
	    }
	}
	
	int hash() {
	    return temp;
	}	
    }


    class MArg extends MTree {
	void init( int op, MTree left, MTree right ) {
	    super.init(op, null, left, right);
	    // IO.Std.err.println( "init arg, left is: " + cast<int>(left) + ", right is " + cast<int>(right) );

	    if( left == null ) {
		throw new Exception( "arg has no left sub-tree" );
	    }

	    if( getRawOp() >= Op.PARAM0 && getRawOp() <= Op.PARAM5 ) {
		left.Mode = Mode.WRITE;
	    }
	}

	get int Temp {
	    return left.Temp;
	}
    
	get int Reg {
	    return left.Reg;
	}

	String toArgString() {
	    // IO.Std.err.println( "to arg string, left is: " + cast<int>(left) + ", right is " + cast<int>(right) );
	    StringBuffer b = new StringBuffer();
	    b.append( ' ' );
	    b.append( left.toString() );
	    b.append( ',' );

	    if( right != null ) { 
		b.append( right.toArgString() );
	    }

	    return b;
	}

	String toString() {
	    return opString(op) + toArgString();
	}

	String dump() {
	    return "MArg(" + opString(op) + " " + toArgString() + ")";
	}
    }

    /*
    class MParam extends MTree {
	void init( int op, MTree left ) {
	    super.init(op, null, left, null);
	    left.setMode( Mode.WRITE );
	}

	int getTemp() {
	    return left.getTemp();
	}
    
	int getReg() {
	    return left.getReg();
	}

	String toString() {
	    return opString(op) + " " + left;
	}

	String dump() {
	    return "MParam(" + opString(op) + " " + left.dump() + ")";
	}
    }
    */

    class MDivide extends MTree {
	void init( int op, MTree dest, MTree left, MTree right ) {
	    super.init( op, dest, left, right );

	    if( RawOp == Op.DIV ) {
		right.Mode = Mode.WRITE;
		dest.Mode = Mode.READ | Mode.WRITE;
	    } else {
		dest.Mode = Mode.WRITE;
	    }
	}

	get int Temp {
	    return left.Temp;
	}
    
	get int Reg {
	    return left.Reg;
	}

        void markLive( int u, MBitSet seen, MBitSet[] matrix ) {
	    if( RawOp == Op.MOD && matrix != null ) {
		int d, l, r;
		d = dest.Temp;
		l = left.Temp;
		r = right.Temp;
		// IO.Std.err.println( "mod: force adjacent: T" + d + ",T" + l + "," + r );

		matrix[left.Temp].mark(right.Temp);
		matrix[left.Temp].mark(dest.Temp);
		matrix[dest.Temp].mark(right.Temp);
	    }
	}
	/*
	bool dontCoalesce() {
	    return true;
	}
	*/

	String toString() {
	    // IO.Std.err.println( "op string " + op + " is " + opString(op) );

	    if( getRawOp() != Op.MOD ) {
		return opString(op) + " " + left + " # div " + dest + "," + right;
	    } else {
		return opString(op) + " " + right + " # mod " + dest + "," + left;
	    }
	}

	String dump() {
	    return "MDivide(" + opString(op) + " " + right.dump() + "," + left.dump() + ")";
	}
    }

    // 2 address operation. reads left and right. updates left
    class MA2 extends MTree {
	void init( int op, MTree left, MTree right ) {
	    super.init( op, null, left, right );
	    left.Mode = Mode.READ | Mode.WRITE;
	}
    
	get int Temp {
	    return left.Temp;
	}
    
	get int Reg {
	    return left.Reg;
	}

	bool writesMemory() {
	    return left.isMemory();
	}

	String toString() {
	    int rop = RawOp;
	    // IO.Std.err.println( "rop: " + rop + " versus: " + Op.ADD + "/" + Op.SUB );
	    // IO.Std.err.println( "==1: " + right.isConstantOne() + ", ==-1: " + right.isConstantMinusOne() );

	    if( (rop == Op.ADD2 || rop == Op.SUB2) &&
		(right.isConstantOne() || right.isConstantMinusOne()) ){

		int s = getSize();
		char suffix;
		if( s == 1 ) {
		    suffix = 'b';
		} else if( s == 4 ) {
		    suffix = 'l';
		} else if( s == 8 ) {
		    suffix = 'q';
		}

		String os;
		if( rop == Op.ADD2 ) {
		    if( right.isConstantOne() ) {
			// IO.Std.err.println( "op add const 1 => inc" );
			os = "inc";
		    } else {
			// IO.Std.err.println( "op add const -1 => dec" );
			os = "dec";
		    }
		} else {
		    if( right.isConstantOne() ) {
			// IO.Std.err.println( "op sub const 1 => dec" );
			os = "dec";
		    } else {
			// IO.Std.err.println( "op sub const -1 => dec" );
			os = "inc";
		    }
		}

		return os + suffix + " " + left;
		//} else {
		// IO.Std.err.println( "not increment: " + left + "+=" + right );
	    }

	    if( rop == Op.SHL || rop == Op.SHAR ) {
		right.setSize(1);
	    }

	    return opString(op) + " " + right + "," + left;
	}

	String dump() {
	    return "MA2(" + opString(op) + " " + right.dump() + "," + left.dump() + ")";
	}
    }

    // 1 address operation. reads left
    class MA1 extends MTree {
	void init( int op, MTree left ) {
	    super.init( op, null, left, null );
	    left.Mode = Mode.READ | Mode.WRITE;
	}
    
	get int Temp {
	    return left.Temp;
	}
    
	get int Reg {
	    return left.Reg;
	}
    
	String toString() {	   
	    return opString(op) + " " + left;
	}

	String dump() {
	    return "MA1(" + opString(op) + " " + left.dump() + ")";
	}
    }

    class MU2 extends MTree {
        void init( int op, MTree dest, MTree left ) {
	    super.init( op, dest, left, null );
	    dest.Mode = Mode.WRITE;
	    left.Mode = Mode.READ;
	}

	get int Temp {
	    return dest.Temp;
	}

	get int Reg {
	    return dest.Reg;
	}

	bool needRegen() {
	    return true;
	}

	String toString() {
	    return opString(op) + " " + left + "," + dest;
	}

	String dump() {
	    return "MU2(" + opString(op) + " " + left + "," + dest + ")";
	}
    }

    class MA0 extends MTree {
	void init( int op ) {
	    super.init( op, null, null, null );
	}

	bool isEnterLoop() {
	    return op == Op.ENTER_LOOP;
	}

	bool isLeaveLoop() {
	    return op == Op.LEAVE_LOOP;
	}
    
	String toString() {
	    return opString(op);
	}

	String dump() {
	    return "M0(" + opString(op) + ")";
	}
    }

    class MBase extends MTree {
	void init( int op, MTree offset, MTree base ) {
	    super.init(op, null, offset, base);
	}

	get MTree Offset {
	    return left;
	}

	get MTree Base {
	    return right;
	}

	String toString() {
	    if( left != null ) {
		return "BASE[" + left.toString() + "+" + right + "]";
	    } else {
		return "BASE[" + left.toString() + "]";
	    }
	}

	String dump() {
	    return "MBase(" + left + "+" + right + ")";
	}

	void calcFrameSize( MFrame m ) {
	    // IO.Std.err.println( "calc frame size for: " + this );
	    if( right != null && right.getReg() == 7 ) {
		// IO.Std.err.println( "seen indirect through frame pointer. frame offset: " + left );
		m.seenFrameAccess( left.getInt() );
	    }
	}

	void adjustFrameOffset( MAdjustFrameOffset m ) {
	    if( right != null && right.getReg() == 7 ) {
		m.adjustFrameOffset( left );
	    }
	}
    }

    class MIndex extends MTree {
	void init( int op, MTree index, MTree scale ) {
	    super.init(op, null, index, scale);
	}

	get MTree Index {
	    return left;
	}

	get MTree Scale {
	    return right;
	}

	String toString() {
	    return "INDEX[" + left + "," + right + "]";
	}

	String dump() {
	    return "MIndex(" + left + "*" + right + ")";
	}
    }

    class MAddress extends MTree {
	void init(MTree base, MTree index ) {
	    super.init(Op.ADD | ITree.getSizeMask(Machine.WORD), null, base, index);
	    /*
	    if( index != null ) {
		// check left operand is MBase:
		MBase b = cast<MBase>(base);
	    }
	    */

	    /*
	    MBase b;
	    try {
		b = cast<MBase>(left);
	    } catch( System.CastException ce1 ) {
		if( right != null ) {
		    IO.Std.err.println( "left is: " + left );
		    IO.Std.err.println( "left class is: " + left.getClass() );
		    throw new Exception( "cannot have index with non base left hand side in address: " + this.dump() );
		} else {
		    return;
		}
	    }
	    */
	}

	String toString() {
	    String offset = "";
	    String base = "";
	    String index = "";
	    String scale = "";

	    MBase b;
	    MIndex i;

	    /*
	    IO.Std.err.println( "MIndex, size: " + Size );

	    if( left != null ) {
		IO.Std.err.println( "left, size: " + left.Size );
	    }

	    if( right != null ) {
		IO.Std.err.println( "right, size: " + right.Size );
	    }
	    */

	    try {
	      	b = cast<MBase>(left);
	    } catch( System.CastException ce1 ) {
		b = null;

		base = left.toString();

		if( right != null ) {
		    // IO.Std.err.println( "left is: " + left );
		    // IO.Std.err.println( "left class is: " + left.getClass() );
		    offset = base;
		    base = "";
		} else {
		    return base;
		}
	    }

	    i = cast<MIndex>(right);

	    if( b != null ) {
		if( b.left != null ) {
		    offset = b.left.toString();
		}
		if( b.right != null ) {
		    base = b.right.toString();
		}
	    }

	    if( i != null ) {
		if( i.left != null ) {
		    index = i.left.toString();
		}
		if( i.right != null ) {
		    scale = i.right.toString();
		}
	    
		return offset + "(" + base + "," + index + "," + scale + ")";
	    } else {
		return offset + "(" + base + ")";
	    }
	}

	String dump() {
	    return "MAddress(" + left + "+" + right + ")";
	}
    }

    class MLea extends MA2 {
	void init( MTree left, MTree right ) {
	    super.init( Op.LEA, left, right );
	    left.Mode = Mode.WRITE;
	}

	String toString() {
	    return "lea " + right + "," + left;
	}

	String dump() {
	    return "MLea(" + left + "=" + right + ")";
	}
    }


    class MReloc extends MTree {
	void init( int op, MTree left, MTree right ) {
	    super.init(op,null,left,right);
	}
    
	String toString() {
	    String op_string;
	    switch( getRawOp() ) {
	    case Op.ADD:
		op_string = "+";
	    case Op.SUB:
		op_string = "-";
	    default:
		throw new Exception( "unknown relocation operation: " + opString(op) );
	    }
	    return left.toString() + op_string + right.toString();
	}

	String dump() {
	    return "MReloc(" + right.dump() + opString(op) + left.dump() + ")";
	}
    }

    // binary operation. reads left and right. result is (may be) a register
    class MB extends MTree {
	void init( int op, MTree left, MTree right ) {
	    super.init(op,null,left,right);
	}
    
	String toString() {
	    return opString(op) + ' ' + right + ',' + left;
	}

	String dump() {
	    return "MB(" + right.dump() + opString(op) + left.dump() + ")";
	}
    }

    class MJump extends MTree {
	void init( int op, MTree left, MTree right ) {
	    super.init( op, null, left, right );
	}

	String toString() {
	    if( left != null ) {
		return opString(op) + ' ' + right + " # " + left;
	    } else {
		return opString(op) + ' ' + right;
	    }
	}

	String dump() {
	    if( left != null ) {
		return "Jump(" + opString(op) + ' ' + right.dump() + ',' + left.dump() + ")";
	    } else {
		return "Jump(" + opString(op) + ' ' + right.dump() + ")";
	    }
	}

	bool isJump() {
	    return true;
	}

	bool isUnconditionalJump() {
	    return op == Op.JUMP;
	}

	bool equals( Object o ) {
	    IO.Std.err.println( "MTree compare: " + this );
	    IO.Std.err.println( "MTree to:      " + o );
	    /*
	    if( !likeMe(o) ) {
		IO.Std.err.println( "not an MTree" );
		return false;
	    }
	    */

	    MTree t = cast<MTree>(o);

	    if( op != t.op ) {
		IO.Std.err.println( "ops differ" );
		return false;
	    }

	    /*
	    if( !Object.equals(dest, t.dest) ) {
		IO.Std.err.println( "dests differ" );
	    }
	    */

	    if( left == null && t.left != null ) {
		IO.Std.err.println( "left differ" );
		return false;
	    } else if( left != null && !left.equals(t.left) ) {
		IO.Std.err.println( "left differ" );
		return false;
	    }

	    if( right == null && t.right != null ) {
		IO.Std.err.println( "right differ" );
	    } else if( right != null && !right.equals(t.right) ) {
		IO.Std.err.println( "right differ" );
		return false;
	    }

	    return true;
	    /*
	    return op == t.op &&
		Object.equals(dest, t.dest) &&
		Object.equals(left, t.left) &&
		Object.equals(right, t.right);
	    */
	}

	get String Label {
	    return right.Label;
	}
    }

    class MDecBranchNotNeg extends MJump {
	void init( int op, MTree left, MTree right ) {
	    super.init( op, left, right );
	    left.Mode = Mode.READ | Mode.WRITE;
	    IO.Std.err.println( "created MDecBranchNotNeg tree: " + left + "," + right );
	}

	String toString() {
	    IO.Std.err.println( "to string MDecBranchNotNeg tree..." );
	    int s = Size;
	    /* if( left.isReg() && left.getReg() == Machine.R_ECX && s == Machine.WORD ) {
		IO.Std.err.println( "left is RCX - can use loop instruction" );
		return opString(op);
		} else { */
	    // IO.Std.err.println( "left is not CX - cannot use loop instruction" );
		String r;
		if( s == 8 ) {
		    r = "decq ";
		} else if( s == 4 ) {
		    r = "decl ";
		} else if( s == 1 ) {
		    r = "decb ";
		} else {
		    throw new Exception( "unexpected operation size: " + s );
		}
		String result = r + left + "; jge " + right;
		IO.Std.err.println( "returning: " + result );
		return result;
		// }
	}
    }

    class MCall extends MTree {
	void init( int op, MTree dest, MTree left ) {
	    super.init( op, dest, left, null );
	    if( left.toString().equals( "$0" ) ) {
		IO.Std.err.println( "created: " + this + " from " + new Exception("arse") );
	    }

	    if( dest != null ) {
		dest.Mode = Mode.WRITE;
	    }
	}

	String toString() {
	    if( op == Op.DYNAMIC_CALL ) {
		if( dest != null ) {
		    return "call *" + left + " # result in " + dest;
		} else {
		    return "call *" + left + " # discard result";
		}
	    } else if( op == Op.STATIC_CALL ) {
		String result = "";
		
		// FIXME: var args expects zero in rax:
		if( left.toString().equals("printf") && Machine.WORD == 8 ) {
		    result = "xorq %rax,%rax; ";		    
		}

		if( dest != null ) {
		    result = result + "call " + left + " # result in " + dest;
		} else {
		    result = result + "call " + left + " # discard result";
		}

		return result;
	    } else if( op == Op.PROC_CALL ) {
		if( dest != null ) {
		    return "call *0(" + left + ") # result in " + dest;
		} else {
		    return "call *0(" + left + ") # discard result";
		}
	    }
	}

	void calcFrameSize( MFrame m ) {
	    m.seenStack();
	    m.seenCall();
	}

	bool isCall() {
	    return true;
	}

	bool compareRHS( MTree t ) {
	    return false;
	}
    }

    class MCompare extends MTree {
	void init( int op, MTree dest, MTree left, MTree right ) {
	    super.init(op,dest,left,right);
	    dest.Mode = Mode.WRITE;
	}

	get int Temp {
	    return dest.Temp;
	}

	get int Reg {
	    return dest.Reg;
	}

	bool isCSE() {
	    return true;
	}

	bool compareRHS( MTree t, MExpressionTable expressions ) {
	    bool result = super.compareRHS(t, expressions);

	    IO.Std.err.println( "CSE compare: compareRHS: " + this );
	    IO.Std.err.println( "versus:                  " + t );
	    IO.Std.err.println( "result: " + result );

	    return result;
	}
    
	String toString() {
	    return opString(op) + ' ' + right + ',' + left + " # " + dest;
	}
    
	String dump() {
	    return "Compare(" + dest.dump() + " " + opString(op) + " " + left.dump() + "," + right.dump() + ")";
	}
    }
	    

    // 3 address operation. reads left and right, writes dest
    class MA3 extends MTree {
	void init( int op, MTree dest, MTree left, MTree right ) {
	    super.init(op,dest,left,right);
	    dest.Mode = Mode.WRITE;
	    left.Mode = Mode.READ;
	    right.Mode = Mode.READ;
	}

	get int Temp {
	    return dest.Temp;
	}

	get int Reg {
	    return dest.Reg;
	}

	String toString() {
	    return opString(op) + ' ' + right + ',' + left + ',' + dest;
	}
    
	String dump() {
	    return "M3(" + dest.dump() + " " + opString(op) + " " + left.dump() + "," + right.dump() + ")";
	}
    }

    // 3 address operation. reads left and right, writes dest. not executable directly by target
    class MU3 extends MA3 {
	void init( int op, MTree dest, MTree left, MTree right ) {
	    super.init(op,dest,left,right);
	}

	bool needRegen() {
	    return true;
	}

	bool isCSE() {
	    bool result = super.isCSE();

	    IO.Std.err.println( "CSE three address isCSE: " + this );
	    IO.Std.err.println( "can CSE: " + result );

	    return result;
	} 

	bool compareRHS( MTree t, MExpressionTable expressions ) {
	    bool result = super.compareRHS(t, expressions);

	    IO.Std.err.println( "CSE three address: compareRHS: " + this );
	    IO.Std.err.println( "versus:                        " + t );
	    IO.Std.err.println( "result: " + result );

	    return result;
	}
    }

    class MMove extends MTree {
	void init( int op, MTree dest, MTree source ) {
	    super.init(op,dest,source,null);

	    if( op == RawOp ) {
		throw new Exception( "creating MMove with zero size operation: " + op );
	    }
	    if( source == null ) {
		throw new Exception( "creating MMove with null source: " + opString(op) + " " + dest );
	    }
	    if( dest == null ) {
		throw new Exception( "creating MMove with null source: " + opString(op) + " " + left );
	    }
	    dest.Mode = Mode.WRITE;

	    // IO.Std.err.println( "mmove: " + this + "from " + new System.Backtrace() );
	}
    
	get int Reg {
	    return dest.Reg;
	}
    
	get int Temp {
	    return dest.Temp;
	}

	bool isCopy() {
	    return RawOp == Op.COPY;
	}

	bool isCSE() {
	    return true;
	}

	String toString() {
	    /*
 	    // xor trashes flags, which is a bloody nuisence

	    if( isCopy() && dest.isReg() && left.isConstantZero() ) {
		// not any faster in cycles but saves decode bandwidth as move immediate is several bytes longer:
		return "xor " + dest + "," + dest;
	    }
	    */

	    int o = RawOp;

	    if( o >= Op.CAST_FROM1 && o <= Op.CAST_FROM8 ) {
		if( op == Op.CAST_FROM1_4 || op == Op.CAST_FROM1_8 ) {
		    left.Size = 1;
		} else if( op == Op.CAST_FROM4_8 ) {
		    left.Size = 4;
		}

	    }
	    return opString(op) + ' ' + left + ',' + dest;
	}

	String dump() {
	    if( dest == null ) {
	        IO.Std.err.println( "dest is null" );
	    } else if( left == null ) {
		IO.Std.err.println( "left is null" ) ;
	    }
	    return "MMove(" + left.dump() + ',' + dest.dump() + ")";
	}
    }


    class MCondSet extends MTree {
	void init( int op, MTree dest, MTree source ) {
	    super.init(op,dest,source,null);
	    if( source == null ) {
		throw new Exception( "creating MMove with null source: " + opString(op) + " " + dest );
	    }
	    if( dest == null ) {
		throw new Exception( "creating MMove with null source: " + opString(op) + " " + left );
	    }
	    dest.Mode = Mode.WRITE;
	}
    
	get int Reg {
	    return dest.Reg;
	}
    
	get int Temp {
	    return dest.Temp;
	}
    
	String toString() {
	    return opString(op) + ' ' + dest + " # " + left;
	}

	String dump() {
	    if( dest == null ) {
	        IO.Std.err.println( "dest is null" );
	    } else if( left == null ) {
		IO.Std.err.println( "left is null" ) ;
	    }
	    return "MMove(" + left.dump() + ',' + dest.dump() + ")";
	}
    }

    class MIndirect extends MTree {
	void init( MTree left ) {
	    super.init(0,null,left,null);
	    // IO.Std.err.println( "init indirect: " + left + "/" + this.left );
	}
    
	String toString() {
	    // not strictly right but each memory reference generally should only be converted to a string once when
	    // code is written to assembler file:
	    MInst.indirect_number = MInst.indirect_number + 1;

	    return left.toString();
	}

	String dump() {
	    return "MIndirect(" + left.dump() + ")";
	}

	bool compareRHS( MTree t, MExpressionTable expressions ) {
	    return compareRHS(left, t.Left, expressions);
	}

	bool isMemory() {
	    return true;
	}
    }


    class MGlobal extends MTree {
	String name;
    
	void init( String name ) {
	    super.init(0,null,null,null);
	    this.name = name;
	}

	String toString() {
	    return name;
	}

	String toContents() {
	    return name;
	}

	get String Value {
	    return name;
	}

	String dump() {
	    return "MGlobal(" + name + ")";
	}
    }

    class MImmediate extends MTree {
	protected String value;

	void init( String value ) {
	    super.init(0,null,null,null);
	    this.value = value;
	}

	void init( int value ) {
	    init( "" + value );
	}

	String toString() {
	    return "$" + value;
	}

	get String Label {
	    return value;
	}

	get String Value {
	    return value;
	}

	bool isConstantZero() {
	    // IO.Std.err.println( "is constant 0: " + value + "?" );
	    return String.equals("0",value);
	}

	bool isConstantOne() {
	    // IO.Std.err.println( "is constant 1: " + value + "?" );
	    return String.equals("1",value);
	}

	bool isConstantMinusOne() {
	    // IO.Std.err.println( "is constant -1: " + value + "?" );
	    return String.equals("-1",value);
	}	

	String dump() {
	    return "MImmediate(" + value + ")";
	}
    }

    class MConst extends MTree {
	protected String value;

	void init( String value ) {
	    super.init(0,null,null,null);
	    this.value = value;
	}

	void init( int value ) {
	    init( "" + value );
	}

	String toString() {
	    return value;
	}

	set String Value = v {
	    value = v;
	}

	set int Value = v {
	    value = "" + v;
	}

	get String Label {
	    return value;
	}

	get int Int {
	    return value.parseInt();
	}

	bool isConstantZero() {
	    IO.Std.err.println( "is constant 0: " + value + "?" );
	    return String.equals("0",value);
	}

	bool isConstantOne() {
	    IO.Std.err.println( "is constant 1: " + value + "?" );
	    return String.equals("1",value);
	}

	bool isConstantMinusOne() {
	    IO.Std.err.println( "is constant -1: " + value + "?" );
	    return String.equals("-1",value);
	}	

	get String Value {
	    return value;
	}

	String dump() {
	    return "MConst(" + value + ")";
	}
    }

    class MLabel extends MTree {
	String value;
 
	void init( int op, String value ) {
	    super.init(op,null,null,null);
	    this.value = value;
	}

	String toString() {
	    return this.value + ":";
	}

	String dump() {
	    return "MLabel(" + value + ")";
	}

	bool isLabel() {
	    return op == Op.LABEL;
	}

	get String Label {
	    return value;
	}

	get String Value {
	    return value;
	}
    }

    class MFindOperands extends MTreeWalker {
	public Util.Vector result;
	void init() {
	    super.init();
	    result = new Util.Vector();
	}

	void process( MTree m ) {
	    if( m.Operation == Op.DYNAMIC_CALL ) {
		m.dump();
	    }
		    

	    m.findOperands(result);
	}
    }

    class MReplaceTemp extends MTreeWalker {
	int temp;
	int replace;

	void init( int temp, int replace ) {
	    super.init();

	    this.temp = temp;
	    this.replace = replace;
	}

	void process( MTree m ) {
	    // IO.Std.err.print( "flattening: " + m + "\ngives: " );
	    m.replaceTemp( temp, replace );
	    // if( result != null ) {
	    // IO.Std.err.println( result );
	    // } else {
	    // 	IO.Std.err.println( "null from: " + new Exception("X") );
	    // }
	}
    }

    class MFlatten extends MTreeWalker {
	Util.Vector list;
	ITree itree;

	void init(ITree t) {
	    super.init();
	    list = new Util.Vector();
	    itree = t;
	}

	MTree rewrite( MTree m ) {
	    // IO.Std.err.print( "flattening: " + m + "\ngives: " );
	    MTree result = m.flatten( this );
	    // if( result != null ) {
	    // IO.Std.err.println( result );
	    // } else {
	    // 	IO.Std.err.println( "null from: " + new Exception("X") );
	    // }
	    if( result != null ) {
		result.setITree( itree );
	    }
	    return result;
	}

	void add( MTree t ) {
	    t.setITree( itree );
	    list.add( t );
	}

	void dump( Util.Vector v ) {
	    foreach( MTree t; list.elements() ) {
		// IO.Std.err.println( t );
		v.add( t );
	    }
	}

	String toString() {
	    StringBuffer result = new StringBuffer();
	    foreach( MTree t; list.elements() ) {
		result.append( t );
	    }
	    return result;
	}
    }
}
