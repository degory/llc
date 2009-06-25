CFLAGS=-DB64

install: lrt-amd64.o
	cp lrt-amd64.o /usr/lang/lib

# all: lrtx.o

lrt0.o: lrt0.S

exception.o: exception.c

lrt-amd64.o: lrt0.o exception.o
	ld -r -o lrt-amd64.o lrt0.o exception.o

