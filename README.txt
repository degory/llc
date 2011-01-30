
L Compiler build requirements:
- Create target file to describe locations of LLVM GCC, regular GCC etc
- LLVM GCC installed (apt-get llvm-gcc-4.2)
- L compiler binaries installed (unzip lc.zip into /usr)
- LLVM 2.8 is installed and executables are on path (apt-get llvm-2.8)
- llvm-ld located in exactly /usr/local/bin/llvm
- libLLVM-2.8.so must be on library path 
- FCGI library and headers installed (apt-get libfcgi, libfcgi-dev)
- Boehm GC installed (apt-get libgc, libgc-dev)
- Bundled version of jay compiled (cd jay; make)
- Check Makefile for various shell variables that affect what runtime, compiler, options etc. are used when building
- Create temporary directories for bitcode/object file caches (/tmp/lcache, /tmp/lcache-test)
- Run 'make' to build lc executable
- Run 'make lc.zip' to build canned installation including runtime library and compiler executable
- Run 'make bootstrap' to check compiler can safely build itself

