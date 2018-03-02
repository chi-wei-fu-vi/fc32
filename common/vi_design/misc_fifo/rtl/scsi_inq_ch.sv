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
module scsi_inq_ch # (
	FCOE = 0
) (
	input iCLK,
	input iRST_N,
	input[63:0] iFC_INQ_DATA,
	input[2:0] iFC_INQ_EMPTY,
	input iFC_INQ_SOP,
	input iFC_INQ_EOP,
	input iFC_INQ_ERR,
	input iFC_INQ_VALID,
	input[55:0] iGLOBAL_TIMESTAMP,
	output logic[63:0] oFC_EXTR_DATA,
	output logic[2:0] oFC_EXTR_EMPTY,
	output logic oFC_EXTR_SOP,
	output logic oFC_EXTR_EOP,
	output logic oFC_EXTR_ERR,
	output logic oFC_EXTR_VALID,
	output logic[23:0] oD_ID,
	output logic[23:0] oS_ID,
	output logic[15:0] oOX_ID,
	output logic oIS_CMD,
	output logic oIS_RSP,
	output logic[55:0] oLAST_TS
);
localparam OPCODE = 8'h12;
localparam PAGE = 8'h83;

logic[63:0] iFC_INQ_DATA_buf[3:0];
logic[2:0] iFC_INQ_EMPTY_buf[3:0];
logic iFC_INQ_SOP_buf[3:0];
logic iFC_INQ_EOP_buf[3:0];
logic iFC_INQ_ERR_buf[3:0];
logic iFC_INQ_VALID_buf[3:0];

// TODO: No support for extended frames in extractor templates
/*enum {IDLE, SOF08B_EXT, SOF16B_EXT, SOF24B_EXT, SOF32B_EXT, SOF40B_EXT,
		SOF08B, SOF16B, SOF24B, SOF32B, SOF40B} state, next;*/
enum {IDLE, SOF08B, SOF16B, SOF24B, SOF32B, SOF40B, ETH08B, ETH16B, ETH24B} state, next;

