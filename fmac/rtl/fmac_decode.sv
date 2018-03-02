//*************************************************************************** // Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_decode.sv $
// $Author: leon.zhou $
// $Date: 2014-10-01 15:34:12 -0700 (Wed, 01 Oct 2014) $
// $Revision: 7356 $
//**************************************************************************/

   import fmac_pkg::*;
module fmac_decode
   (

    // ----------------
    // PCS interface
    // ----------------
    // If pcs_rx_valid/pcs_rx_sync is negated, all other interface signals are ignored.  

    input [1:0]                pcs_rx_hdr,            // 2b block sync header field
    input [63:0]               pcs_rx_data,           // 64b transmission word
    input                      pcs_rx_sync,           // 64b transmission word synced. 
    input                      pcs_rx_valid,          // rx_data and rx_hdr are valid.  Negated on errors


    // ----------------
    // Decode to EFIFO
    // ----------------
    // All decode attributes are flopped.  There is some qualification against error conditions
    // which can be detected in the single cycle the decoder operates.  If synced and valid, rx_data
    // is decoded into either a sof, eof, idle, data, or other.  For sof, eof, and other special
    // functions, additional fields are available to identify the type of special function.  

    output fmac_pkg::dec_intf  fdec_dec_intf_0,
    output fmac_pkg::dec_intf  fdec_dec_intf_1,

    output logic [63:0]        fdec_rx_data,        // 64b transmission word to elastic FIFO
    output logic               fdec_rx_data_valid,  // 64b transmission word is valid to elastic FIFO

    // ----------------
    // FMAC regs
    // ----------------
    input [7:0]         reg_fill_word_min,          // min count of fill words between frames
    output logic        reg_ipg_err_cnt_en,
    output logic        reg_sof_cnt_en,
		output logic        reg_eof_cnt_en,


    // ----------------
    // Stats
    // ----------------
    // These signals go into the core clock domain

//    output logic               reg_losync_cnt_en,   // loss of sync event, pulsed

    // ----------------
    // Reset & Clocks
    // ----------------
    input                      rx_rst_n,            // asynchronous recovered clock reset
    input                      rx_clk,               // recovered clock, ~219Mhz
		input                      clk,
		input                      rst_n,
    input  [3:0]          iREG_LINKCTRL_MONITORMODE,
		output logic mon_invl_mode


    );


   // -------------------
   // Declarations
   // -------------------

   logic                       rx_valid_d0, rx_valid_d1, rx_valid_d2, rx_good_d1;
   logic [63:0]                rx_data_d0, rx_data_d1;
   logic [7:0]                 rx_type_d0;
   logic [1:0][3:0]            rx_order_d0;
   logic [1:0][23:0]           rx_mod_d0;
   logic [1:0][27:0]           rx_control_d0;
   logic [1:0]                 rx_hdr_d0;
   logic                       control_word_d0, data_word_d0, invalid_word_d0;
   logic                       type_idle_idle_d0, type_sof_idle_d0, type_idle_eof_d0;
   logic                       type_other_idle_d0, type_idle_other_d0, type_other_other_d0, type_sof_other_d0;
   logic                       type_data_sof_d0, type_eof_data_d0, type_invalid_d0;
   logic [1:0]                 sof_raw_d0, eof_raw_d0, other_raw_d0, idle_raw_d0, data_raw_d0;
   logic [1:0][2:0]            sof_type_raw_d0, eof_type_raw_d0;
   logic [1:0]                 r_rdy_d0, vc_rdy_d0, bb_scs_d0, bb_scr_d0, nos_d0, ols_d0, lr_d0, lrr_d0;
   logic [1:0][5:0] 	       err_vec_d0;
   logic [1:0][7:0]            err_vec_d1;
   logic [1:0]                 sof_d1, eof_d1, other_d1, data_d1, idle_d1, code_viol_d1;
   logic [1:0][2:0]            sof_type_d1, eof_type_d1;
   logic                       nos_event, ols_event, lr_event, lrr_event;
   logic [1:0][7:0]            prim_d1;
   logic [1:0]                 fdec_sof;
   logic [1:0][2:0]            fdec_sof_type;
   logic [1:0]                 fdec_eof;
   logic [1:0][2:0]            fdec_eof_type;
   logic [1:0][7:0]            fdec_prim;
   logic [1:0]                 fdec_idle, fdec_code_viol;
   logic [1:0]                 fdec_data;
   logic [1:0]                 fdec_other;
   logic [1:0][7:0]            fdec_err_vec;
   logic 		       code_viol_d0;
   genvar                      gi;

//VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
// ERROR : refer comment below to why this won't work
// VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
   // *************************************
   // Pipeline Sequencing
   // *************************************
   // The decode pipeline is designed to interlock and collapse all incoming bubbles.  It can tolerate any
   // combination of bubbling from the PCS.  Pipe stages D2 and D1 are held based on the valid_d0.  This
   // prevents clobbering of pipeline state with garbage when pcs_rx_valid/pcs_rx_sync is not asserted.
   // Note that D1 peeks at D2 and D0 state - which requires interlocking of D2 and D1 state.  There is
   // a startup phenomenon since initially, D2 and D1 pipe stages are invalid.  If the very first 
   // transmission word is a SOF/EOF delimiter, it will not be recognized because correct error decoding 
   // requires one prior valid transmission word.  
   // 
   //   |  D2          |     D1       |  D0   | Transport |
   //   --------------------------------------------
   //   |  V=0    RV=0 |  V=0     G=0 |  V=0  |   V=1     |
   //   |  V=0(H) RV=0 |  V=0(H)  G=0 |  V=1  |   V=0     |
   //   |  V=0    RV=0 |  V=1     G=0 |  V=0  |   V=1     |
   //   |  V=0(H) RV=0 |  V=1(H)  G=0 |  V=1  |   V=0     |
   //   |  V=1    RV=0 |  V=1     G=0 |  V=0  |   V=1     |
   //   |  V=1(H) RV=0 |  V=1(H)  G=1 |  V=1  |   V=0     |
   //   |  V=1    RV=1 |  V=1     G=0 |  V=0  |   V=1     |
   //   |  V=1(H) RV=0 |  V=1(H)  G=1 |  V=1  |   V=0     |
   //   |  V=1    RV=1 |  V=1     G=0 |  V=0  |   V=0     |
   //   |  V=1(H) RV=0 |  V=1(H)  G=0 |  V=0  |   V=1     |
   //   |  V=1(H) RV=0 |  V=1(H)  G=1 |  V=1  |   V=1     |
   //   |  V=1    RV=1 |  V=1     G=1 |  V=1  |   V=1     |
   //
   //   valid_d0 :  pipelined version of valid_transport
   //   valid_d1 :  hold if valid_d0=0, otherwise flop valid_d0
   //   valid_d2 :  hold if valid_d0=0, otherwise flop valid_d1
   //   good_d1  :  valid_d0 & valid_d1 & valid_d2
   //   rx_valid :  flopped version of good_d1
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// ERROR : refer comment below to why this won't work
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   mon_invl_mode_retime
     (
      .out_level    ( mon_invl_mode  ),
      .clk          ( rx_clk        ),
      .rst_n        ( rx_rst_n      ),
      .in_level     ( (|iREG_LINKCTRL_MONITORMODE[1:0])  )
      );

   
   always_ff @(posedge rx_clk or negedge rx_rst_n) begin
      rx_valid_d0        <= ~rx_rst_n   ? 1'b0 : (pcs_rx_sync & pcs_rx_valid & mon_invl_mode);
      //rx_valid_d1        <= ~rx_rst_n   ? 1'b0 :
                            //rx_valid_d0 ? rx_valid_d0 : rx_valid_d1;
      //rx_valid_d2        <= ~rx_rst_n   ? 1'b0 :
                            //rx_valid_d0 ? rx_valid_d1 : rx_valid_d2;
      //fdec_rx_data_valid <= ~rx_rst_n   ? 1'b0 : rx_good_d1;
   end


