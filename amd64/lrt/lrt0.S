.file 1 "lrt0.S"


// default allocator 
#define ALLOC GC_malloc
// #define ALLOC GC_malloc
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
.global __static_begin
__static_begin:
	pushq %rbp
	movq %rsp,%rbp
.section x_static_init,"ax"
	nop
.section x_static_end,"ax"
	popq %rbp
	ret
.text


# cstring/result	36
# return address	32
# ebp			28
# eax			24
# ebx			20
# ecx			16
# edx			12
# esi			8
# edi			4
# flags			0

# saved reg                12
# return address	    8
# pushed return address     4
# pushed reg		<-- 0


# param 1                  40
# param 2		   32
# return		   24
# saved rax		   16
# saved rdx		    8
# saved rcx		<-- 0

	.globl __exception_top
	.section        .tbss,"awT",@nobits
	.align 8
	.type   __exception_top, @object
	.size   __exception_top, 8
__exception_top:
	.zero   8
	.globl __exception_rsp
	.align 8
	.type   __exception_rsp, @object
	.size   __exception_rsp, 8
__exception_rsp:
	.zero   8

	.text

.global divide

1:	.ascii "dividing %d into %d\n"
	.byte 0
2:	.ascii "result %d %d\n"
	.byte 0
	
divide:
	pushq %rax
	pushq %rdx
	pushq %rcx

	movq 40(%rsp),%rax
	cqo
	movq 32(%rsp),%rcx
	idivq %rcx
	movq %rax,32(%rsp)
	movq %rdx,40(%rsp)

	popq %rcx
	popq %rdx
	popq %rax
	ret
	
#.global __show_save
#__show_save:
#	pushd 0(%rsp)
#	pushq %rax
#	lea 12(%rsp),%rax
#	pushl %rax
#	call __show_save2
#	addq $12,%rsp
#	ret
#

.global __get_word_size
__get_word_size:
	        movl $8,%eax
	        ret
	
	
.section .rodata
1:	.ascii "saving %x\n"
	.byte 0

.section  .tbss,"awT",@nobits
__tls1:		.quad 0
__tls2:		.quad 0

.text

.global __get_tls1
__get_tls1:
	movq %fs:__tls1@TPOFF,%rax
	retq

.global __set_tls1
__set_tls1:
	movq %rdi,%fs:__tls1@TPOFF
	retq

.global __get_tls2	
__get_tls2:
	movq %fs:__tls2@TPOFF,%rax
	retq

.global __set_tls2	
__set_tls2:
	movq %rdi,%fs:__tls2@TPOFF
	retq

.data
__argv:		.quad 0
__envp:		.quad 0


.global exception$top

#.section .tbss,"awT",@nobits
#.align 4
#	        .type   exception$top, @object
#	        .size   exception$top, 8
exception$top:	.zero 8


.global alloca
	
.section .rodata
1:	.ascii "alloca %d bytes...\n"
	.byte 0
.text	

// FIXME: this looks nice but I think having all these jump targets probably in one cache line might thrash
// the branch target cache?
	
.global __proc_thunk5
__proc_thunk5:
	mov %r8, %r9

.global __proc_thunk4
__proc_thunk4:
	mov %rcx,%r8

.global __proc_thunk3
__proc_thunk3:
	mov %rdx,%rcx
	
.global __proc_thunk2
__proc_thunk2:
	mov %rsi,%rdx	   # shift param #1 -> param #2
	
.global __proc_thunk1
__proc_thunk1:
	mov %rdi,%rsi      # shift param #0 -> param #1
	
.global __proc_thunk0
__proc_thunk0:
	mov 16(%rax),%rdi   # shift this -> param #0
	jmp *24(%rax)

# rdi = element size
# rsi = element count
# rdx = vtable

.global allocag
allocag:
	pushq %r12	
	pushq %rbx
	movq %rdi,%r12	# save element count
	movq %rdx,%rbx
	imulq %rsi,%rdi	# total size = element count * element size
	addq $16, %rdi  #              + 8 bytes for vtable + 8 bytes for stored size

	call NON_OBJECT_ARRAY_ALLOC

	movq %rbx, (%rax)  # initialize vtable
	movq %r12, 8(%rax) # initialize element count
	
	popq %rbx
	popq %r12
	ret

.global allocao
	
# vtable	0 
# length	8 
# first cell <- 16

# rdi - element count
# rsi - element size
#alloca:
#	pushq %r12	
#	
#	movq %rdi,%r12	# save element count
#
#	imulq %rsi,%rdi	# total size = element count * element size
#	addq $16, %rdi  #              + 8 bytes for vtable + 8 bytes for stored size
#
#	call NON_OBJECT_ARRAY_ALLOC
#
#	mov %rax, %rcx  # save pointer to allocated array
#
#	call __get_vtable__Q26System5Array
#	movq %rax, (%rcx)  # initialize vtable
#	movq %r12, 8(%rcx) # initialize element count
#	
#	movq %rcx,%rax
#	popq %r12
#	ret
#
#.global allocao


#
# vtable	0      
# length	4     
# first cell <- 8     
#allocao:
#	pushq %r12	
#	
#	movq %rdi,%r12	# save element count
#
#	imulq $8,%rdi	# total size = element count * element size
#	addq $16,%rdi   #              + 8 bytes for vtable + 8 bytes for stored size
#	call OBJECT_ARRAY_ALLOC
	
#	mov %rax, %rcx  # save pointer to allocated array

#	call __get_vtable__Q26System5Array
#	movq %rax, (%rcx)  # initialize vtable
#	movq %r12, 8(%rcx) # initialize element count
	
#	movq %rcx,%rax
#	popq %r12
#	ret	
	

	
# size      	rdi

.global alloco
alloco:
	pushq %rbp
	movq %rsp, %rbp

	call OBJECT_ALLOC

	popq %rbp
	ret


# .global __install_segv_handler
# __install_segv_handler:
# 	ret


	
	

.global __geterrno
.extern __errno_location
__geterrno:
	call __errno_location
	movq (%rax),%rax
	ret

.extern __entry_point


.global __get_argv
__get_argv:
	movq __argv, %rax
	ret

.global __get_envp
__get_envp:
	movq __envp, %rax
	ret

.global main
main:
	pushq %rbp
	movq $0,%rbp

        movq %rsi,__argv
	movq %rdx,__envp

.extern GC_print_stats
.extern GC_disable
.extern GC_init
.extern GC_parallel
.extern GC_enable_incremental
.extern __install_segv_handler
	call __install_segv_handler
	
	
#	movl $1,GC_print_stats
#	movl $1,GC_parallel
#	call GC_init

#	call GC_enable_incremental

		
	call __static_begin

	call __entry_point

	mov $0, %edi
	call exit

.data
.global __unwind_start
__unwind_start:
	.quad 1f
.section z_backtrace_begin,"a"
1:
.section z_backtrace_info,"a"
.section z_backtrace_end,"a"
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
.text

.global __get_classes_info
__get_classes_info:
	movq $__class_start,%rax
	retq

.section y_classes_begin,"a"
	.global __class_start
__class_start:
.section y_classes_info,"a"
.section y_classes_end,"a"
	.quad 0
	.quad 0

.section z_backtrace_info,"a"
	.quad __throw_memoryexception
	.quad 4f-__throw_memoryexception
	.quad 3f
	.quad 0
	.quad 0xFFFFFFFFFFFFFFFF
	.quad 0
.section .rodata
3:	 .asciz "__throw_memoryexception lrt0.S"

.section .text
.global __throw_memoryexception
__throw_memoryexception:
	# restore registers as if we were called from the faulting instruction using
	# the saved register state passed to the SEGV signal handler:
	/*
	mov 80(%rsi),%rbp
	mov 88(%rsi),%rbx
	mov 32(%rsi),%r12
	mov 40(%rsi),%r13
	mov 48(%rsi),%r14
	mov 56(%rsi),%r15


	mov 120(%rsi),%rsp	# restore stack pointer
	*/
	// mov 128(%rsi),%rax	# faulting rip	
	# push return address on the stack as if called from faulting instruction:
	pushq %rdi

5:	
	# regular method prolog storing all callee save registers at standard offsets
	# so unwind code will restore the fault site state:
	pushq %rbp
	movq %rsp,%rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	# stack is stable - re-enable GC
	# call GC_enable

	# let the unwind code know where it's called from:
	mov $__throw_memoryexception,%rax	
	mov %rax,%rcx
	mov %rbp,%rdx

	# 4 = THROW_EXCEPTION
	mov $4,%rdi
	call __throw
