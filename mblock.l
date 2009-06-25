// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

namespace Gen {
    class MBlock extends System.Object {
	protected MInst inst, tail;

	void init() {
	    super.init();
	}

        void add( MInst i ) {
	    // IO.Std.err.println( "adding: " + i + " to " + this );
            if( i == null ) {
                throw new System.Exception( "adding null MInst to MNode: " + this );
            }
            
            if( tail != null ) {
                tail.next = i;
            }
            i.prev = tail;
            tail = i;
            if( inst == null ) {
                inst = i;
            }
	    // IO.Std.err.println( "tail now: " + tail );
        }

	void add2( MInst i ) {
	    i.initOperands();
	    add( i );
	}

	void addTo( CodeGenerator gen ) {
	    for( MInst i = inst; i != null; i = i.next ) {
		gen.add( i );
	    }
	}



	void process(MTreeWalker tw) {
	    for( MInst i = inst; i != null; i = i.next ) {
		i.process(tw);
	    }
	}	    

	MInst findForward( int op ) {
	    // IO.Std.err.println( "findForward(" + Op.getOpName(op) + ")" );
	    for( MInst i = getHead(); i != null; i = i.next ) {
		// IO.Std.err.print( "findForward: " + i );
		if( i.getLeft() != null && i.Left.Operation == op ) {
		    // IO.Std.err.println( "matched" );
		    return i;
		}
	    }
	    return null;
	}

	MInst findBackward( int op ) {
	    for( MInst i = getTail(); i != null; i = i.prev ) {
		if( i.getLeft() != null && i.Left.Operation == op ) {
		    return i;
		}
	    }
	}

	void output( IO.Writer o ) {
	    for( MInst i = inst; i != null; i = i.next ) {
		o.print( i );
	    }
	}

	void addInto( MBlock into ) {
	    for( MInst i = inst; i != null; i = i.next ) {
		into.add( i );
	    }
	}

	MInst getHead() {
	    return inst;
	}

	void insertBeforeLast( MInst i ) {
	    IO.Std.err.println( "insert after first: " + i);
	    if( tail == null || !tail.isJump() ) {
		IO.Std.err.println( "last is null or not jump - insert as last" );
		if( tail == null ) {
		    inst = i;
		}
		i.prev = tail;
		i.next = null;
		tail = i;
	    } else {
		IO.Std.err.println( "first is label, insert after" );
		tail.insertBefore( this, i );
	    }
	    IO.Std.err.println( "now: " + this );
	}


	void insertAfterFirst( MInst i ) {
	    IO.Std.err.println( "insert after first: " + i);
	    if( inst == null || !inst.isLabel() ) {
		IO.Std.err.println( "first is null or not label - insert as first" );
		if( inst == null ) {
		    tail = i;
		}
		i.prev = null;
		i.next = inst;
		inst = i;
	    } else {
		IO.Std.err.println( "first is label, insert after" );
		inst.insertAfter( this, i );
	    }
	    IO.Std.err.println( "now: " + this );
	}

	void insertFirst( MInst i ) {
	    IO.Std.err.println( "insert first: " + i);
	    i.next = inst;
	    i.prev = null;
	    if( inst != null ) {
		inst.prev = i;
	    }
	    inst = i;
	}

	void setHead(MInst i) {
	    inst = i;
	}


	MInst getTail() {
	    return tail;
	}

	void setTail(MInst i) {
	    tail = i;
	}

	System.String toString() {
	    System.StringBuffer result = new System.StringBuffer(super.toString());
	    for( MInst i = inst; i != null; i = i.next ) {
		result.append( i );
	    }
	    return result;
	}

	static MInst makeList( Util.Vector list ) {
	    MInst head = null;
	    MInst prev = null;

            foreach( MTree t; list.elements() ) {
		MInst i;
		try {
		    i = cast<MInst>(t);
		} catch( System.CastException ce ) {
		    IO.Std.err.println( "oops: not an instruction: " + t );
		    i = null;
		}

		if( i == null ) {
		    continue;
		}

		if( head == null ) {
		    head = i;
		}
		// IO.Std.err.println( "about to init operands: " + i );
		i.initOperands();
		if( prev != null ) {
		    prev.next = i;
		}

		i.prev = prev;
		prev = i;

		// IO.Std.err.print( t );
		// output.print( t );
            }

	    return head;
	}

    }
}
