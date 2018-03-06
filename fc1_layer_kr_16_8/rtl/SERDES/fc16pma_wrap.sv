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
***************************************************************************/
// auto_wire_reg ignore CHANNELS
module fc16pma_wrap #(
        parameter                            CHANNELS                          =  26,
        parameter                            LITE                              =  0,
        parameter                            SIM_ONLY                          =  0,
        parameter                            LOW_LATENCY_PHY                   =  0,
        parameter                            PHASE_COMP                        =  0,
        parameter                            DEBUG                             =  0 
) (
        input   [69:0] fc_reconfig_to_xcvr,
        output  [45:0] fc_reconfig_from_xcvr,
        
        // There are 24/16 FC channels, or 12/8 links.  An extra link (extra two channels) exists for the crosslink
        // between FPGAs.
        
        // --------------------------
        // Tx/Rx Interface
        // --------------------------
        
        input   logic [CHANNELS-1:0][63:0]           tx_parallel_data,                  //   tx parallel data to transceivers
        output  logic [CHANNELS-1:0][63:0]           rx_parallel_data,                  //   rx parallel data from transceivers
        output  [CHANNELS-1:0]                 tx_serial_data,                          //   per transceiver serial data to IOs
        input   [CHANNELS-1:0]                 rx_serial_data,                          //   per transceiver serial data to IOs
        output  [CHANNELS-1:0]                 tx_serial_data_n,                        //   per transceiver serial data to IOs
        input   [CHANNELS-1:0]                 rx_serial_data_n,                        //   per transceiver serial data to IOs
        input  logic [CHANNELS-1:0]                 iSFP_LOS,                           // fixme

        
        // --------------------------
        // Clocks and Reset
        // --------------------------
        input                                  iCLK_CORE_212,        
        input                                  iRST_FC_CORE212_N,        
        input   [1:0]                          ref_clk_219,                     //   per side, reference clock, 1 is right, 0 is left
        input   [1:0]                          ref_clk_425,                     //   per side, reference clock, 1 is right, 0 is left
        input   clk,                            //   core clock, 219Mhz
        input   mgmt_clk_clk,                   //   Avalon MM clock, half the speed of core clock
        input   mgmt_rst_reset,
        input   [CHANNELS-1:0]                 rx_rst_n,                        //   asynchronous reset
        input   [CHANNELS-1:0]                 tx_rst_n,                        //   asynchronous reset
        input   rst_n,                          //   asynchronous reset
        input   rst,                            //   asynchronous reset
        input   tx_pma_clk,
        output  [CHANNELS-1:0]                 rx_pma_clkout,                   //   rx recovered parallel clock
        output  [CHANNELS-1:0]                 tx_pma_clkout,                   //   tx parallel clock
        output  [CHANNELS-1:0]                 atx_pll_locked_425,              //   per channel PLL locked from ATX PLLs
        output  [CHANNELS-1:0]                 atx_pll_locked_219,              //   per channel PLL locked from ATX PLLs
        output  [CHANNELS-1:0]                 rx_ready,                        //   rx is ready
        //     output       [CHANNELS-1:0] 		 cdr_is_locked,                 //  per channel CDR locked
        
        // --------------------------
        // Reconfig Register Interface
        // --------------------------
        
        input   logic [63:0]                         iRECONFIG_MM_WR_DATA,
        input   logic [13:0]                         iRECONFIG_MM_ADDR,
        input   iRECONFIG_MM_WR_EN,
        input   iRECONFIG_MM_RD_EN,
        output  logic [63:0]                         oRECONFIG_MM_RD_DATA,
        output  oRECONFIG_MM_ACK,
        
        output  logic [31:0]                         min_linkspeed_reconfig,
        output  logic [31:0]                         max_linkspeed_reconfig,
        
        
        // --------------------------
        // Control Register Interface
        // --------------------------
        
        input   logic                                mif_retry,
        output  logic [CHANNELS/2-1:0][3:0]          status_data_rate,
        
        input   soft_mgmt_rst_reset,
        input   logic                                direct_access,
        input   fpga_ctl_rx_serdes_disable,
        input   fpga_ctl_tx_serdes_disable,
        output  logic [3:0]                          status_error,
        output  logic                                timeout_error,
        output  logic                                reconfig_busy,
        
        output  logic [25:0][15:0]                   debug,
        
        input   [3:0]                          oREG_LOOPBACKSERDESCFG_PRODUCT,
        input   [3:0]                          oREG_LOOPBACKSERDESCFG_REV,
        input   [3:0]                          oREG_LOOPBACKSERDESCFG_MODE,
        
        input   logic [CHANNELS-1:0]                 cfg_rx_slip_vec,
        
        input   logic [CHANNELS-1:0][3:0]            oLE_LINKSPEED,
        input   logic [CHANNELS-1:0][63:0]           oSERDES_MM_WR_DATA,
        input   logic [CHANNELS-1:0][13:0]           oSERDES_MM_ADDR,
        input   [CHANNELS-1:0]                 oSERDES_MM_WR_EN,
        input   [CHANNELS-1:0]                 oSERDES_MM_RD_EN,
        output  logic [CHANNELS-1:0][63:0]           iSERDES_MM_RD_DATA,
        output  [CHANNELS-1:0]                 iSERDES_MM_RD_DATA_V ,
        output  [CHANNELS-1:0][63:0]           rx_parallel_data_pma,                                   // fixme 8g parallel data
        input   [CHANNELS-1:0][63:0]           tx_parallel_data_pma,                                   // fixme 8g parallel data
				output  [CHANNELS-1:0] rx_is_lockedtodata
        
);

