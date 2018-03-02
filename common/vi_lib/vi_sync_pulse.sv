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

module vi_sync_pulse 
 (
    output logic               out_pulse,
  
    input                      clka,
    input                      clkb,
    input                      rsta_n,
    input                      rstb_n,
    input                      in_pulse
  );
   
   logic 		       in_toggle_r, out_toggle_r, out_toggle_dly_r;
   logic 		       rst_n;

   // internal reset occurs if either clock domain asserts a reset
   assign rst_n = rsta_n & rstb_n;
   
   always_ff @( posedge clka or negedge rst_n )
     if ( ~rst_n ) 
       in_toggle_r <= 1'b0;
     else if ( in_pulse )
       in_toggle_r <= ~in_toggle_r;

   vi_sync_level #(.SIZE(1),
		   .TWO_DST_FLOPS(1))
   vi_sync_level_in_toggle 
     (
      .out_level    ( out_toggle_r  ),
      .clk          ( clkb          ),
      .rst_n        ( rst_n        ),
      .in_level     ( in_toggle_r   )
      );

   always_ff @( posedge clkb or negedge rst_n )
     if ( ~rst_n ) 
       out_toggle_dly_r <= 1'b0;
     else
       out_toggle_dly_r <= out_toggle_r;
   
   assign out_pulse = out_toggle_r ^ out_toggle_dly_r;
   
   // synopsys translate_off
   
   ///////////////////////////////////////////////////////////////////////////////
   // Assertion
   ///////////////////////////////////////////////////////////////////////////////
   // in_pulse is not expected to arrive 3 cycles apart to ensure clkb
   // (if slower) domain has enough time for synchronization
   assert_in_pulse_3cycle_apart: assert property ( @( posedge clka )
						   in_pulse |=> ~in_pulse[*2] );
   
   // synopsys translate_on
   
endmodule

