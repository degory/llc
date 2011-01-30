
	##  
	## 0(%esp) - old eip
	## 4(%esp) - selector id
	## 8(%esp) - object reference
	##
	## (object) -> vtable
	
	## (vtable) -> super
	## (vtable+4) -> ?
	## (vtable+8) -> dispose
	## (vtable+12) -> interface table

	## itable+0,4	selector id, method address
	## itable+8,12	selector id, method address
	## itable+16,20	selector id, method address
	## ...

	
	.text
.globl __ithunk
	.type	__ithunk, @function
__ithunk:
        movl    4(%esp), %eax		# selector id
	movl	8(%esp), %edx		# pointer to object
	movl	(%edx), %edx		# vtable
	movl	12(%edx), %edx		# selector id -> method mapping table

1:	
	
	cmpl	%eax, (%edx)
	leal	8(%edx), %edx
	jne	1b
	call 	*-4(%edx)
	
	.size	__ithunk, .-__ithunk

