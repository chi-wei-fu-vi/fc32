/***********************************************************************************************************
 * * Copyright (c) 2013,2014 Virtual Instruments.
 * * 25 Metro Dr, STE#400, San Jose, CA 95110
 * * www.virtualinstruments.com
 * * $Author: leon.zhou $
 * * $Date:  $
 * * $Revision:  $
 * * $HeadURL:
 * $
 * * Description: 
 * * ***********************************************************************************************************/

/* Do not use this on a bus */
module vi_async_rst (
  input RST_ASYNC_N,
	input CLK,
	output RST_SYNC,
	output RST_SYNC_N
);

reg r0, r1, r2, r3;

always @(posedge CLK or negedge RST_ASYNC_N)
  if (!RST_ASYNC_N)
  begin
		r0 <= 1'b0;
		r1 <= 1'b0;
		r2 <= 1'b0;
		r3 <= 1'b0;
	end
	else
	begin
		r0 <= 1'b1;
		r1 <= r0;
		r2 <= r1;
		r3 <= r2;
	end

  assign RST_SYNC = ~r3;
  assign RST_SYNC_N = r3;

endmodule
