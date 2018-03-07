// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
// Date        : Wed Mar  7 10:31:40 2018
// Host        : lzhou-dt2-vi-local running 64-bit CentOS Linux release 7.2.1511 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /home/chiwei/work/checkout/fc32.git/xilinx_ip/gtwizard/gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/s5_native_phy_16gbps_stub.v
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
  qpll0outrefclk_out, gtyrxn_in, gtyrxp_in, rxusrclk_in, rxusrclk2_in, txusrclk_in, 
  txusrclk2_in, gtpowergood_out, gtytxn_out, gtytxp_out, rxoutclk_out, rxpmaresetdone_out, 
  txoutclk_out, txpmaresetdone_out)
/* synthesis syn_black_box black_box_pad_pin="gtwiz_userclk_tx_active_in[0:0],gtwiz_userclk_rx_active_in[0:0],gtwiz_reset_clk_freerun_in[0:0],gtwiz_reset_all_in[0:0],gtwiz_reset_tx_pll_and_datapath_in[0:0],gtwiz_reset_tx_datapath_in[0:0],gtwiz_reset_rx_pll_and_datapath_in[0:0],gtwiz_reset_rx_datapath_in[0:0],gtwiz_reset_rx_cdr_stable_out[0:0],gtwiz_reset_tx_done_out[0:0],gtwiz_reset_rx_done_out[0:0],gtwiz_userdata_tx_in[1535:0],gtwiz_userdata_rx_out[1535:0],gtrefclk00_in[5:0],qpll0outclk_out[5:0],qpll0outrefclk_out[5:0],gtyrxn_in[23:0],gtyrxp_in[23:0],rxusrclk_in[23:0],rxusrclk2_in[23:0],txusrclk_in[23:0],txusrclk2_in[23:0],gtpowergood_out[23:0],gtytxn_out[23:0],gtytxp_out[23:0],rxoutclk_out[23:0],rxpmaresetdone_out[23:0],txoutclk_out[23:0],txpmaresetdone_out[23:0]" */;
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
  input [1535:0]gtwiz_userdata_tx_in;
  output [1535:0]gtwiz_userdata_rx_out;
  input [5:0]gtrefclk00_in;
  output [5:0]qpll0outclk_out;
  output [5:0]qpll0outrefclk_out;
  input [23:0]gtyrxn_in;
  input [23:0]gtyrxp_in;
  input [23:0]rxusrclk_in;
  input [23:0]rxusrclk2_in;
  input [23:0]txusrclk_in;
  input [23:0]txusrclk2_in;
  output [23:0]gtpowergood_out;
  output [23:0]gtytxn_out;
  output [23:0]gtytxp_out;
  output [23:0]rxoutclk_out;
  output [23:0]rxpmaresetdone_out;
  output [23:0]txoutclk_out;
  output [23:0]txpmaresetdone_out;
endmodule
