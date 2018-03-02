//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// Source files are confidential and proprietary and may not be accessed,
// used, disclosed, modified, or disseminated to third parties without prior
// express written consent of Virtual Instruments Corporation.  All rights reserved.
// $HeadURL:$
// $Author:$
// $Date:$
// $Revision:$
//**************************************************************************/
module misc_rr_arbiter #(
	NUM_LINKS = 12,
	DATA_WIDTH = 256,
	SOFT_XFR_LIMIT = 12, // 2^x cycles between each aggregate transfer
	HARD_XFR_LIMIT = 8,  // 2^x cycles between any two transfers
	BIG_ENDIAN = 0 // little or big endian output (PCie is little endian)
) (
	input iCLK,
	input iRST_N,
	input[55:0] iGLOBAL_TIMESTAMP,
	input iEND_OF_INTERVAL,
	input[NUM_LINKS-1:0][DATA_WIDTH-1:0] iMISC_ARB_DATA,
	input[NUM_LINKS-1:0] iMISC_ARB_DATA_V,
	input[NUM_LINKS-1:0] iMISC_ARB_REQ,
	input[NUM_LINKS-1:0] iMISC_ARB_FULL,
	input[NUM_LINKS-1:0] iMISC_ARB_EMPTY,
	input[NUM_LINKS-1:0] iMISC_ARB_AEMPTY,
	input iMISC_PCIE_GRANT,
	input[3:0] iMISC_FIFO_CTRL,
	output logic oMISC_PCIE_REQ, // PCIE_REQ
	output logic[DATA_WIDTH-1:0] oMISC_ARB_DATA,
	output logic oMISC_ARB_DATA_V,
	output logic[NUM_LINKS-1:0] oMISC_ARB_FIFO_POP, // ARB GRANT
	output logic oMISC_ARB_DATA_CNT,
	output logic oMISC_ARB_INTV_CNT,
	output logic oMISC_ARB_ZERO_CNT
);
import bali_lib_pkg::*;

logic[NUM_LINKS+1:0] state, next; // per-link lock + zero-fill + interval
logic[DATA_WIDTH-1:0][NUM_LINKS-1:0] transpose;
logic[NUM_LINKS-1:0] misc_fifo_next_grant;
logic[DATA_WIDTH-1:0] be_data; // big endian data
logic eoi;
logic[6:0] cycle_cnt; // 128 cycles for full 4K transfer (next cycle = full when this counter saturates)
logic[55:0] last_ts; // last global timestamp
logic[SOFT_XFR_LIMIT-1:0] limit_cnt; // soft limit (defers to FIFO full signal)
logic pcie_granted; // sticky bit to preserve state of pcie grant (grants deassert immediately)
genvar i, j;

// Data valid
assign oMISC_ARB_DATA_V = state[NUM_LINKS+1] | (state[NUM_LINKS] & pcie_granted) | |iMISC_ARB_DATA_V; // when data is valid by either arbiter-fill or data from le

// Debug counters for 64-byte pkts
assign oMISC_ARB_INTV_CNT = state[NUM_LINKS] & pcie_granted;
assign oMISC_ARB_ZERO_CNT = state[NUM_LINKS+1];

// Final data output
assign oMISC_ARB_DATA = BIG_ENDIAN ? be_data : {be_data[7:0], be_data[15:8], be_data[23:16], be_data[31:24], be_data[39:32], be_data[47:40], be_data[55:48], be_data[63:56], be_data[71:64],
						be_data[79:72], be_data[87:80], be_data[95:88], be_data[103:96], be_data[111:104], be_data[119:112], be_data[127:120], be_data[135:128],
						be_data[143:136], be_data[151:144], be_data[159:152], be_data[167:160], be_data[175:168], be_data[183:176], be_data[191:184], be_data[199:192],
						be_data[207:200], be_data[215:208], be_data[223:216], be_data[231:224], be_data[239:232], be_data[247:240], be_data[255:248]};

