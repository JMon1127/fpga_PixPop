-------------------------------------------------------------------------------
-- Title       : Sobel Edge Detection
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : sobel_edge_det.vhd
-- Author      : J. I. Montes
-- Created     : [2025-08-10]
-- Last Update : [2025-08-10]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : Implements the Sobel edge detection algorithm
--
-- Dependencies: None
--
-- Revision History:
--   Date        Author        Description
--   2025-08-10  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sobel_edge_det is
  generic (
    G_PIXEL_SIZE       : integer := 8;   -- grayscale pixel size
    G_IMG_ROW_SIZE     : integer := 640; -- number of pixels in a row
    G_NUM_LINES        : integer := 480; -- number of rows in image
    G_LB_ADDRESS_WIDTH : integer := 10   -- address width for line buffers
  );
  port (
    SYS_CLK         : in std_logic;
    SYS_RST_N       : in std_logic;

    I_GS_DATA       : in std_logic_vector(G_PIXEL_SIZE - 1 downto 0);
    I_GS_DATA_VALID : in std_logic
  );
  end sobel_edge_det;

architecture rtl of sobel_edge_det is
  --------------------
  -- Constants
  --------------------

  --------------------
  -- Types
  --------------------
  type t_line_buffer is array (0 to G_IMG_ROW_SIZE-1) of std_logic_vector(G_PIXEL_SIZE - 1 downto 0);
  type t_window3x3   is array (0 to 2, 0 to 2) of signed(G_PIXEL_SIZE - 1 downto 0);

  --------------------
  -- Signals
  --------------------
  signal s_window3x3 : t_window3x3;

  signal s_pixel_sr : STD_LOGIC_VECTOR(3*(G_PIXEL_SIZE-1) downto 0); -- holds 3 pixels

  -- counters
  signal s_col_cnt : integer := 0;
  signal s_row_cnt : integer := 0;

  -- line buffers
  signal s_line_buffer0, s_line_buffer1 : t_line_buffer;
  signal s_lb_wr_addr : unsigned(G_LB_ADDRESS_WIDTH - 1 downto 0);
  signal s_lb_rd_addr : unsigned(G_LB_ADDRESS_WIDTH - 1 downto 0);

begin

  -- Counters to track incoming pixels
  process (SYS_CLK, SYS_RST_N)
  begin
    if(SYS_RST_N = '0') then
      s_col_cnt <= 0;
      s_row_cnt <= 0;
    elsif(rising_edge(SYS_CLK)) then
      -- check for valid pixel
      if(I_GS_DATA_VALID = '1') then
        if(s_row_cnt = G_NUM_LINES - 1 and s_col_cnt = G_IMG_ROW_SIZE - 1) then
          s_row_cnt <= 0;
          s_col_cnt <= 0;
        elsif(s_col_cnt = G_IMG_ROW_SIZE - 1) then
          s_col_cnt <= 0;
          s_row_cnt <= s_row_cnt + 1;
        else
          s_col_cnt <= s_col_cnt + 1;
        end if;
      end if;
    end if;
  end process;



end architecture rtl;