/***************************************************************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
*
*
* Upper level dependencies: 
* Lower level dependencies: 
*
* Revision History Notes:
*
***************************************************************************/
module pma #(parameter CHANNELS        =  26,
        parameter SIM_ONLY             =  0,
        parameter LOW_LATENCY_PHY      =  0,
        parameter PHASE_COMP           =  0,
        parameter GROUP_PHY            =  0,
        parameter LITE                 =  0,
        parameter DEBUG                =  0)

(
        input   [69:0] fc_reconfig_to_xcvr,
        output  [45:0] fc_reconfig_from_xcvr,
        
        // --------------------------
        // Tx/Rx Interface
        // --------------------------
        
        input   logic [CHANNELS-1:0][63:0]           tx_parallel_data,                  //  tx parallel data to transceivers
        output  logic [CHANNELS-1:0][63:0]           rx_parallel_data,                  //  rx parallel data from transceivers
        output  [CHANNELS-1:0]                 tx_serial_data,                          //  per transceiver serial data to IOs
        input   [CHANNELS-1:0]                 rx_serial_data,                          //  per transceiver serial data to IOs
        input  logic [CHANNELS-1:0]                 iSFP_LOS,

        
        // --------------------------
        // Clocks and Reset
        // --------------------------
        
        input   [1:0]                          ref_clk_219,                             //  per side, reference clock, 1 is right, 0 is left 
        input   [1:0]                          ref_clk_425,                             //  per side, reference clock, 1 is right, 0 is left 
        input   mgmt_clk_clk,                   //  Avalon MM clock, must be 100-125Mhz for Stratix 5
        input   mgmt_rst_reset,                 //  Avalon & reset/reconfig controller reset
        input   clk,                            //  core clock (219Mhz)
        input   rst_n,                          //  asynchronous reset
        input   rst,                            //  asynchronous reset
        input   [CHANNELS-1:0]                 tx_rst_n,                        //  asynchronous reset
        input   [CHANNELS-1:0]                 rx_rst_n,                        //  asynchronous reset
        output  [CHANNELS-1:0]                 rx_pma_clkout,                   //  rx recovered parallel clock
        input   tx_pma_clk,
        output  [CHANNELS-1:0]                 tx_pma_clkout,                   //  tx parallel clock
        output  [CHANNELS-1:0]                 pll_locked_425,                          //  per channel PLL locked from ATX PLLs
        output  [CHANNELS-1:0]                 pll_locked_219,                          //  per channel PLL locked from ATX PLLs
        output  [CHANNELS-1:0]                 rx_ready,                                //  rx is ready
        //     output       [CHANNELS-1:0]               cdr_is_locked     ,            // per channel CDR locked 
        
        
        // --------------------------
        // CR / LE  Interface
        // --------------------------
        
        input   logic [CHANNELS-1:0][63:0]           oSERDES_MM_WR_DATA,
        input   logic [CHANNELS-1:0][13:0]           oSERDES_MM_ADDR,
        input   [CHANNELS-1:0]                 oSERDES_MM_WR_EN,
        input   [CHANNELS-1:0]                 oSERDES_MM_RD_EN,
        output  logic [CHANNELS-1:0][63:0]           iSERDES_MM_RD_DATA,
        output  [CHANNELS-1:0]                 iSERDES_MM_RD_DATA_V,
        input   logic  [CHANNELS-1:0]                 cfg_tx_invert_vec, 
        input   logic  [CHANNELS-1:0]                 cfg_rx_invert_vec,
        input   logic  [CHANNELS-1:0]                 cfg_rx_slip_vec,
        input   fpga_ctl_rx_serdes_disable,
        input   fpga_ctl_tx_serdes_disable,
        
        output  logic [25:0][15:0]                   debug,
        
        // --------------------------
        // Avalon MM interface
        // --------------------------
        
        input   [8:0]                          reconfig_mgmt_address,
        input   [2:0]                          reconfig_mgmt_read,
        input   [2:0]                          reconfig_mgmt_write,
        input   [31:0]                         reconfig_mgmt_writedata,
        output  [2:0][31:0]                    reconfig_mgmt_readdata,
        output  [2:0]                          reconfig_mgmt_waitrequest,
        output  reconfig_busy ,
        output  [CHANNELS-1:0][63:0]           rx_parallel_data_pma,
        input   [CHANNELS-1:0][63:0]           tx_parallel_data_pma,
				input   [CHANNELS/2-1:0][3:0] data_rate,
        output  [CHANNELS-1:0] rx_is_lockedtodata


        
);

localparam ATXS        =  (CHANNELS==16) ? 6 : 5;
genvar gi;

