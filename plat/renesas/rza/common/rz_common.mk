#
# Copyright (c) 2021-2025, Renesas Electronics Corporation. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

RESET_TO_BL2				:= 1
COLD_BOOT_SINGLE_CPU			:= 1
PROGRAMMABLE_RESET_ADDRESS		:= 1
WARMBOOT_ENABLE_DCACHE_EARLY		:= 1
GICV3_SUPPORT_GIC600			:= 1
HW_ASSISTED_COHERENCY			:= 1
USE_COHERENT_MEM			:= 0
TRUSTED_BOARD_BOOT			:= 0
PROTECTED_CHIPID			:= 1
EARLY_CONSOLE 				:= 1
$(eval $(call add_define,PROTECTED_CHIPID))

WA_PLAT_GIC64BIT			:= 1
$(eval $(call add_define,WA_PLAT_GIC64BIT))

USE_SDRAM				?= 1
USE_SPI_NOR				?= 0
$(eval $(call assert_booleans,\
	$(sort \
		USE_SDRAM \
		USE_SPI_NOR \
)))

$(eval $(call add_defines,\
	$(sort \
		USE_SDRAM \
		USE_SPI_NOR \
)))

ifeq (${USE_SPI_NOR},1)
$(eval $(call assert_numeric,RZ_FLASH_SIZE))
$(eval $(call add_define,RZ_FLASH_SIZE))
endif

# Enable workarounds for selected Cortex-A55 erratas.
ERRATA_A55_1530923	:= 1

ifeq (${APPLOAD},RZ_NOFIP)
FSP_BASE		?= 0x20020000
$(eval $(call add_define,FSP_BASE))
endif

PLAT_INCLUDES		+=	-Iplat/renesas/rza/common/include \
				-Idrivers/renesas/common/io \
				-Idrivers/renesas/common/scif

ifeq (${USE_SDRAM},1)
DDR_SOURCES		:= 	drivers/renesas/rza/ddr/ddr.c
endif

ifeq (${USE_SPI_NOR},1)
BL2_SOURCES		+=	drivers/renesas/common/rpc/rpc_driver.c
endif

BL2_SOURCES		+=	lib/cpus/aarch64/cortex_a55.S				\
				common/desc_image_load.c				\
				drivers/arm/tzc/tzc400.c				\
				drivers/delay_timer/delay_timer.c			\
				drivers/delay_timer/generic_delay_timer.c		\
				drivers/io/io_storage.c					\
				drivers/io/io_memmap.c					\
				drivers/io/io_fip.c					\
				drivers/renesas/common/syc/syc.c			\
				drivers/renesas/rza/pfc/pfc.c				\
				drivers/renesas/rza/cpg/cpg.c				\
				drivers/renesas/common/scif/scif.S			\
				drivers/renesas/common/scif/scif_helpers.S		\
				plat/renesas/rza/common/bl2_plat_setup.c		\
				plat/renesas/rza/common/bl2_plat_mem_params_desc.c	\
				plat/renesas/rza/common/plat_image_load.c		\
				plat/renesas/rza/common/plat_early_setup.S		\
				plat/renesas/rza/common/plat_storage.c			\
				plat/renesas/rza/common/plat_security.c			\
				plat/renesas/rza/common/aarch64/plat_helpers.S		\

include lib/xlat_tables_v2/xlat_tables.mk
PLAT_BL_COMMON_SOURCES	+=	${XLAT_TABLES_LIB_SRCS}				\
				plat/renesas/rza/common/rz_common.c

ifneq (${TRUSTED_BOARD_BOOT},0)
# Include common TBB sources
AUTH_SOURCES		:=	drivers/auth/img_parser_mod.c

# Include the selected chain of trust sources.
ifeq (${COT},tbbr)
AUTH_SOURCES		+=	drivers/renesas/rza/auth/tbbr/tbbr_cot.c
else
$(error Unknown chain of trust ${COT})
endif

# Include RZ TBB sources
AUTH_SOURCES		+=	drivers/renesas/rza/auth/auth_mod.c		\
				drivers/renesas/rza/auth/sblib/crypto_sblib.c	\
				drivers/renesas/rza/auth/sblib/sblib_parser.c
BL2_SOURCES		+=	${AUTH_SOURCES}
endif
