/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author: gene.shen $
* $Date: 2014-01-23 16:12:33 -0800 (Thu, 23 Jan 2014) $
* $Revision: 4507 $
* $HeadURL: http://vi-bugs/svn/pld/trunk/dominica_dal/design/xbar/rtl/xbar_efifo.sv $
***********************************************************************************************************/

module xbar_efifo
  (


    output reg [39:0]         tx_data_out,           // rx_data stream from EFIFO with idle insertion
    output                    tx_data_val,           // tx_data_out is valid
    output reg                efifo_overflow,        // EFIFO overflow
    output reg                efifo_underflow,       // EFIFO underflow
    output                    idle_insert_cnt_en,    // increment count of IDLEs inserted - in tx_clk domain
    output                    idle_delete_cnt_en,    // increment count of IDLEs removed - in rx_clk domain

    input                     cr_efifo_idle_type,    // idle type: 0=IDLEs, 1=ARBFFs
    input [9:0]               cr_efifo_low_thresh,   // min threshold before EFIFO starts reading and inserting IDLEs
    input [9:0]               cr_efifo_high_thresh,  // max threshold before EFIFO starts dropping IDLEs
    input [9:0]               cr_efifo_read_thresh,  // read threshold 
    input [41:0]              rx_data_in,            // rx_data from each link, synchronized to rx_clk
    input                     rx_clk,                // rx clock, difference frequency and phase from core clock
    input                     rx_data_val,           // rx data valid, used as write enable to EFIFO
    input                     tx_clk,                // transmit clock, same frequency as core clock but different phase
    input                     tx_rst_n,              // 
    input                     rx_rst_n               // also used asasynchronous reset for Altera FIFOs


   );

`include "xbar_efifo_autoreg.vh"
   import vi_defines_pkg::*;
//`include "vi_defines.vh"

   localparam   SOF   = 2'd1; 
   localparam   EOF   = 2'd2;
   localparam   IDLE  = 2'd3;

//   // -------------
//   // Synchronizers
//   // -------------
//   // These synchronizers add-up, since per channel
//
//   vi_sync_1c #(.SIZE(10),
//                .TWO_DST_FLOPS(0)) 
//   vi_sync_1c_read_thresh
//     (// Outputs
//      .out              (cr_efifo_read_thresh_sync[9:0]),
//      // Inputs
//      .clk_dst          (tx_clk),
//      .rst_n_dst        (tx_rst_n),
//      .in               (cr_efifo_read_thresh[9:0]));
//   
//   vi_sync_1c #(.SIZE(10),
//                .TWO_DST_FLOPS(0)) 
//   vi_sync_1c_low_thresh
//     (// Outputs
//      .out              (cr_efifo_low_thresh_sync[9:0]),
//      // Inputs
//      .clk_dst          (tx_clk),
//      .rst_n_dst        (tx_rst_n),
//      .in               (cr_efifo_low_thresh[9:0]));
//   
//   vi_sync_1c #(.SIZE(1),
//                .TWO_DST_FLOPS(0)) 
//   vi_sync_1c_idle_type
//     (// Outputs
//      .out              (cr_efifo_idle_type_sync),
//      // Inputs
//      .clk_dst          (tx_clk),
//      .rst_n_dst        (tx_rst_n),
//      .in               (cr_efifo_idle_type));

	 logic read_thresh;
	 logic low_thresh;
	 logic high_thresh;

   assign cr_efifo_low_thresh_sync[9:0]    = cr_efifo_low_thresh[9:0];
   assign cr_efifo_high_thresh_sync[9:0]   = cr_efifo_high_thresh[9:0];
   assign cr_efifo_read_thresh_sync[9:0]   = cr_efifo_read_thresh[9:0];


   vi_fc_dec_40b vi_fc_dec_40b_inst
     (// Inputs
      .rx_data    (rx_data_in[39:0]),
      // Outputs
      .sof        (sof),
      .eof        (eof),
      .idle       (idle),
      .nos        (nos),
      .ols        (ols),
      .lr         (lr),
      .lrr        (lrr)
      );
   
   // ------
   // EFIFO
   // ------
   // The elastic FIFO adds/deletes idle characters based on the PPM difference between the
   // read/write clocks.  On writes, the elastic FIFO drops one idle per frame if the FIFO
   // passes the high water mark.  The EFIFO counts on incoming streams to adhere to FC
   // requirements of a minimum of 6 IDLE primitives per frame.  If there are no IDLEs between
   // frames, the EFIFO will not drop any primitives and the EFIFO may eventually overflow.  The
   // EFIFO IDLE drop logic always attempts to drop an IDLE past the high water mark - even if
   // it results in IDLE counts which are less than Fibre Channel requirements.
   //
   // PORT state transition primitives (LR, LRR, NOS, OLS) are considered IDLEs. 
   //   
   // On the read side, the read logic starts to read at the read threshold mark.  The
   // expectation is that the EFIFO is loaded with data at approximately the mid-way point
   // before reads are initiated - allowing sufficient buffering before the EFIFO empties to
   // allow read logic to insert IDLES.  Read logic auto-inserts one IDLE in between frames if
   // the EFIFO drops below the low water mark.  The low water mark should be set less than the
   // read threshold mark.  In the case of POR state primitives, read logic replicates POR
   // state primitives.