wire    [15:0]         reconfig_mif_readdata;
logic                 reconfig_mif_waitrequest =  1'b1;
wire    [31:0]         reconfig_mif_address;
wire    reconfig_mif_read;

logic  [CHANNELS-1:0] rx_is_lockedtodata_ser;

generate
if (LOW_LATENCY_PHY == 0 && PHASE_COMP == 0) begin : native_phy
        
        // xcvr reconfiguration signals
        logic  [CHANNELS+2*ATXS-1:0][69:0]      reconfig_to_xcvr;
        logic  [CHANNELS+2*ATXS-1:0][45:0]      reconfig_from_xcvr;
        
        wire    [CHANNELS-1:0] pll_powerdown_425, pll_powerdown_219, pll_powerdown_from_rc_425, pll_powerdown_from_rc_219;
        wire    [CHANNELS-1:0] ext_pll_clk_425;
        wire    [CHANNELS-1:0] ext_pll_clk_219;
        wire    [3:0]          ref_clk_int_219;
        wire    [3:0]          ref_clk_int_425;
        wire    [ATXS-1:0]     tx_pll_refclk_219;
        wire    [ATXS-1:0]     tx_pll_refclk_425;
        wire    [ATXS-1:0]     pll_clkout_425;
        wire    [ATXS-1:0]     pll_clkout_219;
        wire    [ATXS-1:0]     rc_pll_locked_425, rc_pll_locked_219;
        wire    [2*ATXS-1:0]     rc_pll_powerdown;
        wire    [CHANNELS-1:0] rx_cal_busy, tx_cal_busy;
        wire    [CHANNELS-1:0] rx_analogreset, rx_digitalreset;
        wire    [CHANNELS-1:0] tx_analogreset, tx_digitalreset;
        wire    [CHANNELS-1:0] rx_analogreset_from_rc, rx_digitalreset_from_rc;
        wire    [CHANNELS-1:0] tx_analogreset_from_rc, tx_digitalreset_from_rc;
        wire    [103:0]         pll_select;
        wire    [CHANNELS-1:0] tx_manual;
        wire    [CHANNELS-1:0] tx_ready;
        wire    reconfig_tx_cal_busy, reconfig_rx_cal_busy;
        logic  [CHANNELS-1:0]                phy_mgmt_clk;
        logic  [CHANNELS-1:0]                phy_mgmt_clk_reset;
        logic  [CHANNELS-1:0][8:0]           phy_mgmt_address;
        logic  [CHANNELS-1:0]                phy_mgmt_read;                    
        logic  [CHANNELS-1:0]                phy_mgmt_write;
        logic  [CHANNELS-1:0][31:0]          phy_mgmt_writedata;               
        wire    [CHANNELS-1:0][31:0]          phy_mgmt_readdata;                
        wire    [CHANNELS-1:0]                phy_mgmt_waitrequest;             
        
        
        assign  ref_clk_int_425[3:0]   =  (CHANNELS==16) ? {2'd0,ref_clk_425[1:0]} : { {3{ref_clk_425[1]}}, {1{ref_clk_425[0]}} };
        assign  ref_clk_int_219[3:0]   =  (CHANNELS==16) ? {2'd0,ref_clk_219[1:0]} : { {3{ref_clk_219[1]}}, {1{ref_clk_219[0]}} };
        
        for (gi=  0; gi<CHANNELS; gi   =  gi+1) begin : gen_pma_1ch
                
                pma_1ch 
                #(. SIM_ONLY (SIM_ONLY))
								pma_1ch
                (       // Outputs
                        .rx_pma_clkout                  ( rx_pma_clkout[gi]              ),
                        .iSERDES_MM_RD_DATA             ( iSERDES_MM_RD_DATA[gi]   ),
                        .iSERDES_MM_RD_DATA_V           ( iSERDES_MM_RD_DATA_V[gi]       ),
                        .rx_cal_busy                    ( rx_cal_busy[gi]                ),
                        .tx_cal_busy                    ( tx_cal_busy[gi]                ),
                        .rx_is_lockedtodata             ( rx_is_lockedtodata_ser[gi]         ),
                        .locked_to_data                 ( rx_is_lockedtodata[gi]         ),
                        .reconfig_from_xcvr             ( reconfig_from_xcvr[gi]         ),
                        .tx_serial_data                 ( tx_serial_data[gi]             ),
                        .rx_pma_parallel_data           ( rx_parallel_data[gi]     ),
                        .debug                          ( debug[gi][15:0]                ),
                        .tx_pma_clkout (tx_pma_clkout[gi]),
                        // Inputs
                        .tx_pma_clk                     ( tx_pma_clk                     ),
												.iSFP_LOS                       ( iSFP_LOS[gi]                   ),
                        .cfg_tx_invert                  ( cfg_tx_invert_vec[gi]          ),
                        .cfg_rx_invert                  ( cfg_rx_invert_vec[gi]          ),
                        .cfg_rx_slip                    ( cfg_rx_slip_vec[gi]            ),
                        .ext_pll_clk_425                ( ext_pll_clk_425[gi]                ),
                        .ext_pll_clk_219                ( ext_pll_clk_219[gi]                ),
                        .clk                            ( clk                            ),     // core clock
                        .rst_n                          ( rst_n                          ),     // asynchronous reset
                        .tx_rst_n                       ( tx_rst_n[gi]                   ),     // asynchronous reset
                        .rx_rst_n                       ( rx_rst_n[gi]                   ),     // asynchronous reset
                        .rst                            ( rst                            ),     // asynchronous reset
                        .oSERDES_MM_WR_DATA             ( oSERDES_MM_WR_DATA[gi][63:0]   ),
                        .oSERDES_MM_ADDR                ( oSERDES_MM_ADDR[gi][13:0]      ),
                        .oSERDES_MM_WR_EN               ( oSERDES_MM_WR_EN[gi]           ),
                        .oSERDES_MM_RD_EN               ( oSERDES_MM_RD_EN[gi]           ),
                        .rx_cdr_refclk_425              ( ref_clk_int_425[gi/8]              ),
                        .rx_cdr_refclk_219              ( ref_clk_int_219[gi/8]              ),
                        .tx_ready                       ( tx_ready[gi]                   ),
                        .rx_ready                       ( rx_ready[gi]                   ),
                        .pll_locked_425                     ( pll_locked_425[gi]                 ),
                        .pll_locked_219                     ( pll_locked_219[gi]                 ),
                        .pll_powerdown_425              ( pll_powerdown_425[gi]),
                        .pll_powerdown_219              ( pll_powerdown_219[gi]),
                        .reconfig_to_xcvr               ( reconfig_to_xcvr[gi]           ),
                        .rx_analogreset                 ( rx_analogreset[gi]             ),
                        .rx_digitalreset                ( rx_digitalreset[gi]            ),
                        .rx_serial_data                 ( rx_serial_data[gi]             ),
                        .tx_analogreset                 ( tx_analogreset[gi]             ),
                        .tx_digitalreset                ( tx_digitalreset[gi]            ),
                        .tx_pma_parallel_data           ( tx_parallel_data[gi]     ) ,
                        .rx_parallel_data_pma(rx_parallel_data_pma[gi]),
                        .tx_parallel_data_pma(tx_parallel_data_pma[gi]),
												.data_rate (data_rate[gi/2])

                );
                
                //---------------
                // TX/RX Disables
                //---------------
                assign  tx_digitalreset[gi]    =  fpga_ctl_tx_serdes_disable ? 1'b1 : tx_digitalreset_from_rc[gi];
                assign  tx_analogreset[gi]     =  fpga_ctl_tx_serdes_disable ? 1'b1 : tx_analogreset_from_rc[gi];
                assign  pll_powerdown_425[gi]      =  pll_powerdown_from_rc_425[gi];
                assign  pll_powerdown_219[gi]      =  pll_powerdown_from_rc_219[gi];
                assign  rx_digitalreset[gi]        =  fpga_ctl_rx_serdes_disable ? 1'b1 : rx_digitalreset_from_rc[gi];
                assign  rx_analogreset[gi]         =  fpga_ctl_rx_serdes_disable ? 1'b1 : rx_analogreset_from_rc[gi];
                
        end : gen_pma_1ch
        
        
        s5_atxpll s5_atxpll_0_inst
        (       . pll_powerdown      ( rc_pll_powerdown    [ATXS]                 ),            // input 
                . pll_refclk         ( tx_pll_refclk_219[0]        ),           // input [0:0]
                . pll_fbclk          ( pll_clkout_219[0]),      // input 
                . pll_clkout         ( pll_clkout_219[0]),      // output 
                . pll_locked         ( rc_pll_locked_219[0]),           // output 
                . reconfig_to_xcvr   ( reconfig_to_xcvr    [CHANNELS]      ),           // input [69:0]
                . reconfig_from_xcvr ( reconfig_from_xcvr  [CHANNELS]      )            // output [45:0]
        );
       
        assign reconfig_from_xcvr  [CHANNELS + ATXS] = {46{1'b0}};

        s5_atxpll425 s5_atxpll425_0_inst
        (       . pll_powerdown      ( rc_pll_powerdown    [0]                 ),       // input 
                . pll_refclk         ( tx_pll_refclk_425[0]        ),                   // input [0:0]
                . pll_fbclk          ( pll_clkout_425[0]),      // input 
                . pll_clkout         ( pll_clkout_425[0]),      // output 
                . pll_locked         ( rc_pll_locked_425[0]),           // output 
                . reconfig_to_xcvr   ( fc_reconfig_to_xcvr      ),      // input [69:0]
                . reconfig_from_xcvr ( fc_reconfig_from_xcvr    )       // output [45:0]
        );
        
        
        
        // -----------------------
        // 16 channel configuration
        // -----------------------
        // FC SERDES are located on the top banks left and right:
        //
        //      LEFT                              RIGHT
        //  ch7 - bank_L2   ATX2              ch8  - bank_R2    ATX3     
        //  ch6 - bank_L2   ATX2              ch9  - bank_R2    ATX3
        //  ch5 - bank_L2   ATX2              ch10 - bank_R2    ATX3
        //  ch4 - bank_L2   ATX1              ch11 - bank_R2    ATX4
        //  ch3 - bank_L2   ATX1              ch12 - bank_R2    ATX4
        //  ch2 - bank_L2   ATX1              ch13 - bank_R2    ATX4
        //  --------------                    --------------                                               
        //  ch1 - bank_L1   ATX0              ch14 - bank_R1    ATX5  
        //  ch0 - bank_L1   ATX0              ch15 - bank_R1    ATX5
        
        
        // -----------------------
        // 26 channel configuration
        // -----------------------
        // FC SERDES are located on the top banks left and right:
        //
        //      LEFT                              RIGHT
        //  ch7 - bank_L2   ATX1              ch8  - bank_R2    ATX2     
        //  ch6 - bank_L2   ATX1              ch9  - bank_R2    ATX2
        //  ch5 - bank_L2   ATX1              ch10 - bank_R2    ATX2
        //  ch4 - bank_L2   ATX1              ch11 - bank_R2    ATX2
        //  ch3 - bank_L2   ATX1              ch12 - bank_R2    ATX2
        //  ch2 - bank_L2   ATX1              ch13 - bank_R2    ATX2
        //  --------------                    --------------                                               
        //  ch1 - bank_L1   ATX0              ch14 - bank_R1    ATX3  
        //  ch0 - bank_L1   ATX0              ch15 - bank_R1    ATX3
        //                                    ch16 - bank_R1    ATX3 
        //                                    ch17 - bank_R1    ATX3 
        //                                    ch18 - bank_R1    ATX3 
        //                                    ch19 - bank_R1    ATX3 
        //  --------------                    --------------                                               
        //                                    ch20 - bank_R0    ATX4 
        //                                    ch21 - bank_R0    ATX4 
        //                                    ch22 - bank_R0    ATX4 
        //                                    ch23 - bank_R0    ATX4 
        //                                    ch24 - bank_R0    ATX4 
        //                                    ch25 - bank_R0    ATX4 
        
        
        // -----------------------
        // Reconfig Controller
        // -----------------------
        /*
        s5_reconfig_26ch s5_reconfig_26ch_inst (
                .mgmt_clk_clk                     ( mgmt_clk_clk              ),        // input 
                .mgmt_rst_reset                   ( mgmt_rst_reset            ),        // input 
                
                .reconfig_mgmt_address                              ( reconfig_mgmt_address       [6:0]                  ),     // input [6:0]
                .reconfig_mgmt_read                                 ( reconfig_mgmt_read          [0]                    ),     // input 
                .reconfig_mgmt_readdata                             ( reconfig_mgmt_readdata      [0]                    ),     // output [31:0]
                .reconfig_mgmt_waitrequest                          ( reconfig_mgmt_waitrequest   [0]                    ),     // output 
                .reconfig_mgmt_write                                ( reconfig_mgmt_write         [0]                    ),     // input 
                .reconfig_mgmt_writedata                            ( reconfig_mgmt_writedata                            ),     // input [31:0]
                
                .reconfig_mif_address             ( reconfig_mif_address      ),        // output [31:0]
                .reconfig_mif_read                ( reconfig_mif_read         ),        // output 
                .reconfig_mif_readdata            ( reconfig_mif_readdata     ),        // input [15:0]
                .reconfig_mif_waitrequest         ( reconfig_mif_waitrequest  ),        // input 
                
                .reconfig_busy                    ( reconfig_busy             ),        // output 
                .tx_cal_busy                      ( reconfig_tx_cal_busy      ),        // output 
                .rx_cal_busy                      ( reconfig_rx_cal_busy      ),        // output 
                
                .ch0_0_to_xcvr                    ( reconfig_to_xcvr   [ 0]   ),        // output [69:0]
                .ch0_0_from_xcvr                  ( reconfig_from_xcvr [ 0]   ),        // input [45:0]
                .ch1_1_to_xcvr                    ( reconfig_to_xcvr   [ 1]   ),        // output [69:0]
                .ch1_1_from_xcvr                  ( reconfig_from_xcvr [ 1]   ),        // input [45:0]
                .ch2_2_to_xcvr                    ( reconfig_to_xcvr   [ 2]   ),        // output [69:0]
                .ch2_2_from_xcvr                  ( reconfig_from_xcvr [ 2]   ),        // input [45:0]
                .ch3_3_to_xcvr                    ( reconfig_to_xcvr   [ 3]   ),        // output [69:0]
                .ch3_3_from_xcvr                  ( reconfig_from_xcvr [ 3]   ),        // input [45:0]
                .ch4_4_to_xcvr                    ( reconfig_to_xcvr   [ 4]   ),        // output [69:0]
                .ch4_4_from_xcvr                  ( reconfig_from_xcvr [ 4]   ),        // input [45:0]
                .ch5_5_to_xcvr                    ( reconfig_to_xcvr   [ 5]   ),        // output [69:0]
                .ch5_5_from_xcvr                  ( reconfig_from_xcvr [ 5]   ),        // input [45:0]
                .ch6_6_to_xcvr                    ( reconfig_to_xcvr   [ 6]   ),        // output [69:0]
                .ch6_6_from_xcvr                  ( reconfig_from_xcvr [ 6]   ),        // input [45:0]
                .ch7_7_to_xcvr                    ( reconfig_to_xcvr   [ 7]   ),        // output [69:0]
                .ch7_7_from_xcvr                  ( reconfig_from_xcvr [ 7]   ),        // input [45:0]
                .ch8_8_to_xcvr                    ( reconfig_to_xcvr   [ 8]   ),        // output [69:0]
                .ch8_8_from_xcvr                  ( reconfig_from_xcvr [ 8]   ),        // input [45:0]
                .ch9_9_to_xcvr                    ( reconfig_to_xcvr   [ 9]   ),        // output [69:0]
                .ch9_9_from_xcvr                  ( reconfig_from_xcvr [ 9]   ),        // input [45:0]
                
                .ch10_10_to_xcvr                  ( reconfig_to_xcvr   [10]   ),        // output [69:0]
                .ch10_10_from_xcvr                ( reconfig_from_xcvr [10]   ),        // input [45:0]
                .ch11_11_to_xcvr                  ( reconfig_to_xcvr   [11]   ),        // output [69:0]
                .ch11_11_from_xcvr                ( reconfig_from_xcvr [11]   ),        // input [45:0]
                .ch12_12_to_xcvr                  ( reconfig_to_xcvr   [12]   ),        // output [69:0]
                .ch12_12_from_xcvr                ( reconfig_from_xcvr [12]   ),        // input [45:0]
                .ch13_13_to_xcvr                  ( reconfig_to_xcvr   [13]   ),        // output [69:0]
                .ch13_13_from_xcvr                ( reconfig_from_xcvr [13]   ),        // input [45:0]
                .ch14_14_to_xcvr                  ( reconfig_to_xcvr   [14]   ),        // output [69:0]
                .ch14_14_from_xcvr                ( reconfig_from_xcvr [14]   ),        // input [45:0]
                .ch15_15_to_xcvr                  ( reconfig_to_xcvr   [15]   ),        // output [69:0]
                .ch15_15_from_xcvr                ( reconfig_from_xcvr [15]   ),        // input [45:0]
                .ch16_16_to_xcvr                  ( reconfig_to_xcvr   [16]   ),        // output [69:0]
                .ch16_16_from_xcvr                ( reconfig_from_xcvr [16]   ),        // input [45:0]
                .ch17_17_to_xcvr                  ( reconfig_to_xcvr   [17]   ),        // output [69:0]
                .ch17_17_from_xcvr                ( reconfig_from_xcvr [17]   ),        // input [45:0]
                .ch18_18_to_xcvr                  ( reconfig_to_xcvr   [18]   ),        // output [69:0]
                .ch18_18_from_xcvr                ( reconfig_from_xcvr [18]   ),        // input [45:0]
                .ch19_19_to_xcvr                  ( reconfig_to_xcvr   [19]   ),        // output [69:0]
                .ch19_19_from_xcvr                ( reconfig_from_xcvr [19]   ),        // input [45:0]
                
                .ch20_20_to_xcvr                  ( reconfig_to_xcvr   [20]   ),        // output [69:0]
                .ch20_20_from_xcvr                ( reconfig_from_xcvr [20]   ),        // input [45:0]
                .ch21_21_to_xcvr                  ( reconfig_to_xcvr   [21]   ),        // output [69:0]
                .ch21_21_from_xcvr                ( reconfig_from_xcvr [21]   ),        // input [45:0]
                .ch22_22_to_xcvr                  ( reconfig_to_xcvr   [22]   ),        // output [69:0]
                .ch22_22_from_xcvr                ( reconfig_from_xcvr [22]   ),        // input [45:0]
                .ch23_23_to_xcvr                  ( reconfig_to_xcvr   [23]   ),        // output [69:0]
                .ch23_23_from_xcvr                ( reconfig_from_xcvr [23]   ),        // input [45:0]
                .ch24_24_to_xcvr                  ( reconfig_to_xcvr   [24]   ),        // output [69:0]
                .ch24_24_from_xcvr                ( reconfig_from_xcvr [24]   ),        // input [45:0]
                .ch25_25_to_xcvr                  ( reconfig_to_xcvr   [25]   ),        // output [69:0]
                .ch25_25_from_xcvr                ( reconfig_from_xcvr [25]   ),        // input [45:0]
                .ch26_26_to_xcvr                  ( reconfig_to_xcvr   [26]   ),        // output [69:0]
                .ch26_26_from_xcvr                ( reconfig_from_xcvr [26]   ),        // input [45:0]
                .ch27_27_to_xcvr                  ( reconfig_to_xcvr   [27]   ),        // output [69:0]
                .ch27_27_from_xcvr                ( reconfig_from_xcvr [27]   ),        // input [45:0]
                .ch28_28_to_xcvr                  ( reconfig_to_xcvr   [28]   ),        // output [69:0]
                .ch28_28_from_xcvr                ( reconfig_from_xcvr [28]   ),        // input [45:0]
                .ch29_29_to_xcvr                  ( reconfig_to_xcvr   [29]   ),        // output [69:0]
                .ch29_29_from_xcvr                ( reconfig_from_xcvr [29]   ),        // input [45:0]
                .ch30_30_to_xcvr                  ( reconfig_to_xcvr   [30]   ),        // output [69:0]
                .ch30_30_from_xcvr                ( reconfig_from_xcvr [30]   ),        // input [45:0]
                .ch31_31_to_xcvr                  ( reconfig_to_xcvr   [31]   ),        // output [69:0]
                .ch31_31_from_xcvr                ( reconfig_from_xcvr [31]   ),        // input [45:0]
                .ch32_32_to_xcvr                  ( reconfig_to_xcvr   [32]   ),        // output [69:0]
                .ch32_32_from_xcvr                ( reconfig_from_xcvr [32]   ),        // input [45:0]
                .ch33_33_to_xcvr                  ( reconfig_to_xcvr   [33]   ),        // output [69:0]
                .ch33_33_from_xcvr                ( reconfig_from_xcvr [33]   ),        // input [45:0]
                .ch34_34_to_xcvr                  ( reconfig_to_xcvr   [34]   ),        // output [69:0]
                .ch34_34_from_xcvr                ( reconfig_from_xcvr [34]   ),        // input [45:0]
                .ch35_35_to_xcvr                  ( reconfig_to_xcvr   [35]   ),        // output [69:0]
                .ch35_35_from_xcvr                ( reconfig_from_xcvr [35]   )         // input [45:0]
                
        );
        */
        s5_reset_26ch s5_reset_26ch
        (       // Outputs
                .pll_powerdown                  ( rc_pll_powerdown        [2*ATXS-1:0]     ),
                .tx_analogreset                 ( tx_analogreset_from_rc  [CHANNELS-1:0] ),
                .tx_digitalreset                ( tx_digitalreset_from_rc [CHANNELS-1:0] ),
                .tx_ready                       ( tx_ready                [CHANNELS-1:0] ),
                .rx_analogreset                 ( rx_analogreset_from_rc  [CHANNELS-1:0] ),
                .rx_digitalreset                ( rx_digitalreset_from_rc [CHANNELS-1:0] ),
                .rx_ready                       ( rx_ready                [CHANNELS-1:0] ),
                // Inputs
                .clock                          ( mgmt_clk_clk                          ),
                .reset                          ( mgmt_rst_reset                        ),      // async reset synchronized in reset_controller
                .pll_locked                     ( {rc_pll_locked_219[ATXS-1:0], rc_pll_locked_425[ATXS-1:0]}     ),
                .pll_select                     ( pll_select             [103:0]         ),     // fix me
                .tx_cal_busy                    ( tx_cal_busy            [CHANNELS-1:0] ),
                .tx_manual                      ( tx_manual              [CHANNELS-1:0] ),
                .rx_is_lockedtodata             ( rx_is_lockedtodata_ser     [CHANNELS-1:0] ),
                .rx_cal_busy                    ( rx_cal_busy            [CHANNELS-1:0] ) 
        );
        // glue logic
        
        assign  tx_pll_refclk_219                  =  {{3{ref_clk_219[1]}},{2{ref_clk_219[0]}}};
        assign  tx_pll_refclk_425                  =  {{3{ref_clk_425[1]}},{2{ref_clk_425[0]}}};
        
        assign  ext_pll_clk_425 [ 0 +: 2]          =  {2{pll_clkout_425[0]}};
        assign  ext_pll_clk_425 [ 2 +: 6]          =  {6{pll_clkout_425[1]}};
        assign  ext_pll_clk_425 [ 8 +: 6]          =  {6{pll_clkout_425[2]}};
        assign  ext_pll_clk_425 [14 +: 6]          =  {6{pll_clkout_425[3]}};
        assign  ext_pll_clk_425 [20 +: 6]          =  {6{pll_clkout_425[4]}};
        
        assign  ext_pll_clk_219 [ 0 +: 2]          =  {2{pll_clkout_219[0]}};
        assign  ext_pll_clk_219 [ 2 +: 6]          =  {6{pll_clkout_219[1]}};
        assign  ext_pll_clk_219 [ 8 +: 6]          =  {6{pll_clkout_219[2]}};
        assign  ext_pll_clk_219 [14 +: 6]          =  {6{pll_clkout_219[3]}};
        assign  ext_pll_clk_219 [20 +: 6]          =  {6{pll_clkout_219[4]}};
        
        assign  pll_powerdown_from_rc_425 [ 0 +: 2]        =  {2{rc_pll_powerdown[0]}};
        assign  pll_powerdown_from_rc_425 [ 2 +: 6]        =  {6{rc_pll_powerdown[1]}};
        assign  pll_powerdown_from_rc_425 [ 8 +: 6]        =  {6{rc_pll_powerdown[2]}};
        assign  pll_powerdown_from_rc_425 [14 +: 6]        =  {6{rc_pll_powerdown[3]}};
        assign  pll_powerdown_from_rc_425 [20 +: 6]        =  {6{rc_pll_powerdown[4]}};
        assign  pll_powerdown_from_rc_219 [ 0 +: 2]        =  {2{rc_pll_powerdown[5]}};
        assign  pll_powerdown_from_rc_219 [ 2 +: 6]        =  {6{rc_pll_powerdown[6]}};
        assign  pll_powerdown_from_rc_219 [ 8 +: 6]        =  {6{rc_pll_powerdown[7]}};
        assign  pll_powerdown_from_rc_219 [14 +: 6]        =  {6{rc_pll_powerdown[8]}};
        assign  pll_powerdown_from_rc_219 [20 +: 6]        =  {6{rc_pll_powerdown[9]}};
        
        assign  pll_locked_425 [ 0 +: 2]           =  {2{rc_pll_locked_425[0]}};
        assign  pll_locked_425 [ 2 +: 6]           =  {6{rc_pll_locked_425[1]}};
        assign  pll_locked_425 [ 8 +: 6]           =  {6{rc_pll_locked_425[2]}};
        assign  pll_locked_425 [14 +: 6]           =  {6{rc_pll_locked_425[3]}};
        assign  pll_locked_425 [20 +: 6]           =  {6{rc_pll_locked_425[4]}};
        assign  pll_locked_219 [ 0 +: 2]           =  {2{rc_pll_locked_219[0]}};
        assign  pll_locked_219 [ 2 +: 6]           =  {6{rc_pll_locked_219[1]}};
        assign  pll_locked_219 [ 8 +: 6]           =  {6{rc_pll_locked_219[2]}};
        assign  pll_locked_219 [14 +: 6]           =  {6{rc_pll_locked_219[3]}};
        assign  pll_locked_219 [20 +: 6]           =  {6{rc_pll_locked_219[4]}};
        
        
        // tie-off
        assign  pll_select[103:0]      =  {104{1'b0}};
        assign  tx_manual[CHANNELS-1:0]    =  {CHANNELS{1'b0}};
        
        // -----------------------
        // ATX PLLs
        // -----------------------
        
        for (gi    =  1; gi < ATXS; gi     =  gi + 1) begin : atxpll_sizing
                s5_atxpll425 s5_atxpll_425
                (. pll_powerdown      ( rc_pll_powerdown    [gi]                 ),     // input 
                        . pll_refclk         ( tx_pll_refclk_425   [gi]                 ),      // input [0:0]
                        . pll_fbclk          ( pll_clkout_425      [gi]                 ),      // input 
                        . pll_clkout         ( pll_clkout_425      [gi]                 ),      // output 
                        . pll_locked         ( rc_pll_locked_425   [gi]                 ),      // output 
                        . reconfig_to_xcvr   ( reconfig_to_xcvr    [gi + CHANNELS]      ),      // input [69:0]
                        . reconfig_from_xcvr ( reconfig_from_xcvr  [gi + CHANNELS]      )       // output [45:0]
                );
                
                s5_atxpll s5_atxpll_219
                (. pll_powerdown      ( rc_pll_powerdown    [gi + ATXS]                 ),      // input 
                        . pll_refclk         ( tx_pll_refclk_219   [gi]                 ),      // input [0:0]
                        . pll_fbclk          ( pll_clkout_219      [gi]                 ),      // input 
                        . pll_clkout         ( pll_clkout_219      [gi]                 ),      // output 
                        . pll_locked         ( rc_pll_locked_219   [gi]                 ),      // output 
                        . reconfig_to_xcvr   ( reconfig_to_xcvr    [gi + CHANNELS + ATXS]      ),       // input [69:0]
                        . reconfig_from_xcvr ( reconfig_from_xcvr  [gi + CHANNELS + ATXS]      )        // output [45:0]
                );
                
                
        end : atxpll_sizing
        
        
        assign  reconfig_mgmt_waitrequest  [2:1]       =  2'b0;
        assign  reconfig_mgmt_readdata     [1]         =  32'b0;
        assign  reconfig_mgmt_readdata     [2]         =  32'b0;
/*
//signaltap
wire [127:0] acq_data_in;
wire         acq_clk;

assign acq_clk = tx_pma_clk;
assign acq_data_in = {
//128
//112
//96
//90
rx_parallel_data[0][63:0],
//64
3'b000,
reconfig_busy,
reconfig_mgmt_read[0],
reconfig_mgmt_write[0],
reconfig_mgmt_waitrequest[0],
reconfig_mgmt_address[6:0],
mgmt_clk_clk,
mgmt_rst_reset,
//48
reconfig_mif_waitrequest,
rst_n,
tx_rst_n[0],
rx_rst_n[0],
rst,
tx_ready[0],
rx_ready[0],
pll_locked_219[0],
pll_locked_425[0],
pll_powerdown_219[0],
pll_powerdown_425[0],
rx_analogreset[0],
rx_digitalreset[0],
tx_analogreset[0],
tx_digitalreset[0],
rx_pma_clkout[0],
//32
1'b0,
tx_cal_busy[0],
rx_cal_busy[0],
tx_manual[0],
rx_is_lockedtodata[0],
mgmt_rst_reset,
rc_pll_locked_219[4:0],
rc_pll_locked_425[4:0],
//16
debug[0][15:0]
};

signaltap signaltap_inst (
  .acq_clk(acq_clk),
  .acq_data_in(acq_data_in),
  .acq_trigger_in(acq_data_in)
);
*/
end : native_phy
endgenerate
// -----------------------
// ROMs
// -----------------------

logic [2:0][15:0]                    rom_readdata;


//rom #(
//          . MIF_FILE                                           ( "rom4g.mif"                                        )
//  ) rom_inst2 (
rom rom_inst2 (
 . addra                    ( reconfig_mif_address[8:1]                          ), // input [7:0]
 . clka                  ( mgmt_clk_clk                                       ), // input
 . douta                 ( rom_readdata[ 0]                                   )  
);


//rom #(
//          . MIF_FILE                                           ( "rom8g.mif"                                        )
//  ) rom_inst1 (
rom rom_inst1 (
 . addra                    ( reconfig_mif_address[8:1]                          ), // input [7:0]
 . clka                  ( mgmt_clk_clk                                       ), // input
 . douta                 ( rom_readdata[ 1]                                   )  
);


//rom #(
//          . MIF_FILE                                           ( "rom16g.mif"                                       )
//  ) rom_inst0 (
rom rom_inst0 (
 . addra                    ( reconfig_mif_address[8:1]                          ), // input [7:0]
 . clka                  ( mgmt_clk_clk                                       ), // input
 . douta                 ( rom_readdata[ 2]                                   )  
);

logic reconfig_mif_read_d;
always @(posedge mgmt_clk_clk) 
if (mgmt_rst_reset) begin
        reconfig_mif_waitrequest <= 1'b1;
        reconfig_mif_read_d      <= 1'b0;
end
else begin
        reconfig_mif_read_d      <= reconfig_mif_read;
        reconfig_mif_waitrequest <= ~(reconfig_mif_read_d && reconfig_mif_read);
end
assign  reconfig_mif_readdata      =  rom_readdata[reconfig_mif_address[10:9]];





endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:
