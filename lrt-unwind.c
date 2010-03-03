#include <stdio.h>
#include <stdlib.h>
#include <unwind.h>
#include <gc/gc.h>

/* parts taken from https://llvm.org/svn/llvm-project/compiler-rt/trunk/lib/gcc_personality_v0.c (GPL)
 * parts taken from http://wiki.llvm.org/HowTo:_Build_JIT_based_Exception_mechanism University of Illinois Open Source License
 */

/*
typedef enum {
  _URC_NO_REASON = 0,
  _URC_FOREIGN_EXCEPTION_CAUGHT = 1,
  _URC_FATAL_PHASE2_ERROR = 2,
  _URC_FATAL_PHASE1_ERROR = 3,
  _URC_NORMAL_STOP = 4,
  _URC_END_OF_STACK = 5,
  _URC_HANDLER_FOUND = 6,
  _URC_INSTALL_CONTEXT = 7,
  _URC_CONTINUE_UNWIND = 8
} _Unwind_Reason_Code;

typedef int _Unwind_Action;
static const _Unwind_Action _UA_SEARCH_PHASE = 1;
static const _Unwind_Action _UA_CLEANUP_PHASE = 2;
static const _Unwind_Action _UA_HANDLER_FRAME = 4;
static const _Unwind_Action _UA_FORCE_UNWIND = 8;

struct _Unwind_Exception;

typedef void (*_Unwind_Exception_Cleanup_Fn)(_Unwind_Reason_Code reason, struct _Unwind_Exception *exc);



struct _Unwind_Context;

_Unwind_Reason_Code _Unwind_RaiseException( struct _Unwind_Exception *exception_object );
uint8 *_Unwind_GetLanguageSpecificData( struct _Unwind_Context *context);

_Unwind_Reason_Code (*__personality_routine)(
					     int version,
					     _Unwind_Action actions,
					     uint64 exceptionClass,
					     struct _Unwind_Exception *exceptionObject,
					     struct _Unwind_Context *context);
*/



typedef unsigned long long uintptr_t;

typedef unsigned long long uint64;

typedef unsigned int uint32;
typedef unsigned short uint16;
typedef unsigned char uint8;

typedef long long int64;
typedef int int32;
typedef short int16;
typedef signed char int8;

typedef unsigned long long uint64_t;

typedef unsigned int uint32_t;
typedef unsigned short uint16_t;
typedef unsigned char uint8_t;

// typedef long long int64_t;
typedef int int32_t;
typedef short int16_t;
typedef signed char int8_t;

#define DW_EH_PE_absptr    0x00
#define DW_EH_PE_uleb128   0x01
#define DW_EH_PE_udata2    0x02
#define DW_EH_PE_udata4    0x03
#define DW_EH_PE_udata8    0x04
#define DW_EH_PE_sleb128   0x09
#define DW_EH_PE_sdata2    0x0A
#define DW_EH_PE_sdata4    0x0B
#define DW_EH_PE_sdata8    0x0C

#define DW_EH_PE_pcrel     0x10
#define DW_EH_PE_textrel   0x20
#define DW_EH_PE_datarel   0x30
#define DW_EH_PE_funcrel   0x40
#define DW_EH_PE_aligned   0x50  
#define DW_EH_PE_indirect  0x80 /* gcc extension */



#define DW_EH_PE_omit 0xFF


#define L_EXCEPTION_CLASS 0x1EE71EE7DE95DE95ULL

struct OurExceptionType;

void __debug_init( char *name ) {
  //  fprintf( stderr, "__static_init: %s\n", name ); fflush(stderr);
}

void __add_roots( void *b, void *e ) {
  // printf( "GC_add_roots(%p,%p)\n", b, e ); fflush(stdout);
  GC_add_roots( b, e );  
}

static char *__root_low = 0;
static char *__root_high = 0;

void __add_root( char *g ) {
  int changed = 0;
  char *old_low = __root_low;
  char *old_high = __root_high;

  // printf( "GC register root %p\n", g ); fflush(stdout);

  if( !__root_low || g < __root_low ) {
    changed = 1;

    __root_low = g;
    // printf( "GC low root will be: %p\n", g ); fflush(stdout);
  }

  if( !__root_high || g > __root_high ) {
    changed = 1;
    __root_high = g;

    // printf( "GC high root will be: %p\n", g ); fflush(stdout);
  }

  if( changed ) {
    if( old_low ) {
      // printf( "GC remove roots %p,%p\n", old_low, old_high );
      GC_remove_roots( old_low, old_high + 8); fflush(stdout);
    }

    // printf( "GC roots now %p-%p\n", __root_low, __root_high );
    GC_add_roots( __root_low, __root_high + 8); fflush(stdout);
  }
}

