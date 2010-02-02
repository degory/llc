#!/bin/sh
lli=${LLVMINTERP-lli}
exec $lli \
    -load=/usr/lib/libgc.so \
    -load=/usr/lib/libdl.so \
    -load=/home/degs/Source/lang/llc/llvmc.so \
    -load=/usr/local/lib/libLLVMArchive.so \
    -load=/usr/local/lib/libLLVMBitReader.so \
    -load=/usr/local/lib/libLLVMBitWriter.so \
    -load=/usr/local/lib/libLLVMExecutionEngine.so \
    -load=/usr/local/lib/libLLVMMC.so \
    -load=/usr/local/lib/libLLVMSupport.so \
    -load=/usr/local/lib/libLLVMBitWriter.so \
    lc.bc ${1+"$@"}
#     -load=/usr/local/lib/libLLVMTransformUtils.so \
#     -load=/usr/local/lib/libLLVMTarget.so \
#     -load=/usr/local/lib/libLLVMipa.so \
#     -load=/usr/local/lib/libLLVMSystem.so \
#     -load=/usr/local/lib/libLLVMCore.so \
#     -load=/usr/local/lib/libLLVMAnalysis.so \
