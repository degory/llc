include target
LFLAGS:=$(WANT_LFLAGS)

LRT_VERSION:=0.2


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

ifeq ($(PROJECT),)
	PROJECT:=compiler
endif

ifeq ($(RUNTIME),)
	RUNTIME:=/usr/lib/lang
endif

ifeq ($(JOBS),)
	JOBS:=1
endif


LFLAGS:=-j$(JOBS) $(LFLAGS)

ifeq ($(WANT_NATIVEOBJS),1)
	LFLAGSBC:=-p $(PROJECT) -R$(RUNTIME) $(LFLAGS)
	LFLAGS:=$(LFLAGSBC) -FB
else
	LFLAGS:=-p $(PROJECT) -R$(RUNTIME) $(LFLAGS)
	LFLAGSBC:=$(LFLAGS)
endif


# BC library. Like BC executable, never native objects but export all symbols:
LFLAGSBCLIB:=$(LFLAGSBC) -FE

# Native executable. Maybe native objects, always native excutable, export nothing:
LFLAGSEXE:=$(LFLAGS) -FN

# Native library. As native executable but position independant code, export all symbols:
LFLAGSSO:=$(LFLAGSEXE) -FNPE

ifeq ($(WANT_LINKSOLIB),1)
	LFLAGSEXE:=$(LFLAGSEXE) -N
endif

ifeq ($(LLVM_CC),)
	LLVM_CC:=/usr/local/bin/gcc
endif

ifeq ($(LLVM_CXX),)
	LLVM_CXX:=/usr/local/bin/g++
endif

ifeq ($(PREFIX),)
	PREFIX:=/usr
endif

