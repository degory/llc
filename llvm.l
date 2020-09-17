#C

// Copyright 2004-2010 <degs@giantblob.com> all rights reserved

import llvmimports;

namespace LLVM {
    struct Context { }
    struct Module { System.String toString() { return "LLVM Module"; } }
    struct Type {
	System.String toString() { return "LLVM Type"; }

	bool opEquals( Type t ) {
	    return this == t;
	}

	int opCompare( Type t ) {
	    return cast int(this) - cast int(t);
	}
    }

    struct TypeHandle { }

    struct Value {
	System.String toString() { return "LLVM Value"; }
	
	bool opEquals( Value v ) {
	    return this == v;
	}

	int opCompare( Value v ) {
	    return cast int(this) - cast int(v);
	}
    }

    struct BasicBlock {
	System.String toString() { return "LLVM.BasicBlock"; }

	bool opEquals( BasicBlock b ) {
	    return this == b;
	}

	int opCompare( BasicBlock b ) {
	    return cast int(this) - cast int(b);
	}
    }
    struct Builder { }

    struct LLVMOpaqueModuleProvider {}

    struct LLVMMemoryBuffer {}

    struct LLVMPassManagerRef {}

    struct ModuleProvider {}

    struct LLVMPassManager { }

    struct LLVMExecutionEngine {}
    struct LLVMGenericValue { }

    struct LLVMTargetData { }

    enum LLVMVerifierFailureAction {
	LLVMAbortProcessAction, /* verifier will print to stderr and abort() */
	LLVMPrintMessageAction, /* verifier will print to stderr and return 1 */
	LLVMReturnStatusAction  /* verifier will just return 1 */
    }

    enum LLVMAttribute {
	LLVMZExtAttribute       = 1<<0,
	    LLVMSExtAttribute       = 1<<1,
	    LLVMNoReturnAttribute   = 1<<2,
	    LLVMInRegAttribute      = 1<<3,
	    LLVMStructRetAttribute  = 1<<4,
	    LLVMNoUnwindAttribute   = 1<<5,
	    LLVMNoAliasAttribute    = 1<<6,
	    LLVMByValAttribute      = 1<<7,
	    LLVMNestAttribute       = 1<<8,
	    LLVMReadNoneAttribute   = 1<<9,
	    LLVMReadOnlyAttribute   = 1<<10,
	    LLVMNoInlineAttribute   = 1<<11,
	    LLVMAlwaysInlineAttribute    = 1<<12,
	    LLVMOptimizeForSizeAttribute = 1<<13,
	    LLVMStackProtectAttribute    = 1<<14,
	    LLVMStackProtectReqAttribute = 1<<15,
	    LLVMNoCaptureAttribute  = 1<<21,
	    LLVMNoRedZoneAttribute  = 1<<22,
	    LLVMNoImplicitFloatAttribute = 1<<23,
	    LLVMNakedAttribute      = 1<<24
	    }

    enum TypeKind {
	LLVMVoidTypeKind,        /**< type with no size */
	    LLVMFloatTypeKind,       /**< 32 bit floating point type */
	    LLVMDoubleTypeKind,      /**< 64 bit floating point type */
	    LLVMX86_FP80TypeKind,    /**< 80 bit floating point type (X87) */
	    LLVMFP128TypeKind,       /**< 128 bit floating point type (112-bit mantissa)*/
	    LLVMPPC_FP128TypeKind,   /**< 128 bit floating point type (two 64-bits) */
	    LLVMLabelTypeKind,       /**< Labels */
	    LLVMIntegerTypeKind,     /**< Arbitrary bit width integers */
	    LLVMFunctionTypeKind,    /**< Functions */
	    LLVMStructTypeKind,      /**< Structures */
	    LLVMArrayTypeKind,       /**< Arrays */
	    LLVMPointerTypeKind,     /**< Pointers */
	    LLVMOpaqueTypeKind,      /**< Opaque: type with unknown structure */
	    LLVMVectorTypeKind,      /**< SIMD 'packed' format, or other vector type */
	    LLVMMetadataTypeKind     /**< Metadata */
	    }

    enum LLVMLinkage {
	LLVMExternalLinkage,    /**< Externally visible function */
	    LLVMAvailableExternallyLinkage,
	    LLVMLinkOnceAnyLinkage, /**< Keep one copy of function when linking (inline)*/
	    LLVMLinkOnceODRLinkage, /**< Same, but only replaced by something
				       equivalent. */
	    LLVMWeakAnyLinkage,     /**< Keep one copy of function when linking (weak) */
	    LLVMWeakODRLinkage,     /**< Same, but only replaced by something
				       equivalent. */
	    LLVMAppendingLinkage,   /**< Special purpose, only applies to global arrays */
	    LLVMInternalLinkage,    /**< Rename collisions when linking (static
				       functions) */
	    LLVMPrivateLinkage,     /**< Like Internal, but omit from symbol table */
	    LLVMDLLImportLinkage,   /**< Function to be imported from DLL */
	    LLVMDLLExportLinkage,   /**< Function to be accessible from DLL */
	    LLVMExternalWeakLinkage,/**< ExternalWeak linkage description */
	    LLVMGhostLinkage,       /**< Stand-in functions for streaming fns from
				       bitcode */
	    LLVMCommonLinkage,      /**< Tentative definitions */
	    LLVMLinkerPrivateLinkage /**< Like Private, but linker removes. */
	    }

    enum LLVMVisibility {
	LLVMDefaultVisibility,  /**< The GV is visible */
	    LLVMHiddenVisibility,   /**< The GV is hidden */
	    LLVMProtectedVisibility /**< The GV is protected */
	    }

    enum LLVMCallConv {
	LLVMCCallConv           = 0,
	    LLVMFastCallConv        = 8,
	    LLVMColdCallConv        = 9,
	    LLVMX86StdcallCallConv  = 64,
	    LLVMX86FastcallCallConv = 65
	    }

    enum LLVMIntPredicate {
	LLVMIntEQ = 32, /**< equal */
	    LLVMIntNE,      /**< not equal */
	    LLVMIntUGT,     /**< int greater than */
	    LLVMIntUGE,     /**< int greater or equal */
	    LLVMIntULT,     /**< int less than */
	    LLVMIntULE,     /**< int less or equal */
	    LLVMIntSGT,     /**< signed greater than */
	    LLVMIntSGE,     /**< signed greater or equal */
	    LLVMIntSLT,     /**< signed less than */
	    LLVMIntSLE      /**< signed less or equal */
	    }

    enum LLVMRealPredicate {
	LLVMRealPredicateFalse, /**< Always false (always folded) */
	    LLVMRealOEQ,            /**< True if ordered and equal */
	    LLVMRealOGT,            /**< True if ordered and greater than */
	    LLVMRealOGE,            /**< True if ordered and greater than or equal */
	    LLVMRealOLT,            /**< True if ordered and less than */
	    LLVMRealOLE,            /**< True if ordered and less than or equal */
	    LLVMRealONE,            /**< True if ordered and operands are unequal */
	    LLVMRealORD,            /**< True if ordered (no nans) */
	    LLVMRealUNO,            /**< True if unordered: isnan(X) | isnan(Y) */
	    LLVMRealUEQ,            /**< True if unordered or equal */
	    LLVMRealUGT,            /**< True if unordered or greater than */
	    LLVMRealUGE,            /**< True if unordered, greater than, or equal */
	    LLVMRealULT,            /**< True if unordered or less than */
	    LLVMRealULE,            /**< True if unordered, less than, or equal */
	    LLVMRealUNE,            /**< True if unordered or not equal */
	    LLVMRealPredicateTrue   /**< Always true (always folded) */
	    }