wire        efifo_wr_rst_busy;
wire        efifo_rd_rst_busy;

assign rdfull = efifo_rd_usedw[9:0] == ((1<<$bit(efifo_rd_usedw[9:0]))-1);


assign wrempty = efifo_wr_usedw[9:0] == 0;

s5_afifo_1024x42b s5_afifo_1024x42b_inst
     (// Outputs
 . wr_rst_busy          ( efifo_wr_rst_busy                                  ), // output
 . rd_rst_busy          ( efifo_rd_rst_busy                                  ), // output
 . dout                 ( efifo_rd_data[41:0]                                ), 
 . empty                ( efifo_rd_empty                                     ), 
 . rd_data_count        ( efifo_rd_usedw[9:0]                                ), 
 . full                 ( efifo_wr_full                                      ), 
 . wr_data_count        ( efifo_wr_usedw[9:0]                                ), // Inputs
 . rst                  ( ~rx_rst_n                                          ), 
 . din                  ( drop_fifo_rd_data[41:0]                            ), 
 . rd_clk               ( tx_clk                                             ), 
 . rd_en                ( efifo_rd_en                                        ), 
 . wr_clk               ( rx_clk                                             ), 
 . wr_en                ( efifo_wr_en                                        )  
);


   // write enable
   assign efifo_wr_en         = ~drop_fifo_empty & ~drop_idle;


//   // EFIFO initialization
//
//   always @(posedge rx_clk or negedge rst_n) 
//      cr_xbar_en_q <= ~rst_n ? 1'b0 : cr_xbar_en;
//
//   assign xbar_en_edge = ~cr_xbar_en_q & cr_xbar_en;
//
//   always @(posedge rx_clk or negedge rst_n) 
//      efifo_init_count[5:0] <= ~rst_n ? 6'd0 :
//                               (xbar_en_edge & efifo_init_count[5:0]<6'd65) ? (efifo_init_count[5:0]+6'd1) :
//                               efifo_init_count[5:0];
//
//   assign efifo_init          = (efifo_init_count[5:0]<6'd16) & cr_xbar_en;
//   assign efifo_wr_data[41:0] = efifo_init ? {2'd0,idle_primitive[39:0]} : {rx_sof_q, rx_eof_q, rx_data_q[39:0]};

   

   // ------------
   // EFIFO Write
   // ------------
   // Incoming write data is pipelined to allow decode, and then staged in a two flop buffer.  On detection 
   // of EOF and IDLEs, one of the IDLEs is squashed if we exceed the high water mark.

