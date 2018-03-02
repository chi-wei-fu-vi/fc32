-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
-- Date        : Thu Feb  1 14:42:49 2018
-- Host        : lzhou-dt2-vi-local running 64-bit CentOS Linux release 7.2.1511 (Core)
-- Command     : write_vhdl -force -mode synth_stub -rename_top s5_altpll_219in_212out_0002 -prefix
--               s5_altpll_219in_212out_0002_ s5_altpll_219in_212out_0002_1_stub.vhdl
-- Design      : s5_altpll_219in_212out_0002_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku15p-ffve1517-3-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity s5_altpll_219in_212out_0002 is
  Port ( 
    clk_out1 : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end s5_altpll_219in_212out_0002;

architecture stub of s5_altpll_219in_212out_0002 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1,clk_out2,reset,locked,clk_in1";
begin
end;
