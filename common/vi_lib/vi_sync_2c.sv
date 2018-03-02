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

module vi_sync_2c #(parameter SIZE = 1,
		    parameter TWO_DST_FLOPS = 0)
(
    output [SIZE-1:0]    out,
    input 		 clk_dst,
    input 		 rst_n_dst,
    input [SIZE-1:0] 	 in,
    input 		 clk_src,
    input 		 rst_n_src
);

//(* ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_max_delay -to [get_registers {*vi_sync_2c*out_q*}] 12\"" *)

   reg [SIZE-1:0] 	 in_q, out_q, out_q2;

   always @(posedge clk_src or negedge rst_n_src)
     if (~rst_n_src)
       in_q <= {SIZE{1'b0}};
     else
       in_q <= in;
   
   always @(posedge clk_dst or negedge rst_n_dst)
     if (~rst_n_dst)
       out_q <= {SIZE{1'b0}};
     else
       out_q <= in_q;
   
   generate

      if (TWO_DST_FLOPS) begin: gen_flop
	 always @(posedge clk_dst or negedge rst_n_dst)
	   if (~rst_n_dst)
	     out_q2 <= {SIZE{1'b0}};
	   else
	     out_q2 <= out_q;
	 assign out = out_q2;
      end

      else begin: gen_flop
	 assign out = out_q;
      end
      
   endgenerate

endmodule
