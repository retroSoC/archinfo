include common.mk

SIM_APP  ?= apb4_archinfo
SIM_TOP  := $(SIM_APP)_tb

SRC_FILE ?=
SRC_FILE += ${ROOT_PATH}/../common/rtl/utils/register.sv
SRC_FILE += ${ROOT_PATH}/../common/rtl/interface/apb4_if.sv
SRC_FILE += ${ROOT_PATH}/../common/rtl/verif/helper.sv
SRC_FILE += ${ROOT_PATH}/../common/rtl/verif/test_base.sv
SRC_FILE += ${ROOT_PATH}/../common/rtl/verif/apb4_master.sv
SRC_FILE += ${ROOT_PATH}/rtl/archinfo_reg_pkg.sv
SRC_FILE += ${ROOT_PATH}/rtl/archinfo_reg.sv
SRC_FILE += ${ROOT_PATH}/rtl/apb4_archinfo.sv
SRC_FILE += ${ROOT_PATH}/dv/smoke/archinfo_test.sv
SRC_FILE += ${ROOT_PATH}/dv/smoke/test_top.sv
SRC_FILE += ${ROOT_PATH}/dv/smoke/apb4_archinfo_tb.sv

WAVE_CFG ?= # WAVE_ON
RUN_ARGS ?=
RUN_ARGS += +${WAVE_CFG}
RUN_ARGS += +WAVE_NAME=$(SIM_TOP).fsdb

comp:
	@mkdir -p build
	cd build && (${SIM_TOOL} ${SIM_OPTIONS} -top $(SIM_TOP) -l compile.log $(SRC_FILE) $(SIM_INC))

run: comp
	cd build && (${SIM_BINY} -l run.log ${RUN_ARGS})

wave:
	cd build && (${VERDI_TOOL} -ssf $(SIM_TOP).fsdb &)

clean :
	rm -rf build

.PHONY : wave clean