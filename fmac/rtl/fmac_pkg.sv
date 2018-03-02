//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_pkg.sv $
// $Author: chi-wei.fu $
// $Date: 2017-03-29 08:50:57 -0700 (Wed, 29 Mar 2017) $
// $Revision: 14579 $
//**************************************************************************/

package fmac_pkg;

   //--------------
   // Structs/Enums
   //--------------

   // FMAC interval stat registers - not all are used in interval stats.  This is a superset.  
   typedef struct packed {
      logic [31:0] link_up_cnt;              // FMAC link up events
      logic [31:0] code_viol_cnt;            // code violations per fibre channel spec
      logic [31:0] crc_err_cnt;              // payload CRC errors
      logic [31:0] length_err_cnt;           // frame length errors (too small, too large)
      logic [31:0] nos_ols_cnt;              // NOS/OLS count (only on transition)
      logic [31:0] lr_lrr_cnt;               // LR/LRR count (only on transition)
      logic [31:0] bad_eof_cnt;              // bad EOF special function count (normal-invalid, abort, terminate)
      logic [31:0] loss_sync_cnt;              // bad EOF special function count (normal-invalid, abort, terminate)
      logic [31:0] time_at_min_credit;       // time spent at minimum credit value, per 8 VCs
      logic [31:0] end_credit;                // end credit value, per 8 VCs
      logic [31:0] max_credit;                // maximum creidt count, per 8 VCs
      logic [31:0] min_credit;                // miniimum creidt count, per 8 VCs
      // The following are not used
//      logic [31:0] corrupted_err_cnt;    // frame corrupted due to FIFO, los, other issues
//      logic [31:0] sync_hdr_err_cnt;     // invalid sync header value
//      logic [31:0] type_dec_err_cnt;     // invalid transmission word type decode error
//      logic [31:0] sof_dec_err_cnt;      // SOF decode error (invalid modifier byte or order code)
//      logic [31:0] eof_dec_err_cnt;      // EOF decode error (invalid modifier byte or order code)
//      logic [31:0] other_dec_err_cnt;    // OTHER decode error (invalid modifier byte or order code)
//      logic [31:0] idle_dec_err_cnt;     // IDLE decode error (invalid control code)
//      logic [31:0] sof_cnt;              // SOF special function count
//      logic [31:0] eof_cnt;              // EOF special function count
//      logic [31:0] idle_cnt;             // IDLE special function count
//      logic [31:0] data_cnt;             // 32b data transmission words
//      logic [31:0] r_rdy_cnt;            // receiver ready primitive count
//      logic [31:0] vc_rdy_cnt;           // virtual circuit ready primitive count
//      logic [31:0] bb_scs_cnt;           // buffer to buffer state change (SOF) primtive
//      logic [31:0] bb_scr_cnt;           // buffer to buffer state change (R_RDY) primtive
   } fmac_interval_stats;
   
   // per slot decode attributes : 27b
   typedef struct packed {

      logic [3:0] reserved;

      logic       code_viol;              // code violation

      logic [7:0] err_vec;                // multi-hot decode error vector, per slot
                                          //  [0] : invalid 2b synchronization header field 
                                          //  [1] : invalid control word type
                                          //  [2] = SOF with invalid modifier byte or order code
                                          //  [3] = EOF with invalid modifier byte or order code
                                          //  [4] = other special function with invalid modifier byte or order code 
                                          //  [5] = IDLE with invalid control code
                                          //  [6] = invalid SOF sequence
                                          //  [7] = invalid EOF sequence
 
      logic       other;                  // Other special function per slot.  prim bus identifies the type
                                          // of special function

      logic       data;                   // Data 32b word per slot

      logic       idle;                   // IDLE special function per slot

      logic [7:0] prim;                    // primitive signal or sequence per slot.  must be one-hot
                                           //  [0] : R_RDY - receiver ready
                                           //  [1] : VC_RDY - virtual circuit ready
                                           //  [2] : BB_SCS - buffer-to-buffer state change (SOF)
                                           //  [3] : BB_SCR - buffer-to-buffer state change (R_RDY)
                                           //  [4] : NOS    - not operational
                                           //  [5] : OLS    - offline
                                           //  [6] : LR     - link reset
                                           //  [7] : LRR    - link reset response

      logic [2:0] eof_type;                // EOF type per slot (no invalid because EOF_A is default)
                                           //  000 : Terminate
                                           //  001 : Abort
                                           //  010 : Normal
                                           //  011 : Normal Invalid (error, default)

      logic       eof;                     // EOF delimiter per slot

      logic [2:0] sof_type;                // encoded SOF type per slot 
                                           //  000 : Initiate Class 2
                                           //  001 : Normal   Class 2
                                           //  010 : Initiate Class 3
                                           //  011 : Normal   Class 3
                                           //  100 : Fabric
                                           //  101 : Reserved 
                                           //  110 : Reserved 
                                           //  111 : Reserved (Invalid, error, default)

      logic       sof;                     // SOF delimiter per slot

//      logic [15:0] vc_id;                  // VC_ID field, used with vc_rdy primitives

  } dec_intf;

   //----------------------
   // Functions
   //-----------------------

   function [7:0] bit_reversal;
      input [7:0] data;
      begin
	 bit_reversal = {data[0], data[1], data[2], data[3],
			 data[4], data[5], data[6], data[7]};
      end
   endfunction

   // changes the endian.  Byte[7:0] to byte [63:56], byte [15:8] to byte [55:48] and so on
   function [63:0] change_endian64;
      input [63:0] data;
      begin
	 change_endian64 = {data[7:0], data[15:8], data[23:16], data[31:24],
			    data[39:32], data[47:40], data[55:48], data[63:56]};
      end
   endfunction

   //**********************************************************
   // Parameters   
   //**********************************************************

   // ---------------------
   // 64/66b FC16 preamble
   // ---------------------
   // 2b sync or preamble field from 66b word

   localparam   FC1_PREAMBLE_CTL      = 2'b01;
   localparam   FC1_PREAMBLE_DATA     = 2'b10;

   // ------------------
   // 64/66b FC16 types
   // ------------------
   // Used to decode the 1B type field in 64b control words (preamble = 2'b10).  Distinguishing between
   // RCVR_ERROR and IDLE_IDLE types requires further decode of the transmission word.  These are in
   // little endian format.  For example, SOF_IDLE indicates the first special function is IDLE, 
   // followed by SOF as the 2nd special function.  Note that the fibre channel documentation has this
   // in big-endian format. 
   
   localparam   FC1_TYPE_RCVR_ERROR    = 8'h1E;
   localparam   FC1_TYPE_IDLE_IDLE     = 8'h1E;
   localparam   FC1_TYPE_SOF_IDLE      = 8'h33;
   localparam   FC1_TYPE_IDLE_EOF      = 8'hB4;
   localparam   FC1_TYPE_OTHER_IDLE    = 8'h2D;
   localparam   FC1_TYPE_IDLE_OTHER    = 8'h4B;
   localparam   FC1_TYPE_OTHER_OTHER   = 8'h55;
   localparam   FC1_TYPE_SOF_OTHER     = 8'h66;
   localparam   FC1_TYPE_DATA_SOF      = 8'h78;
   localparam   FC1_TYPE_EOF_DATA      = 8'hFF;

   // --------------------------------------
   // 64/66b Special Functions
   // --------------------------------------
   // special function 3B modifier bytes
   
   // SOF
   localparam   FC1_SOF_I2_MODIFIER      = 24'h55_55_B5;     // SOF Initiate Class 2
   localparam   FC1_SOF_N2_MODIFIER      = 24'h35_35_B5;     // SOF Normal Class 2
   localparam   FC1_SOF_I3_MODIFIER      = 24'h56_56_B5;     // SOF Initiate Class 3
   localparam   FC1_SOF_N3_MODIFIER      = 24'h36_36_B5;     // SOF Normal Class 3
   localparam   FC1_SOF_F_MODIFIER       = 24'h58_58_B5;     // SOF Fabric

   // EOF
   localparam   FC1_EOF_TERM_MODIFIER    = 24'h75_75_95;     // EOF Terminate
   localparam   FC1_EOF_ABORT_MODIFIER   = 24'hF5_F5_95;     // EOF Abort
   localparam   FC1_EOF_NORM_MODIFIER    = 24'hD5_D5_95;     // EOF Normal
   localparam   FC1_EOF_NORM_I_MODIFIER  = 24'hD5_D5_8A;     // EOF Normal-Invalid

   // prmitives
   localparam   FC1_R_RDY_MODIFIER       = 24'h4A_4A_95;      // receiver ready
   localparam   FC1_VC_RDY_MODIFIER      = 8'hF5;      // virtual circuit ready
   localparam   FC1_BB_SCS_MODIFIER      = 24'h96_96_95;      // buffer-to-buffer state change (SOF)
   localparam   FC1_BB_SCR_MODIFIER      = 24'hD6_D6_95;      // buffer-to-buffer state change (R_RDY)
   localparam   FC1_NOS_MODIFIER         = 24'h45_BF_55;      // not operational
   localparam   FC1_OLS_MODIFIER         = 24'h55_8A_35;      // offline
   localparam   FC1_LR_MODIFIER          = 24'h49_BF_49;      // link reset
   localparam   FC1_LRR_MODIFIER         = 24'h49_BF_35;      // link reset response

   // --------------------------------------
   // FC1 Transmission Code Decode Interface
   // --------------------------------------

   // FC1 SOF Types
   localparam   FC1_SOF_I2_TYPE      = 3'b001;
   localparam   FC1_SOF_N2_TYPE      = 3'b010;
   localparam   FC1_SOF_I3_TYPE      = 3'b011;
   localparam   FC1_SOF_N3_TYPE      = 3'b100;
   localparam   FC1_SOF_F_TYPE       = 3'b101;
   localparam   FC1_SOF_INVALID_TYPE = 3'b111;

   // FC16 EOF Types
   localparam   FC1_EOF_TERM_TYPE    = 3'b001;
   localparam   FC1_EOF_ABORT_TYPE   = 3'b010;
   localparam   FC1_EOF_NORM_TYPE    = 3'b011;
   localparam   FC1_EOF_NORM_I_TYPE  = 3'b100;
   localparam   FC1_EOF_INVALID_TYPE = 3'b111;

   // --------------------------------------
   // Decode error vector fields
   // --------------------------------------
   localparam   FC1_ERR_VEC_INVAL_SYNC       = 0;          // invalid 2b sync field					 
   localparam   FC1_ERR_VEC_INVAL_CTL_WORD   = 1;          // invalid control word type					 
   localparam   FC1_ERR_VEC_INVAL_SOF        = 2;          // SOF with invalid modifier bytes or order code
   localparam   FC1_ERR_VEC_INVAL_EOF        = 3;          // EOF with invalid modifier bytes or order code
   localparam   FC1_ERR_VEC_INVAL_OTHER      = 4;          // other special function with invalid modifier byte or order code
   localparam   FC1_ERR_VEC_INVAL_IDLE       = 5;          // IDLE with invalid control codes
   localparam   FC1_ERR_VEC_INVAL_SOF_SEQ    = 6;          // SOF sequence error
   localparam   FC1_ERR_VEC_INVAL_EOF_SEQ    = 7;          // EOF sequence error

   // --------------------------------------
   // Primitive vector fields
   // --------------------------------------
   localparam   FC1_PRIM_R_RDY               = 0;          //  [1] : R_RDY - receiver ready
   localparam   FC1_PRIM_VC_RDY              = 1;          //  [2] : VC_RDY - virtual circuit ready
   localparam   FC1_PRIM_BB_SCS              = 2;          //  [3] : BB_SCS - buffer-to-buffer state change (SOF)
   localparam   FC1_PRIM_BB_SCR              = 3;          //  [4] : BB_SCR -  buffer-to-buffer state change (R_RDY)
   localparam   FC1_PRIM_NOS                 = 4;          //  [5] : NOS - not operational
   localparam   FC1_PRIM_OLS                 = 5;          //  [6] : OLS - offline
   localparam   FC1_PRIM_LR                  = 6;          //  [7] : LR - link reset
   localparam   FC1_PRIM_LRR                 = 7;          //  [8] : LRR - link reset response

   // --------------------------------------
   // RCV FIFO control word types
   // --------------------------------------
   localparam FC2_RCV_TYPE_DATA            = 2'b00;
   localparam FC2_RCV_TYPE_SOF             = 2'b01;
   localparam FC2_RCV_TYPE_EOF             = 2'b10;
   localparam FC2_RCV_TYPE_ERR             = 2'b11;

   // --------------------------------------
   // R_CTL frame header types
   // --------------------------------------

   localparam RCTL_VFT_HEADER              = 8'h50;
   localparam RCTL_IFR_HEADER              = 8'h51;
   localparam RCTL_ENC_HEADER              = 8'h52;

endpackage // fmac_pkg
