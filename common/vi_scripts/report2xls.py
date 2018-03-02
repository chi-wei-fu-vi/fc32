#!/usr/bin/env python2
panelnames=[]
panelname2name={}
name2wsname={}
clk2abrev={
'fc8clkrst_wrap_inst|altpll_425in_212out_inst|s5_altpll_425in_212out_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk' : 'coreclk',
'fc8clkrst_wrap_inst|altpll_425in_215out_inst|s5_altpll_425in_215out_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk' : 'xbarclk',
'fc8clkrst_wrap_inst|clkgen_inst|s5_altpll_425in_inst|s5_altpll_425in_inst|altera_pll_i|stratixv_pll|counter[0].output_counter|divclk' : 'serdesclk',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[0].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk0',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[0].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk0',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[10].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk10',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[10].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk10',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[11].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk11',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[11].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk11',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[12].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk12',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[12].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk12',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[13].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk13',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[13].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk13',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[14].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk14',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[14].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk14',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[15].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk15',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[15].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk15',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[16].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk16',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[16].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk16',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[17].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk17',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[17].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk17',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[18].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk18',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[18].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk18',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[19].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk19',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[19].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk19',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[1].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk1',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[1].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk1',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[20].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk20',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[20].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk20',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[21].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk21',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[21].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk21',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[22].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk22',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[22].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk22',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[23].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk23',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[23].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk23',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[24].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk24',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[24].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk24',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[25].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk25',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[25].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk25',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[2].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk2',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[2].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk2',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[3].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk3',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[3].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk3',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[4].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk4',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[4].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk4',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[5].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk5',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[5].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk5',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[6].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk6',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[6].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk6',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[7].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk7',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[7].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk7',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[8].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk8',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[8].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk8',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[9].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk9',
'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[9].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk9',
'iCLK_100M_0' : 'iCLK_100M_0',
'iCLK_100M_1' : 'iCLK_100M_1',
'iCLK_FR' : 'iCLK_FR',
'iPCIE_REF_CLK' : 'iPCIE_REF_CLK',
'n/a' : 'NA',
'pcie_12le_inst|u_bali_pcie_gen2x8_wrap|bali_pcie_hip|s5_pcie_gen2x8_12_1_inst|altpcie_hip_256_pipen1b|stratixv_hssi_gen3_pcie_hip|coreclkout' : 'pcieclk'
}


def TimeQuest_Timing_Analyzer__Unconstrained_Paths (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Unconstrained_Paths.csv to xls
  '''
  a=[]
  s=[]
  headings=['Property', 'Setup', 'Hold']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Unconstrained_Paths.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAUP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Unconstrained Paths',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Unconstrained Paths')
  panelname2name['TimeQuest Timing Analyzer||Unconstrained Paths']='TimeQuest_Timing_Analyzer__Unconstrained_Paths'
  name2wsname['TimeQuest_Timing_Analyzer__Unconstrained_Paths']='TTAUP'


def Flow_Elapsed_Time (wb) :
  '''
  convert Flow_Elapsed_Time.csv to xls
  '''
  a=[]
  s=[]
  headings=['Module Name', 'Elapsed Time', 'Average Processors Used', 'Peak Virtual Memory', 'Total CPU Time (on all processors)']
  INFILE=open('csv_files/Flow_Elapsed_Time.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FET')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Flow Elapsed Time',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Flow Elapsed Time')
  panelname2name['Flow Elapsed Time']='Flow_Elapsed_Time'
  name2wsname['Flow_Elapsed_Time']='FET'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', '0 to Hi-Z', '1 to Hi-Z', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MDRMODT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Disable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Disable Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Disable Times']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times']='TTAS88MS88MDRMODT'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Source Node', 'Synchronization Node', 'Worst-Case MTBF (Years)', 'Typical MTBF (Years)', 'Included in Design MTBF']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MMRSS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Metastability Report||Synchronizer Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Metastability Report||Synchronizer Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Metastability Report||Synchronizer Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary']='TTAS80MS80MMRSS'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MSS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Setup Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Setup Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Setup Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary']='TTAS80MS80MSS'


def Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report (wb) :
  '''
  convert Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report.csv to xls
  '''
  a=[]
  s=[]
  headings=['Component', 'Type', 'Instance Name']
  INFILE=open('csv_files/Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSGRTRR')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||GXB Reports||Transceiver Reconfiguration Report',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||GXB Reports||Transceiver Reconfiguration Report')
  panelname2name['Fitter||Resource Section||GXB Reports||Transceiver Reconfiguration Report']='Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report'
  name2wsname['Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report']='FRSGRTRR'


def Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics.csv to xls
  '''
  a=[]
  s=[]
  headings=['Inverted Register', 'Fan out']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASORRSIRS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Inverted Register Statistics',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Inverted Register Statistics')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Inverted Register Statistics']='Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics']='ASASORRSIRS'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MSS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Setup Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Setup Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Setup Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary']='TTAS88MS88MSS'


def TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Quartus II Version', 'Version 12.1 Build 177 11/07/2012 SJ Full Version']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTATTAS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||TimeQuest Timing Analyzer Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||TimeQuest Timing Analyzer Summary')
  panelname2name['TimeQuest Timing Analyzer||TimeQuest Timing Analyzer Summary']='TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary']='TTATTAS'


def TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin', 'I/O Standard', '10-90 Rise Time', '90-10 Fall Time']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAAIOTITT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Advanced I/O Timing||Input Transition Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Advanced I/O Timing||Input Transition Times')
  panelname2name['TimeQuest Timing Analyzer||Advanced I/O Timing||Input Transition Times']='TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times']='TTAAIOTITT'


def Assembler__Assembler_Settings (wb) :
  '''
  convert Assembler__Assembler_Settings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Option', 'Setting', 'Default Value']
  INFILE=open('csv_files/Assembler__Assembler_Settings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('AAS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Assembler||Assembler Settings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Assembler||Assembler Settings')
  panelname2name['Assembler||Assembler Settings']='Assembler__Assembler_Settings'
  name2wsname['Assembler__Assembler_Settings']='AAS'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MSS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Setup Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Setup Summary')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Setup Summary']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary']='TTAF80MF80MSS'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MHS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Hold Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Hold Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Hold Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary']='TTAS88MS88MHS'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MDRMOET')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Enable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Enable Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Output Enable Times']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times']='TTAS88MS88MDRMOET'


def Assembler__Assembler_Device_Options____dse_temp_rev_sof (wb) :
  '''
  convert Assembler__Assembler_Device_Options____dse_temp_rev_sof.csv to xls
  '''
  a=[]
  s=[]
  headings=['Option', 'Setting']
  INFILE=open('csv_files/Assembler__Assembler_Device_Options____dse_temp_rev_sof.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('AADOdtrs')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Assembler||Assembler Device Options: __dse_temp_rev.sof',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Assembler||Assembler Device Options: __dse_temp_rev.sof')
  panelname2name['Assembler||Assembler Device Options: __dse_temp_rev.sof']='Assembler__Assembler_Device_Options____dse_temp_rev_sof'
  name2wsname['Assembler__Assembler_Device_Options____dse_temp_rev_sof']='AADOdtrs'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', '0 to Hi-Z', '1 to Hi-Z', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MDRODT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Disable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Disable Times')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Disable Times']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times']='TTAF80MF80MDRODT'


def Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Resource', 'Usage']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASRUS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Resource Usage Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Resource Usage Summary')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Resource Usage Summary']='Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary']='ASASRUS'


def TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Setup', 'Hold', 'Recovery', 'Removal', 'Minimum Pulse Width']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAMTAS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Multicorner Timing Analysis Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Multicorner Timing Analysis Summary')
  panelname2name['TimeQuest Timing Analyzer||Multicorner Timing Analysis Summary']='TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary']='TTAMTAS'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MMPWS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Minimum Pulse Width Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Minimum Pulse Width Summary')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Minimum Pulse Width Summary']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary']='TTAF80MF80MMPWS'


def TimeQuest_Timing_Analyzer_GUI__SDC_File_List (wb) :
  '''
  convert TimeQuest_Timing_Analyzer_GUI__SDC_File_List.csv to xls
  '''
  a=[]
  s=[]
  headings=['SDC File Path', 'Status', 'Read at']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer_GUI__SDC_File_List.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAGSFL')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer GUI||SDC File List',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer GUI||SDC File List')
  panelname2name['TimeQuest Timing Analyzer GUI||SDC File List']='TimeQuest_Timing_Analyzer_GUI__SDC_File_List'
  name2wsname['TimeQuest_Timing_Analyzer_GUI__SDC_File_List']='TTAGSFL'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MMPWS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Minimum Pulse Width Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Minimum Pulse Width Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Minimum Pulse Width Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary']='TTAS88MS88MMPWS'


def Flow_Settings (wb) :
  '''
  convert Flow_Settings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Option', 'Setting']
  INFILE=open('csv_files/Flow_Settings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Flow Settings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Flow Settings')
  panelname2name['Flow Settings']='Flow_Settings'
  name2wsname['Flow_Settings']='FS'


def TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin', 'I/O Standard', 'Near Tline Length', 'Near Tline L per Length', 'Near Tline C per Length', 'Near Series R', 'Near Differential R', 'Near Pull-up R', 'Near Pull-down R', 'Near C', 'Far Tline Length', 'Far Tline L per Length', 'Far Tline C per Length', 'Far Series R', 'Far Pull-up R', 'Far Pull-down R', 'Far C', 'Termination Voltage', 'Far Differential R', 'EBD File Name', 'EBD Signal Name', 'EBD Far-end']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAAIOTBTMA')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Advanced I/O Timing||Board Trace Model Assignments',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Advanced I/O Timing||Board Trace Model Assignments')
  panelname2name['TimeQuest Timing Analyzer||Advanced I/O Timing||Board Trace Model Assignments']='TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments'
  name2wsname['TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments']='TTAAIOTBTMA'


def Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation (wb) :
  '''
  convert Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation.csv to xls
  '''
  a=[]
  s=[]
  headings=['Partition Name', '# Nodes', '# Preserved Nodes', 'Preservation Level Used', 'Netlist Type Used']
  INFILE=open('csv_files/Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FFICSICPP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Fitter Incremental Compilation Section||Incremental Compilation Placement Preservation',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Fitter Incremental Compilation Section||Incremental Compilation Placement Preservation')
  panelname2name['Fitter||Fitter Incremental Compilation Section||Incremental Compilation Placement Preservation']='Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation'
  name2wsname['Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation']='FFICSICPP'


def Restore_Archived_Project__Files_Restored (wb) :
  '''
  convert Restore_Archived_Project__Files_Restored.csv to xls
  '''
  a=[]
  s=[]
  headings=['File Name']
  INFILE=open('csv_files/Restore_Archived_Project__Files_Restored.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('RAPFR')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Restore Archived Project||Files Restored',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Restore Archived Project||Files Restored')
  panelname2name['Restore Archived Project||Files Restored']='Restore_Archived_Project__Files_Restored'
  name2wsname['Restore_Archived_Project__Files_Restored']='RAPFR'


def TimeQuest_Timing_Analyzer__SDC_File_List (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__SDC_File_List.csv to xls
  '''
  a=[]
  s=[]
  headings=['SDC File Path', 'Status', 'Read at']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__SDC_File_List.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTASFL')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||SDC File List',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||SDC File List')
  panelname2name['TimeQuest Timing Analyzer||SDC File List']='TimeQuest_Timing_Analyzer__SDC_File_List'
  name2wsname['TimeQuest_Timing_Analyzer__SDC_File_List']='TTASFL'


def Assembler__Assembler_Encrypted_IP_Cores_Summary (wb) :
  '''
  convert Assembler__Assembler_Encrypted_IP_Cores_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Vendor', 'IP Core Name', 'License Type']
  INFILE=open('csv_files/Assembler__Assembler_Encrypted_IP_Cores_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('AAEICS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Assembler||Assembler Encrypted IP Cores Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Assembler||Assembler Encrypted IP Cores Summary')
  panelname2name['Assembler||Assembler Encrypted IP Cores Summary']='Assembler__Assembler_Encrypted_IP_Cores_Summary'
  name2wsname['Assembler__Assembler_Encrypted_IP_Cores_Summary']='AAEICS'


def Fitter__Fitter_Summary (wb) :
  '''
  convert Fitter__Fitter_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Fitter Status', 'Successful - Wed May 22 00:09:58 2013']
  INFILE=open('csv_files/Fitter__Fitter_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FFS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Fitter Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Fitter Summary')
  panelname2name['Fitter||Fitter Summary']='Fitter__Fitter_Summary'
  name2wsname['Fitter__Fitter_Summary']='FFS'


def Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details (wb) :
  '''
  convert Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details.csv to xls
  '''
  a=[]
  s=[]
  headings=['Source Register', 'Destination Register', 'Delay Added in ns']
  INFILE=open('csv_files/Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FEDAfHTEDAfHTD')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Details',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Details')
  panelname2name['Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Details']='Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details'
  name2wsname['Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details']='FEDAfHTEDAfHTD'


def Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings (wb) :
  '''
  convert Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Setting']
  INFILE=open('csv_files/Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASSASDPS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Settings||Analysis & Synthesis Default Parameter Settings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Settings||Analysis & Synthesis Default Parameter Settings')
  panelname2name['Analysis & Synthesis||Settings||Analysis & Synthesis Default Parameter Settings']='Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings'
  name2wsname['Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings']='ASSASDPS'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MDRHT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Hold Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Hold Times')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Hold Times']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times']='TTAF80MF80MDRHT'


def Fitter__Ignored_Assignments (wb) :
  '''
  convert Fitter__Ignored_Assignments.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Ignored Entity', 'Ignored From', 'Ignored To', 'Ignored Value', 'Ignored Source']
  INFILE=open('csv_files/Fitter__Ignored_Assignments.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FIA')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Ignored Assignments',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Ignored Assignments')
  panelname2name['Fitter||Ignored Assignments']='Fitter__Ignored_Assignments'
  name2wsname['Fitter__Ignored_Assignments']='FIA'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MRS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Recovery Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Recovery Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Recovery Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary']='TTAS88MS88MRS'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MDRST')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Setup Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Setup Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Setup Times']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times']='TTAS88MS88MDRST'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MDRMCtOT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Clock to Output Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Clock to Output Times')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Clock to Output Times']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times']='TTAF80MF80MDRMCtOT'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MRS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Removal Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Removal Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Removal Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary']='TTAS80MS80MRS'


def TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAMDRSCtOT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Clock to Output Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Clock to Output Times')
  panelname2name['TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Clock to Output Times']='TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times']='TTAMDRSCtOT'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MDRCtOT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Clock to Output Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Clock to Output Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Clock to Output Times']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times']='TTAS80MS80MDRCtOT'


def Fitter__Resource_Section__PLL_Usage_Summary (wb) :
  '''
  convert Fitter__Resource_Section__PLL_Usage_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['', '']
  INFILE=open('csv_files/Fitter__Resource_Section__PLL_Usage_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSPUS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||PLL Usage Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||PLL Usage Summary')
  panelname2name['Fitter||Resource Section||PLL Usage Summary']='Fitter__Resource_Section__PLL_Usage_Summary'
  name2wsname['Fitter__Resource_Section__PLL_Usage_Summary']='FRSPUS'


def Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis.csv to xls
  '''
  a=[]
  s=[]
  headings=['Register Name', 'Protected by Synthesis Attribute or Preserve Register Assignment', 'Not to be Touched by Netlist Optimizations']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASORRSRPbS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Protected by Synthesis',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Protected by Synthesis')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Protected by Synthesis']='Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis']='ASASORRSRPbS'


def Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary (wb) :
  '''
  convert Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Source Clock(s)', 'Destination Clock(s)', 'Delay Added in ns']
  INFILE=open('csv_files/Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FEDAfHTEDAfHTS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Summary')
  panelname2name['Fitter||Estimated Delay Added for Hold Timing||Estimated Delay Added for Hold Timing Summary']='Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary'
  name2wsname['Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary']='FEDAfHTEDAfHTS'


def TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAMDRSMCtOT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Minimum Clock to Output Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Minimum Clock to Output Times')
  panelname2name['TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Minimum Clock to Output Times']='TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times']='TTAMDRSMCtOT'


def Flow_Summary (wb) :
  '''
  convert Flow_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Flow Status', 'Successful - Fri May 24 08:56:47 2013']
  INFILE=open('csv_files/Flow_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FS_1')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Flow Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Flow Summary')
  panelname2name['Flow Summary']='Flow_Summary'
  name2wsname['Flow_Summary']='FS_1'


def Fitter__Resource_Section__GXB_Reports__Transmitter_PLL (wb) :
  '''
  convert Fitter__Resource_Section__GXB_Reports__Transmitter_PLL.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', '']
  INFILE=open('csv_files/Fitter__Resource_Section__GXB_Reports__Transmitter_PLL.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSGRTP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||GXB Reports||Transmitter PLL',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||GXB Reports||Transmitter PLL')
  panelname2name['Fitter||Resource Section||GXB Reports||Transmitter PLL']='Fitter__Resource_Section__GXB_Reports__Transmitter_PLL'
  name2wsname['Fitter__Resource_Section__GXB_Reports__Transmitter_PLL']='FRSGRTP'


def Fitter__Fitter_Device_Options (wb) :
  '''
  convert Fitter__Fitter_Device_Options.csv to xls
  '''
  a=[]
  s=[]
  headings=['Option', 'Setting']
  INFILE=open('csv_files/Fitter__Fitter_Device_Options.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FFDO')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Fitter Device Options',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Fitter Device Options')
  panelname2name['Fitter||Fitter Device Options']='Fitter__Fitter_Device_Options'
  name2wsname['Fitter__Fitter_Device_Options']='FFDO'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MDROET')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Enable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Enable Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Enable Times']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times']='TTAS88MS88MDROET'


def Restore_Archived_Project__Restore_Archived_Project_Summary (wb) :
  '''
  convert Restore_Archived_Project__Restore_Archived_Project_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Restore Archived Project Status', 'Successful - Fri May 24 08:56:47 2013']
  INFILE=open('csv_files/Restore_Archived_Project__Restore_Archived_Project_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('RAPRAPS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Restore Archived Project||Restore Archived Project Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Restore Archived Project||Restore Archived Project Summary')
  panelname2name['Restore Archived Project||Restore Archived Project Summary']='Restore_Archived_Project__Restore_Archived_Project_Summary'
  name2wsname['Restore_Archived_Project__Restore_Archived_Project_Summary']='RAPRAPS'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', '0 to Hi-Z', '1 to Hi-Z', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MDRODT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Disable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Disable Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Disable Times']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times']='TTAS80MS80MDRODT'


def Fitter__Resource_Section__Bidir_Pins (wb) :
  '''
  convert Fitter__Resource_Section__Bidir_Pins.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Pin #', 'I/O Bank', 'X coordinate', 'Y coordinate', 'Z coordinate', 'Combinational Fan-Out', 'Registered Fan-Out', 'Global', 'Output Register', 'Slew Rate', 'Open Drain', 'Bus Hold', 'Weak Pull Up', 'I/O Standard', 'Current Strength', 'Input Termination', 'Output Termination', 'Termination Control Block', 'Output Buffer Delay', 'Output Buffer Delay Control', 'Location assigned by', 'Load', 'Output Enable Source', 'Output Enable Group']
  INFILE=open('csv_files/Fitter__Resource_Section__Bidir_Pins.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSBP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Bidir Pins',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Bidir Pins')
  panelname2name['Fitter||Resource Section||Bidir Pins']='Fitter__Resource_Section__Bidir_Pins'
  name2wsname['Fitter__Resource_Section__Bidir_Pins']='FRSBP'


def TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers.csv to xls
  '''
  a=[]
  s=[]
  headings=['From Clock', 'To Clock', 'RR Paths', 'FR Paths', 'RF Paths', 'FF Paths']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTACTRT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Clock Transfers||Removal Transfers',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Clock Transfers||Removal Transfers')
  panelname2name['TimeQuest Timing Analyzer||Clock Transfers||Removal Transfers']='TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers'
  name2wsname['TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers']='TTACTRT'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Fmax', 'Restricted Fmax', 'Clock Name', 'Note']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MFS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Fmax Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Fmax Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Fmax Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary']='TTAS88MS88MFS'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', '0 to Hi-Z', '1 to Hi-Z', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MDRMODT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Disable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Disable Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Disable Times']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times']='TTAS80MS80MDRMODT'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MRS_1')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Removal Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Removal Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Removal Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary']='TTAS88MS88MRS_1'


def Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis.csv to xls
  '''
  a=[]
  s=[]
  headings=['Register name', 'Reason for Removal']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASORRSRRDS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Removed During Synthesis',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Removed During Synthesis')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Registers Removed During Synthesis']='Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis']='ASASORRSRRDS'


def TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_ (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin', 'I/O Standard', 'Board Delay on Rise', 'Board Delay on Fall', 'Steady State Voh at FPGA Pin', 'Steady State Vol at FPGA Pin', 'Voh Max at FPGA Pin', 'Vol Min at FPGA Pin', 'Ringback Voltage on Rise at FPGA Pin', 'Ringback Voltage on Fall at FPGA Pin', '10-90 Rise Time at FPGA Pin', '90-10 Fall Time at FPGA Pin', 'Monotonic Rise at FPGA Pin', 'Monotonic Fall at FPGA Pin', 'Steady State Voh at Far-end', 'Steady State Vol at Far-end', 'Voh Max at Far-end', 'Vol Min at Far-end', 'Ringback Voltage on Rise at Far-end', 'Ringback Voltage on Fall at Far-end', '10-90 Rise Time at Far-end', '90-10 Fall Time at Far-end', 'Monotonic Rise at Far-end', 'Monotonic Fall at Far-end']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAAIOTSIMSIMS90M')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 0c Model)',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 0c Model)')
  panelname2name['TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 0c Model)']='TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_'
  name2wsname['TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_']='TTAAIOTSIMSIMS90M'


