install: llvm-ld
	cp llvm-ld /usr/local/bin

llvm-ld: llvm-ld.cpp Optimize.cpp
	g++ `llvm-config --cxxflags` -o llvm-ld llvm-ld.cpp Optimize.cpp -lLLVM-2.8