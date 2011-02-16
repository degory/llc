// copyright (C) 2009-2010 degs <junk@giantblob.com> all rights reserved

// based on LLVM's lli.cpp

#include <iostream>

#include "llvm/Linker.h"
#include "llvm/LLVMContext.h"
#include "llvm/Module.h"
// #include "llvm/ModuleProvider.h"
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
#include "llvm/Target/TargetOptions.h"
#include "llvm/Analysis/Verifier.h"
#include <cerrno>
using namespace llvm;

static Module *main_module = 0;
static EngineBuilder *builder;
static ExecutionEngine *execution_engine = 0;

enum LogLevel { DEBUG=0, INFO=1, WARN=2, ERROR=3, FATAL=4 };

extern "C" void _ZN4Util6Logger3logEiPc(int, const char *);

static void log(LogLevel level, const char *message) {
  _ZN4Util6Logger3logEiPc(level, message);
}

static void log(LogLevel level, struct std::basic_string<char, std::char_traits<char>, std::allocator<char> > message) {
  _ZN4Util6Logger3logEiPc(level, message.c_str());
}

static void do_shutdown() {
  delete execution_engine;
  llvm_shutdown();
}


extern "C" { 
  ExecutionEngine *__get_execution_engine() {
    return execution_engine;
  }
  typedef void *func(void);

  static std::vector<Module *> modules;
  static std::vector<func *> functions;

  static bool __enable_opt = false;
  static bool __enable_debug = true;

  void __JIT_enable_opt() {
    __enable_opt = true;
  }

  void __JIT_disable_opt() {
    __enable_opt = false;
  }

  void __JIT_enable_debug() {
    __enable_debug = true;
  }

  void __JIT_disable_debug() {
    __enable_debug = false;
  }


  void *__call_function(char *function_name) {
    // std::cerr << "looking for function '" << function_name << "'\n";
    Function *f;

    for( std::vector<Module*>::const_iterator i = modules.begin(); i != modules.end() ; ++i ) {
      f = (*i)->getFunction(function_name);
      if( f ) {
	break;
      }
    }

    if( !f ) {
      log( ERROR, std::string("JIT: could not locate function '") + function_name );
      return 0;
    }

    func *fp;

    fp = (func *)execution_engine->getPointerToFunction(f);

    if( !fp ) {
      log( ERROR, std::string("JIT: could not compile function '") + function_name );
      return 0;
    }

    // std::cerr << "will call function '" << function_name << "'\n";

    return fp();
  }

  void __load_module(char *bitcode_name) {
    std::string error_message;
    
    if( main_module == 0 ) {
      if( !llvm::JITExceptionHandling ) {
        llvm::JITExceptionHandling = true;
      }

      if( !llvm::JITEmitDebugInfo ) {
	llvm::JITEmitDebugInfo = true;
      }

      log( DEBUG, "JIT: starting up\n" );

      InitializeNativeTarget();
      atexit(do_shutdown);  // Call llvm_shutdown() on exit.
    }

    log( DEBUG, std::string("JIT: loading '") + bitcode_name );
  
    MemoryBuffer *buffer = MemoryBuffer::getFile(bitcode_name, &error_message);
    if( !buffer ) {
      log( ERROR, std::string("JIT: MemoryBuffer::getFile('") + bitcode_name + "') failed: " + error_message );
      return;
    }

    Module *module = getLazyBitcodeModule(buffer, getGlobalContext(), &error_message);

    if( !module ) {
      delete buffer;
      log( ERROR, std::string("JIT: get lazy bitcode module failed: ") + error_message );
      return;
    }
    
    if( module->MaterializeAllPermanently(&error_message) ) {
      log( ERROR, std::string("JIT: materialize module failed: ") + error_message );
      if( verifyModule(*module, PrintMessageAction, &error_message) ) {
	log( ERROR, std::string("JIT: module failed to verify: ") + error_message );
	module->dump();
      }    
    }

    if( main_module == 0 ) {
      main_module = module;

      builder = new EngineBuilder(module);

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

      delete(builder);

      if (!execution_engine) {
	log( ERROR, "JIT: execution engine is null" );

	if (!error_message.empty()) {
	  log( ERROR, std::string("JIT: error creating execution_engine: ") + error_message );
	} else {
	  log( ERROR, "JIT: unknown error creating execution_engine!" );
	}
	exit(1);
      }

      log( DEBUG, "JIT: created execution engine" );
    }

    modules.push_back(module);

#if 0
    for (Module::iterator I = module->begin(), E = module->end(); I != E; ++I) {
      Function *f = &*I;
      if(!f->isDeclaration()) {
        func *fp = (func *)execution_engine->getPointerToFunction(f);

	f->deleteBody();
      }
    }
#endif

    // std::cerr << "JIT'd all functions in: " << bitcode_name << "\n";

    execution_engine->runStaticConstructorsDestructors( module, false);

    log( DEBUG, std::string("JIT: initialized module: ") + bitcode_name );
  }
}