/*The above scheme is erroneous.  the 
 * rx_valid_d1 <= rx_valid_d0 ==1 || rx_valid_d1 
 * statement converts all stall cycles at rx_valid_d0 to valid cycles at
 * rx_valid_d1.  This has the effect of replicating a data cycle whenever
 * the input interface has a stall.  Verification shows the same data getting
 * replicated at the FMAC output, thus causing corruption.
 *
 * Generally, for pipelines, each stall at input is just carried over the entire
 * pipe--including the output enable signal.  Thus input stall stalls the
 * entire path. This way, the bubble would get absorbed by the FIFO block downstream.
 *
 * There is no point to crunch bubbles in a pipeline.  A synchronous pipeline, by
 * definition, has matched input and output data rate.  To perform bubble
 * crunching correctly, one needs bypass routes at each stage, thus advancing
 * data to replace bubbles.  The max bubble crunch capability is equal to # of
 * stages - 1.  Pipe optimization is only beneficial w/ asymmetric instruction/data sets.
 * In this case, the compares (ops) are symmetric, thus any temporary gain w/ 
 * bubble crunching will only mean a larger burst of bubbles later on. 
 */

	 assign rx_valid_d1 = rx_valid_d0;
	 assign rx_valid_d2 = rx_valid_d0;
	 assign fdec_rx_data_valid = rx_valid_d0;

   assign rx_good_d1 = (|sof_d1[1:0] | |eof_d1[1:0]) ? (rx_valid_d0 & rx_valid_d1 & rx_valid_d2) :
                       rx_valid_d1;

   // *************************************
   // Pipe Stage D0
   // *************************************
   // primary decode stage.  Always flops in from PCS, even if data is not valid.  Later pipe stages
   // interlocks to prevent clobbering.  
   
   // -------------------
   // Block decodes
   // -------------------
   
   // flop PCS inputs for timing
   
   always_ff @(posedge rx_clk or negedge rx_rst_n) begin
      //rx_hdr_d0[1:0]    <= !rx_rst_n ? 2'd0 : {2{pcs_rx_sync & pcs_rx_valid}} & pcs_rx_hdr[1:0];
      rx_hdr_d0[1:0]    <= !rx_rst_n ? 2'd0 : pcs_rx_hdr[1:0];
   end
   
   always_ff @(posedge rx_clk or negedge rx_rst_n)
	    //input byte boundary endianess control.
				//rx_data_d0[63:0]  <= !rx_rst_n ? 'h0 : {64{pcs_rx_sync & pcs_rx_valid}} & pcs_rx_data[63:0]; 
				rx_data_d0[63:0]  <= !rx_rst_n ? 'h0 : pcs_rx_data[63:0]; 
   
   // renames for clarity
   assign rx_type_d0[7:0]        = rx_data_d0[7:0];             // 8b transmission word type
   assign rx_order_d0[0][3:0]    = rx_data_d0[35:32];           // 4b order code
   assign rx_order_d0[1][3:0]    = rx_data_d0[39:36];           // 4b order code
   assign rx_mod_d0[0][23:0]     = rx_data_d0[31:8];            // 3x8b modifier bytes
   assign rx_mod_d0[1][23:0]     = rx_data_d0[63:40];           // 3x8b modifier bytes
   assign rx_control_d0[0][27:0] = rx_data_d0[35:8];            // 4x7b control codes
   assign rx_control_d0[1][27:0] = rx_data_d0[63:36];           // 4x7b control codes

   // sync field decode
   assign control_word_d0  = (rx_hdr_d0[1:0]==FC1_PREAMBLE_CTL);
   assign data_word_d0     = (rx_hdr_d0[1:0]==FC1_PREAMBLE_DATA);
   assign invalid_word_d0  = (~control_word_d0 & ~data_word_d0);

   // type field decode
   assign type_idle_idle_d0   = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_IDLE_IDLE);
   assign type_sof_idle_d0    = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_SOF_IDLE);
   assign type_idle_eof_d0    = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_IDLE_EOF);
   assign type_idle_other_d0  = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_IDLE_OTHER);
   assign type_other_idle_d0  = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_OTHER_IDLE);
   assign type_other_other_d0 = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_OTHER_OTHER);
   assign type_sof_other_d0   = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_SOF_OTHER);
   assign type_data_sof_d0    = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_DATA_SOF);
   assign type_eof_data_d0    = control_word_d0 & (rx_type_d0[7:0]==FC1_TYPE_EOF_DATA);
   assign type_invalid_d0     = control_word_d0 & ~(type_idle_idle_d0 | type_sof_idle_d0 |
                                                    type_idle_eof_d0  | type_idle_other_d0 | type_other_idle_d0 |
                                                    type_other_other_d0 | type_sof_other_d0 |
                                                    type_data_sof_d0 | type_eof_data_d0);

   // -------------------
   // Special Functions
   // -------------------
   
   // IDLE
   assign idle_raw_d0[0] = type_idle_idle_d0 | type_sof_idle_d0 | type_other_idle_d0;
   assign idle_raw_d0[1] = type_idle_idle_d0 | type_idle_eof_d0 | type_idle_other_d0;

   // SOF
   assign sof_raw_d0[0]  = type_data_sof_d0;
   assign sof_raw_d0[1]  = type_sof_idle_d0 | type_sof_other_d0;

   // EOF 
   assign eof_raw_d0[0]  = type_idle_eof_d0;
   assign eof_raw_d0[1]  = type_eof_data_d0;

   // Other
   assign other_raw_d0[0] = type_other_other_d0 | type_idle_other_d0 | type_sof_other_d0;
   assign other_raw_d0[1] = type_other_other_d0 | type_other_idle_d0;
   
   // Data
   assign data_raw_d0[0]  = type_eof_data_d0 | data_word_d0;
   assign data_raw_d0[1]  = type_data_sof_d0 | data_word_d0;
   

   // -------------------
   // SOF/EOF Decode
   // -------------------

   // SOF decode 
   // --------------
   
   always_comb begin

      // slot 0 does not have an order code
      if (sof_raw_d0[0]) begin
         unique case (rx_mod_d0[0][23:0])
           FC1_SOF_I2_MODIFIER : sof_type_raw_d0[0][2:0] = FC1_SOF_I2_TYPE;
           FC1_SOF_N2_MODIFIER : sof_type_raw_d0[0][2:0] = FC1_SOF_N2_TYPE;
           FC1_SOF_I3_MODIFIER : sof_type_raw_d0[0][2:0] = FC1_SOF_I3_TYPE;
           FC1_SOF_N3_MODIFIER : sof_type_raw_d0[0][2:0] = FC1_SOF_N3_TYPE;
           FC1_SOF_F_MODIFIER  : sof_type_raw_d0[0][2:0] = FC1_SOF_F_TYPE;
           default              : sof_type_raw_d0[0][2:0] = FC1_SOF_INVALID_TYPE;
         endcase // unique case (rx_mod[0][23:0])
      end else 
         sof_type_raw_d0[0][2:0] = FC1_SOF_INVALID_TYPE;

      // slot 1 has order code
      if (sof_raw_d0[1] & (rx_order_d0[1][3:0]==4'h0)) begin
         unique case (rx_mod_d0[1][23:0])
           FC1_SOF_I2_MODIFIER : sof_type_raw_d0[1][2:0] = FC1_SOF_I2_TYPE;
           FC1_SOF_N2_MODIFIER : sof_type_raw_d0[1][2:0] = FC1_SOF_N2_TYPE;
           FC1_SOF_I3_MODIFIER : sof_type_raw_d0[1][2:0] = FC1_SOF_I3_TYPE;
           FC1_SOF_N3_MODIFIER : sof_type_raw_d0[1][2:0] = FC1_SOF_N3_TYPE;
           FC1_SOF_F_MODIFIER  : sof_type_raw_d0[1][2:0] = FC1_SOF_F_TYPE;
           default              : sof_type_raw_d0[1][2:0] = FC1_SOF_INVALID_TYPE;
         endcase // unique case (rx_mod[1][23:0])
      end else 
        sof_type_raw_d0[1][2:0] = FC1_SOF_INVALID_TYPE;

   end // always_comb
      
   // EOF decode
   // --------------
   
   always_comb begin

      // slot 0 has an order code
      if (eof_raw_d0[0] & (rx_order_d0[0][3:0]==4'h0)) begin
         unique case (rx_mod_d0[0][23:0])
           FC1_EOF_TERM_MODIFIER   : eof_type_raw_d0[0][2:0] = FC1_EOF_TERM_TYPE;
           FC1_EOF_ABORT_MODIFIER  : eof_type_raw_d0[0][2:0] = FC1_EOF_ABORT_TYPE;
           FC1_EOF_NORM_MODIFIER   : eof_type_raw_d0[0][2:0] = FC1_EOF_NORM_TYPE;
           FC1_EOF_NORM_I_MODIFIER : eof_type_raw_d0[0][2:0] = FC1_EOF_NORM_I_TYPE;
           default                  : eof_type_raw_d0[0][2:0] = FC1_EOF_INVALID_TYPE;
         endcase // unique case (rx_mod[0][23:0])
      end
      else 
        eof_type_raw_d0[0][2:0] = FC1_EOF_INVALID_TYPE;

      // slot 1 does not have an order code
      if (eof_raw_d0[1]) begin
         unique case (rx_mod_d0[1][23:0])
           FC1_EOF_TERM_MODIFIER   : eof_type_raw_d0[1][2:0] = FC1_EOF_TERM_TYPE;
           FC1_EOF_ABORT_MODIFIER  : eof_type_raw_d0[1][2:0] = FC1_EOF_ABORT_TYPE;
           FC1_EOF_NORM_MODIFIER   : eof_type_raw_d0[1][2:0] = FC1_EOF_NORM_TYPE;
           FC1_EOF_NORM_I_MODIFIER : eof_type_raw_d0[1][2:0] = FC1_EOF_NORM_I_TYPE;
           default                  : eof_type_raw_d0[1][2:0] = FC1_EOF_INVALID_TYPE;
         endcase // unique case (rx_mod[1][23:0])
      end
      else 
        eof_type_raw_d0[1][2:0] = FC1_EOF_INVALID_TYPE;

   end // always_comb

   // -------------------
   // Primitives
   // -------------------

   generate
      for (gi=0; gi<2; gi=gi+1) begin: gen_prim_decode
         assign r_rdy_d0[gi]   = other_raw_d0[gi] & (rx_mod_d0[gi][23:0]==FC1_R_RDY_MODIFIER)  & (rx_order_d0[gi][3:0]==4'hF);
         assign vc_rdy_d0[gi]  = other_raw_d0[gi] & (rx_mod_d0[gi][7:0]==FC1_VC_RDY_MODIFIER)  & (rx_order_d0[gi][3:0]==4'hF);
         assign bb_scs_d0[gi]  = other_raw_d0[gi] & (rx_mod_d0[gi][23:0]==FC1_BB_SCS_MODIFIER) & (rx_order_d0[gi][3:0]==4'hF);
         assign bb_scr_d0[gi]  = other_raw_d0[gi] & (rx_mod_d0[gi][23:0]==FC1_BB_SCR_MODIFIER) & (rx_order_d0[gi][3:0]==4'hF);
         assign nos_d0[gi]     = other_raw_d0[gi] & (rx_mod_d0[gi][23:0]==FC1_NOS_MODIFIER)    & (rx_order_d0[gi][3:0]==4'h0);
         assign ols_d0[gi]     = other_raw_d0[gi] & (rx_mod_d0[gi][23:0]==FC1_OLS_MODIFIER)    & (rx_order_d0[gi][3:0]==4'h0);
         assign lr_d0[gi]      = other_raw_d0[gi] & (rx_mod_d0[gi][23:0]==FC1_LR_MODIFIER)     & (rx_order_d0[gi][3:0]==4'h0);
         assign lrr_d0[gi]     = other_raw_d0[gi] & (rx_mod_d0[gi][23:0]==FC1_LRR_MODIFIER)    & (rx_order_d0[gi][3:0]==4'h0);
      end
   endgenerate

   // Decode errors are multi-hot.  Errors detected in single cycle D0 stage.  Generation of errors in D0 stage 
   // reduces some of the pipelining.
   generate
      for (gi=0; gi<2; gi=gi+1) begin: gen_err_vec_d
         assign err_vec_d0[gi][FC1_ERR_VEC_INVAL_SYNC]         = invalid_word_d0;
         assign err_vec_d0[gi][FC1_ERR_VEC_INVAL_CTL_WORD]     = type_invalid_d0;
         assign err_vec_d0[gi][FC1_ERR_VEC_INVAL_SOF]          = (sof_raw_d0[gi] & (sof_type_raw_d0[gi][2:0]==FC1_SOF_INVALID_TYPE));
         assign err_vec_d0[gi][FC1_ERR_VEC_INVAL_EOF]          = (eof_raw_d0[gi] & (eof_type_raw_d0[gi][2:0]==FC1_EOF_INVALID_TYPE));
         assign err_vec_d0[gi][FC1_ERR_VEC_INVAL_OTHER]        = (other_raw_d0[gi] & ~(r_rdy_d0[gi] | vc_rdy_d0[gi] | bb_scs_d0[gi] | bb_scr_d0[gi] |
                                                                                          nos_d0[gi] | ols_d0[gi]| lr_d0[gi] | lrr_d0[gi]));
         assign err_vec_d0[gi][FC1_ERR_VEC_INVAL_IDLE]         = (idle_raw_d0[0] & (rx_control_d0[0][27:0]!=28'd0)) |
                                                                    (idle_raw_d0[1] & (rx_control_d0[1][27:0]!=28'd0));
      end
   endgenerate

   assign code_viol_d0 = |err_vec_d0[0][5:0] | |err_vec_d0[1][5:0];
   

   // *************************************
   // Pipe Stage D1
   // *************************************
   // This pipe stage interlocks and holds if rx_valid_d0 is not asserted.  We don't want
   // to clobber the next pipe stage with garbage data in case the PCS interface bubbles.

   generate
      for (gi=0; gi<2; gi=gi+1) begin: gen_d1_pipe
         always_ff @(posedge rx_clk or negedge rx_rst_n) begin
				    if (!rx_rst_n) begin
							sof_type_d1[gi][2:0] <= 'h0;
							eof_type_d1[gi][2:0] <= 'h0;
							sof_d1[gi]           <= 'h0;
							eof_d1[gi]           <= 'h0;
							idle_d1[gi]          <= 'h0;
							other_d1[gi]         <= 'h0;
							data_d1[gi]          <= 'h0;
							err_vec_d1[gi][5:0]  <= 'h0;

						end
            else if (rx_valid_d0) begin
               sof_type_d1[gi][2:0] <= sof_type_raw_d0[gi][2:0];
               eof_type_d1[gi][2:0] <= eof_type_raw_d0[gi][2:0];
               sof_d1[gi]           <= sof_raw_d0[gi];
               eof_d1[gi]           <= eof_raw_d0[gi];
               idle_d1[gi]          <= idle_raw_d0[gi];
               other_d1[gi]         <= other_raw_d0[gi];
               data_d1[gi]          <= data_raw_d0[gi];
               err_vec_d1[gi][5:0]  <= err_vec_d0[gi][5:0];
            end
         end // always_ff @
      end // block: gen_d1_pipe      
   endgenerate

   always_ff @(posedge rx_clk or negedge rx_rst_n) 
	   if (!rx_rst_n)
			 rx_data_d1[63:0]   <= 'h0;
     else if (rx_valid_d0)
       rx_data_d1[63:0]   <= rx_data_d0[63:0];
   
   generate
      for (gi=0; gi<2; gi=gi+1) begin: gen_prim
         always_ff @(posedge rx_clk or negedge rx_rst_n) begin
				    if (!rx_rst_n) begin
							prim_d1[gi][FC1_PRIM_R_RDY]    <= 'h0;
							prim_d1[gi][FC1_PRIM_VC_RDY]   <= 'h0;
							prim_d1[gi][FC1_PRIM_BB_SCS]   <= 'h0;
							prim_d1[gi][FC1_PRIM_BB_SCR]   <= 'h0;
							prim_d1[gi][FC1_PRIM_NOS]      <= 'h0;
							prim_d1[gi][FC1_PRIM_OLS]      <= 'h0;
							prim_d1[gi][FC1_PRIM_LR]       <= 'h0;
							prim_d1[gi][FC1_PRIM_LRR]      <= 'h0;
						end
            else if (rx_valid_d0) begin
               prim_d1[gi][FC1_PRIM_R_RDY]    <= r_rdy_d0[gi];
               prim_d1[gi][FC1_PRIM_VC_RDY]   <= vc_rdy_d0[gi];
               prim_d1[gi][FC1_PRIM_BB_SCS]   <= bb_scs_d0[gi];
               prim_d1[gi][FC1_PRIM_BB_SCR]   <= bb_scr_d0[gi];
               prim_d1[gi][FC1_PRIM_NOS]      <= nos_d0[gi];
               prim_d1[gi][FC1_PRIM_OLS]      <= ols_d0[gi];
               prim_d1[gi][FC1_PRIM_LR]       <= lr_d0[gi];
               prim_d1[gi][FC1_PRIM_LRR]      <= lrr_d0[gi];
            end
         end
      end
   endgenerate
   
   
   // ---------------------
   // Sequence Errors 
   // ---------------------
   // Need to peek at prior (d0) and following (d2) pipe stages

   generate
      for (gi=0; gi<2; gi=gi+1) begin: gen_d1_errors

         // SOF sequence error
         //  - prior transmission word was a data word
         //  - prior transmission word contained a SOF
         //  - prior transmission word caused a coding violation
         assign err_vec_d1[gi][FC1_ERR_VEC_INVAL_SOF_SEQ]      = (sof_d1[gi] & (sof_type_d1[gi][2:0]!=FC1_SOF_INVALID_TYPE) &
                                                                  (fdec_data[0] | fdec_data[1] | fdec_sof[1] | fdec_sof[0] | code_viol_d0));

         // EOF sequence error
         //  - following transmission word is a data word
         //  - following transmission word contains a EOF
         //  - following transmission word causes a coding violation
         assign err_vec_d1[gi][FC1_ERR_VEC_INVAL_EOF_SEQ]      = (eof_d1[gi] & (eof_type_d1[gi][2:0]!=FC1_EOF_INVALID_TYPE) &
                                                                  (data_raw_d0[0] | data_raw_d0[1] | eof_raw_d0[1] | eof_raw_d0[0] | |fdec_code_viol[1:0]));
         
      end
   endgenerate
                                                                   


   // *************************************
   // Pipe Stage D2
   // *************************************
   // This pipe stage interlocks and holds so that we don't lose data when the front-end bubles. 

   generate
      for (gi=0; gi<2; gi=gi+1) begin: gen_d2_pipe
         always_ff @(posedge rx_clk or negedge rx_rst_n) begin
				    if (!rx_rst_n) begin
							fdec_sof_type[gi][2:0] <= 'h0;
							fdec_eof_type[gi][2:0] <= 'h0;
							fdec_sof[gi]           <= 'h0;
							fdec_eof[gi]           <= 'h0;
							fdec_other[gi]         <= 'h0;
							fdec_data[gi]          <= 'h0;
							fdec_idle[gi]          <= 'h0;
							fdec_err_vec[gi][7:0]  <= 'h0;
							fdec_prim[gi][7:0]     <= 'h0;
						end
            else if (rx_valid_d0) begin
               fdec_sof_type[gi][2:0] <= sof_type_d1[gi][2:0];
               fdec_eof_type[gi][2:0] <= eof_type_d1[gi][2:0];
               fdec_sof[gi]           <= sof_d1[gi] & ~err_vec_d1[gi][FC1_ERR_VEC_INVAL_SOF_SEQ];
               fdec_eof[gi]           <= eof_d1[gi] & ~err_vec_d1[gi][FC1_ERR_VEC_INVAL_EOF_SEQ];
               fdec_other[gi]         <= other_d1[gi] & ~code_viol_d1[gi];
               fdec_data[gi]          <= data_d1[gi] & ~code_viol_d1[gi];
               fdec_idle[gi]          <= (idle_d1[gi] | |err_vec_d1[gi][7:0]);
               fdec_err_vec[gi][7:0]  <= err_vec_d1[gi][7:0];
               fdec_prim[gi][7:0]     <= prim_d1[gi][7:0]  & ~code_viol_d1[gi];
            end // if (rx_valid_d1)
         end // always_ff @
      end
   endgenerate
wire ipg_err_cnt_en;
reg  sof_cnt_en, eof_cnt_en;

fmac_prim_cnt #(.SIZE(8)) idle_cnt_inst
(
  .rst_n(rx_rst_n),  
  .clk(rx_clk),    
  .prim_in(fdec_idle),
  .start(|fdec_eof && fdec_rx_data_valid),
  .latch(|fdec_sof && fdec_rx_data_valid),
  .llimit(reg_fill_word_min),
  .ulimit(8'hff),
  .too_few(ipg_err_cnt_en),
  .too_many()
);

always_ff @(posedge rx_clk or negedge rx_rst_n)
  if (!rx_rst_n)
  begin
	  sof_cnt_en <= 1'b0;
	  eof_cnt_en <= 1'b0;
  end
  else
  begin
	  sof_cnt_en <= |fdec_sof && fdec_rx_data_valid;
	  eof_cnt_en <= |fdec_eof && fdec_rx_data_valid;
  end

   vi_sync_pulse ipg_err_cnt_en_pulse_inst (
    .out_pulse(reg_ipg_err_cnt_en),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(ipg_err_cnt_en)
   );

   vi_sync_pulse sof_cnt_en_pulse_inst (
    .out_pulse(reg_sof_cnt_en),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(sof_cnt_en)
   );

   vi_sync_pulse eof_cnt_en_pulse_inst (
    .out_pulse(reg_eof_cnt_en),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(eof_cnt_en)
   );


   // In the eof+data end case, the data needs to be shifted by 8b so that it is in the correct
   // 32b word.  This is the best place to perform the shift.  
   always_ff @(posedge rx_clk or negedge rx_rst_n)
	   if (!rx_rst_n)
			 fdec_rx_data[63:0]  <= 'h0;
     else if (rx_valid_d0)
       fdec_rx_data[63:0]  <= eof_d1[1]  ? {rx_data_d1[63:32],rx_data_d1[39:8]} :
			      rx_data_d1[63:0];
   
   assign code_viol_d1[0]     = |err_vec_d1[0][7:0];
   assign code_viol_d1[1]     = |err_vec_d1[1][7:0];
   assign fdec_code_viol[0]     = |fdec_err_vec[0][7:0]& fdec_rx_data_valid;
   assign fdec_code_viol[1]     = |fdec_err_vec[1][7:0]& fdec_rx_data_valid;

   // ----------------
   // Interfaces
   // ----------------
   
   assign fdec_dec_intf_0.sof        = fdec_sof[0];
   assign fdec_dec_intf_0.sof_type   = fdec_sof_type[0][2:0];
   assign fdec_dec_intf_0.eof        = fdec_eof[0];
   assign fdec_dec_intf_0.eof_type   = fdec_eof_type[0][2:0];
   assign fdec_dec_intf_0.prim       = fdec_prim[0][7:0];
   assign fdec_dec_intf_0.idle       = fdec_idle[0];
   assign fdec_dec_intf_0.data       = fdec_data[0];
   assign fdec_dec_intf_0.other      = fdec_other[0];
   assign fdec_dec_intf_0.err_vec    = fdec_err_vec[0][7:0];
   assign fdec_dec_intf_0.code_viol  = fdec_code_viol[0];
   assign fdec_dec_intf_0.reserved   = 4'd0;

   assign fdec_dec_intf_1.sof        = fdec_sof[1];
   assign fdec_dec_intf_1.sof_type   = fdec_sof_type[1][2:0];
   assign fdec_dec_intf_1.eof        = fdec_eof[1];
   assign fdec_dec_intf_1.eof_type   = fdec_eof_type[1][2:0];
   assign fdec_dec_intf_1.prim       = fdec_prim[1][7:0];
   assign fdec_dec_intf_1.idle       = fdec_idle[1];
   assign fdec_dec_intf_1.data       = fdec_data[1];
   assign fdec_dec_intf_1.other      = fdec_other[1];
   assign fdec_dec_intf_1.err_vec    = fdec_err_vec[1][7:0];
   assign fdec_dec_intf_1.code_viol  = fdec_code_viol[1];
   assign fdec_dec_intf_1.reserved   = 4'd0;


   // ----------------
   // Stats
   // ----------------
   
//   assign reg_losync_cnt_en           = (rx_valid_d0 & pcs_rx_valid & ~pcs_rx_sync);

   // ----------------
   // Assertions
   // ----------------

   // synthesis translate_off
   generate
      for (gi=0; gi<2; gi=gi+1) begin: gen_per_slot_assertions

         assert_multi_hot_special_functions : assert property
         ( @(posedge rx_clk)
           disable iff (~rx_rst_n) 
           $onehot0({fdec_sof[gi],fdec_eof[gi],fdec_idle[gi],fdec_data[gi],fdec_other[gi]}));
         
         assert_multi_hot_prim : assert property
         ( @(posedge rx_clk)
           disable iff (~rx_rst_n) 
           $onehot0(fdec_prim[gi]));

      end // block: gen_per_slot_assertions
   endgenerate

   // If pcs_rx_sync and pcs_rx_valid are not asserted, the decoder should not assert any attributes
   assert_dec_attributes_incorrectly_asserted : assert property
   ( @(posedge rx_clk)
     disable iff (~rx_rst_n)
     ~(pcs_rx_sync & pcs_rx_valid) |-> ##2 ~fdec_rx_data_valid);

   // Cannot have two SOFs or two EOFs
   assert_invalid_sof_decode : assert property
   ( @(posedge rx_clk)
     disable iff (~rx_rst_n)
      fdec_rx_data_valid |-> (fdec_sof[1:0]!=2'b11) );
   assert_invalid_eof_decode : assert property
   ( @(posedge rx_clk)
     disable iff (~rx_rst_n)
     fdec_rx_data_valid |-> (fdec_eof[1:0]!=2'b11) );

   // Cannot have two cycles of no rx_valid
   assert_two_cycles_no_rx_valid : assert property
   ( @(posedge rx_clk)
     disable iff (~rx_rst_n)
     (~pcs_rx_valid |=> pcs_rx_valid) );

   // synthesis translate_on

endmodule // fmac_decode

// Local Variables:
// verilog-library-directories:(".")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:

