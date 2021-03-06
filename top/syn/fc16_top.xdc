source ../../../xilinx_ip/pcie4_uscale_plus_1_ex/imports/xilinx_pcie4_uscale_plus_x0y2.xdc
#**************************************************************
# Time Information
#**************************************************************

#set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

#derive_pll_clocks -create_base_clocks
create_clock -name {iPCIE_REF_CLK} -period 10.000 -waveform { 0.000 5.000 } [get_ports {iPCIE_REF_CLK}]
create_clock -name {iCLK_FR} -period 10.000 -waveform { 0.000 5.000 } [get_ports {iCLK_FR}]
create_clock -name {iBUS_CLK} -period 1000.000 -waveform { 0.000 500.000 } [get_ports {iBUS_CLK}]
#iCLK_425M is actually 219MHz
create_clock -name {iCLK_425M_0} -period 4.566 -waveform { 0.000 2.283 } [get_ports {iCLK_425M_P[0]}]
#create_clock -name {iCLK_425M_1} -period 4.566 -waveform { 0.000 2.283 } [get_ports {iCLK_425M_P[1]}]
create_clock -name {iCLK_FC_425_0} -period 2.352 -waveform { 0.000 1.176 } [get_ports {iCLK_FC_425_P[0]}]
create_clock -name {iCLK_FC_425_1} -period 2.352 -waveform { 0.000 1.176 } [get_ports {iCLK_FC_425_P[1]}]



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

#derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

#**************************************************************
# Set False Path
#**************************************************************

set_false_path  -from  [get_clocks {iBUS_CLK}]  -to  [get_clocks {iCLK_FR}]
set_false_path  -from  [get_clocks {iPCIE_REF_CLK}]  -to  [get_clocks {iCLK_FR}]


set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { iBUS_CLK }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[0] }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[0]_1 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[0]_2 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[0]_3 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[0]_4 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[0]_5 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[1] }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[1]_1 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[1]_2 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[1]_3 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[1]_4 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[1]_5 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[2] }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[2]_1 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[2]_2 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[2]_3 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[2]_4 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[2]_5 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[3] }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[3]_1 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[3]_2 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[3]_3 }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[3]_4 }
#set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { rxoutclk_out[3]_5 }
set_false_path -to [get_clocks clk_out1_s5_altpll_219in_212out_0002] -from [get_clocks rxoutclk_out[3]_5]

set_clock_groups -asynchronous -group { rxoutclk_out[0]_4 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[1]_4 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[2]_4 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[3]_4 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[0]_4 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[1]_4 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[2]_4 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[3]_4 }
set_clock_groups -asynchronous -group { rxoutclk_out[0]_5 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[1]_5 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[2]_5 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[3]_5 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[0]_5 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[1]_5 }


set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[2]_5 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[3]_5 }
set_clock_groups -asynchronous -group { rxoutclk_out[0]_6 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[1]_6 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[0]_6 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[1]_6 }
set_clock_groups -asynchronous -group { rxoutclk_out[0] }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[1] }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[2] }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[3] }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { clk_out1_s5_altpll_219in_212out_0002 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[0]_1 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[1]_1 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[2]_1 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[3]_1 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[0]_2 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[1]_2 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[2]_2 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[3]_2 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[0]_3 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[1]_3 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[2]_3 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { rxoutclk_out[3]_3 }  -group { txoutclk_out[0] }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[1] }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[2] }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[3] }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[0]_1 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[1]_1 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[2]_1 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[3]_1 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[0]_2 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[1]_2 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[2]_2 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[3]_2 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[0]_3 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[1]_3 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[2]_3 }
set_clock_groups -asynchronous -group { txoutclk_out[0] }  -group { txoutclk_out[3]_3 }

set_false_path -from [get_pins -hier -filter { NAME =~  "*fmac_efifo_inst*" && NAME =~  "*CLKARDCLK*" }] -to [get_pins -hier -filter {NAME =~ "*fmac_efifo_inst*" && NAME =~  "*ENARDEN*" }]


set_false_path -to [get_pins {pcie_le_inst/le_generate[*].u_link_engine/channel_engine_*/fmac/fmac_efifo_inst/linkdown_level_sync/in_level_sync_r_reg[*]/CLR}]
set_false_path -to [get_pins {pcie_le_inst/le_generate[*].u_link_engine/channel_engine_*/sfp_los_r_reg/CLR}]
set_false_path -to [get_pins {pcie_le_inst/le_generate[*].u_link_engine/channel_engine_*/sfp_los_reg/CLR}]

set_false_path -to [get_pins -of [filter [get_cells -hier] {FILE_NAME =~*vi_async_rst.v}] -filter {REF_PIN_NAME==CLR}]

set_false_path -to [get_pins -of [get_cells -hier -filter name=~*rst_gen*] -filter {REF_PIN_NAME==CLR}]

set_false_path -to [get_pins -of [get_cells -hier -filter name=~fc16clkrst*clk_cnt_gen*] -filter {REF_PIN_NAME==CLR}]

set_false_path -to [get_pins -of [filter [get_cells -hier] {FILE_NAME=~*clk_cnt_sampler.v}] -filter {REF_PIN_NAME==CLR}]

