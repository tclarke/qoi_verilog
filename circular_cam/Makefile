SIM ?= icarus
TOPLEVEL_LANG ?= verilog

COCOTB_ANSI_OUTPUT=1
COCOTB_LOG_LEVEL=DEBUG

VERILOG_SOURCES += $(PWD)/*.sv
TOPLEVEL = CircularCAM
MODULE = test_circular_cam

include $(shell cocotb-config --makefiles)/Makefile.sim
