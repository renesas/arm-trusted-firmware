/*
 * Copyright (c) 2015-2025, Renesas Electronics Corporation. All rights reserved.
 * Copyright (c) 2025, Arm Limited. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <arch.h>
#include <asm_macros.S>
#include <console_macros.S>
#include <platform_def.h>

#define SCIF_INTERNAL_CLK	0
#define SCIF_EXTARNAL_CLK	1
#define SCIF_CLK		SCIF_INTERNAL_CLK

/* scif */
#ifdef RCAR_LSI
#define SCIF_SCSMR		(0x00)
#define SCIF_SCBRR		(0x04)
#define SCIF_SCSCR		(0x08)
#define SCIF_SCFTDR		(0x0C)
#define SCIF_SCFSR		(0x10)
#define SCIF_SCFRDR		(0x14)
#define SCIF_SCFCR		(0x18)
#define SCIF_SCFDR		(0x1C)
#define SCIF_SCSPTR		(0x20)
#define SCIF_SCLSR		(0x24)
#define SCIF_DL			(0x30)
#define SCIF_CKS		(0x34)
#else /* RCAR_LSI */
#define SCIF_SCSMR		(0x00)
#define SCIF_SCBRR		(0x02)
#define SCIF_SCMDDR		(0x02)
#define SCIF_SCSCR		(0x04)
#define SCIF_SCFTDR		(0x06)
#define SCIF_SCFSR		(0x08)
#define SCIF_SCFRDR		(0x0A)
#define SCIF_SCFCR		(0x0C)
#define SCIF_SCFDR		(0x0E)
#define SCIF_SCSPTR		(0x10)
#define SCIF_SCLSR		(0x12)
#define SCIF_SEMR		(0x14)
#define SCIF_FTCR		(0x16)
#define SEMR_MDDRS_MDDR 	(0x10)
#define SEMR_BRME_ON		(0x20)
#define SEMR_MDDR		(SEMR_MDDRS_MDDR | SEMR_BRME_ON)
#endif /* RCAR_LSI */

#define SCSMR_CA_MASK		(1 << 7)
#define SCSMR_CA_ASYNC		(0x0000)
#define SCSMR_CHR_MASK		(1 << 6)
#define SCSMR_CHR_8		(0x0000)
#define SCSMR_PE_MASK		(1 << 5)
#define SCSMR_PE_DIS		(0x0000)
#define SCSMR_STOP_MASK		(1 << 3)
#define SCSMR_STOP_1		(0x0000)
#define SCSMR_CKS_MASK		(3 << 0)
#define SCSMR_CKS_DIV1		(0x0000)
#define SCSMR_INIT_DATA		(SCSMR_CA_ASYNC +	\
					 SCSMR_CHR_8 +		\
					 SCSMR_PE_DIS +		\
					 SCSMR_STOP_1 +		\
					 SCSMR_CKS_DIV1)

#define SCSCR_TE_MASK		(1 << 5)
#define SCSCR_TE_DIS		(0x0000)
#define SCSCR_TE_EN		(0x0020)
#define SCSCR_RE_MASK		(1 << 4)
#define SCSCR_RE_DIS		(0x0000)
#define SCSCR_RE_EN		(0x0010)
#define SCSCR_CKE_MASK		(3 << 0)
#define SCSCR_CKE_INT		(0x0000)
#define SCSCR_CKE_BRG		(0x0002)
#if SCIF_CLK == SCIF_EXTARNAL_CLK
#define SCSCR_CKE_INT_CLK	(SCSCR_CKE_BRG)
#else
#define SCFSR_TEND_MASK		(1 << 6)
#define SCFSR_TEND_TRANS_END	(0x0040)
#define SCSCR_CKE_INT_CLK	(SCSCR_CKE_INT)
#endif
#define SCFSR_INIT_DATA		(0x0000)
#define SCFCR_TTRG_MASK		(3 << 4)
#define SCFCR_TTRG_8		(0x0000)
#define SCFCR_TTRG_0		(0x0030)
#define SCFCR_TFRST_MASK	(1 << 2)
#define SCFCR_TFRST_DIS		(0x0000)
#define SCFCR_TFRST_EN		(0x0004)
#define SCFCR_RFRS_MASK		(1 << 1)
#define SCFCR_RFRS_DIS		(0x0000)
#define SCFCR_RFRS_EN		(0x0002)
#define SCFCR_INIT_DATA		(SCFCR_TTRG_8)
#define SCFDR_T_MASK		(0x1f << 8)
#define DL_INIT_DATA		(8)
#define CKS_CKS_DIV_MASK	(1 << 15)
#define CKS_CKS_DIV_CLK		(0x0000)
#define CKS_XIN_MASK		(1 << 14)
#define CKS_XIN_SCIF_CLK	(0x0000)
#define CKS_INIT_DATA		(CKS_CKS_DIV_CLK + CKS_XIN_SCIF_CLK)

	.globl	console_scif_init
	.globl	console_scif_putc
	.globl	console_scif_flush

	/*
	 * int console_scif_init(unsigned long base_addr,
	 * unsigned int uart_clk, unsigned int baud_rate)
	 * Function to initialize the console without a
	 * C Runtime to print debug information. This
	 * function will be accessed by console_scif_register
	 * and crash reporting.
	 * In: x0 - console base address
	 *     w1 - Uart clock in Hz
	 *     w2 - Baud rate
	 * Out: return 1 on success
	 * Clobber list : x1, x2, x3, x4
	 */
