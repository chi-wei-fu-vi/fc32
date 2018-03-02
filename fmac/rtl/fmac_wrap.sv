//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_wrap.sv $
// $Author: chi-wei.fu $
// $Date: 2017-03-29 08:50:57 -0700 (Wed, 29 Mar 2017) $
// $Revision: 14579 $
//**************************************************************************/

// This file is auto-generated.  Do not manually modify this file.  
// I/O's are documented in leaf modules instantiated by fmac_wrap.  
import fmac_pkg::*;

module fmac_wrap
#(
        parameter SIM_ONLY  =  0,
        parameter LINK_ID  =  0,
        parameter CH_ID    =  0
)
(
        
        // Interfaces manually instantiated
        output  fmac_pkg::fmac_interval_stats ofmac_interval_stats,
        
        // Manually declared - bus width mismatch between fmac_regs and decoder
				input  [3:0]          iREG_LINKCTRL_MONITORMODE,
				input                 iSFP_PHY_LOSIG,
        input   rx_is_lockedtodata,
        input  [13:0]         mm_fmac_addr,            // To fmac_regs of fmac_regs.v
        output logic          sm_linkup,                   // From fmac_efifo of fmac_efifo.v
        output logic [31:0]    int_stats_endcr,         // From fmac_credit_stats of fmac_credit_stats.v
        output logic [31:0]    int_stats_maxcr,         // From fmac_credit_stats of fmac_credit_stats.v
        output logic [31:0]    int_stats_mincr,         // From fmac_credit_stats of fmac_credit_stats.v
        output logic [31:0]   int_stats_timecr,        // From fmac_credit_stats of fmac_credit_stats.v
        input  logic [31:0]    reg_fmac_credit_start,         // From fmac_regs of fmac_regs.v
        
        /*AUTOINPUT*/
        // Beginning of automatic inputs (from unused autoinst inputs)
        input   clk,            // To fmac_regs of fmac_regs.v, ...
        input   [1:0]  credit_in_r_rdy,         // To fmac_credit_stats of fmac_credit_stats.v
        input   int_stats_latch_clr,            // To fmac_credit_stats of fmac_credit_stats.v, ...
        input   mm_fmac_rd_en,                  // To fmac_regs of fmac_regs.v
        input   [63:0]  mm_fmac_wr_data,        // To fmac_regs of fmac_regs.v
        input   mm_fmac_wr_en,                  // To fmac_regs of fmac_regs.v
        input   [63:0]  pcs_rx_data,            // To fmac_regs of fmac_regs.v, ...
        input   [1:0]  pcs_rx_hdr,              // To fmac_regs of fmac_regs.v, ...
        input   pcs_rx_sync,    // To fmac_regs of fmac_regs.v, ...
        input   pcs_rx_valid,           // To fmac_regs of fmac_regs.v, ...
        input   rst_n,                  // To fmac_regs of fmac_regs.v, ...
        input   rx_clk,                 // To fmac_decode of fmac_decode.v, ...
        input   rx_rst_n,               // To fmac_decode of fmac_decode.v, ...
        // End of automatics
        
        /*AUTOOUTPUT*/
        // Beginning of automatic outputs (from unused autoinst outputs)
        output  logic [1:0] fmac_credit_out_r_rdy,      // From fmac_efifo of fmac_efifo.v
        output  fmac_mm_ack,    // From fmac_regs of fmac_regs.v
        output  [63:0]  fmac_mm_rd_data,        // From fmac_regs of fmac_regs.v
        output  logic  fmac_st_avail,           // From fmac_rcv of fmac_rcv.v
        output  logic [63:0] fmac_st_data,      // From fmac_rcv of fmac_rcv.v
        output  logic  fmac_st_empty,           // From fmac_rcv of fmac_rcv.v
        output  logic  fmac_st_eop,             // From fmac_rcv of fmac_rcv.v
        output  logic  fmac_st_err,             // From fmac_rcv of fmac_rcv.v
        output  logic [7:0] fmac_st_err_stat,   // From fmac_rcv of fmac_rcv.v
        output  logic  fmac_st_sop,             // From fmac_rcv of fmac_rcv.v
        output  logic  fmac_st_valid,           // From fmac_rcv of fmac_rcv.v
        output  logic [11:0] fmac_st_vf_id,     // From fmac_rcv of fmac_rcv.v
        output  logic [63:0] fmac_xbar_rx_data,         // From fmac_efifo of fmac_efifo.v
        output  logic [1:0] fmac_xbar_rx_sh,         // From fmac_efifo of fmac_efifo.v
        output  logic  fmac_xbar_rx_valid               // From fmac_efifo of fmac_efifo.v
        // End of automatics
        
);

// -------------------
// Declarations
// -------------------

// Manual Declarations

