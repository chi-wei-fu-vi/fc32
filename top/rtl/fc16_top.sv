/*************************************************************************** * Copyright (c) 2012 Virtual Instruments.
 * 25 Metro Dr, STE#400, San Jose, CA 95110
 * www.virtualinstruments.com
 * $Archive: $
 * $Author: $
 * $Date: $
 * $Revision: $
 * Description:
 ***************************************************************************/

import fc1_pkg::*;

module fc16_top #(
      parameter PL_LINK_CAP_MAX_LINK_WIDTH=8,
      parameter PCIE_GEN3                    =  0,
		  parameter bonded_mode                  =  "non_bonded",
		  parameter RX_POLARITY_INV              =  "invert_disable",     //valid setting for 10gbaser:invert_disable,invert_enable
		  parameter TX_POLARITY_INV              =  "invert_disable",     //valid setting for 10gbaser:invert_disable,invert_enable
		  parameter LINKS                        =  12,                   // 12 for Dominica, 8 for Bali
		  parameter CROSSLINK                    =  1,                    // create the crosslink. Set CROSSLINK=1 only when LINKS=12 for Dominica
		  parameter DATARATE                     =  14.025,
		  parameter TENGLL40                     =  0,
		  parameter TENGLL64                     =  0,
		  parameter TENGLL66                     =  0,
		  parameter TENGBASER                    =  1,
		  parameter NATIVE_PHY                   =  1,
		  parameter LITE                         =  0,
		  parameter SIM_ONLY_PCIE                =  0,
		  parameter SIM_ONLY_TXBIST_BP           =  0,
		  parameter SIM_ONLY_PMA_BP              =  0,
		  parameter DEBUG                        =  0
		  ) (
  input logic  [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp,
  input logic  [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn,
  input logic                  sys_clk_p,
  input logic                  sys_clk_n,
  input logic                  sys_rst_n,
  output logic [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp,
  output logic [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn,

		     // ------------
		     // global clock
		     // ------------
		     input   [1:0]                          iCLK_425M_P,                     //  218.945313 mhz ref clocks, used to generate core clocks
		     input   iCLK_FR,                        //  100Mhz free-running clock, continuously available
		     input   iFPGA_RSTN,
		     input   iFPGA_CLRN,

		     // ------------
		     // uC interface
		     // ------------
		     input   iBUS_CLK,                       //  UC reg transfer : strobe - not really a clock
		     input   iBUS_EN,                        //  UC reg transfer : chip select to enable this FPGA
		     input   iBUS_MASTER,                    //  UC reg transfer : master owns UC shared I/O
		     input   iBUS_RST,                       //  UC reg transfer : reset UC interface
		     inout   ioBUS_SPARE,                    //  UC reg transfer : unused spare I/O
		     inout   [7:0]                          ioFPGA_DATA,                     //  UC reg transfer : shared address/data bus

		     // ------------
		     // external IO
		     // ------------
		     //inout   ioEXT1,                         //  external I/O to header
		     inout   ioEXT2,                         //  external I/O to header
		     inout   ioEXT3,                         //  external I/O to header
		     inout   ioEXT4,                         //  external I/O to header

		     // ------------
		     // Fibre Channel
		     // ------------
		     input   [1:0]                          iCLK_FC_219_P,                           //  218.945313 Mhz ref clock to FC SERDES
		     input   [1:0]                          iCLK_FC_425_P,                           //  218.945313 Mhz ref clock to FC SERDES
		     input   [1:0]                          iCLK_FC_219_N,                           //  218.945313 Mhz ref clock to FC SERDES
		     input   [1:0]                          iCLK_FC_425_N,                           //  218.945313 Mhz ref clock to FC SERDES

		     input   [      (LINKS+CROSSLINK)*2-1:0]      iFC_RD_P,                          //  FC serial receive lines
		     output  [      (LINKS+CROSSLINK)*2-1:0]      oFC_TD_P,                          //  FC serial transmit lines
		     input   [      (LINKS+CROSSLINK)*2-1:0]      iFC_RD_N,                          //  FC serial receive lines
		     output  [      (LINKS+CROSSLINK)*2-1:0]      oFC_TD_N,                          //  FC serial transmit lines
		     output  [LINKS-1:0]                    oFC_RATE_SEL,                            //  1=high speed, 0=low speed. Affects SFP bandwidth settings
		     input   [LINKS*2-1:0]                  iSFP_LOS,                                //  SFP loss of signal

		     // ------------
		     // board ID
		     // ------------
		     input   [1:0]                          iBD_NO,                          //  board rev - only used in dominica
		     input   [3:0]                          iASY,                            //  assembly ID
		     input   iFPGA_ID_N,
		     output  [15:0]                         oLED_N,                          //  general purpose LEDs

		     // ------------
		     // UART
		     // ------------
		     input   iRXD,
		     output  oTXD,

		     // ------------
		     // PCIE
		     // ------------
		     input   iPCIE_REF_CLK,                  //  100Mhz ref clock from root complex
		     input   iPIN_PERST_n,
		     input   iHIP_SERIAL_RX_IN0,             //  PCIE serial receive
		     input   iHIP_SERIAL_RX_IN1,             //  PCIE serial receive
		     input   iHIP_SERIAL_RX_IN2,             //  PCIE serial receive
		     input   iHIP_SERIAL_RX_IN3,             //  PCIE serial receive
		     input   iHIP_SERIAL_RX_IN4,             //  PCIE serial receive
		     input   iHIP_SERIAL_RX_IN5,             //  PCIE serial receive
		     input   iHIP_SERIAL_RX_IN6,             //  PCIE serial receive
		     input   iHIP_SERIAL_RX_IN7,             //  PCIE serial receive
		     output  oHIP_SERIAL_TX_OUT0,            //  PCIE serial transmit
		     output  oHIP_SERIAL_TX_OUT1,            //  PCIE serial transmit
		     output  oHIP_SERIAL_TX_OUT2,            //  PCIE serial transmit
		     output  oHIP_SERIAL_TX_OUT3,            //  PCIE serial transmit
		     output  oHIP_SERIAL_TX_OUT4,            //  PCIE serial transmit
		     output  oHIP_SERIAL_TX_OUT5,            //  PCIE serial transmit
		     output  oHIP_SERIAL_TX_OUT6,            //  PCIE serial transmit
		     output  oHIP_SERIAL_TX_OUT7,            //  PCIE serial transmit

		     // ------------
		     // Jumpers
		     // ------------
		     inout   ioOPT_1,                        //  currently selects debug signals on the logic analyzer interface
		     inout   ioOPT_2,
		     inout   ioOPT_3,
		     inout   ioOPT_4,
		     inout   ioOPT_5,
		     inout   ioOPT_6,
		     inout   ioOPT_7,
		     inout   ioOPT_8,

		     inout   ioOPT_ROT_1,                    //  jumpers
		     inout   ioOPT_ROT_2,
		     inout   ioOPT_ROT_4,
		     inout   ioOPT_ROT_3,

		     // ------------
		     // debug
		     // ------------
		     //inout   [33:0]                         oMICTOR_A,                       //  Logic analyzer debug interface A
		     //output  [33:0]                         oMICTOR_B,                       //  Logic analyzer debug interface B

		     inout   ioSYNC_RIBBON,
		     inout   ioSYNC_NEIGHBOR

		     );

   localparam CHANNELS    =  (LINKS+CROSSLINK)*2;

   wire [1:0][71:0] 	     txbist_data;
   wire [1:0] 		     txbist_data_val;

   wire [69:0] 		     fc_reconfig_to_xcvr;
   wire [45:0] 		     fc_reconfig_from_xcvr;


   wire 		     CLK_BIST;
   wire 		     CLK_CORE_212;
   wire 		     CLK_SER_PMA;
   wire 		     CLK_SER_212;
   wire [CHANNELS-1:0] 	     iCLK_RX;
   wire [CHANNELS-1:0] 	     oCLK_TX;
   wire 		     oRST_FC_CORE212_N;
   wire 		     oRST_FC_SER219_N;
   wire 		     oRST_FC_SER212_N;
   wire 		     oRST_CHIP_PCIE_N;
   wire 		     oRST_PCIE_REF_N;

   wire [3:0] 		     oREG_LOOPBACKSERDESCFG_PRODUCT;
   wire [3:0] 		     oREG_LOOPBACKSERDESCFG_REV;
   wire [3:0] 		     oREG_LOOPBACKSERDESCFG_MODE;
   wire [55:0] 		     oGLOBAL_TIMESTAMP;
   wire [CHANNELS-1:0] 	     atx_pll_locked;
   wire [CHANNELS-1:0] 	     tx_ready;
   wire [CHANNELS-1:0] 	     rx_ready;
   wire [CHANNELS-1:0] 	     losync;

   wire [1:0] 		     hip_pipe_sim_pipe_rate;
   wire [4:0] 		     hip_pipe_sim_ltssmstate;
   wire [7:0] 		     hip_pipe_rxpolarity;
   wire [7:0] 		     hip_pipe_txcompl;
   wire [7:0] 		     hip_pipe_txdatak;
   wire [7:0] 		     hip_pipe_txdetectrx;
   wire [7:0] 		     hip_pipe_txelecidle;
   wire [7:0] 		     hip_pipe_txdeemph;
   wire [7:0] 		     hip_pipe_txswing;
   wire [7:0] 		     hip_pipe_phystatus;
   wire [7:0] 		     hip_pipe_rxdatak;
   wire [7:0] 		     hip_pipe_rxelecidle;
   wire [7:0] 		     hip_pipe_rxvalid;
   wire [7:0][2:0] 	     hip_pipe_eidleinfersel;
   wire [7:0][1:0] 	     hip_pipe_powerdown;
   wire [7:0][7:0] 	     hip_pipe_txdata;
   wire [7:0][2:0] 	     hip_pipe_txmargin;
   wire [7:0][7:0] 	     hip_pipe_rxdata;
   wire [7:0][2:0] 	     hip_pipe_rxstatus;


   wire [31:0] 		     iHIP_CTRL_TEST_IN;
   wire [31:0] 		     oPCIE_MISC_STATUS;
   wire [11:0] 		     oRST_LINK_FC_CORE_N;
   wire [11:0] 		     oRST_LINK_FC_SER_N;
   wire [CHANNELS-1:0] 	     oRST_LINK_SERDES_TX212_N;
   wire [CHANNELS-1:0] 	     oRST_LINK_SERDES_TX219_N;
   wire [CHANNELS-1:0] 	     oRST_LINK_SERDES_RXREC_N;

   wire 		     oRST_GLB_TIMESTAMP_FR;
   wire 		     oRST_GLB_TIMESTAMP_FC;
   wire 		     oRST_GLB_TIMESTAMP_PCIE;


   wire [13:0] 		     cr_ucstats_addr;
   wire [20:0] 		     PCIEBIST_ADDR;
   wire [11:0][63:0] 	     LE_WR_DATA;
   wire [11:0][20:0] 	     LE_ADDR;
   wire [11:0][63:0] 	     LE_RD_DATA;
   wire [11:0] 		     LE_WR_EN;
   wire [11:0] 		     LE_RD_EN;
   wire [11:0] 		     LE_RD_DATA_V;
   logic   [1:0]                          iCLK_FC_219;                           //  218.945313 Mhz ref clock to FC SERDES
   logic   [1:0]                          iCLK_FC_425;                           //  218.945313 Mhz ref clock to FC SERDES
   logic [2*LINKS-1:0][63:0] iSERDES_MM_RD_DATA;
   logic [2*LINKS-1:0] 	     iSERDES_MM_RD_DATA_V;
   wire [2*LINKS-1:0][63:0]  oSERDES_MM_WR_DATA;
   wire [2*LINKS-1:0][13:0]  oSERDES_MM_ADDR;
   wire [2*LINKS-1:0] 	     oSERDES_MM_WR_EN;
   wire [2*LINKS-1:0] 	     oSERDES_MM_RD_EN;
   logic [2*LINKS-1:0][63:0] iFC1_LAYER_KR_MM_RD_DATA;
   logic [2*LINKS-1:0] 	     iFC1_LAYER_KR_MM_RD_DATA_V;
   wire [2*LINKS-1:0][63:0]  oFC1_LAYER_KR_MM_WR_DATA;
   wire [2*LINKS-1:0][13:0]  oFC1_LAYER_KR_MM_ADDR;
   wire [2*LINKS-1:0] 	     oFC1_LAYER_KR_MM_WR_EN;
   wire [2*LINKS-1:0] 	     oFC1_LAYER_KR_MM_RD_EN;
   logic [2*LINKS-1:0][63:0] rx_parallel_data_pma;
   logic [2*LINKS-1:0][63:0] tx_parallel_data_pma;
   logic 		     soft_mgmt_rst_reset  =  1'b0;

   logic 		     direct_access;    // = 1'b0;
   logic [3:0] 		     status_error;
   logic 		     timeout_error;
   logic 		     reconfig_busy;
   logic [63:0] 	     RECONFIG_MM_WR_DATA;
   logic [13:0] 	     RECONFIG_MM_ADDR;
   logic 		     RECONFIG_MM_WR_EN;
   logic 		     RECONFIG_MM_RD_EN;
   logic [63:0] 	     RECONFIG_MM_RD_DATA;
   logic 		     RECONFIG_MM_RD_DATA_V;


   logic 		     cr_xbar_wr_en;
   logic 		     cr_xbar_rd_en;
   logic [13:0] 	     cr_xbar_addr;
   logic [63:0] 	     cr_xbar_wr_data;
   wire [63:0] 		     cr_xbar_rd_data     ;    
   wire 		     cr_xbar_rd_data_v;

   logic [1:0] 		     enc_lane_act;
   logic [31:0] 	     iUCSTATS_MM_RD_DATA;
   logic [33:0] 	     debug_counter;
   logic [63:0] 	     BIST_RD_DATA;
   logic [63:0] 	     CLKRST_RD_DATA;

   logic [63:0] 	     CROSS_CH0_RD_DATA;
   logic [63:0] 	     CROSS_CH1_RD_DATA;
   logic 		     CROSS_CH0_RD_DATA_V;
   logic 		     CROSS_CH1_RD_DATA_V;
   logic 		     CROSS_CH0_RD_EN;
   logic 		     CROSS_CH1_RD_EN;
   logic 		     CROSS_CH0_WR_EN;
   logic 		     CROSS_CH1_WR_EN;
   wire [13:0] 		     CROSS_CH0_ADDR;
   wire [13:0] 		     CROSS_CH1_ADDR;
   wire [63:0] 		     CROSS_CH0_WR_DATA;
   wire [63:0] 		     CROSS_CH1_WR_DATA;

   logic [63:0] 	     FPGA_RD_DATA;
   logic [63:0] 	     GLOBAL_RD_DATA;
   logic [63:0] 	     iMM2PCIE_RD_DATA;
   logic [63:0] 	     PCIE_RD_DATA;
   logic [7:0] 		     mm_rd_en_delay;
   logic [7:0] 		     mm_wr_en_delay;
   logic [9:0] 		     le_ucstats_addr;
   logic [9:0] 		     oLE_UCSTATS_MM_ADDR;
   logic 		     BIST_RD_DATA_V;
   logic 		     CLKRST_RD_DATA_V;
   logic 		     FPGA_RD_DATA_V;
   logic 		     GLOBAL_RD_DATA_V;
   logic 		     iMM2PCIE_RD_DATA_V;
   logic 		     PCIE_RD_DATA_V;
   wire [1:0][16:0] 	     cr_txbist_addr;
   wire [1:0][63:0] 	     cr_txbist_rd_data;
   wire [1:0][63:0] 	     cr_txbist_wr_data;
   wire [1:0] 		     cr_txbist_ack;
   wire [1:0] 		     cr_txbist_rd_en;
   wire [1:0] 		     cr_txbist_wr_en;
   wire [1:0] 		     oCURRENT_SPEED;
   wire [11:0] 		     oRST_LINK_PCIE_N;
   wire [13:0] 		     CLKRST_ADDR;
   wire [13:0] 		     FPGA_ADDR;
   wire [20:0] 		     BIST_ADDR;
   wire [20:0] 		     GLOBAL_ADDR;
   wire [20:0] 		     oPCIE2MM_ADDRESS;
   wire [20:0] 		     PCIE_ADDR;
   wire [3:0] 		     heartbeat_led;
   wire [3:0] 		     oLANE_ACT;
   wire [31:0] 		     ucstats_data;
   wire [33:0] 		     debug_pcie_regs;
   wire [4:0] 		     oLTSSM;
   wire [63:0] 		     BIST_WR_DATA;
   wire [63:0] 		     CLKRST_WR_DATA;
   wire [63:0] 		     cr_ucstats_rd_data;
   wire [63:0] 		     cr_ucstats_wr_data;
   wire [63:0] 		     FPGA_WR_DATA;
   wire [63:0] 		     GLOBAL_WR_DATA;
   wire [63:0] 		     oPCIE2MM_WR_DATA;
   wire [63:0] 		     PCIEBIST_RD_DATA;
   wire [63:0] 		     PCIEBIST_WR_DATA;
   wire [63:0] 		     PCIE_WR_DATA;
   wire [7:0] 		     io_uc_data_out;
   wire 		     cr_ucstats_rd_data_v;
   wire 		     io_uc_data_out_val;
   wire 		     oAPP_RST_n_STATUS;
   wire 		     oPCIE2MM_RD_EN;
   wire 		     oPCIE2MM_WR_EN;
   wire 		     PCIEBIST_RD_DATA_V;
   wire [CHANNELS-1:0][7:0]  xgmii_rx_ctrl;
   wire [CHANNELS-1:0][63:0] xgmii_rx_data;

   logic [CHANNELS-1:0]      fc16pma_rd_data_v;
   logic [CHANNELS-1:0]      fc16pma_rd_en;
   logic [CHANNELS-1:0]      fc16pma_wr_en;
   logic [CHANNELS-1:0][63:0] fc16pma_rd_data;
   logic [CHANNELS-1:0][63:0] fc16pma_wr_data;
   logic [CHANNELS-1:0][13:0] fc16pma_addr;

   logic 		      oREG_FPGA_CTL_RX_SERDES_DISABLE;
   logic 		      oREG_FPGA_CTL_TX_SERDES_DISABLE;
   logic [CHANNELS-1:0]       rx_hi_ber;        // fix me

   wire [CHANNELS-1:0] 	      mtip_enable;
   wire [23:0] 		      sfp_los_qual;
   wire 		      oREG_FPGA_CTL_LED_OUTPUT_DISABLE;
   wire 		      oREG_FPGA_CTL_LOGIC_ANALYZER_INF_DISABLE;

   wire [CHANNELS-1:0] 	      oREG_CTL_FARLOOPBACKEN;

   wire [CHANNELS-1:0] 	      TX_CLK219;
   wire [2*LINKS-1:0] 	      FC1_RX_BLOCK_SYNC;
   wire [2*LINKS-1:0] 	      FC1_RX_VAL;
   wire [2*LINKS-1:0][1:0]    FC1_RX_SH;
   wire [2*LINKS-1:0][63:0]   FC1_RX_DATA;
   //fc1_interval_stats [CHANNELS-1:0]  FC1_INT_STATS ;
   logic [CHANNELS-1:0] [31:0] INT_STATS_FC1_CORR_EVENT_CNT;
   logic [CHANNELS-1:0] [31:0] INT_STATS_FC1_UNCORR_EVENT_CNT;
   logic [CHANNELS-1:0] [31:0] INT_STATS_FC1_PCS_LOS_CNT;



   logic [LINKS-1:0][63:0]    fmac0_xbar_rx_data;
   logic [LINKS-1:0][1:0]     fmac0_xbar_rx_sh;
   logic [LINKS-1:0] 	      fmac0_xbar_rx_valid;
   logic [LINKS-1:0][63:0]    fmac1_xbar_rx_data;
   logic [LINKS-1:0][1:0]     fmac1_xbar_rx_sh;
   logic [LINKS-1:0] 	      fmac1_xbar_rx_valid;

   logic  [CHANNELS-1:0] rx_is_lockedtodata;

   // Manual declarations because of autoreg issues
   // Manual declarations because of autoreg issues

   // Fix at 12 links and 24 channels - not a function of parameters because the link engine has 12 link interfaces



   genvar 		      gi;



   // ------------
   // LEDS
   // ------------

   always @* begin
      case(oLANE_ACT[3:0])
        4'b0001 : enc_lane_act[1:0]    =  2'b00;
        4'b0010 : enc_lane_act[1:0]    =  2'b01;
        4'b0100 : enc_lane_act[1:0]    =  2'b10;
        default : enc_lane_act[1:0]    =  2'b11;
      endcase // case (oLANE_ACT[3:0])
   end

   // PCIe Debug - the following signals should be locked down to the following
   // LEDs.
   assign  oLED_N[1:0]    =  oREG_FPGA_CTL_LED_OUTPUT_DISABLE ? 2'h3  : ~oCURRENT_SPEED[1:0];      // Gen1,2,3
   assign  oLED_N[3:2]    =  oREG_FPGA_CTL_LED_OUTPUT_DISABLE ? 2'h3  : ~enc_lane_act[1:0];        // lanes - 1,2,4,8
   assign  oLED_N[4]      =  oREG_FPGA_CTL_LED_OUTPUT_DISABLE ? 2'h1  : ~oAPP_RST_n_STATUS;

   // optional debug LEDs
   assign  oLED_N[9:5]    =  oREG_FPGA_CTL_LED_OUTPUT_DISABLE ? 5'h1F : ~oLTSSM[4:0];
   assign  oLED_N[11:10]  =  oREG_FPGA_CTL_LED_OUTPUT_DISABLE ? 2'h3  : 2'h3;
   assign  oLED_N[15:12]  =  oREG_FPGA_CTL_LED_OUTPUT_DISABLE ? 4'hF  : heartbeat_led[3:0];


   heartbeat_x4 #(
		  .heartbeat_mode                                        ( 1                                                  ),  // Selects LED pattern
		  .lfsr_seed                                             ( 1                                                  ),
		  .led_width                                             ( 4                                                  )
		  ) heartbeat_x4_inst (
				       .reset_n                                               ( oRST_FR_100M_N                                     ),  // input
				       .clk                                                   ( oCLK_100M_GLOBAL                                   ),  // input
				       .led_pattern                                           ( heartbeat_led[3:0]                                 )   // output [led_width-1:0]
				       );


   logic                                 mif_retry;
   logic [LINKS-1:0][3:0] 		 oLE_LINKSPEED;
   logic [CHANNELS-1:0][3:0] 		 iLINKSPEED;
   wire [31:0] 				 min_linkspeed_reconfig;
   wire [31:0] 				 max_linkspeed_reconfig;
   wire [CHANNELS/2-1:0][3:0] 		 status_data_rate;

   logic [7:0] 				 iREG_PCIE_AUTORESET_CNT;
   logic [31:0] 			 iREG_MIN_LINKSPEED_RECONFIG;
   logic [31:0] 			 iREG_MAX_LINKSPEED_RECONFIG;
   wire 				 ioCRC_ERROR;
   wire 				 oREG_FPGA_CTL_PCIE_AUTORESET_DISABLE;
   wire 				 oREG_FPGA_CTL_FORCE_RXDATA_ON_LOSSIG_DISABLE;
   wire [63:0] 				 fpga_rev;
   logic         oEND_OF_INTERVAL;
   logic end_of_interval;
   logic PCIE_REF_CLK;
   //IBUFG pcieclk_buf (.I(iPCIE_REF_CLK), .O(PCIE_REF_CLK)); 
   assign PCIE_REF_CLK = iPCIE_REF_CLK;
   
   always @(posedge CLK_SER_212 or negedge oRST_FC_SER212_N)
	   if (!oRST_FC_SER212_N)
			 end_of_interval <= 1'b0;
		 else
			 end_of_interval <= oEND_OF_INTERVAL;


   chipregs_wrap #(
		   . pFSERDESGRADE                                        ( 8'h01                                              ),
		   . pFSPEEDGRADE                                         ( 8'h02                                              ),
		   . pGBLTIMESTAMPRST                                     ( 1'b1                                               ),
		   . pNUMPCIELANES                                        ( 8'd8                                               ),
		   . pBISTPCIE1                                           ( 1'd0                                               ),
		   . pBISTPCIE0                                           ( 1'd1                                               ),
		   . pLITE                                                ( LITE                                               ),
		   . pPCIEGENMAX                                          ( 4'd2                                               ),
		   . pXCVRSPEEDMAX                                        ( 12'd8                                              ),
		   . pNUMDPLBUF                                           ( 4'd12                                              ),
		   . pFVENDOR                                             ( 16'h0a17                                           ),
		   . pNUMPCIEEP                                           ( 4'd1                                               ),
		   . pPROTOCOL                                            ( 4'd1                                               ),
		   . pFPACKAGE                                            ( 24'hA90F40                                         ),
		   . pNUMXCVR                                             ( CHANNELS                                           ),
		   . pXBAR                                                ( 1'd0                                               ),
		   . pBISTTX32B                                           ( 1'd1                                               ),
		   . pFFAMILY                                             ( 16'h0055                                           ),
		   . pNUMLINKENGINES                                      ( 4'd12                                              ),
		   . pBISTPRBSXCVR                                        ( 1'd1                                               )
		   ) chipregs_wrap_inst (
					 . ioCRC_ERROR                                          ( ioCRC_ERROR                                        ),  // output
					 . iREG_PCIE_AUTORESET_CNT                              ( iREG_PCIE_AUTORESET_CNT                            ),  // input [7:0]
					 . iREG_MIN_LINKSPEED_RECONFIG                          ( min_linkspeed_reconfig                             ),  // input [31:0]
					 . iREG_MAX_LINKSPEED_RECONFIG                          ( max_linkspeed_reconfig                             ),  // input [31:0]
					 . oRCFG_RETRY                                          ( mif_retry                                          ),  // output
					 . oREG_FPGA_CTL_PCIE_AUTORESET_DISABLE                 ( oREG_FPGA_CTL_PCIE_AUTORESET_DISABLE               ),  // output
					 . oREG_FPGA_CTL_FORCE_RXDATA_ON_LOSSIG_DISABLE         ( oREG_FPGA_CTL_FORCE_RXDATA_ON_LOSSIG_DISABLE       ),  // output
					 . fpga_rev                                             ( fpga_rev                                           ),  // output [63:0]
					 
					 . iRST_100M_n                                          ( oRST_FR_100M_N                                     ),  // input
					 . iCLK_100M                                            ( oCLK_100M_GLOBAL                                   ),  // input
					 . iRST_PCIE_REF_n                                      ( oRST_PCIE_REF_N                                    ),  // input
					 . iCLK_PCIE_REF                                        ( oCLK_PCIE_REF_GLOBAL                               ),  // input
					 . iRST_FC_CORE_n                                       ( oRST_FC_SER212_N                                  ),  // input
					 . iCLK_FC_CORE                                         ( CLK_SER_212                                       ),  // input
					 . iSFP_LOS                                             ( iSFP_LOS[LINKS*2-1:0]                              ),  // input [23:0]
					 . sfp_los_qual                                         ( sfp_los_qual[23:0]                                 ),  // output [23:0]
					 . iFPGA_RSTN                                           ( iFPGA_RSTN                                         ),  // input
					 . iFPGA_CLRN                                           ( iFPGA_CLRN                                         ),  // input
					 . iBUS_CLK                                             ( iBUS_CLK                                           ),  // input
					 . iBUS_EN                                              ( iBUS_EN                                            ),  // input
					 . iBUS_MASTER                                          ( iBUS_MASTER                                        ),  // input
					 . iBUS_RST                                             ( iBUS_RST                                           ),  // input
					 . ioBUS_SPARE                                          ( {1'b0,ioBUS_SPARE}                                 ),  // input [1:0]
					 . ioFPGA_DATA                                          ( ioFPGA_DATA[7:0]                                   ),  // input [7:0]
					 //. ioEXT1                                               ( ioEXT1                                             ),  // input
					 . ioEXT2                                               ( ioEXT2                                             ),  // input
					 . ioEXT3                                               ( ioEXT3                                             ),  // input
					 . ioEXT4                                               ( ioEXT4                                             ),  // input
					 . oFC_RATE_SEL                                         ( oFC_RATE_SEL[LINKS-1:0]                            ),  // input [11:0]
					 . iBD_NO                                               ( iBD_NO[1:0]                                        ),  // input [1:0]
					 . iASY                                                 ( iASY[3:0]                                          ),  // input [3:0]
					 . iFPGA_ID_N                                           ( iFPGA_ID_N                                         ),  // input
					 . oLED_N                                               ( oLED_N[15:0]                                       ),  // input [15:0]
					 . iRXD                                                 ( iRXD                                               ),  // input
					 . oTXD                                                 ( oTXD                                               ),  // input
					 . ioOPT_1                                              ( ioOPT_1                                            ),  // input
					 . ioOPT_2                                              ( ioOPT_2                                            ),  // input
					 . ioOPT_3                                              ( ioOPT_3                                            ),  // input
					 . ioOPT_4                                              ( ioOPT_4                                            ),  // input
					 . ioOPT_5                                              ( ioOPT_5                                            ),  // input
					 . ioOPT_6                                              ( ioOPT_6                                            ),  // input
					 . ioOPT_7                                              ( ioOPT_7                                            ),  // input
					 . ioOPT_8                                              ( ioOPT_8                                            ),  // input
					 . ioOPT_ROT_1                                          ( ioOPT_ROT_1                                        ),  // input
					 . ioOPT_ROT_2                                          ( ioOPT_ROT_2                                        ),  // input
					 . ioOPT_ROT_4                                          ( ioOPT_ROT_4                                        ),  // input
					 . ioOPT_ROT_3                                          ( ioOPT_ROT_3                                        ),  // input
					 . iMM_WR_DATA                                          ( FPGA_WR_DATA[63:0]                                 ),  // input [63:0]
					 . iMM_ADDRESS                                          ( FPGA_ADDR[9:0]                                     ),  // input [9:0]
					 . iMM_WR_EN                                            ( FPGA_WR_EN                                         ),  // input
					 . iMM_RD_EN                                            ( FPGA_RD_EN                                         ),  // input
					 . oMM_RD_DATA                                          ( FPGA_RD_DATA[63:0]                                 ),  // output [63:0]
					 . oMM_RD_DATA_V                                        ( FPGA_RD_DATA_V                                     ),  // output
					 . iFPGA_RIGHT_LEFT_N                                   ( iFPGA_ID_N                                         ),  // input
					 . iPCBREV                                              ( iASY                                               ),  // input [3:0]
					 . iRCFG_TIMEOUT                                        ( timeout_error                                      ),  // input
					 . iRCFG_BUSY                                           ( reconfig_busy                                      ),  // input
					 . iRCFG_ERROR                                          ( status_error[3:0]                                  ),  // input [3:0]
					 . oRCFG_DIRECT                                         ( direct_access                                      ),  // output
					 . oREG_LOOPBACKSERDESCFG_PRODUCT                       ( oREG_LOOPBACKSERDESCFG_PRODUCT[3:0]                ),  // output [3:0]
					 . oREG_LOOPBACKSERDESCFG_REV                           ( oREG_LOOPBACKSERDESCFG_REV[3:0]                    ),  // output [3:0]
					 . oREG_LOOPBACKSERDESCFG_MODE                          ( oREG_LOOPBACKSERDESCFG_MODE[3:0]                   ),  // output [3:0]
					 . oREG_FPGA_CTL_LED_OUTPUT_DISABLE                     ( oREG_FPGA_CTL_LED_OUTPUT_DISABLE                   ),  // output
					 . oREG_FPGA_CTL_LOGIC_ANALYZER_INF_DISABLE             ( oREG_FPGA_CTL_LOGIC_ANALYZER_INF_DISABLE           ),  // output
					 . oREG_FPGA_CTL_RX_SERDES_DISABLE                      ( oREG_FPGA_CTL_RX_SERDES_DISABLE                    ),  // output
					 . oREG_FPGA_CTL_TX_SERDES_DISABLE                      ( oREG_FPGA_CTL_TX_SERDES_DISABLE                    ),  // output
					 . iRST_GLB_TIMESTAMP_FR                                ( oRST_GLB_TIMESTAMP_FR                              ),  // input
					 . iRST_GLB_TIMESTAMP_FC                                ( oRST_GLB_TIMESTAMP_FC                              ),  // input
					 . iRST_GLB_TIMESTAMP_PCIE                              ( oRST_GLB_TIMESTAMP_PCIE                            ),  // input
					 . oGLOBAL_TIMESTAMP                                    ( oGLOBAL_TIMESTAMP[55:0]                            ),  // output [55:0]
					 . oEND_OF_INTERVAL                                     ( oEND_OF_INTERVAL                                   )   // output
					 );

   fc16clkrst_wrap #(
		     .pCNT_CMP_THRESH                                       ( 1973790                                            )
		     ) fc16clkrst_wrap_inst (
					     .iMM_WR_DATA                                           ( CLKRST_WR_DATA[63:0]                               ),  // input [63:0]
					     .iMM_ADDRESS                                           ( CLKRST_ADDR[9:0]                                   ),  // input [9:0]
					     .iMM_WR_EN                                             ( CLKRST_WR_EN                                       ),  // input
					     .iMM_RD_EN                                             ( CLKRST_RD_EN                                       ),  // input
					     .oMM_RD_DATA                                           ( CLKRST_RD_DATA[63:0]                               ),  // output [63:0]
					     .oMM_RD_DATA_V                                         ( CLKRST_RD_DATA_V                                   ),  // output
					     .iUC2FPGA_RST_PAD_N                                    ( iFPGA_RSTN                                         ),  // input
					     .iUC2FPGA_CLR_PAD_N                                    ( iFPGA_CLRN                                         ),  // input
					     .oRST_PCIE_HIP_N                                       ( oRST_PCIE_HIP_N                                    ),  // output
					     .oRST_PCIE_REF_N                                       ( oRST_PCIE_REF_N                                    ),  // output
					     .oRST_PCIE_APP_N                                       ( oRST_CHIP_PCIE_N                                    ),  // output
					     .oRST_LINK_PCIE_N                                      ( oRST_LINK_PCIE_N[11:0]                             ),  // output [11:0]
					     .oRST_LINK_FC_CORE_N                                   ( oRST_LINK_FC_CORE_N[11:0]                          ),  // output [11:0]
					     .oRST_LINK_FC_SER_N                                   ( oRST_LINK_FC_SER_N[11:0]                          ),  // output [11:0]
					     .oRST_LINK_SERDES_RXREC_N                              ( oRST_LINK_SERDES_RXREC_N[CHANNELS-1:0]             ),  // output [25:0]
					     .oRST_LINK_SERDES_TX212_N                              ( oRST_LINK_SERDES_TX212_N[CHANNELS-1:0]             ),  // output [25:0]
					     .oRST_LINK_SERDES_TX219_N                              ( oRST_LINK_SERDES_TX219_N[CHANNELS-1:0]             ),  // output [25:0]
					     .oRST_FR_100M_N                                        ( oRST_FR_100M_N                                     ),  // output
					     .oRST_FC_CORE212_N                                     ( oRST_FC_CORE212_N                                  ),          // output
					     .oRST_FC_SER219_N                                      ( oRST_FC_SER219_N                                  ),           // output
					     .oRST_FC_SER212_N                                      ( oRST_FC_SER212_N                                  ),           // output
					     .oRST_TXBIST_N                                         ( oRST_TXBIST_N                                      ),          // output
					     .oRST_XBAR_N                                           ( oRST_XBAR_N                                        ),          // output
					     .oRST_GLB_TIMESTAMP_FR                                 (oRST_GLB_TIMESTAMP_FR),
					     .oRST_GLB_TIMESTAMP_FC                                 (oRST_GLB_TIMESTAMP_FC),
					     .oRST_GLB_TIMESTAMP_PCIE                               (oRST_GLB_TIMESTAMP_PCIE),
					     .ioSYNC_RIBBON                                         (ioSYNC_RIBBON),
					     .ioSYNC_NEIGHBOR                                       (ioSYNC_NEIGHBOR),
					     .iCLK_FR_100M_PAD                                      ( iCLK_FR                                            ),          // input
					     .iCLK_PCIE_REF_PAD                                     (  PCIE_REF_CLK                                      ),          // input
					     .iCLK_425M_PAD                                         ( iCLK_425M_P[1:0]                                   ),          // input [1:0]
					     .iCLK_PCIE_CORECLKOUT_HIP                              ( iCLK_PCIE_CORECLKOUT_HIP                           ),          // input
					     .iCLK_SERDES_RXREC                                     ( iCLK_RX),      // input [25:0]
					     .iCLK_SERDES_TXCLK                                     ( oCLK_TX),      // input [25:0]
					     .iATX_PLL_LOCKED                                       ( atx_pll_locked[CHANNELS-1:0]                       ),  // input [25:0]
					     .iRX_READY                                             ( rx_ready[CHANNELS-1:0]                             ),  // input [25:0]
					     .iCLK_FC_219REF                                        (iCLK_FC_219[0]                                    ), 
					     .oCLK_100M_GLOBAL                                      ( oCLK_100M_GLOBAL                                   ),  // output
					     .oCLK_PCIE_GLOBAL                                      ( oCLK_PCIE_GLOBAL                                   ),  // output
					     .oCLK_PCIE_REF_GLOBAL                                  ( oCLK_PCIE_REF_GLOBAL                               ),  // output
					     .oCLK_CORE_212                                         ( CLK_CORE_212                                          ),       // output
					     .oCLK_BIST                                             ( CLK_BIST                                          ),       // output
					     .oCLK_SER_212                                          ( CLK_SER_212 ),                 // output
					     .oCLK_SER_PMA                                          ( CLK_SER_PMA )                  // output
					     );

   // uc statistics module
   assign  ioFPGA_DATA[7:0]   =  io_uc_data_out_val ? io_uc_data_out[7:0] : 8'hz;
   ucstats_wrap ucstats_wrap_inst (
				   .io_uc_cs                                              ( iBUS_EN                                            ),          // input
				   .io_uc_data_in                                         ( ioFPGA_DATA[7:0]                                   ),          // input [7:0]
				   .io_uc_valid                                           ( iBUS_CLK                                           ),          // input
				   .io_uc_master                                          ( iBUS_MASTER                                        ),          // input
				   .io_uc_reset_n                                         ( ~iBUS_RST                                          ),          // input
				   .io_uc_data_out                                        ( io_uc_data_out[7:0]                                ),          // output [7:0]
				   .io_uc_data_out_val                                    ( io_uc_data_out_val                                 ),          // output
				   .le_ucstats_req                                        ( le_ucstats_req                                     ),          // input
				   .le_ucstats_addr                                       ( le_ucstats_addr[9:0]                               ),          // input [9:0]
				   .le_ucstats_done                                       ( le_ucstats_done                                    ),          // input
				   .ucstats_data                                          ( ucstats_data[31:0]                                 ),          // output [31:0]
				   .ucstats_gnt                                           ( ucstats_gnt                                        ),          // output
				   .oLE_UCSTATS_MM_ADDR                                   ( oLE_UCSTATS_MM_ADDR[9:0]                           ),          // input [9:0]
				   .iUCSTATS_MM_RD_DATA                                   ( iUCSTATS_MM_RD_DATA[31:0]                          ),          // output [31:0]
				   .cr_rd_data                                            ( cr_ucstats_rd_data[63:0]                           ),          // output [63:0]
				   .cr_rd_data_v                                          ( cr_ucstats_rd_data_v                               ),          // output
				   .cr_wr_en                                              ( cr_ucstats_wr_en                                   ),          // input
				   .cr_rd_en                                              ( cr_ucstats_rd_en                                   ),          // input
				   .cr_addr                                               ( cr_ucstats_addr[9:0]                               ),          // input [9:0]
				   .cr_wr_data                                            ( cr_ucstats_wr_data[63:0]                           ),          // input [63:0]
				   .rst_n                                                 ( oRST_FC_SER212_N                                     ),       // input
				   .clk                                                   ( CLK_SER_212                                          )        // input
				   );


   logic [LINKS*2-1:0] [63:0] 		 tx_blk;
   logic [LINKS*2-1:0] [1:0] 		 tx_sh;
   logic [LINKS*2-1:0] 			 tx_val;

   logic [LINKS*2-1:0] [63:0] 		 pma_blk;
   logic [LINKS*2-1:0] [1:0] 		 pma_sh;
   logic [LINKS*2-1:0] 			 pma_val;
   
   logic [LINKS*2-1:0] [63:0] 		 enc_pcs_blk;
   logic [LINKS*2-1:0] [1:0] 		 enc_pcs_sh;
   logic [LINKS*2-1:0] 			 enc_pcs_val;

   generate   

      if (SIM_ONLY_TXBIST_BP) begin: txbist_bypass
	 for(gi = 0;gi< LINKS*2;gi++) begin :bypass_for_loop

	    assign enc_pcs_blk[gi] = pma_blk[gi];
	    assign enc_pcs_sh [gi] = pma_sh[gi];
	    assign enc_pcs_val[gi] = pma_val[gi];

	 end:bypass_for_loop
      end: txbist_bypass

      else begin : txbist_normal
	 for(gi = 0;gi< LINKS*2;gi++) begin :normal_for_loop

	    assign enc_pcs_blk[gi] = tx_blk[gi];
	    assign enc_pcs_sh [gi] = tx_sh[gi];
	    assign enc_pcs_val[gi] = tx_val[gi];

	 end:normal_for_loop
      end:txbist_normal

   endgenerate
   
   generate   
	 for(gi = 0;gi< 2;gi++) begin :clk_fc_gen
   IBUFDS_GTE4 clkin1_buf (.I(iCLK_FC_219_P[gi]), .IB(iCLK_FC_219_N[gi]), .O(iCLK_FC_219[gi])); 
   IBUFDS_GTE4 clkin2_buf (.I(iCLK_FC_425_P[gi]), .IB(iCLK_FC_425_N[gi]), .O(iCLK_FC_425[gi])); 
	 end:clk_fc_gen
   endgenerate
   fc1_kr_ser_wrap #(
		     . SIM_ONLY                                             ( SIM_ONLY_PMA_BP                                    ),
		     . CHANNELS                                             ( CHANNELS                                           ),
		     . DEBUG                                                ( 0                                                  ),
		     . LOW_LATENCY_PHY                                      ( 0                                                  ),
		     . LITE                                                 ( 0                                                  ),
		     . GROUP_PHY                                            ( 0                                                  ),
		     . PHASE_COMP                                           ( 0                                                  )
		     ) fc1_kr_ser_wrap_inst (
					     
					     .fc_reconfig_to_xcvr   (fc_reconfig_to_xcvr),
					     .fc_reconfig_from_xcvr (fc_reconfig_from_xcvr),
               . rx_is_lockedtodata (rx_is_lockedtodata),
					     
					     //. iCLK_FC_219_P                                        ( iCLK_FC_219_P                                      ),          // input [1:0]
					     //. iCLK_FC_425_P                                        ( iCLK_FC_425_P                                      ),          // input [1:0]
					     . iCLK_FC_219_P                                        ( iCLK_FC_219                                        ),          // input [1:0]
					     . iCLK_FC_425_P                                        ( iCLK_FC_425                                        ),          // input [1:0]
					     . iSFP_LOS                                             ( sfp_los_qual[LINKS*2-1:0]                              ),  // input [23:0]

					     // .iCLK_FC_P(iCLK_FC_P),
					     . min_linkspeed_reconfig                               ( min_linkspeed_reconfig                             ),  // output [31:0]
					     . max_linkspeed_reconfig                               ( max_linkspeed_reconfig                             ),  // output [31:0]
					     . status_data_rate                                     ( status_data_rate                                   ),  // output [CHANNELS/2-1:0][3:0]
					     . mif_retry                                            ( mif_retry                                          ),  // input 
					     . oLE_LINKSPEED                                        ( iLINKSPEED[CHANNELS-1:0]                           ),  // input [CHANNELS-1:0][3:0]
					     
					     . oFC_TD_P                                             ( oFC_TD_P[CHANNELS-1:0]                             ),  // output [CHANNELS-1:0]
					     . iFC_RD_P                                             ( iFC_RD_P[CHANNELS-1:0]                             ),  // input [CHANNELS-1:0]
					     . oFC_TD_N                                             ( oFC_TD_N[CHANNELS-1:0]                             ),  // output [CHANNELS-1:0]
					     . iFC_RD_N                                             ( iFC_RD_N[CHANNELS-1:0]                             ),  // input [CHANNELS-1:0]
					     . iCLK_CORE_212                                        ( CLK_CORE_212                                       ),  // input
					     . iCLK_SER_212                                         ( CLK_SER_212                                        ),  // input
					     . iCLK_SER_219                                         ( CLK_SER_PMA                                        ),  // input
					     . iCLK_100M_GLOBAL                                     ( oCLK_100M_GLOBAL                                   ),  // input
					     . iRST_FR_100M_N                                       ( oRST_FR_100M_N                                     ),  // input
					     . iRST_LINK_SERDES_RXREC_N                             ( oRST_LINK_SERDES_RXREC_N[CHANNELS-1:0]             ),  // input [CHANNELS-1:0]
					     . iRST_LINK_SERDES_TX212_N                             ( oRST_LINK_SERDES_TX212_N[CHANNELS-1:0]             ),  // input [CHANNELS-1:0]
					     . iRST_LINK_SERDES_TX219_N                             ( oRST_LINK_SERDES_TX219_N[CHANNELS-1:0]             ),  // input [CHANNELS-1:0]
					     . iRST_FC_CORE212_N                                    ( oRST_FC_SER212_N                                  ),  // input
					     . iRST_FC_SER212_N                                     ( oRST_FC_SER212_N                                  ),   // input
					     . iRST_FC_SER219_N                                     ( oRST_FC_SER219_N                                  ),   // input
					     . rx_pma_clkout                                        ( iCLK_RX                                            ),  // output [CHANNELS-1:0]
					     . atx_pll_locked                                       ( atx_pll_locked[CHANNELS-1:0]                       ),  // output [CHANNELS-1:0]
					     . rx_ready                                             ( rx_ready[CHANNELS-1:0]                             ),  // output [CHANNELS-1:0]
					     . RECONFIG_MM_WR_DATA                                  ( RECONFIG_MM_WR_DATA[63:0]                          ),  // input [63:0]
					     . RECONFIG_MM_ADDR                                     ( RECONFIG_MM_ADDR[13:0]                             ),  // input [13:0]
					     . RECONFIG_MM_WR_EN                                    ( RECONFIG_MM_WR_EN                                  ),  // input
					     . RECONFIG_MM_RD_EN                                    ( RECONFIG_MM_RD_EN                                  ),  // input
					     . RECONFIG_MM_RD_DATA                                  ( RECONFIG_MM_RD_DATA[63:0]                          ),  // output [63:0]
					     . RECONFIG_MM_ACK                                      ( RECONFIG_MM_ACK                                    ),  // output
					     . soft_mgmt_rst_reset                                  ( soft_mgmt_rst_reset                                ),  // input
					     . direct_access                                        ( direct_access                                      ),  // input
					     . oREG_FPGA_CTL_RX_SERDES_DISABLE                      ( oREG_FPGA_CTL_RX_SERDES_DISABLE                    ),  // input
					     . oREG_FPGA_CTL_TX_SERDES_DISABLE                      ( oREG_FPGA_CTL_TX_SERDES_DISABLE                    ),  // input
							 . REG_CTL_FARLOOPBACKEN                                ( oREG_CTL_FARLOOPBACKEN ),
					     . status_error                                         ( status_error                                       ),  // output [3:0]
					     . timeout_error                                        ( timeout_error                                      ),  // output
					     . reconfig_busy                                        ( reconfig_busy                                      ),  // output
					     . fc16pma_debug                                        (        /*SIM ONLY*/                                       ),   // output [25:0][15:0]
					     . oREG_LOOPBACKSERDESCFG_PRODUCT                       ( oREG_LOOPBACKSERDESCFG_PRODUCT                     ),  // input [3:0]
					     . oREG_LOOPBACKSERDESCFG_REV                           ( oREG_LOOPBACKSERDESCFG_REV                         ),  // input [3:0]
					     . oREG_LOOPBACKSERDESCFG_MODE                          ( oREG_LOOPBACKSERDESCFG_MODE                        ),  // input [3:0]
					     . fc16pma_wr_data                                      ( fc16pma_wr_data[CHANNELS-1:0]                      ),  // input [CHANNELS-1:0][63:0]
					     . fc16pma_addr                                         ( fc16pma_addr[CHANNELS-1:0]                         ),  // input [CHANNELS-1:0][13:0]
					     . fc16pma_wr_en                                        ( fc16pma_wr_en[CHANNELS-1:0]                        ),  // input [CHANNELS-1:0]
					     . fc16pma_rd_en                                        ( fc16pma_rd_en[CHANNELS-1:0]                        ),  // input [CHANNELS-1:0]
					     . fc16pma_rd_data                                      ( fc16pma_rd_data[CHANNELS-1:0]                      ),  // output [CHANNELS-1:0][63:0]
					     . fc16pma_rd_data_v                                    ( fc16pma_rd_data_v[CHANNELS-1:0]                    ),  // output [CHANNELS-1:0]
					     . iENC_IN_PCS_SH                                       ( enc_pcs_sh                                         ),  // input [CHANNELS-1:0][1:0]
					     . iENC_IN_PCS_BLK                                      ( enc_pcs_blk                                        ),  // input [CHANNELS-1:0][63:0]
					     . iENC_IN_PCS_BLK_ENA                                  ( enc_pcs_val                                        ),  // input [CHANNELS-1:0]
					     . oPCS_DOUT_BLOCK_SYNC                                 ( FC1_RX_BLOCK_SYNC                                  ),  // output [CHANNELS-1:0]
					     . oPCS_DOUT                                            ( FC1_RX_DATA                                        ),  // output [CHANNELS-1:0][63:0]
					     . oPCS_DOUT_SH                                         ( FC1_RX_SH                                          ),  // output [CHANNELS-1:0][1:0]
					     . oPCS_DOUT_EN                                         ( FC1_RX_VAL                                         ),  // output [CHANNELS-1:0]
					     . iCSR_WR_EN                                           ( oFC1_LAYER_KR_MM_WR_EN                             ),  // input [CHANNELS-1:0]
					     . iCSR_RD_EN                                           ( oFC1_LAYER_KR_MM_RD_EN                             ),  // input [CHANNELS-1:0]
					     . iCSR_ADDR                                            ( oFC1_LAYER_KR_MM_ADDR                              ),  // input [CHANNELS-1:0][13:0]
					     . iCSR_WR_DATA                                         ( oFC1_LAYER_KR_MM_WR_DATA                           ),  // input [CHANNELS-1:0][63:0]
					     . oCSR_RD_DATA                                         ( iFC1_LAYER_KR_MM_RD_DATA                           ),  // output [CHANNELS-1:0][63:0]
					     . oCSR_RD_DATA_V                                       ( iFC1_LAYER_KR_MM_RD_DATA_V                         ),  // output [CHANNELS-1:0]
					     . iINT_STATS_LATCH_CLR                                 ( {CHANNELS{end_of_interval}}                       ),  // input [CHANNELS-1:0]
					     //. oINT_STATS_FC1                                       ( FC1_INT_STATS                                      ),  // fc1_interval_stats [CHANNELS-1:0]
        .oINT_STATS_FC1_CORR_EVENT_CNT(INT_STATS_FC1_CORR_EVENT_CNT),
        .oINT_STATS_FC1_UNCORR_EVENT_CNT(INT_STATS_FC1_UNCORR_EVENT_CNT),
        .oINT_STATS_FC1_PCS_LOS_CNT(INT_STATS_FC1_PCS_LOS_CNT),

					     . tx_pma_clkout                                        ( oCLK_TX                                            ),   // output [CHANNELS-1:0]
					     . rx_parallel_data_pma                                (rx_parallel_data_pma),
					     . tx_parallel_data_pma                                (tx_parallel_data_pma)
					     );

   txmux
     #(
       .LINKS(LINKS)
       )
   txmux_inst
     (

      .txbist_data(txbist_data),
      .txbist_data_val(txbist_data_val),

      .tx_blk(tx_blk),
      .tx_sh(tx_sh),
      .tx_val(tx_val)
      );


   logic end_of_interval_bist;
   vi_sync_pulse end_of_interval_bist_inst
   (// source
    .clka       (CLK_SER_212),
    .rsta_n     (oRST_FC_SER212_N),
    .in_pulse   (end_of_interval),
    // dest
    .clkb       (CLK_BIST),
    .rstb_n     (oRST_TXBIST_N),
    .out_pulse  (end_of_interval_bist));

   
   txbist72b_wrap #(.BALI(1)) tx_bist_inst (
	            . linkspeed (iLINKSPEED[0]),
					    . clk                                                ( CLK_BIST                                       ),     // input 
					    . cr_txbist_addr                                     ( { cr_txbist_addr[1][9:0], cr_txbist_addr[0][9:0] }),     // input [1:0][9:0]
					    . cr_txbist_rd_en                                    ( cr_txbist_rd_en                                    ),    // input [1:0]
					    . cr_txbist_wr_data                                  ( cr_txbist_wr_data                                  ),    // input [1:0][63:0]
					    . cr_txbist_wr_en                                    ( cr_txbist_wr_en                                    ),    // input [1:0]
					    . end_of_interval                                    ( end_of_interval_bist                              ),    // input 
					    . rst                                                ( !oRST_TXBIST_N                                     ),    // input 
					    . rst_n                                              ( oRST_TXBIST_N                                      ),    // input 
					    . cr_txbist_ack                                      ( cr_txbist_ack                                      ),    // output [1:0]
					    . cr_txbist_rd_data                                  ( cr_txbist_rd_data                                  ),    // output [1:0][63:0]
					    . txbist_data                                        ( txbist_data                                        ),    // output [1:0][71:0]
					    . txbist_data_val                                    ( txbist_data_val                                    )     // output [1:0]
					    );
   
xilinx_pcie4_uscale_ep #(
  . AXI4_CC_TUSER_WIDTH                                ( 33                                                 ),
  . AXI4_CQ_TUSER_WIDTH                                ( 88                                                 ),
  . AXI4_RC_TUSER_WIDTH                                ( 75                                                 ),
  . AXI4_RQ_TUSER_WIDTH                                ( 62                                                 ),
  . AXISTEN_IF_CC_ALIGNMENT_MODE                       ( "FALSE"                                            ),
  . AXISTEN_IF_CC_PARITY_CHECK                         ( 0                                                  ),
  . AXISTEN_IF_CQ_ALIGNMENT_MODE                       ( "FALSE"                                            ),
  . AXISTEN_IF_CQ_PARITY_CHECK                         ( 0                                                  ),
  . AXISTEN_IF_ENABLE_CLIENT_TAG                       ( 0                                                  ),
  . AXISTEN_IF_ENABLE_MSG_ROUTE                        ( 18'h2FFFF                                          ),
  . AXISTEN_IF_ENABLE_RX_MSG_INTFC                     ( "FALSE"                                            ),
  . AXISTEN_IF_MC_RX_STRADDLE                          ( 0                                                  ),
  . AXISTEN_IF_RC_ALIGNMENT_MODE                       ( "FALSE"                                            ),
  . AXISTEN_IF_RC_PARITY_CHECK                         ( 0                                                  ),
  . AXISTEN_IF_RQ_ALIGNMENT_MODE                       ( "FALSE"                                            ),
  . AXISTEN_IF_RQ_PARITY_CHECK                         ( 0                                                  ),
  . C_DATA_WIDTH                                       ( 256                                                ),
  . EXT_PIPE_SIM                                       ( "FALSE"                                            ),
  //. KEEP_WIDTH                                         ( C_DATA_WIDTH / 32                                  ),
  . PL_LINK_CAP_MAX_LINK_SPEED                         ( 4                                                  ),
  . PL_LINK_CAP_MAX_LINK_WIDTH                         ( PL_LINK_CAP_MAX_LINK_WIDTH                         ),
  . RQ_AVAIL_TAG                                       ( 256                                                ),
  . RQ_AVAIL_TAG_IDX                                   ( 8                                                  )
) xilinx_pcie4_uscale_ep_inst (
  . pci_exp_txp                                        ( pci_exp_txp                                        ), // output [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]
  . pci_exp_txn                                        ( pci_exp_txn                                        ), // output [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]
  . pci_exp_rxp                                        ( pci_exp_rxp                                        ), // input [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]
  . pci_exp_rxn                                        ( pci_exp_rxn                                        ), // input [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]
  . sys_clk_p                                          ( sys_clk_p                                          ), // input 
  . sys_clk_n                                          ( sys_clk_n                                          ), // input 
  . sys_rst_n                                          ( sys_rst_n                                          )  // input 
);
   fc16_pcie_le #(
	    .PCIE_GEN3                                             ( PCIE_GEN3                     ),
		  .PORTS                                                 ( LINKS                         ),
		  .LINKS                                                 ( LINKS                         ),
		  .SIM_ONLY                                              ( SIM_ONLY_PCIE                 )
		  ) pcie_le_inst (
				  
				  .iRST_PCIE_APP_N                                       ( oRST_CHIP_PCIE_N                                    ),
				  . iRST_CHIP_PCIE_N                                   ( oRST_CHIP_PCIE_N                                   ), // input

				  .fc_reconfig_to_xcvr   (fc_reconfig_to_xcvr),
				  .fc_reconfig_from_xcvr (fc_reconfig_from_xcvr),
          . rx_is_lockedtodata (rx_is_lockedtodata),
				  
				  .fmac0_xbar_rx_data(fmac0_xbar_rx_data),
				  .fmac0_xbar_rx_sh(fmac0_xbar_rx_sh),
				  .fmac0_xbar_rx_valid(fmac0_xbar_rx_valid),
				  .fmac1_xbar_rx_data(fmac1_xbar_rx_data),
				  .fmac1_xbar_rx_sh(fmac1_xbar_rx_sh),
				  .fmac1_xbar_rx_valid(fmac1_xbar_rx_valid),
				  .oREG_LINKCTRL_RATESEL(oFC_RATE_SEL),
					. rx_parallel_data_pma                                (rx_parallel_data_pma),
					. mtip_enable (mtip_enable),
				  
				  . oLE_LINKSPEED                                        ( oLE_LINKSPEED                                      ),          // output [CHANNELS-1:0][3:0]
				  . iLE_LINKSPEED                                        ( status_data_rate                                   ),          // input [CHANNELS/2-1:0][3:0]
				  
				  .iCLK_CORE                                             ( CLK_SER_212                                          ),       // input
				  .iCLK_CORE219                                          ( CLK_SER_PMA                                          ),       // input
				  .iCLK_RX                                               ( iCLK_RX                                          ),            // input
				  .iRST_CORE_N                                             ( {12{oRST_FC_SER212_N}}                               ),       // input [LINKS-1:0] fix me
				  .iRST_CORE219_N                                          ( {12{oRST_FC_SER219_N}}                               ),       // input [LINKS-1:0] fix me
				  . fcrxrst_n                                            ( oRST_LINK_SERDES_TX219_N                                         ),
				  .iRST_LINK_FC_CORE_N (oRST_LINK_FC_CORE_N),
				  
				  .iRST_NPOR_n                                           ( oRST_PCIE_HIP_N                                    ),          // input
				  .iPIN_PERST_n                                          ( iPIN_PERST_n                                       ),          // input
				  .iRST_RX_N                                             ( oRST_LINK_FC_SER_N[11:0]                          ),          // input
				  .iRST_100M_N                                           ( oRST_FR_100M_N                                     ),          // input
				  .iRST_PCIE_N                                           ( {12{oRST_CHIP_PCIE_N}}                             ),          // input [LINKS-1:0]
				  .iREF_CLK                                              (  PCIE_REF_CLK                                      ),          // input
				  .iRECONFIG_XCVR_CLK                                    ( oCLK_100M_GLOBAL                                   ),          // input
				  .iCLK_100M                                             ( oCLK_100M_GLOBAL                                   ),          // input
				  .iCLK_PCIE_GLOBAL                                      ( oCLK_PCIE_GLOBAL                                   ),          // input
				  .oCLK_PCIE_CORECLKOUT_HIP                              ( iCLK_PCIE_CORECLKOUT_HIP                           ),          // output
				  .iGLOBAL_TIMESTAMP                                     ( oGLOBAL_TIMESTAMP[55:0]                            ),          // input [55:0]
				  .iEND_OF_INTERVAL                                      ( end_of_interval                                   ),          // input
				  .iHIP_SERIAL_RX_IN0                                    ( iHIP_SERIAL_RX_IN0                                 ),          // input
				  .iHIP_SERIAL_RX_IN1                                    ( iHIP_SERIAL_RX_IN1                                 ),          // input
				  .iHIP_SERIAL_RX_IN2                                    ( iHIP_SERIAL_RX_IN2                                 ),          // input
				  .iHIP_SERIAL_RX_IN3                                    ( iHIP_SERIAL_RX_IN3                                 ),          // input
				  .iHIP_SERIAL_RX_IN4                                    ( iHIP_SERIAL_RX_IN4                                 ),          // input
				  .iHIP_SERIAL_RX_IN5                                    ( iHIP_SERIAL_RX_IN5                                 ),          // input
				  .iHIP_SERIAL_RX_IN6                                    ( iHIP_SERIAL_RX_IN6                                 ),          // input
				  .iHIP_SERIAL_RX_IN7                                    ( iHIP_SERIAL_RX_IN7                                 ),          // input
				  .oHIP_SERIAL_TX_OUT0                                   ( oHIP_SERIAL_TX_OUT0                                ),          // output
				  .oHIP_SERIAL_TX_OUT1                                   ( oHIP_SERIAL_TX_OUT1                                ),          // output
				  .oHIP_SERIAL_TX_OUT2                                   ( oHIP_SERIAL_TX_OUT2                                ),          // output
				  .oHIP_SERIAL_TX_OUT3                                   ( oHIP_SERIAL_TX_OUT3                                ),          // output
				  .oHIP_SERIAL_TX_OUT4                                   ( oHIP_SERIAL_TX_OUT4                                ),          // output
				  .oHIP_SERIAL_TX_OUT5                                   ( oHIP_SERIAL_TX_OUT5                                ),          // output
				  .oHIP_SERIAL_TX_OUT6                                   ( oHIP_SERIAL_TX_OUT6                                ),          // output
				  .oHIP_SERIAL_TX_OUT7                                   ( oHIP_SERIAL_TX_OUT7                                ),          // output
				  .hip_pipe_sim_pipe_pclk_in                             ( hip_pipe_sim_pipe_pclk_in                          ),          // input  <<< NC
				  .hip_pipe_sim_pipe_rate                                ( hip_pipe_sim_pipe_rate[1:0]                        ),          // output [1:0]  <<< NC
				  .hip_pipe_sim_ltssmstate                               ( hip_pipe_sim_ltssmstate[4:0]                       ),          // output [4:0]  <<< NC
				  .hip_pipe_eidleinfersel                                ( hip_pipe_eidleinfersel /*[7:0][2:0]*/               ),         // output [7:0][2:0]  <<< NC
				  .hip_pipe_powerdown                                    ( hip_pipe_powerdown     /*[7:0][1:0]*/                   ),     // output [7:0][1:0]  <<< NC
				  .hip_pipe_rxpolarity                                   ( hip_pipe_rxpolarity[7:0]                           ),  // output [7:0]  <<< NC
				  .hip_pipe_txcompl                                      ( hip_pipe_txcompl[7:0]                              ),  // output [7:0]  <<< NC
				  .hip_pipe_txdata                                       ( hip_pipe_txdata/*[7:0][7:0]*/                      ),  // output [7:0][7:0]  <<< NC
				  .hip_pipe_txdatak                                      ( hip_pipe_txdatak[7:0]                              ),  // output [7:0]  <<< NC
				  .hip_pipe_txdetectrx                                   ( hip_pipe_txdetectrx[7:0]                           ),  // output [7:0]  <<< NC
				  .hip_pipe_txelecidle                                   ( hip_pipe_txelecidle[7:0]                           ),  // output [7:0]  <<< NC
				  .hip_pipe_txdeemph                                     ( hip_pipe_txdeemph[7:0]                             ),  // output [7:0]  <<< NC
				  .hip_pipe_txmargin                                     ( hip_pipe_txmargin      /*[7:0][2:0]*/                    ),    // output [7:0][2:0]  <<< NC
				  .hip_pipe_txswing                                      ( hip_pipe_txswing[7:0]                              ),  // output [7:0]  <<< NC
				  .hip_pipe_phystatus                                    ( hip_pipe_phystatus[7:0]                            ),  // input [7:0]  <<< NC
				  .hip_pipe_rxdata                                       ( hip_pipe_rxdata/*[7:0][7:0]*/                      ),  // input [7:0][7:0]  <<< NC
				  .hip_pipe_rxdatak                                      ( hip_pipe_rxdatak[7:0]                              ),  // input [7:0]  <<< NC
				  .hip_pipe_rxelecidle                                   ( hip_pipe_rxelecidle[7:0]                           ),  // input [7:0]  <<< NC
				  .hip_pipe_rxstatus                                     ( hip_pipe_rxstatus      /*[7:0][2:0]*/                    ),    // input [7:0][2:0]  <<< NC
				  .hip_pipe_rxvalid                                      ( hip_pipe_rxvalid[7:0]                              ),  // input [7:0]  <<< NC
				  .iHIP_CTRL_TEST_IN                                     ( iHIP_CTRL_TEST_IN[31:0]                            ),  // input [31:0]  <<< NC
				  .iHIP_CTRL_SIMU_MODE_PIPE                              ( iHIP_CTRL_SIMU_MODE_PIPE                           ),  // input <<< NC
				  .oLANE_ACT                                             ( oLANE_ACT[3:0]                                     ),  // output [3:0]
				  .oLTSSM                                                ( oLTSSM[4:0]                                        ),  // output [4:0]
				  .oCURRENT_SPEED                                        ( oCURRENT_SPEED[1:0]                                ),  // output [1:0]
				  .oAPP_RST_n_STATUS                                     ( oAPP_RST_n_STATUS                                  ),  // output
				  .oPCIE_MISC_STATUS                                     ( oPCIE_MISC_STATUS[31:0]                            ),  // output [31:0]  <<< NC
				  .oPCIE2MM_WR_DATA                                      ( oPCIE2MM_WR_DATA[63:0]                             ),  // output [63:0]
				  .oPCIE2MM_ADDRESS                                      ( oPCIE2MM_ADDRESS[20:0]                             ),  // output [20:0]
				  .oPCIE2MM_WR_EN                                        ( oPCIE2MM_WR_EN                                     ),  // output
				  .oPCIE2MM_RD_EN                                        ( oPCIE2MM_RD_EN                                     ),  // output
				  .iMM2PCIE_RD_DATA                                      ( iMM2PCIE_RD_DATA[63:0]                             ),  // input [63:0]
				  .iMM2PCIE_RD_DATA_V                                    ( iMM2PCIE_RD_DATA_V                                 ),  // input
				  .iLE_MM_WR_DATA                                        ( LE_WR_DATA                                         ),  // input [LINKS-1:0][63:0]
				  .iLE_MM_ADDR                                           ( LE_ADDR                                            ),  // input [LINKS-1:0][20:0]
				  .iLE_MM_WR_EN                                          ( LE_WR_EN                                           ),  // input [LINKS-1:0]
				  .iLE_MM_RD_EN                                          ( LE_RD_EN                                           ),  // input [LINKS-1:0]
				  .oLE_MM_RD_DATA                                        ( LE_RD_DATA                                         ),  // output [LINKS-1:0][63:0]
				  .oLE_MM_RD_DATA_V                                      ( LE_RD_DATA_V                                       ),  // output [LINKS-1:0]
				  .iBIST_MM_WR_DATA                                      ( PCIEBIST_WR_DATA[63:0]                             ),  // input [63:0]
				  .iBIST_MM_ADDR                                         ( PCIEBIST_ADDR[20:0]                                ),  // input [20:0]
				  .iBIST_MM_WR_EN                                        ( PCIEBIST_WR_EN                                     ),  // input
				  .iBIST_MM_RD_EN                                        ( PCIEBIST_RD_EN                                     ),  // input
				  .oBIST_MM_RD_DATA                                      ( PCIEBIST_RD_DATA[63:0]                             ),  // output [63:0]
				  .oBIST_MM_RD_DATA_V                                    ( PCIEBIST_RD_DATA_V                                 ),  // output
				  .iPCIE_MM_WR_DATA                                      ( PCIE_WR_DATA[63:0]                                 ),  // input [63:0]
				  .iPCIE_MM_ADDR                                         ( PCIE_ADDR[20:0]                                    ),  // input [20:0]
				  .iPCIE_MM_WR_EN                                        ( PCIE_WR_EN                                         ),  // input
				  .iPCIE_MM_RD_EN                                        ( PCIE_RD_EN                                         ),  // input
				  .oPCIE_MM_RD_DATA                                      ( PCIE_RD_DATA[63:0]                                 ),  // output [63:0]
				  .oPCIE_MM_RD_DATA_V                                    ( PCIE_RD_DATA_V                                     ),  // output
				  //.iLOSYNC                                               ( ~FC1_RX_BLOCK_SYNC                                             ),  // input [2*LINKS-1:0]
				  .iSFP_PHY_LOSIG                                        ( sfp_los_qual[23:0]                                     ),  // input [2*LINKS-1:0]
				  .iFC1_RX_BLOCK_SYNC                                    ( FC1_RX_BLOCK_SYNC                                             ),       // input [2*LINKS-1:0]
				  .iFC1_RX_VAL                                           ( FC1_RX_VAL                                         ),  // input [2*LINKS-1:0][7:0]
				  .iFC1_RX_SH                                            ( FC1_RX_SH                                          ),  // input [2*LINKS-1:0][7:0]
				  .iFC1_RX_DATA                                          ( FC1_RX_DATA                                        ),  // input [2*LINKS-1:0][63:0]
				  //.iFC1_INT_STATS                                        ( FC1_INT_STATS                                      ),
        .iINT_STATS_FC1_CORR_EVENT_CNT(INT_STATS_FC1_CORR_EVENT_CNT),
        .iINT_STATS_FC1_UNCORR_EVENT_CNT(INT_STATS_FC1_UNCORR_EVENT_CNT),
        .iINT_STATS_FC1_PCS_LOS_CNT(INT_STATS_FC1_PCS_LOS_CNT),

				  .oSERDES_MM_WR_DATA                                    ( oSERDES_MM_WR_DATA                                 ),  // output [2*LINKS-1:0][63:0]
				  .oSERDES_MM_ADDR                                       ( oSERDES_MM_ADDR                                    ),  // output [2*LINKS-1:0][13:0]
				  .oSERDES_MM_WR_EN                                      ( oSERDES_MM_WR_EN                                   ),  // output [2*LINKS-1:0]
				  .oSERDES_MM_RD_EN                                      ( oSERDES_MM_RD_EN                                   ),  // output [2*LINKS-1:0]
				  .iSERDES_MM_RD_DATA                                    ( iSERDES_MM_RD_DATA                                 ),  // input [2*LINKS-1:0][63:0]
				  .iSERDES_MM_RD_DATA_V                                  ( iSERDES_MM_RD_DATA_V                               ),  // input [2*LINKS-1:0]
				  .oFC1_LAYER_KR_MM_WR_DATA                                      ( oFC1_LAYER_KR_MM_WR_DATA                                 ),    // output [2*LINKS-1:0][63:0]
				  .oFC1_LAYER_KR_MM_ADDR                                         ( oFC1_LAYER_KR_MM_ADDR                                    ),    // output [2*LINKS-1:0][13:0]
				  .oFC1_LAYER_KR_MM_WR_EN                                        ( oFC1_LAYER_KR_MM_WR_EN                                   ),    // output [2*LINKS-1:0]
				  .oFC1_LAYER_KR_MM_RD_EN                                        ( oFC1_LAYER_KR_MM_RD_EN                                   ),    // output [2*LINKS-1:0]
				  .iFC1_LAYER_KR_MM_RD_DATA                                      ( iFC1_LAYER_KR_MM_RD_DATA                                 ),    // input [2*LINKS-1:0][63:0]
				  .iFC1_LAYER_KR_MM_RD_DATA_V                                    ( iFC1_LAYER_KR_MM_RD_DATA_V                               ),    // input [2*LINKS-1:0]
				  .iUCSTATS_DATA                                                 ( ucstats_data[31:0]                                 ),          // input [31:0]
				  .iUCSTATS_GNT                                                  ( ucstats_gnt                                        ),          // input
				  .oLE_UCSTATS_REQ                                               ( le_ucstats_req                                     ),          // output
				  .oLE_UCSTATS_ADDR                                              ( le_ucstats_addr[9:0]                               ),          // output [9:0]
				  .oLE_UCSTATS_DONE                                              ( le_ucstats_done                                    ),          // output
				  .iUCSTATS_MM_RD_DATA                                           ( iUCSTATS_MM_RD_DATA[31:0]                          ),          // input [31:0]
				  .oLE_UCSTATS_MM_ADDR                                           ( oLE_UCSTATS_MM_ADDR[9:0]                           )           // output [9:0]
				  );


   xx01_g_addr_decoder xx01_g_addr_decoder_inst (
						 .clk                                                   ( CLK_SER_212                                          ),       // input
						 .rst_n                                                 ( oRST_FC_SER212_N                                     ),       // input
						 .iMM_ADDR                                              ( GLOBAL_ADDR[13:0]                                  ),          // input [13:0]
						 .iMM_WR_EN                                             ( GLOBAL_WR_EN                                       ),          // input
						 .iMM_RD_EN                                             ( GLOBAL_RD_EN                                       ),          // input
						 .iMM_WR_DATA                                           ( GLOBAL_WR_DATA[63:0]                               ),          // input [63:0]
						 .oMM_RD_DATA                                           ( GLOBAL_RD_DATA[63:0]                               ),          // output [63:0]
						 .oMM_RD_DATA_V                                         ( GLOBAL_RD_DATA_V                                   ),          // output
						 .FPGA_ADDR                                             ( FPGA_ADDR[13:0]                                    ),          // output [13:0]
						 .FPGA_WR_DATA                                          ( FPGA_WR_DATA[63:0]                                 ),          // output [63:0]
						 .FPGA_WR_EN                                            ( FPGA_WR_EN                                         ),          // output
						 .FPGA_RD_EN                                            ( FPGA_RD_EN                                         ),          // output
						 .FPGA_RD_DATA                                          ( FPGA_RD_DATA[63:0]                                 ),          // input [63:0]
						 .FPGA_RD_DATA_V                                        ( FPGA_RD_DATA_V                                     ),          // input
						 .FPGA_clk                                              ( oCLK_100M_GLOBAL                                   ),          // input
						 .FPGA_rst_n                                            ( oRST_FR_100M_N                                     ),          // input
						 .CLKRST_ADDR                                           ( CLKRST_ADDR[13:0]                                  ),          // output [13:0]
						 .CLKRST_WR_DATA                                        ( CLKRST_WR_DATA[63:0]                               ),          // output [63:0]
						 .CLKRST_WR_EN                                          ( CLKRST_WR_EN                                       ),          // output
						 .CLKRST_RD_EN                                          ( CLKRST_RD_EN                                       ),          // output
						 .CLKRST_RD_DATA                                        ( CLKRST_RD_DATA[63:0]                               ),          // input [63:0]
						 .CLKRST_RD_DATA_V                                      ( CLKRST_RD_DATA_V                                   ),          // input
						 .CLKRST_clk                                            ( oCLK_100M_GLOBAL                                   ),          // input
						 .CLKRST_rst_n                                          ( oRST_FR_100M_N                                     ),          // input
						 .UCSTATS_ADDR                                          ( cr_ucstats_addr[13:0]                              ),          // output [13:0]
						 .UCSTATS_WR_DATA                                       ( cr_ucstats_wr_data[63:0]                           ),          // output [63:0]
						 .UCSTATS_WR_EN                                         ( cr_ucstats_wr_en                                   ),          // output
						 .UCSTATS_RD_EN                                         ( cr_ucstats_rd_en                                   ),          // output
						 .UCSTATS_RD_DATA                                       ( cr_ucstats_rd_data[63:0]                           ),          // input [63:0]
						 .UCSTATS_RD_DATA_V                                     ( cr_ucstats_rd_data_v                               ),          // input
						 .XBAR_ADDR                                             ( cr_xbar_addr[13:0]                                 ),          // output [13:0]
						 .XBAR_WR_DATA                                          ( cr_xbar_wr_data[63:0]                              ),          // output [63:0]
						 .XBAR_WR_EN                                            ( cr_xbar_wr_en                                      ),          // output
						 .XBAR_RD_EN                                            ( cr_xbar_rd_en                                      ),          // output
						 .XBAR_RD_DATA                                          ( cr_xbar_rd_data[63:0]                              ),          // input [63:0]
						 .XBAR_RD_DATA_V                                        ( cr_xbar_rd_data_v                                  ),          // input
						 .XBAR_clk                                              ( CLK_BIST                                   ),              // input
						 .XBAR_rst_n                                            ( oRST_XBAR_N                                        ),          // input
						 .CROSS_CH0_ADDR                                        ( CROSS_CH0_ADDR[13:0]                               ),          // output [13:0]
						 .CROSS_CH0_WR_DATA                                     ( CROSS_CH0_WR_DATA[63:0]                            ),          // output [63:0]
						 .CROSS_CH0_WR_EN                                       ( CROSS_CH0_WR_EN                                    ),          // output
						 .CROSS_CH0_RD_EN                                       ( CROSS_CH0_RD_EN                                    ),          // output
						 .CROSS_CH0_RD_DATA                                     ( CROSS_CH0_RD_DATA[63:0]                            ),          // input [63:0]
						 .CROSS_CH0_RD_DATA_V                                   ( CROSS_CH0_RD_DATA_V                                ),          // input
						 .CROSS_CH1_ADDR                                        ( CROSS_CH1_ADDR[13:0]                               ),          // output [13:0]
						 .CROSS_CH1_WR_DATA                                     ( CROSS_CH1_WR_DATA[63:0]                            ),          // output [63:0]
						 .CROSS_CH1_WR_EN                                       ( CROSS_CH1_WR_EN                                    ),          // output
						 .CROSS_CH1_RD_EN                                       ( CROSS_CH1_RD_EN                                    ),          // output
						 .CROSS_CH1_RD_DATA                                     ( CROSS_CH1_RD_DATA[63:0]                            ),          // input [63:0]
						 .CROSS_CH1_RD_DATA_V                                   ( CROSS_CH1_RD_DATA_V                                ),          // input
						 .RCFG_ADDR                                             ( RECONFIG_MM_ADDR[13:0]                             ),          // output [13:0]
						 .RCFG_WR_DATA                                          ( RECONFIG_MM_WR_DATA[63:0]                          ),          // output [63:0]
						 .RCFG_WR_EN                                            ( RECONFIG_MM_WR_EN                                  ),          // output
						 .RCFG_RD_EN                                            ( RECONFIG_MM_RD_EN                                  ),          // output
						 .RCFG_RD_DATA                                          ( RECONFIG_MM_RD_DATA[63:0]                          ),          // input [63:0]
						 .RCFG_RD_DATA_V                                        ( RECONFIG_MM_ACK                                    ),          // input
						 .RCFG_clk                                              ( oCLK_100M_GLOBAL                                   ),          // input
						 .RCFG_rst_n                                            ( oRST_FR_100M_N                                     )            // input 
						 );

   bist_addr_decoder bist_addr_decoder_inst (
					     .clk                                                   ( CLK_SER_212                                    ),             // input
					     .rst_n                                                 ( oRST_FC_SER212_N                                     ),       // input
					     .iMM_ADDR                                              ( BIST_ADDR[16:0]                                    ),          // input [16:0]
					     .iMM_WR_EN                                             ( BIST_WR_EN                                         ),          // input
					     .iMM_RD_EN                                             ( BIST_RD_EN                                         ),          // input
					     .iMM_WR_DATA                                           ( BIST_WR_DATA[63:0]                                 ),          // input [63:0]
					     .oMM_RD_DATA                                           ( BIST_RD_DATA[63:0]                                 ),          // output [63:0]
					     .oMM_RD_DATA_V                                         ( BIST_RD_DATA_V                                     ),          // output
					     .XX03_PCIE_ADDR                                        ( PCIEBIST_ADDR[16:0]                                ),          // output [16:0]
					     .XX03_PCIE_WR_DATA                                     ( PCIEBIST_WR_DATA[63:0]                             ),          // output [63:0]
					     .XX03_PCIE_WR_EN                                       ( PCIEBIST_WR_EN                                     ),          // output
					     .XX03_PCIE_RD_EN                                       ( PCIEBIST_RD_EN                                     ),          // output
					     .XX03_PCIE_RD_DATA                                     ( PCIEBIST_RD_DATA[63:0]                             ),          // input [63:0]
					     .XX03_PCIE_RD_DATA_V                                   ( PCIEBIST_RD_DATA_V                                 ),          // input
					     .XX03_PCIE_clk                                         ( oCLK_PCIE_GLOBAL                                   ),          // input
					     .XX03_PCIE_rst_n                                       ( oRST_CHIP_PCIE_N                                    ),          // input
					     .TX_CH0_ADDR                                           ( cr_txbist_addr[0][16:0]                            ),          // output [16:0]
					     .TX_CH0_WR_DATA                                        ( cr_txbist_wr_data[0][63:0]                         ),          // output [63:0]
					     .TX_CH0_WR_EN                                          ( cr_txbist_wr_en[0]                                 ),          // output
					     .TX_CH0_RD_EN                                          ( cr_txbist_rd_en[0]                                 ),          // output
					     .TX_CH0_RD_DATA                                        ( cr_txbist_rd_data[0][63:0]                         ),          // input [63:0]
					     .TX_CH0_RD_DATA_V                                      ( cr_txbist_ack[0]                                   ),          // input
					     .TX_CH0_clk                                            ( CLK_BIST                                 ),                // input
					     .TX_CH0_rst_n                                          ( oRST_TXBIST_N                                      ),          // input
					     .TX_CH1_ADDR                                           ( cr_txbist_addr[1][16:0]                            ),          // output [16:0]
					     .TX_CH1_WR_DATA                                        ( cr_txbist_wr_data[1][63:0]                         ),          // output [63:0]
					     .TX_CH1_WR_EN                                          ( cr_txbist_wr_en[1]                                 ),          // output
					     .TX_CH1_RD_EN                                          ( cr_txbist_rd_en[1]                                 ),          // output
					     .TX_CH1_RD_DATA                                        ( cr_txbist_rd_data[1][63:0]                         ),          // input [63:0]
					     .TX_CH1_RD_DATA_V                                      ( cr_txbist_ack[1]                                   ),          // input
					     .TX_CH1_clk                                            ( CLK_BIST                                 ),                // input
					     .TX_CH1_rst_n                                          ( oRST_TXBIST_N                                      )           // input
					     );

   top_addr_decoder top_addr_decoder_inst (
					   .clk                                                   ( CLK_SER_212                                    ),             // input
					   .rst_n                                                 ( oRST_FC_SER212_N                                     ),       // input
					   .iMM_ADDR                                              ( oPCIE2MM_ADDRESS[20:0]                             ),          // input [20:0]
					   .iMM_WR_EN                                             ( mm_wr_en_delay[4]                                  ),          // input
					   .iMM_RD_EN                                             ( mm_rd_en_delay[4]                                  ),          // input
					   .iMM_WR_DATA                                           ( oPCIE2MM_WR_DATA[63:0]                             ),          // input [63:0]
					   .oMM_RD_DATA                                           ( iMM2PCIE_RD_DATA[63:0]                             ),          // output [63:0]
					   .oMM_RD_DATA_V                                         ( iMM2PCIE_RD_DATA_V                                 ),          // output
      
					   .LINK0_ADDR                                            ( LE_ADDR[0][20:0]                                   ),          // output [20:0]
					   .LINK0_WR_DATA                                         ( LE_WR_DATA[0][63:0]                                ),          // output [63:0]
					   .LINK0_WR_EN                                           ( LE_WR_EN[0]                                        ),          // output
					   .LINK0_RD_EN                                           ( LE_RD_EN[0]                                        ),          // output
					   .LINK0_RD_DATA                                         ( LE_RD_DATA[0][63:0]                                ),          // input [63:0]
					   .LINK0_RD_DATA_V                                       ( LE_RD_DATA_V[0]                                    ),          // input
					   .LINK1_ADDR                                            ( LE_ADDR[1][20:0]                                   ),          // output [20:0]
					   .LINK1_WR_DATA                                         ( LE_WR_DATA[1][63:0]                                ),          // output [63:0]
					   .LINK1_WR_EN                                           ( LE_WR_EN[1]                                        ),          // output
					   .LINK1_RD_EN                                           ( LE_RD_EN[1]                                        ),          // output
					   .LINK1_RD_DATA                                         ( LE_RD_DATA[1][63:0]                                ),          // input [63:0]
					   .LINK1_RD_DATA_V                                       ( LE_RD_DATA_V[1]                                    ),          // input
					   .LINK2_ADDR                                            ( LE_ADDR[2][20:0]                                   ),          // output [20:0]
					   .LINK2_WR_DATA                                         ( LE_WR_DATA[2][63:0]                                ),          // output [63:0]
					   .LINK2_WR_EN                                           ( LE_WR_EN[2]                                        ),          // output
					   .LINK2_RD_EN                                           ( LE_RD_EN[2]                                        ),          // output
					   .LINK2_RD_DATA                                         ( LE_RD_DATA[2][63:0]                                ),          // input [63:0]
					   .LINK2_RD_DATA_V                                       ( LE_RD_DATA_V[2]                                    ),          // input
					   .LINK3_ADDR                                            ( LE_ADDR[3][20:0]                                   ),          // output [20:0]
					   .LINK3_WR_DATA                                         ( LE_WR_DATA[3][63:0]                                ),          // output [63:0]
					   .LINK3_WR_EN                                           ( LE_WR_EN[3]                                        ),          // output
					   .LINK3_RD_EN                                           ( LE_RD_EN[3]                                        ),          // output
					   .LINK3_RD_DATA                                         ( LE_RD_DATA[3][63:0]                                ),          // input [63:0]
					   .LINK3_RD_DATA_V                                       ( LE_RD_DATA_V[3]                                    ),          // input
					   .LINK4_ADDR                                            ( LE_ADDR[4][20:0]                                   ),          // output [20:0]
					   .LINK4_WR_DATA                                         ( LE_WR_DATA[4][63:0]                                ),          // output [63:0]
					   .LINK4_WR_EN                                           ( LE_WR_EN[4]                                        ),          // output
					   .LINK4_RD_EN                                           ( LE_RD_EN[4]                                        ),          // output
					   .LINK4_RD_DATA                                         ( LE_RD_DATA[4][63:0]                                ),          // input [63:0]
					   .LINK4_RD_DATA_V                                       ( LE_RD_DATA_V[4]                                    ),          // input
					   .LINK5_ADDR                                            ( LE_ADDR[5][20:0]                                   ),          // output [20:0]
					   .LINK5_WR_DATA                                         ( LE_WR_DATA[5][63:0]                                ),          // output [63:0]
					   .LINK5_WR_EN                                           ( LE_WR_EN[5]                                        ),          // output
					   .LINK5_RD_EN                                           ( LE_RD_EN[5]                                        ),          // output
					   .LINK5_RD_DATA                                         ( LE_RD_DATA[5][63:0]                                ),          // input [63:0]
					   .LINK5_RD_DATA_V                                       ( LE_RD_DATA_V[5]                                    ),          // input
					   .LINK6_ADDR                                            ( LE_ADDR[6][20:0]                                   ),          // output [20:0]
					   .LINK6_WR_DATA                                         ( LE_WR_DATA[6][63:0]                                ),          // output [63:0]
					   .LINK6_WR_EN                                           ( LE_WR_EN[6]                                        ),          // output
					   .LINK6_RD_EN                                           ( LE_RD_EN[6]                                        ),          // output
					   .LINK6_RD_DATA                                         ( LE_RD_DATA[6][63:0]                                ),          // input [63:0]
					   .LINK6_RD_DATA_V                                       ( LE_RD_DATA_V[6]                                    ),          // input
					   .LINK7_ADDR                                            ( LE_ADDR[7][20:0]                                   ),          // output [20:0]
					   .LINK7_WR_DATA                                         ( LE_WR_DATA[7][63:0]                                ),          // output [63:0]
					   .LINK7_WR_EN                                           ( LE_WR_EN[7]                                        ),          // output
					   .LINK7_RD_EN                                           ( LE_RD_EN[7]                                        ),          // output
					   .LINK7_RD_DATA                                         ( LE_RD_DATA[7][63:0]                                ),          // input [63:0]
					   .LINK7_RD_DATA_V                                       ( LE_RD_DATA_V[7]                                    ),          // input
					   .LINK8_ADDR                                            ( LE_ADDR[8][20:0]                                   ),          // output [20:0]
					   .LINK8_WR_DATA                                         ( LE_WR_DATA[8][63:0]                                ),          // output [63:0]
					   .LINK8_WR_EN                                           ( LE_WR_EN[8]                                        ),          // output
					   .LINK8_RD_EN                                           ( LE_RD_EN[8]                                        ),          // output
					   .LINK8_RD_DATA                                         ( LE_RD_DATA[8][63:0]                                ),          // input [63:0]
					   .LINK8_RD_DATA_V                                       ( LE_RD_DATA_V[8]                                    ),          // input
					   .LINK9_ADDR                                            ( LE_ADDR[9][20:0]                                   ),          // output [20:0]
					   .LINK9_WR_DATA                                         ( LE_WR_DATA[9][63:0]                                ),          // output [63:0]
					   .LINK9_WR_EN                                           ( LE_WR_EN[9]                                        ),          // output
					   .LINK9_RD_EN                                           ( LE_RD_EN[9]                                        ),          // output
					   .LINK9_RD_DATA                                         ( LE_RD_DATA[9][63:0]                                ),          // input [63:0]
					   .LINK9_RD_DATA_V                                       ( LE_RD_DATA_V[9]                                    ),          // input
					   .LINK10_ADDR                                           ( LE_ADDR[10][20:0]                                  ),          // output [20:0]
					   .LINK10_WR_DATA                                        ( LE_WR_DATA[10][63:0]                               ),          // output [63:0]
					   .LINK10_WR_EN                                          ( LE_WR_EN[10]                                       ),          // output
					   .LINK10_RD_EN                                          ( LE_RD_EN[10]                                       ),          // output
					   .LINK10_RD_DATA                                        ( LE_RD_DATA[10][63:0]                               ),          // input [63:0]
					   .LINK10_RD_DATA_V                                      ( LE_RD_DATA_V[10]                                   ),          // input
					   .LINK11_ADDR                                           ( LE_ADDR[11][20:0]                                  ),          // output [20:0]
					   .LINK11_WR_DATA                                        ( LE_WR_DATA[11][63:0]                               ),          // output [63:0]
					   .LINK11_WR_EN                                          ( LE_WR_EN[11]                                       ),          // output
					   .LINK11_RD_EN                                          ( LE_RD_EN[11]                                       ),          // output
					   .LINK11_RD_DATA                                        ( LE_RD_DATA[11][63:0]                               ),          // input [63:0]
					   .LINK11_RD_DATA_V                                      ( LE_RD_DATA_V[11]                                   ),          // input
      
					   .GLOBAL_ADDR                                           ( GLOBAL_ADDR[20:0]                                  ),          // output [20:0]
					   .GLOBAL_WR_DATA                                        ( GLOBAL_WR_DATA[63:0]                               ),          // output [63:0]
					   .GLOBAL_WR_EN                                          ( GLOBAL_WR_EN                                       ),          // output
					   .GLOBAL_RD_EN                                          ( GLOBAL_RD_EN                                       ),          // output
					   .GLOBAL_RD_DATA                                        ( GLOBAL_RD_DATA[63:0]                               ),          // input [63:0]
					   .GLOBAL_RD_DATA_V                                      ( GLOBAL_RD_DATA_V                                   ),          // input
					   .PCIE_ADDR                                             ( PCIE_ADDR[20:0]                                    ),          // output [20:0]
					   .PCIE_WR_DATA                                          ( PCIE_WR_DATA[63:0]                                 ),          // output [63:0]
					   .PCIE_WR_EN                                            ( PCIE_WR_EN                                         ),          // output
					   .PCIE_RD_EN                                            ( PCIE_RD_EN                                         ),          // output
					   .PCIE_RD_DATA                                          ( PCIE_RD_DATA[63:0]                                 ),          // input [63:0]
					   .PCIE_RD_DATA_V                                        ( PCIE_RD_DATA_V                                     ),          // input
					   .PCIE_clk                                              ( oCLK_PCIE_GLOBAL                                   ),          // input
					   .PCIE_rst_n                                            ( oRST_CHIP_PCIE_N                                    ),          // input
					   .BIST_ADDR                                             ( BIST_ADDR[20:0]                                    ),          // output [20:0]
					   .BIST_WR_DATA                                          ( BIST_WR_DATA[63:0]                                 ),          // output [63:0]
					   .BIST_WR_EN                                            ( BIST_WR_EN                                         ),          // output
					   .BIST_RD_EN                                            ( BIST_RD_EN                                         ),          // output
					   .BIST_RD_DATA                                          ( BIST_RD_DATA[63:0]                                 ),          // input [63:0]
					   .BIST_RD_DATA_V                                        ( BIST_RD_DATA_V                                     )           // input
					   );

   always @(posedge CLK_SER_212 or negedge oRST_FC_SER212_N) begin
      mm_rd_en_delay[7:0] <= ~oRST_FC_SER212_N ? 8'd0 : {mm_rd_en_delay[6:0],oPCIE2MM_RD_EN};
      mm_wr_en_delay[7:0] <= ~oRST_FC_SER212_N ? 8'd0 : {mm_wr_en_delay[6:0],oPCIE2MM_WR_EN};
   end

   xbar_wrap #(
	       .REMOVE_XBAR                    ( 1                                                  )
	       ) xbar_wrap_inst (
				 .rx_data_val                    ( {26{1'b1}}                                         ), // input [25:0]
				 .rx_data_in                     ( rx_parallel_data_pma                                   ), // input [25:0][39:0]
				 .rx_clk                         ( iCLK_RX                        ), // input [25:0]
				 .rx_rst_n                       ( oRST_LINK_SERDES_RXREC_N[CHANNELS-1:0] & rx_is_lockedtodata), // input [25:0]
				 .tx_clk                         ( {CHANNELS{CLK_SER_PMA}}), // input [25:0]
				 .tx_rst_n                       ( oRST_LINK_SERDES_TX212_N[CHANNELS-1:0] ), // input [25:0]
				 .txbist32b_data0                ( txbist_data[0]                              ), // input [39:0]
				 .txbist32b_data1                ( txbist_data[1]                              ), // input [39:0]
				 .txbist32b_data_val0            ( txbist_data_val[0]                                ), // input
				 .txbist32b_data_val1            ( txbist_data_val[1]                                ), // input
				 .xbar_tx_data                   ( tx_parallel_data_pma                                   ), // output [25:0][39:0]
				 .xbar_tx_data_val               (                              ), // output [25:0]
				 .cr_xbar_rd_data                ( cr_xbar_rd_data[63:0]                              ), // output [63:0]
				 .cr_xbar_rd_data_v              ( cr_xbar_rd_data_v                                  ), // output
				 .cr_xbar_wr_en                  ( cr_xbar_wr_en                                      ), // input
				 .cr_xbar_rd_en                  ( cr_xbar_rd_en                                      ), // input
				 .cr_xbar_addr                   ( cr_xbar_addr[9:0]                                  ), // input [9:0]
				 .cr_xbar_wr_data                ( cr_xbar_wr_data[63:0]                              ), // input [63:0]
				 .clk_txbist                     ( CLK_BIST                                 ), // input
				 .clk_xbar                       ( CLK_BIST                                   ), // input
				 .rst_txbist_n                   ( oRST_TXBIST_N                                      ), // input
				 .rst_xbar_n                     ( oRST_XBAR_N                                        ), // input
				 .oREG_CTL_FARLOOPBACKEN         (oREG_CTL_FARLOOPBACKEN)
				 );


   // -------------
   // Glue logic
   // -------------

   generate

      // fc16 - 26 channels, channels 25 and 26 are used in crosslink
      if ( (LINKS==12) & (CROSSLINK==1)) begin: gen_serdes
         assign  iLINKSPEED =  {{2{4'h4}},{2{oLE_LINKSPEED[11]}},  
				{2{oLE_LINKSPEED[10]}},  
				{2{oLE_LINKSPEED[9]}},   
				{2{oLE_LINKSPEED[8]}},   
				{2{oLE_LINKSPEED[7]}},   
				{2{oLE_LINKSPEED[6]}},   
				{2{oLE_LINKSPEED[5]}},
				{2{oLE_LINKSPEED[4]}},
				{2{oLE_LINKSPEED[3]}},   
				{2{oLE_LINKSPEED[2]}},   
				{2{oLE_LINKSPEED[1]}},
				{2{oLE_LINKSPEED[0]}}};
         assign  iSERDES_MM_RD_DATA[23:0]               =  {fc16pma_rd_data[23:0]};
         assign  iSERDES_MM_RD_DATA_V[23:0]             =  {fc16pma_rd_data_v[23:0]};
         assign  CROSS_CH0_RD_DATA[63:0]                =  fc16pma_rd_data[24];
         assign  CROSS_CH1_RD_DATA[63:0]                =  fc16pma_rd_data[25];
         assign  CROSS_CH0_RD_DATA_V                    =  fc16pma_rd_data_v[24];
         assign  CROSS_CH1_RD_DATA_V                    =  fc16pma_rd_data_v[25];
         assign  fc16pma_wr_data[25:0]                  =  {CROSS_CH1_WR_DATA[63:0],CROSS_CH0_WR_DATA[63:0],oSERDES_MM_WR_DATA[23:0]};
         assign  fc16pma_addr[25:0]                     =  {CROSS_CH1_ADDR[13:0],CROSS_CH0_ADDR[13:0],oSERDES_MM_ADDR[23:0]};
         assign  fc16pma_wr_en[25:0]                    =  {CROSS_CH1_WR_EN,CROSS_CH0_WR_EN,oSERDES_MM_WR_EN[23:0]};
         assign  fc16pma_rd_en[25:0]                    =  {CROSS_CH1_RD_EN,CROSS_CH0_RD_EN,oSERDES_MM_RD_EN[23:0]};
      end

   endgenerate



   // -------------
   // Debug
   // -------------

   // incrementing counter used to debug logic analyzer interface
   always @(posedge CLK_SER_212 or negedge oRST_FC_SER212_N)
     debug_counter[33:0] <= ~oRST_FC_SER212_N ? 34'd0 :
			    (debug_counter[33:0]+34'd1);

   //   assign oMICTOR_A[33:0] = ioOPT_1 ? debug_pcie_regs[33:0] : debug_counter[33:0];    - removed for LAI
   //assign  oMICTOR_A[33:0]    =  oREG_FPGA_CTL_LOGIC_ANALYZER_INF_DISABLE ? 34'd0 : debug_counter[33:0];
   //assign  oMICTOR_B[33:0]    =  oREG_FPGA_CTL_LOGIC_ANALYZER_INF_DISABLE ? 34'd0 : debug_counter[33:0];
   //assign  oMICTOR_A[33:0]    =  34'd0;
   //assign  oMICTOR_B[33:0]    =  34'd0;


   assign  debug_pcie_regs[33:0]  =  {iMM2PCIE_RD_DATA_V,8'd0,oPCIE2MM_ADDRESS[20:0],oPCIE2MM_WR_EN,oPCIE2MM_RD_EN};


endmodule
