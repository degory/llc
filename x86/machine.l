// copyright (C) 2005 degs <junk@giantblob.com> all rights reserved

import x86;
import x86rewrite;

namespace Gen {

    enum MSet {
	None = 0,

	// use/hold sets
	Byte = 1,
	General = 2,
	Preserve = 3,
	BytePreserve = 4,
	Return = 5,
	Param0 = 6,
	Param1 = 7,
        Flags = 8,

	// clobber sets
	CallR = 9, // call with result
	CallD = 10 // call discard result (also clobbers eax)

    }

    class Machine extends System.Object {
	public static System.String NAME = "x86";

	public const int WORD = 4;
	public const int NUM_REG_SET = 11;
	public const int RED_ZONE = 0;
	public const int INLINE_DEPTH = 2;

	public const bool CALLEE_POPS_ARGUMENTS = true;

	public static System.String GCC_SWITCH = "-m32";
	public static System.String AS_SWITCH = "--32";

        public static System.String EXCEPTION_RSP = "%gs:__exception_rsp@NTPOFF";
        public static System.String EXCEPTION_TOP = "%gs:__exception_top@NTPOFF";

	public const int
	    M_EAX =  0x00002,
	    M_EBX =  0x00004,
	    M_ECX =  0x00008,
	    M_EDX =  0x00010,
	    M_ESI =  0x00020,
	    M_EDI =  0x00040,
	    M_EBP =  0x00080,
	    M_ESP =  0x00100,
	    M_EFLAGS=0x00200,

	    R_EAX = 1,
	    R_EBX = 2,
	    R_ECX = 3,
	    R_EDX = 4,
	    R_ESI = 5,
	    R_EDI = 6,
	    R_EBP = 7,
	    R_ESP = 8,
	    R_EFLAGS = 9,

	    R_FRAME = R_EBP,
	    R_STACK = R_ESP;

	public const int
	    NUM_REG_PARAM = 2,
	    NUM_REG_PARAM_NATIVE = 0;

	public static int[] param_register = {
	    R_ECX,
	    R_EDX,
	};

        public const int
	    NUM_MACHINE_REG = R_EFLAGS - R_EAX,
	    NUM_REG_VAR = 4,

            FIRST_MACHINE_REG = R_EAX,
            FIRST_REG = FIRST_MACHINE_REG,
            LAST_MACHINE_REG = R_EFLAGS,
            MACHINE_REG_BOUND = (LAST_MACHINE_REG+1),
            FIRST_SOFT_REG = (LAST_MACHINE_REG+1),
            FIRST_VAR_REG = FIRST_SOFT_REG,
            LAST_VAR_REG = (FIRST_VAR_REG+NUM_REG_VAR-1),
            FIRST_TEMP_REG = (LAST_VAR_REG+1),
            NUM_TEMP_REG = 1024,
            LAST_TEMP_REG = (FIRST_TEMP_REG+NUM_TEMP_REG-1),
            LAST_SOFT_REG = LAST_TEMP_REG,
            LAST_REG = LAST_TEMP_REG,
            NUM_REG = (LAST_REG+1),
            MAX_MACHINE_CHILDREN = 10,
	    BIT_SET_MAX = NUM_REG/4+1;

	public const int
	    COST_IDEAL_REG = 1,
	    COST_WRONG_REG = 10,
	    COST_USE_MEM = 20,
	    COST_CLOBBER = 1000,
	    COST_SINGLE_REG = 1000,
	    COST_KILL = 10000000;

	public const int CALL_PRESERVE =
	    M_EBX | M_ESI | M_EDI;

	public const int
	    // saved ebp <--- 0(ebp)
	    // return         4(ebp)
            // this           8(ebp)
	    // first argument 16(ebp)

	    FIRST_ARGUMENT_OFFSET = 8,
	    THIS_OFFSET = 4,
	    FIRST_ARGUMENT_OFFSET_STATIC = 8, // no this

	    FIRST_LOCAL_OFFSET = 8, // negative (up stack) relative to frame pointer

            VECTOR_OBJECT_OFFSET = 0,
            VECTOR_LENGTH_OFFSET = 4,
	    VECTOR_DATA_OFFSET = 8;

	public const int
	    NUM_PRESERVE_REG = 3,
	    NUM_BYTE_REG = 4,
	    NUM_GENERAL_REG = 6;


	public static int[] reg_set_size;

