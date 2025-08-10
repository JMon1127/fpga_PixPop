# simulator
SIM = ghdl

#language
TOPLEVEL_LANG = vhdl

# source files
VHDL_SOURCES = $(abspath ../hdl/vhdl/sobel_edge_det.vhd)

# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = sobel_edge_det

# MODULE is the basename of the Python test file
MODULE = sobel_edge_det_testbench

# waveform for gtkwave
SIM_ARGS = --vcd=$(TOPLEVEL).vcd

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
