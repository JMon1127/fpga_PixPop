-------------------------------------------------------------------------------
-- Title       : PixPop FPGA testbench
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : tb_top.vhd
-- Author      : J. I. Montes
-- Company     : [Organization, if applicable]
-- Created     : [2025-05-11]
-- Last Update : [YYYY-MM-DD]
-- Platform    : Microsemi Igloo2 TODO: add PN
-- Description : Top level testbench for the PixPop FPGA
--
-- Dependencies: [List any external modules/packages if applicable]
--
-- Revision History:
--   Date        Author        Description
--   2025-05-21  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer (if applicable)
-- This code is distributed under the terms of [license].
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_top is
end tb_top;

architecture behavorial of tb_top is

  signal s_tb_sys_clk   : std_logic := '0';
  signal s_tb_sys_rst_n : std_logic := '0';

begin

  -- generate a 50MHz clock to drive the sys clk input to the DUT
  proc_tb_clkgen : process
  begin
    wait for 20 ns;
    s_tb_sys_clk <= not s_tb_sys_clk;
  end process proc_tb_clkgen;

  -- wait for clock to be stable and release DUT from RST
  proc_tb_rst : process
  begin
    wait for 400 ns; -- after 20 clock cycles release the DUT out of reset
    s_tb_sys_rst_n <= '1';
  end process;


  -- TODO: will need some sort of model for the OV7670 camera

  -- instantiat the dut
  dut : entity work.PixPop_top
  port map (
    SYS_CLK     => s_tb_sys_clk,
    SYS_RST_N   => s_tb_sys_rst_n,

    I_CAM_DATA  =>
    I_CAM_PCLK  =>
    I_CAM_VSYNC =>
    I_CAM_HREF  =>
  );
end behavorial;