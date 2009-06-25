
#define GC_DEBUG 1
#define POSIX_SOURCE 1
#include <sys/types.h>
#include <sys/stat.h>
// #include <sigcontext.h>
// #include <ucontext.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>

#include <gc/gc.h>

typedef void ExFunc(int type, void *ex);

#define CATCH_RETURN 0
#define CATCH_FINALLY 1
#define CATCH_EXCEPTION 2

#define THROW_RETURN 3 
#define THROW_EXCEPTION 4
#define THROW_FINALLY 5
#define THROW_STOP 6

typedef unsigned long u8;

// #define D(e...) printf(e)
#define D(e...)

// #define D(e) printf e

typedef struct _Registers {
  u8 r8;     // +0
  u8 r9;     // +8
  u8 r10;    // +16
  u8 r11;    // +24
  u8 r12;    // +32
  u8 r13;    // +40
  u8 r14;    // +48
  u8 r15;    // +56
  u8 rdi;    // +64
  u8 rsi;    // +72
  u8 rbp;    // +80
  u8 rbx;    // +88
  u8 rdx;    // +96
  u8 rax;    // +104
  u8 rcx;    // +112
  u8 rsp;    // +128
  u8 rflags; // +136
} Registers;


typedef struct _SigContext {
  u8 u0[5];
  Registers regs;
} SigContext;

typedef struct _VTable {
  u8    type;      // -24
  char *name;     // -16
  u8    size;      // -8
  void *super;    // 0
} VTable;


typedef struct _ExRecord {
  u8      type;
  void   *catch;
  ExFunc *func;
  struct _ExRecord *next;
} ExRecord;

typedef struct _Exception {
  void   *vtable;
  void   *backtrace;
  void   *message;
} Exception;

typedef struct _Stat {
  long mtime;
} Stat;

ExRecord *__exception_top = 0;
void     *__exception_rsp = 0;

extern int GC_print_stats;
extern int GC_quiet;


VTable *shiftVTable( VTable *p ) {
  long *q;
  VTable *result;
  /*
                   type     type -24
                   name     name -16
                   size     size -8
    e->vtable----->super--->super->...->0
       instance0   method0
       instance1   method1
       instance2
   */

  if( p == 0 ) {
    return 0;
  }

  return (VTable *)(((long *)p)-3);
  /*
  q = (long *)p;

  q -= 3;

  result = (VTable *)q;

  D( "shift %p -> %p/%p\n", p, q, result );

  D( "result %s\n", result->name );

  return result;
  */
}

VTable *getObjectVTable( void *e ) {
  if( e == 0 ) {
    return 0;
  }

  // D( "exception vtable %p\n", e );
  // D( "vtable %p\n", *((long**)e) );

  // D( "head %p\n", -3 + *((long**)e) );

  VTable *p = *(VTable **)e;
  return shiftVTable(p);
}

VTable *getSuperVTable( VTable *v ) {
  if( v == 0 ) {
    return 0;
  }
  VTable *p = v->super;
  return shiftVTable(p);
}

VTable *getCatchVTable( ExRecord *r ) {
  if( r == 0 ) {
    return 0;
  }

  // D( "catch vtable %p\n", r );
  // D( "vtable %p\n", ((long**)(r->catch)) );

  // D( "head %p\n", -3 + ((long**)(r->catch)) );

  VTable *p = r->catch;
  return shiftVTable(p);
}

static int alloc_count = 0;

void *__calloc( long size ) {
  void *result = calloc( 1, size );
  // printf( "zzzzz,%d,%p,__calloc-%ld...\n", alloc_count++, result, size );
  // fflush(stdout);

  return result;
}

void *__mutex_alloc() {
  return __calloc( sizeof(pthread_mutex_t) );
}


void __GC_add_roots( GC_PTR from, GC_PTR to ) {
  GC_add_roots( from, to+1 );
}


void __GC_finalize( GC_PTR obj, GC_PTR p ) {
  if( obj != 0 ) {
    VTable *v = getObjectVTable( (void *)obj );

    // printf( "finalize: %s @ %p\n", v->name, obj );

    /*
    if( v != 0 ) {
      printf( "zzzzz,%d,%p,finalize,%s\n", alloc_count++, obj, v->name );
    } else {
      printf( "zzzzz,%d,%p,finalize,\n", alloc_count++, obj );
    }
    */
    fflush(stdout);
  }
}

