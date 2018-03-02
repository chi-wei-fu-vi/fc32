/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-01-21 14:47:07 -0800 (Tue, 21 Jan 2014) $
* $Revision: 4478 $
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

module fc1_kr_ser_wrap 
#(
        parameter CHANNELS             =  26,
        parameter LOW_LATENCY_PHY      =  0,
        parameter PHASE_COMP           =  0,
        parameter GROUP_PHY            =  0,
        parameter LITE                 =  0,
        parameter DEBUG                =  0,
        parameter SIM_ONLY             =  0,
        parameter LINKS                = 12,
        parameter CROSSLINK            = 1

)

(
/******************************************************************
* PMA layer signals
*****************************************************************/
        input   [69:0] fc_reconfig_to_xcvr,
        output  [45:0] fc_reconfig_from_xcvr, 
        output  [CHANNELS-1:0] rx_is_lockedtodata,
        
        // --------------------------
        // Tx/Rx Interface
        // --------------------------
        
        output  [CHANNELS-1:0]                 oFC_TD_P,                        //   per transceiver serial data to IOs
        input   [CHANNELS-1:0]                 iFC_RD_P,                        //   per transceiver serial data to IOs
        output  [CHANNELS-1:0]                 oFC_TD_N,                        //   per transceiver serial data to IOs
        input   [CHANNELS-1:0]                 iFC_RD_N,                        //   per transceiver serial data to IOs
        input  logic [CHANNELS-1:0]            iSFP_LOS,

        // --------------------------
        // Clocks and Reset
        // --------------------------
        input   [1:0]                          iCLK_FC_219_P,                   //   per side, reference clock, 1 is right, 0 is l
        input   [1:0]                          iCLK_FC_425_P,                   //   per side, reference clock, 1 is right, 0 is l
        input   iCLK_100M_GLOBAL,               //   Avalon MM clock, half the speed of core clock
        input   iRST_FR_100M_N,
        input   [CHANNELS-1:0]                 iRST_LINK_SERDES_RXREC_N,        //   asynchronous reset
        input   [CHANNELS-1:0]                 iRST_LINK_SERDES_TX212_N,                //   asynchronous reset
        input   [CHANNELS-1:0]                 iRST_LINK_SERDES_TX219_N,                //   asynchronous reset
        input   iRST_FC_CORE212_N,              //   asynchronous reset
        input   iRST_FC_SER212_N,              //   asynchronous reset
        input   iRST_FC_SER219_N,              //   asynchronous reset
        input   iCLK_SER_219,
        input   iCLK_SER_212,            //   core clock, 212.5Mhz
        input   iCLK_CORE_212,            //   core clock, 212.5Mhz
        output  [CHANNELS-1:0]                 rx_pma_clkout,                   //   rx recovered parallel clock
        output  [CHANNELS-1:0]                 atx_pll_locked,                  //   per channel PLL locked from ATX PLLs
        output  [CHANNELS-1:0]                 rx_ready,                        //   rx is ready
        
        // --------------------------
        // Reconfig Register Interface
        // --------------------------
        
        input   logic [63:0]                         RECONFIG_MM_WR_DATA,
        input   logic [13:0]                         RECONFIG_MM_ADDR,
        input   RECONFIG_MM_WR_EN,
        input   RECONFIG_MM_RD_EN,
        output  logic [63:0]                         RECONFIG_MM_RD_DATA,
        output  RECONFIG_MM_ACK,
        
        // --------------------------
        // Control Register Interface
        // --------------------------
        
        input   soft_mgmt_rst_reset,
        input   logic                                direct_access,
        input   oREG_FPGA_CTL_RX_SERDES_DISABLE,
        input   oREG_FPGA_CTL_TX_SERDES_DISABLE,
        
        output  logic [31:0]                         min_linkspeed_reconfig,
        output  logic [31:0]                         max_linkspeed_reconfig,
        output  logic [CHANNELS/2-1:0][3:0]          status_data_rate,
        input   logic                                mif_retry,
        input   logic [CHANNELS-1:0][3:0]            oLE_LINKSPEED,
        
        
        output  logic [3:0]                          status_error,
        output  logic                                timeout_error,
        output  logic                                reconfig_busy,
        
        output  logic [25:0][15:0]                   fc16pma_debug,
        
        input   [3:0]                          oREG_LOOPBACKSERDESCFG_PRODUCT,
        input   [3:0]                          oREG_LOOPBACKSERDESCFG_REV,
        input   [3:0]                          oREG_LOOPBACKSERDESCFG_MODE,
        
        input   logic [CHANNELS-1:0][63:0]           fc16pma_wr_data,
        input   logic [CHANNELS-1:0][13:0]           fc16pma_addr,
        input   [CHANNELS-1:0]                 fc16pma_wr_en,
        input   [CHANNELS-1:0]                 fc16pma_rd_en,
        output  logic [CHANNELS-1:0][63:0]           fc16pma_rd_data,
        output  [CHANNELS-1:0]                 fc16pma_rd_data_v,
        
        
        /******************************************************************
* FC1 layer signals
*****************************************************************/
        /*Encoder IO*/
        // input
        input   logic [CHANNELS-1:0][1:0]            iENC_IN_PCS_SH,                    //  To compressor_inst of compressor.v
        input   logic [CHANNELS-1:0][63:0]           iENC_IN_PCS_BLK,                   //  To compressor_inst of compressor.v
        input   logic [CHANNELS-1:0]                 iENC_IN_PCS_BLK_ENA,               //  To compressor_inst of compressor.v
				input   logic [CHANNELS-1:0]         REG_CTL_FARLOOPBACKEN,               // To compressor_inst of compressor.v

        
        
        /*Decoder IO*/
        // dout
        output  logic [CHANNELS-1:0]                 oPCS_DOUT_BLOCK_SYNC,
        output  logic [CHANNELS-1:0][63:0]           oPCS_DOUT,
        output  logic [CHANNELS-1:0][1:0]            oPCS_DOUT_SH,
        output  logic [CHANNELS-1:0]                 oPCS_DOUT_EN,
        
        /*ENC register interface*/
        //din
        input   logic [CHANNELS-1:0]                 iCSR_WR_EN,
        input   logic [CHANNELS-1:0]                 iCSR_RD_EN,
        input   logic [CHANNELS-1:0][13:0]           iCSR_ADDR,
        input   logic [CHANNELS-1:0][63:0]           iCSR_WR_DATA,
        //dout
        output  logic [CHANNELS-1:0][63:0]           oCSR_RD_DATA,
        output  logic [CHANNELS-1:0]                 oCSR_RD_DATA_V,
        
        /*Interval Stats*/
        input   logic [CHANNELS-1:0]                 iINT_STATS_LATCH_CLR,
        //output  fc1_interval_stats[CHANNELS-1:0] oINT_STATS_FC1,
        output logic [CHANNELS-1:0] [31:0] oINT_STATS_FC1_CORR_EVENT_CNT,
        output logic [CHANNELS-1:0] [31:0] oINT_STATS_FC1_UNCORR_EVENT_CNT,
        output logic [CHANNELS-1:0] [31:0] oINT_STATS_FC1_PCS_LOS_CNT,

        output  [CHANNELS-1:0]                 tx_pma_clkout,
				output  [CHANNELS-1:0][63:0]           rx_parallel_data_pma,
				input   [CHANNELS-1:0][63:0]           tx_parallel_data_pma

        
        
        /******************************************************************
* END TOPLEVEL SIGNALS
*****************************************************************/
);


