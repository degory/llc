// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import stream;
import sort;
import vector;
import intvector;
import machine;
import mbitset;

namespace Gen {

    // Thrown if back end cannot compile intermediate code - usually because register allocation
    // failed. Front end can catch this and retry with less complex code:
    class RegisterException extends System.Exception {
	int temp;
	bool in_memory;

	void init( System.String s, int t, bool m ) {
	    super.init( s );
	    temp = t;
	    in_memory = m;
	}

	void init( System.String s ) {
	    init( s, 0, false );
	}

	public int getTemp() {
	    return temp;
	}

	public bool getInMemory() {
	    return in_memory;
	}
    }


    // How is an operand used - values are or'd together
    class Mode {
	public static int
	    READ = 1,              // this operand's temporary is read by this instruction
	    WRITE = 2,             // this operand's temporary operand is written by this instruction
	    READ_WRITE = 3,        // this operand's temporary is read and then written by this instruction
	    FINAL = 4,             // this operand's temporary will not be used after this reference
	    REDUNDANT = 8,
	    MASK_USE = 7;
    }

    // table of available values for common sub-expression elimination - not currently used:
    class MExpressionTable extends System.Object {
	Util.Vector expressions;

	void init() {
	    expressions = new Util.Vector(20);
	}

	void clear() {
	    expressions.Length = 0;
	}

	void killTemp( int t ) {
	    Util.Vector v = new Util.Vector(expressions.Length);
	    foreach( MInst u; expressions.elements() ) {
		if( !u.readsTemp( t ) ) {
		    v.add( u );
		} else {
		    IO.Std.err.print( "kill read T" + t + ": " + u );
		}
	    }
	    expressions = v;
	}

	void killMemory() {
	    Util.Vector v = new Util.Vector(expressions.Length);
	    foreach( MTree u; expressions.elements() ) {
		if( !u.readsMemory() ) {
		    v.add( u );
		} else {
		    IO.Std.err.print( "kill read memory: " + u );
		}
	    }
	    expressions = v;
	}

	bool matchTemps( int t, int u ) {
	    foreach( MTree v; expressions.elements() ) {
		if( v.Left.isCopy() ) {
		    MTree l, r;
		    l = v.Left.Dest;
		    r = v.Left.Left;

		    if( l.isReg() && r.isReg() ) {
			// IO.Std.err.print( "check copy: " + v );

		    
			if( l.Temp == u && r.Temp == t ) {
			    // IO.Std.err.println( "AAA T" + t + " matches T" + u );				 
			    return true;
			} /*else if( l.Temp == t && r.Temp == u ) {
			    IO.Std.err.println( "BBB T" + t + " matches T" + u );
			    return true;
			    } */
		    }
		}
	    }

	    return false;
	}

	int findExpression( MInst rhs ) {
	    foreach( MInst v; expressions.elements() ) {
		IO.Std.err.print( "CSE cached: " + v );
	    }
	    // IO.Std.err.print( ">>>>find expression instruction: " + rhs );
	    foreach( MInst u; expressions.elements() ) {
		IO.Std.err.print( "CSE compare:" + rhs );
		IO.Std.err.print( "CSE versus: " + u );

		if( u.compareRHS(rhs, this) ) {
		    IO.Std.err.println( "CSE match writes: T" + u.WrittenTemp );
		    return u.WrittenTemp;
		}
	    }	    
	    // IO.Std.err.println( ">>>>no match" );
	    return 0;
	}

	bool add( MNode into, MInst i ) {
	    bool result = false;
	    bool can_cache = i.isCSE();

	    int r;

	    if( can_cache ) {
		r = findExpression( i );
	    }

	    int l;

	    if( r > 0 ) {
		IO.Std.err.println( "CSE potential common sub expression: T" + r + " from: " + i );
	    }

	    if( i.writesMemory() ) {
		// IO.Std.err.println( "XXXX writes to memory: kill instructions that read memory" );
		killMemory();
	    } 

	    l = i.killWritten( this );

	    // l = i.WrittenTemp;
	    /*
	    if( l > 0 ) {
		IO.Std.err.println( "XXXX writes to T" + l + ": killing instructions that read this temp" );
		killTemp( l );
		if( i.readsTemp(l) ) {
		    IO.Std.err.println( "reads written temp, do not cache" );
		    l = 0;
		}
	    }
	    */
	    
	    /*
	    if( i.Left.isCopy() ) {
		MTree tl, tr;
		tl = i.Left.Dest;
		tr = i.Left.Left; 
		if( tl.isReg() && tr.isReg() ) {
		    r = 0;
		    IO.Std.err.println( "not replacing copy T" + tl.Temp + "<-" + tr.Temp );
		}
	    }
	    */

	    if( r > 0 && l > 0 ) {
		IO.Std.err.println( "CSE instruction calculates a cached expression for T" + l + ", substitute T" + r );

		if( i.Left.isCopy() && i.Left.Dest.isReg() && i.Left.Left.isReg() ) {
		    IO.Std.err.print( "CSE might be replacing a copy with a copy: " + i );
		    IO.Std.err.println( "XXXXXX: versus new copy T" + l + "<-" + r );

		    if( i.Left.Dest.Temp == l && i.Left.Dest.Temp == r ) {
			IO.Std.err.println( "XXXXXX: no point in replacing" );
		    }
		}


		if( !i.Left.isCopy() || !i.Left.Dest.isReg() || !i.Left.Left.isReg() ||
		    i.Left.Dest.Temp != l || i.Left.Left.Temp != r ) {
				
		    i.makeCopy( into, i.Left.Size, l, r );
		    System.String s = i.toString();
		    i.makeComment( " SS CSE " + s.substring(0,s.getLength()-1) );		
		    
		    // cache the copy:
		    i = new MInst( new MMove( Op.COPY | ITree.getSizeMask(Machine.WORD), new MReg( l, MSet.General ), new MReg( r, MSet.General ) ) );
		    i.initOperands();
		    
		    // l = 0; // do not cache
		    result = true;
		} else {
		    IO.Std.err.println( "resulting copy would be the same as existing instruction T" + l + "<-T" + r );
		    IO.Std.err.print( i );
		}
	    }

	    if( l > 0 && can_cache ) {
		IO.Std.err.print( "instruction writes T" + l + ", cache it: " + i );
		expressions.add( i );
	    }

	    return result;
	}
    }

    // represents a temporary referenced by a particular instruction
    class MOperand extends System.Object {
	public int mode;    // how is this temporary used?
	public int reg;     // what register is this temporary in for this instruction (0 == not yet assigned)
	public int ssa_write;  // SSA number for temporary if written 
	public int ssa_read;   // SSA number for temporary if read
	public int temp;    // temporary referenced by this operand
	public MSet rset;   // what sort of register should be assigned to this reference
	public int size;    // what size is this reference in bytes (FIXME: is this still used anywhere?)
	public MReg[] mr;   // link to MReg(s) for this operand in the instructions machine code tree

	void init( int mode, int reg, int temp, MSet rset, int size, MReg r ) {
	    super.init();
	    this.mode = mode;
	    this.reg = reg;
	    this.temp = temp;
	    this.rset = rset;
	    this.mr = new MReg[3];
	    add(r);
	}

	// add a link to an MReg in this instruction's machine code tree
	void add(MReg r) {
	    // find free slot:
	    for( int i = 0; i < mr.length; i = i + 1 ) {
		if( mr[i] == null ) {
		    // copy the link:
		    mr[i] = r;
		    return;
		}
	    }

	    throw new System.Exception( "too many references (" + i + ") to operand: " + this );
	}

	static System.String setString(MSet s) {	    
	    return Machine.getSetName(s);
	}

	// set the FINAL bit in this operand's mode if this is the last use of the operand before the
	// end of the method or a following definition. seen[this.temp] will be set if we've seen a
	// subsequent use working backwards though each node in the control flow graph
        void calcFinal( MBitSet seen ) {
            // IO.Std.err.print( "calc final: " + this );
            mode = mode & Mode.READ_WRITE;
            int t = temp;

	    // if no temporary set
            if( t == 0 ) {
		// use register instead
		// FIXME: does anything care about final uses of fixed registers?
                t = reg;
            }

            if( t != 0 && mode != 0 ) {
                if( mode == Mode.READ ) {
                    if( !seen[t] ) {
                        // IO.Std.err.println( "Final READ: " + this );
                        mode = mode | Mode.FINAL;
                        seen.mark(t);
                    }
                } else if( mode == Mode.WRITE ) {
                    if( !seen[t] ) {
			// IO.Std.err.println( "Final WRITE: " + this );
                        mode = mode | Mode.FINAL;
		    } else {
                        seen.clear( t );
                    }
                } else if( mode == Mode.READ_WRITE ) {
                    if( !seen[t] ) {
                        // IO.Std.err.println( "Final READ-WRITE: " + this );
                        mode = mode | Mode.FINAL;
                        seen.mark( t );
                    }
		    // } else {                                                                                                                                        
                    // IO.Std.err.println( "Not Final: " + this ); 
                }
                // } else {                                                                                                                                           
                // IO.Std.err.println( "No mode or no temp: " + this );                                                                                               
            }
            // IO.Std.err.println( "calc final done" );                                                                                                               
        }

	// add this temporary to the live temporary set and optionally update the interference graph
	// if this temporary reference is a definition:
        void markLive( MBitSet live, MBitSet[] matrix ) {
            if( mode & Mode.MASK_USE != 0 ) {
                int t = temp;
                if( t == 0 ) {
                    t = reg;
                }
		// fixClobber creates temporaries so t may be off end of live

		/*
		int r = reg;
		if( r == 0 ) {
		    r = Machine.singleReg( rset );
		    if( r != 0 ) {
			IO.Std.err.println( "single reg temporary T" + t + " in R" + r );
		    }
		}
		*/

		// IO.Std.err.println( "mark live: " + this );

                if( t != 0 && t < live.getLength() ) {

		    // is this a definition of t and is t not currently live?
		    if( mode & Mode.WRITE != 0 && !live[t] ) {
			// note that t is now live:
			live.mark( t );
			//IO.Std.err.print( "T" + t + ": " );
			if( matrix != null ) {
			    // all live temporaries interfere with t. note, t also
			    // interferes with all live temporaries but we don't record that
			    // here as it's inefficient compared to MBitSet.or
			    // instead we do it once, at the end:
			    matrix[t].or(live);

			    /*
			    for( int i = 0; i < live.getLength(); i = i + 1 ) {
				if( live.get(i) ) {
				    // IO.Std.err.println( "T" + i + " " );
				    matrix[i].set(t);
				}
			    }
			    */
			}
		    }
		    // IO.Std.err.println();
                }

                if( reg != 0 ) {
                    live.mark( reg );
		}
            }
        }

	void markDead( MBitSet live ) {
	    // if this is a final use of this operand's temporary then remove it from the set of live
	    // temporaries:
	    if( mode & Mode.FINAL != 0 ) {
		if( temp != 0 ) {
		    live.clear( temp );
		}
		if( reg != 0 ) {
		    live.clear( reg );
		}
	    }
	}

	void reset() {
	    // clear this operand back to it's initial state:

	    // IO.Std.err.println( "reset T" + temp + " in R" + reg );

	    // if this is a temporary and not a fixed register then:
	    if( temp != 0 ) {
		// clear any assigned register here:
		// IO.Std.err.println( "clear reg" );
		reg = 0;

		// and in the associated machine code tree:
		for( int i = 0; mr[i] != null; i = i + 1 ) {
		    // IO.Std.err.println( "clear mreg: " + mr[i] );
		    mr[i].reg = 0;
		    // IO.Std.err.println( "mreg now: " + mr[i] );
		}
	    }

	    // clear the final use flag:
	    mode = mode & ~Mode.FINAL;
	    // IO.Std.err.println( "mode now: " + mode );
	}

	void assignRegister( int[] regs ) {
	    if( reg == 0 ) {
		reg = regs[temp];
		for( int i = 0; mr[i] != null; i = i + 1 ) {
		    mr[i].reg = reg;
		}
	    }
	}

	System.String toString() {
	    System.StringBuffer b = new System.StringBuffer();
	    b.append( "[" );
	    if( temp != 0 ) {
		b.append( "T" + temp );
		if( ssa_read != 0 ) {
		    b.append( '.' );
		    b.append( ssa_read );
		}
		if( ssa_write != 0 ) {
		    b.append( '.' );
		    b.append( ssa_write );
		}
		if( reg != 0 ) { 
		    b.append( '/' );
		}
	    }
	    if( reg != 0 ) {
		b.append( "R" + reg );
	    }
	    b.append( ':' );
	    b.append( setString(rset) );
	    if( mode != 0 ) {
		b.append( ' ' );
	    }
	    if( mode & Mode.READ != 0 ) {
		b.append( 'R' );
	    }
	    if( mode & Mode.WRITE != 0 ) {
		b.append( 'W' );
	    }
	    if( mode & Mode.FINAL != 0 ) {
		b.append( 'F' );
	    }
	    b.append( ']' );
	    return b;
	}
    }

    // this describes a temporary that is a node in the temporary interference
    // graph during register allocation
    class MCandidate extends System.Object {
        public int refs;           // weighted number of references to this temporary
	public int cost;           // weighted number of clobbers by method calls of this temporary
        public int temp;           // temporary number
	public int range;          // measure of size of live range of this temporary
	// public int last_node;
        private MSet rset;         // what kind of register this node needs
	public int offset;         // address of slot on the stack for this temporary if it is spilled

	public int reg;            // register assigned to this temporary
	private int mask;          // bit mask specifying which registers can hold this temporary
	private int count_general;  // how many interfering registers of any type are adjacent to this temporary
	private int count_preserve; // how many interfering callee preserve registers are adjacent to this temporary
        

	// holds a list of adjacent temporaries:
	public MCandidate[] adjacent;

	// bit mask of registers clobbered over this temporaries lifetime:
	int clobber;

	void init( int temp, MSet s ) {
	    super.init();

	    assert( temp != 0, "creating MCandidate with for T0" );
	    assert( s != MSet.None, "creating MCandidate for MSet.None" );

	    this.cost = 0;
	    this.refs = 0;
	    this.temp = temp;
	    clearClobber();

	    Set = s;
	    // IO.Std.err.println( "T" + temp + " R" + reg + " set: " + cast<int>(s) + " mask: " + mask );
	}

	public int getMask() {
	    return mask;
	}

	void init( MOperand o ) {
	    init( o.temp, o.rset );
	}


	void countAdjacent() {
	    // IO.Std.err.println( "count adjacent: " + toString(removed) );

	    int i;

	    // assert( removed == null || !removed[temp], "counting spilled temporary" );

	    if( reg != 0 ) {
		// IO.Std.err.println( "count adjacent T" + temp + " R" + reg );

		countAdjacentSingleReg();
	    } else {
		countAdjacentMultiReg();
	    }
	}

	// this is a single register, count all adjacent temps single or multi:
	void countAdjacentSingleReg() {
	    int i;
	    int m = mask;
	    int c = 0;

	    // IO.Std.err.println( "count adjacent single register: T" + temp + " in R" + reg );

	    // this node requires a particular register. for each adjacent temporary, figure out if it
	    // could use our register and, if so, count it against the number of registers required
	    // to color this node:
	    for( i = 0; i < adjacent.length; i = i + 1 ) {
		MCandidate d = adjacent[i];

		int n = d.mask;

		// could adjacent temporary be placed in the register that we require?
		if( n & m != 0 ) {

		    if( d.reg != 0 ) {
			IO.Std.err.print( "T" + temp + " adjacent to: " );
			for( int j = 0; j < adjacent.length; j = j + 1 ) {
			    IO.Std.err.print( "T" + adjacent[j].temp + " " );
			}

			IO.Std.err.println();

			throw new RegisterException( "T" + temp + " in R" + reg + 
			    " interferes with adjacent T" + d.temp + " in R" + d.reg );
		    }
		    // d requires the same register as us but we interfere with it
		    // should have handled this earlier with a split:
		    assert( d.reg == 0, "T" + temp + " in R" + reg + 
			    " interferes with adjacent T" + d.temp + " in R" + d.reg );
		    /*
		      not an error on x86 - ebx interferes with callee preserve register set
		    assert( d.rset != MSet.Preserve, "T" + temp + " in fixed R" + reg + " mask: " + System.String.hex(m) +
			    " interferes with adjacent to T" + d.temp + " in preserve mask: " + System.String.hex(n) + " intersect: " + System.String.hex(n & m) );
		    */
		    // IO.Std.err.println( "count adjacent T" + d.temp );

		    // count adjacent temp:
		    c = c + 1;
		    // } else {
		    // IO.Std.err.println( "ignore adjacent T" + d.temp );
		}
	    }
	    
	    // IO.Std.err.println( "count myself" );
	    // count this temporary itself:
	    c = c + 1;

	    count_general = c;
	    // IO.Std.err.println( "count general now: " + count_general );
	}

	// this is a single register temp, remove an adjacent temp c single or multi
	void removeAdjacentSingleReg( MCandidate c ) {
	    // IO.Std.err.println( "T" + temp + " R" + reg + " remove adjacent to me T" + c.temp + " R" + c.reg );
	    // c is either a different single register or a regular set. removing an adjacent single register will not
	    // affect the count. Removing an adjacent regular set may do.

	    // if c is a single reg then mask & c.mask will be null as no single register temporaries requiring the same register
	    // can be adjacent
	    if( mask & c.mask != 0 ) {
		// IO.Std.err.println( "interferes - decrement my count" );
		count_general = count_general - 1;
	    }

	    // IO.Std.err.println( "count general now: " + count_general );
	}

	// this is a multi register temp, count all adjacent temps single or multi
	void countAdjacentMultiReg() {
	    // IO.Std.err.println( "count adjacent multi reg T" + temp + "..." );

	    int i, l;
	    int m = mask;
	    int count_mask;
	    int cg = 0;
	    int cp = 0;

	    for( i = 0; i < adjacent.length; i = i + 1 ) {
		MCandidate c = adjacent[i];
		int n = c.mask;
		if( n & m != 0 ) {
		    // IO.Std.err.println( "count adjacent T" + c.temp );

		    if( c.reg != 0 ) {
			// IO.Std.err.println( "single reg - record in mask" );
			count_mask = count_mask | c.mask;
		    } else if( c.rset == MSet.Preserve ) {
			// IO.Std.err.println( "preserve" );
			cp = cp + 1;
   /*		    } else if( c.rset == MSet.General ) {
			// IO.Std.err.println( "general" );
			cg = cg + 1; */
		    } else {
			// IO.Std.err.println( "other - count as general" );
			// other non-single reg register set. count as general
			// FIXME: x86 byte registers need counting here up to a limit like Preserve
			cg = cg + 1;
		    }
		}
	    }

	    // FIXME: assuming no single registers overlap preserve class here - not case for i386 32-bit (ebx)
	    if( count_mask != 0 ) {
		// IO.Std.err.println( "at least one adjacent single reg " + System.String.hex(count_mask) + " counting them..." );
		m = 1;
		l = 1 << Machine.LAST_MACHINE_REG;
		
		while( m <= l ) {
		    //IO.Std.err.println( "count " + System.String.hex(m) );
		    if( count_mask & m != 0 ) {
			// IO.Std.err.println( "counting mask: " + System.String.hex(m) );
			cg = cg + 1;
		    }
		    m = m + m;
		}
	    }


	    // count this temporary itself:
	    if( rset == MSet.Preserve ) {
		// IO.Std.err.println( "count self preserve" );
		cp = cp + 1;

		// FIXME: should could against cg here?
		cg = cg + 1;
	    } else {
		// IO.Std.err.println( "count self general" );
		cg = cg + 1;
	    }

	    // FIXME: > or >= here?
	    if( cp > Machine.NUM_PRESERVE_REG ) {
		// IO.Std.err.println( "capping adjacent preserve registers at " + Machine.NUM_PRESERVE_REG );

		// irrespective of how many adjacent temporaries want preserve registers, no more than number
		// of physical preserve registers can actually interfere here (since any additional adjacent
		// temporaries must be spilled):
		count_preserve = cp;
		count_general = cg + Machine.NUM_PRESERVE_REG;
	    } else {
		count_preserve = cp;
		count_general = cg + cp;
	    }

	    // IO.Std.err.println( "adjacent preserve: " + count_preserve );
	    // IO.Std.err.println( "adjacent any: " + count_general );
	}

	// this is a multi register temp, remove an adjacent temp c single or multi
	void removeAdjacentMultiReg( MCandidate c ) {
	    // IO.Std.err.println( "T" + temp + " remove adjacent to me T" + c.temp + " R" + c.reg );
	    // c is either a single register or a regular set. removing either may affect our count depending on mutual mask:
	    // affect the count. Removing an adjacent regular set may do.

	    if( mask & c.mask != 0 ) {
		// IO.Std.err.println( "interferes" );
		if( c.rset == MSet.Preserve ) {
		    // IO.Std.err.println( "decrementing preserve count" );
		    count_preserve = count_preserve - 1;
		    // if there are more preserve register temps adjacent to us than physical registers to hold them
		    // then removing one does not improve our chances of getting a register (general or preserve):
		    if( count_preserve < Machine.NUM_PRESERVE_REG ){
			// IO.Std.err.println( "adjacent preserve below physical - decrement general also" );
			count_general = count_general - 1;
		    }
		} else {
		    // IO.Std.err.println( "decrementing general count" );
		    count_general = count_general - 1;
		}
	    }

	    // IO.Std.err.println( "adjacent preserve: " + count_preserve );
	    // IO.Std.err.println( "adjacent any: " + count_general );
	}


