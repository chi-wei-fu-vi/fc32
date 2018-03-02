/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-05-01 11:43:18 -0700 (Thu, 01 May 2014) $
* $Revision: 5580 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


/* detect block sync on non-FEC encoded DATA
 */

module block_sync (
	input   CLK,
	input   RST,
	input   [65:0] GB_BLK,
	input   GB_BLK_ENA,
	/* sense FEC status for auto-locking feature */
	input   FEC_SLIP,
	output reg   CSR_EXPT_FEC_LOCK_TO,
	input   CSR_PCS_FORCE_NO_FEC,
	
	input   [65:0] DEC_OUT_FEC_BLK,
	input   DEC_OUT_FEC_BLK_ENA,
	input   CSR_STAT_FEC_LOCK,
	
	output  reg     [63:0] BS_BLK,
	output  reg     [1:0] BS_SH,
	output  reg     BS_ENA,
	output  reg     BLK_SLIP,
	
	output  reg     CSR_STAT_BLOCK_LOCK,
	output  reg     CSR_EXPT_LOSS_BLOCKLOCK
);

reg     bs_en;  /* block sync enable */
reg     [3:0] blackout_cnt;
wire    blackout;
wire    slip;

reg     [5:0] lock_cnt;
reg     [1:0] los_cnt;
reg     [2:0] los_rst_cnt;
wire    lockcnt_64;
wire    loscnt_3; 

wire    bad_sh;

reg     [9:0] bs_to_cnt;

reg [11:0] fec_slip_cnt;
wire force_no_fec;

vi_sync_level
#(.SIZE(1)) force_no_fec_sync (
    .out_level(force_no_fec),
    .clk(CLK),
    .rst_n(~RST),
    .in_level(CSR_PCS_FORCE_NO_FEC)
);


always @(posedge CLK)
if (RST)
	bs_to_cnt <= 'h0;
else if (!bs_en || CSR_STAT_BLOCK_LOCK)
	bs_to_cnt <= 'h0;
else if (!bs_to_cnt[9] && !CSR_STAT_BLOCK_LOCK && !force_no_fec && slip)        //implied bs_en
	bs_to_cnt <= bs_to_cnt + 1;

assign  RST_FEC_TO_CNT =  bs_to_cnt[9];


always @(posedge CLK)
if (RST || RST_FEC_TO_CNT)
	fec_slip_cnt <= 'h0;
else if (FEC_SLIP && !bs_en)
	fec_slip_cnt <= fec_slip_cnt + 1;

always @(posedge CLK)
if (RST)
	CSR_EXPT_FEC_LOCK_TO <= 1'b0;
else
	CSR_EXPT_FEC_LOCK_TO <= fec_slip_cnt[11:8] == 4'hf;

always @(posedge CLK)
if (RST)
	bs_en <= 1'b0;
else  
	bs_en <= (force_no_fec || CSR_EXPT_FEC_LOCK_TO);

always @(posedge CLK)
if (RST)
	blackout_cnt <= 'h1;
else if (slip || blackout)
	blackout_cnt <= blackout_cnt + 1;

assign  blackout       =  |blackout_cnt; 

assign  slip   =  bs_en && GB_BLK_ENA && bad_sh && !blackout;

always @(posedge CLK)
if (RST)
	BLK_SLIP <= 1'b0;
else 
	BLK_SLIP <= (!bs_en && FEC_SLIP) || (slip && !CSR_STAT_BLOCK_LOCK);     // only allow slip in no lock state


assign  bad_sh =  ~^GB_BLK[1:0];

/* count consecutive lock, sat at 64 */
assign  lockcnt_64 =  &lock_cnt;
always @(posedge CLK)
if (RST)
	lock_cnt <= 'h0;
else if (!GB_BLK_ENA)
	lock_cnt <= lock_cnt;
else if (bad_sh)
	lock_cnt <= 'h0;
else if (!lockcnt_64)
	lock_cnt <= lock_cnt + 1;	

/* count consecutive nolock, sat at 3.  Finds 3 fails in a rolling window of 8 */
assign  loscnt_3   =  &los_cnt;

/* los_rst_cnt : count 8 block after 1st bad sync header. Roll over at 8*/
always @(posedge CLK)
if (RST)
	los_rst_cnt <= 'h0;
else if (!GB_BLK_ENA)
	los_rst_cnt <= los_rst_cnt;
else if (bad_sh || |los_rst_cnt)
	los_rst_cnt <= los_rst_cnt + 1;	

/* los_cnt : count los in a rolling window of 8.  Rolling window begins with
	 * 1st bad SH.  If >3 bad SH in a window of 8, then LOS
	 */
always @(posedge CLK)
if (RST)
	los_cnt <= 'h0;
else if (!GB_BLK_ENA)
	los_cnt <= los_cnt;
else if (&los_rst_cnt)
	los_cnt <= 'h0;
else if (!loscnt_3 && bad_sh)
	los_cnt <= los_cnt + 1;

/* track lock state. 
	 * Declare "lock" if observe 64 consecute good SH while in "no lock" state
	 * Declare "LOS" if observe 3 bad SH in a rolling window of 8 blocks while
	 * in lock state.
	 */
always @(posedge CLK)
if (RST)
begin
	CSR_STAT_BLOCK_LOCK <= 1'b0;
	CSR_EXPT_LOSS_BLOCKLOCK <= 1'b0;        /* LOS is default to 0, otherwise inverse of LOCK */
end
else if (!bs_en)
begin
	CSR_STAT_BLOCK_LOCK <= CSR_STAT_FEC_LOCK;
	CSR_EXPT_LOSS_BLOCKLOCK <= 1'b0;        /* LOS is default to 0, otherwise inverse of LOCK */
end
else if (CSR_STAT_BLOCK_LOCK && loscnt_3)
begin
	CSR_STAT_BLOCK_LOCK <= 1'b0;
	CSR_EXPT_LOSS_BLOCKLOCK <= 1'b1;
end
else if (!CSR_STAT_BLOCK_LOCK && lockcnt_64)
begin
	CSR_STAT_BLOCK_LOCK <= 1'b1;
	CSR_EXPT_LOSS_BLOCKLOCK <= 1'b0;
end

always @(posedge CLK)
if (RST)
begin
	BS_BLK <= 'h0;
	BS_SH  <= 'h0;
	BS_ENA <= 1'b0;
end
else if (bs_en)
begin
	BS_BLK <= GB_BLK[65:2];
	BS_SH  <= GB_BLK[1:0];
	BS_ENA <= GB_BLK_ENA && CSR_STAT_BLOCK_LOCK;
end
else 
begin
	BS_BLK <= DEC_OUT_FEC_BLK[65:2];
	BS_SH  <= DEC_OUT_FEC_BLK[1:0];
	BS_ENA <= DEC_OUT_FEC_BLK_ENA;
end

endmodule