logic  [CHANNELS-1:0]                 atx_pll_locked_425;                       //  per channel PLL locked from ATX PLLs
logic  [CHANNELS-1:0]                 atx_pll_locked_219;                       //  per channel PLL locked from ATX PLLs

logic [CHANNELS-1:0][63:0]           tx_parallel_data, tx_parallel_data_bp, tx_parallel_data_bp8g;     //  tx parallel data to transceivers
logic [CHANNELS-1:0][63:0]           rx_parallel_data_core, rx_parallel_data_bp, rx_parallel_data_ser, rx_parallel_8g, rx_parallel_8g_bp;
logic [CHANNELS-1:0] cfg_rx_slip_vec;

logic [CHANNELS-1:0] rx_pma_clkout_bp;
logic [CHANNELS-1:0] rx_pma_clkout_ser;

logic [CHANNELS-1:0] tx_pma_clkout_bp;
logic [CHANNELS-1:0] tx_pma_clkout_ser;

logic [CHANNELS/2-1:0][3:0]          status_data_rate_i;
//provide bypass for simulation
assign  tx_parallel_data_bp    =  tx_parallel_data;
assign  tx_parallel_data_bp8g  = tx_parallel_data_pma;

generate
if (SIM_ONLY) begin: serdes_bypass
        assign  rx_parallel_data_core  =  rx_parallel_data_bp;
        assign  rx_pma_clkout  =  rx_pma_clkout_bp;
        assign  tx_pma_clkout  =  tx_pma_clkout_bp;
				assign   rx_parallel_data_pma = rx_parallel_8g_bp;