//   // pipeline all the signals by one cycle to allow idle/eof/sof decode
//   always @(posedge rx_clk or negedge rx_rst_n) begin
//      rx_data_q[39:0] <= ~rx_rst_n ? 40'd0 : rx_data_in;
//      rx_sof_q        <= ~rx_rst_n ? 1'd0  : sof;
//      rx_eof_q        <= ~rx_rst_n ? 1'd0  : eof;
//      rx_idle_q       <= ~rx_rst_n ? 1'd0  : idle;
//      rx_data_val_q   <= ~rx_rst_n ? 1'd0  : rx_data_val;
//   end
//
//   // two flop buffer
//   always @(posedge rx_clk or negedge rx_rst_n) begin
//      efifo_wr_buf0[43:0] <= ~rx_rst_n ? 44'd0 : (wr_buf_ptr==0) ? {rx_data_val, sof, eof, idle, rx_data[39:0]} : efifo_wr_buf1[43:0];
//      efifo_wr_buf1[43:0] <= ~rx_rst_n ? 44'd0 : (wr_buf_ptr==1) ? {rx_data_val, sof, eof, idle, rx_data[39:0]} : efifo_wr_buf0[43:0];
//      wr_buf_ptr          <= ~rx_rst_n ? 1'b0  : remove_idle     ? ~wr_buf_ptr : wr_buf_ptr;
//   end
//
//   // when we squash, we write from the earlier buffer entry.  Note the wr_buf_ptr update is flopped and delayed
//   // by cone cycle to coincide with the IDLE that is being squashed.
//   assign efifo_wr_data[41:0] = wr_buf_ptr ? {efifo_wr_buf0[43], efifo_wr_buf0[41], efifo_wr_buf1[39:0]} : 
//                                             {efifo_wr_buf1[43], efifo_wr_buf1[41], efifo_wr_buf0[39:0]};
//   assign remove_idle         = rx_eof_q & rx_idle_q & (efifo_wr_usedw[9:0]>=cr_efifo_high_thresh[9:0]);


   // This FIFO buffers data from the LPM_MUX before writing into the EFIFO.  It's a FWFT FIFO.
   

