
#define POSIX_SOURCE 1

#include <sys/types.h>
#include <sys/stat.h>
// #include <sigcontext.h>
#define __USE_GNU 1
#include <ucontext.h>
#undef __USE_GNU

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>
#include <time.h>
#include <unistd.h>
#include <errno.h>


// #define DEBUG 1
// #define GC_DEBUG 0
// #define TRACE_ALLOC 1

#define GC_THREADS 1
#include <gc/gc.h>

#ifdef LLVM
#define USE_GCJ_MALLOC 0
#else
#define USE_GCJ_MALLOC 1
#endif

typedef void ExFunc(int type, void *ex);

#define CATCH_RETURN 0
#define CATCH_FINALLY 1
#define CATCH_EXCEPTION 2

#define THROW_RETURN 3 
#define THROW_EXCEPTION 4
#define THROW_FINALLY 5
#define THROW_STOP 6

typedef void *GC_PTR;


#if DEBUG
#define D(e...) { printf(e); fflush(stdout); }
#else
#define D(e...)
#endif

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

WORD __l_rbp = 0; // FIXME: should be thread local and doesn't handle more than one L -> foreign code transition on stack
extern void __native_thunk(void (*f)(),...);

int __in_segv = 0;

void __clear_in_segv() {
  __in_segv = 0;
}

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


#ifdef LLVM

#define ALLOC GC_malloc_ignore_off_page
#define NON_OBJECT_ARRAY_ALLOC  GC_malloc_atomic_ignore_off_page
	
#define OBJECT_ARRAY_ALLOC ALLOC
#define OBJECT_ALLOC ALLOC
	

int __get_word_size() {
  return sizeof(WORD);
}

__thread WORD __tls1;
__thread WORD __tls2;

WORD __get_tls1() {
  return __tls1;
}

void __set_tls1(WORD v) {
  __tls1 = v;
}

WORD __get_tls2() {
  return __tls2;
}

void __set_tls2(WORD v) {
  __tls2 = v;
}

typedef WORD proc();

WORD __proc_thunk5(proc *p, WORD a, WORD b, WORD c, WORD d, WORD e) {
  return (*p)(a, b, c, d, e);
}

WORD __proc_thunk4(proc *p, WORD a, WORD b, WORD c, WORD d) {
  return (*p)(a, b, c, d);
}

WORD __proc_thunk3(proc *p, WORD a, WORD b, WORD c) {
  return (*p)(a, b, c);
}

WORD __proc_thunk2(proc *p, WORD a, WORD b) {
  return (*p)(a, b);
}

WORD __proc_thunk1(proc *p, WORD a) {
  return (*p)(a);
}

WORD __proc_thunk0(proc *p) {
  return (*p)();
}

void __collision_thunk(void) {
  fprintf( stderr, "selector collision" );
  exit(1);
}

void __print_backtrace() {
  void *trace[16];
  int c = backtrace( trace, 16 );
  backtrace_symbols_fd( trace, c, 2);
}

/*	
.global __proc_thunk5
__proc_thunk5:
	mov %r8, %r9

.global __proc_thunk4
__proc_thunk4:
	mov %rcx,%r8

.global __proc_thunk3
__proc_thunk3:
	mov %rdx,%rcx
	
.global __proc_thunk2
__proc_thunk2:
	mov %rsi,%rdx	   # shift param #1 -> param #2
	
.global __proc_thunk1
__proc_thunk1:
	mov %rdi,%rsi      # shift param #0 -> param #1
	
.global __proc_thunk0
__proc_thunk0:
	mov 16(%rax),%rdi   # shift this -> param #0
	jmp *24(%rax)
*/

typedef int vtable_function();

unsigned char *allocago( int element_count, int element_size, vtable_function* vt ) {
  int total_size = element_count * element_size + sizeof(WORD) * 2;

  WORD *result = OBJECT_ARRAY_ALLOC(total_size);
  result[0] = (WORD)vt;
  result[1] = element_count;

  return (unsigned char *)result;
}

