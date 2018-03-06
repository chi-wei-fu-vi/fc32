#------------------------------------------------------------------------------
#  (c) Copyright 2013-2015 Xilinx, Inc. All rights reserved.
#
#  This file contains confidential and proprietary information
#  of Xilinx, Inc. and is protected under U.S. and
#  international copyright and other intellectual property
#  laws.
#
#  DISCLAIMER
#  This disclaimer is not a license and does not grant any
#  rights to the materials distributed herewith. Except as
#  otherwise provided in a valid license issued to you by
#  Xilinx, and to the maximum extent permitted by applicable
#  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
#  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
#  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
#  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
#  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
#  (2) Xilinx shall not be liable (whether in contract or tort,
#  including negligence, or under any other theory of
#  liability) for any loss or damage of any kind or nature
#  related to, arising under or in connection with these
#  materials, including for any direct, or any indirect,
#  special, incidental, or consequential loss or damage
#  (including loss of data, profits, goodwill, or any type of
#  loss or damage suffered as a result of any action brought
#  by a third party) even if such damage or loss was
#  reasonably foreseeable or Xilinx had been advised of the
#  possibility of the same.
#
#  CRITICAL APPLICATIONS
#  Xilinx products are not designed or intended to be fail-
#  safe, or for use in any application requiring fail-safe
#  performance, such as life-support or safety devices or
#  systems, Class III medical devices, nuclear facilities,
#  applications related to the deployment of airbags, or any
#  other applications that could lead to death, personal
#  injury, or severe property or environmental damage
#  (individually and collectively, "Critical
#  Applications"). Customer assumes the sole risk and
#  liability of any use of Xilinx products in Critical
#  Applications, subject only to applicable laws and
#  regulations governing limitations on product liability.
#
#  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
#  PART OF THIS FILE AT ALL TIMES.
#------------------------------------------------------------------------------


# UltraScale FPGAs Transceivers Wizard IP core-level XDC file
# ----------------------------------------------------------------------------------------------------------------------

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y0
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y0 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AH37 [get_ports gtyrxn_in[0]]
#set_property package_pin AH36 [get_ports gtyrxp_in[0]]
#set_property package_pin AF32 [get_ports gtytxn_out[0]]
#set_property package_pin AF31 [get_ports gtytxp_out[0]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[0].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[0].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y1
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y1 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AG39 [get_ports gtyrxn_in[1]]
#set_property package_pin AG38 [get_ports gtyrxp_in[1]]
#set_property package_pin AE34 [get_ports gtytxn_out[1]]
#set_property package_pin AE33 [get_ports gtytxp_out[1]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[1].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[1].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y2
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y2 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AF37 [get_ports gtyrxn_in[2]]
#set_property package_pin AF36 [get_ports gtyrxp_in[2]]
#set_property package_pin AD32 [get_ports gtytxn_out[2]]
#set_property package_pin AD31 [get_ports gtytxp_out[2]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[2].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[2].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y3
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y3 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AE39 [get_ports gtyrxn_in[3]]
#set_property package_pin AE38 [get_ports gtyrxp_in[3]]
#set_property package_pin AC34 [get_ports gtytxn_out[3]]
#set_property package_pin AC33 [get_ports gtytxp_out[3]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[3].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[3].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y4
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y4 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AD37 [get_ports gtyrxn_in[4]]
#set_property package_pin AD36 [get_ports gtyrxp_in[4]]
#set_property package_pin AB32 [get_ports gtytxn_out[4]]
#set_property package_pin AB31 [get_ports gtytxp_out[4]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[4].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[4].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y5
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y5 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AC39 [get_ports gtyrxn_in[5]]
#set_property package_pin AC38 [get_ports gtyrxp_in[5]]
#set_property package_pin AA34 [get_ports gtytxn_out[5]]
#set_property package_pin AA33 [get_ports gtytxp_out[5]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[5].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[5].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y6
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y6 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AB37 [get_ports gtyrxn_in[6]]
#set_property package_pin AB36 [get_ports gtyrxp_in[6]]
#set_property package_pin Y32 [get_ports gtytxn_out[6]]
#set_property package_pin Y31 [get_ports gtytxp_out[6]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[6].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[6].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y7
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y7 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AA39 [get_ports gtyrxn_in[7]]
#set_property package_pin AA38 [get_ports gtyrxp_in[7]]
#set_property package_pin W34 [get_ports gtytxn_out[7]]
#set_property package_pin W33 [get_ports gtytxp_out[7]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[7].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[7].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y8
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y8 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin Y37 [get_ports gtyrxn_in[8]]
#set_property package_pin Y36 [get_ports gtyrxp_in[8]]
#set_property package_pin V32 [get_ports gtytxn_out[8]]
#set_property package_pin V31 [get_ports gtytxp_out[8]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[8].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[8].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y9
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y9 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin W39 [get_ports gtyrxn_in[9]]
#set_property package_pin W38 [get_ports gtyrxp_in[9]]
#set_property package_pin U34 [get_ports gtytxn_out[9]]
#set_property package_pin U33 [get_ports gtytxp_out[9]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[9].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[9].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y10
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y10 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin V37 [get_ports gtyrxn_in[10]]
#set_property package_pin V36 [get_ports gtyrxp_in[10]]
#set_property package_pin T32 [get_ports gtytxn_out[10]]
#set_property package_pin T31 [get_ports gtytxp_out[10]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[10].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[10].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y11
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y11 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin U39 [get_ports gtyrxn_in[11]]
#set_property package_pin U38 [get_ports gtyrxp_in[11]]
#set_property package_pin R34 [get_ports gtytxn_out[11]]
#set_property package_pin R33 [get_ports gtytxp_out[11]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[11].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[11].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y12
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y12 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[3].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin T37 [get_ports gtyrxn_in[12]]
#set_property package_pin T36 [get_ports gtyrxp_in[12]]
#set_property package_pin P32 [get_ports gtytxn_out[12]]
#set_property package_pin P31 [get_ports gtytxp_out[12]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[12].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[12].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y13
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y13 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[3].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin R39 [get_ports gtyrxn_in[13]]
#set_property package_pin R38 [get_ports gtyrxp_in[13]]
#set_property package_pin N34 [get_ports gtytxn_out[13]]
#set_property package_pin N33 [get_ports gtytxp_out[13]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[13].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[13].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y14
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y14 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[3].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin P37 [get_ports gtyrxn_in[14]]
#set_property package_pin P36 [get_ports gtyrxp_in[14]]
#set_property package_pin M32 [get_ports gtytxn_out[14]]
#set_property package_pin M31 [get_ports gtytxp_out[14]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[14].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[14].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y15
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y15 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[3].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin N39 [get_ports gtyrxn_in[15]]
#set_property package_pin N38 [get_ports gtyrxp_in[15]]
#set_property package_pin L34 [get_ports gtytxn_out[15]]
#set_property package_pin L33 [get_ports gtytxp_out[15]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[15].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[15].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y16
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y16 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin M37 [get_ports gtyrxn_in[16]]
#set_property package_pin M36 [get_ports gtyrxp_in[16]]
#set_property package_pin J34 [get_ports gtytxn_out[16]]
#set_property package_pin J33 [get_ports gtytxp_out[16]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[16].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[16].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y17
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y17 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin L39 [get_ports gtyrxn_in[17]]
#set_property package_pin L38 [get_ports gtyrxp_in[17]]
#set_property package_pin G34 [get_ports gtytxn_out[17]]
#set_property package_pin G33 [get_ports gtytxp_out[17]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[17].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[17].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y18
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y18 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin K37 [get_ports gtyrxn_in[18]]
#set_property package_pin K36 [get_ports gtyrxp_in[18]]
#set_property package_pin F36 [get_ports gtytxn_out[18]]
#set_property package_pin F35 [get_ports gtytxp_out[18]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[18].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[18].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y19
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y19 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin J39 [get_ports gtyrxn_in[19]]
#set_property package_pin J38 [get_ports gtyrxp_in[19]]
#set_property package_pin E34 [get_ports gtytxn_out[19]]
#set_property package_pin E33 [get_ports gtytxp_out[19]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[19].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[19].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y20
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y20 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin H37 [get_ports gtyrxn_in[20]]
#set_property package_pin H36 [get_ports gtyrxp_in[20]]
#set_property package_pin D36 [get_ports gtytxn_out[20]]
#set_property package_pin D35 [get_ports gtytxp_out[20]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[20].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[20].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y21
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y21 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin G39 [get_ports gtyrxn_in[21]]
#set_property package_pin G38 [get_ports gtyrxp_in[21]]
#set_property package_pin C34 [get_ports gtytxn_out[21]]
#set_property package_pin C33 [get_ports gtytxp_out[21]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[21].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[21].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y22
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y22 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin E39 [get_ports gtyrxn_in[22]]
#set_property package_pin E38 [get_ports gtyrxp_in[22]]
#set_property package_pin B36 [get_ports gtytxn_out[22]]
#set_property package_pin B35 [get_ports gtytxp_out[22]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[22].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[22].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTYE4_CHANNEL_X0Y23
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTYE4_CHANNEL_X0Y23 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin C39 [get_ports gtyrxn_in[23]]
#set_property package_pin C38 [get_ports gtyrxp_in[23]]
#set_property package_pin A34 [get_ports gtytxn_out[23]]
#set_property package_pin A33 [get_ports gtytxp_out[23]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[23].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[23].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet


# False path constraints
# ----------------------------------------------------------------------------------------------------------------------

set_false_path -to [get_cells -hierarchical -filter {NAME =~ *bit_synchronizer*inst/i_in_meta_reg}]

##set_false_path -to [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_*_reg}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_meta_reg/D}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_meta_reg/PRE}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync1_reg/PRE}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync2_reg/PRE}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync3_reg/PRE}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_out_reg/PRE}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_meta_reg/CLR}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync1_reg/CLR}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync2_reg/CLR}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_sync3_reg/CLR}]
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_out_reg/CLR}]