wire          drop_fifo_almost_full;
wire  [3:0]   drop_fifo_data_count;
wire          drop_fifo_almost_empty;
wire          drop_fifo_underflow;
wire          drop_fifo_wr_rst_busy;
wire          drop_fifo_rd_rst_busy;
wire          drop_fifo_overflow;
s5_sfifo_4x42b s5_sfifo_4x42b_inst
     (// Outputs
 . almost_full          ( drop_fifo_almost_full                              ), // output
 . data_count           ( drop_fifo_data_count                               ), // output [3:0]
 . almost_empty         ( drop_fifo_almost_empty                             ), // output
 . underflow            ( drop_fifo_underflow                                ), // output
 . wr_rst_busy          ( drop_fifo_wr_rst_busy                              ), // output
 . rd_rst_busy          ( drop_fifo_rd_rst_busy                              ), // output
 . overflow             ( drop_fifo_overflow                                 ), // output
 . din                  ( {rx_type[1:0],rx_data_in[39:0]}                    ), 
 . full                 ( drop_fifo_full                                     ), 
 . dout                 ( drop_fifo_rd_data[41:0]                            ), // Inputs
 . clk                  ( rx_clk                                             ), 
 . wr_en                ( rx_data_val & drop_fifo_wr_one_shot                ), 
 . rd_en                ( ~drop_fifo_empty                                   ), 
 . rst                  ( ~rx_rst_n                                          ), 
 . empty                ( drop_fifo_empty                                    )  
);


   assign idle_in_drop_fifo = (drop_fifo_rd_data[41:40]==IDLE);
   assign sof_in_drop_fifo  = (drop_fifo_rd_data[41:40]==SOF);

   assign rx_type[1:0] = (idle | lr | lrr | nos | ols) ? IDLE :
			 sof  ? SOF  :
			 eof  ? EOF  : 2'd0;

   // This one shot gets set on the first "idle" from the SERDES.  Once set, it remains set.   This is a workaround
   // for EFIFO issues when there are no IDLEs in the input stream wedging the EFIFO. 
   always @(posedge rx_clk or negedge rx_rst_n)
     drop_fifo_wr_one_shot <= ~rx_rst_n ? 1'b0 :
			      (rx_type[1:0]==IDLE) ? 1'b1 :
			      drop_fifo_wr_one_shot;
   
   // Drop Ctl
   // ----------
   // Drop IDLEs when we have passed the high threshold.  Only drop one idle.  If there are no idles between
   // frames, go back to IDLE

   localparam SM_WR_IDLE        = 3'h0;
   localparam SM_WR_DROP        = 3'h1;
   localparam SM_WR_WAIT0       = 3'h2;
   localparam SM_WR_WAIT1       = 3'h3;
   localparam SM_WR_ERROR       = 3'h7;

   always @(posedge rx_clk or negedge rx_rst_n)
      if (~rx_rst_n)
			  high_thresh <= 1'b0;
			else
			  high_thresh <= efifo_wr_usedw[9:7]>=cr_efifo_high_thresh_sync[9:7];

   always @(posedge rx_clk or negedge rx_rst_n) begin
      if (~rx_rst_n)
        sm_state[2:0] <= SM_WR_IDLE;
      else begin
         case (sm_state[2:0])

           // IDLE - wait for threshold to be reached
           SM_WR_IDLE :
             sm_state[2:0] <= high_thresh ? SM_WR_DROP : SM_WR_IDLE;

           // DROP - drop the next IDLE
           SM_WR_DROP :
             sm_state[2:0] <= sof_in_drop_fifo  ? SM_WR_IDLE :                     // error case, go back to IDLE and re-check
                              idle_in_drop_fifo ? SM_WR_WAIT0 : SM_WR_DROP;
           
           // WAIT - wait for the next SOF to restart
           SM_WR_WAIT0 :
             sm_state[2:0] <= SM_WR_WAIT1;
           SM_WR_WAIT1 :
             sm_state[2:0] <= SM_WR_IDLE;

           default :
             sm_state[2:0] <= SM_WR_IDLE;
         endcase // case (sm_state[2:0])
      end // else: !if(~rx_rst_n)
   end // always @ (posedge rx_clk or negedge rx_rst_n)

   assign sm_in_drop   = (sm_state[2:0]==SM_WR_DROP);
   assign drop_idle    = (sm_in_drop & idle_in_drop_fifo);
   

   
   // ----------
   // EFIFO Read
   // ----------

   // Insert Ctl
   // ----------
   // Insert IDLEs when we have passed the low threshold.  Only insert one idle.  

   localparam SM_RD_IDLE        = 3'h0;
   localparam SM_RD_READING     = 3'h1;
   localparam SM_RD_INSERT      = 3'h2;
   localparam SM_RD_WAIT0       = 3'h3;
   localparam SM_RD_WAIT1       = 3'h4;
   localparam SM_RD_ERROR       = 3'h7;




   always @(posedge tx_clk or negedge tx_rst_n)
      if (~tx_rst_n)
			begin
			  read_thresh <= 1'b0;
			  low_thresh <= 1'b0;
			end
			else
			begin
			  read_thresh <= efifo_rd_usedw[9:7]>=cr_efifo_read_thresh_sync[9:7];
			  low_thresh <= efifo_rd_usedw[9:7]<=cr_efifo_low_thresh_sync[9:7];
			end


   always @(posedge tx_clk or negedge tx_rst_n) begin
      if (~tx_rst_n)
        sm_rd_state[2:0] <= SM_RD_IDLE;
      else begin
         case (sm_rd_state[2:0])

           // IDLE - wait for threshold to be reached
           SM_RD_IDLE :
             sm_rd_state[2:0] <= read_thresh ? SM_RD_READING : SM_RD_IDLE;

           // Reading
           SM_RD_READING :
             sm_rd_state[2:0] <= low_thresh ? SM_RD_INSERT : SM_RD_READING;

           // INSERT - insert on the next IDLE
           SM_RD_INSERT :
             sm_rd_state[2:0] <= sof_in_efifo  ? SM_RD_READING :                     // error case, go back to IDLE and re-check
                                 idle_in_efifo ? SM_RD_WAIT0 : SM_RD_INSERT;
           
           // WAIT - wait states
           SM_RD_WAIT0 :
             sm_rd_state[2:0] <= SM_RD_WAIT1;
           SM_RD_WAIT1 :
             sm_rd_state[2:0] <= SM_RD_READING;

           default :
             sm_rd_state[2:0] <= SM_RD_IDLE;
         endcase // case (sm_rd_state[2:0])
      end // else: !if(~tx_rst_n)
   end // always @ (posedge tx_clk or negedge tx_rst_n)

   assign sm_rd_in_insert   = (sm_rd_state[2:0]==SM_RD_INSERT);

   assign insert_idle       = (sm_rd_in_insert & idle_in_efifo);
   assign idle_in_efifo     = (efifo_rd_data[41:40]==IDLE);
   assign sof_in_efifo      = (efifo_rd_data[41:40]==SOF);

   assign efifo_rd_en       = (sm_rd_state[2:0]!=SM_RD_IDLE) & ~efifo_rd_empty & ~insert_idle;
   
   // FIXME: running disparity?

   always @(posedge tx_clk) begin
      tx_data_last_idle[39:0] <= idle_in_efifo ? efifo_rd_data[39:0] : tx_data_last_idle[39:0];
      tx_data_out[39:0]       <= efifo_rd_en   ? efifo_rd_data[39:0] :
				 insert_idle   ? tx_data_last_idle[39:0] : tx_data_out[39:0];
   end
   
   assign tx_data_val   = 1'b1;

   
   // ---------------
   // Stats and Debug
   // ---------------