def Fitter__Resource_Section__Delay_Chain_Summary (wb) :
  '''
  convert Fitter__Resource_Section__Delay_Chain_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Pin Type', 'D1', 'D2', 'D3_0', 'D3_1', 'T4 (DDIO_MUX)', 'D4', 'T8_0 (DQS)', 'T8_1 (NDQS)', 'D5', 'D6', 'D6 OE', 'D5 OCT', 'D6 OCT', 'T11 (Postamble)']
  INFILE=open('csv_files/Fitter__Resource_Section__Delay_Chain_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSDCS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Delay Chain Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Delay Chain Summary')
  panelname2name['Fitter||Resource Section||Delay Chain Summary']='Fitter__Resource_Section__Delay_Chain_Summary'
  name2wsname['Fitter__Resource_Section__Delay_Chain_Summary']='FRSDCS'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MDRHT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Hold Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Hold Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Hold Times']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times']='TTAS80MS80MDRHT'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MDRST')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Setup Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Setup Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Setup Times']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times']='TTAS80MS80MDRST'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MDRMCtOT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Clock to Output Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Clock to Output Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Minimum Clock to Output Times']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times']='TTAS88MS88MDRMCtOT'


def Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity (wb) :
  '''
  convert Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity.csv to xls
  '''
  a=[]
  s=[]
  headings=['Compilation Hierarchy Node', 'ALMs needed [=A-B+C]', '[A] ALMs used in final placement', '[B] Estimate of ALMs recoverable by dense packing', '[C] Estimate of ALMs unavailable', 'ALMs used for memory', 'Combinational ALUTs', 'Dedicated Logic Registers', 'I/O Registers', 'Block Memory Bits', 'M20Ks', 'DSP Blocks', 'Pins', 'Virtual Pins', 'Full Hierarchy Name', 'Library Name']
  INFILE=open('csv_files/Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSFRUbE')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Fitter Resource Utilization by Entity',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Fitter Resource Utilization by Entity')
  panelname2name['Fitter||Resource Section||Fitter Resource Utilization by Entity']='Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity'
  name2wsname['Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity']='FRSFRUbE'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Source Node', 'Synchronization Node', 'Worst-Case MTBF (Years)', 'Typical MTBF (Years)', 'Included in Design MTBF']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MMRSS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Metastability Report||Synchronizer Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Metastability Report||Synchronizer Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Metastability Report||Synchronizer Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary']='TTAS88MS88MMRSS'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MRS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Removal Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Removal Summary')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Removal Summary']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary']='TTAF80MF80MRS'


def Assembler__Assembler_Summary (wb) :
  '''
  convert Assembler__Assembler_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Assembler Status', 'Successful - Wed May 22 00:17:21 2013']
  INFILE=open('csv_files/Assembler__Assembler_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('AAS_1')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Assembler||Assembler Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Assembler||Assembler Summary')
  panelname2name['Assembler||Assembler Summary']='Assembler__Assembler_Summary'
  name2wsname['Assembler__Assembler_Summary']='AAS_1'


def TimeQuest_Timing_Analyzer__Clocks (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Clocks.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock Name', 'Type', 'Period', 'Frequency', 'Rise', 'Fall', 'Duty Cycle', 'Divide by', 'Multiply by', 'Phase', 'Offset', 'Edge List', 'Edge Shift', 'Inverted', 'Master', 'Source', 'Targets']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Clocks.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAC')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Clocks',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Clocks')
  panelname2name['TimeQuest Timing Analyzer||Clocks']='TimeQuest_Timing_Analyzer__Clocks'
  name2wsname['TimeQuest_Timing_Analyzer__Clocks']='TTAC'


def TimeQuest_Timing_Analyzer__Parallel_Compilation (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Parallel_Compilation.csv to xls
  '''
  a=[]
  s=[]
  headings=['Processors', 'Number']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Parallel_Compilation.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAPC')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Parallel Compilation',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Parallel Compilation')
  panelname2name['TimeQuest Timing Analyzer||Parallel Compilation']='TimeQuest_Timing_Analyzer__Parallel_Compilation'
  name2wsname['TimeQuest_Timing_Analyzer__Parallel_Compilation']='TTAPC'


def TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers.csv to xls
  '''
  a=[]
  s=[]
  headings=['From Clock', 'To Clock', 'RR Paths', 'FR Paths', 'RF Paths', 'FF Paths']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTACTST')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Clock Transfers||Setup Transfers',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Clock Transfers||Setup Transfers')
  panelname2name['TimeQuest Timing Analyzer||Clock Transfers||Setup Transfers']='TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers'
  name2wsname['TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers']='TTACTST'


def Fitter__I_O_Assignment_Warnings (wb) :
  '''
  convert Fitter__I_O_Assignment_Warnings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin Name', 'Reason']
  INFILE=open('csv_files/Fitter__I_O_Assignment_Warnings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FIOAW')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||I/O Assignment Warnings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||I/O Assignment Warnings')
  panelname2name['Fitter||I/O Assignment Warnings']='Fitter__I_O_Assignment_Warnings'
  name2wsname['Fitter__I_O_Assignment_Warnings']='FIOAW'


def TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_ (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin', 'I/O Standard', 'Board Delay on Rise', 'Board Delay on Fall', 'Steady State Voh at FPGA Pin', 'Steady State Vol at FPGA Pin', 'Voh Max at FPGA Pin', 'Vol Min at FPGA Pin', 'Ringback Voltage on Rise at FPGA Pin', 'Ringback Voltage on Fall at FPGA Pin', '10-90 Rise Time at FPGA Pin', '90-10 Fall Time at FPGA Pin', 'Monotonic Rise at FPGA Pin', 'Monotonic Fall at FPGA Pin', 'Steady State Voh at Far-end', 'Steady State Vol at Far-end', 'Voh Max at Far-end', 'Vol Min at Far-end', 'Ringback Voltage on Rise at Far-end', 'Ringback Voltage on Fall at Far-end', '10-90 Rise Time at Far-end', '90-10 Fall Time at Far-end', 'Monotonic Rise at Far-end', 'Monotonic Fall at Far-end']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAAIOTSIMSIMF90M')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Fast 900mv 0c Model)',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Fast 900mv 0c Model)')
  panelname2name['TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Fast 900mv 0c Model)']='TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_'
  name2wsname['TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_']='TTAAIOTSIMSIMF90M'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MDROET')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Enable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Enable Times')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Output Enable Times']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times']='TTAF80MF80MDROET'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MDRCtOT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Clock to Output Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Clock to Output Times')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Clock to Output Times']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times']='TTAF80MF80MDRCtOT'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MDRMCtOT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Clock to Output Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Clock to Output Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Clock to Output Times']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times']='TTAS80MS80MDRMCtOT'


def Fitter__Resource_Section__GXB_Reports__Receiver_Channel (wb) :
  '''
  convert Fitter__Resource_Section__GXB_Reports__Receiver_Channel.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', '']
  INFILE=open('csv_files/Fitter__Resource_Section__GXB_Reports__Receiver_Channel.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSGRRC')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||GXB Reports||Receiver Channel',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||GXB Reports||Receiver Channel')
  panelname2name['Fitter||Resource Section||GXB Reports||Receiver Channel']='Fitter__Resource_Section__GXB_Reports__Receiver_Channel'
  name2wsname['Fitter__Resource_Section__GXB_Reports__Receiver_Channel']='FRSGRRC'