    /*===-- Error handling ----------------------------------------------------===*/

    class Calls {
	pragma NoWarnUnsafe;
	native void LLVMDumpType( Type t );

	// native void LLVMLinkInJIT();

	// native void LLVMInitializeX86Target();
	// native void LLVMInitializeX86TargetInfo();

	native void LLVMDisposeMessage(char ptr Message);

	/*===-- Modules -----------------------------------------------------------===*/

	/* Create and destroy contexts. */

	native Context LLVMContextCreate();
	native Context LLVMGetGlobalContext();
	native void LLVMContextDispose(Context C);

	/* Create and destroy modules. */ 
	/** See llvm::Module::Module. */
	native Module LLVMModuleCreateWithName(char ptr ModuleID);
	native Module LLVMModuleCreateWithNameInContext(char ptr ModuleID,
							    Context C);

	/** See llvm::Module::~Module. */
	native void LLVMDisposeModule(Module M);

	/** Data layout. See Module::getDataLayout. */
	native char ptr LLVMGetDataLayout(Module M);
	native void LLVMSetDataLayout(Module M, char ptr Triple);

	/** Target triple. See Module::getTargetTriple. */
	native char ptr LLVMGetTarget(Module M);
	native void LLVMSetTarget(Module M, char ptr Triple);

	/** See Module::addTypeName. */
	native int LLVMAddTypeName(Module M, char ptr Name, Type Ty);
	native void LLVMDeleteTypeName(Module M, char ptr Name);
	native Type LLVMGetTypeByName(Module M, char ptr Name);

	/** See Module::dump. */
	native void LLVMDumpModule(Module M);

	/*===-- Types -------------------------------------------------------------===*/

	/* LLVM types conform to the following hierarchy:
	 * 
	 *   types:
	 *     integer type
	 *     real type
	 *     function type
	 *     sequence types:
	 *       array type
	 *       pointer type
	 *       vector type
	 *     void type
	 *     label type
	 *     opaque type
	 */

	/** See llvm::TypeKind::getTypeID. */
	native TypeKind LLVMGetTypeKind(Type Ty);

	/** See llvm::Type::getContext. */
	native Context LLVMGetTypeContext(Type Ty);

	/* Operations on integer types */
	native Type LLVMInt1TypeInContext(Context C);
	native Type LLVMInt8TypeInContext(Context C);
	native Type LLVMInt16TypeInContext(Context C);
	native Type LLVMInt32TypeInContext(Context C);
	native Type LLVMInt64TypeInContext(Context C);
	native Type LLVMIntTypeInContext(Context C, int NumBits);

	native Type LLVMInt1Type();
	native Type LLVMInt8Type();
	native Type LLVMInt16Type();
	native Type LLVMInt32Type();
	native Type LLVMInt64Type();
	native Type LLVMIntType(int NumBits);
	native int LLVMGetIntTypeWidth(Type IntegerTy);

	/* Operations on real types */
	native Type LLVMFloatTypeInContext(Context C);
	native Type LLVMDoubleTypeInContext(Context C);
	native Type LLVMX86FP80TypeInContext(Context C);
	native Type LLVMFP128TypeInContext(Context C);
	native Type LLVMPPCFP128TypeInContext(Context C);

	native Type LLVMFloatType();
	native Type LLVMDoubleType();
	native Type LLVMX86FP80Type();
	native Type LLVMFP128Type();
	native Type LLVMPPCFP128Type();

	/* Operations on function types */
	native Type LLVMFunctionType(Type ReturnType,
					 Type ptr ParamTypes, int ParamCount,
					 int IsVarArg);
	native int LLVMIsFunctionVarArg(Type FunctionTy);
	native Type LLVMGetReturnType(Type FunctionTy);
	native int LLVMCountParamTypes(Type FunctionTy);
	native void LLVMGetParamTypes(Type FunctionTy, Type ptr Dest);

	/* Operations on struct types */
	native Type LLVMStructTypeInContext(Context C, Type ptr ElementTypes,
						int ElementCount, int Packed);
	native Type LLVMStructType(Type ptr ElementTypes, int ElementCount,
				       int Packed);
	native int LLVMCountStructElementTypes(Type StructTy);
	native void LLVMGetStructElementTypes(Type StructTy, Type ptr Dest);
	native int LLVMIsPackedStruct(Type StructTy);

	/* Operations on array, pointer, and vector types (sequence types) */
	native Type LLVMArrayType(Type ElementType, int ElementCount);
	native Type LLVMPointerType(Type ElementType, int AddressSpace);
	native Type LLVMVectorType(Type ElementType, int ElementCount);

	native Type LLVMGetElementType(Type Ty);
	native int LLVMGetArrayLength(Type ArrayTy);
	native int LLVMGetPointerAddressSpace(Type PointerTy);
	native int LLVMGetVectorSize(Type VectorTy);

	/* Operations on other types */
	native Type LLVMVoidTypeInContext(Context C);
	native Type LLVMLabelTypeInContext(Context C);
	native Type LLVMOpaqueTypeInContext(Context C);

	native Type LLVMVoidType();
	native Type LLVMLabelType();
	native Type LLVMOpaqueType();

	/* Operations on type handles */
	native TypeHandle LLVMCreateTypeHandle(Type PotentiallyAbstractTy);
	native void LLVMRefineType(Type AbstractTy, Type ConcreteTy);
	native Type LLVMResolveTypeHandle(TypeHandle TypeHandle);
	native void LLVMDisposeTypeHandle(TypeHandle TypeHandle);


	/* Operations on all values */
	/*===-- Values ------------------------------------------------------------===*/

	/* The bulk of LLVM's object model consists of values, which comprise a very
	 * rich type hierarchy.
	 */


	native Type LLVMTypeOf(Value Val);
	native char ptr LLVMGetValueName(Value Val);
	native void LLVMSetValueName(Value Val, char ptr Name);
	native void LLVMDumpValue(Value Val);

	/* Conversion functions. Return the input value if it is an instance of the
	   specified class, otherwise NULL. See llvm::dyn_cast_or_null<>. */


	native long LLVMGetConstValue(Value v);

	native Value LLVMConstNull(Type Ty); /* all zeroes */
	native Value LLVMConstAllOnes(Type Ty); /* only for int/vector */
	native Value LLVMGetUndef(Type Ty);
	native int LLVMIsConstant(Value Val);
	native int LLVMIsNull(Value Val);
	native int LLVMIsUndef(Value Val);
	native Value LLVMConstPointerNull(Type Ty);

	/* Operations on scalar constants */
	native Value LLVMConstInt(Type IntTy, long N,
				      int SignExtend);


	native Value LLVMConstIntOfString(Type IntTy, char ptr Text,
					      char Radix);
	native Value LLVMConstIntOfStringAndSize(Type IntTy, char ptr Text,
						     int SLen, char Radix);
	// native Value LLVMConstReal(Type RealTy, double N);
	native Value LLVMConstRealOfString(Type RealTy, char ptr Text);
	native Value LLVMConstRealOfStringAndSize(Type RealTy, char ptr Text,
						      int SLen);