void cleanup( _Unwind_Reason_Code reason, struct _Unwind_Exception *e ) {
  free(e);
}


struct _Unwind_Exception_L {
  struct _Unwind_Exception e;
  void *l_exception;
};

#define D(x)


extern char **backtrace_symbols(void **, int);

#define MAX_BACKTRACE_DEPTH 16
#define MAX_BACKTRACE_LENGTH 512
char *__get_backtrace() {
  void *buffer[MAX_BACKTRACE_DEPTH];
  char *result = (char *)GC_malloc(MAX_BACKTRACE_LENGTH);
  int i;
  int n = backtrace(buffer, MAX_BACKTRACE_DEPTH);

  char **symbols = backtrace_symbols(buffer, n);

  for( i = 0; i < n; i++ ) {
    printf( symbols[i] );
  }

  return "argh";
}

typedef struct _Exception {
  void   *vtable;
  void   *backtrace;
  void   *message;
} Exception;


struct _Unwind_Exception *makeException( void *l_exception ) {
  struct _Unwind_Exception_L *result = (struct _Unwind_Exception_L *)malloc(sizeof(struct _Unwind_Exception_L));

  result->e.exception_class = L_EXCEPTION_CLASS;
  result->e.exception_cleanup = cleanup;
  result->l_exception = l_exception;

  D( fprintf( stderr, "exception class is: %ul\n", result->e.exception_class ) );

  D( fprintf( stderr, "AAA: l exception: %p\n", l_exception ) );
  D( fprintf( stderr, "AAA:  result:     %p\n", result ) );

  D( fprintf( stderr, "\n" ) );
  D( fflush(stderr) );
  return (struct _Unwind_Exception *)result;
}

void *__get_l_exception( struct _Unwind_Exception_L *e ) {
  D( fprintf( stderr, "__get_l_exception: %p\n", e ) );
  D( fprintf( stderr, "exception object: %p\n", e->l_exception ) );
  D( fflush( stderr ) );

  return e->l_exception;
}


/* read a uleb128 encoded value and advance pointer */
uintptr_t readULEB128(uint8** data) {
  uintptr_t result = 0;
  uintptr_t shift = 0;
  unsigned char byte;
  uint8* p = *data;
  do {
    byte = *p++;
    result |= (byte & 0x7f) << shift;
    shift += 7;
  } while (byte & 0x80);
  *data = p;
  return result;
}

uintptr_t readSLEB128(uint8** data)
{
  uintptr_t result = 0;
  uintptr_t shift = 0;
  unsigned char byte;
  uint8* p = *data;

  do {
    byte = *p++;
    result |= (byte & 0x7f) << shift;
    shift += 7;
  } while (byte & 0x80);

  *data = p;

  // Note: Not sure this works
  //
  if ((byte & 0x40) && (shift < (sizeof(result) << 3))) {
    // Note: I wonder why I can't do: ~0 << shift
    //
    // result |= -(1L << shift);
    result |= (~0 << shift);
  }

  return result;
}

static uintptr_t readEncodedPointer(const uint8** data, uint8 encoding)
{
  const uint8* p = *data;
  uintptr_t result = 0;

  if (encoding != DW_EH_PE_omit) 
    {
      /* first get value 
       */
      switch (encoding & 0x0F) 
        {
	case DW_EH_PE_absptr:
	  result = *((uintptr_t*)p);
	  p += sizeof(uintptr_t);
	  break;
	case DW_EH_PE_uleb128:
	  result = readULEB128(&p);
	  break;
	  // Note: This case has not been tested
	  //
	case DW_EH_PE_sleb128:
	  result = readSLEB128(&p);
	  break;
	case DW_EH_PE_udata2:
	  result = *((uint16*)p);
	  p += sizeof(uint16);
	  break;
	case DW_EH_PE_udata4:
	  result = *((uint32*)p);
	  p += sizeof(uint32);
	  break;
	case DW_EH_PE_udata8:
	  result = *((uint64*)p);
	  p += sizeof(uint64);
	  break;
	case DW_EH_PE_sdata2:
	  result = *((int16*)p);
	  p += sizeof(int16);
	  break;
	case DW_EH_PE_sdata4:
	  result = *((int32*)p);
	  p += sizeof(int32);
	  break;
	case DW_EH_PE_sdata8:
	  result = *((int64*)p);
	  p += sizeof(int64);
	  break;
	default:
	  /* not supported 
	   */
	  abort();
	  break;
        }

      /* then add relative offset 
       */
      switch ( encoding & 0x70 ) 
        {
	case DW_EH_PE_absptr:
	  /* do nothing 
	   */
	  break;
	case DW_EH_PE_pcrel:
	  result += (uintptr_t)(*data);
	  break;
	case DW_EH_PE_textrel:
	case DW_EH_PE_datarel:
	case DW_EH_PE_funcrel:
	case DW_EH_PE_aligned:
	default:
	  /* not supported 
	   */
	  abort();
	  break;
        }

      /* then apply indirection 
       */
      if (encoding & DW_EH_PE_indirect) 
        {
	  result = *((uintptr_t*)result);
        }

      *data = p;
    }

  return result;
}


