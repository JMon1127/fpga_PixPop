-------------------------------------------------------------------------------
-- Title       : Camera Data CDC
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : cam_data_cdc_wrap.vhd
-- Author      : J. I. Montes
-- Created     : [2025-05-31]
-- Last Update : [2025-05-31]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : This block is the wrapper for the Camera Data CDC FIFO.
--               Handles camera data domain cross from the camera pixel clock
--               domain to the system clock domain.
--
-- Dependencies: Microsemi CoreFIFO IP component
--
-- Revision History:
--   Date        Author        Description
--   2025-05-31  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
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

  --------------------
  -- Components
  --------------------
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

  --------------------
  -- Signals
  --------------------
  signal s_fifo_rd_en : std_logic;
  signal s_fifo_empty : std_logic;

begin

  -- Instantiate FIFO used to domain cross from pixel clock to system clock domain
  -- FIFO is 16 wide by 16 deep
  u_cam_data_cdc_fifo : cam_data_cdc
  port map (
    DATA     => I_PIXEL_DATA,
    RCLOCK   => I_SYS_CLK,
    RE       => s_fifo_rd_en,
    RRESET_N => I_SYS_RST_N,
    WCLOCK   => I_PIXEL_CLK,
    WE       => I_PIXEL_VALID, -- writes to the fifo whenever pixel is valid
    WRESET_N => I_PIXEL_RST_N,

    DVLD     => O_PIXEL_VALID,
    EMPTY    => s_fifo_empty,
    FULL     => open,          -- full flag unused
    Q        => O_PIXEL_DATA
  );

  -- read from the fifo whenever it is not empty
  s_fifo_rd_en <= '1' when s_fifo_empty = '0' else '0';

end architecture rtl;