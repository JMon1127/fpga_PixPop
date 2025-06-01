# This creates the libero project
new_project -location {..\PixPop_fpga} \
            -name {PixPop_fpga} \
            -project_description {} \
            -block_mode 0 \
            -standalone_peripheral_initialization 0 \
            -instantiate_in_smartdesign 1 \
            -ondemand_build_dh 1 \
            -use_relative_path 0 \
            -linked_files_root_dir_env {} \
            -hdl {VHDL} \
            -family {IGLOO2} \
            -die {M2GL010T} \
            -package {484 FBGA} \
            -speed {STD} \
            -die_voltage {1.2} \
            -part_range {COM} \
            -adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} \
            -adv_options {IO_DEFT_STD:LVCMOS 2.5V} \
            -adv_options {PLL_SUPPLY:PLL_SUPPLY_25} \
            -adv_options {RESTRICTPROBEPINS:1} \
            -adv_options {RESTRICTSPIPINS:0} \
            -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} \
            -adv_options {TEMPR:COM} \
            -adv_options {VCCI_1.2_VOLTR:COM} \
            -adv_options {VCCI_1.5_VOLTR:COM} \
            -adv_options {VCCI_1.8_VOLTR:COM} \
            -adv_options {VCCI_2.5_VOLTR:COM} \
            -adv_options {VCCI_3.3_VOLTR:COM} \
            -adv_options {VOLTR:COM} \

# Add source files here. These are remote links
create_links \
            -convert_EDN_to_HDL 0 \
            -hdl_source {../../src/PixPop_top/hdl/vhdl/PixPop_top.vhd} \
            -hdl_source {../../src/PixPop_top/hdl/vhdl/clocks_wrap.vhd} \
            -hdl_source {../../src/cam_data_rcvr/hdl/vhdl/cam_data_rcvr.vhd} \
            -hdl_source {../../src/cam_data_rcvr/hdl/vhdl/cam_data_cdc_wrap.vhd}

# Add simulation files here. These are remote links
create_links \
            -convert_EDN_to_HDL 0 \
            -stimulus {../../simulation/tb_src/ov7670_cam_model.vhd} \
            -stimulus {../../simulation/tb_src/tb_top.vhd}

# this builds the hierarchy
build_design_hierarchy

# this sets the top level as root
set_root -module {PixPop_top::work}

# this sets up the active stimulus
organize_tool_files -tool {SIM_PRESYNTH} \
                    -file {../../simulation/tb_src/ov7670_cam_model.vhd} \
                    -file {../../simulation/tb_src/tb_top.vhd} \
                    -module {PixPop_top::work} \
                    -input_type {stimulus}

organize_tool_files -tool {SIM_POSTSYNTH} \
                    -file {../../simulation/tb_src/ov7670_cam_model.vhd} \
                    -file {../../simulation/tb_src/tb_top.vhd} \
                    -module {PixPop_top::work} \
                    -input_type {stimulus}

organize_tool_files -tool {SIM_POSTLAYOUT} \
                    -file {../../simulation/tb_src/ov7670_cam_model.vhd} \
                    -file {../../simulation/tb_src/tb_top.vhd} \
                    -module {PixPop_top::work} \
                    -input_type {stimulus}

source cam_data_cdc.tcl
source FCCC_C0.tcl

save_project