//////////////////////////////////////////////////////////////////////////////
// Arbiter
//////////////////////////////////////////////////////////////////////////////
arbiter_round_robin #(
  .WIDTH   (NUM_LINKS)
) arbiter_round_robin_inst (
	.iRST    (~iRST_N),
	.iCLK    (iCLK),
	.iREQ    (iMISC_ARB_REQ),
	.oGNT    (misc_fifo_next_grant)
);

// Transpose the data array and then select the correct line
generate
	// Transpose operation
	for (i=0; i < DATA_WIDTH; i++) begin : arr_transpose_x
		for (j=0; j < NUM_LINKS; j++) begin : arr_transpose_y
			assign transpose[i][j] = iMISC_ARB_DATA[j][i];
		end
	end

	// And all possibilities in each data bit (only the onehot state will be allowed to have a 1)
	// 0-fill for intv pkt
	for (i=64; i < DATA_WIDTH; i++) begin : out3
		assign be_data[i] = (state[NUM_LINKS] & pcie_granted) ? 1'b0 : |(transpose[i] & state[NUM_LINKS-1:0]); // real data or stat pkt?
	end
	// last_ts for intv pkt
	for (i=8; i < 64; i++) begin : out2
		assign be_data[i] = (state[NUM_LINKS] & pcie_granted) ? last_ts[i-8] : |(transpose[i] & state[NUM_LINKS-1:0]); // real data or stat pkt?
	end
	// pkt type #7 for intv pkt
	for (i=3; i < 8; i++) begin : out1
		assign be_data[i] = (state[NUM_LINKS] & pcie_granted) ? 1'b0 : |(transpose[i] & state[NUM_LINKS-1:0]); // real data or stat pkt?
	end
	for (i=0; i < 3; i++) begin : out0
		assign be_data[i] = (state[NUM_LINKS] & pcie_granted) ? 1'b1 : |(transpose[i] & state[NUM_LINKS-1:0]); // real data or stat pkt?
	end
endgenerate

