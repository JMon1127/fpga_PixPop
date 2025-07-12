quietly set ACTELLIBNAME IGLOO2
quietly set PROJECT_DIR "C:/Users/JMon1/FPGA_dev/PixPop/develop/fpga_PixPop/build/PixPop_fpga"

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth
   vlib presynth
}
vmap presynth presynth
vmap IGLOO2 "C:/Microchip/Libero_SoC_v2024.2/Designer/lib/modelsimpro/precompiled/vlog/smartfusion2"
vmap SmartFusion2 "C:/Microchip/Libero_SoC_v2024.2/Designer/lib/modelsimpro/precompiled/vlog/smartfusion2"

vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/corefifo_sync_scntr.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/corefifo_sync.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/corefifo_graytobinconv.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/corefifo_nstagessync.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/corefifo_async.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/corefifo_fwft.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/cam_data_cdc_cam_data_cdc_0_USRAM_top.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/cam_data_cdc_cam_data_cdc_0_ram_wrapper.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc_0/rtl/vlog/core/COREFIFO.v"
vlog -sv -work presynth "${PROJECT_DIR}/component/work/cam_data_cdc/cam_data_cdc.v"
vcom -2008 -explicit  -work presynth "C:/Users/JMon1/FPGA_dev/PixPop/develop/fpga_PixPop/src/rgb2gs/hdl/vhdl/rgb2gs.vhd"
vcom -2008 -explicit  -work presynth "C:/Users/JMon1/FPGA_dev/PixPop/develop/fpga_PixPop/src/cam_data_rcvr/hdl/vhdl/cam_data_cdc_wrap.vhd"
vcom -2008 -explicit  -work presynth "C:/Users/JMon1/FPGA_dev/PixPop/develop/fpga_PixPop/src/cam_data_rcvr/hdl/vhdl/cam_data_rcvr.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FCCC_C0/FCCC_C0_0/FCCC_C0_FCCC_C0_0_FCCC.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FCCC_C0/FCCC_C0.vhd"
vcom -2008 -explicit  -work presynth "C:/Users/JMon1/FPGA_dev/PixPop/develop/fpga_PixPop/src/PixPop_top/hdl/vhdl/clock_rst_wrap.vhd"
vcom -2008 -explicit  -work presynth "C:/Users/JMon1/FPGA_dev/PixPop/develop/fpga_PixPop/src/PixPop_top/hdl/vhdl/PixPop_top.vhd"
vcom -2008 -explicit  -work presynth "C:/Users/JMon1/FPGA_dev/PixPop/develop/fpga_PixPop/simulation/tb_src/ov7670_cam_model.vhd"
vcom -2008 -explicit  -work presynth "C:/Users/JMon1/FPGA_dev/PixPop/develop/fpga_PixPop/simulation/tb_src/tb_top.vhd"

vsim -L IGLOO2 -L presynth  -t 1ps presynth.tb_top
add wave -group tb_top      /tb_top/*
add wave -group cam_model   /tb_top/cam_model/*
add wave -group dut         /tb_top/dut/*
add wave -group clock_rst   /tb_top/dut/u_clk_mgr/*
add wave -group cam_receive /tb_top/dut/u_cam_rcvr/*
add wave -group rgb2gs      /tb_top/dut/u_rgb2gs_conv/*
add wave -group cdc_wrap    /tb_top/dut/u_cam_rcvr/u_cam_data_cdc/*
add wave -group cdc_fifo    /tb_top/dut/u_cam_rcvr/u_cam_data_cdc/u_cam_data_cdc_fifo/*
run 100ms