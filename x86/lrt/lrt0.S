.file 1 "lrt0.S"


// default allocator 
#define ALLOC GC_malloc
// non-object array alloc - could potentially be GC_atomic or GC_atomic_ignore_off_page
// if we checked the array type at compile time to make sure it was not a pointer
#define NON_OBJECT_ARRAY_ALLOC ALLOC
#define OBJECT_ARRAY_ALLOC ALLOC
#define OBJECT_ALLOC ALLOC
	
.extern NON_OBJECT_ARRAY_ALLOC
.extern OBJECT_ARRAY_ALLOC
.extern OBJECT_ALLOC
	
.data
.global __data_begin
__data_begin:	
	
.section x_static_begin,"ax"
static$begin:
	pushl %ebp
	movl %esp,%ebp
.section x_static_init,"ax"
	nop
.section x_static_end,"ax"
	pop %ebp
	ret
.text

#.extern exit
#.global __main_init
#__main_init:
#	pushl $0
#	call exit

.global __get_word_size
__get_word_size:
	movl $4,%eax
	ret

.data
__argv:		.int 0
__envp:		.int 0


.global alloca
	
.section .rodata
1:	.ascii "alloca %d bytes...\n"
	.byte 0
.text	

	
# vtable	0 
# length	4
# first cell <- 8
	
# ecx - element count
# edx - element size
alloca:
	pushl %ebx	
	
	movl %ecx,%ebx	# save element count

	imull %edx,%ecx	# total size = element count * element size
	addl $8, %ecx  #              + 4 bytes for vtable + 4 bytes for stored size

	pushl %ecx
	call NON_OBJECT_ARRAY_ALLOC
	addl $4,%esp

	movl $vtable$__Q26System5Array, (%eax) # initialize vtable
	movl %ebx, 4(%eax) # initialize element count
	
	popl %ebx
	ret

.global allocao


#
# vtable	0      
# length	4     
# first cell <- 8

# ecx - element count
allocao:
	pushl %ebx
	
	movl %ecx,%ebx	# save element count

	imull $4,%ecx	# total size = element count * element size
	addl $8,%ecx    #              + 4 bytes for vtable + 4 bytes for stored size

	pushl %ecx
	call OBJECT_ARRAY_ALLOC
	addl $4,%esp
	
	movl $vtable$__Q26System5Array, (%eax) # initialize vtable
	movl %ebx, 4(%eax) # initialize element count
	
	popl %ebx
	ret	
	
	
# .global __install_segv_handler
# __install_segv_handler:
# 	ret

.section  .tbss,"awT",@nobits
__tls1:	         .quad 0
__tls2:	         .quad 0

	

.text

	.global __get_tls1
__get_tls1:
	        movl %gs:__tls1@NTPOFF,%eax
	        ret

	.global __set_tls1
__set_tls1:
	        movl %edx,%gs:__tls1@NTPOFF
	        ret

	.global __get_tls2
__get_tls2:
	        movl %gs:__tls2@NTPOFF,%eax
	        ret

	.global __set_tls2
__set_tls2:
	        movl %edx,%gs:__tls2@NTPOFF
	        ret

	
	

.global __geterrno
.extern __errno_location
__geterrno:
	call __errno_location
	movl (%eax),%eax
	ret

.extern entry$point


.global __get_argv
__get_argv:
	movl __argv, %eax
	ret

.global __get_envp
__get_envp:
	movl __envp, %eax
	ret

# envp        +16
# argv        +12
# argc        +8
# eip         +4
# ebp <--- ebp+0
.global main
main:
	pushl %ebp
	movl %esp,%ebp

	movl 12(%ebp),%eax
        movl %eax,__argv
	movl 16(%ebp),%eax
	movl %eax,__envp

.extern GC_print_stats
.extern GC_disable
.extern GC_init
.extern GC_enable_incremental
	
#	movl $1,GC_print_stats

	call GC_init
#	call GC_enable_incremental

	movl $0,%ebp
	call static$begin

	call entry$point

	pushl $0
	call exit

.data
.global __unwind_start
__unwind_start:
	.int 1f
.section z_backtrace_begin,"a"
1:
.section z_backtrace_info,"a"
.section z_backtrace_end,"a"
	.int 0
	.int 0
	.int 0
	.int 0
	.int 0
	.int 0
.text

.global __get_classes_info
__get_classes_info:
	movl $__class_start,%eax
	retl


	
.section y_classes_begin,"a"
__class_start:	
.section y_classes_info,"a"
.section y_classes_end,"a"
	.int 0
	.int 0

.section z_backtrace_info,"a"
.int __throw_exception
	.int 4f
	.int 3f
	.int 0
	.int 0xFFFFFFFF
	.int 0
.section .rodata
3:	 .asciz "__throw_exception lrt0.S"

.section .text
.global __throw_exception

# ecx - exception object 
__throw_exception:
	pushl %ebp	# set up frame for unwind
	movl %esp,%ebp
	pushl %ebx	# save all callee save registers for unwind:
	pushl %esi
	pushl %edi

	# call __throw($4,%ecx,%ebp,$__throw_exception)
	pushl $__throw_exception	# eip for backtrace
	pushl %ebp			# ebp for unwind
	pushl %ecx			# exception value
	pushl $4			# exception type
	call __throw
4:


.section z_backtrace_info,"a"
	.int __throw_return
	.int 4f
	.int 3f
	.int 0
	.int 0xFFFFFFFF
	.int 0
.section .rodata
3:	 .asciz "__throw_return lrt0.S"

.section .text

# ecx: return value
	
.global __throw_return
__throw_return:
	pushl %ebp	# set up frame for unwind
	movl %esp,%ebp
	pushl %ebx	# save all callee save registers for unwind:
	pushl %esi
	pushl %edi

	# call __throw($3,%edx,%ebp,$__throw_return)	
	pushl $__throw_return		# eip for backtrace
	pushl %ebp			# ebp for unwind
	pushl %ecx			# exception value
	pushl $3			# exception type
	call __throw
4:

.section z_backtrace_info,"a"
	.int __throw_endfinally	
	.int 4f
	.int 3f
	.int 0
	.int 0xFFFFFFFF
	.int 0
.section .rodata
3:	 .asciz "__throw_endfinally lrt0.S"

.section .text


# type: ecx
# exception: edx
	
.global __throw_endfinally
__throw_endfinally:
	pushl %ebp	# set up frame for unwind
	movl %esp,%ebp
	pushl %ebx	# save all callee save registers for unwind:
	pushl %esi
	pushl %edi
	
	# call __throw(%ecx, %edx, %ebp, __throw_endfinally )
	pushl $__throw_endfinally
	pushl %ebp
	pushl %edx
	pushl %ecx
	
	call __throw

4:

.section z_backtrace_info,"a"
	.int __throw_arrayboundsexception
	.int 4f
	.int 3f
	.int 0
	.int 0xFFFFFFFF
	.int 0
.section .rodata
3:	 .asciz "__throw_arrayboundsexception lrt0.S"

.section .text
	
.global __throw_arrayboundsexception
__throw_arrayboundsexception:
	pushl %ebp	# set up frame for unwind
	movl %esp,%ebp
	pushl %ebx	# save all callee save registers for unwind:
	pushl %esi
	pushl %edi

	call __make_arrayboundsexception
	
	# call __throw($4,%eax,%ebp,$__throw_arrayboundsexception)
	pushl $__throw_arrayboundsexception	# eip for backtrace
	pushl %ebp			# ebp for unwind
	pushl %eax			# exception value
	pushl $4			# exception type
	call __throw
	
4:


.section z_backtrace_info,"a"
	.int __throw_castexception
	.int 4f
	.int 3f
	.int 0
	.int 0xFFFFFFFF
	.int 0
.section .rodata
3:	 .asciz "__throw_castexception lrt0.S"

.section .text


	
.global __throw_castexception
__throw_castexception:
	pushl %ebp	# set up frame for unwind
	movl %esp,%ebp
	pushl %ebx	# save all callee save registers for unwind:
	pushl %esi
	pushl %edi

	call __make_castexception
	
	# call __throw($4,%eax,%ebp,$__throw_castexception)
	pushl $__throw_castexception	# eip for backtrace
	pushl %ebp			# ebp for unwind
	pushl %eax			# exception value
	pushl $4			# exception type
	call __throw	

4:

.section z_backtrace_info,"a"
	.int __throw_memoryexception	
	.int 4f
	.int 3f
	.int 0
	.int 0xFFFFFFFF
	.int 0
.section .rodata
3:	 .asciz "__throw_memoryexception lrt0.S"

.section .text


# ecx: exception to throw
# edx: faulting address
	
.global __throw_memoryexception
__throw_memoryexception:
	pushl %edx	# push faulting address as if we were called from it	
	pushl %ebp	# set up frame for unwind
	movl %esp,%ebp
	pushl %ebx	# save all callee save registers for unwind:
	pushl %esi
	pushl %edi
	
	# call __throw($4,%ecx,%ebp,$__throw_memoryexception)
	pushl $__throw_memoryexception	# eip for backtrace
	pushl %ebp			# ebp for unwind
	pushl %ecx			# exception value
	pushl $4			# exception type
	call __throw	

4:	
	
.global __catch_exception

	

# standard Linux C calling convention, all params on stack, right-most pushed first, left-most on stack top
# registers    +20
# handler eip  +16
# exception     +12	param1
# type 	        +8	param0
# return address + 4
# ebp   <--- ebp+0
__catch_exception:
	pushl %ebp		
	movl %esp,%ebp
	movl 20(%ebp),%eax
	pushl 16(%ebp)		# no free registers - put handler address on stack
	movl 12(%ebp),%edx
	movl 8(%ebp),%ecx
	
	movl 0(%eax),%edi
	movl 4(%eax),%esi
	movl 8(%eax),%ebp
	movl 12(%eax),%ebx

	ret			# return to handler (will stuff up cpu return stack but stuffed anyway...)
#	jmp *%eax
