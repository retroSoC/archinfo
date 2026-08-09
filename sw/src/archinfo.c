// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

#include "archinfo.h"

#include <stddef.h>

#include "archinfo_regs.h"

static uint32_t archinfo_reg_read(uintptr_t base, uint32_t offset) {
    const volatile uint32_t *const reg = (const volatile uint32_t *)(base + (uintptr_t)offset);

    return *reg;
}

archinfo_status_t archinfo_read(uintptr_t base, archinfo_snapshot_t *snapshot) {
    if ((base == (uintptr_t)0U) || (snapshot == NULL)) {
        return ARCHINFO_STATUS_INVALID_ARGUMENT;
    }

    snapshot->component_id = archinfo_reg_read(base, ARCHINFO_COMPONENT_ID_OFFSET);
    snapshot->vendor_id = archinfo_reg_read(base, ARCHINFO_VENDOR_ID_OFFSET);
    snapshot->soc_id = archinfo_reg_read(base, ARCHINFO_SOC_ID_OFFSET);
    snapshot->soc_revision = archinfo_reg_read(base, ARCHINFO_SOC_REVISION_OFFSET);
    snapshot->build_id = (uint64_t)archinfo_reg_read(base, ARCHINFO_BUILD_ID_LO_OFFSET);
    snapshot->build_id |= ((uint64_t)archinfo_reg_read(base, ARCHINFO_BUILD_ID_HI_OFFSET) << 32U);
    snapshot->config_id = archinfo_reg_read(base, ARCHINFO_CONFIG_ID_OFFSET);
    snapshot->build_status = archinfo_reg_read(base, ARCHINFO_BUILD_STATUS_OFFSET);
    snapshot->reference_clock_hz = archinfo_reg_read(base, ARCHINFO_REFERENCE_CLOCK_OFFSET);
    snapshot->sram_bytes = archinfo_reg_read(base, ARCHINFO_SRAM_BYTES_OFFSET);
    snapshot->topology = archinfo_reg_read(base, ARCHINFO_TOPOLOGY_OFFSET);
    snapshot->features0 = archinfo_reg_read(base, ARCHINFO_FEATURES0_OFFSET);
    snapshot->technology = archinfo_reg_read(base, ARCHINFO_TECHNOLOGY_OFFSET);
    snapshot->device_id_status = archinfo_reg_read(base, ARCHINFO_DEVICE_ID_STATUS_OFFSET);
    snapshot->ip_version = archinfo_reg_read(base, ARCHINFO_IP_VERSION_OFFSET);
    snapshot->capability = archinfo_reg_read(base, ARCHINFO_CAPABILITY_OFFSET);

    return ARCHINFO_STATUS_OK;
}

archinfo_status_t archinfo_validate(const archinfo_snapshot_t *snapshot,
                                    const archinfo_build_expectation_t *expectation) {
    uint32_t abi_version;

    if (snapshot == NULL) {
        return ARCHINFO_STATUS_INVALID_ARGUMENT;
    }

    abi_version =
        (snapshot->capability & ARCHINFO_CAPABILITY_ABI_MASK) >> ARCHINFO_CAPABILITY_ABI_SHIFT;
    if ((snapshot->component_id != ARCHINFO_COMPONENT_ID_VALUE) ||
        (snapshot->soc_id != ARCHINFO_SOC_ID_VALUE) ||
        (snapshot->ip_version != ARCHINFO_IP_VERSION_VALUE) ||
        (abi_version != ARCHINFO_ABI_VERSION)) {
        return ARCHINFO_STATUS_INCOMPATIBLE;
    }

    if (expectation != NULL) {
        if (expectation->check_build_id && (snapshot->build_id != expectation->build_id)) {
            return ARCHINFO_STATUS_INCOMPATIBLE;
        }
        if (expectation->check_config_id && (snapshot->config_id != expectation->config_id)) {
            return ARCHINFO_STATUS_INCOMPATIBLE;
        }
    }

    return ARCHINFO_STATUS_OK;
}

archinfo_status_t archinfo_read_device_id(uintptr_t base, uint32_t device_id[4]) {
    uint32_t status;

    if ((base == (uintptr_t)0U) || (device_id == NULL)) {
        return ARCHINFO_STATUS_INVALID_ARGUMENT;
    }

    status = archinfo_reg_read(base, ARCHINFO_DEVICE_ID_STATUS_OFFSET);
    if ((status & ARCHINFO_DEVICE_ID_READABLE_MASK) == 0U) {
        return ARCHINFO_STATUS_UNAVAILABLE;
    }

    device_id[0] = archinfo_reg_read(base, ARCHINFO_DEVICE_ID0_OFFSET);
    device_id[1] = archinfo_reg_read(base, ARCHINFO_DEVICE_ID1_OFFSET);
    device_id[2] = archinfo_reg_read(base, ARCHINFO_DEVICE_ID2_OFFSET);
    device_id[3] = archinfo_reg_read(base, ARCHINFO_DEVICE_ID3_OFFSET);

    return ARCHINFO_STATUS_OK;
}
