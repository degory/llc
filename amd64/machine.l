// copyright (C) 2009 degs <junk@giantblob.com> all rights reserved

import amd64;
import amd64rewrite;

namespace Gen {

    enum MSet {
	None = 0,

	// use/hold sets
        General = 1,
	Preserve = 2,

        // single regs
	Return = 3,
        Param0 = 4,
	Param1 = 5,
	Param2 = 6,
	Param3 = 7,
	Param4 = 8,
	Param5 = 9,
	Flags = 10,

        Memory = 11,

	// clobber sets
	CallR = 12, // call with result
        CallD = 13,  // call discard result (also clobbers eax)

        Byte = 14 // not used
    }

    class Machine extends System.Object {
	public static System.String NAME = "amd64";
	public static System.String AS_SWITCH = "--64";
	public static System.String GCC_SWITCH = "-m64";

	public static System.String EXCEPTION_RSP = "%fs:__exception_rsp@TPOFF";
	public static System.String EXCEPTION_TOP = "%fs:__exception_top@TPOFF";

	public static System.String EXCEPTION_RSP_PIC = "__exception_rsp@GOTPCREL(%rip)";
	public static System.String EXCEPTION_TOP_PIC = "__exception_top@GOTPCREL(%rip)";

	public const int WORD = 8;
	public const int RED_ZONE = 0; // 128;
	public const int INLINE_DEPTH = 3;
	public const int NUM_MULTI_REG_SET = 3;

	public const int NUM_PRESERVE_REG = 5;
	public const int NUM_GENERAL_REG = 14;
	public const int NUM_BYTE_REG = 0; // not used

	// public const int FIRST_SINGLE_REG_SET = 3;

	public const int
	    M_EAX =  0x00002,
	    M_EBX =  0x00004,
	    M_ECX =  0x00008,
	    M_EDX =  0x00010,
	    M_ESI =  0x00020,
	    M_EDI =  0x00040,
	    M_EBP =  0x00080,
	    M_ESP =  0x00100,
	    M_R8 =   0x00200,
            M_R9 =   0x00400,
            M_R10 =  0x00800,
	    M_R11 =  0x01000,
	    M_R12 =  0x02000,
            M_R13 =  0x04000,
            M_R14 =  0x08000,
            M_R15 =  0x10000,
	    M_EFLAGS=0x20000,

	    R_EAX = 1,
	    R_EBX = 2,
	    R_ECX = 3,
	    R_EDX = 4,
	    R_ESI = 5,
	    R_EDI = 6,
	    R_EBP = 7,
	    R_ESP = 8,
	    R_R8 = 9,
            R_R9 = 10,
            R_R10 = 11,
            R_R11 = 12,
	    R_R12 = 13,
	    R_R13 = 14,
            R_R14 = 15,
            R_R15 = 16,
	    R_EFLAGS = 17,

	    R_FRAME = R_EBP,
	    R_STACK = R_ESP;

	public const int
	    NUM_REG_PARAM = 6,
	    NUM_REG_PARAM_NATIVE = 6;

	public const bool
	    CALLEE_POPS_ARGUMENTS = false;

        public const int
	    NUM_MACHINE_REG = R_EFLAGS - R_EAX,
	    NUM_REG_VAR = 30,

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
	    M_EBX | M_R12 | M_R13 | M_R14 | M_R15;

	public const int
	    // saved ebp <--- 0(ebp)
	    // return         4(ebp)
            // this           8(ebp)
	    // first argument 16(ebp)

	    FIRST_ARGUMENT_OFFSET = 16,
	    THIS_OFFSET = 8,
	    FIRST_ARGUMENT_OFFSET_STATIC = 16, // no this

	    FIRST_LOCAL_OFFSET = 16, // negative (up stack) relative to frame pointer

            VECTOR_OBJECT_OFFSET = 0,
            VECTOR_LENGTH_OFFSET = 8,
	    VECTOR_DATA_OFFSET = 16,

	    INTERFACE_OFFSET = 32;  // negative relative to the super class pointer

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
	    Op.setAsName(Op.CAST_FROM1_8,"movsbq" );
	    Op.setAsName(Op.CAST_FROM4_8,"movslq" );
	    Op.setAsName(Op.CAST_FROM1_4,"movsbl" );
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
	    Op.setAsName(Op.RESULT_8, "# result" );
	    Op.setAsName(Op.DIV_8, "cqo; idivq" );
	    Op.setAsName(Op.DIV_4, "cdq; idivl" );
            Op.setAsName(Op.DIV_1, "cbw; idivb" );
	    Op.setAsName(Op.MOD_8, "cqo; idivq" );
	    Op.setAsName(Op.MOD_4, "cdq; idivl" );
            Op.setAsName(Op.MOD_1, "cbw; idivb" );
	    Op.setAsName(Op.DIVR_8, "cqo; idivrq" );
	    Op.setAsName(Op.DIVR_4, "cdq; idivrl" );
            Op.setAsName(Op.DIVR_1, "cbw; idivrb" );
	    Op.setAsName(Op.DECBNN_8, "loop" );
	    Op.setAsName(Op.DECBNN_4, "loopl" );
	    Op.setAsName(Op.DECBNN_1, "loopb" );
	}


	public static System.String[] set_name = {
	    "None",     // 0

	    // use/hold sets
	    "General",  // 1
	    "Preserve", // 2

	    // single regs
	    "Return",   // 3
            "Param0",   // 4
	    "Param1",   // 5
	    "Param2",   // 6
	    "Param3",   // 7
	    "Param4",   // 8
	    "Param5",   // 9
   	    "Flags",    // 10

            "Memory",   // 11

	// clobber sets
	    "CallR",    // 12, // call with result
            "CallD"     //13  // call discard result (also clobbers eax)
	};


	public static int[] param_register = {
	    R_EDI,
	    R_ESI,
	    R_EDX,
	    R_ECX,
	    R_R8,
	    R_R9
	};


	public static int[] reg_mask = {
	    0,                                     // None         0
	    M_EAX | M_EBX | M_ECX | M_EDX | M_ESI | M_EDI | M_R8 | M_R9 | M_R10 | M_R11 | M_R12 | M_R13 | M_R14 | M_R15, // General 1
	    M_EBX | M_R12 | M_R13 | M_R14 | M_R15, // Preserve, 2
	    M_EAX,                                 // Return    3
	    M_EDI,                                 // Param0    4
	    M_ESI,                                 // Param1    5
	    M_EDX,                                 // Param2    6   
	    M_ECX,                                 // Param3    7
	    M_R8,                                  // Param4    8
	    M_R9,                                  // Param5    9
	    M_EFLAGS                               // Flags    10
	};


	public static int[] single_reg = {
	    0, // None                          0
	    0, // General                       1
            0, // Preserve                      2
	    R_EAX, // Return                    3
	    R_EDI, // Param0                    4
	    R_ESI, // Param1                    5
	    R_EDX, // Param2                    6
	    R_ECX, // Param3                    7
	    R_R8,  // Param4                    8
	    R_R9,  // Param5                    9
	    R_EFLAGS, // Flags                  10
	};


	public static int[] single_reg_mask = {
	    0, // None                          0
	    0, // General                       1
            0, // Preserve                      2
	    M_EAX, // Return                    3
	    M_EDI, // Param0                    4
	    M_ESI, // Param1                    5
	    M_EDX, // Param2                    6
	    M_ECX, // Param3                    7
	    M_R8,  // Param4                    8
	    M_R9,  // Param5                    9
	    M_EFLAGS, // Flags                 10
	};

	public static int[] clobber_mask = {
	    // use/hold masks - irrelevant here
	    0, // None
	    0, // General
	    0, // Preserve
	    0, // Return
	    0, // Param0
	    0, // Param1
	    0, // Param2
	    0, // Param3
	    0, // Param4
	    0, // Param5
	    0, // Flags
	    0, // Memory
	    // clobber masks
	    M_ECX | M_EDX | M_ESI | M_EDI | M_R8 | M_R9 | M_R10 | M_R11 | M_EFLAGS, // Call with result
	    M_EAX | M_ECX | M_EDX | M_ESI | M_EDI | M_R8 | M_R9 | M_R10 | M_R11 | M_EFLAGS, // Call with result
	};

	public static System.String[] name_8 = {
	    "None",
	    "%rax",
	    "%rbx",
	    "%rcx",
	    "%rdx",
	    "%rsi",
	    "%rdi",
	    "%rbp",
	    "%rsp",
	    "%r8",
	    "%r9",
	    "%r10",
	    "%r11",
	    "%r12",
	    "%r13",
	    "%r14",
	    "%r15",
	    "rflags"
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
	    "%r8d",
	    "%r9d",
	    "%r10d",
	    "%r11d",
	    "%r12d",
	    "%r13d",
	    "%r14d",
	    "%r15d",
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
	    "%r8b",
	    "%r9b",
	    "%r10b",
	    "%r11b",
	    "%r12b",
	    "%r13b",
	    "%r14b",
	    "%r15b",
	    "eflags-byte"
	};

	static System.String file_name = "unknown";
	static int line_info_label;

	static bool isSingleReg( MSet s ) {
	    return cast<int>(s) >= NUM_MULTI_REG_SET;
	}

	static int getSingleReg( MSet s ) {
	    return single_reg[cast<int>(s)];
	}