	public static System.String[] set_name = {
	    "None",
	    "Byte",
	    "General",
	    "Preserve",
	    "BytePreserve",
	    "Return",
	    "Param0",
	    "Param1",
	    "Flags",
	    "CallR",
	    "CallD",
	};



	public static int[] reg_mask = {
	    0,                                             // None
	    M_EAX | M_EBX | M_ECX | M_EDX,                 // Byte
	    M_EAX | M_EBX | M_ECX | M_EDX | M_ESI | M_EDI, // General     
	    M_EBX | M_ESI | M_EDI,                         // Preserve,
	    M_EBX,                                         // BytePreserve,
	    M_EAX,                                         // Return
	    M_ECX,                                         // Param0
	    M_EDX,                                         // Param1
	    M_EFLAGS                                       // Flags
	};

	public static int[] single_reg = {
	    0, // None
	    0, // Byte
	    0, // General
	    0, // Preserve
	    R_EBX, // BytePreserve
	    R_EAX, // Return
	    R_ECX, // Param0
	    R_EDX, // Param1
	    R_EFLAGS, // Flags
	};

	public static int[] clobber_mask = {
	    // use/hold masks - irrelevant here
	    0, // None
	    0, // Byte
	    0, // General
	    0, // Preserve
	    0, // BytePreserve
	    0, // Return
	    0, // Param0
	    0, // Param1
	    0, // Flags
	    // clobber masks
	    M_ECX | M_EDX | M_EFLAGS, // Call with result
	    M_EAX | M_ECX | M_EDX | M_EFLAGS, // Call with no result
	};

	    

	public static System.String[] name_4 = {
	    "None",
	    "%eax",
	    "%ebx",
	    "%ecx",
	    "%edx",
	    "%esi",
	    "%edi",
	    "%ebp",
	    "%esp",
	    "eflags"
	};

	public static System.String[] name_byte = {
	    "None",
	    "%al",
	    "%bl",
	    "%cl",
	    "%dl",
	    "%sil",
	    "%dil",
	    "%bpl",
	    "%spl",
	    "eflags-byte"
	};

	static System.String file_name = "unknown";
	static int line_info_label;

	static bool doesSetContain( MSet s, MSet t ) {
	    int ms, mt;

	    if( t == MSet.None ) {
		return false;
	    }

	    ms = getMaskForSet( s, reg_mask );
	    mt = getMaskForSet( t, reg_mask );

	    return ms != mt && (ms | mt) == ms;
	}

	static int compareRegSets( MSet s, MSet t ) {
	    if( s == MSet.None ) {
		if( t == MSet.None ) {
		    return 0;
		} else {
		    return 1;
		}
	    } else if( t == MSet.None ) {
		return -1;
	    }

	    int ss = single_reg[ cast<int>(s) ];
	    int st = single_reg[ cast<int>(t) ];

	    if( ss != 0 ) {
		ss = 1;
	    }
	    if( st != 0 ) {
		st = 1;
	    }

	    if( st != ss ) {
		return st - ss;
	    }

	    return cast<int>(s) - cast<int>(t);

	}

	static MSet getRegSetIntersection( MSet s, MSet t ) {
	    //IO.Std.err.println( "intersection: " + getSetName(s) + " & " + getSetName(t) );
	    if( s == t ) {
		// IO.Std.err.println( "equal, return: " + getSetName(s) );
		return s;
	    } else if( s == MSet.None || s == MSet.General ) {
		// IO.Std.err.println( "s: " + getSetName(s) + " return t: " + getSetName(t) );
		return t;
	    } else if( t == MSet.None || t == MSet.General ) {
		// IO.Std.err.println( "t: " + getSetName(t) + " return s: " + getSetName(s) );
		return s;
	    } else {
		// IO.Std.err.println( "return: None" );
		return MSet.None;
	    }
	}

	static int getSingleReg( MSet s ) {
	    if( s == MSet.BytePreserve ) {
		IO.Std.err.println( "single reg for " + getSetName(s) + " is " + single_reg[cast<int>(s)] + " from: " + new System.Backtrace() );
	    }
	    
	    return single_reg[cast<int>(s)];
	}

	static System.String getRegName( int r, int size ) {
	    try {
		if( size == 4 ) {
		    return name_4[r];
		} else if( size == 1 ) {
		    return name_byte[r];
		} else {
		    throw new System.Exception( "unexpected register size: " + size );
		}
	    } catch( System.ArrayBoundsException e ) {
		return "T" + r;
	    }
	}
	    
