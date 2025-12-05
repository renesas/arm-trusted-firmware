/*
 * Copyright (c) 2018-2021, Renesas Electronics Corporation. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <arch.h>
#include <asm_macros.S>
#include <console_macros.S>

	.globl	console_scif_register
	.globl	console_scif_init
	.globl	console_scif_putc
	.globl	console_scif_flush

	.extern	rcar_log_init
	.extern	rcar_set_log_data

	/* -----------------------------------------------
	 * int console_scif_register(
	 *      uintptr_t base, uint32_t clk, uint32_t baud,
	 *      console_t *console)
	 * Function to initialize and register a new rcar
	 * console. Storage passed in for the console struct
	 * *must* be persistent (i.e. not from the stack).
	 * In: x0 - UART register base address
	 *     w1 - UART clock in Hz
	 *     w2 - Baud rate
	 *     x3 - pointer to empty console_t struct
	 * Out: return 1 on success, 0 on error
	 * Clobber list : x0, x1, x2, x6, x7, x14
	 * -----------------------------------------------
	 */
func console_scif_register
	mov	x7, x30
	mov	x6, x3
	cbz	x6, register_fail
	str	x0, [x6, #CONSOLE_T_BASE]

	bl	rcar_log_init
	cbz	x0, register_fail

	mov	x0, x6
	mov	x30, x7
	finish_console_register scif, putc=1, getc=0, flush=1

register_fail:
	ret	x7
endfunc console_scif_register

	/* ---------------------------------------------
	 * int console_scif_init(unsigned long base_addr,
	 * unsigned int uart_clk, unsigned int baud_rate)
	 * Function to initialize the console without a
	 * C Runtime to print debug information. This
	 * function will be accessed by crash reporting.
	 * In: x0 - console base address
	 *     w1 - Uart clock in Hz
	 *     w2 - Baud rate
	 * Out: return 1 on success
	 * Clobber list : x1, x2
	 * ---------------------------------------------
	 */
func console_scif_init
	mov	w0, #1
	ret
endfunc console_scif_init

	/* --------------------------------------------------------
	 * int console_scif_putc(int c, console_t *console)
	 * Function to output a character over the console. It
	 * returns the character printed on success or -1 on error.
	 * In : w0 - character to be printed
	 *      x1 - pointer to console_t structure
	 * Out : return -1 on error else return character.
	 * Clobber list : x2
	 * --------------------------------------------------------
	 */
func console_scif_putc
	b	rcar_set_log_data
endfunc console_scif_putc

	/* ---------------------------------------------
	 * void console_scif_flush(void)
	 * Function to force a write of all buffered
	 * data that hasn't been output. It returns void
	 * Clobber list : x0, x1
	 * ---------------------------------------------
	 */
func console_scif_flush
	ret
endfunc console_scif_flush
