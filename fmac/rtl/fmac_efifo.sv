//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_efifo.sv $
// $Author: leon.zhou $
// $Date: 2014-10-20 09:00:58 -0700 (Mon, 20 Oct 2014) $
// $Revision: 7513 $
//**************************************************************************/

module fmac_efifo
#(
  parameter SIM_ONLY = 0
)
   (

    // ----------------
    // Decode Interface
    // ----------------

    input   pcs_rx_sync,    // To fmac_regs of fmac_regs.v, ...
    input fmac_pkg::dec_intf   fdec_dec_intf_0,
    input fmac_pkg::dec_intf   fdec_dec_intf_1,
    input [63:0]               fdec_rx_data,        // 64b transmission word to elastic FIFO
    input                      fdec_rx_data_valid,  // 64b transmission word is valid

    // --------------------
    // Outputs to fmac_rcv
    // --------------------

    output logic [63:0]		fefo_rx_data,	    // 64b data
    output logic 		fefo_rx_data_valid, // 64b data is valid
    output fmac_pkg::dec_intf   fefo_dec_intf_0,
    output fmac_pkg::dec_intf   fefo_dec_intf_1,

    // --------------------
    // Outputs to xbar
    // --------------------

    output logic [63:0]		fmac_xbar_rx_data,   // 64b data
    output logic [1:0]		fmac_xbar_rx_sh,   // 64b data
    output logic          fmac_xbar_rx_valid,  // 64b data is valid

    // ----------------
    // FMAC regs
    // ----------------

    output logic [7:0]		reg_efifo_delete_cnt,	    // to fmac_regs of fmac_regs.v
    output logic [7:0]		reg_efifo_insert_cnt,	    // to fmac_regs of fmac_regs.v
    output logic		reg_efifo_rd_full,          // to fmac_regs of fmac_regs.v
    output logic		reg_efifo_wr_full,          // to fmac_regs of fmac_regs.v
    output logic		reg_efifo_rd_empty,         // to fmac_regs of fmac_regs.v
    output logic		reg_efifo_wr_empty,         // to fmac_regs of fmac_regs.v
    output logic [7:0] 	reg_efifo_overflow_cnt,     // to fmac_regs of fmac_regs.v
    output logic		reg_efifo_underflow_cnt_en, // to fmac_regs of fmac_regs.v
    output logic [2:0]		reg_efifo_sm_rd,            // to fmac_regs of fmac_regs.v
    output logic [2:0]		reg_efifo_sm_wr,            // to fmac_regs of fmac_regs.v
    output logic [4:0]		reg_efifo_rd_used,          // to fmac_regs of fmac_regs.v
    output logic [4:0]		reg_efifo_wr_used,          // to fmac_regs of fmac_regs.v

    input [7:0]                 reg_efifo_read_level,       // occupancy threshold before starting efifo reads
    input [7:0]                 reg_efifo_low_limit,	    // low water mark to iniate IDLE adds
    input [7:0]                 reg_efifo_high_limit,	    // high water mark to iniate IDLE deletes

    output logic                reg_nos_ols_event,   // NOS/OLS counter enable
    output logic                reg_lr_lrr_event,    // LR/LRR counter enable
    output logic                reg_bad_eof_event,   // EOF error type (EOFa, EOFni, EOFt)
    output logic                sm_linkup,           // linkup state machine state
    output logic                linkup,           // linkup state machine state 
    //output logic                reg_sof_cnt_en,
    //output logic                reg_eof_cnt_en,
    output logic                reg_idle_cnt_en,
    output logic                reg_data_cnt_en,
    output logic                reg_r_rdy_cnt_en,
    output logic                reg_vc_rdy_cnt_en,
    output logic                reg_bb_scs_cnt_en,
    output logic                reg_bb_scr_cnt_en,
    output logic [1:0]          reg_idle_cnt_inc,
    output logic [1:0]          reg_data_cnt_inc,
    output logic [1:0]          reg_r_rdy_cnt_inc,
    output logic [1:0]          reg_vc_rdy_cnt_inc,
    output logic [1:0]          reg_bb_scs_cnt_inc,
    output logic [1:0]          reg_bb_scr_cnt_inc,
    output logic                reg_sync_hdr_err_cnt_en,
    output logic                reg_invalid_type_err_cnt_en,
    output logic                reg_sof_dec_err_cnt_en,
    output logic                reg_eof_dec_err_cnt_en,
    output logic                reg_other_dec_err_cnt_en,
    output logic [1:0]          reg_other_dec_err_cnt_inc,
    output logic                reg_idle_dec_err_cnt_en,
    output logic [1:0]          reg_idle_dec_err_cnt_inc,
    output logic                reg_code_viol_cnt_en,
    output logic [1:0]          reg_code_viol_cnt_inc,
    input [7:0]                 reg_inj_code_viol,   

    output logic [1:0]          fmac_out_r_rdy,

    // synchronized in core clock domain
    output logic               reg_link_up_cnt_en,  // link up event, pulsed
    output logic               reg_link_down_cnt_en,// link down event, pulsed

    // ----------------
    // Reset & Clocks
    // ----------------
    input                      rst_n,               // asynchronous core clock chip reset
    input                      clk,                 // core clock, 212.5Mhz
    input                      rx_rst_n,            // asynchronous recovered clock chip reset
    input                      rx_clk,              // recovered clock, ~212.5Mhz
    input                      monitor_mode,
		input                      iSFP_PHY_LOSIG,
    input   rx_is_lockedtodata,
		output logic linkdown_event212_final

    );
