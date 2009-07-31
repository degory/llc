CFLAGS=-DB64 -g 
install: lrt-amd64-1.o ldn-amd64-1.o exception.so
	cp lrt-amd64-1.o /usr/lang/lib
	cp ldn-amd64-1.o /usr/lang/lib
	cp exception.o /usr/lang/lib
	cp exception.so /usr/lang/lib

# all: lrtx.o


lrdD.o: lrtD.S

exception.so: exception.c
	gcc $(CFLAGS) -shared -fpic exception.c -o exception.so

# exception.o: exception.c

lrt-amd64-1.o: lrt0.o exception.o
	gcc -c $(CFLAGS) lrt0.S -o lrt-amd64-1.o

ldn-amd64-1.o: lrtD.o
	ld -r -o ldn-amd64-1.o lrtD.o