	static int getSingleRegMask( MSet s ) {
	    return single_reg_mask[cast<int>(s)];
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


	static System.String getRegName( int r, int s ) {
	    try {
		if( s == 8 ) {
		    return name_8[r];
		} else if( s == 4 ) {
		    return name_4[r];
		} else {
		    return name_byte[r];
		}
	    } catch( System.Exception e ) {
		return "T" + r;
	    }
	}
	    
	static System.String getSetName( MSet s ) {
	    int i = cast<int>(s);
	    return set_name[ i ];
	}

	public static int getMaskForSet( MSet s ) {
	    if( cast<int>(s) >= reg_mask.length ) {
		IO.Std.err.println( "unexected register set: " + cast<int>(s) );
	    }
	    return reg_mask[cast<int>(s)];
	}

	public static int getMaskForSet( MSet s, int[] mask ) {
	    return mask[cast<int>(s)];
	}


        void init() {
            super.init();
        }

	static MInst makeSaveCallee( int reg, int fp, int offset ) {
	    return new MInst( new MMove( Op.COPY_8,
					 new MIndirect( new MAddress(
								     new MBase(
									       Op.ADD_8,
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
	    return new MInst( new MMove( Op.COPY_8,
					 new MReg( reg ).rset( MSet.General ),
					 new MIndirect( new MAddress(
								     new MBase(
									       Op.ADD_8,
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
            f.write( ".quad " + i + "\n" );
        }

        static void emitDefLong( IO.Writer f, System.String i ) {
            f.write( ".quad " + i + "\n" );
        }

        static void emitDefPointer( IO.Writer f, int i ) {
            f.write( ".quad " + i + "\n" );
        }

        static void emitDefPointer( IO.Writer f, System.String i ) {
            f.write( ".quad " + i + "\n" );
        }

        static void emitExtern( IO.Writer f, System.String s ) {
            f.write( ".extern " + s + "\n" );
        }

        static void emitGlobal( IO.Writer f, System.String s ) {
            f.write( ".global " + s + "\n" );
        }

        static void emitRoDataSegment( IO.Writer f ) {
            f.write( ".section .rodata\n" );
        }

	static void emitClassSegment( IO.Writer f ) {
	    f.write( ".section y_classes_info,\"a\"\n" );
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
	    f.write( ".quad .L" + n + "\n" );
	}

        static void emitFile( IO.Writer f, System.String n ) {
            f.write( ".file 1 " + '\"' + n + '\"' + "\n" );
	    file_name = n;
        }

	static char quote = '"';

	static void emitEntryPoint( IO.Writer f, System.String main_class_decorated ) {		
	    f.println( ".global entry$point\n" );
	    f.println( "entry$point:" );
	    f.println( "\tpushq %rbp" );
	    f.println( "\tmovq %rsp,%rbp" );
	    f.println( "\tmovq vtable$__" + main_class_decorated + "@GOTPCREL(%rip),%rsi" );
	    f.println( "\tmovq size$__" + main_class_decorated + "@GOTPCREL(%rip),%rax" );
	    f.println( "\tmovl 0(%rax),%edi" );
	    f.println( "\tcall alloco@PLT" );	    
	    f.println( "\tmovq %rax,%rdi" );
	    //f.println( "\tmovq $vtable$__" + main_class_decorated + ",%rax" );
	    //f.println( "\tmovq %rax,(%rdi)" );
	    f.println( "\tcall run__Q26System7StartupQ26System6Object@PLT" );
	    f.println( "\txorq %rax,%rax" );
	    f.println( "\tpopq %rbp" );
	    f.println( "\tret" );
	    f.println( "\t.global __main_init" );
	    f.println( "__main_init:" );
	    f.println( "\tjmp init__" + main_class_decorated + "@PLT" );
	}

	static void emitEntryPointOrig( IO.Writer f, System.String main_class_decorated ) {		
	    f.println( ".global entry$point\n" );
	    f.println( "entry$point:" );
	    f.println( "\tpushq %rbp" );
	    f.println( "\tmovq %rsp,%rbp" );
	    f.println( "\tmovq $vtable$__" + main_class_decorated + ",%rax" );
	    f.println( "\tmovq %rax,%rsi" );
	    f.println( "\tmovl size$__" + main_class_decorated + ",%edi" );
	    f.println( "\tcall alloco" );	    
	    f.println( "\tmovq %rax,%rdi" );
	    f.println( "\tmovq $vtable$__" + main_class_decorated + ",%rax" );
	    f.println( "\tmovq %rax,(%rdi)" );
	    f.println( "\tcall run__Q26System7StartupQ26System6Object" );
	    f.println( "\txorq %rax,%rax" );
	    f.println( "\tpopq %rbp" );
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
	    f.println( ".quad " + decorated_name ); // method start
	    f.println( ".quad .LM" + line_info_label ); // method end
	    f.println( ".quad 3f" ); // method name
	    if( want_line_numbers ) {
		f.println( ".quad 1b" ); // line number chain
	    } else {
		f.println( ".quad 0" );
	    }

	    // method name
	    f.println( ".section .rodata" );
	    f.println( "3: .ascii " + quote + human_name + " " + file_name + quote );
	    f.println( ".byte 0" );
	    
	    // unwind key
	    f.println( ".section .text" );
	    f.println( ".align 16" );
	    f.println( ".quad 0, 0" );
	}
       
	static void emitEndUnwindInfo(
            IO.Writer f, int flags,
	    ILabel ro_start,
	    ILabel ro_end ) {

	    f.println( ".section z_backtrace_info," + quote + "a" + quote );
	    f.println( ".quad " + flags );
	    f.println( ".quad " + ro_end + "-" + ro_start );

	    f.println( ".section w_line_info," + quote + "a" + quote );
	    f.println( ".quad 0" );
	    f.println( ".section .text" );
	    f.println( ".byte 0" ); // displace label so exception or fault rip always < label 
	    f.println( ".LM" + line_info_label + ":" );
	}
    }
}