//`include "fc16pma_wrap_autoreg.vh"

// auto_wire_reg ignore rx_parallel_data
// auto_wire_reg ignore tx_parallel_data
// auto_wire_reg ignore iRECONFIG_MM_WR_DATA
// auto_wire_reg ignore iRECONFIG_MM_ADDR
// auto_wire_reg ignore iRECONFIG_MM_WR_EN
// auto_wire_reg ignore iRECONFIG_MM_RD_EN
// auto_wire_reg ignore oRECONFIG_MM_RD_DATA
// auto_wire_reg ignore reconfig_mgmt_address
// auto_wire_reg ignore reconfig_mgmt_waitrequest
// auto_wire_reg ignore reconfig_mgmt_read
// auto_wire_reg ignore reconfig_mgmt_readdata
// auto_wire_reg ignore reconfig_mgmt_write
// auto_wire_reg ignore reconfig_mgmt_writedata
// auto_wire_reg ignore mm_address;
// auto_wire_reg ignore mm_readdata;
// auto_wire_reg ignore mm_ack;
// auto_wire_reg ignore mm_read;
// auto_wire_reg ignore mm_write;
// auto_wire_reg ignore mm_writedata;


logic [8:0]                          reconfig_mgmt_address;
logic [2:0]                          reconfig_mgmt_waitrequest;
logic [2:0]                          reconfig_mgmt_read;
logic [2:0][31:0]                    reconfig_mgmt_readdata;
logic [2:0]                          reconfig_mgmt_write;
logic [31:0]                         reconfig_mgmt_writedata;
logic [25:0] 			cfg_tx_invert_vec, cfg_rx_invert_vec;
logic 				mm_waitrequest;
logic [CHANNELS/2-1:0][3:0] data_rate_pma;
logic [CHANNELS/2-1:0][3:0] data_rate_mgmtclk;

generate