fmac_pkg::dec_intf  fefo_dec_intf_0;
fmac_pkg::dec_intf  fefo_dec_intf_1;
fmac_pkg::dec_intf  fdec_dec_intf_0;
fmac_pkg::dec_intf  fdec_dec_intf_1;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [63:0]    fdec_rx_data;           // From fmac_decode of fmac_decode.v
logic      fdec_rx_data_valid;          // From fmac_decode of fmac_decode.v
logic [63:0]    fefo_rx_data;           // From fmac_efifo of fmac_efifo.v
logic      fefo_rx_data_valid;          // From fmac_efifo of fmac_efifo.v
logic      reg_bad_eof_event;           // From fmac_efifo of fmac_efifo.v
logic      reg_bb_scr_cnt_en;           // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_bb_scr_cnt_inc;      // From fmac_efifo of fmac_efifo.v
logic      reg_bb_scs_cnt_en;           // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_bb_scs_cnt_inc;      // From fmac_efifo of fmac_efifo.v
logic      reg_code_viol_cnt_en;        // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_code_viol_cnt_inc;   // From fmac_efifo of fmac_efifo.v
logic      reg_crc_err_cnt_en;          // From fmac_rcv of fmac_rcv.v
logic      reg_data_cnt_en;             // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_data_cnt_inc;        // From fmac_efifo of fmac_efifo.v
logic [31:0]    reg_efifo_delete_cnt;   // From fmac_efifo of fmac_efifo.v
wire    [7:0]    reg_efifo_high_limit;  // From fmac_regs of fmac_regs.v
logic [31:0]    reg_efifo_insert_cnt;   // From fmac_efifo of fmac_efifo.v
wire    [7:0]    reg_efifo_low_limit;   // From fmac_regs of fmac_regs.v
logic [31:0]    reg_efifo_overflow_cnt;         // From fmac_efifo of fmac_efifo.v
logic      reg_efifo_rd_empty;  // From fmac_efifo of fmac_efifo.v
logic      reg_efifo_rd_full;   // From fmac_efifo of fmac_efifo.v
logic [4:0]    reg_efifo_rd_used;       // From fmac_efifo of fmac_efifo.v
wire    [7:0]    reg_efifo_read_level;  // From fmac_regs of fmac_regs.v
logic [2:0]    reg_efifo_sm_rd;         // From fmac_efifo of fmac_efifo.v
logic [2:0]    reg_efifo_sm_wr;         // From fmac_efifo of fmac_efifo.v
logic      reg_efifo_underflow_cnt_en;  // From fmac_efifo of fmac_efifo.v
logic      reg_efifo_wr_empty;          // From fmac_efifo of fmac_efifo.v
logic      reg_efifo_wr_full;           // From fmac_efifo of fmac_efifo.v
logic [4:0]    reg_efifo_wr_used;       // From fmac_efifo of fmac_efifo.v
logic      reg_eof_cnt_en;              // From fmac_decode of fmac_decode.v
logic      reg_eof_dec_err_cnt_en;      // From fmac_efifo of fmac_efifo.v
wire    [7:0]    reg_fill_word_min;     // From fmac_regs of fmac_regs.v
wire    reg_fmac_ctl_crc_disable;               // From fmac_regs of fmac_regs.v
wire    reg_fmac_ctl_le_endianess;              // From fmac_regs of fmac_regs.v
logic      reg_fmac_fifo_empty;                 // From fmac_rcv of fmac_rcv.v
logic      reg_fmac_fifo_full;  // From fmac_rcv of fmac_rcv.v
logic [5:0]    reg_fmac_fifo_usedw;     // From fmac_rcv of fmac_rcv.v
logic [15:0]    reg_fmac_vc_id;         // From fmac_credit_stats of fmac_credit_stats.v
wire    [2:0]    reg_fmac_vc_sel;       // From fmac_regs of fmac_regs.v
wire    [15:0]    reg_frame_max;        // From fmac_regs of fmac_regs.v
wire    [15:0]    reg_frame_min;        // From fmac_regs of fmac_regs.v
logic      reg_idle_cnt_en;             // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_idle_cnt_inc;        // From fmac_efifo of fmac_efifo.v
logic      reg_idle_dec_err_cnt_en;     // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_idle_dec_err_cnt_inc;// From fmac_efifo of fmac_efifo.v
wire    [7:0]    reg_inj_code_viol;     // From fmac_regs of fmac_regs.v
wire    reg_inj_crc_err;                // From fmac_regs of fmac_regs.v
logic      reg_invalid_type_err_cnt_en; // From fmac_efifo of fmac_efifo.v
logic      reg_ipg_err_cnt_en;          // From fmac_decode of fmac_decode.v
logic      reg_length_err_cnt_en;       // From fmac_rcv of fmac_rcv.v
logic      reg_link_down_cnt_en;        // From fmac_efifo of fmac_efifo.v
logic      reg_link_up_cnt_en;          // From fmac_efifo of fmac_efifo.v
logic      reg_lr_lrr_event;            // From fmac_efifo of fmac_efifo.v
logic      reg_nos_ols_event;           // From fmac_efifo of fmac_efifo.v
logic      reg_other_dec_err_cnt_en;    // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_other_dec_err_cnt_inc;       // From fmac_efifo of fmac_efifo.v
logic      reg_r_rdy_cnt_en;    // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_r_rdy_cnt_inc;       // From fmac_efifo of fmac_efifo.v
logic      reg_rcv_fifo_empty;          // From fmac_rcv of fmac_rcv.v
logic      reg_rcv_fifo_full;           // From fmac_rcv of fmac_rcv.v
logic [3:0]    reg_rcv_fifo_usedw;      // From fmac_rcv of fmac_rcv.v
logic      reg_sof_cnt_en;              // From fmac_decode of fmac_decode.v
logic      reg_sof_dec_err_cnt_en;      // From fmac_efifo of fmac_efifo.v
logic      reg_sync_hdr_err_cnt_en;     // From fmac_efifo of fmac_efifo.v
logic      reg_vc_rdy_cnt_en;           // From fmac_efifo of fmac_efifo.v
logic [1:0]    reg_vc_rdy_cnt_inc;      // From fmac_efifo of fmac_efifo.v
// End of automatics

logic monitor_mode;
logic monitor_mode_s;
logic mon_invl_mode;
logic linkdown_event212_final;

//--------------------
// Auto Instantiation
//--------------------

