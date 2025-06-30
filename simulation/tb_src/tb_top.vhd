-------------------------------------------------------------------------------
-- Title       : PixPop FPGA testbench
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : tb_top.vhd
-- Author      : J. I. Montes
-- Created     : [2025-05-21]
-- Last Update : [2025-05-21]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : Top level testbench for the PixPop FPGA
--
-- Dependencies: PixPop_top.vhd
--               ov7670_cam_model.vhd
--
-- Revision History:
--   Date        Author        Description
--   2025-05-21  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_top is
end tb_top;

architecture behavorial of tb_top is
  --------------------
  -- Signals
  --------------------
  signal s_tb_sys_clk   : std_logic := '0';
  signal s_tb_sys_rst_n : std_logic := '0';

  signal s_tb_cam_rst_n : std_logic := '0';
  signal s_tb_cam_xclk  : std_logic := '0';
  signal s_tb_cam_data  : std_logic_vector(7 downto 0);
  signal s_tb_cam_vsync : std_logic;
  signal s_tb_cam_href  : std_logic;
  signal s_tb_cam_pclk  : std_logic;

begin

  -- generate a 50MHz clock to drive the sys clk input to the DUT
  proc_tb_clkgen : process
  begin
    wait for 10 ns;
    s_tb_sys_clk <= not s_tb_sys_clk;
  end process proc_tb_clkgen;

  -- wait for clock to be stable and release DUT from RST
  proc_tb_rst : process
  begin
    wait for 400 ns; -- after 20 clock cycles release the DUT out of reset
    s_tb_sys_rst_n <= '1';
  end process proc_tb_rst;

  -- release camera model out of reset shortly after the DUT
  proc_tb_cam_rst : process
  begin
    wait for 6000 ns;
    s_tb_cam_rst_n <= '1';
  end process proc_tb_cam_rst;

  --instantiate the camera model
  cam_model : entity work.ov7670_cam_model
  port map (
    I_CAM_RST_N => s_tb_cam_rst_n,
    I_CAM_XCLK  => s_tb_cam_xclk,

    O_CAM_DATA  => s_tb_cam_data,
    O_CAM_PCLK  => s_tb_cam_pclk,
    O_CAM_VSYNC => s_tb_cam_vsync,
    O_CAM_HREF  => s_tb_cam_href
  );

  -- instantiate the dut
  dut : entity work.PixPop_top
  port map (
    REF_CLK   => s_tb_sys_clk,
    EXT_RST_N => s_tb_sys_rst_n,

    CAM_DATA  => s_tb_cam_data,
    CAM_PCLK  => s_tb_cam_pclk,
    CAM_XCLK  => s_tb_cam_xclk,
    CAM_VSYNC => s_tb_cam_vsync,
    CAM_HREF  => s_tb_cam_href
  );
end behavorial;