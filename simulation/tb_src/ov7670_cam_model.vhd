-------------------------------------------------------------------------------
-- Title       : OV7670 Camera Model
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : ov7670_cam_model.vhd
-- Author      : J. I. Montes
-- Company     : [Organization, if applicable]
-- Created     : [2025-05-22]
-- Last Update : [YYYY-MM-DD]
-- Platform    : Microsemi Igloo2 TODO: add PN
-- Description : VHDL simulation model of the OV7670 camera
--
-- Dependencies: [List any external modules/packages if applicable]
--
-- Revision History:
--   Date        Author        Description
--   2025-05-22  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer (if applicable)
-- This code is distributed under the terms of [license].
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ov7670_cam_model is
  port (
    I_CAM_XCLK  : in  std_logic;

    O_CAM_DATA  : out std_logic_vector(7 downto 0);
    O_CAM_PCLK  : out std_logic;
    O_CAM_VSYNC : out std_logic;
    O_CAM_HREF  : out std_logic;
  );
end ov7670_cam_model;

architecture rtl of ov7670_cam_model is

begin

end architecture rtl;