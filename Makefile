ifeq ($(BITS),32)
	MODEL:=-m32
	TARGET:=linux-x86-32
else
	MODEL:=-m64
	TARGET:=linux-x86-64
endif


all: lc lc.bc lc.d lang lang.d

install: lc jit.o dummy.o llvmc.so lang.bc lang.lh
	cp safe/lc-previous-1 safe/lc-previous-2 || true
	cp safe/lc-previous safe/lc-previous-1 || true
	cp /usr/bin/lc safe/lc-previous
	cp jit.o dummy.o llvmc.so lang.bc lang.lh /usr/lang/lib/$(TARGET)/
	sudo cp lc /usr/bin
	sudo cp -r lib/* /usr/lib/lang

lc.d:
	lc $(MODEL) -D -w -p test -o lc -N -s llvm -lllvmc.o -lLLVMAnalysis -lLLVMArchive -lLLVMBitReader -lLLVMBitWriter -lLLVMCore -lLLVMExecutionEngine -lLLVMipa -lLLVMMC -lLLVMSupport -lLLVMSystem -lLLVMTarget -lLLVMTransformUtils main.l

lang.d:
	lc $(MODEL) -D -w -u lib.l -o lang

include lc.d

include lang.d

lang: lang.bc lang.lh

lang.bc: $(lang_DEPS)
	lc -f $(MODEL) -w -u lib.l -o lang

lang.lh: lang.bc

lc: $(lc_DEPS) llvmc.o llvmc.so dummy.o
	lc -f $(MODEL) -w -p test -o lc -N -s llvm -lllvmc.o -lLLVMAnalysis -lLLVMArchive -lLLVMBitReader -lLLVMBitWriter -lLLVMCore -lLLVMExecutionEngine -lLLVMipa -lLLVMMC -lLLVMSupport -lLLVMSystem -lLLVMTarget -lLLVMTransformUtils main.l

llvmc.o: llvmc.cpp
	g++ `llvm-config --cxxflags` -c llvmc.cpp

llvmc.so: llvmc.cpp
	g++ `llvm-config --cxxflags` -fpic -shared llvmc.cpp -o llvmc.so

dummy.o: dummy.c
	gcc -c dummy.c
	cp dummy.o /usr/lang/lib

lc.bc:	x
	lc -Os -p test main.l -l llvm -o lc

jit.o: jit.cpp
	g++ `llvm-config --cxxflags` -c jit.cpp -o jit.o
	cp jit.o /usr/lang/lib/unsafe


