CFLAGS=-m32 -DB32

install: lrt-x86.o
	cp lrt-x86.o /usr/lang/lib

# all: lrtx.o

lrt0.o: lrt0.S
	gcc $(CFLAGS) -c -o lrt0.o lrt0.S

exception.o: exception.c

lrt-x86.o: lrt0.o exception.o
	ld -melf_i386 -r -o lrt-x86.o lrt0.o exception.o

