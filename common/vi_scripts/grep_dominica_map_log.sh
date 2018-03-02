#!/bin/bash
# 
# This script is run on the map.log file on Dominica quartus jobs to identify all warnings - and filter
# expected issues.  What follows is a line by line explanation for each grep component
#
# "assigned a value but never"   
#    -> These are nets that are assigned a vlaue but never used
#
# "truncated value with size"    
#    -> Truncation issue due to width mismatches - almost all are in the register
#       flow which defaults to 64b signals and busses - but performs assignments
#       to much smaller widths
#
# "created implicit net"         
#    -> Missing declarations which are innocuous
#
# "altpcie_hip_256_pipen1b"      
#    -> pipe module which is not used.  Generates a large number of "used but
#       never assigned" warnings
#
# "behaves as a local parameter declaration"
#    -> parameters which should have been declared as localparams
#    -> altpcierd_example_app_chaining.v(596): Parameter Declaration in module "altpcierd_example_app_chaining" behaves as a Local Parameter Declaration because the module has a Module Parameter Port List
#
# "Attribute warning at altpcie_rs_serdes.v
#    -> Removes the following warnings:
#       Warning (10890): Verilog HDL Attribute warning at altpcie_rs_serdes.v(80): overriding existing value for attribute "altera_attribute"
#       Warning (10890): Verilog HDL Attribute warning at altpcie_rs_serdes.v(81): overriding existing value for attribute "altera_attribute"
# 
# "Assertion warning: Device family Arria V GZ does not have M9K blocks -- using available memory blocks"
#     -> Warning (287001): Assertion warning: Device family Arria V GZ does not have M9K blocks -- using available memory blocks
#
# Inferred Latches  due to coding style in auto-generate register modules
#      -> Warning (10240): Verilog HDL Always Construct warning at xbar_regs.v(318): inferring latch(es) for variable "WREG_CTL", which holds its previous value in one or more paths through the always construct
#      -> Warning (10240): Verilog HDL Always Construct warning at fc8clkrst_regs.v(312): inferring latch(es) for variable "WREG_RSTCTRL_0", which holds its previous value in one or more paths through the always construct
#      -> Warning (10240): Verilog HDL Always Construct warning at fc8clkrst_regs.v(330): inferring latch(es) for variable "WREG_RSTCTRL_1", which holds its previous value in one or more paths through the always construct
#      -> Warning (10240): Verilog HDL Always Construct warning at mtip_if_fc2_regs.v(255): inferring latch(es) for variable "WREG_SINGLESTEP", which holds its previous value in one or more paths through the always construct
#
# "altpcie_sv_hip_ast_hwtcl.v " - Altera module
#      -> Warning (10764): Verilog HDL warning at altpcie_sv_hip_ast_hwtcl.v(1081): converting signed shift amount to unsigned
#      -> Warning (10764): Verilog HDL warning at altpcie_sv_hip_ast_hwtcl.v(1082): converting signed shift amount to unsigned
#      -> Warning (10764): Verilog HDL warning at altpcie_sv_hip_ast_hwtcl.v(1083): converting signed shift amount to unsigned]
#
# Waived case statements - in Altera code
#      -> Warning (10762): Verilog HDL Case Statement warning at heartbeat_x4.v(68): can't check case statement for completeness because the case expression has too many possible states
#      -> Warning (10270): Verilog HDL Case Statement warning at altera_pll_reconfig_core.v(1422): incomplete case statement has no default case item
#      -> Warning (10270): Verilog HDL Case Statement warning at altera_pll_reconfig_core.v(1438): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at dynamicReconfig.sv(624): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10763): Verilog HDL warning at fc2_extr_bridge.v(196): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10958): SystemVerilog warning at fc2_extr_bridge.v(196): unique or priority keyword makes case statement complete
#      -> Warning (10763): Verilog HDL warning at timestamp_fifo.v(99): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at timestamp_fifo.v(99): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at fifo1c_ctl.v(207): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at fifo1c_ctl.v(207): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at fifo1c_ctl.v(207): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at fifo1c_ctl.v(207): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at fifo1c_ctl.v(207): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at fifo1c_ctl.v(207): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at fifo1c_ctl.v(207): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at fifo1c_ctl.v(207): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at fifo1c_ctl.v(207): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at fifo1c_ctl.v(207): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at fifo1c_ctl.v(207): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at fifo1c_ctl.v(207): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at mtip_pio.v(152): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10958): SystemVerilog warning at mtip_pio.v(152): unique or priority keyword makes case statement complete
#      -> Warning (10763): Verilog HDL warning at mtip_pio.v(276): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10958): SystemVerilog warning at mtip_pio.v(276): unique or priority keyword makes case statement complete
#      -> Warning (10763): Verilog HDL warning at frame_extract.v(817): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10958): SystemVerilog warning at frame_extract.v(817): unique or priority keyword makes case statement complete
#      -> Warning (10763): Verilog HDL warning at frame_packager.v(631): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10958): SystemVerilog warning at frame_packager.v(631): unique or priority keyword makes case statement complete
#      -> Warning (10763): Verilog HDL warning at time_arbiter.v(299): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at time_arbiter.v(299): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at time_arbiter.v(562): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10958): SystemVerilog warning at time_arbiter.v(562): unique or priority keyword makes case statement complete
#      -> Warning (10763): Verilog HDL warning at lk_dpl_xfr.v(62): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at lk_dpl_xfr.v(62): incomplete case statement has no default case item
#      -> Warning (10763): Verilog HDL warning at lk_dpl_xfr.v(98): case statement has overlapping case item expressions with non-constant or don't care bits - unable to check case statement for completeness
#      -> Warning (10270): Verilog HDL Case Statement warning at lk_dpl_xfr.v(98): incomplete case statement has no default case item
#
# Misc warnings
#          -> Warning (10649): Verilog HDL Display System Task warning at alt_xcvr_reconfig_dfe_sv.sv(101):  Decision Feedback Equalizer calibration algorithm is preliminary.
# DFPE-134 -> Warning (10858): Verilog HDL warning at lt_cfg_demux.sv(60): object cfg_np_lim used but never assigned

