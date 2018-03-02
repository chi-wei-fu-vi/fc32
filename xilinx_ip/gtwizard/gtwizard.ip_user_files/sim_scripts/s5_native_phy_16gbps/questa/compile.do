vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/gtwizard_ultrascale_v1_7_1
vlib questa_lib/msim/xil_defaultlib

vmap gtwizard_ultrascale_v1_7_1 questa_lib/msim/gtwizard_ultrascale_v1_7_1
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work gtwizard_ultrascale_v1_7_1 -64 \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_bit_sync.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gte4_drp_arb.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_delay_powergood.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_delay_powergood.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe3_cpll_cal.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe3_cal_freqcnt.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gthe4_cal_freqcnt.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtye4_cal_freqcnt.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_reset.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_rx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_tx.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_reset_sync.v" \
"../../../ipstatic/hdl/gtwizard_ultrascale_v1_7_reset_inv_sync.v" \

vlog -work xil_defaultlib -64 \
"../../../../gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/sim/gtwizard_ultrascale_v1_7_gthe4_channel.v" \
"../../../../gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/sim/s5_native_phy_16gbps_gthe4_channel_wrapper.v" \
"../../../../gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/sim/gtwizard_ultrascale_v1_7_gthe4_common.v" \
"../../../../gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/sim/s5_native_phy_16gbps_gthe4_common_wrapper.v" \
"../../../../gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/sim/s5_native_phy_16gbps_gtwizard_gthe4.v" \
"../../../../gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/sim/s5_native_phy_16gbps_gtwizard_top.v" \
"../../../../gtwizard.srcs/sources_1/ip/s5_native_phy_16gbps/sim/s5_native_phy_16gbps.v" \

vlog -work xil_defaultlib \
"glbl.v"

