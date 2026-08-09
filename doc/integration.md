# Integration Guide

Instantiate `apb4_archinfo` with complete named connections. Supply immutable
SoC constants as parameters; do not create writable shadow registers for these
values. `REFERENCE_CLOCK_HZ` describes the stable board/reference clock.

The integration build should run `scripts/generate_metadata.py` with the SoC
repository, canonical dependency lock, and configuration digest. The generated
SV and C headers are build products and must not be committed.

```sh
python3 scripts/generate_metadata.py \
  --repo-root /path/to/soc \
  --lock /path/to/soc/config/dependencies.lock.json \
  --config-digest 0123456789ab \
  --output-sv build/include/archinfo_integration_metadata.svh \
  --output-c build/include/archinfo_integration_metadata.h
```

Device identity must come from a reviewed OTP, eFuse, lifecycle, or board
identity block. Tie `device_id_valid_i` and `device_id_read_enable_i` low when
that source is not integrated. This deliberate tie-off keeps the status
discoverable while denied data reads fail and cannot leak input values.

APB address decoding may pass either a local offset or a full SoC address; the
IP decodes the low 12 bits. The containing interconnect remains responsible for
the 4 KiB region selection and master access policy.