// Pipeline for data (special latching mechanism for alteranting cycles of valid data)
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		iFC_INQ_DATA_buf[0][63:0] <= 64'b0;
		iFC_INQ_DATA_buf[1][63:0] <= 64'b0;
		iFC_INQ_DATA_buf[2][63:0] <= 64'b0;
		iFC_INQ_DATA_buf[3][63:0] <= 64'd0;
		oFC_EXTR_DATA[63:0] <= 64'b0;
		iFC_INQ_EMPTY_buf[0] <= 3'd0;
		iFC_INQ_EMPTY_buf[1] <= 3'd0;
		iFC_INQ_EMPTY_buf[2] <= 3'd0;
		iFC_INQ_EMPTY_buf[3] <= 3'd0;
		oFC_EXTR_EMPTY <= 3'd0;
		iFC_INQ_SOP_buf[0] <= 1'b0;
		iFC_INQ_SOP_buf[1] <= 1'b0;
		iFC_INQ_SOP_buf[2] <= 1'b0;
		iFC_INQ_SOP_buf[3] <= 1'b0;
		oFC_EXTR_SOP <= 1'b0;
		iFC_INQ_EOP_buf[0] <= 1'b0;
		iFC_INQ_EOP_buf[1] <= 1'b0;
		iFC_INQ_EOP_buf[2] <= 1'b0;
		iFC_INQ_EOP_buf[3] <= 1'b0;
		oFC_EXTR_EOP <= 1'b0;
		iFC_INQ_ERR_buf[0] <= 1'b0;
		iFC_INQ_ERR_buf[1] <= 1'b0;
		iFC_INQ_ERR_buf[2] <= 1'b0;
		iFC_INQ_ERR_buf[3] <= 1'b0;
		oFC_EXTR_ERR <= 1'b0;
		iFC_INQ_VALID_buf[0] <= 1'b0;
		iFC_INQ_VALID_buf[1] <= 1'b0;
		iFC_INQ_VALID_buf[2] <= 1'b0;
		iFC_INQ_VALID_buf[3] <= 1'b0;
		oFC_EXTR_VALID <= 1'b0;
	end else if (iFC_INQ_SOP) begin // push first 8 bytes in
		iFC_INQ_DATA_buf[0][63:0] <= iFC_INQ_DATA[63:0];
		iFC_INQ_DATA_buf[1][63:0] <= 64'd0;
		iFC_INQ_DATA_buf[2][63:0] <= iFC_INQ_DATA_buf[1][63:0];
		iFC_INQ_DATA_buf[3][63:0] <= iFC_INQ_DATA_buf[2][63:0];
		oFC_EXTR_DATA[63:0] <= iFC_INQ_DATA_buf[3][63:0];
		iFC_INQ_EMPTY_buf[0][2:0] <= iFC_INQ_EMPTY[2:0];
		iFC_INQ_EMPTY_buf[1][2:0] <= 3'd0;
		iFC_INQ_EMPTY_buf[2][2:0] <= iFC_INQ_EMPTY_buf[1][2:0];
		iFC_INQ_EMPTY_buf[3][2:0] <= iFC_INQ_EMPTY_buf[2][2:0];
		oFC_EXTR_EMPTY[2:0] <= iFC_INQ_EMPTY_buf[3][2:0];
		iFC_INQ_SOP_buf[0] <= iFC_INQ_SOP;
		iFC_INQ_SOP_buf[1] <= 1'd0;
		iFC_INQ_SOP_buf[2] <= iFC_INQ_SOP_buf[1];
		iFC_INQ_SOP_buf[3] <= iFC_INQ_SOP_buf[2];
		oFC_EXTR_SOP <= iFC_INQ_SOP_buf[3];
		iFC_INQ_EOP_buf[0] <= iFC_INQ_EOP;
		iFC_INQ_EOP_buf[1] <= 1'd0;
		iFC_INQ_EOP_buf[2] <= iFC_INQ_EOP_buf[1];
		iFC_INQ_EOP_buf[3] <= iFC_INQ_EOP_buf[2];
		oFC_EXTR_EOP <= iFC_INQ_EOP_buf[3];
		iFC_INQ_ERR_buf[0] <= iFC_INQ_ERR;
		iFC_INQ_ERR_buf[1] <= 1'd0;
		iFC_INQ_ERR_buf[2] <= iFC_INQ_ERR_buf[1];
		iFC_INQ_ERR_buf[3] <= iFC_INQ_ERR_buf[2];
		oFC_EXTR_ERR <= iFC_INQ_ERR_buf[3];
		iFC_INQ_VALID_buf[0] <= iFC_INQ_VALID;
		iFC_INQ_VALID_buf[1] <= 1'd0;
		iFC_INQ_VALID_buf[2] <= iFC_INQ_VALID_buf[1];
		iFC_INQ_VALID_buf[3] <= iFC_INQ_VALID_buf[2];
		oFC_EXTR_VALID <= iFC_INQ_VALID_buf[3];
	end else if (state == SOF08B) begin // push 2nd 8 bytes only when valid
		if (iFC_INQ_VALID) begin // latch behaviour
			iFC_INQ_DATA_buf[0][63:0] <= iFC_INQ_DATA[63:0];
			iFC_INQ_DATA_buf[1][63:0] <= iFC_INQ_DATA_buf[0][63:0];
			iFC_INQ_EMPTY_buf[0][2:0] <= iFC_INQ_EMPTY[2:0];
			iFC_INQ_EMPTY_buf[1][2:0] <= iFC_INQ_EMPTY_buf[0][2:0];
			iFC_INQ_SOP_buf[0] <= iFC_INQ_SOP;
			iFC_INQ_SOP_buf[1] <= iFC_INQ_SOP_buf[0];
			iFC_INQ_EOP_buf[0] <= iFC_INQ_EOP;
			iFC_INQ_EOP_buf[1] <= iFC_INQ_EOP_buf[0];
			iFC_INQ_ERR_buf[0] <= iFC_INQ_ERR;
			iFC_INQ_ERR_buf[1] <= iFC_INQ_ERR_buf[0];
			iFC_INQ_VALID_buf[0] <= iFC_INQ_VALID;
			iFC_INQ_VALID_buf[1] <= iFC_INQ_VALID_buf[0];
		end
		iFC_INQ_DATA_buf[2][63:0] <= 64'd0;
		iFC_INQ_DATA_buf[3][63:0] <= iFC_INQ_DATA_buf[2][63:0];
		oFC_EXTR_DATA[63:0] <= iFC_INQ_DATA_buf[3][63:0];
		iFC_INQ_EMPTY_buf[2][2:0] <= 3'd0;
		iFC_INQ_EMPTY_buf[3][2:0] <= iFC_INQ_EMPTY_buf[2][2:0];
		oFC_EXTR_EMPTY[2:0] <= iFC_INQ_EMPTY_buf[3][2:0];
		iFC_INQ_SOP_buf[2] <= 1'd0;
		iFC_INQ_SOP_buf[3] <= iFC_INQ_SOP_buf[2];
		oFC_EXTR_SOP <= iFC_INQ_SOP_buf[3];
		iFC_INQ_EOP_buf[2] <= 1'd0;
		iFC_INQ_EOP_buf[3] <= iFC_INQ_EOP_buf[2];
		oFC_EXTR_EOP <= iFC_INQ_EOP_buf[3];
		iFC_INQ_ERR_buf[2] <= 1'd0;
		iFC_INQ_ERR_buf[3] <= iFC_INQ_ERR_buf[2];
		oFC_EXTR_ERR <= iFC_INQ_ERR_buf[3];
		iFC_INQ_VALID_buf[2] <= 1'd0;
		iFC_INQ_VALID_buf[3] <= iFC_INQ_VALID_buf[2];
		oFC_EXTR_VALID <= iFC_INQ_VALID_buf[3];
	end else if (state == SOF16B) begin // push 3rd 8 bytes only when valid
		if (iFC_INQ_VALID) begin // latch behaviour
			iFC_INQ_DATA_buf[0][63:0] <= iFC_INQ_DATA[63:0];
			iFC_INQ_DATA_buf[1][63:0] <= iFC_INQ_DATA_buf[0][63:0];
			iFC_INQ_DATA_buf[2][63:0] <= iFC_INQ_DATA_buf[1][63:0];
			iFC_INQ_EMPTY_buf[0][2:0] <= iFC_INQ_EMPTY[2:0];
			iFC_INQ_EMPTY_buf[1][2:0] <= iFC_INQ_EMPTY_buf[0][2:0];
			iFC_INQ_EMPTY_buf[2][2:0] <= iFC_INQ_EMPTY_buf[1][2:0];
			iFC_INQ_SOP_buf[0] <= iFC_INQ_SOP;
			iFC_INQ_SOP_buf[1] <= iFC_INQ_SOP_buf[0];
			iFC_INQ_SOP_buf[2] <= iFC_INQ_SOP_buf[1];
			iFC_INQ_EOP_buf[0] <= iFC_INQ_EOP;
			iFC_INQ_EOP_buf[1] <= iFC_INQ_EOP_buf[0];
			iFC_INQ_EOP_buf[2] <= iFC_INQ_EOP_buf[1];
			iFC_INQ_ERR_buf[0] <= iFC_INQ_ERR;
			iFC_INQ_ERR_buf[1] <= iFC_INQ_ERR_buf[0];
			iFC_INQ_ERR_buf[2] <= iFC_INQ_ERR_buf[1];
			iFC_INQ_VALID_buf[0] <= iFC_INQ_VALID;
			iFC_INQ_VALID_buf[1] <= iFC_INQ_VALID_buf[0];
			iFC_INQ_VALID_buf[2] <= iFC_INQ_VALID_buf[1];
		end
		iFC_INQ_DATA_buf[3][63:0] <= 64'd0;
		oFC_EXTR_DATA[63:0] <= iFC_INQ_DATA_buf[3][63:0];
		iFC_INQ_EMPTY_buf[3][2:0] <= 3'd0;
		oFC_EXTR_EMPTY[2:0] <= iFC_INQ_EMPTY_buf[3][2:0];
		iFC_INQ_SOP_buf[3] <= 1'd0;
		oFC_EXTR_SOP <= iFC_INQ_SOP_buf[3];
		iFC_INQ_EOP_buf[3] <= 1'd0;
		oFC_EXTR_EOP <= iFC_INQ_EOP_buf[3];
		iFC_INQ_ERR_buf[3] <= 1'd0;
		oFC_EXTR_ERR <= iFC_INQ_ERR_buf[3];
		iFC_INQ_VALID_buf[3] <= 1'd0;
		oFC_EXTR_VALID <= iFC_INQ_VALID_buf[3];
	end else if (state == SOF24B) begin // push 4th 8 bytes into top buffer space
		if (iFC_INQ_VALID) begin // latch behaviour
			iFC_INQ_DATA_buf[0][63:0] <= iFC_INQ_DATA[63:0];
			iFC_INQ_DATA_buf[1][63:0] <= iFC_INQ_DATA_buf[0][63:0];
			iFC_INQ_DATA_buf[2][63:0] <= iFC_INQ_DATA_buf[1][63:0];
			iFC_INQ_DATA_buf[3][63:0] <= iFC_INQ_DATA_buf[2][63:0];
			iFC_INQ_EMPTY_buf[0][2:0] <= iFC_INQ_EMPTY[2:0];
			iFC_INQ_EMPTY_buf[1][2:0] <= iFC_INQ_EMPTY_buf[0][2:0];
			iFC_INQ_EMPTY_buf[2][2:0] <= iFC_INQ_EMPTY_buf[1][2:0];
			iFC_INQ_EMPTY_buf[3][2:0] <= iFC_INQ_EMPTY_buf[2][2:0];
			iFC_INQ_SOP_buf[0] <= iFC_INQ_SOP;
			iFC_INQ_SOP_buf[1] <= iFC_INQ_SOP_buf[0];
			iFC_INQ_SOP_buf[2] <= iFC_INQ_SOP_buf[1];
			iFC_INQ_SOP_buf[3] <= iFC_INQ_SOP_buf[2];
			iFC_INQ_EOP_buf[0] <= iFC_INQ_EOP;
			iFC_INQ_EOP_buf[1] <= iFC_INQ_EOP_buf[0];
			iFC_INQ_EOP_buf[2] <= iFC_INQ_EOP_buf[1];
			iFC_INQ_EOP_buf[3] <= iFC_INQ_EOP_buf[2];
			iFC_INQ_ERR_buf[0] <= iFC_INQ_ERR;
			iFC_INQ_ERR_buf[1] <= iFC_INQ_ERR_buf[0];
			iFC_INQ_ERR_buf[2] <= iFC_INQ_ERR_buf[1];
			iFC_INQ_ERR_buf[3] <= iFC_INQ_ERR_buf[2];
			iFC_INQ_VALID_buf[0] <= iFC_INQ_VALID;
			iFC_INQ_VALID_buf[1] <= iFC_INQ_VALID_buf[0];
			iFC_INQ_VALID_buf[2] <= iFC_INQ_VALID_buf[1];
			iFC_INQ_VALID_buf[3] <= iFC_INQ_VALID_buf[2];
		end
		oFC_EXTR_DATA[63:0] <= 64'd0;
		oFC_EXTR_EMPTY[2:0] <= 3'd0;
		oFC_EXTR_SOP <= 1'd0;
		oFC_EXTR_EOP <= 1'd0;
		oFC_EXTR_ERR <= 1'd0;
		oFC_EXTR_VALID <= 1'd0;
	end else begin // when idle just a standard pipeline
		if (!(state == SOF32B && ~iFC_INQ_VALID)) begin // pipelining begins when SOF32B does a match on the OPCODE location
			iFC_INQ_DATA_buf[0][63:0] <= iFC_INQ_DATA[63:0];
			iFC_INQ_DATA_buf[1][63:0] <= iFC_INQ_DATA_buf[0][63:0];
			iFC_INQ_DATA_buf[2][63:0] <= iFC_INQ_DATA_buf[1][63:0];
			iFC_INQ_DATA_buf[3][63:0] <= iFC_INQ_DATA_buf[2][63:0];
			oFC_EXTR_DATA[63:0] <= iFC_INQ_DATA_buf[3][63:0];
			iFC_INQ_EMPTY_buf[0][2:0] <= iFC_INQ_EMPTY[2:0];
			iFC_INQ_EMPTY_buf[1][2:0] <= iFC_INQ_EMPTY_buf[0][2:0];
			iFC_INQ_EMPTY_buf[2][2:0] <= iFC_INQ_EMPTY_buf[1][2:0];
			iFC_INQ_EMPTY_buf[3][2:0] <= iFC_INQ_EMPTY_buf[2][2:0];
			oFC_EXTR_EMPTY[2:0] <= iFC_INQ_EMPTY_buf[3][2:0];
			iFC_INQ_SOP_buf[0] <= iFC_INQ_SOP;
			iFC_INQ_SOP_buf[1] <= iFC_INQ_SOP_buf[0];
			iFC_INQ_SOP_buf[2] <= iFC_INQ_SOP_buf[1];
			iFC_INQ_SOP_buf[3] <= iFC_INQ_SOP_buf[2];
			oFC_EXTR_SOP <= iFC_INQ_SOP_buf[3];
			iFC_INQ_EOP_buf[0] <= iFC_INQ_EOP;
			iFC_INQ_EOP_buf[1] <= iFC_INQ_EOP_buf[0];
			iFC_INQ_EOP_buf[2] <= iFC_INQ_EOP_buf[1];
			iFC_INQ_EOP_buf[3] <= iFC_INQ_EOP_buf[2];
			oFC_EXTR_EOP <= iFC_INQ_EOP_buf[3];
			iFC_INQ_ERR_buf[0] <= iFC_INQ_ERR;
			iFC_INQ_ERR_buf[1] <= iFC_INQ_ERR_buf[0];
			iFC_INQ_ERR_buf[2] <= iFC_INQ_ERR_buf[1];
			iFC_INQ_ERR_buf[3] <= iFC_INQ_ERR_buf[2];
			oFC_EXTR_ERR <= iFC_INQ_ERR_buf[3];
			iFC_INQ_VALID_buf[0] <= iFC_INQ_VALID;
			iFC_INQ_VALID_buf[1] <= iFC_INQ_VALID_buf[0];
			iFC_INQ_VALID_buf[2] <= iFC_INQ_VALID_buf[1];
			iFC_INQ_VALID_buf[3] <= iFC_INQ_VALID_buf[2];
			oFC_EXTR_VALID <= iFC_INQ_VALID_buf[3];
		end
	end
