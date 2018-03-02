/*************************************************************************** 
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: link_engine.v$
* $Author: jaedon.kim $
* $Date: 2013-08-13 16:39:37 -0700 (Tue, 13 Aug 2013) $
* $Revision: 3177 $
* Description: Top level Link Engine
*
***************************************************************************/
import fc1_pkg::*;
import fmac_pkg::*;

module link_engine
#(
        parameter SIM_ONLY  =  0,
        parameter LINK_ID  =  0
)
(
        //////////////////////////////////////////////////////////////////////
        // Reset & Clocks
        //////////////////////////////////////////////////////////////////////
        input   [1:0]                          iCLK_RX,         // 219MHz
        input   [1:0]                          fcrxrst_n,
        input   iCLK_CORE,              // 212MHz
        input   iCLK_CORE219,              // 219MHz
        input   iCLK_PCIE,
        input   iCLK_100M,
        
        input   iRST_100M_N,
        
        input   iRST_RX_N,
        input   iRST_CORE_N,
        input   iRST_CORE219_N,
        input   iRST_PCIE_N,
				input   iRST_LINK_FC_CORE_N,
        
        //////////////////////////////////////////////////////////////////////
        // Global
        //////////////////////////////////////////////////////////////////////
        input   [3:0]                          iLINK_ID,
        input   [55:0]                         iGLOBAL_TIMESTAMP,
        input   iEND_OF_INTERVAL,
        output  [63:0]                         fmac0_xbar_rx_data,
        output  [1:0]                          fmac0_xbar_rx_sh,
        output                                 fmac0_xbar_rx_valid,
        output  [63:0]                         fmac1_xbar_rx_data,
        output  [1:0]                          fmac1_xbar_rx_sh,
        output                                 fmac1_xbar_rx_valid,
        input  [1:0] rx_is_lockedtodata,
        
        //////////////////////////////////////////////////////////////////////
        // MM I/F
        //////////////////////////////////////////////////////////////////////
        input   [63:0]                         iMM_WR_DATA,
        input   [16:0]                         iMM_ADDR,
        input   iMM_WR_EN,
        input   iMM_RD_EN,
        output  [63:0]                         oMM_RD_DATA,
        output  oMM_RD_DATA_V,
        
        //////////////////////////////////////////////////////////////////////
        // TO/FROM PCS
        //////////////////////////////////////////////////////////////////////
        input   [1:0][63:0]                    rx_parallel_data_pma,
				input   [1:0]                          iFC1_RX_BLOCK_SYNC,
        input   [1:0]                          iFC1_RX_VAL,
        input   [1:0][1:0]                     iFC1_RX_SH,
        input   [1:0][63:0]                    iFC1_RX_DATA,
        //input   fc1_pkg::fc1_interval_stats    iCH0_INT_STATS_FC1,
        input logic [1:0] [31:0] iINT_STATS_FC1_CORR_EVENT_CNT,
        input logic [1:0] [31:0] iINT_STATS_FC1_UNCORR_EVENT_CNT,
        input logic [1:0] [31:0] iINT_STATS_FC1_PCS_LOS_CNT,

        //input   fc1_pkg::fc1_interval_stats    iCH1_INT_STATS_FC1,
        
        
        //////////////////////////////////////////////////////////////////////
        // SFP
        //////////////////////////////////////////////////////////////////////
        //input   [1:0]                          iLOSYNC,
        input   [1:0]                          iSFP_PHY_LOSIG,
        output                                 oREG_LINKCTRL_RATESEL,
        
        //////////////////////////////////////////////////////////////////////
        // Serdes
        //////////////////////////////////////////////////////////////////////
        
        output  [3:0]                          oLE_LINKSPEED,
        input   [3:0]                          iLE_LINKSPEED,
        
        output  [1:0][63:0]                    oSERDES_MM_WR_DATA,
        output  [1:0][13:0]                    oSERDES_MM_ADDR,
        output  [1:0]                          oSERDES_MM_WR_EN,
        output  [1:0]                          oSERDES_MM_RD_EN,
        input   [1:0][63:0]                    iSERDES_MM_RD_DATA,
        input   [1:0]                          iSERDES_MM_RD_DATA_V,
        
        //////////////////////////////////////////////////////////////////////
        // FC1 KR
        //////////////////////////////////////////////////////////////////////
        output  [1:0][63:0]                    oFC1_LAYER_KR_MM_WR_DATA,
        output  [1:0][13:0]                    oFC1_LAYER_KR_MM_ADDR,
        output  [1:0]                          oFC1_LAYER_KR_MM_WR_EN,
        output  [1:0]                          oFC1_LAYER_KR_MM_RD_EN,
        input   [1:0][63:0]                    iFC1_LAYER_KR_MM_RD_DATA,
        input   [1:0]                          iFC1_LAYER_KR_MM_RD_DATA_V,
        
        //////////////////////////////////////////////////////////////////////
        // PCIE
        //////////////////////////////////////////////////////////////////////
        input   iDPLBUF_ANY_DATA_VLD,
        input   iDAT_DPLBUF_GNT,
        input   iCTL_DPLBUF_GNT,
        output  oDAT_DPLBUF_REQ,
        output  logic                                oDAT_DPLBUF_DATA_V,
        output  oCTL_DPLBUF_REQ,
        output  logic [255:0]                        oCTL_DAT_DPLBUF_DATA,
        output  logic                                oCTL_DPLBUF_DATA_V,
        
        //////////////////////////////////////////////////////////////////////
        // uC Stats
        //////////////////////////////////////////////////////////////////////
        input   [31:0]                         iUCSTATS_DATA,
        input   iUCSTATS_GNT,
        output  oLE_UCSTATS_REQ,
        output  [5:0]                          oLE_UCSTATS_ADDR,
        
        input   [31:0]                         iUCS_LE_MM_RD_DATA,
        input   [1:0]                          iUCS_LE_MM_RD_DATA_V,
        output  [1:0]                          oLE_UCS_MM_RD_EN,
        output  [1:0][4:0]                     oLE_UCS_MM_ADDR,
        
        //////////////////////////////////////////////////////////////////////
        // Other Link Engine
        //////////////////////////////////////////////////////////////////////
				input   [1:0] mon_mask,
				input   [1:0] mtip_enable,
        input   iLE_UC_RD_START,
        input   iINTERVAL_ANY_LINK,
        output  oLE_UC_RD_DONE,
        output  [3:0]                          oLE_MONITORMODE 
        
);

logic   [1:0]                         LOSYNC;

logic                                 iCLK_FC_CORE;
logic  [1:0]                          iCLK_FC_RX;
logic  [1:0]                          iRST_FC_RX_N;
logic                                 mtip_enable_stat, mtip_enable0, mtip_enable1;
assign  iCLK_FC_CORE               =  iCLK_CORE;
assign  iCLK_FC_RX                 =  iCLK_RX;
assign  iRST_FC_RX_N               =  {2{iRST_RX_N}};
assign mtip_enable0 = mtip_enable[0];
assign mtip_enable1 = mtip_enable[1];


logic [1:0] [31:0]    int_stats_endcr;         // From fmac_credit_stats of fmac_credit_stats.v
logic [1:0] [31:0]    int_stats_maxcr;         // From fmac_credit_stats of fmac_credit_stats.v
logic [1:0] [31:0]    int_stats_mincr;         // From fmac_credit_stats of fmac_credit_stats.v
logic [1:0] [31:0]    int_stats_timecr;        // From fmac_credit_stats of fmac_credit_stats.v
logic [1:0] [31:0]    reg_fmac_credit_start;         // From fmac_regs of fmac_regs.v


logic  [2:0]                          INT_STATS_CH1_MEM_RA;
logic  [1:0]                          LINK_UP_EVENT;
logic  [1:0]                          STATS_LATCH_CLR_RXCLK;
wire    [2:0]                          INT_STATS_CH0_MEM_RA;
wire    [1:0]                          STATS_LATCH_CLR_DONE_LAT;
//wire    [107:0]                        MIF0_DAT_FUTURE_TS;
//wire    [107:0]                        MIF1_DAT_FUTURE_TS;
wire    [11:0]                         CH0_RX_PRIMITIVE;
wire    [11:0]                         CH1_RX_PRIMITIVE;
wire    [127:0]                        STATS_CH0_MEM_DATA;
wire    [127:0]                        STATS_CH1_MEM_DATA;
wire    [13:0]                         CREDIT_STATS0_ADDR;
wire    [13:0]                         CREDIT_STATS1_ADDR;
wire    [3:0]                          REG_LINKSTATUS_LINKSPEED;
wire    [31:0]                         CH0_INT_STATS_BADEOF;
wire    [31:0]                         CH0_INT_STATS_ENDCR;
wire    [31:0]                         CH0_INT_STATS_FC_CODE;
wire    [31:0]                         CH0_INT_STATS_FC_CRC;
wire    [31:0]                         CH0_INT_STATS_FRAME_DROP;
wire    [31:0]                         CH0_INT_STATS_LINK_UP;
wire    [31:0]                         CH0_INT_STATS_LIP;
wire    [31:0]                         CH0_INT_STATS_LOSIG;
wire    [31:0]                         CH0_INT_STATS_LOSYNC;
wire    [31:0]                         CH0_INT_STATS_LR_LRR;
wire    [31:0]                         CH0_INT_STATS_MAXCR;
wire    [31:0]                         CH0_INT_STATS_MINCR;
wire    [31:0]                         CH0_INT_STATS_NOS_OLS;
wire    [31:0]                         CH0_INT_STATS_TIMECR;
wire    [31:0]                         CH0_INT_STATS_TRUNC;
wire    [31:0]                         CH0_REG_CREDITSTART;
wire    [31:0]                         CH1_INT_STATS_BADEOF;
wire    [31:0]                         CH1_INT_STATS_ENDCR;
wire    [31:0]                         CH1_INT_STATS_FC_CODE;
wire    [31:0]                         CH1_INT_STATS_FC_CRC;
wire    [31:0]                         CH1_INT_STATS_FRAME_DROP;
wire    [31:0]                         CH1_INT_STATS_LINK_UP;
wire    [31:0]                         CH1_INT_STATS_LIP;
wire    [31:0]                         CH1_INT_STATS_LOSIG;
wire    [31:0]                         CH1_INT_STATS_LOSYNC;
wire    [31:0]                         CH1_INT_STATS_LR_LRR;
wire    [31:0]                         CH1_INT_STATS_MAXCR;
wire    [31:0]                         CH1_INT_STATS_MINCR;
wire    [31:0]                         CH1_INT_STATS_NOS_OLS;
wire    [31:0]                         CH1_INT_STATS_TIMECR;
wire    [31:0]                         CH1_INT_STATS_TRUNC;
wire    [31:0]                         CH1_REG_CREDITSTART;
wire    [63:0]                         CREDIT_STATS0_WR_DATA;
wire    [63:0]                         CREDIT_STATS1_WR_DATA;
wire    CH0_INT_STATS_LOSIG_LATCH;
wire    CH0_INT_STATS_LOSYNC_LATCH;
wire    CH0_INT_STATS_LR_LRR_LATCH;
wire    CH0_INT_STATS_NOS_LOS_LATCH;
wire    CH0_INT_STATS_UP_LATCH;
wire    CH0_RX_CLASS_VAL;
wire    CH1_INT_STATS_LOSIG_LATCH;
wire    CH1_INT_STATS_LOSYNC_LATCH;
wire    CH1_INT_STATS_LR_LRR_LATCH;
wire    CH1_INT_STATS_NOS_LOS_LATCH;
wire    CH1_INT_STATS_UP_LATCH;
wire    CH1_RX_CLASS_VAL;
logic  [63:0]                         CREDIT_STATS0_RD_DATA;
logic                                 CREDIT_STATS0_RD_DATA_V;
wire    CREDIT_STATS0_RD_EN;
wire    CREDIT_STATS0_WR_EN;
logic  [63:0]                         CREDIT_STATS1_RD_DATA;
logic                                 CREDIT_STATS1_RD_DATA_V;
wire    CREDIT_STATS1_RD_EN;
wire    CREDIT_STATS1_WR_EN;
wire    INT_STATS_BOTH_CH_DONE;
//wire    MIF0_DAT_FTS_VALID;
wire    MIF0_LOSIG;
wire    MIF0_LOSYNC;
wire    MIF0_OFF_FILL_REQ;
//wire    MIF1_DAT_FTS_VALID;
wire    MIF1_LOSIG;
wire    MIF1_LOSYNC;
wire    MIF1_OFF_FILL_REQ;
wire    REG_INVLDROPCTR_EN;
logic                                 TA_OFF_FILL_DONE;

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import link_cfg::*;

