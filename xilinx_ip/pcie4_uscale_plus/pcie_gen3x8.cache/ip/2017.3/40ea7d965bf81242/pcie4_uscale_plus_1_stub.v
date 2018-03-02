// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
// Date        : Wed Feb  7 11:02:14 2018
// Host        : lzhou-dt2-vi-local running 64-bit CentOS Linux release 7.2.1511 (Core)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ pcie4_uscale_plus_1_stub.v
// Design      : pcie4_uscale_plus_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku15p-ffve1517-3-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "pcie4_uscale_plus_1_pcie4_uscale_core_top,Vivado 2017.3" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(pci_exp_txn, pci_exp_txp, pci_exp_rxn, 
  pci_exp_rxp, user_clk, user_reset, user_lnk_up, s_axis_rq_tdata, s_axis_rq_tkeep, 
  s_axis_rq_tlast, s_axis_rq_tready, s_axis_rq_tuser, s_axis_rq_tvalid, m_axis_rc_tdata, 
  m_axis_rc_tkeep, m_axis_rc_tlast, m_axis_rc_tready, m_axis_rc_tuser, m_axis_rc_tvalid, 
  m_axis_cq_tdata, m_axis_cq_tkeep, m_axis_cq_tlast, m_axis_cq_tready, m_axis_cq_tuser, 
  m_axis_cq_tvalid, s_axis_cc_tdata, s_axis_cc_tkeep, s_axis_cc_tlast, s_axis_cc_tready, 
  s_axis_cc_tuser, s_axis_cc_tvalid, pcie_rq_seq_num0, pcie_rq_seq_num_vld0, 
  pcie_rq_seq_num1, pcie_rq_seq_num_vld1, pcie_rq_tag0, pcie_rq_tag1, pcie_rq_tag_av, 
  pcie_rq_tag_vld0, pcie_rq_tag_vld1, pcie_tfc_nph_av, pcie_tfc_npd_av, pcie_cq_np_req, 
  pcie_cq_np_req_count, cfg_phy_link_down, cfg_phy_link_status, cfg_negotiated_width, 
  cfg_current_speed, cfg_max_payload, cfg_max_read_req, cfg_function_status, 
  cfg_function_power_state, cfg_vf_status, cfg_vf_power_state, cfg_link_power_state, 
  cfg_mgmt_addr, cfg_mgmt_function_number, cfg_mgmt_write, cfg_mgmt_write_data, 
  cfg_mgmt_byte_enable, cfg_mgmt_read, cfg_mgmt_read_data, cfg_mgmt_read_write_done, 
  cfg_mgmt_debug_access, cfg_err_cor_out, cfg_err_nonfatal_out, cfg_err_fatal_out, 
  cfg_local_error_valid, cfg_local_error_out, cfg_ltssm_state, cfg_rx_pm_state, 
  cfg_tx_pm_state, cfg_rcb_status, cfg_obff_enable, cfg_pl_status_change, 
  cfg_tph_requester_enable, cfg_tph_st_mode, cfg_vf_tph_requester_enable, 
  cfg_vf_tph_st_mode, cfg_msg_received, cfg_msg_received_data, cfg_msg_received_type, 
  cfg_msg_transmit, cfg_msg_transmit_type, cfg_msg_transmit_data, cfg_msg_transmit_done, 
  cfg_fc_ph, cfg_fc_pd, cfg_fc_nph, cfg_fc_npd, cfg_fc_cplh, cfg_fc_cpld, cfg_fc_sel, cfg_dsn, 
  cfg_bus_number, cfg_power_state_change_ack, cfg_power_state_change_interrupt, 
  cfg_err_cor_in, cfg_err_uncor_in, cfg_flr_in_process, cfg_flr_done, 
  cfg_vf_flr_in_process, cfg_vf_flr_func_num, cfg_vf_flr_done, cfg_link_training_enable, 
  cfg_interrupt_int, cfg_interrupt_pending, cfg_interrupt_sent, cfg_interrupt_msi_enable, 
  cfg_interrupt_msi_mmenable, cfg_interrupt_msi_mask_update, cfg_interrupt_msi_data, 
  cfg_interrupt_msi_select, cfg_interrupt_msi_int, cfg_interrupt_msi_pending_status, 
  cfg_interrupt_msi_pending_status_data_enable, 
  cfg_interrupt_msi_pending_status_function_num, cfg_interrupt_msi_sent, 
  cfg_interrupt_msi_fail, cfg_interrupt_msi_attr, cfg_interrupt_msi_tph_present, 
  cfg_interrupt_msi_tph_type, cfg_interrupt_msi_tph_st_tag, 
  cfg_interrupt_msi_function_number, cfg_pm_aspm_l1_entry_reject, 
  cfg_pm_aspm_tx_l0s_entry_disable, cfg_hot_reset_out, cfg_config_space_enable, 
  cfg_req_pm_transition_l23_ready, cfg_hot_reset_in, cfg_ds_port_number, 
  cfg_ds_bus_number, cfg_ds_device_number, sys_clk, sys_clk_gt, sys_reset, 
  common_commands_in, pipe_rx_0_sigs, pipe_rx_1_sigs, pipe_rx_2_sigs, pipe_rx_3_sigs, 
  pipe_rx_4_sigs, pipe_rx_5_sigs, pipe_rx_6_sigs, pipe_rx_7_sigs, pipe_rx_8_sigs, 
  pipe_rx_9_sigs, pipe_rx_10_sigs, pipe_rx_11_sigs, pipe_rx_12_sigs, pipe_rx_13_sigs, 
  pipe_rx_14_sigs, pipe_rx_15_sigs, common_commands_out, pipe_tx_0_sigs, pipe_tx_1_sigs, 
  pipe_tx_2_sigs, pipe_tx_3_sigs, pipe_tx_4_sigs, pipe_tx_5_sigs, pipe_tx_6_sigs, 
  pipe_tx_7_sigs, pipe_tx_8_sigs, pipe_tx_9_sigs, pipe_tx_10_sigs, pipe_tx_11_sigs, 
  pipe_tx_12_sigs, pipe_tx_13_sigs, pipe_tx_14_sigs, pipe_tx_15_sigs, gt_pcieuserratedone, 
  gt_loopback, gt_txprbsforceerr, gt_txinhibit, gt_txprbssel, gt_rxprbssel, 
  gt_rxprbscntreset, gt_txelecidle, gt_txresetdone, gt_rxresetdone, gt_rxpmaresetdone, 
  gt_txphaligndone, gt_txphinitdone, gt_txdlysresetdone, gt_rxphaligndone, 
  gt_rxdlysresetdone, gt_rxsyncdone, gt_eyescandataerror, gt_rxprbserr, gt_dmonfiforeset, 
  gt_dmonitorclk, gt_dmonitorout, gt_rxcommadet, gt_phystatus, gt_rxvalid, gt_rxcdrlock, 
  gt_pcierateidle, gt_pcieuserratestart, gt_gtpowergood, gt_cplllock, gt_rxoutclk, 
  gt_rxrecclkout, gt_qpll1lock, gt_qpll0lock, gt_rxstatus, gt_rxbufstatus, gt_bufgtdiv, 
  phy_txeq_ctrl, phy_txeq_preset, phy_rst_fsm, phy_txeq_fsm, phy_rxeq_fsm, phy_rst_idle, 
  phy_rrst_n, phy_prst_n, gt_gen34_eios_det, gt_txoutclk, gt_txoutclkfabric, 
  gt_rxoutclkfabric, gt_txoutclkpcs, gt_rxoutclkpcs, gt_txpmareset, gt_rxpmareset, 
  gt_txpcsreset, gt_rxpcsreset, gt_rxbufreset, gt_rxcdrreset, gt_rxdfelpmreset, 
  gt_txprogdivresetdone, gt_txpmaresetdone, gt_txsyncdone, gt_rxprbslocked, drp_rdy, drp_do, 
  drp_clk, drp_en, drp_we, drp_addr, drp_di, phy_rdy_out)