grep "warning " $1 \
| grep -v -i "assigned a value but never" \
| grep -v -i "truncated value with size" \
| grep -v "created implicit net" \
| grep -v "altpcie_hip_256_pipen1b" \
| grep -v -i "behaves as a local parameter declaration because the module has a module parameter port list" \
| grep -v "Verilog HDL Attribute warning at altpcie_rs_serdes.v" \
| grep -v "Assertion warning: Device family Arria V GZ does not have M9K blocks -- using available memory blocks" \
| grep -v 'xbar_regs.v(318): inferring latch(es) for variable "WREG_CTL", which holds its previous value in one or more paths through the always construct' \
| grep -v 'fc8clkrst_regs.v(312): inferring latch(es) for variable "WREG_RSTCTRL_0", which holds its previous value in one or more paths through the always construct' \
| grep -v 'fc8clkrst_regs.v(330): inferring latch(es) for variable "WREG_RSTCTRL_1", which holds its previous value in one or more paths through the always construct' \
| grep -v 'mtip_if_fc2_regs.v(255): inferring latch(es) for variable "WREG_SINGLESTEP", which holds its previous value in one or more paths through the always construct' \
| grep -v 'Verilog HDL Display System Task warning at alt_xcvr_reconfig_dfe_sv.sv(101):  Decision Feedback Equalizer calibration algorithm is preliminary' \
| grep -v "heartbeat_x4.v(68): can't check case statement for completeness because the case expression has too many possible states" \
| egrep -v '(altera_pll_reconfig_core.*case)' \
| egrep -v '(dynamicReconfig|fc2_extr_bridge|timestamp_fifo|fifo1c_ctl|mtip_pio|frame_extract|frame_packager|time_arbiter|lk_dpl_xfr.*case)' \
| grep -v "Verilog HDL warning at lt_cfg_demux.sv(60): object cfg_np_lim used but never assigned" \
| grep -v "altpcie_sv_hip_ast_hwtcl.v"