end

// Export up for checking
assign oD_ID[23:0] = iFC_INQ_DATA_buf[3][55:32];
assign oS_ID[23:0] = iFC_INQ_DATA_buf[3][23:0];
assign oOX_ID[15:0] = iFC_INQ_DATA_buf[1][63:48];

// State machine to detect SCSI Inquiry Cmds (8'h12)
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N)
		state <= IDLE;
	else
		state <= next;
end

// Record the last timestamp from the SOP receive
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		oLAST_TS <= 56'd0;
	end else if (iFC_INQ_SOP) begin
		oLAST_TS <= iGLOBAL_TIMESTAMP;
	end	
end
			
always_comb begin
	oIS_CMD = 1'b0;
	oIS_RSP = 1'b0;
	next = IDLE;

	// Force state reset whenever SOP or EOP is seen (previous packet is forcibly cut off) or if an ERROR is seen
	if (iFC_INQ_ERR || oFC_EXTR_EOP) begin
		next = IDLE;
	end if (iFC_INQ_SOP) begin // Standard FC w/ SOF stripped begins with SOP signal
		if (FCOE) begin
			next = ETH08B;
		end else begin
			if (iFC_INQ_DATA[63:56]==8'h01 || iFC_INQ_DATA[63:56]==8'h06)
				next = SOF08B;
			else
				next = IDLE;
		end
	end else begin
		unique case (state)
			IDLE: next = IDLE;
			ETH08B: begin // Ethernet encapsulation
				if (iFC_INQ_VALID) begin // don't advance if not valid
					next = ETH16B;
				end else begin
					next = ETH08B;
				end
			end
			ETH16B: begin
				if (iFC_INQ_VALID) // don't advance if not valid
					next = ETH24B;
				else
					next = ETH16B;
			end
			ETH24B: begin
				if (iFC_INQ_VALID) // don't advance if not valid
					if (iFC_INQ_DATA[63:56]==8'h01 || iFC_INQ_DATA[63:56]==8'h06)
						next = SOF08B;
					else
						next = IDLE;
				else
					next = ETH24B;
			end
			SOF08B: begin // FC Frame
				if (iFC_INQ_VALID) begin // overwrite invalid data on next cycle
					if (iFC_INQ_DATA[63:56]==8'h08)
						next = SOF16B;
					else
						next = IDLE;
				end else begin
					next = SOF08B;
				end
			end
			SOF16B: begin
				if (iFC_INQ_VALID)
					next = SOF24B;
				else
					next = SOF16B;
			end
			SOF24B: begin 
				if (iFC_INQ_VALID)
					next = SOF32B;
				else
					next = SOF24B;
			end
			SOF32B: begin
				if (iFC_INQ_VALID) begin
					// Detect the SCSI opcode, R_CTL, Type, and F_CTL top bit (exchange originator)
					if (iFC_INQ_DATA[15:8] == PAGE && iFC_INQ_DATA[16] == 1'b1 && iFC_INQ_DATA[31:24] == OPCODE && iFC_INQ_DATA_buf[2][39]==1'b0)
						oIS_CMD = 1'b1;
					else
						oIS_RSP = 1'b1;
					next = SOF40B;
				end else begin
					next = SOF32B;
				end
			end
			SOF40B: next = IDLE;
		endcase
	end

	// Return to the IDLE state at EOP
	if (oFC_EXTR_EOP) begin
		next = IDLE;
	end
end

endmodule


