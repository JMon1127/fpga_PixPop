###############################################################################
## Title       : GHDL Compile/Simulate
## Project     : fpga_PixPop
###############################################################################
## File        : compile_ghdl.sh
## Author      : J. I. Montes
## Created     : [2025-06-06]
## Last Update : [2025-06-06]
## Platform    : Microsemi Igloo2 M2GL010T-FG484
## Description : This script compiles and simulates the PixPop FPGA using GHDL
##
## Dependencies: GHDL, GTKWave, All design files
##
## Revision History:
##   Date        Author        Description
##   2025-06-06  J. I. Montes  Initial version
###############################################################################
## License/Disclaimer
## This code may be adapted or shared as long as appropriate credit is given
###############################################################################

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