	static System.String getSetName( MSet s ) {
	    int i = cast<int>(s);

	    if( i >= cast<int>(MSet.None) &&
		i <= cast<int>(MSet.CallD) ) {
		return set_name[ cast<int>(s) ];
	    } else {
		return "Unkown reg set";
	    }
	}



	private static int[] countRegSetSizes() {
	    int[] result = new int[NUM_REG_SET];

	    for( int i = 0; i < NUM_REG_SET; i = i + 1 ) {
		int set_ = reg_mask[i];
		result[i] = 0;

		for( int j = FIRST_MACHINE_REG; j <= LAST_MACHINE_REG; j = j + 1 ) {
		    int r = 1 << j;

		    if( set_ & r != 0 ) {
			result[i] = result[i] + 1;
		    }
		}
	    }

	    return result;
	}

      
	public static int getSetSize( MSet set_ ) {
	    if( reg_set_size == null ) {
		reg_set_size = countRegSetSizes();
	    }
	    return reg_set_size[ cast<int>(set_) ];
	}

	static void initOpNames() {
	    char quote = '"';
	    Op.setAsName(Op.ERROR_0,"# bad tree" );
	    Op.setAsName(Op.COPY_8,"movq");
	    Op.setAsName(Op.COPY_4,"movl");
	    Op.setAsName(Op.COPY_1,"movb");
	    Op.setAsName(Op.EXTERN_0,".extern");
	    Op.setAsName(Op.GLOBAL_4,".global");
	    Op.setAsName(Op.GLOBAL_8,".global");
	    Op.setAsName(Op.RET_0,"ret");
	    Op.setAsName(Op.JUMP_0,"jmp");
	    Op.setAsName(Op.ENTER_0,"# enter frame" );
	    Op.setAsName(Op.LEAVE_0,"# leave frame" );
	    Op.setAsName(Op.COMMENT_0, "                         #" );
	    Op.setAsName(Op.LINE_0, ".loc 1 " );
	    Op.setAsName(Op.TEXT_0, ".section .text" );
	    Op.setAsName(Op.DATA_0, ".section .data" );
	    Op.setAsName(Op.RODATA_0, ".section .rodata" );
	    Op.setAsName(Op.STATIC_0, ".section x_static_init," + quote + "ax" + quote );
	    Op.setAsName(Op.UNWIND_0, ".section w_line_info," + quote + "a" + quote );
	    Op.setAsName(Op.PUSHSEG_0, "# save section" );
	    Op.setAsName(Op.POPSEG_0,"# restore section\n.section" );
	    Op.setAsName(Op.ENTER_LOOP_0, "# enter loop" );
	    Op.setAsName(Op.LEAVE_LOOP_0, "# leave loop" );
	    Op.setAsName(Op.JE_0,"je" );
	    Op.setAsName(Op.JNE_0,"jne" );
	    Op.setAsName(Op.JG_0,"jg" );
	    Op.setAsName(Op.JL_0,"jl" );
	    Op.setAsName(Op.JGE_0,"jge" );
	    Op.setAsName(Op.JLE_0,"jle" );
	    Op.setAsName(Op.JGU_0,"ja" );
	    Op.setAsName(Op.JLU_0,"jb" );
	    Op.setAsName(Op.JGEU_0,"jae" );
	    Op.setAsName(Op.JLEU_0,"jbe" );
	    Op.setAsName(Op.SETGU_1,"seta" );
	    Op.setAsName(Op.SETLU_1,"setb" );
	    Op.setAsName(Op.SETGEU_1,"setae" );
	    Op.setAsName(Op.SETLEU_1,"setbe" );
	    Op.setAsName(Op.MUL_8,"imulq" );
	    Op.setAsName(Op.MUL2_8, "imulq" );
	    Op.setAsName(Op.MUL_4,"imull" );
	    Op.setAsName(Op.MUL2_4, "imull" );
	    Op.setAsName(Op.CONST_STR_0,"# string constant\n.byte" );
	    Op.setAsName(Op.CONST_CSTR_0,"# C string constant\n.byte" );
	    Op.setAsName(Op.DEFINT_8,".quad" );
	    Op.setAsName(Op.DEFINT_4,".int" );
	    Op.setAsName(Op.DEFINT_1,".byte" );
	    Op.setAsName(Op.CAST_FROM1_8,"movsx" );
	    Op.setAsName(Op.CAST_FROM4_8,"movsxd" );
	    Op.setAsName(Op.CAST_FROM1_4,"movsx" );
	    Op.setAsName(Op.TREAT_AS_8,"# treat as 8" );
	    Op.setAsName(Op.TREAT_AS_4,"# treat as 4" );
	    Op.setAsName(Op.TREAT_AS_1,"# treat as 1" );
	    Op.setAsName(Op.SAVE_ALL_0, "# save all" );
	    Op.setAsName(Op.RESTORE_ALL_0, "# restore all" );
	    Op.setAsName(Op.DUMMY_JUMP_0, "# dummy jump" );
	    Op.setAsName(Op.SHAR_8, "shrq" );
	    Op.setAsName(Op.SHAR_4, "shrl" );
	    Op.setAsName(Op.SHAR_1, "shrb" );
	    Op.setAsName(Op.PARAM0, "# param0" );
	    Op.setAsName(Op.PARAM1, "# param1" );
	    Op.setAsName(Op.PARAM2, "# param2" );
	    Op.setAsName(Op.PARAM3, "# param3" );
	    Op.setAsName(Op.PARAM4, "# param4" );
	    Op.setAsName(Op.PARAM5, "# param5" );
	    Op.setAsName(Op.ARG0, "# 1 arg" );
	    Op.setAsName(Op.ARG1, "# 2 args" );
	    Op.setAsName(Op.ARG2, "# 3 args" );
	    Op.setAsName(Op.ARG3, "# 4 args" );
	    Op.setAsName(Op.ARG4, "# 5 args" );
	    Op.setAsName(Op.ARG5, "# 6 args" );
	    Op.setAsName(Op.RESULT, "# result" );
	    Op.setAsName(Op.DIV_8, "cqo; idivq" );
	    Op.setAsName(Op.DIV_4, "cdq; idivl" );
            Op.setAsName(Op.DIV_1, "cbw; idivb" );
	    Op.setAsName(Op.MOD_8, "cqo; idivq" );
	    Op.setAsName(Op.MOD_4, "cdq; idivl" );
            Op.setAsName(Op.MOD_1, "cbw; idivb" );
	    Op.setAsName(Op.DIVR_8, "cqo; idivrq" );
	    Op.setAsName(Op.DIVR_4, "cdq; idivrl" );
            Op.setAsName(Op.DIVR_1, "cbw; idivrb" );
	    Op.setAsName(Op.DECBNN_8, "loopq" );
	    Op.setAsName(Op.DECBNN_4, "loopl" );
	    Op.setAsName(Op.DECBNN_1, "loopb" );
	}


