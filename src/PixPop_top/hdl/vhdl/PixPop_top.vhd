-------------------------------------------------------------------------------
-- Title       : PixPop FPGA top level
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : PixPop_top.vhd
-- Author      : J. I. Montes
-- Company     : [Organization, if applicable]
-- Created     : [2025-05-11]
-- Last Update : [YYYY-MM-DD]
-- Platform    : Microsemi Igloo2 TODO: add PN
-- Description : Top level code for the PixPop FPGA
--
-- Dependencies: [List any external modules/packages if applicable]
--
-- Revision History:
--   Date        Author        Description
--   2025-05-11  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer (if applicable)
-- This code is distributed under the terms of [license].
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity PixPop_top is
  port(
    REF_CLK   : IN    STD_LOGIC;
    SYS_RST_N : IN    STD_LOGIC;

    --will need ports for the camera interface
    -- CAM_SCL   : OUT   STD_LOGIC; -- i2c clock for config
    -- CAM_SDA   : INOUT STD_LOGIC; -- i2c ata bus for config
    CAM_VSYNC : IN    STD_LOGIC; -- frame valid (active frame)
    CAM_HREF  : IN    STD_LOGIC; -- line data valid (active pixels)
    CAM_PCLK  : IN    STD_LOGIC; -- camera pixel clock
    CAM_XCLK  : OUT   STD_LOGIC; -- camera input clock
    CAM_DATA  : IN    STD_LOGIC_VECTOR(7 downto 0) -- 8 bit color data

    --eventually need to also transmit somehow

    -- since we arent having a soft core proc yet i think minimal control will be with switches on board
    -- eventually can look into adding a proc... or could also connect one externally
  );
end PixPop_top;

architecture rtl of PixPop_top is
  --------------------
  -- Signals
  --------------------

begin
  -- TODO: will have a smart design here
  -- this should drive the camera xclk

  -- TODO: need data receiver block
  -- this should receive the camera sync/ref, pclk and data
  -- also this will probably be a good spot to convert the parallel data to stream
  -- Instantiate the data receiver block
  u_cam_rcvr : entity work.cam_data_rcvr
  port map (
    SYS_CLK     => REF_CLK, -- TODO: make this a faster clock than the 50MHz
    SYS_RST_N   => SYS_RST_N, -- TODO: may need ot get a reset that is synced to the PCLK domain

    I_CAM_DATA  => CAM_DATA,
    I_CAM_PCLK  => CAM_PCLK,
    I_CAM_VSYNC => CAM_VSYNC,
    I_CAM_HREF  => CAM_HREF,

    O_PIX_DATA  => open,
    O_PIX_VALID => open
  );
  -- Will need a data proc block
  -- here it will probably be a top level that selects between edge detect algo, normal color, or even grayscale

  -- will need a data transmit block
  -- this should take the strem from data proc block and perform the transmit logic

end architecture rtl;