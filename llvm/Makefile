all: amd64.l amd64rewrite.l

clean:
	rm amd64rewrite.l amd64.l

amd64.l: amd64.md
	../lgeng M 8 <amd64.md >amd64.l

amd64rewrite.l: amd64.md
	../lgeng R 8 <amd64.md >amd64rewrite.l
