#include <stdio.h>

extern "C" {

  extern void *makeException(void *e);
  extern void _Unwind_RaiseException( void *e );
  typedef unsigned long long uint64;

  void __throw_exception( void *l_exception ) {
    fprintf( stderr, "will throw: %p\n", l_exception );
    _Unwind_RaiseException( makeException(l_exception) );
    fprintf( stderr, "oops: unwind raise exception should not return\n" );
  }
}
