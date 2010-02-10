//===- lli.cpp - LLVM Interpreter / Dynamic compiler ----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This utility provides a simple wrapper around the LLVM Execution Engines,
// which allow the direct execution of LLVM programs through a Just-In-Time
// compiler, or through an interpreter if no JIT is available for this platform.
//
//===----------------------------------------------------------------------===//


#include <iostream>

#include "llvm/Linker.h"
#include "llvm/LLVMContext.h"
#include "llvm/Module.h"
#include "llvm/ModuleProvider.h"
#include "llvm/Type.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/ExecutionEngine/GenericValue.h"
// #include "llvm/ExecutionEngine/Interpreter.h"
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/ExecutionEngine/JITEventListener.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/PluginLoader.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/System/Process.h"
#include "llvm/System/Signals.h"
#include "llvm/Target/TargetSelect.h"
#include <cerrno>
using namespace llvm;

static Module *main_module = 0;
static EngineBuilder *builder;
static ExecutionEngine *EE = 0;

static void do_shutdown() {
  delete EE;
  llvm_shutdown();
}

extern "C" { 
  ExecutionEngine *__get_EE() {
    return EE;
  }

  typedef void *func(void);

  void *__call_function(char *function_name) {
    std::cerr << "looking for function '" << function_name << "'\n";

    Function *f = main_module->getFunction(function_name);

    if( !f ) {
      std::cerr << "oops: could not locate function '" << function_name << "' in module\n";
      return 0;
    }

    func *fp;

    fp = (func *)EE->getPointerToFunction(f);

    if( !fp ) {
      std::cerr << "oops: could not compile function '" << function_name << "'\n";
      return 0;
    }

    std::cerr << "will call function '" << function_name << "'\n";

    return fp();
  }

  void __load_module(char *bitcode_name) {
    std::string error_message;
    
    std::cerr << "loading '" << bitcode_name << "'\n";
  
    MemoryBuffer *buffer = MemoryBuffer::getFile(bitcode_name, &error_message);
    if( !buffer ) {
      std::cerr << "oops: MemoryBuffer::getFile('%s') failed: " << error_message << "\n";
      return;
    }

    ModuleProvider *mp = getBitcodeModuleProvider(buffer, getGlobalContext(), &error_message);
    if( !mp ) {
      std::cerr << "getBitcodeModuleProvider() failed: " << error_message << "\n";
      delete buffer;
    }

    std::cerr << "actual load bitcode\n";

    Module *module = mp->materializeModule(&error_message);

    std::cerr << "after actual load bitcode: " << error_message << "\n";

    if( !module ) {
      std::cerr << "ModuleProvider::materializeModule() failed: " << error_message << "\n";
      return;
    }

    if( main_module != 0 ) {
      std::cerr << "main module exists, will use linker...\n";

      Linker linker("lli", "output.bc", getGlobalContext(), 1);

      if( linker.LinkModules( main_module, module, &error_message ) ) {
	std::cerr << "LinkModules failed: " << error_message << "\n";
	return;
      }
    } else {
      std::cerr << "no main module, will create execution engine...\n";

      InitializeNativeTarget();
      atexit(do_shutdown);  // Call llvm_shutdown() on exit.

      main_module = module;

      builder = new EngineBuilder(mp);

      std::cerr << "constructed builder\n";

      builder->setErrorStr(&error_message);
      builder->setEngineKind(EngineKind::JIT);

      CodeGenOpt::Level opt_level = CodeGenOpt::Default;
      builder->setOptLevel(opt_level);

      EE = builder->create();
      std::cerr << "created builder\n";

      delete(builder);

      if (!EE) {
	std::cerr << "execution engine is null\n";

	if (!error_message.empty()) {
	  errs() << "error creating EE: " << error_message << "\n";
	} else {
	  errs() << "unknown error creating EE!\n";
	}
	exit(1);
      }
    }

    //for (Module::iterator I = main_module->begin(), E = main_module->end(); I != E; ++I) {
    for (Module::iterator I = module->begin(), E = module->end(); I != E; ++I) {
      Function *f = &*I;
      if(!f->isDeclaration()) {
        EE->getPointerToFunction(f);
      }
    }

    std::cerr << "JIT'd all functions in: " << bitcode_name << "\n";

    EE->runStaticConstructorsDestructors( /*module,*/ false);

    std::cerr << "initialized module: " << bitcode_name << "\n";

    if( module != main_module ) {
      delete module;
    }

    // delete mp;

    // delete buffer;
  }
}







