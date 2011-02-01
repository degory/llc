#include <stdio.h>
#include <cxxabi.h>

extern "C" {

  extern void *makeException(void *e);
  extern void _Unwind_RaiseException( void *e );
  typedef unsigned long long uint64;

  void __throw_exception( void *l_exception ) {
    // fprintf( stderr, "will throw: %p\n", l_exception );
    _Unwind_RaiseException( makeException(l_exception) );
    fprintf( stderr, "oops: unwind raise exception should not return\n" );
    //exit(1);
  }
  /*
  char *__demangle_symbol( char *name ) {
    int status;
    char *result = abi::__cxa_demangle(name, 0, 0, &status);
    // fprintf( stderr, "demangle result: %d\n", status );
    return result;
  }
  */
}
