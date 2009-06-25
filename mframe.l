// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

namespace Gen {
    class MFrame extends MBlock {
	bool seen_stack;
	bool seen_call;
	bool seen_local;
	int flags;

	int getFlags() {
	    return flags;
	}

	int frame_size;
	int frame_offset;
	int seen_call_preserve_registers;

	void init() {
	    super.init();
	}

	void calcFrameSize() {
	    MCalcFrameSize tw = new MCalcFrameSize(this);
	    // IO.Std.err.println( ">>>calcFramSize..." );
	    process(tw);
	    // IO.Std.err.println( "<<<calcFramSize" );
	}

	void adjustFrameOffset() {
	    if( frame_offset > 0 ) {
		MAdjustFrameOffset tw = new MAdjustFrameOffset(frame_offset);
		process(tw);
	    }
	}

	void seenFrameAccess(int n) {
	    seen_local = true;
	    n = -n;
	    // IO.Std.err.println( "BBBBBB: seen frame access at offset " + n );
	    if( n > frame_size ) {
	        // IO.Std.err.println( "BBBBBB: frame size is now " + frame_size + " bytes" );
		frame_size = n;
	    }
	}

	void seenCallPreserveRegister(int r) {
	    // IO.Std.err.println( "SSSSSS: reference to callee save register: " + Machine.getRegName( r, MSet.Int8 ) );

	    seen_call_preserve_registers = seen_call_preserve_registers | (1 << r);
	}

	void seenStack() {
	    seen_stack = true;
	}

	void seenCall() {
	    seen_call = true;
	}

	// rip
	// rbp (if saved, must be saved for unwind if any methods called or any other callee save registers saved)

