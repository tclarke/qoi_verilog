SIM ?= icarus
TOPLEVEL_LANG ?= verilog

COCOTB_ANSI_OUTPUT=1
COCOTB_LOG_LEVEL=DEBUG

VERILOG_SOURCES += $(PWD)/*.sv
VERILOG_SOURCES += $(PWD)/circular_cam/*.sv
VERILOG_SOURCES += $(PWD)/full_pixel_encoder/*.sv

TOPLEVEL = QoiEncoder
MODULE = test_qoi_encoder

include $(shell cocotb-config --makefiles)/Makefile.sim
