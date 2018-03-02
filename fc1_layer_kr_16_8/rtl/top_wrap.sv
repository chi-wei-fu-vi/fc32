/********************************CONFIDENTIAL**************************** * Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-01-27 15:42:52 -0800 (Mon, 27 Jan 2014) $
* $Revision: 4535 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/
module top_wrap 
#(
        parameter CHANNELS             = 26 
)
(
// --------------------------
// Tx/Rx Interface
// --------------------------

output  [CHANNELS-1:0]                 oFC_TD_P,                                //  per transceiver serial data to IOs
input   [CHANNELS-1:0]                 iFC_RD_P,                                //  per transceiver serial data to IOs

// --------------------------
// Clocks and Reset
// --------------------------

input   [1:0]                          iCLK_FC_219_P,                               //  per side, reference clock, 1 is right, 0 is l
input   [1:0]                          iCLK_FC_425_P,                               //  per side, reference clock, 1 is right, 0 is l
input   oCLK_FC_CORE_GLOBAL,                            //  core clock, 212.5Mhz
input   oCLK_100M_GLOBAL,                               //  Avalon MM clock, half the speed of core clock
input   oRST_FR_100M_N,
input   [CHANNELS-1:0]                 oRST_LINK_SERDES_RXREC_N,                        //  asynchronous reset
input   [CHANNELS-1:0]                 oRST_LINK_SERDES_TX_N,                           //  asynchronous reset
input   oRST_FC_CORE_N,                                 //  asynchronous reset
input   iCLK_CORE_219,

// --------------------------
// Reconfig Register Interface
// --------------------------

input   logic [63:0]                   RECONFIG_MM_WR_DATA,
input   logic [13:0]                   RECONFIG_MM_ADDR,
input   RECONFIG_MM_WR_EN,
input   RECONFIG_MM_RD_EN,
output  logic [63:0]                   RECONFIG_MM_RD_DATA,
output  RECONFIG_MM_ACK,

// --------------------------
// Control Register Interface
// --------------------------

input   soft_mgmt_rst_reset,
input   logic                          direct_access,
input   oREG_FPGA_CTL_RX_SERDES_DISABLE,
input   oREG_FPGA_CTL_TX_SERDES_DISABLE,
output  logic [3:0]                    status_error,
output  logic                          timeout_error,
output  logic                          reconfig_busy,


input   [3:0]                          oREG_LOOPBACKSERDESCFG_PRODUCT,
input   [3:0]                          oREG_LOOPBACKSERDESCFG_REV,
input   [3:0]                          oREG_LOOPBACKSERDESCFG_MODE,

input   logic [63:0]     fc16pma_wr_data,
input   logic [13:0]     fc16pma_addr,
input                    fc16pma_wr_en,
input                    fc16pma_rd_en,
output  logic [63:0]     fc16pma_rd_data,
output                   fc16pma_rd_data_v,

/******************************************************************
 * FC1 layer signals 
 *****************************************************************/

/*Decoder IO*/
// dout
output  logic [CHANNELS-1:0]         PCS_DOUT_BLOCK_SYNC,

/*ENC register interface*/
//din
input   logic          CSR_WR_EN,
input   logic          CSR_RD_EN,
input   logic   [9:0]  CSR_ADDR,
input   logic   [63:0] CSR_WR_DATA
//dout

);

/*Encoder IO*/
// input logic [CHANNELS-1:0]  [65:0] ENC_IN_PCS_BLK;                    // To compressor_inst of compressor.v logic [CHANNELS-1:0]         ENC_IN_PCS_BLK_ENA;                // To compressor_inst of compressor.v


/*Decoder IO*/
// dout
logic [CHANNELS-1:0]  [63:0] PCS_DOUT;
logic [CHANNELS-1:0]  [1:0]  PCS_DOUT_SH;
logic [CHANNELS-1:0]         PCS_DOUT_EN;

assign ENC_IN_PCS_BLK = {PCS_DOUT, PCS_DOUT_SH};
assign ENC_IN_PCS_BLK_ENA = PCS_DOUT_EN;

fc1_kr_ser_wrap #(.CHANNELS(CHANNELS)) fc1_kr_ser_wrap_inst (
// --------------------------
// Tx/Rx Interface
// --------------------------

 .oFC_TD_P(oFC_TD_P),                                //  per transceiver serial data to IOs
 .iFC_RD_P(iFC_RD_P),                                //  per transceiver serial data to IOs

