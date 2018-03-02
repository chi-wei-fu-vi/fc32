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
module scsi_inq (
	input iCLK,
	input iRST_N,
	input[1:0][63:0] iINQ_DATA,
	input[1:0] iINQ_DATA_VALID,
	input[1:0][23:0] iINQ_D_ID_OUT,
	input[1:0][23:0] iINQ_S_ID_OUT,
	input[1:0][15:0] iINQ_OX_ID_OUT,
	input[1:0] iINQ_IS_CMD,
	input[1:0] iINQ_IS_RSP,
	input[1:0] iINQ_SOP,
	input[1:0] iINQ_EOP,
	input[1:0] iINQ_ERR,
	input[1:0][55:0] iINQ_LAST_TS,
	input iINQ_MATCH_EXPECTED,
	//output logic[1:0] oINQ_DETECT, // sim only
	output logic[1:0][63:0] oINQ_DATA,
	output logic[1:0] oINQ_DATA_VALID,
	output logic[1:0] oINQ_EOP,
	output logic[1:0] oINQ_IS_CMD,
	output logic[1:0] oINQ_IS_MATCH,
	output logic[1:0] oINQ_ERR,
	output logic[1:0][55:0] oINQ_LAST_TS
);

logic[23:0] d_id;
logic[23:0] s_id;
logic[15:0] ox_id;
//logic[1:0] rsp_inq;

// Assert INQ_DETECT and export to extractor - TODO: No support for extended frames in extractor templates
//assign oINQ_DETECT[0] = (rsp_inq[0] | oINQ_IS_MATCH[0]) & iINQ_SOP[0];
//assign oINQ_DETECT[1] = (rsp_inq[1] | oINQ_IS_MATCH[1]) & iINQ_SOP[1];
// Check for matching criteria
assign oINQ_IS_MATCH[0] = iINQ_IS_RSP[0] & (& (d_id[23:0] ~^ iINQ_S_ID_OUT[0][23:0])) & (& (s_id[23:0] ~^ iINQ_D_ID_OUT[0][23:0])) & (& (ox_id[15:0] ~^ iINQ_OX_ID_OUT[0][15:0])) & iINQ_MATCH_EXPECTED;
assign oINQ_IS_MATCH[1] = iINQ_IS_RSP[1] & (& (d_id[23:0] ~^ iINQ_S_ID_OUT[1][23:0])) & (& (s_id[23:0] ~^ iINQ_D_ID_OUT[1][23:0])) & (& (ox_id[15:0] ~^ iINQ_OX_ID_OUT[1][15:0])) & iINQ_MATCH_EXPECTED;

// Pass through information
assign oINQ_DATA = iINQ_DATA;
assign oINQ_DATA_VALID = iINQ_DATA_VALID;
assign oINQ_EOP = iINQ_EOP;
assign oINQ_IS_CMD = iINQ_IS_CMD;
assign oINQ_ERR = iINQ_ERR;
assign oINQ_LAST_TS = iINQ_LAST_TS;

always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		d_id[23:0] <= 24'b0;
		s_id[23:0] <= 24'b0;
		ox_id[15:0] <= 16'b0;
		//oINQ_DETECT[1:0] <= 2'b0;
		//rsp_inq[1:0] <= 2'b0;
	end else begin
		// Save the IDs of an outbound inquiry command
		if (iINQ_IS_CMD[0]) begin
			d_id[23:0] <= iINQ_D_ID_OUT[0][23:0];
			s_id[23:0] <= iINQ_S_ID_OUT[0][23:0];
			ox_id[15:0] <= iINQ_OX_ID_OUT[0][15:0];
		end else if (iINQ_IS_CMD[1]) begin
			d_id[23:0] <= iINQ_D_ID_OUT[1][23:0];
			s_id[23:0] <= iINQ_S_ID_OUT[1][23:0];
			ox_id[15:0] <= iINQ_OX_ID_OUT[1][15:0];
		end
		
		/*// Check for channel 0 inquiry response match - TODO: No support for extended frames in extractor templates
		//if (oINQ_IS_MATCH[0] & ~iINQ_SOP[0]) begin
		if (oINQ_IS_MATCH[0]) begin
			oINQ_DETECT[0] <= 1'b1;
		//end else begin
		end else if (iINQ_EOP[0] == 1 || |iINQ_ERR[0] || |iINQ_IS_CMD) begin // gatekeeper ensures EOP
			oINQ_DETECT[0] <= 1'b0;
		end
		
		// Check for channel 1 inquiry response match - TODO: No support for extended frames in extractor templates
		//if (oINQ_IS_MATCH[1] & ~iINQ_SOP[1]) begin
		if (oINQ_IS_MATCH[1]) begin
			oINQ_DETECT[1] <= 1'b1;
		//end else begin
		end else if (iINQ_EOP[1] == 1 || |iINQ_ERR[1] || |iINQ_IS_CMD) begin // gatekeeper ensures EOP
			oINQ_DETECT[1] <= 1'b0;
		end*/
	end
end

// Make sure we don't have simultaneous matches
//ONLY_CH0_ACTIVE_INQ: assert property (@(posedge iCLK)(oINQ_DETECT[0] == 1 |-> oINQ_DETECT[1] != 1));
//ONLY_CH1_ACTIVE_INQ: assert property (@(posedge iCLK)(oINQ_DETECT[1] == 1 |-> oINQ_DETECT[0] != 1));

endmodule