	public static int getMaskForSet( MSet s, int[] mask ) {
	    return mask[cast<int>(s)];
	}

	public static int getMaskForSet( MSet s ) {
	    return reg_mask[cast<int>(s)];
	}

        void init() {
            super.init();
        }

	static MInst makeSaveCallee( int reg, int fp, int offset ) {
	    return new MInst( new MMove( Op.COPY_4,
					 new MIndirect( new MAddress(
								     new MBase(
									       Op.ADD_4,
									       new MConst(offset),
									       new MReg( fp ).rset( MSet.General )
									       ),
								     null
								     )
							),
					 new MReg( reg ).rset( MSet.General )
					 )
			      );
	}

	static MInst makeRestoreCallee( int reg, int fp, int offset ) {
	    return new MInst( new MMove( Op.COPY_4,
					 new MReg( reg ).rset( MSet.General ),
					 new MIndirect( new MAddress(
								     new MBase(
									       Op.ADD_4,
									       new MConst(offset),
									       new MReg( fp ).rset( MSet.General )
									       ),
								     null
								     )
							)
					 )
			      );
	}
	    
        static void emitDefByte( IO.Writer f, int b ) {
            f.write( ".byte " + b + "\n" );
        }
       
        static void emitDefInt( IO.Writer f, int i ) {
            f.write( ".int " + i + "\n" );
        }

        static void emitDefInt( IO.Writer f, System.String i ) {
            f.write( ".int " + i + "\n" );
        }

        static void emitDefLong( IO.Writer f, int i ) {
            f.write( ".int " + i + "\n" );
        }

        static void emitDefLong( IO.Writer f, System.String i ) {
            f.write( ".int " + i + "\n" );
        }

        static void emitDefPointer( IO.Writer f, int i ) {
            f.write( ".int " + i + "\n" );
        }

