#
# Copyright (c) 2021-2025, Renesas Electronics Corporation. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

PLAT_INCLUDES		+=	-Iplat/renesas/rza/soc/rza3ul/include

ifneq (${USE_SDRAM},0)
DDR_SOURCES		+=	plat/renesas/rza/soc/rza3ul/drivers/ddr/ddr_a3ul.c \
				plat/renesas/rza/soc/rza3ul/drivers/ddr/param_mc_C-011_D4-01-2.c \
				drivers/renesas/rza/ddr/param_swizzle_T3bcud2.c
DDR_PLL4		?=	1600
$(eval $(call add_define,DDR_PLL4))
endif

BL2_SOURCES		+=	${DDR_SOURCES}

RZA3			:=	1
RZA3UL			:=	1
DEVICE_TYPE		:=	1
ARCH_TYPE		:=	ARMv8A
LOG_LEVEL		:=	10
ifeq (${SOC_TYPE},2)
DEVICE_TYPE		:=	2
endif
RZ_XSPI_MEMORY_BASE	:=	0x20000000

$(eval $(call add_define,RZA3))
$(eval $(call add_define,RZA3UL))
$(eval $(call add_define,DEVICE_TYPE))
$(eval $(call add_define,ARCH_TYPE))
$(eval $(call add_define,RZ_XSPI_MEMORY_BASE))
