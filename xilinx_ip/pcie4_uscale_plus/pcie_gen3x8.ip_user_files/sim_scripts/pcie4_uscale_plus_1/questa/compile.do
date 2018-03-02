vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm
vlib questa_lib/msim/gtwizard_ultrascale_v1_7_1

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm
vmap gtwizard_ultrascale_v1_7_1 questa_lib/msim/gtwizard_ultrascale_v1_7_1

vlog -work xil_defaultlib -64 -sv "+incdir+../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source" "+incdir+../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source" \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"/opt/Xilinx/Vivado/2017.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work gtwizard_ultrascale_v1_7_1 -64 "+incdir+../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source" "+incdir+../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source" \
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

vlog -work xil_defaultlib -64 "+incdir+../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source" "+incdir+../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/ip_0/sim/gtwizard_ultrascale_v1_7_gtye4_channel.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/ip_0/sim/pcie4_uscale_plus_1_gt_gtye4_channel_wrapper.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/ip_0/sim/gtwizard_ultrascale_v1_7_gtye4_common.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/ip_0/sim/pcie4_uscale_plus_1_gt_gtye4_common_wrapper.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/ip_0/sim/pcie4_uscale_plus_1_gt_gtwizard_gtye4.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/ip_0/sim/pcie4_uscale_plus_1_gt_gtwizard_top.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/ip_0/sim/pcie4_uscale_plus_1_gt.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gtwizard_top.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_phy_ff_chain.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_phy_pipeline.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram_16k_int.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram_16k.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram_32k.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram_4k_int.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram_msix.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram_rep_int.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram_rep.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram_tph.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_bram.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_gt_channel.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_gt_common.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_phy_clk.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_phy_rst.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_phy_rxeq.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_phy_txeq.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_sync_cell.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_sync.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_cdr_ctrl_on_eidle.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_receiver_detect_rxterm.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_gt_phy_wrapper.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_init_ctrl.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_pl_eq.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_vf_decode.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_pipe.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_phy_top.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_seqnum_fifo.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_sys_clk_gen_ps.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/source/pcie4_uscale_plus_1_pcie4_uscale_core_top.v" \
"../../../../pcie_gen3x8.srcs/sources_1/ip/pcie4_uscale_plus_1/sim/pcie4_uscale_plus_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

