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

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y0
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y0 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AW3 [get_ports gthrxn_in[0]]
#set_property package_pin AW4 [get_ports gthrxp_in[0]]
#set_property package_pin AW7 [get_ports gthtxn_out[0]]
#set_property package_pin AW8 [get_ports gthtxp_out[0]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[0].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[0].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y1
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y1 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AV1 [get_ports gthrxn_in[1]]
#set_property package_pin AV2 [get_ports gthrxp_in[1]]
#set_property package_pin AV5 [get_ports gthtxn_out[1]]
#set_property package_pin AV6 [get_ports gthtxp_out[1]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[1].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[1].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y2
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y2 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AU3 [get_ports gthrxn_in[2]]
#set_property package_pin AU4 [get_ports gthrxp_in[2]]
#set_property package_pin AU7 [get_ports gthtxn_out[2]]
#set_property package_pin AU8 [get_ports gthtxp_out[2]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[2].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[2].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y3
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y3 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[0].*gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AT1 [get_ports gthrxn_in[3]]
#set_property package_pin AT2 [get_ports gthrxp_in[3]]
#set_property package_pin AT5 [get_ports gthtxn_out[3]]
#set_property package_pin AT6 [get_ports gthtxp_out[3]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[3].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[3].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y4
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y4 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AR3 [get_ports gthrxn_in[4]]
#set_property package_pin AR4 [get_ports gthrxp_in[4]]
#set_property package_pin AR7 [get_ports gthtxn_out[4]]
#set_property package_pin AR8 [get_ports gthtxp_out[4]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[4].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[4].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y5
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y5 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AP1 [get_ports gthrxn_in[5]]
#set_property package_pin AP2 [get_ports gthrxp_in[5]]
#set_property package_pin AP5 [get_ports gthtxn_out[5]]
#set_property package_pin AP6 [get_ports gthtxp_out[5]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[5].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[5].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y6
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y6 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AN3 [get_ports gthrxn_in[6]]
#set_property package_pin AN4 [get_ports gthrxp_in[6]]
#set_property package_pin AN7 [get_ports gthtxn_out[6]]
#set_property package_pin AN8 [get_ports gthtxp_out[6]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[6].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[6].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y7
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y7 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[1].*gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AM1 [get_ports gthrxn_in[7]]
#set_property package_pin AM2 [get_ports gthrxp_in[7]]
#set_property package_pin AM5 [get_ports gthtxn_out[7]]
#set_property package_pin AM6 [get_ports gthtxp_out[7]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[7].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[7].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y8
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y8 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AL3 [get_ports gthrxn_in[8]]
#set_property package_pin AL4 [get_ports gthrxp_in[8]]
#set_property package_pin AL7 [get_ports gthtxn_out[8]]
#set_property package_pin AL8 [get_ports gthtxp_out[8]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[8].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[8].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y9
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y9 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AK1 [get_ports gthrxn_in[9]]
#set_property package_pin AK2 [get_ports gthrxp_in[9]]
#set_property package_pin AK5 [get_ports gthtxn_out[9]]
#set_property package_pin AK6 [get_ports gthtxp_out[9]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[9].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[9].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y10
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y10 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AJ3 [get_ports gthrxn_in[10]]
#set_property package_pin AJ4 [get_ports gthrxp_in[10]]
#set_property package_pin AJ7 [get_ports gthtxn_out[10]]
#set_property package_pin AJ8 [get_ports gthtxp_out[10]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[10].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[10].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y11
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y11 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[2].*gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AH1 [get_ports gthrxn_in[11]]
#set_property package_pin AH2 [get_ports gthrxp_in[11]]
#set_property package_pin AH5 [get_ports gthtxn_out[11]]
#set_property package_pin AH6 [get_ports gthtxp_out[11]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[11].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[11].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y12
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y12 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[3].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AG3 [get_ports gthrxn_in[12]]
#set_property package_pin AG4 [get_ports gthrxp_in[12]]
#set_property package_pin AG7 [get_ports gthtxn_out[12]]
#set_property package_pin AG8 [get_ports gthtxp_out[12]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[12].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[12].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y13
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y13 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[3].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AF1 [get_ports gthrxn_in[13]]
#set_property package_pin AF2 [get_ports gthrxp_in[13]]
#set_property package_pin AF5 [get_ports gthtxn_out[13]]
#set_property package_pin AF6 [get_ports gthtxp_out[13]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[13].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[13].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y14
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y14 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[3].*gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AE3 [get_ports gthrxn_in[14]]
#set_property package_pin AE4 [get_ports gthrxp_in[14]]
#set_property package_pin AE7 [get_ports gthtxn_out[14]]
#set_property package_pin AE8 [get_ports gthtxp_out[14]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[14].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[14].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y15
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y15 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[3].*gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AD1 [get_ports gthrxn_in[15]]
#set_property package_pin AD2 [get_ports gthrxp_in[15]]
#set_property package_pin AD5 [get_ports gthtxn_out[15]]
#set_property package_pin AD6 [get_ports gthtxp_out[15]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[15].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[15].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y16
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y16 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AC3 [get_ports gthrxn_in[16]]
#set_property package_pin AC4 [get_ports gthrxp_in[16]]
#set_property package_pin AC7 [get_ports gthtxn_out[16]]
#set_property package_pin AC8 [get_ports gthtxp_out[16]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[16].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[16].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y17
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y17 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AB1 [get_ports gthrxn_in[17]]
#set_property package_pin AB2 [get_ports gthrxp_in[17]]
#set_property package_pin AB5 [get_ports gthtxn_out[17]]
#set_property package_pin AB6 [get_ports gthtxp_out[17]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[17].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[17].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y18
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y18 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin AA3 [get_ports gthrxn_in[18]]
#set_property package_pin AA4 [get_ports gthrxp_in[18]]
#set_property package_pin AA7 [get_ports gthtxn_out[18]]
#set_property package_pin AA8 [get_ports gthtxp_out[18]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[18].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[18].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y19
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y19 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[4].*gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin Y1 [get_ports gthrxn_in[19]]
#set_property package_pin Y2 [get_ports gthrxp_in[19]]
#set_property package_pin Y5 [get_ports gthtxn_out[19]]
#set_property package_pin Y6 [get_ports gthtxp_out[19]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[19].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[19].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y20
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y20 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin W3 [get_ports gthrxn_in[20]]
#set_property package_pin W4 [get_ports gthrxp_in[20]]
#set_property package_pin W7 [get_ports gthtxn_out[20]]
#set_property package_pin W8 [get_ports gthtxp_out[20]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[20].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[20].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y21
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y21 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin V1 [get_ports gthrxn_in[21]]
#set_property package_pin V2 [get_ports gthrxp_in[21]]
#set_property package_pin V5 [get_ports gthtxn_out[21]]
#set_property package_pin V6 [get_ports gthtxp_out[21]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[21].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[21].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y22
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y22 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin U3 [get_ports gthrxn_in[22]]
#set_property package_pin U4 [get_ports gthrxp_in[22]]
#set_property package_pin U7 [get_ports gthtxn_out[22]]
#set_property package_pin U8 [get_ports gthtxp_out[22]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[22].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[22].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y23
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y23 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[5].*gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin T1 [get_ports gthrxn_in[23]]
#set_property package_pin T2 [get_ports gthrxp_in[23]]
#set_property package_pin T5 [get_ports gthtxn_out[23]]
#set_property package_pin T6 [get_ports gthtxp_out[23]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[23].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[23].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y24
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y24 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[6].*gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin R3 [get_ports gthrxn_in[24]]
#set_property package_pin R4 [get_ports gthrxp_in[24]]
#set_property package_pin R7 [get_ports gthtxn_out[24]]
#set_property package_pin R8 [get_ports gthtxp_out[24]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[24].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[24].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet

# Commands for enabled transceiver GTHE4_CHANNEL_X0Y25
# ----------------------------------------------------------------------------------------------------------------------

# Channel primitive location constraint
set_property LOC GTHE4_CHANNEL_X0Y25 [get_cells -hierarchical -filter {NAME =~ *gen_channel_container[6].*gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST}]

# Channel primitive serial data pin location constraints
# (Provided as comments for your reference. The channel primitive location constraint is sufficient.)
#set_property package_pin P1 [get_ports gthrxn_in[25]]
#set_property package_pin P2 [get_ports gthrxp_in[25]]
#set_property package_pin P5 [get_ports gthtxn_out[25]]
#set_property package_pin P6 [get_ports gthtxp_out[25]]
set_false_path -through [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[25].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet
set_case_analysis 1 [get_pins -hierarchical -filter {NAME =~ *gen_pwrgood_delay_inst[25].delay_powergood_inst/gen_powergood_delay.pwr_on_fsm_reg/Q}] -quiet


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

