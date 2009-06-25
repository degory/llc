all: x86.l x86rewrite.l

clean:
	rm x86rewrite.l x86.l

x86.l: x86.md
	../lgeng M 4 <x86.md >x86.l

x86rewrite.l: x86.md
	../lgeng R 4 <x86.md >x86rewrite.l
