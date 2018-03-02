//***************************************************************************
// Copyright (c) 2015 Virtual Instruments.
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
module misc_le_wrap (
	input                                  iCLK,
	input                                  iCLK_PCIE,
	input                                  iRST_N,
	input                                  iRST_PCIE_N,
	input                                  iMISC_ARB_GRANT,
	input [3:0]                            iMISC_FIFO_CTRL,
	input [3:0]                            iLINK_ID,
	input [1:0]                            iCHAN_LINKUP,
	input [3:0]                            iREG_LINKCTRL_MONITORMODE,
	input [1:0][63:0]                      iINQ_DATA,
	input [1:0]                            iINQ_DATA_V,
	input [1:0][23:0]                      iINQ_D_ID,
	input [1:0][23:0]                      iINQ_S_ID,
	input [1:0][15:0]                      iINQ_OX_ID,
	input [1:0]                            iINQ_IS_CMD,
	input [1:0]                            iINQ_IS_RSP,
	input [1:0]                            iINQ_SOP,
	input [1:0]                            iINQ_EOP,
	input [1:0]                            iINQ_ERR,
	input [1:0][55:0]                      iINQ_LAST_TS,
	output  logic [255:0]                  oMISC_FIFO_DATA,
	output  logic                          oMISC_FIFO_DATA_V,
	output  logic                          oMISC_FIFO_FULL,
	output  logic                          oMISC_FIFO_EMPTY,
	output  logic                          oMISC_FIFO_AEMPTY,
	output  logic                          oMISC_FIFO_RD_REQ,
	output  logic [1:0]                    oREG_INQ_IS_CMD,
	output  logic [1:0]                    oREG_INQ_IS_MATCH,
	output  logic                          oREG_INQ_PKT_DROP,
	output  logic                          oREG_INQ_PKT_ERR,
	output  logic                          oREG_INQ_PKT_OVR

);
///////////////////////////////////////////////////////////////////////////////
// SCSI_INQ Datapath Connections
///////////////////////////////////////////////////////////////////////////////
logic[3:0] misc_fifo_ctrl_r0;
logic[3:0] misc_fifo_ctrl_r1;
logic INQ_MATCH_EXPECTED;
logic[1:0][63:0] INQ_FRMT_DATA;
logic[1:0] INQ_FRMT_DATA_V;
logic[1:0] INQ_FRMT_SOP;
logic[1:0] INQ_FRMT_EOP;
logic[1:0] INQ_FRMT_IS_CMD;
logic[1:0] INQ_FRMT_IS_MATCH;
logic[1:0] INQ_FRMT_ERR;
logic[1:0][55:0] INQ_FRMT_LAST_TS;
logic[127:0] INQ_FRMT_BUF_DATA;
logic INQ_FRMT_BUF_FLUSH;
logic[1:0] INQ_FRMT_BUF_WR_BANK_SLOT;
logic INQ_FRMT_BUF_START_SET;
logic INQ_FRMT_BUF_END_SET;
logic INQ_BUFFER_BUSY;
logic[127:0] INQ_FRMT_BUF_DATA_R;
logic INQ_FRMT_BUF_FLUSH_R;
logic[1:0] INQ_FRMT_BUF_WR_BANK_SLOT_R;
logic INQ_FRMT_BUF_START_SET_R;
logic INQ_FRMT_BUF_END_SET_R;
logic INQ_BUFFER_BUSY_R;
logic[127:0] INQ_BUFFER_MISC_DATA;
logic INQ_BUFFER_MISC_FLUSH_ALL;
logic INQ_BUFFER_PUSH_MISC_FIFO;
logic INQ_MISC_FIFO_BUSY;

///////////////////////////////////////////////////////////////////////////////
// SCSI Inquiry Datapath (per link)
///////////////////////////////////////////////////////////////////////////////
// Flop the ctrl signal
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		misc_fifo_ctrl_r0 <= 4'b0;
		misc_fifo_ctrl_r1 <= 4'b0;
	end else begin
		misc_fifo_ctrl_r0 <= iMISC_FIFO_CTRL;
		misc_fifo_ctrl_r1 <= misc_fifo_ctrl_r0;
	end
end

assign oREG_INQ_IS_CMD = INQ_FRMT_IS_CMD;
assign oREG_INQ_IS_MATCH = INQ_FRMT_IS_MATCH;

// Cross channel scsi_inq_ch detector communcation
scsi_inq u_scsi_inq (
	.iCLK(iCLK), // input 
	.iRST_N(iRST_N), // input
	.iINQ_DATA(iINQ_DATA), // input [1:0][63:0]
	.iINQ_DATA_VALID(iINQ_DATA_V), // input [1:0]
	.iINQ_D_ID_OUT(iINQ_D_ID), // input [1:0][23:0]
	.iINQ_S_ID_OUT(iINQ_S_ID), // input [1:0][23:0]
	.iINQ_OX_ID_OUT(iINQ_OX_ID), // input [1:0][15:0]
	.iINQ_IS_CMD(iINQ_IS_CMD), // input [1:0]
	.iINQ_IS_RSP(iINQ_IS_RSP), // input [1:0]
	.iINQ_SOP(iINQ_SOP), // input [1:0]
	.iINQ_EOP(iINQ_EOP), // input [1:0]
	.iINQ_ERR(iINQ_ERR), // input [1:0]
	.iINQ_LAST_TS(iINQ_LAST_TS), // input [1:0][55:0]
	.iINQ_MATCH_EXPECTED(INQ_MATCH_EXPECTED),
	.oINQ_DATA(INQ_FRMT_DATA),
	.oINQ_DATA_VALID(INQ_FRMT_DATA_V),
	.oINQ_EOP(INQ_FRMT_EOP),
	.oINQ_IS_CMD(INQ_FRMT_IS_CMD),
	.oINQ_IS_MATCH(INQ_FRMT_IS_MATCH),
	.oINQ_ERR(INQ_FRMT_ERR),
	.oINQ_LAST_TS(INQ_FRMT_LAST_TS)
);

