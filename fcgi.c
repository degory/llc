
#include "fcgi_config.h"

#include <stdlib.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include "fcgi_stdio.h"
#include "fcgiapp.h"
extern char **environ;

FCGI_FILE *__get_FCGI_stdin() { return FCGI_stdin; }
FCGI_FILE *__get_FCGI_stdout() { return FCGI_stdout; }
FCGI_FILE *__get_FCGI_stderr() { return FCGI_stderr; }
char **__get_FCGI_environ() { return environ; }

size_t __FCGX_get_sizeof_request() { return sizeof(FCGX_Request); }
FCGX_Stream *__FCGX_get_in(FCGX_Request *r) {
  return r->in;
}

FCGX_Stream *__FCGX_get_out(FCGX_Request *r) {
  return r->out;
}

FCGX_Stream *__FCGX_get_err(FCGX_Request *r) {
  return r->err;
}

char **__FCGX_get_envp(FCGX_Request *r) {
  return r->envp;
}