import fmac_pkg::*;


   logic 		       efifo_rdempty;
   logic 		       efifo_rdreq, efifo_rdreq_q, efifo_insert_q;
   logic 		       efifo_wrreq;
   logic [63:0] 	       rd_rx_data, ccs_rx_data, wr_rx_data;
   logic 		       wr_ccs, rd_ccs;
   logic 		       wr_data_valid;
   logic [2:0] 		       sm_wr_state, sm_rd_state;
   logic [3:0] 		       last_ccs_prim_q;
   logic 		       last_ccs_idle;
   logic [1:0] 		       eof, sof, idle, data;
   logic [1:0][2:0] 	       eof_type;
   logic [1:0][7:0] 	       prim, err_vec;
   logic 		       nos_event, ols_event, lr_event, lrr_event;
   logic 		       efifo_insert, efifo_delete;
   logic 		       efifo_overflow_cnt_en;

   logic read_side_ready;

   fmac_pkg::dec_intf   rd_dec_intf_0;
   fmac_pkg::dec_intf   rd_dec_intf_1; 
   fmac_pkg::dec_intf   ccs_dec_intf; 
   fmac_pkg::dec_intf   wr_dec_intf_0;
   fmac_pkg::dec_intf   wr_dec_intf_1;

   //------------
   // Input Stage
   //------------
   // Flop the inputs