/* fmac_regs AUTO_TEMPLATE 
    (
    .wr_en            (mm_fmac_wr_en@),
    .rd_en            (mm_fmac_rd_en@),
    .wr_data            (mm_fmac_wr_data@[]),
    .rd_data            (fmac_mm_rd_data@[]),
    .rd_data_v            (fmac_mm_ack@),
    // Outputs
    .oREG_\(.*\)                (),
    .oREG_FILL_WORD_MIN          (reg_fill_word_min[]),
    .oREG_FRAME_MIN    (reg_frame_min[]),
    .oREG_FRAME_MAX    (reg_frame_max[]),
    .oREG_EFIFO_READ_LEVEL  (reg_efifo_read_level[]),
    .oREG_EFIFO_LOW_LIMIT  (reg_efifo_low_limit[]),
    .oREG_EFIFO_HIGH_LIMIT  (reg_efifo_high_limit[]),
    .oREG_FMAC_ERR_INJ_CRC_ERR     (reg_inj_crc_err),
    .oREG_FMAC_ERR_INJ_CODE_VIOL   (reg_inj_code_viol[]),
    .oREG_FMAC_CREDIT_START     (reg_fmac_credit_start[]),
    .oREG_FMAC_CTL_LE_ENDIANESS     (reg_fmac_ctl_le_endianess),
    .oREG_FMAC_CTL_CRC_DISABLE     (reg_fmac_ctl_crc_disable),
    .oREG_FMAC_VC_SEL       (reg_fmac_vc_sel[]),
    // Inputs
    .iREG_R_RDY_CNT_EN      (reg_r_rdy_cnt_en),  
    .iREG_R_RDY_CNT_INC      (reg_r_rdy_cnt_inc[]),  
    .iREG_VC_RDY_CNT_EN      (reg_vc_rdy_cnt_en),  
    .iREG_VC_RDY_CNT_INC    (reg_vc_rdy_cnt_inc[]),
    .iREG_BB_SCS_CNT_EN      (reg_bb_scs_cnt_en),  
    .iREG_BB_SCS_CNT_INC    (reg_bb_scs_cnt_inc[]),
    .iREG_BB_SCR_CNT_EN      (reg_bb_scr_cnt_en),  
    .iREG_BB_SCR_CNT_INC      (reg_bb_scr_cnt_inc[]),
    .iREG_NOS_OLS_CNT_EN    (reg_nos_ols_event),
    .iREG_LR_LRR_CNT_EN      (reg_lr_lrr_event),
    .iREG_BAD_EOF_CNT_EN    (reg_bad_eof_event),
    .iREG_SYNC_HDR_ERR_CNT_EN    (reg_sync_hdr_err_cnt_en),
    .iREG_INVALID_TYPE_ERR_CNT_EN (reg_invalid_type_err_cnt_en),
    .iREG_SOF_DEC_ERR_CNT_EN    (reg_sof_dec_err_cnt_en),
    .iREG_EOF_DEC_ERR_CNT_EN    (reg_eof_dec_err_cnt_en),
    .iREG_OTHER_DEC_ERR_CNT_EN    (reg_other_dec_err_cnt_en),
    .iREG_OTHER_DEC_ERR_CNT_INC    (reg_other_dec_err_cnt_inc[]),
    .iREG_IDLE_DEC_ERR_CNT_EN    (reg_idle_dec_err_cnt_en),
    .iREG_IDLE_DEC_ERR_CNT_INC    (reg_idle_dec_err_cnt_inc[]),
    .iREG_SOF_CNT_EN      (reg_sof_cnt_en),
    .iREG_EOF_CNT_EN      (reg_eof_cnt_en),
    .iREG_IDLE_CNT_EN      (reg_idle_cnt_en),
    .iREG_IDLE_CNT_INC      (reg_idle_cnt_inc[]),
    .iREG_DATA_CNT_EN      (reg_data_cnt_en),
    .iREG_DATA_CNT_INC      (reg_data_cnt_inc[]),
    .iREG_LENGTH_ERR_CNT_EN    (reg_length_err_cnt_en),
    .iREG_CRC_ERR_CNT_EN    (reg_crc_err_cnt_en),
    .iREG_FRAME_CORRUPT_EN  (fmac_st_err&fmac_st_err_stat[3]),
    .iREG_LINK_UP_CNT_EN  (reg_link_up_cnt_en),
    .iREG_LINK_DOWN_CNT_EN  (reg_link_down_cnt_en),
    .iREG_EFIFO_OVERFLOW_CNT   (reg_efifo_overflow_cnt[]),
    .iREG_EFIFO_UNDERFLOW_CNT_EN (reg_efifo_underflow_cnt_en),
    .iREG_IPG_ERR_CNT_EN  (reg_ipg_err_cnt_en),
    .iREG_EFIFO_INSERT_CNT   (reg_efifo_insert_cnt[]),
    .iREG_EFIFO_DELETE_CNT   (reg_efifo_delete_cnt[]),
    .iREG_CODE_VIOL_CNT_EN   (reg_code_viol_cnt_en),
    .iREG_CODE_VIOL_CNT_INC   (reg_code_viol_cnt_inc),
    .iREG_FMAC_CREDIT_BBC_MAX    (int_stats_maxcr[]),
    .iREG_FMAC_CREDIT_BBC_MIN    (int_stats_mincr[]),
    .iREG_FMAC_CREDIT_CNT        (int_stats_endcr[]),
    .iREG_FMAC_TIME_MIN_CREDIT   (int_stats_timecr[]),
    .iREG_FMAC_VC_ID             (reg_fmac_vc_id[15:0]),
    .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_WRUSEDW  (reg_efifo_wr_used[]),
    .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_RDUSEDW  (reg_efifo_rd_used[]),
    .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_RD_EMPTY (reg_efifo_rd_empty),
    .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_RD_FULL  (reg_efifo_rd_full),
    .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_WR_EMPTY (reg_efifo_wr_empty),
    .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_WR_FULL  (reg_efifo_wr_full),
    .iREG_FMAC_FIFO_STATUS_RCV_FIFO_USEDW        (reg_rcv_fifo_usedw[]),
    .iREG_FMAC_FIFO_STATUS_RCV_FIFO_EMPTY        (reg_rcv_fifo_empty),
    .iREG_FMAC_FIFO_STATUS_RCV_FIFO_FULL         (reg_rcv_fifo_full),
    .iREG_FMAC_FIFO_STATUS_FMAC_FIFO_USEDW       (reg_fmac_fifo_usedw[]),
    .iREG_FMAC_FIFO_STATUS_FMAC_FIFO_EMPTY       (reg_fmac_fifo_empty),
    .iREG_FMAC_FIFO_STATUS_FMAC_FIFO_FULL        (reg_fmac_fifo_full),
    .iREG_FMAC_DEBUG_0_PCS_VALID      (pcs_rx_valid),
    .iREG_FMAC_DEBUG_0_PCS_SYNC        (pcs_rx_sync),
    .iREG_FMAC_DEBUG_0_PCS_HDR        (pcs_rx_hdr[]),
    .iREG_PCS_RX_DATA          (pcs_rx_data[]),
    .iREG_FMAC_DEBUG_0_SM_LINKUP      (sm_linkup),
    .iREG_FMAC_DEBUG_0_FMAC_FIFO_WR_USED(reg_fmac_fifo_wr_used[]),
    .iREG_FMAC_DEBUG_0_FMAC_FIFO_RD_USED(reg_fmac_fifo_rd_used[]),
    .iREG_FMAC_DEBUG_0_SM_EFIFO_WR  (reg_efifo_sm_wr[]),
    .iREG_FMAC_DEBUG_0_SM_EFIFO_RD  (reg_efifo_sm_rd[]),
    .\(.*\)_EN                  (1'b0),    
    .\(.*\)_INC                 (2'b0),    
    ); */

