// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
// Date        : Thu Feb  1 14:42:50 2018
// Host        : lzhou-dt2-vi-local running 64-bit CentOS Linux release 7.2.1511 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /home/chiwei/work/checkout/xilinx-bali.git.new/xilinx_ip/clk_wiz/clk_wiz.srcs/sources_1/ip/s5_altpll_219in_212out_0002_1/s5_altpll_219in_212out_0002_1_stub.v
// Design      : s5_altpll_219in_212out_0002_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku15p-ffve1517-3-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module s5_altpll_219in_212out_0002_1(clk_out1, clk_out2, reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,clk_out2,reset,locked,clk_in1" */;
  output clk_out1;
  output clk_out2;
  input reset;
  output locked;
  input clk_in1;
endmodule
