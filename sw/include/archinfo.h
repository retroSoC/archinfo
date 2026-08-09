// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

#ifndef ARCHINFO_H
#define ARCHINFO_H

#include <stdbool.h>
#include <stdint.h>

typedef enum {
    ARCHINFO_STATUS_OK = 0,
    ARCHINFO_STATUS_INVALID_ARGUMENT = -1,
    ARCHINFO_STATUS_INCOMPATIBLE = -2,
    ARCHINFO_STATUS_UNAVAILABLE = -3
} archinfo_status_t;

typedef struct {
    uint32_t component_id;
    uint32_t vendor_id;
    uint32_t soc_id;
    uint32_t soc_revision;
    uint64_t build_id;
    uint32_t config_id;
    uint32_t build_status;
    uint32_t reference_clock_hz;
    uint32_t sram_bytes;
    uint32_t topology;
    uint32_t features0;
    uint32_t technology;
    uint32_t device_id_status;
    uint32_t ip_version;
    uint32_t capability;
} archinfo_snapshot_t;

typedef struct {
    bool check_build_id;
    bool check_config_id;
    uint64_t build_id;
    uint32_t config_id;
} archinfo_build_expectation_t;

archinfo_status_t archinfo_read(uintptr_t base, archinfo_snapshot_t *snapshot);
archinfo_status_t archinfo_validate(const archinfo_snapshot_t *snapshot,
                                    const archinfo_build_expectation_t *expectation);
archinfo_status_t archinfo_read_device_id(uintptr_t base, uint32_t device_id[4]);

#endif
