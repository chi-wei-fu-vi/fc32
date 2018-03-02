-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:gtwizard_ultrascale:1.7
-- IP Revision: 1

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT s5_native_phy_16gbps
  PORT (
    gtwiz_userclk_tx_active_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_rx_active_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_clk_freerun_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_all_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_cdr_stable_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userdata_tx_in : IN STD_LOGIC_VECTOR(1663 DOWNTO 0);
    gtwiz_userdata_rx_out : OUT STD_LOGIC_VECTOR(1663 DOWNTO 0);
    gtrefclk00_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    qpll0outclk_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    qpll0outrefclk_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    gthrxn_in : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
    gthrxp_in : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
    rxusrclk_in : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
    rxusrclk2_in : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
    txusrclk_in : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
    txusrclk2_in : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
    gthtxn_out : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
    gthtxp_out : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
    gtpowergood_out : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
    rxoutclk_out : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
    rxpmaresetdone_out : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
    txoutclk_out : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
    txpmaresetdone_out : OUT STD_LOGIC_VECTOR(25 DOWNTO 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : s5_native_phy_16gbps
  PORT MAP (
    gtwiz_userclk_tx_active_in => gtwiz_userclk_tx_active_in,
    gtwiz_userclk_rx_active_in => gtwiz_userclk_rx_active_in,
    gtwiz_reset_clk_freerun_in => gtwiz_reset_clk_freerun_in,
    gtwiz_reset_all_in => gtwiz_reset_all_in,
    gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
    gtwiz_reset_tx_datapath_in => gtwiz_reset_tx_datapath_in,
    gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
    gtwiz_reset_rx_datapath_in => gtwiz_reset_rx_datapath_in,
    gtwiz_reset_rx_cdr_stable_out => gtwiz_reset_rx_cdr_stable_out,
    gtwiz_reset_tx_done_out => gtwiz_reset_tx_done_out,
    gtwiz_reset_rx_done_out => gtwiz_reset_rx_done_out,
    gtwiz_userdata_tx_in => gtwiz_userdata_tx_in,
    gtwiz_userdata_rx_out => gtwiz_userdata_rx_out,
    gtrefclk00_in => gtrefclk00_in,
    qpll0outclk_out => qpll0outclk_out,
    qpll0outrefclk_out => qpll0outrefclk_out,
    gthrxn_in => gthrxn_in,
    gthrxp_in => gthrxp_in,
    rxusrclk_in => rxusrclk_in,
    rxusrclk2_in => rxusrclk2_in,
    txusrclk_in => txusrclk_in,
    txusrclk2_in => txusrclk2_in,
    gthtxn_out => gthtxn_out,
    gthtxp_out => gthtxp_out,
    gtpowergood_out => gtpowergood_out,
    rxoutclk_out => rxoutclk_out,
    rxpmaresetdone_out => rxpmaresetdone_out,
    txoutclk_out => txoutclk_out,
    txpmaresetdone_out => txpmaresetdone_out
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file s5_native_phy_16gbps.vhd when simulating
-- the core, s5_native_phy_16gbps. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

