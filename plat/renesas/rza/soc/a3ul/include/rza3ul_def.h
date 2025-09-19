/*
 * Copyright (c) 2020-2025, Renesas Electronics Corporation. All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifndef __RZA3UL_DEF_H__
#define __RZA3UL_DEF_H__

#define PLAT_BOOT_ROM_BASE         (0x00000000)
#define PLAT_MSRAM_BASE            (0x00010000)
#define PLAT_ASRAM_BASE            (0x00020000)
#define PLAT_DEVICE_BASE           (0x10000000)
#define PLAT_SCIF0_BASE            (0x1004B800)
#define PLAT_SPIMULT_BASE          (0x10060000)
#define PLAT_SPIMULT_WBUF_BASE     (0x10070000)
#define PLAT_SYC_BASE              (0x11000000)
#define PLAT_CPG_BASE              (0x11010000)
#define PLAT_SYSC_BASE             (0x11020000)
#define PLAT_GPIO_BASE             (0x11030000)
#define PLAT_TZC_ASRAM_BASE        (0x11040000)
#define PLAT_TZC_MSRAM_BASE        (0x11050000)
#define PLAT_TZC_SPI_BASE          (0x11060000)
#define PLAT_TZC_DDR_BASE          (0x11070000)
#define PLAT_DDR_PHY_BASE          (0x11400000)
#define PLAT_DDR_MEMC_BASE         (0x11410000)
#define PLAT_OTP_BASE              (0x11860000)
#define PLAT_GIC_BASE              (0x11900000)
#define PLAT_SD0_BASE              (0x11C00000)
#define PLAT_SPIROM_BASE           (0x20000000)
#define PLAT_DDR1_BASE             (0x40000000)
#define PLAT_DDR2_BASE             (0x80000000)
#define PLAT_DDR3_BASE             (0x100000000)

#define PLAT_GICD_BASE             (PLAT_GIC_BASE)
#define PLAT_GICR_BASE             (PLAT_GIC_BASE + 0x00040000)

#define PLAT_SRAM_BASE             (PLAT_MSRAM_BASE)

#define PLAT_BOOT_ROM_SIZE         (0x00010000 - PLAT_BOOT_ROM_BASE)
#define PLAT_MSRAM_SIZE            (0x00020000 - PLAT_MSRAM_BASE)
#define PLAT_ASRAM_SIZE            (0x00030000 - PLAT_ASRAM_BASE)
#define PLAT_SRAM_SIZE             (PLAT_MSRAM_SIZE + PLAT_ASRAM_SIZE)
#define PLAT_DEVICE_SIZE           (0x15000000 - PLAT_DEVICE_BASE)
#define PLAT_SPIROM_SIZE           (0x30000000 - PLAT_SPIROM_BASE)
#define PLAT_DDR1_SIZE             (PLAT_DDR2_BASE - PLAT_DDR1_BASE)
#define PLAT_DDR2_SIZE             (PLAT_DDR3_BASE - PLAT_DDR2_BASE)

#define PLAT_SPIROM_FIP_BASE       (PLAT_SPIROM_BASE + 0x0001D200)
#define PLAT_SPIROM_FIP_SIZE       (0x30000000 - PLAT_SPIROM_FIP_BASE)

#define PLAT_OTP_DEVICE_INFO       (PLAT_OTP_BASE + 0x1178)

#define PLAT_EMMC_FIP_BASE         (0x00020000)
#define PLAT_EMMC_FIP_SIZE         (0x001DFFFF)

#define PLAT_SYC_INCK_HZ           (24000000)
#define PLAT_UART_INCK_HZ          (100000000)
#define PLAT_UART_BARDRATE         (115200)

/* Boot Info base address */
#define PLAT_BOOTINFO_BASE         (PLAT_SRAM_BASE)

/* Base address where parameters to BL31 are stored */
#define PARAMS_BASE                 (PLAT_SRAM_BASE + 0x0001F000)
#define PARAMS_SIZE                 (0x1000)

#endif /* __RZA3UL_DEF_H__ */