end
else begin
        assign  rx_parallel_data_core  =  rx_parallel_data_ser;
        assign  rx_pma_clkout  =  rx_pma_clkout_ser;
        assign  tx_pma_clkout  =  tx_pma_clkout_ser;
				assign   rx_parallel_data_pma = rx_parallel_8g;
end
endgenerate

//provide bypass access in 8g mode
//assign rx_parallel_data_pma = rx_parallel_data_core;

/*both ATX ref clocks are from on-board PLLs.  They have to be locked at
 * startup*/

assign  atx_pll_locked =  atx_pll_locked_425 & atx_pll_locked_219;
fc16pma_wrap #(
        . SIM_ONLY                                             ( SIM_ONLY                                           ),
        . CHANNELS                                             ( CHANNELS                                           ),
        . LOW_LATENCY_PHY                                      ( LOW_LATENCY_PHY                                    ),
        . LITE                                                 ( LITE                                               ),
        . PHASE_COMP                                           ( PHASE_COMP                                         )
) fc16pma_wrap_inst (
        .fc_reconfig_to_xcvr   (fc_reconfig_to_xcvr),
        .fc_reconfig_from_xcvr (fc_reconfig_from_xcvr),
        . rx_is_lockedtodata (rx_is_lockedtodata),
        . oLE_LINKSPEED                                        ( oLE_LINKSPEED                                      ),  // input [CHANNELS-1:0][3:0]
				. iSFP_LOS                                             ( iSFP_LOS                                           ),
        . min_linkspeed_reconfig                               ( min_linkspeed_reconfig                             ),  // output [31:0]
        . max_linkspeed_reconfig                               ( max_linkspeed_reconfig                             ),  // output [31:0]
        . mif_retry                                            ( mif_retry                                          ),  // input
        . status_data_rate                                     ( status_data_rate_i                                   ),  // output [CHANNELS/2-1:0][3:0]
        
        . tx_parallel_data                                     ( tx_parallel_data                                   ),  // input [CHANNELS-1:0][63:0]
        . rx_parallel_data                                     ( rx_parallel_data_ser                               ),  // output [CHANNELS-1:0][63:0]
        . tx_serial_data                                       ( oFC_TD_P[CHANNELS-1:0]                             ),  // output [CHANNELS-1:0]
        . rx_serial_data                                       ( iFC_RD_P[CHANNELS-1:0]                             ),  // input [CHANNELS-1:0]
        . tx_serial_data_n                                     ( oFC_TD_N[CHANNELS-1:0]                             ),  // output [CHANNELS-1:0]
        . rx_serial_data_n                                     ( iFC_RD_N[CHANNELS-1:0]                             ),  // input [CHANNELS-1:0]
        . ref_clk_219                                          ( iCLK_FC_219_P[1:0]                                 ),  // input [1:0]
        . ref_clk_425                                          ( iCLK_FC_425_P[1:0]                                 ),  // input [1:0]
        . clk                                                  ( iCLK_SER_219                                ),  // input
        . mgmt_clk_clk                                         ( iCLK_100M_GLOBAL                                   ),  // input
        . mgmt_rst_reset                                       ( ~iRST_FR_100M_N                                    ),  // input
        //. rx_rst_n                                             ( iRST_LINK_SERDES_RXREC_N[CHANNELS-1:0]             ),  // input [CHANNELS-1:0]
        //. tx_rst_n                                             ( iRST_LINK_SERDES_TX219_N[CHANNELS-1:0]                ),       // input [CHANNELS-1:0]
        . rx_rst_n                                             ( {CHANNELS{iRST_FC_SER219_N}}             ),  // input [CHANNELS-1:0]
        . tx_rst_n                                             ( {CHANNELS{iRST_FC_SER219_N}}                ),       // input [CHANNELS-1:0]
        . rst_n                                                ( iRST_FC_SER219_N                                  ),          // input
        . rst                                                  ( ~iRST_FC_SER219_N                                 ),          // input
        . tx_pma_clk                                           ( iCLK_SER_219                                      ),          // input
        . rx_pma_clkout                                        ( rx_pma_clkout_ser[CHANNELS-1:0]                    ),          // output [CHANNELS-1:0]
        . tx_pma_clkout                                        ( tx_pma_clkout_ser[CHANNELS-1:0]                        ),          // output [CHANNELS-1:0]
        . atx_pll_locked_425                                   ( atx_pll_locked_425[CHANNELS-1:0]                   ),          // output [CHANNELS-1:0]
        . atx_pll_locked_219                                   ( atx_pll_locked_219[CHANNELS-1:0]                   ),          // output [CHANNELS-1:0]
        . rx_ready                                             ( rx_ready[CHANNELS-1:0]                             ),          // output [CHANNELS-1:0]
        . iRECONFIG_MM_WR_DATA                                 ( RECONFIG_MM_WR_DATA[63:0]                          ),          // input [63:0]
        . iRECONFIG_MM_ADDR                                    ( RECONFIG_MM_ADDR[13:0]                             ),          // input [13:0]
        . iRECONFIG_MM_WR_EN                                   ( RECONFIG_MM_WR_EN                                  ),          // input
        . iRECONFIG_MM_RD_EN                                   ( RECONFIG_MM_RD_EN                                  ),          // input
        . oRECONFIG_MM_RD_DATA                                 ( RECONFIG_MM_RD_DATA[63:0]                          ),          // output [63:0]
        . oRECONFIG_MM_ACK                                     ( RECONFIG_MM_ACK                                    ),          // output
        . soft_mgmt_rst_reset                                  ( soft_mgmt_rst_reset                                ),          // input
        . direct_access                                        ( direct_access                                      ),          // input
        . fpga_ctl_rx_serdes_disable                           ( oREG_FPGA_CTL_RX_SERDES_DISABLE                    ),          // input
        . fpga_ctl_tx_serdes_disable                           ( oREG_FPGA_CTL_TX_SERDES_DISABLE                    ),          // input
        . status_error                                         ( status_error                                       ),          // output [3:0]
        . timeout_error                                        ( timeout_error                                      ),          // output
        . reconfig_busy                                        ( reconfig_busy                                      ),          // output
        . debug                                                ( fc16pma_debug                                      ),          // output [25:0][15:0]
        . oREG_LOOPBACKSERDESCFG_PRODUCT                       ( oREG_LOOPBACKSERDESCFG_PRODUCT[3:0]                ),          // input [3:0]
        . oREG_LOOPBACKSERDESCFG_REV                           ( oREG_LOOPBACKSERDESCFG_REV[3:0]                    ),          // input [3:0]
        . oREG_LOOPBACKSERDESCFG_MODE                          ( oREG_LOOPBACKSERDESCFG_MODE[3:0]                   ),          // input [3:0]
        . cfg_rx_slip_vec                                      ( cfg_rx_slip_vec[CHANNELS-1:0]                      ),          // input [CHANNELS-1:0]
        . oSERDES_MM_WR_DATA                                   ( fc16pma_wr_data[CHANNELS-1:0]                      ),          // input [CHANNELS-1:0][63:0]
        . oSERDES_MM_ADDR                                      ( fc16pma_addr[CHANNELS-1:0]                         ),          // input [CHANNELS-1:0][13:0]
        . oSERDES_MM_WR_EN                                     ( fc16pma_wr_en[CHANNELS-1:0]                        ),          // input [CHANNELS-1:0]
        . oSERDES_MM_RD_EN                                     ( fc16pma_rd_en[CHANNELS-1:0]                        ),          // input [CHANNELS-1:0]
        . iSERDES_MM_RD_DATA                                   ( fc16pma_rd_data[CHANNELS-1:0]                      ),          // output [CHANNELS-1:0][63:0]
        . iSERDES_MM_RD_DATA_V                                 ( fc16pma_rd_data_v[CHANNELS-1:0]                    ),           // output [CHANNELS-1:0]
				. rx_parallel_data_pma(rx_parallel_8g),
				//. rx_parallel_data_pma(),
				. tx_parallel_data_pma(tx_parallel_data_pma),
				. iCLK_CORE_212(iCLK_CORE_212),
				. iRST_FC_CORE212_N(iRST_FC_CORE212_N)
);

