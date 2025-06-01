-------------------------------------------------------------------------------
-- Title       : Camera Data Receiver
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : cam_data_rcvr.vhd
-- Author      : J. I. Montes
-- Company     : [Organization, if applicable]
-- Created     : [2025-05-12]
-- Last Update : [YYYY-MM-DD]
-- Platform    : Microsemi Igloo2 TODO: add PN
-- Description : This block receives parallel data from the OV7670 camera.
--               The parallel data is converted to AXI stream.
--
-- Dependencies: [List any external modules/packages if applicable]
--
-- Revision History:
--   Date        Author        Description
--   2025-05-12  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer (if applicable)
-- This code is distributed under the terms of [license].
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cam_data_rcvr is
  port (
    SYS_CLK     : in std_logic;
    SYS_RST_N   : in std_logic;

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
  type sm_cam_rcvr is ( tIdleVsync, -- waits for vsync pulse
                        tIdleHref,  -- waits for Href start
                        tDataCapture
                      );
  --------------------
  -- Constants
  --------------------
  constant c_row               : integer := 480;
  constant c_col               : integer := 640;

  --------------------
  -- Signals
  --------------------
  signal s_cam_data_rcvr       : sm_cam_rcvr := tIdleVsync;

  signal s_sys_rst_n_dly       : std_logic;
  signal s_rst_n_sync1         : std_logic;
  signal s_rst_n_slow          : std_logic;

  signal s_cam_vsync_prev      : std_logic; -- used for rising edge detect
  signal s_cam_href_prev       : std_logic; -- used for rising edge detect

  signal s_pix_msb             : std_logic_vector( 7 downto 0); -- stores the most significant byte of pixel data
  signal s_pix_cap_msb         : std_logic;                     -- msB should be captured
  signal s_pix_data            : std_logic_vector(15 downto 0);
  signal s_col_cntr            : integer := 0;
  signal s_row_cntr            : integer := 0;
  signal s_pix_valid           : std_logic; -- indicates a captured pixel is valid

  -- TODO: will need some counters to keep track of row/col or maybe even just total pixel

begin
  --TODO: sync the reset to the slower clock
  proc_rst_dly : process (SYS_CLK)
  begin
    if(rising_edge(SYS_CLK)) then
      s_sys_rst_n_dly <= SYS_RST_N;
    end if;
  end process;

  proc_rst_sync : process (I_CAM_PCLK)
  begin
    if(rising_edge(I_CAM_PCLK)) then
      s_rst_n_sync1 <= s_sys_rst_n_dly;
      s_rst_n_slow  <= s_rst_n_sync1;
    end if;
  end process;

  proc_cam_data_rcvr : process (s_rst_n_slow, I_CAM_PCLK)
  begin
    if(s_rst_n_slow = '0') then
      s_cam_data_rcvr <= tIdleVsync;
      s_pix_data      <= (others => '0');
      s_pix_msb       <= (others => '0');
      s_pix_cap_msb   <= '0';
      s_cam_href_prev <= '0';
      s_col_cntr      <= 0;
      s_row_cntr      <= 0;
      s_pix_valid     <= '0';
    elsif(rising_edge(I_CAM_PCLK)) then
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
            -- TODO: at this point there is valid data on the bus
            s_pix_msb       <= I_CAM_DATA;
            s_pix_cap_msb   <= '0';
            s_cam_data_rcvr <= tDataCapture;
          end if;
        when tDataCapture =>
          s_cam_href_prev <= I_CAM_HREF;
          s_pix_valid     <= s_cam_href_prev; -- indicate a valid pixel was captured

          -- check if msB should be captured or form full pixel word data
          if(s_pix_cap_msb = '1') then
            s_pix_msb     <= I_CAM_DATA;
            s_pix_cap_msb <= '0';
          else
            if(s_cam_href_prev = '1') then
              s_pix_data    <= s_pix_msb & I_CAM_DATA;
              s_col_cntr    <= s_col_cntr + 1;
            end if;

            if(s_row_cntr = c_row) then
              s_row_cntr <= 0;
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

  -- TODO: once data is sampled it should then be crossed to the system clock 125MHz
  -- I'm thinking of using a dual clock fifo
  -- From there the data will be passed to a line buffer module
  -- great it seems that microsemi does not have a streaming fifo...
  -- i will probably have to use their CoreFIFO ip and add my own logic to make it streaming... smh
  u_cam_data_cdc : entity work.cam_data_cdc_wrap
  port map (
    I_PIXEL_DATA  => s_pix_data,
    I_PIXEL_VALID => s_pix_valid,
    I_PIXEL_CLK   => I_CAM_PCLK,
    I_PIXEL_RST_N => s_rst_n_slow,
    I_SYS_CLK     => SYS_CLK,
    I_SYS_RST_N   => SYS_RST_N,

    O_PIXEL_DATA  => O_PIX_DATA,
    O_PIXEL_VALID => O_PIX_VALID
  );


end architecture rtl;