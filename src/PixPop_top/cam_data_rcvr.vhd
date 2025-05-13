-------------------------------------------------------------------------------
-- Title       : Camera Data Receiver
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : cam_data_rcvr.vhd
-- Author      : J. I. Montes
-- Company     : [Organization, if applicable]
-- Created     : [2025-05-12]
-- Last Update : [YYYY-MM-DD]
-- Platform    : Microsemi Igloo2 TODO: add PN
-- Description : This block receives parallel data from the OV7670 camera.
--               The parallel data is converted to AXI stream.
--
-- Dependencies: [List any external modules/packages if applicable]
--
-- Revision History:
--   Date        Author        Description
--   2025-05-12  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer (if applicable)
-- This code is distributed under the terms of [license].
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cam_data_rcvr is
  port (
    SYS_CLK     : in STD_LOGIC;
    SYS_RST_N   : in STD_LOGIC;

    I_CAM_DATA  : in STD_LOGIC_VECTOR(7 downto 0);
    I_CAM_PCLK  : in STD_LOGIC;
    I_CAM_VSYNC : in STD_LOGIC;
    I_CAM_HREF  : in STD_LOGIC

    -- output stream interface
  );
end cam_data_rcvr;

architecture behavorial of cam_data_rcvr is
  --------------------
  -- Signals
  --------------------

begin



end behavorial;