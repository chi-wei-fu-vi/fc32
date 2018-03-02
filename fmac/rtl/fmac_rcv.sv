//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_rcv.sv $
// $Author: chi-wei.fu $
// $Date: 2017-03-29 08:50:57 -0700 (Wed, 29 Mar 2017) $
// $Revision: 14579 $
//**************************************************************************/

module fmac_rcv
   (

    // ------------------------
    // Interfaces
    // ------------------------

    input  fmac_pkg::dec_intf               fefo_dec_intf_0,
    input  fmac_pkg::dec_intf               fefo_dec_intf_1,
    output fmac_pkg::fmac_interval_stats    fmac_interval_stats,
		input monitor_mode,
		input linkdown_event212_final,

    // ---------------------
    // Link Engine Interface
    // ---------------------

    // From FMAC FIFO.  Uses Avalon streaming interface.  

    output logic        fmac_st_valid,              // Avalon-ST data valid - data from FIFO is valid.  Asserted and
                                                    // held high while st_data is read from the FMAC FIFO and sent to
                                                    // the link engine.  This signal stays high until 
                                                    // fmac_st_eop is asserted to indicate end of packet.  

    output logic [63:0] fmac_st_data,               // Avalon-ST data from FMAC FIFO. valid on assertion of fmac_st_valid.
                                                    // frames will have SOF, EOF, and CRC fields removed.  Note that the 
                                                    // data is aligned so that on SOP assertion, the first 64b data word
                                                    // is always valid.  However, the last 64b data word (marked by EOP) 
                                                    // may only have one 32b word. 

    output logic        fmac_st_sop,                // Avalon-ST reive data start of packet.  Assertion indicates data 
                                                    // on st_data corresponds with the first 64b of a frame.  Valid 
                                                    // on assertion of fmac_st_valid.  

    output logic        fmac_st_eop,                // Avalon-ST receive data end of packet.  Assertion indicates data
                                                    // on st_data corresponds with the last 64b of a frame.   Valid 
                                                    // on assertion of fmac_st_valid.  In the case of an error, the last
                                                    // 64b of the frame will always have a eop to mark the end of the frame.

    output logic        fmac_st_empty,              // Avalon-ST empty - only valid on st_eop assertion.
                                                    // Indicates the number of empty 32b words on the EOP.
                                                    // 0 - no empty words (all 64b valid)
                                                    // 1 - one empty word (last 32b does not contain data)

    output logic        fmac_st_avail,              // receive frame available.  FMAC FIFO contains data and is ready 
                                                    // to be read.  The FMAC FIFO may not contain the complete frame.  

    output logic [11:0] fmac_st_vf_id,              // 12b virtual fabric ID extracted from the virtual fabric extended
                                                    // header.  Valid on assertion of fmac_st_sop and fmac_st_valid.  
                                                    // In case there was no virtual fabric extended header, this value
                                                    // defaults to 0xFFF which is one of two invalid VF_IDs.  

    output logic        fmac_st_err,                // receive frame error.  Asserted on last 64b of frame (assertion
                                                    // of fmac_st_eop) to indicate an error occurred while receiving
                                                    // the frame.  The error code is specified in fmac_st_err_stat[7:0].

    output logic [7:0]  fmac_st_err_stat,           // receive frame error code.  Only valid on assertion of fmac_st_err.
                                                    // Can be multi-hot to indicate multiple errors.  
                                                    //   [0] CRC error (asserted only if no other errors occur)
                                                    //   [1] invalid length - too short
                                                    //   [2] invalid length - too long 
                                                    //   [3] FC1 error (code violation, link/physical layer error)
                                                    //   [4] sequence error (missing EOF, SOF) (not implemented)
                                                    //   [7:5] RESERVED - set to zero

    input               int_stats_latch_clr,        // pulsed for one cycle - clears and latches interval stat counters

    // ----------------------
    // fmac_efifo Interface
    // ----------------------

    input [63:0]        fefo_rx_data,               // 64b data
    input               fefo_rx_data_valid,         // data valid

    // ----------------------------
    // fmac_credit_stats Interface
    // ----------------------------

    input [31:0]         int_stats_mincr,
    input [31:0]         int_stats_maxcr,
    input [31:0]         int_stats_endcr,
    input [31:0]        int_stats_timecr,

    // ----------------
    // FMAC regs
    // ----------------

    //input [7:0]         reg_fill_word_min,          // min count of fill words between frames
    input [15:0]        reg_frame_max,              // maximum frame length
    input [15:0]        reg_frame_min,              // minimum frame length
    input               reg_inj_crc_err,
    input               reg_link_up_cnt_en,         // rx_clk domain
    input               reg_nos_ols_event,
    input               reg_lr_lrr_event,
    input [1:0]         reg_code_viol_cnt_inc,
    input               reg_bad_eof_event,
    input               reg_fmac_ctl_le_endianess,  // 0=Big Endian, 1=Little Endian
    input               reg_fmac_ctl_crc_disable,

    output logic        reg_fmac_fifo_empty,        // FIFO status - empty
    output logic        reg_fmac_fifo_full,         // FIFO status - full
    output logic [5:0]  reg_fmac_fifo_usedw,        // FIFO status - usedw
    output logic        reg_rcv_fifo_empty,         // FIFO status - empty
    output logic        reg_rcv_fifo_full,          // FIFO status - full
    output logic [3:0]  reg_rcv_fifo_usedw,         // FIFO status - usedw
    //output logic        reg_ipg_err_cnt_en,
    output logic        reg_crc_err_cnt_en,
    output logic        reg_length_err_cnt_en,

    // ----------------
    // Reset & Clocks
    // ----------------
    input               rst_n,                      // asynchronous core clock chip reset
    input               clk                         // core clock, 212.5Mhz
    
    );

