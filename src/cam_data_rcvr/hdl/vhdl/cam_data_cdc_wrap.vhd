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

  component cam_data_cdc
    port (
      DATA     : in std_logic_vector(15 downto 0);
      RCLOCK   : in std_logic;
      RE       : in std_logic;
      RRESET_N : in std_logic;
      WCLOCK   : in std_logic;
      WE       : in std_logic;
      WRESET_N : in std_logic;

      DVLD     : out std_logic;
      EMPTY    : out std_logic;
      FULL     : out std_logic;
      Q        : out std_logic_vector(15 downto 0)
    );
    end component cam_data_cdc;

  signal s_fifo_rd_en : std_logic;

  -- TODO: remove
  signal s_fifo_empty : std_logic;
  signal s_fifo_full : std_logic;

begin
  -- TODO: add logic to make the fifo streaming
  u_cam_data_cdc_fifo : cam_data_cdc
  port map (
    DATA     => I_PIXEL_DATA,
    RCLOCK   => I_SYS_CLK,
    RE       => s_fifo_rd_en,
    RRESET_N => I_SYS_RST_N,
    WCLOCK   => I_PIXEL_CLK,
    WE       => I_PIXEL_VALID, -- write to the fifo whenever pixel is valid
    WRESET_N => I_PIXEL_RST_N,

    DVLD     => O_PIXEL_VALID,
    EMPTY    => s_fifo_empty,
    FULL     => s_fifo_full,
    Q        => O_PIXEL_DATA
  );

  proc_rd_fifo : process (I_SYS_CLK, I_SYS_RST_N)
  begin
    if(I_SYS_RST_N = '0') then
      s_fifo_rd_en <= '0';
    elsif(rising_edge(I_SYS_CLK)) then
      -- as long as fifo is not empty then keep reading from it
      if(s_fifo_empty = '0') then
        s_fifo_rd_en <= '1';
      else
        s_fifo_rd_en <= '0';
      end if;
    end if;
  end process;

end architecture rtl;