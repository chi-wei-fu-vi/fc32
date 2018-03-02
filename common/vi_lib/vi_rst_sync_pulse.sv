/***************************************************************************
* Copyright (c) 2013, 2014 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
***************************************************************************/

// This module is used to transfer a short reset pulse in one clock domain to another clock domain.
// The module is used to generate a stretched reset signal from a self-clearing reset bit in a
// control register.  

module vi_rst_sync_pulse
(
  input  rst_a_n,         // async reset in domain A
  input  rst_b_n,         // async reset in domain B
  input  clk_a,           // clock in domain A
  input  clk_b,           // clock in domain B
  input  rst_sync_n,      // reset pulse in domain A - will be stretched into a multi-cycle pulse
                          // in domain B.

  output rst_out_sync_n   // multi-cycle reset pulse in domain B.  
);

   logic [6:0] reset_ctr;

   // reset pulse in clock domain A is transferred to clock domain B

   vi_sync_pulse vi_sync_pulse
     (// Outputs
      .out_pulse	(rst_sync_b),
      // Inputs
      .clka		(clk_a),
      .clkb		(clk_b),
      .rsta_n		(rst_a_n),
      .rstb_n		(rst_b_n),
      .in_pulse		(~rst_sync_n));

   // Counter is reset by clock domain B reset.  It is also reset by rst_sync_b
   // to create a pulse in clock domain B.
   
   always @(posedge clk_b or negedge rst_b_n)
     reset_ctr[6:0] <= ~rst_b_n   ? 7'd0 :
		       rst_sync_b ? 7'd0 :
		       (~reset_ctr[6]) ? (reset_ctr[6:0] + 7'd1) : 
                       reset_ctr[6:0];

   assign rst_out_sync_n = reset_ctr[6];
   
endmodule
