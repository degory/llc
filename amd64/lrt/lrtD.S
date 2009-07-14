.file 1 "lrtD.S"
	
.data
.global __data_begin
__data_begin:	
	
.section x_static_begin,"ax"
static$begin:
	pushq %rbp
	movq %rsp,%rbp
.section x_static_init,"ax"
	nop
.section x_static_end,"ax"
	popq %rbp
	ret
.text

_init:
	call static$begin
	ret
	
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

.section y_classes_begin,"a"
	.global __class_start
__class_start:
.section y_classes_info,"a"
.section y_classes_end,"a"
	.quad 0
	.quad 0

.section .text

	
	