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
  type sm_data_rcv is ( tIdle,
                        tWaitHREF,
                        tSamplePix_byte1,
                        tSamplePix_byte2
                      );

  --------------------
  -- Constants
  --------------------
  constant c_max_row : integer := 480;
  constant c_max_col : integer := 640;

  --------------------
  -- Signals
  --------------------
  signal s_data_rcv_cur_state  : sm_data_rcv;
  signal s_data_rcv_next_state : sm_data_rcv;

  signal s_cam_vsync_prev      : std_logic; -- used for rising edge detect
  signal s_cam_vsync_redge_flg : std_logic; -- flags rising edge

  signal s_cam_href_prev       : std_logic;
  signal s_cam_href_redge_flg  : std_logic;

  signal s_pix_data            : std_logic_vector(15 downto 0);

  signal s_row_cnt             : integer := 0; -- counter to track the rows, 480 total
  signal s_col_cnt             : integer := 0; -- counter to track the cols, 640 total

  -- TODO: will need some counters to keep track of row/col or maybe even just total pixel

begin
  --TODO: sync the reset to the slower clock

  -- this process samples the vsync signal
  -- start of frame is indicated by rising edge of vsync
  proc_vsync_edge : process (I_CAM_PCLK, SYS_RST_N)
  begin
    if(SYS_RST_N = '0') then
      s_cam_vsync_prev      <= '0';
      s_cam_vsync_redge_flg <= '0';
    elsif(rising_edge(I_CAM_PCLK)) then
      -- sample vsync
      s_cam_vsync_prev <= I_CAM_VSYNC;

      -- check for rising edge
      if(I_CAM_VSYNC = '1' and s_cam_vsync_prev = '0') then
        s_cam_vsync_redge_flg <= '1';
      else
        s_cam_vsync_redge_flg <= '0';
      end if;
    end if;
  end process proc_vsync_edge;

  -- maybe also sample the rising edges of HREF
  -- each rise of HREF will indicate a new row
  -- when HREF is toggling VSYNC is low
  proc_href_edge : process (I_CAM_PCLK, SYS_RST_N)
  begin
    if(SYS_RST_N = '0') then
      s_cam_href_prev      <= '0';
      s_cam_href_redge_flg <= '0';
    elsif(rising_edge(I_CAM_PCLK)) then
      -- sample href
      s_cam_href_prev <= I_CAM_HREF;

      -- check for rising edge
      if(I_CAM_HREF = '1' and s_cam_href_prev = '0') then
        s_cam_href_redge_flg <= '1';
      else
        s_cam_href_redge_flg <= '0';
      end if;
    end if;
  end process proc_href_edge;

  -- this process keeps track of the current row and column for the frame
  proc_cntrs : process (I_CAM_PCLK, SYS_RST_N)
  begin
    if(SYS_RST_N = '0') then
      s_row_cnt <= 0;
      s_col_cnt <= 0;
    elsif(rising_edge(I_CAM_PCLK)) then
      -- check to see if col should increment
      if(s_cam_href_redge_flg = '1' and s_col_cnt /= c_max_col-1) then
        s_col_cnt <= s_col_cnt + 1;
      else
        s_col_cnt <= 0;
      end if;

      --check ot see if row should increment
      if (s_cam_vsync_redge_flg = '1' and s_row_cnt /= c_max_row-1) then
        s_row_cnt <= s_row_cnt + 1;
      else
        s_row_cnt <= 0;
      end if;

    end if;
  end process;

  -- this process will drive the state machine through the states
  proc_sm_driver : process (I_CAM_PCLK, SYS_RST_N)
  begin
    if(SYS_RST_N = '0') then
      s_data_rcv_cur_state <= tIdle;
    elsif(rising_edge(I_CAM_PCLK)) then
      s_data_rcv_cur_state <= s_data_rcv_next_state;
    end if;
  end process proc_sm_driver;

  proc_sm_logic : process ( s_data_rcv_cur_state,
                            s_cam_vsync_redge_flg,
                            I_CAM_DATA,
                            I_CAM_HREF,
                            s_col_cnt,
                            s_row_cnt
                          )
  begin
    -- prevent latching
    s_data_rcv_next_state <= s_data_rcv_cur_state;

    -- TODO: this does not seem to follow the timing correctly yet
    case s_data_rcv_cur_state is
      when tIdle            =>
        -- stay idle until rising edge of vsync detected
        if(s_cam_vsync_redge_flg = '1') then
          s_data_rcv_next_state <= tWaitHREF;
        end if;
      when tWaitHREF        =>
        -- wait for new row (line)
        if(s_cam_href_redge_flg = '1') then
          s_data_rcv_next_state <= tSamplePix_byte1;
        end if;
      when tSamplePix_byte1 =>
        -- TODO: sample data on rising edge of pclk
        s_pix_data(15 downto 8) <= I_CAM_DATA;

        s_data_rcv_next_state <= tSamplePix_byte2;
      when tSamplePix_byte2 =>
        s_pix_data(7 downto 0) <= I_CAM_DATA;

        -- check to see if this is the same line and that we have not finished a full frame
        if(I_CAM_HREF = '1' and s_col_cnt /= c_max_col-1 and s_row_cnt /= c_max_row-1)  then
          s_data_rcv_next_state <= tSamplePix_byte1;
        -- check to see if the line has finished but not full frame
        elsif(s_col_cnt = c_max_col-1 and s_row_cnt /= c_max_row-1) then
          s_data_rcv_next_state <= tWaitHREF;
        -- check ot see if full frame has finished and wait for next
        elsif(s_col_cnt = c_max_col-1 and s_row_cnt = c_max_row-1) then
          s_data_rcv_next_state <= tIdle;
        end if;
    end case;
  end process proc_sm_logic;

  -- TODO: once data is sampled it should then be crossed to the system clock
  -- I'm thinking of using a dual clock fifo
  -- but it may be a good idea to just use BRAM will have to check if microsemi has dual port/clock bram
  -- igloo2 seems to call them LSRAM, once the data is set an address and write enable must be set too
  -- the camera outputs 640x480 pixels so 307200 total. each pixel is 2 bytes so 614400 total bytes
  -- it seems that the lsram would not be able to hold a full frame...
  -- i may have to do a line buffer implmentation instead


end architecture rtl;