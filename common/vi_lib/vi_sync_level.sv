/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: vi_sync_level.sv$
* $Author: honda.yang $
* $Date: 2013-07-18 14:25:50 -0700 (Thu, 18 Jul 2013) $
* $Revision: 2874 $
* Description:
***************************************************************************/

module vi_sync_level #(parameter SIZE=4,
		       parameter TWO_DST_FLOPS = 1,
		       parameter ASSERT = 0)
(
    output [SIZE-1:0]    out_level,
    input 		 clk,
    input 		 rst_n,
    input  [SIZE-1:0] 	 in_level
);

// (* altera_attribute = "-name SDC_STATEMENT \"set_false_path -to [get_registers *vi_sync_level*in_level_sync_r*]\"" *) 

logic [SIZE-1:0] in_level_sync_r, out_q2;

   always_ff @(posedge clk or negedge rst_n)
     if ( ~rst_n ) 
       in_level_sync_r <= {SIZE{1'b0}};
     else 
       in_level_sync_r <= in_level;

   generate
      if (TWO_DST_FLOPS) begin: gen_flop
	 always_ff @(posedge clk or negedge rst_n)
	   if (~rst_n)
	     out_q2 <= {SIZE{1'b0}};
	   else
	     out_q2 <= in_level_sync_r;
	 assign out_level = out_q2;
      end
      else begin: gen_flop
	 assign out_level = in_level_sync_r;
      end
   endgenerate

// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
// If a multi-bit bus going through a synchronizer, it must be
// gray coded.
assert_in_bus_graycode: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    ASSERT & ( in_level != $past(in_level) ) |-> $countones( in_level ^ $past(in_level) ) == 1 );

// synopsys translate_on

endmodule
