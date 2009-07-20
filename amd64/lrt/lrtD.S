.file 1 "lrtD.S"
	
.data
.global __data_begin
__data_begin:

.text
 .global _init
 _init:
	push %rbp
	movq %rsp,%rbp
	
	pushq %rbx
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	
	leaq 2f(%rip),%rdi
	call __add_unwind_info@PLT
	call __static_begin

	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbx
	
	popq %rbp
	ret
	
.section x_static_begin,"ax"
// .global static$begin
__static_begin:	
// static$begin:
	pushq %rbp
	movq %rsp,%rbp
.section x_static_init,"ax"
	nop
.section x_static_end,"ax"
	popq %rbp
	ret
.text

.data
// .global __unwind_start

// __unwind_start:
2:	.quad 1f
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

.section y_classes_begin,"a"
	.global __class_start
__class_start:
.section y_classes_info,"a"
.section y_classes_end,"a"
	.quad 0
	.quad 0

.section .text

	
	