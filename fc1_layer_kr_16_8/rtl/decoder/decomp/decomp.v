/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-03-26 14:59:44 -0700 (Wed, 26 Mar 2014) $
* $Revision: 5002 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


module decomp (
	input   CLK,
	input   RST,
	input   [64:0] C_BLK,
	input   C_BLK_ENA,
	input   ENDIAN_SWAP,
	
	output  reg     [65:0] PCS_BLK,
	output  reg     PCS_BLK_ENA
);

wire     [64:0] pcs_blk;
wire     sbit;



reverse #(65) dec_out_reverse_inst (.ENA  (1'b1), .IN      (C_BLK[64:0]), .OUT (pcs_blk));
assign sbit = pcs_blk[0] ^ pcs_blk[9];

always @(posedge CLK)
if (RST)
begin
	PCS_BLK <= 'h0;
	PCS_BLK_ENA <= 1'b0;
end
else
begin
	PCS_BLK <= {pcs_blk[64:1], sbit, !sbit};
	PCS_BLK_ENA <= C_BLK_ENA;
end


wire [65:0] rev_PCS_BLK;
//VERIF test point :
reverse #(66) rev_PCS_BLK_inst (.ENA  (1'b1), .IN      (PCS_BLK[65:0]), .OUT (rev_PCS_BLK));

endmodule
