//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_prim_event.sv $
// $Author: leon.zhou $
// $Date: 2014-02-07 11:13:30 -0800 (Fri, 07 Feb 2014) $
// $Revision: 4632 $
//**************************************************************************/

// Primitive sequences (NOS, OLS, LR, LRR) require 3 consecutive instances before recognition

module fmac_prim_event
   (
    output logic        prim_event,                 // pulsed signal, asserted on 3rd instance of prim_in
    input [1:0]         prim_in,                    // per slot primitive
		input               prim_val,
    input               rst_n,                      // asynchronous core clock chip reset
    input               clk                         // core clock, 212.5Mhz
    );

  reg [1:0] prim_in_s;
	wire [1:0] prim_in_gated;
	wire [3:0] vec;
	wire e123, e012;

  assign prim_in_gated = prim_in & {2{prim_val}};
  assign vec = {prim_in_gated, prim_in_s};
	assign e012 = &vec[2:0];
	assign e123 = &vec[3:1];

  always @(posedge clk)
	  if (!rst_n || e012)
		  prim_in_s <= 'h0; 
		else 
		  prim_in_s <= e012 ? {prim_in[1], 1'b0} : e123 ? 2'b00 : prim_in;  // DO NOT change priority order

  assign prim_event = e012 || e123;



endmodule 

