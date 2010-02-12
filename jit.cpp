// copyright (C) 2009-2010 degs <junk@giantblob.com> all rights reserved

// based on LLVM's lli.cpp

#include <iostream>

#include "llvm/Linker.h"
#include "llvm/LLVMContext.h"
#include "llvm/Module.h"
#include "llvm/ModuleProvider.h"
#include "llvm/Type.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/CodeGen/LinkAllCodegenComponents.h"
#include "llvm/ExecutionEngine/GenericValue.h"
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
static ExecutionEngine *execution_engine = 0;

static void do_shutdown() {
  delete execution_engine;
  llvm_shutdown();
}

extern "C" { 
  ExecutionEngine *__get_execution_engine() {
    return execution_engine;
  }

  static std::vector<Module *> modules;

  typedef void *func(void);

  static bool __enable_opt = false;
  void __JIT_enable_opt() {
    __enable_opt = true;
  }

  void *__call_function(char *function_name) {
    std::cerr << "looking for function '" << function_name << "'\n";
    Function *f;

    for( std::vector<Module*>::const_iterator i = modules.begin(); i != modules.end() ; ++i ) {
      f = (*i)->getFunction(function_name);
      if( f ) {
	break;
      }
    }

    if( !f ) {
      std::cerr << "oops: could not locate function '" << function_name << "' in module\n";
      return 0;
    }

    func *fp;

    fp = (func *)execution_engine->getPointerToFunction(f);

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

      /*
      Linker linker("lli", "output.bc", getGlobalContext(), 1);

      if( linker.LinkModules( main_module, module, &error_message ) ) {
	std::cerr << "LinkModules failed: " << error_message << "\n";
	return;
      }
      */
    } else {
      std::cerr << "no main module, will create execution engine...\n";

      InitializeNativeTarget();
      atexit(do_shutdown);  // Call llvm_shutdown() on exit.

      main_module = module;

      builder = new EngineBuilder(mp);

      std::cerr << "constructed builder\n";

      builder->setErrorStr(&error_message);
      builder->setEngineKind(EngineKind::JIT);

      CodeGenOpt::Level opt_level;

      if( __enable_opt ) {
	opt_level = CodeGenOpt::Default;
      } else {
	opt_level = CodeGenOpt::None;
      }

      builder->setOptLevel(opt_level);

      execution_engine = builder->create();
      std::cerr << "created execution engine\n";

      delete(builder);

      if (!execution_engine) {
	std::cerr << "execution engine is null\n";

	if (!error_message.empty()) {
	  errs() << "error creating execution_engine: " << error_message << "\n";
	} else {
	  errs() << "unknown error creating execution_engine!\n";
	}
	exit(1);
      }
    }

    modules.push_back(module);

    //for (Module::iterator I = main_module->begin(), E = main_module->end(); I != E; ++I) {
    for (Module::iterator I = module->begin(), E = module->end(); I != E; ++I) {
      Function *f = &*I;
      if(!f->isDeclaration()) {
        execution_engine->getPointerToFunction(f);
	f->deleteBody();
      }
    }

    std::cerr << "JIT'd all functions in: " << bitcode_name << "\n";

    execution_engine->runStaticConstructorsDestructors( /*module,*/ false);

    std::cerr << "initialized module: " << bitcode_name << "\n";

    // delete module;

    // delete mp;

    // delete buffer;
  }
}







