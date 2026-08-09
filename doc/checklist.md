# Release Checklist

- [ ] Register offsets and field meanings are reviewed.
- [ ] `make register-check` confirms RTL/C parity.
- [ ] Format, lint, Icarus, Verilator, host, synthesis, and formal gates pass.
- [ ] Source revision, dependency lock, and configuration digest are captured.
- [ ] Device-ID source, clock domain, provisioning, and read policy are reviewed.
- [ ] SoC firmware validates ABI 2 before consuming optional fields.
- [ ] Integration timing and APB master access policy are signed off.
- [ ] Changelog and semantic version are updated.
