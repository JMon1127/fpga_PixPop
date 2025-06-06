-------------------------------------------------------------------------------
-- Title       : Clock Management
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : clocks_wrap.vhd
-- Author      : J. I. Montes
-- Created     : [2025-06-01]
-- Last Update : [2025-06-01]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : This block is a wrapper for clocks generated using CCC
--
-- Dependencies: Microsemi Fabric Clock Conditioning Circuit(FCCC) IP component
--
-- Revision History:
--   Date        Author        Description
--   2025-06-01  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clocks_wrap is
  port (
    I_REF_CLK  : in std_logic;
    O_SYS_CLK  : out std_logic; -- main system clock
    O_CAM_XCLK : out std_logic; -- drives OV7670 camera
    O_LOCK     : out std_logic  -- indicate PLL has locked
  );
  end clocks_wrap;

architecture rtl of clocks_wrap is
  --------------------
  -- Components
  --------------------
  component FCCC_C0 is
    port (
      CLK0 : in std_logic;
      GL0  : out std_logic; -- 125MHz
      GL1  : out std_logic; -- 24MHz
      LOCK : out std_logic
    );
  end component FCCC_C0;

begin

  u_cam_clks_0 : FCCC_C0
  port map (
    CLK0 => I_REF_CLK,
    GL0  => O_SYS_CLK,
    GL1  => O_CAM_XCLK,
    LOCK => O_LOCK
  );

  -- TODO: reset sync and let out once locked
end architecture rtl;