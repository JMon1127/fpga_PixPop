-------------------------------------------------------------------------------
-- Title       : Clock Management
-- Project     : fpga_PixPop
-------------------------------------------------------------------------------
-- File        : clock_rst_wrap.vhd
-- Author      : J. I. Montes
-- Created     : [2025-06-01]
-- Last Update : [2025-06-01]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : This block is a wrapper for clocks generated using CCC.
--               It also provides synchronized reset signals for each domain.
--
-- Dependencies: Microsemi Fabric Clock Conditioning Circuit(FCCC) IP component
--
-- Revision History:
--   Date        Author        Description
--   2025-06-01  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clock_rst_wrap is
  port (
    I_REF_CLK            : in std_logic;
    I_EXT_RST_N          : in std_logic;
    I_CAM_PCLK           : in std_logic;  -- pixel clock from OV7670 camera
    O_RST_N_SYNCD_PCLK   : out std_logic; -- reset synced to pixel clock domain
    O_RST_N_SYNCD_SYSCLK : out std_logic; -- reset synced to system clock domain
    O_SYS_CLK            : out std_logic; -- main system clock
    O_CAM_XCLK           : out std_logic -- drives OV7670 camera
  );
  end clock_rst_wrap;

architecture rtl of clock_rst_wrap is
  --------------------
  -- Components
  --------------------
  component FCCC_C0 is
    port (
      CLK0 : in std_logic;
      GL0  : out std_logic; -- 125MHz
      GL1  : out std_logic; -- 24MHz
      LOCK : out std_logic
    );
  end component FCCC_C0;

  --------------------
  -- Signals
  --------------------
  signal s_pclk_rst_n_dly     : std_logic;
  signal s_rst_n_syncd_pclk   : std_logic;
  signal s_sys_clk            : std_logic;
  signal s_sysclk_rst_n_dly   : std_logic;
  signal s_rst_n_syncd_sysclk : std_logic;
  signal s_mstr_rst_n         : std_logic;
  signal s_pll_lock           : std_logic;

begin

  u_cam_clks_0 : FCCC_C0
  port map (
    CLK0 => I_REF_CLK,
    GL0  => s_sys_clk,
    GL1  => O_CAM_XCLK,
    LOCK => s_pll_lock
  );

  -- hold in reset if external async reset is hit or if pll is not locked
  s_mstr_rst_n <= '0' when (I_EXT_RST_N = '0' or s_pll_lock = '0') else '1';

  -- this process syncs the reset to the pixel clock domain
  proc_sync_rst_pclk : process (I_CAM_PCLK, s_mstr_rst_n)
  begin
    if(s_mstr_rst_n = '0') then
      s_pclk_rst_n_dly   <= '0';
      s_rst_n_syncd_pclk <= '0';
    elsif(rising_edge(I_CAM_PCLK)) then
      s_pclk_rst_n_dly   <= '1';
      s_rst_n_syncd_pclk <= s_pclk_rst_n_dly;
    end if;
  end process;

  -- this process syncs the reset to the system clock domain
  proc_sync_rst_sysclk : process (s_sys_clk, s_mstr_rst_n)
  begin
    if(s_mstr_rst_n = '0') then
      s_sysclk_rst_n_dly   <= '0';
      s_rst_n_syncd_sysclk <= '0';
    elsif(rising_edge(s_sys_clk)) then
      s_sysclk_rst_n_dly   <= '1';
      s_rst_n_syncd_sysclk <= s_sysclk_rst_n_dly;
    end if;
  end process;

  -- assign outputs
  O_SYS_CLK            <= s_sys_clk;
  O_RST_N_SYNCD_PCLK   <= s_rst_n_syncd_pclk;
  O_RST_N_SYNCD_SYSCLK <= s_rst_n_syncd_sysclk;

end architecture rtl;