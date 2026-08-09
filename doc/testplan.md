# Verification Plan

| Requirement | Directed simulation | Formal property |
| --- | --- | --- |
| Every defined constant/parameter is readable | all register reads | component-ID exact value |
| APB response completes without waits | every transaction | `PREADY` always high |
| Writes cannot change identity | write to mapped offset, read again | every access-phase write errors and returns zero |
| Invalid addresses are diagnosed | unaligned and unmapped reads | unaligned read errors and returns zero |
| Device identity cannot leak | invalid and denied reads | denied word 0 errors and returns zero |
| Enabled identity preserves word order | four identity reads | enabled word 0 equals input bits 31:0 |
| Error is access-phase qualified | setup checks | no `PSLVERR` outside access phase |
| RTL/C definitions match | `make register-check` | not applicable |

Both Icarus and Verilator execute the same self-checking testbench. The host C
test validates snapshot assembly, ABI/build checks, unavailable device ID, and
least-significant-word-first identity reads. Yosys checks the scalar decoder is
synthesizable; SBY/Bitwuzla proves the protocol and non-disclosure invariants.