ifeq ($(NOLLVMCC),)
	CLEAN:=lc lrt-llvm-$(LRT_VERSION).bc lrt-llvm-$(LRT_VERSION).o lc.bc lc.lh jit.o dummy.o llvmc.o llvmc.so lang lang.bc lang.lh lrt-exception.o lrt-unwind.o lrt-throw.o /tmp/lcache-$(PROJECT)/* || true
else
	CLEAN:=lc lrt-llvm-$(LRT_VERSION).bc lc.bc lc.lh llvmc.so lang lang.bc lang.lh /tmp/lcache-$(PROJECT)/* || true
endif


INSTALL_OBJS:=lc jit.o dummy.o llvmc.so fcgi.o lang.bc lang.so lang.lh lrt-llvm-$(LRT_VERSION).bc lrt-llvm-$(LRT_VERSION).o

LRT_CFLAGS:=-DB64 -g -O1 -DLLVM

CP_FLAGS:=-u -v -p --preserve=timestamps

all: $(INSTALL_OBJS)

install: $(INSTALL_OBJS)
	echo "Installing in $(PREFIX)/"
	echo "Target is $(TARGET)"
	#mkdir -p safe
	#cp safe/lc-previous-1 safe/lc-previous-2 || true
	#cp safe/lc-previous safe/lc-previous-1 || true
	#cp /usr/bin/lc safe/lc-previous
	mkdir -p $(PREFIX)/bin/
	cp -u -v -p lc $(PREFIX)/bin
	mkdir -p $(PREFIX)/lib/lang/$(TARGET)/trusted/
	mkdir -p $(PREFIX)/lib/lang/$(TARGET)/unsafe/
	mkdir -p $(PREFIX)/lib/lang/$(TARGET)/safe/
	cp -r $(CP_FLAGS) lib/* $(PREFIX)/lib/lang	
	cp $(CP_FLAGS) jit.o fcgi.o llvmc.so $(PREFIX)/lib/lang/$(TARGET)/unsafe/
	cp $(CP_FLAGS) dummy.o lang.so lang.bc lang.lh $(PREFIX)/lib/lang/$(TARGET)/trusted/
	cp $(CP_FLAGS) lrt-llvm-$(LRT_VERSION).bc $(PREFIX)/lib/lang/$(TARGET)/
	cp $(CP_FLAGS) lrt-llvm-$(LRT_VERSION).o $(PREFIX)/lib/lang/$(TARGET)/
#	cp $(CP_FLAGS) lang.so $(PREFIX)/lib/lang/$(TARGET)/trusted/


lc.zip: $(INSTALL_OBJS)	
	rm -r /tmp/canned || true
	mkdir /tmp/canned
	$(MAKE) $(MAKEFILE) PREFIX=/tmp/canned install
	rm lc.zip || true
	HERE=`pwd` ; cd /tmp/canned ; zip -r $$HERE/lc.zip .

clean:
	rm $(CLEAN) || true

lc.d:	operation.l syntaxl.l syntaxk.l
	$(LC) $(MODEL) $(LFLAGS) -D -p test -o lc -s llvm main.l

lang.d:
	$(LC) $(MODEL) $(LFLAGS) -D -u lib.l -o lang

include lc.d

include lang.d

lang: lang.bc lang.lh

lang.bc: $(lang_DEPS)
	echo build lang.bc $(LFLAGSBCLIB)
	$(LC) -V -f $(MODEL) $(LFLAGSBCLIB) -u lib.l -o lang

lang.so: $(lang_DEPS)
	echo build lang.so $(LFLAGSSO)
	rm /tmp/lcache-$(PROJECT)/* || true
	$(LC) -V -f $(MODEL) $(LFLAGSSO) -u lib.l -o lang
	mv lang lang.so

lang.lh: lang.bc

lc: $(lc_DEPS) llvmc.o llvmc.so dummy.o
	rm -f lang.lh 2>/dev/null # don't link against any lang.so in current directory
	$(LC) -f $(MODEL) $(LFLAGSEXE) -o lc -s llvm -lllvmc.o -lLLVM-2.8 main.l

# -lLLVMAnalysis -lLLVMArchive -lLLVMBitReader -lLLVMBitWriter -lLLVMCore -lLLVMExecutionEngine -lLLVMipa -lLLVMMC -lLLVMSupport -lLLVMSystem -lLLVMTarget -lLLVMTransformUtils main.l

llvmc.o: llvmc.cpp
	g++ $(MODEL) `llvm-config --cxxflags` -c llvmc.cpp

llvmc.so: llvmc.cpp
	g++ $(MODEL) `llvm-config --cxxflags` -fpic -shared llvmc.cpp -o llvmc.so

dummy.o: dummy.c
	gcc $(MODEL) -c dummy.c

lcbc:	$(lc_DEPS) 
	$(LC) -f $(MODEL) $(LFLAGSBC) -o lcbc -s llvm main.l -o lc

fcgi.o: fcgi.c
	gcc $(MODEL) -c fcgi.c 

jit.o: jit.cpp
	g++ $(MODEL) `llvm-config --cxxflags` -c jit.cpp -o jit.o

lrt-llvm-$(LRT_VERSION).bc: lrt-exception.o lrt-unwind.o lrt-throw.o
	llvm-ld -disable-opt -o lrt-llvm-$(LRT_VERSION) lrt-exception.o lrt-unwind.o lrt-throw.o

lrt-llvm-$(LRT_VERSION).o: lrt-llvm-$(LRT_VERSION).bc
	llc lrt-llvm-$(LRT_VERSION).bc
	gcc -c lrt-llvm-$(LRT_VERSION).s

lrt-exception.o: lrt-exception.c
	$(LLVM_CC) $(MODEL) $(LRT_CFLAGS) -emit-llvm -c lrt-exception.c

lrt-unwind.o: lrt-unwind.c
	$(LLVM_CC) $(MODEL) $(LRT_CFLAGS) -emit-llvm -c lrt-unwind.c

lrt-throw.o: lrt-throw.cpp
	$(LLVM_CXX) $(MODEL) $(LRT_CFLAGS) -emit-llvm -c lrt-throw.cpp

bootstrap:
	rm -r ./bs1 || true
	$(MAKE) clean
	$(MAKE) install PREFIX=./bs1 NOSAFE=1	
	rm -r ./bs2 || true
	$(MAKE) clean
	$(MAKE) install LC=./bs1/bin/lc RUNTIME=./bs1/lib/lang PREFIX=./bs2 NOSAFE=1
	rm -r ./bs3 || true
	$(MAKE) clean
	$(MAKE) install LC=./bs2/bin/lc RUNTIME=./bs2/lib/lang PREFIX=./bs3 NOSAFE=1
	rm -r ./bs4 || true
	$(MAKE) clean
	$(MAKE) install LC=./bs3/bin/lc RUNTIME=./bs3/lib/lang PREFIX=./bs4 NOSAFE=1	
	diff -r bs3 bs4

syntaxl.l: syntax-l.jay skeleton-l
	jay/jay -v syntax-l.jay <skeleton-l >syntaxl.l

syntaxk.l: syntax-k.jay skeleton-k
	jay/jay -v syntax-k.jay <skeleton-k >syntaxk.l

printtermg: printtermg.l
	lc printtermg.l

operation.l: ops printtermg
	./printtermg <ops


