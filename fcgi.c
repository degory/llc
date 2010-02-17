
#include "fcgi_config.h"

#include <stdlib.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include "fcgi_stdio.h"
extern char **environ;

FCGI_FILE *__get_FCGI_stdin() { return FCGI_stdin; }
FCGI_FILE *__get_FCGI_stdout() { return FCGI_stdout; }
FCGI_FILE *__get_FCGI_stderr() { return FCGI_stderr; }
char **__get_FCGI_environ() { return environ; }

