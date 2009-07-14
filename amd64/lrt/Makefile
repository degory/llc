CFLAGS=-DB64 -g

install: lrt-amd64.o ldn-amd64.o
	cp lrt-amd64.o /usr/lang/lib
	cp ldn-amd64.o /usr/lang/lib

# all: lrtx.o

lrt0.o: lrt0.S

lrdD.o: lrtD.S

exception.o: exception.c

lrt-amd64.o: lrt0.o exception.o
	ld -r -o lrt-amd64.o lrt0.o exception.o

ldn-amd64.o: lrtD.o
	ld -r -o ldn-amd64.o lrtD.o