unsigned char *allocagn( int element_count, int element_size, vtable_function* vt ) {
  int total_size = element_count * element_size + sizeof(WORD) * 2;

  WORD *result = NON_OBJECT_ARRAY_ALLOC(total_size);

  memset(result,0,total_size);
  result[0] = (WORD)vt;
  result[1] = element_count;

  return (unsigned char *)result;
}

unsigned char *alloco( int total_size ) {
  return OBJECT_ALLOC(total_size);
}

int __geterrno() {
  /*
  fprintf( stderr, "errno is: %d\n", errno);
  fprintf( stderr, "error is %s\n", strerror(errno) );
  perror("__geterrno");
  */
  return errno;
}

char **__argv;

char **__get_argv() {
  return __argv;
}

char **__envp;

char **__get_envp() {
  return __envp;
}

extern int __entry_point(void);

int main(int argc, char **argv, char **envp) {
  __argv = argv;
  __envp = envp;
  __l_personality(-1,0,0,0);
  __entry_point();
  return 0;
}



void *_get_classes_info() {
  fprintf( stderr, "FIXME: _get_classes_info" );
  return 0;
}

void __throw_memoryexception() {
  fprintf( stderr, "FIXME: __throw_memory_exception" );
  exit(0);
}





void __throw_arrayboundsexception() {
  fprintf( stderr, "FIXME: __throw_arrayboundsexception" );
  exit(0);
}

void __throw_castexception() {
  fprintf( stderr, "FIXME: __throw_castexception" );
  exit(0);
}

void __catch_exception( WORD type, void *e, void *rip, Registers *regs ) {
  fprintf( stderr, "FIXME: __throw_catchexception" );
  exit(0);
}  
	
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
  void *dummy;
  int mtime;
  int size;
} Stat;

typedef struct _Stat2 {
  int mtime;
  int size;
} Stat2;

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

long __get_micro_time() {
  struct timeval t;

  gettimeofday( &t, 0 );

  return (long)t.tv_sec * 1000000L + t.tv_usec;  
}

#if B32
// C calling convention:

// L calling convention on 32 bit x86 is fastcall - first two parameters in ecx and edx and callee pops arguments from stack:
extern __attribute__((fastcall)) void _ZN6System6Thread16__set_pthread_idEu4word( void *thread, WORD id );
extern __attribute__((fastcall)) void _ZN6System6Thread14__thread_entryEv( void *thread );
extern __attribute__((fastcall)) void _ZN6System9Coroutine17__coroutine_entryEv( void *coroutine );
extern __attribute__((fastcall)) char *_ZN6System12StringBuffer9toCStringEv( void *lstring );
extern __attribute__((fastcall)) void *_ZN6System9Exception16getBacktraceInfoEv( void *e );
extern __attribute__((fastcall)) void *_ZN6System12StringBuffer6appendEPc( void *buffer, char *s );
extern __attribute__((fastcall)) void *_ZN6System12StringBuffer6appendEi( void *buffer, int i );
extern __attribute__((fastcall)) void *_ZN6System12StringBuffer6appendEc( void *buffer, char c );
extern __attribute__((fastcall)) void _ZN6System9Exception16setBacktraceInfoEu4word( void *exception, WORD info );

extern __attribute__((fastcall)) void _ZN6System15MemoryException4initEPc( void *e, char *m );

extern __attribute__((fastcall)) void _ZN6System25MemoryProtectionException4initEPc( void *e, char *m );
extern __attribute__((fastcall)) void _ZN6System20NullPointerException4initEPc( void *e, char *m );

extern __attribute__((fastcall)) char *_ZN6System6Object9toCStringEv( void *e );

#else

extern void _ZN6System6Thread16__set_pthread_idEu4word( void *thread, WORD id );
extern void _ZN6System6Thread14__thread_entryEv( void *thread );
extern void _ZN6System9Coroutine17__coroutine_entryEv( void *coroutine );
extern char *_ZN6System12StringBuffer9toCStringEv( void *lstring );
extern void *_ZN6System9Exception16getBacktraceInfoEv( void *e );
extern void *_ZN6System12StringBuffer6appendEPc( void *buffer, char *s );
extern void *_ZN6System12StringBuffer6appendEi( void *buffer, int i );
extern void *_ZN6System12StringBuffer6appendEc( void *buffer, char c );
extern void _ZN6System9Exception16setBacktraceInfoEu4word( void *exception, WORD info );