// --------------------------
// Clocks and Reset
// --------------------------

 .iCLK_FC_219_P(iCLK_FC_219_P),                               //  per side, reference clock, 1 is right, 0 is l
 .iCLK_FC_425_P(iCLK_FC_425_P),                               //  per side, reference clock, 1 is right, 0 is l
 .oCLK_FC_CORE_GLOBAL(oCLK_FC_CORE_GLOBAL),                            //  core clock, 212.5Mhz
 .oCLK_100M_GLOBAL(oCLK_100M_GLOBAL),                               //  Avalon MM clock, half the speed of core clock
 .oRST_FR_100M_N(oRST_FR_100M_N),
 .oRST_LINK_SERDES_RXREC_N(oRST_LINK_SERDES_RXREC_N),                        //  asynchronous reset
 .oRST_LINK_SERDES_TX_N(oRST_LINK_SERDES_TX_N),                           //  asynchronous reset
 .oRST_FC_CORE_N(oRST_FC_CORE_N),                                 //  asynchronous reset
 .iCLK_CORE_219(iCLK_CORE_219),
 .rx_pma_clkout(),                   //  rx recovered parallel clock
 .atx_pll_locked_425(),                  //  per channel PLL locked from ATX PLLs
 .atx_pll_locked_219(),                  //  per channel PLL locked from ATX PLLs
 .rx_ready(),                        //  rx is ready

// --------------------------
// Reconfig Register Interface
// --------------------------

 .RECONFIG_MM_WR_DATA(RECONFIG_MM_WR_DATA),
 .RECONFIG_MM_ADDR(RECONFIG_MM_ADDR),
 .RECONFIG_MM_WR_EN(RECONFIG_MM_WR_EN),
 .RECONFIG_MM_RD_EN(RECONFIG_MM_RD_EN),
 .RECONFIG_MM_RD_DATA(RECONFIG_MM_RD_DATA),
 .RECONFIG_MM_ACK(RECONFIG_MM_ACK),

// --------------------------
// Control Register Interface
// --------------------------

 .soft_mgmt_rst_reset(soft_mgmt_rst_reset),
 .direct_access(direct_access),
 .oREG_FPGA_CTL_RX_SERDES_DISABLE(oREG_FPGA_CTL_RX_SERDES_DISABLE),
 .oREG_FPGA_CTL_TX_SERDES_DISABLE(oREG_FPGA_CTL_TX_SERDES_DISABLE),
 .status_error(status_error),
 .timeout_error(timeout_error),
 .reconfig_busy(reconfig_busy),

 .fc16pma_debug(),

 .oREG_LOOPBACKSERDESCFG_PRODUCT(oREG_LOOPBACKSERDESCFG_PRODUCT),
 .oREG_LOOPBACKSERDESCFG_REV(oREG_LOOPBACKSERDESCFG_REV),
 .oREG_LOOPBACKSERDESCFG_MODE(oREG_LOOPBACKSERDESCFG_MODE),

 .fc16pma_wr_data({24{fc16pma_wr_data}}),
 .fc16pma_addr({24{fc16pma_addr}}),
 .fc16pma_wr_en({24{fc16pma_wr_en}}),
 .fc16pma_rd_en({24{fc16pma_rd_en}}),
 .fc16pma_rd_data(),
 .fc16pma_rd_data_v(),

/******************************************************************
 * FC1 layer signals 
 *****************************************************************/
/*Encoder IO*/
// input
 .iENC_IN_PCS_BLK(ENC_IN_PCS_BLK),                    // To compressor_inst of compressor.v
 .iENC_IN_PCS_BLK_ENA(ENC_IN_PCS_BLK_ENA),                // To compressor_inst of compressor.v

/*Decoder IO*/
// dout
 .oPCS_DOUT_BLOCK_SYNC(PCS_DOUT_BLOCK_SYNC),
 .oPCS_DOUT(PCS_DOUT),
 .oPCS_DOUT_SH(PCS_DOUT_SH),
 .oPCS_DOUT_EN(PCS_DOUT_EN),

/*ENC register interface*/
//din
 .iCSR_WR_EN({26{CSR_WR_EN}}),
 .iCSR_RD_EN({26{CSR_RD_EN}}),
 .iCSR_ADDR({26{CSR_ADDR}}),
 .iCSR_WR_DATA({26{CSR_WR_DATA}}),
//dout
 .oCSR_RD_DATA(),
 .oCSR_RD_DATA_V()
);



endmodule

