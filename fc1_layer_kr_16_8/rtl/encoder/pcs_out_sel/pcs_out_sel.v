/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-05-01 11:35:18 -0700 (Thu, 01 May 2014) $
* $Revision: 5576 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


module pcs_out_sel (
	input   CLK219,
	input   RST219,
	
	input   [63:0] GB65_BLK,
	input   [63:0] PN2112_CW,
	
	input   [63:0] GB66_BLK,
	
	input   CSR_PCS_ENC_FEC_ENA,
	input   CSR_ENC_OUT_ENDIAN_SWAP,
	input   CSR_ENC_INV,
	
	output  reg     [63:0] ENC_OUT_PMA_BLK
);

reg     [63:0] unswapped_blk;
wire    [63:0] swapped_blk;
wire fec_ena;
wire enc_inv;

vi_sync_level
#(.SIZE(1)) fec_ena_sync (
    .out_level(fec_ena),
    .clk(CLK219),
    .rst_n(~RST219),
    .in_level(CSR_PCS_ENC_FEC_ENA)
);

vi_sync_level
#(.SIZE(1)) fec_inv_sync (
    .out_level(enc_inv),
    .clk(CLK219),
    .rst_n(~RST219),
    .in_level(CSR_ENC_INV)
);



always @(posedge CLK219)
if (RST219)
	unswapped_blk <= 'h0;
else if (fec_ena)
	unswapped_blk <= GB65_BLK ^ PN2112_CW;
else
	unswapped_blk <= GB66_BLK;
/*
reverse #(64) enc_out_reverse_inst (
	// Outputs
	.OUT   (swapped_blk),
	// Inputs
	.ENA   (CSR_ENC_OUT_ENDIAN_SWAP),
	.IN    (unswapped_blk)
);
*/

always @(posedge CLK219)
if (RST219)
	ENC_OUT_PMA_BLK <= 'h0;
else
	ENC_OUT_PMA_BLK <= enc_inv ? ~unswapped_blk : unswapped_blk;

//Verification test point
reverse #(64) swapped_blk_inst (.ENA(1'b1), .IN(unswapped_blk), .OUT(swapped_blk));

endmodule
