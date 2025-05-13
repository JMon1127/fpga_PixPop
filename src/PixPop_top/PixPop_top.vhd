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
    REF_CLK   : IN STD_LOGIC;
    SYS_RST_N : IN STD_LOGIC

    --will need ports for the camera interface
    --eventually need to also transmit somehow

    -- since we arent having a soft core proc yet i think minimal control will be with switches on board
    -- eventually can look into adding a proc... or could also connect one externally
  );
end PixPop_top;

architecture structural of PixPop_top is
  --------------------
  -- Signals
  --------------------

begin
  -- TODO: will have a smart design here

  -- TODO: need data receiver block

  -- Will need a data proc block

  -- will need a data transmit block
end structural;