#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path 2 -to [get_pins {fc1_kr_ser_wrap_inst/fc1_kr_wrap_inst/gen_fc1_kr[*].fc1_kr/decoder_inst/err_detect_inst/*/D}]
set_multicycle_path 1 -to [get_pins {fc1_kr_ser_wrap_inst/fc1_kr_wrap_inst/gen_fc1_kr[*].fc1_kr/decoder_inst/err_detect_inst/*/D}] -hold



#**************************************************************
# Set Maximum Delay
#**************************************************************

#set_max_delay -to [get_registers {*vi_sync_1c*out_q[*]*}] 12.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

#set_min_delay -to [get_registers {*vi_sync_1c*out_q[*]*}] -10.000


#**************************************************************
# Set Input Transition
#**************************************************************

#**************************************************************
# New false path between clocks
#**************************************************************
#set_false_path  -to {fc16_pcie_le:pcie_le_inst|pcie_gen3x8_13_1:u_bali_pcie_gen3x8_wrap|bali_pcie_app:bali_pcie_app_inst|vi_sync_level:vi_sync_level_inst|in_level_sync_r[*]}

#set_false_path  -to {fc16_pcie_le:pcie_le_inst|pcie_gen3x8_13_1:u_bali_pcie_gen3x8_wrap|bali_pcie_app:bali_pcie_app_inst|vi_sync_pulse:vi_sync_pulse_*|in_toggle_r*}


#set_false_path -to {xbar_wrap:xbar_wrap_inst|vi_sync_pulse:gen_efifo[*].vi_sync_pulse_insert|in_toggle_r}

####



set_property IOSTANDARD LVCMOS18 [get_ports { iASY[0] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iASY[1] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iASY[2] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iASY[3] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iBD_NO[0] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iBD_NO[1] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iBUS_CLK }]
set_property IOSTANDARD LVCMOS18 [get_ports { iBUS_EN }]
set_property IOSTANDARD LVCMOS18 [get_ports { iBUS_MASTER }]
set_property IOSTANDARD LVCMOS18 [get_ports { iBUS_RST }]
set_property IOSTANDARD LVCMOS18 [get_ports { iCLK_FR }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[0] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[1] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[10] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[11] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[12] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[13] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[14] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[15] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[16] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[17] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[18] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[19] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[2] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[20] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[21] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[22] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[23] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[24] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[25] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[3] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[4] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[5] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[6] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[7] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[8] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iFC_RD_P[9] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iFPGA_CLRN }]
set_property IOSTANDARD LVCMOS18 [get_ports { iFPGA_ID_N }]
set_property IOSTANDARD LVCMOS18 [get_ports { iFPGA_RSTN }]
set_property IOSTANDARD LVCMOS18 [get_ports { iHIP_SERIAL_RX_IN0 }]
set_property IOSTANDARD LVCMOS18 [get_ports { iHIP_SERIAL_RX_IN1 }]
set_property IOSTANDARD LVCMOS18 [get_ports { iHIP_SERIAL_RX_IN2 }]
set_property IOSTANDARD LVCMOS18 [get_ports { iHIP_SERIAL_RX_IN3 }]
set_property IOSTANDARD LVCMOS18 [get_ports { iHIP_SERIAL_RX_IN4 }]
set_property IOSTANDARD LVCMOS18 [get_ports { iHIP_SERIAL_RX_IN5 }]
set_property IOSTANDARD LVCMOS18 [get_ports { iHIP_SERIAL_RX_IN6 }]
set_property IOSTANDARD LVCMOS18 [get_ports { iHIP_SERIAL_RX_IN7 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioBUS_SPARE }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioEXT2 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioEXT3 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioEXT4 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioFPGA_DATA[0] }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioFPGA_DATA[1] }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioFPGA_DATA[2] }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioFPGA_DATA[3] }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioFPGA_DATA[4] }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioFPGA_DATA[5] }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioFPGA_DATA[6] }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioFPGA_DATA[7] }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_1 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_2 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_3 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_4 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_5 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_6 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_7 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_8 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_ROT_1 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_ROT_2 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_ROT_3 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioOPT_ROT_4 }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioSYNC_NEIGHBOR }]
set_property IOSTANDARD LVCMOS18 [get_ports { ioSYNC_RIBBON }]
set_property IOSTANDARD LVCMOS18 [get_ports { iPIN_PERST_n }]
set_property IOSTANDARD LVCMOS18 [get_ports { iRXD }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[0] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[1] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[10] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[11] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[12] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[13] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[14] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[15] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[16] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[17] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[18] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[19] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[2] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[20] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[21] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[22] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[23] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[3] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[4] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[5] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[6] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[7] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[8] }]
set_property IOSTANDARD LVCMOS18 [get_ports { iSFP_LOS[9] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[0] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[1] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[10] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[11] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[2] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[3] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[4] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[5] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[6] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[7] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[8] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oFC_RATE_SEL[9] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[0] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[1] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[10] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[11] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[12] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[13] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[14] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[15] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[16] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[17] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[18] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[19] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[2] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[20] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[21] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[22] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[23] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[24] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[25] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[3] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[4] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[5] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[6] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[7] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[8] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oFC_TD_P[9] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oHIP_SERIAL_TX_OUT0 }]
set_property IOSTANDARD LVCMOS18 [get_ports { oHIP_SERIAL_TX_OUT1 }]
set_property IOSTANDARD LVCMOS18 [get_ports { oHIP_SERIAL_TX_OUT2 }]
set_property IOSTANDARD LVCMOS18 [get_ports { oHIP_SERIAL_TX_OUT3 }]
set_property IOSTANDARD LVCMOS18 [get_ports { oHIP_SERIAL_TX_OUT4 }]
set_property IOSTANDARD LVCMOS18 [get_ports { oHIP_SERIAL_TX_OUT5 }]
set_property IOSTANDARD LVCMOS18 [get_ports { oHIP_SERIAL_TX_OUT6 }]
set_property IOSTANDARD LVCMOS18 [get_ports { oHIP_SERIAL_TX_OUT7 }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[0] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[1] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[10] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[11] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[12] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[13] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[14] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[15] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[2] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[3] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[4] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[5] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[6] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[7] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[8] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oLED_N[9] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[0] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[1] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[10] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[11] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[12] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[13] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[14] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[15] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[16] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[17] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[18] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[19] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[2] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[20] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[21] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[22] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[23] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[24] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[25] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[25] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[26] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[27] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[28] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[29] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[3] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[30] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[31] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[32] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[4] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[5] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[6] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[7] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[8] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_A[9] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[0] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[1] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[10] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[11] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[12] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[13] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[14] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[15] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[16] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[17] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[18] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[19] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[2] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[20] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[21] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[22] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[23] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[24] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[25] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[25] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[26] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[27] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[28] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[29] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[3] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[30] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[31] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[32] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[4] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[5] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[6] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[7] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[8] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { oMICTOR_B[9] }]
set_property IOSTANDARD LVCMOS18 [get_ports { oTXD }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iCLK_425M_P[0] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iCLK_425M_P[1] }]
#set_property IOSTANDARD SUB_LVDS [get_ports { iCLK_FC_219_P[0] }]
#set_property IOSTANDARD SUB_LVDS [get_ports { iCLK_FC_219_P[1] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iCLK_FC_425_P[0] }]
#set_property IOSTANDARD LVCMOS18 [get_ports { iCLK_FC_425_P[1] }]
set_property IOSTANDARD SUB_LVDS [get_ports { iPCIE_REF_CLK }]


set_property direction IN [get_ports { iBUS_CLK }];
set_property direction IN [get_ports { iBUS_EN }];
set_property direction IN [get_ports { iBUS_MASTER }];
set_property direction IN [get_ports { iBUS_RST }];
set_property direction IN [get_ports { iCLK_425M_P[0] }];
set_property direction IN [get_ports { iCLK_FC_425_N[0] }];
set_property direction IN [get_ports { iCLK_FC_425_N[1] }];
set_property direction IN [get_ports { iCLK_FC_425_P[0] }];
set_property direction IN [get_ports { iCLK_FC_425_P[1] }];
set_property direction IN [get_ports { iCLK_FR }];
set_property direction IN [get_ports { iFC_RD_N[0] }];
set_property direction IN [get_ports { iFC_RD_N[1] }];
set_property direction IN [get_ports { iFC_RD_N[10] }];
set_property direction IN [get_ports { iFC_RD_N[11] }];
set_property direction IN [get_ports { iFC_RD_N[12] }];
set_property direction IN [get_ports { iFC_RD_N[13] }];
set_property direction IN [get_ports { iFC_RD_N[14] }];
set_property direction IN [get_ports { iFC_RD_N[15] }];
set_property direction IN [get_ports { iFC_RD_N[16] }];
set_property direction IN [get_ports { iFC_RD_N[17] }];
set_property direction IN [get_ports { iFC_RD_N[18] }];
set_property direction IN [get_ports { iFC_RD_N[19] }];
set_property direction IN [get_ports { iFC_RD_N[2] }];
set_property direction IN [get_ports { iFC_RD_N[20] }];
set_property direction IN [get_ports { iFC_RD_N[21] }];
set_property direction IN [get_ports { iFC_RD_N[22] }];
set_property direction IN [get_ports { iFC_RD_N[23] }];
set_property direction IN [get_ports { iFC_RD_N[3] }];
set_property direction IN [get_ports { iFC_RD_N[4] }];
set_property direction IN [get_ports { iFC_RD_N[5] }];
set_property direction IN [get_ports { iFC_RD_N[6] }];
set_property direction IN [get_ports { iFC_RD_N[7] }];
set_property direction IN [get_ports { iFC_RD_N[8] }];
set_property direction IN [get_ports { iFC_RD_N[9] }];
set_property direction IN [get_ports { iFC_RD_P[0] }];
set_property direction IN [get_ports { iFC_RD_P[1] }];
set_property direction IN [get_ports { iFC_RD_P[10] }];
set_property direction IN [get_ports { iFC_RD_P[11] }];
set_property direction IN [get_ports { iFC_RD_P[12] }];
set_property direction IN [get_ports { iFC_RD_P[13] }];
set_property direction IN [get_ports { iFC_RD_P[14] }];
set_property direction IN [get_ports { iFC_RD_P[15] }];
set_property direction IN [get_ports { iFC_RD_P[16] }];
set_property direction IN [get_ports { iFC_RD_P[17] }];
set_property direction IN [get_ports { iFC_RD_P[18] }];
set_property direction IN [get_ports { iFC_RD_P[19] }];
set_property direction IN [get_ports { iFC_RD_P[2] }];
set_property direction IN [get_ports { iFC_RD_P[20] }];
set_property direction IN [get_ports { iFC_RD_P[21] }];
set_property direction IN [get_ports { iFC_RD_P[22] }];
set_property direction IN [get_ports { iFC_RD_P[23] }];
set_property direction IN [get_ports { iFC_RD_P[3] }];
set_property direction IN [get_ports { iFC_RD_P[4] }];
set_property direction IN [get_ports { iFC_RD_P[5] }];
set_property direction IN [get_ports { iFC_RD_P[6] }];
set_property direction IN [get_ports { iFC_RD_P[7] }];
set_property direction IN [get_ports { iFC_RD_P[8] }];
set_property direction IN [get_ports { iFC_RD_P[9] }];
set_property direction IN [get_ports { iFPGA_RSTN }];
set_property direction IN [get_ports { iSFP_LOS[0] }];
set_property direction IN [get_ports { iSFP_LOS[1] }];
set_property direction IN [get_ports { iSFP_LOS[10] }];
set_property direction IN [get_ports { iSFP_LOS[11] }];
set_property direction IN [get_ports { iSFP_LOS[12] }];
set_property direction IN [get_ports { iSFP_LOS[13] }];
set_property direction IN [get_ports { iSFP_LOS[14] }];
set_property direction IN [get_ports { iSFP_LOS[15] }];
set_property direction IN [get_ports { iSFP_LOS[16] }];
set_property direction IN [get_ports { iSFP_LOS[17] }];
set_property direction IN [get_ports { iSFP_LOS[18] }];
set_property direction IN [get_ports { iSFP_LOS[19] }];
set_property direction IN [get_ports { iSFP_LOS[2] }];
set_property direction IN [get_ports { iSFP_LOS[20] }];
set_property direction IN [get_ports { iSFP_LOS[21] }];
set_property direction IN [get_ports { iSFP_LOS[22] }];
set_property direction IN [get_ports { iSFP_LOS[23] }];
set_property direction IN [get_ports { iSFP_LOS[3] }];
set_property direction IN [get_ports { iSFP_LOS[4] }];
set_property direction IN [get_ports { iSFP_LOS[5] }];
set_property direction IN [get_ports { iSFP_LOS[6] }];
set_property direction IN [get_ports { iSFP_LOS[7] }];
set_property direction IN [get_ports { iSFP_LOS[8] }];
set_property direction IN [get_ports { iSFP_LOS[9] }];
set_property direction IN [get_ports { pci_exp_rxn[0] }];
set_property direction IN [get_ports { pci_exp_rxn[1] }];
set_property direction IN [get_ports { pci_exp_rxn[2] }];
set_property direction IN [get_ports { pci_exp_rxn[3] }];
set_property direction IN [get_ports { pci_exp_rxn[4] }];
set_property direction IN [get_ports { pci_exp_rxn[5] }];
set_property direction IN [get_ports { pci_exp_rxn[6] }];
set_property direction IN [get_ports { pci_exp_rxn[7] }];
set_property direction IN [get_ports { pci_exp_rxp[0] }];
set_property direction IN [get_ports { pci_exp_rxp[1] }];
set_property direction IN [get_ports { pci_exp_rxp[2] }];
set_property direction IN [get_ports { pci_exp_rxp[3] }];
set_property direction IN [get_ports { pci_exp_rxp[4] }];
set_property direction IN [get_ports { pci_exp_rxp[5] }];
set_property direction IN [get_ports { pci_exp_rxp[6] }];
set_property direction IN [get_ports { pci_exp_rxp[7] }];
set_property direction IN [get_ports { sys_clk_n }];
set_property direction IN [get_ports { sys_clk_p }];
set_property direction IN [get_ports { sys_rst_n }];
set_property direction INOUT [get_ports { ioFPGA_DATA[0] }];
set_property direction INOUT [get_ports { ioFPGA_DATA[1] }];
set_property direction INOUT [get_ports { ioFPGA_DATA[2] }];
set_property direction INOUT [get_ports { ioFPGA_DATA[3] }];
set_property direction INOUT [get_ports { ioFPGA_DATA[4] }];
set_property direction INOUT [get_ports { ioFPGA_DATA[5] }];
set_property direction INOUT [get_ports { ioFPGA_DATA[6] }];
set_property direction INOUT [get_ports { ioFPGA_DATA[7] }];
set_property direction INOUT [get_ports { ioSYNC_NEIGHBOR }];
set_property direction INOUT [get_ports { ioSYNC_RIBBON }];
set_property direction OUT [get_ports { oFC_RATE_SEL[0] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[1] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[10] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[11] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[2] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[3] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[4] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[5] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[6] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[7] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[8] }];
set_property direction OUT [get_ports { oFC_RATE_SEL[9] }];
set_property direction OUT [get_ports { oFC_TD_N[0] }];
set_property direction OUT [get_ports { oFC_TD_N[1] }];
set_property direction OUT [get_ports { oFC_TD_N[10] }];
set_property direction OUT [get_ports { oFC_TD_N[11] }];
set_property direction OUT [get_ports { oFC_TD_N[12] }];
set_property direction OUT [get_ports { oFC_TD_N[13] }];
set_property direction OUT [get_ports { oFC_TD_N[14] }];
set_property direction OUT [get_ports { oFC_TD_N[15] }];
set_property direction OUT [get_ports { oFC_TD_N[16] }];
set_property direction OUT [get_ports { oFC_TD_N[17] }];
set_property direction OUT [get_ports { oFC_TD_N[18] }];
set_property direction OUT [get_ports { oFC_TD_N[19] }];
set_property direction OUT [get_ports { oFC_TD_N[2] }];
set_property direction OUT [get_ports { oFC_TD_N[20] }];
set_property direction OUT [get_ports { oFC_TD_N[21] }];
set_property direction OUT [get_ports { oFC_TD_N[22] }];
set_property direction OUT [get_ports { oFC_TD_N[23] }];
set_property direction OUT [get_ports { oFC_TD_N[24] }];
set_property direction OUT [get_ports { oFC_TD_N[25] }];
set_property direction OUT [get_ports { oFC_TD_N[3] }];
set_property direction OUT [get_ports { oFC_TD_N[4] }];
set_property direction OUT [get_ports { oFC_TD_N[5] }];
set_property direction OUT [get_ports { oFC_TD_N[6] }];
set_property direction OUT [get_ports { oFC_TD_N[7] }];
set_property direction OUT [get_ports { oFC_TD_N[8] }];
set_property direction OUT [get_ports { oFC_TD_N[9] }];
set_property direction OUT [get_ports { oFC_TD_P[0] }];
set_property direction OUT [get_ports { oFC_TD_P[1] }];
set_property direction OUT [get_ports { oFC_TD_P[10] }];
set_property direction OUT [get_ports { oFC_TD_P[11] }];
set_property direction OUT [get_ports { oFC_TD_P[12] }];
set_property direction OUT [get_ports { oFC_TD_P[13] }];
set_property direction OUT [get_ports { oFC_TD_P[14] }];
set_property direction OUT [get_ports { oFC_TD_P[15] }];
set_property direction OUT [get_ports { oFC_TD_P[16] }];
set_property direction OUT [get_ports { oFC_TD_P[17] }];
set_property direction OUT [get_ports { oFC_TD_P[18] }];
set_property direction OUT [get_ports { oFC_TD_P[19] }];
set_property direction OUT [get_ports { oFC_TD_P[2] }];
set_property direction OUT [get_ports { oFC_TD_P[20] }];
set_property direction OUT [get_ports { oFC_TD_P[21] }];
set_property direction OUT [get_ports { oFC_TD_P[22] }];
set_property direction OUT [get_ports { oFC_TD_P[23] }];
set_property direction OUT [get_ports { oFC_TD_P[24] }];
set_property direction OUT [get_ports { oFC_TD_P[25] }];
set_property direction OUT [get_ports { oFC_TD_P[3] }];
set_property direction OUT [get_ports { oFC_TD_P[4] }];
set_property direction OUT [get_ports { oFC_TD_P[5] }];
set_property direction OUT [get_ports { oFC_TD_P[6] }];
set_property direction OUT [get_ports { oFC_TD_P[7] }];
set_property direction OUT [get_ports { oFC_TD_P[8] }];
set_property direction OUT [get_ports { oFC_TD_P[9] }];
set_property direction OUT [get_ports { oHIP_SERIAL_TX_OUT0 }];
set_property direction OUT [get_ports { oHIP_SERIAL_TX_OUT1 }];
set_property direction OUT [get_ports { oHIP_SERIAL_TX_OUT2 }];
set_property direction OUT [get_ports { oHIP_SERIAL_TX_OUT3 }];
set_property direction OUT [get_ports { oHIP_SERIAL_TX_OUT4 }];
set_property direction OUT [get_ports { oHIP_SERIAL_TX_OUT5 }];
set_property direction OUT [get_ports { oHIP_SERIAL_TX_OUT6 }];
set_property direction OUT [get_ports { oHIP_SERIAL_TX_OUT7 }];
set_property direction OUT [get_ports { oLED_N[0] }];
set_property direction OUT [get_ports { oLED_N[1] }];
set_property direction OUT [get_ports { oLED_N[10] }];
set_property direction OUT [get_ports { oLED_N[11] }];
set_property direction OUT [get_ports { oLED_N[12] }];
set_property direction OUT [get_ports { oLED_N[13] }];
set_property direction OUT [get_ports { oLED_N[14] }];
set_property direction OUT [get_ports { oLED_N[15] }];
set_property direction OUT [get_ports { oLED_N[2] }];
set_property direction OUT [get_ports { oLED_N[3] }];
set_property direction OUT [get_ports { oLED_N[4] }];
set_property direction OUT [get_ports { oLED_N[5] }];
set_property direction OUT [get_ports { oLED_N[6] }];
set_property direction OUT [get_ports { oLED_N[7] }];
set_property direction OUT [get_ports { oLED_N[8] }];
set_property direction OUT [get_ports { oLED_N[9] }];
set_property direction OUT [get_ports { oTXD }];
set_property direction OUT [get_ports { pci_exp_txn[0] }];
set_property direction OUT [get_ports { pci_exp_txn[1] }];
set_property direction OUT [get_ports { pci_exp_txn[2] }];
set_property direction OUT [get_ports { pci_exp_txn[3] }];
set_property direction OUT [get_ports { pci_exp_txn[4] }];
set_property direction OUT [get_ports { pci_exp_txn[5] }];
set_property direction OUT [get_ports { pci_exp_txn[6] }];
set_property direction OUT [get_ports { pci_exp_txn[7] }];
set_property direction OUT [get_ports { pci_exp_txp[0] }];
set_property direction OUT [get_ports { pci_exp_txp[1] }];
set_property direction OUT [get_ports { pci_exp_txp[2] }];
set_property direction OUT [get_ports { pci_exp_txp[3] }];
set_property direction OUT [get_ports { pci_exp_txp[4] }];
set_property direction OUT [get_ports { pci_exp_txp[5] }];
set_property direction OUT [get_ports { pci_exp_txp[6] }];
set_property direction OUT [get_ports { pci_exp_txp[7] }];

set_property PACKAGE_PIN B11 [get_ports { iBUS_CLK }]; # IO_L12P_AD8P_91 High Density 91 INPUT LVCMOS18
set_property PACKAGE_PIN A11 [get_ports { iBUS_EN }]; # IO_L12N_AD8N_91 High Density 91 INPUT LVCMOS18
set_property PACKAGE_PIN B10 [get_ports { iBUS_MASTER }]; # IO_L11P_AD9P_91 High Density 91 INPUT LVCMOS18
set_property PACKAGE_PIN A9 [get_ports { iBUS_RST }]; # IO_L11N_AD9N_91 High Density 91 INPUT LVCMOS18
set_property PACKAGE_PIN E23 [get_ports { iCLK_425M_P[0] }]; # IO_L14P_T2L_N2_GC_70 High Performance 70 INPUT LVCMOS18*

#| AC29       |                     |                  | MGTREFCLK1P_127         
#| AC30       |                     |                  | MGTREFCLK1N_127         
#| AA29       |                     |                  | MGTREFCLK1P_128         
#| AA30       |                     |                  | MGTREFCLK1N_128         
#| W29        |                     |                  | MGTREFCLK1P_129         
#| W30        |                     |                  | MGTREFCLK1N_129         
#
#| U29        |                     |                  | MGTREFCLK1P_130         
#| U30        |                     |                  | MGTREFCLK1N_130         
#| R29        |                     |                  | MGTREFCLK1P_131         
#| R30        |                     |                  | MGTREFCLK1N_131         
#| N29        |                     |                  | MGTREFCLK1P_132         
#| N30        |                     |                  | MGTREFCLK1N_132         

#| AE29       |                     |                  | MGTREFCLK0P_127         
#| AE30       |                     |                  | MGTREFCLK0N_127         
#| AB27       |                     |                  | MGTREFCLK0P_128         
#| AB28       |                     |                  | MGTREFCLK0N_128         
#| Y27        | iCLK_FC_425_P[1]    |                  | MGTREFCLK0P_129         
#| Y28        | iCLK_FC_425_N[1]    |                  | MGTREFCLK0N_129         
#
#| V27        |                     |                  | MGTREFCLK0P_130         
#| V28        |                     |                  | MGTREFCLK0N_130         
#| T27        |                     |                  | MGTREFCLK0P_131         
#| T28        |                     |                  | MGTREFCLK0N_131         
#| P27        | iCLK_FC_425_P[0]    |                  | MGTREFCLK0P_132         
#| P28        | iCLK_FC_425_N[0]    |                  | MGTREFCLK0N_132         
set_property PACKAGE_PIN AB27 [get_ports { iCLK_FC_425_P[0] }]; # MGTREFCLK0P_129   INPUT 
set_property PACKAGE_PIN AB28 [get_ports { iCLK_FC_425_N[0] }]; # MGTREFCLK0N_129   INPUT 
set_property PACKAGE_PIN T27 [get_ports { iCLK_FC_425_P[1] }]; # MGTREFCLK0P_132   INPUT 
set_property PACKAGE_PIN T28 [get_ports { iCLK_FC_425_N[1] }]; # MGTREFCLK0N_132   INPUT 
set_property PACKAGE_PIN C5 [get_ports { iCLK_FR }]; # IO_L8P_HDGC_AD4P_90 High Density 90 INPUT LVCMOS18
set_property PACKAGE_PIN AH37 [get_ports { iFC_RD_N[0] }]; # MGTYRXN0_127   INPUT 
set_property PACKAGE_PIN AG39 [get_ports { iFC_RD_N[1] }]; # MGTYRXN1_127   INPUT 
set_property PACKAGE_PIN V37 [get_ports { iFC_RD_N[10] }]; # MGTYRXN2_129   INPUT 
set_property PACKAGE_PIN U39 [get_ports { iFC_RD_N[11] }]; # MGTYRXN3_129   INPUT 
set_property PACKAGE_PIN T37 [get_ports { iFC_RD_N[12] }]; # MGTYRXN0_130   INPUT 
set_property PACKAGE_PIN R39 [get_ports { iFC_RD_N[13] }]; # MGTYRXN1_130   INPUT 
set_property PACKAGE_PIN P37 [get_ports { iFC_RD_N[14] }]; # MGTYRXN2_130   INPUT 
set_property PACKAGE_PIN N39 [get_ports { iFC_RD_N[15] }]; # MGTYRXN3_130   INPUT 
set_property PACKAGE_PIN M37 [get_ports { iFC_RD_N[16] }]; # MGTYRXN0_131   INPUT 
set_property PACKAGE_PIN L39 [get_ports { iFC_RD_N[17] }]; # MGTYRXN1_131   INPUT 
set_property PACKAGE_PIN K37 [get_ports { iFC_RD_N[18] }]; # MGTYRXN2_131   INPUT 
set_property PACKAGE_PIN J39 [get_ports { iFC_RD_N[19] }]; # MGTYRXN3_131   INPUT 
set_property PACKAGE_PIN AF37 [get_ports { iFC_RD_N[2] }]; # MGTYRXN2_127   INPUT 
set_property PACKAGE_PIN H37 [get_ports { iFC_RD_N[20] }]; # MGTYRXN0_132   INPUT 
set_property PACKAGE_PIN G39 [get_ports { iFC_RD_N[21] }]; # MGTYRXN1_132   INPUT 
set_property PACKAGE_PIN E39 [get_ports { iFC_RD_N[22] }]; # MGTYRXN2_132   INPUT 
set_property PACKAGE_PIN C39 [get_ports { iFC_RD_N[23] }]; # MGTYRXN3_132   INPUT 
set_property PACKAGE_PIN AE39 [get_ports { iFC_RD_N[3] }]; # MGTYRXN3_127   INPUT 
set_property PACKAGE_PIN AD37 [get_ports { iFC_RD_N[4] }]; # MGTYRXN0_128   INPUT 
set_property PACKAGE_PIN AC39 [get_ports { iFC_RD_N[5] }]; # MGTYRXN1_128   INPUT 
set_property PACKAGE_PIN AB37 [get_ports { iFC_RD_N[6] }]; # MGTYRXN2_128   INPUT 
set_property PACKAGE_PIN AA39 [get_ports { iFC_RD_N[7] }]; # MGTYRXN3_128   INPUT 
set_property PACKAGE_PIN Y37 [get_ports { iFC_RD_N[8] }]; # MGTYRXN0_129   INPUT 
set_property PACKAGE_PIN W39 [get_ports { iFC_RD_N[9] }]; # MGTYRXN1_129   INPUT 
set_property PACKAGE_PIN AH36 [get_ports { iFC_RD_P[0] }]; # MGTYRXP0_127   INPUT 
set_property PACKAGE_PIN AG38 [get_ports { iFC_RD_P[1] }]; # MGTYRXP1_127   INPUT 
set_property PACKAGE_PIN V36 [get_ports { iFC_RD_P[10] }]; # MGTYRXP2_129   INPUT 
set_property PACKAGE_PIN U38 [get_ports { iFC_RD_P[11] }]; # MGTYRXP3_129   INPUT 
set_property PACKAGE_PIN T36 [get_ports { iFC_RD_P[12] }]; # MGTYRXP0_130   INPUT 
set_property PACKAGE_PIN R38 [get_ports { iFC_RD_P[13] }]; # MGTYRXP1_130   INPUT 
set_property PACKAGE_PIN P36 [get_ports { iFC_RD_P[14] }]; # MGTYRXP2_130   INPUT 
set_property PACKAGE_PIN N38 [get_ports { iFC_RD_P[15] }]; # MGTYRXP3_130   INPUT 
set_property PACKAGE_PIN M36 [get_ports { iFC_RD_P[16] }]; # MGTYRXP0_131   INPUT 
set_property PACKAGE_PIN L38 [get_ports { iFC_RD_P[17] }]; # MGTYRXP1_131   INPUT 
set_property PACKAGE_PIN K36 [get_ports { iFC_RD_P[18] }]; # MGTYRXP2_131   INPUT 
set_property PACKAGE_PIN J38 [get_ports { iFC_RD_P[19] }]; # MGTYRXP3_131   INPUT 
set_property PACKAGE_PIN AF36 [get_ports { iFC_RD_P[2] }]; # MGTYRXP2_127   INPUT 
set_property PACKAGE_PIN H36 [get_ports { iFC_RD_P[20] }]; # MGTYRXP0_132   INPUT 
set_property PACKAGE_PIN G38 [get_ports { iFC_RD_P[21] }]; # MGTYRXP1_132   INPUT 
set_property PACKAGE_PIN E38 [get_ports { iFC_RD_P[22] }]; # MGTYRXP2_132   INPUT 
set_property PACKAGE_PIN C38 [get_ports { iFC_RD_P[23] }]; # MGTYRXP3_132   INPUT 
set_property PACKAGE_PIN AE38 [get_ports { iFC_RD_P[3] }]; # MGTYRXP3_127   INPUT 
set_property PACKAGE_PIN AD36 [get_ports { iFC_RD_P[4] }]; # MGTYRXP0_128   INPUT 
set_property PACKAGE_PIN AC38 [get_ports { iFC_RD_P[5] }]; # MGTYRXP1_128   INPUT 
set_property PACKAGE_PIN AB36 [get_ports { iFC_RD_P[6] }]; # MGTYRXP2_128   INPUT 
set_property PACKAGE_PIN AA38 [get_ports { iFC_RD_P[7] }]; # MGTYRXP3_128   INPUT 
set_property PACKAGE_PIN Y36 [get_ports { iFC_RD_P[8] }]; # MGTYRXP0_129   INPUT 
set_property PACKAGE_PIN W38 [get_ports { iFC_RD_P[9] }]; # MGTYRXP1_129   INPUT 
set_property PACKAGE_PIN B9 [get_ports { iFPGA_RSTN }]; # IO_L10P_AD10P_91 High Density 91 INPUT LVCMOS18
set_property PACKAGE_PIN B6 [get_ports { ioFPGA_DATA[0] }]; # IO_L12P_AD0P_90 High Density 90 BIDIR LVCMOS18
set_property PACKAGE_PIN A6 [get_ports { ioFPGA_DATA[1] }]; # IO_L12N_AD0N_90 High Density 90 BIDIR LVCMOS18
set_property PACKAGE_PIN A4 [get_ports { ioFPGA_DATA[2] }]; # IO_L11P_AD1P_90 High Density 90 BIDIR LVCMOS18
set_property PACKAGE_PIN A3 [get_ports { ioFPGA_DATA[3] }]; # IO_L11N_AD1N_90 High Density 90 BIDIR LVCMOS18
set_property PACKAGE_PIN B5 [get_ports { ioFPGA_DATA[4] }]; # IO_L10P_AD2P_90 High Density 90 BIDIR LVCMOS18
set_property PACKAGE_PIN B4 [get_ports { ioFPGA_DATA[5] }]; # IO_L10N_AD2N_90 High Density 90 BIDIR LVCMOS18
set_property PACKAGE_PIN C2 [get_ports { ioFPGA_DATA[6] }]; # IO_L9P_AD3P_90 High Density 90 BIDIR LVCMOS18
set_property PACKAGE_PIN B2 [get_ports { ioFPGA_DATA[7] }]; # IO_L9N_AD3N_90 High Density 90 BIDIR LVCMOS18
set_property PACKAGE_PIN K11 [get_ports { ioSYNC_NEIGHBOR }]; # IO_L12P_AD0P_93 High Density 93 BIDIR LVCMOS18
set_property PACKAGE_PIN K10 [get_ports { ioSYNC_RIBBON }]; # IO_L12N_AD0N_93 High Density 93 BIDIR LVCMOS18
set_property PACKAGE_PIN B14 [get_ports { iSFP_LOS[0] }]; # IO_L12P_AD8P_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN A14 [get_ports { iSFP_LOS[1] }]; # IO_L12N_AD8N_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN F13 [get_ports { iSFP_LOS[10] }]; # IO_L7P_HDGC_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN F12 [get_ports { iSFP_LOS[11] }]; # IO_L7N_HDGC_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN F11 [get_ports { iSFP_LOS[12] }]; # IO_L6P_HDGC_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN E11 [get_ports { iSFP_LOS[13] }]; # IO_L6N_HDGC_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN G12 [get_ports { iSFP_LOS[14] }]; # IO_L5P_HDGC_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN G11 [get_ports { iSFP_LOS[15] }]; # IO_L5N_HDGC_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN H10 [get_ports { iSFP_LOS[16] }]; # IO_L4P_AD12P_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN G10 [get_ports { iSFP_LOS[17] }]; # IO_L4N_AD12N_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN H13 [get_ports { iSFP_LOS[18] }]; # IO_L3P_AD13P_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN H12 [get_ports { iSFP_LOS[19] }]; # IO_L3N_AD13N_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN A13 [get_ports { iSFP_LOS[2] }]; # IO_L11P_AD9P_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN J11 [get_ports { iSFP_LOS[20] }]; # IO_L2P_AD14P_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN J10 [get_ports { iSFP_LOS[21] }]; # IO_L2N_AD14N_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN J13 [get_ports { iSFP_LOS[22] }]; # IO_L1P_AD15P_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN J12 [get_ports { iSFP_LOS[23] }]; # IO_L1N_AD15N_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN A12 [get_ports { iSFP_LOS[3] }]; # IO_L11N_AD9N_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN C13 [get_ports { iSFP_LOS[4] }]; # IO_L10P_AD10P_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN B12 [get_ports { iSFP_LOS[5] }]; # IO_L10N_AD10N_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN D12 [get_ports { iSFP_LOS[6] }]; # IO_L9P_AD11P_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN C12 [get_ports { iSFP_LOS[7] }]; # IO_L9N_AD11N_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN E13 [get_ports { iSFP_LOS[8] }]; # IO_L8P_HDGC_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN D13 [get_ports { iSFP_LOS[9] }]; # IO_L8N_HDGC_94 High Density 94 INPUT LVCMOS18
set_property PACKAGE_PIN C3 [get_ports { oFC_RATE_SEL[0] }]; # IO_L7N_HDGC_AD5N_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN D2 [get_ports { oFC_RATE_SEL[1] }]; # IO_L6P_HDGC_AD6P_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN E3 [get_ports { oFC_RATE_SEL[10] }]; # IO_L2N_AD10N_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN E5 [get_ports { oFC_RATE_SEL[11] }]; # IO_L1P_AD11P_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN D1 [get_ports { oFC_RATE_SEL[2] }]; # IO_L6N_HDGC_AD6N_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN D6 [get_ports { oFC_RATE_SEL[3] }]; # IO_L5P_HDGC_AD7P_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN D5 [get_ports { oFC_RATE_SEL[4] }]; # IO_L5N_HDGC_AD7N_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN F1 [get_ports { oFC_RATE_SEL[5] }]; # IO_L4P_AD8P_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN E1 [get_ports { oFC_RATE_SEL[6] }]; # IO_L4N_AD8N_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN F3 [get_ports { oFC_RATE_SEL[7] }]; # IO_L3P_AD9P_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN F2 [get_ports { oFC_RATE_SEL[8] }]; # IO_L3N_AD9N_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN F4 [get_ports { oFC_RATE_SEL[9] }]; # IO_L2P_AD10P_90 High Density 90 OUTPUT LVCMOS18
set_property PACKAGE_PIN AF32 [get_ports { oFC_TD_N[0] }]; # MGTYTXN0_127   OUTPUT 
set_property PACKAGE_PIN AE34 [get_ports { oFC_TD_N[1] }]; # MGTYTXN1_127   OUTPUT 
set_property PACKAGE_PIN T32 [get_ports { oFC_TD_N[10] }]; # MGTYTXN2_129   OUTPUT 
set_property PACKAGE_PIN R34 [get_ports { oFC_TD_N[11] }]; # MGTYTXN3_129   OUTPUT 
set_property PACKAGE_PIN P32 [get_ports { oFC_TD_N[12] }]; # MGTYTXN0_130   OUTPUT 
set_property PACKAGE_PIN N34 [get_ports { oFC_TD_N[13] }]; # MGTYTXN1_130   OUTPUT 
set_property PACKAGE_PIN M32 [get_ports { oFC_TD_N[14] }]; # MGTYTXN2_130   OUTPUT 
set_property PACKAGE_PIN L34 [get_ports { oFC_TD_N[15] }]; # MGTYTXN3_130   OUTPUT 
set_property PACKAGE_PIN J34 [get_ports { oFC_TD_N[16] }]; # MGTYTXN0_131   OUTPUT 
set_property PACKAGE_PIN G34 [get_ports { oFC_TD_N[17] }]; # MGTYTXN1_131   OUTPUT 
set_property PACKAGE_PIN F36 [get_ports { oFC_TD_N[18] }]; # MGTYTXN2_131   OUTPUT 
set_property PACKAGE_PIN E34 [get_ports { oFC_TD_N[19] }]; # MGTYTXN3_131   OUTPUT 
set_property PACKAGE_PIN AD32 [get_ports { oFC_TD_N[2] }]; # MGTYTXN2_127   OUTPUT 
set_property PACKAGE_PIN D36 [get_ports { oFC_TD_N[20] }]; # MGTYTXN0_132   OUTPUT 
set_property PACKAGE_PIN C34 [get_ports { oFC_TD_N[21] }]; # MGTYTXN1_132   OUTPUT 
set_property PACKAGE_PIN B36 [get_ports { oFC_TD_N[22] }]; # MGTYTXN2_132   OUTPUT 
set_property PACKAGE_PIN A34 [get_ports { oFC_TD_N[23] }]; # MGTYTXN3_132   OUTPUT 
set_property PACKAGE_PIN C4 [get_ports { oFC_TD_N[24] }]; # IO_L8N_HDGC_AD4N_90 High Density 90 OUTPUT LVCMOS18*
set_property PACKAGE_PIN D3 [get_ports { oFC_TD_N[25] }]; # IO_L7P_HDGC_AD5P_90 High Density 90 OUTPUT LVCMOS18*
set_property PACKAGE_PIN AC34 [get_ports { oFC_TD_N[3] }]; # MGTYTXN3_127   OUTPUT 
set_property PACKAGE_PIN AB32 [get_ports { oFC_TD_N[4] }]; # MGTYTXN0_128   OUTPUT 
set_property PACKAGE_PIN AA34 [get_ports { oFC_TD_N[5] }]; # MGTYTXN1_128   OUTPUT 
set_property PACKAGE_PIN Y32 [get_ports { oFC_TD_N[6] }]; # MGTYTXN2_128   OUTPUT 
set_property PACKAGE_PIN W34 [get_ports { oFC_TD_N[7] }]; # MGTYTXN3_128   OUTPUT 
set_property PACKAGE_PIN V32 [get_ports { oFC_TD_N[8] }]; # MGTYTXN0_129   OUTPUT 
set_property PACKAGE_PIN U34 [get_ports { oFC_TD_N[9] }]; # MGTYTXN1_129   OUTPUT 
set_property PACKAGE_PIN AF31 [get_ports { oFC_TD_P[0] }]; # MGTYTXP0_127   OUTPUT 
set_property PACKAGE_PIN AE33 [get_ports { oFC_TD_P[1] }]; # MGTYTXP1_127   OUTPUT 
set_property PACKAGE_PIN T31 [get_ports { oFC_TD_P[10] }]; # MGTYTXP2_129   OUTPUT 
set_property PACKAGE_PIN R33 [get_ports { oFC_TD_P[11] }]; # MGTYTXP3_129   OUTPUT 
set_property PACKAGE_PIN P31 [get_ports { oFC_TD_P[12] }]; # MGTYTXP0_130   OUTPUT 
set_property PACKAGE_PIN N33 [get_ports { oFC_TD_P[13] }]; # MGTYTXP1_130   OUTPUT 
set_property PACKAGE_PIN M31 [get_ports { oFC_TD_P[14] }]; # MGTYTXP2_130   OUTPUT 
set_property PACKAGE_PIN L33 [get_ports { oFC_TD_P[15] }]; # MGTYTXP3_130   OUTPUT 
set_property PACKAGE_PIN J33 [get_ports { oFC_TD_P[16] }]; # MGTYTXP0_131   OUTPUT 
set_property PACKAGE_PIN G33 [get_ports { oFC_TD_P[17] }]; # MGTYTXP1_131   OUTPUT 
set_property PACKAGE_PIN F35 [get_ports { oFC_TD_P[18] }]; # MGTYTXP2_131   OUTPUT 
set_property PACKAGE_PIN E33 [get_ports { oFC_TD_P[19] }]; # MGTYTXP3_131   OUTPUT 
set_property PACKAGE_PIN AD31 [get_ports { oFC_TD_P[2] }]; # MGTYTXP2_127   OUTPUT 
set_property PACKAGE_PIN D35 [get_ports { oFC_TD_P[20] }]; # MGTYTXP0_132   OUTPUT 
set_property PACKAGE_PIN C33 [get_ports { oFC_TD_P[21] }]; # MGTYTXP1_132   OUTPUT 
set_property PACKAGE_PIN B35 [get_ports { oFC_TD_P[22] }]; # MGTYTXP2_132   OUTPUT 
set_property PACKAGE_PIN A33 [get_ports { oFC_TD_P[23] }]; # MGTYTXP3_132   OUTPUT 
set_property PACKAGE_PIN B7 [get_ports { oFC_TD_P[24] }]; # IO_L9P_AD11P_91 High Density 91 OUTPUT LVCMOS18*
set_property PACKAGE_PIN A7 [get_ports { oFC_TD_P[25] }]; # IO_L9N_AD11N_91 High Density 91 OUTPUT LVCMOS18*
set_property PACKAGE_PIN AC33 [get_ports { oFC_TD_P[3] }]; # MGTYTXP3_127   OUTPUT 
set_property PACKAGE_PIN AB31 [get_ports { oFC_TD_P[4] }]; # MGTYTXP0_128   OUTPUT 
set_property PACKAGE_PIN AA33 [get_ports { oFC_TD_P[5] }]; # MGTYTXP1_128   OUTPUT 
set_property PACKAGE_PIN Y31 [get_ports { oFC_TD_P[6] }]; # MGTYTXP2_128   OUTPUT 
set_property PACKAGE_PIN W33 [get_ports { oFC_TD_P[7] }]; # MGTYTXP3_128   OUTPUT 
set_property PACKAGE_PIN V31 [get_ports { oFC_TD_P[8] }]; # MGTYTXP0_129   OUTPUT 
set_property PACKAGE_PIN U33 [get_ports { oFC_TD_P[9] }]; # MGTYTXP1_129   OUTPUT 
set_property PACKAGE_PIN L12 [get_ports { oHIP_SERIAL_TX_OUT0 }]; # IO_L11P_AD1P_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN L11 [get_ports { oHIP_SERIAL_TX_OUT1 }]; # IO_L11N_AD1N_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN L13 [get_ports { oHIP_SERIAL_TX_OUT2 }]; # IO_L10P_AD2P_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN K13 [get_ports { oHIP_SERIAL_TX_OUT3 }]; # IO_L10N_AD2N_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN N10 [get_ports { oHIP_SERIAL_TX_OUT4 }]; # IO_L9P_AD3P_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN M10 [get_ports { oHIP_SERIAL_TX_OUT5 }]; # IO_L9N_AD3N_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN M12 [get_ports { oHIP_SERIAL_TX_OUT6 }]; # IO_L8P_HDGC_AD4P_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN M11 [get_ports { oHIP_SERIAL_TX_OUT7 }]; # IO_L8N_HDGC_AD4N_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN C10 [get_ports { oLED_N[0] }]; # IO_L8P_HDGC_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN C9 [get_ports { oLED_N[1] }]; # IO_L8N_HDGC_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN F9 [get_ports { oLED_N[10] }]; # IO_L3P_AD13P_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN E8 [get_ports { oLED_N[11] }]; # IO_L3N_AD13N_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN F8 [get_ports { oLED_N[12] }]; # IO_L2P_AD14P_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN F7 [get_ports { oLED_N[13] }]; # IO_L2N_AD14N_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN F6 [get_ports { oLED_N[14] }]; # IO_L1P_AD15P_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN E6 [get_ports { oLED_N[15] }]; # IO_L1N_AD15N_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN C8 [get_ports { oLED_N[2] }]; # IO_L7P_HDGC_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN C7 [get_ports { oLED_N[3] }]; # IO_L7N_HDGC_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN D11 [get_ports { oLED_N[4] }]; # IO_L6P_HDGC_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN D10 [get_ports { oLED_N[5] }]; # IO_L6N_HDGC_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN D8 [get_ports { oLED_N[6] }]; # IO_L5P_HDGC_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN D7 [get_ports { oLED_N[7] }]; # IO_L5N_HDGC_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN E10 [get_ports { oLED_N[8] }]; # IO_L4P_AD12P_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN E9 [get_ports { oLED_N[9] }]; # IO_L4N_AD12N_91 High Density 91 OUTPUT LVCMOS18
set_property PACKAGE_PIN M14 [get_ports { oTXD }]; # IO_L7P_HDGC_AD5P_93 High Density 93 OUTPUT LVCMOS18
set_property PACKAGE_PIN AD1 [get_ports { pci_exp_rxn[0] }]; # MGTHRXN3_227   INPUT 
set_property PACKAGE_PIN AE3 [get_ports { pci_exp_rxn[1] }]; # MGTHRXN2_227   INPUT 
set_property PACKAGE_PIN AF1 [get_ports { pci_exp_rxn[2] }]; # MGTHRXN1_227   INPUT 
set_property PACKAGE_PIN AG3 [get_ports { pci_exp_rxn[3] }]; # MGTHRXN0_227   INPUT 
set_property PACKAGE_PIN AH1 [get_ports { pci_exp_rxn[4] }]; # MGTHRXN3_226   INPUT 
set_property PACKAGE_PIN AJ3 [get_ports { pci_exp_rxn[5] }]; # MGTHRXN2_226   INPUT 
set_property PACKAGE_PIN AK1 [get_ports { pci_exp_rxn[6] }]; # MGTHRXN1_226   INPUT 
set_property PACKAGE_PIN AL3 [get_ports { pci_exp_rxn[7] }]; # MGTHRXN0_226   INPUT 
set_property PACKAGE_PIN AD2 [get_ports { pci_exp_rxp[0] }]; # MGTHRXP3_227   INPUT 
set_property PACKAGE_PIN AE4 [get_ports { pci_exp_rxp[1] }]; # MGTHRXP2_227   INPUT 
set_property PACKAGE_PIN AF2 [get_ports { pci_exp_rxp[2] }]; # MGTHRXP1_227   INPUT 
set_property PACKAGE_PIN AG4 [get_ports { pci_exp_rxp[3] }]; # MGTHRXP0_227   INPUT 
set_property PACKAGE_PIN AH2 [get_ports { pci_exp_rxp[4] }]; # MGTHRXP3_226   INPUT 
set_property PACKAGE_PIN AJ4 [get_ports { pci_exp_rxp[5] }]; # MGTHRXP2_226   INPUT 
set_property PACKAGE_PIN AK2 [get_ports { pci_exp_rxp[6] }]; # MGTHRXP1_226   INPUT 
set_property PACKAGE_PIN AL4 [get_ports { pci_exp_rxp[7] }]; # MGTHRXP0_226   INPUT 
set_property PACKAGE_PIN AD5 [get_ports { pci_exp_txn[0] }]; # MGTHTXN3_227   OUTPUT 
set_property PACKAGE_PIN AE7 [get_ports { pci_exp_txn[1] }]; # MGTHTXN2_227   OUTPUT 
set_property PACKAGE_PIN AF5 [get_ports { pci_exp_txn[2] }]; # MGTHTXN1_227   OUTPUT 
set_property PACKAGE_PIN AG7 [get_ports { pci_exp_txn[3] }]; # MGTHTXN0_227   OUTPUT 
set_property PACKAGE_PIN AH5 [get_ports { pci_exp_txn[4] }]; # MGTHTXN3_226   OUTPUT 
set_property PACKAGE_PIN AJ7 [get_ports { pci_exp_txn[5] }]; # MGTHTXN2_226   OUTPUT 
set_property PACKAGE_PIN AK5 [get_ports { pci_exp_txn[6] }]; # MGTHTXN1_226   OUTPUT 
set_property PACKAGE_PIN AL7 [get_ports { pci_exp_txn[7] }]; # MGTHTXN0_226   OUTPUT 
set_property PACKAGE_PIN AD6 [get_ports { pci_exp_txp[0] }]; # MGTHTXP3_227   OUTPUT 
set_property PACKAGE_PIN AE8 [get_ports { pci_exp_txp[1] }]; # MGTHTXP2_227   OUTPUT 
set_property PACKAGE_PIN AF6 [get_ports { pci_exp_txp[2] }]; # MGTHTXP1_227   OUTPUT 
set_property PACKAGE_PIN AG8 [get_ports { pci_exp_txp[3] }]; # MGTHTXP0_227   OUTPUT 
set_property PACKAGE_PIN AH6 [get_ports { pci_exp_txp[4] }]; # MGTHTXP3_226   OUTPUT 
set_property PACKAGE_PIN AJ8 [get_ports { pci_exp_txp[5] }]; # MGTHTXP2_226   OUTPUT 
set_property PACKAGE_PIN AK6 [get_ports { pci_exp_txp[6] }]; # MGTHTXP1_226   OUTPUT 
set_property PACKAGE_PIN AL8 [get_ports { pci_exp_txp[7] }]; # MGTHTXP0_226   OUTPUT 
set_property PACKAGE_PIN AC11 [get_ports { sys_clk_n }]; # MGTREFCLK0N_228   INPUT 
set_property PACKAGE_PIN AC12 [get_ports { sys_clk_p }]; # MGTREFCLK0P_228   INPUT 
set_property PACKAGE_PIN A8 [get_ports { sys_rst_n }]; # IO_L10N_AD10N_91 High Density 91 INPUT LVCMOS18*

make_diff_pair_ports iCLK_FC_425_P[0] iCLK_FC_425_N[0];
make_diff_pair_ports iCLK_FC_425_P[1] iCLK_FC_425_N[1];
make_diff_pair_ports iFC_RD_P[0] iFC_RD_N[0];
make_diff_pair_ports iFC_RD_P[10] iFC_RD_N[10];
make_diff_pair_ports iFC_RD_P[11] iFC_RD_N[11];
make_diff_pair_ports iFC_RD_P[12] iFC_RD_N[12];
make_diff_pair_ports iFC_RD_P[13] iFC_RD_N[13];
make_diff_pair_ports iFC_RD_P[14] iFC_RD_N[14];
make_diff_pair_ports iFC_RD_P[15] iFC_RD_N[15];
make_diff_pair_ports iFC_RD_P[16] iFC_RD_N[16];
make_diff_pair_ports iFC_RD_P[17] iFC_RD_N[17];
make_diff_pair_ports iFC_RD_P[18] iFC_RD_N[18];
make_diff_pair_ports iFC_RD_P[19] iFC_RD_N[19];
make_diff_pair_ports iFC_RD_P[1] iFC_RD_N[1];
make_diff_pair_ports iFC_RD_P[20] iFC_RD_N[20];
make_diff_pair_ports iFC_RD_P[21] iFC_RD_N[21];
make_diff_pair_ports iFC_RD_P[22] iFC_RD_N[22];
make_diff_pair_ports iFC_RD_P[23] iFC_RD_N[23];
make_diff_pair_ports iFC_RD_P[2] iFC_RD_N[2];
make_diff_pair_ports iFC_RD_P[3] iFC_RD_N[3];
make_diff_pair_ports iFC_RD_P[4] iFC_RD_N[4];
make_diff_pair_ports iFC_RD_P[5] iFC_RD_N[5];
make_diff_pair_ports iFC_RD_P[6] iFC_RD_N[6];
make_diff_pair_ports iFC_RD_P[7] iFC_RD_N[7];
make_diff_pair_ports iFC_RD_P[8] iFC_RD_N[8];
make_diff_pair_ports iFC_RD_P[9] iFC_RD_N[9];
make_diff_pair_ports oFC_TD_P[0] oFC_TD_N[0];
make_diff_pair_ports oFC_TD_P[10] oFC_TD_N[10];
make_diff_pair_ports oFC_TD_P[11] oFC_TD_N[11];
make_diff_pair_ports oFC_TD_P[12] oFC_TD_N[12];
make_diff_pair_ports oFC_TD_P[13] oFC_TD_N[13];
make_diff_pair_ports oFC_TD_P[14] oFC_TD_N[14];
make_diff_pair_ports oFC_TD_P[15] oFC_TD_N[15];
make_diff_pair_ports oFC_TD_P[16] oFC_TD_N[16];
make_diff_pair_ports oFC_TD_P[17] oFC_TD_N[17];
make_diff_pair_ports oFC_TD_P[18] oFC_TD_N[18];
make_diff_pair_ports oFC_TD_P[19] oFC_TD_N[19];
make_diff_pair_ports oFC_TD_P[1] oFC_TD_N[1];
make_diff_pair_ports oFC_TD_P[20] oFC_TD_N[20];
make_diff_pair_ports oFC_TD_P[21] oFC_TD_N[21];
make_diff_pair_ports oFC_TD_P[22] oFC_TD_N[22];
make_diff_pair_ports oFC_TD_P[23] oFC_TD_N[23];
make_diff_pair_ports oFC_TD_P[2] oFC_TD_N[2];
make_diff_pair_ports oFC_TD_P[3] oFC_TD_N[3];
make_diff_pair_ports oFC_TD_P[4] oFC_TD_N[4];
make_diff_pair_ports oFC_TD_P[5] oFC_TD_N[5];
make_diff_pair_ports oFC_TD_P[6] oFC_TD_N[6];
make_diff_pair_ports oFC_TD_P[7] oFC_TD_N[7];
make_diff_pair_ports oFC_TD_P[8] oFC_TD_N[8];
make_diff_pair_ports oFC_TD_P[9] oFC_TD_N[9];
