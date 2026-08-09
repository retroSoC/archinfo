SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:

ROOT := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))
COMMON_ROOT ?= $(abspath $(ROOT)/../common)
BUILD_DIR ?= $(ROOT)/build
IVERILOG ?= iverilog
VVP ?= vvp
VERILATOR ?= verilator
VERIBLE_FORMAT ?= verible-verilog-format
CLANG_FORMAT ?= clang-format-14
HOST_CC ?= cc
PYTHON ?= python3
SBY ?= sby

RTL_SRCS := rtl/archinfo_reg.sv rtl/apb4_archinfo.sv
RTL_HDRS := rtl/archinfo_define.svh
C_SRCS := sw/src/archinfo.c sw/tests/test_archinfo.c
C_HDRS := sw/include/archinfo.h sw/include/archinfo_regs.h

COMMON_APB := $(COMMON_ROOT)/rtl/interface/apb4_if.sv
COMMON_XCHECKER := $(COMMON_ROOT)/rtl/utils/xchecker.sv
IVERILOG_OUT := $(BUILD_DIR)/iverilog/archinfo_tb.vvp
VERILATOR_DIR := $(BUILD_DIR)/verilator
HOST_TEST := $(BUILD_DIR)/host/test_archinfo

.PHONY: help doctor format format-check register-check lint test test-iverilog \
	test-verilator test-host synth formal clean

help:
	@printf '%s\n' \
	  'archinfo targets:' \
	  '  doctor          verify required tools and Common checkout' \
	  '  format-check    verify SystemVerilog and C formatting' \
	  '  register-check  compare hand-written RTL and C offsets' \
	  '  lint            run Verilator lint' \
	  '  test            run Icarus, Verilator, and host C tests' \
	  '  synth           synthesize the scalar register decoder with Yosys' \
	  '  formal          prove the decoder properties with SBY/Bitwuzla'

doctor:
	@for tool in $(IVERILOG) $(VVP) $(VERILATOR) $(VERIBLE_FORMAT) $(CLANG_FORMAT) \
		$(HOST_CC) $(PYTHON) yosys $(SBY) bitwuzla; do \
		command -v $$tool >/dev/null || { echo "missing tool: $$tool" >&2; exit 1; }; \
	done
	@test -f $(COMMON_APB) || { echo "missing Common checkout: $(COMMON_ROOT)" >&2; exit 1; }

format:
	$(VERIBLE_FORMAT) --inplace $(RTL_SRCS) $(RTL_HDRS) dv/unit/archinfo_tb.sv formal/archinfo_formal.sv
	$(CLANG_FORMAT) -i $(C_SRCS) $(C_HDRS)

format-check:
	@set -e; for file in $(RTL_SRCS) $(RTL_HDRS) dv/unit/archinfo_tb.sv formal/archinfo_formal.sv; do \
		tmp=$$(mktemp); $(VERIBLE_FORMAT) $$file > $$tmp; cmp -s $$file $$tmp || { \
			echo "SystemVerilog format mismatch: $$file" >&2; rm -f $$tmp; exit 1; }; rm -f $$tmp; \
	done
	@set -e; for file in $(C_SRCS) $(C_HDRS); do \
		tmp=$$(mktemp); $(CLANG_FORMAT) $$file > $$tmp; cmp -s $$file $$tmp || { \
			echo "C format mismatch: $$file" >&2; rm -f $$tmp; exit 1; }; rm -f $$tmp; \
	done

register-check:
	$(PYTHON) scripts/check_register_parity.py

lint:
	$(VERILATOR) --lint-only --timing -Wall -Wno-fatal -Wno-UNDRIVEN -Wno-UNUSEDSIGNAL \
		--top-module apb4_archinfo -DSV_ASSRT_DISABLE \
		-Irtl -I$(COMMON_ROOT)/rtl/interface -I$(COMMON_ROOT)/rtl/utils \
		$(COMMON_APB) $(COMMON_XCHECKER) $(RTL_SRCS)

$(IVERILOG_OUT): rtl/archinfo_reg.sv $(RTL_HDRS) dv/unit/archinfo_tb.sv
	@mkdir -p $(@D)
	$(IVERILOG) -g2012 -DSV_ASSRT_DISABLE -Irtl -o $@ rtl/archinfo_reg.sv dv/unit/archinfo_tb.sv

test-iverilog: $(IVERILOG_OUT)
	$(VVP) $(IVERILOG_OUT) | tee $(BUILD_DIR)/iverilog/test.log
	@grep -q ARCHINFO_TEST_PASS $(BUILD_DIR)/iverilog/test.log

test-verilator:
	@mkdir -p $(VERILATOR_DIR) $(BUILD_DIR)/ccache-tmp $(BUILD_DIR)/tmp
	CCACHE_DISABLE=1 CCACHE_TEMPDIR=$(BUILD_DIR)/ccache-tmp TMPDIR=$(BUILD_DIR)/tmp \
	$(VERILATOR) --binary --timing -Wall -Wno-fatal -DSV_ASSRT_DISABLE \
	--Mdir $(VERILATOR_DIR) --top-module archinfo_tb \
	-Irtl rtl/archinfo_reg.sv dv/unit/archinfo_tb.sv
	$(VERILATOR_DIR)/Varchinfo_tb | tee $(VERILATOR_DIR)/test.log
	@grep -q ARCHINFO_TEST_PASS $(VERILATOR_DIR)/test.log

$(HOST_TEST): $(C_SRCS) $(C_HDRS)
	@mkdir -p $(@D)
	$(HOST_CC) -std=c11 -Wall -Wextra -Werror -pedantic -Isw/include $(C_SRCS) -o $@

test-host: $(HOST_TEST)
	$(HOST_TEST)

test: test-iverilog test-verilator test-host

synth:
	@mkdir -p $(BUILD_DIR)/synth
	yosys -p 'read_verilog -sv -Irtl rtl/archinfo_reg.sv; hierarchy -top archinfo_reg; proc; opt; check; stat' \
		| tee $(BUILD_DIR)/synth/yosys.log

formal:
	$(SBY) -f -d $(BUILD_DIR)/formal formal/archinfo.sby

clean:
	rm -rf $(BUILD_DIR)