	// is this node colorable according the the current count of adjacent temporaries?
	bool checkCounts( MBitSet removed, bool force_general ) {
	    /*
	    IO.Std.err.println( "T" + temp + " R" + reg + " check counts, force general: " + force_general );
	    IO.Std.err.println( "adjacent preserve: " + count_preserve );
	    IO.Std.err.println( "adjacent any: " + count_general );
	    */
	    /*
	    assert( count_general > 0, "register must at least be adjacent to itself: T" + temp + ", set: " + Machine.getSetName(rset) + " cg: " + count_general + ", cp: " + count_preserve + " removed: " + removed );
	    assert( !removed[temp] );
	    */

      	    if( reg != 0 ) {
		// if this node requires a fixed register then it's only colorable if no adjacent temporary could
		// use the required register - the adjacent count should be exactly one - i.e. this temporary itself
		// only:
		
		// IO.Std.err.println( "single reg, general: " + count_general + ", colorable: " + (count_general == 1) );
		return count_general == 1;
	    } else if( rset == MSet.General || force_general ) {
		// if the node requires a general register then just check that the general count does not exceed
		// the number of general registers:

		// IO.Std.err.println( "general reg, general: " + count_general + ", colorable: " + (count_general <= Machine.NUM_GENERAL_REG) );
		return count_general <= Machine.NUM_GENERAL_REG;
	    } else if( rset == MSet.Preserve ) {
		// FIXME: is this correct?
		// we need at least one preserve register free. 
		// adjacent temps could tie up the registers we want even if they're not preserve if there are more than
		// machine has preserve registers 
		// do we actually need to check the preserve count at all here?

		// FIXME: x86 byte registers end up here - they may appear colorable when actually not due to 5 or 6
		// adjacent registers:

		// IO.Std.err.println( "preserve or other reg, preserve: " + count_preserve + ", general: " + count_general + ", colorable: " + (count_general <= Machine.NUM_GENERAL_REG && count_preserve <= Machine.NUM_PRESERVE_REG) );
		return count_preserve <= Machine.NUM_PRESERVE_REG && count_general <= Machine.NUM_PRESERVE_REG;
	    } else if( rset == MSet.Byte ) {
		return count_general <= Machine.NUM_BYTE_REG;
	    }

	    return true;
	}


	// remove this temporary from the interference graph - subtract out its contribution to any adjacent temps' counts
	void remove(MBitSet removed) {
	    assert( !removed[temp] );

	    for( int i = 0; i < adjacent.length; i = i + 1 ) {
		MCandidate c = adjacent[i];
		if( !removed[c.temp] ) {
		    c.removed(this);
		}
	    }


	    removed.mark(temp);
	}

	// temporary d has been removed from the interference graph - update our counts accordingly:
	void removed(MCandidate d) {
	    if( reg != 0 ) {
		removeAdjacentSingleReg(d);
	    } else {
		removeAdjacentMultiReg(d);
	    }
	}

	void setSet( MSet s ) {
	    if( rset != s ) {
		rset = s;
		mask = Machine.getMaskForSet(s);
		reg = Machine.getSingleReg(s);
	    }
	    /*
	    if( cast<int>(s) == 4 ) {
		IO.Std.err.println( "T" + temp + ", set 4, reg " + reg + ", mask " + mask );
	    } 
	    */
	}

	MSet getSet() {
	    return rset;
	}

	void markClobber( MSet s ) {
	    int m = Machine.getMaskForSet( s, Machine.clobber_mask );

	    if( m != 0 ) {
		clobber = clobber | m;	    
	    }
	}

	void clearClobber() {
	    clobber = 0;
	}

	int getClobber() {
	    return clobber;
	}

	System.String toString( MBitSet removed ) {
	    System.StringBuffer result = new System.StringBuffer( "T" );
	    result.append( temp );
	    result.append( ':' );
	    result.append(Machine.getSetName(rset));
	    result.append( ' ' );

	    if( removed != null ) {
		result.append(":  ");

		for( int i = 0; i < adjacent.length; i = i + 1 ) {
		    if( !removed[adjacent[i].temp] ) {
			result.append( adjacent[i] );
			result.append( " " );
		    }
		}
	    }

            // result.append( "count: " + count_general + "/" + count_preserve );
	    return result;
	}


	System.String toString() {
	    return toString(null);

	    // return "[Candidate T" + temp + ":" + Machine.getSetName(set) + "\n  with refs " + refs + ", clobber cost " + cost + ", clobber " + clobber + ", range size: " + range + "]\n";
	}
    }


    // compare two candidates to determine which should be given preference when assigning registers by priority.
    // no longer used as assign order now determined by interference graph simplification via Chaitin's algorhythm
    class CompareCandidates extends Util.Compare {
	public static CompareCandidates f = new CompareCandidates();

        int compare( System.Object a, System.Object b ) {
	    MCandidate ma = cast<MCandidate>(a);
	    MCandidate mb = cast<MCandidate>(b);

	    if( ma == null ) {
		if( mb == null ) {
		    return 0;
		} else {
		    return 1;
		}
	    } else if( mb == null ) {
		return -1;
	    }

	    int cs = Machine.compareRegSets( ma.Set, mb.Set );

	    if( cs != 0 ) {
		return cs;
	    } else {
		return (mb.refs + mb.cost) - (ma.refs + ma.cost);
	    }
        }

	void init() {
	    super.init();
	}
    }


    // an edge in the control flow graph:
    class MEdge extends System.Object {
        int n;
        public MNode from;
        public MNode to;
        
        void init( MFlow mflow, MNode from, MNode to ) {
	    super.init();
            this.n = mflow.nextEdge();
            this.from = from;
            this.to = to;
        }


	System.String toString() {
	    return "MEdge(" + from.name[0] + "->" + to.name[0] + ")";
	}
    }

    // holds the control flow graph used for register allocation:
    class MFlow extends System.Object {
        Util.Vector node;  // program order nodes
        Util.Vector edge;  // edges connecting basic blocks to their successors

	MNode[] df_node;   // depth first ordered nodes
        
	int local_offset;  // at what stack offset should next spilled temporary be placed
	int size;          // how many temporaries are we allocating registers for

	int next_edge;

	// statistics for debugging purposes:
	public static int color_count;
	public static int coalesce_count;
	public static int instruction_count;
	public static int method_count;
	public static int temporary_count;

	static int c_count;
	static int max_coalesce_copies;

        MBitSet potential_spills;    // temporaries that we may not be able to find a register for
	MBitSet actual_spills;       // temporaries that we could not find a register for

	MBitSet already_spilled;     // temporaries used by instructions referencing a spilled or split temporary. Must not spill	                     
	MBitSet already_split;       // or split or an infinite loop in the register allocator is likely

	MBitSet[] matrix;            // bitmap representation of the temporary interference graph
	MBitSet[] copied;            // tracks which temporaries are copied to which other temporaries for coalescing
	                             // or preferential register assignment to avoid redundant copies
	// int[][] adjacent;
	MCandidate[] reg_cost;       // indexed by temporary number, used when calculating register sets and reference
	                             // counts for temporaries

	int[] regs;                  // indexed by temporary number, holds register to assign for each temporary

	bool debug;

	// code generation flags:
	public const int             
	    GEN_INLINE = 1,          // not used here
	    GEN_REGVARS = 2,         // not used here
	    GEN_COALESCE = 4,        // coalesce copies    
	    GEN_CSE = 8;             // common sub-expression elimination (disabled)

	void init() {
	    super.init();

            node = new Util.Vector();
            edge = new Util.Vector();

	    // these are grown when needed:
	    already_spilled = new MBitSet(50);  
	    already_split = new MBitSet(50);

	    initialize();
	}

	// initialize or reinitialze for a coalesce or register allocation pass:
        void initialize() {
	    size = TempFactory.CurrentTemp;
	    
	    // IO.Std.err.println( "JJJJJJ: initialize register allocator for " + size + " temporaries" );
            potential_spills = new MBitSet(size);
	    actual_spills = new MBitSet(size);
	    // already_clobbered =

	    if( size > 16000 ) {
		IO.Std.err.println( "too many temporaries: " + this );
		foreach( MNode o; node.elements() ) {
		    IO.Std.err.println( "node: " + o );
		}
		throw new System.Exception( "too many temporaries: " + size );
	    }

	    matrix = new MBitSet[size];
	    copied = new MBitSet[size];
	    // adjacent = new int[][size];
	    reg_cost = new MCandidate[size];
	    for( int i = 0; i < size; i = i + 1 ) {
		matrix[i] = new MBitSet(size);
		copied[i] = new MBitSet(size);
		// reg_cost[i] = new MCandidate();
		// IO.Std.err.println( "reg_cost[" + i + "]<-" + reg_cost[i] );
	    }

	    foreach( MNode n; node.elements() ) {
		n.initialize( size );
	    }
        }

	// reset all instructions to a clean state discarding any previously assigned
	// registers and clearing final use markers:
	void reset() {
	    foreach( MNode n; node.elements() ) {
		n.reset();
	    }
	}

	int nextEdge() {
	    int result = next_edge;
            next_edge = next_edge + 1;
	    return result;
	}


	// do simple local common subexpression elimination using available expressions (not currently used):
	bool calcSimpleCSE() {
	    bool result = false;
	    if( node.Length == 0 ) {
		return false;
	    }
	    MExpressionTable expressions = new MExpressionTable();

	    // ssa();

	    MNode[] dfn = calcDFN();

	    if( dfn == null ) {
		return false;
	    }
	    MNode previous = null;
	    int i; 
	    for( i = 0; i < dfn.length; i = i + 1 ) {
		MNode n = dfn[i];

		IO.Std.err.println( "CSE dfn " + i + ": " + n );
		if( n.calcSimpleCSE( previous, expressions ) ) {
		    result = true;
		}

		previous = n;
	    }

	    IO.Std.err.println( this );

	    // fixPhis();

	    // clearAllPhis();

	    return result;
	}


	// do simple local common subexpression elimination using available expressions (not currently used):
	bool calcSimpleJumpElim() {
	    bool result = false;
	    if( node.Length == 0 ) {
		return false;
	    }
	    MExpressionTable expressions = new MExpressionTable();

	    // ssa();

	    MNode[] dfn = calcDFN();

	    if( dfn == null ) {
		return false;
	    }
	    MNode previous = null;
	    int i; 
	    for( i = 0; i < dfn.length; i = i + 1 ) {
		MNode n = dfn[i];

		IO.Std.err.println( "CSE dfn " + i + ": " + n );
		if( n.calcSimpleJumpElim( previous, expressions ) ) {
		    result = true;
		}

		previous = n;
	    }

	    IO.Std.err.println( this );

	    // fixPhis();

	    // clearAllPhis();

	    return result;
	}

	void setDebug( bool debug ) {
	    this.debug = debug;
	}

	// do def-use data flow analysis to determine liveness of temporaries at all points in method:
	void calcLive() {
	    // IO.Std.err.println( "CCCCCC: calcLive: " + this );
	    bool changed = true;

	    /*
	      memset( minimum_mask, 0xFF, sizeof minimum_mask );
	      memset( clobber_mask, 0, sizeof clobber_mask );
	    */


	    foreach( MNode i; node.elements() ) {
		i.calcUse(false);
	    }

	    int count = 0;
	    

	    // DEF: those temporaries that are (always, certainly) DEFined within this block before any USE within this block
	    // USE: those temporaries that are (could be) USEd before DEFinition within this block

	    // IN: those temporaries that are USEd either directly in this block or in it's successors
	    // OUT: those temporaries that are in the IN sets of any of its successors

	    // a node's IN set is the set of those definitions which
	    // (EITHER output the block (OUT) OR are used by this node (U0))
	    // AND are not defined before use by this node (D0)
	    // a node's OUT set is the union of the IN sets of its successors
	    
	    // repeat until stabilises  


	    MBitSet t = new MBitSet(size);	    
	    for( count = 0; changed; count = count + 1 ) {
		// IO.Std.err.print( "." );
		changed = false;
		
		foreach( MNode n; node.elements() ) {

		    // a nodes IN set is the set of those definitions which

		    //   EITHER
		    //     output the block (i.e. inputs to other blocks)
		    //   OR
		    //     are used in this block
		    // AND
		    //   are not defined in this block
		    
		    // IO.Std.err.println( "out: " + n.bs_out + " or use: " + n.bs_use + " and not def: " + n.bs_def );
		    t.copy(n.bs_out);
		    t.or( n.bs_use );
		    t.andnot( n.bs_def );
		    // IO.Std.err.println( "gives: " + t );
		    
		    // this test may not be required - no change after IN . OUT propogation below may be
		    // sufficient to detect convergence
		    
		    if( !t.equals( n.bs_in ) ) {
		        // IO.Std.err.println( "changed" );
			changed = true;
			n.bs_in.assign(t);
		    }

		    // IO.Std.err.println( "changed: " + changed );
		}

		// IO.Std.err.println( "calculate OUT sets..." );
		
		foreach( MEdge e; edge.elements() ) {
		    // IO.Std.err.println( "calculate OUT set for " + e + " changed initially: " + changed );
		    // a node's OUT set is the union of the IN sets of its targets
		    e.from.bs_out.IsChanged = false;
		    changed = e.from.bs_out.or( e.to.bs_in ) || changed;
		    // IO.Std.err.println( "calcuated OUT sets, changed now: " + changed );
		}

		// IO.Std.err.println( "go again..." );
	    }
	    // IO.Std.err.println( " converged" );

	    /*
	    foreach( MNode q; node.elements() ) {
		IO.Std.err.println( "name: " + q.name[0] + " in: " + q.bs_in + " out: " + q.bs_out + " use: " + q.bs_use + " def: " + q.bs_def );
	    }
	    */

	    foreach( MNode p; node.elements() ) {
		p.calcFinal();
	    }

	    // IO.Std.err.println( "calc live done" );

	    // IO.Std.err.println( "finally: " + this );
	}

	// for debugging copy coalesing - limit copies coalesced to allow finding exact point
	// of failure:
	public static void setMaxCoalesceCopies( int c ) {
	    max_coalesce_copies = c;
	    IO.Std.err.println( "max coalesce copies: " + max_coalesce_copies );
	}

	// calculate depth first numbering for control flow graph and return array of
	// nodes in depth first order:
	MNode[] calcDFN() {
	    MNode p, w, u, v;
	    int i, k;

	    if( node.getLength() == 0 ) {
		return null;
	    }

	    int number = 0;
	    int count = node.getLength();

	    MNode[] n = new MNode[count];

	    bool[] seen = new bool[count];

	    // IO.Std.err.println( "calc dominators for " + count + " nodes..." );
	    foreach( MNode o; node.elements() ) {
		o.s = null;
	    }

	    IO.Std.err.println( "before DFN: " + this );

	    cast<MNode>(node[0]).depthFirstSearch( number, n );

	    for( i = 0; i < count; i = i + 1 ) {	       
		IO.Std.err.println( "node " + i + " of " + count );
		v = n[i];

		v.initSources();
	    }

	    return n;
	}


	// calculate dominators for SSA form (not currently used);
	void calcDominators() {
	    MNode p, w, u, v;
	    int i, k;

	    if( node.getLength() == 0 ) {
		return;
	    }

	    int number = 0;
	    int count = node.getLength();

	    MNode[] n = new MNode[count];

	    bool[] seen = new bool[count];

	    // IO.Std.err.println( "calc dominators for " + count + " nodes..." );

	    foreach( MNode o; node.elements() ) {
		o.s = null;
	    }

	    // IO.Std.err.println( "before SSA: " + this );

	    cast<MNode>(node[0]).depthFirstSearch( number, n );

	    for( i = 0; i < count; i = i + 1 ) {	       
		// IO.Std.err.println( "node " + i + " of " + count );
		v = n[i];

		if( v.dfn != i ) {
		    IO.Std.err.println( "dfn wrong node #" + i + ": "+ v );
		} else {
		    seen[i] = true;
		}

		v.initSources();
		/*
		for( k = 0; k < v.target.length; k = k + 1 ) {
		    if( v.target[k] != null ) {
			IO.Std.err.println( "target " + k + " is " + v.target[k].dfn );
		    } else {
			IO.Std.err.println( "target " + k + " is null" );
		    }
		}
		*/

		v.s = new Util.Vector();

		v.bs_dom = new MBitSet(count);

		v.semi = v;
		v.idom = null;
		v.ancestor = null;
		v.best = v;
	    }

	    for( i = count-1; i > 0; i = i - 1 ) {
		w = n[i];
		// IO.Std.err.println( "node " + i + " of " + count + " is " + w );

		if( w.dfn != i ) {
		    IO.Std.err.println( "dfn wrong node #" + i + ": "+ v );
		} else if( !seen[i] ) {
		    IO.Std.err.println( "strange: not seen node #" + i + " yet" );
		}


		p = w.parent;

		// IO.Std.err.println( "parent is " + p );
		
		for( k = 0; k < w.source.length; k = k + 1 ) {
		    v = w.source[k];    
		    // IO.Std.err.println( "source " + k + " of " + w.source.length + " is " + v );

		    u = eval(v);
		    // IO.Std.err.println( "eval is " + u );

		    // IO.Std.err.println( "u.semi is: " + u.semi );

		    if( w.semi.dfn > u.semi.dfn ) {
			w.semi = u.semi;
		    }
		}

		if( w.semi.bs_dom[w.dfn] ) {
		    IO.Std.err.println( "w.semi.bucket " + w.semi.dfn + " already contains w: " + w.dfn );
		}

		w.semi.bs_dom.mark(w.dfn);

		link(p,w);

		//  IO.Std.err.println( "parent bucket is: " + p.bs_dom );

		for( k = 0; k < count; k = k + 1 ) {
		    if( p.bs_dom[k] ) {
			v = n[k];

			u = eval(v);

			if( v.semi != p ) {
			    if( v.semi != null ) {
				IO.Std.err.println( "expected " + v.semi.dfn + " == " + p.dfn );
			    } else {
				IO.Std.err.println( "expected null/0 == " + p.dfn );				
			    }
			}

			if( u == null || u.semi == null ) {
			    IO.Std.err.println( "node or node semi is null" );
			}

			if( u.semi.dfn < p.dfn ) {
			    // IO.Std.err.println( "setting dom = " + u );
			    v.idom = u;
			} else {
			    // IO.Std.err.println( "setting dom = " + v.parent );
			    v.idom = p;
			}
		    }
		}
		p.bs_dom.clear();
	    }

	    for( i = 1; i < count; i = i + 1 ) {
		p.bs_dom.clear();

		w = n[i];
		//IO.Std.err.println( "set dom for node " + i );
		
		if( w.idom != w.semi ) {
		    w.idom = w.idom.idom;
		}

		if( w.idom != null ) {
		    w.idom.s.add(w);
		}
	    }

	    n[0].idom = null;


	    df_node = n;

	    for( i = 0; i < count; i = i + 1 ) {
		w = n[i];

		w.children = new MNode[w.s.getLength()];
		k = 0;
		foreach( MNode m; w.s.elements() ) {
		    w.children[k] = m;
		    k = k + 1;
		}
	    }

	    //native.printf( `df_node after A: %p\n`, df_node );
	}

	// calculate dominance frontiers for SSA form (not currently used);
	void calcDominanceFrontiers() {
	    int i, j, k;
	    MNode x, y, z;

	    if( node.getLength() == 0 ) {
		return;
	    }

	    MNode[] n = df_node;

	    // native.printf( `df_node before B: %p\n`, n );

	    for( i = n.length-1; i >= 0; i = i - 1 ) {
		x = n[i];
		x.s = new Util.Vector();
	    }

	    for( i = n.length-1; i >= 0; i = i - 1 ) {
		x = n[i];
		if( x.idom != null ) {
		    x.idom.s.add(x);
		}
	    }

	    for( i = n.length-1; i >= 0; i = i - 1 ) {
		x = n[i];
		// IO.Std.err.println( "idom("+i+") = " + x.s );

		x.bs_dom.clear();
		for( j = 0; j < x.target.length; j = j + 1 ) {
		    y = x.target[j];
		    if( y.idom != x ) {
			// IO.Std.err.println( "set local DF(" + i + ") U= " + j ); 
			x.bs_dom.mark(y.dfn);
		    }
		}

		for( k = 0; k < x.children.length; k = k + 1 ) {
		    y = x.children[k];
		    j = y.dfn;
		    
		    if( y.idom != x ) {
			// IO.Std.err.println( "set up DF(" + i + ") DF U= " + j ); 
			x.bs_dom.mark(j);
		    }
		}	      
	    }

	    for( i = 0; i < n.length; i = i + 1 ) {
		x = n[i];
		x.s = new Util.Vector();

		IO.Std.err.print( "df " + i + ":" );
		for( j = 0; j < n.length; j = j + 1 ) {
		    if( x.bs_dom[j] ) {
			x.s.add( n[j] );
			IO.Std.err.print( " " + j );
		    }
		}

		x.domf = new MNode[x.s.getLength()];

		j = 0;
		foreach( MNode m; x.s.elements() ) {
		    x.domf[j] = m;
		    j = j + 1;
		}
		
		IO.Std.err.println();
	    }
	}

