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
module scsi_inq_frmt (
	input iCLK,
	input iRST_N,
	input[1:0] iINQ_IS_CMD,
	input[1:0] iINQ_IS_MATCH,
	input[1:0] iINQ_EOP,
	input[1:0] iINQ_ERR,
	input[1:0][63:0] iINQ_DATA,
	input[1:0] iINQ_DATA_V,
	input[1:0][55:0] iINQ_LAST_TS,
	input[1:0][15:0] iINQ_VLAN,
	input iINQ_BUFFER_BUSY,
	input[3:0] iLINK_ID,
	input iFLUSH,
	output logic oFLUSH,
	output logic[1:0] oWR_BANK_SLOT,
	output logic oSTART_SET,
	output logic oEND_SET,
	output logic[127:0] oINQ_DATA,
	output logic oINQ_MATCH_EXPECTED,
	output logic oINQ_PKT_ERR,
	output logic oINQ_PKT_DROP,
	output logic oINQ_PKT_OVERWRITE
);

enum {IDLE, INQ_CMD_0, INQ_CMD_1, INQ_CMD_IDLE, INQ_RSP_0, INQ_RSP_1} state, next; // Tracks CMD/RSP pairs (sets)
enum {WR_IDLE, INQ_WR_HI_0, INQ_WR_HI_1, INQ_WR_LO_0, INQ_WR_LO_1} wr_state, wr_next; // Control for WR-to-bank
logic[1:0][127:0] data_buf;
logic cmd_ch, rsp_ch; // CH where CMD/RSP last seen
logic[55:0] ts; // TS of the current CMD/RSP frame
logic next_wr_bank; // selector for output data
logic data_valid; // is data valid on current channel

// Is a RSP expected? (Filters out OX_ID reuse)
assign oINQ_MATCH_EXPECTED = (state == INQ_CMD_IDLE || state == INQ_CMD_1) ? 1'b1 : 1'b0;

// State machine - inquiry set control and validation
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N)
		state <= IDLE;
	else
		state <= next;
end

always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		cmd_ch <= 1'd0;
		rsp_ch <= 1'd0;
	end else begin
		// Track the CH which CMD or RSP is seen
		if (|iINQ_IS_CMD && state != INQ_RSP_0 && (state != INQ_RSP_1  || ((~rsp_ch & iINQ_EOP[0]) | (rsp_ch & iINQ_EOP[1])))) begin
			cmd_ch <= iINQ_IS_CMD[1];
			rsp_ch <= 1'b0; // reset the other state (signals cannot be simultaneous)
		end

		if (|iINQ_IS_MATCH && (state == INQ_CMD_IDLE || (state != INQ_CMD_1 && ((~cmd_ch & iINQ_EOP[0]) | (cmd_ch & iINQ_EOP[1]))))) begin
			rsp_ch <= iINQ_IS_MATCH[1];
			cmd_ch <= 1'b0; // reset the other state (signals cannot be simultaneous)
		end
	end
end

