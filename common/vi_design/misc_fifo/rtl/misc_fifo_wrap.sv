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
module misc_fifo_wrap (
	input iCLK,
	input iCLK_PCIE,
	input iRST_N,
	input iRST_PCIE_N,
	input[127:0] iMISC_DATA,
	input iMISC_PUSH_FIFO,
	input iMISC_POP_FIFO,
	output logic[255:0] oMISC_DATA,
	output logic oMISC_DATA_V,
	output logic oMISC_FIFO_FULL,
	output logic oMISC_FIFO_EMPTY,
	output logic oMISC_FIFO_AEMPTY,
	output logic oMISC_FIFO_RD_REQ,
	output logic oMISC_FIFO_BUSY
);

enum {IDLE, BUSY} state, next;
logic[127:0] fifo_wr_data;
logic fifo_wr, fifo_wr_full, fifo_wr_empty, fifo_rd_empty;
logic fifo_rd_empty_r;
logic fifo_rd_sync;
logic[7:0] usedw;

// Output-side almost empty signal
assign oMISC_FIFO_AEMPTY = fifo_rd_empty;
assign oMISC_FIFO_EMPTY = fifo_rd_empty_r;

// State machine - for zero filling and asserting busy (as its emptying)
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N)
		state <= IDLE;
	else
		state <= next;
end

always_comb begin
	next = IDLE;
	fifo_wr_data = iMISC_DATA;
	fifo_wr = iMISC_PUSH_FIFO;
	oMISC_FIFO_BUSY = 1'b0;

	unique case (state)
		// Don't interfere with the inputs while waiting
		IDLE: begin
			if (fifo_wr_full | fifo_rd_sync) begin
				next = BUSY;
				oMISC_FIFO_BUSY = 1'b1;
			end else
				next = IDLE;
		end
		// Wait until it's emptied before allowing more writes
		BUSY: begin
			fifo_wr_data = 128'd0;
			fifo_wr = 1'b0;
			oMISC_FIFO_BUSY = 1'b1;

			if (fifo_wr_empty)
				next = IDLE;
			else
				next = BUSY;
		end
	endcase	
end

// Flop the RD iMISC_POP_FIFO signal
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N)
		fifo_rd_sync <= 1'b0;
	else
		fifo_rd_sync <= iMISC_POP_FIFO;
end

// Flop the RD empty signal (seems to behave like AEMPTY instead)
always_ff @(posedge iCLK_PCIE or negedge iRST_PCIE_N) begin
	if (~iRST_PCIE_N)
		fifo_rd_empty_r <= 1'b0;
	else
		fifo_rd_empty_r <= fifo_rd_empty;
end

// Data valid (DATA_V) signal (required for DPL buffer and arbitration) and output side request
always_ff @(posedge iCLK_PCIE or negedge iRST_PCIE_N) begin
	if (~iRST_PCIE_N)begin
		oMISC_DATA_V <= 1'b0;
		oMISC_FIFO_RD_REQ <= 1'b0;
	end else begin
		if (iMISC_POP_FIFO & ~oMISC_FIFO_AEMPTY)
			oMISC_DATA_V <= 1'b1;
		else
			oMISC_DATA_V <= 1'b0;

		if (usedw[3:0] == 4'b0000 && |usedw[7:4]) // only multiples of 16
			oMISC_FIFO_RD_REQ <= 1'b1;
		else
			oMISC_FIFO_RD_REQ <= 1'b0;
			
	end
end

// Dual clock FIFO RAM
misc_fifo misc_fifo_u (
	.aclr(~iRST_N), // synchronized with wr_clk
	.data(fifo_wr_data),
	.rdclk(iCLK_PCIE),
	.rdreq(iMISC_POP_FIFO),
	.wrclk(iCLK),
	.wrreq(fifo_wr),
	.q(oMISC_DATA),
	.wrempty(fifo_wr_empty),
	.rdempty(fifo_rd_empty),
	.rdfull(oMISC_FIFO_FULL),
	.rdusedw(usedw),
	.wrfull(fifo_wr_full)
);

endmodule