	/* Operations on composite constants */
	native Value LLVMConstStringInContext(Context C, char ptr Str,
						  int Length, int DontNullTerminate);
	native Value LLVMConstStructInContext(Context C, 
						  Value ptr ConstantVals,
						  int Count, int Packed);

	native Value LLVMConstString(char ptr Str, int Length,
					 int DontNullTerminate);
	native Value LLVMConstArray(Type ElementTy,
					Value ptr ConstantVals, int Length);
	native Value LLVMConstStruct(Value ptr ConstantVals, int Count,
					 int Packed);
	native Value LLVMConstVector(Value ptr ScalarConstantVals, int Size);

	/* Constant expressions */
	native Value LLVMAlignOf(Type Ty);
	native Value LLVMSizeOf(Type Ty);
	native Value LLVMConstNeg(Value ConstantVal);
	native Value LLVMConstFNeg(Value ConstantVal);
	native Value LLVMConstNot(Value ConstantVal);
	native Value LLVMConstAdd(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstNSWAdd(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstFAdd(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstSub(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstFSub(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstMul(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstFMul(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstUDiv(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstSDiv(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstExactSDiv(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstFDiv(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstURem(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstSRem(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstFRem(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstAnd(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstOr(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstXor(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstICmp(LLVMIntPredicate Predicate,
				       Value LHSConstant, Value RHSConstant);
	native Value LLVMConstFCmp(LLVMRealPredicate Predicate,
				       Value LHSConstant, Value RHSConstant);
	native Value LLVMConstShl(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstLShr(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstAShr(Value LHSConstant, Value RHSConstant);
	native Value LLVMConstGEP(Value ConstantVal,
				      Value ptr ConstantIndices, int NumIndices);
	native Value LLVMConstInBoundsGEP(Value ConstantVal,
					      Value ptr ConstantIndices,
					      int NumIndices);
	native Value LLVMConstTrunc(Value ConstantVal, Type ToType);
	native Value LLVMConstSExt(Value ConstantVal, Type ToType);
	native Value LLVMConstZExt(Value ConstantVal, Type ToType);
	native Value LLVMConstFPTrunc(Value ConstantVal, Type ToType);
	native Value LLVMConstFPExt(Value ConstantVal, Type ToType);
	native Value LLVMConstUIToFP(Value ConstantVal, Type ToType);
	native Value LLVMConstSIToFP(Value ConstantVal, Type ToType);
	native Value LLVMConstFPToUI(Value ConstantVal, Type ToType);
	native Value LLVMConstFPToSI(Value ConstantVal, Type ToType);
	native Value LLVMConstPtrToInt(Value ConstantVal, Type ToType);
	native Value LLVMConstIntToPtr(Value ConstantVal, Type ToType);
	native Value LLVMConstBitCast(Value ConstantVal, Type ToType);
	native Value LLVMConstZExtOrBitCast(Value ConstantVal,
						Type ToType);
	native Value LLVMConstSExtOrBitCast(Value ConstantVal,
						Type ToType);
	native Value LLVMConstTruncOrBitCast(Value ConstantVal,
						 Type ToType);
	native Value LLVMConstPointerCast(Value ConstantVal,
					      Type ToType);
	native Value LLVMConstIntCast(Value ConstantVal, Type ToType,
					  int isSigned);
	native Value LLVMConstFPCast(Value ConstantVal, Type ToType);
	native Value LLVMConstSelect(Value ConstantCondition,
					 Value ConstantIfTrue,
					 Value ConstantIfFalse);
	native Value LLVMConstExtractElement(Value VectorConstant,
						 Value IndexConstant);
	native Value LLVMConstInsertElement(Value VectorConstant,
						Value ElementValueConstant,
						Value IndexConstant);
	native Value LLVMConstShuffleVector(Value VectorAConstant,
						Value VectorBConstant,
						Value MaskConstant);
	native Value LLVMConstExtractValue(Value AggConstant, int ptr IdxList,
					       int NumIdx);
	native Value LLVMConstInsertValue(Value AggConstant,
					      Value ElementValueConstant,
					      int ptr IdxList, int NumIdx);
	native Value LLVMConstInlineAsm(Type Ty, 
					    char ptr AsmString, char ptr Constraints,
					    int HasSideEffects);

	/* Operations on global variables, functions, and aliases (globals) */
	native Module LLVMGetGlobalParent(Value Global);
	native int LLVMIsDeclaration(Value Global);
	native LLVMLinkage LLVMGetLinkage(Value Global);
	native void LLVMSetLinkage(Value Global, LLVMLinkage Linkage);
	native char ptr LLVMGetSection(Value Global);
	native void LLVMSetSection(Value Global, char ptr Section);
	native LLVMVisibility LLVMGetVisibility(Value Global);
	native void LLVMSetVisibility(Value Global, LLVMVisibility Viz);
	native int LLVMGetAlignment(Value Global);
	native void LLVMSetAlignment(Value Global, int Bytes);

	/* Operations on global variables */
	native Value LLVMAddGlobal(Module M, Type Ty, char ptr Name);
	native Value LLVMGetNamedGlobal(Module M, char ptr Name);
	native Value LLVMGetFirstGlobal(Module M);
	native Value LLVMGetLastGlobal(Module M);
	native Value LLVMGetNextGlobal(Value GlobalVar);
	native Value LLVMGetPreviousGlobal(Value GlobalVar);
	native void LLVMDeleteGlobal(Value GlobalVar);
	native Value LLVMGetInitializer(Value GlobalVar);
	native void LLVMSetInitializer(Value GlobalVar, Value ConstantVal);
	native int LLVMIsThreadLocal(Value GlobalVar);
	native void LLVMSetThreadLocal(Value GlobalVar, int IsThreadLocal);
	native int LLVMIsGlobalConstant(Value GlobalVar);
	native void LLVMSetGlobalConstant(Value GlobalVar, int IsConstant);

	/* Operations on aliases */
	native Value LLVMAddAlias(Module M, Type Ty, Value Aliasee,
				      char ptr Name);

	/* Operations on functions */
	native Value LLVMAddFunction(Module M, char ptr Name,
					 Type FunctionTy);
	native Value LLVMGetNamedFunction(Module M, char ptr Name);
	native Value LLVMGetFirstFunction(Module M);
	native Value LLVMGetLastFunction(Module M);
	native Value LLVMGetNextFunction(Value Fn);
	native Value LLVMGetPreviousFunction(Value Fn);
	native void LLVMDeleteFunction(Value Fn);
	native void LLVMRemoveFunction(Value Fn);
	native int LLVMGetIntrinsicID(Value Fn);
	native int LLVMGetFunctionCallConv(Value Fn);
	native void LLVMSetFunctionCallConv(Value Fn, LLVMCallConv cc);
	native char ptr LLVMGetGC(Value Fn);
	native void LLVMSetGC(Value Fn, char ptr Name);
	native void LLVMAddFunctionAttr(Value Fn, LLVMAttribute PA);
	native void LLVMRemoveFunctionAttr(Value Fn, LLVMAttribute PA);

	/* Operations on parameters */
	native int LLVMCountParams(Value Fn);
	native void LLVMGetParams(Value Fn, Value ptr Params);
	native Value LLVMGetParam(Value Fn, int Index);
	native Value LLVMGetParamParent(Value Inst);
	native Value LLVMGetFirstParam(Value Fn);
	native Value LLVMGetLastParam(Value Fn);
	native Value LLVMGetNextParam(Value Arg);
	native Value LLVMGetPreviousParam(Value Arg);
	native void LLVMAddAttribute(Value Arg, LLVMAttribute PA);
	native void LLVMRemoveAttribute(Value Arg, LLVMAttribute PA);
	native void LLVMSetParamAlignment(Value Arg, int align);

	/* Operations on basic blocks */
	native Value LLVMBasicBlockAsValue(BasicBlock BB);
	native int LLVMValueIsBasicBlock(Value Val);
	native BasicBlock LLVMValueAsBasicBlock(Value Val);
	native Value LLVMGetBasicBlockParent(BasicBlock BB);
	native int LLVMCountBasicBlocks(Value Fn);
	native void LLVMGetBasicBlocks(Value Fn, BasicBlock ptr BasicBlocks);
	native BasicBlock LLVMGetFirstBasicBlock(Value Fn);
	native BasicBlock LLVMGetLastBasicBlock(Value Fn);
	native BasicBlock LLVMGetNextBasicBlock(BasicBlock BB);
	native BasicBlock LLVMGetPreviousBasicBlock(BasicBlock BB);
	native BasicBlock LLVMGetEntryBasicBlock(Value Fn);

	native BasicBlock LLVMAppendBasicBlockInContext(Context C,
							    Value Fn,
							    char ptr Name);
	native BasicBlock LLVMInsertBasicBlockInContext(Context C,
							    BasicBlock BB,
							    char ptr Name);

	native BasicBlock LLVMAppendBasicBlock(Value Fn, char ptr Name);
	native BasicBlock LLVMInsertBasicBlock(BasicBlock InsertBeforeBB,
						   char ptr Name);

	native BasicBlock LLVMCreateBasicBlock(char ptr name);
	native void LLVMMoveBasicBlockAfter(BasicBlock bb, BasicBlock after);
	native void LLVMInsertBasicBlockAtEnd(Value function, BasicBlock bb);
	native void LLVMDeleteBasicBlock(BasicBlock BB);

	/* Operations on instructions */
	native BasicBlock LLVMGetInstructionParent(Value Inst);
	native Value LLVMGetFirstInstruction(BasicBlock BB);
	native Value LLVMGetLastInstruction(BasicBlock BB);
	native Value LLVMGetNextInstruction(Value Inst);
	native Value LLVMGetPreviousInstruction(Value Inst);

	/* Operations on call sites */
	native void LLVMSetInstructionCallConv(Value Instr, int CC);
	native int LLVMGetInstructionCallConv(Value Instr);
	native void LLVMAddInstrAttribute(Value Instr, int index, LLVMAttribute a);
	native void LLVMRemoveInstrAttribute(Value Instr, int index, 
					     LLVMAttribute a);
	native void LLVMSetInstrParamAlignment(Value Instr, int index, 
					       int align);

	/* Operations on call instructions (only) */
	native int LLVMIsTailCall(Value CallInst);
	native void LLVMSetTailCall(Value CallInst, int IsTailCall);

	/* Operations on phi nodes */
	native void LLVMAddIncoming(Value PhiNode, Value ptr IncomingValues,
				    BasicBlock ptr IncomingBlocks, int Count);
	native int LLVMCountIncoming(Value PhiNode);
	native Value LLVMGetIncomingValue(Value PhiNode, int Index);
	native BasicBlock LLVMGetIncomingBlock(Value PhiNode, int Index);

	/*===-- Instruction builders ----------------------------------------------===*/

	/* An instruction builder represents a point within a basic block, and is the
	 * exclusive means of building instructions using the C interface.
	 */

	native Builder LLVMCreateBuilderInContext(Context C);
	native Builder LLVMCreateBuilder();
	native void LLVMPositionBuilder(Builder Builder, BasicBlock Block,
					Value Instr);
	native void LLVMPositionBuilderBefore(Builder Builder, Value Instr);
	native void LLVMPositionBuilderAtEnd(Builder Builder, BasicBlock Block);
	native BasicBlock LLVMGetInsertBlock(Builder Builder);
	native void LLVMClearInsertionPosition(Builder Builder);
	native void LLVMInsertIntoBuilder(Builder Builder, Value Instr);
	native void LLVMInsertIntoBuilderWithName(Builder Builder, Value Instr,
						  char ptr Name);
	native void LLVMDisposeBuilder(Builder Builder);

	/* Terminators */
	native Value LLVMBuildRetVoid(Builder b);
	native Value LLVMBuildRet(Builder b, Value V);
	native Value LLVMBuildAggregateRet(Builder b, Value ptr RetVals,
					       int N);
	native Value LLVMBuildBr(Builder b, BasicBlock Dest);
	native Value LLVMBuildCondBr(Builder b, Value If,
					 BasicBlock Then, BasicBlock Else);
	native Value LLVMBuildSwitch(Builder b, Value V,
					 BasicBlock Else, int NumCases);
	native Value LLVMBuildInvoke(Builder b, Value Fn,
					 Value ptr Args, int NumArgs,
					 BasicBlock Then, BasicBlock Catch,
					 char ptr Name);
	native Value LLVMBuildUnwind(Builder b);
	native Value LLVMBuildUnreachable(Builder b);

	/* Add a case to the switch instruction */
	native void LLVMAddCase(Value Switch, Value OnVal,
				BasicBlock Dest);

	/* Arithmetic */
	native Value LLVMBuildAdd(Builder b, Value LHS, Value RHS,
				      char ptr Name);
	native Value LLVMBuildNSWAdd(Builder b, Value LHS, Value RHS,
					 char ptr Name);
	native Value LLVMBuildFAdd(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildSub(Builder b, Value LHS, Value RHS,
				      char ptr Name);
	native Value LLVMBuildFSub(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildMul(Builder b, Value LHS, Value RHS,
				      char ptr Name);
	native Value LLVMBuildFMul(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildUDiv(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildSDiv(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildExactSDiv(Builder b, Value LHS, Value RHS,
					    char ptr Name);
	native Value LLVMBuildFDiv(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildURem(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildSRem(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildFRem(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildShl(Builder b, Value LHS, Value RHS,
				      char ptr Name);
	native Value LLVMBuildLShr(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildAShr(Builder b, Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildAnd(Builder b, Value LHS, Value RHS,
				      char ptr Name);
	native Value LLVMBuildOr(Builder b, Value LHS, Value RHS,
				     char ptr Name);
	native Value LLVMBuildXor(Builder b, Value LHS, Value RHS,
				      char ptr Name);
	native Value LLVMBuildNeg(Builder b, Value V, char ptr Name);
	native Value LLVMBuildNot(Builder b, Value V, char ptr Name);

	/* Memory */
	native Value LLVMBuildMalloc(Builder b, Type Ty, char ptr Name);
	native Value LLVMBuildArrayMalloc(Builder b, Type Ty,
					      Value Val, char ptr Name);
	native Value LLVMBuildAlloca(Builder b, Type Ty, char ptr Name);
	native Value LLVMBuildArrayAlloca(Builder b, Type Ty,
					      Value Val, char ptr Name);
	native Value LLVMBuildFree(Builder b, Value PointerVal);
	native Value LLVMBuildLoad(Builder b, Value PointerVal,
				       char ptr Name);
	native Value LLVMBuildStore(Builder b, Value Val, Value Ptr);
	native Value LLVMBuildGEP(Builder B, Value Pointer,
				      Value ptr Indices, int NumIndices,
				      char ptr Name);
	native Value LLVMBuildInBoundsGEP(Builder B, Value Pointer,
					      Value ptr Indices, int NumIndices,
					      char ptr Name);
	native Value LLVMBuildStructGEP(Builder B, Value Pointer,
					    int Idx, char ptr Name);
	native Value LLVMBuildGlobalString(Builder B, char ptr Str,
					       char ptr Name);
	native Value LLVMBuildGlobalStringPtr(Builder B, char ptr Str,
						  char ptr Name);

	/* Casts */
	native Value LLVMBuildTrunc(Builder b, Value Val,
					Type DestTy, char ptr Name);
	native Value LLVMBuildZExt(Builder b, Value Val,
				       Type DestTy, char ptr Name);
	native Value LLVMBuildSExt(Builder b, Value Val,
				       Type DestTy, char ptr Name);
	native Value LLVMBuildFPToUI(Builder b, Value Val,
					 Type DestTy, char ptr Name);
	native Value LLVMBuildFPToSI(Builder b, Value Val,
					 Type DestTy, char ptr Name);
	native Value LLVMBuildUIToFP(Builder b, Value Val,
					 Type DestTy, char ptr Name);
	native Value LLVMBuildSIToFP(Builder b, Value Val,
					 Type DestTy, char ptr Name);
	native Value LLVMBuildFPTrunc(Builder b, Value Val,
					  Type DestTy, char ptr Name);
	native Value LLVMBuildFPExt(Builder b, Value Val,
					Type DestTy, char ptr Name);
	native Value LLVMBuildPtrToInt(Builder b, Value Val,
					   Type DestTy, char ptr Name);
	native Value LLVMBuildIntToPtr(Builder b, Value Val,
					   Type DestTy, char ptr Name);
	native Value LLVMBuildBitCast(Builder b, Value Val,
					  Type DestTy, char ptr Name);
	native Value LLVMBuildZExtOrBitCast(Builder b, Value Val,
						Type DestTy, char ptr Name);
	native Value LLVMBuildSExtOrBitCast(Builder b, Value Val,
						Type DestTy, char ptr Name);
	native Value LLVMBuildTruncOrBitCast(Builder b, Value Val,
						 Type DestTy, char ptr Name);
	native Value LLVMBuildPointerCast(Builder b, Value Val,
					      Type DestTy, char ptr Name);
	native Value LLVMBuildIntCast(Builder b, Value Val,
					  Type DestTy, char ptr Name);
	native Value LLVMBuildFPCast(Builder b, Value Val,
					 Type DestTy, char ptr Name);

	/* Comparisons */
	native Value LLVMBuildICmp(Builder b, LLVMIntPredicate Op,
				       Value LHS, Value RHS,
				       char ptr Name);
	native Value LLVMBuildFCmp(Builder b, LLVMRealPredicate Op,
				       Value LHS, Value RHS,
				       char ptr Name);

	/* Miscellaneous instructions */
	native Value LLVMBuildPhi(Builder b, Type Ty, char ptr Name);
	native Value LLVMBuildCall(Builder b, Value Fn,
				       Value ptr Args, int NumArgs,
				       char ptr Name);
	native Value LLVMBuildSelect(Builder b, Value If,
					 Value Then, Value Else,
					 char ptr Name);
	native Value LLVMBuildVAArg(Builder b, Value List, Type Ty,
					char ptr Name);
	native Value LLVMBuildExtractElement(Builder b, Value VecVal,
						 Value Index, char ptr Name);
	native Value LLVMBuildInsertElement(Builder b, Value VecVal,
						Value EltVal, Value Index,
						char ptr Name);
	native Value LLVMBuildShuffleVector(Builder b, Value V1,
						Value V2, Value Mask,
						char ptr Name);
	native Value LLVMBuildExtractValue(Builder b, Value AggVal,
					       int Index, char ptr Name);
	native Value LLVMBuildInsertValue(Builder b, Value AggVal,
					      Value EltVal, int Index,
					      char ptr Name);

	native Value LLVMBuildIsNull(Builder b, Value Val,
					 char ptr Name);
	native Value LLVMBuildIsNotNull(Builder b, Value Val,
					    char ptr Name);
	native Value LLVMBuildPtrDiff(Builder b, Value LHS,
					  Value RHS, char ptr Name);


	/*===-- Module providers --------------------------------------------------===*/

	/* Encapsulates the module M in a module provider, taking ownership of the
	 * module.
	 * See the constructor llvm::ExistingModuleProvider::ExistingModuleProvider.
	 */
	native ModuleProvider
	    LLVMCreateModuleProviderForExistingModule(Module M);

	/* Destroys the module provider MP as well as the contained module.
	 * See the destructor llvm::ModuleProvider::~ModuleProvider.
	 */
	native void LLVMDisposeModuleProvider(ModuleProvider MP);


	/*===-- Memory buffers ----------------------------------------------------===*/

	native int LLVMCreateMemoryBufferWithContentsOfFile(char ptr Path,
							    LLVMMemoryBuffer ptr OutMemBuf,
							    char ptr ptr OutMessage);
	native int LLVMCreateMemoryBufferWithSTDIN(LLVMMemoryBuffer ptr OutMemBuf,
						   char ptr ptr OutMessage);
	native void LLVMDisposeMemoryBuffer(LLVMMemoryBuffer MemBuf);


	/*===-- Pass Managers -----------------------------------------------------===*/

	/** Constructs a new whole-module pass pipeline. This type of pipeline is
	    suitable for link-time optimization and whole-module transformations.
	    See llvm::PassManager::PassManager. */
	native LLVMPassManager LLVMCreatePassManager();

	/** Constructs a new function-by-function pass pipeline over the module
	    provider. It does not take ownership of the module provider. This type of
	    pipeline is suitable for code generation and JIT compilation tasks.
	    See llvm::FunctionPassManager::FunctionPassManager. */
	native LLVMPassManager LLVMCreateFunctionPassManager(ModuleProvider MP);

	/** Initializes, executes on the provided module, and finalizes all of the
	    passes scheduled in the pass manager. Returns 1 if any of the passes
	    modified the module, 0 otherwise. See llvm::PassManager::run(Module&). */
	native int LLVMRunPassManager(LLVMPassManager PM, Module M);

	/** Initializes all of the function passes scheduled in the function pass
	    manager. Returns 1 if any of the passes modified the module, 0 otherwise.
	    See llvm::FunctionPassManager::doInitialization. */
	native int LLVMInitializeFunctionPassManager(LLVMPassManager FPM);

	/** Executes all of the function passes scheduled in the function pass manager
	    on the provided function. Returns 1 if any of the passes modified the
	    function, false otherwise.
	    See llvm::FunctionPassManager::run(Function&). */
	native int LLVMRunFunctionPassManager(LLVMPassManager FPM, Value F);

	/** Finalizes all of the function passes scheduled in in the function pass
	    manager. Returns 1 if any of the passes modified the module, 0 otherwise.
	    See llvm::FunctionPassManager::doFinalization. */
	native int LLVMFinalizeFunctionPassManager(LLVMPassManager FPM);

	/** Frees the memory of a pass pipeline. For function pipelines, does not free
	    the module provider.
	    See llvm::PassManagerBase::~PassManagerBase. */
	native void LLVMDisposePassManager(LLVMPassManager PM);


	native int LLVMCreateJITCompiler(LLVMExecutionEngine ptr OutJIT,
				  ModuleProvider MP,
				  int OptLevel,
				  char ptr ptr OutError);

	native LLVMTargetData LLVMGetExecutionEngineTargetData(LLVMExecutionEngine EE);
	native void LLVMAddTargetData(LLVMTargetData td, LLVMPassManager pm);

	native int LLVMRunFunctionAsMain(LLVMExecutionEngine EE, Value F,
				  int ArgC, char ptr ptr ArgV,
				  char ptr ptr EnvP);

	native LLVMGenericValue LLVMRunFunction(LLVMExecutionEngine EE, Value F,
					    int NumArgs,
					    LLVMGenericValue ptr Args);

	native void LLVMDisposeExecutionEngine(LLVMExecutionEngine EE);

	/*===-- Operations on generic values --------------------------------------===*/



	native LLVMGenericValue LLVMCreateGenericValueOfInt(Type Ty,
							long N,
							int IsSigned);

	native LLVMGenericValue LLVMCreateGenericValueOfPointer(word ptr P);

	// native LLVMGenericValueRef LLVMCreateGenericValueOfFloat(TypeRef Ty, double N);

	native int LLVMGenericValueIntWidth(LLVMGenericValue GenValRef);

	native long LLVMGenericValueToInt(LLVMGenericValue GenVal,
						 int IsSigned);

	native word ptr LLVMGenericValueToPointer(LLVMGenericValue GenVal);

	// double LLVMGenericValueToFloat(TypeRef TyRef, LLVMGenericValueRef GenVal);

	native void LLVMDisposeGenericValue(LLVMGenericValue GenVal);


	/* Verifies that a module is valid, taking the specified action if not.
   Optionally returns a human-readable description of any invalid constructs.
   OutMessage must be disposed with LLVMDisposeMessage. */
	native int LLVMVerifyModule(Module M, LLVMVerifierFailureAction Action,
			     char ptr ptr OutMessage);

	/* Verifies that a single function is valid, taking the specified action. Useful
	   for debugging. */
	native int LLVMVerifyFunction(Value Fn, LLVMVerifierFailureAction Action);

	/* Open up a ghostview window that displays the CFG of the current function.
	   Useful for debugging. */
	native void LLVMViewFunctionCFG(Value Fn);
	native void LLVMViewFunctionCFGOnly(Value Fn);

	/*
	Type LLVMGetStructElementType(Type type, int index) {
	    LLVM.Type t;

	    LLVMGetStructElementTypes(type, index, t.address);

	    t = [cast Type ptr(t) + index];

	    return t;
	}
	*/
	native void LLVMCleanUpFunction(Value function);

	native bool LLVMHasTerminator(LLVM.BasicBlock bb);

	native int LLVMWriteBitcodeToFile(Module M, char ptr path);

	static Value LLVMConstTypeSizeIndirect(Type type) {
	    // %Size = getelementptr %T* null, int 1
	    // %SizeI = cast %T* %Size to uint
	    
	    Value null_ = LLVMConstPointerNull(type);
	    Value[] indexes = {
		LLVMConstInt(LLVMInt32Type(), 1L, 0)
	    };

	    Value sp = LLVMConstGEP(null_, indexes.address, 1);

	    return LLVMConstPtrToInt(sp, LLVMInt32Type());
        }


	static Value LLVMConstTypeSizeIndirectPointer(Type type) {
	    // %Size = getelementptr %T* null, int 1
	    // %SizeI = cast %T* %Size to uint
	    
	    Value null_ = LLVMConstPointerNull(type);
	    Value[] indexes = {
		LLVMConstInt(LLVMInt32Type(), 1L, 0)
	    };

	    return LLVMConstGEP(null_, indexes.address, 1);
        }

	static Value LLVMConstTypeSize(Type type) {
	    // %Size = getelementptr %T* null, int 1
	    // %SizeI = cast %T* %Size to uint

	    return LLVMConstTypeSizeIndirect(LLVMPointerType(type,0));
        }

	private static TypeHandle llvm_vtable_function_type;
	static Type LLVMVTableFunctionType() {
	    if( llvm_vtable_function_type == null ) {
		var args = new Type[0];
		
		llvm_vtable_function_type = LLVMCreateTypeHandle(LLVMPointerType(LLVMFunctionType( LLVMInt32Type(), args.address, 0, 1 ),0));
	    }

	    var result = LLVMResolveTypeHandle(llvm_vtable_function_type);

	    return result;
	}

	private static TypeHandle llvm_vtable_type;
	static Type LLVMVTableType() {
	    if( llvm_vtable_type == null ) {
		llvm_vtable_type = LLVMCreateTypeHandle(LLVMPointerType(LLVMVTableFunctionType(),0));
	    }

	    return LLVMResolveTypeHandle(llvm_vtable_type);
	}

    }

    class State {
	public Module mod;
	void init() {

	    // BasicBlock entry = Calls.LLVMAppendBasicBlock(fac, `entry`);

	    // Calls.LLVMPositionBuilderAtEnd(builder, entry);

	}

	void dump() {
	    Calls.LLVMDumpModule( mod );
	}

	void add( System.String name, LLVM.Type type ) {
	    Calls.LLVMAddTypeName( mod, name.toCString(), type );
	}
    }
}

namespace Gen {
    use System.String;
    use System.Object;
    use Generic.Vector;
    use LLVM;
    use Parse.CompileState;    

    class IRBlock extends Object {
	CompileState state;
	Value function;
	Builder builder;
	BasicBlock entry_block;
	BasicBlock current_block;
	Value entry_jump;

	Vector<BasicBlock> at_end;

	void init( CompileState s, Value f ) {
	    state = s;
	    function = f;
	    builder = LLVM.Calls.LLVMCreateBuilder();
	    entry_block = LLVM.Calls.LLVMAppendBasicBlock(function,`entry`);
	    PositionEnd(entry_block);

	    var next_block = Block();
	    Label(next_block);	  

	    entry_jump = LLVM.Calls.LLVMGetLastInstruction(entry_block);
	}

	// Create a block outside any function:
	void init( CompileState s ) {
	    state = s;
	    builder = LLVM.Calls.LLVMCreateBuilder();
	    entry_block = LLVM.Calls.LLVMCreateBasicBlock(``);
	    current_block = entry_block;

	    PositionEnd(entry_block);
	}

	void PositionEnd(BasicBlock bb) {
	    current_block = bb;
	    Calls.LLVMPositionBuilderAtEnd(builder, current_block);
	}

	void Close() {
	    if( at_end != null ) {
		throw new System.Exception( "at-end blocks not yet linked into CFG" );
	    }
	    // Fixup();
	    LLVM.Calls.LLVMDisposeBuilder(builder);
	    builder = null;
	}

	get Builder Builder {
	    return builder;
	}

	void Verify() {
/*
            if( function == null ) {
		//
		return;
	    }

	    IO.Std.err.println( "verify from: " + new System.Backtrace() );
	    Calls.LLVMDumpValue(function);
	    //if( Calls.LLVMVerifyFunction( function, LLVM.LLVMVerifierFailureAction.LLVMPrintMessageAction ) != 0 ) {
	//	IO.Std.err.println( "borken from: " + new System.Backtrace() );
	    //}
*/
	}

	void Verify2() {
/* 
           if( function == null ) {
		//
		return;
	    }

	    IO.Std.err.println( "verify2 from: " + new System.Backtrace() ); IO.Std.err.flush();
	    Calls.LLVMDumpValue(function);
	    if( Calls.LLVMVerifyFunction( function, LLVM.LLVMVerifierFailureAction.LLVMPrintMessageAction ) != 0 ) {
		IO.Std.err.println( "borken from: " + new System.Backtrace() );
	    } else {
		IO.Std.err.println( "verify2 OK" ); IO.Std.err.flush();
	    }
*/
	}

        Value RetVoid() { return Calls.LLVMBuildRetVoid(builder); }
        Value Ret(Value v) { return Calls.LLVMBuildRet(builder, v); }

	// Jump without starting a new block. Not legal IR unless immediately followed by a new reachable block
	Value _Br(BasicBlock Dest) {
	    Verify();	    
	    return Calls.LLVMBuildBr(builder, Dest);
	}

	// jump to either t or f without starting a new block. Not legal IR unless immediately followed by a new reachable block
        Value _CondBr(Value c, BasicBlock t, BasicBlock f) {
	    Verify();
	    if( c == null ) {
		IO.Std.err.println( "_CondBr: c is null\n" ); IO.Std.err.flush();
	    }

	    if( t == null ) {
		IO.Std.err.println( "_CondBr: t is null\n" ); IO.Std.err.flush();
	    }

	    if( f == null ) {
		IO.Std.err.println( "_CondBr: f is null\n" ); IO.Std.err.flush();
	    }

	    return Calls.LLVMBuildCondBr(builder, c, t, f);
	}

	// create a new block in the current function. This block can be the target of jumps/branches but
	// no instructions are generated into it until it's made the current block with Label()
	BasicBlock Block() {
	    Verify();

	    // LLVM.Calls.LLVMDeleteBasicBlock(bb);

	    // return bb;
	    return LLVM.Calls.LLVMCreateBasicBlock(``);
	}

	BasicBlock BlockAtEnd() {
	    // IO.Std.err.println( "block at end..." );
	    Verify();
	    var result = Block();
	    addBlockAtEnd(result);
	    return result;
	}

	BasicBlock BlockAtEnd(String name) {
	    // IO.Std.err.println( "block at end " + name + "..." );
	    Verify();
	    var result = Block(name);
	    addBlockAtEnd(result);
	    return result;
	}

	void addBlockAtEnd(BasicBlock b) {
	    // IO.Std.err.println( "block at end:" );
	    // IO.Std.err.flush();
	    // Calls.LLVMDumpValue(b);

	    Verify();
	    if( at_end == null ) {
		at_end = new Vector<BasicBlock>();
	    }

	    at_end.add(b);
	}

	get BasicBlock CurrentBlock {
	    Verify();
	    return current_block;
	}

	set BasicBlock CurrentBlock = b {
	    Verify();
	    current_block = b;
	    PositionEnd(current_block);
	}

	BasicBlock Block(String name) {
	    Verify();

	    // LLVM.Calls.LLVMDeleteBasicBlock(bb);

	    // return bb;
	    return LLVM.Calls.LLVMCreateBasicBlock(name.toCString());
	}

	void AtEnd() {
/*
	    IO.Std.err.println( "add at end blocks..." );
	    IO.Std.err.println( "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
	    IO.Std.err.flush();
*/
	    Verify2();
	    if( at_end != null ) {
		BasicBlock last = null;
		foreach( var b; at_end.Iterator ) {
		    // IO.Std.err.println( "adding an at end block...." ); IO.Std.err.flush();
		    // Calls.LLVMDumpValue( cast LLVM.Value(b) );
		    Label( b );

		    Verify();
		    last = b;
		}
/*
		IO.Std.err.println( "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY" );
		IO.Std.err.println( "added all at end blocks" );
*/
		if( last != null && !Calls.LLVMHasTerminator(last) ) {
		    // IO.Std.err.println( "need to add unreachable..." );
		    var c = CurrentBlock;
		    CurrentBlock = last;
		    Unreachable();
		    CurrentBlock = last;
		// } else {
		    // IO.Std.err.println( "function should be valid without unreachable" );
		}
		at_end = null;
	    }
/*
	    IO.Std.err.println( "ZZZZZZZZZZZZZZZZZZZZZZZZ" );
	    IO.Std.err.println( "function complete" );
	    Verify2();
*/
	}

	// jump to the given block if the current block has no terminator instruction. Make the given block
	// the new current block
	void Label( BasicBlock bb ) {
	    Verify();
/*
	    IO.Std.err.print( "function initially: " ); IO.Std.err.flush();
	    Calls.LLVMDumpValue( function );
*/
	    /*
	    if( current_block != null ) {
		IO.Std.err.print( "current block: " ); IO.Std.err.flush();
		Calls.LLVMDumpValue(Calls.LLVMBasicBlockAsValue(current_block));
	    } else {
		IO.Std.err.println( "no current block" );
	    }
	    */

	    // IO.Std.err.print( "function is now: " ); IO.Std.err.flush();
	    if( current_block != null && !Calls.LLVMHasTerminator(current_block) ) {
		_Br(bb);
	    }		

	    if( current_block != null ) {
		Calls.LLVMInsertBasicBlockAtEnd(function, bb);
	    }

	    PositionEnd(bb);

	    // Verify();
	    // IO.Std.err.println( "function now:"); IO.Std.err.flush();
	    // Calls.LLVMDumpValue(function);
	    Verify();

	}


	// jump immediately followed by label of next block
	Value JumpLabel(BasicBlock dest, BasicBlock next) {
	    // IO.Std.err.println( "jump label" );
	    var result = _Br(dest);
	    Label(next);	  
	    Verify();

	    return result;
	}


	// jump to either t or next, linking next in after this instruction
	Value BranchLabel(Value c, BasicBlock t, BasicBlock next) {
	    // IO.Std.err.println( "branch-label" );
	    Value result = _CondBr(c, t, next);
	    Label(next);
	    Verify();

	    return result;
	}

	// jump followed by an unreachable block
	Value Jump(BasicBlock dest) {
	    // IO.Std.err.println( "jump" );
	    BasicBlock f = Block();
	    var result = JumpLabel(dest, f);
	    Verify();

	    return result;
	}


	// jump to either t or following instruction, adding a new block after this instruction
	Value Branch(Value c, BasicBlock t) {
	    // IO.Std.err.println( "branch from: " + new System.Backtrace() );
	    BasicBlock f = Block();
	    var result = BranchLabel(c, t, f);

	    // IO.Std.err.println( "after branch: " ); IO.Std.err.flush();
	    // Calls.LLVMDumpValue(result);
	    // IO.Std.err.println( "function is: " ); IO.Std.err.flush();
	    // Calls.LLVMDumpValue(function);
	    Verify();

	    return result;
	}



        Value Switch(Value V, BasicBlock Else, int NumCases) {
	    Verify();
	    return Calls.LLVMBuildSwitch(builder, V, Else, NumCases); 
	}

	void AddCase(Value switch_, Value on_value, BasicBlock dest) {
	    Verify();
	    Calls.LLVMAddCase(switch_, on_value, dest);
	}

	bool isConst(Value v) {
	    return Calls.LLVMIsConstant(v) != 0;
	}

        Value Invoke(Value Fn, Value[] Args, BasicBlock Then, BasicBlock Catch) {
	    Verify();
	    return Calls.LLVMBuildInvoke(builder, Fn, Args.address, Args.length,  Then, Catch, `` );
	}

	Value Unwind() {
	    Verify();
	    return Calls.LLVMBuildUnwind(builder);
	}

	void Unreachable() {
	    Verify();
	    Calls.LLVMBuildUnreachable(builder);
	}

        /* Arithmetic */
        Value Add(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildAdd(builder, LHS, RHS, `` );
	}

        Value NSWAdd(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildNSWAdd(builder, LHS, RHS, ``);
	}

        Value FAdd(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildFAdd(builder, LHS, RHS, ``);
	}
	
        Value Sub(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildSub(builder, LHS, RHS, ``);
	}

	Value FSub(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildFSub(builder, LHS, RHS, ``);
	}

	Value Mul(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildMul(builder, LHS, RHS, ``);
	}

	Value FMul(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildFMul(builder, LHS, RHS, ``);
	}

	Value UDiv(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildUDiv(builder, LHS, RHS, ``);
	}

	Value SDiv(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildSDiv(builder, LHS, RHS, ``);
	}

	Value ExactSDiv(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildExactSDiv(builder, LHS, RHS, ``);
	}

	Value FDiv(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildFDiv(builder, LHS, RHS, ``);
	}

	Value URem(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildURem(builder, LHS, RHS, ``);
	}

	Value SRem(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildSRem(builder, LHS, RHS, ``);
	}

	Value FRem(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildFRem(builder, LHS, RHS, ``);
	}

	Value Shl(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildShl(builder, LHS, RHS, ``);
	}

	Value LShr(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildLShr(builder, LHS, RHS, ``);
	}

	Value AShr(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildAShr(builder, LHS, RHS, ``);
	}

	Value And(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildAnd(builder, LHS, RHS, ``);
	}

	Value Or(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildOr(builder, LHS, RHS, ``);
	}

	Value Xor(Value LHS, Value RHS) {
	    Verify();
	    return Calls.LLVMBuildXor(builder, LHS, RHS, ``);
	}

	Value Neg(Value LHS) {
	    Verify();
	    return Calls.LLVMBuildNeg(builder, LHS, ``);
	}

	Value Not(Value LHS) {
	    Verify();
	    return Calls.LLVMBuildNot(builder, LHS, ``);
	}

	Value AllocaEntry(Type Ty, String name) {
	    Verify();
	    Calls.LLVMPositionBuilderBefore(builder, entry_jump);
	    var result = Calls.LLVMBuildAlloca(builder, Ty, name.toCString());
	    Calls.LLVMPositionBuilderAtEnd(builder, current_block);
	    Verify();
	    return result;
	}

	Value AllocaHere(Type Ty, String name) {
	    Verify();
	    return Calls.LLVMBuildAlloca(builder, Ty, name.toCString());
	}

	Value ArrayAllocaEntry(Type Ty, Value Val) {
	    Verify();
	    Calls.LLVMPositionBuilderBefore(builder, entry_jump);
	    return Calls.LLVMBuildArrayAlloca(builder, Ty, Val, ``);
	    Calls.LLVMPositionBuilderAtEnd(builder, current_block);
	}

	Value ArrayAllocaHere(Type Ty, Value Val) {
	    Verify();
	    return Calls.LLVMBuildArrayAlloca(builder, Ty, Val, ``);
	}

	Value Load(Value p) {
	    Verify();
	    return Calls.LLVMBuildLoad(builder, p, ``);	    
	}
	
	Value Store(Value v, Value p) {
	    Verify();
	    return Calls.LLVMBuildStore(builder, v, p);
	}

	Value GEP(Value p, Value[] i) {
	    Verify();
	    return Calls.LLVMBuildGEP(builder, p, i.address, i.length, ``);
	}

	Value InBoundsGEP( Value p, Value[] i) {
	    Verify();
	    return Calls.LLVMBuildInBoundsGEP(builder, p, i.address, i.length, ``);
	}

	Value StructGEP( Value p, int i ) {
	    Verify();
	    return Calls.LLVMBuildStructGEP(builder, p, i, ``);
	}        

	Value Phi(Type Ty) {
	    Verify();
	    return Calls.LLVMBuildPhi(builder, Ty, ``);
	}

	void AddIncoming( Value phi, Value[] v, BasicBlock[] b ) {
	    Verify();
	    if( v.length != b.length ) {
		throw new System.Exception( "AddIncoming value.length != block.length" );
	    }
	    Calls.LLVMAddIncoming( phi, v.address, b.address, v.length );
	}

	Value Call( Value f, Value[] args) {
	    Verify();
	    /*
	    IO.Std.err.print( "call f: " ); IO.Std.err.flush();
	    Calls.LLVMDumpType(Calls.LLVMTypeOf(f));

	    for( int i = 0; i < args.length; i = i + 1 ) {
		IO.Std.err.print( "param #" + i + ": "); IO.Std.err.flush();
		Calls.LLVMDumpType(Calls.LLVMTypeOf(args[i]));
	    }
	    */
	    
	    return Calls.LLVMBuildCall(builder, f, args.address, args.length, ``);
	}

	Value PtrToInt( Value v, Type d ) {
	    Verify();
	    return Calls.LLVMBuildPtrToInt(builder, v, d, `` );
	}

	Value IntToPtr( Value v, Type d ) {
	    Verify();
	    return Calls.LLVMBuildIntToPtr(builder, v, d, ``);
	}

	Value BitCast( Value v, Type d ) {
	    Verify();
	    return Calls.LLVMBuildBitCast(builder, v, d, ``);
	}

	Value IntCast( Value v, Type d ) {
	    Verify();
	    return Calls.LLVMBuildIntCast(builder, v, d, ``);
	}

	Value PointerCast( Value v, Type d ) {
	    Verify();
	    return Calls.LLVMBuildPointerCast(builder, v, d, ``);
	}

	Value SExtOrBitCast( Value v, Type d ) {
	    Verify();
	    return Calls.LLVMBuildSExtOrBitCast(builder, v, d, ``);
	}

	Value SExt( Value v, Type d ) {
	    Verify();
	    return Calls.LLVMBuildSExt(builder, v, d, ``);
	}

	Value Trunc( Value v, Type d ) {
	    Verify();
	    return Calls.LLVMBuildTrunc(builder, v, d, ``);
	}

	Value ICmp( LLVMIntPredicate op, Value l, Value r ) {
	    Verify();
	    return Calls.LLVMBuildICmp( builder, op, l, r, `` );
	}

	Value Select( Value b, Value t, Value f ) {
	    Verify();
	    return Calls.LLVMBuildSelect(builder, b, t, f, `` );
	}
    }
}