always_comb begin
	// Default values
	next = IDLE;
	oSTART_SET = 1'b0;
	oEND_SET = 1'b0;
	ts = iINQ_LAST_TS[0];
	oFLUSH = 1'b0;
	data_valid = 1'b0;
	oINQ_PKT_ERR = 1'b0;
	oINQ_PKT_DROP = 1'b0;
	oINQ_PKT_OVERWRITE = 1'b0;
	
	unique case (state)
		// Nothing interesting happening
		IDLE: begin
			if (iFLUSH) begin // redundant (buffer should be empty) but just in case
				oFLUSH = 1'b1;
			end else if (iINQ_IS_CMD) begin // errors and ~valid won't assert IS_CMD (see scsi_inq_ch logic)
				if (~iINQ_BUFFER_BUSY) begin // only case where the buffer can be busy (pkt is not complete until it re-enters the IDLE state)
					oSTART_SET = 1'b1;
					next = INQ_CMD_0;
				end else begin
					oSTART_SET = 1'b0;
					next = IDLE;
					oINQ_PKT_DROP = 1'b1;
				end
			end else begin
				next = IDLE;
			end
		end
		// SCSI_INQ has detected a command frame passing through - fill LO bank with header
		INQ_CMD_0: begin
			if (iFLUSH) begin
				next = IDLE;
				oINQ_PKT_DROP = 1'b1;
				oFLUSH = 1'b1;
			/*end else if ((~cmd_ch & iINQ_ERR[0] & iINQ_DATA_V[0]) | (cmd_ch & iINQ_ERR[1] & iINQ_DATA_V[1])) begin // error check
				next = IDLE;
				oINQ_PKT_ERR = 1'b1;
				oFLUSH = 1'b1;*/
			end else if (|iINQ_IS_CMD) begin// errors won't assert IS_CMD (see scsi_inq_ch logic)
				oSTART_SET = 1'b1;
				next = INQ_CMD_0;
				oINQ_PKT_OVERWRITE = 1'b1;
				oFLUSH = 1'b1; // new set, get rid of old set
			end else
				next = INQ_CMD_1;

			// Mux the TS - only used for this state (can revert without consequence after)
			if (cmd_ch)
				ts = iINQ_LAST_TS[1];

			// Data valid?
			if (cmd_ch)
				data_valid = iINQ_DATA_V[1];
			else
				data_valid = iINQ_DATA_V[0];
		end
		// Record the rest of the CMD frame until EOP or RSP detected
		INQ_CMD_1: begin
			if (iFLUSH) begin
				next = IDLE;
				oINQ_PKT_DROP = 1'b1;
				oFLUSH = 1'b1;
			end else if ((~cmd_ch & iINQ_ERR[0]) | (cmd_ch & iINQ_ERR[1])) begin // error check
				next = IDLE;
				oINQ_PKT_ERR = 1'b1;
				oFLUSH = 1'b1;
			end else if (|iINQ_IS_CMD) begin // errors won't assert IS_CMD (see scsi_inq_ch logic)
				oSTART_SET = 1'b1;
				next = INQ_CMD_0;
				oINQ_PKT_OVERWRITE = 1'b1;
				oFLUSH = 1'b1; // new set, get rid of old set
			end else if ((~cmd_ch & iINQ_EOP[0]) | (cmd_ch & iINQ_EOP[1])) begin // make sure it's on the right CH
				if (|iINQ_IS_MATCH) begin
					next = INQ_RSP_0;
				end else begin
					next = INQ_CMD_IDLE;
				end
			end else begin
				next = INQ_CMD_1;
			end
			
			// Data valid?
			if (cmd_ch)
				data_valid = iINQ_DATA_V[1];
			else
				data_valid = iINQ_DATA_V[0];
		end
		// Waiting for corresponding RSP frame asserted by SCSI_INQ
		INQ_CMD_IDLE: begin
			if (iFLUSH) begin // flush the buffer, hence need to go wait to waiting for CMD
				oINQ_PKT_DROP = 1'b1;
				oFLUSH = 1'b1;
			end else if (|iINQ_IS_CMD) begin // CMD seen again, flush current set
				oSTART_SET = 1'b1;
				next = INQ_CMD_0;
				oINQ_PKT_OVERWRITE = 1'b1;
				oFLUSH = 1'b1; // new set, get rid of old set
			end else if (|iINQ_IS_MATCH) begin // RSP matched
				next = INQ_RSP_0;
			end else begin
				next = INQ_CMD_IDLE;
			end
			
			// Data valid?
			if (rsp_ch)
				data_valid = iINQ_DATA_V[1];
			else
				data_valid = iINQ_DATA_V[0];
		end
		// SCSI_INQ has detected the right response frame - fill LO bank with header
		INQ_RSP_0: begin
			if (iFLUSH) begin
				next = IDLE;
				oINQ_PKT_DROP = 1'b1;
				oFLUSH = 1'b1;
			/*end else if ((~rsp_ch & iINQ_ERR[0] & iINQ_DATA_V[0]) | (rsp_ch & iINQ_ERR[1] & iINQ_DATA_V[1])) begin // error check
				next = IDLE;
				oINQ_PKT_ERR = 1'b1;
				oFLUSH = 1'b1;*/
			end else
				next = INQ_RSP_1;
	
			// Mux the TS - only used for this state (can revert without consequence after)
			if (rsp_ch)
				ts = iINQ_LAST_TS[1];
			
			// Data valid?
			if (rsp_ch)
				data_valid = iINQ_DATA_V[1];
			else
				data_valid = iINQ_DATA_V[0];
		end
		// Record the rest of the RSP frame until EOP or CMD detected
		INQ_RSP_1: begin
			if (iFLUSH) begin
				next = IDLE;
				oINQ_PKT_DROP = 1'b1;
				oFLUSH = 1'b1;
			end else if ((~rsp_ch & iINQ_ERR[0]) | (rsp_ch & iINQ_ERR[1])) begin // error check
				next = IDLE;
				oINQ_PKT_ERR = 1'b1;
				oFLUSH = 1'b1;
			end else if ((~rsp_ch & iINQ_EOP[0]) | (rsp_ch & iINQ_EOP[1])) begin // make sure its on the right CH
				/*if (|iINQ_IS_CMD) begin // CMD seen again, flush current set
					oSTART_SET = 1'b1;
					next = INQ_CMD_0;
					oINQ_PKT_OVERWRITE = 1'b1;
					oFLUSH = 1'b1; // new set, get rid of old set
				end else begin*/
					oEND_SET = 1'b1;
					next = IDLE;
				//end
			end else begin
				next = INQ_RSP_1;
			end
			
			// Data valid?
			if (rsp_ch)
				data_valid = iINQ_DATA_V[1];
			else
				data_valid = iINQ_DATA_V[0];
		end
	endcase
