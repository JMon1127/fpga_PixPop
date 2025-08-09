-------------------------------------------------------------------------------
-- Title       : Line Buffer
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : line_buf.vhd
-- Author      : J. I. Montes
-- Created     : [2025-08-03]
-- Last Update : [2025-08-03]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : Line buffer for image data
--
-- Dependencies: None
--
-- Revision History:
--   Date        Author        Description
--   2025-08-03  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity line_buf is
  generic (
    pixel_size    : integer := 8;
    img_row_size  : integer := 640;
    address_width : integer := 16
  );
  port (
    SYS_CLK          : in std_logic;

    I_WR_DATA        : in std_logic_vector(pixel_size-1 downto 0);
    I_WR_EN          : in std_logic;
    I_WR_ADDR        : in std_logic_vector((address_width - 1) downto 0);
    I_RD_ADDR        : in std_logic_vector((address_width - 1) downto 0);

    O_RD_DATA        : out std_logic_vector(pixel_size-1 downto 0)
  );
end line_buf;

architecture rtl of line_buf is
  --------------------
  -- Types
  --------------------
  type t_line_buffer is array (0 to img_row_size-1) of std_logic_vector(pixel_size-1 downto 0);

  --------------------
  -- Signals
  --------------------
  signal s_line_buffer : t_line_buffer;
  signal s_rd_addr_reg : std_logic_vector((address_width - 1) downto 0);

begin

  -- write operation
  process (SYS_CLK)
  begin
    if(rising_edge(SYS_CLK)) then
      s_rd_addr_reg <= I_RD_ADDR;
      -- check for write enable
      if(I_WR_EN = '1') then
        s_line_buffer(to_integer(unsigned(I_WR_ADDR))) <= I_WR_DATA;
      end if;
    end if;
  end process;

  -- read operation
  O_RD_DATA <= s_line_buffer(to_integer(unsigned(s_rd_addr_reg)));

end architecture rtl;