fmac_regs fmac_regs
(       // Manually declared because of bus width mismatch
        .addr          (mm_fmac_addr[9:0]),
        /*AUTOINST*/
        // Outputs
        .rd_data               (fmac_mm_rd_data[63:0]), // Templated
        .rd_data_v             (fmac_mm_ack),           // Templated
        .oREG__SCRATCH          (),                      // Templated
        .oREG_FMAC_CTL_LE_ENDIANESS    (reg_fmac_ctl_le_endianess),     // Templated
        .oREG_FMAC_CTL_CRC_DISABLE     (reg_fmac_ctl_crc_disable),      // Templated
        .oREG_FMAC_ERR_INJ_CRC_ERR     (reg_inj_crc_err),               // Templated
        .oREG_FMAC_ERR_INJ_CODE_VIOL           (reg_inj_code_viol[7:0]),        // Templated
        .oREG_FRAME_MIN        (reg_frame_min[15:0]),   // Templated
        .oREG_FRAME_MAX        (reg_frame_max[15:0]),   // Templated
        .oREG_FILL_WORD_MIN            (reg_fill_word_min[7:0]),        // Templated
        .oREG_EFIFO_READ_LEVEL         (reg_efifo_read_level[7:0]),     // Templated
        .oREG_EFIFO_LOW_LIMIT          (reg_efifo_low_limit[7:0]),      // Templated
        .oREG_EFIFO_HIGH_LIMIT         (reg_efifo_high_limit[7:0]),     // Templated
        //.oREG_FMAC_CREDIT_START        (reg_fmac_credit_start[31:0]),    // Templated
        .oREG_FMAC_VC_SEL              (reg_fmac_vc_sel[2:0]),          // Templated
        // Inputs
        .clk           (clk),
        .rst_n                 (rst_n),
        .wr_en                 (mm_fmac_wr_en),         // Templated
        .rd_en                 (mm_fmac_rd_en),         // Templated
        .wr_data               (mm_fmac_wr_data[63:0]), // Templated
        .iREG_SOF_CNT_EN       (reg_sof_cnt_en),        // Templated
        .iREG_EOF_CNT_EN       (reg_eof_cnt_en),        // Templated
        .iREG_IDLE_CNT_EN      (reg_idle_cnt_en),       // Templated
        .iREG_IDLE_CNT_INC             (reg_idle_cnt_inc[1:0]), // Templated
        .iREG_DATA_CNT_EN              (reg_data_cnt_en),       // Templated
        .iREG_DATA_CNT_INC             (reg_data_cnt_inc[1:0]), // Templated
        .iREG_R_RDY_CNT_EN             (reg_r_rdy_cnt_en),      // Templated
        .iREG_R_RDY_CNT_INC            (reg_r_rdy_cnt_inc[1:0]),        // Templated
        .iREG_VC_RDY_CNT_EN            (reg_vc_rdy_cnt_en),             // Templated
        .iREG_VC_RDY_CNT_INC           (reg_vc_rdy_cnt_inc[1:0]),       // Templated
        .iREG_BB_SCS_CNT_EN            (reg_bb_scs_cnt_en),             // Templated
        .iREG_BB_SCS_CNT_INC           (reg_bb_scs_cnt_inc[1:0]),       // Templated
        .iREG_BB_SCR_CNT_EN            (reg_bb_scr_cnt_en),             // Templated
        .iREG_BB_SCR_CNT_INC           (reg_bb_scr_cnt_inc[1:0]),       // Templated
        .iREG_NOS_OLS_CNT_EN           (reg_nos_ols_event),             // Templated
        .iREG_LR_LRR_CNT_EN            (reg_lr_lrr_event),              // Templated
        .iREG_BAD_EOF_CNT_EN           (reg_bad_eof_event),             // Templated
        .iREG_SYNC_HDR_ERR_CNT_EN      (reg_sync_hdr_err_cnt_en),       // Templated
        .iREG_INVALID_TYPE_ERR_CNT_EN          (reg_invalid_type_err_cnt_en),   // Templated
        .iREG_SOF_DEC_ERR_CNT_EN               (reg_sof_dec_err_cnt_en),        // Templated
        .iREG_EOF_DEC_ERR_CNT_EN               (reg_eof_dec_err_cnt_en),        // Templated
        .iREG_OTHER_DEC_ERR_CNT_EN             (reg_other_dec_err_cnt_en),      // Templated
        .iREG_OTHER_DEC_ERR_CNT_INC            (reg_other_dec_err_cnt_inc[1:0]),        // Templated
        .iREG_IDLE_DEC_ERR_CNT_EN              (reg_idle_dec_err_cnt_en),               // Templated
        .iREG_IDLE_DEC_ERR_CNT_INC             (reg_idle_dec_err_cnt_inc[1:0]),         // Templated
        .iREG_CODE_VIOL_CNT_EN                 (reg_code_viol_cnt_en),                  // Templated
        .iREG_CODE_VIOL_CNT_INC                (reg_code_viol_cnt_inc), // Templated
        .iREG_CRC_ERR_CNT_EN                   (reg_crc_err_cnt_en),    // Templated
        .iREG_LENGTH_ERR_CNT_EN                (reg_length_err_cnt_en), // Templated
        .iREG_IPG_ERR_CNT_EN                   (reg_ipg_err_cnt_en),    // Templated
        .iREG_LINK_UP_CNT_EN                   (reg_link_up_cnt_en),    // Templated
        .iREG_LINK_DOWN_CNT_EN                 (reg_link_down_cnt_en),          // Templated
        .iREG_EFIFO_OVERFLOW_CNT               (reg_efifo_overflow_cnt[15:0]),  // Templated
        .iREG_EFIFO_UNDERFLOW_CNT_EN           (reg_efifo_underflow_cnt_en),    // Templated
        .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_WRUSEDW    (reg_efifo_wr_used[4:0]),        // Templated
        .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_RDUSEDW    (reg_efifo_rd_used[4:0]),        // Templated
        .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_WR_EMPTY   (reg_efifo_wr_empty),            // Templated
        .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_WR_FULL    (reg_efifo_wr_full),             // Templated
        .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_RD_EMPTY   (reg_efifo_rd_empty),            // Templated
        .iREG_FMAC_FIFO_STATUS_ELASTIC_FIFO_RD_FULL    (reg_efifo_rd_full),             // Templated
        .iREG_FMAC_FIFO_STATUS_RCV_FIFO_USEDW          (reg_rcv_fifo_usedw[3:0]),       // Templated
        .iREG_FMAC_FIFO_STATUS_RCV_FIFO_EMPTY          (reg_rcv_fifo_empty),            // Templated
        .iREG_FMAC_FIFO_STATUS_RCV_FIFO_FULL           (reg_rcv_fifo_full),             // Templated
        .iREG_FMAC_FIFO_STATUS_FMAC_FIFO_USEDW         (reg_fmac_fifo_usedw[5:0]),      // Templated
        .iREG_FMAC_FIFO_STATUS_FMAC_FIFO_EMPTY         (reg_fmac_fifo_empty),           // Templated
        .iREG_FMAC_FIFO_STATUS_FMAC_FIFO_FULL          (reg_fmac_fifo_full),            // Templated
        .iREG_EFIFO_INSERT_CNT         (reg_efifo_insert_cnt[15:0]),    // Templated
        .iREG_EFIFO_DELETE_CNT         (reg_efifo_delete_cnt[15:0]),    // Templated
        .iREG_PCS_RX_DATA              (pcs_rx_data[63:0]),             // Templated
        .iREG_FMAC_DEBUG_0_SM_LINKUP           (sm_linkup),             // Templated
        .iREG_FMAC_DEBUG_0_SM_EFIFO_WR         (reg_efifo_sm_wr[2:0]),          // Templated
        .iREG_FMAC_DEBUG_0_SM_EFIFO_RD         (reg_efifo_sm_rd[2:0]),          // Templated
        .iREG_FMAC_DEBUG_0_PCS_VALID           (pcs_rx_valid),                  // Templated
        .iREG_FMAC_DEBUG_0_PCS_SYNC            (pcs_rx_sync),                   // Templated
        .iREG_FMAC_DEBUG_0_PCS_HDR             (pcs_rx_hdr[1:0]),               // Templated
        //.iREG_FMAC_TIME_MIN_CREDIT             (int_stats_timecr[15:0]),        // Templated
        //.iREG_FMAC_CREDIT_BBC_MIN              (int_stats_mincr[31:0]),          // Templated
        //.iREG_FMAC_CREDIT_BBC_MAX              (int_stats_maxcr[31:0]),          // Templated
        //.iREG_FMAC_CREDIT_CNT                  (int_stats_endcr[31:0]),          // Templated
        .iREG_FMAC_VC_ID       (reg_fmac_vc_id[15:0]));         // Templated
