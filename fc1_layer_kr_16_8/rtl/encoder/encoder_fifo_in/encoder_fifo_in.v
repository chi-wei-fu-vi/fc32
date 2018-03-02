/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-03-24 14:07:38 -0700 (Mon, 24 Mar 2014) $
* $Revision: 4983 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


/* Encoder input FIFO wrapper.
 * Note !!!  This design assumes a rate-matched streaming interface.  It accumulates data
 * upon reset de-assetion, and only de-asserts fifo_n_empty when it becomes
 * 1/2 full.  There is no empty/full checking.
 */

module encoder_fifo_in 
( 
	input   CLK,
	input   RST,
	input   [1:0]  PCS_SH,
	input   [63:0] PCS_BLK,
	input   ENA,
	
	output  [1:0]  fifo_pcs_sh,
	output  [63:0] fifo_pcs_blk,
	output  reg     fifo_dval,
	output  CSR_EXPT_ENC_FULL,
	output  CSR_EXPT_ENC_EMPT
	
);

wire    [4:0] usedw;
reg     fifo_empt;

reg     [65:0] fifo_dout;

reg    rd_en;
reg    wr_en;
reg  [1:0] pcs_sh;
reg  [63:0] pcs_blk;

wire    alt_fifo_empty;

assign  CSR_EXPT_ENC_EMPT  =  alt_fifo_empty && !fifo_empt;

alt_fifo_sync_66_66 
alt_fifo_sync_66_66_inst
(
	.clock (CLK),
	.data  ({pcs_sh, pcs_blk}),
	.rdreq (rd_en),
	.wrreq (wr_en),
	.empty (alt_fifo_empty),
	.full  (CSR_EXPT_ENC_FULL),
	.q     (fifo_dout),
	.usedw (usedw)
);

assign  fifo_pcs_sh  = fifo_dout[65:64];
assign  fifo_pcs_blk = fifo_dout[63:0];

always @(posedge CLK)
if (RST)
	fifo_empt <= 1'b1;
else if (usedw[4])
	fifo_empt <= 1'b0;

always @(posedge CLK)
if (RST)
begin
	wr_en <= 1'b0;
	pcs_sh <= 'h0;
	pcs_blk <= 'h0;
end
else
begin
	wr_en <= ENA;
	pcs_sh <= PCS_SH;
	pcs_blk <= PCS_BLK;
end

always @(posedge CLK)
if (fifo_empt)
	rd_en <= 'h0;
else
	rd_en <= 1'b1;

always @(posedge CLK)
if (RST)
	fifo_dval <= 1'b0;
else if (!fifo_empt)
	fifo_dval <= rd_en;


endmodule