void __register_finalizer( void *o ) {
  GC_finalization_proc ofn;
  GC_PTR ocd;

  // GC_REGISTER_FINALIZER( (GC_PTR)o, __GC_finalize, 0, &ofn, &ocd );
}


#define ALLOC_STOP 3000

void *__GC_calloc( long size ) {
  // GC_dump();
  /*
  if( alloc_count > ALLOC_STOP ) {
    return __calloc( size );
  }
  */
  //  GC_quiet = 0;
  // GC_print_stats = 1;

  void *result = GC_MALLOC( size );
  // printf( "zzzzz,%d,%p,gc-alloc-%ld...\n", alloc_count++, result, size );
  fflush(stdout);

  __register_finalizer( result );

  // printf( "result is %p\n", result );
  // fflush(stdout);

  return result;
}


#define M_RBX 0x00004
#define M_R12 0x02000
#define M_R13 0x04000
#define M_R14 0x08000
#define M_R15 0x10000


void unwindFrame( long rbp, int flags, Registers *r ) {
  int offset = 0;

  long *stack = (long *)rbp;

  r->rbp = *stack;
  // D( "unwind rbp = %lx\n", r->rbp );

  if( flags & M_RBX ) {
    // D( "unwind rbx...\n" );
    r->rbx = *--stack;
    // D( "unwind rbx = %lx\n", r->rbx );
  }

  if( flags & M_R12 ) {
    // D( "unwind r12...\n" );
    r->r12 = *--stack;
    // D( "unwind r12 = %lx\n", r->r12 );
  }

  if( flags & M_R13 ) {
    // D( "unwind r13...\n" );
    r->r13 = *--stack;
    // D( "unwind r13 = %lx\n", r->r13 );
  }

  if( flags & M_R14 ) {
    // D( "unwind r14...\n", r->r14 );
    r->r14 = *--stack;
    // D( "unwind r14 = %lx\n", r->r14 );
  }

  if( flags & M_R15 ) {
    // D( "unwind r15...\n", r->r15 );
    r->r15 = *--stack;
    // D( "unwind r15 = %lx\n", r->r15 );
  }
}


int catches( VTable *catch, VTable *e ) {
  if( catch == e ) {
    return 1;
  } else if( e == 0 || catch == 0 ) {
    return 0;
  } else {
    // D( "no good %s versus %s, try super class %p\n", catch->name, e->name, e->super );
    e = getSuperVTable( e );

    return catches( catch, e );
  }
}


void dumpExRecord( ExRecord *r ) {
  if( r->type == CATCH_RETURN ) {
    D( "return record\n" );
  } else if( r->type == CATCH_FINALLY ) {
    D( "finally record\n" );
  } else if( r->type == CATCH_EXCEPTION ) {
    D( "exception record\n" );
    if( r->catch != 0 ) {
      VTable *v = getCatchVTable(r);
      D( "catch class %s\n", v->name );
    }
  } else {
    printf( "unexpected record type %ld\n", r->type );
    exit(1);
  }
}


typedef struct _LineRecord {
  long address;
  long line_number;
} LineRecord;

typedef struct _UnwindRecord {
  long        method_start;
  long        method_end;
  char       *method_name;
  LineRecord *line_numbers;
  long        flags;
} UnwindRecord;

extern UnwindRecord *__unwind_start;


void findLineNumber( LineRecord *line_number, long rip, void *backtrace ) {
  long result = -1;
  while( line_number != 0 && line_number->address != 0 ) {
    if( rip >= line_number->address ) {
      D( "line %ld at %p\n", line_number->line_number, (void *)rip );
      if( backtrace != 0 ) {
	append__Q26System12StringBufferPc( backtrace, ": " );
	append__Q26System12StringBufferi( backtrace, line_number->line_number );
	append__Q26System12StringBufferc( backtrace, '\n' );
      }
      return;
    }
  }
  if( backtrace != 0 ) {
    append__Q26System12StringBufferc( backtrace, '\n' );
  }
  D( "unknown line\n" );
}



