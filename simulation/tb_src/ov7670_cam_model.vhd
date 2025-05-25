-------------------------------------------------------------------------------
-- Title       : OV7670 Camera Model
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : ov7670_cam_model.vhd
-- Author      : J. I. Montes
-- Company     : [Organization, if applicable]
-- Created     : [2025-05-22]
-- Last Update : [YYYY-MM-DD]
-- Platform    : Microsemi Igloo2 TODO: add PN
-- Description : VHDL simulation model of the OV7670 camera
--
-- Dependencies: [List any external modules/packages if applicable]
--
-- Revision History:
--   Date        Author        Description
--   2025-05-22  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer (if applicable)
-- This code is distributed under the terms of [license].
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ov7670_cam_model is
  port (
    I_CAM_RST_N : in  std_logic;
    I_CAM_XCLK  : in  std_logic;

    O_CAM_DATA  : out std_logic_vector(7 downto 0);
    O_CAM_PCLK  : out std_logic;
    O_CAM_VSYNC : out std_logic;
    O_CAM_HREF  : out std_logic
  );
end ov7670_cam_model;

architecture rtl of ov7670_cam_model is
  --------------------
  -- Types
  --------------------
  type sm_cam_timing is ( tReset,
                          tVsync_pulse,
                          tVsync_blank,
                          tHref,
                          tFrame_end
                        );

  --------------------
  -- Constants
  --------------------
  constant c_vsync_pulse_width : integer := 4704;
  constant c_vsync_blank_width : integer := 26656;
  constant c_thref_width       : integer := 752640;
  constant c_href_cyc_width    : integer := 1568;
  constant c_href_hi_width     : integer := 1280;
  constant c_frame_end_width   : integer := 15680;

  --------------------
  -- Signals
  --------------------
  signal s_drive_cam     : sm_cam_timing := tReset;

  signal s_vsync         : std_logic;
  signal s_href          : std_logic;
  signal s_pix_data      : unsigned(7 downto 0);
  signal s_cntr          : integer := 0;
  signal s_thref_cntr    : integer := 0;

begin

  proc_cam_model : process (I_CAM_RST_N, I_CAM_XCLK)
  begin
    if(I_CAM_RST_N ='0') then
      s_drive_cam <= tReset;
    elsif(rising_edge(I_CAM_XCLK)) then
      case s_drive_cam is
        when tReset       =>
          s_vsync     <= '0';
          s_href      <= '0';
          s_pix_data  <= (others => '0');
          s_drive_cam <= tVsync_pulse;
        when tVsync_pulse =>
            s_vsync <= '1';
            -- vsync should be high for 3*Tline, where Tline = 784*2pclk
            if(s_cntr = c_vsync_pulse_width -1) then
              s_cntr      <= 0;
              s_drive_cam <= tVsync_blank;
            else
              s_cntr <= s_cntr + 1;
            end if;
        when tVsync_blank =>
          s_vsync <= '0';
          --vsync should be low for 17*Tline before driving Href
          if(s_cntr = c_vsync_blank_width -1) then
            s_cntr      <= 0;
            s_drive_cam <= tHref;
          else
            s_cntr      <= s_cntr + 1;
          end if;
        when tHref        =>
          -- href toggles for 480*Tline
          if(s_thref_cntr = c_thref_width - 1) then
            s_thref_cntr <= 0;
            s_drive_cam <= tFrame_end;
          else
            s_thref_cntr <= s_thref_cntr + 1;
          end if;

          -- href cycle is 784*2
          if(s_cntr = c_href_cyc_width - 1) then
            s_cntr <= 0;
          else
            s_cntr <= s_cntr + 1;
          end if;

          -- href is high for 640*2pclk
          if(s_cntr <= c_href_hi_width - 1) then
            s_href     <= '1';
            s_pix_data <= s_pix_data + 1;
          else
            s_href     <= '0';
            s_pix_data <= (others => '0');
          end if;
        when tFrame_end   =>
          -- wait 10*Tline before driving vsync high again
          if(s_cntr = c_frame_end_width -1) then
            s_cntr <= 0;
            s_drive_cam <= tVsync_pulse;
          else
            s_cntr <= s_cntr + 1;
          end if;
      end case;
    end if;
  end process;

  -- assign output ports
  O_CAM_PCLK  <= I_CAM_XCLK;
  O_CAM_DATA  <= std_logic_vector(s_pix_data);
  O_CAM_VSYNC <= s_vsync;
  O_CAM_HREF  <= s_href;
end architecture rtl;