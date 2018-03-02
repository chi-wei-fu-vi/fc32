/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
***************************************************************************/

   /* IMPORTANT NOTE :
		* This BALI version differs from the original with an additional
		* destination flop for the signals.  This helps timing.
		*
		* This module must be used with care.  It uses simple flop stages to
		* "sync" a bus to the target domain.  Make sure that the source clock is
		* not so fast when compared to target clock that addr/data changes before
		* the read/write signals gets there.
		*/

module vi_sync_csr
  (
    // upstream (towards root) clock domain
    input                       iRST_N_A,
    input                       iCLK_A,
    input                       iWREN_A,
    input                       iRDEN_A,
    input [20:0] 		iADDR_A,
    input [63:0] 		iWR_DATA_A,
    output 			oACK_A,
    output [63:0] 		oRD_DATA_A,
   
    // downstream (towards leaf) clock domain
    input                       iRST_N_B,
    input                       iCLK_B,
    input [63:0] 		iRD_DATA_B,
    input                       iACK_B,
    output wire                 oWREN_B,
    output wire                 oRDEN_B,
    output [63:0] 		oWR_DATA_B,
    output [20:0] 		oADDR_B
   );
  

   // Signal Declarations

   wire 			rden_b_sync, wren_b_sync, ack_a_sync;
   reg [3:0] 			rden_b_delay, wren_b_delay, ack_a_delay;

   // Flop the address and wr_data
   // ----------------------------
   // Note these flops are in the destination clock domain

   vi_sync_1c #(.SIZE(21),
		.TWO_DST_FLOPS(1)) 
   vi_sync_1c_addr
     (// Outputs
      .out		(oADDR_B[20:0]),
      // Inputs
      .clk_dst		(iCLK_B),
      .rst_n_dst	(iRST_N_B),
      .in		(iADDR_A[20:0]));

   vi_sync_1c #(.SIZE(64),
		.TWO_DST_FLOPS(1)) 
   vi_sync_1c_wr_data
     (// Outputs
      .out		(oWR_DATA_B[63:0]),
      // Inputs
      .clk_dst		(iCLK_B),
      .rst_n_dst	(iRST_N_B),
      .in		(iWR_DATA_A[63:0]));

   // Flop the rd_data
   // ----------------------------

   vi_sync_1c #(.SIZE(64),
		.TWO_DST_FLOPS(1)) 
   vi_sync_1c_rd_data
     (// Outputs
      .out		(oRD_DATA_A[63:0]),
      // Inputs
      .clk_dst		(iCLK_A),
      .rst_n_dst	(iRST_N_A),
      .in		(iRD_DATA_B[63:0]));

   // pulse syncs
   // -----------

   vi_sync_pulse vi_sync_pulse_rd_en
     (// Outputs
      .out_pulse	(rden_b_sync),
      // Inputs
      .clka		(iCLK_A),
      .clkb		(iCLK_B),
      .rsta_n		(iRST_N_A),
      .rstb_n		(iRST_N_B),
      .in_pulse		(iRDEN_A));
   
   vi_sync_pulse vi_sync_pulse_wr_en
     (// Outputs
      .out_pulse	(wren_b_sync),
      // Inputs
      .clka		(iCLK_A),
      .clkb		(iCLK_B),
      .rsta_n		(iRST_N_A),
      .rstb_n		(iRST_N_B),
      .in_pulse		(iWREN_A));

   // note the confusing I/O - the direction is different since we are syncing ack from CLK_B to CLK_A
   vi_sync_pulse vi_sync_pulse_ack
     (// Outputs
      .out_pulse	(ack_a_sync),
      // Inputs
      .clka		(iCLK_B),
      .clkb		(iCLK_A),
      .rsta_n		(iRST_N_B),
      .rstb_n		(iRST_N_A),
      .in_pulse		(iACK_B));
   
   // delays
   // -----------
   // control signals are delayed to allow multi-bit data/address to stabilize

   always @(posedge iCLK_B or negedge iRST_N_B) begin
      rden_b_delay[3:0] <= ~iRST_N_B ? 4'h0 : {rden_b_delay[2:0],rden_b_sync};
      wren_b_delay[3:0] <= ~iRST_N_B ? 4'h0 : {wren_b_delay[2:0],wren_b_sync};
   end

   always @(posedge iCLK_A or negedge iRST_N_A) begin
      ack_a_delay[3:0] <= ~iRST_N_A ? 4'h0 : {ack_a_delay[2:0],ack_a_sync};
   end

   assign oRDEN_B = rden_b_delay[3];
   assign oWREN_B = wren_b_delay[3];
   assign oACK_A  = ack_a_delay[3];
   
   
endmodule 

// Local Variables:
// verilog-library-directories:(".")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:

      
