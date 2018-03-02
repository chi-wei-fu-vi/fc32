/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-05-09 14:09:06 -0700 (Fri, 09 May 2014) $
* $Revision: 5751 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/
import fc1_pkg::*;

module fc1_kr_wrap 
#(
        parameter CHANNELS         =  1,
				parameter LINKS = 1,
				parameter SIM_ONLY = 0
)
(
        input   [CHANNELS-1:0] iRST_LINK_SERDES_TX212_N,
        input   [CHANNELS-1:0] iRST_LINK_SERDES_TX219_N,
       
			  input                                iCLK_CORE,
			  input                                iRST_CORE,
        input   logic [CHANNELS-1:0]         iTX_CLK,
        input   logic [CHANNELS-1:0]         iTX_RST,
        input   logic [CHANNELS-1:0]         iTX_CLK219,
        input   logic [CHANNELS-1:0]         iTX_RST219,
        input   logic [CHANNELS-1:0]         iRX_RST,
        input   logic [CHANNELS-1:0]         rx_is_lockedtodata,
        input   logic [CHANNELS-1:0]         iRX_CLK,
        /*Encoder IO*/
        // input
        input   logic [CHANNELS-1:0]  [1:0]  iENC_IN_PCS_SH,            // To compressor_inst of compressor.v
        input   logic [CHANNELS-1:0]  [63:0] iENC_IN_PCS_BLK,           // To compressor_inst of compressor.v
        input   logic [CHANNELS-1:0]         iENC_IN_PCS_BLK_ENA,               // To compressor_inst of compressor.v
        input   logic [CHANNELS-1:0]         REG_CTL_FARLOOPBACKEN,               // To compressor_inst of compressor.v
        // output
        output  logic [CHANNELS-1:0]  [63:0] oENC_OUT_PMA_BLK,          // From out_regs_inst of regs.v
        
        /*Decoder IO*/
        // din
        input   logic [CHANNELS-1:0] [63:0]  iDEC_IN_PMA_BLK,
        // dout
        output  logic [CHANNELS-1:0]         oPCS_DOUT_BLOCK_SYNC,
        output  logic [CHANNELS-1:0]  [63:0] oPCS_DOUT,
        output  logic [CHANNELS-1:0]  [1:0]  oPCS_DOUT_SH,
        output  logic [CHANNELS-1:0]         oPCS_DOUT_EN,
        output  logic [CHANNELS-1:0]         oDEC_BITSLIP,
        
        /*ENC register interface*/
        //din
        input   logic [CHANNELS-1:0]         iCSR_WR_EN,
        input   logic [CHANNELS-1:0]         iCSR_RD_EN,
        input   logic [CHANNELS-1:0]  [13:0] iCSR_ADDR,
        input   logic [CHANNELS-1:0]  [63:0] iCSR_WR_DATA,
        //dout
        output  logic [CHANNELS-1:0]  [63:0] oCSR_RD_DATA,
        output  logic [CHANNELS-1:0]         oCSR_RD_DATA_V,
        
        /*Interval Stats*/
        //output  fc1_interval_stats [CHANNELS-1:0] oINT_STATS_FC1,
        output logic [CHANNELS-1:0] [31:0] oINT_STATS_FC1_CORR_EVENT_CNT,
        output logic [CHANNELS-1:0] [31:0] oINT_STATS_FC1_UNCORR_EVENT_CNT,
        output logic [CHANNELS-1:0] [31:0] oINT_STATS_FC1_PCS_LOS_CNT,

        input   logic [CHANNELS-1:0]         iINT_STATS_LATCH_CLR
        
);

logic [CHANNELS-1:0] rxrst_n;

genvar gi;
generate
for (gi=  0; gi<CHANNELS; gi       =  gi+1) begin : gen_fc1_kr

vi_rst_sync_async rx_reset_synchro
  (
   .iRST_ASYNC_N(~iRX_RST[gi] & rx_is_lockedtodata[gi]),    // asynchronous reset input.  must be held until target
   .iCLK(iRX_CLK[gi]),            // target clock domain
   .oRST_SYNC_N(rxrst_n[gi])      // async assert, sync de-assert reset
   );


        fc1_kr #(.CH(gi), .SIM_ONLY(SIM_ONLY))  fc1_kr (
                // Outputs
                .oENC_OUT_PMA_BLK(oENC_OUT_PMA_BLK[gi]),
                .oPCS_DOUT_BLOCK_SYNC(oPCS_DOUT_BLOCK_SYNC[gi]),
                .oPCS_DOUT(oPCS_DOUT[gi]),
                .oPCS_DOUT_SH(oPCS_DOUT_SH[gi]),
                .oPCS_DOUT_EN(oPCS_DOUT_EN[gi]),
                .oDEC_BITSLIP(oDEC_BITSLIP[gi]),
                .oCSR_RD_DATA(oCSR_RD_DATA[gi]),
                .oCSR_RD_DATA_V(oCSR_RD_DATA_V[gi]),
                
                // Inputs
                .iRST_LINK_SERDES_TX212_N(iRST_LINK_SERDES_TX212_N),
                .iRST_LINK_SERDES_TX219_N(iRST_LINK_SERDES_TX219_N),
                .iTX_RST(iTX_RST[gi]),
								.iCLK_CORE (iCLK_CORE),
								.iRST_CORE (iRST_CORE),
                .iTX_CLK(iTX_CLK[gi]),
                .iTX_RST219(iTX_RST219[gi]),
                .iTX_CLK219(iTX_CLK219[gi]),
                //.iRX_RST(iRX_RST[gi]),
                .iRX_RST(~rxrst_n[gi]),
                .iRX_CLK(iRX_CLK[gi]),
                .iENC_IN_PCS_SH(iENC_IN_PCS_SH[gi]),
                .iENC_IN_PCS_BLK(iENC_IN_PCS_BLK[gi]),
                .iENC_IN_PCS_BLK_ENA(iENC_IN_PCS_BLK_ENA[gi]),
                .REG_CTL_FARLOOPBACKEN(REG_CTL_FARLOOPBACKEN[gi]), 
                
                .iDEC_IN_PMA_BLK(iDEC_IN_PMA_BLK[gi]),
                .iCSR_WR_EN(iCSR_WR_EN[gi]),
                .iCSR_RD_EN(iCSR_RD_EN[gi]),
                .iCSR_ADDR(iCSR_ADDR[gi]),
                
                .iCSR_WR_DATA(iCSR_WR_DATA[gi]),
                .iINT_STATS_LATCH_CLR(iINT_STATS_LATCH_CLR[gi]),
        .oINT_STATS_FC1_CORR_EVENT_CNT(oINT_STATS_FC1_CORR_EVENT_CNT[gi]),
        .oINT_STATS_FC1_UNCORR_EVENT_CNT(oINT_STATS_FC1_UNCORR_EVENT_CNT[gi]),
        .oINT_STATS_FC1_PCS_LOS_CNT(oINT_STATS_FC1_PCS_LOS_CNT[gi])

                //.oINT_STATS_FC1(oINT_STATS_FC1[gi])
        );
end
endgenerate

endmodule
