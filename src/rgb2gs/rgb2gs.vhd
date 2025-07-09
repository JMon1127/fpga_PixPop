-------------------------------------------------------------------------------
-- Title       : RGB to Grayscale
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : rgb2gs.vhd
-- Author      : J. I. Montes
-- Created     : [2025-07-08]
-- Last Update : [2025-07-08]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : This block takes in RGB565 data and converts it to grayscale
--
-- Dependencies: cam_data_cdc_wrap.vhd
--
-- Revision History:
--   Date        Author        Description
--   2025-07-08  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rgb2gs is
    port (
        SYS_CLK          : in std_logic;
        SYS_RST_N        : in std_logic;

        I_RGB_DATA       : in std_logic_vector(15 downto 0);
        I_RGB_DATA_VALID : in std_logic;

        O_GS_DATA        : out std_logic_vector(7 downto 0);
        O_GS_DATA_VALID  : out std_logic
    );
end rgb2gs;

architecture rtl of rgb2gs is
  --------------------
  -- Signals
  --------------------
  signal s_red   : std_logic_vector(7 downto 0); -- scales 5 bit red to 8 bits
  signal s_green : std_logic_vector(7 downto 0); -- scales 6 bit green to 8 bits
  signal s_blue  : std_logic_vector(7 downto 0); -- scales 5 bit blue to 8 bits

begin



end architecture rtl;