func console_scif_init
	/* Clear bits TE and RE in SCSCR to 0 */
	mov	w3, #(SCSCR_TE_DIS + SCSCR_RE_DIS)
	strh	w3, [x0, #SCIF_SCSCR]
	/* Set bits TFRST and RFRST in SCFCR to 1 */
	ldrh	w3, [x0, #SCIF_SCFCR]
	orr	w3, w3, #(SCFCR_TFRST_EN + SCFCR_RFRS_EN)
	strh	w3, [x0, #SCIF_SCFCR]
	/*
	 * Read flags of ER, DR, BRK, and RDF in SCFSR and those of TO and ORER
	 * in SCLSR, then clear them to 0
	 */
	mov	w3, #SCFSR_INIT_DATA
	strh	w3, [x0, #SCIF_SCFSR]
	mov	w3, #0
	strh	w3, [x0, #SCIF_SCLSR]
	/* Set bits CKE[1:0] in SCSCR */
	ldrh	w3, [x0, #SCIF_SCSCR]
	and	w3, w3, #~SCSCR_CKE_MASK
	mov	w4, #SCSCR_CKE_INT_CLK
	orr	w3, w3, w4
	strh	w3, [x0, #SCIF_SCSCR]
	/* Set data transfer format in SCSMR */
	mov	w3, #SCSMR_INIT_DATA
	strh	w3, [x0, #SCIF_SCSMR]
	/* Set value in SCBRR */
#if SCIF_CLK == SCIF_INTERNAL_CLK
	udiv	w3, w1, w2	/* w3 = uart clock in Hz / baud rate */
	lsr	w3, w3, #5	/* w3 = w3 / 32 */
	sub	w3, w3, #1	/* w3 -= 1 */
	strb	w3, [x0, #SCIF_SCBRR]
#if RZA3
	/* Set value in MDDR and SEMR */
	add	x3, x3, #1	/* brr += 1 */
	lsl	x3, x3, #13	/* brr = brr * 8192 */
	mul	x3, x3, x2	/* brr = brr * baud rate */
	udiv	x3, x3, x1	/* mddr = brr / uart clock in Hz */
	mov	w1, #(SEMR_MDDR)
	strb	w1, [x0, #SCIF_SEMR]
	strb	w3, [x0, #SCIF_SCMDDR]
#endif /* RZA3 */
#else /* SCIF_CLK == SCIF_INTERNAL_CLK */
	mov	w1, #DL_INIT_DATA
	strh	w1, [x0, #SCIF_DL]
	mov	w1, #CKS_INIT_DATA
	strh	w1, [x0, #SCIF_CKS]
#endif
	/* 1-bit interval elapsed */
	mov	w1, #100
1:
	subs	w1, w1, #1
	cbnz	w1, 1b
	/*
	 * Set bits RTRG[1:0], TTRG[1:0], and MCE in SCFCR
	 * Clear bits FRST and RFRST to 0
	 */
	mov	w1, #SCFCR_INIT_DATA
	strh	w1, [x0, #SCIF_SCFCR]
	/* Set bits TE and RE in SCSCR to 1 */
	ldrh	w1, [x0, #SCIF_SCSCR]
	orr	w1, w1, #(SCSCR_TE_EN + SCSCR_RE_EN)
	strh	w1, [x0, #SCIF_SCSCR]
	mov	x0, #1

	ret
endfunc console_scif_init

	/*
	 * int console_scif_putc(int c, unsigned int base_addr)
	 * Function to output a character over the console. It
	 * returns the character printed on success or -1 on error.
	 * In : w0 - character to be printed
	 *      x1 - pointer to console_t structure
	 * Out : return -1 on error else return character.
	 * Clobber list : x2
	 */
func console_scif_putc
	ldr	x1, [x1, #CONSOLE_T_BASE]
	cmp	w0, #0xA
	/* Prepend '\r' to '\n' */
	bne	2f
1:
	/* Check if the transmit FIFO is full */
	ldrh	w2, [x1, #SCIF_SCFDR]
	ubfx	w2, w2, #8, #5
	cmp	w2, #16
	bcs	1b
	mov	w2, #0x0D
	strb	w2, [x1, #SCIF_SCFTDR]
2:
	/* Check if the transmit FIFO is full */
	ldrh	w2, [x1, #SCIF_SCFDR]
	ubfx	w2, w2, #8, #5
	cmp	w2, #16
	bcs	2b
	strb	w0, [x1, #SCIF_SCFTDR]

	/* Clear TEND flag */
	ldrh	w2, [x1, #SCIF_SCFSR]
	and	w2, w2, #~SCFSR_TEND_MASK
	strh	w2, [x1, #SCIF_SCFSR]

	ret
endfunc console_scif_putc

	/*
	 * void console_scif_flush(void)
	 * Function to force a write of all buffered
	 * data that hasn't been output. It returns void
	 * Clobber list : x0, x1
	 */
func console_scif_flush
	ldr	x0, [x0, #CONSOLE_T_BASE]
1:
	/* Check TEND flag */
	ldrh	w1, [x0, #SCIF_SCFSR]
	and	w1, w1, #SCFSR_TEND_MASK
	cmp	w1, #SCFSR_TEND_TRANS_END
	bne	1b

	ldrh	w1, [x0, #SCIF_SCSCR]
	and	w1, w1, #~(SCSCR_TE_EN + SCSCR_RE_EN)
	strh	w1, [x0, #SCIF_SCSCR]

	ret
endfunc console_scif_flush