	void fixup() {
	    if( inst == null ) {
		// IO.Std.err.println( "Frame.fixup(): no instructions" );
		return;
	    }


	    calcFrameSize();

	    MInst h = findForward( Op.ENTER );
	    MInst t = findBackward( Op.LEAVE );

	    if( h == null ) {
		// IO.Std.err.println( "BBBBBB: frame has no enter instruction: not adjusting frame pointer or preserving registers" );
		return;
	    }

	    // h.insertBefore( this, new MInst( new MAny( ".cfi_def_cfa_register rbp" ) ) );
	    // h.insertBefore( this, new MInst( new MAny( ".cfi_offset rbp,0" ) ) );

	    MInst l = findForward( Op.LABEL );

	    // l.insertAfter( this, new MInst( new MAny( ".cfi_startproc" ) ) );
	    // l.next.next.insertAfter( this, new MInst( new MAny( ".cfi_def_cfa_offset 0" ) ) );

	    // getTail().insertAfter( this, new MInst( new MAny( ".cfi_endproc" ) ) );

	    if( t == null ) {
		t = getTail();
	    }

	    bool need_frame;   // need to save and setup RBP?
	    bool push_frame;   // store RBP via push rather than store indirect through RSP?
	    bool adjust_stack; // need to make room on stack via subtract from RSP?
	    bool red_zone = Machine.RED_ZONE > 0;

	    int save_size = 0; // how many bytes on the stack are occupied by callee save registers (including RBP)

	    int r;
	    for( r = Machine.FIRST_MACHINE_REG; r <= Machine.LAST_MACHINE_REG; r = r + 1 ) {
		if( seen_call_preserve_registers & (1 << r) != 0 ) {
		    save_size = save_size + Machine.WORD;

		    // stack unwind code needs RBP set up to restore callee save registers to caller:
		    need_frame = true;
		}
	    }

	    if( seen_stack ) {
		// push and pop instructions expect RSP to point to stack top so we can't leave it
		// pointing elsewhere:
		adjust_stack = true;

		// for unwind - FIXME
		need_frame = true;
	    }

	    /*
	    if( seen_call ) {
		// for backtraces to include this method we need a backlink to prior RBP on the stack
		// adjacent to prior RIP:
		need_frame = true;
	    }
	    */

	    if( seen_local ) {
		// local variable accessed via RBP - could change this to RSP for leaf functions here
		need_frame = true;
	    }

	    if( need_frame ) {
		// include space for RBP in callee save area:
		save_size = save_size + Machine.WORD;
	    }

	    // total stack space used by this method is callee save area plus locals area:
	    int total_size = save_size + frame_size;

	    // if the total size exceeds the size of the red zone below RSP then we'll need to
	    // adjust RSP downwards: 
	    if( total_size > Machine.RED_ZONE ) {
		adjust_stack = true;
	    }

	    int save_registers = seen_call_preserve_registers;

	    // first callee save is at RBP + 16, RSP + 0 holds RBP. RBP must be saved if any callee saved
	    // registers are used as unwind relies on it:
	    int r_offset = Machine.WORD;  

	    int fp = Machine.R_STACK;	   

	    frame_offset = save_size - Machine.WORD; // don't include saved RBP in offset since 0(RBP) -> RBP

	    adjustFrameOffset();

	    int sz = ITree.getSizeMask(Machine.WORD);

	    if( !red_zone || (need_frame && total_size == Machine.WORD) ) {
		// don't adjust the stack pointer to store only RBP - just push RBP instead.
		push_frame = true;
	    } else if( red_zone && adjust_stack && total_size > 0 ) {
		push_frame = false;

		h.insertAfter( this, new MInst( new MA2( Op.SUB2+sz, new MReg( Machine.R_STACK ), new MImmediate( total_size ) ) ) );
		if( !need_frame ) {
		    t.insertBefore( this, new MInst( new MA2( Op.ADD2+sz, new MReg( Machine.R_STACK ), new MImmediate( total_size ) ) ) );
		}
	    }

	    for( r = Machine.FIRST_MACHINE_REG; r <= Machine.LAST_MACHINE_REG; r = r + 1 ) {
		if( save_registers & (1 << r) != 0 ) {	    
		    // IO.Std.err.println( "SSSSSS: save/restore callee save register: " + Machine.getRegName( r, MSet.Int8 ) );
		    // h.insertAfter( this, new MInst( new MAny( ".cfi_offset " + Machine.getRegName(r,MSet.Int8) + ",-" + cfi_offset  ) ) );

		    // frame offset will be subtraced out from all frame relative addresses in this method but here we don't want this
		    // so add it in to compensate leaving net offset of zero:
		    h.insertAfter( this, Machine.makeSaveCallee( r, Machine.R_FRAME, -r_offset) );
		    t.insertBefore( this, Machine.makeRestoreCallee( r, Machine.R_FRAME, -r_offset) );

		    r_offset = r_offset + Machine.WORD;
		}
	    }

	    if( !red_zone && adjust_stack && total_size > 0 ) {
		// if machine has no red-zone then we have to adjust the stack before saving anything to it:
		h.insertAfter( this, new MInst( new MA2( Op.SUB2+sz, new MReg( Machine.R_STACK ), new MImmediate( total_size - Machine.WORD ) ) ) );
	    }

	    if( need_frame ) {
		save_registers = save_registers | (1 << Machine.R_FRAME);

		// first save the frame pointer onto the stack:
		if( push_frame ) {
		    // copy stack pointer into frame pointer:
		    h.insertAfter( this, new MInst( new MMove( Op.COPY+sz, new MReg( Machine.R_FRAME ), new MReg( Machine.R_STACK ) ) ) );
		    h.insertAfter( this, new MInst( new MStack( Op.PUSH+sz, new MReg( Machine.R_FRAME ) ) ) );
		} else {
		    IO.Std.err.println( "LEALEALEA: push frame is: " + push_frame + " sz is: " + sz );
		    h.insertAfter( this, new MInst( new MMove( Op.LEA+sz, 
							       new MReg( Machine.R_FRAME ),
							       new MIndirect( new MAddress(
											   new MBase(
												     Op.ADD+sz,
												     new MConst(-Machine.WORD),
												     new MReg( Machine.R_STACK )
												     ),
											   null
											   )
									      )

							       )
						    )
				   );

		    h.insertAfter( this, Machine.makeSaveCallee( Machine.R_FRAME, Machine.R_STACK, -Machine.WORD ) );
		    // h.insertAfter( this, Machine.makeRestoreCallee( Machine.R_FRAME, Machine.R_STACK, -8 ) );
		}


	    
		// this should work regardless of whether we pushed EBP or moved it onto the stack as we set up
		// RBP = &RIP - 8 ether way. leave will copy RBP in RSP leaving RSP -> saved RBP then pop off
		// saved RBP leaving RSP pointing at return RIP:
		t.insertBefore( this, new MInst( new MAny( "leave" ) ) );		   
	    }

	    flags = seen_call_preserve_registers;
	}
    }


    /*

      rip <-- sp initially
      rbp <-- rpb
      rbx
      ...
      r12
      r13
      V1
      V2
      V3
    */

    class MAdjustFrameOffset extends MTreeWalker {
	int frame_offset;
	void init( int frame_offset ) {
	    super.init();
	    this.frame_offset = frame_offset;
	    // IO.Std.err.println( "BBBBBB: initialize MAdjustFrameOffset, frame offset = " + frame_offset );
	}

	void process( MTree m ) {
	    m.adjustFrameOffset(this);
	}

	void adjustFrameOffset( MTree m ) {
	    int original_offset = m.getInt();
	    // IO.Std.err.println( "BBBBBB: adjust " + original_offset + " by " + frame_offset + "?" );

	    if( original_offset < 0 ) {
		m.setValue(original_offset - frame_offset);
		// IO.Std.err.println( "now: " + (original_offset - frame_offset ) + "/" + m );
	    }
	}
    }


    class MCalcFrameSize extends MTreeWalker {
	MFrame method;
	void init(MFrame m) {
	    super.init();
	    this.method = m;
	    // IO.Std.err.println( "BBBBBB: new MCalcFrameSize for: " + method );
	}

	void process( MTree m ) {
	    // IO.Std.err.println( "BBBBBB: MCalcFrameSize: process: " + m );
	    m.calcFrameSize(method);
	    // IO.Std.err.println( "BBBBBB: MCalcFrameSize: process done" );
	}
    }
}
