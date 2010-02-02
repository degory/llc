all: lc

lc: lco.o llvmc.o dummy.o
	g++ -o lc lco.o llvmc.o dummy.o -lLLVMAnalysis -lLLVMArchive -lLLVMBitReader -lLLVMBitWriter -lLLVMCore -lLLVMExecutionEngine -lLLVMipa -lLLVMMC -lLLVMSupport -lLLVMSystem -lLLVMTarget -lLLVMTransformUtils

llvmc.o: llvmc.cpp
	g++ `llvm-config --cxxflags` -c llvmc.cpp

dummy.o: dummy.c
	gcc -c dummy.c

lco.s: lco.bc
	llc -f lco.bc

lco.o: lco.s
	gcc -c lco.s

lco.bc: lc.bc
	opt -f -O3 lc.bc -o lco.bc

lc.bc:	x
	lc -Os -p test main.l -l llvm -o lc