extern void _ZN6System15MemoryException4initEPc( void *e, char *m );
extern void _ZN6System25MemoryProtectionException4initEPc( void *e, char *m );
extern void _ZN6System20NullPointerException4initEPc( void *e, char *m );

extern char *_ZN6System6Object9toCStringEv( void *e );
#endif

extern  _ZN6System15MemoryException7throwMEEv();

// extern __throw_memoryexception();

#define STACK_SIZE (1024*1024*2)

void *__thread_entry( void *thread_object ) {
  _ZN6System6Thread14__thread_entryEv( thread_object );
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

    result = pthread_mutex_timedlock( mutex, &ts );
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


void *__get_coroutine_entry() {
  return _ZN6System9Coroutine17__coroutine_entryEv;
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
  // int result = GC_pthread_create( &thread, &attr, __thread_entry, thread_object );
  int result = pthread_create( &thread, &attr, __thread_entry, thread_object );
  _ZN6System6Thread16__set_pthread_idEu4word( thread_object, thread );
  // printf( "result is %d, thread is %p\n", result, (void *)thread );

  // GC_pthread_detach( thread );
  /*
  stack = 
  GC_add_roots( stack, stack+STACK_SIZE );
  */
}


void __GC_add_roots( GC_PTR from, GC_PTR to ) {
  GC_add_roots( from, (void *)(((unsigned long *)to)+1) );
}





void *__alloc_object( WORD size, WORD *vtable ) {
  // GC_find_leak = 1;
  WORD *result;


  if( vtable != 0 ) {
#if USE_GCJ_MALLOC
    result = GC_gcj_malloc( size, vtable );
#else
    result = GC_malloc( size );
    result[0] = (WORD)vtable;
#endif
  } else {
    result = GC_malloc_ignore_off_page( size ); // GC_MALLOC_IGNORE_OFF_PAGE( size );
  }

    // result[0] = (WORD)vtable;

#ifdef TRACE_ALLOC
  if( vtable != 0 ) {
    char *class_name = ((char **)vtable)[-2];
    int class_size = ((WORD *)vtable)[-1];
    printf( "\tAAAAA\t%s\t%d\t\n", class_name, size );
  }
#endif

  return result;
}


// dispose() is first method after vtable parent pointer:
#define FINALIZE_OFFSET 2

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


#else

typedef void DISPOSE(WORD*);

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
  char **p = (char **)vtable;

  // fprintf( stderr, "XXXX: alloc object finalize %s\n", p[-2] );
  // fflush(stderr);

  WORD *result = (WORD *)__alloc_object( size, (WORD *)vtable );

  GC_finalization_proc ofn;
  GC_PTR ocd;

  // WORD *result = GC_malloc_ignore_off_page( size );
  // result[0] = (WORD)vtable;

#if B32
  // wrong calling convention means GC can't call the finalizer directly - need to
  // provide a thunk:
  GC_register_finalizer( (GC_PTR)result, (GC_finalization_proc)__call_dispose, 0, &ofn, &ocd );

#else
  GC_register_finalizer( (GC_PTR)result, (GC_finalization_proc)__call_dispose, 0, &ofn, &ocd );
  // GC_register_finalizer( (GC_PTR)result, vtable[FINALIZE_OFFSET], 0, &ofn, &ocd );
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
    fprintf( stderr, "unexpected exception handler record type %ld\n", r->type );
    fflush( stderr );
    exit(1);
  }
}


typedef struct _LineRecord {
  WORD address;
  WORD line_number;
} LineRecord;

typedef struct _UnwindRecord {
  WORD        method_start;
  WORD        method_length;
  char       *method_name;
  LineRecord *line_numbers;
  WORD        flags;
  WORD        ro_size;
} UnwindRecord;

extern UnwindRecord *__unwind_start;

typedef struct _UnwindList {
  UnwindRecord *head;
  struct _UnwindList *tail;
  int length;
} UnwindList;

static UnwindList *unwind_head = 0;

