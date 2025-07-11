-------------------------------------------------------------------------------
-- Title       : Camera Data Receiver
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : cam_data_rcvr.vhd
-- Author      : J. I. Montes
-- Created     : [2025-05-12]
-- Last Update : [2025-05-12]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : This block receives parallel data from the OV7670 camera.
--               2 byte pixels are formed and written to a FIFO which handles
--               domain cross safely into the system domain.
--
-- Dependencies: cam_data_cdc_wrap.vhd
--
-- Revision History:
--   Date        Author        Description
--   2025-05-12  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cam_data_rcvr is
  port (
    SYS_CLK     : in std_logic;
    SYS_RST_N   : in std_logic;
    PCLK_RST_N  : in std_logic;

    I_CAM_DATA  : in std_logic_vector(7 downto 0);
    I_CAM_PCLK  : in std_logic;
    I_CAM_VSYNC : in std_logic;
    I_CAM_HREF  : in std_logic;

    -- output stream interface
    O_PIX_DATA  : out std_logic_vector(15 downto 0);
    O_PIX_VALID : out std_logic
  );
end cam_data_rcvr;

architecture rtl of cam_data_rcvr is
  --------------------
  -- Types
  --------------------
  type sm_cam_rcvr is ( tIdleVsync,  -- waits for vsync pulse
                        tIdleHref,   -- waits for Href start
                        tDataCapture -- capturing data and forming 2 byte pixels
                      );

  --------------------
  -- Constants
  --------------------
  constant c_row               : integer := 480; -- total number of active rows
  constant c_col               : integer := 640; -- total number of active columns

  --------------------
  -- Signals
  --------------------
  signal s_cam_data_rcvr       : sm_cam_rcvr := tIdleVsync;

  signal s_cam_vsync_prev      : std_logic; -- used for rising edge detect of vsync
  signal s_cam_href_prev       : std_logic; -- used for rising edge detect of href

  signal s_pix_msb             : std_logic_vector( 7 downto 0); -- stores the most significant byte of pixel data
  signal s_pix_cap_msb         : std_logic;                     -- indicates msB should be captured
  signal s_pix_data            : std_logic_vector(15 downto 0); -- 2 byte pixel data
  signal s_pix_valid           : std_logic;                     -- indicates a captured pixel is valid
  signal s_col_cntr            : integer := 0;                  -- counter to track columns
  signal s_row_cntr            : integer := 0;                  -- counter to track rows

begin

  -- State machine to capture data
  proc_cam_data_rcvr : process (PCLK_RST_N, I_CAM_PCLK)
  begin
    if(PCLK_RST_N = '0') then
      s_cam_data_rcvr <= tIdleVsync;
      s_pix_data      <= (others => '0');
      s_pix_msb       <= (others => '0');
      s_pix_cap_msb   <= '0';
      s_cam_href_prev <= '0';
      s_col_cntr      <= 0;
      s_row_cntr      <= 0;
      s_pix_valid     <= '0';
    elsif(rising_edge(I_CAM_PCLK)) then
      -- default state for pixel valid
      s_pix_valid <= '0';

      case s_cam_data_rcvr is
        when tIdleVsync   =>
          -- sample vsync in order to detect rising edge and advance state
          s_cam_vsync_prev <= I_CAM_VSYNC;

          if(s_cam_vsync_prev = '0' and I_CAM_VSYNC = '1') then
            s_cam_data_rcvr <= tIdleHref;
          end if;
        when tIdleHref    =>
          -- sample href in order to detect rising edge and advance state
          s_cam_href_prev <= I_CAM_HREF;

          if(s_cam_href_prev = '0' and I_CAM_HREF = '1') then
            -- at this point there is valid data on the bus so capture it
            s_pix_msb       <= I_CAM_DATA;
            s_pix_cap_msb   <= '0';
            s_cam_data_rcvr <= tDataCapture;
          end if;
        when tDataCapture =>
          -- check if msB should be captured or form full pixel word data
          if(s_pix_cap_msb = '1') then
            s_pix_msb     <= I_CAM_DATA;
            s_pix_cap_msb <= '0';
          else
            if(I_CAM_HREF = '1') then
              s_pix_data  <= s_pix_msb & I_CAM_DATA;
              s_pix_valid <= '1';
              s_col_cntr  <= s_col_cntr + 1;
            end if;

            if(s_row_cntr = (c_row-1) and (s_col_cntr = c_col)) then
              s_row_cntr <= 0;
              s_col_cntr <= 0;
              s_cam_data_rcvr <= tIdleVsync;
            elsif(s_col_cntr = c_col) then
              s_row_cntr <= s_row_cntr + 1;
              s_col_cntr <= 0;
            end if;

            s_pix_cap_msb <= '1';
          end if;

      end case;
    end if;
  end process;

  -- Instantiate CDC wrapper
  -- Contains dual clock FIFO with write/read logic to handle domain cross safely
  u_cam_data_cdc : entity work.cam_data_cdc_wrap
  port map (
    I_PIXEL_DATA  => s_pix_data,
    I_PIXEL_VALID => s_pix_valid,
    I_PIXEL_CLK   => I_CAM_PCLK,
    I_PIXEL_RST_N => PCLK_RST_N,
    I_SYS_CLK     => SYS_CLK,
    I_SYS_RST_N   => SYS_RST_N,

    O_PIXEL_DATA  => O_PIX_DATA,
    O_PIXEL_VALID => O_PIX_VALID
  );

end architecture rtl;