#!/usr/bin/env python3
# Copyright (c) 2023-2026 Yuchi Miao <miaoyuchi@ict.ac.cn>
# SPDX-License-Identifier: MulanPSL-2.0

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def definitions(path: Path, pattern: str) -> dict[str, int]:
    values: dict[str, int] = {}
    for match in re.finditer(pattern, path.read_text(encoding="utf-8"), re.MULTILINE):
        values[match.group(1)] = int(match.group(2), 16)
    return values


def main() -> int:
    rtl = definitions(
        ROOT / "rtl" / "archinfo_define.svh",
        r"^`define ARCHINFO_([A-Z0-9_]+)_OFFSET\s+12'h([0-9A-Fa-f]+)$",
    )
    c_header = definitions(
        ROOT / "sw" / "include" / "archinfo_regs.h",
        r"^#define ARCHINFO_([A-Z0-9_]+)_OFFSET\s+UINT32_C\(0x([0-9A-Fa-f]+)\)$",
    )
    if rtl != c_header:
        missing_rtl = sorted(c_header.keys() - rtl.keys())
        missing_c = sorted(rtl.keys() - c_header.keys())
        mismatched = sorted(key for key in rtl.keys() & c_header.keys() if rtl[key] != c_header[key])
        raise SystemExit(
            f"register definitions differ: missing RTL={missing_rtl}, missing C={missing_c}, "
            f"mismatched={mismatched}"
        )
    print(f"register parity valid: {len(rtl)} offsets")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