typedef struct _BacktraceRecord {
  WORD rip;
  char *method_name;
  LineRecord *line_number_info;
} BacktraceRecord;

void findLineNumber( void *buffer, BacktraceRecord *backtrace ) {
  if( buffer == 0 ) {
    D( "line info buffer is null\n" );
    return;
  }

  D("find line number %p, %p\n", buffer, backtrace );

  if( backtrace == 0 ) {
    D("no backtrace required\n");
    return;
  }

  _ZN6System12StringBuffer6appendEc( buffer, '\t' );
  if( backtrace->method_name != 0 ) {
    _ZN6System12StringBuffer6appendEPc( buffer, backtrace->method_name );
  } else {
    _ZN6System12StringBuffer6appendEPc( buffer, "unknown\n" );
    return;
  }

  LineRecord *line_number = backtrace->line_number_info;
  WORD rip = backtrace->rip;

  if( line_number == 0 ) {
    D("no line number information available\n");
    _ZN6System12StringBuffer6appendEc( buffer, '\n' );
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
    _ZN6System12StringBuffer6appendEPc( buffer, ": " );
    _ZN6System12StringBuffer6appendEi( buffer, previous_line );
    _ZN6System12StringBuffer6appendEc( buffer, '\n' );
  } else {
    _ZN6System12StringBuffer6appendEPc( buffer, ": outside method\n" );
  }
}


void __find_line_numbers( void *buffer, BacktraceRecord *backtrace ) {
  if( backtrace == 0 ) {
    return;
  }

  while( backtrace->rip ) {
    D("find line number for rip %p from line info %p\n", backtrace->rip, backtrace->line_number_info );
    findLineNumber( buffer, backtrace++ );
  }
}

void __add_unwind_info( UnwindRecord **u ) {
  UnwindList *list;

  D("adding unwind info %p\n", u );

  list = (UnwindList *)GC_malloc( sizeof(UnwindList) );

  list->head = *u;
  list->tail = unwind_head;
  list->length = 0;

  unwind_head = list;
}

typedef struct _RecentUnwindInfo {
  WORD rip;
  UnwindRecord *p;
  struct _RecentUnwindInfo *next;
} RecentUnwindInfo;

#ifdef B64
#define UNWIND_HASH_BYTES 4
#else
#define UNWIND_HASH_BYTES 4
#endif

#define UNWIND_CACHE_MAX 256
#define UNWIND_CACHE_MASK (UNWIND_CACHE_MAX-1)

// FIXME: none of this is thread safe

// mapping from rip values to unwind records, indexed by hash of rip:
RecentUnwindInfo __unwind_cache[UNWIND_CACHE_MAX];

// unwind record we expect to encounter next if current unwind follows same path as previous:
RecentUnwindInfo *__next_unwind_hit = __unwind_cache;

// last matched cache entry:
RecentUnwindInfo *__last_unwind_hit = __unwind_cache;

RecentUnwindInfo *findCachedUnwindInfo( WORD rip ) {
  WORD rip_c;
  RecentUnwindInfo *p;
  unsigned char *c;
  unsigned char hash;
  int i;

  D("find cached rip %p\n", (void *)rip );

  // first check if we're following an existing unwind chain:
  if( __next_unwind_hit != 0 &&__next_unwind_hit->rip == rip ) {
    // matched an existing chain:
    p = __next_unwind_hit;
    D("unwind chain hit\n" );

    // we now hope the next rip to look up will be the next entry in this chain:
    __next_unwind_hit = p->next;

    if( __last_unwind_hit != 0 ) {
	// if we take this exception again then the frame under last unwind hit is the frame we just found:
	__last_unwind_hit->next = p;
    }
    // in case next lookup is a miss we'll want to patch this cache entry's next pointer:
    __last_unwind_hit = p;
    return p;
  }

  D("unwind chain miss, hashing...\n" );
  rip_c = rip;
  c = (unsigned char *)&rip_c;
  hash = 0;

  // haven't hit the current unwind chain so compute hash of rip:
  for( i = 0; i < UNWIND_HASH_BYTES; i++ ) {
    hash = hash ^ c[i];
  }

  D("hash is %x table[%d] @ %p\n", (unsigned)hash, (unsigned)hash, &__unwind_cache[hash]);

  // look in the cache entry for hash of rip:
  p = &__unwind_cache[hash];
  if( p->rip == rip ) {
    // cache hit:
    D("cache hit\n" );

    if( __last_unwind_hit != 0 ) {
	// if we take this exception again then the frame under last unwind hit is the frame we just found:
	__last_unwind_hit->next = p;
    }

    // this record is now the last referenecd cache entry:
    __last_unwind_hit = p;

    D("returning recent unwind %p\n", p );
    return p;
  }

  D("should patch %p\n", &__unwind_cache[hash]);
  
  return p;
}

