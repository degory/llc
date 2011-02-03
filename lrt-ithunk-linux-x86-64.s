
	##  
	## %rdi selector id
	## %rsi object reference
	##
	## (object) -> vtable
	
	## (vtable) -> super
	## (vtable+8) -> ?
	## (vtable+16) -> ?
	## (vtable+24) -> dispose
	## (vtable+32) -> interface table

	## itable+0,8	selector id, method address
	## itable+16,24	selector id, method address
	## itable+32,40	selector id, method address
	## ...

	
	.text
.globl __ithunk
	.type	__ithunk, @function
__ithunk:
	pushq   %rbp
	movq    %rsp,%rbp
        movq    %rsi, %r10		# object reference
	movq	(%r10), %r10		# vtable
	movq	32(%r10), %r10		# selector id -> method mapping table

1:	
	
	cmpq	%rdi, (%r10)
	leaq	16(%r10), %r10
	jne	1b

	popq	%rbp
	jmp 	*-8(%r10)
	
	.size	__ithunk, .-__ithunk

