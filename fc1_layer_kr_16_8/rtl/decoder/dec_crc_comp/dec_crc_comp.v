/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2013-11-13 14:43:41 -0800 (Wed, 13 Nov 2013) $
* $Revision: 3883 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


module dec_crc_comp (
	input   CLK,
	input   RST,
	
	input   [31:0] T_CRC,
	input   T_CRC_ENA,
	input   [31:0] DEC_CRC,
	
	output  reg     CRC_FAIL,
	output  reg     [31:0] SYNDR,
	output  reg     SYNDR_VAL,
	output  reg     FEC_LOCK,
	output  reg     SLIP
);

reg     [31:0] t_crc_sample, dec_crc_sample;

reg     t_crc_en_s0, t_crc_en_s1, t_crc_en_s2;

reg     blackout;

assign  SYNDR_VAL  =  t_crc_en_s1 && FEC_LOCK;

always @(posedge CLK)
if (RST)
begin
	t_crc_en_s0 <= 1'b0;
	t_crc_en_s1 <= 1'b0;
	t_crc_en_s2 <= 1'b0;
end
else
begin
	t_crc_en_s0 <= T_CRC_ENA;
	t_crc_en_s1 <= t_crc_en_s0;
	t_crc_en_s2 <= t_crc_en_s1;
end

/* sample T-WORD CRC on enable
	 * hold shadow copy until next version becomes available.
	 * t_crc_shadow_val should stay 1'b1 once machine enter normal operation
	 */
always @(posedge CLK)
if (RST)
begin
	t_crc_sample <= 'h0;	
	dec_crc_sample <= 'h0;	
end
else
begin
	t_crc_sample <= T_CRC;	
	dec_crc_sample <= DEC_CRC;	
end

/* generator for syndrome vector and crc_fail
	 * CRC_FAIL is asserted for 1 pulse only. (lags 2 clks)
	 * DEC_CRC (from locally generated CRC lags by 1 CLK)
	 */
always @(posedge CLK)
if (RST)
begin
	CRC_FAIL <= 1'b0;
	SYNDR <= 'h0;
end
else if (t_crc_en_s0 && !blackout)
begin
	SYNDR <= t_crc_sample ^ dec_crc_sample;
end
else if (t_crc_en_s1 && !blackout)
begin
	CRC_FAIL <= |SYNDR;
end
else 
begin
	CRC_FAIL <= 1'b0;
end

/* Blackout period after generating CRC_FAIL
	 * By the time CRC_FAIL detected, the machine would have already
	 * moved onto the next FEC block.  It is too late to retro-actively 
	 * slip the data stream by 1 cycle.  The slip is thus applied to the
	 * middle of then next block, which would certainly corrupt it.  This
	 * corrupted block is thrown away.  CRC check will resume starting 
	 * the following FEC block
	 */
always @(posedge CLK)
if (RST)
	blackout <= 1'b0;
else if (blackout && t_crc_en_s2)
	blackout <= 1'b0;
else if (!FEC_LOCK && CRC_FAIL)
	blackout <= 1'b1;

/* FEC_LOCK:
	 * 4 consecutive CRC match declears lock
	 * 4 consecutive CRC mismatch declears out-of-lock
	 */

localparam SM_FEC_NLOCK    =  3'h0;
localparam SM_FEC_LOCK     =  3'h7;
localparam SM_FEC_G0       =  3'h1;
localparam SM_FEC_G1       =  3'h2;
localparam SM_FEC_G2       =  3'h3;
localparam SM_FEC_B0       =  3'h4;
localparam SM_FEC_B1       =  3'h5;
localparam SM_FEC_B2       =  3'h6;

reg     [2:0] sm_fec_s, sm_fec_ns;

always @(posedge CLK)
if (RST)
	sm_fec_s <= SM_FEC_NLOCK;
else
	sm_fec_s <= sm_fec_ns;

always @(
	sm_fec_s
	or blackout
	or t_crc_en_s2
	or CRC_FAIL)
begin
	sm_fec_ns  =  sm_fec_s;
	if (!blackout && t_crc_en_s2)
		case (sm_fec_s)
		SM_FEC_NLOCK :
	if (!CRC_FAIL)
		sm_fec_ns  =  SM_FEC_G0;
	
	SM_FEC_G0 :
	if (!CRC_FAIL)
		sm_fec_ns  =  SM_FEC_G1;
	else 
		sm_fec_ns  =  SM_FEC_NLOCK;
	
	SM_FEC_G1 :
	if (!CRC_FAIL)
		sm_fec_ns  =  SM_FEC_G2;
	else 
		sm_fec_ns  =  SM_FEC_NLOCK;
	
	SM_FEC_G2 :	
	if (!CRC_FAIL)
		sm_fec_ns  =  SM_FEC_LOCK;
	else 
		sm_fec_ns  =  SM_FEC_NLOCK;
	
	SM_FEC_LOCK :
	if (CRC_FAIL)
		sm_fec_ns  =  SM_FEC_B0;
	
	SM_FEC_B0 :
	if (CRC_FAIL)
		sm_fec_ns  =  SM_FEC_B1;
	else 
		sm_fec_ns  =  SM_FEC_LOCK;
	
	SM_FEC_B1 :
	if (CRC_FAIL)
		sm_fec_ns  =  SM_FEC_B2;
	else 
		sm_fec_ns  =  SM_FEC_LOCK;
	
	SM_FEC_B2 :	
	if (CRC_FAIL)
		sm_fec_ns  =  SM_FEC_NLOCK;
	else 
		sm_fec_ns  =  SM_FEC_LOCK;
	
	default :
	sm_fec_ns  =  SM_FEC_NLOCK;
	
	endcase
end

always @(posedge CLK)
if (RST)
	FEC_LOCK <= 1'b0;
else
	FEC_LOCK <= (sm_fec_s == SM_FEC_LOCK) || 
	(sm_fec_s == SM_FEC_B0) ||
	(sm_fec_s == SM_FEC_B1) ||
	(sm_fec_s == SM_FEC_B2);

always @(posedge CLK)
if (RST)
	SLIP <= 1'b0;
else
	SLIP <= (sm_fec_s == SM_FEC_NLOCK) && CRC_FAIL;
endmodule
