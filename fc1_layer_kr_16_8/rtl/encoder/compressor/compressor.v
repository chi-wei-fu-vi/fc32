/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-04-02 09:26:11 -0700 (Wed, 02 Apr 2014) $
* $Revision: 5082 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


/* compressor.v
 * takes 66bits and generate 65bit blocks by compressing the sync bits
 * This module is also the input flop stage for the encoder
 * PCS_BLK    >>    pcs_din_sync    >>    T_BLK
 * ENA        >>    ena_s           >>    T_BLK_ENA
 *
 * latency is 2 clock cycles
 */

module compressor (
	input   CLK,
	input   RST,
	input   ENA,
	input   [65:0] PCS_BLK,
	output  logic     [64:0] T_BLK,
	output  logic     [4:0] BLK_CNT,
	output  logic     T_BLK_ENA
);

reg     [65:0] pcs_din_sync;
reg     ena_s;

wire [1:0] sh;
wire [63:0] data;
logic [64:0] t_blk;

always @ (posedge CLK)
if (RST)
begin
	ena_s <= 'h0;
	T_BLK_ENA <= 'h0;
end
else
begin
	ena_s <= ENA;
	T_BLK_ENA <= ena_s;
end

always @ (posedge CLK)
if (RST)
	pcs_din_sync <= 'h0;
else
	pcs_din_sync <= PCS_BLK;


assign sh = pcs_din_sync[1:0];
assign data = pcs_din_sync[65:2];

always @ (posedge CLK)
if (RST)
	t_blk <= 'h0;
else
	t_blk <= {data, sh[1]^data[8]};

reverse #(65) t_blk_rev (.ENA (1'b1), .IN(t_blk), .OUT(T_BLK));

/* block count is incremented one cycle per clock.
   * A new block is expected for every clock
   */
always @ (posedge CLK)
if (RST)
	BLK_CNT <= 'h0;
else if (&BLK_CNT && ena_s)
	BLK_CNT <= 'h0;
else if (ena_s)
	BLK_CNT <= BLK_CNT + 1;

endmodule

