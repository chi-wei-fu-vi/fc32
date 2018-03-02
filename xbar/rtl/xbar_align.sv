/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author: gene.shen $
* $Date: 2013-12-17 10:13:03 -0800 (Tue, 17 Dec 2013) $
* $Revision: 4104 $
* $HeadURL: http://vi-bugs/svn/pld/trunk/dominica_dal/design/xbar/rtl/xbar_align.sv $
***********************************************************************************************************/

module xbar_align
   (
    input [39:0]              rx_data,               // rx_data from each link, synchronized to rx_clk
    input                     rx_clk,                // rx clock, difference frequency and phase from core clock
    input                     rx_rst_n,              // rx async reset

    output logic [39:0]       rx_align_data         // aligned rx_data

   );

   localparam COMMA_P = {10'b0101_111100};
   localparam COMMA_N = {10'b1010_000011};

   genvar 		      gi;
   integer 		      i;
   logic [39:0] 	      comma_loc, rx_data_q, rx_data_qq;
   logic [5:0] 		      comma_ptr_q, comma_ptr_d;
   logic [48:0] 	      rx_data_wide;
   logic [79:0] 	      rx_data_double;

   // padded and shifted rx_data.  Since the five 1's/0's are located in location [6:2] of the
   // 10b comma byte, we shift by two.  Pad the upper bits so that we can perform a scan and not have
   // to deal with wrap-around issues
   assign rx_data_wide[48:0] = {rx_data[8:0],rx_data_q[39:0]};

   // search for fives 1's/0's.  This simplification reduces the gate count compared to searching
   // for the 10b comma.  The comma_ptr is an encoded value that points to the starting bit location
   // of the comma.  Note this code is meant to work for finding a single comma, multiple commas
   // will result in the comma_ptr pointing to the last comma
   generate
      for (gi=0; gi<40; gi=gi+1) begin : gen_comma_loc
	 assign comma_loc[gi] = ( (rx_data_wide[gi+9:gi]==COMMA_P) |
				  (rx_data_wide[gi+9:gi]==COMMA_N) );
      end
   endgenerate

   always @* begin
      comma_ptr_d[5:0] = 6'd0;
      for (i=0; i<40; i=i+1) begin
	 if (comma_loc[i])
	   comma_ptr_d[5:0] = i;
      end
   end

   // save the comma_ptr only if there's a comma.  This has been pipelined to help timing
   //   cycle 0 : {rx_data,rx_data_q} scan for comma, form comma_ptr
   //   cycle 1 : {rx_data_qq, rx_data_q} mux out 
      always_ff @(posedge rx_clk or negedge rx_rst_n) begin
	 comma_ptr_q[5:0]  <= ~rx_rst_n  ? 6'd0 : 
			      |comma_loc[39:0] ? comma_ptr_d[5:0] : comma_ptr_q[5:0];
   end

   // double width rx_data for use by selector
//   assign rx_data_double[79:0] = {rx_data[39:0],rx_data_q[39:0]};
   assign rx_data_double[79:0] = {rx_data_q[39:0],rx_data_qq[39:0]};

   // alignment is coded using a variable part select into the double width rx_data to reduce 
   // errors and code size
   always_ff @(posedge rx_clk) begin
      rx_data_q[39:0]     <= rx_data[39:0];
      rx_data_qq[39:0]    <= rx_data_q[39:0];
      rx_align_data[39:0] <= rx_data_double[comma_ptr_q+39-:40];
   end

endmodule // xbar_align

  
