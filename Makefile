ifeq ($(LC),)
	LC:=lc
endif

ifeq ($(BITS),32)
	MODEL:=-m32
	TARGET:=linux-x86-32
else
	MODEL:=-m64
	TARGET:=linux-x86-64
endif

ifeq ($(LFLAGS),)
	LFLAGS:=-p test -w
endif

ifeq ($(LFLAGSBC),)
	LFLAGSBC:=$(LFLAGS)
endif

ifeq ($(LFLAGSNATIVE),)
	LFLAGSNATIVE:=$(LFLAGS) -CN
endif


ifeq ($(LLVM_CC),)
	LLVM_CC:=/usr/local/bin/gcc
endif

ifeq ($(LLVM_CXX),)
	LLVM_CXX:=/usr/local/bin/g++
endif

LRT_VERSION:=0.2

INSTALL_OBJS:=$(LC) jit.o dummy.o llvmc.so fcgi.o lang.bc lang.so lang.lh lrt-llvm-$(LRT_VERSION).bc

LRT_CFLAGS:=-DB64 -g -O1 -DLLVM

CP_FLAGS:=-u -v -p --preserve=timestamps

all: $(INSTALL_OBJS)

install: $(INSTALL_OBJS)
	echo "Installing in $(PREFIX)/"
	cp safe/lc-previous-1 safe/lc-previous-2 || true
	cp safe/lc-previous safe/lc-previous-1 || true
	cp /usr/bin/lc safe/lc-previous

	mkdir -p $(PREFIX)/usr/bin/
	mkdir -p $(PREFIX)/usr/lib/lang/$(TARGET)/trusted/
	mkdir -p $(PREFIX)/usr/lib/lang/$(TARGET)/unsafe/
	mkdir -p $(PREFIX)/usr/lib/lang/$(TARGET)/safe/

	cp -r $(CP_FLAGS) lib/* $(PREFIX)/usr/lib/lang	
	cp $(CP_FLAGS) jit.o fcgi.o llvmc.so $(PREFIX)/usr/lib/lang/$(TARGET)/unsafe/
	cp $(CP_FLAGS) dummy.o lang.bc lang.lh $(PREFIX)/usr/lib/lang/$(TARGET)/trusted/
	cp $(CP_FLAGS) lrt-llvm-$(LRT_VERSION).bc $(PREFIX)/usr/lib/lang/$(TARGET)/
	cp $(CP_FLAGS) lang.so $(PREFIX)/usr/lib/lang/$(TARGET)/
	cp -u -v -p lc $(PREFIX)/usr/bin

lc.zip: $(INSTALL_OBJS)	
	rm -r /tmp/canned || true
	mkdir /tmp/canned
	$(MAKE) $(MAKEFILE) PREFIX=/tmp/canned install
	rm lc.zip || true
	HERE=`pwd` ; cd /tmp/canned ; zip -r $$HERE/lc.zip usr

clean:
	rm lc lc.bc lc.lh jit.o dummy.o llvmc.o llvmc.so lang lang.bc lang.lh lrt-exception.o lrt-unwind.o lrt-throw.o /tmp/lcache-test/* || true

lc.d:
	$(LC) $(MODEL) $(LFLAGS) -D -w -p test -o lc -N -s llvm -lllvmc.o -lLLVMAnalysis -lLLVMArchive -lLLVMBitReader -lLLVMBitWriter -lLLVMCore -lLLVMExecutionEngine -lLLVMipa -lLLVMMC -lLLVMSupport -lLLVMSystem -lLLVMTarget -lLLVMTransformUtils main.l

lang.d:
	$(LC) $(MODEL) $(LFLAGS) -D -w -u lib.l -o lang

include lc.d

include lang.d

lang: lang.bc lang.lh

lang.bc: $(lang_DEPS)
	$(LC) -f $(MODEL) $(LFLAGSBC) -w -u lib.l -o lang

lang.so: $(lang_DEPS)
	$(LC) -V -f $(MODEL) $(LFLAGSNATIVE) -CP -w -u lib.l -o lang
	mv lang lang.so

lang.lh: lang.bc

lc: $(lc_DEPS) llvmc.o llvmc.so dummy.o
	$(LC) -f $(MODEL) $(LFLAGSNATIVE) -p test -o lc -s llvm -lllvmc.o -lLLVMAnalysis -lLLVMArchive -lLLVMBitReader -lLLVMBitWriter -lLLVMCore -lLLVMExecutionEngine -lLLVMipa -lLLVMMC -lLLVMSupport -lLLVMSystem -lLLVMTarget -lLLVMTransformUtils main.l

llvmc.o: llvmc.cpp
	g++ $(MODEL) `llvm-config --cxxflags` -c llvmc.cpp

llvmc.so: llvmc.cpp
	g++ $(MODEL) `llvm-config --cxxflags` -fpic -shared llvmc.cpp -o llvmc.so

dummy.o: dummy.c
	gcc $(MODEL) -c dummy.c

lc.bc:	$(lc_DEPS) 
	$(LC) -f $(MODEL) $(LFLAGSBC) -w -p test -o lc -s llvm main.l -o lc

fcgi.o: fcgi.c
	gcc $(MODEL) -c fcgi.c 

jit.o: jit.cpp
	g++ $(MODEL) `llvm-config --cxxflags` -c jit.cpp -o jit.o

lrt-llvm-$(LRT_VERSION).bc: lrt-exception.o lrt-unwind.o lrt-throw.o
	llvm-ld -disable-opt -o lrt-llvm-$(LRT_VERSION) lrt-exception.o lrt-unwind.o lrt-throw.o

lrt-exception.o: lrt-exception.c
	$(LLVM_CC) $(MODEL) $(LRT_CFLAGS) -emit-llvm -c lrt-exception.c

lrt-unwind.o: lrt-unwind.c
	$(LLVM_CC) $(MODEL) $(LRT_CFLAGS) -emit-llvm -c lrt-unwind.c

lrt-throw.o: lrt-throw.cpp
	$(LLVM_CXX) $(MODEL) $(LRT_CFLAGS) -emit-llvm -c lrt-throw.cpp

bootstrap:
	rm lc /tmp/lcache-test/* || true
	$(MAKE) lc
	mv lc lc1
	rm /tmp/lcache-test/*
	$(MAKE) LC=./lc1 lc
	mv lc lc2
	rm /tmp/lcache-test/*
	$(MAKE) LC=./lc2 lc
	mv lc lc3
	rm /tmp/lcache-test/*
	$(MAKE) LC=./lc3 lc
	diff lc2 lc3