genvar gi;

generate
for ( gi   =  0; gi<CHANNELS/2; gi++ ) begin: data_rate_stat_sync_generate

vi_sync_pp #(4) status_linkspeed_sync (
.clka(iCLK_100M_GLOBAL),
.clkb(iCLK_CORE_212),
.rsta_n(iRST_FR_100M_N),
.rstb_n(iRST_FC_CORE212_N),
.in_bus(status_data_rate_i[gi]),
.out_bus(status_data_rate[gi])
  );

end
endgenerate

/*
fc1_kr_wrap AUTO_TEMPLATE (
   .iCLK_CORE                     (iCLK_CORE_212),
   .iTX_CLK                       ({CHANNELS{iCLK_SER_212}}),
   .iTX_RST                       ({CHANNELS{~iRST_FC_SER212_N}}),
   .iTX_CLK219                    ({CHANNELS{iCLK_SER_219}}),
   .iTX_RST219                    ({CHANNELS{~iRST_FC_SER219_N}}),

  .iRX_RST(~iRST_LINK_SERDES_RXREC_N),
  .iRX_CLK(rx_pma_clkout),
  .oENC_OUT_PMA_BLK(tx_parallel_data),
  .iDEC_IN_PMA_BLK(rx_parallel_data_core),
  .oDEC_BITSLIP(cfg_rx_slip_vec),
);
*/
fc1_kr_wrap
#(
        .CHANNELS      (CHANNELS),
        .LINKS         (LINKS + CROSSLINK),
				.SIM_ONLY      (SIM_ONLY)
)
fc1_kr_wrap_inst
(
        /*AUTOINST*/
        // Outputs
        .oENC_OUT_PMA_BLK      (tx_parallel_data),      // Templated
        .oPCS_DOUT_BLOCK_SYNC          (oPCS_DOUT_BLOCK_SYNC[CHANNELS-1:0]),
        .oPCS_DOUT                     (oPCS_DOUT       /*[CHANNELS-1:0][63:0]*/),
        .oPCS_DOUT_SH                  (oPCS_DOUT_SH    /*[CHANNELS-1:0][1:0]*/),
        .oPCS_DOUT_EN                  (oPCS_DOUT_EN[CHANNELS-1:0]),
        .oDEC_BITSLIP                  (cfg_rx_slip_vec),       // Templated
        .oCSR_RD_DATA                  (oCSR_RD_DATA            /*[CHANNELS-1:0][63:0]*/),
        .oCSR_RD_DATA_V                (oCSR_RD_DATA_V[CHANNELS-1:0]),
        //.oINT_STATS_FC1                (oINT_STATS_FC1),
        .oINT_STATS_FC1_CORR_EVENT_CNT(oINT_STATS_FC1_CORR_EVENT_CNT),
        .oINT_STATS_FC1_UNCORR_EVENT_CNT(oINT_STATS_FC1_UNCORR_EVENT_CNT),
        .oINT_STATS_FC1_PCS_LOS_CNT(oINT_STATS_FC1_PCS_LOS_CNT),

        // Inputs
        .iRST_LINK_SERDES_TX212_N      (iRST_LINK_SERDES_TX212_N),
        .iRST_LINK_SERDES_TX219_N      (iRST_LINK_SERDES_TX219_N),
        .iCLK_CORE                     (iCLK_CORE_212),
        .iRST_CORE                     (~iRST_FC_CORE212_N),
        .iTX_CLK                       ({CHANNELS{iCLK_SER_212}}),       // Templated
        .iTX_RST                       ({CHANNELS{~iRST_FC_SER212_N}}),        // Templated
        .iTX_CLK219                    ({CHANNELS{iCLK_SER_219}}),             // Templated
        .iTX_RST219                    ({CHANNELS{~iRST_FC_SER219_N}}),        // Templated
        //.iRX_RST                       (~iRST_LINK_SERDES_RXREC_N),             // Templated
        .iRX_RST                       ({CHANNELS{~iRST_FC_SER219_N}}),             // Templated
        .rx_is_lockedtodata (rx_is_lockedtodata),
        .iRX_CLK                       (rx_pma_clkout),                         // Templated
				.REG_CTL_FARLOOPBACKEN         (REG_CTL_FARLOOPBACKEN),
        .iENC_IN_PCS_SH                (iENC_IN_PCS_SH  /*[CHANNELS-1:0][1:0]*/),
        .iENC_IN_PCS_BLK               (iENC_IN_PCS_BLK /*[CHANNELS-1:0][63:0]*/),
        .iENC_IN_PCS_BLK_ENA           (iENC_IN_PCS_BLK_ENA[CHANNELS-1:0]),
        .iDEC_IN_PMA_BLK               (rx_parallel_data_core), // Templated
        .iCSR_WR_EN                    (iCSR_WR_EN[CHANNELS-1:0]),
        .iCSR_RD_EN                    (iCSR_RD_EN[CHANNELS-1:0]),
        .iCSR_ADDR                     (iCSR_ADDR               /*[CHANNELS-1:0][13:0]*/),
        .iCSR_WR_DATA                  (iCSR_WR_DATA            /*[CHANNELS-1:0][63:0]*/),
        .iINT_STATS_LATCH_CLR          (iINT_STATS_LATCH_CLR[CHANNELS-1:0]));


endmodule
