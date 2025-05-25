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

    -- O_CAM_DATA  : out std_logic_vector(7 downto 0);
    O_CAM_PCLK  : out std_logic;
    O_CAM_VSYNC : out std_logic;
    O_CAM_HREF  : out std_logic
  );
end ov7670_cam_model;

architecture rtl of ov7670_cam_model is
  type sm_cam_timing is ( tReset,
                          tVsync_pulse,
                          tVsync_blank,
                          tHref,
                          tFrame_end
                        );

  signal s_drive_cam : sm_cam_timing;

  signal s_vsync : std_logic;
  signal s_href  : std_logic;
  signal s_vsync_hi_cntr : integer := 0;
  signal s_vsync_lo_cntr : integer := 0;
  signal s_href_cntr     : integer := 0;

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
          s_drive_cam <= tVsync_pulse;
        when tVsync_pulse =>
            s_vsync <= '1';
            if(s_vsync_hi_cntr = 4704 -1) then
              s_vsync_hi_cntr <= 0;
              s_drive_cam     <= tVsync_blank;
            else
              s_vsync_hi_cntr <= s_vsync_hi_cntr + 1;
            end if;
        when tVsync_blank =>
          s_vsync <= '0';
          if(s_vsync_lo_cntr = 26656 -1) then
            s_vsync_lo_cntr <= 0;
            s_drive_cam     <= tHref;
          else
            s_vsync_lo_cntr <= s_vsync_lo_cntr + 1;
          end if;
        when tHref        =>
          if(s_href_cntr = 1568 - 1) then
            s_href_cntr <= 0;
          else
            s_href_cntr <= s_href_cntr + 1;
          end if;

          if(s_href_cntr <= 1280 - 1) then
            s_href <= '1';
          else
            s_href <= '0';
          end if;
        when tFrame_end   =>
      end case;
    end if;
  end process;

end architecture rtl;