/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author: gene.shen $
* $Date: 2013-01-08 16:31:00 -0800 (Tue, 08 Jan 2013) $
* $Revision: 1005 $
* $HeadURL: http://vi-bugs/svn/pld/trunk/bali_dal/prototype/uc_stats/rtl/debounce.v $
* Description:  Debounce of noisy input
* ***********************************************************************************************************/

module vi_debounce
(
    input        in,           // input, data to be synchronized
    input        reset_n,      // reset
    input        clk,          // output clock
    output reg   debounced     // output, debounced
 );

   reg [1:0] 	 count;

   always @(posedge clk or negedge reset_n) begin
      count[1:0]   <= ~reset_n ? 2'd0 :
		      (in & (count[1:0]!=2'b11))  ? (count[1:0] + 2'd1) :
		      (~in & (count[1:0]!=2'b00)) ? (count[1:0] - 2'd1) :
		      count[1:0];
   end

   assign debounced = count[1];

//   // translate_off
//   always @ (posedge clk) begin
//      if ( ((count[1:0]==2'b01)&~in) | ((count[1:0]==2'b10)&in) )
//	$display("Warning: Unexpected single cycle pulse in debounce module - output squelched.");
//   end
   // translate_on

endmodule // debounce



   

   