4:	

.section z_backtrace_info,"a"
	.quad __throw_exception
	.quad 4f-__throw_exception
	.quad 3f	
	.quad 0
	.quad 0xFFFFFFFFFFFFFFFF
	.quad 0
.section .rodata
3:	 .asciz "__throw_exception lrt0.S"

.section .text
.global __throw_exception
__throw_exception:
	pushq %rbp
	movq %rsp,%rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	mov $__throw_exception,%eax
	mov %rax,%rcx
	mov %rbp,%rdx
	mov %rdi,%rsi
	mov $4,%rdi
	jmp __throw
4:


.section z_backtrace_info,"a"
	.quad __throw_return
	.quad 4f-__throw_return
	.quad 3f
	.quad 0
	.quad 0xFFFFFFFFFFFFFFFF
	.quad 0
.section .rodata
3:	 .asciz "__throw_return lrt0.S"

.section .text

# rdi: return value
	
.global __throw_return
__throw_return:
	pushq %rbp
	movq %rsp,%rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	mov $__throw_return,%eax
	mov %rax,%rcx
	mov %rbp,%rdx
	mov %rdi,%rsi
	mov $3,%rdi
	jmp __throw
4:


.section z_backtrace_info,"a"
	.quad __throw_endcatch
	.quad 4f-__throw_endcatch
	.quad 3f
	.quad 0
	.quad 0xFFFFFFFFFFFFFFFF
	.quad 0
	.section .rodata
3:	 .asciz "__throw_endcatch lrt0.S"

.section .text

.global __throw_endcatch
__throw_endcatch:
	pushq %rbp
	movq %rsp,%rbp
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

# call __throw( type, e, rbp, rip )	
	mov $__throw_endcatch,%eax
	mov %rax,%rcx   # rip
	mov %rbp,%rdx   # rbp
	mov $5,%rdi	# 
	mov $0,%rsi	# 

	jmp __throw
4:


.section z_backtrace_info,"a"
	.quad __throw_endfinally
	.quad 4f-__throw_endfinally
	.quad 3f
	.quad 0
	.quad 0xFFFFFFFFFFFFFFFF
	.quad 0
	.section .rodata
3:	 .asciz "__throw_endfinally lrt0.S"

.section .text


# type: rsi
# exception: rdi
	
.global __throw_endfinally
__throw_endfinally:
	pushq %rbp
	movq %rsp,%rbp

	cmpq $6,%rdi	# stop?
	je 5f
	
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

# call __throw( type, e, rbp, rip )	
	mov $__throw_endfinally,%eax
	mov %rax,%rcx   # rip
	mov %rbp,%rdx   # rbp
	# rdi already holds type
	# rsi already holds exception
	jmp __throw
5:	popq %rbp
	ret

4:

.section z_backtrace_info,"a"
	.quad __throw_endfinally
	.quad 4f-__throw_endfinally
	.quad 3f
	.quad 0
	.quad 0xFFFFFFFFFFFFFFFF
	.quad 0
	
.section .rodata
3:	 .asciz "__throw_endtry lrt0.S"

.section .text


# type: rsi
# exception: rdi
	
.global __throw_endtry
__throw_endtry:	
	pushq %rbp
	movq %rsp,%rbp

	cmpq $3,%rdi	# return?
	je 5f
	
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

# call __throw( type, e, rbp, rip )	
	mov $__throw_endfinally,%eax
	mov %rax,%rcx   # rip
	mov %rbp,%rdx   # rbp
	# rdi already holds type
	# rsi already holds exception
	jmp __throw
5:	movq %rsi,%rax
	popq %rbp
	ret

4:

.section z_backtrace_info,"a"
	.quad __throw_arrayboundsexception
	.quad 4f-__throw_arrayboundsexception
	.quad 3f
	.quad 0
	.quad 0xFFFFFFFFFFFFFFFF
	.quad 0
.section .rodata
3:	 .asciz "__throw_arrayboundsexception lrt0.S"

.section .text
	
.global __throw_arrayboundsexception
__throw_arrayboundsexception:	
	pushq %rbp
	movq %rsp,%rbp
	
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	call __make_arrayboundsexception
	movq %rax,%rsi