//   // interfaces
//   assign wr_dec_intf_0.sof        = fdec_sof[0];
//   assign wr_dec_intf_0.sof_type   = fdec_sof_type[0][2:0];
//   assign wr_dec_intf_0.eof        = fdec_eof[0];
//   assign wr_dec_intf_0.eof_type   = fdec_eof_type[0][2:0];
//   assign wr_dec_intf_0.prim       = fdec_prim[0][7:0];
//   assign wr_dec_intf_0.idle       = fdec_idle[0];
//   assign wr_dec_intf_0.data       = fdec_data[0];
//   assign wr_dec_intf_0.other      = fdec_other[0];
//   assign wr_dec_intf_0.err_vec    = fdec_err_vec[0][7:0];
//   assign wr_dec_intf_0.reserved   = 5'd0;
//
//   assign wr_dec_intf_1.sof        = fdec_sof[1];
//   assign wr_dec_intf_1.sof_type   = fdec_sof_type[1][2:0];
//   assign wr_dec_intf_1.eof        = fdec_eof[1];
//   assign wr_dec_intf_1.eof_type   = fdec_eof_type[1][2:0];
//   assign wr_dec_intf_1.prim       = fdec_prim[1][7:0];
//   assign wr_dec_intf_1.idle       = fdec_idle[1];
//   assign wr_dec_intf_1.data       = fdec_data[1];
//   assign wr_dec_intf_1.other      = fdec_other[1];
//   assign wr_dec_intf_1.err_vec    = fdec_err_vec[1][7:0];
//   assign wr_dec_intf_1.reserved   = 5'd0;

   // This initial flop may be removed - inserted for timing

   fmac_pkg::dec_intf   fdec_dec_intf_0r;
   fmac_pkg::dec_intf   fdec_dec_intf_1r;
	 reg [63:0] fdec_rx_data_r;
	 reg        fdec_rx_data_valid_r;

   always_ff @(posedge rx_clk) begin
	    fdec_dec_intf_0r <= fdec_dec_intf_0;
			fdec_dec_intf_1r <= fdec_dec_intf_1;
			fdec_rx_data_r   <= fdec_rx_data;
      wr_dec_intf_0    <= fdec_dec_intf_0r;
      wr_dec_intf_1    <= fdec_dec_intf_1r;
      wr_rx_data[63:0] <= fdec_rx_data_r[63:0];
   end

   always_ff @(posedge rx_clk or negedge rx_rst_n)
	 begin
      wr_data_valid   <= ~rx_rst_n ? 1'b0 : fdec_rx_data_valid_r;
      fdec_rx_data_valid_r   <= ~rx_rst_n ? 1'b0 : fdec_rx_data_valid;
	end 

   // --------------------
   // Add/Write Interface
   // --------------------
   // The write interface is clocked in the rx_clk domain.  Inputs from the EFIFO are flopped for
   // timing.  The write interface monitors the EFIFO wr occupancy, if it exceeds the high limit
   // it looks for the next clock correction symbol, and drops it by suppressing writes to the
   // EFIFO.  
	 //
	 // LZ :
	 // Must preserve at least 1 cycle (2) primitives before each SOP.
	 // Otherwise, the xbar far-end-loopback data will have minimum IPG
	 // violations.

   // Detect clock correction symbols
   // --------------------------------
   assign wr_ccs = 
	 wr_data_valid & 
	     (!wr_dec_intf_1.code_viol && !wr_dec_intf_0.code_viol) &&    // no code violations
	     (!fdec_dec_intf_0r.sof && !fdec_dec_intf_1r.sof) &&            // no SOF next cycle.

		   ( (wr_dec_intf_1.idle & wr_dec_intf_0.idle) |
		     (wr_dec_intf_1.prim[FC1_PRIM_NOS] & wr_dec_intf_0.prim[FC1_PRIM_NOS]) |
		     (wr_dec_intf_1.prim[FC1_PRIM_OLS] & wr_dec_intf_0.prim[FC1_PRIM_OLS]) |
		     (wr_dec_intf_1.prim[FC1_PRIM_LR]  & wr_dec_intf_0.prim[FC1_PRIM_LR]) |
		     (wr_dec_intf_1.prim[FC1_PRIM_LRR] & wr_dec_intf_0.prim[FC1_PRIM_LRR]) );


   // Drop Ctl
   // ----------
   // Drop CCS's when we have passed the high threshold.  Only drop one.  If there are no CCS's between
   // frames, go back to IDLE.

   localparam SM_WR_IDLE        = 3'h0;
   localparam SM_WR_DROP        = 3'h1;
   localparam SM_WR_WAIT0       = 3'h2;
   localparam SM_WR_WAIT1       = 3'h3;
   localparam SM_WR_ERROR       = 3'h7;

   always_ff @(posedge rx_clk or negedge rx_rst_n) begin
      if (~rx_rst_n)
        sm_wr_state[2:0] <= SM_WR_IDLE;
      else begin
         case (sm_wr_state[2:0])

           // IDLE - wait for threshold to be reached
           SM_WR_IDLE :
             //sm_wr_state[2:0] <= (reg_efifo_wr_used[4:0]>reg_efifo_high_limit[4:0]) ? SM_WR_DROP : SM_WR_IDLE;
             sm_wr_state[2:0] <= (reg_efifo_wr_used[4:0]>5'h14) ? SM_WR_DROP : SM_WR_IDLE;

           // DROP - drop the next CCS
           SM_WR_DROP :
             sm_wr_state[2:0] <= wr_ccs ? SM_WR_WAIT0 : SM_WR_DROP;
           
           // WAIT - wait states
           SM_WR_WAIT0 :
             sm_wr_state[2:0] <= SM_WR_WAIT1;
           SM_WR_WAIT1 :
             sm_wr_state[2:0] <= SM_WR_IDLE;

           default :
             sm_wr_state[2:0] <= SM_WR_IDLE;
         endcase // case (sm_wr_state[2:0])
      end // else: !if(~rx_rst_n)
   end // always @ (posedge rx_clk or negedge rx_rst_n)

   // Always write whenever we have valid data, except when dropping
   assign efifo_delete         = ((sm_wr_state[2:0]==SM_WR_DROP) & wr_ccs);
   assign efifo_wrreq          = wr_data_valid & ~efifo_delete & read_side_ready ;
   assign reg_efifo_sm_wr[2:0] = sm_wr_state[2:0];


   logic efifo_delete_212;

   vi_sync_pulse efifo_delete_event (
    .out_pulse(efifo_delete_212),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(efifo_delete)
   );



   // delete counts are maintained in fmac_efifo in the rx clock domain
   always_ff @(posedge clk or negedge rst_n) 
      reg_efifo_delete_cnt <= ~rst_n ? 'h0 :
				    (efifo_delete_212) ? (reg_efifo_delete_cnt+1) :
				    reg_efifo_delete_cnt;
      
   always_ff @(posedge clk or negedge rst_n) 
      reg_efifo_insert_cnt <= ~rst_n ? 'h0 :
				    (efifo_insert) ? (reg_efifo_insert_cnt+1) :
				    reg_efifo_insert_cnt;


   // ------------
   // Elastic FIFO
   // ------------
   //
   

wire                  wr_rst_busy;
wire                  rd_rst_busy;

assign rdfull = reg_efifo_rd_used[4:0] == ((1<<$bit(reg_efifo_rd_used[4:0]))-1);


assign wrempty = reg_efifo_wr_used[4:0] == 0;

s5_afifo_32x128b efifo_32x128b 
     (// Outputs
 . wr_rst_busy          ( wr_rst_busy                                        ), // output
 . rd_rst_busy          ( rd_rst_busy                                        ), // output
 . dout                 ( {rd_dec_intf_1,rd_dec_intf_0,rd_rx_data[63:0]}     ), 
 . empty                ( reg_efifo_rd_empty                                 ), 
 . rd_data_count        ( reg_efifo_rd_used[4:0]                             ), 
 . full                 ( reg_efifo_wr_full                                  ), 
 . wr_data_count        ( reg_efifo_wr_used[4:0]                             ), // Inputs
 . rst                  ( ~rst_n | ~rx_rst_n | ~linkup                       ), 
 . din                  ( {wr_dec_intf_1,wr_dec_intf_0,wr_rx_data[63:0]}     ), 
 . rd_clk               ( clk                                                ), 
 . rd_en                ( efifo_rdreq                                        ), 
 . wr_clk               ( rx_clk                                             ), 
 . wr_en                ( efifo_wrreq                                        )  
);


   // --------------------
   // Clock Correction Word
   // --------------------

   assign ccs_dec_intf.sof        = 1'b0;
   assign ccs_dec_intf.sof_type   = FC1_SOF_INVALID_TYPE;
   assign ccs_dec_intf.eof        = 1'b0;
   assign ccs_dec_intf.eof_type   = FC1_EOF_INVALID_TYPE;
   assign ccs_dec_intf.prim       = {last_ccs_prim_q[3:0],4'd0}; 
   assign ccs_dec_intf.idle       = last_ccs_idle;
   assign ccs_dec_intf.data       = 1'b0;
   assign ccs_dec_intf.other      = 1'b0;
   assign ccs_dec_intf.err_vec    = 8'd0;
   assign ccs_dec_intf.reserved   = 4'd0;
   assign ccs_dec_intf.code_viol  = 1'b0;

   // This state is used to form the clock correction transmission word
   always_ff @(posedge clk or negedge rst_n) begin
      last_ccs_prim_q[3:0] <= ~rst_n     ? 4'd0 :
			      efifo_rdreq_q ? rd_dec_intf_1.prim[7:4] :
			      last_ccs_prim_q[3:0];
      last_ccs_idle        <= ~rst_n     ? 1'd0 :
			      efifo_rdreq_q ? rd_dec_intf_1.idle : 
			      last_ccs_idle;
   end

   assign ccs_rx_data[63:0] = last_ccs_prim_q[0] ? {FC1_NOS_MODIFIER, 8'h0,FC1_NOS_MODIFIER,FC1_TYPE_OTHER_OTHER} :
			      last_ccs_prim_q[1] ? {FC1_OLS_MODIFIER, 8'h0,FC1_OLS_MODIFIER,FC1_TYPE_OTHER_OTHER} :
			      last_ccs_prim_q[2] ? {FC1_LR_MODIFIER,  8'h0,FC1_LR_MODIFIER, FC1_TYPE_OTHER_OTHER} :
			      last_ccs_prim_q[3] ? {FC1_LRR_MODIFIER, 8'h0,FC1_LRR_MODIFIER,FC1_TYPE_OTHER_OTHER} :
			                          {56'h0,FC1_TYPE_IDLE_IDLE};

   // --------------------
   // Drop/Read Interface
   // --------------------

   // Detect clock correction symbols
   // --------------------------------
   assign rd_ccs = efifo_rdreq_q &
		   ( (rd_dec_intf_1.idle & rd_dec_intf_0.idle) |
		     (rd_dec_intf_1.prim[FC1_PRIM_NOS] & rd_dec_intf_0.prim[FC1_PRIM_NOS]) |
		     (rd_dec_intf_1.prim[FC1_PRIM_OLS] & rd_dec_intf_0.prim[FC1_PRIM_OLS]) |
		     (rd_dec_intf_1.prim[FC1_PRIM_LR]  & rd_dec_intf_0.prim[FC1_PRIM_LR]) |
		     (rd_dec_intf_1.prim[FC1_PRIM_LRR] & rd_dec_intf_0.prim[FC1_PRIM_LRR]) );


   // Insert Ctl
   // ----------
   // Insert CCS's when we have passed the low threshold.  Only insert one CCS.  

   localparam SM_RD_IDLE        = 3'h0;
   localparam SM_RD_READING     = 3'h1;
   localparam SM_RD_INSERT      = 3'h2;
   localparam SM_RD_WAIT0       = 3'h3;
   localparam SM_RD_WAIT1       = 3'h4;
   localparam SM_RD_ERROR       = 3'h7;

   logic lt_low_limit;
   always_ff @(posedge clk or negedge rst_n)
	   if (!rst_n)
			 lt_low_limit <= 1'b1;
		 else
			 lt_low_limit <= reg_efifo_rd_used[4:0]<5'ha;

   logic gt_read_limit;
   always_ff @(posedge clk or negedge rst_n)
	   if (!rst_n)
			 gt_read_limit<= 1'b0;
		 else
			 gt_read_limit<= reg_efifo_rd_used[4:0]>5'h10;


   always_ff @(posedge clk or negedge rst_n) begin
      if (~rst_n)
        sm_rd_state[2:0] <= SM_RD_IDLE;
      else begin
         case (sm_rd_state[2:0])

           // IDLE - wait for read threshold to be reached
           SM_RD_IDLE :
             //sm_rd_state[2:0] <= (reg_efifo_rd_used[4:0]>reg_efifo_read_level[4:0]) ? SM_RD_READING : SM_RD_IDLE;
             sm_rd_state[2:0] <= (gt_read_limit) ? SM_RD_READING : SM_RD_IDLE;

           // Reading
           SM_RD_READING :
             //sm_rd_state[2:0] <= (reg_efifo_rd_used[4:0]<reg_efifo_low_limit[4:0]) ? SM_RD_WAIT0 : SM_RD_READING;
             sm_rd_state[2:0] <= (lt_low_limit) ? SM_RD_WAIT0 : SM_RD_READING;

           SM_RD_WAIT0 :
             //sm_rd_state[2:0] <= (reg_efifo_rd_used[4:0]>=reg_efifo_low_limit[4:0]) ? SM_RD_READING : rd_ccs ? SM_RD_INSERT : SM_RD_WAIT0;
             sm_rd_state[2:0] <= (!lt_low_limit) ? SM_RD_READING : rd_ccs ? SM_RD_INSERT : SM_RD_WAIT0;

           // INSERT - insert on the next CCS
           SM_RD_INSERT :
             //sm_rd_state[2:0] <= (reg_efifo_rd_used[4:0]>=reg_efifo_low_limit[4:0]) ? SM_RD_READING : SM_RD_INSERT;
             sm_rd_state[2:0] <= (!lt_low_limit) ? SM_RD_READING : SM_RD_INSERT;

//           // WAIT - wait states
//           SM_RD_WAIT1 :
//             sm_rd_state[2:0] <= SM_RD_READING;

           default :
             sm_rd_state[2:0] <= SM_RD_IDLE;
         endcase // case (sm_rd_state[2:0])
      end // else: !if(~tx_rst_n)
   end // always @ (posedge tx_clk or negedge tx_rst_n)

   //assign efifo_insert = (sm_rd_state[2:0]==SM_RD_INSERT) & rd_ccs;
   assign efifo_insert = (sm_rd_state[2:0]== SM_RD_WAIT0 && lt_low_limit && rd_ccs) || (sm_rd_state[2:0]==SM_RD_INSERT);
   assign efifo_rdreq  = ((sm_rd_state[2:0]==SM_RD_READING) || ((sm_rd_state[2:0]==SM_RD_WAIT0) && ~rd_ccs)) & ~reg_efifo_rd_empty; 

   always_ff @(posedge clk or negedge rst_n) begin
      efifo_rdreq_q   <= ~rst_n ? 1'b0 : efifo_rdreq;
      efifo_insert_q  <= ~rst_n ? 1'b0 : efifo_insert;
   end

   always_ff @(posedge clk or negedge rst_n) begin
      fefo_dec_intf_0    <= ~rst_n         ? ccs_dec_intf :
			    efifo_insert_q ? ccs_dec_intf :
			    efifo_rdreq_q  ? rd_dec_intf_0 : fefo_dec_intf_0;
      fefo_dec_intf_1    <= ~rst_n         ? ccs_dec_intf : 
			    efifo_insert_q ? ccs_dec_intf :
			    efifo_rdreq_q  ? rd_dec_intf_1 : fefo_dec_intf_1;
   end

   always_ff @(posedge clk)
      fefo_rx_data[63:0] <=  efifo_rdreq_q  ? rd_rx_data[63:0] :
			     efifo_insert_q ? ccs_rx_data[63:0] :
			     fefo_rx_data[63:0];
   
   assign reg_other_dec_err_cnt_en    = fefo_rx_data_valid & (err_vec[0][4]|err_vec[1][4]);
   assign reg_other_dec_err_cnt_inc   = (err_vec[0][4] && err_vec[1][4]) ? 2'h2 : {1'b0, reg_other_dec_err_cnt_en};
   assign reg_idle_dec_err_cnt_en     = fefo_rx_data_valid & (err_vec[0][5]|err_vec[1][5]);
   assign reg_idle_dec_err_cnt_inc     = (err_vec[0][5] && err_vec[1][5]) ? 2'h2 : {1'b0, reg_idle_dec_err_cnt_en};

   // Decode Violations

   wire code_viol0, code_viol1;

   vi_sync_pulse code_viol0_pulse_inst (
    .out_pulse(code_viol0),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(wr_dec_intf_0.code_viol & wr_data_valid)
   );

   vi_sync_pulse code_viol1_pulse_inst (
    .out_pulse(code_viol1),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(wr_dec_intf_1.code_viol & wr_data_valid)
   );

   assign reg_code_viol_cnt_en = code_viol0 | code_viol1;
   assign reg_code_viol_cnt_inc = code_viol0 && code_viol1 ? 2'h2 : {1'b0, reg_code_viol_cnt_en};

   //-----------------------
   // linkup state machine
   //-----------------------
   wire linkup_event219, linkdown_event219;
   wire linkup_event212, linkdown_event212;
   logic linkdown_level212, linkdown_level212_r;

   assign linkup_event219  =  ~wr_dec_intf_0.code_viol && ~wr_dec_intf_1.code_viol && wr_data_valid && (wr_dec_intf_0.idle | wr_dec_intf_1.idle);

   assign linkdown_event219 = ~wr_dec_intf_0.code_viol && ~wr_dec_intf_1.code_viol && wr_data_valid && (nos_event | ols_event | lrr_event | lr_event);

   vi_sync_pulse linkup_pulse_inst (
    .out_pulse(linkup_event212),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(linkup_event219)
   );

   vi_sync_pulse linkdown_pulse_inst (
    .out_pulse(linkdown_event212),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(linkdown_event219)
   );

   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   linkdown_level_sync
     (
      .out_level    ( linkdown_level212  ),
      .clk          ( clk          ),
      .rst_n        ( rst_n        ),
      .in_level     ( ~pcs_rx_sync | iSFP_PHY_LOSIG | ~rx_is_lockedtodata )
      );

  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      linkdown_level212_r <= 1'b1;
    else
      linkdown_level212_r <= linkdown_level212;

  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      linkdown_event212_final <= 1'b0;
    else
      linkdown_event212_final <= linkdown_event212 || (linkdown_level212 && !linkdown_level212_r);


   /* add init state to wait for stable condition
		* upon reset, look for 
		* */

   logic [15:0] linkup_cnt;
   logic pcs_rx_sync_212;

   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   pcs_rx_sync_retime
     (
      .out_level    ( pcs_rx_sync_212  ),
      .clk          ( clk          ),
      .rst_n        ( rst_n        ),
      .in_level     ( pcs_rx_sync   )
      );

   always_ff @(posedge clk or negedge rst_n)
     if (!rst_n)
			 linkup_cnt <= 'h0;
		 else if (~sm_linkup)
			 linkup_cnt <= 'h0;
		 else if (linkup_event212 && ~linkup_cnt[15])
			 linkup_cnt <= linkup_cnt + 1;


generate
  if (SIM_ONLY == 1)
  begin  
   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   pcs_rx_sync_retime
     (
      .out_level    ( read_side_ready  ),
      .clk          ( rx_clk          ),
      .rst_n        ( rx_rst_n        ),
      .in_level     ( linkup   )
      );
   always_ff @(posedge clk or negedge rst_n)
     if (!rst_n)
			 linkup <= 1'b0;
		 else
			 linkup <= |linkup_cnt[15:2];
  end

  if (SIM_ONLY == 0)
  begin
   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   pcs_rx_sync_retime
     (
      .out_level    ( read_side_ready  ),
      .clk          ( rx_clk          ),
      .rst_n        ( rx_rst_n        ),
      .in_level     ( linkup   )
      );
   always_ff @(posedge clk or negedge rst_n)
     if (!rst_n)
			 linkup <= 1'b0;
		 else
			 linkup <= linkup_cnt[15];
  end
 
endgenerate


/* SW requests 1 link_up event when transitioning from no monitor mode to monitored mode 
 * based on current link up state
 */
 logic monitor_mode_s;
 logic monitor_mode_sr;
 logic mms;
 logic mms_event;
 logic link_up_event;

   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   monitor_mode_retime
     (
      .out_level    ( monitor_mode_s  ),
      .clk          ( clk        ),
      .rst_n        ( rst_n      ),
      .in_level     ( monitor_mode  )
      );

   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       monitor_mode_sr <= 1'b0;
     else
       monitor_mode_sr <= monitor_mode_s;
      

  /* on monitor enable, arm event (mms) to wait for next linkup state
	 * on linkup, trigger link_up count by 1
	 * on link_up trigger, disarm event.
	 */

   always @(posedge clk or negedge rst_n)
     if (!rst_n)
       mms <= 1'b0;
		 else if (~monitor_mode_sr && monitor_mode_s)
			 mms <= 1'b1;
		 else if (mms_event)
       mms <= 1'b0;
       
	 assign mms_event                   = sm_linkup && mms;

   assign link_up_event               = !sm_linkup && linkup_event212;
   assign reg_link_up_cnt_en          = (!mms && link_up_event) || mms_event;
   assign reg_link_down_cnt_en        = sm_linkup && linkdown_event212_final;

   always_ff @(posedge clk or negedge rst_n)
     if (!rst_n)
       sm_linkup <= 1'b0;
     else if (linkdown_event212_final)
       sm_linkup <= 1'b0;
     else if (link_up_event)
       sm_linkup <= 1'b1;  

   //-----------------------
   // Primitive Sequences
   //-----------------------
   // Primitive sequences (NOS, OLS, LR, LRR) require 3 consecutive instances before recognition

   /* fmac_prim_event AUTO_TEMPLATE "fmac_prim_event_\([a-z0-9]+\)" 
     (// Outputs
      .prim_event			(@_event),
      // Inputs
      .rst_n				(rst_n),
      .clk				(clk),
    ) */

   // NOS 
   fmac_prim_event fmac_prim_event_nos
     (.prim_in				({wr_dec_intf_1.prim[FC1_PRIM_NOS],wr_dec_intf_0.prim[FC1_PRIM_NOS]}),
		  .prim_val (wr_data_valid),
      /*AUTOINST*/
      // Outputs
      .prim_event			(nos_event),		 // Templated
      // Inputs
      .rst_n				(rx_rst_n),		 // Templated
      .clk				(rx_clk));			 // Templated

   fmac_prim_event fmac_prim_event_ols
     (.prim_in				({wr_dec_intf_1.prim[FC1_PRIM_OLS],wr_dec_intf_0.prim[FC1_PRIM_OLS]}),
		  .prim_val (wr_data_valid),
      /*AUTOINST*/
      // Outputs
      .prim_event			(ols_event),		 // Templated
      // Inputs
      .rst_n				(rx_rst_n),		 // Templated
      .clk				(rx_clk));			 // Templated

   fmac_prim_event fmac_prim_event_lr
     (.prim_in				({wr_dec_intf_1.prim[FC1_PRIM_LR],wr_dec_intf_0.prim[FC1_PRIM_LR]}),
		  .prim_val (wr_data_valid),
      /*AUTOINST*/
      // Outputs
      .prim_event			(lr_event),		 // Templated
      // Inputs
      .rst_n				(rx_rst_n),		 // Templated
      .clk				(rx_clk));			 // Templated

   fmac_prim_event fmac_prim_event_lrr
     (.prim_in				({wr_dec_intf_1.prim[FC1_PRIM_LRR],wr_dec_intf_0.prim[FC1_PRIM_LRR]}),
		  .prim_val (wr_data_valid),
      /*AUTOINST*/
      // Outputs
      .prim_event			(lrr_event),		 // Templated
      // Inputs
      .rst_n				(rx_rst_n),		 // Templated
      .clk				(rx_clk));			 // Templated


	 vi_sync_pulse nos_ols_pulse_inst (
    .out_pulse(reg_nos_ols_event),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(nos_event | ols_event)
	 );

   vi_sync_pulse lr_lrr_pulse_inst (
    .out_pulse(reg_lr_lrr_event),
    .clka(rx_clk),
    .clkb(clk),                
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(lr_event | lrr_event)
   );


   // ----------------
   // Stats
   // ----------------
   // Most stats are updated in the core clock domain to reduce synchronizers.  

   assign reg_efifo_sm_rd[2:0]    = sm_rd_state[2:0];
   assign fefo_rx_data_valid      = efifo_rdreq_q | efifo_insert_q;

   always @(posedge clk or negedge rst_n)
	   if (!rst_n)
		 begin
       fmac_xbar_rx_data[63:0] <= 'h0;
       fmac_xbar_rx_valid      <= 'h0;
       fmac_xbar_rx_sh         <= 'h0;
		 end
		 else
		 begin
       fmac_xbar_rx_data[63:0] <= fefo_dec_intf_1.eof ? {fefo_rx_data[63:40], fefo_rx_data[31:0], 8'hff} :  fefo_rx_data[63:0];
       fmac_xbar_rx_valid      <= fefo_rx_data_valid;
       fmac_xbar_rx_sh         <= (fefo_dec_intf_0.data && fefo_dec_intf_1.data) ? 2'b10 : 2'b01;
		 end

   assign reg_efifo_underflow_cnt_en = reg_efifo_rd_empty & efifo_rdreq;

   assign eof[0]            = fefo_dec_intf_0.eof;
   assign eof_type[0][2:0]  = fefo_dec_intf_0.eof_type[2:0];
   assign sof[0]            = fefo_dec_intf_0.sof;
//   assign sof_type[0][2:0]  = fefo_dec_intf_0.sof_type[2:0];
   assign idle[0]           = fefo_dec_intf_0.idle;
   assign data[0]           = fefo_dec_intf_0.data;
   assign prim[0][7:0]      = fefo_dec_intf_0.prim;
   assign err_vec[0][7:0]   = fefo_dec_intf_0.err_vec;

   assign eof[1]            = fefo_dec_intf_1.eof;
   assign eof_type[1][2:0]  = fefo_dec_intf_1.eof_type[2:0];
   assign sof[1]            = fefo_dec_intf_1.sof;
//   assign sof_type[1][2:0]  = fefo_dec_intf_1.sof_type[2:0];
   assign idle[1]           = fefo_dec_intf_1.idle;
   assign data[1]           = fefo_dec_intf_1.data;
   assign prim[1][7:0]      = fefo_dec_intf_1.prim;
   assign err_vec[1][7:0]   = fefo_dec_intf_1.err_vec;
   
   assign reg_bad_eof_event = fefo_rx_data_valid & 
			      ( (eof[0] & ( 
					    (eof_type[0][2:0]==FC1_EOF_ABORT_TYPE) |
					    (eof_type[0][2:0]==FC1_EOF_NORM_I_TYPE) ) ) | 
				(eof[1] & ( 
					    (eof_type[1][2:0]==FC1_EOF_ABORT_TYPE) |
					    (eof_type[1][2:0]==FC1_EOF_NORM_I_TYPE) ) ) );
 
   //assign reg_sof_cnt_en              = fefo_rx_data_valid & |sof[1:0];
   //assign reg_eof_cnt_en              = fefo_rx_data_valid & |eof[1:0];
   assign reg_idle_cnt_en             = fefo_rx_data_valid & |idle[1:0];                   // has 100ppm error
   assign reg_data_cnt_en             = fefo_rx_data_valid & |data[1:0];
   assign reg_r_rdy_cnt_en            = fefo_rx_data_valid & (prim[0][0]|prim[1][0]);
   assign fmac_out_r_rdy[1:0]         = reg_r_rdy_cnt_inc[1:0] & {2{reg_r_rdy_cnt_en}};
   assign reg_vc_rdy_cnt_en           = fefo_rx_data_valid & (prim[0][1]|prim[1][1]);
   assign reg_bb_scs_cnt_en           = fefo_rx_data_valid & (prim[0][2]|prim[1][2]);
   assign reg_bb_scr_cnt_en           = fefo_rx_data_valid & (prim[0][3]|prim[1][3]);
   assign reg_sync_hdr_err_cnt_en     = fefo_rx_data_valid & (err_vec[0][0]|err_vec[1][0]);
   assign reg_invalid_type_err_cnt_en = fefo_rx_data_valid & (err_vec[0][1]|err_vec[1][1]);
   assign reg_sof_dec_err_cnt_en      = fefo_rx_data_valid & (err_vec[0][2]|err_vec[1][2]);
   assign reg_eof_dec_err_cnt_en      = fefo_rx_data_valid & (err_vec[0][3]|err_vec[1][3]);

   // cnt_inc signals do not need to be qualified by fefo_rx_data_valid.  They specify
   // increment values and are not used as enables.

   assign reg_idle_cnt_inc[1:0]       = idle[1:0];
   assign reg_data_cnt_inc[1:0]       = data[1:0];
   assign reg_r_rdy_cnt_inc[1:0]      = (prim[0][0]&prim[1][0]) ? 2'b10 : (prim[0][0]|prim[1][0]) ? 2'b01 : 2'b00;
   assign reg_vc_rdy_cnt_inc[1:0]     = (prim[0][1]&prim[1][1]) ? 2'b10 : (prim[0][1]|prim[1][1]) ? 2'b01 : 2'b00;
   assign reg_bb_scs_cnt_inc[1:0]     = (prim[0][2]&prim[1][2]) ? 2'b10 : (prim[0][2]|prim[1][2]) ? 2'b01 : 2'b00;
   assign reg_bb_scr_cnt_inc[1:0]     = (prim[0][3]&prim[1][3]) ? 2'b10 : (prim[0][3]|prim[1][3]) ? 2'b01 : 2'b00;

   // These are in rx_clk domain

   vi_sync_pulse overflow_count_enable (
    .out_pulse(efifo_overflow_cnt_en),
    .clka(rx_clk),
    .clkb(clk),
    .rsta_n(rx_rst_n),
    .rstb_n(rst_n),
    .in_pulse(reg_efifo_wr_full & efifo_wrreq)
   );



   always_ff @(posedge clk or negedge rst_n) 
      reg_efifo_overflow_cnt <= ~rst_n ? 'h0 :
				      (efifo_overflow_cnt_en & ~&reg_efifo_overflow_cnt) ? (reg_efifo_overflow_cnt + 1) :
				      reg_efifo_overflow_cnt;


   
   // ----------------
   // Assertions
   // ----------------

   // synthesis translate_off

   // synthesis translate_on


endmodule // fmac_efifo

// Local Variables:
// verilog-library-directories:(".")
// verilog-library-files:("fmac_prim_event.sv") 
// verilog-library-extensions:(".v" ".sv" ".h")
// End:


