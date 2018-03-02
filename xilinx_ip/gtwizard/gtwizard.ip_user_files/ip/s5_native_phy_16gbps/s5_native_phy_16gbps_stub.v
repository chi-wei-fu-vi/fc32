// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
// Date        : Mon Jan  8 10:25:59 2018
// Host        : lzhou-dt2-vi-local running 64-bit CentOS Linux release 7.2.1511 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /home/chiwei/work/checkout/xilinx-bali.git.new/xilinx_ip/gtwizard/gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/s5_native_phy_16gbps_stub.v
// Design      : s5_native_phy_16gbps
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku15p-ffve1517-3-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "s5_native_phy_16gbps_gtwizard_top,Vivado 2017.3" *)
module s5_native_phy_16gbps(gtwiz_userclk_tx_active_in, 
  gtwiz_userclk_rx_active_in, gtwiz_reset_clk_freerun_in, gtwiz_reset_all_in, 
  gtwiz_reset_tx_pll_and_datapath_in, gtwiz_reset_tx_datapath_in, 
  gtwiz_reset_rx_pll_and_datapath_in, gtwiz_reset_rx_datapath_in, 
  gtwiz_reset_rx_cdr_stable_out, gtwiz_reset_tx_done_out, gtwiz_reset_rx_done_out, 
  gtwiz_userdata_tx_in, gtwiz_userdata_rx_out, gtrefclk00_in, qpll0outclk_out, 
  qpll0outrefclk_out, gthrxn_in, gthrxp_in, rxusrclk_in, rxusrclk2_in, txusrclk_in, 
  txusrclk2_in, gthtxn_out, gthtxp_out, gtpowergood_out, rxoutclk_out, rxpmaresetdone_out, 
  txoutclk_out, txpmaresetdone_out)
/* synthesis syn_black_box black_box_pad_pin="gtwiz_userclk_tx_active_in[0:0],gtwiz_userclk_rx_active_in[0:0],gtwiz_reset_clk_freerun_in[0:0],gtwiz_reset_all_in[0:0],gtwiz_reset_tx_pll_and_datapath_in[0:0],gtwiz_reset_tx_datapath_in[0:0],gtwiz_reset_rx_pll_and_datapath_in[0:0],gtwiz_reset_rx_datapath_in[0:0],gtwiz_reset_rx_cdr_stable_out[0:0],gtwiz_reset_tx_done_out[0:0],gtwiz_reset_rx_done_out[0:0],gtwiz_userdata_tx_in[1663:0],gtwiz_userdata_rx_out[1663:0],gtrefclk00_in[6:0],qpll0outclk_out[6:0],qpll0outrefclk_out[6:0],gthrxn_in[25:0],gthrxp_in[25:0],rxusrclk_in[25:0],rxusrclk2_in[25:0],txusrclk_in[25:0],txusrclk2_in[25:0],gthtxn_out[25:0],gthtxp_out[25:0],gtpowergood_out[25:0],rxoutclk_out[25:0],rxpmaresetdone_out[25:0],txoutclk_out[25:0],txpmaresetdone_out[25:0]" */;
  input [0:0]gtwiz_userclk_tx_active_in;
  input [0:0]gtwiz_userclk_rx_active_in;
  input [0:0]gtwiz_reset_clk_freerun_in;
  input [0:0]gtwiz_reset_all_in;
  input [0:0]gtwiz_reset_tx_pll_and_datapath_in;
  input [0:0]gtwiz_reset_tx_datapath_in;
  input [0:0]gtwiz_reset_rx_pll_and_datapath_in;
  input [0:0]gtwiz_reset_rx_datapath_in;
  output [0:0]gtwiz_reset_rx_cdr_stable_out;
  output [0:0]gtwiz_reset_tx_done_out;
  output [0:0]gtwiz_reset_rx_done_out;
  input [1663:0]gtwiz_userdata_tx_in;
  output [1663:0]gtwiz_userdata_rx_out;
  input [6:0]gtrefclk00_in;
  output [6:0]qpll0outclk_out;
  output [6:0]qpll0outrefclk_out;
  input [25:0]gthrxn_in;
  input [25:0]gthrxp_in;
  input [25:0]rxusrclk_in;
  input [25:0]rxusrclk2_in;
  input [25:0]txusrclk_in;
  input [25:0]txusrclk2_in;
  output [25:0]gthtxn_out;
  output [25:0]gthtxp_out;
  output [25:0]gtpowergood_out;
  output [25:0]rxoutclk_out;
  output [25:0]rxpmaresetdone_out;
  output [25:0]txoutclk_out;
  output [25:0]txpmaresetdone_out;
endmodule
