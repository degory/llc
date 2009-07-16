
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
#include <time.h>
#include <unistd.h>
#include <errno.h>

#include <gc/gc.h>

typedef void ExFunc(int type, void *ex);

#define CATCH_RETURN 0
#define CATCH_FINALLY 1
#define CATCH_EXCEPTION 2

#define THROW_RETURN 3 
#define THROW_EXCEPTION 4
#define THROW_FINALLY 5
#define THROW_STOP 6


// #define D(e...) { printf(e); fflush(stdout); }
#define D(e...)


#ifdef B32 /* 32 bit */

typedef unsigned long WORD;

typedef struct _Registers {
  WORD rdi;    // +0
  WORD rsi;    // +4
  WORD rbp;    // +8
  WORD rbx;    // +12
  WORD rdx;    // +16
  WORD rax;    // +20
  WORD rcx;    // +24
  WORD rsp;    // +28
  WORD rflags; // +32
  WORD trap_no; // + 36 
  WORD err;    // +40
  WORD rip;    // +44
} Registers;

typedef struct _SigContext {
  WORD u0[5];
  Registers regs;
} SigContext;


#endif

#ifdef B64

typedef unsigned long WORD;

typedef struct _Registers {
  WORD r8;     // +0
  WORD r9;     // +8
  WORD r10;    // +16
  WORD r11;    // +24
  WORD r12;    // +32
  WORD r13;    // +40
  WORD r14;    // +48
  WORD r15;    // +56
  WORD rdi;    // +64
  WORD rsi;    // +72
  WORD rbp;    // +80
  WORD rbx;    // +88
  WORD rdx;    // +96
  WORD rax;    // +104
  WORD rcx;    // +112
  WORD rsp;    // +120
  WORD rip;    // +128
  WORD rflags; // +136
} Registers;


typedef struct _SigContext {
  WORD u0[5];
  Registers regs;
} SigContext;

#endif



typedef struct _VTable {
  WORD    type;      // -12
  char *name;        // -8
  WORD    size;      // -4
  void *super;       // 0
} VTable;


typedef struct _ExRecord {
  WORD      type;
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
  int mtime;
  int size;
} Stat;

__thread ExRecord *__exception_top = 0;
__thread void     *__exception_rsp = 0;

extern int GC_print_stats;
extern int GC_quiet;


int __sql_callback(void *NotUsed, int argc, char **argv, char **azColName){
  int i;
  for(i=0; i<argc; i++){
    printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
  }
  printf("\n");
  return 0;
}

void *__get_sql_callback() {
  return __sql_callback;
}