	// calculate phi function placement for SSA (not currently used):
	void calcPhis() {
	    MNode x;
	    int i, j;

	    if( node.getLength() == 0 ) {
		IO.Std.err.println( "method is empty: no phi's to insert?" );
		return;
	    }

	    foreach( MNode o; node.elements() ) {
		o.calcUse(true);
		o.has_already = 0;
		o.work = 0;
	    }

	    MNode[] n = df_node;
	    int icount = 0;
	    Util.Vector work = new Util.Vector();

	    MBitSet w = new MBitSet( n.length );
	    MBitSet def;

	    for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
		icount = icount + 1;
		// IO.Std.err.println( "Temporary T" + i + ", iteration count now " + icount );

		for( j = 0; j < n.length; j = j + 1 ) {
		    x = n[j];
		    // IO.Std.err.println( "does node #" + j + " assign to T" + i + "?" );
		    def = x.bs_written;
		    // def = x.bs_def;

		    if( def[i] ) {
			// IO.Std.err.println( "node #" + j + " assigns to T" + i + "..." );
			x.work = icount;

			if( !w[j] ) {
			    // IO.Std.err.println( "stacking block #" + j );
			    w.mark(j);
			    work.add(x);
			} else {
			    // IO.Std.err.println( "work stack already contains node X (" + j + ")" );
			}
		    }
		}


		while( work.getLength() > 0 ) {
		    x = cast<MNode>(work.pop());
		    w.clear(x.dfn);

		    IO.Std.err.println( "place phi functions on node #" + x.dfn + "'s dominance frontier" );

		    // x.s currently holds list of nodes in x's dominance frontier:
		    foreach( MNode y; x.s.elements() ) {
			IO.Std.err.println( "considering node #" + y.dfn );
			if( y.has_already < icount ) {
			    if( !y.bs_in[i] ) {
				IO.Std.err.println( "plaching phi T" + i + " here is probably pointless because not live on entry" );
			    }

			    y.insertPhi(i);
			    y.has_already = icount;

			    if( y.work < icount ) {
				y.work = icount;

				if( !w[y.dfn] ) {
				    work.add(y);
				    w.mark(y.dfn);
				} else {
				    IO.Std.err.println( "work stack already contains node Y (" + y.dfn + ")" );
				}
			    }
			} else {
			    // IO.Std.err.println( "node #" + y.dfn + " already done" );
			}
		    }
		}
	    }
	    // IO.Std.err.println( "phis inserted: " + this );
	}

	void fixPhis() {
	    foreach( MNode n; node.elements() ) {
		n.fixPhis();
	    }
	}

	// set the SSA names for all temporaries (not currently used):
	void calcSSANames() {
	    // IO.Std.err.println( "calc SSA names..." );
	    if( node.getLength() == 0 ) {
		// IO.Std.err.println( "empty method" );
		return;
	    }

	    int[] c = new int[size];
	    Util.IntVector[] s = new Util.IntVector[size];

	    int i;
	    for( i = 0; i < size; i = i + 1 ) {
		s[i] = new Util.IntVector(size/2);
	    }

	    df_node[0].calcSSANames(s, c);
	    // IO.Std.err.println( "renamed temps for SSA: " );

	    foreach( MNode n; node.elements() ) {
		IO.Std.err.println( n );
	    }

	    // IO.Std.err.println( "calc SSA names done" );
	}

	// comment out phis that don't appear to be useful (not currently used):
	void clearIneffectivePhis() {
	    foreach( MNode n; node.elements() ) {
		MInst next = n.getHead().next;
		for( MInst i = n.getHead(); i != null; i = next ) {
		    next = i.next;

		    i.clearIneffectivePhi(n.bs_in);
		}
	    }
	}

	// comment out all phis (not currently used):
	void clearAllPhis() {
	    foreach( MNode n; node.elements() ) {
		MInst next = n.getHead().next;
		for( MInst i = n.getHead(); i != null; i = next ) {
		    next = i.next;
		    i.clearPhi();
		}
	    }
	}

	void link( MNode v, MNode w ) {
	    w.ancestor = v;
	}

	MNode eval( MNode v ) {
	    // IO.Std.err.println( "eval: " + v );

	    MNode a = v.ancestor;

	    // IO.Std.err.println( "a initially: " + a );
	    while( a != null && a.ancestor != null && a.ancestor.dfn != 0 ) {
		// IO.Std.err.println( "test v.semi versus a.semi..." );
		// IO.Std.err.println( "v: " + v );
		// IO.Std.err.println( "a: " + a );
		if( v.semi.dfn > a.semi.dfn ) {
		    // IO.Std.err.println( "v <- a" );
		    v = a;
		}

		// IO.Std.err.println( "a has no right to be null here: " + a );

		a = a.ancestor;

		// IO.Std.err.println( "a could be null here: " + a );
	    }

	    return v;
	}

	/*
	    if( v.ancestor == null ) {
		return v;
	    } else {
		compress(v);
		return v.label;
	    }
	}

	MNode compress( MNode v ) {
	    if( v.ancestor.ancestor != null ) {
		compress( v.ancestor );
		if( v.ancestor.label.semi.dfn < v.label.semi.dfn ) {
		    v.label = v.ancestor.label;
		}
		v.ancestor = v.ancestor.ancestor;
	    }
	}

	*/  

	/*
	bool calcRangeSizes() {
	    bool result = true;

	    int i = 1;
	    foreach( MNode k; node.elements() ) {
		// IO.Std.err.println( "calc reg sets for node" );

		if( !k.calcRangeSizes( reg_cost, i ) ) {
		    IO.Std.err.println( "JJJJJJ: calc range sizes inserted splits for this node" );
		    result = false;
		}

		i = i + 1;
	    }

	    return result;
	}
	*/

	// determine register sets for each temporary putting results in reg_cost[] indexed by temporary number:
	bool calcRegSets(MBitSet already_split) {
	    bool result = true;

	    // IO.Std.err.println( "MFlow calc reg sets: " + this );

	    foreach( MNode k; node.elements() ) {
		// IO.Std.err.println( "calc reg sets for node" );

		if( !k.calcRegSets( reg_cost, already_split ) ) {
		    // Parse.ParseTree.message( "JJJJJJ: calc reg sets inserted splits for this node" );
		    result = false;
		}
	    }

	    /*
	    if( !result ) {
		Parse.ParseTree.message( "JJJJJJ: at least one temporary split due to null register set intersection" );
	    }
	    */

	    return result;
	}

	// for each element in matrix[i][j], if matrix[i][j] is set then also set matrix[j][i]:
	static void reflect( MBitSet[] matrix, int size ) {
            int i, j, l, m;
	    MBitSet a;
	    l = matrix.length;
	    assert( l == size );

	    // IO.Std.err.println( "loop " + Machine.FIRST_SOFT_REG + " < " + l );

	    // MBitSetIterator i = new MBitSetIterator();

	    for( i = Machine.FIRST_SOFT_REG; i < l; i = i + 1 ) {
		// IO.Std.err.println( "enter: " + i );
		a = matrix[i];
		a.reset( Machine.FIRST_SOFT_REG );

		// IO.Std.err.println( "reflect matrix[" + i + "]: " + a );
		// IO.Std.err.println( "reflect value[" + i + "]: " + a.Set );
		for( j = a.nextSet(); j != -1; j = a.nextSet() ) {

		    // IO.Std.err.println( "matrix[" + i + "][" + j + "]..." );
		    if( j != i ) {
			// IO.Std.err.println( "setting matrix[" + j + "][" + i + "]..." );
			matrix[j].mark(i);
		    } /* else if( !matrix[j][i] ) {
			 IO.Std.err.println( "reflect arg!" );
			 throw new System.Exception( "reflect arg!" );		    
			 } */

		}
		// IO.Std.err.println( "again: " + i );
	    }

	    /*
	    for( i = Machine.FIRST_SOFT_REG; i < l; i = i + 1 ) {
		a = matrix[i];
		m = a.Length;
		for( j = Machine.FIRST_SOFT_REG; j < m; j = j + 1 ) {
		    if( a[j] != matrix[j][i] ) {
			IO.Std.err.println( "oops: not reflected T" + i + ",T" + j );
		    }
		}
	    }
	    */

	    // IO.Std.err.println( "exit: " + i );
	}

	// calculate the temporary-to-temporay copies graph and, optionally, the
	// temporary interference graph:
	void calcAdjacent(bool coalesce_only) {
            int i, k, l;
            int live_count;
	    MBitSet a;

	    // for( i = 0; i < next_temporary; i = i + 1 ) {
	    //	matrix[i].clearAll();
	    // }

	    // IO.Std.err.println( "marking nodes adjacent: " + node );

	    MCandidate[] rc;

	    // calculating the temporary interference graph is quite expensive and is not needed for
	    // copy coalescing so don't calculate it needlessly:
	    if( !coalesce_only ) {
		rc = reg_cost;
	    }

	    foreach( MNode q; node.elements() ) {
		q.calcAdjacent( matrix, rc );
	    }

            // IO.Std.err.println( "marked nodes adjacent" );

	    // IO.Std.err.println( "calling reflect " + size + "..." );

	    reflect( matrix, size );

	    /*
	    for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
		for( j = Machine.FIRST_SOFT_REG; j < size; j = j + 1 ) {		    
		    if( matrix[i][j] && !matrix[j][i] ) {
			IO.Std.err.println( "matrix not reflected: " + i + "," + j + " but not " + j + "," + i );
		    }
		}
	    }
	    
	    for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
		IO.Std.err.println( "matrix[" + i + "]: " + matrix[i] );
		IO.Std.err.println( "value[" + i + "]: " + matrix[i].Set );
	    }
	    */

	    // we always want the copied graph as the register allocator needs it for
	    // preferential allocation to avoid redundant copies:
	    foreach( MNode p; node.elements() ) {
		p.calcCopies( matrix, copied );
	    }

	    reflect( copied, size );

	    /*
	    for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
		int l = copied[i].Length;
		if( l > 0 ) {

		    for( k = 0
		    if( copied[i][j] ) {
		        copied[j].set(i);
		    }
		}
	    }
	    */

	    /*
	    if( !coalesce_only ) {
		for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
		    a = matrix[i];
		    adjacent[i] = a.Array;
		}
	    }
	    */

/*
            for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
                if( adjacent[i] != null ) {
                    IO.Std.err.print( "T" + i + " is adjacent to: " );

                    for( j = 0; adjacent[i][j] != 0; j = j + 1 ) {
                        IO.Std.err.print( " T" + adjacent[i][j] );
                    }
                    IO.Std.err.println();
                }
            }
*/

	    // IO.Std.err.println( "JJJJJJ: adjacent temporaries calculated" );
        }

	System.String toString() {
	    System.StringBuffer b = new System.StringBuffer();
	    b.append( "MFlow: " );
	    
	    foreach( MEdge e; edge.elements() ) {
		b.append( e );
		b.append( " " );
	    }

	    b.append( '\n' );

	    foreach( MNode n; node.elements() ) {
		b.append( n );
	    }

	    return b;
	}

	// given a list of basic blocks in program order, build the control flow graph by adding edges based
	// on jumps, labels and falling through from block to block:
	void enumerate() {
	    // next_edge = 0;
	    foreach( MNode n; node.elements() ) {
		for( int j = 0; j < MNode.MAX_NODE_TARGET; j = j + 1 ) {
		    if( n.target[j] != null ) {
			// IO.Std.err.println( "add edge: " + n.name[0] + "->" + n.target[j].name[0] );
			edge.add( new MEdge( this, n, n.target[j] ) );
		    }
		}
	    }

	    // IO.Std.err.println( "edges: " + edge );
	}

	// put the control flow graph into SSA form (not currently used):
	void ssa(/*MInst head*/) {
	    /*
	    if( head == null ) {
		return;
	    }

	    // IO.Std.err.println( "fill..." );
	    fill( head );

	    // IO.Std.err.println( "enumerate..." );

	    // IO.Std.err.println( "assign registers, local offset: " + local_offset );

	    enumerate();
	    */
	    IO.Std.err.println( "calc SSA for " + size + " temporaries..." );

	    calcDominators();
	    calcDominanceFrontiers();
	    calcPhis();
	    calcSSANames();

	    clearIneffectivePhis();

	    /*
	    renameSSATemps();
	    initialize();
	    reset();
	    */
	}

	// is it safe to coalesce a copy involving temporary t?
	bool canCoalesce( int t ) {
	    MCandidate d = reg_cost[t];

	    if( d == null ) {
		return false;
	    }

	    assert( d.temp == t );

	    // it's not safe to coalesce copies to or from temporaries that require a fixed register -
	    // if we do we risk making work for the register allocator which will potentially need to
	    // split the temporary again if it interferes with another temporary also requiring the
	    // same fixed register.
	    // chances are that preferential register allocation can eliminate such copies anyway 
	    if( d.reg != 0 ) {
		// IO.Std.err.println( "do not coalesce T" + t + " requiring fixed register" );
		return false;
	    } else {
		// IO.Std.err.println( "can coalesce T" + t );
	    }

	    return true;
	}

	// attempt to coalesce copied temporaries into the same temporary. This is aggressive coalescing in
	// that we take no account of register pressure and just coalesce anything that doesn't interfere
	// with the exception of temporaries that require a fixed register:
	int coalesce() {
	    MBitSet seen = new MBitSet(size);
	    int[] rename = new int[size];
	    int i, j, k, p;
	    int count = 0;
	    bool result = false;

	    // for debugging - stop after a specified number of copies coalesced:
	    if( max_coalesce_copies > 0 && c_count >= max_coalesce_copies ) {
		// IO.Std.err.println( "skipping coalesce completely: " + c_count + " >= " + max_coalesce_copies );
		return 0;
	    }

	    // IO.Std.err.println( "\nCCCCCC: start coalescing..." );

	    // for every temporary:
	    for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
		// IO.Std.err.println( "checking mbitset copied T" + i );
		// copied[i].check();

		// IO.Std.err.println( "coalesce T" + i + ", seen: " + seen[i] );

		// if we've already coalesced it, it's not safe to do so again in this coalesce pass:
		if( seen[i] ) {
		    // IO.Std.err.println( "already done T" + i + " seen: " + seen[i] ); 
		    continue;
		}

		// if it's a fixed register temporary we should not coalesce it:
		if( !canCoalesce(i) ) {
		    // IO.Std.err.println( "can't coalesce T" + i + " seen: " + seen[i] );
		    continue;
		}

		// for each temporay copied to or from this one:
		MBitSet c = copied[i];
		c.reset( Machine.FIRST_SOFT_REG );

		// IO.Std.err.println( "reset copied T" + i + " seen: " + seen[i] ); 

		for( j = c.nextSet(); j != -1 ; j = c.nextSet() ) {
		   if( i != j ) {
		       /*
		       p = p + 1;
		       if( p & 1024 == 0 ) {
			   Parse.ParseTree.progress();
		       }
		       */

		       // IO.Std.err.println( "try coalesce T" + i + "<->T" + j + " seen: " + seen[i] );

			// shouldn't happen - copies excludes interfering pairs:
			assert( !matrix[i][j], "potential coalesce copies interfering temps T" + i + ", T" + j + " seen: " + seen[i] );

			// assert( !seen[i], "oops: already seen T" + i );
			
			// if we've not already coalesced temp j and it is not a fixed register:
			if( !seen[j] && canCoalesce(j) ) {
			    // IO.Std.err.println( "can coalesce T" + i + "<->T" + j );
			    // do not attempt to coalesce either of these temporaries again on this pass:
			    seen.mark(i);
			    seen.mark(j);
			    
			    // IO.Std.err.println( "coalesce T" + i + "<-T" + j );
			    if( rename[j] != 0 ) {
				throw new System.Exception( "oops: already intending rename: T" + rename[j] + "<-T" + j );
			    }

			    // for debugging - stop after a specified number of copies coalesced:
			    if( max_coalesce_copies > 0 && c_count >= max_coalesce_copies ) {
				// IO.Std.err.println( "stopping coalescing here: " + c_count + " >= " + max_coalesce_copies );
				break;
			    }
			    
			    // note that we need to rename i to j (or vice versa):
			    rename[i] = j;
			    c_count = c_count + 1;
			    count = count + 1;
			    // IO.Std.err.println( "count now: " + count );

			    // note that we will have coalesced at least one copy:
			    result = true;

			    // no point in continuing looking for things to coalesce with i on this pass:
			    break; 
			}
		    }
		}
	    }

	    if( result ) {
		// IO.Std.err.println( "coalesced " + count + " copies" );

		assert( count != 0 );

		int[] t = new int[count];
		int[] u = new int[count];

		// IO.Std.err.println( "t.length initially: " + t.length );

		j = 0;
		for( i = 0; i < rename.length; i = i + 1 ) {
		    int r = rename[i];
		    if( r != 0 ) {
			if( i > r ) {
			    t[j] = i;
			    u[j] = r;
			    // IO.Std.err.println( "CCCCCC: no swap T" + u[j] + "<-T" + t[j] );
			} else {
			    t[j] = r;
			    u[j] = i;
			    // IO.Std.err.println( "CCCCCC: swap T" + u[j] + "<-T" + t[j] );
			}
			// IO.Std.err.println( "CCCCCC: coalesce " + c_count + ", " + count + " T" + u[j] + "<-T" + t[j] );
			j = j + 1;
			count = count - 1;
			// IO.Std.err.println( "count now: " + count + ", j now: " + j );
		    }
		}

		// IO.Std.err.println( "j: " + j + ", t.length: " + t.length );

		assert( j == t.length, "" + j + " != " + t.length );
		assert( count == 0, "" + count + " != " + 0 );


		for( i = 0; j < t.length; i = i + 1 ) {
		    assert( t[i] != 0, "t[" + i + "] == 0" );
		    assert( u[i] != 0, "u[" + i + "] == 0" );
		    assert( t[i] != u[i], "t==u " + i );
		}

		renameTemps( t, u, "coalesce copy" );
		/*
		
		for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
		    if( rename[i] != 0 ) {
			if( i > rename[i] ) {
			    // IO.Std.err.println( "will rename T" + i + "<-T" + rename[i] );
			    renameTemp( i, rename[i], "coalesce copy" );
			} else {
			    // IO.Std.err.println( "will rename T" + rename[i] + "<-T" + i );
			    renameTemp( rename[i], i, "coalesce copy" );
			}
		    }
		}
		*/
		return t.length;
	    }

