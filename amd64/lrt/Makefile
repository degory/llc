VERSION=0.2
CFLAGS=-DB64 -g -O1
install: lrt-amd64.o ldn-amd64.o exception.so exception.o
	cp lrt-amd64.o /usr/lang/lib/lrt-amd64-$(VERSION).o
	cp ldn-amd64.o /usr/lang/lib/ldn-amd64-$(VERSION).o
	cp exception.o /usr/lang/lib/exception-$(VERSION).o
	cp exception.so /usr/lang/lib/exception-$(VERSION).so

# all: lrtx.o

clean:
	rm *.o *.so


lrdD.o: lrtD.S

exception.so: exception.c
	gcc $(CFLAGS) -shared -fpic exception.c -o exception.so

# exception.o: exception.c

lrt-amd64.o: lrt0.o exception.o
	gcc -c $(CFLAGS) lrt0.S -o lrt-amd64.o

ldn-amd64.o: lrtD.o
	ld -r -o ldn-amd64.o lrtD.o