// SERDES inversions - not applied during simulation
if (SIM_ONLY) begin : gen_cfg_invert
        assign  cfg_rx_invert_vec[25:0]    =  {26'b00_0000_0000_0000_0000_0000_0000};
        assign  cfg_tx_invert_vec[25:0]    =  {26'b00_0000_0000_0000_0000_0000_0000};
end

// SERDES inversions - in real hardware, based on board revision
else begin : gen_cfg_invert
        always @* begin
                casez({oREG_LOOPBACKSERDESCFG_PRODUCT[3:0], oREG_LOOPBACKSERDESCFG_REV[3:0], oREG_LOOPBACKSERDESCFG_MODE[3:0]})
                // Bali - rev A - external loopback
                12'h1_0_1 : begin
                        cfg_rx_invert_vec[25:0]    =  {26'b00_0000_0000_1111_1111_1111_1111};
                        cfg_tx_invert_vec[25:0]    =  {26'b00_0000_0000_1010_1010_0101_0101};
                end
                // Dominica - rev A - external loopback
                12'h2_0_1 : begin
                        cfg_rx_invert_vec[25:0]    =  {26'b00_1111_1110_1111_1111_1111_1111};
                        cfg_tx_invert_vec[25:0]    =  {26'b00_1010_1010_1010_1010_0101_0101};
                end
                // default 
                default : begin
                        cfg_rx_invert_vec[25:0]    =  {26'b00_0000_0000_0000_0000_0000_0000};
                        cfg_tx_invert_vec[25:0]    =  {26'b00_0000_0000_0000_0000_0000_0000};
                end
                endcase // casez ({oREG_LOOPBACKSERDESCFG_PRODUCT[3:0], oREG_LOOPBACKSERDESCFG_REV[3:0], oREG_LOOPBACKSERDESCFG_MODE[3:0]})
        end             // always @ *
end     // block: gen_cfg_invert

endgenerate

//pma #(
//        . SIM_ONLY (SIM_ONLY),
//        . LITE                                                 ( LITE                                               ),
//        . DEBUG                                                ( DEBUG                                              ),
//        . LOW_LATENCY_PHY                                      ( LOW_LATENCY_PHY                                    ),
//        . CHANNELS                                             ( CHANNELS                                           ),
//        . PHASE_COMP                                           ( PHASE_COMP                                         )
//) pma_inst (
//        .fc_reconfig_to_xcvr   (fc_reconfig_to_xcvr),
//        .fc_reconfig_from_xcvr (fc_reconfig_from_xcvr),
//        
//        . tx_pma_clkout			               ( tx_pma_clkout[CHANNELS-1:0]                        ),
//        . cfg_rx_slip_vec  		                       ( cfg_rx_slip_vec[CHANNELS-1:0]                      ),
//        
//        . ref_clk_425				               ( ref_clk_425[1:0]                                   ),
//        . ref_clk_219				               ( ref_clk_219[1:0]                                   ),
//        . pll_locked_425			               ( atx_pll_locked_425[CHANNELS-1:0]                   ),
//        . pll_locked_219			               ( atx_pll_locked_219[CHANNELS-1:0]                   ),
//        . iSFP_LOS                           ( iSFP_LOS[CHANNELS-1:0]                             ), // input [CHANNELS-1:0]
//				. rx_is_lockedtodata (rx_is_lockedtodata),
//        //. oLE_LINKSPEED                                      ( oLE_LINKSPEED/*[CHANNELS-1:0][3:0]*/               ), // input [CHANNELS-1:0][3:0]
//        //. fpga_ctl_force_rxdata_on_lossig_disable            ( fpga_ctl_force_rxdata_on_lossig_disable            ), // input
//        
//        . tx_parallel_data                                     ( tx_parallel_data       /*[CHANNELS-1:0][63:0]*/               ),       // input [CHANNELS-1:0][63:0]
//        . rx_parallel_data                                     ( rx_parallel_data       /*[CHANNELS-1:0][63:0]*/               ),       // output [CHANNELS-1:0][63:0]
//        . tx_serial_data                                       ( tx_serial_data[CHANNELS-1:0]                       ),  // output [CHANNELS-1:0]
//        . rx_serial_data                                       ( rx_serial_data[CHANNELS-1:0]                       ),  // input [CHANNELS-1:0]
//        . mgmt_clk_clk                                         ( mgmt_clk_clk                                       ),  // input
//        . mgmt_rst_reset                                       ( mgmt_rst_reset                                     ),  // input
//        . clk                                                  ( clk                                                ),  // input
//        . rst_n                                                ( rst_n                                              ),  // input
//        . rst                                                  ( rst                                                ),  // input
//        . tx_rst_n                                             ( tx_rst_n[CHANNELS-1:0]                             ),  // input [CHANNELS-1:0]
//        . rx_rst_n                                             ( rx_rst_n[CHANNELS-1:0]                             ),  // input [CHANNELS-1:0]
//        . rx_pma_clkout                                        ( rx_pma_clkout[CHANNELS-1:0]                        ),  // output [CHANNELS-1:0]
//        . tx_pma_clk                                           ( tx_pma_clk                                         ),  // input
//        . rx_ready                                             ( rx_ready[CHANNELS-1:0]                             ),  // output [CHANNELS-1:0]
//        . oSERDES_MM_WR_DATA                                   ( oSERDES_MM_WR_DATA             /*[CHANNELS-1:0][63:0]*/   ),   // input [CHANNELS-1:0][63:0]
//        . oSERDES_MM_ADDR                                      ( oSERDES_MM_ADDR                /*[CHANNELS-1:0][13:0]*/   ),   // input [CHANNELS-1:0][13:0]
//        . oSERDES_MM_WR_EN                                     ( oSERDES_MM_WR_EN[CHANNELS-1:0]                     ),  // input [CHANNELS-1:0]
//        . oSERDES_MM_RD_EN                                     ( oSERDES_MM_RD_EN[CHANNELS-1:0]                     ),  // input [CHANNELS-1:0]
//        . iSERDES_MM_RD_DATA                                   ( iSERDES_MM_RD_DATA             /*[CHANNELS-1:0][63:0]*/   ),   // output [CHANNELS-1:0][63:0]
//        . iSERDES_MM_RD_DATA_V                                 ( iSERDES_MM_RD_DATA_V[CHANNELS-1:0]                 ),  // output [CHANNELS-1:0]
//        . cfg_tx_invert_vec                                    ( cfg_tx_invert_vec[CHANNELS-1:0]                    ),  // input [CHANNELS-1:0]
//        . cfg_rx_invert_vec                                    ( cfg_rx_invert_vec[CHANNELS-1:0]                    ),  // input [CHANNELS-1:0]
//        . fpga_ctl_rx_serdes_disable                           ( fpga_ctl_rx_serdes_disable                         ),  // input
//        . fpga_ctl_tx_serdes_disable                           ( fpga_ctl_tx_serdes_disable                         ),  // input
//        . debug                                                ( debug          /*[25:0][15:0]*/                           ),   // output [25:0][15:0]
//        . reconfig_mgmt_address                                ( reconfig_mgmt_address[8:0]                         ),  // input [8:0]
//        . reconfig_mgmt_read                                   ( reconfig_mgmt_read[2:0]                            ),  // input [2:0]
//        . reconfig_mgmt_write                                  ( reconfig_mgmt_write[2:0]                           ),  // input [2:0]
//        . reconfig_mgmt_writedata                              ( reconfig_mgmt_writedata[31:0]                      ),  // input [31:0]
//        . reconfig_mgmt_readdata                               ( reconfig_mgmt_readdata         /*[2:0][31:0]*/            ),   // output [2:0][31:0]
//        . reconfig_mgmt_waitrequest                            ( reconfig_mgmt_waitrequest[2:0]                     ),  // output [2:0]
//        . reconfig_busy                                        ( reconfig_busy                                      ),   // output
//        . rx_parallel_data_pma(rx_parallel_data_pma),
//        . tx_parallel_data_pma(tx_parallel_data_pma),
//				. data_rate (data_rate_pma)
//
//);
logic [1663 : 0] gtwiz_userdata_tx_in;
logic [1663 : 0] gtwiz_userdata_rx_out;
  wire [6 : 0] qpll0outclk_out;
  wire [6 : 0] qpll0outrefclk_out;
  wire gtwiz_reset_rx_cdr_stable_out;
  wire gtwiz_reset_tx_done_out;
  wire gtwiz_reset_rx_done_out;
  logic [0 : 0] gtwiz_userclk_tx_active_in = 1'b1;
  logic [0 : 0] gtwiz_userclk_rx_active_in = 1'b1;

logic [CHANNELS-1:0]                pll_powerdown;
logic [CHANNELS-1:0]                tx_digitalreset;
logic [CHANNELS-1:0]                tx_analogreset;
logic [CHANNELS-1:0]                rx_digitalreset;
logic [CHANNELS-1:0]                rx_analogreset;
logic [CHANNELS-1:0]                rx_is_lockedtoref;
//logic [CHANNELS-1:0]                rx_is_lockedtodata;
logic [CHANNELS-1:0]                tx_cal_busy;
logic [CHANNELS-1:0]                rx_cal_busy;
logic [CHANNELS-1:0]                tx_ready;
logic [CHANNELS-1:0] [2:0]          data_rate;
logic [CHANNELS-1:0]                pll_locked_219;
logic [CHANNELS-1:0]                pll_locked_425;
logic [CHANNELS-1:0] [39:0]         bist_data;
logic [CHANNELS-1:0] [39:0]         tx_pma_parallel_data_q;
logic [CHANNELS-1:0] [15:0]         prbs_error_cnt;
logic [CHANNELS-1:0] [47:0]         prbs_bit_cnt;
logic [CHANNELS-1:0] [31:0]         prbs_not_locked_cnt;
logic [CHANNELS-1:0]                prbs_lock_state;
logic [CHANNELS-1:0] [15:0]         prbs_inj_err_cnt;

wire [CHANNELS-1:0]                oREG_CTL_TXRESET;
wire [CHANNELS-1:0]                oREG_CTL_RXRESET;
wire [CHANNELS-1:0]                oREG_CTL_SERIALLPBKEN;
wire [CHANNELS-1:0] [1:0]          oREG_CTL_CDRLOCKMODE;
wire [CHANNELS-1:0]                oREG_CTL_TXMUXSEL;
wire [CHANNELS-1:0]                oREG_CTL_EYEHCLEAR;
wire [CHANNELS-1:0]                oREG_CTL_EYEVCLEAR;
wire [CHANNELS-1:0]                oREG_CTL_TXINVERT;
wire [CHANNELS-1:0]                oREG_CTL_RXINVERT;
wire [CHANNELS-1:0]                oREG_CTL_CDRLOCKOVERRIDE                           ;
wire [CHANNELS-1:0] [1:0]          oREG_PRBSCTL_PRBSSEL;
wire [CHANNELS-1:0]                oREG_PRBSCTL_INJERR;
wire [CHANNELS-1:0]                oREG_PRBSCTL_ERRCNTCLR;
wire [CHANNELS-1:0]                oREG_PRBSCTL_RXCNTCLR;
wire [CHANNELS-1:0]                oREG_PRBSCTL_NOTLOCKEDCNTCLR;
wire [CHANNELS-1:0] [63:0]         oREG_SCRATCH;

logic  [25 : 0] rxoutclk_out;
logic  [25 : 0] txoutclk_out;
logic  [25 : 0] rxusrclk2_in;
logic  [25 : 0] txusrclk2_in;
logic  [25 : 0] rxusrclk_in;
logic  [25 : 0] txusrclk_in;
//logic gtwiz_reset_rx_cdr_stable_out;  // fixme
//logic gtwiz_reset_tx_done_out;  // fixme
//logic gtwiz_reset_rx_done_out;  // fixme
logic           userclk_tx_reset_in;
logic           userclk_rx_reset_in;
assign userclk_tx_reset_in = !gtwiz_reset_tx_done_out;
assign userclk_rx_reset_in = !gtwiz_reset_rx_done_out;

genvar                      gi;
generate
  for (gi    =  0; gi < CHANNELS; gi   =  gi+1) begin : pma_gen
    assign         pll_powerdown[gi] = 0;
    assign         tx_digitalreset[gi] = 0;
    assign         tx_analogreset[gi] = 0;
    assign         rx_digitalreset[gi] = 0;
    assign         rx_analogreset[gi] = 0;
    assign         rx_is_lockedtoref[gi] = 0;
    assign         rx_is_lockedtodata[gi] = 1;
    assign         tx_cal_busy[gi] = 0;
    assign         rx_cal_busy[gi] = 0;
    assign         rx_ready[gi] = 1;
    assign         tx_ready[gi] = 1;
    assign         data_rate[gi] = 0;
    assign         pll_locked_219[gi] = 1;
    assign         pll_locked_425[gi] = 1;
    assign         bist_data[gi] = 0;
    assign         tx_pma_parallel_data_q[gi] = 0;
    assign         prbs_error_cnt[gi] = 0;
    assign         prbs_bit_cnt[gi] = 0;
    assign         prbs_not_locked_cnt[gi] = 0;
    assign         prbs_lock_state[gi] = 0;
    assign         prbs_inj_err_cnt[gi] = 0;
    pma_1ch_regs #(
      . LITE                                               ( 0                                                  )
    ) pma_1ch_regs_inst (
      . clk                                                ( {26{iCLK_CORE_212}}                                 ), // input
      . rst_n                                              ( {26{iRST_FC_CORE212_N}}                             ), // input
      . wr_en                                              ( oSERDES_MM_WR_EN                             [gi]   ), // input
      . rd_en                                              ( oSERDES_MM_RD_EN                             [gi]   ), // input
      . addr                                               ( oSERDES_MM_ADDR[gi][9:0]                            ), // input [9:0]
      . wr_data                                            ( oSERDES_MM_WR_DATA                           [gi]   ), // input [63:0]
      . rd_data                                            ( iSERDES_MM_RD_DATA[gi][63:0]                        ), // output [63:0]
      . rd_data_v                                          ( iSERDES_MM_RD_DATA_V                         [gi]   ), // output
    
      . oREG_CTL_TXRESET                                   ( oREG_CTL_TXRESET                             [gi]   ), // output
      . oREG_CTL_RXRESET                                   ( oREG_CTL_RXRESET                             [gi]   ), // output
      . oREG_CTL_SERIALLPBKEN                              ( oREG_CTL_SERIALLPBKEN                        [gi]   ), // output
      . oREG_CTL_CDRLOCKMODE                               ( oREG_CTL_CDRLOCKMODE[gi][1:0]                       ), // output [1:0]
      . oREG_CTL_TXMUXSEL                                  ( oREG_CTL_TXMUXSEL                            [gi]   ), // output
      . oREG_CTL_EYEHCLEAR                                 ( oREG_CTL_EYEHCLEAR                           [gi]   ), // output
      . oREG_CTL_EYEVCLEAR                                 ( oREG_CTL_EYEVCLEAR                           [gi]   ), // output
      . oREG_CTL_TXINVERT                                  ( oREG_CTL_TXINVERT                            [gi]   ), // output
      . oREG_CTL_RXINVERT                                  ( oREG_CTL_RXINVERT                            [gi]   ), // output
      . oREG_CTL_CDRLOCKOVERRIDE                           ( oREG_CTL_CDRLOCKOVERRIDE                     [gi]   ), // output
      . oREG_PRBSCTL_PRBSSEL                               ( oREG_PRBSCTL_PRBSSEL[gi][1:0]                       ), // output [1:0]
      . oREG_PRBSCTL_INJERR                                ( oREG_PRBSCTL_INJERR                          [gi]   ), // output
      . oREG_PRBSCTL_ERRCNTCLR                             ( oREG_PRBSCTL_ERRCNTCLR                       [gi]   ), // output
      . oREG_PRBSCTL_RXCNTCLR                              ( oREG_PRBSCTL_RXCNTCLR                        [gi]   ), // output
      . oREG_PRBSCTL_NOTLOCKEDCNTCLR                       ( oREG_PRBSCTL_NOTLOCKEDCNTCLR                 [gi]   ), // output
      . oREG__SCRATCH                                      ( oREG_SCRATCH[gi][63:0]                              ), // output [63:0]
    
      . iREG_STATUS_PLLPWRDN                               ( pll_powerdown                                [gi]   ), // input
      . iREG_STATUS_TXDIGITALRST                           ( tx_digitalreset                              [gi]   ), // input
      . iREG_STATUS_TXANALOGRST                            ( tx_analogreset                               [gi]   ), // input
      . iREG_STATUS_RXDIGITALRST                           ( rx_digitalreset                              [gi]   ), // input
      . iREG_STATUS_RXANALOGRST                            ( rx_analogreset                               [gi]   ), // input
      . iREG_STATUS_RXLOCKEDTOREF                          ( rx_is_lockedtoref                            [gi]   ), // input
      . iREG_STATUS_RXLOCKEDTODATA                         ( rx_is_lockedtodata                           [gi]   ), // input
      . iREG_STATUS_TXCALBUSY                              ( tx_cal_busy                                  [gi]   ), // input
      . iREG_STATUS_RXCALBUSY                              ( rx_cal_busy                                  [gi]   ), // input
      . iREG_STATUS_RXREADY                                ( rx_ready                                     [gi]   ), // input
      . iREG_STATUS_TXREADY                                ( tx_ready                                     [gi]   ), // input
      . iREG_STATUS_LINKSPEED                              ( data_rate                                    [gi]   ), // input [2:0]
      . iREG_STATUS_PLLLOCKED_219                          ( pll_locked_219                               [gi]   ), // input
      . iREG_STATUS_PLLLOCKED_425                          ( pll_locked_425                               [gi]   ), // input
      . iREG_RXDATA                                        ( bist_data[gi][39:0]                                 ), // input [39:0]
      . iREG_TXDATA                                        ( tx_pma_parallel_data_q[gi][39:0]                    ), // input [39:0]
      . iREG_PRBSERRCNT                                    ( prbs_error_cnt[gi][15:0]                            ), // input [15:0]
      . iREG_PRBSRXCNT                                     ( prbs_bit_cnt[gi][47:0]                              ), // input [47:0]
      . iREG_PRBSNOTLOCKEDCNT                              ( prbs_not_locked_cnt[gi][31:0]                       ), // input [31:0]
      . iREG_PRBSLOCK                                      ( prbs_lock_state                              [gi]   ), // input
      . iREG_PRBSINJERRCNT                                 ( prbs_inj_err_cnt[gi][15:0]                          )  // input [15:0]
    );

        assign gtwiz_userdata_tx_in[gi*64 +: 64] = tx_parallel_data[gi];                  //   tx parallel data to transceivers
        assign rx_parallel_data[gi]              = gtwiz_userdata_rx_out[gi*64 +: 64];    //   rx parallel data from transceivers

        assign atx_pll_locked_425[gi] = 1'b1;              //   per channel PLL locked from ATX PLLs fixme
        assign atx_pll_locked_219[gi] = 1'b1;              //   per channel PLL locked from ATX PLLs fixme
  end
endgenerate
generate
  for (gi    =  0; gi < 24; gi   =  gi+1) begin : bufg_gen
BUFG_GT txusrclk2_bufg_inst   (.I (txoutclk_out[gi] ), .CE (1'b1     ), .O   (txusrclk2_in[gi]), .CLR(userclk_tx_reset_in));
//BUFG_GT txusrclk_bufg_inst    (.I (txoutclk_out[gi] ), .CE (1'b1     ), .DIV (3'b001  ), .O (txusrclk_in[gi]  ), .CLR(userclk_tx_reset_in));
BUFG_GT rxusrclk2_bufg_inst   (.I (rxoutclk_out[gi] ), .CE (1'b1     ), .O   (rxusrclk2_in[gi]), .CLR(userclk_rx_reset_in));
//BUFG_GT rxusrclk_bufg_inst    (.I (rxoutclk_out[gi] ), .CE (1'b1     ), .DIV (3'b001  ), .O (rxusrclk_in[gi]  ), .CLR(userclk_rx_reset_in));

  end
endgenerate

//assign tx_pma_clkout = txoutclk_out;
//assign rx_pma_clkout = rxoutclk_out;
assign txusrclk_in[0 +: 24]=txusrclk2_in[0 +: 24];
assign rxusrclk_in[0 +: 24]=rxusrclk2_in[0 +: 24];
assign tx_pma_clkout = {2'b0,txusrclk_in[0 +: 24]};
assign rx_pma_clkout = {2'b0,rxusrclk_in[0 +: 24]};

s5_native_phy_16gbps s5_native_phy_16gbps ( 
  .gtwiz_userclk_tx_active_in( gtwiz_userclk_tx_active_in                         ),                  // input wire [0 : 0] gtwiz_userclk_tx_active_in
  .gtwiz_userclk_rx_active_in( gtwiz_userclk_rx_active_in                         ),                  // input wire [0 : 0] gtwiz_userclk_rx_active_in
  .gtwiz_reset_clk_freerun_in( mgmt_clk_clk                                       ),                  // input wire [0 : 0] gtwiz_reset_clk_freerun_in
  .gtwiz_reset_all_in( rst                                                ),                                  // input wire [0 : 0] gtwiz_reset_all_in
  .gtwiz_reset_tx_pll_and_datapath_in( !tx_rst_n                                          ),  // input wire [0 : 0] gtwiz_reset_tx_pll_and_datapath_in
  .gtwiz_reset_tx_datapath_in( !tx_rst_n                                          ),                  // input wire [0 : 0] gtwiz_reset_tx_datapath_in
  .gtwiz_reset_rx_pll_and_datapath_in( !rx_rst_n                                          ),  // input wire [0 : 0] gtwiz_reset_rx_pll_and_datapath_in
  .gtwiz_reset_rx_datapath_in( !rx_rst_n                                          ),                  // input wire [0 : 0] gtwiz_reset_rx_datapath_in
  .gtwiz_reset_rx_cdr_stable_out( gtwiz_reset_rx_cdr_stable_out                      ),            // output wire [0 : 0] gtwiz_reset_rx_cdr_stable_out
  .gtwiz_reset_tx_done_out( gtwiz_reset_tx_done_out                            ),                        // output wire [0 : 0] gtwiz_reset_tx_done_out
  .gtwiz_reset_rx_done_out( gtwiz_reset_rx_done_out                            ),                        // output wire [0 : 0] gtwiz_reset_rx_done_out
  .gtwiz_userdata_tx_in( gtwiz_userdata_tx_in [1535 : 0]                              ),                              // input wire [1535 : 0] gtwiz_userdata_tx_in
  .gtwiz_userdata_rx_out( gtwiz_userdata_rx_out [1535 : 0]                             ),                            // output wire [1535 : 0] gtwiz_userdata_rx_out
  .gtrefclk00_in( {{3{ref_clk_425[1]}},{3{ref_clk_425[0]}}}          ),                                            // input wire [5 : 0] gtrefclk00_in
  .qpll0outclk_out( qpll0outclk_out                                    ),                                        // output wire [5 : 0] qpll0outclk_out
  .qpll0outrefclk_out( qpll0outrefclk_out                                 ),                                  // output wire [5 : 0] qpll0outrefclk_out
  .gtyrxn_in( rx_serial_data_n                                   ),                                                    // input wire [23 : 0] gtyrxn_in
  .gtyrxp_in( rx_serial_data                                     ),                                                    // input wire [23 : 0] gtyrxp_in
  .rxusrclk_in( rxusrclk_in                                        ),                                                // input wire [23 : 0] rxusrclk_in
  .rxusrclk2_in( rxusrclk2_in                                       ),                                              // input wire [23 : 0] rxusrclk2_in
  .txusrclk_in( txusrclk_in                                        ),                                                // input wire [23 : 0] txusrclk_in
  .txusrclk2_in( txusrclk2_in                                       ),                                              // input wire [23 : 0] txusrclk2_in
  .gtpowergood_out( gtpowergood_out                                    ),                                        // output wire [23 : 0] gtpowergood_out
  .gtytxn_out( tx_serial_data_n                                   ),                                                  // output wire [23 : 0] gtytxn_out
  .gtytxp_out( tx_serial_data                                     ),                                                  // output wire [23 : 0] gtytxp_out
  .rxoutclk_out( rxoutclk_out                                       ),                                              // output wire [23 : 0] rxoutclk_out
  .rxpmaresetdone_out(rxpmaresetdone_out),                                  // output wire [23 : 0] rxpmaresetdone_out
  .txoutclk_out( txoutclk_out                                       ),                                              // output wire [23 : 0] txoutclk_out
  .txpmaresetdone_out( txpmaresetdone_out                                 )                                  // output wire [23 : 0] txpmaresetdone_out
);
assign gtwiz_userdata_rx_out[1536 +: 128]=128'b0;
/*
s5_native_phy_16gbps s5_native_phy_16gbps (
  .gtwiz_userdata_tx_in(gtwiz_userdata_tx_in),                              // input wire [1663 : 0] gtwiz_userdata_tx_in
  .gtwiz_userdata_rx_out(gtwiz_userdata_rx_out),                            // output wire [1663 : 0] gtwiz_userdata_rx_out

  .gthrxn_in(rx_serial_data_n),                                                    // input wire [25 : 0] gthrxn_in
  .gthrxp_in(rx_serial_data),                                                    // input wire [25 : 0] gthrxp_in
  .gthtxn_out(tx_serial_data_n),                                                  // output wire [25 : 0] gthtxn_out
  .gthtxp_out(tx_serial_data),                                                  // output wire [25 : 0] gthtxp_out

  //.rxoutclk_out(rx_pma_clkout),                                              // output wire [25 : 0] rxoutclk_out
  //.txoutclk_out(tx_pma_clkout),                                              // output wire [25 : 0] txoutclk_out
  .rxoutclk_out(rxoutclk_out),                                              // output wire [25 : 0] rxoutclk_out
  .txoutclk_out(txoutclk_out),                                              // output wire [25 : 0] txoutclk_out
  .rxusrclk2_in(rxusrclk2_in),                                              // input wire [25 : 0] rxusrclk2_in
  .txusrclk2_in(txusrclk2_in),                                              // input wire [25 : 0] txusrclk2_in
  .rxusrclk_in(rxusrclk_in),                                                // input wire [25 : 0] rxusrclk_in
  .txusrclk_in(txusrclk_in),                                                // input wire [25 : 0] txusrclk_in

  .gtwiz_reset_clk_freerun_in(mgmt_clk_clk),                  // input wire [0 : 0] gtwiz_reset_clk_freerun_in free running clock
  .gtwiz_reset_all_in(rst),                                  // input wire [0 : 0] gtwiz_reset_all_in fixme
  .gtwiz_reset_tx_pll_and_datapath_in(!tx_rst_n),  // input wire [0 : 0] gtwiz_reset_tx_pll_and_datapath_in fixme
  .gtwiz_reset_tx_datapath_in(!tx_rst_n),                  // input wire [0 : 0] gtwiz_reset_tx_datapath_in fixme
  .gtwiz_reset_rx_pll_and_datapath_in(!rx_rst_n),  // input wire [0 : 0] gtwiz_reset_rx_pll_and_datapath_in fixme
  .gtwiz_reset_rx_datapath_in(!rx_rst_n),                  // input wire [0 : 0] gtwiz_reset_rx_datapath_in fixme

  .gtwiz_reset_rx_cdr_stable_out(gtwiz_reset_rx_cdr_stable_out),            // output wire [0 : 0] gtwiz_reset_rx_cdr_stable_out
  .gtwiz_reset_tx_done_out(gtwiz_reset_tx_done_out),                        // output wire [0 : 0] gtwiz_reset_tx_done_out
  .gtwiz_reset_rx_done_out(gtwiz_reset_rx_done_out),                        // output wire [0 : 0] gtwiz_reset_rx_done_out

  .gtpowergood_out(gtpowergood_out),                                        // output wire [25 : 0] gtpowergood_out
  .txpmaresetdone_out(txpmaresetdone_out),                                 // output wire [25 : 0] txpmaresetdone_out

  .gtwiz_userclk_tx_active_in(gtwiz_userclk_tx_active_in),                  // input wire [0 : 0] gtwiz_userclk_tx_active_in
  .gtwiz_userclk_rx_active_in(gtwiz_userclk_rx_active_in),                  // input wire [0 : 0] gtwiz_userclk_rx_active_in
  .gtrefclk00_in({{3{ref_clk_425[0]}},{4{ref_clk_425[1]}}}),                // input wire [6 : 0] gtrefclk00_in
  //.gtrefclk00_in({{3{ref_clk_219[0]}},{4{ref_clk_219[1]}}}),                // input wire [6 : 0] gtrefclk00_in
//  .gtrefclk00_in({
//{2{ref_clk_219[0]}},{2{ref_clk_219[1]}},
//{2{ref_clk_425[0]}},{1{ref_clk_425[1]}}
//}),                // input wire [6 : 0] gtrefclk00_in
  //.gtrefclk00_in({7{ref_clk_425[0]}}),                                    // input wire [6 : 0] gtrefclk00_in
  .qpll0outclk_out(qpll0outclk_out),                                        // output wire [6 : 0] qpll0outclk_out
  .qpll0outrefclk_out(qpll0outrefclk_out)                                   // output wire [6 : 0] qpll0outrefclk_out
);
*/


//genvar                      gi;
generate
for (gi    =  0; gi < CHANNELS/2; gi   =  gi+1) begin : datarate_gen

vi_sync_pp #(4) status_linkspeed_sync_pma (
.clkb(tx_pma_clk),
.clka(iCLK_CORE_212),
.rstb_n(rst_n),
.rsta_n(iRST_FC_CORE212_N),
.in_bus(oLE_LINKSPEED[gi*2]),
.out_bus(data_rate_pma[gi])
  );

vi_sync_pp #(4) status_linkspeed_sync_mgmt (
.clkb(mgmt_clk_clk),
.clka(iCLK_CORE_212),
.rstb_n(~mgmt_rst_reset),
.rsta_n(iRST_FC_CORE212_N),
.in_bus(oLE_LINKSPEED[gi*2]),
.out_bus(data_rate_mgmtclk[gi])
  );



end
endgenerate


logic [10:0]                         mm_address;
logic [31:0]                         mm_readdata;
logic                                mm_read;
logic                                mm_write;
logic [31:0]                         mm_writedata;

assign  oRECONFIG_MM_RD_DATA [0 +: 64] =  {32'b0,mm_readdata};
assign  mm_address           [0 +: 11] =  iRECONFIG_MM_ADDR[0 +: 11];
assign  mm_writedata         [0 +: 32] =  iRECONFIG_MM_WR_DATA[0 +: 32];


dynamicReconfig #(
  . LINKS                                              ( CHANNELS/2                                         ),
  . AVALON                                             ( 0                                                  )
) dynamicReconfig_inst (
  . clk                                                ( mgmt_clk_clk                                       ), // input
  . reset                                              ( mgmt_rst_reset                                     ), // input
  . soft_reset                                         ( soft_mgmt_rst_reset                                ), // input
  . mif_retry                                          ( mif_retry                                          ), // input
  . direct_access                                      ( direct_access                                      ), // input
  . data_rate                                          ( data_rate_mgmtclk                                  ), // input [LINKS-1:0][1:0]
  . status_data_rate                                   ( status_data_rate                                   ), // output [LINKS-1:0][3:0]
  . status_error                                       ( status_error                                       ), // output [3:0]
  . timeout_error                                      ( timeout_error                                      ), // output
  . min_linkspeed_reconfig                             ( min_linkspeed_reconfig                             ), // output [31:0]
  . max_linkspeed_reconfig                             ( max_linkspeed_reconfig                             ), // output [31:0]
  . mm_address                                         ( mm_address                                         ), // input [10:0]
  . mm_readdata                                        ( mm_readdata                                        ), // output [31:0]
  . mm_ack                                             ( oRECONFIG_MM_ACK                                   ), // output
  . mm_waitrequest                                     ( mm_waitrequest                                     ), // output
  . mm_read                                            ( iRECONFIG_MM_RD_EN                                 ), // input
  . mm_write                                           ( iRECONFIG_MM_WR_EN                                 ), // input
  . mm_writedata                                       ( mm_writedata                                       ), // input [31:0]
  . reconfig_mgmt_address                              ( reconfig_mgmt_address                              ), // output [8:0]
  . reconfig_mgmt_waitrequest                          ( reconfig_mgmt_waitrequest                          ), // input [2:0]
  . reconfig_busy                                      ( reconfig_busy                                      ), // input
  . reconfig_mgmt_read                                 ( reconfig_mgmt_read                                 ), // output [2:0]
  . reconfig_mgmt_readdata                             ( reconfig_mgmt_readdata                             ), // input [2:0][31:0]
  . reconfig_mgmt_write                                ( reconfig_mgmt_write                                ), // output [2:0]
  . reconfig_mgmt_writedata                            ( reconfig_mgmt_writedata                            )  // output [31:0]
);
/*
//signaltap
wire [127:0] acq_data_in;
wire         acq_clk;

assign acq_clk = mgmt_clk_clk;
assign acq_data_in = {
//128
//112
//96
//80
4'h0,
rx_rst_n[25:0],
tx_rst_n[25:0],
//72
2'b00,
fpga_ctl_tx_serdes_disable,
fpga_ctl_rx_serdes_disable,
reconfig_mgmt_read,
reconfig_mgmt_write,
reconfig_busy,
reconfig_mgmt_waitrequest,
//64
//48
mm_writedata[31:0],
//32
5'h0,
mm_address[10:0],
//16
mm_readdata[7:0],
//8
iRECONFIG_MM_RD_EN,
iRECONFIG_MM_WR_EN,
mm_waitrequest,
timeout_error,
status_error,
direct_access,
soft_mgmt_rst_reset,
mgmt_rst_reset
};

signaltap signaltap_inst (
  .acq_clk(acq_clk),
  .acq_data_in(acq_data_in),
  .acq_trigger_in(acq_data_in)
);

*/
endmodule       // fc16pma_wrap

// Local Variables:
// verilog-library-directories:("." "../../pma/rtl/")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:   
