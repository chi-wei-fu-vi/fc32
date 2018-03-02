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

/* DO NOT use this module to sync an actual "BUS".
 * You would obviously need an async FIFO for an actual bus.  This module
 * provides a shorthand to synchronize a bunch of low freq and unrelated
 * asynchronous inputs.  Rather than having to instantiate one instance per
 * input, one can group an interface and sync the signals together.  However,
 * there is no gurantee that these signals will arrive at the target clock
 * domain with the same relative timing.  They can be skewed by 1 or 2 clocks
 * from each other.
 */


module vi_sync_pp
#(parameter SIZE = 1
)
 (
  
    input                      clka,
    input                      clkb,
    input                      rsta_n,
    input                      rstb_n,

		input  [SIZE-1:0]          in_bus, 
		output logic [SIZE-1:0]    out_bus 
  );
   
   logic 		       in_toggle_r, mid_toggle_r, out_toggle_r, out_toggle_dly_r;
   logic 		       rst_n;
   logic           rsta_s_n, rstb_s_n;

		logic  [SIZE-1:0]          sample, sample_b0, sample_b1;
		logic  sampling_pulse;

/* out_bus is a sampled version in_bus w/ in_pulse as ENA
 * out_bus settles when in_pulse is synchronized to clkb side.
 */

   logic [5:0] count;
	 logic in_pulse;

   always_ff @( posedge clka or negedge rsta_n)
	    if (!rsta_n)
				count <= 'h0;
			else if (in_pulse)
				count <= 'h0;
		  else
				count <= count + 1;
			 
	assign in_pulse = count[5];
			 

   always_ff @( posedge clka or negedge rsta_n)
	    if (!rsta_n)
				sample <= {SIZE{1'b0}};
		  else if (in_pulse)
			 sample <= in_bus;

/* pulse(clka) --> level --> pulse(clkb)
*/
   
   always_ff @( posedge clka or negedge rsta_n )
     if ( ~rsta_n ) 
       in_toggle_r <= 1'b0;
     else if ( in_pulse )
       in_toggle_r <= ~in_toggle_r;

   vi_sync_level #(.SIZE(1),
		   .TWO_DST_FLOPS(1))
   vi_sync_level_in_toggle0 
     (
      .out_level    ( mid_toggle_r  ),
      .clk          ( clkb          ),
      .rst_n        ( rstb_n        ),
      .in_level     ( in_toggle_r   )
      );
   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   vi_sync_level_in_toggle1
     (
      .out_level    ( out_toggle_r  ),
      .clk          ( clkb          ),
      .rst_n        ( rstb_n        ),
      .in_level     ( mid_toggle_r   )
      );

   always_ff @( posedge clkb)
       out_toggle_dly_r <= out_toggle_r;
  
   always_ff @( posedge clkb)
	     sample_b0 <= sample;

   always_ff @( posedge clkb)
	     sample_b1 <= sample_b0;

   always_ff @( posedge clkb or negedge rstb_n)
	   if (!rstb_n)
       sampling_pulse <= 1'b0;
		 else
       sampling_pulse <= out_toggle_r ^ out_toggle_dly_r;

   always_ff @( posedge clkb or negedge rstb_n)
	   if (!rstb_n)
			 out_bus <= {SIZE{1'b0}};
		 else if (sampling_pulse)
			 out_bus <= sample_b1;
   
endmodule