import fmac_pkg::*;

   //-----------------------
   // Declarations
   //-----------------------

   logic [63:0]                rx_data_q, rx_data_qq, rx_data_a, crc_data_in_be;
   logic [1:0]                 sof, eof, idle, nos, ols, lr, lrr, ccs, code_viol;
   logic [1:0]                 sof_q, eof_q, ccs_q, code_viol_q;
   logic [1:0]                 sof_qq, eof_qq, ccs_qq;
   logic [1:0]                 eof_a, ccs_a, code_viol_a;
   logic                       sof_a;
   logic                       in_ipg, in_ipg_q, in_frame, in_frame_q;
   logic                       in_frame_fp1, end_frame_fp2, in_frame_fp2;
   logic 		       new_frame_fp0, new_frame_fp1, new_frame_fp2;
   logic                       align64, align64_q;
   logic [1:0][1:0]            rx_type_a, rcv_type_fp0, rcv_type_fp1, rcv_type_fp2, fmac_fifo_type_fp2;
   logic [531:0]                unused;
   logic [63:0]                rcv_data_fp0, rcv_data_fp1, rcv_data_fp2;
   logic                       ipg_count_eq_254, ipg_count_eq_255;
   logic [7:0]                 ipg_count, ipg_count_d, frame_err_stat_fp2;
   logic                       fmac_fifo_empty, fmac_fifo_full, fmac_fifo_rd, fmac_fifo_dw_fp2;
   logic [95:0]                fmac_fifo_wr_data, fmac_fifo_rd_data;
   logic [31:0]                crc_out_be, crc_in_be, rcvd_crc, crc_invert_be, exp_crc;
   logic                       fp_pipe_advance;
   logic                       min_length_err_fp2, max_length_err_fp2;
   logic                       rcv_fifo_rd, other_frame_err_fp2, frame_err_fp2;
   logic 		       fmac_fifo_eop_fp2, fmac_fifo_sop_fp2, insert_eof_fp2;
   logic                       crc_check, crc_err_fp2, crc_check_d, crc_check_q;
   logic                       crc_end_dw_cnt;
   logic                       rcv_sof_fp0, rcv_sof_fp1, rcv_sof_fp2, cv_fp2;
   logic                       valid_fp0, valid_fp1, valid_fp2, vft_header_fp2;
   logic 		       length_cnt_eq_max_fp2, length_cnt_eq_max_m1_fp2, fmac_fifo_wr_fp2;
   logic [1:0]                 rcv_cv_fp2, rcv_eof_fp0, rcv_eof_fp1, rcv_eof_fp2;
   logic [13:0]                length_cnt_fp2, length_cnt_fp1;
   logic [11:0]                fmac_fifo_vf_id_fp2;
   genvar                      gi;

	 logic monitor_mode_state;
	 logic monitor_mode_s;

   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   monitor_mode_retime
     (
      .out_level    ( monitor_mode_s  ),
      .clk          ( clk        ),
      .rst_n        ( rst_n      ),
      .in_level     ( monitor_mode  )
      );



   //---------------------------
   // Renames and input flopping
   //---------------------------

   assign nos[1:0]       = {fefo_dec_intf_1.prim[FC1_PRIM_NOS],fefo_dec_intf_0.prim[FC1_PRIM_NOS]};
   assign ols[1:0]       = {fefo_dec_intf_1.prim[FC1_PRIM_OLS],fefo_dec_intf_0.prim[FC1_PRIM_OLS]};
   assign lr[1:0]        = {fefo_dec_intf_1.prim[FC1_PRIM_LR], fefo_dec_intf_0.prim[FC1_PRIM_LR]};
   assign lrr[1:0]       = {fefo_dec_intf_1.prim[FC1_PRIM_LRR],fefo_dec_intf_0.prim[FC1_PRIM_LRR]};
   assign idle[1:0]      = {fefo_dec_intf_1.idle,fefo_dec_intf_0.idle};
   assign sof[1:0]       = {fefo_dec_intf_1.sof,fefo_dec_intf_0.sof};
   assign eof[1:0]       = {fefo_dec_intf_1.eof,fefo_dec_intf_0.eof};
   assign ccs[1:0]       = (nos[1:0] | ols[1:0] | lr[1:0] | lrr[1:0] | idle[1:0]);
   assign code_viol[1:0] = {fefo_dec_intf_1.code_viol,fefo_dec_intf_0.code_viol};

   // three cycle pipeline to allow SOF and EOF stripping
   always_ff @(posedge clk) begin
      sof_q[1:0]         <= sof[1:0];
      eof_q[1:0]         <= eof[1:0];
      ccs_q[1:0]         <= ccs[1:0];
      code_viol_q[1:0]   <= code_viol[1:0];
      sof_qq[1:0]        <= sof_q[1:0];
      eof_qq[1:0]        <= eof_q[1:0];
      ccs_qq[1:0]        <= ccs_q[1:0];
      rx_data_q[63:0]    <= fefo_rx_data[63:0];
      rx_data_qq[63:0]   <= rx_data_q[63:0];
   end
   
   //***********************************************************************************************
   // Pre-processor
   //***********************************************************************************************
   // Frame processing is divided into a pre-processor and post-processor.
   // The pre-processor strips IDLEs and other CCSs, SOFs, EOFs and writes
   // frames into the RCV FIFO.  It also checks min IPG.  Each 32b word is
   // marked with the following control type:
   // 
   //   2'b00 : data
   //   2'b01 : SOF (first 32b word)
   //   2'b10 : EOF (last 32b word)
   //   2'b11 : error (code violation)
   // 
   //   Pre-processing does not throttle - it only strips words.  

   //-----------------------
   // Re-align
   //-----------------------
   // re-align 64b word so that SOF is located in first 32b word. There are two conditions:
   //
   //  align64 = 1'b1: 
   //          SOF                          <--- word1----->  <----word0---->
   //  rx_data_qq[63:32], rx_data_qq[31:0], rx_data_q[63:32], rx_data_q[31:0]
   // 
   //  align64 = 1'b0: 
   //  <----word0------>              SOF                     <-- word1----->
   //  rx_data_qq[63:32], rx_data_qq[31:0], rx_data_q[63:32], rx_data_q[31:0]
   //
   //  after alignment
   //
   //           data     sof           data        data                         eof   
   //   {word1[31:0],word0[31:0]}, {word3[31:0],word2[31:0]}, ... {ccs, wordn[31:0]}, {ccs,ccs}
   //
   //   or
   //           data     sof           data        data                 eof        data
   //   {word1[31:0],word0[31:0]}, {word3[31:0],word2[31:0]}, ... {wordn[31:0],wordn_1[31:0]}, {ccs,ccs}

   // align = 1'b1 indicates we are 64b aligned
   always_ff @(posedge clk or negedge rst_n) 
      align64_q <= ~rst_n    ? 1'b0 :
                   sof_qq[1] ? 1'b1 :
                   sof_qq[0] ? 1'b0 : align64_q;

   assign align64 = sof_qq[1] ? 1'b1 :
                    sof_qq[0] ? 1'b0 : align64_q;

   assign rx_data_a[63:0] = align64 ? rx_data_q[63:0] : {rx_data_q[31:0], rx_data_qq[63:32]};

   // sof_a is asserted on first aligned transmission word (32b).  Peek forward to identify SOF attributes
   assign sof_a           = sof_qq[0] | sof_qq[1];

   // eof_a is asserted on last aligned transmission word (32b).  Peek ahead to identify EOF attributes.
   assign eof_a[0]        = align64 ? eof_q[1] : eof_q[0];
   assign eof_a[1]        = align64 ? eof[0]   : eof_q[1];

   // ccs_a corresponds with aligned transmission word (32b)
   assign ccs_a[0]        = align64 ? ccs_q[0] : ccs_qq[1];
   assign ccs_a[1]        = align64 ? ccs_q[1] : ccs_q[0];

   // code_viol_a is from the previous cycle.  This allows us to terminate the frame on the last valid word
   assign code_viol_a[0]  = align64 ? code_viol[0] : code_viol_q[0];
   assign code_viol_a[1]  = align64 ? code_viol[1] : code_viol[0];

   assign rx_type_a[0] = sof_a          ? FC2_RCV_TYPE_SOF :
                         eof_a[0]       ? FC2_RCV_TYPE_EOF :
                         code_viol_a[0] || (in_frame_q & ccs_a[0]) ? FC2_RCV_TYPE_ERR : FC2_RCV_TYPE_DATA;

   // second type cannot be SOF
   assign rx_type_a[1] = eof_a[1]       ? FC2_RCV_TYPE_EOF :
                         code_viol_a[1] || (in_frame_q & ccs_a[1]) ? FC2_RCV_TYPE_ERR : FC2_RCV_TYPE_DATA;
   
   
   //-----------------------
   // Process
   //-----------------------

   // in_ipg indicates we are in the inter-packet gap.  It gets set on EOF and is cleared on SOF.
   // It gets cleared in error cases.

   // FIXME : add error cases
   assign in_ipg = |eof[1:0] ? 1'd1   :
                   sof[0]    ? 1'd0   :   // If sof[1], we are still in IPG
		   |sof_q[1:0] ? 1'd0 :
                   in_ipg_q;

   always_ff @(posedge clk or negedge rst_n)
     in_ipg_q <= ~rst_n ? 1'd0 : in_ipg;

   
   // in_frame indicates we are in the fibre channel frame. It used as a write enable for the RCV FIFO
   // assert in_frame on a sof.  de-assert on an error, idle, or eof.  On code violations, we do not
   // write the bad transmission word.  The prior word is marked with error which will be converted
   // to an EOF by the frame processor post RCV FIFO read.
   
   always_ff @(posedge clk or negedge rst_n)
     in_frame_q <= ~rst_n      ? 1'd0 :
                   sof_a       ? 1'd1 :
                   (in_frame_q & (|ccs_a[1:0] | |eof_a[1:0] | |code_viol_a[1:0])) ? 1'd0 :
                   in_frame_q;

   // suppress writes if we have a CCS (missing EOF condition).
   assign in_frame = (in_frame_q | sof_a); // & ~(|ccs_a);

   //------------------
   // minimum IDLE gap  
   //------------------
   // check IDLEs between packets meets min fill word limits

   assign ipg_count_eq_254 = (ipg_count[7:0]==8'd254);
   assign ipg_count_eq_255 = (ipg_count[7:0]==8'd255);

   // ipg_count_d does not wraparound once it reaches a max value of 255
   always_comb begin
      unique casez ({idle[1:0],ipg_count_eq_255,ipg_count_eq_254})
        4'b01_0? : ipg_count_d[7:0] = ipg_count[7:0]+8'd1;
        4'b01_1? : ipg_count_d[7:0] = 8'd255;
        4'b10_0? : ipg_count_d[7:0] = ipg_count[7:0]+8'd1;
        4'b10_1? : ipg_count_d[7:0] = 8'd255;
        4'b11_00 : ipg_count_d[7:0] = ipg_count[7:0]+8'd2;
        4'b11_01 : ipg_count_d[7:0] = 8'd255;
        4'b11_10 : ipg_count_d[7:0] = 8'd255;
        default  : ipg_count_d[7:0] = ipg_count[7:0];
      endcase
   end // always_comb

   // IPG count is incremented during IPG.  Gets cleared on in_ipg assertion.  lags in_ipg by one clock
   always_ff @(posedge clk or negedge rst_n)
        ipg_count[7:0] <= ~rst_n ? 8'd0 :
                          (in_ipg & eof[0]) ? 8'd1 :
                          (in_ipg & eof[1]) ? 8'd0 :
                          in_ipg            ? ipg_count_d[7:0] : ipg_count[7:0];

   // perform an IPG check on de-assertion of in_ipg
   //assign reg_ipg_err_cnt_en = (in_ipg_q & ~in_ipg) & (ipg_count[7:0]<reg_fill_word_min[7:0]);

   
   //-----------------------
   // RCV FIFO
   //-----------------------
   logic rcv_fifo_empty, rcv_fifo_full;


wire    rcv_fifo_almost_full;
wire    rcv_fifo_almost_empty;
wire    rcv_fifo_underflow;
wire    rcv_fifo_wr_rst_busy;
wire    rcv_fifo_rd_rst_busy;
wire    rcv_fifo_overflow;
s5_sfifo_16x72b rcv_fifo
     (// Outputs
 . almost_full          ( rcv_fifo_almost_full                               ), // output
 . almost_empty         ( rcv_fifo_almost_empty                              ), // output
 . underflow            ( rcv_fifo_underflow                                 ), // output
 . wr_rst_busy          ( rcv_fifo_wr_rst_busy                               ), // output
 . rd_rst_busy          ( rcv_fifo_rd_rst_busy                               ), // output
 . overflow             ( rcv_fifo_overflow                                  ), // output
 . din                  ( {4'h0,rx_type_a[1][1:0],rx_type_a[0][1:0],rx_data_a[63:0]} ), 
 . full                 ( rcv_fifo_full                                      ), 
 . dout                 ( {unused[3:0],rcv_type_fp0[1][1:0],rcv_type_fp0[0][1:0],rcv_data_fp0[63:0]} ), 
 . data_count           ( reg_rcv_fifo_usedw[3:0]                            ), // Inputs
 . clk                  ( clk                                                ), 
 . wr_en                ( in_frame                                           ), 
 . rd_en                ( rcv_fifo_rd                                        ), 
 . rst                  ( ~rst_n                                             ), 
 . empty                ( rcv_fifo_empty                                     )  
);



   assign rcv_fifo_rd = ~rcv_fifo_empty;

   always @(posedge clk)
	   begin
			 reg_rcv_fifo_empty <= rcv_fifo_empty;
			 reg_rcv_fifo_full  <= rcv_fifo_full;
		 end

   //*********************************************
   // Frame Processor - Post-processor
   //*********************************************
   // The frame processor performs integrity checks on frames read from the RCV FIFO.  It has a multi-cycle
   // pipeline.  It performs error checks in the fp2 pipe stage, and auto-inserts EOFs in the fp3
   // pipe stage.  When it inserts EOFs on errors, it stalls the pipeline and reads from the RCV FIFO.
   //
   // 1st cycle :     - read RCV FIFO (output flopped in FIFO)
   // 2nd cycle : fp0 - first CRC pipe stage
   // 3rd cycle : fp1 - second CRC pipe stage
   // 4th cycle : fp2 - error detection, CRC check, length check, cv check, insert EOF if needed
   // 5th cycle :     - write FMAC FIFO
   //
   // Note that the frame processing pipeline holds and interlocks from the fp2 stage.  Outputs of fp2
   // flops are checked for errors, and pipeline advancement is held from fp2 backwards.  The frame
   // processing pipeline is always moving so that in flight operations are processed even when
   // there is nothing in the RCV FIFO - flushing the pipeline in case of long periods of no frames.

   // -----------
   // Pipeline
   // -----------

   // pipe stage valids.  in stall case, rcv_fifo_rd is suppressed.  Continually moving
   always_ff @(posedge clk or negedge rst_n) begin
      valid_fp0 <= ~rst_n ? 1'd0 : rcv_fifo_rd;
      valid_fp1 <= ~rst_n ? 1'd0 : valid_fp0;
      valid_fp2 <= ~rst_n ? 1'd0 : valid_fp1;
   end

   // data flops.  Interlocks and holds based on EOF insertion.  Otherwise, continually moving.
   // There are no fp0 flops since RCV FIFO outputs are flopped and represent the fp0 pipe stage.
   always_ff @(posedge clk) begin
      rcv_data_fp1[63:0]   <= rcv_data_fp0[63:0];
      rcv_data_fp2[63:0]   <= rcv_data_fp1[63:0];
   end // always_ff @
   always_ff @(posedge clk or negedge rst_n) begin
      rcv_type_fp1[0][1:0] <= ~rst_n ? FC2_RCV_TYPE_DATA : rcv_type_fp0[0];
      rcv_type_fp2[0][1:0] <= ~rst_n ? FC2_RCV_TYPE_DATA : rcv_type_fp1[0];
      rcv_type_fp1[1][1:0] <= ~rst_n ? FC2_RCV_TYPE_DATA : rcv_type_fp0[1];
      rcv_type_fp2[1][1:0] <= ~rst_n ? FC2_RCV_TYPE_DATA : rcv_type_fp1[1];
   end // always_ff @

   // SOF must be in slot 0 since it is aligned
   assign rcv_sof_fp2 = (rcv_type_fp2[0][1:0]==FC2_RCV_TYPE_SOF);
   assign rcv_sof_fp1 = (rcv_type_fp1[0][1:0]==FC2_RCV_TYPE_SOF);
   assign rcv_sof_fp0 = (rcv_type_fp0[0][1:0]==FC2_RCV_TYPE_SOF);

   // EOF can be in slot 0 or 1
   assign rcv_eof_fp0[1] = (rcv_type_fp0[1][1:0]==FC2_RCV_TYPE_EOF);
   assign rcv_eof_fp0[0] = (rcv_type_fp0[0][1:0]==FC2_RCV_TYPE_EOF);
   assign rcv_eof_fp1[1] = (rcv_type_fp1[1][1:0]==FC2_RCV_TYPE_EOF);
   assign rcv_eof_fp1[0] = (rcv_type_fp1[0][1:0]==FC2_RCV_TYPE_EOF);
   assign rcv_eof_fp2[1] = (rcv_type_fp2[1][1:0]==FC2_RCV_TYPE_EOF);
   assign rcv_eof_fp2[0] = (rcv_type_fp2[0][1:0]==FC2_RCV_TYPE_EOF);
   assign rcv_cv_fp2[1]  = (rcv_type_fp2[1][1:0]==FC2_RCV_TYPE_ERR);
   assign rcv_cv_fp2[0]  = (rcv_type_fp2[0][1:0]==FC2_RCV_TYPE_ERR);

   // in_frame_fp2 : in frame state bit used by frame processor to indicate we are in 
   // the fibre channel frame.  Held high during frame.  Negated on EOF or ERROR types.
   // Note : in_frame_fp2 may stay high and never negate across multiple frames.

   assign new_frame_fp0 = (valid_fp0 & rcv_sof_fp0);

   assign end_frame_fp2 = (valid_fp1 & (rcv_type_fp1[0][1:0]==FC2_RCV_TYPE_EOF)) |    // last 32b is CRC - drop
                          (valid_fp2 & (rcv_type_fp2[1][1:0]==FC2_RCV_TYPE_EOF)) |
													insert_eof_fp2;
                           
   always_ff @(posedge clk or negedge rst_n) begin
      new_frame_fp1 <= ~rst_n                               ? 1'd0 :
		       new_frame_fp0;
      new_frame_fp2 <= ~rst_n                               ? 1'd0 :
		       new_frame_fp1;
      in_frame_fp1  <= ~rst_n                               ? 1'd0 :
                       new_frame_fp0                        ? 1'd1 :
                       (max_length_err_fp2 | end_frame_fp2) ? 1'd0 :
                       in_frame_fp1;
      in_frame_fp2  <= ~rst_n                               ? 1'd0 :
                       (max_length_err_fp2 | end_frame_fp2) ? 1'd0 :
                       in_frame_fp1;
   end

   //------------------
   // Length checking
   //------------------
   // Length cnt is incremented while we are inside the frame.  The count saturates.  Length
   // of frame is checked when we exit the frame.  Length error is suppressed on code violations.
   // Code violations increment only the code_viol_cnt.  Note length_cnt is in bytes, and
   // FC is always 4B aligned.  length_cnt counter is in double words (4B).

   assign length_cnt_eq_max_fp2    = (length_cnt_fp2[13:0]==14'h3FFF);
   assign length_cnt_eq_max_m1_fp2 = (length_cnt_fp2[13:0]==14'h3FFE);

   always_comb begin
      if (~rst_n)
	length_cnt_fp1[13:0] = 14'd0;
      else if (new_frame_fp1)
	length_cnt_fp1[13:0] = 14'd2;
      else begin
	 unique casez ({in_frame_fp1,rcv_eof_fp1[1],rcv_eof_fp1[0],length_cnt_eq_max_fp2,length_cnt_eq_max_m1_fp2})
	   5'b1_00_00 : length_cnt_fp1[13:0] = length_cnt_fp2[13:0] + 14'd2;
	   5'b1_00_01 : length_cnt_fp1[13:0] = 14'h3FFF;
	   5'b1_10_0? : length_cnt_fp1[13:0] = (length_cnt_fp2[13:0] + 14'd1);
	   default    : length_cnt_fp1[13:0] = length_cnt_fp2[13:0];
	 endcase // unique casez ({eof_fp[1],eof_fp[0],length_cnt_eq_max_fp2,length_cnt_eq_max_m1_fp2})
      end
   end // always_comb

   always_ff @(posedge clk or negedge rst_n)
     length_cnt_fp2[13:0] <= ~rst_n ? 14'd0 : length_cnt_fp1[13:0];

   // min length error is only checked at end of frame.  
   assign min_length_err_fp2 = (end_frame_fp2 & ({length_cnt_fp2[13:0],2'd0} < reg_frame_min[15:0]));

   // max length error truncates frame.  checked continuously. 
   assign max_length_err_fp2 = (in_frame_fp2 & ({length_cnt_fp2[13:0],2'd0} > reg_frame_max[15:0]));

   always_ff @(posedge clk or negedge rst_n)
      reg_length_err_cnt_en <= ~rst_n ? 1'b0 :  min_length_err_fp2 | max_length_err_fp2;
   
   // If the frame is missing an EOF, the pipeline is held and an EOF is inserted.
   //  no EOF, SOF detected :  SOF is in slot 0.  Insert a EOF in slot 0, mark the frame 
   //                           with error
   //  max_length_err       :  truncate frame.  Insert a EOF in slot 0, mark the frame with error


   logic expect_eop;
	 logic eop_case;
	 logic sop_case;

	 assign eop_case = fmac_fifo_eop_fp2 && valid_fp2 || insert_eof_fp2;
	 assign sop_case = fmac_fifo_sop_fp2 && valid_fp2 && in_frame_fp2;

   always_ff @(posedge clk or negedge rst_n)
	   if (!rst_n)
			 expect_eop <= 1'b0;
		 else if (eop_case)
			 expect_eop <= 1'b0;
		 else if (sop_case)
			 expect_eop <= 1'b1;

   //LZ
   //Some SFPs use internal PLLs to increas S/N ratio.  However, this also
	 //means that output (electrical) data can flatline when the PLL does not
	 //see enough transitions to stay in lock.  This change is abrupt and causes
	 //the RX recovery clock to disappear.  When the recovery clock flatlines,
	 //the rest of the packet/EOP can be delayed indefinitely.  When the clock
	 //finally resume, the resulting data is most likely corrupt.  This
	 //corruption causes an imbalance of SOP/EOP pairs in the future timestamp
	 //FIFO.  This imbalance causes interval stats packets to halt.
	 //The following timeout mechanism is designed to artificially insert an EOP
	 //should this error case happen.  This timeout is set to around 2x the maximum
	 //packet size of 2112 bytes ~= 4096 bytes / 64 = 512 clock cycles.
   logic [8:0] eop_timeout_cnt;
   logic eop_timeout, eop_timeout_r, eop_timeout_pulse;

	 //if top bits of count are ALL ONE, then signal EOP timeout event
	 //eop insertion will result and the count will be reset to ZERO in the next
	 //cycle
	 //This count will not be activated again until the next SOP event
   always_ff @(posedge clk or negedge rst_n)
	   if (!rst_n)
		 begin
			 eop_timeout <= 1'b0;
			 eop_timeout_r <= 1'b0;
			 eop_timeout_pulse <= 1'b0;
		 end
		 else
		 begin
			 eop_timeout <= &eop_timeout_cnt[8:2];  // give 4 cycles to reset count
			 eop_timeout_r <= eop_timeout;
			 eop_timeout_pulse <= eop_timeout && ~eop_timeout_r;
		 end

   //start counting once per clock on SOP event OR if count is non zero
	 //reset count to 0 on EOP event
   always_ff @(posedge clk or negedge rst_n)
	   if (!rst_n)
			 eop_timeout_cnt <= 'h0;
		 else if (eop_case)
			 eop_timeout_cnt <= 'h0;
		 else if (sop_case || |eop_timeout_cnt)
			 eop_timeout_cnt <= eop_timeout_cnt + 1;


   assign insert_eof_fp2  = (max_length_err_fp2 |                          // max length
	                           linkdown_event212_final |                     // link down event
														 eop_timeout_pulse   |                               // eop times out
                             rcv_cv_fp2[0] |                               // code violation
                             rcv_cv_fp2[1] |                               // code violation
														 sop_case      |
			     (rcv_sof_fp1 & (sop_case || ~|rcv_eof_fp2[1:0]) )) && expect_eop;        // data cycle, no EOF, SOF next


   
   //---------------------
   // Frame header parsing
   //---------------------
   // [7:0]     = R_CTL
   // [8]       = E
   // [9]       = Reserved=0
   // [13:10]   = Type
   // [15:14]   = Ver
   // [20:16]   = VF_ID[12:8] 
   // [23:21]   = Priority
   // [31:25]   = VF_ID[7:1]
   // [24]      = VF_ID[0]=0
   // 
   // Drop extended headers - any header with 0x5 in first nibble of R_CTL.
   //   - VFT header (R_CTL=0x50)
   //   - IFR header (R_CTL=0x51)
   //   - ENC header (R_CTL=0x52)
   // Identify the frame header.  Extract D_ID

   assign vft_header_fp2 = new_frame_fp2 & (rcv_data_fp2[7:0]==RCTL_VFT_HEADER);
 
   assign fmac_fifo_vf_id_fp2[11:0] = vft_header_fp2 ? {rcv_data_fp2[20:16],rcv_data_fp2[31:25]} : 12'hFFF;
   
   //------------------
   // CRC checking
   //------------------
   // Two cases to consider, depending on whether the frame ends in slot 0 or slot 1.  Note
   // that data is little endian.  In case the frame has one more 32b section to accumulate,
   // CRC check is delayed an additional cycle.  
   // 
   // EOF in slot 0:  FCS is in dataA and crc_check performed next cycle.  Note that results
   // of CRC accumulation starting where dw=X are don't care.  
   // 
   //  
   //                                                 | in_frame=1          | in_frame=0
   //  dw=0        |  dw=0       | dw=0 |    dw=X     | crc_check (early)   |
   //  SOF         |             | ..   |    EOF[0]   |                     |
   //  data1,data0 | data3,data2 | ..   | dataB,dataA |                     |
   //              |             | ..   |             | rcv_crc=dataA       |
   //                            | ..   | crc_out     |                     |
   //                            | ..   |             | (crc_in==rcv_crc)   |
   //                            | ..   |             | crc_err_fp2 (pulsed)| 
   //                                     
   // EOF in slot 1:  FCS is in dataB, dw=1 (32b) and crc_check performed two cycles after EOF
   // 
   //                                                                   | in_frame=1         
   //              |             | ..   |    dw=1     |                 | crc_check
   //  SOF         |             | ..   |    EOF[1]   |                 |
   //  data1,data0 | data3,data2 | ..   | dataB,dataA |                 |
   //              |             | ..   |             | rcv_crc=dataB   | rcv_crc=dataB
   //                            | ..   |             | crc_out         |                 
   //                            | ..   |             |                 | (crc_in==rcv_crc)        
   //                            | ..   |             |                 | crc_err_fp2 (pulsed)  

   // two cycle piplined.  CRC module is in big endian.  Data is in little endian. 
   fmac_rcv_crc fmac_rcv_crc
     (// Outputs
      .crc_out                          (crc_out_be[31:0]),  // big endian
      // Inputs
      .clk                              (clk),
      .data_in                          (crc_data_in_be[63:0]),
      .sop                              (rcv_sof_fp0),
      .dw_cnt                           (crc_end_dw_cnt),
      .crc_in                           (crc_in_be[31:0]));

   assign crc_data_in_be[63:0] = change_endian64(rcv_data_fp0[63:0]);
                            
   // dw_cnt=0 indicates 64b, dw_cnt=1 indicates 32b. 
   assign crc_end_dw_cnt = rcv_eof_fp0[1];

   always_ff @(posedge clk) 
      crc_in_be[31:0] <= crc_out_be[31:0];

   // CRC from frame frame is always captured one cycle after EOF_fp0.
   always_ff @(posedge clk or negedge rst_n)
     rcvd_crc[31:0] <= ~rst_n          ? 32'd0 :
                       rcv_eof_fp0[0] ? rcv_data_fp0[31:0] : 
                       rcv_eof_fp0[1] ? rcv_data_fp0[63:32] : rcvd_crc[31:0];

   // check the pipeline diagram.  crc_check is asserted in different cycles.  used to indicate
   // crc_err

   assign crc_check_d = (rcv_eof_fp1[0] | rcv_eof_fp2[1]) & in_frame_fp2;

   always_ff @(posedge clk or negedge rst_n)
     crc_check_q <= ~rst_n ? 1'b0 : crc_check_d;
   
   assign crc_check = (~crc_check_q & crc_check_d) & ~reg_fmac_ctl_crc_disable;

   // Calculated CRC is complemented.  There's also an endian swap to match endianess of rcvd_crc
   assign crc_invert_be[31:0] = ~crc_in_be[31:0];
   assign exp_crc[31:0]       = { bit_reversal(crc_invert_be[7:0]),
                                  bit_reversal(crc_invert_be[15:8]),
                                  bit_reversal(crc_invert_be[23:16]),
                                  bit_reversal(crc_invert_be[31:24]) };

   // crc_err asserted and stays high until next crc_check.  
   assign crc_err_fp2 = crc_check & ((rcvd_crc[31:0] != exp_crc[31:0]) & ~other_frame_err_fp2);
   assign reg_crc_err_cnt_en = crc_err_fp2;


   //------------------
   // Error Handling
   //------------------

   assign other_frame_err_fp2 = max_length_err_fp2;
   assign frame_err_fp2       = crc_err_fp2 | max_length_err_fp2 | min_length_err_fp2 | cv_fp2 | insert_eof_fp2;


   //-----------------------
   // FMAC FIFO
   //-----------------------
	 logic [5:0] fmac_fifo_usedw;

	 always @ (posedge clk)
	 begin
	   reg_fmac_fifo_empty <= fmac_fifo_empty;
		 reg_fmac_fifo_full  <= fmac_fifo_full;
		 reg_fmac_fifo_usedw <= fmac_fifo_usedw;
	 end


wire    mac_fifo_almost_full;
wire    mac_fifo_almost_empty;
wire    mac_fifo_underflow;
wire    mac_fifo_wr_rst_busy;
wire    mac_fifo_rd_rst_busy;
wire    mac_fifo_overflow;
s5_sfifo_64x96b mac_fifo
     (// Outputs
 . almost_full          ( mac_fifo_almost_full                               ), // output
 . almost_empty         ( mac_fifo_almost_empty                              ), // output
 . underflow            ( mac_fifo_underflow                                 ), // output
 . wr_rst_busy          ( mac_fifo_wr_rst_busy                               ), // output
 . rd_rst_busy          ( mac_fifo_rd_rst_busy                               ), // output
 . overflow             ( mac_fifo_overflow                                  ), // output
 . din                  ( fmac_fifo_wr_data[95:0]                            ), 
 . full                 ( fmac_fifo_full                                     ), 
 . dout                 ( fmac_fifo_rd_data[95:0]                            ), 
 . data_count           ( fmac_fifo_usedw[5:0]                               ), // Inputs
 . clk                  ( clk                                                ), 
 . wr_en                ( fmac_fifo_wr_fp2                                   ), 
 . rd_en                ( fmac_fifo_rd                                       ), 
 . rst                  ( ~rst_n                                             ), 
 . empty                ( fmac_fifo_empty                                    )  
);


   /* must write a cycle when eof is inserted due to error condition */
   assign fmac_fifo_wr_fp2 = in_frame_fp2 & valid_fp2 || insert_eof_fp2;

   assign fmac_fifo_wr_data[95:0] = {
                                     7'd0,                          // 95:89
                                     fmac_fifo_vf_id_fp2[11:0],     // 88:77
                                     frame_err_stat_fp2[7:0],       // 76:69
                                     frame_err_fp2,                 // 68
				     1'd0,                          // 67
                                     fmac_fifo_dw_fp2,              // 66
                                     fmac_fifo_eop_fp2,             // 65
                                     fmac_fifo_sop_fp2 && ~insert_eof_fp2,             // squelch SOP if inserting EOP
                                     rcv_data_fp2[63:0]             // 63:0
                                     };

   assign fmac_fifo_rd  = ~fmac_fifo_empty;

   // NOTE: - since we drop the CRC, the location of the EOF is shifted forwards by 32b
   //       - in case there's a missing EOF, insert one to terminate the frame

   assign fmac_fifo_eop_fp2   = (insert_eof_fp2 | 
				 rcv_eof_fp2[1] | 
                                 rcv_eof_fp1[0] );

   assign fmac_fifo_sop_fp2   = rcv_sof_fp2;

   // indicates only one dw
   assign fmac_fifo_dw_fp2        = rcv_eof_fp2[1];

   assign cv_fp2 = (|rcv_cv_fp2[1:0]);
   
   assign frame_err_stat_fp2[7:0] = {
                                     3'd0,                    // RESERVED - set to zero
                                     1'd0,                    // sequence error field
                                     cv_fp2,
                                     max_length_err_fp2,
                                     min_length_err_fp2,
                                     crc_err_fp2
                                     };
   logic dat_val;

   always_ff @(posedge clk or negedge rst_n)  
     dat_val <= ~rst_n ? 1'b0 : fmac_fifo_rd;

   assign fmac_st_valid = dat_val && monitor_mode_state;

  // extractor assumes big-endian.
   assign fmac_st_data[63:0] = change_endian64(fmac_fifo_rd_data[63:0]);
  // assign fmac_st_data[63:0] = reg_fmac_ctl_le_endianess ? change_endian64(fmac_fifo_rd_data[63:0]) : fmac_fifo_rd_data[63:0];
   
	 assign fmac_st_sop        = fmac_st_valid & fmac_fifo_rd_data[64];
   assign fmac_st_eop        = fmac_st_valid & fmac_fifo_rd_data[65];
   assign fmac_st_empty      = fmac_st_valid & fmac_fifo_rd_data[66];
   assign fmac_st_avail      = ~fmac_fifo_empty;
   assign fmac_st_err        = fmac_st_valid & fmac_fifo_rd_data[68];
   assign fmac_st_err_stat   = fmac_fifo_rd_data[76:69];
   assign fmac_st_vf_id[11:0] = fmac_fifo_rd_data[95:89];


   //-----------------------
   // Monitor mode state 
   //-----------------------
	 //When fmac is streaming an EOP or if fmac FIFO is empty, then sample the
	 //current state of MONITOR_MODE.  This will take effect on the next packet.
	 //If the mode is disabled, then the valid bit shall be squelched to the
	 //extractor and timestamp fifo.
   
	 always_ff @(posedge clk or negedge rst_n)  
	   if (!rst_n)
			 monitor_mode_state <= 'h0;
		 else if (fmac_st_eop || fmac_fifo_empty)
			 monitor_mode_state <= monitor_mode_s;


   //-----------------------
   // Interval Stats
   //-----------------------
   // Interval stat counters are cleared periodically by int_stats_latch_clr.  They accumulate
   // stats using the same enables as the free-running counters in fmac_regs

   /* vi_invl_stats_ctr AUTO_TEMPLATE
    (.latch_clr  (int_stats_latch_clr),
    ); */
   logic reg_link_up_cnt_en_s; 
   always_ff @(posedge clk or negedge rst_n)  
     reg_link_up_cnt_en_s <= ~rst_n ? 1'b0 : reg_link_up_cnt_en;

   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_link_up
     ( // Manual
       .latched_stats_ctr_r             (fmac_interval_stats.link_up_cnt[31:0]),
       .increment                       (reg_link_up_cnt_en_s),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated
   
   logic reg_nos_ols_event_s; 
   always_ff @(posedge clk or negedge rst_n)  
     reg_nos_ols_event_s <= ~rst_n ? 1'b0 : reg_nos_ols_event;

   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_nos_ols
     ( // Manual
       .latched_stats_ctr_r             (fmac_interval_stats.nos_ols_cnt[31:0]),
       .increment                       (reg_nos_ols_event_s),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated
   
   logic reg_lr_lrr_event_s; 
   always_ff @(posedge clk or negedge rst_n)  
     reg_lr_lrr_event_s <= ~rst_n ? 1'b0 : reg_lr_lrr_event;

   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_lr_lrr
     ( // Manual
       .latched_stats_ctr_r             (fmac_interval_stats.lr_lrr_cnt[31:0]),
       .increment                       (reg_lr_lrr_event_s),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated
  /* 2 control words are carried per block. so 2 counters are used to generate
	 * status.  The output are summed
	 */

   logic [7:0] code_viol0_cnt, code_viol1_cnt;

   logic reg_code_viol0_cnt_en_s; 
   always_ff @(posedge clk or negedge rst_n)  
     reg_code_viol0_cnt_en_s <= ~rst_n ? 1'b0 : reg_code_viol_cnt_inc[0];

   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_code_viol0
     ( // Manual
       .latched_stats_ctr_r             (code_viol0_cnt),
       .increment                       (reg_code_viol0_cnt_en_s),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated
  

   logic reg_code_viol1_cnt_en_s;
   always_ff @(posedge clk or negedge rst_n)  
     reg_code_viol1_cnt_en_s <= ~rst_n ? 1'b0 : reg_code_viol_cnt_inc[1];

   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_code_viol1
     ( // Manual
       .latched_stats_ctr_r             (code_viol1_cnt),
       .increment                       (reg_code_viol1_cnt_en_s),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated


   always_ff @(posedge clk or negedge rst_n)  
     fmac_interval_stats.code_viol_cnt[31:0] <= ~rst_n ? 'h0 : code_viol0_cnt + code_viol1_cnt;


   logic reg_crc_err_cnt_en_s; 
   always_ff @(posedge clk or negedge rst_n)  
     reg_crc_err_cnt_en_s <= ~rst_n ? 1'b0 : reg_crc_err_cnt_en;

   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_crc_err
     ( // Manual
       .latched_stats_ctr_r             (fmac_interval_stats.crc_err_cnt[31:0]),
       .increment                       (reg_crc_err_cnt_en_s),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated
   
   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_length_err
     ( // Manual
       .latched_stats_ctr_r             (fmac_interval_stats.length_err_cnt[31:0]),
       .increment                       (reg_length_err_cnt_en),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated
   
   logic reg_bad_eof_event_s; 
   always_ff @(posedge clk or negedge rst_n)  
     reg_bad_eof_event_s <= ~rst_n ? 1'b0 : reg_bad_eof_event;

   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_bad_eof_err
     ( // Manual
       .latched_stats_ctr_r             (fmac_interval_stats.bad_eof_cnt[31:0]),
       .increment                       (reg_bad_eof_event_s),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated

   vi_invl_stats_ctr #(.SIZE(8)) invl_stats_loss_sync
     ( // Manual
       .latched_stats_ctr_r             (fmac_interval_stats.loss_sync_cnt[31:0]),
       .increment                       (linkdown_event212_final),
       /*AUTOINST*/
      // Inputs
      .clk                              (clk),
      .rst_n                            (rst_n),
      .latch_clr                        (int_stats_latch_clr));  // Templated



   assign fmac_interval_stats.min_credit[31:0] = int_stats_mincr[31:0];
   assign fmac_interval_stats.max_credit[31:0] = int_stats_maxcr[31:0];
   assign fmac_interval_stats.end_credit[31:0] = int_stats_endcr[31:0];
   assign fmac_interval_stats.time_at_min_credit[31:0] = int_stats_timecr[31:0];

endmodule // fmac_rcv


// Local Variables:
// verilog-library-directories:(".")
// verilog-library-files:( "lib/s5_sfifo_64x96b.v" "lib/s5_sfifo_16x72b.v" "../../../../common/vi_lib/vi_sync_pulse.sv" "../../../../common/vi_lib/vi_invl_stats_ctr.sv")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:


