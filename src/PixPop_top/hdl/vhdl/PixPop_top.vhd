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
-- Dependencies: clock_rst_wrap.vhd
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
    EXT_RST_N : IN    STD_LOGIC;

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
  signal s_sys_clk            : std_logic;                     -- main system clock
  signal s_rst_n_syncd_pclk   : std_logic;
  signal s_rst_n_syncd_sysclk : std_logic;

  signal s_cam_src_data       : std_logic_vector(15 downto 0); -- 2 byte RGB data
  signal s_cam_src_valid      : std_logic;                     -- indicate data is valid

  signal s_cam_gs_data        : std_logic_vector(7 downto 0);  -- 8 bit grayscale data converted from RGB
  signal s_cam_gs_valid       : std_logic;                     -- indicates grayscale data is valid

begin

  -- Clock Management
  u_clk_mgr : entity work.clock_rst_wrap
  port map (
    I_REF_CLK            => REF_CLK,
    I_EXT_RST_N          => EXT_RST_N,
    I_CAM_PCLK           => CAM_PCLK,
    O_RST_N_SYNCD_PCLK   => s_rst_n_syncd_pclk,
    O_RST_N_SYNCD_SYSCLK => s_rst_n_syncd_sysclk,
    O_SYS_CLK            => s_sys_clk,
    O_CAM_XCLK           => CAM_XCLK -- drives OV7670 camera at 24MHz
  );

  -- OV7670 Camera Data Receiver
  u_cam_rcvr : entity work.cam_data_rcvr
  port map (
    SYS_CLK     => s_sys_clk,
    SYS_RST_N   => s_rst_n_syncd_sysclk,
    PCLK_RST_N  => s_rst_n_syncd_pclk,

    I_CAM_DATA  => CAM_DATA,
    I_CAM_PCLK  => CAM_PCLK,
    I_CAM_VSYNC => CAM_VSYNC,
    I_CAM_HREF  => CAM_HREF,

    O_PIX_DATA  => s_cam_src_data,
    O_PIX_VALID => s_cam_src_valid
  );

  -- TODO: Will need a data proc block
  -- here it will probably be a top level that selects between edge detect algo, normal color, or even grayscale
  -- TODO: eventually this rgb2gs module should move down a level into data proc block
  u_rgb2gs_conv : entity work.rgb2gs
  port map (
    SYS_CLK          => s_sys_clk,
    SYS_RST_N        => s_rst_n_syncd_sysclk,

    I_RGB_DATA       => s_cam_src_data,
    I_RGB_DATA_VALID => s_cam_src_valid,

    O_GS_DATA        => s_cam_gs_data,
    O_GS_DATA_VALID  => s_cam_gs_valid
  );
  -- TODO: will need a data transmit block
  -- this should take the strem from data proc block and perform the transmit logic

end architecture rtl;