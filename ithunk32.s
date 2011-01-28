
	;  
	; 
	; 
	;
	;
	.text
.globl __ithunk
	.type	__ithunk, @function
__ithunk:
	movl 
        movl    4(%ebp), %eax		; selector id
	movl	8(%ebp), %edx		; pointer to object
	movl	(%edx), %edx		; vtable
	movl	12(%edx), %edx		; selector id -> method mapping table

1:	
	
	cmpl	%eax, (%edx)
	leal	8(%edx), %edx
	jne	1b
	call 	*-4(%edx)
	
	.size	__ithunk, .-__ithunk

