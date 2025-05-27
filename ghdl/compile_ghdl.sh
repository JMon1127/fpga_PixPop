#!/bin/bash

# exit on error
set -e

# clean previous
echo "Cleaning previous compilation"
rm -f *.ghw *.cf

echo "Analyzing source files"
ghdl -a ../src/cam_data_rcvr/cam_data_rcvr.vhd
ghdl -a ../src/PixPop_top/PixPop_top.vhd
ghdl -a ../simulation/tb_src/ov7670_cam_model.vhd
ghdl -a ../simulation/tb_src/tb_top.vhd

echo "Elaborating design"
ghdl -e tb_top

echo "Running simulation"
ghdl -r tb_top --stop-time=100ms --wave=wave.ghw

echo "Opening waveform viewer"
gtkwave wave.ghw

