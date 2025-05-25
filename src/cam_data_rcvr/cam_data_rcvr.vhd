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
    I_CAM_HREF  : in std_logic

    -- output stream interface
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
  constant c_max_row : integer := 480;
  constant c_max_col : integer := 640;

  --------------------
  -- Signals
  --------------------
  signal s_cam_data_rcvr       : sm_cam_rcvr := tIdleVsync;

  signal s_sys_rst_n_dly       : std_logic;
  signal s_rst_n_sync1         : std_logic;
  signal s_rst_n_slow          : std_logic;

  signal s_cam_vsync_prev      : std_logic; -- used for rising edge detect
  signal s_cam_href_prev       : std_logic; -- used for rising edge detect

  signal s_pix_data            : std_logic_vector(15 downto 0);

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
            s_cam_data_rcvr <= tDataCapture;
          end if;
        when tDataCapture =>

      end case;
    end if;
  end process;
  -- TODO: once data is sampled it should then be crossed to the system clock
  -- I'm thinking of using a dual clock fifo
  -- but it may be a good idea to just use BRAM will have to check if microsemi has dual port/clock bram
  -- igloo2 seems to call them LSRAM, once the data is set an address and write enable must be set too
  -- the camera outputs 640x480 pixels so 307200 total. each pixel is 2 bytes so 614400 total bytes
  -- it seems that the lsram would not be able to hold a full frame...
  -- i may have to do a line buffer implmentation instead


end architecture rtl;