int __unwind_length;

UnwindRecord *findUnwindInfo( WORD rip, BacktraceRecord *backtrace ) {
  int result = 0;
  UnwindRecord *p, *q, *r;
  D( "looking for method containing %p\n", (void *)rip );

  RecentUnwindInfo *rp = findCachedUnwindInfo( rip );
  if( rp->rip == rip ) {
    D("cached unwind info matches rip\n" );
    p = rp->p;
    if( p == 0 ) {
      D( "no unwind record stored\n" );
      return 0;
    }
    if( backtrace != 0 ) {
      D( "filling in backtrace from cached unwind info rip %p, line numbers %p\n", rip, p->line_numbers );
      backtrace->rip = rip;
      backtrace->method_name = p->method_name;
      backtrace->line_number_info = p->line_numbers;
    }

    D("returning unwind record %p\n", p );
    return p;
  }

  UnwindRecord *start = __unwind_start;
  int length = __unwind_length;
  int *p_length = &__unwind_length;
  UnwindList *next = unwind_head;

  D( "initial unwind table %p...\n", start );

  do {
    D( "unwind table %p, first method start %p...\n", (void *)start, (void *)start->method_start );

    if( length == 0 ) {

      D( "linear search...\n" );
      p = 0;
      // first time, don't know table length so do linear search and calculate length at same time:
      for( q = start; q->method_start != 0; q++ ) {
	long method_end = q->method_start + q->method_length;
	D( "have record %p, %p +%ld (%p) %s\n", q, (void *)q->method_start, q->method_length, (void *)method_end, q->method_name );
	if( rip >= q->method_start && rip < method_end ) {
	  D( "match %p in method %s between %p and %p, unwind flags %lx\n", (void *)rip, q->method_name, (void*)q->method_start, (void*)method_end, q->flags );
	  if( backtrace != 0 ) {
	    D( "filling in backtrace\n" );
	    backtrace->rip = rip;
	    backtrace->method_name = q->method_name;
	    backtrace->line_number_info = q->line_numbers;
	  } else {
	    D( "no backtrace to fill in\n" );
	  }

	  D( "will patch %p\n", __last_unwind_hit );
	  
	  p = q;
	}

	length++;
      }

      if( p == 0 ) {
	D( "not found\n" );
      } else {
	D( "found\n" );
      }

      *p_length = length;
    } else {
      p = start;
      q = p + length -1;
      D( "binary search over %d entries %p .. %p\n", length, p->method_start, q->method_start + q->method_length );

      do {
	WORD difference = (q - p);

	D( "between %p and %p, %ld entries", p, q, difference );

	UnwindRecord *r = p + difference / 2;
	
	D( "chop at %p\n", r->method_start );

	if( r == p ) {
	  if( rip >= p->method_start && rip <= p->method_start + p->method_length ) {
	    D( "found %p\n", p );
	  } else {
      	    D( "probably not found %p outside %p..%p, try linear search\n", (void *)rip, p->method_start, p->method_start + p->method_length );
	    //	     length = 0;
	    p = 0; // findUnwindInfo( rip, backtrace );
	  }
	  break;
	}

	if( rip < r->method_start ) {
	  D( "chop downwards [%p .. %p] .. %p\n", p->method_start, r->method_start, q->method_start );
	  q = r;
	} else if( rip > r->method_start + r->method_length ) {
	  D( "chop upwards %p .. [%p .. %p]\n", p->method_start, r->method_start, q->method_start );
	  p = r;
	} else {
	  D( "appear to have found at %p", r->method_start );
	  p = r;
	  break;
	}
      } while( 1 );
    }

    if( p != 0 ) {
      rp->rip = rip;
      rp->p = p;
      rp->next = 0;

      if( backtrace != 0 ) {
	D( "filling in backtrace from cached unwind info rip %p, line numbers %p\n", rip, p->line_numbers );
	backtrace->rip = rip;
	backtrace->method_name = p->method_name;
	backtrace->line_number_info = p->line_numbers;
      }

      D("setting unwind cache entry %p, rip %p, unwind record %p\n", rp, rp->rip, rp->p );

      if( __last_unwind_hit != 0 ) {
	// if we take this exception again then the frame under last unwind hit is the frame we just found:
	__last_unwind_hit->next = rp;
      }

      __last_unwind_hit = rp;

      return p;
    }

    if( next != 0 ) {
      start = next->head;
      next = next->tail;
      length = next->length;
      p_length = &next->length;
    } else {
      start = 0;
    }
    D( "next unwind list is %p\n", start );
  } while( start != 0 );

  rp->rip = rip;
  rp->p = 0;
  rp->next = 0;
  D("not found unwind cache entry %p, rip %p, unwind record %p\n", rp, rp->rip, rp->p );

    
  // __last_unwind_hit = 0;
  D( "could not find rip\n" );
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
      D("no unwind record\n", u );
      if( br != 0 ) {
	br->method_name = "unknown";
      }

      if( found_frame ) {
	D("found catch frame so stop unwind here\n" );
	break;
      } else {
	fprintf( stderr, "foreign stack frame found before handler for method containing address %p, expect trouble...\n", (void *)rip );
	fflush(stderr);
	// exit(1);
      }

      D("pass through non-L frame here\n" );

      // break; ??
    } else {
      D("have unwind record: %p\n", u );

      if( stop_at_rip == u->method_start ) {
	D( "stop unwinding here but continue filling backtrace...\n" );

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


extern WORD __size_N6System12StringBufferE;
extern WORD **__get_vtable_N6System12StringBufferE();


void __flush_stdout() {
  fflush(stdout);
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

extern WORD  __size_N6System20NullPointerExceptionE;
extern WORD **__get_vtable_N6System20NullPointerExceptionE();

extern WORD __size_N6System13CastExceptionE;
extern WORD **__get_vtable_N6System13CastExceptionE();

extern WORD __size_N6System15BoundsExceptionE;
extern WORD **__get_vtable_N6System15BoundsExceptionE();

extern WORD  __size_N6System25MemoryProtectionExceptionE;
extern WORD **__get_vtable_N6System25MemoryProtectionExceptionE();

/*

Exception *makeNullPointerException() {
  Exception *result = (Exception *)malloc(size$__Q26System20NullPointerException);
  result->vtable = vtable$__Q26System20NullPointerException;

  init__Q26System20NullPointerExceptionPc(result,"null pointer");

  return result;
}
*/



int segv_count = 0;

extern void _ZN6System20NullPointerException8throwNPEEv();

void __segv_handler(int sig, siginfo_t *si, SigContext *uc) {
  if( __in_segv ) {
    fprintf( stderr, "segv in segv handler\n" );
    fflush( stderr );
    __print_backtrace();

    exit(1);
  }

  __in_segv = 1;
  __print_backtrace();


  // GC_disable();

  int i;
  D("caught SIGSEGV referencing address: 0x%lx\n", (long) si->si_addr); 

  // printf( "segv count %d, rip %p\n", segv_count++, (void *)uc->regs.rip ); fflush(stdout);

  long rip = (long)uc->regs.rip;

  // null or negative, > 32M and below shared object area, > 64M beyond start of shared object area       
  /*
  if( rip <= 8192l || (rip > 0x2000000 && rip < 0x80000000000) || rip > 0x80004000000 ) {
    // if rip doesn't look like a valid instruction address, assume we've somehow called through a bad pointer and
    // look on the stack top for a return address pointing at the offending instruction:

    rip = *(WORD *)uc->regs.rsp;

    // fprintf( stderr, "rip is now %p\n", (void *)rip );

    uc->regs.rsp += sizeof(WORD);
    // } else {

    // fprintf( stderr, "non null rip %d\n", (void *)rip );
  }
  */

  // fprintf( stderr, "Content-type: text/plain\r\n\r\n" );
  // fprintf( stderr, "SIGSEGV referencing address: 0x%p\n", (void *)si->si_addr );

  /*
  Exception *e;

  long address = (WORD)si->si_addr;
  if( address > -8192l && address < 8192l ) {
    e = __make_nullpointerexception();
  } else {
    e = __make_memoryprotectionexception();
  }

  D( "e:   %p\n", e );
  */

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
#endif
  D( "rip: %lx\n", uc->regs.rip );


  // void *p = malloc( sizeof(Registers) );
  // memcpy( p, &uc->regs, sizeof(Registers) );

  /*
#if B32
  uc->regs.rdx = (WORD)rip;            // faulting address
  uc->regs.rcx = (WORD)e;                       // exception to throw;
#endif

#if B64
  uc->regs.rdi = (WORD)rip;            // faulting address
  uc->regs.rsi = (WORD)e;                       // exception to throw;
#endif
  */
  // uc->regs.rip = (WORD)_ZN6System15MemoryException7throwMEEv; // restart address
  // exit(1);

  // this isn't right but try throwing from within the handler as returning to the handler
  // address is unreliable (due to uncertain stack state?):

  _ZN6System15MemoryException7throwMEEv();
}





void *__gcj_mark_proc(
		      WORD * addr,
		      void *mark_stack_ptr,
		      void *mark_stack_limit,
		      WORD env ) {
  fprintf( stderr, "oops: __gcj_mark_proc called for address %lx\n", addr );

  return(mark_stack_ptr);
}


void __init_gcj_malloc() {
    GC_init_gcj_malloc( 0, (void *)__gcj_mark_proc );
}

#define SIGNAL_STACK_SIZE 65536
void __install_segv_handler() {
  D("install segv handler\n");
  stack_t ss;
  struct sigaction sa;

  ss.ss_sp = malloc(SIGNAL_STACK_SIZE);
  if( ss.ss_sp == 0 ) {
    fprintf( stderr, "failed to allocate signal stack" );
    exit(1);
  }

  ss.ss_size = SIGNAL_STACK_SIZE;
  ss.ss_flags = 0;

  if( sigaltstack( &ss, 0 ) < 0 ) {
    fprintf( stderr, "failed to set signal stack" );
    exit(1);
  }

  sa.sa_flags = SA_SIGINFO | SA_NODEFER | SA_ONSTACK;
  sigemptyset(&sa.sa_mask);
  sa.sa_sigaction = __segv_handler;
  if( sigaction(SIGSEGV, &sa, NULL) < 0 ) {
    fprintf( stderr, "failed to set SEGV signal handler" );
    exit(1);
  }
}


int __stat_file( char *name, Stat *ls ) {
  struct stat us;

  int result = stat( name, &us );
  if( !result ) {

    ls->mtime = us.st_mtime;
  }

  return result;
}

int __stat_file2( char *name, Stat2 *ls ) {
  struct stat us;

  int result = stat( name, &us );
  if( !result ) {
    ls->mtime = us.st_mtime;
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

void ftest(void) {
  fprintf(stderr, "ftest...\n" ); fflush(stderr);
}


void *__alloc_ucontext(void *coroutine_object, size_t stack_size) {
  fprintf(stderr, "alloc ucontext object %p, stacksize %u...\n", coroutine_object, stack_size ); fflush(stderr);
  ucontext_t *result = GC_malloc(sizeof(ucontext_t));
  fprintf(stderr, "getcontext into %p...\n", result ); fflush(stderr);
  getcontext(result);

  fprintf(stderr, "alloc stack...\n" ); fflush(stderr); 
  result->uc_stack.ss_sp = GC_malloc(stack_size);
  result->uc_stack.ss_size = stack_size - 16;
  result->uc_link = 0;

  fprintf(stderr, "make context into %p...\n", result ); fflush(stderr);
  makecontext(result, _ZN6System9Coroutine17__coroutine_entryEv, 1, coroutine_object);

  return result;
}