end

// State machine - bank writing
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N)
		wr_state <= WR_IDLE;
	else
		wr_state <= wr_next;
end

// Writes 64-bits to one of one of 4 possible slots (LO bank and HI bank, 2 64b slots each)
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		data_buf[0] <= 128'd0;
		data_buf[1] <= 128'd0;
		oWR_BANK_SLOT <= 2'd0;
		next_wr_bank <= 1'b0;
	end else begin
		if (wr_state == INQ_WR_LO_0) begin	
			if ((state != INQ_RSP_0 && state != INQ_RSP_1 && (iINQ_IS_CMD[1] | iINQ_IS_MATCH[1])) | cmd_ch | rsp_ch)
				data_buf[0][63:0] <= {iINQ_DATA[1][7:0], iINQ_DATA[1][15:8], iINQ_DATA[1][23:16], iINQ_DATA[1][31:24], iINQ_DATA[1][39:32], iINQ_DATA[1][47:40], iINQ_DATA[1][55:48], iINQ_DATA[1][63:56]};
			else
				data_buf[0][63:0] <= {iINQ_DATA[0][7:0], iINQ_DATA[0][15:8], iINQ_DATA[0][23:16], iINQ_DATA[0][31:24], iINQ_DATA[0][39:32], iINQ_DATA[0][47:40], iINQ_DATA[0][55:48], iINQ_DATA[0][63:56]};
			
			if (state == INQ_CMD_1 && ((~cmd_ch & iINQ_EOP[0]) | (cmd_ch & iINQ_EOP[1]))) begin // EOP during CMD
				next_wr_bank <= 1'b0;
				oWR_BANK_SLOT <= 2'b01; // only lower slot is valid
			end else if (state == INQ_RSP_1 && ((~rsp_ch & iINQ_EOP[0]) | (rsp_ch & iINQ_EOP[1]))) begin // EOP during RSP
				next_wr_bank <= 1'b0;
				oWR_BANK_SLOT <= 2'b01;
			end else begin // includes the case of invalid data
				next_wr_bank <= 1'b1;
				oWR_BANK_SLOT <= 2'b00;
			end
		end else if (wr_state == INQ_WR_LO_1) begin
			if ((state != INQ_RSP_0 && state != INQ_RSP_1 && (iINQ_IS_CMD[1] | iINQ_IS_MATCH[1])) | cmd_ch | rsp_ch)
				data_buf[0][127:64] <= {iINQ_DATA[1][7:0], iINQ_DATA[1][15:8], iINQ_DATA[1][23:16], iINQ_DATA[1][31:24], iINQ_DATA[1][39:32], iINQ_DATA[1][47:40], iINQ_DATA[1][55:48], iINQ_DATA[1][63:56]};
			else
				data_buf[0][127:64] <= {iINQ_DATA[0][7:0], iINQ_DATA[0][15:8], iINQ_DATA[0][23:16], iINQ_DATA[0][31:24], iINQ_DATA[0][39:32], iINQ_DATA[0][47:40], iINQ_DATA[0][55:48], iINQ_DATA[0][63:56]};
		
			if (~data_valid) // not valid data
				oWR_BANK_SLOT <= 2'b00;
			else	
				oWR_BANK_SLOT <= 2'b11;
			next_wr_bank <= 1'b0;
		end else if (wr_state == INQ_WR_HI_0) begin
			// Append the header to the LO bank for all new CMD or RSP
			// LO bank is always written to FIFO buffer first (information is
			// pushed to HI bank in the buffer first, hence FIFO 2nd)
			if (state == INQ_CMD_0) begin
				data_buf[0][7:0] <= 8'd6;
				data_buf[0][63:8] <= ts; 
				data_buf[0][71:64] <= {4'd0, iLINK_ID};	
				data_buf[0][79:72] <= {7'd0, cmd_ch};
				data_buf[0][95:80] <= cmd_ch ? iINQ_VLAN[1] : iINQ_VLAN[0];
				data_buf[0][127:96] <= 32'd0;
			end else if (state == INQ_RSP_0) begin
				data_buf[0][7:0] <= 8'd6;
				data_buf[0][63:8] <= ts; 
				data_buf[0][71:64] <= {4'd0, iLINK_ID};	
				data_buf[0][79:72] <= {7'd0, rsp_ch};
				data_buf[0][95:80] <= rsp_ch ? iINQ_VLAN[1] : iINQ_VLAN[0];
				data_buf[0][127:96] <= 32'd0;
			end

			// Normal writing
			if ((state != INQ_RSP_0 && state != INQ_RSP_1 && (iINQ_IS_CMD[1] | iINQ_IS_MATCH[1])) | cmd_ch | rsp_ch)
				data_buf[1][63:0] <= {iINQ_DATA[1][7:0], iINQ_DATA[1][15:8], iINQ_DATA[1][23:16], iINQ_DATA[1][31:24], iINQ_DATA[1][39:32], iINQ_DATA[1][47:40], iINQ_DATA[1][55:48], iINQ_DATA[1][63:56]};
			else
				data_buf[1][63:0] <= {iINQ_DATA[0][7:0], iINQ_DATA[0][15:8], iINQ_DATA[0][23:16], iINQ_DATA[0][31:24], iINQ_DATA[0][39:32], iINQ_DATA[0][47:40], iINQ_DATA[0][55:48], iINQ_DATA[0][63:56]};
			
			if (state == INQ_CMD_1 && ((~cmd_ch & iINQ_EOP[0]) | (cmd_ch & iINQ_EOP[1]))) begin // EOP during CMD
				next_wr_bank <= 1'b1;
				oWR_BANK_SLOT <= 2'b01; // only lower slot is valid
			end else if (state == INQ_RSP_1 && ((~rsp_ch & iINQ_EOP[0]) | (rsp_ch & iINQ_EOP[1]))) begin // EOP during RSP
				next_wr_bank <= 1'b1;
				oWR_BANK_SLOT <= 2'b01;
			end else if (state == INQ_CMD_0 || state == INQ_RSP_0) begin // special SOP state (write pkt header)
				next_wr_bank <= 1'b0;
				oWR_BANK_SLOT <= 2'b11;
			end else begin // also includes the case of invalid data
				next_wr_bank <= 1'b0;
				oWR_BANK_SLOT <= 2'b00;
			end
		end else if (wr_state == INQ_WR_HI_1) begin
			if ((state != INQ_RSP_0 && state != INQ_RSP_1 && (iINQ_IS_CMD[1] | iINQ_IS_MATCH[1])) | cmd_ch | rsp_ch)
				data_buf[1][127:64] <= {iINQ_DATA[1][7:0], iINQ_DATA[1][15:8], iINQ_DATA[1][23:16], iINQ_DATA[1][31:24], iINQ_DATA[1][39:32], iINQ_DATA[1][47:40], iINQ_DATA[1][55:48], iINQ_DATA[1][63:56]};
			else
				data_buf[1][127:64] <= {iINQ_DATA[0][7:0], iINQ_DATA[0][15:8], iINQ_DATA[0][23:16], iINQ_DATA[0][31:24], iINQ_DATA[0][39:32], iINQ_DATA[0][47:40], iINQ_DATA[0][55:48], iINQ_DATA[0][63:56]};

			if (~data_valid) // not valid data
				oWR_BANK_SLOT <= 2'b00;
			else
				oWR_BANK_SLOT <= 2'b11;
			next_wr_bank <= 1'b1;
		end else begin // Output 0 if no expected pushes (no latching)
			data_buf[0] <= 128'd0;
			data_buf[1] <= 128'd0;
			oWR_BANK_SLOT <= 2'b00;
		end
	end
end

// Round robin of 64b data pushing into 128b output - idles when no FIFO push necessary
always_comb begin
	wr_next = WR_IDLE;

	if (next_wr_bank)
		oINQ_DATA = data_buf[1];
	else
		oINQ_DATA = data_buf[0]; // default behaviour is to output the LO bank (doesn't matter since WR_BANK would be low anyways)

	unique case (wr_state)
		// Nothing intersting, wait for CMD or RSP frame
		WR_IDLE: begin	
			if (|iINQ_IS_CMD || (state == INQ_CMD_IDLE && |iINQ_IS_MATCH)) // continue idling if no RSP was expected
				wr_next = INQ_WR_HI_0;
			else
				wr_next = WR_IDLE;
		end
		// Write to bit 0 to 63 in HI bank
		INQ_WR_HI_0: begin
			oINQ_DATA = data_buf[0]; // output is muxed to opposing bank during wr
			if ((state == INQ_CMD_0 || state == INQ_CMD_1) && |iINQ_IS_CMD) begin // CMD OVR
				wr_next = INQ_WR_LO_0;
			end else if (state == INQ_CMD_1 && ((~cmd_ch & iINQ_EOP[0]) | (cmd_ch & iINQ_EOP[1]))) begin // EOP during CMD
				if (|iINQ_IS_CMD | |iINQ_IS_MATCH) // immediate wr
					wr_next = INQ_WR_LO_0;
				else
					wr_next = WR_IDLE;	
			end else if (state == INQ_RSP_1 && ((~rsp_ch & iINQ_EOP[0]) | (rsp_ch & iINQ_EOP[1]))) begin // EOP during RSP
				/*if (|iINQ_IS_CMD) begin // finding another RSP after RSP is invalid
					wr_next = INQ_WR_LO_0;
				end else begin*/
					wr_next = WR_IDLE;
				//end
			end else if (~data_valid) begin // keep state if invalid data on active bank
				wr_next = INQ_WR_HI_0;
			end else begin
				wr_next = INQ_WR_HI_1;
			end
		end
		// Write to bit 64 to 127 in HI bank
		INQ_WR_HI_1: begin
			oINQ_DATA = data_buf[0]; // output is muxed to opposing bank during wr
			if ((state == INQ_CMD_0 || state == INQ_CMD_1) && |iINQ_IS_CMD) begin // CMD OVR
				wr_next = INQ_WR_LO_0;
			end else if (state == INQ_CMD_1 && ((~cmd_ch & iINQ_EOP[0]) | (cmd_ch & iINQ_EOP[1]))) begin // EOP during CMD
				if (|iINQ_IS_CMD | |iINQ_IS_MATCH)
					wr_next = INQ_WR_LO_0;
				else
					wr_next = WR_IDLE;	
			end else if (state == INQ_RSP_1 && ((~rsp_ch & iINQ_EOP[0]) | (rsp_ch & iINQ_EOP[1]))) begin // EOP during RSP
				/*if (|iINQ_IS_CMD) begin
					wr_next = INQ_WR_LO_0;
				end else begin*/
					wr_next = WR_IDLE;
				//end
			end else if (~data_valid) begin // keep state if invalid data on active bank
				wr_next = INQ_WR_HI_1;
			end else begin
				wr_next = INQ_WR_LO_0;
			end
		end
		// Write to bit 0 to 63 in LO bank
		INQ_WR_LO_0: begin
			oINQ_DATA = data_buf[1]; // output is muxed to opposing bank during wr
			if ((state == INQ_CMD_0 || state == INQ_CMD_1) && |iINQ_IS_CMD) begin // CMD OVR
				wr_next = INQ_WR_LO_0;
			end else if (state == INQ_CMD_1 && ((~cmd_ch & iINQ_EOP[0]) | (cmd_ch & iINQ_EOP[1]))) begin // EOP during CMD
				if (|iINQ_IS_CMD | |iINQ_IS_MATCH)
					wr_next = INQ_WR_LO_0;
				else
					wr_next = WR_IDLE;	
			end else if (state == INQ_RSP_1 && ((~rsp_ch & iINQ_EOP[0]) | (rsp_ch & iINQ_EOP[1]))) begin // EOP during RSP
				/*if (|iINQ_IS_CMD) begin
					wr_next = INQ_WR_LO_0;
				end else begin*/
					wr_next = WR_IDLE;
				//end
			end else if (~data_valid) begin // keep state if invalid data on active bank
				wr_next = INQ_WR_LO_0;
			end else begin
				wr_next = INQ_WR_LO_1;
			end
		end
		// Write to bit 64 to 127 in LO bank
		INQ_WR_LO_1: begin
			oINQ_DATA = data_buf[1]; // output is muxed to opposing bank during wr
			if ((state == INQ_CMD_0 || state == INQ_CMD_1) && |iINQ_IS_CMD) begin // CMD OVR
				wr_next = INQ_WR_LO_0;
			end else if (state == INQ_CMD_1 && ((~cmd_ch & iINQ_EOP[0]) | (cmd_ch & iINQ_EOP[1]))) begin // EOP during CMD
				if (|iINQ_IS_CMD | |iINQ_IS_MATCH)
					wr_next = INQ_WR_LO_0;
				else
					wr_next = WR_IDLE;
			end else if (state == INQ_RSP_1 && ((~rsp_ch & iINQ_EOP[0]) | (rsp_ch & iINQ_EOP[1]))) begin // EOP during RSP
				/*if (|iINQ_IS_CMD) begin
					wr_next = INQ_WR_LO_0;
				end else begin*/
					wr_next = WR_IDLE;
				//end
			end else if (~data_valid) begin // keep state if invalid data on active bank
				wr_next = INQ_WR_LO_1;
			end else begin
				wr_next = INQ_WR_HI_0;
			end
		end
	endcase
end
endmodule