	    // IO.Std.err.println( "no coalesceble copies found" );
	    return 0;
	}

	void renameTemps( int[] t, int[] u, System.String why ) {
	    foreach( MNode n; node.elements() ) {
		// IO.Std.err.println( "flow rename temp " + from + "->" + to );
		n.renameTemps( t, u, why );
	    }
	}

	void renameSSATemps() {
	    foreach( MNode n; node.elements() ) {	       
		n.renameSSATemps();
	    }
	}

	
	// assign registers and optionally coalesce copies:
	bool build( int attempt, MInst inst, int local_offset ) {
	    try {
		return build2( attempt, inst, local_offset );
	    } catch( RegisterException re ) {
		IO.Std.err.println( this );
		IO.Std.err.println( "build failed with register exception: " + re );
		return false;
	    }
	}

	bool build2( int attempt, MInst inst, int local_offset ) {
	    this.local_offset = local_offset;
	    // IO.Std.err.println( "MFlow.build...\n" );
	    assignSegments(inst);
	    int count = 1;
	    bool coalesced = false;

	    // IO.Std.err.println( "fill..." );

	    // determine basic blocks:
	    fill( inst );

	    // IO.Std.err.println( "enumerate..." );

	    // IO.Std.err.println( "assign registers, local offset: " + local_offset );

	    // build control flow graph:
	    enumerate();
	    

	    // if requested repeatedly coalesce copied temporaries until all possible copies removed:
	    if( attempt & GEN_COALESCE != 0 && size > 0 ) {
		// IO.Std.err.println( "coalesce..." );
		
		count = 0;
		coalesced = false;
		do {
		    Parse.ParseTree.progress();

		    // determine what temporaries are live at what points in the method:
		    calcLive();

		    // determine what kinds of registers are required for temporaries so that we
		    // can avoid coalesing temporaries that require a fixed register:
		    calcRegSets(null);

		    // determine which temporaries are live at the same time as each other and so cannot
		    // be coalesced into one temporary:
		    calcAdjacent(true);
		    
		    coalesce_count = coalesce_count + 1;
		    
		    int number_coalesced = coalesce();
		    int ratio = 1000 * number_coalesced / size;
		    // IO.Std.err.println( "coalesced ratio is: " + ratio + ", size: " + size + " temps versus: " + number_coalesced + " copies eliminated" );
		    if( number_coalesced == 0 || ratio < 5 ) {
			// no more coalescable copies found :
			coalesced = true;			
			break;
		    }
		    
		    // IO.Std.err.println( "coalesce again: " + count );
		    
		    count = count + 1;
		    
		    // register numbers have changed. reset everything including clearing the
		    // copied graph and the interference graph:
		    initialize();
		    reset();

		    // repeat until either no more coalesible copies found or we excede a reasonable
		    // number of passes:
		} while( count < 20 );
	    }
	    
	    // calcSimpleCSE();

	    count = 0;
      	    while( count < 20 ) {
		// IO.Std.err.println( "calc live..." );
		Parse.ParseTree.progress();

		// determine what temporaries are live at what points in the method:
		calcLive();

		// determine what kinds of registers are required for temporaries and split temporaries
		// that cannot be held in a single register over their whole lifetime:
		if( calcRegSets(already_split) ) {
		    Parse.ParseTree.progress();
		    // IO.Std.err.println( "calc adjacent..." );

		    // determine which temporaries are live at the same time as each other and so cannot
		    // be stored in the same register:
		    calcAdjacent(false);
		    MCandidate[] candidates = initializeCandidates();

		    // if any temporaries requiring fixed registers interfere then they must be split
		    // so they no longer interfere:
		    if( fixSingleRegTemps(candidates) ) {
			
			// if we got here then we've split no temporaries on this pass and we can now try
			// and color the interference graph and assign instructions:
			if( color(candidates, count) ) {
			    // IO.Std.err.println( "CCCCCC: colored successfully" );

			    // remove copies where source and destination are the same register or where
			    // the destination is not used before next definition or method end:
			    peephole( /*reg, spilled*/ );

			    // output the register assigments to the assembler file for debugging:
			    dumpTemps();
			    
			    countInstructions(count+1);
			    return true;
			}
		    }
		    // } else {
		    // Parse.ParseTree.message( "JJJJJJ: issued splits due to null register set intersections" );
		}

		count = count + 1;

		// IO.Std.err.println( "color again: " + count );

		// did not color the graph on this pass, reset state ready for another pass:
		initialize();
		reset();
	    }

	    IO.Std.err.println( "failed to color: " + this );
	    // throw new System.Exception( "failed to color" );

	    // return failure - caller can try again with less complex code:
	    return false;
	}


	// convert 3-address instructions to machine instructions. Not currently used
	// as input is machine code:
	bool regen() {
	    bool result = false;
	    ITree.AllowThreeAddress = false;
	    Util.Vector list = new Util.Vector();
	    foreach( MNode n; node.elements() ) {
		if( n.regen( list ) ) {
		    result = true;
		}
	    }

	    return result;
	}

	void countInstructions(int cc) {
	    foreach( MNode n; node.elements() ) {
		n.countInstructions();
	    }

	    method_count = method_count + 1;
	    color_count = color_count + cc;

	    temporary_count = temporary_count + TempFactory.nextTemp() - Machine.FIRST_SOFT_REG;
	}

	void dumpTemps() {

	    if( node.getLength() == 0 ) {
		return;
	    }
	    MNode n = cast<MNode>(node[0]);

	    for( int j = reg_cost.length - 1; j >= 0; j = j - 1 ) {
		MCandidate c = reg_cost[j];
		System.String s;
		if( c != null && c.temp != 0 ) {
		    System.String where = "";
		    int r = regs[c.temp];
		    if( r != 0 ) {
			where = "R" + r + " " + Machine.getRegName(r,Machine.WORD);
		    } else {
			where = "memory";
		    }
		    
		    s = "T" + c.temp + " in " + where + "," + cast<char>(9) + " refs: " + c.refs + ", clobbers: " + c.cost + ", range: " + c.range;

		    MInst i = new MInst( new MData( Op.COMMENT, new MConst( s ) ) );
		    n.getHead().insertAfter( n, i );
		}
	    }
	}

	// convert segment save and restore directives to actual segements:
	void assignSegments(MInst i) {
	    Util.Vector stack = new Util.Vector();
	    stack.add(".text");
	    for( ; i != null; i = i.next ) {
		i.assignSegment(stack);
	    }
	}

	// break instruction list into individual basic blocks:
	void fill( MInst inst ) {
	    MInst i, next;
	    
	    int l = 0;
	    int weight = 1;

	    // next_node = 0;
	    // IO.Std.err.println( "creating MNode: size = " + size );
	    MNode current = new MNode( size, inst );
	    current.weight = 1;
	    for( i = inst; i != null; i = next ) {
		// IO.Std.err.println( "inst: " + i );
		next = i.next;

		if( i.isEnterLoop() ) {
		    weight = weight * 8;
		    // IO.Std.err.println( "enter loop: weight now " + weight );
		} else if( i.isLeaveLoop() ) {
		    weight = weight / 8;
		    // IO.Std.err.println( "leave loop: weight now " + weight );
		}

		if( i.isJump() ) {
		    current.name[1] = i.getLabel();
		    // IO.Std.err.println( "jump: exit name 1 is " + current.name[1] );
		} else if( i.isLabel() ) {
		    current.name[0] = i.getLabel();
		    // IO.Std.err.println( "label: exit name 0 is " + current.name[0] );
		}
		
		if( i.isJump() || next == null || next.isLabel() ) {
		    // IO.Std.err.println( "last instruction in block" );

		    if( current.name[0] == null ) {
			current.name[0] = "M" + l;
			// IO.Std.err.println( "no labels seen so block name 0 is " + current.name[0] );

			l = l + 1;
		    }

		    node.add( current );
		    if( i.next != null ) {
			// IO.Std.err.println( "more instructions coming..." );

			MNode o = new MNode( size, i.next );
			o.weight = weight;
			current.removeTail(i);
			if( !i.isUnconditionalJump() ) {
			    // IO.Std.err.println( "fall through from " + current.name[0] + " to following node" );
			    current.target[0] = o;
			}
			current = o;
		    } else {
			current.removeTail(i);
		    }
		}
	    }
	   
	    foreach( MNode n; node.elements() ) {
		if( n.name[1] != null ) {
		    // IO.Std.err.println( "looking for label " + n.name[1] + " to satisfy jump" );
		    foreach( MNode m; node.elements() ) {
			if( m.name[0] != null && n.name[1].equals(m.name[0]) ) {
			    if( n.target[0] != null ) {
				n.target[1] = m;
			    } else {
				n.target[0] = m;
			    }
			    break;
			}
		    }
		}
	    }
	    // IO.Std.err.println( "filled: " + this );
	}
	
        void addEdge( int n, MNode from, MNode to ) {
            edge.add( new MEdge( this, from, to) );
        }

	void addInto( MBlock into ) {
	    foreach( MNode n; node.elements() ) {
		n.addInto( into );
	    }
	}

	// print assembler to supplied output:
	void output( IO.Writer o ) {
	    foreach( MNode n; node.elements() ) {
		n.output( o );
	    }
	}

	void assignCandidates( Util.Vector candidates ) {

	}

	// take the list of temporaries in reg_cost and the bitset interference graph and build the
	// alternate MCandidate representation:
	MCandidate[] initializeCandidates() {
	    int i, j, t, u;
	    MCandidate c, d;

	    MCandidate[] a;

	    Util.Vector v = new Util.Vector();

	    for( i = 0; i < reg_cost.length; i = i + 1 ) {
		Util.Vector w = new Util.Vector();

		c = reg_cost[i];		
		if( c == null || c.temp <= 0 ) {
		    continue;
		}
		t = c.temp;

		// IO.Std.err.println( "T" + t + ", length: " + already_spilled.Length );
		// IO.Std.err.println( "spilled: " + already_spilled );

		/*
		if( t < already_spilled.Length && already_spilled[t] ) {
		    c.spilled = true;
		} else {
		    c.spilled = false;
		}
		*/

		v.add( c );

		MBitSet m = matrix[t];
		m.reset( Machine.FIRST_SOFT_REG );
		for( j = m.nextSet(); j != -1; j = m.nextSet() ) {
		    // IO.Std.err.println( "adjacent T" + t + " T" + j );
		    /*
		    u = adjacent[t][j];
		    if( u <= 0 || u == t ) {
			continue;
		    }
		    */
		    if( j < 0 || j >= reg_cost.length ) {
			IO.Std.err.println( "unexpected temp T" + j + " versus " + reg_cost.length );
			continue;
		    }

		    d = reg_cost[j];
		    if( d == null || d.temp == t ) {
			continue;
		    }

		    w.add( d );
		}

		c.adjacent = new MCandidate[w.getLength()];
		j = 0;
		foreach( MCandidate f; w.elements() ) {
		    c.adjacent[j] = f;
		    j = j + 1;
		}
	    }

	    MCandidate[] result = new MCandidate[v.getLength()];
	    MBitSet rr = new MBitSet(size);

	    i = 0;
	    foreach( MCandidate e; v.elements() ) {
		result[i] = e;
		i = i + 1;
	    }


	    return result;
	}

	// for any temporary that requires a fixed register that is live at the same time as another 
	// temporary that also requires the same fixed register, split one or other of the temporaries
	// at each use and definition requiring that register to try to break this interference

	// returns true if any temporaries split
	bool fixSingleRegTemps( MCandidate[] candidates ) {
	    if( candidates.length == 0 ) {
		return true;
	    }

	    bool result = true;
	    MBitSet to_fix = new MBitSet(size);
	    MBitSet already_fixed = already_split;

	    MSet s;
	    int i, j, rd, re, t, u, f;
	    MCandidate d, e;

	    /*
	    for( i = 0; i < candidates.length; i = i + 1 ) {
		d = candidates[i];
		s = d.Set;
		t = d.temp;
	    */
		/*
		if( t < already_split.Length && already_split[t] ) {
		    IO.Std.err.println( this );
		    IO.Std.err.println( "refusing to split already split T" + d.temp );
		    assert("refusing to split already split T" + d.temp );
		} else if( t < already_spilled.Length && already_spilled[t] ) {
		    IO.Std.err.println( this );
		    IO.Std.err.println( "refusing to split already spilled T" + d.temp );
		    assert("refusing to split already spilled T" + d.temp );

		    } else */

	    /*
		if( s == MSet.None ) {
		throw new System.Exception( "register set change requires split: T" + d.temp );
	    */
		    /*
		    // no one register can hold for entire lifetime - split at all single reg references
		    splitSingleRegTemp( d, true );
		    already_split.set(t);
		    result = false;
		    */
	    /*
		}
		}*/

	    /*
	    if( !result ) {
		return false;
	    }
	    */

	    for( i = 0; i < candidates.length; i = i + 1 ) {
		d = candidates[i];
		s = d.Set;
		t = d.temp;

		if( to_fix[t] ) {
		    continue;
		}
		/*
		if( t < already_split.Length && already_split[t] ) {
		    IO.Std.err.println( this );
		    IO.Std.err.println( "refusing to split already split T" + d.temp );
		    assert("refusing to split already split T" + d.temp );
		} else if( t < already_spilled.Length && already_spilled[t] ) {
		    IO.Std.err.println( this );
		    IO.Std.err.println( "refusing to split already spilled T" + d.temp );
		    assert("refusing to split already spilled T" + d.temp );

		    } else */

		/* if( split_now[t] ) {
		    continue;
		    } */
		
		// may need split if adjacent to any temporaries requiring the same single register:
		rd = d.reg;
		if( rd != 0 ) {
		    // IO.Std.err.println( "checking T" + t + " requiring R" + rd + "..." );
		    for( j = 0; j < d.adjacent.length; j = j + 1 ) {
			e = d.adjacent[j];
			u = e.temp;

			if( u == t ) {
			    // IO.Std.err.println( "AAAA: T" + u + " is adjacent to itself" );
			    continue;
			}

			// IO.Std.err.println( "adjacent to T" + u + "..." );

			if( to_fix[u] ) {
			    continue;
			}
			// s = e.rset;
			re = e.reg;
			
			if( re == rd ) {
			    // IO.Std.err.println( "AAAA: T" + t + " in reg R" + rd + " interferes with T" + u + " in R" + re + ": split required" );
			   
			    bool already_split_t = false;
			    bool already_split_u = false; 
			    if( t < already_fixed.Length ) {
				already_split_t = already_fixed[t];
			    }
			    
			    if( u < already_fixed.Length ) {
				already_split_u = already_fixed[u];
			    } 

			    /*
			    IO.Std.err.println( "already split T" + t + ": " + already_split_d );
			    IO.Std.err.println( "already split T" + u + ": " + already_split_e );
			    IO.Std.err.println( "split now T" + t + ": " + to_fix[t] );
			    IO.Std.err.println( "split now T" + u + ": " + to_fix[u] );
			    */

			    if( already_split_t && already_split_u ) {
				IO.Std.err.println( this );

				IO.Std.err.println( "already split T" + t + ": " + already_split_t );
				IO.Std.err.println( "already split T" + u + ": " + already_split_u );
				// IO.Std.err.println( "split now T" + t + ": " + split_now[t] );
				// IO.Std.err.println( "split now T" + u + ": " + split_now[u] );

				throw new System.Exception( "single reg temporaries interfere and both already splilled" );
			    }


			    /*
			    if( to_fix[t] ) {
				already_split_t = true;
			    }

			    if( to_fix[u] ) {
				already_split_u = true;
			    }
			    */

      			    if( already_split_t && !already_split_u ) {
				// IO.Std.err.println( "choosing to split not-split T" + u );
				f = u;
			    } else if( already_split_u && !already_split_t ) {
				// IO.Std.err.println( "choosing to split not-split T" + u );
				f = t;
			    } else if( d.range > e.range ) {
				// IO.Std.err.println( "choosing to split smaller range T" + u );
				f = u;
			    } else {
				// IO.Std.err.println( "choosing to split smaller range T" + t );
				f = t;
			    }

			    to_fix.mark( f );
			    result = false;
			}
		    }
		}
	    }

	    if( !result ) {
		// fixSpills( reg_cost, to_spill );
		fixSplits( reg_cost, to_fix );
	    }

	    return result;
	}


	void fixSplits( MCandidate[] candidates, MBitSet to_split ) {
	    foreach( MNode n; node.elements() ) {
		n.fixSplits( candidates, already_split, to_split );
	    }
	}

	// attempt to find a register assignment order that will allow the temporary inteference graph to be
	// colored with a minimum of spills. we do this by repeatedly removing colorable nodes from the graph
	// and placing them on a stack until the graph is empty. If at any point we become blocked because no
	// remaining node in the graph is colorable then we instead select a node to spill and remove it from
	// the graph. This is Chaitin's 'simplify graph' step.
	MCandidate[] calcAssignOrder( MCandidate[] candidates, MBitSet already_spilled, MBitSet potential_spills, MBitSet potential_clobbers, bool first ) {
            int i, j, k, t, u, s, v;

	    int count = 0;

	    MCandidate c, d, e;
	    MCandidate[] a;

	    if( candidates.length == 0 ) {
		return candidates;
	    }

	    // initialize the counts of adjacent temporaries:
	    for( i = 0; i < candidates.length; i = i + 1 ) {
		d = candidates[i];
		d.countAdjacent();
		/*
		IO.Std.err.print( "candidate: " + d + ": " );

		for( j = 0; j < d.adjacent.length; j = j + 1 ) {
		    IO.Std.err.print( "" + d.adjacent[j] + ", " );
		} 

		IO.Std.err.println();
		*/
	    }


	    // IO.Std.err.println( "XXXXXX: color graph: " + this );

	    Util.Vector stack_reg = new Util.Vector();           // nodes we expect to be able to assign a register to 
	    Util.Vector stack_spill = new Util.Vector();         // nodes we expect to have to spill

	    MBitSet removed = new MBitSet(size);                 // nodes we've removed from the graph

	    bool removed_any;
	    bool spilled_any;
	    while( true ) {
		removed_any = false;
		spilled_any = false;

		/*
		IO.Std.err.println();
		IO.Std.err.println();
		IO.Std.err.println( "XXXXXX: colorable loop" );
		IO.Std.err.println();
		*/

		if( count == candidates.length ) {
		    // we've removed all temporaries from the graph:

		    // IO.Std.err.println( "assigned or spilled all required temporaries" );
		    break;
		}		

		removed.IsChanged = false;

		// first look for a colorable node:
		for( k = 0; k < candidates.length; k = k + 1 ) {
		    d = candidates[k];

		    t = d.temp;

		    // if we have not already colored or spilled this node:
		    if( !removed[t] ) {
			// IO.Std.err.println( "considering " + d.toString(removed) );
			
			// is this node colorable (i.e. no possible coloring of its neighbor nodes
			// could result in it not receiving a register:
			if( d.checkCounts( removed, false ) ) {
			    // if so then it's safe to defer assigning a register to this node until
			    // after all remaining neighbors are assigned so remove it from the 
			    // graph and place it on te stack:

			    // d.countBlocks( removed, spilled );
			    d.remove(removed);

			    // IO.Std.err.println( "removed colorable node T" + d );

			    /*
			    for( j = 0; j < candidates.length; j = j + 1 ) {
				IO.Std.err.println( "      " + candidates[j].toString(removed) );
			    }

			    IO.Std.err.println( "\n" );
			    */

			    stack_reg.add(d);

			    removed_any = true;		    

			    count = count + 1;
			    break;
			    /* } else {
			    IO.Std.err.println( "node T" + t + " is not colorable" );
			    */
			}
		    }
		}


		/*

		// failed to find any colorable temporaries - consider placing a call clobbered register in a
		// non callee preserve register, if this would result in fewer memory accesses than a spill:

		if( !removed_any ) {
		    IO.Std.err.println( "looking for preserve to put in clobbered register..." );
		    // see if we can give a preserve temp a general register before resorting to a spill:
		    c = null;
		    v = 0;

		    for( k = 0; k < candidates.length; k = k + 1 ) {
			d = candidates[k];
			
			t = d.temp;
			IO.Std.err.println( "T" + t + " refs: " + d.refs + " clobbers: " + d.cost + " removed: " + removed[t] + " preserve: " + (d.Set == MSet.Preserve) );
			if( !removed.get(t) && d.Set == MSet.Preserve && d.refs > d.cost ) {

			    IO.Std.err.println( "considering " + d.toString(removed) );
			    // IO.Std.err.println( "counts: " + d.dumpCounts() );
			    
			    if( d.checkCounts( removed, true ) ) {
				d.remove(removed);

				if( d.Set == MSet.Preserve ) {
				    d.Set = MSet.General;
				    IO.Std.err.println( "potentially assigning preserve T" + d.temp + " to non preserve register" );
				    potential_clobbers.set(d.temp);
				}
				stack_reg.add(d);
				
				removed_any = true;
				count = count + 1;
			    }
			}
		    }
		}
		*/

		if( !removed_any ) {
		    // failed to remove any temporary from the graph. To make further progress we need to select a temporay as
		    // a potential spill. Look for something that's likely to make the graph colorable at minimal runtime cost:

		    for( k = 0; k < candidates.length; k = k + 1 ) {
			d = candidates[k];
			t = d.temp;
			// IO.Std.err.println( "consider " + d );
			if( !removed[t] ) {
			    if( already_spilled != null && t < already_spilled.Length && already_spilled[t] ) {
				// this temporary is being used to operate on a previously spilled temporary, do not 
				// spill it or we'll likely end up with an infinite loop where the same value is
				// repeatedly spilled:
				// IO.Std.err.println( "AAAAAA: refusing to spill already spilled: T" + t );
				continue;
			    }
			    // IO.Std.err.println( "could be spilled: " + d );

			    // prefer temporaries with many adjacent nodes but avoid temporaries with many references:
			    int w = d.adjacent.length * 10 + d.range - d.refs;

			    // IO.Std.err.println( "spill score " + w + " for " + d.toString(removed) + ", adjacent: " + d.adjacent.length + ", refs: " + d.refs );			    
			    // if this is the best candidate for a spill we've seen so far:
			    if( c == null || (w > v && (d.reg == 0 || c.reg != 0))) {
				// remember that this is the best candiate yet:
				// IO.Std.err.println( "T" + d.temp + " is current best spill candidate" );
				c = d;
				w = v;
			    }
			}
		    }

		    if( c == null ) {
			// oops: didn't find anything to spill
			IO.Std.err.println( this );
			IO.Std.err.println( "already spilled: " + already_spilled );
			IO.Std.err.println( "about to spill: " + potential_spills );
			throw new RegisterException( "expected to spill something but found nothing suitable" );
		    }

		    // IO.Std.err.println( "potential spill " + c.toString(removed) );
		    /*

		    IO.Std.err.print( "adjacent: " );
		    for( int q = 0; q < c.adjacent.length; q = q + 1 ) {
			IO.Std.err.print( "" + c.adjacent[q] + " " );
		    }
		    IO.Std.err.println();
		    */

		    // remove the potentially spilled temporary from the graph and put it on the spill stack:
		    t = c.temp;
		    c.remove(removed);

		    removed.mark(t);
		    potential_spills.mark(t);

		    stack_spill.add(c);
		    spilled_any = true;

		    count = count + 1;
		    
		}

		if( count == candidates.length ) {
		    // IO.Std.err.println( "successfully empied interference graph" );
		    break;
		}

		if( !removed_any && !spilled_any ) {
		    throw new RegisterException( "failed to empty interference graph" );
		}
	    }

            // IO.Std.err.println( "XXXXXX: color done" );

	    // remove colorable and then spilled nodes from their stacks and put into the 
	    // assignment list in reverse of order removed from the graph:

	    MCandidate[] result = new MCandidate[stack_reg.getLength() + stack_spill.getLength()];

	    k = 0;
	    foreach( MCandidate f; stack_reg.reverseElements() ) {
		// IO.Std.err.println( "should get register: " + f );
		result[k] = f;
		k = k + 1;
	    }

	    foreach( MCandidate g; stack_spill.reverseElements() ) {
		// IO.Std.err.println( "potential spill: " + g );
		result[k] = g;
		k = k + 1;
	    }

	    return result;
	}

	// return a bit mask of what registers adjacent to candidate c are currently occupied:
	int getFull( MCandidate c, int[] regs ) {
	    int full;
	    MCandidate d;
	    int j, r;

	    for( j = 0; j < c.adjacent.length; j = j + 1 ) {
		d = c.adjacent[j];
		// IO.Std.err.println( "AAAAAA: adjacent T" + t + " " + d );
		if( d.temp <= 0 ) {
		    IO.Std.err.println( "ignoring candidate T0" );
		    continue;
		}
		
		r = regs[d.temp];
		
		if( r > 0 ) {
		    // IO.Std.err.println( "AAAAAA: full initially: " + System.String.hex(full) );
		    // IO.Std.err.println( "AAAAAA: adjacent R" + r + " is full" );
		    full = full | (1 << r);
		    // IO.Std.err.println( "AAAAAA: full now: " + System.String.hex(full) );
		}
	    }

	    return full;
	}

	// given a bit mask of free registers, return the first free register:
	int findFree( int free ) {
	    int m = 1 << Machine.FIRST_MACHINE_REG;
	    for( int j = Machine.FIRST_MACHINE_REG; j <= Machine.LAST_MACHINE_REG; j = j + 1 ) {
		// IO.Std.err.println( "full R" + j + ": " + System.String.hex(full & m) );
		// IO.Std.err.println( "mask R" + j + ": " + System.String.hex(s & m) );
			    
		if( free & m != 0 ) {
		    return j;
		}

		m = m + m;
	    }

	    return 0;
	}
	
	// given a assignment order sorted list of temporaries, attempt to assign registers to temporaries
	bool tryAssign( MCandidate[] candidates, MBitSet potential_spills, MBitSet actual_spills, MBitSet potential_clobbers ) {
	    MCandidate c, d;

	    MBitSet assigned = new MBitSet(size);

	    bool result = true;
            int i, j, k, l, m, t, u, r, avail, reg, count;
            int full = 0;

	    for( i = 0; i < size; i = i + 1 ) {
		// default not assigned, this value will cause a wrong register exception if any instructions
		// are emitted that actually reference an unassigned temporary:
		regs[i] = -1;
	    }

	    // IO.Std.err.println( "AAAAAA: MFlow.color(): assigning candidates in priority order..." );

	    // for each temporary in assign order:
            for( k = 0; k < candidates.length; k = k + 1 ) {
		c = candidates[k];
		t = c.temp;
		reg = -1; // -1 == not done, == 0 done but spilled, > 0 done assigned this register

		/*
		IO.Std.err.println( "looking for register for T" + t + ", adjacent: " );
		
		for( l = 0; l < c.adjacent.length; l = l + 1 ) {
		    IO.Std.err.print( "T" + c.adjacent[l].temp + " " );
		    if( c.adjacent[l].reg != 0 ) {
			IO.Std.err.print( " in R" + c.adjacent[l].reg + ", " );
		    } else {
			IO.Std.err.print( ", " );
		    }			
		}

		IO.Std.err.println();
		*/

		assert( !assigned[t], "already assigned T" + t + " to R" + regs[t] );

		// if temporary requires a fixed register then assign it now:
		if( c.reg != 0 ) {
		    reg = c.reg;
		    regs[t] = reg;
		    assigned.mark(t);

		    // IO.Std.err.println( "T is in fixed register R" + reg );
		    continue;
		}


		avail = c.Mask;
		
		// what registers are already occupied by temporaries adjacent to this temporary?
		full = getFull( c, regs );
		
		// what registers in the desired set are free?
		avail = avail & ~full;

		bool may_be_clobbered = false;

		/*
		if( avail == 0 && c.refs > c.cost * 2 ) {
		    // want callee save register but none free, try a general register instead:
		    may_be_clobbered = true;
		    avail = Machine.getMaskForSet( MSet.General ) & ~full;
		}
		*/

		// IO.Std.err.println( "available and suitable registers: " + System.String.hex(avail) );

		// if at least one suitible register is available:
		if( avail != 0 ) {
		    // IO.Std.err.println( "trying to avoid a copy" );
		    // at least one register is free. 
		    
		    // try and avoid copies between temps by assigning same registers to pairs of copied temps 
		    

		    // for each temporary that is copied to or from this temporary:
		    MBitSet cc = copied[c.temp];		    
		    cc.reset( Machine.FIRST_SOFT_REG );
		    for( j = cc.nextSet(); j != -1; j = cc.nextSet() ) {
			d = reg_cost[j];
			if( d == null ) {
			    continue;
			}
			u = d.temp;
			assert( u == j, "reg cost not in temp order" );
			
			// attempt to share it's register to avoid copy:
			// IO.Std.err.println( "SSSSSS: copied T" + c.temp + " -> T" + j );
			if( regs[u] > 0 ) {
			    // copied temp is already assigned a register
			    m = 1 << regs[u];
			    
			    if( avail & m != 0 ) {
				// and register is free here and suitible for us: use it in preference to any other
				// IO.Std.err.println( "R" + j + " is free" );
				
				// IO.Std.err.println( "SSSSSS: Prefered copy reg: T" + t + "\nis in R" + regs[l] );
				reg = regs[u];
				
				MInst.copy_number = MInst.copy_number + 1;
				break;
			    }
			} else {
			    // copied temp is not yet assigned a register, see if we could assign ourselves
			    // a register that is compatible with what l will get:
			    int ml = avail & d.Mask;
			    
			    if( ml != 0 ) {
				// IO.Std.err.println( "SSSSSS: intersection is non-zero - looking for a free register" );

				m = 1 << Machine.FIRST_MACHINE_REG;					
				for( j = Machine.FIRST_MACHINE_REG; j <= Machine.LAST_MACHINE_REG; j = j + 1 ) {
				    // IO.Std.err.println( "full R" + j + ": " + System.String.hex(full & m) );
				    // IO.Std.err.println( "mask R" + j + ": " + System.String.hex(s & m) );
				    
				    if( ml & m != 0 && full & m == 0 ) {
					// IO.Std.err.println( "R" + j + " is free" );
					
					// IO.Std.err.println( "SSSSSS: hoping for copy reg: T" + t + "\nis in R" + j );
					
					// assign a compatible register and hope the other temporary will get the
					// same register when it is assigned:
					reg = j;
					break;
				    }
				    m = m + m;
				}
			    }
			}
			
			
			if( reg != -1 ) {
			    // we were able to assign a prefered copy register, we're done for this temporary:

			    // IO.Std.err.println( "assigned " + c + " to preferred copy reg R" + reg );
			    break;
			}
		    }

		    if( reg == -1 ) {
			// couldn't eliminate a copy. any available register from required set will do:
			/*
			IO.Std.err.println( "looking for a free register..." );
			IO.Std.err.println( "full:     " + System.String.hex(full) );
			*/
			m = 1 << Machine.FIRST_MACHINE_REG;			
			for( j = Machine.FIRST_MACHINE_REG; j <= Machine.LAST_MACHINE_REG; j = j + 1 ) {
			    // IO.Std.err.println( "full R" + j + ": " + System.String.hex(full & m) );
			    // IO.Std.err.println( "mask R" + j + ": " + System.String.hex(s & m) );
			    
			    if( avail & m != 0 ) {
				// IO.Std.err.println( "R" + j + " is free" );
				
				// IO.Std.err.println( "" + c + "\nis in R" + j + " refs " + c.refs + "\n" );
				// if( c.set != MSet.Param1 && j == Machine.R_ESI ) {
				// IO.Std.err.println( "rsi because free. full: " + System.String.hex(full) + " versus ecx: " + Machine.M_ECX + "->" + System.String.hex(full & Machine.M_ECX) );
				// IO.Std.err.println( "s: " + System.String.hex(s) + " versus ecx ->" + System.String.hex(m & Machine.M_ECX) ); 
				// }
				reg = j;
				break;
			    }

			    m = m + m;
			}
		    }		   
		} else {
		    if( reg == -1 && !potential_spills[t] ) {
			// oops: we expected to be able to assign a register to this temporary be we couldn't 
			// find one. will need to spill it.

			IO.Std.err.println( this );
			full = 0;

			Parse.ParseTree.message( "suprise spill: T" + t + " (" + c + ")" );
			IO.Std.err.println( "adjacent: " );
			for( i = 0; i < c.adjacent.length; i = i + 1 ) {
			    d = c.adjacent[i];
			    u = d.temp;
			    System.String rr = "";
			    if( regs[u] > 0 ) {
				full = full | (1 << regs[u]);
				rr = "/R" + regs[u];
			    }

			    IO.Std.err.println( "T" + u + rr + ":" + Machine.getSetName(reg_cost[u].Set) );
			}
			m = Machine.getMaskForSet(c.Set);

			IO.Std.err.println( "mask:  " + System.String.hex(m));
			IO.Std.err.println( "full:  " + System.String.hex(full) );
			IO.Std.err.println( "free:  " + System.String.hex(m & ~full) );
			IO.Std.err.println( "avail: " + System.String.hex(avail) ); 

			// IO.Std.err.println( "XXXXXX: expected to be able to color T" + t + " but no register free" );
		    }

		    // IO.Std.err.println( "T" + t + " is in memory at refs " + c.refs + " becase set is None" );
		    reg = 0;
		}

		regs[t] = reg;
                assigned.mark(t);

                if( reg <= 0 ) {
		    // IO.Std.err.println( "actual spill: T" + t );
		    actual_spills.mark(t);
		    result = false;
		} else if( may_be_clobbered ) {
		    // assigned at least one call clobbered register to a non-callee-preserve register - need to save 
		    // clobbered registers to stack around calls:
		    potential_clobbers.mark(t);
		}
            }

	    return result;
	}

	// given a set of temporaries to spill, generate code to copy them between new temporaries and the stack around instructions
	// that reference them:
	void fixSpills( MCandidate[] candidates, MBitSet spilled) {
	    int i, j;

	    // IO.Std.err.println( "fixing spills" );
	    // IO.Std.err.println( "to spill: " + spilled );
	    for( i = 0; i < candidates.length; i = i + 1 ) {
		MCandidate c = candidates[i];
		int t = c.temp;

		if( spilled[t] ) {
		    // IO.Std.err.println( "spilling T" + t + "..." );  		

		    if( t < already_spilled.Length && already_spilled[t] ) {
			throw new RegisterException( "already spilled T" + t );
		    }

		    // IO.Std.err.println( "spilled T" + t + " is at stack offset: " + offset );
		    c.offset = local_offset;
		    local_offset = local_offset - Machine.WORD;
		}
	    }

	    CodeGenerator gen = new CodeGenerator( null );

	    foreach( MNode k; node.elements() ) {
		k.fixSpills( reg_cost, already_spilled, spilled, gen );
	    }
	}

	// determine register assignment order and assign registers to temporaries. return
	// true if color succeeds or false if spills or splits generated and coloring must
	// be attempted again:
        bool color(MCandidate[] candidates, int count) {
	    bool result = true;
            int i, j, t;

	    MBitSet could_clobber = new MBitSet(size);

	    regs = new int[size];

	    // IO.Std.err.println( "color: " + this );

	    // IO.Std.err.println( "LIVE:\n" + node );

	    // IO.Std.err.println( "MFlow.color(): building candiate list..." );

            for( i = 0; i < candidates.length; i = i + 1 ) {
		MCandidate d = candidates[i];

		bool bad_mask = false;
		bool narrow_mask = false;
		bool is_clobbered = false;
		bool wide_range = false;
		
		// IO.Std.err.println( "T" + i + ": " + d );
		
		if( d.reg != 0 ) {
		    narrow_mask = true;
		}
		
		if( d.Clobber != 0 ) {
		    // IO.Std.err.println( "clobber is " + d.getClobber() );
		    is_clobbered = true;
		}
		
		if( d.range > 6 ) {
		    // IO.Std.err.println( "live range includes " + d.range + " blocks" );
		    wide_range = true;
		} else {
		    // IO.Std.err.println( "live range is short" );
		}
		
		// MSet rset = d.rset;
		
		if( is_clobbered ) {
		    // if( d.Set != MSet.Byte ) {
			d.Set = MSet.Preserve;
			/*
		    } else {
			d.Set = MSet.BytePreserve;
		    }
			*/
		}

		/*
		IO.Std.err.print( "candidate: " + d + ": " );

		for( j = 0; j < d.adjacent.length; j = j + 1 ) {
		    IO.Std.err.print( "" + d.adjacent[j] + ", " );
		} 		

		IO.Std.err.println();
		*/

		/*
		    IO.Std.err.println( "clobbered reg: T" + d.temp );
		    if( count > 0 || (!wide_range && narrow_mask) ) {
			IO.Std.err.println( "will preserve clobbered reg: T" + d.temp );
			d.Set = MSet.Preserve;
		    } else {
			IO.Std.err.println( "will allow clobber reg: T" + d.temp );
			could_clobber.set(d.temp);
		    }
		}	
		*/
	    }



	    /*
	    Util.Sort.sort( CompareCandidates.f, candidates );
	    */

	    // attempt to find out an assignment order that minimizes number of spills
	    candidates = calcAssignOrder( candidates, already_spilled, potential_spills, could_clobber, count == 0 );

	    // IO.Std.err.println( "WWWWWW: assign..." );

	    // try to assign registers:
	    if( !tryAssign(candidates, potential_spills, actual_spills, could_clobber) ) {
		// IO.Std.err.println( "actual spills required: " + actual_spills );
		
		// had to spill at least one temporary - generate instructions for the spills and tell caller they
		// need to try again:
		fixSpills(candidates, actual_spills);
		return false;
	    }


	    // IO.Std.err.println( "CCCCCC: assigned registers" );

	    /*
            for( i = Machine.FIRST_SOFT_REG; i < size; i = i + 1 ) {
		if( referenced[i] && (!assigned[i] || regs[i] <= 0) ) {
		    IO.Std.err.println( "FFFFFF: needs fixing: T" + i + ":" + Machine.getSetName( reg_cost[i].set ) );
		    
		    not_allocated.set(i);
 		}

		if( !referenced[i] && !assigned[i] ) {
		    // IO.Std.err.println( "did not need to assign T" + i );
		} else if( !assigned[i] ) {
		    IO.Std.err.println( "not assigned A: T" + i + " is " + regs[i] );
		} else if( regs[i] == -1 ) {
		    IO.Std.err.println( "not assigned B: T" + i + " is " + regs[i] );
		} else if( regs[i] == 0 ) {
		    IO.Std.err.println( "T" + i + " assigned to memory" );
		    spilled.set( i );
		} else {
		    // IO.Std.err.println( "T" + i + " assigned to R" + regs[i] );
		}
            }

	    if( spilled.isChanged() || not_allocated.isChanged() ) {
		result = false;
		IO.Std.err.println( "FFFFFF: spill(s) and/or split(s) required" );
	    }
            */

	    // IO.Std.err.println( "MFlow.color(): assigning registers" );

	    // successfully found registers to all temporaries - update instructions 
	    // with assigned registers:
            foreach( MNode n; node.elements() ) {
                n.assignRegisters( regs );
            }

	    // IO.Std.err.println( "CCCCCC: fixup clobbered: " + this );

	    // prepare a list of potentially clobbered candidates:
	    MCandidate[] cc;
	    int c;
	    if( could_clobber.IsChanged ) {
		c = 0;
		for( j = 0; j < size; j = j + 1 ) {
		    if( could_clobber[j] ) {
			c = c + 1;
		    }
		}
		cc = new MCandidate[c];
		c = 0;
		for( j = 0; j < size; j = j + 1 ) {
		    if( could_clobber[j] ) {
			cc[c] = reg_cost[j];
			assert( reg_cost[j].temp == j );
			c = c + 1;
		    }
		}
	    } else {
		cc = null;
	    }

	    // it's still possible that some temporaries are in registers that are not compatible with all
	    // instructions that reference them. If we find any generate additional splits
	    if( !fixRegSets( regs, cc ) ) {
		// generated additional splits - caller needs to retry:
		// IO.Std.err.println( "CCCCCC: reg sets fixed - need recolor" );
		return false;
	    }

	    // we may have placed temporaries that are clobbered by call instructions in registers that
	    // are not preserved across calls - these temporaries need to be saved to the stack around calls
	    fixClobbered( regs, cc );

	    // IO.Std.err.println( "CCCCCC: no clobbers issued" );

	    // successfully assigned appropriate registers to all temporaries:
	    return true;
        }

	/*
        void insertFixups( int[] reg, MBitSet spilled ) {
            foreach( MNode n; node.elements() ) {
                // IO.Std.err.println( "about to fix up node: " + n );
                n.insertFixups( reg, spilled );
            }
        }
	*/

        bool fixClobbered( int[] reg, MCandidate[] could_clobber ) {
	    bool result = true;
            foreach( MNode n; node.elements() ) {
                // IO.Std.err.println( "about to fix up node: " + n );
		if( !n.fixClobbered( reg, could_clobber, local_offset ) ) {
		    result = false;
		}
            }

	    return result;
        }


        bool fixRegSets( int[] reg, MCandidate[] could_need_fixing ) {
	    bool result = true;
            foreach( MNode n; node.elements() ) {
                // IO.Std.err.println( "about to fix up node: " + n );
		if( !n.fixRegSets( reg, could_need_fixing) ) {
		    result = false;
		}
            }

	    return result;
        }



	void peephole( /*int[] reg, MBitSet spilled*/ ) {
	    foreach( MNode n; node.elements() ) {
		// IO.Std.err.println( "about to fix up node: " + n );
		n.peephole( /*reg, spilled*/ );
	    }
	}
    }


    class MNode extends MBlock {
        public const int
            MAX_NODE_TARGET = 2,
            MAX_NODE_SOURCE = 16;

        bool is_visited;
        bool is_removed;
        public int weight;
        // int n;
        // int last_temp;
        public System.String[] name;

	public Util.Vector s;
	public MNode[] source; 
        public MNode[] target;

	// data flow for register allocator
        public MBitSet bs_def;
	public MBitSet bs_use;
	public MBitSet bs_out;
	public MBitSet bs_in;

	// Dominator tree:
        public int dfn;
	public MNode parent;
	public MNode ancestor;
	public MNode label;
	public MNode idom;
	public MNode best;
	public MNode dom;
	public MNode semi;
	public MBitSet bs_dom;   // working set for dominance calculations
	public MNode[] children; // immediately dominated nodes
	public MNode[] domf;     // dominance frontier

	// phi placement:
	public MBitSet bs_written;
	public int has_already;
	public int work;


	// public MBitSet idom;

        
        void init( int size, MInst i ) {
	    super.init();
            // n = next_node;
            // next_node = next_node + 1;
            dfn = 0;
            is_visited = false;
            is_removed = false;

            name = new System.String[MAX_NODE_TARGET];
            target = new MNode[MAX_NODE_TARGET];

	    initialize( size );

            for( inst = i; i != null; i = i.next ) {
		if( i.next == null ) {
		    tail = i;
		}
	    }

	    // IO.Std.err.println( "tail: " + tail );
	    
	    // IO.Std.err.println( "new MNode, size: " + size );
        }


	void initialize( int size ) {
            bs_def = new MBitSet(size);
	    bs_use = new MBitSet(size);
	    bs_out = new MBitSet(size);
	    bs_in = new MBitSet(size);
	    bs_written = new MBitSet(size);
	}

	void reset() {
	    MInst i;
	    for( i = inst; i != null; i = i.next ) {
		// IO.Std.err.println( "reset..." );
		i.reset();
	    }
	}

        void init( int size ) {
            init( size, null );
        }

	void clearAll() {
	    bs_def.clear();
	    bs_use.clear();
	    bs_out.clear();
	    bs_in.clear();
	    bs_written.clear();
	}



	int findSource( MNode y ) {
	    for( int j = 0; j < source.length; j = j + 1 ) {
		IO.Std.err.println( "source[" + j + "] " + source[j].dfn + " == " + y.dfn + "?" );
		if( source[j] == y ) {
		    if( source[j].dfn != y.dfn ) {
			IO.Std.err.println( "WEIRD: source[" + j + "].dfn (" + source[j].dfn + ") != y.dfn (" + y.dfn + ")" );			
		    }
		    IO.Std.err.println( "returning source #" + j + ", dfn " + source[j].dfn );
		    
		    return j;
		}
	    }
	    throw new System.Exception( "node #" + y.dfn + " not source #" + this.dfn );
	}



	void calcSSANames( Util.IntVector[] s, int[] c /*, Util.IntVector renamed */ ) {
	    int v, k, l;

	    MNode y;
	    MInst i;
	    for( i = inst; i != null; i = i.next ) {
		// IO.Std.err.print( "search: " + i );
		if( !i.isPhi() ) {
		    i.setTempNamesRHS( s );
		}

		i.setTempNamesLHS( s, c );

		// i.setTempNames();
	    }

	    for( l = 0; l < target.length; l = l + 1 ) {
		y = target[l];
		IO.Std.err.println( "fix phi names in target #" + l + ", dfn #" + y.dfn );

		v = y.findSource(this);
		IO.Std.err.println( "this node is source #" + v + " in the target node" );

		for( i = y.inst; i != null; i = i.next ) {
		    // IO.Std.err.print( "try: " + i ); 
		    if( i.isPhi() ) {
			IO.Std.err.print( "fixup phi: " + i );
			int t = i.getTemp();
			if( !y.bs_in[t] ) {
			    IO.Std.err.println( "target phi T" + t + " is probably pointless" );
			}

			if( s[t].Length > 0 ) {
			    i.setTempName(v, s[t].getTop());
			} else {
			    IO.Std.err.println( "oops: empty stack for T" + t + ": may not be live here?" );
			}
		    } else if( i.isLabel() ) {
			// IO.Std.err.print( "ignore label: " + i );
		    } else {
			// IO.Std.err.print( "something else, should quit: " + i );
			break;
		    }
		}
		// IO.Std.err.println( "fixed up from node #" + y.dfn );
	    }

	    // IO.Std.err.println( "fixed up all" );

	    for( l = 0; l < children.length; l = l + 1 ) {
		y = children[l];
		y.calcSSANames( s, c );
	    }

	    for( i = inst; i != null; i = i.next ) {
		// if( !i.isPhi() ) {
		    i.popTempNames(s);
		    // }
	    }
	}

	void fixPhis() {
	    for( MInst i = inst; i != null; i = i.next ) {
		if( i.isPhi() ) {
		    for( int j = 0; j < source.length; j = j + 1 ) {
			MInst s = new MInst(
					    new MMove( Op.COPY_8,
						       new MReg( i.getOperand(0).temp, MSet.General ),
						       new MReg( i.getOperand(0).temp, MSet.General )  // i.Left.getTempName(j), MSet.General )
						       )
					    );
			s.initOperands();
			source[j].insertBeforeLast( s );
		    }
		}
	    }
	}

	void depthFirstSearch( int ref number, MNode[] nodes ) {
	    if( this == null ) {
		IO.Std.err.println( "oops: dfs, this is null" );
		throw new System.Exception( "oops: dfs, this is null" );
	    }

	    if( semi != null ) {
		IO.Std.err.println( "oops: been here before: " + this );
		throw new System.Exception( "oops: been here before: " + this );
	    }

	    dfn = number;

	    semi = this;

	    // IO.Std.err.println( "setting node[" + number + " of " + nodes.length + "] to " + this + "..." );

	    nodes[dfn] = this;

	    // IO.Std.err.println( "dfn " + dfn );

	    number = number + 1;

	    for( int i = 0; i < target.length; i = i + 1 ) {
		MNode w = target[i];
		if( w != null ) {
		    if( w.semi == null ) {
			w.parent = this;
			// IO.Std.err.println( "search " + number );
			w.depthFirstSearch( number, nodes );
		    }
		    // IO.Std.err.println( "add source " + this.dfn + " to " + w.dfn );
		    if( w.s == null ) {
			w.s = new Util.Vector();
		    }
		    w.s.add(this);
		}
	    }
	}

	void insertPhi( int t ) {
	    MInst s = new MInst( new MPhi( t ) );
	    s.initOperands();
	    // IO.Std.err.println( "inserted phi: " + s );
	    insertAfterFirst( s );
	}

	void initSources() {
	    if( source != null ) {
		IO.Std.err.println( "node " + dfn + ", sources already set" );
		return;
	    }

	    int i;
	    int c = 0;
	    for( i = 0; i < target.length; i = i + 1 ) {
		if( target[i] != null ) {
		    c = c + 1;
		}
	    }

	    MNode[] t = new MNode[c];
	    c = 0;
	    for( i = 0; i < target.length; i = i + 1 ) {
		if( target[i] != null ) {
		    t[c] = target[i];
		    c = c + 1;
		}
	    }
	    target = t;

	    if( s == null ) {
		IO.Std.err.println( "node " + dfn + ", s is null" );
		source = new MNode[0];
		return;
	    }

	    source = new MNode[s.getLength()];

	    i = 0;
	    foreach( MNode n; s.elements() ) {
		if( n == null ) {
		    IO.Std.err.println( "oops: init null source: " + this );
		    throw new System.Exception( "oops: init null source: " + this );
		}
		IO.Std.err.println( "node " + dfn + ", setting source #" + i + " to dfn " + n.dfn );
		source[i] = n;
		i = i + 1;
	    }

	    s = null;
	}

        bool calcAdjacent( MBitSet[] matrix, MCandidate[] reg_cost ) {
	    // IO.Std.err.println( "mark adjacent..." );

            // MBitSet seen = new MBitSet( bs_out );       // known live on exit
	    bool result = true;
            MBitSet live = new MBitSet( bs_in );        // known live on entry

            MInst prev, i, next;
            // for( i = tail; i != null; i = prev ) {
            //     prev = i.prev;
            //    i.calcFinal( seen );
            // }

            for( i = inst; i != null; i = next ) {
		next = i.next;
                live.IsChanged = false;
                i.markLive( Mode.READ, live, matrix );
                i.markDead( Mode.READ, live );

		// IO.Std.err.println( "HHHHH: " + i );

		// IO.Std.err.println( "HHHHH: live: " + live );
		if( reg_cost != null ) {
		    // I think there might be more than one sort of clobber - not sure where to put this
		    i.calcClobberCost( reg_cost, live, weight );

		    calcRangeSizes( reg_cost, live, weight );
		}

                live.IsChanged = false;
                i.markLive( Mode.WRITE, live, matrix );
                i.markDead( Mode.WRITE, live );

		// IO.Std.err.println( "calc: " + i );

		if( reg_cost != null ) {
		    i.calcRegCost( this, reg_cost, weight );
		}
		/*
		for( int j = 0; j < reg_cost.length; j = j + 1 ) {
		    if( live.get(j) ) {
			if( reg_cost[j] != null ) {
			    IO.Std.err.print( " T" + j + ": " + Machine.getSetName(reg_cost[j].set) );
			} else {
			    IO.Std.err.print( " T" + j + ": unknown" );
			}
		    }
		}

		IO.Std.err.println(); */
            }

	    return result;
        }

	void calcRangeSizes( MCandidate[] reg_cost, MBitSet live, int weight ) {
	    for( int i = Machine.FIRST_SOFT_REG; i < reg_cost.length; i = i + 1 ) {
		if( live[i] && reg_cost[i] != null ) {
		    reg_cost[i].range = reg_cost[i].range + 1; // FIXME: should be + weight?
		}
	    }
	}


	void calcCopies( MBitSet[] matrix, MBitSet[] copies ) {
            MInst prev, i, next;

            for( i = inst; i != null; i = next ) {
		next = i.next;
		i.calcCopies( matrix, copies );
	    }
	}

	void renameTemps( int[] t, int[] u, System.String why ) {
            MInst prev, i, next;

            for( i = inst; i != null; i = next ) {
		next = i.next;
		i.renameTemp( this, t, u, why );
	    }
	}


	void renameSSATemps() {
            MInst i, next;

            for( i = inst; i != null; i = next ) {
		next = i.next;
		i.renameSSATemps();
	    }
	}

	void countInstructions() {
            for( MInst i = inst; i != null; i = i.next ) {
		MFlow.instruction_count = MFlow.instruction_count + 1;
	    }
	}

	/*
	bool calcRangeSizes( MCandidate[] reg_cost, int node_number ) {
	    IO.Std.err.println( "calc range sizes..." );

	    bool result = true;

            MInst i, next;

            for( i = inst; i != null; i = next ) {
		next = i.next;

		if( !i.calcRangeSizes( reg_cost, node_number ) ) {
		    IO.Std.err.println( "JJJJJJ range size problem" );
		    result = false;
		}
            }

	    return result;
	    }*/

        bool calcRegSets( MCandidate[] reg_cost, MBitSet already_split ) {
	    // IO.Std.err.println( "calc reg sets..." );

	    bool result = true;

            MInst i, next;

            for( i = inst; i != null; i = next ) {
		next = i.next;

		if( !i.calcRegSets( this, reg_cost, already_split ) ) {
		    // IO.Std.err.println( "JJJJJJ register set problem" );
		    result = false;
		}
            }

	    // IO.Std.err.println( "JJJJJJ result is: " + result );
	    return result;
        }

        void removeTail(MInst i) {
	    tail = i;
	    if( tail == null ) {
		throw new System.Exception( "null tail" );
	    }
	    if( tail != null ) {
		// IO.Std.err.println( "remove tail: " + tail );
		if( tail.next != null ) {
		    tail.next.prev = null;
		}
		tail.next = null;
	    }
	    // IO.Std.err.println( "removed tail. tail now: " + tail );
        }

        void calcUse(bool all_definitions) {
	    bs_def.clear();
	    bs_use.clear();
	    MBitSet written = null;
	    if( all_definitions ) {
		written = bs_written;
		written.clear();
	    }
	    // IO.Std.err.println( "MNode: calcUse: " + bs_def.original_size );
            for( MInst i = inst; i != null; i = i.next ) {
		// IO.Std.err.print( "calc use: " + i );
                i.calcUse( bs_def, bs_use, written );
            }

	    // IO.Std.err.println( "calcUse: " + bs_use + "\n" + this );
        }

	void calcFinal() {
	    MBitSet seen = new MBitSet(bs_out);
	    // IO.Std.err.println( "CCCCCC: seen initially: " + seen );
	    // IO.Std.err.println( "calcFinal: out: " + bs_out + " in: " + bs_in );
	    for( MInst i = tail; i != null; i = i.prev ) {
		i.calcFinal(seen);
	    }
        }

	void assignRegisters( int[] regs ) {
	    for( MInst i = tail; i != null; i = i.prev ) {
		i.assignRegisters( regs );
	    }	    
	}

	void dumpTargets( System.StringBuffer b, MNode[] target, System.String name ) {
	    if( target != null ) {
		bool seen_any = false;
		for( int j = 0; j < target.length; j = j + 1 ) {
		    if( target[j] != null ) {
			if( !seen_any ) {
			    b.append( name );
			} else {
			    b.append( ", " );
			}

			b.append( target[j].dfn );		   
			seen_any = true;
		    }
		}

		if( seen_any ) {
		    b.append( '\n' );
		}
	    }
	}

	System.String toString() {
	    System.StringBuffer b = new System.StringBuffer();

	    // throw new System.Exception( "arse" );

	    b.append( "node #" + dfn + "\n" );

	    if( idom != null ) {
		b.append( "idom #" + idom.dfn + "\n" );
	    }

	    if( parent != null ) {
		b.append( "parent #" + parent.dfn + "\n" );
	    }

	    if( semi != null ) {
		b.append( "semi #" + semi.dfn + "\n" );
	    }

	    if( ancestor != null ) {
		b.append( "ancestor #" + ancestor.dfn + "\n" );
	    }

	    dumpTargets( b, source, "sources " );
	    dumpTargets( b, target, "targets " );

	    b.append( "MNode: " + name[0] + "," + name[1] + "\nin: " + bs_in + "\nout: " + bs_out + '\n' );

	    for( MInst i = inst; i != null; i = i.next ) {
		b.append( i );
	    }

	    return b;
	}

	void fixSplits( MCandidate[] candidates, MBitSet new_splits, MBitSet split ) {
            MInst next;
            for( MInst i = inst; i != null; i = next ) {
		next = i.next;

                // IO.Std.err.println( "about to fix up inst: " + i );
                i.fixSplits( this, candidates, new_splits, split );
            }	    
	}

	void fixSpills( MCandidate[] candidates, MBitSet new_spills, MBitSet spilled, CodeGenerator gen ) {	   
            MInst next;
            for( MInst i = inst; i != null; i = next ) {
		next = i.next;

                // IO.Std.err.println( "about to fix up inst: " + i );
                i.fixSpills( this, candidates, new_spills, spilled, gen );
            }

	}

	bool fixClobbered( int[] reg, MCandidate[] could_clobber, int ref local_offset ) {
	    bool result = true;

            MBitSet live = new MBitSet( bs_in );        // known live on entry

            MInst i, next;

            for( i = inst; i != null; i = next ) {
		next = i.next;
                i.markLive( Mode.READ, live, null );
                i.markDead( Mode.READ, live );

                // IO.Std.err.println( "about to fix up inst: " + i );
                if( !i.fixClobbered( this, reg, could_clobber, live, local_offset ) ) {
		    result = false;
		    // IO.Std.err.println( "node now: " + this );
		}

                i.markLive( Mode.WRITE, live, null );
                i.markDead( Mode.WRITE, live );
            }

	    return result;
	}


	bool fixRegSets( int[] reg, MCandidate[] could_need_fixing ) {
	    bool result = true;

            // MBitSet live = new MBitSet( bs_in );        // known live on entry

            MInst i, next;

            for( i = inst; i != null; i = next ) {
		next = i.next;

                // IO.Std.err.println( "about to fix up inst: " + i );
                if( !i.fixRegSets( this, reg, could_need_fixing ) ) {
		    result = false;
		    // IO.Std.err.println( "node now: " + this );
		}
            }

	    return result;
	}

	bool calcSimpleCSE( MNode previous, MExpressionTable expressions ) {
	    bool result = false;

	    if( source == null ) {
		IO.Std.err.println( "oops: node #" + dfn + " has no source array, not reachable?" );
		return false;
	    }

	    bool cleared = false;
	    for( int j = 0; j < source.length; j = j + 1 ) {
		if( source[j] != previous ) {
		    cleared = true;
		    expressions.clear();
		    break;
		}
	    }

	    // expressions.clear();
	    if( cleared ) {
		IO.Std.err.println( "more than one source or source not previous block - clear expression cache" );
	    } else {
		IO.Std.err.println( "retain expression cache" );
	    }

	    MInst next;
	    for( MInst i = inst; i != null; i = next ) {
		next = i.next;
		if( expressions.add( this, i ) ) {
		    result = true;
		}
	    }

	    return result;
	}


	bool calcSimpleJumpElim( MNode previous, MExpressionTable expressions ) {
	    bool result = false;

	    if( source == null ) {
		IO.Std.err.println( "oops: node #" + dfn + " has no source array, not reachable?" );
		return false;
	    }

	    bool cleared = false;
	    for( int j = 0; j < source.length; j = j + 1 ) {
		if( source[j] != previous ) {
		    cleared = true;
		    expressions.clear();
		    break;
		}
	    }

	    // expressions.clear();
	    if( cleared ) {
		IO.Std.err.println( "more than one source or source not previous block - clear expression cache" );
	    } else {
		IO.Std.err.println( "retain expression cache" );
	    }

	    MInst next;
	    for( MInst i = inst; i != null; i = next ) {
		next = i.next;
		if( expressions.add( this, i ) ) {
		    result = true;
		}
	    }

	    return result;
	}

	/*
        bool insertFixups( int[] reg, MBitSet spilled ) {
	    bool result = false;
            MBitSet live = new MBitSet( bs_in );        // known live on entry

            MInst i, next;

            for( i = inst; i != null; i = next ) {
		next = i.next;
                i.markLive( Mode.READ, live, null );
                i.markDead( Mode.READ, live );

                // IO.Std.err.println( "about to fix up inst: " + i );
                if( i.insertFixups( this, reg, live, spilled ) ) {
		    IO.Std.err.println( "node now: " + this );
		}
                i.markLive( Mode.WRITE, live, null );
                i.markDead( Mode.WRITE, live );
            }
        }
	*/

	bool regen( Util.Vector list ) {
	    bool result = false;

	    Util.Vector values = new Util.Vector();

	    MInst next = null;
	    for( MInst i = inst; i != null; i = next ) {
		next = i.next;
		if( i.regen( this, list ) ) {
		    result = true;
		}
	    }

	    return result;
	}

	void peephole( /*int[] reg, MBitSet spilled*/ ) {
            MBitSet live = new MBitSet( bs_in );        // known live on entry

            MInst i;

            for( i = inst; i != null; i = i.next ) {
                i.markLive( Mode.READ, live, null );
                i.markDead( Mode.READ, live );

		// IO.Std.err.println( "about to fix up inst: " + i );
		i.peephole( this, /*reg,*/ live /*, spilled*/ );
                i.markLive( Mode.WRITE, live, null );
                i.markDead( Mode.WRITE, live );
            }
        }
    }

    // represents a single machine instruction. 
    class MInst extends MTree {
	public static int spill_number = 0;
	public static int mem_number = 0;
	public static int split_number = 0;
	public static int copy_number = 0;
	public static int rename_number = 0;
	public static int indirect_number = 0;

	ITree itree;
	
	bool is_effective;
	bool is_killed;
	bool is_spill;
	MSet clobber;
	MOperand[] operands;
	public MInst prev, next;
	System.String pattern;
	System.String comment;
	
	void init( MTree left ) {
	    init(null,left,MSet.None);
	}

	void init( System.String pattern, MTree left ) {
	    init(pattern,left,MSet.None);
	}

	void init( MTree left, MSet clobber ) {
	    init(null,left,clobber);
	}
	
	void init( System.String pattern, MTree left, MSet clobber ) {
	    super.init(0,null,left,null);
	    prev = null;
	    next = null;
	    this.clobber = clobber;
	    this.pattern = pattern;
	    is_effective = true;
	}

	void reset() {
	    is_effective = true;
	    if( operands == null ) {
		return;
	    }
	    // IO.Std.err.print( "reset inst: " + this );
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		operands[i].reset();
	    }
	    // IO.Std.err.println( "inst now: " + this );
	}

	void addComment( System.String c ) {
	    if( comment == null ) {
		comment = c;
	    } else {
		comment = comment + " " + c;
	    }
	}

	void insertAfter( MInst ni ) {
	    ni.initOperands();

            ni.prev = this;
            ni.next = next;
            if( next != null ) {
                next.prev = ni;
            }
            next = ni;
	}

        void insertAfter( MBlock into, MInst ni ) {
            ni.prev = this;
            ni.next = next;
            if( next != null ) {
                next.prev = ni;
            } else {
                into.setTail(ni);
            }
            next = ni;
        }

	void insertBefore( MInst ni ) {
	    ni.initOperands();

            ni.next = this;
            ni.prev = prev;
            if( prev != null ) {
                prev.next = ni;
            }
            prev = ni;
	}

        void insertBefore( MBlock into, MInst ni ) {
            ni.next = this;
            ni.prev = prev;
            if( prev != null ) {
                prev.next = ni;
            } else {
                into.setHead(ni);
            }
            prev = ni;
        }

	/*
	void setName( int t, int n, bool write ) {
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		if( operands[i].temp == t ) {
		    if( write ) {
			if( operands[i].mode & Mode.WRITE != 0 ) {
			    operands[i].ssa_write = n;
			}
		    } else {
			if( operands[i].mode & Mode.READ != 0 ) {
			    operands[i].ssa_read = n;
			}
		    }
		}
	    }
	}
	*/

	MOperand getOperand( int i ) {
	    return operands[i];
	}

	int killWritten( MExpressionTable expressions ) {
	    int result;
	    bool ok = true;

	    for( int j = 0; j < operands.length; j = j + 1 ) {
		MOperand o = operands[j];
		if( o.mode & Mode.WRITE != 0 ) {
		    int t = o.temp;
		    expressions.killTemp(t);

		    if( o.mode & Mode.READ != 0 || result != 0 ) {
			ok = false;
		    } else {
			result = t;
		    }
		}
	    }

	    if( ok ) {
		return result;
	    } else {
		return 0;
	    }
	}

	void clearPhi() {
	    if( left.isPhi() ) {
		System.String s = toString();
		makeComment( "SS phi " + s.substring(0,s.Length-1) );
	    }
	}

	bool clearIneffectivePhi( MBitSet in ) {
      	    if( left.isPhi() && !in[operands[0].temp] ) {
		makeComment( "SS ineffective phi T" + operands[0].temp );
		return true;
	    }
	    return false;	   
	}

	void setTempNamesRHS( Util.IntVector[] temp_stacks ) {
	    for( int j = 0; j< operands.length; j = j + 1 ) {
		if( operands[j].mode & Mode.READ != 0 ) {
		    int t = operands[j].temp;		    
		    if( operands[j].mode & Mode.WRITE != 0 ) {
			IO.Std.err.println( "reads and writes same temp T" + t + ": will break" );
		    }
		    if( t >= Machine.FIRST_SOFT_REG ) {
			// IO.Std.err.println( "read from T" + t );
			if( temp_stacks[t].getLength() > 0 ) {
			    int i = temp_stacks[t].getTop();
			    // IO.Std.err.println( "last assign was to number " + i );
			    operands[j].ssa_read = i;
			} else {
			    IO.Std.err.println( "oops: stack is empty for T" + t );
			}
		    }
		}
	    }
	}

	void setTempNamesLHS( Util.IntVector[] temp_stacks, int[] temp_counts /*, Util.IntVector renamed */ ) {
	    for( int j = 0; j < operands.length; j = j + 1 ) {
		if( operands[j].mode & Mode.WRITE != 0 ) {
		    int t = operands[j].temp;
		    int u;
		    if( t >= Machine.FIRST_SOFT_REG && t < temp_stacks.length ) {
			// IO.Std.err.println( "write to T" + t );
			// int i = TempFactory.nextTemp(); 

			u = TempFactory.nextTemp();
			operands[j].ssa_write = u;
			temp_stacks[t].add( u );
			/*
			renamed.reserve(u+1);
			renamed[u] = t;
			*/

			int i = temp_counts[t];
			// temp_stacks[t].add(i);
			temp_counts[t] = i + 1;
		    } else {
			IO.Std.err.println( "ignoring out of range T" + t );
		    }
		}
	    }
	}

	void setTempNames() {
	    for( int j = 0; j < operands.length; j = j + 1 ) {
		MOperand o = operands[j];
		if( o.ssa_read != 0 ) {
		    o.temp = o.ssa_read;
		} else if( o.ssa_write != 0 ) {
		    o.temp = o.ssa_write;
		}
		for( int k = 0; k < o.mr.length && o.mr[k] != null; k = k + 1 ) {
		    o.mr[k].setTemp(o.temp);
		}
	    }
	}

	void setTempName( int j, int n ) {
	    // IO.Std.err.println( "MINst set temp name " + j + "," + n );
	    left.setTempName( j, n );
	}

	void popTempNames( Util.IntVector[] s ) {
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		if( operands[i].mode & Mode.WRITE != 0 ) {
		    int t = operands[i].temp;
		    if( t >= Machine.FIRST_SOFT_REG && t < s.length ) {
			if( s[t].getLength() > 0 ) {
			    s[t].pop();
			} else {
			    IO.Std.err.println( "oops: popping empty stack for T" + t );
			}
		    } else {
			IO.Std.err.println( "ignoring out of range T" + t );
		    }
		}
	    }
	}

	bool isCall() {
	    return left.isCall();
	}

	bool isJump() {
	    return left.isJump();
	}

	bool isLabel() {
	    return left.isLabel();
	}

	bool isPhi() {
	    return left.isPhi();
	}

	bool isEnterLoop() {
	    return left.isEnterLoop();
	}

	bool isLeaveLoop() {
	    return left.isLeaveLoop();
	}

	bool isCSE() {
	    return left.isCSE();
	}

	System.String getLabel() {
	    return left.getLabel();
	}

	void setITree( ITree t ) {
	    itree = t;
	}

	void initOperands() {
	    // IO.Std.err.print( "MInst: initOperands: " + this.Left.Class.Name + " " + this );
	    initSize();

	    MFindOperands fo = new MFindOperands();
	    this.process(fo);
	    operands = new MOperand[fo.result.getLength()];
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		operands[i] = cast<MOperand>(fo.result[i]);
		// IO.Std.err.println( "operand " + i + ": " + operands[i] );
	    }
	}

	bool readsTemp( int t ) {
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		if( operands[i].temp == t && operands[i].mode & Mode.READ != 0 ) {
		    return true;
		}
	    }

	    return false;
	}

	int getWrittenTemp() {
	    int result;

	    for( int i = 0; i < operands.length; i = i + 1 ) {
		if( operands[i].temp > 0 && operands[i].mode & Mode.WRITE != 0 ) {
		    if( result != 0 ) {
			IO.Std.err.println( "instruction writes more than one register - not considering for CSE" );
		    }
		    result = operands[i].temp;
		}
	    }

	    // IO.Std.err.println( "written temp T" + result );
	    return result;
	}

	/*
	bool writesTemp( int t ) {
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		if( operands[i].temp == t && operands[i].mode & Mode.WRITE != 0 ) {
		    return true;
		}
	    }

	    return false;
	}
	*/

	bool writesMemory() {
	    return left.isCall() || left.writesMemory();
	}

	bool readsMemory() {
	    return left.isCall() || left.readsMemory();
	}
	// void findOperands( Util.Vector v ) {
	//     left.findOperands(v);
	// }

	int getTemp() {
	    return left.getTemp();
	}
    
	int getReg() {
	    return left.getReg();
	}

	MTree flatten( MFlatten f ) {
	    // IO.Std.err.println( "adding MInst: " + this );
	    f.add( this );
	    // IO.Std.err.println( "flattening MInst gives null result" );
	    return null;
	}

	System.String toString() {
	    int i;
	    if( left == null ) {
		return "# null instruction";
	    }

	    System.StringBuffer b = new System.StringBuffer();

	    if( !is_effective ) {
		b.append( "                                 " );
		b.append( "# not effective " );
	    }

	    if( pattern == null ) {
		System.String s = left.toString();

		if( s == null ) {
		    IO.Std.err.println( "non null instruction has null representation" );
		    return "# null instruction";
		}

		bool seen_comment = false;
		for( i = 0; i < 2 && i < s.getLength(); i = i + 1 ) {
		    if( s.charAt(i) == '#' ) {
			b.append( "                                 " );
			seen_comment = true;
			break;
		    }
		}

		if( !seen_comment && s.charAt(0) != '.' ) {
		    b.append( "        " );
		}

		b.append( s );

	    } else {
		for( int j = 0; j < pattern.getLength(); j = j + 1 ) {
		    if( pattern.charAt(j) == '?' ) {
			j = j + 1;
			if( pattern.charAt(j) == 'l' ) {
			    b.append( left.left );
			} else if( pattern.charAt(j) == 'r' ) {
			    b.append( left.right );
			} else if( pattern.charAt(j) == 'd' ) {
			    b.append( left.dest );
			} else {
			    b.append( pattern.charAt(j) );
			}
		    } else {
			b.append( pattern.charAt(j) );
		    }
		}
	    }



	    if( (operands != null && operands.length > 0) || clobber != MSet.None || comment != null ) {
		while( b.getLength() < 32 ) {
		    b.append( ' ' );
		}
		b.append( " # " );
	    }

	    for( i = 0; operands != null && i < operands.length; i = i + 1 ) {
		b.append( operands[i] );
		if( i < operands.length - 1 ) {
		    b.append( ' ' );
		}
	    }

	    if( clobber != MSet.None ) {
		b.append( " clobber " + MOperand.setString(clobber) + " " );
	    }

	    if( comment != null ) {
		b.append( comment );
	    }

	    b.append( '\n' );

	    return b;
	}
    
	System.String dump() {
	    return "MInst(" + left.dump() + ")";
	}

	/*
	void calcReadWrite( IO.Writer f, MBitSet read, MBitSet write ) {
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		int t = operands[i].temp;
		if( t != 0 ) {
		    if( operands[i].mode & Mode.READ != 0 ) {
			read.set( t );
		    }
		    if( operands[i].mode & Mode.WRITE != 0 ) {
			write.set( t );
		    }
		}
	    }
	}
	*/


	void calcClobberCost( MCandidate[] reg_cost, MBitSet live, int weight ) {
	    int sr = 0, tr = 0, i;

	    int j;

	    if( clobber != MSet.None ) {
		int m = Machine.getMaskForSet( clobber, Machine.clobber_mask );

		// IO.Std.err.println( "clobber set is " + cast<int>(clobber) );
		// IO.Std.err.print( "clobbers " + System.String.hex(m) + ": " + this );
		
		for( i = Machine.FIRST_SOFT_REG; i < reg_cost.length; i = i + 1 ) {
		    if( live[i] && reg_cost[i] != null  ) {
			bool could_clobber = true;
			for( j = 0; j < operands.length; j = j + 1 ) {
			    if( operands[j].temp == i ) {
				// register sets on arguments will prevent a genuine clobber of any argument:
				// IO.Std.err.println( "cannot clobber T" + i + ": referenced by instruction" );
				could_clobber = false;
				break;
			    }
			}

			if( could_clobber ) {			
			    // IO.Std.err.println( "T" + i + " is live" );
			    
			    reg_cost[i].cost = reg_cost[i].cost + weight;
			    reg_cost[i].markClobber( clobber );
			}
		    }
		}
	    }
	}
	
	/*
        void calcClobberCost( int[][] reg_cost, MBitSet live, int weight ) {


            if( clobber != MSet.None ) {
                int m = Machine.getMaskForSet( clobber, Machine.clobber_mask );
                for( int i = Machine.FIRST_SOFT_REG; i < live.original_size; i = i + 1 ) {
                    if( live.get(i) ) {
                        for( int j = Machine.FIRST_MACHINE_REG; j <= Machine.LAST_MACHINE_REG; j = j + 1 ) {
                            if( m & (1 << j) != 0 ) {
                                reg_cost[i][j] = reg_cost[i][j] + Machine.COST_CLOBBER * weight;
                            }
                        }
                    }
                }
            }
        }
	*/

	void makeComment(System.String text) {
	    left = new MData( Op.COMMENT, new MConst( text ) );
	    initOperands();
	}

	void makeCopy( MNode into, int size, int t, int u ) {
	    MInst s;
	    MSet copy_set = MSet.General;
	    int copy_op = Op.COPY | ITree.getSizeMask(Machine.WORD);
	    
	    s = new MInst( new MMove( copy_op,
				      new MReg( t, copy_set ),
				      new MReg( u, copy_set )
				      )

			   );
	    s.initOperands();
	    insertAfter( into, s );
	}

	bool spillTemp( MNode into, MOperand o, int t, int u, int offset, CodeGenerator gen, bool direct_memory ) {
	    MInst s;
	    MReplaceTemp rt;
	    spill_number = spill_number + 1;

	    if( direct_memory && itree != null ) {
		ITree it = IBlock.replaceTempWithMemory( itree, t, offset );

		MInst mt = gen.genSingleInstruction( it );

		if( mt != null ) {
		    mt.setITree( it );
		    insertAfter( into, mt );
		    mt.initOperands();
		    makeComment( "SS converteds spilled T" + t + " to memory reference at offset " + offset );

		    mem_number = mem_number + 1;
		    return true; // re-wrote rather than spilled
		}
	    }

	    int size = Machine.WORD; // FIXME...

	    int copy_op = Op.COPY | ITree.getSizeMask(Machine.WORD);
	    int add_op = Op.ADD | ITree.getSizeMask(Machine.WORD);

	    MSet copy_set;
	    /*
	    if( size == 8 ) {
		copy_op = Op.COPY_8;
	    } else if( size == 4 ) {
		copy_op = Op.COPY_4;
	    } else if( size == 1 ) {
		copy_op = Op.COPY_1;
	    } else {
		throw new RegisterException( "cannot spill T" + t + " of unexpected size " + size );
	    }
	    */
	    copy_set = MSet.General;

	    // IO.Std.err.println( "rset: " + Machine.getSetName( o.rset ) + " is size: " + size + ", copy set: " + Machine.getSetName(copy_set) );

	    if( o.mode & Mode.READ != 0 ) {
		s = new MInst( new MData( Op.COMMENT, new MConst( "SS " + size + " fill T" + t + " -> T" + u + " at offset " + offset ) ) );
		s.initOperands();
		insertBefore( into, s );
		
		s = new MInst( new MMove( copy_op,
					  new MReg( u, copy_set ),
					  new MIndirect( new MAddress(
								      new MBase(
										add_op,
										new MConst( offset ),
										new MReg( 7 )
										),
								      null
								      )
							 )
					  )
			       );
		s.initOperands();
		insertBefore( into, s );
	    }

	    if( o.mode & Mode.WRITE != 0 ) {
		s = new MInst( new MData( Op.COMMENT, new MConst( "SS " + size + " spill T" + u + " -> T" + t + " at offset " + offset ) ) );
		s.initOperands();
		insertAfter( into, s );
		s = new MInst( new MMove( copy_op,
					  new MIndirect( new MAddress(
								      new MBase(
										add_op,
										new MConst( offset ),
										new MReg( 7 )
										),
								      null
								      )
							 ),
					  new MReg( u, copy_set )
					  )
			       );
		
		s.initOperands();
		insertAfter( into, s );
	    }



	    // if( replace ) {
		rt = new MReplaceTemp( t, u );
		process(rt);
		initOperands();
		if( itree != null ) {
		    itree = IBlock.replaceSplitTemp( itree, t, u );
		}
		// }	

	    // if( o.mode & Mode.READ != 0 ) {


	    // IO.Std.err.println( "JJJJJJ: spill: T" + t + "->local@" + offset );

	    return false;
	}


	void splitTemp( MNode into, MOperand o, int t, int u, bool replace, System.String why ) {
	    MInst s;
	    MReplaceTemp rt;

	    // int offset = 72;

	    // IO.Std.err.println( "split temp T" + t + " with new temp T" + u );

	    MSet copy_set = MSet.General;

	    int copy_op = Op.COPY | ITree.getSizeMask(Machine.WORD);
	    // int add_op = Op.ADD | ITree.getSizeMask(Machine.WORD);


	    /*
	    if( o != null ) {
		int size = 8;
		if( size == 8 ) {
		    copy_op = Op.COPY_8;
		} else if( size == 4 ) {
		    copy_op = Op.COPY_4;
		} else if( size == 1 ) {
		    copy_op = Op.COPY_1;
		} else {
		    throw new RegisterException( "cannot split T" + t + " in unexpected set " + Machine.getSetName(o.rset) + " of size " + size );
		}
	    }
	    */

	    if( o == null || o.mode & Mode.READ != 0 ) {
		s = new MInst( new MData( Op.COMMENT, new MConst( "SS split T" + t + " -> T" + u + " " + why ) ) );
		s.initOperands();
		
		insertBefore( into, s );

		if( t > 0 ) {
		    s = new MInst( new MMove( copy_op, new MReg( u, copy_set ), new MReg( t, copy_set ) ) );
		} else {
		    throw new RegisterException( "split into memory" );
		    /*
		    s = new MInst( new MMove( Op.COPY_8,
					      new MReg( t, MSet.Int8 ),
					      new MIndirect( new MAddress(
									  new MBase(
										    Op.ADD_8,
										    new MConst( offset ),
										    new MReg( 7 )
										    ),
									  null
									  )
							     )
					      )
					      ); */
		}
		s.initOperands();    
		insertBefore( into, s );
	    }

	    if( o == null || o.mode & Mode.WRITE != 0 ) {
		s = new MInst( new MData( Op.COMMENT, new MConst( "SS split T" + u + " <- T" + t + " " + why ) ) );
		s.initOperands();
		
		insertAfter( into, s );

		if( t > 0 ) {
		    s = new MInst( new MMove( copy_op, new MReg( t, copy_set ), new MReg( u, copy_set ) ) );
		} else {
		    throw new RegisterException( "split into memory" );
		    /*
		    s = new MInst( new MMove( Op.COPY_8,
					      new MIndirect( new MAddress(
									  new MBase(
										    Op.ADD_8,
										    new MConst( offset ),
										    new MReg( 7 )
										    ),
									  null
									  )
							     ),
					      new MReg( t, MSet.Int8 )
					      )
				   );
		    */
		}

		s.initOperands();
		insertAfter( into, s );
	    }

	    if( replace ) {
		rt = new MReplaceTemp( t, u );
		process(rt);
		initOperands();

		if( itree != null ) {
		    itree = IBlock.replaceSplitTemp( itree, t, u );
		}
	    }

	    split_number = split_number + 1;

	    // IO.Std.err.println( "JJJJJJ: problem register set change - need to split live range here: T" + t + "->T" + u );
	}
	
	// temporarily save a temporary to memory that would otherwise be clobbered by this instruction:
	void saveTemp( MNode into, int t, int offset, System.String reason ) {
	    MInst s;

	    int size = 8; // left.Size; // FIXME: may not be correct?

	    int copy_op = Op.COPY | ITree.getSizeMask(Machine.WORD);
	    int add_op = Op.ADD | ITree.getSizeMask(Machine.WORD);

	    MSet copy_set = MSet.General;

	    /*
	    if( size == 8 ) {
		copy_op = Op.COPY_8;
	    } else if( size == 4 ) {
		copy_op = Op.COPY_4;
	    } else if( size == 1 ) {
		copy_op = Op.COPY_1;
	    } else {
		throw new RegisterException( "cannot spill T" + t + " of unexpected size " + size );
	    }
	    */

	    MReg r1, r2;

	    if( t < Machine.FIRST_SOFT_REG ) {
		r1 = new MReg( t );
		r2 = new MReg( t );
	    } else {
		r1 = new MReg( t, copy_set );
		r2 = new MReg( t, copy_set );
	    }

	    s = new MInst( new MData( Op.COMMENT, new MConst( "SS " + size + " save T" + t + " at offset " + offset + " because " + reason ) ) );
	    s.initOperands();
	    insertBefore( into, s );
	    s = new MInst( new MMove( copy_op,
				      new MIndirect( new MAddress(
								  new MBase(
									    add_op,
									    new MConst( offset ),
									    new MReg( 7 )
									    ),
								  null
								  )
						     ),
				      r1
				      )
			   );
	    
	    s.initOperands();
	    insertBefore( into, s );
	


	    s = new MInst( new MData( Op.COMMENT, new MConst( "SS " + size + " restore T" + t + " at offset " + offset + " because " + reason ) ) );
	    s.initOperands();
	    insertAfter( into, s );
	    
	    s = new MInst( new MMove( copy_op,
				      r2,
				      new MIndirect( new MAddress(
								  new MBase(
									    add_op,
									    new MConst( offset ),
									    new MReg( 7 )
									    ),
								  null
								  )
						     )
				      )
			   );
	    s.initOperands();
	    insertAfter( into, s );

	    spill_number = spill_number + 1;
	}


	void renameSSATemps() {
	    MReplaceTemp rt;
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		MOperand o = operands[i];
		if( o.ssa_write != 0 || o.ssa_read != 0 ) {
		    int t = o.temp;
		    int u;
		    if( o.ssa_write != 0 ) {
			u = o.ssa_write;
		    }
		    if( o.ssa_read != 0 ) {
			if( u != 0 ) {
			    IO.Std.err.println( "this isn't going to work..." );
			    continue;
			}

			u = o.ssa_read;
		    }

		    rt = new MReplaceTemp( t, u );
		    process(rt);
		    initOperands();
		    
		    if( itree != null ) {
			itree = IBlock.replaceSplitTemp( itree, t, u );
		    }
		}
	    }
	}

	void renameTemp( MNode into, MOperand o, int t, int u, System.String why ) {
	    MInst s;
	    MReplaceTemp rt;
	    // int offset = 72;

	    // IO.Std.err.println( "rename temp T" + t + " to new temp T" + u );

	    /*
	    s = new MInst( new MData( Op.COMMENT, new MConst( "SS rename T" + t + " -> T" + u + " " + why ) ) );
	    s.initOperands();
	    
	    insertBefore( into, s );
	    */

	    rt = new MReplaceTemp( t, u );
	    process(rt);
	    initOperands();

	    if( itree != null ) {
		itree = IBlock.replaceSplitTemp( itree, t, u );
	    }

	    rename_number = rename_number + 1;

	    if( left == null || !left.isCopy() ) {
		// IO.Std.err.println( "peephole not copy" );
		return;
	    }
		 
	    if( left.dest == null || left.left == null ) {
		// IO.Std.err.println( "wrong structure" );
		return;
	    }
	    if( left.dest.isReg() && left.left.isReg() &&
		left.dest.getTemp() == left.left.getTemp() ) {
		MInst.copy_number = MInst.copy_number + 1;

		makeComment( "SS removed redundant copy T" + t );
	    }

	    // IO.Std.err.println( "JJJJJJ: problem register set change - need to split live range here: T" + t + "->T" + u );
	}

	void renameTemp( MNode into, int[] t, int[] u, System.String why ) {
	    
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		MOperand o = operands[i];
		for( int j = 0; j < t.length; j = j + 1 ) {
		    int tt = t[j];
		    int uu = u[j];
		    // IO.Std.err.println( "T" + o.temp + "==T" + t + "?" );
		    if( o.temp == tt ) {
			// IO.Std.err.print( "inst rename temp " + tt + "->" + uu + ": " + this );
			renameTemp( into, o, tt, uu, why );
		    }
		}
	    }
	}

	/*
        bool calcRangeSizes( MCandidate[] reg_cost, int node_number ) {
	    bool result = true;
	    int t, i, j;

	    for( i = 0; i < operands.length; i = i + 1 ) {
		t = operands[i].temp;

		if( t != 0 ) {
		    // IO.Std.err.println( "count range for T" + " in node #" + node_number );
		    if( reg_cost[t] == null ) {
			reg_cost[t] = new MCandidate( operands[i] );
		    }
		    
		    if( reg_cost[t].last_node != node_number ) {
			// IO.Std.err.println( "RRRRRR: increment range size for T" + t );
			
			reg_cost[t].range = reg_cost[t].range + 1;
			reg_cost[t].last_node = node_number;
		    }
		}
	    }
	    // IO.Std.err.println( "JJJJJJ: reg cost result: " + result );
	    return result;
        }
	*/

	void calcCopies( MBitSet[] matrix, MBitSet[] copied ) {
	    if( left == null ) {
		return;
	    }

	    /*
	    if( left.dontCoalesce() ) {
		for( int i = 0; i < operands.length; i = i + 1 ) {
		    dont_coalesce.set(operands[i].temp);
		}

		return;
	    }
	    */
	    
	    if( !left.isCopy() ) {
		return;
	    }

	    if( left.dest == null || left.left == null ) {
		throw new System.Exception( "OOOOOO: oops: oddly shaped copy instruction: " + this );
	    }

	    // IO.Std.err.println( "copy: " + this );

	    if( left.dest.isReg() && left.left.isReg() ) {
		int t, u;
		t = left.dest.getTemp();
		u = left.left.getTemp();
		// IO.Std.err.println( "SSSSSS: register-to-register copy" );

		if( t > 0 && u > 0 ) {
		    // IO.Std.err.println( "SSSSSS: potential register share after copy: T" + t + " -> T" + u );

		    if( !matrix[t][u] ) {
			// IO.Std.err.println( "SSSSSS: temporaries do not interfere - marking for preferred same register" );
			copied[t].mark(u);
		    }
		}
	    }
	}

        bool calcRegCost( MNode into, MCandidate[] reg_cost, int weight ) {
	    bool result = true;
	    int i, j, t, u, m;
	    MSet rset;
	    // MReplaceTemp rt;
	    // try {
		for( i = 0; i < operands.length; i = i + 1 ) {
		    t = operands[i].temp;
		    if( t == 0 ) {
			// IO.Std.err.println( "ignoring operand T0 R" + operands[i].reg );
			continue;
		    }

		    /*		        
		    // IO.Std.err.println( "operand  " + i + ": T" + t + ", mode " + operands[i].mode );
		    if( t != 0 && operands[i].mode != 0 ) {
			rset = operands[i].rset;
			// IO.Std.err.println( "T" + t + " set for this reference " + Machine.getSetName(rset) );

			if( reg_cost[t] == null ) {
			    reg_cost[t] = new MCandidate( operands[i] );
			} else {
			    // IO.Std.err.println( "T" + t + " current set is " + Machine.getSetName(reg_cost[t].set) );

			    reg_cost[t].set = Machine.getRegSetIntersection( reg_cost[t].set, rset ); 

			    // IO.Std.err.println( "T" + t + " intersection set is " + Machine.getSetName(reg_cost[t].set) );
			    if( reg_cost[t].set == MSet.None ) {
				IO.Std.err.println( "register set change to incompatible set: will require a split" );
				u = TempFactory.nextTemp();
				
				splitTemp( into, operands[i], t, u, true, " register set change" );

				result = false;
			    } else {
				m = Machine.getMaskForSet( rset, Machine.reg_mask );
				// IO.Std.err.println( "mask for this reference: " + m );
				m = reg_cost[t].mask & m;

				// IO.Std.err.println( "mask for intersection: " + m );

				if( m == 0 ) {
				    IO.Std.err.println( "no register can hold this temporary for its entire lifetime: will require a split" );
				    u = TempFactory.nextTemp();
				        
				    splitTemp( into, operands[i], t, u, " register set change" );
				        
				    result = false;
				} else {
				    reg_cost[t].mask = m;
				}
			    }
			} }
		    */

		    if( reg_cost[t] == null ) {
			reg_cost[t] = new MCandidate( operands[i] );
		    }
		    reg_cost[t].refs = reg_cost[t].refs + weight;
		}

		// } catch( RegisterException re ) {
		// IO.Std.err.println( "JJJJJJ: register set problem: " + this );
		// throw re;
		// }

	    // IO.Std.err.println( "JJJJJJ: reg cost result: " + result );
	    return result;
        }


	bool calcRegSets( MNode into, MCandidate[] reg_cost, MBitSet already_split ) {
            bool result = true;
            int i, j, t, u, m;
            MSet rset;
            // MReplaceTemp rt;
            // try {

	    //  IO.Std.err.print( "calc reg sets: " + this );
                
            for( i = 0; i < operands.length; i = i + 1 ) {
                MOperand o = operands[i];

		// IO.Std.err.println( "operand: " + o );
                t = o.temp;
                
                if( t != 0 && o.mode != 0 ) {
                    rset = o.rset;
                    
                    if( reg_cost[t] == null ) {
                        reg_cost[t] = new MCandidate( operands[i] );
                    } else {                      
			// IO.Std.err.println( "operand set is          " + Machine.getSetName( rset ) );
			// IO.Std.err.println( "current set is          " + Machine.getSetName( reg_cost[t].Set ) );

                        rset = Machine.getRegSetIntersection( reg_cost[t].Set, rset ); 
			// IO.Std.err.println( "CCCCCC: intersection is " + Machine.getSetName( rset ) );
                        
                        if( already_split != null ) {
                            if( rset == MSet.None ) {
                                already_split.reserve(t);
                                if( already_split[t] ) {
                                    throw new RegisterException( "already split T" + t + ": " + this );
                                }
                                u = TempFactory.nextTemp();
                                already_split.reserve(u);
                                already_split.mark(u);
                                splitTemp( into, o, t, u, true, "register set change (A)" );
                                
                                result = false;
                            } else {
				reg_cost[t].Set = rset;
			    }

			    /* else {            
                                m = Machine.getMaskForSet( rset, Machine.reg_mask );
                                int n = reg_cost[t].mask & m;
                                
                                if( n == 0 ) {
                                    already_split.reserve(t);
                                    if( already_split[t] ) {
                                        throw new RegisterException( "already split T" + t + ": " + this );
                                    }

                                    u = TempFactory.nextTemp();
                                    already_split.reserve(u);
                                    already_split.set(u);
                                    splitTemp( into, o, t, u, true, "register set change (B)" );
                                    
                                    result = false;
                                } else {
                                    reg_cost[t].Set = rset;
                                    reg_cost[t].mask = n;
				    } */

			    // }
                        } else {
                            reg_cost[t].Set = rset;
                        }
                    }
                }
            }
            //} catch( RegisterException re ) {
            //IO.Std.err.println( "JJJJJJ: register set problem: " + this );
            //throw re;
            //}
            
            // IO.Std.err.println( "JJJJJJ: reg set result: " + result );
            return result;
        }



	void calcUse( MBitSet def, MBitSet uze, MBitSet written ) {
	    int i, t;
	    // IO.Std.err.println( "calcUse: " + this );
	    for( i = 0; i < operands.length; i = i + 1 ) {
		t = operands[i].temp;
		if( t == 0 ) {
		    t = operands[i].reg;
		}
		if( t != 0 ) {
		    if( operands[i].mode & Mode.READ != 0 ) {
			if( !def[t] ) {
			    uze.mark( t );
			}
		    }
		}
	    }
	
	    for( i = 0; i < operands.length; i = i + 1 ) {
		t = operands[i].temp;
		if( t == 0 ) {
		    t = operands[i].reg;
		}
		if( t != 0 ) {
		    if( operands[i].mode & Mode.WRITE != 0 ) {
			if( written != null ) {
			    written.mark( t );
			}
			if( !uze[t] ) {
			    def.mark( t );
			}
		    }
		}
	    }
	}


        void calcFinal( MBitSet seen ) {
            int i;
            
	    // IO.Std.err.println( "CCCCCC: seen now: " + seen );
	    // IO.Std.err.print( "CCCCCC: calc final: " + this );

            // instructions never reference the same temporary more than once so read-write order is not important here
	    // IO.Std.err.println( "calc final: " + this + ", seen: " + seen );
            
            for( i = 0; i < operands.length; i = i + 1 ) {
                if( operands[i].mode != 0 ) {
                    operands[i].calcFinal( seen );
                }
            }

	    // IO.Std.err.print( "CCCCCC: result is:  " + this );

	    //  markEffective();
        }

	void markEffective() {
	    /*
	    if( left == null || !left.isCopy() ) {
		return;
	    }
	    
	    // IO.Std.err.println( "checking: " + this );

	    if( left.dest == null || !left.dest.isReg() ) {
		// IO.Std.err.println( "dest is not a register" );
		return;
	    }

	    int d = left.dest.getTemp();
	    */

	    // IO.Std.err.print( "mark effective: " + this );

	    if( !is_effective || operands.length == 0 ) {
		// IO.Std.err.println( "no operands" );
		// no operands - assumed effective
		return;
	    }

	    bool all_reads = true;
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		if( operands[i].temp <= Machine.LAST_MACHINE_REG ) {
		    // references machine register: assumed effective
		    return;
		}

		int m = operands[i].mode;
		if( m & Mode.WRITE != 0 ) {
		    if( m & Mode.FINAL == 0 ) {	
			// IO.Std.err.println( "non-final write" );
			// writes a temporary that is subsequently used: is effective
			return;
		    }
		    all_reads = false;
		}
	    }

	    /*
	    if( !all_reads ) {
		IO.Std.err.print( "XXXXXXX: all writes are final - not effective: " + this );
	    }
	    */
	    is_effective = all_reads;
	}
        
        void markLive( int u, MBitSet seen, MBitSet[] matrix ) {
            int i;

	    if( left != null ) {
		left.markLive( u, seen, matrix );
	    }
            
            // IO.Std.err.println( "mark live: " + this );


            for( i = 0; i < operands.length; i = i + 1 ) {
		MOperand o = operands[i];
                if( o.mode & u != 0 ) {
                    o.markLive( seen, matrix );
                }
            }
        }
        
        void markUsed( MBitSet seen ) {
            int i;
            
            for( i = 0; i < operands.length; i = i + 1 ) {
		int t = operands[i].temp;
		if( t == 0 ) {
		    t = operands[i].reg;
		}
                if( t != 0 && operands[i].mode & Mode.MASK_USE != 0 ) {
                    seen.mark( t );
                }
            }
        }
        
        void markDead( int u, MBitSet seen ) {
            int i;
            
            for( i = 0; i < operands.length; i = i + 1 ) {
                if( operands[i].mode & u != 0 && operands[i].mode & Mode.FINAL != 0 ) {
                    operands[i].markDead( seen );
                }
            }
        }

	void assignRegisters( int[] reg ) {
	    for( int i = 0; i < operands.length; i = i + 1 ) {
		operands[i].assignRegister( reg );
	    }
	    // IO.Std.err.println( "assign: " + this );
	}

	void assignSegment( Util.Vector stack ) {
	    left.assignSegment( stack );
	}

	/*
	void spillSingleRegTemp( MNode into, int temp, int reg, MBitSet already_spilled ) {
	    int r, t, u, i;
	    for( i = 0; i < operands.length; i = i + 1 ) {
		MOperand o = operands[i];
		t = o.temp;
		if( t == temp ) {


		    r = Machine.getSingleReg( o.rset );

		    IO.Std.err.print( "maybe split T" + temp + "R" + r + " here: " + this );

		    // r will be zero if not single reg set
		    // reg will be zero if we want to match not single reg set

		    if( r != 0 ) {
			u = TempFactory.nextTemp();
			already_split.reserve(u);
			already_split.set(u);
			IO.Std.err.println( "split into T" + u );
			splitTemp( into, o, t, u, true, "single reg" );
		    }
		}
	    }
	}
*/


	void fixSpills( MNode into, MCandidate[] candidates, MBitSet new_spills, MBitSet spilled, CodeGenerator gen ) {
	    bool direct_memory = true;
	    int count = 0;
	    int i, j, u, t;

	    for( i = 0; i < operands.length; i = i + 1 ) {
		t = operands[i].temp;
		if( spilled[t] ) {
		    count = count + 1;
		}
	    }

	    if( count == 0 ) {
		return;
	    } else if( count > 1 ) {
		direct_memory = false;
	    }

	    for( i = 0; i < operands.length; i = i + 1 ) {
		t = operands[i].temp;
		if( spilled[t] ) {
		    MCandidate c = candidates[t];
		    assert( c.temp == t );

		    u = TempFactory.nextTemp();

		    // IO.Std.err.println( "will spill T" + t + " using T" + u + " as temporary" );
		    /*
		      if( t < new_spills.Length ) {
		      IO.Std.err.println( "already spilled: T" + t + "=" + new_spills[t] );
		      }
		    */
		    // IO.Std.err.println( "already spilled: " + new_spills );
		    
		    if( t < new_spills.Length && new_spills[t] ) {
			throw new RegisterException( "already spilled T" + t );
		    }


		    if( !spillTemp( into, operands[i], t, u, c.offset, gen, direct_memory ) ) {
			// IO.Std.err.println( "AAAAAA: should not attempt to spill T" + u + " again" );
			new_spills.reserve(u);
			new_spills.mark(u);
		    }
		}
	    }
	}


	void fixSplits( MNode into, MCandidate[] candidates, MBitSet new_splits, MBitSet split ) {
	    int i, j, u, t;

	    for( i = 0; i < operands.length; i = i + 1 ) {
		MOperand o = operands[i];
		t = o.temp;
		if( split[t] ) {
		    MCandidate c = candidates[t];
		    assert( c.temp == t );

		    int r = Machine.getSingleReg( o.rset );
		    if( r != c.reg ) {
			// IO.Std.err.println( "do not need to split T" + t + " for operation not requiring fixed register R" + c.reg );
			continue;
		    } 			

		    u = TempFactory.nextTemp();
		    // IO.Std.err.println( "will actually split T" + t + " for operation requiring R" + r );

		    if( t < new_splits.Length && new_splits[t] ) {
			throw new RegisterException( "already split T" + t );
		    }
		    
		    splitTemp( into, operands[i], t, u, true, "interferes with another temporary requiring R" + r );
		    new_splits.reserve(u);
		    new_splits.mark(u);
		}
	    }
	}


    
        bool fixClobbered( MNode into, int[] reg, MCandidate[] could_clobber, MBitSet live, int ref local_offset ) {
	    bool result = true;
	    
            int i, t, r, m, n, u;
	    MSet rset;
            int clobber_mask = Machine.getMaskForSet( clobber, Machine.clobber_mask );

	    // IO.Std.err.println( "live now: " + live.toString(reg) );
	    // IO.Std.err.println( "fixing clobbered: " + this );

	    if( clobber_mask != 0 && could_clobber != null ) {
		for( i = 0; i < could_clobber.length; i = i + 1 ) {
		    MCandidate c = could_clobber[i];
		    t = c.temp;

		    r = reg[t];
		    if( r != 0 && live[t] ) {
		        m = 1 << r;
			// IO.Std.err.println( "checking masks " + System.String.hex(m) + " & "+  System.String.hex(clobber_mask) + " = " + System.String.hex(m & clobber_mask) );
			if( clobber_mask & m != 0 ) {
			    if( local_offset == 0 ) {
				local_offset = local_offset + Machine.WORD;
			    }

			    if( c.offset == 0 ) {
				c.offset = local_offset;
				local_offset = local_offset + Machine.WORD;
			    }

			    // IO.Std.err.println( "CCCCCC: split T" + t + " in R" + r + " into memory because clobbered by: " + this );

			    saveTemp( into, r, c.offset, "clobbered" );
			    result = false;
			}
		    } 
		}
	    }

	    return result;
        }

        bool fixRegSets( MNode into, int[] reg, MCandidate[] could_need_fixing ) {
	    bool result = true;
	    
            int i, j, t, r, m, n, u;
	    MSet rset;

	    // IO.Std.err.print( "fixup: " + this );
	    for( i = 0; i < operands.length; i = i + 1 ) {
		rset = operands[i].rset;
		t = operands[i].temp;
		
		if( t != 0 ) {
		    r = reg[t];
		    if( r != 0 ) {
			n = 1 << r;
			m = Machine.getMaskForSet( rset );

			if( m & n == 0 ) {
			    /*
			    bool expected = false;
			    if( could_need_fixing != null ) {
				for( j = 0; j < could_need_fixing.length; j = j + 1 ) {
				    if( could_need_fixing[j].temp == t ) {
					expected = true;
				    }
				}
			    }

			    if( !expected ) {
				IO.Std.err.println( "did not expect to have to split T" + t );
			    }

			    IO.Std.err.println( "set is          " + Machine.getSetName(rset) );
			    IO.Std.err.println( "r is            " + r );
			    IO.Std.err.println( "n is            " + System.String.hex(m) );
			    IO.Std.err.println( "m is            " + System.String.hex(n) );
			    IO.Std.err.println( "intersection is " + System.String.hex(m & n) );
			    */

			    u = TempFactory.nextTemp();

			    splitTemp( into, operands[i], t, u, true, "wrong register set (C)" );
			    result = false;
			}
			/*
		    } else {
		    IO.Std.err.println( "fixup T" + t + "0: " + this ); */
		    }
		}
	    }

	    return result;
        }