VTable *shiftVTable( VTable *p ) {
  WORD *q;
  VTable *result;
  /*
                   type     type -12
                   name     name -8
                   size     size -4
    e->vtable----->super--->super->...->0
       instance0   method0
       instance1   method1
       instance2
   */

  if( p == 0 ) {
    return 0;
  }

  return (VTable *)(((WORD *)p)-3);
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

void *__calloc( WORD size ) {
  void *result = calloc( 1, size );
  // printf( "zzzzz,%d,%p,__calloc-%ld...\n", alloc_count++, result, size );
  // fflush(stdout);

  return result;
}

void *__mutex_alloc() {
  return __calloc( sizeof(pthread_mutex_t) );
}

void *__cond_alloc() {
  return __calloc( sizeof(pthread_cond_t) );
}

int __get_time() {
  struct timeval t;

  gettimeofday( &t, 0 );

  return (int)t.tv_sec;
}

#if B32
// C calling convention:
extern __catch_exception( WORD type, void *e, void *rip, Registers *regs );

// L calling convention on 32 bit x86 is fastcall - first two parameters in ecx and edx and callee pops arguments from stack:
extern __attribute__((fastcall)) void __set_pthread_id__Q26System6Threadl( void *thread, WORD id );
extern __attribute__((fastcall)) void *__thread_entry__Q26System6Thread( void *thread );
extern __attribute__((fastcall)) char *toCString__Q26System12StringBuffer( void *lstring );
extern __attribute__((fastcall)) void *getBacktraceInfo__Q26System9Exception( void *e );
extern __attribute__((fastcall)) void *append__Q26System12StringBufferPc( void *buffer, char *s );
extern __attribute__((fastcall)) void *append__Q26System12StringBufferi( void *buffer, int i );
extern __attribute__((fastcall)) void *append__Q26System12StringBufferc( void *buffer, char c );
extern __attribute__((fastcall)) void setBacktraceInfo__Q26System9Exceptionl( void *exception, WORD info );

extern __attribute__((fastcall)) void init__Q26System15MemoryExceptionPc( void *e, char *m );
extern __attribute__((fastcall)) void init__Q26System25MemoryProtectionExceptionPc( void *e, char *m );
extern __attribute__((fastcall)) void init__Q26System20NullPointerExceptionPc( void *e, char *m );

#else
extern __catch_exception( WORD type, void *e, void *rip, Registers *regs );

extern void __set_pthread_id__Q26System6Threadl( void *thread, WORD id );
extern void *__thread_entry__Q26System6Thread( void *thread );
extern char *toCString__Q26System12StringBuffer( void *lstring );
extern void *getBacktraceInfo__Q26System9Exception( void *e );
extern void *append__Q26System12StringBufferPc( void *buffer, char *s );
extern void *append__Q26System12StringBufferi( void *buffer, int i );
extern void *append__Q26System12StringBufferc( void *buffer, char c );
extern void setBacktraceInfo__Q26System9Exceptionl( void *exception, WORD info );

extern void init__Q26System15MemoryExceptionPc( void *e, char *m );
extern void init__Q26System25MemoryProtectionExceptionPc( void *e, char *m );
extern void init__Q26System20NullPointerExceptionPc( void *e, char *m );
#endif

extern __throw_memoryexception();

#define STACK_SIZE (1024*1024*2)

void *__thread_entry( void *thread_object ) {
  __exception_top = 0;
  __exception_rsp = 0;

  __thread_entry__Q26System6Thread( thread_object );
  return 0;
}

int __mutex_lock_timed( pthread_mutex_t *mutex, int seconds ) {
  struct timespec ts;
  struct timeval tv;

  int result = 0;
  if( seconds >= 0 ) {
    gettimeofday( &tv, 0 );
    ts.tv_nsec = tv.tv_usec * 1000;
    ts.tv_sec = tv.tv_sec + seconds;

    result = pthread_mutex_timedlock( mutex, &tv );
  } else {
    result = pthread_mutex_lock( mutex );
  }

  if( result != 0 ) {
    printf( "mutex lock failed %d\n", result );
    return 0;
    fflush( stdout );
  } else {
    return 1;
  }
}

int __mutex_lock(  pthread_mutex_t *mutex ) {
  __mutex_lock_timed( mutex, -1 );
}

int __cond_wait_timed( pthread_cond_t *cond, pthread_mutex_t *mutex, int seconds ) {
  struct timespec ts;
  struct timeval tv;

  int result = 0;
  if( seconds >= 0 ) {
    gettimeofday( &tv, 0 );
    ts.tv_nsec = tv.tv_usec * 1000;
    ts.tv_sec = tv.tv_sec + seconds;

    result = pthread_cond_timedwait( cond, mutex, &ts );
  } else {
    result = pthread_cond_wait( cond, mutex );
  }

  if( result != 0 ) {
    printf( "cond wait failed %d\n", result );
    return 0;
    fflush( stdout );
  } else {
    return 1;
  }
}

int __cond_wait( pthread_cond_t *cond, pthread_mutex_t *mutex ) {
  __cond_wait_timed( cond, mutex, -1 );
}

void __thread_start( void *thread_object ) {
  pthread_t thread;
  pthread_attr_t attr;
  // void *stack = GC_malloc( STACK_SIZE );

  void *stack;
  pthread_attr_init( &attr );

  // posix_memalign( &stack, (size_t)4096, (size_t)STACK_SIZE);


  // pthread_attr_setstackaddr( &attr, stack );
  // pthread_attr_setstacksize( &attr, STACK_SIZE );
  
  pthread_attr_setstacksize( &attr, (size_t)STACK_SIZE );

  // printf( "creating thread...\n" );
  int result = GC_pthread_create( &thread, &attr, __thread_entry, thread_object );
  __set_pthread_id__Q26System6Threadl( thread_object, thread );
  // printf( "result is %d, thread is %p\n", result, (void *)thread );

  // GC_pthread_detach( thread );
  /*
  stack = 
  GC_add_roots( stack, stack+STACK_SIZE );
  */
}


void __GC_add_roots( GC_PTR from, GC_PTR to ) {
  GC_add_roots( from, to+1 );
}


/*
void __GC_finalize( GC_PTR obj, GC_PTR p ) {
  if( obj != 0 ) {
    VTable *v = getObjectVTable( (void *)obj );

    // printf( "finalize: %s @ %p\n", v->name, obj );

    fflush(stdout);
  }
}
*/


void *__alloc_object( WORD size, WORD *vtable ) {
  WORD *result = GC_MALLOC_IGNORE_OFF_PAGE( size );
  result[0] = (WORD)vtable;
  return result;
}


// dispose() is first method after vtable parent pointer:
#define FINALIZE_OFFSET 1

#if B32 

typedef void __attribute__((fastcall)) DISPOSE(WORD*);

// thunk for GC to call System.Object.dispose() with fastcall
// calling convention:
void __call_dispose( WORD *object ) {
  WORD *vtable = (WORD *)object[0];
  DISPOSE *dispose = (DISPOSE *)vtable[FINALIZE_OFFSET];

  // fprintf( stderr, "calling dipose on %lp\n", object );
  (*dispose)(object);
}


#endif

// allocate an object and register it's dispose method with the garbage collector
// as a finalizer:
void *__alloc_object_finalize( WORD size, GC_finalization_proc *vtable ) {
  GC_finalization_proc ofn;
  GC_PTR ocd;

  WORD *result = GC_MALLOC_IGNORE_OFF_PAGE( size );
  result[0] = (WORD)vtable;

#if B32
  // wrong calling convention means GC can't call the finalizer directly - need to
  // provide a thunk:
  GC_REGISTER_FINALIZER( (GC_PTR)result, (GC_finalization_proc)__call_dispose, 0, &ofn, &ocd );

#else
  GC_REGISTER_FINALIZER( (GC_PTR)result, vtable[FINALIZE_OFFSET], 0, &ofn, &ocd );
#endif
  return result;
}




#define M_RBX 0x00004
#define M_ESI 0x00020
#define M_EDI 0x00040
#define M_EBP 0x00080
#define M_R12 0x02000
#define M_R13 0x04000
#define M_R14 0x08000
#define M_R15 0x10000


void unwindFrame( WORD rbp, int flags, Registers *r ) {
  int offset = 0;

  WORD *stack = (WORD *)rbp;

  // if( flags & M_EBP ) {
    r->rbp = *stack;
    D( "unwind rbp = %lx\n", r->rbp );
    // } else {
    // D( "no saved rbp - now what?\n" );
    // }

  if( flags & M_RBX ) {
    D( "unwind rbx...\n" );
    r->rbx = *--stack;
    D( "unwind rbx = %lx\n", r->rbx );
  }

#if B32
  if( flags & M_ESI ) {
    D( "unwind esi...\n" );
    r->rsi = *--stack;
    D( "unwind esi = %lx\n", r->rsi );
  }

  if( flags & M_EDI ) {
    D( "unwind edi...\n" );
    r->rdi = *--stack;
    D( "unwind edi = %lx\n", r->rdi );
  }
#endif

#if B64
  if( flags & M_R12 ) {
    D( "unwind r12...\n" );
    r->r12 = *--stack;
    D( "unwind r12 = %lx\n", r->r12 );
  }

  if( flags & M_R13 ) {
    D( "unwind r13...\n" );
    r->r13 = *--stack;
    D( "unwind r13 = %lx\n", r->r13 );
  }

  if( flags & M_R14 ) {
    D( "unwind r14...\n", r->r14 );
    r->r14 = *--stack;
    D( "unwind r14 = %lx\n", r->r14 );
  }

  if( flags & M_R15 ) {
    D( "unwind r15...\n", r->r15 );
    r->r15 = *--stack;
    D( "unwind r15 = %lx\n", r->r15 );
  }
#endif
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
  WORD address;
  WORD line_number;
} LineRecord;

typedef struct _UnwindRecord {
  WORD        method_start;
  WORD        method_end;
  char       *method_name;
  LineRecord *line_numbers;
  WORD        flags;
  WORD        ro_size;
} UnwindRecord;

extern UnwindRecord *__unwind_start;

typedef struct _UnwindList {
  UnwindRecord *head;
  struct _UnwindList *tail;
} UnwindList;

static UnwindList *unwind_head = 0;

typedef struct _BacktraceRecord {
  WORD rip;
  char *method_name;
  LineRecord *line_number_info;
} BacktraceRecord;

void findLineNumber( void *buffer, BacktraceRecord *backtrace ) {
  D("find line number %p, %p", buffer, backtrace );

  if( backtrace == 0 ) {
    D("no backtrace required\n");
    return;
  }

  append__Q26System12StringBufferc( buffer, '\t' );
  if( backtrace->method_name != 0 ) {
    append__Q26System12StringBufferPc( buffer, backtrace->method_name );
  } else {
    append__Q26System12StringBufferPc( buffer, "unknown\n" );
    return;
  }

  LineRecord *line_number = backtrace->line_number_info;
  WORD rip = backtrace->rip;

  if( line_number == 0 ) {
    D("no line number information available\n");
    // append__Q26System12StringBufferPc( buffer, ": unknown line\n" );
    append__Q26System12StringBufferc( buffer, '\n' );
    return;
  }

  WORD previous_line = -1;
  WORD previous_rip = -1;
  while( line_number->address != 0 ) {
    D("current address %lx\n", line_number->address );

    if( rip > previous_rip && rip <= line_number->address ) {
      D( "code at %p is between %ld and %ld\n", (void *)rip, previous_line, line_number->line_number );
      break;
    }

    previous_rip = line_number->address;
    previous_line = line_number->line_number;
    D("next line...\n");
    line_number++;
  }

  if( previous_line != -1 ) {
    D( "appending line to backtrace\n" );
    append__Q26System12StringBufferPc( buffer, ": " );
    append__Q26System12StringBufferi( buffer, previous_line );
    append__Q26System12StringBufferc( buffer, '\n' );
  } else {

    append__Q26System12StringBufferPc( buffer, ": outside method\n" );
  }
}


void __find_line_numbers( void *buffer, BacktraceRecord *backtrace ) {
  if( backtrace == 0 ) {
    return;
  }

  while( backtrace->rip ) {
    findLineNumber( buffer, backtrace++ );
  }
}

void __add_unwind_info( UnwindRecord **u ) {
  UnwindList *list;

  printf( "adding unwind info %p\n", u );

  list = (UnwindList *)GC_malloc( sizeof(UnwindList) );

  list->head = *u;
  list->tail = unwind_head;

  unwind_head = list;
}

UnwindRecord *findUnwindInfo( WORD rip, BacktraceRecord *backtrace ) {
  int result = 0;
  UnwindRecord *p;
  D( "looking for method containing %p\n", (void *)rip );

  UnwindRecord *start = __unwind_start;
  UnwindList *next = unwind_head;

  do {
    for( p = start; p->method_start != 0; p = p + 1 ) {
      // D( "have record %p, %p..%p %s\n", p, (void *)p->method_start, (void *)p->method_end, p->method_name );

      if( rip >= p->method_start && rip < p->method_end ) {
	D( "method %s at %p, unwind flags %lx\n", p->method_name, (void *)rip, p->flags );
	if( backtrace != 0 ) {
	  backtrace->rip = rip;
	  backtrace->method_name = p->method_name;
	  backtrace->line_number_info = p->line_numbers;
	}
	return p;
      }
    }

    if( next != 0 ) {
      start = next->head;
      next = next->tail;
    } else {
      start = 0;
    }
  } while( start != 0 );

  // D( "count not find rip\n" );
  return 0;
}

void clearRegisters(Registers *r) {
  memset(r,0,sizeof(Registers));
}

int unwindStack( WORD rbp, WORD rip, WORD stop_at_rip, Registers *regs, BacktraceRecord *backtrace, int backtrace_length ) {
  int found_frame = 0;
  clearRegisters(regs);

  D( "unwind stack..." );

  int frame = 0;

  while( rbp != 0 ) {
    WORD *p = (WORD *)rbp;
    BacktraceRecord *br = 0;
    if( backtrace != 0 && frame < backtrace_length ) {
      br = backtrace + frame;
    }

    UnwindRecord *u = findUnwindInfo( rip, br );

    D( "rbp %p\n", (void *)rbp );
    D( "rip %p\n", (void *)rip );

    if( u == 0 ) {
      if( br != 0 ) {
	br->method_name = "unknown";
      }

      if( found_frame ) {
	break;
      } else {
	fprintf( stderr, "cannot unwind through non-L code" );
	exit(1);
      }

      // break; ??
    } else {
      if( stop_at_rip == u->method_start ) {
	D( "stop unwinding here but continue filling backtrace...\n" );
	/*
	if( backtrace != 0 ) {
	  append__Q26System12StringBufferPc( backtrace, "(handled)\n" );
	}
	*/
	found_frame = 1;
      }

      if( !found_frame ) {
	D( "unwind saved registers from this frame...\n" );
	unwindFrame( rbp, u->flags, regs );
      }
    }

    if( p[0] != 0 ) {
      rip = p[1];
      D( "previous rip %p\n", (void *)rip );
    }

    rbp = p[0];
    D( "previous rbp %p\n", (void *)rbp );
    frame++;
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



extern WORD size$__Q26System12StringBuffer;
extern WORD vtable$__Q26System12StringBuffer[];


void __flush_stdout() {
  fflush(stdout);
}

#define BACKTRACE_LENGTH 32

void catchException( WORD type, void *e, ExRecord *r, WORD rbp, WORD rip, Registers *regs ) {
  // if( r != 0 ) {
  BacktraceRecord *backtrace = 0;

  D( "catch exception %ld, %p\n", type, e );
  
  if( type == THROW_EXCEPTION ) {
    if( getBacktraceInfo__Q26System9Exception(e) == 0 ) {
        backtrace = (BacktraceRecord*)GC_malloc_atomic( sizeof(BacktraceRecord)*BACKTRACE_LENGTH );
	setBacktraceInfo__Q26System9Exceptionl( e, (WORD)backtrace );
      }
  } else {
    fprintf( stderr, "runtime does not expect to see exception of type %ld\n", type );
    fflush( stderr );
    exit(1);
  }
  
  Registers initial_regs;

  if( regs == 0 ) {
    regs = &initial_regs;
  }
  
  D( "need to unwind to method containing address %p\n", r->catch );
  
  ExRecord *m = 0;
  WORD catch_address = 0;
  
  if( r != 0 ) {
    // fixme - is this needed if the handler label is within the method
    // since unwindStack should find it anyway?
    m = findMethodHandler( r );
    if( m == 0 ) {
      fprintf( stderr, "could not find method containing exception handler\n" );
      fflush( stderr );
      exit( 1 );
    } else {
      catch_address = (WORD)m->catch;
    }
  } else {
    D( "build backrace only\n" );
  }
  
  D( "about to unwind stack\n" );
  
  if( unwindStack( rbp, rip, catch_address, regs, backtrace, BACKTRACE_LENGTH-1 ) && r != 0 ) {
    D( "about to catch %lx, %p, %p, %p...\n", type, e, r->func, regs );
    __catch_exception( type, e, r->func, regs );
  } else {
    D( "get backtrace string from %p\n", backtrace );
    
    char *s = (char *)toCString__Q26System12StringBuffer( backtrace );
    // }
    D( "failed to catch %p\n", e );
    D( "%s\n", s );
  }
  exit(1);
}


void __throw( WORD type, void *e, WORD rbp, WORD rip ) {
  ExRecord *top = __exception_top;

  D( "__throw(%ld,%p)...\n", type, e );
  D( "top is %p\n", top );
  D( "sizeof UnwindRecord is %p", (void *)sizeof(UnwindRecord) );

  if( top != 0 ) {
    catchException( type, e, top, rbp, rip, 0 );
  } else {
    fprintf( stderr, "unhandled exception\n" );
  }

  exit( 1 );
}



/*
void __throw_with_regs( WORD type, void *e, Registers *regs ) {
  ExRecord *top = __exception_top;

  // fprintf( stderr, "__throw(%ld,%p)...\n", type, e );
  // fprintf( stderr, "top is %p\n", top );

  WORD frame[2] = { regs->rbp, regs->rip };

  if( top != 0 ) {
    catchException( type, e, top, (WORD)&frame, (WORD)__throw_memoryexception, regs );
  } else {
    fprintf( stderr, "unhandled exception\n" );
  }

  exit( 1 );
}
*/
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

extern WORD size$__Q26System9Exception;

extern WORD size$__Q26System20NullPointerException;
extern WORD vtable$__Q26System20NullPointerException[];

extern WORD size$__Q26System13CastException;
extern WORD vtable$__Q26System13CastException[];

extern WORD size$__Q26System20ArrayBoundsException;
extern WORD vtable$__Q26System20ArrayBoundsException[];

extern WORD size$__Q26System25MemoryProtectionException;
extern WORD vtable$__Q26System25MemoryProtectionException[];

/*

Exception *makeNullPointerException() {
  Exception *result = (Exception *)malloc(size$__Q26System20NullPointerException);
  result->vtable = vtable$__Q26System20NullPointerException;

  init__Q26System20NullPointerExceptionPc(result,"null pointer");

  return result;
}
*/


Exception *__make_castexception() {
  Exception *result = (Exception *)GC_MALLOC(size$__Q26System13CastException);
  result->vtable = vtable$__Q26System13CastException;

  init__Q26System15MemoryExceptionPc(result,"illegal cast");

  return result;
}

Exception *__make_arrayboundsexception() {
  Exception *result = (Exception *)GC_MALLOC(size$__Q26System20ArrayBoundsException);
  result->vtable = vtable$__Q26System20ArrayBoundsException;

  init__Q26System15MemoryExceptionPc(result,"array bounds");

  return result;
}

Exception *__make_memoryprotectionexception() {
  Exception *result = (Exception *)calloc(1,size$__Q26System25MemoryProtectionException);
  result->vtable = vtable$__Q26System25MemoryProtectionException;

  init__Q26System25MemoryProtectionExceptionPc(result,"memory protection");

  return result;
}


Exception *__make_nullpointerexception() {
  // Exception *result = (Exception *)malloc(size$__Q26System20NullPointerException);
  Exception *result = (Exception *)calloc(1,size$__Q26System20NullPointerException);
  result->vtable = vtable$__Q26System20NullPointerException;
  
  init__Q26System20NullPointerExceptionPc(result,"null pointer");

  return result;
}



void __segv_handler(int sig, siginfo_t *si, SigContext *uc) {
  // GC_disable();
  int i;
  D("caught SIGSEGV referencing address: 0x%lx\n", (long) si->si_addr); 

  fprintf( stderr, "Content-type: text/plain\r\n\r\n" );
  fprintf( stderr, "SIGSEGV referencing address: 0x%p\n", (void *)si->si_addr );

  Exception *e;

  int address = (WORD)si->si_addr;
  if( address > -8192 && address < 8192 ) {
    e = __make_nullpointerexception();
  } else {
    e = __make_memoryprotectionexception();
  }

  D( "e:   %p\n", e );

  D( "rax: %lx\n", uc->regs.rax );
  D( "rbx: %lx\n", uc->regs.rbx );
  D( "rcx: %lx\n", uc->regs.rcx );
  D( "rdx: %lx\n", uc->regs.rdx );
  D( "rsi: %lx\n", uc->regs.rsi );
  D( "rdi: %lx\n", uc->regs.rdi );
  D( "rbp: %lx\n", uc->regs.rbp );
  D( "rsp: %lx\n", uc->regs.rsp );
#if B64
  D( "r8:  %lx\n", uc->regs.r8 );
  D( "r9:  %lx\n", uc->regs.r9 );
  D( "r10: %lx\n", uc->regs.r10 );
  D( "r11: %lx\n", uc->regs.r11 );
  D( "r12: %lx\n", uc->regs.r12 );
  D( "r13: %lx\n", uc->regs.r13 );
  D( "r14: %lx\n", uc->regs.r14 );
  D( "r15: %lx\n", uc->regs.r15 );
  D( "rip: %lx\n", uc->regs.rip );
#endif

  // void *p = malloc( sizeof(Registers) );
  // memcpy( p, &uc->regs, sizeof(Registers) );

#if B32
  uc->regs.rdx = (WORD)uc->regs.rip;            // faulting address
  uc->regs.rcx = (WORD)e;                       // exception to throw;
#endif

#if B64
  uc->regs.rdi = (WORD)uc->regs.rip;            // faulting address
  uc->regs.rsi = (WORD)e;                       // exception to throw;
#endif
  uc->regs.rip = (WORD)__throw_memoryexception; // restart address
  /*
  __throw_memoryexception( e, &uc->regs );
  //  __throw_with_regs( THROW_EXCEPTION, e, &uc->regs );

  exit(1);
  */
}


#define SIGNAL_STACK_SIZE 65536
void __install_segv_handler() {
  D(printf( "install segv handler\n" ));
  // stack_t ss;
  struct sigaction sa;

  /*
  ss.ss_sp = malloc(SIGNAL_STACK_SIZE);
  if( ss.ss_sp == 0 ) {
    D( "failed to allocate signal stack" );
    exit(1);
  }

  ss.ss_size = SIGNAL_STACK_SIZE;
  ss.ss_flags = 0;


  if( signalstack( &ss, 0 ) < 0 ) {
    D( "failed to set signal stack" );
    // exit(1);
  }
  */

  sa.sa_flags = SA_SIGINFO | SA_NODEFER; // | SA_ONSTACK;
  sigemptyset(&sa.sa_mask);
  sa.sa_sigaction = __segv_handler;
  if( sigaction(SIGSEGV, &sa, NULL) < 0 ) {
    D( "failed to set SEGV signal handler" );
  }
}

void __start_thread( void *thread ) {

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
    //    ls->size = us.st_size;
  }

  return result;
}

extern char **environ;

void __set_environ( char **env ) {
  char **p;
  /*
  for( p = env; p != 0; p++ ) {
    fprintf( stderr, "env: %s\n", *p );
  }
  */

  environ = env;
}

void *__get_stderr() {
  return stderr;
}

void *__get_unwind_start() {
  return __unwind_start;
}

long __get_nanotime() {
  struct timespec t;
  if( clock_gettime( CLOCK_PROCESS_CPUTIME_ID, &t ) ) {
    // printf( "clock gettime failed %s\n", strerror(errno) );
    return 0;
  } else {
    // printf( "clock gettime success: %ld %ld\n", t.tv_sec, t.tv_nsec );
    long result = t.tv_sec * 1000000000 + t.tv_nsec;
    // printf( "result is %ld\n", result );

    return result;
  }

}

void __static_begin( void (*f)() ) {
  f();
}
