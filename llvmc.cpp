#include "llvm/Type.h"
#include "llvm/Constants.h"
#include "llvm/LLVMContext.h"
#include "llvm/Support/CFG.h"
// #include "llvm/Support/Streams.h"
#include "llvm/Target/TargetData.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm-c/Core.h"

#include <sstream>
#include <cstring>

using namespace llvm;
using namespace std;

extern "C"
{
  void LLVMDumpType(LLVMTypeRef T) {
    unwrap(T)->dump();
  }

  bool LLVMHasTerminator(LLVMBasicBlockRef BB) {
    LLVMValueRef i = LLVMGetLastInstruction(BB);
    if( i == 0 ) {      
      return 0;
    } else {
      return LLVMIsATerminatorInst(i);
    }
  } 

  LLVMBasicBlockRef LLVMCreateBasicBlock(const char *name) {
    return wrap(BasicBlock::Create(getGlobalContext(),name));
  }

  void LLVMMoveBasicBlockAfter(LLVMBasicBlockRef bb, LLVMBasicBlockRef after) {
    unwrap(bb)->moveAfter(unwrap(after));
  }

  void LLVMInsertBasicBlockAtEnd(LLVMValueRef function, LLVMBasicBlockRef bb) {
    unwrap<Function>(function)->getBasicBlockList().push_back(unwrap(bb));
  }

  void LLVMRemoveFunction(LLVMValueRef Fn) {
    unwrap<Function>(Fn)->removeFromParent();
  }

  void LLVMCleanUpFunction(LLVMValueRef function) {
    Function *f = unwrap<Function>(function);
    int changed;
    do {
      changed = 0;
      int first = 1;
      
      for (Function::const_iterator BB = f->begin(), E = f->end(); BB != E; ++BB) {
	if( first ) {
	  first = 0;
	  continue;
	}
	
	int count = 0;
	for( const_pred_iterator PI = pred_begin(BB), E = pred_end(BB); PI != E; ++PI) {
	  count ++;
	}
	
	if( count == 0 ) {
	  // llvm::cerr << "basic block has no predecessors: " << *BB << "\n";

	  const BasicBlock *b = BB;
	  BasicBlock *c = (BasicBlock *)b;

	  DeleteDeadBlock(c);
	  // c->eraseFromParent();
	  changed = 1;
	  break;
	}
      }
    } while( changed );
  }

  unsigned long long LLVMGetConstValue(LLVMValueRef c) {
    ConstantInt *ci = unwrap<ConstantInt>(c);

    return ci->getValue().getLimitedValue();
  }

}
