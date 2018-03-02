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
module scsi_inq_buffer (
	input iCLK,
	input iRST_N,
	input iFLUSH,
	input iFLUSH_ALL,
	input[1:0] iWR_BANK_SLOT,
	input[127:0] iINQ_DATA,
	input iSTART_SET,
	input iEND_SET,
	input iINQ_MISC_FIFO_BUSY,
	output logic[127:0] oINQ_DATA,
	output logic oINQ_PUSH_MISC_FIFO,
	output logic oINQ_BUFFER_BUSY
);
enum {IDLE, PEND, FILL, XFR} state, next;
logic[127:0] fifo_wr_data;
logic fifo_wr, fifo_aempty, fifo_aempty_r, fifo_afull, fifo_afull_r, fifo_flush, fifo_rd;
logic end_set_r; // buffer for 1 cycle delay

// Single buffer state machine
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N)
		state <= IDLE;
	else
		state <= next;
end

always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		fifo_wr_data <= 128'd0;
		fifo_wr <= 1'b0;
		fifo_rd <= 1'b0;
		end_set_r <= 1'b0;
		fifo_aempty_r <= 1'b0;
		fifo_afull_r <= 1'b0;
	end else begin
		// Write the 128b input to the buffer FIFO (write 0 where the data is invalid)
		if (state == PEND) begin
			if (iWR_BANK_SLOT[0])
				fifo_wr_data[63:0] <= iINQ_DATA[63:0];
			else
				fifo_wr_data[63:0] <= 64'd0;
			
			if (iWR_BANK_SLOT[1])
				fifo_wr_data[127:64] <= iINQ_DATA[127:64];
			else
				fifo_wr_data[127:64] <= 64'd0;
			
			// Stop writing immediately if the FIFO is full
			if (iWR_BANK_SLOT[0] | iWR_BANK_SLOT[1])
				fifo_wr <= 1'b1;
			else
				fifo_wr <= 1'b0;
		// 0 fill the rest of the buffer
		end else if (state == FILL) begin
			fifo_wr_data[127:0] <= 128'd0;
			fifo_wr <= 1'b1; // Will try to write for one extra cycle, safely ignored by fifo
		// Stop writing
		end else if (state == XFR) begin
			fifo_wr_data[127:0] <= 128'd0;
			fifo_wr <= 1'b0;
		// Do nothing
		end else begin
			fifo_wr_data[127:0] <= 128'd0;
			fifo_wr <= 1'b0;
		end
		
		// FIFO RD
		if (state == XFR && ~iINQ_MISC_FIFO_BUSY) // Write when FIFO (not bit the buffer) not busy
			fifo_rd <= 1'b1; // Will try to read after fifo_aempty_r asserted, safely caught by oINQ_PUSH_MISC_FIFO
		else
			fifo_rd <= 1'b0;

		// Buffer fifo_rd to sync with q
		oINQ_PUSH_MISC_FIFO <= fifo_rd & ~fifo_aempty_r;
		
		// Pipleline 1 cycle
		end_set_r <= iEND_SET;
		fifo_aempty_r <= fifo_aempty;
		fifo_afull_r <= fifo_afull;
	end
end

always_comb begin
	next = IDLE;
	fifo_flush = 1'b0;
	oINQ_BUFFER_BUSY = 1'b0; // buffer is busy when pkt is complete awaiting 0-fill/transfer

	unique case (state)
		// Nothing to do...
		IDLE: begin
			oINQ_BUFFER_BUSY = 1'b0;
			if (iSTART_SET) // Starts recording an inquiry set
				next = PEND;
			else
				next = IDLE;
		end 
		// Allows pushing data into the buffer
		PEND: begin
			oINQ_BUFFER_BUSY = 1'b0;
			if (iFLUSH | iFLUSH_ALL) begin // upstream flush request
				fifo_flush = 1'b1;
				if (iSTART_SET)
					next = PEND;
				else
					next = IDLE;
			end else if (iWR_BANK_SLOT[0] & fifo_afull_r) begin // fifo full before end - drop all
				fifo_flush = 1'b1;
				next = IDLE;
			end else if (end_set_r & fifo_afull) // no need to zero fill (guaranteed to enter link fifo)
				next = XFR;
			else if (end_set_r & ~fifo_afull) // done the set, zero fill (guaranteed to enter link fifo)
				next = FILL;
			else // keep going
				next = PEND;
		end
		// Force zero-fill until the buffer is full
		FILL: begin
			oINQ_BUFFER_BUSY = 1'b1;
			if (fifo_afull)
				next = XFR;
			else
				next = FILL;
		end
		// Empty the fifo into the link FIFO 
		XFR: begin
			oINQ_BUFFER_BUSY = 1'b1;
			if (fifo_aempty)
				next = IDLE;
			else
				next = XFR;
		end
	endcase
end

// FIFO RAM buffer (single clock)
scsi_inq_buffer_fifo buffer_fifo (
	.aclr(~iRST_N),
	.clock(iCLK),
	.data(fifo_wr_data),
	.rdreq(fifo_rd),
	.sclr(fifo_flush),
	.wrreq(fifo_wr),
	.almost_empty(fifo_aempty),
	.almost_full(fifo_afull),
	.empty(),
	.full(),
	.q(oINQ_DATA)
);

endmodule