/*
generate
  if (LINK_ID == 0 && CH_ID == 0) begin: sigtap_gen_DEC
//signaltap
wire [127:0] DEC_acq_data_in;
wire         DEC_acq_clk;

assign DEC_acq_clk = rx_clk;

signaltap DEC_signaltap_inst (
  .acq_clk(DEC_acq_clk),
  .acq_data_in(DEC_acq_data_in),
  .acq_trigger_in(DEC_acq_data_in)
);

assign DEC_acq_data_in = {
//128
pcs_rx_data[63:0],
//112
//104
//96
//90
//72
//64
fdec_dec_intf_1.sof      ,
fdec_dec_intf_1.sof_type ,
fdec_dec_intf_1.eof      ,
fdec_dec_intf_1.eof_type ,
fdec_dec_intf_1.prim     ,
fdec_dec_intf_1.idle     ,
fdec_dec_intf_1.data     ,
fdec_dec_intf_1.other    ,
fdec_dec_intf_1.err_vec  ,
fdec_dec_intf_1.code_viol,
//48
//40
fdec_dec_intf_0.sof      ,
fdec_dec_intf_0.sof_type ,
fdec_dec_intf_0.eof      ,
fdec_dec_intf_0.eof_type ,
fdec_dec_intf_0.prim     ,
fdec_dec_intf_0.idle     ,
fdec_dec_intf_0.data     ,
fdec_dec_intf_0.other    ,
fdec_dec_intf_0.err_vec  ,
fdec_dec_intf_0.code_viol,
//32
//16
//8
1'h0,
fefo_rx_data_valid,
fdec_rx_data_valid,
pcs_rx_hdr[1:0],
pcs_rx_sync,
pcs_rx_valid,
rx_rst_n
};

  end  // if LINK_ID, CH_ID
endgenerate
*/
fmac_decode fmac_decode
(       /*AUTOINST*/
        // Interfaces
        .fdec_dec_intf_0       (fdec_dec_intf_0),
        .fdec_dec_intf_1       (fdec_dec_intf_1),
        // Outputs
        .fdec_rx_data          (fdec_rx_data[63:0]),
        .fdec_rx_data_valid            (fdec_rx_data_valid),
        .reg_ipg_err_cnt_en            (reg_ipg_err_cnt_en),
        .reg_sof_cnt_en                (reg_sof_cnt_en),
        .reg_eof_cnt_en                (reg_eof_cnt_en),
				.mon_invl_mode                  (mon_invl_mode),
        // Inputs
				.iREG_LINKCTRL_MONITORMODE     (iREG_LINKCTRL_MONITORMODE),
        .pcs_rx_hdr                    (pcs_rx_hdr[1:0]),
        .pcs_rx_data                   (pcs_rx_data[63:0]),
        .pcs_rx_sync                   (pcs_rx_sync),
        .pcs_rx_valid                  (pcs_rx_valid),
        .reg_fill_word_min             (reg_fill_word_min[7:0]),
        .rx_rst_n                      (rx_rst_n),
        .rx_clk        (rx_clk),
        .clk           (clk),
        .rst_n                 (rst_n));

