#!/usr/bin/env python2
import xml.dom.minidom
import xlwt
from pprint import pprint
seed=0
summary={}
clks=[]
typs=[] # [u'Clock Setup', u'Clock Hold', u'Clock Recovery', u'Clock Removal']
conds=[] # [u'Fmax', u'Worst-case Slack', u'Per-clock Edge TNS', u'Actual Time', u'Per-clock Keeper TNS', u'Restricted Fmax']

clk2setup={}
clk2hold={}
clk2recov={}
clk2remov={}

clk2abrev={
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[0].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk0',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[1].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk1',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[2].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk2',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[3].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk3',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[4].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk4',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[5].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk5',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[6].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk6',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[7].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk7',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[8].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk8',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[9].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk9',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[10].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk10',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[11].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk11',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[12].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk12',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[13].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk13',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[14].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk14',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[15].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk15',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[16].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk16',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[17].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk17',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[18].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk18',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[19].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk19',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[20].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk20',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[21].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk21',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[22].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk22',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[23].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk23',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[24].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk24',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[25].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]' : 'txclk25',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[0].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk0',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[1].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk1',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[2].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk2',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[3].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk3',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[4].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk4',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[5].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk5',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[6].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk6',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[7].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk7',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[8].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk8',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[9].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk9',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[10].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk10',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[11].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk11',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[12].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk12',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[13].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk13',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[14].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk14',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[15].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk15',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[16].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk16',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[17].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk17',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[18].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk18',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[19].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk19',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[20].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk20',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[21].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk21',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[22].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk22',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[23].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk23',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[24].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk24',
 'fc8pma_wrap_inst|pma|native_phy.gen_pma_1ch[25].pma_1ch|s5_native_phy_8G|s5_native_phy_8g_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b' : 'rxclk25',
 'n/a' : 'NA',
 'iCLK_100M_0' :  'iCLK_100M_0',
 'iCLK_100M_1' :  'iCLK_100M_1',
 'iCLK_FR' :  'iCLK_FR',
 'iPCIE_REF_CLK' :  'iPCIE_REF_CLK',
 'fc8clkrst_wrap_inst|altpll_425in_212out_inst|s5_altpll_425in_212out_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk' : 'coreclk',
 'fc8clkrst_wrap_inst|altpll_425in_215out_inst|s5_altpll_425in_215out_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk' : 'xbarclk',
 'fc8clkrst_wrap_inst|clkgen_inst|s5_altpll_425in_inst|s5_altpll_425in_inst|altera_pll_i|stratixv_pll|counter[0].output_counter|divclk' : 'serdesclk',
 'pcie_12le_inst|u_bali_pcie_gen2x8_wrap|bali_pcie_hip|s5_pcie_gen2x8_12_1_inst|altpcie_hip_256_pipen1b|stratixv_hssi_gen3_pcie_hip|coreclkout' : 'pcieclk',
}

lines=[]
def readcsv(file):
  """
  read dse csv file
  """
  INFILE=open(file,"r")
  for line in INFILE.readlines():
    line=line.strip()
    fs=line.split(',')
    if ':' in fs[0]:
      gs=map(lambda x: x.replace("'",""),map(lambda x: x.strip(),fs[0].split(':')))
      if len(gs) == 3:
        if gs[1] in clk2abrev.keys():
          gs[1]=clk2abrev[gs[1]]
      fs[0] = " : ".join(gs)
      lines.append(",".join(fs))
    elif fs[0] == 'Worst-case Slack':
      hs=[]
      hs.append(fs[0])
      for f in fs[1:]:
        index=f.index('(')
        gs=map(lambda x: x.replace("'",""),map(lambda x: x.strip(),f[index+1:-1].split(':')))
        if gs[1] in clk2abrev.keys():
          gs[1]=clk2abrev[gs[1]]
        hs.append('%s(%s)' % (f[:index]," : ".join(gs)))
      lines.append(",".join(hs))
    else:  
      lines.append(",".join(fs))
        
      
        

def write_new_cvs(file):
  """
  """
  OUTFILE=open(file,"w")
  OUTFILE.write("\n".join(lines))
      
def writexls(file):
  """
  """
  hdr_col=6
  wb = xlwt.Workbook()
  ws = wb.add_sheet('Summary')
  ws.col(0).width = 50*256 
  for i in range(1,len(lines[hdr_col].split(','))):
     ws.col(i).width = 30*256 

  hdr_style  = xlwt.easyxf('font: bold on, colour_index white; pattern: pattern solid, fore-colour 0x12;' "borders: top thin, bottom thin, right thin;")
  cell_style_white = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  cell_style_white_err = xlwt.easyxf('font: bold off, colour_index red; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x9;' "borders: top thin, bottom thin, right thin;")
  #cell_style_shade = xlwt.easyxf('font: bold off; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")
  #cell_style_shade_err = xlwt.easyxf('font: bold off, colour_index red; align: wrap on, vert centre, horiz left;pattern: pattern solid, fore-colour 0x1b;' "borders: top thin, bottom thin, right thin;")

  for row,line in enumerate(lines):
    fs=line.split(',')
    for col,f in enumerate(fs):
      if row == hdr_col:
        ws.write(row,col,f,hdr_style)
      elif f.startswith('-'):
        ws.write(row,col,f,cell_style_white_err)
      else:
        ws.write(row,col,f,cell_style_white)
  wb.save(file)
          

          
def help():
  print """
        dsexml2xls.py -i <input filename> -o <output filename>
        -i      dse csv file
        -o      excel file
"""

if __name__ == '__main__':
  """
  """
  import sys
  import getopt
  opts, params = getopt.getopt(sys.argv[1:],'i:o:')
  if len(opts) == 2:
    for k,v in opts:
      if k in ['-i']:
        csv     = v
      elif k in ['-o']:
        xls     = v
    readcsv(csv)
    writexls(xls)
  else:
    help()