def Fitter__I_O_Rules_Section__I_O_Rules_Summary (wb) :
  '''
  convert Fitter__I_O_Rules_Section__I_O_Rules_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['I/O Rules Statistic', 'Total']
  INFILE=open('csv_files/Fitter__I_O_Rules_Section__I_O_Rules_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FIORSIORS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||I/O Rules Section||I/O Rules Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||I/O Rules Section||I/O Rules Summary')
  panelname2name['Fitter||I/O Rules Section||I/O Rules Summary']='Fitter__I_O_Rules_Section__I_O_Rules_Summary'
  name2wsname['Fitter__I_O_Rules_Section__I_O_Rules_Summary']='FIORSIORS'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MDRMOET')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Enable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Enable Times')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Enable Times']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times']='TTAF80MF80MDRMOET'


def Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Vendor', 'IP Core Name', 'Version', 'Release Date', 'License Type', 'Entity Instance', 'IP Include File']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASICS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis IP Cores Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis IP Cores Summary')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis IP Cores Summary']='Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary']='ASASICS'


def Fitter__Resource_Section__Fitter_Partition_Statistics (wb) :
  '''
  convert Fitter__Resource_Section__Fitter_Partition_Statistics.csv to xls
  '''
  a=[]
  s=[]
  headings=['Statistic', 'Top', 'hard_block:auto_generated_inst']
  INFILE=open('csv_files/Fitter__Resource_Section__Fitter_Partition_Statistics.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSFPS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Fitter Partition Statistics',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Fitter Partition Statistics')
  panelname2name['Fitter||Resource Section||Fitter Partition Statistics']='Fitter__Resource_Section__Fitter_Partition_Statistics'
  name2wsname['Fitter__Resource_Section__Fitter_Partition_Statistics']='FRSFPS'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MRS_1')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Recovery Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Recovery Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Recovery Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary']='TTAS80MS80MRS_1'


def Fitter__Resource_Section__Control_Signals (wb) :
  '''
  convert Fitter__Resource_Section__Control_Signals.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Location', 'Fan-Out', 'Usage', 'Global', 'Global Resource Used', 'Global Line Name', 'Enable Signal Source Name']
  INFILE=open('csv_files/Fitter__Resource_Section__Control_Signals.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSCS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Control Signals',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Control Signals')
  panelname2name['Fitter||Resource Section||Control Signals']='Fitter__Resource_Section__Control_Signals'
  name2wsname['Fitter__Resource_Section__Control_Signals']='FRSCS'


def Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations.csv to xls
  '''
  a=[]
  s=[]
  headings=['Register name', 'Reason for Removal', 'Registers Removed due to This Register']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASORRSRRTFRO')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Removed Registers Triggering Further Register Optimizations',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    if row == 65534:
      print "Error: row exceeds 65534"
      break
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Removed Registers Triggering Further Register Optimizations')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||Removed Registers Triggering Further Register Optimizations']='Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations']='ASASORRSRRTFRO'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MMPWS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Minimum Pulse Width Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Minimum Pulse Width Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Minimum Pulse Width Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary']='TTAS80MS80MMPWS'


def TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers.csv to xls
  '''
  a=[]
  s=[]
  headings=['From Clock', 'To Clock', 'RR Paths', 'FR Paths', 'RF Paths', 'FF Paths']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTACTRT_1')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Clock Transfers||Recovery Transfers',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Clock Transfers||Recovery Transfers')
  panelname2name['TimeQuest Timing Analyzer||Clock Transfers||Recovery Transfers']='TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers'
  name2wsname['TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers']='TTACTRT_1'


def Fitter__Resource_Section__Output_Pins (wb) :
  '''
  convert Fitter__Resource_Section__Output_Pins.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Pin #', 'I/O Bank', 'X coordinate', 'Y coordinate', 'Z coordinate', 'Output Register', 'Slew Rate', 'Open Drain', 'TRI Primitive', 'Bus Hold', 'Weak Pull Up', 'I/O Standard', 'Current Strength', 'Termination', 'Termination Control Block', 'Output Buffer Pre-emphasis', 'Voltage Output Differential', 'Output Buffer Delay', 'Output Buffer Delay Control', 'Location assigned by', 'Output Enable Source', 'Output Enable Group']
  INFILE=open('csv_files/Fitter__Resource_Section__Output_Pins.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSOP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Output Pins',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Output Pins')
  panelname2name['Fitter||Resource Section||Output Pins']='Fitter__Resource_Section__Output_Pins'
  name2wsname['Fitter__Resource_Section__Output_Pins']='FRSOP'


def TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_ (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin', 'I/O Standard', 'Board Delay on Rise', 'Board Delay on Fall', 'Steady State Voh at FPGA Pin', 'Steady State Vol at FPGA Pin', 'Voh Max at FPGA Pin', 'Vol Min at FPGA Pin', 'Ringback Voltage on Rise at FPGA Pin', 'Ringback Voltage on Fall at FPGA Pin', '10-90 Rise Time at FPGA Pin', '90-10 Fall Time at FPGA Pin', 'Monotonic Rise at FPGA Pin', 'Monotonic Fall at FPGA Pin', 'Steady State Voh at Far-end', 'Steady State Vol at Far-end', 'Voh Max at Far-end', 'Vol Min at Far-end', 'Ringback Voltage on Rise at Far-end', 'Ringback Voltage on Fall at Far-end', '10-90 Rise Time at Far-end', '90-10 Fall Time at Far-end', 'Monotonic Rise at Far-end', 'Monotonic Fall at Far-end']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAAIOTSIMSIMS98M')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)')
  panelname2name['TimeQuest Timing Analyzer||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)']='TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_'
  name2wsname['TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_']='TTAAIOTSIMSIMS98M'


def Analysis___Synthesis__Settings__Analysis___Synthesis_Settings (wb) :
  '''
  convert Analysis___Synthesis__Settings__Analysis___Synthesis_Settings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Option', 'Setting', 'Default Value']
  INFILE=open('csv_files/Analysis___Synthesis__Settings__Analysis___Synthesis_Settings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASSASS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Settings||Analysis & Synthesis Settings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Settings||Analysis & Synthesis Settings')
  panelname2name['Analysis & Synthesis||Settings||Analysis & Synthesis Settings']='Analysis___Synthesis__Settings__Analysis___Synthesis_Settings'
  name2wsname['Analysis___Synthesis__Settings__Analysis___Synthesis_Settings']='ASSASS'


def Flow_Non_Default_Global_Settings (wb) :
  '''
  convert Flow_Non_Default_Global_Settings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Assignment Name', 'Value', 'Default Value', 'Entity Name', 'Section Id']
  INFILE=open('csv_files/Flow_Non_Default_Global_Settings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FNDGS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Flow Non-Default Global Settings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Flow Non-Default Global Settings')
  panelname2name['Flow Non-Default Global Settings']='Flow_Non_Default_Global_Settings'
  name2wsname['Flow_Non_Default_Global_Settings']='FNDGS'


def TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAMDRSHT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Hold Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Hold Times')
  panelname2name['TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Hold Times']='TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times']='TTAMDRSHT'


def Restore_Archived_Project__Files_Not_Restored (wb) :
  '''
  convert Restore_Archived_Project__Files_Not_Restored.csv to xls
  '''
  a=[]
  s=[]
  headings=['File Name']
  INFILE=open('csv_files/Restore_Archived_Project__Files_Not_Restored.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('RAPFNR')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Restore Archived Project||Files Not Restored',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Restore Archived Project||Files Not Restored')
  panelname2name['Restore Archived Project||Files Not Restored']='Restore_Archived_Project__Files_Not_Restored'
  name2wsname['Restore_Archived_Project__Files_Not_Restored']='RAPFNR'


def TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_ (wb) :
  '''
  convert TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin', 'I/O Standard', 'Board Delay on Rise', 'Board Delay on Fall', 'Steady State Voh at FPGA Pin', 'Steady State Vol at FPGA Pin', 'Voh Max at FPGA Pin', 'Vol Min at FPGA Pin', 'Ringback Voltage on Rise at FPGA Pin', 'Ringback Voltage on Fall at FPGA Pin', '10-90 Rise Time at FPGA Pin', '90-10 Fall Time at FPGA Pin', 'Monotonic Rise at FPGA Pin', 'Monotonic Fall at FPGA Pin', 'Steady State Voh at Far-end', 'Steady State Vol at Far-end', 'Voh Max at Far-end', 'Vol Min at Far-end', 'Ringback Voltage on Rise at Far-end', 'Ringback Voltage on Fall at Far-end', '10-90 Rise Time at Far-end', '90-10 Fall Time at Far-end', 'Monotonic Rise at Far-end', 'Monotonic Fall at Far-end']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAGAIOTSIMSIMS98M')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)')
  panelname2name['TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Signal Integrity Metrics||Signal Integrity Metrics (Slow 900mv 85c Model)']='TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_'
  name2wsname['TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_']='TTAGAIOTSIMSIMS98M'


def Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read.csv to xls
  '''
  a=[]
  s=[]
  headings=['File Name with User-Entered Path', 'Used in Netlist', 'File Type', 'File Name with Absolute Path', 'Library']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASSFR')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Source Files Read',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Source Files Read')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Source Files Read']='Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read']='ASASSFR'


def Flow_OS_Summary (wb) :
  '''
  convert Flow_OS_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Module Name', 'Machine Hostname', 'OS Name', 'OS Version', 'Processor type']
  INFILE=open('csv_files/Flow_OS_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FOS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Flow OS Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Flow OS Summary')
  panelname2name['Flow OS Summary']='Flow_OS_Summary'
  name2wsname['Flow_OS_Summary']='FOS'


def Fitter__Parallel_Compilation (wb) :
  '''
  convert Fitter__Parallel_Compilation.csv to xls
  '''
  a=[]
  s=[]
  headings=['Processors', 'Number']
  INFILE=open('csv_files/Fitter__Parallel_Compilation.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FPC')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Parallel Compilation',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Parallel Compilation')
  panelname2name['Fitter||Parallel Compilation']='Fitter__Parallel_Compilation'
  name2wsname['Fitter__Parallel_Compilation']='FPC'


def Fitter__I_O_Rules_Section__I_O_Rules_Details (wb) :
  '''
  convert Fitter__I_O_Rules_Section__I_O_Rules_Details.csv to xls
  '''
  a=[]
  s=[]
  headings=['Status', 'ID', 'Category', 'Rule Description', 'Severity', 'Information', 'Area', 'Extra Information']
  INFILE=open('csv_files/Fitter__I_O_Rules_Section__I_O_Rules_Details.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FIORSIORD')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||I/O Rules Section||I/O Rules Details',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||I/O Rules Section||I/O Rules Details')
  panelname2name['Fitter||I/O Rules Section||I/O Rules Details']='Fitter__I_O_Rules_Section__I_O_Rules_Details'
  name2wsname['Fitter__I_O_Rules_Section__I_O_Rules_Details']='FIORSIORD'


def Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary (wb) :
  '''
  convert Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Type', 'Value']
  INFILE=open('csv_files/Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FFICSICPS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Fitter Incremental Compilation Section||Incremental Compilation Preservation Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Fitter Incremental Compilation Section||Incremental Compilation Preservation Summary')
  panelname2name['Fitter||Fitter Incremental Compilation Section||Incremental Compilation Preservation Summary']='Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary'
  name2wsname['Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary']='FFICSICPS'


def Analysis___Synthesis__Analysis___Synthesis_Summary (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Analysis & Synthesis Status', 'Successful - Tue May 21 20:45:23 2013']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Summary')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Summary']='Analysis___Synthesis__Analysis___Synthesis_Summary'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Summary']='ASASS'


def TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Quartus II Version', 'Version 12.1 Build 177 11/07/2012 SJ Full Version']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAGTTAS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer GUI||TimeQuest Timing Analyzer Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer GUI||TimeQuest Timing Analyzer Summary')
  panelname2name['TimeQuest Timing Analyzer GUI||TimeQuest Timing Analyzer Summary']='TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary'
  name2wsname['TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary']='TTAGTTAS'


def Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions.csv to xls
  '''
  a=[]
  s=[]
  headings=['Register Name', 'Megafunction', 'Type']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASORRPIIM')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Optimization Results||Registers Packed Into Inferred Megafunctions',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Optimization Results||Registers Packed Into Inferred Megafunctions')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Optimization Results||Registers Packed Into Inferred Megafunctions']='Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions']='ASASORRPIIM'


def Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals (wb) :
  '''
  convert Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Fan-Out']
  INFILE=open('csv_files/Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSNGHFOS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Non-Global High Fan-Out Signals',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Non-Global High Fan-Out Signals')
  panelname2name['Fitter||Resource Section||Non-Global High Fan-Out Signals']='Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals'
  name2wsname['Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals']='FRSNGHFOS'


def TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAMDRSST')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Setup Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Setup Times')
  panelname2name['TimeQuest Timing Analyzer||Multicorner Datasheet Report Summary||Setup Times']='TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times']='TTAMDRSST'


def Fitter__Fitter_Settings (wb) :
  '''
  convert Fitter__Fitter_Settings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Option', 'Setting', 'Default Value']
  INFILE=open('csv_files/Fitter__Fitter_Settings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FFS_1')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Fitter Settings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Fitter Settings')
  panelname2name['Fitter||Fitter Settings']='Fitter__Fitter_Settings'
  name2wsname['Fitter__Fitter_Settings']='FFS_1'


def Non_Default_Global_Settings (wb) :
  '''
  convert Non_Default_Global_Settings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Assignment', 'Default Value', 'Design Value']
  INFILE=open('csv_files/Non_Default_Global_Settings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('NDGS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Non-Default Global Settings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Non-Default Global Settings')
  panelname2name['Non-Default Global Settings']='Non_Default_Global_Settings'
  name2wsname['Non_Default_Global_Settings']='NDGS'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Fmax', 'Restricted Fmax', 'Clock Name', 'Note']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MFS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Fmax Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Fmax Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Fmax Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary']='TTAS80MS80MFS'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MDRST')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Setup Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Setup Times')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Setup Times']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times']='TTAF80MF80MDRST'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MHS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Hold Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Hold Summary')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Hold Summary']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary']='TTAS80MS80MHS'


def Assembler__Assembler_Generated_Files (wb) :
  '''
  convert Assembler__Assembler_Generated_Files.csv to xls
  '''
  a=[]
  s=[]
  headings=['File Name                ']
  INFILE=open('csv_files/Assembler__Assembler_Generated_Files.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('AAGF')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Assembler||Assembler Generated Files',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Assembler||Assembler Generated Files')
  panelname2name['Assembler||Assembler Generated Files']='Assembler__Assembler_Generated_Files'
  name2wsname['Assembler__Assembler_Generated_Files']='AAGF'


def TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers.csv to xls
  '''
  a=[]
  s=[]
  headings=['From Clock', 'To Clock', 'RR Paths', 'FR Paths', 'RF Paths', 'FF Paths']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTACTHT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Clock Transfers||Hold Transfers',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Clock Transfers||Hold Transfers')
  panelname2name['TimeQuest Timing Analyzer||Clock Transfers||Hold Transfers']='TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers'
  name2wsname['TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers']='TTACTHT'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Source Node', 'Synchronization Node', 'Worst-Case MTBF (Years)', 'Typical MTBF (Years)', 'Included in Design MTBF']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MMRSS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Metastability Report||Synchronizer Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Metastability Report||Synchronizer Summary')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Metastability Report||Synchronizer Summary']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary']='TTAF80MF80MMRSS'


def TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin', 'I/O Standard', '10-90 Rise Time', '90-10 Fall Time']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAGAIOTITT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Input Transition Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Input Transition Times')
  panelname2name['TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Input Transition Times']='TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times'
  name2wsname['TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times']='TTAGAIOTITT'


def Fitter__Fitter_Netlist_Optimizations (wb) :
  '''
  convert Fitter__Fitter_Netlist_Optimizations.csv to xls
  '''
  a=[]
  s=[]
  headings=['Node', 'Action', 'Operation', 'Reason', 'Node Port', 'Node Port Name', 'Destination Node', 'Destination Port', 'Destination Port Name']
  INFILE=open('csv_files/Fitter__Fitter_Netlist_Optimizations.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FFNO')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Fitter Netlist Optimizations',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Fitter Netlist Optimizations')
  panelname2name['Fitter||Fitter Netlist Optimizations']='Fitter__Fitter_Netlist_Optimizations'
  name2wsname['Fitter__Fitter_Netlist_Optimizations']='FFNO'


def Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics.csv to xls
  '''
  a=[]
  s=[]
  headings=['Statistic', 'Value']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASORRSGRS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||General Register Statistics',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||General Register Statistics')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Optimization Results||Register Statistics||General Register Statistics']='Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics']='ASASORRSGRS'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MHS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Hold Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Hold Summary')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Hold Summary']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary']='TTAF80MF80MHS'


def Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_ (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_.csv to xls
  '''
  a=[]
  s=[]
  headings=['Multiplexer Inputs', 'Bus Width', 'Baseline Area', 'Area if Restructured', 'Saving if Restructured', 'Registered', 'Example Multiplexer Output']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASORMSMRSRP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Optimization Results||Multiplexer Statistics||Multiplexer Restructuring Statistics (Restructuring Performed)',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Optimization Results||Multiplexer Statistics||Multiplexer Restructuring Statistics (Restructuring Performed)')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Optimization Results||Multiplexer Statistics||Multiplexer Restructuring Statistics (Restructuring Performed)']='Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_']='ASASORMSMRSRP'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MDRCtOT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Clock to Output Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Clock to Output Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Clock to Output Times']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times']='TTAS88MS88MDRCtOT'


def Fitter__Resource_Section__GXB_Reports__Transmitter_Channel (wb) :
  '''
  convert Fitter__Resource_Section__GXB_Reports__Transmitter_Channel.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', '']
  INFILE=open('csv_files/Fitter__Resource_Section__GXB_Reports__Transmitter_Channel.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSGRTC')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||GXB Reports||Transmitter Channel',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||GXB Reports||Transmitter Channel')
  panelname2name['Fitter||Resource Section||GXB Reports||Transmitter Channel']='Fitter__Resource_Section__GXB_Reports__Transmitter_Channel'
  name2wsname['Fitter__Resource_Section__GXB_Reports__Transmitter_Channel']='FRSGRTC'


def TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments (wb) :
  '''
  convert TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin', 'I/O Standard', 'Near Tline Length', 'Near Tline L per Length', 'Near Tline C per Length', 'Near Series R', 'Near Differential R', 'Near Pull-up R', 'Near Pull-down R', 'Near C', 'Far Tline Length', 'Far Tline L per Length', 'Far Tline C per Length', 'Far Series R', 'Far Pull-up R', 'Far Pull-down R', 'Far C', 'Termination Voltage', 'Far Differential R', 'EBD File Name', 'EBD Signal Name', 'EBD Far-end']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAGAIOTBTMA')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Board Trace Model Assignments',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Board Trace Model Assignments')
  panelname2name['TimeQuest Timing Analyzer GUI||Advanced I/O Timing||Board Trace Model Assignments']='TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments'
  name2wsname['TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments']='TTAGAIOTBTMA'


def Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity.csv to xls
  '''
  a=[]
  s=[]
  headings=['Compilation Hierarchy Node', 'LC Combinationals', 'LC Registers', 'Block Memory Bits', 'DSP Blocks', 'Pins', 'Virtual Pins', 'Full Hierarchy Name', 'Library Name']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASRUbE')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis Resource Utilization by Entity',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis Resource Utilization by Entity')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis Resource Utilization by Entity']='Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity']='ASASRUbE'


def Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout (wb) :
  '''
  convert Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout.csv to xls
  '''
  a=[]
  s=[]
  headings=['Source Pin / Fanout', 'Pad To Core Index', 'Setting']
  INFILE=open('csv_files/Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSPTCDCF')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Pad To Core Delay Chain Fanout',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Pad To Core Delay Chain Fanout')
  panelname2name['Fitter||Resource Section||Pad To Core Delay Chain Fanout']='Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout'
  name2wsname['Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout']='FRSPTCDCF'


def Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings (wb) :
  '''
  convert Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings.csv to xls
  '''
  a=[]
  s=[]
  headings=['Partition Name', 'Partition Type', 'Netlist Type Used', 'Preservation Level Used', 'Netlist Type Requested', 'Preservation Level Requested', 'Contents']
  INFILE=open('csv_files/Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FFICSICPS_1')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Fitter Incremental Compilation Section||Incremental Compilation Partition Settings',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Fitter Incremental Compilation Section||Incremental Compilation Partition Settings')
  panelname2name['Fitter||Fitter Incremental Compilation Section||Incremental Compilation Partition Settings']='Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings'
  name2wsname['Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings']='FFICSICPS_1'


def Fitter__Resource_Section__Fitter_Resource_Usage_Summary (wb) :
  '''
  convert Fitter__Resource_Section__Fitter_Resource_Usage_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Resource', 'Usage', '%']
  INFILE=open('csv_files/Fitter__Resource_Section__Fitter_Resource_Usage_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSFRUS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Fitter Resource Usage Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Fitter Resource Usage Summary')
  panelname2name['Fitter||Resource Section||Fitter Resource Usage Summary']='Fitter__Resource_Section__Fitter_Resource_Usage_Summary'
  name2wsname['Fitter__Resource_Section__Fitter_Resource_Usage_Summary']='FRSFRUS'


def Analysis___Synthesis__Analysis___Synthesis_RAM_Summary (wb) :
  '''
  convert Analysis___Synthesis__Analysis___Synthesis_RAM_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Type', 'Mode', 'Port A Depth', 'Port A Width', 'Port B Depth', 'Port B Width', 'Size', 'MIF']
  INFILE=open('csv_files/Analysis___Synthesis__Analysis___Synthesis_RAM_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASASRS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Analysis & Synthesis RAM Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Analysis & Synthesis RAM Summary')
  panelname2name['Analysis & Synthesis||Analysis & Synthesis RAM Summary']='Analysis___Synthesis__Analysis___Synthesis_RAM_Summary'
  name2wsname['Analysis___Synthesis__Analysis___Synthesis_RAM_Summary']='ASASRS'


def Fitter__Resource_Section__Input_Pins (wb) :
  '''
  convert Fitter__Resource_Section__Input_Pins.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Pin #', 'I/O Bank', 'X coordinate', 'Y coordinate', 'Z coordinate', 'Combinational Fan-Out', 'Registered Fan-Out', 'Global', 'Bus Hold', 'Weak Pull Up', 'I/O Standard', 'Termination', 'Termination Control Block', 'Location assigned by']
  INFILE=open('csv_files/Fitter__Resource_Section__Input_Pins.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSIP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Input Pins',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Input Pins')
  panelname2name['Fitter||Resource Section||Input Pins']='Fitter__Resource_Section__Input_Pins'
  name2wsname['Fitter__Resource_Section__Input_Pins']='FRSIP'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MDRMOET')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Enable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Enable Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Minimum Output Enable Times']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times']='TTAS80MS80MDRMOET'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MDRHT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Hold Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Hold Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Hold Times']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times']='TTAS88MS88MDRHT'


def Analysis___Synthesis__Parallel_Compilation (wb) :
  '''
  convert Analysis___Synthesis__Parallel_Compilation.csv to xls
  '''
  a=[]
  s=[]
  headings=['Processors', 'Number']
  INFILE=open('csv_files/Analysis___Synthesis__Parallel_Compilation.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASPC')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Parallel Compilation',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Parallel Compilation')
  panelname2name['Analysis & Synthesis||Parallel Compilation']='Analysis___Synthesis__Parallel_Compilation'
  name2wsname['Analysis___Synthesis__Parallel_Compilation']='ASPC'


def Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements (wb) :
  '''
  convert Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements.csv to xls
  '''
  a=[]
  s=[]
  headings=['Preserved Component', 'Removed Component']
  INFILE=open('csv_files/Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSGROGE')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||GXB Reports||Optimized GXB Elements',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||GXB Reports||Optimized GXB Elements')
  panelname2name['Fitter||Resource Section||GXB Reports||Optimized GXB Elements']='Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements'
  name2wsname['Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements']='FRSGROGE'


def Fitter__Resource_Section__Global___Other_Fast_Signals (wb) :
  '''
  convert Fitter__Resource_Section__Global___Other_Fast_Signals.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Location', 'Fan-Out', 'Global Resource Used', 'Global Line Name', 'Enable Signal Source Name']
  INFILE=open('csv_files/Fitter__Resource_Section__Global___Other_Fast_Signals.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSGOFS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Global & Other Fast Signals',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Global & Other Fast Signals')
  panelname2name['Fitter||Resource Section||Global & Other Fast Signals']='Fitter__Resource_Section__Global___Other_Fast_Signals'
  name2wsname['Fitter__Resource_Section__Global___Other_Fast_Signals']='FRSGOFS'


def TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', 'Rise', 'Fall', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS80MS80MDROET')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Enable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Enable Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 0C Model||Slow 850mV 0C Model Datasheet Report||Output Enable Times']='TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times']='TTAS80MS80MDROET'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Clock', 'Slack', 'End Point TNS']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MRS_1')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Recovery Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Recovery Summary')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Recovery Summary']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary']='TTAF80MF80MRS_1'


def Analysis___Synthesis__Elapsed_Time_Per_Partition (wb) :
  '''
  convert Analysis___Synthesis__Elapsed_Time_Per_Partition.csv to xls
  '''
  a=[]
  s=[]
  headings=['Partition Name', 'Elapsed Time']
  INFILE=open('csv_files/Analysis___Synthesis__Elapsed_Time_Per_Partition.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('ASETPP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Analysis & Synthesis||Elapsed Time Per Partition',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Analysis & Synthesis||Elapsed Time Per Partition')
  panelname2name['Analysis & Synthesis||Elapsed Time Per Partition']='Analysis___Synthesis__Elapsed_Time_Per_Partition'
  name2wsname['Analysis___Synthesis__Elapsed_Time_Per_Partition']='ASETPP'


def Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary (wb) :
  '''
  convert Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Other Routing Resource Type', 'Usage']
  INFILE=open('csv_files/Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSLaRSORUS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Logic and Routing Section||Other Routing Usage Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Logic and Routing Section||Other Routing Usage Summary')
  panelname2name['Fitter||Resource Section||Logic and Routing Section||Other Routing Usage Summary']='Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary'
  name2wsname['Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary']='FRSLaRSORUS'


def TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', '0 to Hi-Z', '1 to Hi-Z', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAF80MF80MDRMODT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Disable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Disable Times')
  panelname2name['TimeQuest Timing Analyzer||Fast 850mV 0C Model||Fast 850mV 0C Model Datasheet Report||Minimum Output Disable Times']='TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times']='TTAF80MF80MDRMODT'


def Fitter__Operating_Settings_and_Conditions (wb) :
  '''
  convert Fitter__Operating_Settings_and_Conditions.csv to xls
  '''
  a=[]
  s=[]
  headings=['Setting', 'Value']
  INFILE=open('csv_files/Fitter__Operating_Settings_and_Conditions.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FOSaC')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Operating Settings and Conditions',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Operating Settings and Conditions')
  panelname2name['Fitter||Operating Settings and Conditions']='Fitter__Operating_Settings_and_Conditions'
  name2wsname['Fitter__Operating_Settings_and_Conditions']='FOSaC'


def Fitter__Resource_Section__All_Package_Pins (wb) :
  '''
  convert Fitter__Resource_Section__All_Package_Pins.csv to xls
  '''
  a=[]
  s=[]
  headings=['Location', 'Pad Number', 'I/O Bank', 'Pin Name/Usage', 'Dir.', 'I/O Standard', 'Voltage', 'I/O Type', 'User Assignment', 'Bus Hold', 'Weak Pull Up']
  INFILE=open('csv_files/Fitter__Resource_Section__All_Package_Pins.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSAPP')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||All Package Pins',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||All Package Pins')
  panelname2name['Fitter||Resource Section||All Package Pins']='Fitter__Resource_Section__All_Package_Pins'
  name2wsname['Fitter__Resource_Section__All_Package_Pins']='FRSAPP'


def TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times (wb) :
  '''
  convert TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times.csv to xls
  '''
  a=[]
  s=[]
  headings=['Data Port', 'Clock Port', '0 to Hi-Z', '1 to Hi-Z', 'Clock Edge', 'Clock Reference']
  INFILE=open('csv_files/TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('TTAS88MS88MDRODT')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Disable Times',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Disable Times')
  panelname2name['TimeQuest Timing Analyzer||Slow 850mV 85C Model||Slow 850mV 85C Model Datasheet Report||Output Disable Times']='TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times'
  name2wsname['TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times']='TTAS88MS88MDRODT'


def Fitter__Resource_Section__I_O_Bank_Usage (wb) :
  '''
  convert Fitter__Resource_Section__I_O_Bank_Usage.csv to xls
  '''
  a=[]
  s=[]
  headings=['I/O Bank', 'Usage', 'VCCIO Voltage', 'VREF Voltage', 'VCCPD Voltage']
  INFILE=open('csv_files/Fitter__Resource_Section__I_O_Bank_Usage.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSIOBU')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||I/O Bank Usage',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||I/O Bank Usage')
  panelname2name['Fitter||Resource Section||I/O Bank Usage']='Fitter__Resource_Section__I_O_Bank_Usage'
  name2wsname['Fitter__Resource_Section__I_O_Bank_Usage']='FRSIOBU'


def Fitter__I_O_Rules_Section__I_O_Rules_Matrix (wb) :
  '''
  convert Fitter__I_O_Rules_Section__I_O_Rules_Matrix.csv to xls
  '''
  a=[]
  s=[]
  headings=['Pin/Rules', 'IO_000001', 'IO_000002', 'IO_000003', 'IO_000004', 'IO_000005', 'IO_000006', 'IO_000007', 'IO_000008', 'IO_000009', 'IO_000010', 'IO_000011', 'IO_000012', 'IO_000013', 'IO_000014', 'IO_000015', 'IO_000018', 'IO_000019', 'IO_000020', 'IO_000021', 'IO_000022', 'IO_000023', 'IO_000024', 'IO_000026', 'IO_000027', 'IO_000045', 'IO_000046', 'IO_000047', 'IO_000034']
  INFILE=open('csv_files/Fitter__I_O_Rules_Section__I_O_Rules_Matrix.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FIORSIORM')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||I/O Rules Section||I/O Rules Matrix',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||I/O Rules Section||I/O Rules Matrix')
  panelname2name['Fitter||I/O Rules Section||I/O Rules Matrix']='Fitter__I_O_Rules_Section__I_O_Rules_Matrix'
  name2wsname['Fitter__I_O_Rules_Section__I_O_Rules_Matrix']='FIORSIORM'