// SCSI INQ packet formatter
scsi_inq_frmt u_scsi_inq_frmt (
	.iCLK(iCLK),
	.iRST_N(iRST_N),
	.iINQ_IS_CMD(INQ_FRMT_IS_CMD),
	.iINQ_IS_MATCH(INQ_FRMT_IS_MATCH),
	.iINQ_EOP(INQ_FRMT_EOP),
	.iINQ_ERR(INQ_FRMT_ERR),
	.iINQ_DATA(INQ_FRMT_DATA),
	.iINQ_DATA_V(INQ_FRMT_DATA_V),
	.iINQ_LAST_TS(INQ_FRMT_LAST_TS),
	.iINQ_VLAN(32'd0), // VLAN
	.iINQ_BUFFER_BUSY(INQ_BUFFER_BUSY_R),
	.iLINK_ID(iLINK_ID),
	.iFLUSH(~iREG_LINKCTRL_MONITORMODE[1] | ~misc_fifo_ctrl_r1[1] | ~iCHAN_LINKUP[0] | ~iCHAN_LINKUP[1]),
	.oFLUSH(INQ_FRMT_BUF_FLUSH),
	.oWR_BANK_SLOT(INQ_FRMT_BUF_WR_BANK_SLOT),
	.oSTART_SET(INQ_FRMT_BUF_START_SET),
	.oEND_SET(INQ_FRMT_BUF_END_SET),
	.oINQ_DATA(INQ_FRMT_BUF_DATA),
	.oINQ_MATCH_EXPECTED(INQ_MATCH_EXPECTED),
	.oINQ_PKT_ERR(oREG_INQ_PKT_ERR),
	.oINQ_PKT_DROP(oREG_INQ_PKT_DROP),
	.oINQ_PKT_OVERWRITE(oREG_INQ_PKT_OVR)
);

// Flop the formatter to buffer inputs
always_ff @(posedge iCLK or negedge iRST_N) begin
	if (~iRST_N) begin
		INQ_FRMT_BUF_FLUSH_R <= 1'b0;
		INQ_FRMT_BUF_WR_BANK_SLOT_R <= 2'b0;
		INQ_FRMT_BUF_DATA_R <= 128'd0;
		INQ_FRMT_BUF_START_SET_R <= 1'b0;
		INQ_FRMT_BUF_END_SET_R <= 1'b0;
		INQ_BUFFER_BUSY_R <= 1'b0;
	end else begin
		INQ_FRMT_BUF_FLUSH_R <= INQ_FRMT_BUF_FLUSH;
		INQ_FRMT_BUF_WR_BANK_SLOT_R <= INQ_FRMT_BUF_WR_BANK_SLOT;
		INQ_FRMT_BUF_DATA_R <= INQ_FRMT_BUF_DATA;
		INQ_FRMT_BUF_START_SET_R <= INQ_FRMT_BUF_START_SET;
		INQ_FRMT_BUF_END_SET_R <= INQ_FRMT_BUF_END_SET;
		INQ_BUFFER_BUSY_R <= INQ_BUFFER_BUSY;
	end
end

// SCSI INQ single packet buffer
scsi_inq_buffer u_scsi_inq_buffer (
	.iCLK(iCLK),
	.iRST_N(iRST_N),
	.iFLUSH(INQ_FRMT_BUF_FLUSH_R),
	.iWR_BANK_SLOT(INQ_FRMT_BUF_WR_BANK_SLOT_R),
	.iINQ_DATA(INQ_FRMT_BUF_DATA_R),
	.iSTART_SET(INQ_FRMT_BUF_START_SET_R),
	.iEND_SET(INQ_FRMT_BUF_END_SET_R),
	.iINQ_MISC_FIFO_BUSY(INQ_MISC_FIFO_BUSY),
	.oINQ_DATA(INQ_BUFFER_MISC_DATA),
	.oINQ_PUSH_MISC_FIFO(INQ_BUFFER_PUSH_MISC_FIFO),
	.oINQ_BUFFER_BUSY(INQ_BUFFER_BUSY)
);

///////////////////////////////////////////////////////////////////////////////
// Miscalleaneous Packet FIFO
///////////////////////////////////////////////////////////////////////////////
misc_fifo_wrap u_misc_fifo_wrap (
	.iCLK(iCLK),
	.iCLK_PCIE(iCLK_PCIE),
	.iRST_N(iRST_N),
	.iRST_PCIE_N(iRST_PCIE_N),
	.iMISC_DATA(INQ_BUFFER_MISC_DATA),
	.iMISC_PUSH_FIFO(INQ_BUFFER_PUSH_MISC_FIFO),
	.iMISC_POP_FIFO(iMISC_ARB_GRANT),
	.oMISC_DATA(oMISC_FIFO_DATA),
	.oMISC_DATA_V(oMISC_FIFO_DATA_V),
	.oMISC_FIFO_FULL(oMISC_FIFO_FULL),
	.oMISC_FIFO_EMPTY(oMISC_FIFO_EMPTY),
	.oMISC_FIFO_AEMPTY(oMISC_FIFO_AEMPTY),
	.oMISC_FIFO_RD_REQ(oMISC_FIFO_RD_REQ),
	.oMISC_FIFO_BUSY(INQ_MISC_FIFO_BUSY)
);

endmodule
