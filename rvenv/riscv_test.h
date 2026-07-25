#ifndef _ENV_BARE_RV32_H

#define _ENV_BARE_RV32_H

#define RVTEST_RV32U
#define RVTEST_RV32M
#define RVTEST_RV64U
#define RVTEST_RV64M
#define RVTEST_FP_ENABLE
#define RVTEST_VEC_ENABLE
#define TESTNUM gp
#define RVTEST_CODE_BEGIN                    \
	.section .text.init;                 \
	.align 6;                            \
	.globl _start;                       \
_start:                                      \
	li gp, 0;

#define RVTEST_CODE_END                      \

#define RVTEST_PASS                          \
	li gp, 1;                            \
pass_loop:                                   \
	j pass_loop;

#define RVTEST_FAIL                          \
fail_loop:                                   \
	j fail_loop;

#define EXTRA_DATA

#define RVTEST_DATA_BEGIN                    \
	EXTRA_DATA                           \
	.align 4;                            \
	.global begin_signature; begin_signature:

#define RVTEST_DATA_END                      \
	.align 4;                            \
	.global end_signature; end_signature:

#endif
