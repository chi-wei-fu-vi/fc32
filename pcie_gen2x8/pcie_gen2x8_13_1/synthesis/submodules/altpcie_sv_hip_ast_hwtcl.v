// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altpcie_sv_hip_ast_hwtcl # (

      parameter pll_refclk_freq_hwtcl                             = "100 MHz",
      parameter set_pld_clk_x1_625MHz_hwtcl                       = 0,
      parameter enable_slot_register_hwtcl                        = 0,
      parameter port_type_hwtcl                                   = "Native endpoint",
      parameter bypass_cdc_hwtcl                                  = "false",
      parameter slotclkcfg_hwtcl                                  = 1,
      parameter enable_rx_buffer_checking_hwtcl                   = "false",
      parameter single_rx_detect_hwtcl                            = 0,
      parameter use_crc_forwarding_hwtcl                          = 0,
      parameter gen123_lane_rate_mode_hwtcl                       = "gen1",
      parameter lane_mask_hwtcl                                   = "x4",
      parameter in_cvp_mode_hwtcl                                 = 0,
      parameter disable_link_x2_support_hwtcl                     = "false",
      parameter wrong_device_id_hwtcl                             = "disable",
      parameter data_pack_rx_hwtcl                                = "disable",
      parameter ast_width_hwtcl                                   = "Avalon-ST 64-bit",
      parameter use_ast_parity                                    = 0,
      parameter ltssm_1ms_timeout_hwtcl                           = "disable",
      parameter ltssm_freqlocked_check_hwtcl                      = "disable",
      parameter gen3_rxfreqlock_counter_hwtcl                     = 0,
      parameter deskew_comma_hwtcl                                = "com_deskw",
      parameter port_link_number_hwtcl                            = 1,
      parameter device_number_hwtcl                               = 0,
      parameter bypass_clk_switch_hwtcl                           = "TRUE",
      parameter pipex1_debug_sel_hwtcl                            = "disable",
      parameter pclk_out_sel_hwtcl                                = "pclk",
      parameter vendor_id_hwtcl                                   = 4466,
      parameter device_id_hwtcl                                   = 57345,
      parameter revision_id_hwtcl                                 = 1,
      parameter class_code_hwtcl                                  = 16711680,
      parameter subsystem_vendor_id_hwtcl                         = 4466,
      parameter subsystem_device_id_hwtcl                         = 57345,
      parameter no_soft_reset_hwtcl                               = "false",
      parameter maximum_current_hwtcl                             = 0,
      parameter d1_support_hwtcl                                  = "false",
      parameter d2_support_hwtcl                                  = "false",
      parameter d0_pme_hwtcl                                      = "false",
      parameter d1_pme_hwtcl                                      = "false",
      parameter d2_pme_hwtcl                                      = "false",
      parameter d3_hot_pme_hwtcl                                  = "false",
      parameter d3_cold_pme_hwtcl                                 = "false",
      parameter use_aer_hwtcl                                     = 0,
      parameter low_priority_vc_hwtcl                             = "single_vc",
      parameter disable_snoop_packet_hwtcl                        = "false",
      parameter max_payload_size_hwtcl                            = 256,
      parameter surprise_down_error_support_hwtcl                 = 0,
      parameter dll_active_report_support_hwtcl                   = 0,
      parameter extend_tag_field_hwtcl                            = "false",
      parameter endpoint_l0_latency_hwtcl                         = 0,
      parameter endpoint_l1_latency_hwtcl                         = 0,
      parameter indicator_hwtcl                                   = 0,
      parameter slot_power_scale_hwtcl                            = 0,
      parameter enable_l0s_aspm_hwtcl                             = "true",
      parameter enable_l1_aspm_hwtcl                              = "false",
      parameter l1_exit_latency_sameclock_hwtcl                   = 0,
      parameter l1_exit_latency_diffclock_hwtcl                   = 0,
      parameter hot_plug_support_hwtcl                            = 0,
      parameter slot_power_limit_hwtcl                            = 0,
      parameter slot_number_hwtcl                                 = 0,
      parameter diffclock_nfts_count_hwtcl                        = 128,
      parameter sameclock_nfts_count_hwtcl                        = 128,
      parameter completion_timeout_hwtcl                          = "abcd",
      parameter enable_completion_timeout_disable_hwtcl           = 1,
      parameter extended_tag_reset_hwtcl                          = "false",
      parameter ecrc_check_capable_hwtcl                          = 0,
      parameter ecrc_gen_capable_hwtcl                            = 0,
      parameter no_command_completed_hwtcl                        = "true",
      parameter msi_multi_message_capable_hwtcl                   = "count_4",
      parameter msi_64bit_addressing_capable_hwtcl                = "true",
      parameter msi_masking_capable_hwtcl                         = "false",
      parameter msi_support_hwtcl                                 = "true",
      parameter interrupt_pin_hwtcl                               = "inta",
      parameter enable_function_msix_support_hwtcl                = 0,
      parameter msix_table_size_hwtcl                             = 0,
      parameter msix_table_bir_hwtcl                              = 0,
      parameter msix_table_offset_hwtcl                           = "0",
      parameter msix_pba_bir_hwtcl                                = 0,
      parameter msix_pba_offset_hwtcl                             = "0",
      parameter bridge_port_vga_enable_hwtcl                      = "false",
      parameter bridge_port_ssid_support_hwtcl                    = "false",
      parameter ssvid_hwtcl                                       = 0,
      parameter ssid_hwtcl                                        = 0,
      parameter eie_before_nfts_count_hwtcl                       = 4,
      parameter gen2_diffclock_nfts_count_hwtcl                   = 255,
      parameter gen2_sameclock_nfts_count_hwtcl                   = 255,
      parameter deemphasis_enable_hwtcl                           = "false",
      parameter pcie_spec_version_hwtcl                           = "v2",
      parameter l0_exit_latency_sameclock_hwtcl                   = 6,
      parameter l0_exit_latency_diffclock_hwtcl                   = 6,
      parameter rx_ei_l0s_hwtcl                                   = 1,
      parameter l2_async_logic_hwtcl                              = "disable",
      parameter aspm_config_management_hwtcl                      = "true",
      parameter atomic_op_routing_hwtcl                           = "false",
      parameter atomic_op_completer_32bit_hwtcl                   = "false",
      parameter atomic_op_completer_64bit_hwtcl                   = "false",
      parameter cas_completer_128bit_hwtcl                        = "false",
      parameter ltr_mechanism_hwtcl                               = "false",
      parameter tph_completer_hwtcl                               = "false",
      parameter extended_format_field_hwtcl                       = "false",
      parameter atomic_malformed_hwtcl                            = "true",
      parameter flr_capability_hwtcl                              = "false",
      parameter enable_adapter_half_rate_mode_hwtcl               = "false",
      parameter vc0_clk_enable_hwtcl                              = "true",
      parameter register_pipe_signals_hwtcl                       = "false",
      parameter bar0_io_space_hwtcl                               = "Disabled",
      parameter bar0_64bit_mem_space_hwtcl                        = "Enabled",
      parameter bar0_prefetchable_hwtcl                           = "Enabled",
      parameter bar0_size_mask_hwtcl                              = 28,
      parameter bar1_io_space_hwtcl                               = "Disabled",
      parameter bar1_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar1_prefetchable_hwtcl                           = "Disabled",
      parameter bar1_size_mask_hwtcl                              = 0,
      parameter bar2_io_space_hwtcl                               = "Disabled",
      parameter bar2_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar2_prefetchable_hwtcl                           = "Disabled",
      parameter bar2_size_mask_hwtcl                              = 0,
      parameter bar3_io_space_hwtcl                               = "Disabled",
      parameter bar3_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar3_prefetchable_hwtcl                           = "Disabled",
      parameter bar3_size_mask_hwtcl                              = 0,
      parameter bar4_io_space_hwtcl                               = "Disabled",
      parameter bar4_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar4_prefetchable_hwtcl                           = "Disabled",
      parameter bar4_size_mask_hwtcl                              = 0,
      parameter bar5_io_space_hwtcl                               = "Disabled",
      parameter bar5_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar5_prefetchable_hwtcl                           = "Disabled",
      parameter bar5_size_mask_hwtcl                              = 0,
      parameter expansion_base_address_register_hwtcl             = 0,
      parameter io_window_addr_width_hwtcl                        = 0,
      parameter prefetchable_mem_window_addr_width_hwtcl          = 0,
      parameter skp_os_gen3_count_hwtcl                           = 0,
      parameter tx_cdc_almost_empty_hwtcl                         = 5,
      parameter rx_cdc_almost_full_hwtcl                          = 12,
      parameter tx_cdc_almost_full_hwtcl                          = 11,
      parameter rx_l0s_count_idl_hwtcl                            = 0,
      parameter cdc_dummy_insert_limit_hwtcl                      = 11,
      parameter ei_delay_powerdown_count_hwtcl                    = 10,
      parameter millisecond_cycle_count_hwtcl                     = 124250,
      parameter skp_os_schedule_count_hwtcl                       = 0,
      parameter fc_init_timer_hwtcl                               = 1024,
      parameter l01_entry_latency_hwtcl                           = 31,
      parameter flow_control_update_count_hwtcl                   = 30,
      parameter flow_control_timeout_count_hwtcl                  = 200,
      parameter credit_buffer_allocation_aux_hwtcl                = "balanced",
      parameter vc0_rx_flow_ctrl_posted_header_hwtcl              = 50,
      parameter vc0_rx_flow_ctrl_posted_data_hwtcl                = 360,
      parameter vc0_rx_flow_ctrl_nonposted_header_hwtcl           = 54,
      parameter vc0_rx_flow_ctrl_nonposted_data_hwtcl             = 0,
      parameter vc0_rx_flow_ctrl_compl_header_hwtcl               = 112,
      parameter vc0_rx_flow_ctrl_compl_data_hwtcl                 = 448,
      parameter cpl_spc_header_hwtcl                              = 112,
      parameter cpl_spc_data_hwtcl                                = 448,
      parameter retry_buffer_last_active_address_hwtcl            = 2047,
      parameter reconfig_to_xcvr_width                            = 350,
      parameter reconfig_from_xcvr_width                          = 230,
      parameter hip_hard_reset_hwtcl                              = 1,
      parameter reserved_debug_hwtcl                              = 0,
      parameter gen3_skip_ph2_ph3_hwtcl                           = 1,
      parameter gen3_dcbal_en_hwtcl                               = 1,
      parameter g3_bypass_equlz_hwtcl                             = 1,

      parameter use_tx_cons_cred_sel_hwtcl                        = 0,
      parameter enable_pipe32_sim_hwtcl                           = 0,
      parameter enable_tl_only_sim_hwtcl                          = 0,
      parameter use_atx_pll_hwtcl                                 = 0,
      parameter hip_reconfig_hwtcl                                = 0,
      parameter port_width_data_hwtcl                             = 256,
      parameter port_width_be_hwtcl                               = 32,
      parameter use_config_bypass_hwtcl                           = 0,
      parameter use_pci_ext_hwtcl                                 = 0,
      parameter use_pcie_ext_hwtcl                                = 0,
      parameter multiple_packets_per_cycle_hwtcl                  = 0,
      parameter vsec_id_hwtcl                                     = 0,
      parameter vsec_rev_hwtcl                                    = 0,
      parameter full_swing_hwtcl                                  = 35,
      parameter low_latency_mode_hwtcl                            = 0,


      parameter hwtcl_override_g3rxcoef                       = 0, // When 1 use gen3 param from HWTCL, else use default

      parameter gen3_coeff_1_hwtcl                            = 7,
      parameter gen3_coeff_1_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_1_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_1_nxtber_more_ptr_hwtcl            = 1,
      parameter gen3_coeff_1_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_1_nxtber_less_ptr_hwtcl            = 1,
      parameter gen3_coeff_1_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_1_reqber_hwtcl                     = 0,
      parameter gen3_coeff_1_ber_meas_hwtcl                   = 2,

      parameter gen3_coeff_2_hwtcl                            = 0,
      parameter gen3_coeff_2_sel_hwtcl                        = "preset_2",
      parameter gen3_coeff_2_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_2_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_2_nxtber_more_hwtcl                = "g3_coeff_2_nxtber_more",
      parameter gen3_coeff_2_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_2_nxtber_less_hwtcl                = "g3_coeff_2_nxtber_less",
      parameter gen3_coeff_2_reqber_hwtcl                     = 0,
      parameter gen3_coeff_2_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_3_hwtcl                            = 0,
      parameter gen3_coeff_3_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_3_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_3_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_3_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_3_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_3_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_3_reqber_hwtcl                     = 0,
      parameter gen3_coeff_3_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_4_hwtcl                            = 0,
      parameter gen3_coeff_4_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_4_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_4_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_4_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_4_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_4_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_4_reqber_hwtcl                     = 0,
      parameter gen3_coeff_4_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_5_hwtcl                            = 0,
      parameter gen3_coeff_5_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_5_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_5_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_5_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_5_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_5_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_5_reqber_hwtcl                     = 0,
      parameter gen3_coeff_5_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_6_hwtcl                            = 0,
      parameter gen3_coeff_6_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_6_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_6_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_6_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_6_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_6_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_6_reqber_hwtcl                     = 0,
      parameter gen3_coeff_6_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_7_hwtcl                            = 0,
      parameter gen3_coeff_7_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_7_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_7_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_7_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_7_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_7_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_7_reqber_hwtcl                     = 0,
      parameter gen3_coeff_7_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_8_hwtcl                            = 0,
      parameter gen3_coeff_8_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_8_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_8_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_8_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_8_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_8_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_8_reqber_hwtcl                     = 0,
      parameter gen3_coeff_8_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_9_hwtcl                            = 0,
      parameter gen3_coeff_9_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_9_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_9_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_9_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_9_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_9_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_9_reqber_hwtcl                     = 0,
      parameter gen3_coeff_9_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_10_hwtcl                            = 0,
      parameter gen3_coeff_10_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_10_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_10_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_10_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_10_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_10_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_10_reqber_hwtcl                     = 0,
      parameter gen3_coeff_10_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_11_hwtcl                            = 0,
      parameter gen3_coeff_11_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_11_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_11_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_11_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_11_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_11_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_11_reqber_hwtcl                     = 0,
      parameter gen3_coeff_11_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_12_hwtcl                            = 0,
      parameter gen3_coeff_12_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_12_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_12_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_12_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_12_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_12_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_12_reqber_hwtcl                     = 0,
      parameter gen3_coeff_12_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_13_hwtcl                            = 0,
      parameter gen3_coeff_13_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_13_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_13_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_13_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_13_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_13_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_13_reqber_hwtcl                     = 0,
      parameter gen3_coeff_13_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_14_hwtcl                            = 0,
      parameter gen3_coeff_14_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_14_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_14_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_14_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_14_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_14_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_14_reqber_hwtcl                     = 0,
      parameter gen3_coeff_14_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_15_hwtcl                            = 0,
      parameter gen3_coeff_15_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_15_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_15_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_15_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_15_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_15_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_15_reqber_hwtcl                     = 0,
      parameter gen3_coeff_15_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_16_hwtcl                            = 0,
      parameter gen3_coeff_16_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_16_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_16_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_16_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_16_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_16_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_16_reqber_hwtcl                     = 0,
      parameter gen3_coeff_16_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_17_hwtcl                            = 0,
      parameter gen3_coeff_17_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_17_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_17_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_17_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_17_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_17_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_17_reqber_hwtcl                     = 0,
      parameter gen3_coeff_17_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_18_hwtcl                            = 0,
      parameter gen3_coeff_18_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_18_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_18_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_18_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_18_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_18_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_18_reqber_hwtcl                     = 0,
      parameter gen3_coeff_18_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_19_hwtcl                            = 0,
      parameter gen3_coeff_19_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_19_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_19_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_19_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_19_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_19_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_19_reqber_hwtcl                     = 0,
      parameter gen3_coeff_19_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_20_hwtcl                            = 0,
      parameter gen3_coeff_20_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_20_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_20_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_20_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_20_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_20_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_20_reqber_hwtcl                     = 0,
      parameter gen3_coeff_20_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_21_hwtcl                            = 0,
      parameter gen3_coeff_21_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_21_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_21_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_21_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_21_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_21_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_21_reqber_hwtcl                     = 0,
      parameter gen3_coeff_21_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_22_hwtcl                            = 0,
      parameter gen3_coeff_22_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_22_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_22_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_22_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_22_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_22_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_22_reqber_hwtcl                     = 0,
      parameter gen3_coeff_22_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_23_hwtcl                            = 0,
      parameter gen3_coeff_23_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_23_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_23_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_23_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_23_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_23_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_23_reqber_hwtcl                     = 0,
      parameter gen3_coeff_23_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_24_hwtcl                            = 0,
      parameter gen3_coeff_24_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_24_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_24_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_24_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_24_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_24_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_24_reqber_hwtcl                     = 0,
      parameter gen3_coeff_24_ber_meas_hwtcl                   = 0,

      parameter hwtcl_override_g3txcoef                  = 0, // When 1 use gen3 param from HWTCL, else use default
      parameter gen3_preset_coeff_1_hwtcl                      = 0,
      parameter gen3_preset_coeff_2_hwtcl                      = 0,
      parameter gen3_preset_coeff_3_hwtcl                      = 0,
      parameter gen3_preset_coeff_4_hwtcl                      = 0,
      parameter gen3_preset_coeff_5_hwtcl                      = 0,
      parameter gen3_preset_coeff_6_hwtcl                      = 0,
      parameter gen3_preset_coeff_7_hwtcl                      = 0,
      parameter gen3_preset_coeff_8_hwtcl                      = 0,
      parameter gen3_preset_coeff_9_hwtcl                      = 0,
      parameter gen3_preset_coeff_10_hwtcl                     = 0,
      parameter gen3_preset_coeff_11_hwtcl                     = 0,
      parameter gen3_low_freq_hwtcl                            = 0,
      parameter gen3_full_swing_hwtcl                          = 35,


      parameter hwtcl_override_g2_txvod                        = 0, // When 1 use gen3 param from HWTCL, else use default
      parameter rpre_emph_a_val_hwtcl                          = 9 ,
      parameter rpre_emph_b_val_hwtcl                          = 0 ,
      parameter rpre_emph_c_val_hwtcl                          = 16,
      parameter rpre_emph_d_val_hwtcl                          = 11,
      parameter rpre_emph_e_val_hwtcl                          = 5 ,
      parameter rvod_sel_a_val_hwtcl                           = 42,
      parameter rvod_sel_b_val_hwtcl                           = 38,
      parameter rvod_sel_c_val_hwtcl                           = 38,
      parameter rvod_sel_d_val_hwtcl                           = 38,
      parameter rvod_sel_e_val_hwtcl                           = 15,

      parameter cvp_rate_sel_hwtcl                             = "full_rate",
      parameter cvp_data_compressed_hwtcl                      = "false",
      parameter cvp_data_encrypted_hwtcl                       = "false",
      parameter cvp_mode_reset_hwtcl                           = "false",
      parameter cvp_clk_reset_hwtcl                            = "false",
      parameter cseb_cpl_status_during_cvp_hwtcl               = "config_retry_status",
      parameter core_clk_sel_hwtcl                             = "pld_clk",
      parameter fixed_preset_on                                = 0,
      parameter g3_dis_rx_use_prst_hwtcl                       = "true",
      parameter g3_dis_rx_use_prst_ep_hwtcl                    = "false"

) (
  // Control signals
  input        [31 : 0]                       test_in,
  input                                       simu_mode_pipe,                //  When 1'b1 indicate running DUT under pipe simulation
  input        [31 : 0]                       reservedin,

  // Reset signals
  input                                       pin_perst,
  input                                       npor,
  output logic                                reset_status,
  output logic                                serdes_pll_locked,
  output logic                                pld_clk_inuse,
  input                                       pld_core_ready,
  output logic                                testin_zero,

  // Clock
  input                                       pld_clk,

  // Serdes related
  input                                       refclk,

  // Reconfig GXB
  input        [reconfig_to_xcvr_width-1:0]   reconfig_to_xcvr,
  output logic [reconfig_from_xcvr_width-1:0] reconfig_from_xcvr,
  output logic                                fixedclk_locked,

  // HIP control signals
  input        [4 : 0]                        hpg_ctrler,

  // Input PIPE simulation _ext for simulation only
  output logic [1 : 0]                        sim_pipe_rate,
  input                                       sim_pipe_pclk_in,
  output logic                                sim_pipe_pclk_out,
  output logic                                sim_pipe_clk250_out,
  output logic                                sim_pipe_clk500_out,
  output logic [4 : 0]                        sim_ltssmstate,
  input                                       phystatus0,
  input                                       phystatus1,
  input                                       phystatus2,
  input                                       phystatus3,
  input                                       phystatus4,
  input                                       phystatus5,
  input                                       phystatus6,
  input                                       phystatus7,
  input        [7 : 0]                        rxdata0,
  input        [7 : 0]                        rxdata1,
  input        [7 : 0]                        rxdata2,
  input        [7 : 0]                        rxdata3,
  input        [7 : 0]                        rxdata4,
  input        [7 : 0]                        rxdata5,
  input        [7 : 0]                        rxdata6,
  input        [7 : 0]                        rxdata7,
  input                                       rxdatak0,
  input                                       rxdatak1,
  input                                       rxdatak2,
  input                                       rxdatak3,
  input                                       rxdatak4,
  input                                       rxdatak5,
  input                                       rxdatak6,
  input                                       rxdatak7,
  input                                       rxelecidle0,
  input                                       rxelecidle1,
  input                                       rxelecidle2,
  input                                       rxelecidle3,
  input                                       rxelecidle4,
  input                                       rxelecidle5,
  input                                       rxelecidle6,
  input                                       rxelecidle7,
  input                                       rxfreqlocked0,
  input                                       rxfreqlocked1,
  input                                       rxfreqlocked2,
  input                                       rxfreqlocked3,
  input                                       rxfreqlocked4,
  input                                       rxfreqlocked5,
  input                                       rxfreqlocked6,
  input                                       rxfreqlocked7,
  input        [2 : 0]                        rxstatus0,
  input        [2 : 0]                        rxstatus1,
  input        [2 : 0]                        rxstatus2,
  input        [2 : 0]                        rxstatus3,
  input        [2 : 0]                        rxstatus4,
  input        [2 : 0]                        rxstatus5,
  input        [2 : 0]                        rxstatus6,
  input        [2 : 0]                        rxstatus7,
  input                                       rxdataskip0,
  input                                       rxdataskip1,
  input                                       rxdataskip2,
  input                                       rxdataskip3,
  input                                       rxdataskip4,
  input                                       rxdataskip5,
  input                                       rxdataskip6,
  input                                       rxdataskip7,
  input                                       rxblkst0,
  input                                       rxblkst1,
  input                                       rxblkst2,
  input                                       rxblkst3,
  input                                       rxblkst4,
  input                                       rxblkst5,
  input                                       rxblkst6,
  input                                       rxblkst7,
  input        [1 : 0]                        rxsynchd0,
  input        [1 : 0]                        rxsynchd1,
  input        [1 : 0]                        rxsynchd2,
  input        [1 : 0]                        rxsynchd3,
  input        [1 : 0]                        rxsynchd4,
  input        [1 : 0]                        rxsynchd5,
  input        [1 : 0]                        rxsynchd6,
  input        [1 : 0]                        rxsynchd7,
  input                                       rxvalid0,
  input                                       rxvalid1,
  input                                       rxvalid2,
  input                                       rxvalid3,
  input                                       rxvalid4,
  input                                       rxvalid5,
  input                                       rxvalid6,
  input                                       rxvalid7,

  //TL BFM Ports
  output logic [1000 : 0]                     tlbfm_in,
  input        [1000 : 0]                     tlbfm_out,


  // Application signals inputs
  input        [4 : 0]                        aer_msi_num,
  input                                       app_int_sts,
  input        [4 : 0]                        app_msi_num,
  input                                       app_msi_req,
  input        [2 : 0]                        app_msi_tc,
  input        [4 : 0]                        pex_msi_num,

  input        [11 : 0]                       lmi_addr,
  input        [31 : 0]                       lmi_din,
  input                                       lmi_rden,
  input                                       lmi_wren,
  input                                       pm_auxpwr,
  input        [9 : 0]                        pm_data,
  input                                       pme_to_cr,
  input                                       pm_event,
  input                                       rx_st_mask,
  input                                       rx_st_ready,

  input        [port_width_data_hwtcl-1 : 0]  tx_st_data,
  input        [1 :0]                         tx_st_empty,
  input        [multiple_packets_per_cycle_hwtcl :0] tx_st_eop,
  input        [multiple_packets_per_cycle_hwtcl :0] tx_st_err,
  input        [multiple_packets_per_cycle_hwtcl :0] tx_st_sop,
  input        [port_width_be_hwtcl-1 :0]     tx_st_parity,
  input        [multiple_packets_per_cycle_hwtcl :0] tx_st_valid,

  input        [6 :0]                         cpl_err,
  input                                       cpl_pending,


  // Output Pipe interface
  output logic [2 : 0]                        eidleinfersel0,
  output logic [2 : 0]                        eidleinfersel1,
  output logic [2 : 0]                        eidleinfersel2,
  output logic [2 : 0]                        eidleinfersel3,
  output logic [2 : 0]                        eidleinfersel4,
  output logic [2 : 0]                        eidleinfersel5,
  output logic [2 : 0]                        eidleinfersel6,
  output logic [2 : 0]                        eidleinfersel7,
  output logic [1 : 0]                        powerdown0,
  output logic [1 : 0]                        powerdown1,
  output logic [1 : 0]                        powerdown2,
  output logic [1 : 0]                        powerdown3,
  output logic [1 : 0]                        powerdown4,
  output logic [1 : 0]                        powerdown5,
  output logic [1 : 0]                        powerdown6,
  output logic [1 : 0]                        powerdown7,
  output logic                                rxpolarity0,
  output logic                                rxpolarity1,
  output logic                                rxpolarity2,
  output logic                                rxpolarity3,
  output logic                                rxpolarity4,
  output logic                                rxpolarity5,
  output logic                                rxpolarity6,
  output logic                                rxpolarity7,
  output logic                                txcompl0,
  output logic                                txcompl1,
  output logic                                txcompl2,
  output logic                                txcompl3,
  output logic                                txcompl4,
  output logic                                txcompl5,
  output logic                                txcompl6,
  output logic                                txcompl7,
  output logic [7 : 0]                        txdata0,
  output logic [7 : 0]                        txdata1,
  output logic [7 : 0]                        txdata2,
  output logic [7 : 0]                        txdata3,
  output logic [7 : 0]                        txdata4,
  output logic [7 : 0]                        txdata5,
  output logic [7 : 0]                        txdata6,
  output logic [7 : 0]                        txdata7,
  output logic                                txdatak0,
  output logic                                txdatak1,
  output logic                                txdatak2,
  output logic                                txdatak3,
  output logic                                txdatak4,
  output logic                                txdatak5,
  output logic                                txdatak6,
  output logic                                txdatak7,
  output logic                                txdetectrx0,
  output logic                                txdetectrx1,
  output logic                                txdetectrx2,
  output logic                                txdetectrx3,
  output logic                                txdetectrx4,
  output logic                                txdetectrx5,
  output logic                                txdetectrx6,
  output logic                                txdetectrx7,
  output logic                                txelecidle0,
  output logic                                txelecidle1,
  output logic                                txelecidle2,
  output logic                                txelecidle3,
  output logic                                txelecidle4,
  output logic                                txelecidle5,
  output logic                                txelecidle6,
  output logic                                txelecidle7,
  output logic [2 : 0]                        txmargin0,
  output logic [2 : 0]                        txmargin1,
  output logic [2 : 0]                        txmargin2,
  output logic [2 : 0]                        txmargin3,
  output logic [2 : 0]                        txmargin4,
  output logic [2 : 0]                        txmargin5,
  output logic [2 : 0]                        txmargin6,
  output logic [2 : 0]                        txmargin7,
  output logic                                txdeemph0,
  output logic                                txdeemph1,
  output logic                                txdeemph2,
  output logic                                txdeemph3,
  output logic                                txdeemph4,
  output logic                                txdeemph5,
  output logic                                txdeemph6,
  output logic                                txdeemph7,
  output logic                                txswing0,
  output logic                                txswing1,
  output logic                                txswing2,
  output logic                                txswing3,
  output logic                                txswing4,
  output logic                                txswing5,
  output logic                                txswing6,
  output logic                                txswing7,
  output logic                                txblkst0,
  output logic                                txblkst1,
  output logic                                txblkst2,
  output logic                                txblkst3,
  output logic                                txblkst4,
  output logic                                txblkst5,
  output logic                                txblkst6,
  output logic                                txblkst7,
  output logic [1 : 0]                        txsynchd0,
  output logic [1 : 0]                        txsynchd1,
  output logic [1 : 0]                        txsynchd2,
  output logic [1 : 0]                        txsynchd3,
  output logic [1 : 0]                        txsynchd4,
  output logic [1 : 0]                        txsynchd5,
  output logic [1 : 0]                        txsynchd6,
  output logic [1 : 0]                        txsynchd7,
  output logic [17 : 0]                       currentcoeff0,
  output logic [17 : 0]                       currentcoeff1,
  output logic [17 : 0]                       currentcoeff2,
  output logic [17 : 0]                       currentcoeff3,
  output logic [17 : 0]                       currentcoeff4,
  output logic [17 : 0]                       currentcoeff5,
  output logic [17 : 0]                       currentcoeff6,
  output logic [17 : 0]                       currentcoeff7,
  output logic [2 : 0]                        currentrxpreset0,
  output logic [2 : 0]                        currentrxpreset1,
  output logic [2 : 0]                        currentrxpreset2,
  output logic [2 : 0]                        currentrxpreset3,
  output logic [2 : 0]                        currentrxpreset4,
  output logic [2 : 0]                        currentrxpreset5,
  output logic [2 : 0]                        currentrxpreset6,
  output logic [2 : 0]                        currentrxpreset7,


  // Output HIP Status signals
  output logic                                coreclkout_hip,
  output logic [1 : 0]                        currentspeed,
  output logic                                derr_cor_ext_rcv,
  output logic                                derr_cor_ext_rpl,
  output logic                                derr_rpl,
  output logic                                rx_par_err,
  output logic [1:0]                          tx_par_err,
  output logic                                cfg_par_err,
  output logic                                dlup,
  output logic                                dlup_exit,
  output logic                                ev128ns,
  output logic                                ev1us,
  output logic                                hotrst_exit,
  output logic [3 : 0]                        int_status,
  output logic                                l2_exit,
  output logic [3 : 0]                        lane_act,
  output logic [4 : 0]                        ltssmstate,
  output logic [7 :0]                         ko_cpl_spc_header,
  output logic [11 :0]                        ko_cpl_spc_data,
  output logic                                rxfc_cplbuf_ovf,

  // Output Application interface
  output logic                                serr_out,
  output logic                                app_int_ack,
  output logic                                app_msi_ack,
  output logic                                lmi_ack,
  output logic [31 : 0]                       lmi_dout,
  output logic                                pme_to_sr,

  output logic [7 : 0]                        rx_st_bar,

  output logic [port_width_be_hwtcl-1 : 0]    rx_st_be,
  output logic [port_width_be_hwtcl-1 : 0]    rx_st_parity,
  output logic [port_width_data_hwtcl-1 : 0]  rx_st_data,
  output logic [multiple_packets_per_cycle_hwtcl:0] rx_st_sop,
  output logic [multiple_packets_per_cycle_hwtcl:0] rx_st_valid,
  output logic [1:0]                          rx_st_empty,
  output logic [multiple_packets_per_cycle_hwtcl:0] rx_st_eop,
  output logic [multiple_packets_per_cycle_hwtcl:0] rx_st_err,

  input                                       tx_cons_cred_sel,
  output logic [3 : 0]                        tl_cfg_add,
  output logic [31 : 0]                       tl_cfg_ctl,
  output logic [52 : 0]                       tl_cfg_sts,
  output logic [11 : 0]                       tx_cred_datafccp,
  output logic [11 : 0]                       tx_cred_datafcnp,
  output logic [11 : 0]                       tx_cred_datafcp,
  output logic [5 : 0]                        tx_cred_fchipcons,
  output logic [5 : 0]                        tx_cred_fcinfinite,
  output logic [7 : 0]                        tx_cred_hdrfccp,
  output logic [7 : 0]                        tx_cred_hdrfcnp,
  output logic [7 : 0]                        tx_cred_hdrfcp,
  output logic                                tx_st_ready,
  //
  // HIP Reconfig
  input                                       hip_reconfig_rst_n,            //  DPRIO reset
  input                                       hip_reconfig_clk,              //  DPRIO clock
  input                                       hip_reconfig_write,            //  write enable input
  input                                       hip_reconfig_read,             //  read enable input
  input        [1:0]                          hip_reconfig_byte_en,          //  Byte enable
  input        [9:0]                          hip_reconfig_address,          //  address input
  input        [15:0]                         hip_reconfig_writedata,        //  write data input
  output logic [15:0]                         hip_reconfig_readdata,         //  Read data output
  input                                       ser_shift_load,                //  1'b1=shift in data from si into scan flop
  // 1'b0=load data from writedata into scan flop
  // Toggle 1->0 (10 clock cycle) 0->1 cp CSR  bits into DPRIO  Register
  input                                       interface_sel,                 //  Interface selection inputs
  // 1'b1: select CSR as a source for CRAM
  // After toggling ser_shift_load
  // de-assert interface_sel 1-->0
  // serial interface
  input                                       rx_in0,
  input                                       rx_in1,
  input                                       rx_in2,
  input                                       rx_in3,
  input                                       rx_in4,
  input                                       rx_in5,
  input                                       rx_in6,
  input                                       rx_in7,

  output logic                                tx_out0,
  output logic                                tx_out1,
  output logic                                tx_out2,
  output logic                                tx_out3,
  output logic                                tx_out4,
  output logic                                tx_out5,
  output logic                                tx_out6,
  output logic                                tx_out7,


  // Config. Bypass
  input        [12:0]                         cfgbp_link2csr,
  input                                       cfgbp_comclk_reg,
  input                                       cfgbp_extsy_reg,
  input        [2:0]                          cfgbp_max_pload,
  input                                       cfgbp_tx_ecrcgen,
  input                                       cfgbp_rx_ecrchk,
  input        [7:0]                          cfgbp_secbus,
  input                                       cfgbp_linkcsr_bit0,
  input                                       cfgbp_tx_req_pm,
  input        [2:0]                          cfgbp_tx_typ_pm,
  input        [3:0]                          cfgbp_req_phypm,
  input        [3:0]                          cfgbp_req_phycfg,
  input        [6:0]                          cfgbp_vc0_tcmap_pld,
  input                                       cfgbp_inh_dllp,
  input                                       cfgbp_inh_tx_tlp,
  input                                       cfgbp_req_wake,
  input        [1:0]                          cfgbp_link3_ctl,

  output logic [7:0]                          cfgbp_lane_err,
  output logic                                cfgbp_link_equlz_req,
  output logic                                cfgbp_equiz_complete,
  output logic                                cfgbp_phase_3_successful,
  output logic                                cfgbp_phase_2_successful,
  output logic                                cfgbp_phase_1_successful,
  output logic                                cfgbp_current_deemph,
  output logic [1:0]                          cfgbp_current_speed,
  output logic                                cfgbp_link_up,
  output logic                                cfgbp_link_train,
  output logic                                cfgbp_10state,
  output logic                                cfgbp_10sstate,
  output logic                                cfgbp_rx_val_pm,
  output logic [2:0]                          cfgbp_rx_typ_pm,
  output logic                                cfgbp_tx_ack_pm,
  output logic [1:0]                          cfgbp_ack_phypm,
  output logic                                cfgbp_vc_status,
  output logic                                cfgbp_rxfc_max,
  output logic                                cfgbp_txfc_max,
  output logic                                cfgbp_txbuf_emp,
  output logic                                cfgbp_cfgbuf_emp,
  output logic                                cfgbp_rpbuf_emp,
  output logic                                cfgbp_dll_req,
  output logic                                cfgbp_link_auto_bdw_status,
  output logic                                cfgbp_link_bdw_mng_status,
  output logic                                cfgbp_rst_tx_margin_field,
  output logic                                cfgbp_rst_enter_comp_bit,
  output logic [3:0]                          cfgbp_rx_st_ecrcerr,
  output logic                                cfgbp_err_uncorr_internal,
  output logic                                cfgbp_rx_corr_internal,
  output logic                                cfgbp_err_tlrcvovf,
  output logic                                cfgbp_txfc_err,
  output logic                                cfgbp_err_tlmalf,
  output logic                                cfgbp_err_surpdwn_dll,
  output logic                                cfgbp_err_dllrev,
  output logic                                cfgbp_err_dll_repnum,
  output logic                                cfgbp_err_dllreptim,
  output logic                                cfgbp_err_dllp_baddllp,
  output logic                                cfgbp_err_dll_badtlp,
  output logic                                cfgbp_err_phy_tng,
  output logic                                cfgbp_err_phy_rcv,
  output logic                                cfgbp_root_err_reg_sts,
  output logic                                cfgbp_corr_err_reg_sts,
  output logic                                cfgbp_unc_err_reg_sts,


  // CSEB I/O
  input        [31 : 0]                       cseb_rddata,
  input        [3 : 0]                        cseb_rddata_parity,
  input        [4 : 0]                        cseb_rdresponse,
  input                                       cseb_waitrequest,
  input        [4 : 0]                        cseb_wrresponse,
  input                                       cseb_wrresp_valid,

  output logic [32 : 0]                       cseb_addr,
  output logic [4 : 0]                        cseb_addr_parity,
  output logic [3 : 0]                        cseb_be,
  output logic                                cseb_is_shadow,
  output logic                                cseb_rden,
  output logic [31 : 0]                       cseb_wrdata,
  output logic [3 : 0]                        cseb_wrdata_parity,
  output logic                                cseb_wren,
  output logic                                cseb_wrresp_req 


      );


  assign reset_status = 0;
  assign serdes_pll_locked = 0;
  assign pld_clk_inuse = 0;
  assign testin_zero = 0;
  assign reconfig_from_xcvr = 0;
  assign fixedclk_locked = 0;
  assign sim_pipe_rate = 0;
  assign sim_pipe_pclk_out = 0;
  assign sim_pipe_clk250_out = 0;
  assign sim_pipe_clk500_out = 0;
  assign sim_ltssmstate = 0;
  assign tlbfm_in = 0;
  assign eidleinfersel0 = 0;
  assign eidleinfersel1 = 0;
  assign eidleinfersel2 = 0;
  assign eidleinfersel3 = 0;
  assign eidleinfersel4 = 0;
  assign eidleinfersel5 = 0;
  assign eidleinfersel6 = 0;
  assign eidleinfersel7 = 0;
  assign powerdown0 = 0;
  assign powerdown1 = 0;
  assign powerdown2 = 0;
  assign powerdown3 = 0;
  assign powerdown4 = 0;
  assign powerdown5 = 0;
  assign powerdown6 = 0;
  assign powerdown7 = 0;
  assign rxpolarity0 = 0;
  assign rxpolarity1 = 0;
  assign rxpolarity2 = 0;
  assign rxpolarity3 = 0;
  assign rxpolarity4 = 0;
  assign rxpolarity5 = 0;
  assign rxpolarity6 = 0;
  assign rxpolarity7 = 0;
  assign txcompl0 = 0;
  assign txcompl1 = 0;
  assign txcompl2 = 0;
  assign txcompl3 = 0;
  assign txcompl4 = 0;
  assign txcompl5 = 0;
  assign txcompl6 = 0;
  assign txcompl7 = 0;
  assign txdata0 = 0;
  assign txdata1 = 0;
  assign txdata2 = 0;
  assign txdata3 = 0;
  assign txdata4 = 0;
  assign txdata5 = 0;
  assign txdata6 = 0;
  assign txdata7 = 0;
  assign txdatak0 = 0;
  assign txdatak1 = 0;
  assign txdatak2 = 0;
  assign txdatak3 = 0;
  assign txdatak4 = 0;
  assign txdatak5 = 0;
  assign txdatak6 = 0;
  assign txdatak7 = 0;
  assign txdetectrx0 = 0;
  assign txdetectrx1 = 0;
  assign txdetectrx2 = 0;
  assign txdetectrx3 = 0;
  assign txdetectrx4 = 0;
  assign txdetectrx5 = 0;
  assign txdetectrx6 = 0;
  assign txdetectrx7 = 0;
  assign txelecidle0 = 0;
  assign txelecidle1 = 0;
  assign txelecidle2 = 0;
  assign txelecidle3 = 0;
  assign txelecidle4 = 0;
  assign txelecidle5 = 0;
  assign txelecidle6 = 0;
  assign txelecidle7 = 0;
  assign txmargin0 = 0;
  assign txmargin1 = 0;
  assign txmargin2 = 0;
  assign txmargin3 = 0;
  assign txmargin4 = 0;
  assign txmargin5 = 0;
  assign txmargin6 = 0;
  assign txmargin7 = 0;
  assign txdeemph0 = 0;
  assign txdeemph1 = 0;
  assign txdeemph2 = 0;
  assign txdeemph3 = 0;
  assign txdeemph4 = 0;
  assign txdeemph5 = 0;
  assign txdeemph6 = 0;
  assign txdeemph7 = 0;
  assign txswing0 = 0;
  assign txswing1 = 0;
  assign txswing2 = 0;
  assign txswing3 = 0;
  assign txswing4 = 0;
  assign txswing5 = 0;
  assign txswing6 = 0;
  assign txswing7 = 0;
  assign txblkst0 = 0;
  assign txblkst1 = 0;
  assign txblkst2 = 0;
  assign txblkst3 = 0;
  assign txblkst4 = 0;
  assign txblkst5 = 0;
  assign txblkst6 = 0;
  assign txblkst7 = 0;
  assign txsynchd0 = 0;
  assign txsynchd1 = 0;
  assign txsynchd2 = 0;
  assign txsynchd3 = 0;
  assign txsynchd4 = 0;
  assign txsynchd5 = 0;
  assign txsynchd6 = 0;
  assign txsynchd7 = 0;
  assign currentcoeff0 = 0;
  assign currentcoeff1 = 0;
  assign currentcoeff2 = 0;
  assign currentcoeff3 = 0;
  assign currentcoeff4 = 0;
  assign currentcoeff5 = 0;
  assign currentcoeff6 = 0;
  assign currentcoeff7 = 0;
  assign currentrxpreset0 = 0;
  assign currentrxpreset1 = 0;
  assign currentrxpreset2 = 0;
  assign currentrxpreset3 = 0;
  assign currentrxpreset4 = 0;
  assign currentrxpreset5 = 0;
  assign currentrxpreset6 = 0;
  assign currentrxpreset7 = 0;
  assign coreclkout_hip = 0;
  assign currentspeed = 0;
  assign derr_cor_ext_rcv = 0;
  assign derr_cor_ext_rpl = 0;
  assign derr_rpl = 0;
  assign rx_par_err = 0;
  assign tx_par_err = 0;
  assign cfg_par_err = 0;
  assign dlup = 0;
  assign dlup_exit = 0;
  assign ev128ns = 0;
  assign ev1us = 0;
  assign hotrst_exit = 0;
  assign int_status = 0;
  assign l2_exit = 0;
  assign lane_act = 0;
  assign ltssmstate = 0;
  assign ko_cpl_spc_header = 0;
  assign ko_cpl_spc_data = 0;
  assign rxfc_cplbuf_ovf = 0;
  assign serr_out = 0;
  assign app_int_ack = 0;
  assign app_msi_ack = 0;
  assign lmi_ack = 0;
  assign lmi_dout = 0;
  assign pme_to_sr = 0;
  assign rx_st_bar = 0;
  assign    rx_st_be = 0;
  assign    rx_st_parity = 0;
  assign  rx_st_data = 0;
  assign rx_st_sop = 0;
  assign rx_st_valid = 0;
  assign rx_st_empty = 0;
  assign rx_st_eop = 0;
  assign rx_st_err = 0;
  assign tl_cfg_add = 0;
  assign tl_cfg_ctl = 0;
  assign tl_cfg_sts = 0;
  assign tx_cred_datafccp = 0;
  assign tx_cred_datafcnp = 0;
  assign tx_cred_datafcp = 0;
  assign tx_cred_fchipcons = 0;
  assign tx_cred_fcinfinite = 0;
  assign tx_cred_hdrfccp = 0;
  assign tx_cred_hdrfcnp = 0;
  assign tx_cred_hdrfcp = 0;
  assign tx_st_ready = 0;
  assign hip_reconfig_readdata = 0;         //  Read data output
  assign tx_out0 = 0;
  assign tx_out1 = 0;
  assign tx_out2 = 0;
  assign tx_out3 = 0;
  assign tx_out4 = 0;
  assign tx_out5 = 0;
  assign tx_out6 = 0;
  assign tx_out7 = 0;
  assign cfgbp_lane_err = 0;
  assign cfgbp_link_equlz_req = 0;
  assign cfgbp_equiz_complete = 0;
  assign cfgbp_phase_3_successful = 0;
  assign cfgbp_phase_2_successful = 0;
  assign cfgbp_phase_1_successful = 0;
  assign cfgbp_current_deemph = 0;
  assign cfgbp_current_speed = 0;
  assign cfgbp_link_up = 0;
  assign cfgbp_link_train = 0;
  assign cfgbp_10state = 0;
  assign cfgbp_10sstate = 0;
  assign cfgbp_rx_val_pm = 0;
  assign cfgbp_rx_typ_pm = 0;
  assign cfgbp_tx_ack_pm = 0;
  assign cfgbp_ack_phypm = 0;
  assign cfgbp_vc_status = 0;
  assign cfgbp_rxfc_max = 0;
  assign cfgbp_txfc_max = 0;
  assign cfgbp_txbuf_emp = 0;
  assign cfgbp_cfgbuf_emp = 0;
  assign cfgbp_rpbuf_emp = 0;
  assign cfgbp_dll_req = 0;
  assign cfgbp_link_auto_bdw_status = 0;
  assign cfgbp_link_bdw_mng_status = 0;
  assign cfgbp_rst_tx_margin_field = 0;
  assign cfgbp_rst_enter_comp_bit = 0;
  assign cfgbp_rx_st_ecrcerr = 0;
  assign cfgbp_err_uncorr_internal = 0;
  assign cfgbp_rx_corr_internal = 0;
  assign cfgbp_err_tlrcvovf = 0;
  assign cfgbp_txfc_err = 0;
  assign cfgbp_err_tlmalf = 0;
  assign cfgbp_err_surpdwn_dll = 0;
  assign cfgbp_err_dllrev = 0;
  assign cfgbp_err_dll_repnum = 0;
  assign cfgbp_err_dllreptim = 0;
  assign cfgbp_err_dllp_baddllp = 0;
  assign cfgbp_err_dll_badtlp = 0;
  assign cfgbp_err_phy_tng = 0;
  assign cfgbp_err_phy_rcv = 0;
  assign cfgbp_root_err_reg_sts = 0;
  assign cfgbp_corr_err_reg_sts = 0;
  assign cfgbp_unc_err_reg_sts = 0;
  assign cseb_addr = 0;
  assign cseb_addr_parity = 0;
  assign cseb_be = 0;
  assign cseb_is_shadow = 0;
  assign cseb_rden = 0;
  assign cseb_wrdata = 0;
  assign cseb_wrdata_parity = 0;
  assign cseb_wren = 0;
  assign cseb_wrresp_req = 0;

endmodule