#if 0
/* read a pointer encoded value and advance pointer */
uintptr_t readEncodedPointer_borken(uint8** data, uint8 encoding) {

  D( fprintf( stderr, "read encoded pointer %p\n", data ) );
  D( fprintf( stderr, "encoding %02X\n", encoding ) );

  uint8* p = *data;
  uintptr_t result = 0;

  D( fprintf( stderr, "p %p\n", p ) );

  if ( encoding == DW_EH_PE_omit ) {
    D( fprintf( stderr, "encoding is null\n" ) );
    return 0;
  }

  /* first get value */
  switch (encoding & 0x0F) {
  case DW_EH_PE_absptr:
    D( fprintf( stderr, "DW_EH_PE_absptr:\n" ) );
    result = *((uintptr_t*)p);
    p += sizeof(uintptr_t);
    break;
  case DW_EH_PE_uleb128:
    D( fprintf( stderr, "DW_EH_PE_uleb128:\n" ) );
    result = readULEB128(&p);
    break;
  case DW_EH_PE_udata2:
    D( fprintf( stderr, "DW_EH_PE_udata2:\n" ) );
    result = *((uint16*)p);
    p += sizeof(uint16);
    break;
  case DW_EH_PE_udata4:
    D( fprintf( stderr, "DW_EH_PE_udata4:\n" ) );
    result = *((uint32*)p);
    p += sizeof(uint32);
    break;
  case DW_EH_PE_udata8:
    D( fprintf( stderr, "DW_EH_PE_udata8:\n" ) );
    result = *((uint64*)p);
    p += sizeof(uint64);
    D( fprintf( stderr, "read %lx\n", result ) );
    break;
  case DW_EH_PE_sdata2:
    D( fprintf( stderr, "DW_EH_PE_sdata2:\n" ) );
    result = *((int16*)p);
    p += sizeof(int16);
    break;
  case DW_EH_PE_sdata4:
    D( fprintf( stderr, "DW_EH_PE_sdata4:\n" ) );
    result = *((int32*)p);
    p += sizeof(int32);
    break;
  case DW_EH_PE_sdata8:
    D( fprintf( stderr, "DW_EH_PE_sdata8:\n" ) );
    result = *((int64*)p);
    p += sizeof(int64);
    break;
  case DW_EH_PE_sleb128:
    D( fprintf( stderr, "DW_EH_PE_sleb128:\n" ) );
    result = readSLEB128(&p);
    break;

  default:
    D( fprintf( stderr, "not supported %02X default\n", encoding ) );
    /* not supported */
    abort();
    break;
  }

  D( fprintf( stderr, "intermediate result %lx\n", result ) );
  /* then add relative offset */
  switch ( encoding & 0x70 ) {
  case DW_EH_PE_absptr:
    D( fprintf( stderr, "absptr\n" ) );
    /* do nothing */
    break;
  case DW_EH_PE_pcrel:
    D( fprintf( stderr, "pcrel\n" ) );
    result += (uintptr_t)(*data);
    D( fprintf( stderr, "result %lx\n", result ) );
    break;
  case DW_EH_PE_textrel:
    D( fprintf( stderr, "not supported relative %02X textrel\n", (encoding & 0x70) ) );
    abort();
  case DW_EH_PE_datarel:
    D( fprintf( stderr, "not supported relative %02X datarel\n", (encoding & 0x70) ) );
    abort();
  case DW_EH_PE_funcrel:
    D( fprintf( stderr, "not supported relative %02X funcrel\n", (encoding & 0x70) ) );
    abort();
  case DW_EH_PE_aligned:
    D( fprintf( stderr, "not supported relative %02X aligned\n", (encoding & 0x70) ) );
    abort();
  default:
    D( fprintf( stderr, "not supported relative %02X default\n", (encoding & 0x70) ) );
    /* not supported */
    abort();
    break;
  }

  D( fprintf( stderr, "maybe indirect?\n" );
  /* then apply indirection */
  if (encoding & DW_EH_PE_indirect) {
    D( fprintf( stderr, "indirect\n" ) );
    result = *((uintptr_t*)result);
    D( fprintf( stderr, "indirect result %lx\n", result ) );
  }

     D( fprintf( stderr, "final result %lx\n", result ) );
  *data = p;
     D( fprintf( stderr, "returning\n" ) );
  return result;
}
#endif

int handleActionValue(
		      int64 *resultAction,
		      void *classInfo,
		      uintptr_t actionEntry,
		      uint64 exceptionClass,
		      struct _Unwind_Exception *exceptionObject
		      ) {
  int ret = 1;

  if (resultAction && exceptionObject && (exceptionClass == L_EXCEPTION_CLASS)) {
    //    struct OurBaseException_t* excp = (struct OurBaseException_t*)
    //  (((char*) exceptionObject) + baseFromUnwindOffset);
    
    // struct OurExceptionType_t *excpType = &(excp->type);
    
    int type = 1;
    
    D(fprintf(stderr,
	    "handleActionValue(...): exceptionObject = %p, class info: %p\n",
	      exceptionObject, classInfo ) );

    uint8 *actionPos = (uint8*) actionEntry,
      *tempActionPos;
    
    int64 typeOffset = 0,
      actionOffset;
    
    int i;
    for(i = 0; 1; ++i) {
      // Each emitted dwarf action corresponds to a 2 tuple of
      // type info address offset, and action offset to the next
      // emitted action.
      //
      typeOffset = readSLEB128(&actionPos);
      tempActionPos = actionPos;
      actionOffset = readSLEB128(&tempActionPos);
      
      D(
	fprintf(stderr,
		"handleActionValue(...):typeOffset: <%lld>, "
		"actionOffset: <%lld>.\n",
		typeOffset,
		actionOffset)
	);
      // Note: A typeOffset == 0 implies that a cleanup llvm.eh.selector
      //       argument has been matched.
      //
      if ((typeOffset > 0)/* &&
			     (type == (classInfo[-typeOffset])->type)*/) {
	D( fprintf(stderr,
		"handleActionValue(...):actionValue <%d> found.\n",
		   i) );

	*resultAction = i + 1;
	ret = 1;
	break;
      } else {
	D(fprintf(stderr,
		  "handleActionValue(...):actionValue not found.\n"));

	if (actionOffset) {
	  actionPos += actionOffset;
	} else {
	  break;
	}
      }
    }
  }
  return ret;
}


_Unwind_Reason_Code handleLsda(
			       int version,
			       uint8 *lsda,
			       _Unwind_Action actions,
			       uint64 exceptionClass,
			       struct _Unwind_Exception* exceptionObject,
                               struct _Unwind_Context *context
			       ) {

  if( version < 0 ) {
    return _URC_CONTINUE_UNWIND;
  }

  _Unwind_Reason_Code ret = _URC_CONTINUE_UNWIND;
  
  if( lsda ) {
    D( fprintf( stderr, "have LSDA %p\n", lsda ) );
  } else {
    D( fprintf( stderr, "no LSDA\n" ) );
  }

  uintptr_t pc = _Unwind_GetIP(context)-1;

  D( fprintf( stderr, "PC is %p\n", (void *)pc ) );

  // Get beginning current frame's code (as defined by the
  // emitted dwarf code)
  //
  uintptr_t funcStart = _Unwind_GetRegionStart(context);
  uintptr_t pcOffset = pc - funcStart;

  D( fprintf( stderr, "func start is %p\n", (void *)funcStart  ) );
  D( fprintf( stderr, "pcOffset is %p\n", (void *)pcOffset ) );

  if( lsda == 0 ) {
    D( fprintf( stderr, "no lsda\n" ) );
    return ret;
  }

  struct OurExceptionType** classInfo = NULL;

  //
  // Note: See JITDwarfEmitter::EmitExceptionTable(...) for corresponding
  //       dwarf emittion
  //

  /* Parse LSDA header. */
  //
  uint8 lpStartEncoding = *lsda++;

  D( fprintf( stderr, "start encoding is %d\n", lpStartEncoding ));

  if (lpStartEncoding != DW_EH_PE_omit) {
    D( fprintf( stderr, "read encoded pointer start encoding %x\n", lpStartEncoding ) );
    readEncodedPointer(&lsda, lpStartEncoding);
    D( fprintf(  stderr, "done\n" ) );
  }

  uint8 ttypeEncoding = *lsda++;
  uintptr_t classInfoOffset;
  if (ttypeEncoding != DW_EH_PE_omit) {
    D( fprintf( stderr, "read type arguments %x\n", ttypeEncoding ) );
    // Calculate type info locations in emitted dwarf code which
    // were flagged by type info arguments to llvm.eh.selector
    // intrinsic
    //readULEB128(uint8** data) {
    classInfoOffset = readULEB128(&lsda); // readEncodedPointer(&lsda, ttypeEncoding);

    D( fprintf( stderr, "finished type arguments\n" ) );
    classInfo = (struct OurExceptionType**) (lsda + classInfoOffset);
  }

  D( fprintf( stderr, "initial call site walk\n" ) );

  /* Walk call-site table looking for range that
   * includes current PC.
   */
  uint8         callSiteEncoding = *lsda++;
  D( fprintf( stderr, "call site encoding %d\n", callSiteEncoding ) );
  uint32        callSiteTableLength = readULEB128(&lsda);
  D( fprintf( stderr, "call site table length %d\n", callSiteTableLength ) );
  uint8*  callSiteTableStart = lsda;
  D( fprintf( stderr, "call site table start %p\n", callSiteTableStart ) );
  uint8*  callSiteTableEnd = callSiteTableStart + callSiteTableLength;
  D( fprintf( stderr, "call site table end %p\n", callSiteTableEnd ) );
  uint8*  actionTableStart = callSiteTableEnd;

  uint8*  callSitePtr = callSiteTableStart;

  int is_L_exception = exceptionClass == L_EXCEPTION_CLASS;
  int have_landing_pad = 0;

  D( fprintf( stderr, "before loop\n" ) );
  while (callSitePtr < callSiteTableEnd) {
    uintptr_t start = readEncodedPointer(&callSitePtr,
					 callSiteEncoding);

    // D( fprintf( stderr, "start %p\n", start ) );
    uintptr_t length = readEncodedPointer(&callSitePtr,
					  callSiteEncoding);

    // D( fprintf( stderr, "length %ld\n", length ) );
    uintptr_t landingPad = readEncodedPointer(&callSitePtr,
					      callSiteEncoding);

    // D( fprintf( stderr, "landing pad %p\n", landingPad ) );
    // Note: Action value
    //
    uintptr_t actionEntry = readULEB128(&callSitePtr);
    // D( fprintf( stderr, "action entry %ld\n", actionEntry ) );

    /*    

	  don't care - still offer it to catches but marked as foreign:
    if( !is_L_exception ) {
      D( fprintf( stderr, "XXXXX: foreign exception %llx\n", exceptionClass ) );
      if( actionEntry != 0 ) {
	D( fprintf( stderr, "ignoring existing action entry %llx\n", actionEntry ) );
      }
      // We have been notified of a foreign exception being thrown,
      // and we therefore need to execute cleanup landing pads
      //
      actionEntry = 0;
    } else {
      D( fprintf( stderr, "L exception %llx\n", exceptionClass ) );
    }
    */

    if (landingPad == 0) {
      /*
      D( fprintf(stderr,
		 "handleLsda(...): No landing pad found.\n") );
      */
      continue; /* no landing pad for this entry */
    }

    have_landing_pad = 1;

    if (actionEntry) {
      actionEntry += ((uintptr_t) actionTableStart) - 1;
    } /* else {
      D( fprintf(stderr,
		 "handleLsda(...):No action table found.\n" ) );
    }
      */


    if ((start <= pcOffset) && (pcOffset < (start + length))) {
      if (actions & _UA_SEARCH_PHASE) {
	D( fprintf(stderr,
		   "LLLL handleLsda(...): Landing pad found, should return handler found\n") );
      } else {
	D( fprintf(stderr,
		   "LLLL handleLsda(...): Landing pad found, should branch to it\n") );
      }
      uint64 actionValue = 0;

      if( !actionEntry ) {
	fprintf(stderr, "no action entry for code region: probably an error\n" );
      }

      /*
      if (actionEntry) {
	D( fprintf( stderr, "call handle action value\n" ) );
	exceptionMatched = handleActionValue(
					     &actionValue,
					     classInfo,
					     actionEntry,
					     exceptionClass,
					     exceptionObject
					     );
	D( fprintf( stderr, "exception matched = %d\n", exceptionMatched ) );
      } else {
	D( fprintf( stderr, "LLLL: unexpected, no action entry despite landing pad\n" ) );
      }
      */

      if (!(actions & _UA_SEARCH_PHASE)) {
	if( !have_landing_pad ) {
	  fprintf(stderr, "LLLL: not in search phase and have no landing pad: expect trouble\n" );
	}

	D( fprintf(stderr, "LLLL: prepare to branch to landing pad...\n" ) );

	/* Found landing pad for the PC.
	 * Set Instruction Pointer to so we re-enter function
	 * at landing pad. The landing pad is created by the
	 * compiler to take two parameters in registers.
	 */
	D( fprintf( stderr, "set exception object in register 0\n" ) );
	
	_Unwind_SetGR(context,
		      __builtin_eh_return_data_regno(0),
		      (uintptr_t)exceptionObject);
	
	// Note: this virtual register directly corresponds
	//       to the return of the llvm.eh.selector intrinsic
	//
	
	_Unwind_SetGR(context,
		      __builtin_eh_return_data_regno(1),
		      is_L_exception ? 2 : 4);
	
	// To execute landing pad set here
	//
	D( fprintf( stderr, "return to IP %p\n", (funcStart + landingPad) ) );
	_Unwind_SetIP(context, funcStart + landingPad);
	
	ret = _URC_INSTALL_CONTEXT;
	
	break;
      } else {
	if( have_landing_pad ) {
	  if( is_L_exception ) {
	    D( fprintf(stderr,
		       "have landing pad for L exception\n") );
	  } else {
	    D( fprintf(stderr,
		       "have landing pad for foreign exception\n") );
	  }
	  ret = _URC_HANDLER_FOUND;
	} else {
	  //
	  // Note: Only non-clean up handlers are marked as
	  //       found. Otherwise the clean up handlers will be
	  //       re-found and executed during the clean up
	  //       phase.
	  //
	  D( fprintf(stderr,
		     "XXXX: cleanup handler found: almost certainly wrong.\n") );
	  
	  // FIXME: cheat:
	  // ret = _URC_HANDLER_FOUND;
	}
	
	break;
      }
    }
  }
  
  D( fprintf( stderr, "returning %x\n", ret ) );
  return ret;
}


 __attribute__((noinline)) _Unwind_Reason_Code __l_personality(
				    int version, 
				    _Unwind_Action actions,
				    uint64 exceptionClass, 
				    struct _Unwind_Exception* exceptionObject,
				    struct _Unwind_Context* context
				    ) {

   D( fprintf(stderr, "unwind exception: %p (%lld)\n", exceptionObject, (long long)exceptionObject); fflush(stderr); );
  _Unwind_Reason_Code ret = _URC_CONTINUE_UNWIND;

  if( version < 0 ) {
    return _URC_CONTINUE_UNWIND;
  }

  D( fprintf(stderr, 
	  "We are in ourPersonality(...):actions is <%d>.\n",
	     actions); fflush(stderr) );

  if (actions & _UA_SEARCH_PHASE) {
    D( fprintf(stderr, "ourPersonality(...):In search phase.\n" ) );
  } else {
    D( fprintf(stderr, "ourPersonality(...):In non-search phase.\n") );
  }
  
  D( fprintf( stderr, "context is %p\n", context ) );
     
  uint8 *lsda = (uint8*) _Unwind_GetLanguageSpecificData(context);
  
  D( fprintf(stderr, "lsda is %p\n", lsda ) );

  ret = handleLsda(
		   version,
		   lsda,
		   actions,
		   exceptionClass,
		   exceptionObject,
		   context
		   );
  
  D( fprintf( stderr, "result is %d\n", ret ) );

  return ret;
}

void __throw_exception_broken( void *l_exception ) {
  _Unwind_RaiseException( makeException(l_exception) );
  fprintf( stderr, "oops: unwind raise exception should not return\n" );
  fflush(stderr);
  abort();
}  