// Priority shifter, end of interval sticky bit, cycle counter, last timestamp, limiter counter, sticky bit for grants
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		eoi <= 1'b0;
		cycle_cnt <= 7'b0;
		last_ts <= 56'd0;
		limit_cnt <= {HARD_XFR_LIMIT{1'b1}};
	end else begin
		// Keep sticky bit unless:
		// 1: interval stat is being pushed
		// 2: status control is off
		eoi <= (iEND_OF_INTERVAL | (eoi & ~state[NUM_LINKS])) & (|iMISC_FIFO_CTRL); 
	
		// Get last G_TS	
		if (iEND_OF_INTERVAL)
			last_ts <= iGLOBAL_TIMESTAMP;

		// Xfer cycler counter
		if (state == {1'b0, 1'b0, {NUM_LINKS{1'b0}}}) // idle reset
			cycle_cnt <= 7'b0;
		else if (oMISC_ARB_DATA_V & ~&cycle_cnt) // writing interval stat, zero-fill, or pop
			cycle_cnt <= cycle_cnt + 7'd1;
		else
			cycle_cnt <= cycle_cnt;

		// Xfer throughput limit counter
		if (|state)
			limit_cnt <= {HARD_XFR_LIMIT{1'b0}};
		else if (&limit_cnt)
			limit_cnt <= limit_cnt;
		else
			limit_cnt <= limit_cnt + 12'd1;
		
	end
end

// State machine
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N)
		state <= {1'b0, 1'b0, {NUM_LINKS{1'b0}}};
	else
		state <= next;
end

always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		oMISC_ARB_FIFO_POP <= {NUM_LINKS{1'b0}};
		oMISC_PCIE_REQ <= 1'b0;
		pcie_granted <= 1'b0;
	end else if (~|state) begin // IDLE
		pcie_granted <= 1'b0;
		if (|(misc_fifo_next_grant & iMISC_ARB_FULL) & &limit_cnt[HARD_XFR_LIMIT-1:0]) begin // FIFO is full, obey hard limit only
			oMISC_PCIE_REQ <= 1'b1;
		end else if (|misc_fifo_next_grant & |limit_cnt[SOFT_XFR_LIMIT-1:HARD_XFR_LIMIT]) begin // FIFO is not empty, obey soft limit only
			oMISC_PCIE_REQ <= 1'b1;
		end else if (eoi) begin // EOI requested, send only the interval packet out
			oMISC_PCIE_REQ <= 1'b1;
		end
	end else begin
		pcie_granted <= pcie_granted;
		// PCIe Grants (sticky until end of xfer)
		if (iMISC_PCIE_GRANT) begin
			pcie_granted <= 1'b1;
			oMISC_PCIE_REQ <= 1'b0;
		end

		if (~|state[NUM_LINKS+1:0] || ~pcie_granted)
			oMISC_ARB_FIFO_POP <= 1'b0;
		else
			oMISC_ARB_FIFO_POP <= state[NUM_LINKS-1:0];			
	end
end

always_comb begin
	next = {1'b0, 1'b1, {NUM_LINKS{1'b0}}}; // defaults to IDLE
	oMISC_ARB_DATA_CNT = 1'b0; // debug counter for 512-byte pkts

	if (~|state) begin // IDLE
		if (|(misc_fifo_next_grant & iMISC_ARB_FULL) & &limit_cnt[HARD_XFR_LIMIT-1:0]) begin // FIFO is full, obey hard limit only
			oMISC_ARB_DATA_CNT = 1'b1;
			next = {1'b0, 1'b0, misc_fifo_next_grant};
		end else if (|misc_fifo_next_grant & |limit_cnt[SOFT_XFR_LIMIT-1:HARD_XFR_LIMIT]) begin // FIFO is not empty, obey soft limit only
			oMISC_ARB_DATA_CNT = 1'b1;
			next = {1'b0, 1'b0, misc_fifo_next_grant};
		end else if (eoi) begin // EOI requested, send only the interval packet out
			next = {1'b0, 1'b1, {NUM_LINKS{1'b0}}};
		end else begin // Nothing interesting happening...
			next = {1'b0, 1'b0, {NUM_LINKS{1'b0}}};
		end
	end else if (state[NUM_LINKS+1]) begin // Zero-fill
		if (&cycle_cnt) // return to idle
			next = {1'b0, 1'b0, {NUM_LINKS{1'b0}}};
		else
			next = state;	
	end else if (state[NUM_LINKS]) begin // Interval stat
		// Immediately head to 0-fill since we only have 1 cycle of data for interval state after grant
		if (pcie_granted)
			next = {1'b1, 1'b0, {NUM_LINKS{1'b0}}};
		else
			next = state;
	end else begin // LOCK on link
		if (&cycle_cnt) begin // Full xfer, no 0-fill required
			next = {1'b0, 1'b0, {NUM_LINKS{1'b0}}};
		end else if (&iMISC_ARB_AEMPTY) begin // All FIFOs are now empty
			if (eoi)
				next = {1'b0, 1'b1, {NUM_LINKS{1'b0}}};
			else
				next = {1'b1, 1'b0, {NUM_LINKS{1'b0}}};
		end else if (eoi && cycle_cnt == 7'b01101111) begin // Must insert interval stat pkt on 8th pkt slot
			next = {1'b0, 1'b1, {NUM_LINKS{1'b0}}};
		end else if (state[NUM_LINKS-1:0] == (state[NUM_LINKS-1:0] & iMISC_ARB_AEMPTY)) begin // Release once FIFO is emptied (check with a mask)
			if (|misc_fifo_next_grant) begin// If request is granted, lock state
				oMISC_ARB_DATA_CNT = 1'b1;
				next = {1'b0, 1'b0, misc_fifo_next_grant};
			end else begin // Else we are done
				next = {1'b1, 1'b0, {NUM_LINKS{1'b0}}};
			end
		end else begin // Otherwise keep arbiter locked
			next = state;
		end
	end
end

endmodule
