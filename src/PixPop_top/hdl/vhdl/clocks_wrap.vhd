-------------------------------------------------------------------------------
-- Title       : Clock Management
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : clocks_wrap.vhd
-- Author      : J. I. Montes
-- Company     : [Organization, if applicable]
-- Created     : [2025-06-01]
-- Last Update : [YYYY-MM-DD]
-- Platform    : Microsemi Igloo2 TODO: add PN
-- Description : This block is a wrapper for clocks generated using CCC
--
-- Dependencies: [List any external modules/packages if applicable]
--
-- Revision History:
--   Date        Author        Description
--   2025-06-01  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer (if applicable)
-- This code is distributed under the terms of [license].
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clocks_wrap is
  port (
    I_REF_CLK : in std_logic;
    O_SYS_CLK : out std_logic;
    O_LOCK    : out std_logic
  );
  end clocks_wrap;

architecture rtl of clocks_wrap is

  component FCCC_C0 is
    port (
      CLK0 : in std_logic;
      GL0  : out std_logic;
      LOCK : out std_logic
    );
  end component FCCC_C0;

begin

  u_cam_clks_0 : FCCC_C0
  port map (
    CLK0 => I_REF_CLK,
    GL0  => O_SYS_CLK,
    LOCK => O_LOCK
  );


end architecture rtl;