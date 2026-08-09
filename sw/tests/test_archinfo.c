// Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
// SPDX-License-Identifier: MulanPSL-2.0

#include <assert.h>
#include <stddef.h>
#include <stdint.h>

#include "archinfo.h"
#include "archinfo_regs.h"

int main(void) {
    uint32_t registers[64] = {0U};
    uint32_t device_id[4] = {0U, 0U, 0U, 0U};
    archinfo_snapshot_t snapshot;
    archinfo_build_expectation_t expectation = {
        .check_build_id = true,
        .check_config_id = true,
        .build_id = UINT64_C(0x0123456789ABCDEF),
        .config_id = UINT32_C(0x76543210),
    };
    const uintptr_t base = (uintptr_t)&registers[0];

    registers[ARCHINFO_COMPONENT_ID_OFFSET / 4U] = ARCHINFO_COMPONENT_ID_VALUE;
    registers[ARCHINFO_SOC_ID_OFFSET / 4U] = ARCHINFO_SOC_ID_VALUE;
    registers[ARCHINFO_BUILD_ID_LO_OFFSET / 4U] = UINT32_C(0x89ABCDEF);
    registers[ARCHINFO_BUILD_ID_HI_OFFSET / 4U] = UINT32_C(0x01234567);
    registers[ARCHINFO_CONFIG_ID_OFFSET / 4U] = UINT32_C(0x76543210);
    registers[ARCHINFO_IP_VERSION_OFFSET / 4U] = ARCHINFO_IP_VERSION_VALUE;
    registers[ARCHINFO_CAPABILITY_OFFSET / 4U] = ARCHINFO_CAPABILITY_VALUE;

    assert(archinfo_read(base, &snapshot) == ARCHINFO_STATUS_OK);
    assert(archinfo_validate(&snapshot, &expectation) == ARCHINFO_STATUS_OK);

    expectation.config_id = UINT32_C(0x11111111);
    assert(archinfo_validate(&snapshot, &expectation) == ARCHINFO_STATUS_INCOMPATIBLE);
    assert(archinfo_read_device_id(base, device_id) == ARCHINFO_STATUS_UNAVAILABLE);

    registers[ARCHINFO_DEVICE_ID_STATUS_OFFSET / 4U] = ARCHINFO_DEVICE_ID_READABLE_MASK;
    registers[ARCHINFO_DEVICE_ID0_OFFSET / 4U] = UINT32_C(0x33221100);
    registers[ARCHINFO_DEVICE_ID1_OFFSET / 4U] = UINT32_C(0x77665544);
    registers[ARCHINFO_DEVICE_ID2_OFFSET / 4U] = UINT32_C(0xBBAA9988);
    registers[ARCHINFO_DEVICE_ID3_OFFSET / 4U] = UINT32_C(0xFFEEDDCC);
    assert(archinfo_read_device_id(base, device_id) == ARCHINFO_STATUS_OK);
    assert(device_id[0] == UINT32_C(0x33221100));
    assert(device_id[3] == UINT32_C(0xFFEEDDCC));

    assert(archinfo_read((uintptr_t)0U, &snapshot) == ARCHINFO_STATUS_INVALID_ARGUMENT);
    assert(archinfo_read(base, NULL) == ARCHINFO_STATUS_INVALID_ARGUMENT);
    assert(archinfo_validate(NULL, NULL) == ARCHINFO_STATUS_INVALID_ARGUMENT);

    return 0;
}
