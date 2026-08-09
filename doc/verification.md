# Verification and Release Contract

A release candidate must pass:

```sh
make format-check register-check lint
make test-iverilog test-verilator test-host
make synth formal
```

The acceptance marker for both RTL simulators is `ARCHINFO_TEST_PASS`. A test
also fails on a nonzero command status or any `$fatal`. Generated outputs are
confined to `build/`.

The testbench parameterizes every integration field with non-default values to
detect accidental hard-coding. Formal operates on `archinfo_reg`, the same
scalar decoder used below the APB wrapper, avoiding a separate verification
model. Both RTL simulators exercise that decoder directly. Verilator lint and
the integrating SoC regression elaborate the APB interface wrapper; this avoids
making the standalone Icarus test depend on an interface-to-Verilog conversion.

Hardware signoff must additionally review lifecycle stability for the device
identity inputs and confirm the surrounding interconnect enforces the intended
master privilege policy. Those integration properties are outside this IP's
standalone proof boundary.