/*
generate
  if (LINK_ID == 0 && CH_ID == 0) begin: sigtap_gen_EFIFO
//signaltap
wire [127:0] EFIFO_acq_data_in;
wire         EFIFO_acq_clk;

assign EFIFO_acq_clk = rx_clk;

signaltap EFIFO_signaltap_inst (
  .acq_clk(EFIFO_acq_clk),
  .acq_data_in(EFIFO_acq_data_in),
  .acq_trigger_in(EFIFO_acq_data_in)
);

assign EFIFO_acq_data_in = {
//128
fefo_rx_data[63:0],
//112
//104
//96
//90
//64
reg_efifo_rd_full,
reg_efifo_wr_full,
reg_efifo_rd_empty,
reg_efifo_wr_empty,
reg_efifo_sm_rd[2:0],
reg_bad_eof_event,
//56
fefo_dec_intf_1.sof      ,
fefo_dec_intf_1.sof_type ,
fefo_dec_intf_1.eof      ,
fefo_dec_intf_1.eof_type ,
fefo_dec_intf_1.prim     ,
fefo_dec_intf_1.idle     ,
fefo_dec_intf_1.data     ,
fefo_dec_intf_1.other    ,
fefo_dec_intf_1.err_vec  ,
fefo_dec_intf_1.code_viol,
//48
//32
//28
fefo_dec_intf_0.sof      ,
fefo_dec_intf_0.sof_type ,
fefo_dec_intf_0.eof      ,
fefo_dec_intf_0.eof_type ,
fefo_dec_intf_0.prim     ,
fefo_dec_intf_0.idle     ,
fefo_dec_intf_0.data     ,
fefo_dec_intf_0.other    ,
fefo_dec_intf_0.err_vec  ,
fefo_dec_intf_0.code_viol
//16
};

  end  // if LINK_ID, CH_ID
endgenerate
*/


