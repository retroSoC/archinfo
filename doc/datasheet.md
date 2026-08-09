# ARCHINFO ABI V2 Datasheet

## Purpose

ARCHINFO provides immutable hardware identity and build provenance through an
APB4 slave. It is intended for boot compatibility checks, support logs,
manufacturing records, and firmware feature discovery. It is not a security
root: security-sensitive device identity must be qualified by the integration's
lifecycle and access-control policy.

All registers are 32-bit, read-only, and naturally aligned. `PREADY` is always
high. A write, unaligned access, unmapped offset, or denied device-ID read
asserts `PSLVERR` only in the APB access phase and returns zero read data.

## Interface

| Port | Direction | Description |
| --- | --- | --- |
| `device_id_i[127:0]` | input | Lifecycle/OTP supplied identity, least-significant word first |
| `device_id_valid_i` | input | Identity has been provisioned and is stable |
| `device_id_read_enable_i` | input | Current lifecycle policy permits software reads |
| `apb4` | interface slave | 32-bit APB4 interface from Common |

The three device identity inputs must be synchronous to `apb4.pclk`, or held
static after reset. An integration using another clock or power domain must add
a qualified CDC/lifecycle bridge before this IP.

## Register Map

| Offset | Name | Reset/source | Description |
| ---: | --- | --- | --- |
| `0x000` | `COMPONENT_ID` | `0x41524348` | ASCII `ARCH` |
| `0x004` | `VENDOR_ID` | parameter | JEP106-compatible vendor encoding; zero means unassigned |
| `0x008` | `SOC_ID` | `0x4D494E49` | ASCII `MINI` default SoC family |
| `0x00C` | `SOC_REVISION` | parameter | Major/minor implementation revision |
| `0x010` | `BUILD_ID_LO` | parameter | Source revision bits 31:0 |
| `0x014` | `BUILD_ID_HI` | parameter | Source revision bits 63:32 |
| `0x018` | `CONFIG_ID` | parameter | First 32 bits of canonical configuration digest |
| `0x01C` | `BUILD_STATUS` | parameter | Build provenance flags |
| `0x020` | `REFERENCE_CLOCK_HZ` | parameter | External/reference clock, not dynamic PLL output |
| `0x024` | `SRAM_BYTES` | parameter | Integrated SRAM capacity; zero means no SRAM interface |
| `0x028` | `TOPOLOGY` | parameter | GPIO/user-core/management-hart/IRQ counts |
| `0x02C` | `FEATURES0` | parameter | SoC feature bitmap |
| `0x030` | `TECHNOLOGY` | parameter | Process, PDK, and target class |
| `0x034` | `DEVICE_ID_STATUS` | inputs | Provisioning/access state and byte width |
| `0x038` | `DEVICE_ID0` | gated input | Device ID bits 31:0 |
| `0x03C` | `DEVICE_ID1` | gated input | Device ID bits 63:32 |
| `0x040` | `DEVICE_ID2` | gated input | Device ID bits 95:64 |
| `0x044` | `DEVICE_ID3` | gated input | Device ID bits 127:96 |
| `0x0F8` | `IP_VERSION` | `0x00020000` | ARCHINFO implementation ABI version |
| `0x0FC` | `CAPABILITY` | `0x023F1014` | ABI, capabilities, ID width, register count |

`BUILD_STATUS[0]` is dirty, bit 1 is dependency-lock valid, bit 2 is release,
and bit 3 is source-known. Unknown source revision produces a zero `BUILD_ID`
and clears source-known.

`TOPOLOGY[7:0]` is the management-hart count, bits 15:8 are user-core slots,
bits 23:16 are GPIO count, and bits 31:24 are interrupt-vector width.

`TECHNOLOGY[15:0]` is process nanometers, bits 23:16 are the PDK ID, and bits
31:24 are the target class. Defined PDK IDs are IHP130=1, GF180=2, SKY130=3,
and ICS55=4. Target class 2 denotes ASIC.

`DEVICE_ID_STATUS[0]` is valid, bit 1 is read-enable, bit 2 is readable, and
bits 15:8 contain the fixed width of 16 bytes. Device data registers are legal
only when readable is one.

`CAPABILITY[31:24]` is ABI 2, bits 23:16 are capability flags, bits 15:8 are
the device-ID width, and bits 7:0 are the register count. Capability flags
identify strict errors, build ID, config ID, topology, technology, and device
ID support.

## Software Rules

Firmware should first read `COMPONENT_ID`, `IP_VERSION`, and `CAPABILITY`, then
validate the ABI before interpreting optional fields. Read
`DEVICE_ID_STATUS` before accessing identity words. The integration must keep
lifecycle controls stable across the status and data reads.