UnwindRecord *findUnwindInfo( long rip, void *backtrace ) {
  int result = 0;
  UnwindRecord *p;
  // D( "looking for method containing %p\n", (void *)rip );

  for( p = __unwind_start; p->method_start != 0; p = p + 1 ) {
    // D( "have record %p, %p..%p %s\n", p, (void *)p->method_start, (void *)p->method_end, p->method_name );

    if( rip >= p->method_start && rip < p->method_end ) {
      D( "method %s at %p, unwind flags %lx\n", p->method_name, (void *)rip, p->flags );
      if( backtrace != 0 ) {
	append__Q26System12StringBufferc( backtrace, '\t' );
	append__Q26System12StringBufferPc( backtrace, p->method_name );
      }
      D( "appended\n" );
      findLineNumber( p->line_numbers, rip, backtrace );

      return p;
    }
  }

  // D( "count not find rip\n" );
  return 0;
}

void clearRegisters(Registers *r) {
  memset(r,0,sizeof(Registers));
}

int unwindStack( long rbp, long rip, long stop_at_rip, Registers *regs, void *backtrace ) {
  int found_frame = 0;
  clearRegisters(regs);

  D( "unwind stack..." );

  while( rbp != 0 ) {
    long *p = (long *)rbp;
    UnwindRecord *u = findUnwindInfo( rip, backtrace );

    D( "rbp %p\n", (void *)rbp );
    D( "rip %p\n", (void *)rip );

    if( u == 0 ) {
      if( backtrace != 0 ) {
	append__Q26System12StringBufferPc( backtrace, "\tunknown\n" );
	break;
      }
    } else {
      if( stop_at_rip == u->method_start ) {
	// D( "stop unwinding here\n" );
	if( backtrace != 0 ) {
	  append__Q26System12StringBufferPc( backtrace, "(handled)\n" );
	}
	found_frame = 1;
      }

      if( !found_frame ) {
	unwindFrame( rbp, u->flags, regs );
      }
    }

    if( p[0] != 0 ) {
      rip = p[1];
    }

    rbp = p[0];
  }

  D( "unwound %d\n", found_frame );

  return found_frame;
}


ExRecord *nextExRecord( ExRecord *r ) {
  if( r->next != 0 ) {
    return r->next;
  } else if( r->type == CATCH_EXCEPTION ) {
    return r + 1;
  }
}


ExRecord *findMethodHandler( ExRecord *r ) {
  while( r != 0 ) {
    D( "search outer exception handler %p\n", r );
    if( r->type == CATCH_RETURN ) {
      D( "found %p\n", r );
      return r;
    }

    D( "next...\n" );
    r = nextExRecord( r );
  }

  D( "no outer handler found" );
  return 0;
}

extern __catch_exception( long type, void *e, void *rip, Registers * );

extern u8 size$__Q26System12StringBuffer;
extern u8 vtable$__Q26System12StringBuffer[];

extern char *toCString__Q26System12StringBuffer( void *lstring );

void __flush_stdout() {
  fflush(stdout);
}

void catchException( long type, void *e, ExRecord *r, long rbp, long rip ) {
  // if( r != 0 ) {
    void *backtrace = 0;

    if( type == THROW_EXCEPTION ) {
      backtrace = malloc( size$__Q26System12StringBuffer );
      *(u8 **)backtrace = vtable$__Q26System12StringBuffer;
      init__Q26System12StringBuffer( backtrace );
      setBackTrace__Q26System9ExceptionQ26System6String( e, backtrace );
    }

    Registers regs;
    
    // D( "need to unwind to method containing address %p\n", r->catch );

    ExRecord *m = 0;
    long catch_address = 0;
    
    if( r != 0 ) {
      m = findMethodHandler( r );
      if( m == 0 ) {
	D( "could not find method containing exception handler\n" );
	exit( 1 );
      } else {
	catch_address = (long)m->catch;
      }
    } else {
      D( "build backrace only\n" );
    }

    D( "about to unwind stack\n" );

    if( unwindStack( rbp, rip, catch_address, &regs, backtrace ) && r != 0 ) {
      D( "about to catch %lx, %p, %p...\n", type, e, r->func );
      __catch_exception( type, e, r->func, &regs );
    } else {
      D( "get backtrace string from %p\n", backtrace );

      char *s = (char *)toCString__Q26System12StringBuffer( backtrace );
    // }
      D( "failed to catch %p\n", e );
      D( "%s\n", s );
    }
  exit(1);
}