/*
fmac_efifo AUTO_TEMPLATE (
      .fmac_out_r_rdy     (fmac_credit_out_r_rdy[1:0]),
)
*/
fmac_efifo #(.SIM_ONLY(SIM_ONLY)) fmac_efifo_inst
(       /*AUTOINST*/
        // Interfaces
        .fdec_dec_intf_0       (fdec_dec_intf_0),
        .fdec_dec_intf_1       (fdec_dec_intf_1),
        .fefo_dec_intf_0       (fefo_dec_intf_0),
        .fefo_dec_intf_1       (fefo_dec_intf_1),
        // Outputs
        .fefo_rx_data          (fefo_rx_data[63:0]),
        .fefo_rx_data_valid            (fefo_rx_data_valid),
        .fmac_xbar_rx_data             (fmac_xbar_rx_data[63:0]),
        .fmac_xbar_rx_sh             (fmac_xbar_rx_sh[1:0]),
        .fmac_xbar_rx_valid            (fmac_xbar_rx_valid),
        .reg_efifo_delete_cnt          (reg_efifo_delete_cnt[31:0]),
        .reg_efifo_insert_cnt          (reg_efifo_insert_cnt[31:0]),
        .reg_efifo_rd_full             (reg_efifo_rd_full),
        .reg_efifo_wr_full             (reg_efifo_wr_full),
        .reg_efifo_rd_empty            (reg_efifo_rd_empty),
        .reg_efifo_wr_empty            (reg_efifo_wr_empty),
        .reg_efifo_overflow_cnt        (reg_efifo_overflow_cnt[31:0]),
        .reg_efifo_underflow_cnt_en    (reg_efifo_underflow_cnt_en),
        .reg_efifo_sm_rd               (reg_efifo_sm_rd[2:0]),
        .reg_efifo_sm_wr               (reg_efifo_sm_wr[2:0]),
        .reg_efifo_rd_used             (reg_efifo_rd_used[4:0]),
        .reg_efifo_wr_used             (reg_efifo_wr_used[4:0]),
        .reg_nos_ols_event             (reg_nos_ols_event),
        .reg_lr_lrr_event              (reg_lr_lrr_event),
        .reg_bad_eof_event             (reg_bad_eof_event),
        .sm_linkup                     (sm_linkup),
        .reg_idle_cnt_en               (reg_idle_cnt_en),
        .reg_data_cnt_en               (reg_data_cnt_en),
        .reg_r_rdy_cnt_en              (reg_r_rdy_cnt_en),
        .reg_vc_rdy_cnt_en             (reg_vc_rdy_cnt_en),
        .reg_bb_scs_cnt_en             (reg_bb_scs_cnt_en),
        .reg_bb_scr_cnt_en             (reg_bb_scr_cnt_en),
        .reg_idle_cnt_inc              (reg_idle_cnt_inc[1:0]),
        .reg_data_cnt_inc              (reg_data_cnt_inc[1:0]),
        .reg_r_rdy_cnt_inc             (reg_r_rdy_cnt_inc[1:0]),
        .reg_vc_rdy_cnt_inc            (reg_vc_rdy_cnt_inc[1:0]),
        .reg_bb_scs_cnt_inc            (reg_bb_scs_cnt_inc[1:0]),
        .reg_bb_scr_cnt_inc            (reg_bb_scr_cnt_inc[1:0]),
        .reg_sync_hdr_err_cnt_en       (reg_sync_hdr_err_cnt_en),
        .reg_invalid_type_err_cnt_en           (reg_invalid_type_err_cnt_en),
        .reg_sof_dec_err_cnt_en                (reg_sof_dec_err_cnt_en),
        .reg_eof_dec_err_cnt_en                (reg_eof_dec_err_cnt_en),
        .reg_other_dec_err_cnt_en              (reg_other_dec_err_cnt_en),
        .reg_other_dec_err_cnt_inc             (reg_other_dec_err_cnt_inc[1:0]),
        .reg_idle_dec_err_cnt_en               (reg_idle_dec_err_cnt_en),
        .reg_idle_dec_err_cnt_inc              (reg_idle_dec_err_cnt_inc[1:0]),
        .reg_code_viol_cnt_en                  (reg_code_viol_cnt_en),
        .reg_code_viol_cnt_inc                 (reg_code_viol_cnt_inc[1:0]),
        .fmac_out_r_rdy        (fmac_credit_out_r_rdy[1:0]),    // Templated
        .reg_link_up_cnt_en            (reg_link_up_cnt_en),
        .reg_link_down_cnt_en          (reg_link_down_cnt_en),
				.linkdown_event212_final       (linkdown_event212_final),
        // Inputs
				.iSFP_PHY_LOSIG                (iSFP_PHY_LOSIG),
        .rx_is_lockedtodata            (rx_is_lockedtodata),
				.monitor_mode                  (mon_invl_mode),
        .pcs_rx_sync                   (pcs_rx_sync),
        .fdec_rx_data                  (fdec_rx_data[63:0]),
        .fdec_rx_data_valid            (fdec_rx_data_valid),
        .reg_efifo_read_level          (reg_efifo_read_level[7:0]),
        .reg_efifo_low_limit           (reg_efifo_low_limit[7:0]),
        .reg_efifo_high_limit          (reg_efifo_high_limit[7:0]),
        .reg_inj_code_viol             (reg_inj_code_viol[7:0]),
        .rst_n                         (rst_n),
        .clk           (clk),
        .rx_rst_n              (rx_rst_n),
        .rx_clk                (rx_clk));

/*
fmac_credit_stats AUTO_TEMPLATE (
      .fmac_in_r_rdy      (credit_in_r_rdy[1:0]),
  )
*/

fmac_credit_stats fmac_credit_stats
(       /*AUTOINST*/
        // Outputs
        .reg_fmac_vc_id        (reg_fmac_vc_id[15:0]),
        .int_stats_mincr       (int_stats_mincr[31:0]),
        .int_stats_maxcr       (int_stats_maxcr[31:0]),
        .int_stats_endcr       (int_stats_endcr[31:0]),
        .int_stats_timecr      (int_stats_timecr[31:0]),
        // Inputs
        .reg_link_up_cnt_en            (reg_link_up_cnt_en),
        .reg_fmac_vc_sel               (reg_fmac_vc_sel[2:0]),
        .reg_fmac_credit_start         (reg_fmac_credit_start[31:0]),
        .reg_sof_cnt_en                (reg_sof_cnt_en),
        .fmac_in_r_rdy                 (credit_in_r_rdy[1:0]),          // Templated
        .int_stats_latch_clr           (int_stats_latch_clr),
        .rst_n                         (rst_n),
        .clk           (clk));


