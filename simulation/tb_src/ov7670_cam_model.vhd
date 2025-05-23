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
    I_CAM_XCLK  : in  std_logic;

    -- O_CAM_DATA  : out std_logic_vector(7 downto 0);
    O_CAM_PCLK  : out std_logic;
    O_CAM_VSYNC : out std_logic;
    O_CAM_HREF  : out std_logic
  );
end ov7670_cam_model;

architecture rtl of ov7670_cam_model is
  --------------------
  -- Constants
  --------------------
  constant c_col           : integer := 640;
  constant c_row           : integer := 480;

  constant c_vsync_time_hi : integer := 4704;                                               -- vsync is high for 3*Tline. where Tline = 784*Tp and Tp = 2*Tpclk
  constant c_vsync_time_lo : integer := 794976;                                             -- vsync low for 507*Tline
  constant c_total_pclk    : integer := c_vsync_time_hi + c_vsync_time_lo;                  -- total pclks in a frame
  constant c_href_lo_init  : integer := 31360;                                              -- once vsync rises, href will rise after 20*Tline
  constant c_href_time_hi  : integer := 1280;                                               -- href is high for 640*Tp
  constant c_href_time_lo  : integer := 288;                                                -- after href is high it goes low for 144*Tp
  constant c_href_low_fin  : integer := 15680;                                              -- once href goes low for final time, vsync will go high after 10*Tline
  constant c_href_end      : integer := (c_vsync_time_hi + c_vsync_time_lo)-c_href_low_fin; -- denotes once href will no longer toggle
  constant c_tline         : integer := 1568;
  --------------------
  -- Signals
  --------------------
  signal s_pclk_cntr : integer   := 0;   -- counts the total pclks in a frame
  signal s_href_cntr : integer   := 0;   -- counter to assist with href toggling

  signal s_cam_vsync : std_logic := '0'; -- signal to drive the vsync output
  signal s_cam_href  : std_logic := '0'; -- signal to drive the href output

begin
  O_CAM_PCLK  <= I_CAM_XCLK; -- trying this for giggles
  O_CAM_VSYNC <= s_cam_vsync;
  O_CAM_HREF  <= s_cam_href;

  -- process to count the number of pclks
  -- according to datasheet is should be 510*Tline
  proc_cnt_pclk : process (I_CAM_XCLK)
  begin
    if(rising_edge(I_CAM_XCLK)) then
      -- check if the max has been hit, reset count
      if(s_pclk_cntr = c_total_pclk-1) then
        s_pclk_cntr <= 0;
      else
        s_pclk_cntr <= s_pclk_cntr + 1;
      end if;
    end if;
  end process;

  -- process to generate vsync output
  proc_vsync_gen : process (I_CAM_XCLK)
  begin
    if(rising_edge(I_CAM_XCLK)) then
      -- check pclk counter is 0, indicating start of frame
      if(s_pclk_cntr = 0) then
        s_cam_vsync <= '1';
      -- check if vsync has been high long enough
      elsif(s_pclk_cntr = c_vsync_time_hi-1) then
        s_cam_vsync <= '0';
      end if;
    end if;
  end process;

  proc_track_href : process (I_CAM_XCLK)
  begin
    if(rising_edge(I_CAM_XCLK)) then
      -- only count when href should be toggling
      if((s_pclk_cntr >= c_href_lo_init-1) and (s_pclk_cntr <= c_href_end-1)) then
        if(s_href_cntr = c_tline-1) then
          s_href_cntr <= 0;
        else
          s_href_cntr <= s_href_cntr + 1;
        end if;
      end if;
    end if;
  end process;

  -- process to generate HREF
  -- according to datasheet HREF goes high after 20*Tline
  -- it then stays high for 640*Tp
  proc_href_gen : process (I_CAM_XCLK)
  begin
    if(rising_edge(I_CAM_XCLK)) then
      -- check to see if HREF should be toggling
      if((s_pclk_cntr >= c_href_lo_init-1) and (s_pclk_cntr <= c_href_end-1)) then
        if(s_href_cntr = 0) then
          s_cam_href <= '1';
        --per datasheet href goes low after 640*Tp
        elsif(s_href_cntr = (c_col*2)-1) then
          s_cam_href <= '0';
        end if;
      else
        s_cam_href <= '0';
      end if;
    end if;
  end process;

  -- TODO: generate data

  -- acorrding to data sheet from rising edge to rising edge is 510*tline
  -- vsync is only high for 3*tline.
  -- once vsync goes low HREF should rise at 17*tline
  -- tline = 784*tp where tp is 2*PCLK if RGB mode
end architecture rtl;