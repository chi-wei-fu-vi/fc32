//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: $
// $Author: $
// $Date: $
// $Revision: $
//**************************************************************************/

import fc1_pkg::*;

module fc1_intstat (
        input   iRX_CLK,
        input   iRX_RST,
        input   iTX_CLK,
        input   iTX_RST,
        input   iINT_STATS_LATCH_CLR,
        
        input   CSR_EXPT_ENC_FULL,
        input   CSR_EXPT_ENC_EMPT,
        input   CSR_STAT_CORR_EVENT_CNT,
        input   CSR_STAT_UNCORR_EVENT_CNT,
        input   CSR_EXPT_LOSS_BLOCKLOCK,
        
        //output  fc1_pkg::fc1_interval_stats oINT_STATS_FC1
				output [31:0] oINT_STATS_FC1_CORR_EVENT_CNT,
				output [31:0] oINT_STATS_FC1_UNCORR_EVENT_CNT,
				output [31:0] oINT_STATS_FC1_PCS_LOS_CNT
);

logic latch_clr_sync;

vi_sync_pulse latch_clr_sync_inst
(       // Outputs
        .out_pulse                             (latch_clr_sync),
        // Inputs
        .rsta_n                                (!iTX_RST),
        .clka                                  (iTX_CLK),
        .in_pulse                              (iINT_STATS_LATCH_CLR),
        .rstb_n                                (!iRX_RST),
        .clkb                                  (iRX_CLK));

/*
 * lz : will no longer give full/empty stat thru invl stats.  
 * Status is reflected in local register
 *
vi_invl_stats_ctr #(8) intstat_enc_full (
        .clk           (iTX_CLK), 
        .rst_n         (!iTX_RST), 
        .latch_clr     (iINT_STATS_LATCH_CLR), 
        .increment     (CSR_EXPT_ENC_FULL), 
        .latched_stats_ctr_r   (oINT_STATS_FC1.enc_full_cnt)
);

vi_invl_stats_ctr #(8) intstat_enc_empty (
        .clk           (iTX_CLK), 
        .rst_n         (!iTX_RST), 
        .latch_clr     (iINT_STATS_LATCH_CLR), 
        .increment     (CSR_EXPT_ENC_EMPT), 
        .latched_stats_ctr_r   (oINT_STATS_FC1.enc_empty_cnt)
);
*/

wire [7:0] corr_event_cnt;
wire [7:0] uncorr_event_cnt;
wire [7:0] pcs_los_cnt;

//assign oINT_STATS_FC1.enc_full_cnt = 'h0;
//assign oINT_STATS_FC1.enc_empty_cnt = 'h0;

assign oINT_STATS_FC1_CORR_EVENT_CNT = {{24{1'b0}}, corr_event_cnt};
assign oINT_STATS_FC1_UNCORR_EVENT_CNT = {{24{1'b0}}, uncorr_event_cnt};
assign oINT_STATS_FC1_PCS_LOS_CNT = {{24{1'b0}}, pcs_los_cnt};

vi_invl_stats_ctr #(8) intstat_corr_event (
        .clk           (iRX_CLK), 
        .rst_n         (!iRX_RST), 
        .latch_clr     (latch_clr_sync), 
        .increment     (CSR_STAT_CORR_EVENT_CNT), 
        .latched_stats_ctr_r   (corr_event_cnt)
);

vi_invl_stats_ctr #(8) intstat_uncorr_event (
        .clk           (iRX_CLK), 
        .rst_n         (!iRX_RST), 
        .latch_clr     (latch_clr_sync), 
        .increment     (CSR_STAT_UNCORR_EVENT_CNT), 
        .latched_stats_ctr_r   (uncorr_event_cnt)
);

vi_invl_stats_ctr #(8) intstat_loss_blocklock (
        .clk           (iRX_CLK), 
        .rst_n         (!iRX_RST), 
        .latch_clr     (latch_clr_sync), 
        .increment     (CSR_EXPT_LOSS_BLOCKLOCK), 
        .latched_stats_ctr_r   (pcs_los_cnt)
);

endmodule