//   always @(posedge rx_clk or negedge rst_n) begin 
//     rx_sof_cnt[47:0]      <= ~rst_n                                                 ? 48'd0 : 
//                            ((rx_sof_cnt[47:0]!=`MAX_VALUE_48) & rx_sof_q)         ? (rx_sof_cnt[47:0]+48'd1) :
//                            rx_sof_cnt[47:0];
//     rx_eof_cnt[47:0]      <= ~rst_n                                                 ? 48'd0 : 
//                            ((rx_eof_cnt[47:0]!=`MAX_VALUE_48) & rx_eof_q)         ? (rx_eof_cnt[47:0]+48'd1) :
//                            rx_eof_cnt[47:0];
//     rx_idle_cnt[47:0]     <= ~rst_n                                                 ? 48'd0 : 
//                            ((rx_idle_cnt[47:0]!=`MAX_VALUE_48) & rx_idle_q)       ? (rx_idle_cnt[47:0]+48'd1) :
//                            rx_idle_cnt[47:0];
//   end // always @ (posedge rx_clk or negedge rst_n)
//
//
//   always @(posedge tx_clk or negedge rst_n) begin
//      idle_delete_cnt[15:0] <= ~rst_n ? 16'd0 : 
//                               ((idle_delete_cnt[15:0]!=`MAX_VALUE_16) & remove_idle) ? (idle_delete_cnt[15:0]+16'd1) :
//                               idle_delete_cnt[15:0];
//      idle_insert_cnt[15:0] <= ~rst_n ? 16'd0 : 
//                               ((idle_insert_cnt[15:0]!=`MAX_VALUE_16) & insert_idle) ? (idle_insert_cnt[15:0]+16'd1) :
//                               idle_insert_cnt[15:0];
//   end

   assign idle_insert_cnt_en = insert_idle;
   assign idle_delete_cnt_en = drop_idle;

   always @(posedge rx_clk or negedge rx_rst_n) 
      efifo_overflow <= ~rx_rst_n ? 1'b0 :
                        (efifo_wr_full & efifo_wr_en) ? 1'b1 : efifo_overflow;
   always @(posedge tx_clk or negedge tx_rst_n) 
     efifo_underflow <= ~tx_rst_n ? 1'b0 :
                        (efifo_rd_empty & efifo_rd_en) ? 1'b1 : efifo_underflow;

   // ----------------------
   // Assertions
   // ----------------------

   // synthesis translate_off

   assert_efifo_overflow : assert property
   ( @(posedge rx_clk)
     disable iff (~rx_rst_n) 
     !$rose(efifo_overflow));
   
   assert_efifo_underflow : assert property
   ( @(posedge tx_clk)
     disable iff (~tx_rst_n) 
     !$rose(efifo_underflow));

   // synthesis translate_on
   
endmodule 

// Local Variables:
// verilog-library-directories:("." "auto/" "ip/")
// verilog-library-extensions:(".v" ".sv" ".h" "v.h")
// End:
