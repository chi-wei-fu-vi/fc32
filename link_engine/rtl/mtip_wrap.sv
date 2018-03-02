module mtip_wrap (
  // Reset and Clocks
  input  logic                                iCLK_100M,
  input  logic                                iCLK_FC_CORE,
  input  logic                                iCLK_FC_RX,
  input  logic                                iCLK_FC_TX,

  input  logic                                iRST_100M_N,
  input  logic                                iRST_FC_CORE_N,
  input  logic                                iRST_FC_RX_N,
  input  logic                                iRST_FC_TX_N,
  input  logic                                iRST_LINK_ENGINE_RX_N,

  // Global
  input  logic [55:0]                         iGLOBAL_TIMESTAMP,

  // Interval Stats pkg if
  input  logic                                iINT_STATS_LATCH_CLR,
  output wire  [31:0]                         oINT_STATS_BADEOF,
  output wire  [31:0]                         oINT_STATS_FC_CODE,
  output wire  [31:0]                         oINT_STATS_FC_CRC,
  output wire  [31:0]                         oINT_STATS_LINK_UP,
  output wire  [31:0]                         oINT_STATS_LIP,
  output wire  [31:0]                         oINT_STATS_LOSIG,
  output wire  [31:0]                         oINT_STATS_LOSYNC,
  output wire  [31:0]                         oINT_STATS_LR_LRR,
  output wire  [31:0]                         oINT_STATS_NOS_OLS,
  output wire  [31:0]                         oINT_STATS_TRUNC,
  output wire                                 oINT_STATS_LOSIG_LATCH,
  output wire                                 oINT_STATS_LOSYNC_LATCH,
  output wire                                 oINT_STATS_LR_LRR_LATCH,
  output wire                                 oINT_STATS_NOS_LOS_LATCH,
  output wire                                 oINT_STATS_UP_LATCH,

  // Stats Clear Synchronization
  input  logic                                iSTATS_LATCH_CLR_RXCLK,

  // Serdes
  input  logic [39:0]                         iRX_PHY_DATA,

  // Time Arbiter if
  input  logic                                iTA_OFF_FILL_DONE,
  output wire  [107:0]                        oMIF_DAT_FUTURE_TS,
  output wire                                 oMIF_DAT_FTS_VALID,
  output wire                                 oMIF_LOSIG,
  output wire                                 oMIF_LOSYNC,
  output wire                                 oMIF_OFF_FILL_REQ,

  // Credit Stats
  output  logic [11:0]                        oRX_PRIMITIVE,
  output wire                                 oRX_CLASS_VAL,
  output wire                                 oLINK_UP_EVENT,

  // uC Stats
  input  logic [3:0]                          iREG_LINKCTRL_MONITORMODE,
  input  logic                                iREG_LINKCTRL_SCRMENBL,
  input  logic                                iREG_LINKCTRL_WR_EN,
  input  logic                                iSFP_PHY_LOSIG,
  input  logic                                iINTERVAL_ANY_LINK,

  // Extractor if
  input  logic                                EXTR_MIF_TS_FIFO_POP,
  input  logic                                EXTR_REG_EXTRENABLE,

  output wire  [63:0]                         MIF_EXTR_DATA,
  output wire  [2:0]                          MIF_EXTR_EMPTY,
  output wire                                 MIF_EXTR_SOP,
  output wire                                 MIF_EXTR_EOP,
  output wire                                 MIF_EXTR_ERR,
  output wire                                 MIF_EXTR_VALID,
  output wire  [2:0]                          MIF_EXTR_INDEX,
  output wire  [107:0]                        MIF_EXTR_FUTURE_TS,
  output wire                                 MIF_EXTR_EXTRENABLE,

  // Memory map interface
  input  logic [13:0]                         MTIP_FC1_ADDR,
  output wire                                 MTIP_FC1_RD_DATA_V,
  output wire  [63:0]                         MTIP_FC1_RD_DATA,
  input  logic                                MTIP_FC1_RD_EN,
  input  logic [63:0]                         MTIP_FC1_WR_DATA,
  input  logic                                MTIP_FC1_WR_EN,
  input  logic [13:0]                         MTIP_FC2_ADDR,
  output wire                                 MTIP_FC2_RD_DATA_V,
  output wire  [63:0]                         MTIP_FC2_RD_DATA,
  input  logic                                MTIP_FC2_RD_EN,
  input  logic [63:0]                         MTIP_FC2_WR_DATA,
  input  logic                                MTIP_FC2_WR_EN,
  input  logic [13:0]                         mtip_mm_addr,
  output wire                                 mtip_mm_rd_data_v,
  output wire  [63:0]                         mtip_mm_rd_data,
  input  logic                                mtip_mm_rd_en,
  input  logic [63:0]                         mtip_mm_wr_data,
  input  logic                                mtip_mm_wr_en 
);



  wire   [7:0]                          ff_rx_err_stat;
  wire                                  led_link_online;
  wire                                  led_link_sync;
  wire   [63:0]                         mtip_debug;
  wire   [9:0]                          mtip_reg_addr;
  wire                                  mtip_reg_busy;
  wire   [31:0]                         mtip_reg_data_in;
  wire   [31:0]                         mtip_reg_data_out;
  wire                                  mtip_reg_rd;
  wire                                  mtip_reg_wr;
  wire                                  rx_char_err;
  wire                                  rx_disp_err;
  wire   [31:0]                         rx_fc1_data;
  wire                                  rx_fc1_err;
  wire                                  rx_fc1_kchn;

