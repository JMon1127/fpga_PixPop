-------------------------------------------------------------------------------
-- Title       : Camera Data CDC
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : cam_data_cdc_wrap.vhd
-- Author      : J. I. Montes
-- Company     : [Organization, if applicable]
-- Created     : [2025-05-31]
-- Last Update : [YYYY-MM-DD]
-- Platform    : Microsemi Igloo2 TODO: add PN
-- Description : This block is wrapper for the Camera Data CDC FIFO
--
-- Dependencies: [List any external modules/packages if applicable]
--
-- Revision History:
--   Date        Author        Description
--   2025-05-31  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer (if applicable)
-- This code is distributed under the terms of [license].
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cam_data_cdc_wrap is
  port (
    I_PIXEL_DATA  : in std_logic_vector(15 downto 0);
    I_PIXEL_VALID : in std_logic;
    I_PIXEL_CLK   : in std_logic;
    I_PIXEL_RST_N : in std_logic;
    I_SYS_CLK     : in std_logic;
    I_SYS_RST_N   : in std_logic;

    O_PIXEL_DATA  : out std_logic_vector(15 downto 0);
    O_PIXEL_VALID : out std_logic

  );
  end cam_data_cdc_wrap;

architecture rtl of cam_data_cdc_wrap is
  signal s_fifo_rd_en       : std_logic;
  signal s_fifo_aempty_flg : std_logic;
begin
  -- TODO: add logic to make the fifo streaming
  u_cam_data_cdc : entity work.cam_data_cdc
  port map (
    DATA     => I_PIXEL_DATA,
    RCLOCK   => I_PIXEL_CLK,
    RE       => s_fifo_rd_en,
    RRESET_N => I_SYS_RST_N,
    WCLOCK   => I_SYS_CLK,
    WE       => I_PIXEL_VALID, -- write to the fifo whenever pixel is valid
    WRESET_N => I_PIXEL_RST_N,

    AEMPTY   => s_fifo_aempty_flg,
    DVLD     => O_PIXEL_VALID,
    EMPTY    => open,
    FULL     => open,
    Q        => O_PIXEL_DATA
  );

end architecture rtl;