def Fitter__Resource_Section__Fitter_RAM_Summary (wb) :
  '''
  convert Fitter__Resource_Section__Fitter_RAM_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Name', 'Type', 'Mode', 'Clock Mode', 'Port A Depth', 'Port A Width', 'Port B Depth', 'Port B Width', 'Port A Input Registers', 'Port A Output Registers', 'Port B Input Registers', 'Port B Output Registers', 'Size', 'Implementation Port A Depth', 'Implementation Port A Width', 'Implementation Port B Depth', 'Implementation Port B Width', 'Implementation Bits', 'M20K blocks', 'MLAB cells', 'MIF', 'Location']
  INFILE=open('csv_files/Fitter__Resource_Section__Fitter_RAM_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSFRS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Fitter RAM Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Fitter RAM Summary')
  panelname2name['Fitter||Resource Section||Fitter RAM Summary']='Fitter__Resource_Section__Fitter_RAM_Summary'
  name2wsname['Fitter__Resource_Section__Fitter_RAM_Summary']='FRSFRS'


def Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary (wb) :
  '''
  convert Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary.csv to xls
  '''
  a=[]
  s=[]
  headings=['Interconnect Resource Type', 'Usage']
  INFILE=open('csv_files/Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary.csv','r')
  lines=INFILE.readlines()
  if len(lines)==0: return -1
  hs=lines[0].strip().split(',')
  #print hs
  for f in hs:
    a.append([])
    s.append(len(f))
  
  for line in lines:
    fs=line.strip().split(',')
    for i,f in enumerate(fs):
      if f in clk2abrev.keys():
        f=clk2abrev[f]
      if i < len(hs):
        a[i].append(f)
      if i < len(hs):
        if len(f) > s[i]: s[i]=len(f)
  ws=wb.add_sheet('FRSLaRSIUS')
  rtn_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x6;' "borders: top thin, bottom thin, right thin;")
  bold_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for i in range(len(hs)):
    if s[i]*256 > 65535-256*2:
      ws.col(i).width=65535
    else:
      ws.col(i).width=(s[i]+2)*256

  ws.write(0,0,'Fitter||Resource Section||Logic and Routing Section||Interconnect Usage Summary',bold_style_white)
  f='HYPERLINK("#Summary!A1","Return to Summary")'
  ws.write(0,1,xlwt.Formula(f),rtn_style)
  for row,line in enumerate(lines):
    fs=line.strip().split(',')
    for col,f in enumerate(fs):
      if row == 0:
        ws.write(row+1,col,f,hdr_style)
      elif row % 2:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_white)
        else:
          ws.write(row+1,col,f,cell_style_white)
      else:
        if f in clk2abrev.keys():
          f=clk2abrev[f]
          ws.write(row+1,col,f,cell_style_grey)
        else:
          ws.write(row+1,col,f,cell_style_grey)
  panelnames.append('Fitter||Resource Section||Logic and Routing Section||Interconnect Usage Summary')
  panelname2name['Fitter||Resource Section||Logic and Routing Section||Interconnect Usage Summary']='Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary'
  name2wsname['Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary']='FRSLaRSIUS'


def csv2xls (file) :
  wb=xlwt.Workbook()
  ws=wb.add_sheet("Summary")
  xr=wb.add_sheet("CrossRef")
  xr.col(0).width=20*256
  xr.col(1).width=65535
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_grey = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  for row,fullname in enumerate(sorted(clk2abrev)):
    abrevname=clk2abrev[fullname]
    if row % 2:
      xr.write(row,0,abrevname,cell_style_white)
      xr.write(row,1,fullname,cell_style_white)
    else:
      xr.write(row,0,abrevname,cell_style_grey)
      xr.write(row,1,fullname,cell_style_grey)
    
  TimeQuest_Timing_Analyzer__Unconstrained_Paths(wb)
  Flow_Elapsed_Time(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Disable_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Metastability_Report__Synchronizer_Summary(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Setup_Summary(wb)
  Fitter__Resource_Section__GXB_Reports__Transceiver_Reconfiguration_Report(wb)
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Inverted_Register_Statistics(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Setup_Summary(wb)
  TimeQuest_Timing_Analyzer__TimeQuest_Timing_Analyzer_Summary(wb)
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Input_Transition_Times(wb)
  Assembler__Assembler_Settings(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Setup_Summary(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Hold_Summary(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Output_Enable_Times(wb)
  Assembler__Assembler_Device_Options____dse_temp_rev_sof(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Disable_Times(wb)
  Analysis___Synthesis__Analysis___Synthesis_Resource_Usage_Summary(wb)
  TimeQuest_Timing_Analyzer__Multicorner_Timing_Analysis_Summary(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Minimum_Pulse_Width_Summary(wb)
  TimeQuest_Timing_Analyzer_GUI__SDC_File_List(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Minimum_Pulse_Width_Summary(wb)
  Flow_Settings(wb)
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Board_Trace_Model_Assignments(wb)
  Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Placement_Preservation(wb)
  Restore_Archived_Project__Files_Restored(wb)
  TimeQuest_Timing_Analyzer__SDC_File_List(wb)
  Assembler__Assembler_Encrypted_IP_Cores_Summary(wb)
  Fitter__Fitter_Summary(wb)
  Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Details(wb)
  Analysis___Synthesis__Settings__Analysis___Synthesis_Default_Parameter_Settings(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Hold_Times(wb)
  Fitter__Ignored_Assignments(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Recovery_Summary(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Setup_Times(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Removal_Summary(wb)
  TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Clock_to_Output_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times(wb)
  Fitter__Resource_Section__PLL_Usage_Summary(wb)
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Protected_by_Synthesis(wb)
  Fitter__Estimated_Delay_Added_for_Hold_Timing__Estimated_Delay_Added_for_Hold_Timing_Summary(wb)
  TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Minimum_Clock_to_Output_Times(wb)
  Flow_Summary(wb)
  Fitter__Resource_Section__GXB_Reports__Transmitter_PLL(wb)
  Fitter__Fitter_Device_Options(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Enable_Times(wb)
  Restore_Archived_Project__Restore_Archived_Project_Summary(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Disable_Times(wb)
  Fitter__Resource_Section__Bidir_Pins(wb)
  TimeQuest_Timing_Analyzer__Clock_Transfers__Removal_Transfers(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Fmax_Summary(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Removal_Summary(wb)
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Registers_Removed_During_Synthesis(wb)
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_0c_Model_(wb)
  Fitter__Resource_Section__Delay_Chain_Summary(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Hold_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Setup_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times(wb)
  Fitter__Resource_Section__Fitter_Resource_Utilization_by_Entity(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Metastability_Report__Synchronizer_Summary(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Removal_Summary(wb)
  Assembler__Assembler_Summary(wb)
  TimeQuest_Timing_Analyzer__Clocks(wb)
  TimeQuest_Timing_Analyzer__Parallel_Compilation(wb)
  TimeQuest_Timing_Analyzer__Clock_Transfers__Setup_Transfers(wb)
  Fitter__I_O_Assignment_Warnings(wb)
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Fast_900mv_0c_Model_(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Output_Enable_Times(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Clock_to_Output_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Clock_to_Output_Times(wb)
  Fitter__Resource_Section__GXB_Reports__Receiver_Channel(wb)
  Fitter__I_O_Rules_Section__I_O_Rules_Summary(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times(wb)
  Analysis___Synthesis__Analysis___Synthesis_IP_Cores_Summary(wb)
  Fitter__Resource_Section__Fitter_Partition_Statistics(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Recovery_Summary(wb)
  Fitter__Resource_Section__Control_Signals(wb)
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__Removed_Registers_Triggering_Further_Register_Optimizations(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Minimum_Pulse_Width_Summary(wb)
  TimeQuest_Timing_Analyzer__Clock_Transfers__Recovery_Transfers(wb)
  Fitter__Resource_Section__Output_Pins(wb)
  TimeQuest_Timing_Analyzer__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_(wb)
  Analysis___Synthesis__Settings__Analysis___Synthesis_Settings(wb)
  Flow_Non_Default_Global_Settings(wb)
  TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Hold_Times(wb)
  Restore_Archived_Project__Files_Not_Restored(wb)
  TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Signal_Integrity_Metrics__Signal_Integrity_Metrics__Slow_900mv_85c_Model_(wb)
  Analysis___Synthesis__Analysis___Synthesis_Source_Files_Read(wb)
  Flow_OS_Summary(wb)
  Fitter__Parallel_Compilation(wb)
  Fitter__I_O_Rules_Section__I_O_Rules_Details(wb)
  Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Preservation_Summary(wb)
  Analysis___Synthesis__Analysis___Synthesis_Summary(wb)
  TimeQuest_Timing_Analyzer_GUI__TimeQuest_Timing_Analyzer_Summary(wb)
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Registers_Packed_Into_Inferred_Megafunctions(wb)
  Fitter__Resource_Section__Non_Global_High_Fan_Out_Signals(wb)
  TimeQuest_Timing_Analyzer__Multicorner_Datasheet_Report_Summary__Setup_Times(wb)
  Fitter__Fitter_Settings(wb)
  Non_Default_Global_Settings(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Fmax_Summary(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Setup_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Hold_Summary(wb)
  Assembler__Assembler_Generated_Files(wb)
  TimeQuest_Timing_Analyzer__Clock_Transfers__Hold_Transfers(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Metastability_Report__Synchronizer_Summary(wb)
  TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Input_Transition_Times(wb)
  Fitter__Fitter_Netlist_Optimizations(wb)
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Register_Statistics__General_Register_Statistics(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Hold_Summary(wb)
  Analysis___Synthesis__Analysis___Synthesis_Optimization_Results__Multiplexer_Statistics__Multiplexer_Restructuring_Statistics__Restructuring_Performed_(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Clock_to_Output_Times(wb)
  Fitter__Resource_Section__GXB_Reports__Transmitter_Channel(wb)
  TimeQuest_Timing_Analyzer_GUI__Advanced_I_O_Timing__Board_Trace_Model_Assignments(wb)
  Analysis___Synthesis__Analysis___Synthesis_Resource_Utilization_by_Entity(wb)
  Fitter__Resource_Section__Pad_To_Core_Delay_Chain_Fanout(wb)
  Fitter__Fitter_Incremental_Compilation_Section__Incremental_Compilation_Partition_Settings(wb)
  Fitter__Resource_Section__Fitter_Resource_Usage_Summary(wb)
  Analysis___Synthesis__Analysis___Synthesis_RAM_Summary(wb)
  Fitter__Resource_Section__Input_Pins(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Minimum_Output_Enable_Times(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Hold_Times(wb)
  Analysis___Synthesis__Parallel_Compilation(wb)
  Fitter__Resource_Section__GXB_Reports__Optimized_GXB_Elements(wb)
  Fitter__Resource_Section__Global___Other_Fast_Signals(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_0C_Model__Slow_850mV_0C_Model_Datasheet_Report__Output_Enable_Times(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Recovery_Summary(wb)
  Analysis___Synthesis__Elapsed_Time_Per_Partition(wb)
  Fitter__Resource_Section__Logic_and_Routing_Section__Other_Routing_Usage_Summary(wb)
  TimeQuest_Timing_Analyzer__Fast_850mV_0C_Model__Fast_850mV_0C_Model_Datasheet_Report__Minimum_Output_Disable_Times(wb)
  Fitter__Operating_Settings_and_Conditions(wb)
  Fitter__Resource_Section__All_Package_Pins(wb)
  TimeQuest_Timing_Analyzer__Slow_850mV_85C_Model__Slow_850mV_85C_Model_Datasheet_Report__Output_Disable_Times(wb)
  Fitter__Resource_Section__I_O_Bank_Usage(wb)
  Fitter__I_O_Rules_Section__I_O_Rules_Matrix(wb)
  Fitter__Resource_Section__Fitter_RAM_Summary(wb)
  Fitter__Resource_Section__Logic_and_Routing_Section__Interconnect_Usage_Summary(wb)
  ws.col(0).width=65535
  for row,panelname in enumerate(sorted(panelnames)):
    name=panelname2name[panelname]
    wsname=name2wsname[name]
    f='HYPERLINK("#%s!A1","%s")' % (wsname,panelname)
    if row % 2:
      ws.write(row,0,xlwt.Formula(f),cell_style_white)
    else:
      ws.write(row,0,xlwt.Formula(f),cell_style_grey)
  wb.save(file)


def help():
  print '''
report2xls.py <spreadsheet file> <tcl script> <project name>

  spreadsheet file: quartus report in xls format
  tcl script: quartusrpt.tcl
  project name: quartus project name
 
  ex: ../../../../../common/vi_scripts/report2xls.py report.xls ../../../../../common/vi_scripts/quartusrpt.tcl fcoe10g_top

'''
if __name__ == '__main__':
  
  import sys
  import os
  argc=len(sys.argv)
  libdir = os.path.dirname(os.path.realpath(__file__)) + "/lib"
  sys.path.append(libdir)  # for lib/xlwt module
  import xlwt
  if argc >1: xls =sys.argv[1]
  if argc >2: tcl =sys.argv[2]
  if argc >3: qpf =sys.argv[3]
  if argc == 4:
    os.system('quartus_sta -t %s %s'%(tcl,qpf))
    csv2xls(xls)
  elif argc == 1:
    help()
  else:
    csv2xls(xls)
