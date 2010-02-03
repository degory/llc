VERSION=0.2
CFLAGS=-DB64 -g -O1 -DLLVM

all: /usr/lang/lib/lrt-llvm-$(VERSION).bc # /usr/lang/lib/lrd-llvm-$(VERSION).bc

/usr/lang/lib/lrt-llvm-$(VERSION).bc: 	exception.o unwind.o throw.o
	llvm-ld -disable-opt -o /usr/lang/lib/lrt-llvm-$(VERSION) exception.o unwind.o throw.o

exception.o: exception.c
	/usr/local/llvm/bin/gcc $(CFLAGS) -emit-llvm -c exception.c

unwind.o: unwind.c
	/usr/local/llvm/bin/gcc $(CFLAGS) -emit-llvm -c unwind.c

throw.o: throw.cpp
	/usr/local/llvm/bin/g++ $(CFLAGS) -emit-llvm -c throw.cpp

#install: lrt-amd64.o ldn-amd64.o exception.so exception.o
#	cp lrt-amd64.o /usr/lang/lib/lrt-amd64-$(VERSION).o
#	cp ldn-amd64.o /usr/lang/lib/ldn-amd64-$(VERSION).o
#	cp exception.o /usr/lang/lib/exception-$(VERSION).o
#	cp exception.so /usr/lang/lib/exception-$(VERSION).so

# all: lrtx.o

#clean:
#	rm *.o *.so


#lrdD.o: lrtD.S

#exception.so: exception.c
#

# exception.o: exception.c

#lrt-amd64.o: lrt0.o exception.o
#	gcc -c $(CFLAGS) lrt0.S -o lrt-amd64.o

#ldn-amd64.o: lrtD.o
#	ld -r -o ldn-amd64.o lrtD.o