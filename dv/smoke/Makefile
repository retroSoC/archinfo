ROOT_PATH := $(CURDIR)/../..

include $(ROOT_PATH)/../common/script/smoke.mk

SIM_APP  ?= apb4_archinfo
SIM_TOP  := $(SIM_APP)_tb

SIM_INC  += +incdir+${ROOT_PATH}/rtl/

SRC_FILE += $(ROOT_PATH)/rtl/archinfo_reg_pkg.sv
SRC_FILE += $(ROOT_PATH)/rtl/archinfo_reg.sv
SRC_FILE += $(ROOT_PATH)/rtl/apb4_archinfo.sv
SRC_FILE += $(ROOT_PATH)/dv/smoke/archinfo_test.sv
SRC_FILE += $(ROOT_PATH)/dv/smoke/test_top.sv
SRC_FILE += $(ROOT_PATH)/dv/smoke/apb4_archinfo_tb.sv


include $(ROOT_PATH)/../common/script/vcs.mk