-------------------------------------------------------------------------------
-- Title       : PixPop FPGA top level
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : PixPop_top.vhd
-- Author      : J. I. Montes
-- Created     : [2025-05-11]
-- Last Update : [2025-05-11]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : Top level code for the PixPop FPGA
--
-- Dependencies: clocks_wrap.vhd
--               cam_data_rcvr.vhd
--
-- Revision History:
--   Date        Author        Description
--   2025-05-11  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PixPop_top is
  port(
    REF_CLK   : IN    STD_LOGIC;
    SYS_RST_N : IN    STD_LOGIC;

    -- OV7670 Camera Interface
    -- TODO: I2C camera configuration
    -- CAM_SCL   : OUT   STD_LOGIC; -- i2c clock for config
    -- CAM_SDA   : INOUT STD_LOGIC; -- i2c data bus for config
    CAM_VSYNC : IN    STD_LOGIC; -- Start of Frame (active frame)
    CAM_HREF  : IN    STD_LOGIC; -- line data valid (active pixels)
    CAM_PCLK  : IN    STD_LOGIC; -- camera pixel clock
    CAM_XCLK  : OUT   STD_LOGIC; -- camera input clock
    CAM_DATA  : IN    STD_LOGIC_VECTOR(7 downto 0) -- 8 bit color data

    -- TODO: eventually need to also transmit somehow

    -- since we arent having a soft core proc yet i think minimal control will be with switches on board
    -- eventually can look into adding a proc... or could also connect one externally
  );
end PixPop_top;

architecture rtl of PixPop_top is
  --------------------
  -- Signals
  --------------------
  signal s_sys_clk       : std_logic; -- main system clock
  signal s_clk_lock      : std_logic; -- indicates PLL has locked
  signal s_safe_rst_n    : std_logic; -- indicates safe to let out of reset

  signal s_cam_src_data  : std_logic_vector(15 downto 0); -- 2 byte RGB data
  signal s_cam_src_valid : std_logic;                     -- indicate data is valid

begin

  -- Clock Management
  u_clk_mgr : entity work.clocks_wrap
  port map (
    I_REF_CLK  => REF_CLK,
    O_SYS_CLK  => s_sys_clk,
    O_CAM_XCLK => CAM_XCLK, -- drives OV7670 camera at 24MHz
    O_LOCK     => s_clk_lock
  );

  -- TODO: fix this. Actually seems dumb to have this logic at the top level
  --       instead look into using microsemi ip to handle safe resets for the sys domain and pclk domain
  --       Seems like the ip is called CoreRESETP. Tie this into the clock wrapper
  -- only let out of reset once PLL is locked
  proc_rst_lock : process (REF_CLK)
  begin
    if(SYS_RST_N = '1' and s_clk_lock = '1') then
      s_safe_rst_n <= '1';
    else
      s_safe_rst_n <= '0';
    end if;
  end process;

  -- OV7670 Camera Data Receiver
  u_cam_rcvr : entity work.cam_data_rcvr
  port map (
    SYS_CLK     => s_sys_clk,
    SYS_RST_N   => s_safe_rst_n,

    I_CAM_DATA  => CAM_DATA,
    I_CAM_PCLK  => CAM_PCLK,
    I_CAM_VSYNC => CAM_VSYNC,
    I_CAM_HREF  => CAM_HREF,

    O_PIX_DATA  => s_cam_src_data,
    O_PIX_VALID => s_cam_src_valid
  );

  -- TODO: Will need a data proc block
  -- here it will probably be a top level that selects between edge detect algo, normal color, or even grayscale

  -- TODO: will need a data transmit block
  -- this should take the strem from data proc block and perform the transmit logic

end architecture rtl;