/* synthesis syn_black_box black_box_pad_pin="pci_exp_txn[7:0],pci_exp_txp[7:0],pci_exp_rxn[7:0],pci_exp_rxp[7:0],user_clk,user_reset,user_lnk_up,s_axis_rq_tdata[255:0],s_axis_rq_tkeep[7:0],s_axis_rq_tlast,s_axis_rq_tready[3:0],s_axis_rq_tuser[61:0],s_axis_rq_tvalid,m_axis_rc_tdata[255:0],m_axis_rc_tkeep[7:0],m_axis_rc_tlast,m_axis_rc_tready,m_axis_rc_tuser[74:0],m_axis_rc_tvalid,m_axis_cq_tdata[255:0],m_axis_cq_tkeep[7:0],m_axis_cq_tlast,m_axis_cq_tready,m_axis_cq_tuser[87:0],m_axis_cq_tvalid,s_axis_cc_tdata[255:0],s_axis_cc_tkeep[7:0],s_axis_cc_tlast,s_axis_cc_tready[3:0],s_axis_cc_tuser[32:0],s_axis_cc_tvalid,pcie_rq_seq_num0[5:0],pcie_rq_seq_num_vld0,pcie_rq_seq_num1[5:0],pcie_rq_seq_num_vld1,pcie_rq_tag0[7:0],pcie_rq_tag1[7:0],pcie_rq_tag_av[3:0],pcie_rq_tag_vld0,pcie_rq_tag_vld1,pcie_tfc_nph_av[3:0],pcie_tfc_npd_av[3:0],pcie_cq_np_req[1:0],pcie_cq_np_req_count[5:0],cfg_phy_link_down,cfg_phy_link_status[1:0],cfg_negotiated_width[2:0],cfg_current_speed[1:0],cfg_max_payload[1:0],cfg_max_read_req[2:0],cfg_function_status[15:0],cfg_function_power_state[11:0],cfg_vf_status[503:0],cfg_vf_power_state[755:0],cfg_link_power_state[1:0],cfg_mgmt_addr[9:0],cfg_mgmt_function_number[7:0],cfg_mgmt_write,cfg_mgmt_write_data[31:0],cfg_mgmt_byte_enable[3:0],cfg_mgmt_read,cfg_mgmt_read_data[31:0],cfg_mgmt_read_write_done,cfg_mgmt_debug_access,cfg_err_cor_out,cfg_err_nonfatal_out,cfg_err_fatal_out,cfg_local_error_valid,cfg_local_error_out[4:0],cfg_ltssm_state[5:0],cfg_rx_pm_state[1:0],cfg_tx_pm_state[1:0],cfg_rcb_status[3:0],cfg_obff_enable[1:0],cfg_pl_status_change,cfg_tph_requester_enable[3:0],cfg_tph_st_mode[11:0],cfg_vf_tph_requester_enable[251:0],cfg_vf_tph_st_mode[755:0],cfg_msg_received,cfg_msg_received_data[7:0],cfg_msg_received_type[4:0],cfg_msg_transmit,cfg_msg_transmit_type[2:0],cfg_msg_transmit_data[31:0],cfg_msg_transmit_done,cfg_fc_ph[7:0],cfg_fc_pd[11:0],cfg_fc_nph[7:0],cfg_fc_npd[11:0],cfg_fc_cplh[7:0],cfg_fc_cpld[11:0],cfg_fc_sel[2:0],cfg_dsn[63:0],cfg_bus_number[7:0],cfg_power_state_change_ack,cfg_power_state_change_interrupt,cfg_err_cor_in,cfg_err_uncor_in,cfg_flr_in_process[3:0],cfg_flr_done[3:0],cfg_vf_flr_in_process[251:0],cfg_vf_flr_func_num[7:0],cfg_vf_flr_done[0:0],cfg_link_training_enable,cfg_interrupt_int[3:0],cfg_interrupt_pending[3:0],cfg_interrupt_sent,cfg_interrupt_msi_enable[3:0],cfg_interrupt_msi_mmenable[11:0],cfg_interrupt_msi_mask_update,cfg_interrupt_msi_data[31:0],cfg_interrupt_msi_select[1:0],cfg_interrupt_msi_int[31:0],cfg_interrupt_msi_pending_status[31:0],cfg_interrupt_msi_pending_status_data_enable,cfg_interrupt_msi_pending_status_function_num[1:0],cfg_interrupt_msi_sent,cfg_interrupt_msi_fail,cfg_interrupt_msi_attr[2:0],cfg_interrupt_msi_tph_present,cfg_interrupt_msi_tph_type[1:0],cfg_interrupt_msi_tph_st_tag[7:0],cfg_interrupt_msi_function_number[7:0],cfg_pm_aspm_l1_entry_reject,cfg_pm_aspm_tx_l0s_entry_disable,cfg_hot_reset_out,cfg_config_space_enable,cfg_req_pm_transition_l23_ready,cfg_hot_reset_in,cfg_ds_port_number[7:0],cfg_ds_bus_number[7:0],cfg_ds_device_number[4:0],sys_clk,sys_clk_gt,sys_reset,common_commands_in[25:0],pipe_rx_0_sigs[83:0],pipe_rx_1_sigs[83:0],pipe_rx_2_sigs[83:0],pipe_rx_3_sigs[83:0],pipe_rx_4_sigs[83:0],pipe_rx_5_sigs[83:0],pipe_rx_6_sigs[83:0],pipe_rx_7_sigs[83:0],pipe_rx_8_sigs[83:0],pipe_rx_9_sigs[83:0],pipe_rx_10_sigs[83:0],pipe_rx_11_sigs[83:0],pipe_rx_12_sigs[83:0],pipe_rx_13_sigs[83:0],pipe_rx_14_sigs[83:0],pipe_rx_15_sigs[83:0],common_commands_out[25:0],pipe_tx_0_sigs[83:0],pipe_tx_1_sigs[83:0],pipe_tx_2_sigs[83:0],pipe_tx_3_sigs[83:0],pipe_tx_4_sigs[83:0],pipe_tx_5_sigs[83:0],pipe_tx_6_sigs[83:0],pipe_tx_7_sigs[83:0],pipe_tx_8_sigs[83:0],pipe_tx_9_sigs[83:0],pipe_tx_10_sigs[83:0],pipe_tx_11_sigs[83:0],pipe_tx_12_sigs[83:0],pipe_tx_13_sigs[83:0],pipe_tx_14_sigs[83:0],pipe_tx_15_sigs[83:0],gt_pcieuserratedone[7:0],gt_loopback[23:0],gt_txprbsforceerr[7:0],gt_txinhibit[7:0],gt_txprbssel[31:0],gt_rxprbssel[31:0],gt_rxprbscntreset[7:0],gt_txelecidle[7:0],gt_txresetdone[7:0],gt_rxresetdone[7:0],gt_rxpmaresetdone[7:0],gt_txphaligndone[7:0],gt_txphinitdone[7:0],gt_txdlysresetdone[7:0],gt_rxphaligndone[7:0],gt_rxdlysresetdone[7:0],gt_rxsyncdone[7:0],gt_eyescandataerror[7:0],gt_rxprbserr[7:0],gt_dmonfiforeset[7:0],gt_dmonitorclk[7:0],gt_dmonitorout[127:0],gt_rxcommadet[7:0],gt_phystatus[7:0],gt_rxvalid[7:0],gt_rxcdrlock[7:0],gt_pcierateidle[7:0],gt_pcieuserratestart[7:0],gt_gtpowergood[7:0],gt_cplllock[7:0],gt_rxoutclk[7:0],gt_rxrecclkout[7:0],gt_qpll1lock[1:0],gt_qpll0lock[1:0],gt_rxstatus[23:0],gt_rxbufstatus[23:0],gt_bufgtdiv[8:0],phy_txeq_ctrl[15:0],phy_txeq_preset[31:0],phy_rst_fsm[3:0],phy_txeq_fsm[23:0],phy_rxeq_fsm[23:0],phy_rst_idle,phy_rrst_n,phy_prst_n,gt_gen34_eios_det[7:0],gt_txoutclk[7:0],gt_txoutclkfabric[7:0],gt_rxoutclkfabric[7:0],gt_txoutclkpcs[7:0],gt_rxoutclkpcs[7:0],gt_txpmareset[7:0],gt_rxpmareset[7:0],gt_txpcsreset[7:0],gt_rxpcsreset[7:0],gt_rxbufreset[7:0],gt_rxcdrreset[7:0],gt_rxdfelpmreset[7:0],gt_txprogdivresetdone[7:0],gt_txpmaresetdone[7:0],gt_txsyncdone[7:0],gt_rxprbslocked[7:0],drp_rdy,drp_do[15:0],drp_clk,drp_en,drp_we,drp_addr[9:0],drp_di[15:0],phy_rdy_out" */;
  output [7:0]pci_exp_txn;
  output [7:0]pci_exp_txp;
  input [7:0]pci_exp_rxn;
  input [7:0]pci_exp_rxp;
  output user_clk;
  output user_reset;
  output user_lnk_up;
  input [255:0]s_axis_rq_tdata;
  input [7:0]s_axis_rq_tkeep;
  input s_axis_rq_tlast;
  output [3:0]s_axis_rq_tready;
  input [61:0]s_axis_rq_tuser;
  input s_axis_rq_tvalid;
  output [255:0]m_axis_rc_tdata;
  output [7:0]m_axis_rc_tkeep;
  output m_axis_rc_tlast;
  input m_axis_rc_tready;
  output [74:0]m_axis_rc_tuser;
  output m_axis_rc_tvalid;
  output [255:0]m_axis_cq_tdata;
  output [7:0]m_axis_cq_tkeep;
  output m_axis_cq_tlast;
  input m_axis_cq_tready;
  output [87:0]m_axis_cq_tuser;
  output m_axis_cq_tvalid;
  input [255:0]s_axis_cc_tdata;
  input [7:0]s_axis_cc_tkeep;
  input s_axis_cc_tlast;
  output [3:0]s_axis_cc_tready;
  input [32:0]s_axis_cc_tuser;
  input s_axis_cc_tvalid;
  output [5:0]pcie_rq_seq_num0;
  output pcie_rq_seq_num_vld0;
  output [5:0]pcie_rq_seq_num1;
  output pcie_rq_seq_num_vld1;
  output [7:0]pcie_rq_tag0;
  output [7:0]pcie_rq_tag1;
  output [3:0]pcie_rq_tag_av;
  output pcie_rq_tag_vld0;
  output pcie_rq_tag_vld1;
  output [3:0]pcie_tfc_nph_av;
  output [3:0]pcie_tfc_npd_av;
  input [1:0]pcie_cq_np_req;
  output [5:0]pcie_cq_np_req_count;
  output cfg_phy_link_down;
  output [1:0]cfg_phy_link_status;
  output [2:0]cfg_negotiated_width;
  output [1:0]cfg_current_speed;
  output [1:0]cfg_max_payload;
  output [2:0]cfg_max_read_req;
  output [15:0]cfg_function_status;
  output [11:0]cfg_function_power_state;
  output [503:0]cfg_vf_status;
  output [755:0]cfg_vf_power_state;
  output [1:0]cfg_link_power_state;
  input [9:0]cfg_mgmt_addr;
  input [7:0]cfg_mgmt_function_number;
  input cfg_mgmt_write;
  input [31:0]cfg_mgmt_write_data;
  input [3:0]cfg_mgmt_byte_enable;
  input cfg_mgmt_read;
  output [31:0]cfg_mgmt_read_data;
  output cfg_mgmt_read_write_done;
  input cfg_mgmt_debug_access;
  output cfg_err_cor_out;
  output cfg_err_nonfatal_out;
  output cfg_err_fatal_out;
  output cfg_local_error_valid;
  output [4:0]cfg_local_error_out;
  output [5:0]cfg_ltssm_state;
  output [1:0]cfg_rx_pm_state;
  output [1:0]cfg_tx_pm_state;
  output [3:0]cfg_rcb_status;
  output [1:0]cfg_obff_enable;
  output cfg_pl_status_change;
  output [3:0]cfg_tph_requester_enable;
  output [11:0]cfg_tph_st_mode;
  output [251:0]cfg_vf_tph_requester_enable;
  output [755:0]cfg_vf_tph_st_mode;
  output cfg_msg_received;
  output [7:0]cfg_msg_received_data;
  output [4:0]cfg_msg_received_type;
  input cfg_msg_transmit;
  input [2:0]cfg_msg_transmit_type;
  input [31:0]cfg_msg_transmit_data;
  output cfg_msg_transmit_done;
  output [7:0]cfg_fc_ph;
  output [11:0]cfg_fc_pd;
  output [7:0]cfg_fc_nph;
  output [11:0]cfg_fc_npd;
  output [7:0]cfg_fc_cplh;
  output [11:0]cfg_fc_cpld;
  input [2:0]cfg_fc_sel;
  input [63:0]cfg_dsn;
  output [7:0]cfg_bus_number;
  input cfg_power_state_change_ack;
  output cfg_power_state_change_interrupt;
  input cfg_err_cor_in;
  input cfg_err_uncor_in;
  output [3:0]cfg_flr_in_process;
  input [3:0]cfg_flr_done;
  output [251:0]cfg_vf_flr_in_process;
  input [7:0]cfg_vf_flr_func_num;
  input [0:0]cfg_vf_flr_done;
  input cfg_link_training_enable;
  input [3:0]cfg_interrupt_int;
  input [3:0]cfg_interrupt_pending;
  output cfg_interrupt_sent;
  output [3:0]cfg_interrupt_msi_enable;
  output [11:0]cfg_interrupt_msi_mmenable;
  output cfg_interrupt_msi_mask_update;
  output [31:0]cfg_interrupt_msi_data;
  input [1:0]cfg_interrupt_msi_select;
  input [31:0]cfg_interrupt_msi_int;
  input [31:0]cfg_interrupt_msi_pending_status;
  input cfg_interrupt_msi_pending_status_data_enable;
  input [1:0]cfg_interrupt_msi_pending_status_function_num;
  output cfg_interrupt_msi_sent;
  output cfg_interrupt_msi_fail;
  input [2:0]cfg_interrupt_msi_attr;
  input cfg_interrupt_msi_tph_present;
  input [1:0]cfg_interrupt_msi_tph_type;
  input [7:0]cfg_interrupt_msi_tph_st_tag;
  input [7:0]cfg_interrupt_msi_function_number;
  input cfg_pm_aspm_l1_entry_reject;
  input cfg_pm_aspm_tx_l0s_entry_disable;
  output cfg_hot_reset_out;
  input cfg_config_space_enable;
  input cfg_req_pm_transition_l23_ready;
  input cfg_hot_reset_in;
  input [7:0]cfg_ds_port_number;
  input [7:0]cfg_ds_bus_number;
  input [4:0]cfg_ds_device_number;
  input sys_clk;
  input sys_clk_gt;
  input sys_reset;
  input [25:0]common_commands_in;
  input [83:0]pipe_rx_0_sigs;
  input [83:0]pipe_rx_1_sigs;
  input [83:0]pipe_rx_2_sigs;
  input [83:0]pipe_rx_3_sigs;
  input [83:0]pipe_rx_4_sigs;
  input [83:0]pipe_rx_5_sigs;
  input [83:0]pipe_rx_6_sigs;
  input [83:0]pipe_rx_7_sigs;
  input [83:0]pipe_rx_8_sigs;
  input [83:0]pipe_rx_9_sigs;
  input [83:0]pipe_rx_10_sigs;
  input [83:0]pipe_rx_11_sigs;
  input [83:0]pipe_rx_12_sigs;
  input [83:0]pipe_rx_13_sigs;
  input [83:0]pipe_rx_14_sigs;
  input [83:0]pipe_rx_15_sigs;
  output [25:0]common_commands_out;
  output [83:0]pipe_tx_0_sigs;
  output [83:0]pipe_tx_1_sigs;
  output [83:0]pipe_tx_2_sigs;
  output [83:0]pipe_tx_3_sigs;
  output [83:0]pipe_tx_4_sigs;
  output [83:0]pipe_tx_5_sigs;
  output [83:0]pipe_tx_6_sigs;
  output [83:0]pipe_tx_7_sigs;
  output [83:0]pipe_tx_8_sigs;
  output [83:0]pipe_tx_9_sigs;
  output [83:0]pipe_tx_10_sigs;
  output [83:0]pipe_tx_11_sigs;
  output [83:0]pipe_tx_12_sigs;
  output [83:0]pipe_tx_13_sigs;
  output [83:0]pipe_tx_14_sigs;
  output [83:0]pipe_tx_15_sigs;
  input [7:0]gt_pcieuserratedone;
  input [23:0]gt_loopback;
  input [7:0]gt_txprbsforceerr;
  input [7:0]gt_txinhibit;
  input [31:0]gt_txprbssel;
  input [31:0]gt_rxprbssel;
  input [7:0]gt_rxprbscntreset;
  output [7:0]gt_txelecidle;
  output [7:0]gt_txresetdone;
  output [7:0]gt_rxresetdone;
  output [7:0]gt_rxpmaresetdone;
  output [7:0]gt_txphaligndone;
  output [7:0]gt_txphinitdone;
  output [7:0]gt_txdlysresetdone;
  output [7:0]gt_rxphaligndone;
  output [7:0]gt_rxdlysresetdone;
  output [7:0]gt_rxsyncdone;
  output [7:0]gt_eyescandataerror;
  output [7:0]gt_rxprbserr;
  input [7:0]gt_dmonfiforeset;
  input [7:0]gt_dmonitorclk;
  output [127:0]gt_dmonitorout;
  output [7:0]gt_rxcommadet;
  output [7:0]gt_phystatus;
  output [7:0]gt_rxvalid;
  output [7:0]gt_rxcdrlock;
  output [7:0]gt_pcierateidle;
  output [7:0]gt_pcieuserratestart;
  output [7:0]gt_gtpowergood;
  output [7:0]gt_cplllock;
  output [7:0]gt_rxoutclk;
  output [7:0]gt_rxrecclkout;
  output [1:0]gt_qpll1lock;
  output [1:0]gt_qpll0lock;
  output [23:0]gt_rxstatus;
  output [23:0]gt_rxbufstatus;
  output [8:0]gt_bufgtdiv;
  output [15:0]phy_txeq_ctrl;
  output [31:0]phy_txeq_preset;
  output [3:0]phy_rst_fsm;
  output [23:0]phy_txeq_fsm;
  output [23:0]phy_rxeq_fsm;
  output phy_rst_idle;
  output phy_rrst_n;
  output phy_prst_n;
  output [7:0]gt_gen34_eios_det;
  output [7:0]gt_txoutclk;
  output [7:0]gt_txoutclkfabric;
  output [7:0]gt_rxoutclkfabric;
  output [7:0]gt_txoutclkpcs;
  output [7:0]gt_rxoutclkpcs;
  input [7:0]gt_txpmareset;
  input [7:0]gt_rxpmareset;
  input [7:0]gt_txpcsreset;
  input [7:0]gt_rxpcsreset;
  input [7:0]gt_rxbufreset;
  input [7:0]gt_rxcdrreset;
  input [7:0]gt_rxdfelpmreset;
  output [7:0]gt_txprogdivresetdone;
  output [7:0]gt_txpmaresetdone;
  output [7:0]gt_txsyncdone;
  output [7:0]gt_rxprbslocked;
  output drp_rdy;
  output [15:0]drp_do;
  input drp_clk;
  input drp_en;
  input drp_we;
  input [9:0]drp_addr;
  input [15:0]drp_di;
  output phy_rdy_out;
endmodule