        static void emitDefPointer( IO.Writer f, System.String i ) {
            f.write( ".int " + i + "\n" );
        }

        static void emitExtern( IO.Writer f, System.String s ) {
            f.write( ".extern " + s + "\n" );
        }

        static void emitGlobal( IO.Writer f, System.String s ) {
            f.write( ".global " + s + "\n" );
        }

        static void emitClassSegment( IO.Writer f ) {
            f.write( ".section y_classes_info,\"a\"\n" );
        }

        static void emitRoDataSegment( IO.Writer f ) {
            f.write( ".section .rodata\n" );
        }

        static void emitDataSegment( IO.Writer f ) {
            f.write( ".section .data\n" );
        }

        static void emitTextSegment( IO.Writer f ) {
            f.write( ".section .text\n" );
        }

        static void emitAlign( IO.Writer f, int n ) {
            f.write( ".align " + n + "\n" );
        }

        static void emitLabel( IO.Writer f, int n ) {
            f.write( ".L" + n + ":\n" );
        }

        static void emitLabel( IO.Writer f, System.String s ) {
            f.write( s + ":\n" );
        }

        static void emitDefAsciiz( IO.Writer f, System.String s ) {
            f.write( ".ascii " + '\"' + s + '\"' + "\n.byte 0\n" );
        }

	/*
        static void emitDefIntLabel( IO.Writer f, int n ) {
            f.write( ".int .L" + n + "\n" );
        }
	*/

	static void emitDefPointerLabel( IO.Writer f, int n ) {
	    f.write( ".int .L" + n + "\n" );
	}

        static void emitFile( IO.Writer f, System.String n ) {
            f.write( ".file 1 " + '\"' + n + '\"' + "\n" );
	    file_name = n;
        }

	static char quote = '"';

	static void emitEntryPoint( IO.Writer f, System.String main_class_decorated ) {		
	    f.println( ".global entry$point\n" );
	    f.println( "entry$point:" );
	    f.println( "\tpushl %ebp" );
	    f.println( "\tmovl %esp,%ebp" );
	    f.println( "\pushl $vtable$__" + main_class_decorated );
	    f.println( "\pushl size$__" + main_class_decorated );
	    f.println( "\tcall __alloc_object" );
	    f.println( "\taddl $8,%esp" );
	    f.println( "\tmovl %eax,%ecx" );
	    f.println( "\tcall run__Q26System7StartupQ26System6Object" );
	    f.println( "\txorl %eax,%eax" );
	    f.println( "\tpopl %ebp" );
	    f.println( "\tret" );
	    f.println( "\t.global __main_init" );
	    f.println( "__main_init:" );
	    f.println( "\tjmp init__" + main_class_decorated );	    
	}

	static void emitStartUnwindInfo(
					IO.Writer f, 
					System.String decorated_name, 
					System.String human_name, 
					bool want_line_numbers ) {

	    line_info_label = line_info_label + 1;

	    // start new line number list
	    f.println( ".section w_line_info," + quote + "a" + quote );
	    f.println( "1:" );
	    
	    // backtrace record
	    f.println( ".section z_backtrace_info," + quote + "a" + quote );
	    // f.println( "2:" );
	    f.println( ".int " + decorated_name ); // method start
	    f.println( ".int .LM" + line_info_label ); // method end
	    f.println( ".int 3f" ); // method name
	    if( want_line_numbers ) {
		f.println( ".int 1b" ); // line number chain
	    } else {
		f.println( ".int 0" );
	    }

	    // method name
	    f.println( ".section .rodata" );
	    f.println( "3: .ascii " + quote + human_name + " " + file_name + quote );
	    f.println( ".byte 0" );
	    
	    // unwind key
	    f.println( ".section .text" );
	    f.println( ".align 16" );
	    f.println( ".int 0, 0" );
	}
       
	static void emitEndUnwindInfo(
            IO.Writer f, int flags,
	    ILabel ro_start,
	    ILabel ro_end ) {

	    f.println( ".section z_backtrace_info," + quote + "a" + quote );
	    f.println( ".int " + flags );
	    f.println( ".int " + ro_end + "-" + ro_start );

	    f.println( ".section w_line_info," + quote + "a" + quote );
	    f.println( ".int 0" );
	    f.println( ".section .text" );
	    f.println( ".byte 0" ); // displace label so exception or fault rip always < label 
	    f.println( ".LM" + line_info_label + ":" );
	}
    }
}