/*
generate
  if (LINK_ID == 0 && CH_ID == 0) begin: sigtap_gen_RCV1
//signaltap
wire [127:0] RCV1_acq_data_in;
wire         RCV1_acq_clk;

assign RCV1_acq_clk = clk;

signaltap RCV1_signaltap_inst (
  .acq_clk(RCV1_acq_clk),
  .acq_data_in(RCV1_acq_data_in),
  .acq_trigger_in(RCV1_acq_data_in)
);

assign RCV1_acq_data_in = {
//128
112'h0,
//112
//104
//96
//90
//64
//48
//32
rst_n,
//16
fmac_st_err_stat[7:0],
//8
fmac_st_valid,
fmac_st_sop,
fmac_st_eop,
fmac_st_empty,
fmac_st_avail,
fmac_st_err,
reg_fmac_fifo_empty,
int_stats_latch_clr
};

  end  // if LINK_ID, CH_ID
endgenerate
*/
/*
generate
  if (LINK_ID == 0 && CH_ID == 0) begin: sigtap_gen_RCV
//signaltap
wire [127:0] RCV_acq_data_in;
wire         RCV_acq_clk;

assign RCV_acq_clk = clk;

signaltap RCV_signaltap_inst (
  .acq_clk(RCV_acq_clk),
  .acq_data_in(RCV_acq_data_in),
  .acq_trigger_in(RCV_acq_data_in)
);

assign RCV_acq_data_in = {
//128
//112
//104
//96
//90
fmac_st_data[63:0],
//64
//48
fefo_rx_data[29:0],
fefo_rx_data_valid,
reg_ipg_err_cnt_en,

//32
reg_crc_err_cnt_en,
reg_length_err_cnt_en,
reg_rcv_fifo_empty,
reg_rcv_fifo_full,
reg_rcv_fifo_usedw[3:0],
//24
reg_fmac_fifo_empty,
reg_fmac_fifo_full,
reg_fmac_fifo_usedw[5:0],
//16
fmac_st_err_stat[7:0],
//8
fmac_st_valid,
fmac_st_sop,
fmac_st_eop,
fmac_st_empty,
fmac_st_avail,
fmac_st_err,
reg_fmac_fifo_empty,
rst_n
};

  end  // if LINK_ID, CH_ID
endgenerate
*/
/* fmac_rcv AUTO_TEMPLATE
    (
    .fmac_interval_stats    (ofmac_interval_stats),
    )
    */

fmac_rcv fmac_rcv
(       /*AUTOINST*/
        // Interfaces
        .fefo_dec_intf_0       (fefo_dec_intf_0),
        .fefo_dec_intf_1       (fefo_dec_intf_1),
        .fmac_interval_stats           (ofmac_interval_stats),          // Templated
        // Outputs
        .fmac_st_valid                 (fmac_st_valid),
        .fmac_st_data                  (fmac_st_data[63:0]),
        .fmac_st_sop                   (fmac_st_sop),
        .fmac_st_eop                   (fmac_st_eop),
        .fmac_st_empty                 (fmac_st_empty),
        .fmac_st_avail                 (fmac_st_avail),
        .fmac_st_vf_id                 (fmac_st_vf_id[11:0]),
        .fmac_st_err                   (fmac_st_err),
        .fmac_st_err_stat              (fmac_st_err_stat[7:0]),
        .reg_fmac_fifo_empty           (reg_fmac_fifo_empty),
        .reg_fmac_fifo_full            (reg_fmac_fifo_full),
        .reg_fmac_fifo_usedw           (reg_fmac_fifo_usedw[5:0]),
        .reg_rcv_fifo_empty            (reg_rcv_fifo_empty),
        .reg_rcv_fifo_full             (reg_rcv_fifo_full),
        .reg_rcv_fifo_usedw            (reg_rcv_fifo_usedw[3:0]),
        .reg_crc_err_cnt_en            (reg_crc_err_cnt_en),
        .reg_length_err_cnt_en         (reg_length_err_cnt_en),
        // Inputs
				.linkdown_event212_final       (linkdown_event212_final),
				.monitor_mode                  (iREG_LINKCTRL_MONITORMODE[1]),
        .int_stats_latch_clr           (int_stats_latch_clr),
        .fefo_rx_data                  (fefo_rx_data[63:0]),
        .fefo_rx_data_valid            (fefo_rx_data_valid),
        .int_stats_mincr               (int_stats_mincr[31:0]),
        .int_stats_maxcr               (int_stats_maxcr[31:0]),
        .int_stats_endcr               (int_stats_endcr[31:0]),
        .int_stats_timecr              (int_stats_timecr[31:0]),
        .reg_frame_max                 (reg_frame_max[15:0]),
        .reg_frame_min                 (reg_frame_min[15:0]),
        .reg_inj_crc_err               (reg_inj_crc_err),
        .reg_link_up_cnt_en            (reg_link_up_cnt_en),
        .reg_nos_ols_event             (reg_nos_ols_event),
        .reg_lr_lrr_event              (reg_lr_lrr_event),
        .reg_code_viol_cnt_inc         (reg_code_viol_cnt_inc),
        .reg_bad_eof_event             (reg_bad_eof_event),
        .reg_fmac_ctl_le_endianess     (reg_fmac_ctl_le_endianess),
        .reg_fmac_ctl_crc_disable      (reg_fmac_ctl_crc_disable),
        .rst_n                         (rst_n),
        .clk           (clk));


// ----------------
// Assertions
// ----------------

// synthesis translate_off


// synthesis translate_on




endmodule       //
