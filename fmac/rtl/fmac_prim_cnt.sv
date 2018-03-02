//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_prim_cnt.sv $
// $Author: leon.zhou $
// $Date: 2014-02-07 11:13:30 -0800 (Fri, 07 Feb 2014) $
// $Revision: 4632 $
//**************************************************************************/

// Primitive sequences (NOS, OLS, LR, LRR) require 3 consecutive instances before recognition

module fmac_prim_cnt
#(
  parameter SIZE = 8
)
   (
    input               rst_n,                      // asynchronous core clock chip reset
    input               clk,                         // core clock, 212.5Mhz
    input [1:0]         prim_in,                    // per slot primitive
		input               start,
		input               latch, 
		input [SIZE-1:0]    llimit,
		input [SIZE-1:0]    ulimit,
    output logic        too_few,                 // pulsed signal, asserted on 3rd instance of prim_in
		output logic        too_many
    );

localparam WAIT_START = 0;
localparam ACC = 1;

logic state;

logic [SIZE-1:0] cnt, ncnt;


always @(posedge clk or negedge rst_n)
  if (!rst_n)
		state <= WAIT_START;
	else if (state == WAIT_START && start)
		state <= ACC;
	else if (state == ACC && latch)
		state <= WAIT_START;
	

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		cnt <= 'h0;
	else
		cnt <= ncnt;

always @(*)
begin
	ncnt = cnt;
	if (state == ACC)
	begin
	// in accumulation state, add count to curr count
	  case (prim_in)
		  2'b11 : ncnt = cnt >= ({SIZE{1'b1}} - 2) ? {SIZE{1'b1}} : cnt + 2;
		  2'b10, 2'b01 : ncnt = cnt >= ({SIZE{1'b1}} - 1) ? {SIZE{1'b1}} : cnt + 1;
		  default : ncnt = cnt;
		endcase
	end
  else
	begin
	// in wait state, init count w/ input prim count
	  case (prim_in)
		  2'b10 : ncnt = 'h1;
		  2'b01 : ncnt = 'h1;
		  default : ncnt = 'h0; 
		endcase
	end

end

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		too_few <= 'h0;
	else
		too_few <= (state == ACC) && latch && (ncnt < llimit);

always @(posedge clk or negedge rst_n)
  if (!rst_n)
		too_many <= 'h0;
	else
		too_many <= (state == ACC) && latch && (ncnt > ulimit);


endmodule 

