-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
-- Date        : Mon Jan  8 10:25:59 2018
-- Host        : lzhou-dt2-vi-local running 64-bit CentOS Linux release 7.2.1511 (Core)
-- Command     : write_vhdl -force -mode synth_stub
--               /home/chiwei/work/checkout/xilinx-bali.git.new/xilinx_ip/gtwizard/gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/s5_native_phy_16gbps_stub.vhdl
-- Design      : s5_native_phy_16gbps
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku15p-ffve1517-3-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity s5_native_phy_16gbps is
  Port ( 
    gtwiz_userclk_tx_active_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_userclk_rx_active_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_clk_freerun_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_all_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_tx_pll_and_datapath_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_tx_datapath_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_rx_pll_and_datapath_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_rx_datapath_in : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_rx_cdr_stable_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_tx_done_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_rx_done_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_userdata_tx_in : in STD_LOGIC_VECTOR ( 1663 downto 0 );
    gtwiz_userdata_rx_out : out STD_LOGIC_VECTOR ( 1663 downto 0 );
    gtrefclk00_in : in STD_LOGIC_VECTOR ( 6 downto 0 );
    qpll0outclk_out : out STD_LOGIC_VECTOR ( 6 downto 0 );
    qpll0outrefclk_out : out STD_LOGIC_VECTOR ( 6 downto 0 );
    gthrxn_in : in STD_LOGIC_VECTOR ( 25 downto 0 );
    gthrxp_in : in STD_LOGIC_VECTOR ( 25 downto 0 );
    rxusrclk_in : in STD_LOGIC_VECTOR ( 25 downto 0 );
    rxusrclk2_in : in STD_LOGIC_VECTOR ( 25 downto 0 );
    txusrclk_in : in STD_LOGIC_VECTOR ( 25 downto 0 );
    txusrclk2_in : in STD_LOGIC_VECTOR ( 25 downto 0 );
    gthtxn_out : out STD_LOGIC_VECTOR ( 25 downto 0 );
    gthtxp_out : out STD_LOGIC_VECTOR ( 25 downto 0 );
    gtpowergood_out : out STD_LOGIC_VECTOR ( 25 downto 0 );
    rxoutclk_out : out STD_LOGIC_VECTOR ( 25 downto 0 );
    rxpmaresetdone_out : out STD_LOGIC_VECTOR ( 25 downto 0 );
    txoutclk_out : out STD_LOGIC_VECTOR ( 25 downto 0 );
    txpmaresetdone_out : out STD_LOGIC_VECTOR ( 25 downto 0 )
  );

end s5_native_phy_16gbps;

architecture stub of s5_native_phy_16gbps is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "gtwiz_userclk_tx_active_in[0:0],gtwiz_userclk_rx_active_in[0:0],gtwiz_reset_clk_freerun_in[0:0],gtwiz_reset_all_in[0:0],gtwiz_reset_tx_pll_and_datapath_in[0:0],gtwiz_reset_tx_datapath_in[0:0],gtwiz_reset_rx_pll_and_datapath_in[0:0],gtwiz_reset_rx_datapath_in[0:0],gtwiz_reset_rx_cdr_stable_out[0:0],gtwiz_reset_tx_done_out[0:0],gtwiz_reset_rx_done_out[0:0],gtwiz_userdata_tx_in[1663:0],gtwiz_userdata_rx_out[1663:0],gtrefclk00_in[6:0],qpll0outclk_out[6:0],qpll0outrefclk_out[6:0],gthrxn_in[25:0],gthrxp_in[25:0],rxusrclk_in[25:0],rxusrclk2_in[25:0],txusrclk_in[25:0],txusrclk2_in[25:0],gthtxn_out[25:0],gthtxp_out[25:0],gtpowergood_out[25:0],rxoutclk_out[25:0],rxpmaresetdone_out[25:0],txoutclk_out[25:0],txpmaresetdone_out[25:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "s5_native_phy_16gbps_gtwizard_top,Vivado 2017.3";
begin
end;