/*

each operand has a temporary and a register
the temporary is either live or dying
the temporary either has an acceptable register or an unacceptable register (or no register at all)

each temporary without an acceptable register needs to be given one

exhaustive fixup

for each operand
    temporary might be in chosen register
    temporary might be in a different register
        
    temporary might be in memory

*/

	bool peephole( MNode into, /* int[] reg,*/ MBitSet live /*, MBitSet spilled*/ ) {

	    // IO.Std.err.println( "peephole: " + this );
	    /*
	    MInst ni;
	    MInst top = this;
	    MInst bottom = this;
	    
	    bool needs_recolor = false;
	    bool needs_fixup = false;
	    int occupied = 0;
	    
	    int next_fixup = 0;
	    int i;
	    MFixup[] fixups = new MFixup[operands.length * 3];
	    
	    if( op == Op.SAVE_ALL || op == Op.RESTORE_ALL ) {
		for( i = Machine.FIRST_SOFT_REG; i <= TempFactory.getCurrentTemp(); i = i + 1 ) {
		    if( live.get(i) && reg[i] != 0 ) {
			if( Machine.CALL_PRESERVE & (1 << reg[i]) == 0 ) {
			    // spilled.set( i );
			    IO.Std.err.println( "save/restore T" + i + " in R" + reg[i] );

			    int k;
			    if( op == Op.SAVE_ALL ) {
				k = MFixup.FORWARD;
			    } else {
				k = MFixup.BACKWARD;
			    }
			    fixups[next_fixup] = new MFixup(MFixup.SPILL, k, i, reg[i], i, 0, false );
			    next_fixup = next_fixup + 1;
			}
		    }
		}
		} else */

	    markEffective();

	    if( !is_effective || /* is_killed || */ operands.length == 0 ) { // && clobber == MSet.None) /* || is_spill */ ) {
		return false;
	    //} else {
	    //	IO.Std.err.println( "fixups may be required" );
	    }

	    /*
	
	    int clobber_mask = Machine.getMaskForSet( clobber, Machine.clobber_mask );
	    
	    for( i = 0; i < operands.length; i = i + 1 ) {
		// int reg = operands[i].reg;
		if( operands[i].temp == 0 ) {
		    continue;
		}

		int mask = Machine.getMaskForSet( operands[i].rset, Machine.reg_mask );
		if( operands[i].mode & Mode.WRITE != 0 && operands[i].reg != 0 && clobber_mask & (1 << operands[i].reg) != 0 ) {
		    throw new System.Exception( "instruction " + this + "\nclobbers output T" + operands[i].temp + " in R" + operands[i].reg );
		}
		
		// if no register assigned, or assigned register not acceptable
		if( operands[i].reg == 0 || mask & (1 << operands[i].reg) == 0 ) {
		    IO.Std.err.println( "needs fixup: T" + operands[i].temp + " in R" + operands[i].reg ); 
		    IO.Std.err.println( this );

		    if( operands[i].reg == 0 ) {
			throw new RegisterException( "no register T" + operands[i].temp, operands[i].temp, true );
		    } else {
			throw new RegisterException( "wrong register T" + operands[i].temp + " in R" + operands[i].reg, operands[i].temp, false );
		    }
		    // need to fixup this instruction
		    needs_fixup = true;
		} else {
		    // remember that this register is used by this instruction
		    occupied = occupied | ( 1 << operands[i].reg );
		}
	    }

	    */

	    if( left == null || !left.isCopy() ) {
		// IO.Std.err.println( "peephole not copy" );
		return false;
	    }

		 
	    if( left.dest == null || left.left == null ) {
		// IO.Std.err.println( "wrong structure" );
		return false;
	    }
	    if( left.dest.isReg() && left.left.isReg() &&
		left.dest.getReg() == left.left.getReg() ) {
		// IO.Std.err.println( "IIIIII: redundant copy: " + this );
		is_effective = false;
	    }
	    return false;
	}


	bool needRegen() {
	    return left.needRegen();
	}

	bool regen( MNode into, Util.Vector list ) {
	    if( needRegen() ) {
		ITree i = itree;
		System.String os = this.toString();

		/*
		IO.Std.err.print( "regen needed: " + this );
		IO.Std.err.println( "will regen from: " + i );
		*/
		list.Length = 0;

		// prevent rewrite using temps in instruction for intermediate results:
		i.replaceTempsWithRegVars();

		i = i.rewrite(1);

		Util.Vector v = new Util.Vector();
		// rewrite instruction avoiding intermediate code three address instructions:
		IBlock.flattenTree( i, v );

		foreach( ITree j; v.elements() ) {
		    j.genInto( list );
		}

		/*
		foreach( MInst t; list.elements() ) {
		    IO.Std.err.print( "will insert: " + t );
		    IO.Std.err.println( "with itree: " + t.itree );
		}

		IO.Std.err.println( "done" );
		*/


		foreach( MInst s; list.reverseElements() ) {
		    // IO.Std.err.println( "insert substitute instruction: " + s );
		    s.initOperands();
		    insertAfter( into, s );	    
		}
		

		makeComment( "SS converted 3A to machine instruction " + os.substring(0,os.Length-1) ); 
		return true;
	    } else {
		return false;
	    }
	}
    }
}
