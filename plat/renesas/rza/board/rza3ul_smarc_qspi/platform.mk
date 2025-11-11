#
# Copyright (c) 2021-2025, Renesas Electronics Corporation. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

BOARD		:=	rza3ul_smarc_qspi

APPLOAD		?=	RZ_NOFIP
$(eval $(call add_define,APPLOAD))

USE_SRAM	:=	1
USE_SPI_NOR	:=	1
RZ_FLASH_SIZE	:=	16777216 # 16MB

include plat/renesas/rza/common/rz_common.mk
include plat/renesas/rza/soc/rza3ul/soc.mk

# set file name
RZ_ELF		:=	$(BUILD_PLAT)/$(BOARD)_ipl.elf
BL2_ELF		:=	$(BUILD_PLAT)/bl2/bl2.elf
RZ_BIN		:=	$(BUILD_PLAT)/$(BOARD)_ipl.bin
BL2_BIN		:=	$(BUILD_PLAT)/bl2.bin
RZ_MAP		:=	$(BUILD_PLAT)/$(BOARD)_ipl.map
BL2_MAP		:=	$(BUILD_PLAT)/bl2/bl2.map
RZ_DUMP		:=	$(BUILD_PLAT)/$(BOARD)_ipl.dump
BL2_DUMP	:=	$(BUILD_PLAT)/bl2/bl2.dump
RZ_SREC		:=	$(BUILD_PLAT)/$(BOARD)_ipl.srec

bl2: $(RZ_ELF) $(RZ_BIN) $(RZ_LINKER) $(RZ_MAP) $(RZ_DUMP) $(RZ_SREC)

$(RZ_ELF): $(BL2_ELF)
	$(call SHELL_COPY,$<,$@)

$(RZ_BIN): $(BL2_BIN)
	@echo "  IMG     $@"
	$(Q)/usr/bin/perl ./tools/renesas/rza/rza3ul/rz_image.pl "$<" "$@"

$(BL2_MAP): $(BL2_ELF)
$(RZ_MAP): $(BL2_MAP)
	$(call SHELL_COPY,$<,$@)

$(RZ_DUMP): $(BL2_DUMP)
	$(call SHELL_COPY,$<,$@)

$(RZ_SREC): $(RZ_BIN)
	@echo "  SREC    $@"
	$(q)$($(ARCH)-oc) -I binary -O srec --adjust-vma=0x20000000 --srec-forceS3 "$<" "$@"