# call __throw( type, e, rbp, rip )	
	mov $__throw_arrayboundsexception,%eax
	mov %rax,%rcx   # rip
	mov %rbp,%rdx   # rbp
	mov $4, %rdi
	# rsi already holds exception
	jmp __throw
5:	movq %rsi,%rax
	popq %rbp
	ret

4:


.section z_backtrace_info,"a"
	.quad __throw_castexception
	.quad 4f-__throw_castexception
	.quad 3f
	.quad 0	
	.quad 0xFFFFFFFFFFFFFFFF
	.quad 0
.section .rodata
3:	 .asciz "__throw_castexception lrt0.S"

.section .text

	
.global __throw_castexception
__throw_castexception:	
	pushq %rbp
	movq %rsp,%rbp
	
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	call __make_castexception
	movq %rax,%rsi

# call __throw( type, e, rbp, rip )	
	mov $__throw_castexception,%eax
	mov %rax,%rcx   # rip
	mov %rbp,%rdx   # rbp
	mov $4, %rdi
	# rsi already holds exception
	jmp __throw
5:	movq %rsi,%rax
	popq %rbp
	ret

4:
	
.global __catch_exception
	
# rdi: exception
# rsi: type
# rdx: rip
# rcx: regs
__catch_exception:	
	mov 80(%rcx),%rbp
	mov 88(%rcx),%rbx
	mov 32(%rcx),%r12
	mov 40(%rcx),%r13
	mov 48(%rcx),%r14
	mov 56(%rcx),%r15
	mov %rsi,%rax	# for throw return
	jmp *%rdx

.global __segv_test
__segv_test:
	call __install_segv_handler
	
	mov $0x1111111111111111,%rax
	mov %rax,%rbx
	mov $0x2222222222222222,%rax
	mov %rax,%rcx
	mov $0x3333333333333333,%rax
	mov %rax,%rdx
	mov $0x4444444444444444,%rax
	mov %rax,%rsi
	mov $0x5555555555555555,%rax
	mov %rax,%rdi
	mov $0x6666666666666666,%rax
	mov %rax,%rbp
	mov $0x8888888888888888,%rax
	mov %rax,%r8
	mov $0x9999999999999999,%rax
	mov %rax,%r9
	mov $0xAAAAAAAAAAAAAAAA,%rax
	mov %rax,%r10
	mov $0xBBBBBBBBBBBBBBBB,%rax
	mov %rax,%r11
	mov $0xCCCCCCCCCCCCCCCC,%rax
	mov %rax,%r12
	mov $0xDDDDDDDDDDDDDDDD,%rax
	mov %rax,%r13
	mov $0xEEEEEEEEEEEEEEEE,%rax
	mov %rax,%r14
	mov $0xFFFFFFFFFFFFFFFF,%rax
	mov %rax,%r15

	mov $0,%rax
	mov %rax,0(%rax)

.data
__in_profiler:	.int	0
	
# caller address is in %rax
	
.global __prof_enter
__prof_enter:
	cmpb $0,__in_profiler
	jnz  1f
	movb $1,__in_profiler
	# called immediately after method entry so only additional register we need to save are those that
	# could hold parameters:
	push %rdi
	push %rsi
	push %rdx
	push %rcx
	push %r8
	push %r9
	mov %rax, %rdi
	call enter__Q24Util8Profilerl
	pop %r9
	pop %r8
	pop %rcx
	pop %rdx
	pop %rsi
	pop %rdi
	movb $0,__in_profiler
1:	
	ret

# caller address is in %rdi
	
.global __prof_exit
__prof_exit:
	cmpb $0,__in_profiler
	jnz  1f
	movb $1,__in_profiler
	# called immediately before method return so only additional register we need to preserve
	# here is return value in %rax
	push %rax	# 56
	# caller address already in %rdi
	call exit__Q24Util8Profilerl
	pop %rax
	movb $0,__in_profiler
1:
	ret

.global __prof_stop
__prof_stop:	
	movb $1,__in_profiler
	ret

.weak enter__Q24Util8Profilerl
enter__Q24Util8Profilerl:
	ret
	
.weak exit__Q24Util8Profilerl
exit__Q24Util8Profilerl:
	ret

.weak clock_gettime
clock_gettime:
	mov $0,%rax
	ret
	
	