// not used
  wire                                  rx_end_code_val;
  wire   [3:0]                          rx_end_code;
  wire   [3:0]                          rx_class;
  wire   [39:0]                         rx_align_data;
  wire                                  ff_rx_dsav;
  wire   [3:0]                          ff_rx_class;
  wire   [15:0]                         current_credit;
  wire                                  sd_loopback;
  wire   [39:0]                         tx_phy_data;

  wire   [1:0]                          ff_rx_mod;
  wire   [31:0]                         ff_rx_data;
  wire                                  ff_rx_sop;
  wire                                  ff_rx_eop;
  wire                                  ff_rx_dval;
  wire                                  ff_rx_err;

mtip_no_reg mtip_no_reg_inst (
  // received local clock
  . ff_rx_clk                                          ( iCLK_FC_CORE                                       ), // input
  // frame modulo
  . ff_rx_mod                                          ( ff_rx_mod[1:0]                                     ), // output [1:0]
  // frame class
  . ff_rx_class                                        ( ff_rx_class[3:0]                                   ), // output [3:0]
  // errored packet status word
  . ff_rx_err_stat                                     ( ff_rx_err_stat[7:0]                                ), // output [7:0]
  // application ready
  . ff_rx_rdy                                          ( 1'b1                                               ), // input
  // data available in receive fifo
  . ff_rx_dsav                                         ( ff_rx_dsav                                         ), // output

  // not used
  . ff_rx_data                                         ( ff_rx_data[31:0]                                   ), // output [31:0]
  . ff_rx_sop                                          ( ff_rx_sop                                          ), // output
  . ff_rx_eop                                          ( ff_rx_eop                                          ), // output
  . ff_rx_dval                                         ( ff_rx_dval                                         ), // output
  . ff_rx_err                                          ( ff_rx_err                                          ), // output


  // debug
  . mtip_debug                                         ( mtip_debug[63:0]                                   ), // output [63:0]

  // resets
  . reset_rx_clk                                       ( ~iRST_LINK_ENGINE_RX_N                             ), // input
  . reset_tx_clk                                       ( ~iRST_FC_TX_N                                      ), // input
  . reset_reg_clk                                      ( ~iRST_100M_N                                       ), // input
  . reset_ff_rx_clk                                    ( ~iRST_FC_CORE_N                                    ), // input
  . reset_ff_tx_clk                                    ( ~iRST_FC_CORE_N                                    ), // input

  // clocks
  . rx_clk                                             ( iCLK_FC_RX                                         ), // input
  . tx_clk                                             ( iCLK_FC_TX                                         ), // input

  // rx data and status
  . rx_phy_data                                        ( iRX_PHY_DATA                                       ), // input [39:0]
  . rx_phy_los                                         ( iSFP_PHY_LOSIG                                     ), // input

  // comma aligned phy data
  . rx_align_data                                      ( rx_align_data[39:0]                                ), // output [39:0]
  // transmit phy data
  . tx_phy_data                                        ( tx_phy_data[39:0]                                  ), // output [39:0]
  // transmit local clock
  . ff_tx_clk                                          ( iCLK_FC_CORE                                       ), // input
  . ff_tx_data                                         ( 32'b0                                              ), // input [31:0]
  . ff_tx_sop                                          ( 1'b0                                               ), // input
  . ff_tx_eop                                          ( 1'b0                                               ), // input
  . ff_tx_mod                                          ( 2'b0                                               ), // input [1:0]
  . ff_tx_err                                          ( 1'b0                                               ), // input
  . ff_tx_wren                                         ( 1'b0                                               ), // input
  . ff_tx_class                                        ( 4'b0                                               ), // input [3:0]
  . ff_tx_end_code                                     ( 4'b0                                               ), // input [3:0]
  . ff_tx_crc_fwd                                      ( 1'b0                                               ), // input
  . ff_tx_crc_chk                                      ( 1'b0                                               ), // input
  . ff_tx_sof_eof                                      ( 1'b0                                               ), // input
  . ff_tx_septy                                        ( ), // output
  . ff_tx_rdy                                          ( ), // output
  . ff_tx_ipg                                          ( 32'b0                                              ), // input [31:0]
  // serdes loopback enable
  . sd_loopback                                        ( sd_loopback                                        ), // output
  // link synchronization indication
  . led_link_sync                                      ( led_link_sync                                      ), // output
  // link in active state indication
  . led_link_online                                    ( led_link_online                                    ), // output
  // generate r_rdy primitive
  . rdy_gen                                            ( 1'b0                                               ), // input
  // current credit
  . current_credit                                     ( current_credit[15:0]                               ), // output [15:0]
  // frame class valid
  . rx_class_val                                       ( oRX_CLASS_VAL                                      ), // output
  // frame class
  . rx_class                                           ( rx_class[3:0]                                      ), // output [3:0]
  // frame end code valid
  . rx_end_code_val                                    ( rx_end_code_val                                    ), // output
  // frame end code for external statistic
  . rx_end_code                                        ( rx_end_code[3:0]                                   ), // output [3:0]
  // primitive decoding status
  . rx_primitive                                       ( oRX_PRIMITIVE[11:0]                                ), // output [11:0]

  . rx_fc1_data                                        ( rx_fc1_data[31:0]                                  ), // output [31:0]
  . rx_fc1_kchn                                        ( rx_fc1_kchn                                        ), // output

  . rx_fc1_err                                         ( rx_fc1_err                                         ), // output
  . rx_disp_err                                        ( rx_disp_err                                        ), // output
  . rx_char_err                                        ( rx_char_err                                        ), // output

  . reg_clk                                            ( iCLK_100M                                          ), // input
  . reg_rd                                             ( mtip_reg_rd                                        ), // input
  . reg_wr                                             ( mtip_reg_wr                                        ), // input
  . reg_addr                                           ( mtip_reg_addr[9:2]                                 ), // input [9:2]
  . reg_data_in                                        ( mtip_reg_data_in[31:0]                             ), // input [31:0]
  . reg_data_out                                       ( mtip_reg_data_out[31:0]                            ), // output [31:0]
  . reg_busy                                           ( mtip_reg_busy                                      )  // output
);

mtip_if_top mtip_if_top_inst (
  . iRST_FC_CORE_N                                     ( iRST_FC_CORE_N                                     ), // input
  . iRST_FC_RX_N                                       ( iRST_FC_RX_N                                       ), // input
  . iRST_100M_N                                        ( iRST_100M_N                                        ), // input
  . iCLK_FC_CORE                                       ( iCLK_FC_CORE                                       ), // input
  . iCLK_FC_RX                                         ( iCLK_FC_RX                                         ), // input
  . iCLK_100M                                          ( iCLK_100M                                          ), // input
  . iGLOBAL_TIMESTAMP                                  ( iGLOBAL_TIMESTAMP[55:0]                            ), // input [55:0]
  . iMM0_WR_DATA                                       ( MTIP_FC1_WR_DATA[63:0]                             ), // input [63:0]
  . iMM0_ADDR                                          ( MTIP_FC1_ADDR[13:0]                                ), // input [13:0]
  . iMM0_WR_EN                                         ( MTIP_FC1_WR_EN                                     ), // input
  . iMM0_RD_EN                                         ( MTIP_FC1_RD_EN                                     ), // input
  . oMM0_RD_DATA                                       ( MTIP_FC1_RD_DATA[63:0]                             ), // output [63:0]
  . oMM0_RD_DATA_V                                     ( MTIP_FC1_RD_DATA_V                                 ), // output
  . iMM1_WR_DATA                                       ( MTIP_FC2_WR_DATA[63:0]                             ), // input [63:0]
  . iMM1_ADDR                                          ( MTIP_FC2_ADDR[13:0]                                ), // input [13:0]
  . iMM1_WR_EN                                         ( MTIP_FC2_WR_EN                                     ), // input
  . iMM1_RD_EN                                         ( MTIP_FC2_RD_EN                                     ), // input
  . oMM1_RD_DATA                                       ( MTIP_FC2_RD_DATA[63:0]                             ), // output [63:0]
  . oMM1_RD_DATA_V                                     ( MTIP_FC2_RD_DATA_V                                 ), // output
  . iMTIP_MM_WR_DATA                                   ( mtip_mm_wr_data[63:0]                              ), // input [63:0]
  . iMTIP_MM_ADDR                                      ( mtip_mm_addr[13:0]                                 ), // input [13:0]
  . iMTIP_MM_WR_EN                                     ( mtip_mm_wr_en                                      ), // input
  . iMTIP_MM_RD_EN                                     ( mtip_mm_rd_en                                      ), // input
  . oMTIP_MM_RD_DATA                                   ( mtip_mm_rd_data[63:0]                              ), // output [63:0]
  . oMTIP_MM_RD_DATA_V                                 ( mtip_mm_rd_data_v                                  ), // output
  . iSFP_PHY_LOSIG                                     ( iSFP_PHY_LOSIG                                     ), // input
  . iFF_RX_DATA                                        ( ff_rx_data[31:0]                                   ), // input [31:0]
  . iFF_RX_SOP                                         ( ff_rx_sop                                          ), // input
  . iFF_RX_DVAL                                        ( ff_rx_dval                                         ), // input
  . iFF_RX_EOP                                         ( ff_rx_eop                                          ), // input
  . iFF_RX_ERR                                         ( ff_rx_err                                          ), // input
  . iFF_RX_ERR_STAT                                    ( ff_rx_err_stat[7:0]                                ), // input [7:0]
  . iRX_FC1_DATA                                       ( rx_fc1_data[31:0]                                  ), // input [31:0]
  . iRX_FC1_KCHN                                       ( rx_fc1_kchn                                        ), // input
  . iRX_FC1_ERR                                        ( rx_fc1_err                                         ), // input
  . iRX_PRIMITIVE                                      ( oRX_PRIMITIVE[11:0]                                ), // input [11:0]
  . iRX_DISP_ERR                                       ( rx_disp_err                                        ), // input
  . iRX_CHAR_ERR                                       ( rx_char_err                                        ), // input
  . iFC_LINK_SYNC                                      ( led_link_sync                                      ), // input
  . iMTIP_DEBUG                                        ( mtip_debug[63:0]                                   ), // input [63:0]
  . iMTIP_REG_DATA_OUT                                 ( mtip_reg_data_out[31:0]                            ), // input [31:0]
  . iMTIP_REG_BUSY                                     ( mtip_reg_busy                                      ), // input
  . oMTIP_REG_DATA_IN                                  ( mtip_reg_data_in[31:0]                             ), // output [31:0]
  . oMTIP_REG_ADDR                                     ( mtip_reg_addr[9:0]                                 ), // output [9:0]
  . oMTIP_REG_RD                                       ( mtip_reg_rd                                        ), // output
  . oMTIP_REG_WR                                       ( mtip_reg_wr                                        ), // output
  . iEXTR_MIF_TS_FIFO_POP                              ( EXTR_MIF_TS_FIFO_POP                               ), // input
  . iEXTR_REG_EXTRENABLE                               ( EXTR_REG_EXTRENABLE                                ), // input
  . oMIF_EXTR_DATA                                     ( MIF_EXTR_DATA[63:0]                                ), // output [63:0]
  . oMIF_EXTR_EMPTY                                    ( MIF_EXTR_EMPTY[2:0]                                ), // output [2:0]
  . oMIF_EXTR_SOP                                      ( MIF_EXTR_SOP                                       ), // output
  . oMIF_EXTR_EOP                                      ( MIF_EXTR_EOP                                       ), // output
  . oMIF_EXTR_ERR                                      ( MIF_EXTR_ERR                                       ), // output
  . oMIF_EXTR_VALID                                    ( MIF_EXTR_VALID                                     ), // output
  . oMIF_EXTR_INDEX                                    ( MIF_EXTR_INDEX[2:0]                                ), // output [2:0]
  . oMIF_EXTR_FUTURE_TS                                ( MIF_EXTR_FUTURE_TS[107:0]                          ), // output [107:0]
  . oMIF_EXTR_EXTRENABLE                               ( MIF_EXTR_EXTRENABLE                                ), // output
  . iTA_OFF_FILL_DONE                                  ( iTA_OFF_FILL_DONE                                  ), // input
  . oMIF_DAT_FUTURE_TS                                 ( oMIF_DAT_FUTURE_TS[107:0]                          ), // output [107:0]
  . oMIF_DAT_FTS_VALID                                 ( oMIF_DAT_FTS_VALID                                 ), // output
  . oMIF_LOSYNC                                        ( oMIF_LOSYNC                                        ), // output
  . oMIF_OFF_FILL_REQ                                  ( oMIF_OFF_FILL_REQ                                  ), // output
  . iINT_STATS_LATCH_CLR                               ( iINT_STATS_LATCH_CLR                               ), // input
  . oINT_STATS_FC_CRC                                  ( oINT_STATS_FC_CRC[31:0]                            ), // output [31:0]
  . oINT_STATS_TRUNC                                   ( oINT_STATS_TRUNC[31:0]                             ), // output [31:0]
  . oINT_STATS_BADEOF                                  ( oINT_STATS_BADEOF[31:0]                            ), // output [31:0]
  . oINT_STATS_LOSIG                                   ( oINT_STATS_LOSIG[31:0]                             ), // output [31:0]
  . oINT_STATS_LOSYNC                                  ( oINT_STATS_LOSYNC[31:0]                            ), // output [31:0]
  . oINT_STATS_FC_CODE                                 ( oINT_STATS_FC_CODE[31:0]                           ), // output [31:0]
  . oINT_STATS_LIP                                     ( oINT_STATS_LIP[31:0]                               ), // output [31:0]
  . oINT_STATS_NOS_OLS                                 ( oINT_STATS_NOS_OLS[31:0]                           ), // output [31:0]
  . oINT_STATS_LR_LRR                                  ( oINT_STATS_LR_LRR[31:0]                            ), // output [31:0]
  . oINT_STATS_LINK_UP                                 ( oINT_STATS_LINK_UP[31:0]                           ), // output [31:0]
  . oINT_STATS_UP_LATCH                                ( oINT_STATS_UP_LATCH                                ), // output
  . oINT_STATS_LR_LRR_LATCH                            ( oINT_STATS_LR_LRR_LATCH                            ), // output
  . oINT_STATS_NOS_LOS_LATCH                           ( oINT_STATS_NOS_LOS_LATCH                           ), // output
  . oINT_STATS_LOSIG_LATCH                             ( oINT_STATS_LOSIG_LATCH                             ), // output
  . oINT_STATS_LOSYNC_LATCH                            ( oINT_STATS_LOSYNC_LATCH                            ), // output
  . iSTATS_LATCH_CLR_RXCLK                             ( iSTATS_LATCH_CLR_RXCLK                             ), // input
  . oLINK_UP_EVENT                                     ( oLINK_UP_EVENT                                     ), // output
  . iREG_LINKCTRL_WR_EN                                ( iREG_LINKCTRL_WR_EN                                ), // input
  . iREG_LINKCTRL_SCRMENBL                             ( iREG_LINKCTRL_SCRMENBL                             ), // input
  . iREG_LINKCTRL_MONITORMODE                          ( iREG_LINKCTRL_MONITORMODE[3:0]                     ), // input [3:0]
  . oMIF_LOSIG                                         ( oMIF_LOSIG                                         ), // output
  . iINTERVAL_ANY_LINK                                 ( iINTERVAL_ANY_LINK                                 )  // input
);
endmodule