void tryCatch( long type, void *e, ExRecord *r, long rbp, long rip ) { 
  // D( "catch type %ld\n", type );
  /*  
  if( r != 0 ) {
    dumpExRecord( r );
  }
  */

  VTable *w = getCatchVTable( r );

  if( type == THROW_RETURN ) {
    D( "try to catch a return %p\n", e );

    if( r->type == CATCH_RETURN ) {
      D( "return record %p catches return %p\n", r, e );
      catchException( type, e, r, rbp, rip );
      exit(1);
    } else if( r->type == CATCH_FINALLY ) {
      D( "finally record %p executes and passes return %p\n", r, e );
      catchException( type, e, r, rbp, rip );
    } else if( r->type == CATCH_EXCEPTION ) {
      D( "exception record %p (%s) ignores return %p\n", r, w->name, e );
    } else {
      printf( "unexpected record type %ld\n", r->type );
      exit(1);
    }
  } else if( type == THROW_EXCEPTION ) {
    VTable *v = 0;
    D( "try to catch an exception %p\n", e );
    if( e != 0 ) {
      v = getObjectVTable(e);      
      D( "exception is %s\n", v->name );
    }
    if( r->type == CATCH_RETURN ) {
      D( "return record %p executes and passes exception %p\n", r, e );
      catchException( type, e, r, rbp, rip );
      exit(1);
    } else if( r->type == CATCH_FINALLY ) {
      D( "finally record %p executes and passes execption %p\n", r, e );
      catchException( type, e, r, rbp, rip );
      exit(1);
    } else if( r->type == CATCH_EXCEPTION ) {
      D( "catch record %p (%s) may catch exception %p\n", r, w->name, e );
      if( catches( w, v ) ) {
	D( "found matching catch: should return to %p\n", (void *)r->func );
	catchException( type, e, r, rbp, rip );
	exit(1);
      }
    } else {
      printf( "unexpected record type %ld", r->type );
      exit(1);
    }
  } else if( type == THROW_FINALLY ) {
    D( "try to catch a finally %p\n", e );

    if( r->type == CATCH_RETURN ) {
      D( "return record %p catches finally\n", r );
      catchException( THROW_STOP, 0, r, rbp, rip );
    } else if( r->type == CATCH_FINALLY ) {
      D( "finally record %p executes and swallows finally\n", r );
      catchException( THROW_STOP, 0, r, rbp, rip );
    } else if( r->type == CATCH_EXCEPTION ) {
      D( "catch record %p (%s) ignores finally\n", r, w->name );
    } else {
      printf( "unexpected record type %ld", r->type );
      exit(1);
    }
  } else if( type == THROW_STOP ) {
    printf( "try to catch a stop %p\n", e );

    exit(1);
  } else {
    printf( "unexpected catch type %ld\n", type );
  }
}

void findCatch( long type, void *e, ExRecord *r, long rbp, long rip ) {
  ExRecord *t = r;

  if( r != 0 ) {
    D( "have exception chain pointer %p\n", r );

    while( r != 0 ) {
      tryCatch( type, e, r, rbp, rip );
      r = nextExRecord(r);
    }       
  }

  D( "could not catch %p\n", e );
}



void __throw( long type, void *e, long rbp, long rip ) {
  ExRecord *top = __exception_top;

  // fprintf( stderr, "__throw(%ld,%p)...\n", type, e );

  findCatch( type, e, top, rbp, rip );

  // force backtrace display:
  catchException( type, e, 0, rbp, rip );

  exit( 1 );
}

/*
void __throw_return( void *e, long rbp, long rip ) {
  __throw( CATCH_RETURN, e, rbp, rip );
}
*/

/*
void __throw_exception( void *e, long rbp ) {
  __throw( CATCH_EXCEPTION, e, rbp );
}
*/

/*
void __throw_endcatch( long rbp, long rip ) {
  // exception succesfully caught. throw a new exception that will be caught only by the associated finally block.
  __throw( CATCH_FINALLY, 0, rbp, rip );
}
*/

/*
void __throw_endfinally( long type, void *e, long rbp, long rip ) {
  // fell through the end of a finally block. If this exception was not caught (type is not CATCH_FINALLY) we'll need to rethrow it now:
  if( type == CATCH_FINALLY ) {
    return;
  } else {
    D( "rethrow after finally %ld %p\n", type, e );
    __throw( type, e, rbp, rip );
  }
}
*/

/*
void __segv_handler( int signal, long *context0, long *context1 ) {
  int i;
  D( "signal %d\n", signal );
  D( "context0 %d\n", context0 );
  D( "context1 %d\n", context1 );

  if( context0 > 65536 ) { 
    for( i = 0; i < 32; i++ ) {
      D( "context0[%d] = %lx\n", context0[i] );
    }
  }

  if( context1 > 65536 ) {
    for( i = 0; i < 32; i++ ) {
      D( "context1[%d] = %lx\n", context1[i] );
    }
  }
}
*/

extern u8 size$__Q26System9Exception;
extern u8 size$__Q26System20NullPointerException;
extern u8 vtable$__Q26System20NullPointerException[];

extern u8 size$__Q26System13CastException;
extern u8 vtable$__Q26System13CastException[];

extern u8 size$__Q26System20ArrayBoundsException;
extern u8 vtable$__Q26System20ArrayBoundsException[];

/*

Exception *makeNullPointerException() {
  Exception *result = (Exception *)malloc(size$__Q26System20NullPointerException);
  result->vtable = vtable$__Q26System20NullPointerException;

  init__Q26System20NullPointerExceptionPc(result,"null pointer");

  return result;
}
*/

Exception *__make_castexception() {
  Exception *result = (Exception *)malloc(size$__Q26System13CastException);
  result->vtable = vtable$__Q26System13CastException;

  init__Q26System15MemoryExceptionPc(result,"cast");

  return result;
}

Exception *__make_arrayboundsexception() {
  Exception *result = (Exception *)malloc(size$__Q26System20ArrayBoundsException);
  result->vtable = vtable$__Q26System20ArrayBoundsException;

  init__Q26System15MemoryExceptionPc(result,"array bounds");

  return result;
}

void __segv_handler(int sig, siginfo_t *si, SigContext *uc) {
  int i;
  D("Got SIGSEGV at address: 0x%lx\n", (long) si->si_addr);
   
  D( "rax: %lx\n", uc->regs.rax );
  D( "rbx: %lx\n", uc->regs.rbx );
  D( "rcx: %lx\n", uc->regs.rcx );
  D( "rdx: %lx\n", uc->regs.rdx );
  D( "rsi: %lx\n", uc->regs.rsi );
  D( "rdi: %lx\n", uc->regs.rdi );
  D( "rbp: %lx\n", uc->regs.rbp );
  D( "rsp: %lx\n", uc->regs.rsp );
  D( "r8:  %lx\n", uc->regs.r8 );
  D( "r9:  %lx\n", uc->regs.r9 );
  D( "r10: %lx\n", uc->regs.r10 );
  D( "r11: %lx\n", uc->regs.r11 );
  D( "r12: %lx\n", uc->regs.r12 );
  D( "r13: %lx\n", uc->regs.r13 );
  D( "r14: %lx\n", uc->regs.r14 );
  D( "r15: %lx\n", uc->regs.r15 );
  
  // Exception *e = makeException();

  exit(1);
}


#define SIGNAL_STACK_SIZE 65536
void __install_segv_handler() {
  stack_t ss;
  struct sigaction sa;

  ss.ss_sp = malloc(SIGNAL_STACK_SIZE);
  if( ss.ss_sp == 0 ) {
    D( "failed to allocate signal stack" );
    exit(1);
  }

  ss.ss_size = SIGNAL_STACK_SIZE;
  ss.ss_flags = 0;
  /*
  if( signalstack( &ss, 0 ) < 0 ) {
    D( "failed to set signal stack" );
    exit(1);
  }
  */

  sa.sa_flags = SA_SIGINFO | SA_ONSTACK;
  sigemptyset(&sa.sa_mask);
  sa.sa_sigaction = __segv_handler;
  if( sigaction(SIGSEGV, &sa, NULL) < 0 ) {
    D( "failed to set SEGV signal handler" );
  }
}


void __throw_continue() {
  D( "throw continue\n" );
  exit(1);
}

int __stat_file( char *name, Stat *ls ) {
  struct stat us;

  int result = stat( name, &us );
  if( !result ) {
    // printf( "__stat(%s) -> %ld\n", name, us.st_mtime );
    ls->mtime = us.st_mtime;
  }

  return result;
}