logic                                  CHAN0_LINKUP;
logic                                  CHAN1_LINKUP;
wire    [16:0]                         CHAN0_ADDR;
wire    [63:0]                         CHAN0_RD_DATA;
wire    CHAN0_RD_DATA_V;
wire    CHAN0_RD_EN;
wire    [63:0]                         CHAN0_WR_DATA;
wire    CHAN0_WR_EN;
wire    [16:0]                         CHAN1_ADDR;
wire    [63:0]                         CHAN1_RD_DATA;
wire    CHAN1_RD_DATA_V;
wire    CHAN1_RD_EN;
wire    [63:0]                         CHAN1_WR_DATA;
wire    CHAN1_WR_EN;
wire    CHF0_DROPPING;
wire    CHF1_DROPPING;
logic                                 DAT_DPLBUF_DATA_V;
wire    [127:0]                        EXTR0_DAT_DAL_DATA;
wire    [55:0]                         EXTR0_DAT_GOOD_TS;
wire    EXTR0_DAT_GTS_VALID;
wire    [127:0]                        EXTR1_DAT_DAL_DATA;
wire    [55:0]                         EXTR1_DAT_GOOD_TS;
wire    EXTR1_DAT_GTS_VALID;
wire    FCE0_DAT_FTS_VALID;
wire    [75:0]                         FCE0_DAT_FUTURE_TS;
wire    FCE1_DAT_FTS_VALID;
wire    [75:0]                         FCE1_DAT_FUTURE_TS;
logic                                 INT_STATS_LATCH_CLR;
logic                                 INT_STATS_UC_CH_ID;
logic                                 INT_STATS_UC_START;
logic                                 INVL_DAL_CH_ID;
logic  [127:0]                        INVL_DAL_DATA;
logic                                 INVL_FTS_VALID;
logic                                 INVL_GOOD_FIRST;
logic                                 INVL_GOOD_LAST;
logic  [55:0]                         INVL_GOOD_TS;
logic                                 INVL_GTS_VALID;
wire    [13:0]                         LINKCTRL_ADDR;
wire    [63:0]                         LINKCTRL_RD_DATA;
wire    LINKCTRL_RD_DATA_V;
wire    LINKCTRL_RD_EN;
wire    [63:0]                         LINKCTRL_WR_DATA;
wire    LINKCTRL_WR_EN;
logic                                 LKFD_BLK_AEMPTY;
logic                                 LKFD_FIFO_NEMPTY;
logic                                 LKFD_TAD_AFULL;
logic                                 LKFD_TAD_EMPTY;
logic  [6:0]                          LKFD_TAD_OFST_WA;
wire    [16:0]                         LK_GLOBAL_ADDR;
wire    [63:0]                         LK_GLOBAL_RD_DATA;
wire    LK_GLOBAL_RD_DATA_V;
wire    LK_GLOBAL_RD_EN;
wire    [63:0]                         LK_GLOBAL_WR_DATA;
wire    LK_GLOBAL_WR_EN;
logic  [DAT_LINK_FIFO_ADDR_WIDTH:0]   REG_DATALINKFIFOLEVEL_RD;
wire    REG_DATALINKFIFOLEVEL_RD_EN;
logic                                 REG_DATALINKFIFOLEVEL_V;
wire    [12:0]                         REG_DATALINKFIFOLEVEL_WR;
wire    REG_DATALINKFIFOLEVEL_WR_EN;
logic                                 REG_DATALINKFIFOSTAT_OVERFLOW;
logic                                 REG_DATALINKFIFOSTAT_UNDERFLOW;
logic  [DAT_LINK_FIFO_ADDR_WIDTH:0]   REG_DATALINKFIFOSTAT_WORDS;
logic                                 REG_INVLDATADROPCTR_EN;
logic                                 REG_INVLSTATSTOP_OVERFLOW;
logic                                 REG_INVLSTATSTOP_TOOSOON;
logic                                 REG_INVLSTATSTOP_UNDERFLOW;
wire    [3:0]                          REG_LINKCTRL_MONITORMODE;
wire    REG_LINKCTRL_SCRMENBL;
wire    REG_LINKCTRL_WR_EN;
logic                                 REG_LINKFLUSH;
logic                                 REG_TADALDATACTR_EN;
logic                                 REG_TADALSTATCTR_EN;
logic                                 REG_TADALZEROCTR_EN;
logic                                 REG_TAFIFOSTOP_CH0OVERFLOW;
logic                                 REG_TAFIFOSTOP_CH0UNDERFLOW;
logic                                 REG_TAFIFOSTOP_CH1OVERFLOW;
logic                                 REG_TAFIFOSTOP_CH1UNDERFLOW;
logic                                 REG_TAFIFOSTOP_INVLOVERFLOW;
logic                                 REG_TAFIFOSTOP_INVLUNDERFLOW;
wire    [63:0]                         REG__SCRATCH;
logic                                 TAD_CH0_DAL_READ;
logic                                 TAD_CH0_TS_FIFO_AFULL;
logic                                 TAD_CH1_DAL_READ;
logic                                 TAD_CH1_TS_FIFO_AFULL;
logic                                 TAD_INVL_DAL_READ;
logic  [255:0]                        TAD_LKFD_DAL_DATA;
logic                                 TAD_LKFD_DAL_VALID;
logic                                 TAD_OFF_FILL_DONE;
logic  [31:0]                         UCR_STATS_ALARM;
logic  [1:0]                          UCR_STATS_FIFO_PUSH;
logic  [15:0]                         UCR_STATS_RXPWR;
logic  [15:0]                         UCR_STATS_TEMP;
logic  [15:0]                         UCR_STATS_TXPWR;
logic  [31:0]                         UCR_STATS_WARN;
logic                                 XFRD_AHEAD_ST;
logic                                 XFRD_DATA_V_NXT;

logic iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_UNDERFLOW;
logic iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_OVERFLOW;
logic [4:0]  iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_WORDS;
logic iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_UNDERFLOW;
logic iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_OVERFLOW;
logic [4:0]  iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_WORDS;


logic [3:0] monitor_mode_masked0;
logic [3:0] monitor_mode_masked1;

always_ff @(posedge iCLK_CORE or negedge iRST_CORE_N)
  if (!iRST_CORE_N)
	begin
    monitor_mode_masked0 <= 'h0;
    monitor_mode_masked1 <= 'h0;
	end
	else
  begin
    monitor_mode_masked0 <= mon_mask[0] ? 4'h0 : REG_LINKCTRL_MONITORMODE;
    monitor_mode_masked1 <= mon_mask[1] ? 4'h0 : REG_LINKCTRL_MONITORMODE;
  end

///////////////////////////////////////////////////////////////////////////////
// Manual Declaration
///////////////////////////////////////////////////////////////////////////////
fmac_interval_stats  CH0_INT_STATS_FMAC, CH1_INT_STATS_FMAC;
logic [255:0] dat_dplbuf_data, ctl_dplbuf_data;

assign  oLE_MONITORMODE    =  REG_LINKCTRL_MONITORMODE;


logic [1:0] fmac0_fmac1_r_rdy, fmac1_fmac0_r_rdy;

logic [1:0] fc16_losync;
logic [1:0] fc8_losync;

   vi_sync_level #(.SIZE(2),
       .TWO_DST_FLOPS(1))
   fc8_losync_sync
     (
      .out_level    ( fc8_losync  ),
      .clk          ( iCLK_CORE          ),
      .rst_n        ( iRST_CORE_N        ),
      .in_level     ( {MIF1_LOSYNC, MIF0_LOSYNC} )
      );


   vi_sync_level #(.SIZE(2),
       .TWO_DST_FLOPS(1))
   fc16_losync_sync
     (
      .out_level    ( fc16_losync  ),
      .clk          ( iCLK_CORE          ),
      .rst_n        ( iRST_CORE_N        ),
      .in_level     ( ~iFC1_RX_BLOCK_SYNC )
      );

assign LOSYNC[0] =  mtip_enable_stat ? fc8_losync[0] : fc16_losync[0]; 
assign LOSYNC[1] =  mtip_enable_stat ? fc8_losync[1] : fc16_losync[1]; 

///////////////////////////////////////////////////////////////////////////////
// Channel Engine Instantiation
///////////////////////////////////////////////////////////////////////////////
/* channel_engine AUTO_TEMPLATE "u_channel_engine_\(.*\)" (
    .iCLK_RX (iCLK_RX[@]),
    .iCHANNEL_ID            ( 1'b@                      ),
    .iFC1_\(.*\)            ( iFC1_\1[@] ),
    .oFCE_\(.*\)            ( FCE@_\1[]                 ),
    .oEXTR_\(.*\)           ( EXTR@_\1[]                ),
    .oCHF_\(.*\)            ( CHF@_\1[]                 ),
    .iLOSYNC                ( iLOSYNC[@]                ),
    .iSFP_PHY_LOSIG         ( iSFP_PHY_LOSIG[@]         ),
    .\([a-z]\)MM_\(.*\)     ( CHAN@_\2[]                ), 
    .iREG_\(.*\)            ( REG_\1[]                  ),
    .oINT_STATS_\(.*\)      ( CH@_INT_STATS_\1[]        ),
    .iINT_STATS_\(.*\)      ( INT_STATS_\1[]            ),
 
    .\(.*\)SERDES_MM\(.*\)  ( \1SERDES_MM\2[@]          ),
    .\(.*\)FC1_LAYER_KR_MM\(.*\)  ( \1FC1_LAYER_KR_MM\2[@]          ),
    .iUCS_LE_MM_RD_DATA     ( iUCS_LE_MM_RD_DATA[]      ),
    .iUCS_LE_MM_RD_DATA_V   ( iUCS_LE_MM_RD_DATA_V[@]   ),
    .oLE_UCS_MM\(.*\)       ( oLE_UCS_MM\1[@]           ),
 
   );
*/
channel_engine #(
        . SIM_ONLY                                             ( SIM_ONLY                                           ),
        . CH_ID                                                ( 0                                                  ),
        . LINK_ID                                              ( LINK_ID                                            )
) channel_engine_0 (
				.REG_TSFIFOSTAT_UNDERFLOW(iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_UNDERFLOW),
				.REG_TSFIFOSTAT_OVERFLOW(iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_OVERFLOW),
				.REG_TSFIFOSTAT_WORDS(iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_WORDS),
        . sm_linkup                                            ( CHAN0_LINKUP ),
        . rx_is_lockedtodata (rx_is_lockedtodata[0]),
				. fcrxrst_n (fcrxrst_n[0]),

        . iCLK_100M                                            ( iCLK_100M                                          ),  // input
        . iRST_100M_N                                          ( iRST_100M_N                                        ),  // input
        . mtip_enable                                          ( mtip_enable0                                        ),  // input
        . iSFP_PHY_LOSIG                                       ( iSFP_PHY_LOSIG[0]                                  ),  // input
        . oINT_STATS_FC_CRC                                    ( CH0_INT_STATS_FC_CRC[31:0]                         ),  // output [31:0]
        . oINT_STATS_TRUNC                                     ( CH0_INT_STATS_TRUNC[31:0]                          ),  // output [31:0]
        . oINT_STATS_BADEOF                                    ( CH0_INT_STATS_BADEOF[31:0]                         ),  // output [31:0]
        . oINT_STATS_LOSIG                                     ( CH0_INT_STATS_LOSIG[31:0]                          ),  // output [31:0]
        . oINT_STATS_LOSYNC                                    ( CH0_INT_STATS_LOSYNC[31:0]                         ),  // output [31:0]
        . oINT_STATS_FC_CODE                                   ( CH0_INT_STATS_FC_CODE[31:0]                        ),  // output [31:0]
        . oINT_STATS_LIP                                       ( CH0_INT_STATS_LIP[31:0]                            ),  // output [31:0]
        . oINT_STATS_NOS_OLS                                   ( CH0_INT_STATS_NOS_OLS[31:0]                        ),  // output [31:0]
        . oINT_STATS_LR_LRR                                    ( CH0_INT_STATS_LR_LRR[31:0]                         ),  // output [31:0]
        . oINT_STATS_LINK_UP                                   ( CH0_INT_STATS_LINK_UP[31:0]                        ),  // output [31:0]
        . oINT_STATS_FRAME_DROP                                ( CH0_INT_STATS_FRAME_DROP[31:0]                     ),  // output [31:0]
        . oINT_STATS_UP_LATCH                                  ( CH0_INT_STATS_UP_LATCH                             ),  // output
        . oINT_STATS_LR_LRR_LATCH                              ( CH0_INT_STATS_LR_LRR_LATCH                         ),  // output
        . oINT_STATS_NOS_LOS_LATCH                             ( CH0_INT_STATS_NOS_LOS_LATCH                        ),  // output
        . oINT_STATS_LOSIG_LATCH                               ( CH0_INT_STATS_LOSIG_LATCH                          ),  // output
        . oINT_STATS_LOSYNC_LATCH                              ( CH0_INT_STATS_LOSYNC_LATCH                         ),  // output
        . iSTATS_LATCH_CLR_RXCLK                               ( STATS_LATCH_CLR_RXCLK[0]                           ),  // input
        . iTA_OFF_FILL_DONE                                    ( TAD_OFF_FILL_DONE                                   ),  // input
        //. oMIF_DAT_FUTURE_TS                                   ( MIF0_DAT_FUTURE_TS[107:0]                          ),  // output [107:0]
        //. oMIF_DAT_FTS_VALID                                   ( MIF0_DAT_FTS_VALID                                 ),  // output
        . oMIF_LOSYNC                                          ( MIF0_LOSYNC                                        ),  // output
        . oMIF_OFF_FILL_REQ                                    ( MIF0_OFF_FILL_REQ                                  ),  // output
        . oRX_PRIMITIVE                                        ( CH0_RX_PRIMITIVE[11:0]                             ),  // output [11:0]
        . oRX_CLASS_VAL                                        ( CH0_RX_CLASS_VAL                                   ),  // output
        . oLINK_UP_EVENT                                       ( LINK_UP_EVENT[0]                                   ),  // output
        . iREG_LINKCTRL_WR_EN                                  ( REG_LINKCTRL_WR_EN                                 ),  // input
        . iREG_LINKCTRL_SCRMENBL                               ( REG_LINKCTRL_SCRMENBL                              ),  // input
        . iREG_LINKCTRL_MONITORMODE                            ( REG_LINKCTRL_MONITORMODE[3:0]                      ),  // input [3:0]
        . monitor_mode_masked                                  ( monitor_mode_masked0[3:0]                      ),  // input [3:0]
        . oMIF_LOSIG                                           ( MIF0_LOSIG                                         ),  // output
        . iINTERVAL_ANY_LINK                                   ( iINTERVAL_ANY_LINK                                 ),  // input
        
        . oINT_STATS_FMAC                                      ( CH0_INT_STATS_FMAC                                 ),  // fmac_interval_stats
        . iRST_RX_N                                            ( iRST_RX_N                                          ),  // input
        . iRST_LINK_FC_CORE_N                                  ( iRST_LINK_FC_CORE_N                                ),  // input
        . iCLK_RX                                              ( iCLK_RX[0]                                         ),  // input
        . iRST_CORE_N                                          ( iRST_CORE_N                                        ),  // input
        . iRST_CORE219_N                                       ( iRST_CORE219_N                                        ),  // input
        . iCLK_CORE                                            ( iCLK_CORE                                          ),  // input
        . iCLK_CORE219                                         ( iCLK_CORE219                                          ),  // input
        . iGLOBAL_TIMESTAMP                                    ( iGLOBAL_TIMESTAMP[55:0]                            ),  // input [55:0]
        . iCHANNEL_ID                                          ( 1'b0                                               ),  // input
        . iMM_WR_DATA                                          ( CHAN0_WR_DATA[63:0]                                ),  // input [63:0]
        . iMM_ADDR                                             ( CHAN0_ADDR[16:0]                                   ),  // input [16:0]
        . iMM_WR_EN                                            ( CHAN0_WR_EN                                        ),  // input
        . iMM_RD_EN                                            ( CHAN0_RD_EN                                        ),  // input
        . oMM_RD_DATA                                          ( CHAN0_RD_DATA[63:0]                                ),  // output [63:0]
        . oMM_RD_DATA_V                                        ( CHAN0_RD_DATA_V                                    ),  // output
				. rx_parallel_data_pma                                 ( rx_parallel_data_pma[0]                            ),
        . iINT_STATS_LATCH_CLR                                 ( INT_STATS_LATCH_CLR                                ),  // input
        . iFC1_RX_SH                                           ( iFC1_RX_SH[0]                                      ),  // input [1:0]
        . iFC1_RX_DATA                                         ( iFC1_RX_DATA[0]                                    ),  // input [63:0]
        . iFC1_RX_VAL                                          ( iFC1_RX_VAL[0]                                     ),  // input
        . iFC1_RX_BLOCK_SYNC                                   ( iFC1_RX_BLOCK_SYNC[0]                              ),  // input
        . oSERDES_MM_WR_DATA                                   ( oSERDES_MM_WR_DATA[0]                              ),  // output [63:0]
        . oSERDES_MM_ADDR                                      ( oSERDES_MM_ADDR[0]                                 ),  // output [13:0]
        . oSERDES_MM_WR_EN                                     ( oSERDES_MM_WR_EN[0]                                ),  // output
        . oSERDES_MM_RD_EN                                     ( oSERDES_MM_RD_EN[0]                                ),  // output
        . iSERDES_MM_RD_DATA                                   ( iSERDES_MM_RD_DATA[0]                              ),  // input [63:0]
        . iSERDES_MM_RD_DATA_V                                 ( iSERDES_MM_RD_DATA_V[0]                            ),  // input
        . oFC1_LAYER_KR_MM_WR_DATA                             ( oFC1_LAYER_KR_MM_WR_DATA[0]                        ),  // output [63:0]
        . oFC1_LAYER_KR_MM_ADDR                                ( oFC1_LAYER_KR_MM_ADDR[0]                           ),  // output [13:0]
        . oFC1_LAYER_KR_MM_WR_EN                               ( oFC1_LAYER_KR_MM_WR_EN[0]                          ),  // output
        . oFC1_LAYER_KR_MM_RD_EN                               ( oFC1_LAYER_KR_MM_RD_EN[0]                          ),  // output
        . iFC1_LAYER_KR_MM_RD_DATA                             ( iFC1_LAYER_KR_MM_RD_DATA[0]                        ),  // input [63:0]
        . iFC1_LAYER_KR_MM_RD_DATA_V                           ( iFC1_LAYER_KR_MM_RD_DATA_V[0]                      ),  // input
        . iTA_DAT_DAL_READ                                     ( TAD_CH0_DAL_READ                                   ),  // input
        . oEXTR_DAT_DAL_DATA                                   ( EXTR0_DAT_DAL_DATA[127:0]                          ),  // output [127:0]
        . oEXTR_DAT_GOOD_TS                                    ( EXTR0_DAT_GOOD_TS[55:0]                            ),  // output [55:0]
        . oEXTR_DAT_GTS_VALID                                  ( EXTR0_DAT_GTS_VALID                                ),  // output
        . oFCE_DAT_FUTURE_TS                                   ( FCE0_DAT_FUTURE_TS[75:0]                           ),  // output [75:0]
        . oFCE_DAT_FTS_VALID                                   ( FCE0_DAT_FTS_VALID                                 ),  // output
        . oCHF_DROPPING                                        ( CHF0_DROPPING                                      ),  // output
        . iUCS_LE_MM_RD_DATA                                   ( iUCS_LE_MM_RD_DATA[31:0]                           ),  // input [31:0]
        . iUCS_LE_MM_RD_DATA_V                                 ( iUCS_LE_MM_RD_DATA_V[0]                            ),  // input
        . oLE_UCS_MM_RD_EN                                     ( oLE_UCS_MM_RD_EN[0]                                ),  // output
        . oLE_UCS_MM_ADDR                                      ( oLE_UCS_MM_ADDR[0]                                 ),  // output [4:0]
        . fmac_xbar_rx_data                                    ( fmac0_xbar_rx_data                            ),  // output [63:0]
        . fmac_xbar_rx_sh                                      ( fmac0_xbar_rx_sh                            ),     // output [63:0]
        . fmac_xbar_rx_valid                                   ( fmac0_xbar_rx_valid                                 ),  // output

        . fmac_credit_out_r_rdy                                ( fmac0_fmac1_r_rdy                                  ),  // output [1:0]
        . credit_in_r_rdy                                      ( fmac1_fmac0_r_rdy                                  ),   // input [1:0],
        . int_stats_endcr (int_stats_endcr[0]),
        . int_stats_maxcr (int_stats_maxcr[0]),
        . int_stats_mincr (int_stats_mincr[0]),
        . int_stats_timecr (int_stats_timecr[0]),
        . reg_fmac_credit_start (reg_fmac_credit_start[0])

);

channel_engine #(
        . SIM_ONLY                                             ( SIM_ONLY                                           ),
        . CH_ID                                                ( 1                                                  ),
        . LINK_ID                                              ( LINK_ID                                            )
) channel_engine_1 (
				.REG_TSFIFOSTAT_UNDERFLOW(iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_UNDERFLOW),
				.REG_TSFIFOSTAT_OVERFLOW(iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_OVERFLOW),
				.REG_TSFIFOSTAT_WORDS(iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_WORDS),
        . sm_linkup                                            ( CHAN1_LINKUP ),
				. fcrxrst_n (fcrxrst_n[1]),
        . iCLK_100M                                            ( iCLK_100M                                          ),  // input
        . rx_is_lockedtodata (rx_is_lockedtodata[1]),
        . iRST_100M_N                                          ( iRST_100M_N                                        ),  // input
        . mtip_enable                                          ( mtip_enable1                                        ),  // input
        . iSFP_PHY_LOSIG                                       ( iSFP_PHY_LOSIG[1]                                  ),  // input
        . oINT_STATS_FC_CRC                                    ( CH1_INT_STATS_FC_CRC[31:0]                         ),  // output [31:0]
        . oINT_STATS_TRUNC                                     ( CH1_INT_STATS_TRUNC[31:0]                          ),  // output [31:0]
        . oINT_STATS_BADEOF                                    ( CH1_INT_STATS_BADEOF[31:0]                         ),  // output [31:0]
        . oINT_STATS_LOSIG                                     ( CH1_INT_STATS_LOSIG[31:0]                          ),  // output [31:0]
        . oINT_STATS_LOSYNC                                    ( CH1_INT_STATS_LOSYNC[31:0]                         ),  // output [31:0]
        . oINT_STATS_FC_CODE                                   ( CH1_INT_STATS_FC_CODE[31:0]                        ),  // output [31:0]
        . oINT_STATS_LIP                                       ( CH1_INT_STATS_LIP[31:0]                            ),  // output [31:0]
        . oINT_STATS_NOS_OLS                                   ( CH1_INT_STATS_NOS_OLS[31:0]                        ),  // output [31:0]
        . oINT_STATS_LR_LRR                                    ( CH1_INT_STATS_LR_LRR[31:0]                         ),  // output [31:0]
        . oINT_STATS_LINK_UP                                   ( CH1_INT_STATS_LINK_UP[31:0]                        ),  // output [31:0]
        . oINT_STATS_FRAME_DROP                                ( CH1_INT_STATS_FRAME_DROP[31:0]                     ),  // output [31:0]
        . oINT_STATS_UP_LATCH                                  ( CH1_INT_STATS_UP_LATCH                             ),  // output
        . oINT_STATS_LR_LRR_LATCH                              ( CH1_INT_STATS_LR_LRR_LATCH                         ),  // output
        . oINT_STATS_NOS_LOS_LATCH                             ( CH1_INT_STATS_NOS_LOS_LATCH                        ),  // output
        . oINT_STATS_LOSIG_LATCH                               ( CH1_INT_STATS_LOSIG_LATCH                          ),  // output
        . oINT_STATS_LOSYNC_LATCH                              ( CH1_INT_STATS_LOSYNC_LATCH                         ),  // output
        . iSTATS_LATCH_CLR_RXCLK                               ( STATS_LATCH_CLR_RXCLK[1]                           ),  // input
        . iTA_OFF_FILL_DONE                                    ( TAD_OFF_FILL_DONE                                   ),  // input
        //. oMIF_DAT_FUTURE_TS                                   ( MIF1_DAT_FUTURE_TS[107:0]                          ),  // output [107:0]
        //. oMIF_DAT_FTS_VALID                                   ( MIF1_DAT_FTS_VALID                                 ),  // output
        . oMIF_LOSYNC                                          ( MIF1_LOSYNC                                        ),  // output
        . oMIF_OFF_FILL_REQ                                    ( MIF1_OFF_FILL_REQ                                  ),  // output
        . oRX_PRIMITIVE                                        ( CH1_RX_PRIMITIVE[11:0]                             ),  // output [11:0]
        . oRX_CLASS_VAL                                        ( CH1_RX_CLASS_VAL                                   ),  // output
        . oLINK_UP_EVENT                                       ( LINK_UP_EVENT[1]                                   ),  // output
        . iREG_LINKCTRL_WR_EN                                  ( REG_LINKCTRL_WR_EN                                 ),  // input
        . iREG_LINKCTRL_SCRMENBL                               ( REG_LINKCTRL_SCRMENBL                              ),  // input
        . iREG_LINKCTRL_MONITORMODE                            ( REG_LINKCTRL_MONITORMODE[3:0]                      ),  // input [3:0]
        . monitor_mode_masked                                  ( monitor_mode_masked1[3:0]                      ),  // input [3:0]
        . oMIF_LOSIG                                           ( MIF1_LOSIG                                         ),  // output
        . iINTERVAL_ANY_LINK                                   ( iINTERVAL_ANY_LINK                                 ),  // input
        
        . oINT_STATS_FMAC                                      ( CH1_INT_STATS_FMAC                                 ),  // fmac_interval_stats
        . iRST_RX_N                                            ( iRST_RX_N                                          ),  // input
        . iRST_LINK_FC_CORE_N                                  ( iRST_LINK_FC_CORE_N                                ),  // input
        . iCLK_RX                                              ( iCLK_RX[1]                                         ),  // input
        . iRST_CORE_N                                          ( iRST_CORE_N                                        ),  // input
        . iRST_CORE219_N                                       ( iRST_CORE219_N                                        ),  // input
        . iCLK_CORE                                            ( iCLK_CORE                                          ),  // input
        . iCLK_CORE219                                         ( iCLK_CORE219                                       ),  // input
        . iGLOBAL_TIMESTAMP                                    ( iGLOBAL_TIMESTAMP[55:0]                            ),  // input [55:0]
        . iCHANNEL_ID                                          ( 1'b1                                               ),  // input
        . iMM_WR_DATA                                          ( CHAN1_WR_DATA[63:0]                                ),  // input [63:0]
        . iMM_ADDR                                             ( CHAN1_ADDR[16:0]                                   ),  // input [16:0]
        . iMM_WR_EN                                            ( CHAN1_WR_EN                                        ),  // input
        . iMM_RD_EN                                            ( CHAN1_RD_EN                                        ),  // input
        . oMM_RD_DATA                                          ( CHAN1_RD_DATA[63:0]                                ),  // output [63:0]
        . oMM_RD_DATA_V                                        ( CHAN1_RD_DATA_V                                    ),  // output
        . iINT_STATS_LATCH_CLR                                 ( INT_STATS_LATCH_CLR                                ),  // input
				. rx_parallel_data_pma                                 ( rx_parallel_data_pma[1]                            ),
        . iFC1_RX_SH                                           ( iFC1_RX_SH[1]                                      ),  // input [1:0]
        . iFC1_RX_DATA                                         ( iFC1_RX_DATA[1]                                    ),  // input [63:0]
        . iFC1_RX_VAL                                          ( iFC1_RX_VAL[1]                                     ),  // input
        . iFC1_RX_BLOCK_SYNC                                   ( iFC1_RX_BLOCK_SYNC[1]                              ),  // input
        . oSERDES_MM_WR_DATA                                   ( oSERDES_MM_WR_DATA[1]                              ),  // output [63:0]
        . oSERDES_MM_ADDR                                      ( oSERDES_MM_ADDR[1]                                 ),  // output [13:0]
        . oSERDES_MM_WR_EN                                     ( oSERDES_MM_WR_EN[1]                                ),  // output
        . oSERDES_MM_RD_EN                                     ( oSERDES_MM_RD_EN[1]                                ),  // output
        . iSERDES_MM_RD_DATA                                   ( iSERDES_MM_RD_DATA[1]                              ),  // input [63:0]
        . iSERDES_MM_RD_DATA_V                                 ( iSERDES_MM_RD_DATA_V[1]                            ),  // input
        . oFC1_LAYER_KR_MM_WR_DATA                             ( oFC1_LAYER_KR_MM_WR_DATA[1]                        ),  // output [63:0]
        . oFC1_LAYER_KR_MM_ADDR                                ( oFC1_LAYER_KR_MM_ADDR[1]                           ),  // output [13:0]
        . oFC1_LAYER_KR_MM_WR_EN                               ( oFC1_LAYER_KR_MM_WR_EN[1]                          ),  // output
        . oFC1_LAYER_KR_MM_RD_EN                               ( oFC1_LAYER_KR_MM_RD_EN[1]                          ),  // output
        . iFC1_LAYER_KR_MM_RD_DATA                             ( iFC1_LAYER_KR_MM_RD_DATA[1]                        ),  // input [63:0]
        . iFC1_LAYER_KR_MM_RD_DATA_V                           ( iFC1_LAYER_KR_MM_RD_DATA_V[1]                      ),  // input
        . iTA_DAT_DAL_READ                                     ( TAD_CH1_DAL_READ                                   ),  // input
        . oEXTR_DAT_DAL_DATA                                   ( EXTR1_DAT_DAL_DATA[127:0]                          ),  // output [127:0]
        . oEXTR_DAT_GOOD_TS                                    ( EXTR1_DAT_GOOD_TS[55:0]                            ),  // output [55:0]
        . oEXTR_DAT_GTS_VALID                                  ( EXTR1_DAT_GTS_VALID                                ),  // output
        . oFCE_DAT_FUTURE_TS                                   ( FCE1_DAT_FUTURE_TS[75:0]                           ),  // output [75:0]
        . oFCE_DAT_FTS_VALID                                   ( FCE1_DAT_FTS_VALID                                 ),  // output
        . oCHF_DROPPING                                        ( CHF1_DROPPING                                      ),  // output
        . iUCS_LE_MM_RD_DATA                                   ( iUCS_LE_MM_RD_DATA[31:0]                           ),  // input [31:0]
        . iUCS_LE_MM_RD_DATA_V                                 ( iUCS_LE_MM_RD_DATA_V[1]                            ),  // input
        . oLE_UCS_MM_RD_EN                                     ( oLE_UCS_MM_RD_EN[1]                                ),  // output
        . oLE_UCS_MM_ADDR                                      ( oLE_UCS_MM_ADDR[1]                                 ),  // output [4:0]
        . fmac_xbar_rx_data                                    ( fmac1_xbar_rx_data                            ),  // output [63:0]
        . fmac_xbar_rx_sh                                      ( fmac1_xbar_rx_sh                            ),     // output [63:0]
        . fmac_xbar_rx_valid                                   ( fmac1_xbar_rx_valid                                 ),  // output

        . fmac_credit_out_r_rdy                                ( fmac1_fmac0_r_rdy                                  ),  // output [1:0]
        . credit_in_r_rdy                                      ( fmac0_fmac1_r_rdy                                  ),   // input [1:0],
        . int_stats_endcr (int_stats_endcr[1]),
        . int_stats_maxcr (int_stats_maxcr[1]),
        . int_stats_mincr (int_stats_mincr[1]),
        . int_stats_timecr (int_stats_timecr[1]),
        . reg_fmac_credit_start (reg_fmac_credit_start[1])
);

always_ff @(posedge iCLK_CORE)
  mtip_enable_stat <= !(iLE_LINKSPEED[3:0] == 4'b0100);

///////////////////////////////////////////////////////////////////////////////
// Data Interval Stats Packager Instantiation
///////////////////////////////////////////////////////////////////////////////
/* interval_stats AUTO_TEMPLATE (
    .clk                ( iCLK_CORE            ),
    .rst_n              ( iRST_CORE_N          ),
    .oINT_STATS_\(.*\)  ( INT_STATS_\1[]        ),
    .oINVL_\(.*\)       ( INVL_\1[]             ),
    .iCH0_INT_STATS_FMAC ( CH0_INT_STATS_FMAC           ),
    .iCH1_INT_STATS_FMAC ( CH1_INT_STATS_FMAC           ),
    .oREG_\(.*\)        ( REG_\1[]              ),
    .iREG_\(.*\)        ( REG_\1[]              ),
    .iUCR_\(.*\)        ( UCR_\1[]              ),
   );
*/
interval_stats u_interval_stats (
        . int_stats_endcr (int_stats_endcr),
        . int_stats_maxcr (int_stats_maxcr),
        . int_stats_mincr (int_stats_mincr),
        . int_stats_timecr (int_stats_timecr),

        . oINT_STATS_LATCH_CLR                                 ( INT_STATS_LATCH_CLR                                ),  // output
        . oINVL_DAL_DATA                                       ( INVL_DAL_DATA[127:0]                               ),  // output [127:0]
        . oINVL_DAL_CH_ID                                      ( INVL_DAL_CH_ID                                     ),  // output
        . oINVL_GOOD_TS                                        ( INVL_GOOD_TS[55:0]                                 ),  // output [55:0]
        . oINVL_GOOD_FIRST                                     ( INVL_GOOD_FIRST                                    ),  // output
        . oINVL_GOOD_LAST                                      ( INVL_GOOD_LAST                                     ),  // output
        . oINVL_GTS_VALID                                      ( INVL_GTS_VALID                                     ),  // output
        . oINVL_FTS_VALID                                      ( INVL_FTS_VALID                                     ),  // output
        . oREG_INVLSTATSTOP_OVERFLOW                           ( REG_INVLSTATSTOP_OVERFLOW                          ),  // output
        . oREG_INVLSTATSTOP_UNDERFLOW                          ( REG_INVLSTATSTOP_UNDERFLOW                         ),  // output
        . oREG_INVLSTATSTOP_TOOSOON                            ( REG_INVLSTATSTOP_TOOSOON                           ),  // output
        . oLE_UC_RD_DONE                                       ( oLE_UC_RD_DONE                                     ),  // output
        . oLE_UCSTATS_REQ                                      ( oLE_UCSTATS_REQ                                    ),  // output
        . oINT_STATS_UC_START                                  ( INT_STATS_UC_START                                 ),  // output
        . oINT_STATS_UC_CH_ID                                  ( INT_STATS_UC_CH_ID                                 ),  // output
        . oREG_INVLDATADROPCTR_EN                              ( REG_INVLDATADROPCTR_EN                             ),  // output
        . clk                                                  ( iCLK_CORE                                          ),  // input
        . rst_n                                                ( iRST_CORE_N                                        ),  // input
        . iLINK_ID                                             ( iLINK_ID[3:0]                                      ),  // input [3:0]
        . iGLOBAL_TIMESTAMP                                    ( iGLOBAL_TIMESTAMP[55:0]                            ),  // input [55:0]
        . iEND_OF_INTERVAL                                     ( iEND_OF_INTERVAL                                   ),  // input
        . iTA_INVL_DAL_READ                                    ( TAD_INVL_DAL_READ                                  ),  // input
        . iCH0_INT_STATS_FMAC                                  ( CH0_INT_STATS_FMAC                                 ),  // fmac_interval_stats
        . iCH1_INT_STATS_FMAC                                  ( CH1_INT_STATS_FMAC                                 ),  // fmac_interval_stats
        //. iCH0_INT_STATS_FC1                                   ( iCH0_INT_STATS_FC1                                 ),  // fc1_interval_stats    
        //. iCH1_INT_STATS_FC1                                   ( iCH1_INT_STATS_FC1                                 ),  // fc1_interval_stats    
        .iINT_STATS_FC1_CORR_EVENT_CNT(iINT_STATS_FC1_CORR_EVENT_CNT),
        .iINT_STATS_FC1_UNCORR_EVENT_CNT(iINT_STATS_FC1_UNCORR_EVENT_CNT),
        .iINT_STATS_FC1_PCS_LOS_CNT(iINT_STATS_FC1_PCS_LOS_CNT),

        . iLE_UC_RD_START                                      ( iLE_UC_RD_START                                    ),  // input
        . iUCSTATS_GNT                                         ( iUCSTATS_GNT                                       ),  // input
        . iUCR_STATS_FIFO_PUSH                                 ( UCR_STATS_FIFO_PUSH[1:0]                           ),  // input [1:0]
        . iUCR_STATS_ALARM                                     ( UCR_STATS_ALARM[31:0]                              ),  // input [31:0]
        . iUCR_STATS_WARN                                      ( UCR_STATS_WARN[31:0]                               ),  // input [31:0]
        . iUCR_STATS_TXPWR                                     ( UCR_STATS_TXPWR[15:0]                              ),  // input [15:0]
        . iUCR_STATS_RXPWR                                     ( UCR_STATS_RXPWR[15:0]                              ),  // input [15:0]
        . iUCR_STATS_TEMP                                      ( UCR_STATS_TEMP[15:0]                               ),  // input [15:0]
        . iREG_LINKCTRL_MONITORMODE                            ( REG_LINKCTRL_MONITORMODE[3:0]                      ),  // input [3:0]
        . mtip_enable                                          ( mtip_enable_stat                                   ),
        . oREG_INVLDROPCTR_EN                                  ( REG_INVLDROPCTR_EN                                 ),  // output
        . iREG_LINKCTRL_LINKSPEED                              ( oLE_LINKSPEED[3:0]                                 ),  // input [3:0]
        . oINT_STATS_CH0_MEM_RA                                ( INT_STATS_CH0_MEM_RA[2:0]                          ),  // output [1:0]
        . oINT_STATS_CH1_MEM_RA                                ( INT_STATS_CH1_MEM_RA[2:0]                          ),  // output [1:0]
        . oINT_STATS_BOTH_CH_DONE                              ( INT_STATS_BOTH_CH_DONE                             ),  // output
        . iCH0_INT_STATS_FC_CRC                                ( CH0_INT_STATS_FC_CRC[31:0]                         ),  // input [31:0]
        . iCH0_INT_STATS_TRUNC                                 ( CH0_INT_STATS_TRUNC[31:0]                          ),  // input [31:0]
        . iCH0_INT_STATS_BADEOF                                ( CH0_INT_STATS_BADEOF[31:0]                         ),  // input [31:0]
        . iCH0_INT_STATS_LOSIG                                 ( CH0_INT_STATS_LOSIG[31:0]                          ),  // input [31:0]
        . iCH0_INT_STATS_LOSYNC                                ( CH0_INT_STATS_LOSYNC[31:0]                         ),  // input [31:0]
        . iCH0_INT_STATS_FRAME_DROP                            ( CH0_INT_STATS_FRAME_DROP[31:0]                     ),  // input [31:0]
        . iCH0_INT_STATS_LOSIG_LATCH                           ( CH0_INT_STATS_LOSIG_LATCH                          ),  // input
        . iCH0_INT_STATS_LOSYNC_LATCH                          ( CH0_INT_STATS_LOSYNC_LATCH                         ),  // input
        . iCH1_INT_STATS_FC_CRC                                ( CH1_INT_STATS_FC_CRC[31:0]                         ),  // input [31:0]
        . iCH1_INT_STATS_TRUNC                                 ( CH1_INT_STATS_TRUNC[31:0]                          ),  // input [31:0]
        . iCH1_INT_STATS_BADEOF                                ( CH1_INT_STATS_BADEOF[31:0]                         ),  // input [31:0]
        . iCH1_INT_STATS_LOSIG                                 ( CH1_INT_STATS_LOSIG[31:0]                          ),  // input [31:0]
        . iCH1_INT_STATS_LOSYNC                                ( CH1_INT_STATS_LOSYNC[31:0]                         ),  // input [31:0]
        . iCH1_INT_STATS_FRAME_DROP                            ( CH1_INT_STATS_FRAME_DROP[31:0]                     ),  // input [31:0]
        . iCH1_INT_STATS_LOSIG_LATCH                           ( CH1_INT_STATS_LOSIG_LATCH                          ),  // input
        . iCH1_INT_STATS_LOSYNC_LATCH                          ( CH1_INT_STATS_LOSYNC_LATCH                         ),  // input
        . iSTATS_LATCH_CLR_DONE_LAT                            ( STATS_LATCH_CLR_DONE_LAT[1:0]                      ),  // input [1:0]
        . iSTATS_CH0_MEM_DATA                                  ( STATS_CH0_MEM_DATA[127:0]                          ),  // input [127:0]
        . iSTATS_CH1_MEM_DATA                                  ( STATS_CH1_MEM_DATA[127:0]                   ),
        . iCH0_INT_STATS_TIMECR                                    ( CH0_INT_STATS_TIMECR[31:0]                         ),  // input [31:0]
        . iCH0_INT_STATS_MINCR                                     ( CH0_INT_STATS_MINCR[31:0]                          ),  // input [31:0]
        . iCH0_INT_STATS_MAXCR                                     ( CH0_INT_STATS_MAXCR[31:0]                          ),  // input [31:0]
        . iCH0_INT_STATS_ENDCR                                     ( CH0_INT_STATS_ENDCR[31:0]                          ),  // input [31:0]
        . iCH0_INT_STATS_FC_CODE                                   ( CH0_INT_STATS_FC_CODE[31:0]                        ),  // input [31:0]
        . iCH0_INT_STATS_NOS_OLS                                   ( CH0_INT_STATS_NOS_OLS[31:0]                        ),  // input [31:0]
        . iCH0_INT_STATS_LR_LRR                                    ( CH0_INT_STATS_LR_LRR[31:0]                         ),  // input [31:0]
        . iCH0_INT_STATS_LINK_UP                                   ( CH0_INT_STATS_LINK_UP[31:0]                        ),  // input [31:0]
        . iCH0_INT_STATS_UP_LATCH                                  ( CH0_INT_STATS_UP_LATCH                             ),  // input
        . iCH0_INT_STATS_LR_LRR_LATCH                              ( CH0_INT_STATS_LR_LRR_LATCH                         ),  // input
        . iCH0_INT_STATS_NOS_LOS_LATCH                             ( CH0_INT_STATS_NOS_LOS_LATCH                        ),  // input
        . iCH1_INT_STATS_TIMECR                                    ( CH1_INT_STATS_TIMECR[31:0]                         ),  // input [31:0]
        . iCH1_INT_STATS_MINCR                                     ( CH1_INT_STATS_MINCR[31:0]                          ),  // input [31:0]
        . iCH1_INT_STATS_MAXCR                                     ( CH1_INT_STATS_MAXCR[31:0]                          ),  // input [31:0]
        . iCH1_INT_STATS_ENDCR                                     ( CH1_INT_STATS_ENDCR[31:0]                          ),  // input [31:0]
        . iCH1_INT_STATS_FC_CODE                                   ( CH1_INT_STATS_FC_CODE[31:0]                        ),  // input [31:0]
        . iCH1_INT_STATS_NOS_OLS                                   ( CH1_INT_STATS_NOS_OLS[31:0]                        ),  // input [31:0]
        . iCH1_INT_STATS_LR_LRR                                    ( CH1_INT_STATS_LR_LRR[31:0]                         ),  // input [31:0]
        . iCH1_INT_STATS_LINK_UP                                   ( CH1_INT_STATS_LINK_UP[31:0]                        ),  // input [31:0]
        . iCH1_INT_STATS_UP_LATCH                                  ( CH1_INT_STATS_UP_LATCH                             ),  // input
        . iCH1_INT_STATS_LR_LRR_LATCH                              ( CH1_INT_STATS_LR_LRR_LATCH                         ),  // input
        . iCH1_INT_STATS_NOS_LOS_LATCH                             ( CH1_INT_STATS_NOS_LOS_LATCH                        )   // input


);

///////////////////////////////////////////////////////////////////////////////
// uC Stats Read Instantiation
///////////////////////////////////////////////////////////////////////////////
/* ucstats_read AUTO_TEMPLATE (
    .clk                ( iCLK_CORE            ),
    .rst_n              ( iRST_CORE_N          ),
    .oUCR_\(.*\)        ( UCR_\1[]              ),
    .iINT_\(.*\)        ( INT_\1[]              ),
    .iCH\(.*\)_INT\(.*\)( CH\1_INT\2[]          ),
   );
*/
ucstats_read u_ucstats_read (
        . oUCR_STATS_FIFO_PUSH                                 ( UCR_STATS_FIFO_PUSH[1:0]                           ),  // output [1:0]
        . oUCR_STATS_ALARM                                     ( UCR_STATS_ALARM[31:0]                              ),  // output [31:0]
        . oUCR_STATS_WARN                                      ( UCR_STATS_WARN[31:0]                               ),  // output [31:0]
        . oUCR_STATS_TXPWR                                     ( UCR_STATS_TXPWR[15:0]                              ),  // output [15:0]
        . oUCR_STATS_RXPWR                                     ( UCR_STATS_RXPWR[15:0]                              ),  // output [15:0]
        . oUCR_STATS_TEMP                                      ( UCR_STATS_TEMP[15:0]                               ),  // output [15:0]
        . oLE_UCSTATS_ADDR                                     ( oLE_UCSTATS_ADDR[5:0]                              ),  // output [5:0]
        . clk                                                  ( iCLK_CORE                                          ),  // input
        . rst_n                                                ( iRST_CORE_N                                        ),  // input
        . iINT_STATS_UC_START                                  ( INT_STATS_UC_START                                 ),  // input
        . iINT_STATS_UC_CH_ID                                  ( INT_STATS_UC_CH_ID                                 ),  // input
        . iUCSTATS_DATA                                        ( iUCSTATS_DATA[31:0]                                )   // input [31:0]
);

///////////////////////////////////////////////////////////////////////////////
// Time Arbiter Instantiation
///////////////////////////////////////////////////////////////////////////////
/* time_arbiter AUTO_TEMPLATE "u_time_arbiter_\(.*\)" (
    .clk                    ( iCLK_CORE                ),
    .rst_n                  ( iRST_CORE_N              ),
    .oTA_LKF_\(.*\)         ( TA@_LKF@_\1[]             ),
    .oTA_\(.*\)             ( TA@_\1[]                  ),
    .iLKF_TA_\(.*\)         ( LKF@_TA@_\1[]             ),
    .iINVL_GOOD_\(.*\)      ( INVL_GOOD_\1[]            ),
    .iREG_LINKCTRL_\(.*\)   ( REG_LINKCTRL_\1[]         ),
    .oREG_TAFIFOSTOP_\(.*\)   ( REG_TAFIFOSTOP_\1[]         ),
    .iDAL_CTL_DAT ('h0),
    .iREG_LINKCTRL_DALCTLSZ ('h0),

   );
*/

// Data Arbiter
time_arbiter  u_time_arbiter_D (
        . oTA_CH0_DAL_READ                                     ( TAD_CH0_DAL_READ                                   ),  // output
        . oTA_CH0_TS_FIFO_AFULL                                ( TAD_CH0_TS_FIFO_AFULL                              ),  // output
        . oTA_CH1_DAL_READ                                     ( TAD_CH1_DAL_READ                                   ),  // output
        . oTA_CH1_TS_FIFO_AFULL                                ( TAD_CH1_TS_FIFO_AFULL                              ),  // output
        . oTA_INVL_DAL_READ                                    ( TAD_INVL_DAL_READ                                  ),  // output
        . oTA_LKF_DAL_DATA                                     ( TAD_LKFD_DAL_DATA[255:0]                           ),  // output [255:0]
        . oTA_LKF_DAL_VALID                                    ( TAD_LKFD_DAL_VALID                                 ),  // output
        . oTA_REG_DALDATACTR_EN                                ( REG_TADALDATACTR_EN                                ),  // output
        . oTA_REG_DALSTATCTR_EN                                ( REG_TADALSTATCTR_EN                                ),  // output
        . oTA_REG_DALZEROCTR_EN                                ( REG_TADALZEROCTR_EN                                ),  // output
        . oREG_TAFIFOSTOP_CH0OVERFLOW                          ( REG_TAFIFOSTOP_CH0OVERFLOW                         ),  // output
        . oREG_TAFIFOSTOP_CH0UNDERFLOW                         ( REG_TAFIFOSTOP_CH0UNDERFLOW                        ),  // output
        . oREG_TAFIFOSTOP_CH1OVERFLOW                          ( REG_TAFIFOSTOP_CH1OVERFLOW                         ),  // output
        . oREG_TAFIFOSTOP_CH1UNDERFLOW                         ( REG_TAFIFOSTOP_CH1UNDERFLOW                        ),  // output
        . oREG_TAFIFOSTOP_INVLOVERFLOW                         ( REG_TAFIFOSTOP_INVLOVERFLOW                        ),  // output
        . oREG_TAFIFOSTOP_INVLUNDERFLOW                        ( REG_TAFIFOSTOP_INVLUNDERFLOW                       ),  // output
        . oREG_LINKFLUSH                                       ( REG_LINKFLUSH                                      ),  // output
        . oTA_OFF_FILL_DONE                                    ( TAD_OFF_FILL_DONE                                  ),  // output
        . clk                                                  ( iCLK_CORE                                          ),  // input
        . rst_n                                                ( iRST_CORE_N                                        ),  // input
        . iDAL_CTL_DAT                                         ( 'h0                                                ),  // input
        . iREG_LINKCTRL_DALCTLSZ                               ( 'h0                                                ),  // input [1:0]
        . iREG_LINKCTRL_MONITORMODE                            ( REG_LINKCTRL_MONITORMODE[3:0]                      ),  // input [3:0]
        . iCH0_DAL_DATA                                        ( EXTR0_DAT_DAL_DATA[127:0]                          ),  // input [127:0]
        . iCH0_GOOD_TS                                         ( EXTR0_DAT_GOOD_TS[55:0]                            ),  // input [55:0]
        . iCH0_GTS_VALID                                       ( EXTR0_DAT_GTS_VALID                                ),  // input
        . iCH1_DAL_DATA                                        ( EXTR1_DAT_DAL_DATA[127:0]                          ),  // input [127:0]
        . iCH1_GOOD_TS                                         ( EXTR1_DAT_GOOD_TS[55:0]                            ),  // input [55:0]
        . iCH1_GTS_VALID                                       ( EXTR1_DAT_GTS_VALID                                ),  // input
        . iINVL_DAL_DATA                                       ( INVL_DAL_DATA[127:0]                               ),  // input [127:0]
        . iINVL_DAL_CH_ID                                      ( INVL_DAL_CH_ID                                     ),  // input
        . iINVL_GOOD_TS                                        ( INVL_GOOD_TS[55:0]                                 ),  // input [55:0]
        . iINVL_GOOD_FIRST                                     ( INVL_GOOD_FIRST                                    ),  // input
        . iINVL_GOOD_LAST                                      ( INVL_GOOD_LAST                                     ),  // input
        . iINVL_GTS_VALID                                      ( INVL_GTS_VALID                                     ),  // input
        . iINVL_FTS_VALID                                      ( INVL_FTS_VALID                                     ),  // input
        . iLKF_TA_AFULL                                        ( LKFD_TAD_AFULL                                     ),  // input
        . iLKF_TA_OFST_WA                                      ( LKFD_TAD_OFST_WA[6:0]                              ),  // input [6:0]
        . iLKF_TA_EMPTY                                        ( LKFD_TAD_EMPTY                                     ),  // input
        //. iCH0_FUTURE_TS                                       ( mtip_enable0? MIF0_DAT_FUTURE_TS : FCE0_DAT_FUTURE_TS[75:0]                           ),  // input [107:0]
        //. iCH0_FTS_VALID                                       ( mtip_enable0? MIF0_DAT_FTS_VALID : FCE0_DAT_FTS_VALID                                 ),  // input
        //. iCH1_FUTURE_TS                                       ( mtip_enable1? MIF1_DAT_FUTURE_TS : FCE1_DAT_FUTURE_TS[75:0]                           ),  // input [107:0]
        //. iCH1_FTS_VALID                                       ( mtip_enable1? MIF1_DAT_FTS_VALID : FCE1_DAT_FTS_VALID                                 ),  // input
        . iCH0_FUTURE_TS                                       ( FCE0_DAT_FUTURE_TS[75:0]                           ),  // input [107:0]
        . iCH0_FTS_VALID                                       ( FCE0_DAT_FTS_VALID                                 ),  // input
        . iCH1_FUTURE_TS                                       ( FCE1_DAT_FUTURE_TS[75:0]                           ),  // input [107:0]
        . iCH1_FTS_VALID                                       ( FCE1_DAT_FTS_VALID                                 ),  // input
        . iCH0_OFF_FILL_REQ                                    ( MIF0_OFF_FILL_REQ                                  ),  // input
        . iCH1_OFF_FILL_REQ                                    ( MIF1_OFF_FILL_REQ                                  )   // input
);

///////////////////////////////////////////////////////////////////////////////
// Link FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
/* link_fifo AUTO_TEMPLATE "u_link_fifo_\(.*\)" (
    .wr_clk             ( iCLK_CORE                ),
    .rd_clk             ( iCLK_PCIE                 ),
    .wr_rst_n           ( iRST_CORE_N              ),
    .rd_rst_n           ( iRST_PCIE_N               ),
    .iTA_LKF_\(.*\)     ( TA@_LKF@_\1[]             ),
    .oLKF_TA_\(.*\)     ( LKF@_TA@_\1[]             ),
    .oLKF_\(.*\)        ( LKF@_\1[]                 ),
    .iXFR_\(.*\)        ( XFR@_\1[]                 ),
   );
*/

// Data Link FIFO
link_fifo #(
        . LINK_FIFO_DEPTH                                      ( DAT_LINK_FIFO_DEPTH                                ),
        . LINK_FIFO_DATA_WIDTH                                 ( DAT_LINK_FIFO_DATA_WIDTH                           ),
        . LINK_FIFO_ADDR_WIDTH                                 ( DAT_LINK_FIFO_ADDR_WIDTH                           )
) u_link_fifo_D (
        . oLKF_FIFO_NEMPTY                                     ( LKFD_FIFO_NEMPTY                                   ),  // output
        . oLKF_BLK_AEMPTY                                      ( LKFD_BLK_AEMPTY                                    ),  // output
        . oDAT_DPLBUF_DATA                                     ( dat_dplbuf_data[255:0]                             ),  // output [255:0]
        . oLKF_TA_AFULL                                        ( LKFD_TAD_AFULL                                     ),  // output
        . oLKF_TA_OFST_WA                                      ( LKFD_TAD_OFST_WA[6:0]                              ),  // output [6:0]
        . oLKF_TA_EMPTY                                        ( LKFD_TAD_EMPTY                                     ),  // output
        . oLKF_REG_LINKFIFOSTAT_UNDERFLOW                      ( REG_DATALINKFIFOSTAT_UNDERFLOW                     ),  // output
        . oLKF_REG_LINKFIFOSTAT_OVERFLOW                       ( REG_DATALINKFIFOSTAT_OVERFLOW                      ),  // output
        . oLKF_REG_LINKFIFOSTAT_WORDS                          ( REG_DATALINKFIFOSTAT_WORDS[DAT_LINK_FIFO_ADDR_WIDTH:0]),       // output [LINK_FIFO_ADDR_WIDTH:0]
        . oLKF_REG_LINKFIFOLEVEL_V                             ( REG_DATALINKFIFOLEVEL_V                            ),          // output
        . oLKF_REG_LINKFIFOLEVEL_RD                            ( REG_DATALINKFIFOLEVEL_RD[DAT_LINK_FIFO_ADDR_WIDTH:0]),         // output [LINK_FIFO_ADDR_WIDTH:0]
        . wr_clk                                               ( iCLK_CORE                                          ),          // input
        . rd_clk                                               ( iCLK_PCIE                                          ),          // input
        . wr_rst_n                                             ( iRST_CORE_N                                        ),          // input
        . rd_rst_n                                             ( iRST_PCIE_N                                        ),          // input
        . iTA_LKF_DAL_DATA                                     ( TAD_LKFD_DAL_DATA[255:0]                           ),          // input [255:0]
        . iTA_LKF_DAL_VALID                                    ( TAD_LKFD_DAL_VALID                                 ),          // input
        . iXFR_AHEAD_ST                                        ( XFRD_AHEAD_ST                                      ),          // input
        . iDPLBUF_DATA_V                                       ( DAT_DPLBUF_DATA_V                                  ),          // input
        . iREG_LINKFIFOLEVEL_WR                                ( REG_DATALINKFIFOLEVEL_WR                           ),          // input [LINK_FIFO_ADDR_WIDTH:0]
        . iREG_LINKFIFOLEVEL_WR_EN                             ( REG_DATALINKFIFOLEVEL_WR_EN                        ),          // input
        . iREG_LINKFIFOLEVEL_RD_EN                             ( REG_DATALINKFIFOLEVEL_RD_EN                        )           // input
);


///////////////////////////////////////////////////////////////////////////////
// Link DPL Buffer Transfer Instantiation
///////////////////////////////////////////////////////////////////////////////
/* lk_dpl_xfr AUTO_TEMPLATE "u_lk_dpl_xfr_\(.*\)" (
    .clk                ( iCLK_PCIE                 ),
    .rst_n              ( iRST_PCIE_N               ),
    .oXFR_\(.*\)        ( XFR@_\1[]                 ),
    .iLKF_\(.*\)        ( LKF@_\1[]                 ),
   );
*/

// Data Transfer State Machine
lk_dpl_xfr u_lk_dpl_xfr_D (
        . oDPLBUF_REQ                                          ( oDAT_DPLBUF_REQ                                    ),          // output
        . oDPLBUF_DATA_V                                       ( DAT_DPLBUF_DATA_V                                  ),          // output
        . oXFR_AHEAD_ST                                        ( XFRD_AHEAD_ST                                      ),          // output
        . oXFR_DATA_V_NXT                                      ( XFRD_DATA_V_NXT                                    ),          // output
        . clk                                                  ( iCLK_PCIE                                          ),          // input
        . rst_n                                                ( iRST_PCIE_N                                        ),          // input
        . iLKF_FIFO_NEMPTY                                     ( LKFD_FIFO_NEMPTY                                   ),          // input
        . iLKF_BLK_AEMPTY                                      ( LKFD_BLK_AEMPTY                                    ),          // input
        . iDPLBUF_GNT                                          ( iDAT_DPLBUF_GNT                                    ),          // input
        . iDPLBUF_ANY_DATA_VLD                                 ( iDPLBUF_ANY_DATA_VLD                               )           // input
);


///////////////////////////////////////////////////////////////////////////////
// Merged Link FIFO Data
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge iCLK_PCIE )
oCTL_DAT_DPLBUF_DATA <= dat_dplbuf_data ;

always_ff @( posedge iCLK_PCIE or negedge iRST_PCIE_N )
if ( ~iRST_PCIE_N ) begin
        oDAT_DPLBUF_DATA_V <= 1'b0;
        oCTL_DPLBUF_DATA_V <= 1'b0;
end
else begin
        oDAT_DPLBUF_DATA_V <= DAT_DPLBUF_DATA_V;
        //oCTL_DPLBUF_DATA_V <= CTL_DPLBUF_DATA_V;
end

///////////////////////////////////////////////////////////////////////////////
// Link Engine Registers Instantiation
///////////////////////////////////////////////////////////////////////////////
/* link_engine_regs AUTO_TEMPLATE (
    .clk                ( iCLK_CORE              ),
    .rst_n              ( iRST_CORE_N            ),
    .wr_data            ( LINKCTRL_WR_DATA[]      ),
    .addr               ( LINKCTRL_ADDR[]     ),
    .wr_en              ( LINKCTRL_WR_EN      ),
    .rd_en              ( LINKCTRL_RD_EN      ),
    .rd_data            ( LINKCTRL_RD_DATA[63:0]  ),
    .rd_data_v          ( LINKCTRL_RD_DATA_V[]    ),
    .iREG_LINKSTATUS_LOSIGCH\(.*\) ( iSFP_PHY_LOSIG[\1]   ),
    .iREG_LINKSTATUS_LO\(.*\)CH\(.*\) ( iLO\1[\2]   ),
    .iREG_LINKSTATUS_DROP\(.*\)CH\(.*\) ( CHF\2_DROP\1[]  ),
    .iREG_\(.*\)        ( REG_\1[]              ),
    .oREG_\(.*\)        ( REG_\1[]              ),
   );
*/


link_engine_regs #(
        . LITE                                                 ( 0                                                  )
) u_engine_regs (
        . clk                                                  ( iCLK_CORE                                          ),  // input
        . rst_n                                                ( iRST_CORE_N                                        ),  // input
        . wr_en                                                ( LINKCTRL_WR_EN                                     ),  // input
        . rd_en                                                ( LINKCTRL_RD_EN                                     ),  // input
        . addr                                                 ( LINKCTRL_ADDR[9:0]                                 ),  // input [9:0]
        . wr_data                                              ( LINKCTRL_WR_DATA[63:0]                             ),  // input [63:0]
        . rd_data                                              ( LINKCTRL_RD_DATA[63:0]                             ),  // output [63:0]
        . rd_data_v                                            ( LINKCTRL_RD_DATA_V                                 ),  // output
        . oREG__SCRATCH                                        ( REG__SCRATCH[63:0]                                 ),  // output [63:0]
        . oREG_LINKCTRL_WR_EN                                  ( REG_LINKCTRL_WR_EN                                 ),  // output
        . oREG_LINKCTRL_LINKSPEED                              ( oLE_LINKSPEED[3:0]                                 ),  // output [3:0]
        . oREG_LINKCTRL_MONITORMODE                            ( REG_LINKCTRL_MONITORMODE[3:0]                      ),  // output [3:0]
        . oREG_LINKCTRL_SCRMENBL                               ( REG_LINKCTRL_SCRMENBL                              ),  // output
        . oREG_LINKCTRL_RATESEL                                ( oREG_LINKCTRL_RATESEL                               ),  // output
				.iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_UNDERFLOW(iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_UNDERFLOW),
				.iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_OVERFLOW(iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_OVERFLOW),
				.iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_WORDS(iREG_LINKSTATUS_CH1_REG_TSFIFOSTAT_WORDS),
				.iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_UNDERFLOW(iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_UNDERFLOW),
				.iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_OVERFLOW(iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_OVERFLOW),
				.iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_WORDS(iREG_LINKSTATUS_CH0_REG_TSFIFOSTAT_WORDS),

        . iREG_LINKSTATUS_DROPPINGCH1                          ( CHF1_DROPPING                                      ),  // input
        . iREG_LINKSTATUS_DROPPINGCH0                          ( CHF0_DROPPING                                      ),  // input
        . iREG_LINKSTATUS_LOSIGCH1                             ( iSFP_PHY_LOSIG[1]                                  ),  // input
        . iREG_LINKSTATUS_LOSYNCCH1                            ( LOSYNC[1]                                         ),  // input
        . iREG_LINKSTATUS_LOSIGCH0                             ( iSFP_PHY_LOSIG[0]                                  ),  // input
        . iREG_LINKSTATUS_LOSYNCCH0                            ( LOSYNC[0]                                         ),  // input
        . iREG_LINKSTATUS_LINKSPEED                            ( REG_LINKSTATUS_LINKSPEED[3:0]                      ),  // input [3:0]
        . iREG_LINKFLUSH                                       ( REG_LINKFLUSH                                      ),  // input
        . iREG_TADALDATACTR_EN                                 ( REG_TADALDATACTR_EN                                ),  // input
        . iREG_TADALSTATCTR_EN                                 ( REG_TADALSTATCTR_EN                                ),  // input
        . iREG_TADALZEROCTR_EN                                 ( REG_TADALZEROCTR_EN                                ),  // input
        . iREG_DATALINKFIFOSTAT_UNDERFLOW                      ( REG_DATALINKFIFOSTAT_UNDERFLOW                     ),  // input
        . iREG_DATALINKFIFOSTAT_OVERFLOW                       ( REG_DATALINKFIFOSTAT_OVERFLOW                      ),  // input
        . iREG_DATALINKFIFOSTAT_WORDS                          ( REG_DATALINKFIFOSTAT_WORDS[12:0]                   ),  // input [12:0]
        . iREG_DATALINKFIFOLEVEL_V                             ( REG_DATALINKFIFOLEVEL_V                            ),  // input
        . iREG_DATALINKFIFOLEVEL_RD                            ( REG_DATALINKFIFOLEVEL_RD[12:0]                     ),  // input [12:0]
        . oREG_DATALINKFIFOLEVEL_WR                            ( REG_DATALINKFIFOLEVEL_WR[12:0]                     ),  // output [12:0]
        . oREG_DATALINKFIFOLEVEL_WR_EN                         ( REG_DATALINKFIFOLEVEL_WR_EN                        ),  // output
        . oREG_DATALINKFIFOLEVEL_RD_EN                         ( REG_DATALINKFIFOLEVEL_RD_EN                        ),  // output
        . iREG_INVLSTATSTOP_TOOSOON                            ( REG_INVLSTATSTOP_TOOSOON                           ),  // input
        . iREG_INVLSTATSTOP_UNDERFLOW                          ( REG_INVLSTATSTOP_UNDERFLOW                         ),  // input
        . iREG_INVLSTATSTOP_OVERFLOW                           ( REG_INVLSTATSTOP_OVERFLOW                          ),  // input
        . iREG_TAFIFOSTOP_INVLUNDERFLOW                        ( REG_TAFIFOSTOP_INVLUNDERFLOW                       ),  // input
        . iREG_TAFIFOSTOP_INVLOVERFLOW                         ( REG_TAFIFOSTOP_INVLOVERFLOW                        ),  // input
        . iREG_TAFIFOSTOP_CH1UNDERFLOW                         ( REG_TAFIFOSTOP_CH1UNDERFLOW                        ),  // input
        . iREG_TAFIFOSTOP_CH1OVERFLOW                          ( REG_TAFIFOSTOP_CH1OVERFLOW                         ),  // input
        . iREG_TAFIFOSTOP_CH0UNDERFLOW                         ( REG_TAFIFOSTOP_CH0UNDERFLOW                        ),  // input
        . iREG_TAFIFOSTOP_CH0OVERFLOW                          ( REG_TAFIFOSTOP_CH0OVERFLOW                         ),  // input
        . iREG_INVLDROPCTR_EN                                  ( REG_INVLDROPCTR_EN                                 )   // input
);

//////////////////////////////////////////////////////////////////////
// Link Engine Addr decoder
//////////////////////////////////////////////////////////////////////
/*  link_addr_decoder AUTO_TEMPLATE(
        .clk    (iCLK_CORE),
        .rst_n    (iRST_CORE_N),
                                .XX04_G_\(.*\)  (LK_GLOBAL_\1[]),
                                .CH\(.*\)       (CHAN\1[]),
);
*/
link_addr_decoder u_addr_dec(
        . clk                                                  ( iCLK_CORE                                          ),  // input
        . rst_n                                                ( iRST_CORE_N                                        ),  // input
        . iMM_ADDR                                             ( iMM_ADDR[16:0]                                     ),  // input [16:0]
        . iMM_WR_EN                                            ( iMM_WR_EN                                          ),  // input
        . iMM_RD_EN                                            ( iMM_RD_EN                                          ),  // input
        . iMM_WR_DATA                                          ( iMM_WR_DATA[63:0]                                  ),  // input [63:0]
        . oMM_RD_DATA                                          ( oMM_RD_DATA[63:0]                                  ),  // output [63:0]
        . oMM_RD_DATA_V                                        ( oMM_RD_DATA_V                                      ),  // output
        . XX04_G_ADDR                                          ( LK_GLOBAL_ADDR[16:0]                               ),  // output [16:0]
        . XX04_G_WR_DATA                                       ( LK_GLOBAL_WR_DATA[63:0]                            ),  // output [63:0]
        . XX04_G_WR_EN                                         ( LK_GLOBAL_WR_EN                                    ),  // output
        . XX04_G_RD_EN                                         ( LK_GLOBAL_RD_EN                                    ),  // output
        . XX04_G_RD_DATA                                       ( LK_GLOBAL_RD_DATA[63:0]                            ),  // input [63:0]
        . XX04_G_RD_DATA_V                                     ( LK_GLOBAL_RD_DATA_V                                ),  // input
        . CH0_ADDR                                             ( CHAN0_ADDR[16:0]                                   ),  // output [16:0]
        . CH0_WR_DATA                                          ( CHAN0_WR_DATA[63:0]                                ),  // output [63:0]
        . CH0_WR_EN                                            ( CHAN0_WR_EN                                        ),  // output
        . CH0_RD_EN                                            ( CHAN0_RD_EN                                        ),  // output
        . CH0_RD_DATA                                          ( CHAN0_RD_DATA[63:0]                                ),  // input [63:0]
        . CH0_RD_DATA_V                                        ( CHAN0_RD_DATA_V                                    ),  // input
        . CH1_ADDR                                             ( CHAN1_ADDR[16:0]                                   ),  // output [16:0]
        . CH1_WR_DATA                                          ( CHAN1_WR_DATA[63:0]                                ),  // output [63:0]
        . CH1_WR_EN                                            ( CHAN1_WR_EN                                        ),  // output
        . CH1_RD_EN                                            ( CHAN1_RD_EN                                        ),  // output
        . CH1_RD_DATA                                          ( CHAN1_RD_DATA[63:0]                                ),  // input [63:0]
        . CH1_RD_DATA_V                                        ( CHAN1_RD_DATA_V                                    )   // input
);
// Global Addr decoder
//////////////////////////////////////////////////////////////////////
/*   xx04_g_addr_decoder AUTO_TEMPLATE(
    .clk                    ( iCLK_CORE            ),
    .rst_n                  ( iRST_CORE_N          ),
    .\([a-z]\)MM_\(.*\)     ( LK_GLOBAL_\2[]        ),

    .CREDIT_STATS@_clk      ( iCLK_FC_RX[\1]        ),
    .CREDIT_STATS@_rst_n    ( iRST_FC_RX_N[\1]      ),
    .CSR_\(.*\)             ( LINKCTRL_\1[]     ),

);
*/
xx04_g_addr_decoder u_glb_addr_dec(
        . clk                                                  ( iCLK_CORE                                          ),  // input
        . rst_n                                                ( iRST_CORE_N                                        ),  // input
        . iMM_ADDR                                             ( LK_GLOBAL_ADDR[13:0]                               ),  // input [13:0]
        . iMM_WR_EN                                            ( LK_GLOBAL_WR_EN                                    ),  // input
        . iMM_RD_EN                                            ( LK_GLOBAL_RD_EN                                    ),  // input
        . iMM_WR_DATA                                          ( LK_GLOBAL_WR_DATA[63:0]                            ),  // input [63:0]
        . oMM_RD_DATA                                          ( LK_GLOBAL_RD_DATA[63:0]                            ),  // output [63:0]
        . oMM_RD_DATA_V                                        ( LK_GLOBAL_RD_DATA_V                                ),  // output
        . CSR_ADDR                                             ( LINKCTRL_ADDR[13:0]                                ),  // output [13:0]
        . CSR_WR_DATA                                          ( LINKCTRL_WR_DATA[63:0]                             ),  // output [63:0]
        . CSR_WR_EN                                            ( LINKCTRL_WR_EN                                     ),  // output
        . CSR_RD_EN                                            ( LINKCTRL_RD_EN                                     ),  // output
        . CSR_RD_DATA                                          ( LINKCTRL_RD_DATA[63:0]                             ),  // input [63:0]
        . CSR_RD_DATA_V                                        ( LINKCTRL_RD_DATA_V                                 ),  // input
        
        . CREDIT_STATS0_ADDR                                   ( CREDIT_STATS0_ADDR[13:0]                           ),  // output [13:0]
        . CREDIT_STATS0_WR_DATA                                ( CREDIT_STATS0_WR_DATA[63:0]                        ),  // output [63:0]
        . CREDIT_STATS0_WR_EN                                  ( CREDIT_STATS0_WR_EN                                ),  // output
        . CREDIT_STATS0_RD_EN                                  ( CREDIT_STATS0_RD_EN                                ),  // output
        . CREDIT_STATS0_RD_DATA                                ( CREDIT_STATS0_RD_DATA[63:0]                        ),  // input [63:0]
        . CREDIT_STATS0_RD_DATA_V                              ( CREDIT_STATS0_RD_DATA_V                            ),  // input
        . CREDIT_STATS0_clk                                    ( iCLK_FC_RX[0]                                      ),  // input
        . CREDIT_STATS0_rst_n                                  ( iRST_FC_RX_N[0]                                    ),  // input
        . CREDIT_STATS1_ADDR                                   ( CREDIT_STATS1_ADDR[13:0]                           ),  // output [13:0]
        . CREDIT_STATS1_WR_DATA                                ( CREDIT_STATS1_WR_DATA[63:0]                        ),  // output [63:0]
        . CREDIT_STATS1_WR_EN                                  ( CREDIT_STATS1_WR_EN                                ),  // output
        . CREDIT_STATS1_RD_EN                                  ( CREDIT_STATS1_RD_EN                                ),  // output
        . CREDIT_STATS1_RD_DATA                                ( CREDIT_STATS1_RD_DATA[63:0]                        ),  // input [63:0]
        . CREDIT_STATS1_RD_DATA_V                              ( CREDIT_STATS1_RD_DATA_V                            ),  // input
        . CREDIT_STATS1_clk                                    ( iCLK_FC_RX[1]                                      ),  // input
        . CREDIT_STATS1_rst_n                                  ( iRST_FC_RX_N[1]                                    )   // input
);

//vi_sync_1c #(4,1) status_linkspeed_sync
//(       // Outputs
        //.out                                   (REG_LINKSTATUS_LINKSPEED[3:0]),
        //// Inputs
        //.clk_dst                               (iCLK_FC_CORE),
        //.rst_n_dst                             (iRST_LINK_FC_CORE_N),
        //.in                                    (iLE_LINKSPEED[3:0])
//);

assign REG_LINKSTATUS_LINKSPEED = iLE_LINKSPEED; // synced to core domain in fc1

stats_clr_syn u_stats_clr_syn_0 (
        . oSTATS_LATCH_CLR_RXCLK                               ( STATS_LATCH_CLR_RXCLK[0]                           ),  // output
        . oSTATS_LATCH_CLR_DONE_LAT                            ( STATS_LATCH_CLR_DONE_LAT[0]                        ),  // output
        . oSTATS_MEM_DATA                                      ( STATS_CH0_MEM_DATA[127:0]                          ),  // output [127:0]
        . iRST_FC_CORE_N                                       ( iRST_LINK_FC_CORE_N                                ),  // input
        . iRST_FC_RX_N                                         ( iRST_FC_RX_N[0]                                    ),  // input
        . iCLK_FC_CORE                                         ( iCLK_FC_CORE                                       ),  // input
        . iCLK_FC_RX                                           ( iCLK_FC_RX[0]                                      ),  // input
        . iINT_STATS_LATCH_CLR                                 ( INT_STATS_LATCH_CLR                                ),  // input
        . iINT_STATS_MEM_RA                                    ( INT_STATS_CH0_MEM_RA[2:0]                          ),  // input [1:0]
        . iINT_STATS_BOTH_CH_DONE                              ( INT_STATS_BOTH_CH_DONE                             ),  // input
        . iINT_STATS_TIMECR                                    ( CH0_INT_STATS_TIMECR[31:0]                         ),  // input [31:0]
        . iINT_STATS_MINCR                                     ( CH0_INT_STATS_MINCR[31:0]                          ),  // input [31:0]
        . iINT_STATS_MAXCR                                     ( CH0_INT_STATS_MAXCR[31:0]                          ),  // input [31:0]
        . iINT_STATS_ENDCR                                     ( CH0_INT_STATS_ENDCR[31:0]                          ),  // input [31:0]
        . iINT_STATS_FC_CODE                                   ( CH0_INT_STATS_FC_CODE[31:0]                        ),  // input [31:0]
        . iINT_STATS_NOS_OLS                                   ( CH0_INT_STATS_NOS_OLS[31:0]                        ),  // input [31:0]
        . iINT_STATS_LR_LRR                                    ( CH0_INT_STATS_LR_LRR[31:0]                         ),  // input [31:0]
        . iINT_STATS_LINK_UP                                   ( CH0_INT_STATS_LINK_UP[31:0]                        ),  // input [31:0]
        . iINT_STATS_UP_LATCH                                  ( CH0_INT_STATS_UP_LATCH                             ),  // input
        . iINT_STATS_LR_LRR_LATCH                              ( CH0_INT_STATS_LR_LRR_LATCH                         ),  // input
        . iINT_STATS_NOS_LOS_LATCH                             ( CH0_INT_STATS_NOS_LOS_LATCH                        )   // input
);


stats_clr_syn u_stats_clr_syn_1 (
        . oSTATS_LATCH_CLR_RXCLK                               ( STATS_LATCH_CLR_RXCLK[1]                           ),  // output
        . oSTATS_LATCH_CLR_DONE_LAT                            ( STATS_LATCH_CLR_DONE_LAT[1]                        ),  // output
        . oSTATS_MEM_DATA                                      ( STATS_CH1_MEM_DATA[127:0]                          ),  // output [127:0]
        . iRST_FC_CORE_N                                       ( iRST_LINK_FC_CORE_N                                ),  // input
        . iRST_FC_RX_N                                         ( iRST_FC_RX_N[1]                                    ),  // input
        . iCLK_FC_CORE                                         ( iCLK_FC_CORE                                       ),  // input
        . iCLK_FC_RX                                           ( iCLK_FC_RX[1]                                      ),  // input
        . iINT_STATS_LATCH_CLR                                 ( INT_STATS_LATCH_CLR                                ),  // input
        . iINT_STATS_MEM_RA                                    ( INT_STATS_CH1_MEM_RA[2:0]                          ),  // input [1:0]
        . iINT_STATS_BOTH_CH_DONE                              ( INT_STATS_BOTH_CH_DONE                             ),  // input
        . iINT_STATS_TIMECR                                    ( CH1_INT_STATS_TIMECR[31:0]                         ),  // input [31:0]
        . iINT_STATS_MINCR                                     ( CH1_INT_STATS_MINCR[31:0]                          ),  // input [31:0]
        . iINT_STATS_MAXCR                                     ( CH1_INT_STATS_MAXCR[31:0]                          ),  // input [31:0]
        . iINT_STATS_ENDCR                                     ( CH1_INT_STATS_ENDCR[31:0]                          ),  // input [31:0]
        . iINT_STATS_FC_CODE                                   ( CH1_INT_STATS_FC_CODE[31:0]                        ),  // input [31:0]
        . iINT_STATS_NOS_OLS                                   ( CH1_INT_STATS_NOS_OLS[31:0]                        ),  // input [31:0]
        . iINT_STATS_LR_LRR                                    ( CH1_INT_STATS_LR_LRR[31:0]                         ),  // input [31:0]
        . iINT_STATS_LINK_UP                                   ( CH1_INT_STATS_LINK_UP[31:0]                        ),  // input [31:0]
        . iINT_STATS_UP_LATCH                                  ( CH1_INT_STATS_UP_LATCH                             ),  // input
        . iINT_STATS_LR_LRR_LATCH                              ( CH1_INT_STATS_LR_LRR_LATCH                         ),  // input
        . iINT_STATS_NOS_LOS_LATCH                             ( CH1_INT_STATS_NOS_LOS_LATCH                        )   // input
);

// monitor received frames on channel 0 and RRDY on channel 1
credit_stats u_credit_stats_0 (
        . oINT_STATS_TIMECR                                    ( CH0_INT_STATS_TIMECR[31:0]                         ),  // output [31:0]
        . oINT_STATS_MINCR                                     ( CH0_INT_STATS_MINCR[31:0]                          ),  // output [31:0]
        . oINT_STATS_MAXCR                                     ( CH0_INT_STATS_MAXCR[31:0]                          ),  // output [31:0]
        . oINT_STATS_ENDCR                                     ( CH0_INT_STATS_ENDCR[31:0]                          ),  // output [31:0]
        . clk                                                  ( {iCLK_FC_RX[1],iCLK_FC_RX[0]}                      ),  // input [1:0]
        . rst_n                                                ( {iRST_FC_RX_N[1],iRST_FC_RX_N[0]}                  ),  // input [1:0]
        . iRX_PRIMITIVE                                        ( CH1_RX_PRIMITIVE                                   ),  // input [11:0]
        . iRX_CLASS_VAL                                        ( CH0_RX_CLASS_VAL                                   ),  // input
        . iSFP_PHY_LOSIG                                       ( {iSFP_PHY_LOSIG[1],iSFP_PHY_LOSIG[0]}              ),  // input [1:0]
        . iSTATS_LATCH_CLR_RXCLK                               ( STATS_LATCH_CLR_RXCLK[0]                           ),  // input
        . iLINK_UP_EVENT                                       ( LINK_UP_EVENT[1:0]                                 ),  // input [1:0]
        . iREG_CREDITSTART                                     ( CH0_REG_CREDITSTART[31:0]                          )   // input [31:0]
);

// monitor received frames on channel 1 and RRDY on channel 0
credit_stats u_credit_stats_1 (
        . oINT_STATS_TIMECR                                    ( CH1_INT_STATS_TIMECR[31:0]                         ),  // output [31:0]
        . oINT_STATS_MINCR                                     ( CH1_INT_STATS_MINCR[31:0]                          ),  // output [31:0]
        . oINT_STATS_MAXCR                                     ( CH1_INT_STATS_MAXCR[31:0]                          ),  // output [31:0]
        . oINT_STATS_ENDCR                                     ( CH1_INT_STATS_ENDCR[31:0]                          ),  // output [31:0]
        . clk                                                  ( {iCLK_FC_RX[0],iCLK_FC_RX[1]}                      ),  // input [1:0]
        . rst_n                                                ( {iRST_FC_RX_N[0],iRST_FC_RX_N[1]}                  ),  // input [1:0]
        . iRX_PRIMITIVE                                        ( CH0_RX_PRIMITIVE                                   ),  // input [11:0]
        . iRX_CLASS_VAL                                        ( CH1_RX_CLASS_VAL                                   ),  // input
        . iSFP_PHY_LOSIG                                       ( {iSFP_PHY_LOSIG[0],iSFP_PHY_LOSIG[1]}              ),  // input [1:0]
        . iSTATS_LATCH_CLR_RXCLK                               ( STATS_LATCH_CLR_RXCLK[1]                           ),  // input
        . iLINK_UP_EVENT                                       ( LINK_UP_EVENT[1:0]                                 ),  // input [1:0]
        . iREG_CREDITSTART                                     ( CH1_REG_CREDITSTART[31:0]                          )   // input [31:0]
);

credit_stats_regs #(
        . LITE                                                 ( 0                                                  )
) u_credit_stats_regs_0 ( 
        . clk                                                  ( iCLK_FC_RX[0]                                      ),  // input
        . rst_n                                                ( iRST_FC_RX_N[0]                                    ),  // input
        //. clk                                                  ( iCLK_CORE                                      ),  // input
        //. rst_n                                                ( iRST_CORE_N                                    ),  // input
        . wr_en                                                ( CREDIT_STATS0_WR_EN                                ),  // input
        . rd_en                                                ( CREDIT_STATS0_RD_EN                                ),  // input
        . addr                                                 ( CREDIT_STATS0_ADDR[9:0]                            ),  // input [9:0]
        . wr_data                                              ( CREDIT_STATS0_WR_DATA[63:0]                        ),  // input [63:0]
        . rd_data                                              ( CREDIT_STATS0_RD_DATA[63:0]                        ),  // output [63:0]
        . rd_data_v                                            ( CREDIT_STATS0_RD_DATA_V                            ),  // output
        . oREG__SCRATCH                                        ( ),     // output [63:0]
        . iREG_TIMEMINCREDIT                                   ( ~mtip_enable0 ? int_stats_timecr[0] : CH0_INT_STATS_TIMECR[31:0]                         ),  // input [31:0]
        . iREG_CREDITBBMIN                                     ( ~mtip_enable0 ? int_stats_mincr[0]  : CH0_INT_STATS_MINCR[31:0]                          ),  // input [31:0]
        . iREG_CREDITBBMAX                                     ( ~mtip_enable0 ? int_stats_maxcr[0]  : CH0_INT_STATS_MAXCR[31:0]                          ),  // input [31:0]
        . iREG_CREDITCOUNTER                                   ( ~mtip_enable0 ? int_stats_endcr[0]  : CH0_INT_STATS_ENDCR[31:0]                          ),  // input [31:0]
        . oREG_CREDITSTART                                     ( CH0_REG_CREDITSTART[31:0]                          )   // output [31:0]
);
credit_stats_regs #(
        . LITE                                                 ( 0                                                  )
) u_credit_stats_regs_1 (
        . clk                                                  ( iCLK_FC_RX[1]                                      ),  // input
        . rst_n                                                ( iRST_FC_RX_N[1]                                    ),  // input
        //. clk                                                  ( iCLK_CORE                                      ),  // input
        //. rst_n                                                ( iRST_CORE_N                                    ),  // input
        . wr_en                                                ( CREDIT_STATS1_WR_EN                                ),  // input
        . rd_en                                                ( CREDIT_STATS1_RD_EN                                ),  // input
        . addr                                                 ( CREDIT_STATS1_ADDR[9:0]                            ),  // input [9:0]
        . wr_data                                              ( CREDIT_STATS1_WR_DATA[63:0]                        ),  // input [63:0]
        . rd_data                                              ( CREDIT_STATS1_RD_DATA[63:0]                        ),  // output [63:0]
        . rd_data_v                                            ( CREDIT_STATS1_RD_DATA_V                            ),  // output
        . oREG__SCRATCH                                        ( ),     // output [63:0]
        . iREG_TIMEMINCREDIT                                   ( ~mtip_enable1 ? int_stats_timecr[1] : CH1_INT_STATS_TIMECR[31:0]                         ),  // input [31:0]
        . iREG_CREDITBBMIN                                     ( ~mtip_enable1 ? int_stats_mincr[1]  : CH1_INT_STATS_MINCR[31:0]                          ),  // input [31:0]
        . iREG_CREDITBBMAX                                     ( ~mtip_enable1 ? int_stats_maxcr[1]  : CH1_INT_STATS_MAXCR[31:0]                          ),  // input [31:0]
        . iREG_CREDITCOUNTER                                   ( ~mtip_enable1 ? int_stats_endcr[1]  : CH1_INT_STATS_ENDCR[31:0]                          ),  // input [31:0]
        . oREG_CREDITSTART                                     ( CH1_REG_CREDITSTART[31:0]                          )   // output [31:0]
);

assign oCTL_DPLBUF_REQ = 'h0;
assign reg_fmac_credit_start[0] = CH0_REG_CREDITSTART;
assign reg_fmac_credit_start[1] = CH1_REG_CREDITSTART;


endmodule
