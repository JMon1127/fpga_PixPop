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
  signal s_red8          : std_logic_vector(7 downto 0); -- scaled 5 bit red to 8 bits
  signal s_green8        : std_logic_vector(7 downto 0); -- scaled 6 bit green to 8 bits
  signal s_blue8         : std_logic_vector(7 downto 0); -- scaled 5 bit blue to 8 bits
  signal s_red5          : std_logic_vector(4 downto 0); -- og 5 bit red from 16 bit input
  signal s_green6        : std_logic_vector(5 downto 0); -- og 6 bit green from 16 bit input
  signal s_blue5         : std_logic_vector(4 downto 0); -- og 5 bit blue from 16 bit input
  signal s_split_valid   : std_logic;                    -- indicates the split RGB data is valid
  signal s_scale_valid   : std_logic;                    -- indicates the scaled data is valid
  signal s_gs_temp_valid : std_logic;                    -- indicates the gs data before shifting is valid
  signal s_gs_temp       : unsigned(15 downto 0);        -- grayscale data prior to shifting

begin

  -- start with splitting the RGB components
  process (SYS_CLK, SYS_RST_N)
  begin
    if(SYS_RST_N = '0') then
      s_red5        <= (others => '0');
      s_green6      <= (others => '0');
      s_blue5       <= (others => '0');
      s_split_valid <= '0';
    elsif(rising_edge(SYS_CLK)) then
      -- ensure input data is valid
      if(I_RGB_DATA_VALID = '1') then
        s_red5   <= I_RGB_DATA(15 downto 11);
        s_green6 <= I_RGB_DATA(10 downto  5);
        s_blue5  <= I_RGB_DATA( 4 downto  0);
      end if;

      s_split_valid <= I_RGB_DATA_VALID;
    end if;
  end process;

  -- scale the RGB components to 8 bits
  process (SYS_CLK, SYS_RST_N)
  begin
    if(SYS_RST_N = '0') then
      s_red8        <= (others => '0');
      s_green8      <= (others => '0');
      s_blue8       <= (others => '0');
      s_scale_valid <= '0';
    elsif(rising_edge(SYS_CLK)) then
      if(s_split_valid = '1') then
        s_red8   <= s_red5 & s_red5(4 downto 2);
        s_green8 <= s_green6 & s_green6(5 downto 4);
        s_blue8  <= s_blue5 & s_blue5(4 downto 2);
      end if;

      s_scale_valid <= s_split_valid;
    end if;
  end process;

  -- using the following formula for RGB => GS
  -- GS = (38*R + 76*G + 14*B)/128
  process (SYS_CLK, SYS_RST_N)
  begin
    if(SYS_RST_N = '0') then
      s_gs_temp       <= (others => '0');
      s_gs_temp_valid <= '0';
    elsif(rising_edge(SYS_CLK)) then
      if(s_scale_valid = '1') then
        s_gs_temp <=  (unsigned(s_red8) * 38)
                    + (unsigned(s_green8) * 76)
                    + (unsigned(s_blue8) * 14);
      end if;

      s_gs_temp_valid <= s_scale_valid;
    end if;
  end process;

  -- right shift 7 times is the same as divide by 128
  O_GS_DATA       <= std_logic_vector(s_gs_temp(14 downto 7));
  O_GS_DATA_VALID <= s_gs_temp_valid;


end architecture rtl;