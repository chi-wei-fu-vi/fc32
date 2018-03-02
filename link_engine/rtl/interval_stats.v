/*************************************************************************** * Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: interval_stats.v$
* $Author: honda.yang $
* $Date: 2013-07-26 15:05:45 -0700 (Fri, 26 Jul 2013) $
* $Revision: 3055 $
* Description: Interval Stats Packager
*
***************************************************************************/
///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import common_cfg::*;
import fc1_pkg::*;
import fmac_pkg::*;

module interval_stats (

// Stats Source Modules
  output logic                                oINT_STATS_LATCH_CLR,

  // Time Arbiter
  output logic [127:0]                        oINVL_DAL_DATA,
  output logic                                oINVL_DAL_CH_ID,
  output logic [55:0]                         oINVL_GOOD_TS,
  output logic                                oINVL_GOOD_FIRST,
  output logic                                oINVL_GOOD_LAST,
  output logic                                oINVL_GTS_VALID,
  output logic                                oINVL_FTS_VALID,

  // Register
  output logic                                oREG_INVLSTATSTOP_OVERFLOW,
  output logic                                oREG_INVLSTATSTOP_UNDERFLOW,
  output logic                                oREG_INVLSTATSTOP_TOOSOON,

  // Other Link Engine
  output logic                                oLE_UC_RD_DONE,

  // uC Stats
  output logic                                oLE_UCSTATS_REQ,

  // uC Read
  output logic                                oINT_STATS_UC_START,
  output logic                                oINT_STATS_UC_CH_ID,

  // Register
  output logic                                oREG_INVLDATADROPCTR_EN,

// Synchronization
  output logic [2:0]                          oINT_STATS_CH0_MEM_RA,
  output logic [2:0]                          oINT_STATS_CH1_MEM_RA,
  output logic                                oINT_STATS_BOTH_CH_DONE,

  // Global
  input                                       clk,
  input                                       rst_n,

  // Configuration
  input        [3:0]                          iLINK_ID,

  // Global Timer
  input        [55:0]                         iGLOBAL_TIMESTAMP,
  input                                       iEND_OF_INTERVAL,

  // Time Arbiter
  input                                       iTA_INVL_DAL_READ,

  // ETH_MAC
  input fmac_pkg::fmac_interval_stats         iCH0_INT_STATS_FMAC,
  input fmac_pkg::fmac_interval_stats         iCH1_INT_STATS_FMAC,

  //input fc1_pkg::fc1_interval_stats           iCH0_INT_STATS_FC1,
  //input fc1_pkg::fc1_interval_stats           iCH1_INT_STATS_FC1,
        input logic [1:0] [31:0] iINT_STATS_FC1_CORR_EVENT_CNT,
        input logic [1:0] [31:0] iINT_STATS_FC1_UNCORR_EVENT_CNT,
        input logic [1:0] [31:0] iINT_STATS_FC1_PCS_LOS_CNT,



input [1:0] [31:0]    int_stats_endcr,         // From fmac_credit_stats of fmac_credit_stats.v
input [1:0] [31:0]    int_stats_maxcr,         // From fmac_credit_stats of fmac_credit_stats.v
input [1:0] [31:0]    int_stats_mincr,         // From fmac_credit_stats of fmac_credit_stats.v
input [1:0] [31:0]   int_stats_timecr,        // From fmac_credit_stats of fmac_credit_stats.v


  // Other Link Engine
  input                                       iLE_UC_RD_START,

  // uC Stats
  input                                       iUCSTATS_GNT,

  // uC Read
  input        [1:0]                          iUCR_STATS_FIFO_PUSH,
  input        [31:0]                         iUCR_STATS_ALARM,
  input        [31:0]                         iUCR_STATS_WARN,
  input        [15:0]                         iUCR_STATS_TXPWR,
  input        [15:0]                         iUCR_STATS_RXPWR,
  input        [15:0]                         iUCR_STATS_TEMP,

  // Register
  input        [3:0]                          iREG_LINKCTRL_MONITORMODE,

  input                                       mtip_enable,
  output logic                                oREG_INVLDROPCTR_EN,
  input        [3:0]                          iREG_LINKCTRL_LINKSPEED,

  // mtip
  input        [31:0]                         iCH0_INT_STATS_FC_CRC,
  input        [31:0]                         iCH0_INT_STATS_TRUNC,
  input        [31:0]                         iCH0_INT_STATS_BADEOF,
  input        [31:0]                         iCH0_INT_STATS_LOSIG,
  input        [31:0]                         iCH0_INT_STATS_LOSYNC,
  input        [31:0]                         iCH0_INT_STATS_FRAME_DROP,
  input        [31:0]                         iCH0_INT_STATS_NOS_OLS,
  input        [31:0]                         iCH0_INT_STATS_LR_LRR,
  input        [31:0]                         iCH0_INT_STATS_LINK_UP,
  input        [31:0]                         iCH0_INT_STATS_FC_CODE,
  input        [31:0]                         iCH0_INT_STATS_TIMECR,
  input        [31:0]                         iCH0_INT_STATS_MINCR,
  input        [31:0]                         iCH0_INT_STATS_MAXCR,
  input        [31:0]                         iCH0_INT_STATS_ENDCR,

  input                                       iCH0_INT_STATS_LOSIG_LATCH,
  input                                       iCH0_INT_STATS_LOSYNC_LATCH,
  input                                       iCH0_INT_STATS_UP_LATCH,
  input                                       iCH0_INT_STATS_LR_LRR_LATCH,
  input                                       iCH0_INT_STATS_NOS_LOS_LATCH,

  input        [31:0]                         iCH1_INT_STATS_FC_CRC,
  input        [31:0]                         iCH1_INT_STATS_TRUNC,
  input        [31:0]                         iCH1_INT_STATS_BADEOF,
  input        [31:0]                         iCH1_INT_STATS_LOSIG,
  input        [31:0]                         iCH1_INT_STATS_LOSYNC,
  input        [31:0]                         iCH1_INT_STATS_FRAME_DROP,
  input        [31:0]                         iCH1_INT_STATS_NOS_OLS,
  input        [31:0]                         iCH1_INT_STATS_LR_LRR,
  input        [31:0]                         iCH1_INT_STATS_LINK_UP,
  input        [31:0]                         iCH1_INT_STATS_FC_CODE,
  input        [31:0]                         iCH1_INT_STATS_TIMECR,
  input        [31:0]                         iCH1_INT_STATS_MINCR,
  input        [31:0]                         iCH1_INT_STATS_MAXCR,
  input        [31:0]                         iCH1_INT_STATS_ENDCR,

  input                                       iCH1_INT_STATS_LOSIG_LATCH,
  input                                       iCH1_INT_STATS_LOSYNC_LATCH,
  input                                       iCH1_INT_STATS_UP_LATCH,
  input                                       iCH1_INT_STATS_LR_LRR_LATCH,
  input                                       iCH1_INT_STATS_NOS_LOS_LATCH,

  input        [1:0]                          iSTATS_LATCH_CLR_DONE_LAT,
  input        [127:0]                        iSTATS_CH0_MEM_DATA,
  input        [127:0]                        iSTATS_CH1_MEM_DATA 

);


///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   INVL_IDLE_ST                = 0;
parameter   INVL_SYNC_ST                = 10;
parameter   INVL_CH0_PKT1_ST            = 1;
parameter   INVL_UCSTAT_REQ_ST          = 2;
parameter   INVL_CH0_UCSTAT_ST          = 3;
parameter   INVL_CH0_PKT2_ST            = 4;
parameter   INVL_CH0_PKT3_ST            = 5;
parameter   INVL_CH1_PKT1_ST            = 6;
parameter   INVL_CH1_UCSTAT_ST          = 7;
parameter   INVL_CH1_PKT2_ST            = 8;
parameter   INVL_CH1_PKT3_ST            = 9;

logic [128:0] stats_ctr_mux_r;
logic [31:0] losig_stats, losync_stats, nos_los_stats;
logic [31:0] lr_lrr_stats, link_up_stats, code_err_stats, crc_err_stats;
logic [31:0] trunc_stats, badeof_stats;
logic [31:0] timecr_stats, mincr_stats, maxcr_stats, endcr_stats;
logic [31:0] frame_drop_stats;
logic [1:0] ucr_stats_push_d1_r;
logic spd_chng_latch_stats_r;
logic [7:0] flag_latch_stats;
logic [7:0] lk_speed_eoi_r;
logic [3:0] linkspeed_r, linkspeed_d1_r;



logic [10:0] invl_state_r, invl_state_nxt;
logic [1:0] invl_pkt_cyc_r, invl_pkt_cyc_nxt;
logic channel_0_sel, pkt_1_sel, pkt_2_sel, pkt_3_sel;
fmac_pkg::fmac_interval_stats  mac_int_stats;
//fc1_pkg::fc1_interval_stats fc1_int_stats;

logic [31:0] INT_STATS_FC1_CORR_EVENT_CNT;
logic [31:0] INT_STATS_FC1_UNCORR_EVENT_CNT;
logic [31:0] INT_STATS_FC1_PCS_LOS_CNT;


//mac_pkg::stats_eth_type  eth_int_stats;
logic [128:0] interval_fifo_wd_r;
logic [143:0] interval_fifo_rd;
logic interval_fifo_push_r;
logic [55:0] stats_timestamp_r;
logic ucstat_gnt_r, uc_rd_start_r, end_of_interval_r;
logic [3:0] monitormode_r, monitormode_lat_r, invl_monitormode;
logic both_ch_clr_done_lat_r, end_of_invl, end_interval_d1_r, end_interval_edge, sample_timestamp;
logic invl_discard_lat_r, ucstats_req_off_nxt, ucstats_req_off_r;
logic [6:0] interval_fifo_usedw_r;
logic and_latch_clr_done, and_latch_clr_done_d1_r;


logic  [31:0]    int_stats_endcr_mux;         // From fmac_credit_stats of fmac_credit_stats.v
logic  [31:0]    int_stats_maxcr_mux;         // From fmac_credit_stats of fmac_credit_stats.v
logic  [31:0]    int_stats_mincr_mux;         // From fmac_credit_stats of fmac_credit_stats.v
logic  [31:0]   int_stats_timecr_mux;        // From fmac_credit_stats of fmac_credit_stats.v
///////////////////////////////////////////////////////////////////////////////
// Interval Stats FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
// Interval packets are 64 bytes which takes 4 entries.
// There are 6 interval packets per interval.
// The FIFO is 64 deep to store up to 16 packets. It is expected the next
// end of interval does not occur before the FIFO is empty again.
fifo1c64x144 #(
    .WRREQ_EARLY( 0                             ),
    .PIPE       ( 1                             )
)
u_invl_stat_fifo (
    .clk                ( clk                               ),
    .rst_n              ( rst_n                             ),
    .data               ( {15'b0, interval_fifo_wd_r}       ),
    .rdreq              ( iTA_INVL_DAL_READ                 ),
    .wrreq              ( interval_fifo_push_r              ),
    .highest_clr        ( 1'b0                              ),
    .almost_empty       (                                   ),
    .almost_full        (                                   ),
    .empty              (                                   ),
    .full               (                                   ),
    .q                  ( interval_fifo_rd                  ),
    .usedw              ( interval_fifo_usedw_r             ),
    .highest_dw         (                                   ),
    .overflow           ( oREG_INVLSTATSTOP_OVERFLOW        ),
    .underflow          ( oREG_INVLSTATSTOP_UNDERFLOW       )
);

assign oINVL_DAL_DATA  = interval_fifo_rd[127:0];
assign oINVL_DAL_CH_ID = interval_fifo_rd[128];

///////////////////////////////////////////////////////////////////////////////
// Flop Inputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        ucstat_gnt_r <= 1'b0;
        uc_rd_start_r <= 1'b0;
        end_of_interval_r <= 1'b0;
    end
    else begin
        ucstat_gnt_r <= iUCSTATS_GNT;
        uc_rd_start_r <= iLE_UC_RD_START;
        end_of_interval_r <= iEND_OF_INTERVAL;
    end

always_ff @( posedge clk ) begin
    monitormode_r <= iREG_LINKCTRL_MONITORMODE;
    linkspeed_r <= iREG_LINKCTRL_LINKSPEED;
    linkspeed_d1_r <= linkspeed_r;
end

always_ff @( posedge clk ) 
    if ( ~rst_n ) 
        monitormode_lat_r <= 4'b0;
    else if ( end_of_interval_r )
        monitormode_lat_r <= monitormode_r;

assign invl_monitormode = end_of_interval_r ? monitormode_r : monitormode_lat_r;

///////////////////////////////////////////////////////////////////////////////
// Stats Packet Framing State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    invl_state_nxt = 'h0;
    unique case ( 1'b1 )
        invl_state_r[ INVL_IDLE_ST ]: begin
            if ( uc_rd_start_r & ( invl_monitormode != 4'b0 ) )
                invl_state_nxt[ INVL_SYNC_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_IDLE_ST ] = 1'b1;
        end
        invl_state_r[ INVL_SYNC_ST ]: begin
            if ( oINT_STATS_BOTH_CH_DONE | both_ch_clr_done_lat_r )
                invl_state_nxt[ INVL_CH0_PKT1_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_SYNC_ST ] = 1'b1;
        end
        invl_state_r[ INVL_CH0_PKT1_ST ]: begin
            if ( invl_pkt_cyc_r == 3'd3 )
                invl_state_nxt[ INVL_UCSTAT_REQ_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_CH0_PKT1_ST ] = 1'b1;
        end
        invl_state_r[ INVL_UCSTAT_REQ_ST ]: begin
            if ( ucstat_gnt_r )
                invl_state_nxt[ INVL_CH0_UCSTAT_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_UCSTAT_REQ_ST ] = 1'b1;
        end
        invl_state_r[ INVL_CH0_UCSTAT_ST ]: begin
            if ( iUCR_STATS_FIFO_PUSH[1] )
                invl_state_nxt[ INVL_CH0_PKT2_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_CH0_UCSTAT_ST ] = 1'b1;
        end
        invl_state_r[ INVL_CH0_PKT2_ST ]: begin
            if ( invl_pkt_cyc_r == 3'd3 )
                invl_state_nxt[ INVL_CH0_PKT3_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_CH0_PKT2_ST ] = 1'b1;
        end
        invl_state_r[ INVL_CH0_PKT3_ST ]: begin
            if ( invl_pkt_cyc_r == 3'd3 )
                invl_state_nxt[ INVL_CH1_PKT1_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_CH0_PKT3_ST ] = 1'b1;
        end
        invl_state_r[ INVL_CH1_PKT1_ST ]: begin
            if ( invl_pkt_cyc_r == 3'd3 )
                invl_state_nxt[ INVL_CH1_UCSTAT_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_CH1_PKT1_ST ] = 1'b1;
        end
        invl_state_r[ INVL_CH1_UCSTAT_ST ]: begin
            if ( iUCR_STATS_FIFO_PUSH[1] )
                invl_state_nxt[ INVL_CH1_PKT2_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_CH1_UCSTAT_ST ] = 1'b1;
        end
        invl_state_r[ INVL_CH1_PKT2_ST ]: begin
            if ( invl_pkt_cyc_r == 3'd3 )
                invl_state_nxt[ INVL_CH1_PKT3_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_CH1_PKT2_ST ] = 1'b1;
        end
        invl_state_r[ INVL_CH1_PKT3_ST ]: begin
            if ( invl_pkt_cyc_r == 3'd3 )
                invl_state_nxt[ INVL_IDLE_ST ] = 1'b1;
            else
                invl_state_nxt[ INVL_CH1_PKT3_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        invl_state_r <= 'h0;
        invl_state_r[ INVL_IDLE_ST ] <= 1'b1;
    end
    else
        invl_state_r <= invl_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Packet Cycle Counter
///////////////////////////////////////////////////////////////////////////////
// Every interval packet takes 4 cycles to build
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        invl_pkt_cyc_r <= 2'b0;
    else
        invl_pkt_cyc_r <= invl_pkt_cyc_nxt;

always_comb
    if ( invl_state_r[ INVL_CH0_PKT1_ST ] | invl_state_r[ INVL_CH0_PKT2_ST ] |
         invl_state_r[ INVL_CH0_PKT3_ST ] | invl_state_r[ INVL_CH1_PKT1_ST ] |
         invl_state_r[ INVL_CH1_PKT2_ST ] | invl_state_r[ INVL_CH1_PKT3_ST ] |
         iUCR_STATS_FIFO_PUSH[0] | iUCR_STATS_FIFO_PUSH[1] )
        invl_pkt_cyc_nxt = invl_pkt_cyc_r + 2'b1;
    else
        invl_pkt_cyc_nxt = invl_pkt_cyc_r;

///////////////////////////////////////////////////////////////////////////////
// Channel Mux
///////////////////////////////////////////////////////////////////////////////
assign channel_0_sel = invl_state_r[ INVL_IDLE_ST       ] | invl_state_r[ INVL_CH0_PKT1_ST   ] |
                       invl_state_r[ INVL_UCSTAT_REQ_ST ] | invl_state_r[ INVL_CH0_UCSTAT_ST ] |
                       invl_state_r[ INVL_CH0_PKT2_ST   ] | invl_state_r[ INVL_CH0_PKT3_ST ];

assign losig_stats    = channel_0_sel ? iCH0_INT_STATS_LOSIG    : iCH1_INT_STATS_LOSIG;
assign losync_stats   = channel_0_sel ? iCH0_INT_STATS_LOSYNC   : iCH1_INT_STATS_LOSYNC;
//assign nos_los_stats  = channel_0_sel ? iCH0_INT_STATS_NOS_OLS  : iCH1_INT_STATS_NOS_OLS;
//assign lr_lrr_stats   = channel_0_sel ? iCH0_INT_STATS_LR_LRR   : iCH1_INT_STATS_LR_LRR;
//assign link_up_stats  = channel_0_sel ? iCH0_INT_STATS_LINK_UP  : iCH1_INT_STATS_LINK_UP;
//assign code_err_stats = channel_0_sel ? iCH0_INT_STATS_FC_CODE  : iCH1_INT_STATS_FC_CODE;
assign nos_los_stats  = channel_0_sel ? iSTATS_CH0_MEM_DATA[63 :32] : iSTATS_CH1_MEM_DATA[63 :32];
assign lr_lrr_stats   = channel_0_sel ? iSTATS_CH0_MEM_DATA[95 :64] : iSTATS_CH1_MEM_DATA[95 :64];
assign link_up_stats  = channel_0_sel ? iSTATS_CH0_MEM_DATA[127:96] : iSTATS_CH1_MEM_DATA[127:96];
assign code_err_stats = channel_0_sel ? iSTATS_CH0_MEM_DATA[31 :0 ] : iSTATS_CH1_MEM_DATA[31 :0 ];

assign crc_err_stats  = channel_0_sel ? iCH0_INT_STATS_FC_CRC   : iCH1_INT_STATS_FC_CRC;
assign trunc_stats    = channel_0_sel ? iCH0_INT_STATS_TRUNC    : iCH1_INT_STATS_TRUNC;
assign badeof_stats   = channel_0_sel ? iCH0_INT_STATS_BADEOF   : iCH1_INT_STATS_BADEOF;

assign flag_latch_stats[7:6] = 'h0;
assign flag_latch_stats[5]   = channel_0_sel ? iCH0_INT_STATS_LOSYNC_LATCH  : iCH1_INT_STATS_LOSYNC_LATCH;
assign flag_latch_stats[4]   = channel_0_sel ? iCH0_INT_STATS_LOSIG_LATCH   : iCH1_INT_STATS_LOSIG_LATCH;
//assign flag_latch_stats[3]   = channel_0_sel ? iCH0_INT_STATS_LR_LRR_LATCH  : iCH1_INT_STATS_LR_LRR_LATCH;
//assign flag_latch_stats[2]   = channel_0_sel ? iCH0_INT_STATS_NOS_LOS_LATCH : iCH1_INT_STATS_NOS_LOS_LATCH;
//assign flag_latch_stats[1]   = channel_0_sel ? iCH0_INT_STATS_UP_LATCH      : iCH1_INT_STATS_UP_LATCH;
assign flag_latch_stats[3:1] = channel_0_sel ? iSTATS_CH0_MEM_DATA[99:97]   : iSTATS_CH1_MEM_DATA[99:97];
assign flag_latch_stats[0]   = spd_chng_latch_stats_r;

//assign timecr_stats = channel_0_sel ? iCH0_INT_STATS_TIMECR : iCH1_INT_STATS_TIMECR;
//assign mincr_stats  = channel_0_sel ? iCH0_INT_STATS_MINCR  : iCH1_INT_STATS_MINCR;
//assign maxcr_stats  = channel_0_sel ? iCH0_INT_STATS_MAXCR  : iCH1_INT_STATS_MAXCR;
//assign endcr_stats  = channel_0_sel ? iCH0_INT_STATS_ENDCR  : iCH1_INT_STATS_ENDCR;
assign timecr_stats = channel_0_sel ? iSTATS_CH0_MEM_DATA[31 :0 ] : iSTATS_CH1_MEM_DATA[31 :0 ];
assign mincr_stats  = channel_0_sel ? iSTATS_CH0_MEM_DATA[63 :32] : iSTATS_CH1_MEM_DATA[63 :32];
assign maxcr_stats  = channel_0_sel ? iSTATS_CH0_MEM_DATA[95 :64] : iSTATS_CH1_MEM_DATA[95 :64];
assign endcr_stats  = channel_0_sel ? iSTATS_CH0_MEM_DATA[95 :64] : iSTATS_CH1_MEM_DATA[95 :64];


assign frame_drop_stats  = channel_0_sel ? iCH0_INT_STATS_FRAME_DROP : iCH1_INT_STATS_FRAME_DROP;



assign mac_int_stats = channel_0_sel ? iCH0_INT_STATS_FMAC : iCH1_INT_STATS_FMAC;
//assign fc1_int_stats = channel_0_sel ? iCH0_INT_STATS_FC1 : iCH1_INT_STATS_FC1;
        assign INT_STATS_FC1_CORR_EVENT_CNT = channel_0_sel ? iINT_STATS_FC1_CORR_EVENT_CNT[0] : iINT_STATS_FC1_CORR_EVENT_CNT[1];
        assign INT_STATS_FC1_UNCORR_EVENT_CNT = channel_0_sel ? iINT_STATS_FC1_UNCORR_EVENT_CNT[0] : iINT_STATS_FC1_UNCORR_EVENT_CNT[1]; 
        assign INT_STATS_FC1_PCS_LOS_CNT = channel_0_sel ? iINT_STATS_FC1_PCS_LOS_CNT[0] : iINT_STATS_FC1_PCS_LOS_CNT[1];

//assign eth_int_stats = channel_0_sel ? iCH0_INT_STATS_ETH : iCH1_INT_STATS_ETH;
assign int_stats_endcr_mux  = channel_0_sel ? int_stats_endcr[0] : int_stats_endcr[1]; 
assign int_stats_maxcr_mux  = channel_0_sel ? int_stats_maxcr[0] : int_stats_maxcr[1]; 
assign int_stats_mincr_mux  = channel_0_sel ? int_stats_mincr[0] : int_stats_mincr[1]; 
assign int_stats_timecr_mux = channel_0_sel ? int_stats_timecr[0] : int_stats_timecr[1];


assign pkt_1_sel = invl_state_r[ INVL_CH0_PKT1_ST ] | invl_state_r[ INVL_CH1_PKT1_ST ];
assign pkt_2_sel = invl_state_r[ INVL_CH0_PKT2_ST ] | invl_state_r[ INVL_CH0_UCSTAT_ST ] |
                   invl_state_r[ INVL_CH1_PKT2_ST ] | invl_state_r[ INVL_CH1_UCSTAT_ST ];
assign pkt_3_sel = invl_state_r[ INVL_CH0_PKT3_ST ] | invl_state_r[ INVL_CH1_PKT3_ST ];

///////////////////////////////////////////////////////////////////////////////
// Timestamp
///////////////////////////////////////////////////////////////////////////////
// All interval stats packets have the same timestamp
// Sample timestamp right before oINVL_FTS_VALID. If sampled too early, oINVL_GOOD_TS
// may carry older timestamp info when compared with data DAL.
always_ff @( posedge clk )
    if ( oINT_STATS_BOTH_CH_DONE )
        stats_timestamp_r <= iGLOBAL_TIMESTAMP;

// When multiple link engines access ucstats, it can take many nano-seconds.
// oINVL_FTS_VALID informs time arbiter to wait until interval stats packets
// are ready.
// Time Arbiter is not informed if interval packets are to be discarded.
//
// If monitor mode is turned off when iLE_UC_RD_START, oINVL_FTS_VALID must not
// be asserted as state machine is not started. Otherwise, the interval timestamp
// may be older than the data path. The data path can not be flushed.
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oINVL_FTS_VALID <= 1'b0;
    else begin
        if ( oINVL_FTS_VALID )
            oINVL_FTS_VALID <= ~invl_state_nxt[ INVL_UCSTAT_REQ_ST ];
        else
            oINVL_FTS_VALID <= oINT_STATS_BOTH_CH_DONE & ~invl_discard_lat_r &
                               ( invl_monitormode != 4'b0 );
    end

///////////////////////////////////////////////////////////////////////////////
// Interval FIFO Write
///////////////////////////////////////////////////////////////////////////////
// PCIe is little endian. Command type is at byte position 0.
// Timestamp is from byte 7 to 1 without byte swapping.
/*
always_ff @( posedge clk ) begin
    unique case ( {pkt_1_sel, pkt_2_sel} )
        // Packet 1
        2'b10: begin
            stats_ctr_mux_r[128  ] <= 1'b0;
            case ( invl_pkt_cyc_r )
                2'b00: begin
                    stats_ctr_mux_r[127:96] <= losync_stats;
                    stats_ctr_mux_r[95 :64] <= losig_stats;
                    stats_ctr_mux_r[63 :0 ] <= 64'b0;
                end
                2'b01: begin
                    stats_ctr_mux_r[127:96] <= link_up_stats;
                    stats_ctr_mux_r[95 :64] <= lr_lrr_stats;
                    stats_ctr_mux_r[63 :32] <= nos_los_stats;
                    stats_ctr_mux_r[31 :0 ] <= 'h0; // deprecated
                end
                2'b10: begin
                    stats_ctr_mux_r[127:96] <= badeof_stats;
                    stats_ctr_mux_r[95 :64] <= trunc_stats;
                    stats_ctr_mux_r[63 :32] <= crc_err_stats;
                    stats_ctr_mux_r[31 :0 ] <= code_err_stats;
                end
                2'b11: begin
                    stats_ctr_mux_r[127:125] <= 3'b0;
                    stats_ctr_mux_r[124]     <= 1'b0;
                    stats_ctr_mux_r[123:120] <= 1'b0;
                    stats_ctr_mux_r[119:112] <= 8'b0;     // packet number
                    stats_ctr_mux_r[111:104] <= 8'b0;
                    stats_ctr_mux_r[103:96 ] <= flag_latch_stats[7:0];
                    stats_ctr_mux_r[95 :64 ] <= mtip_enable? maxcr_stats : int_stats_maxcr_mux;
                    stats_ctr_mux_r[63 :32 ] <= mtip_enable? mincr_stats : int_stats_mincr_mux;
                    stats_ctr_mux_r[31 :0  ] <= mtip_enable? timecr_stats: int_stats_timecr_mux;
                end
            endcase
        end
        // Packet 2
        2'b01: begin
            stats_ctr_mux_r[128  ] <= 1'b0;
            if ( iUCR_STATS_FIFO_PUSH[0] ) begin
                stats_ctr_mux_r[127:0] <= 128'b0;
            end
            else if ( iUCR_STATS_FIFO_PUSH[1] ) begin
                stats_ctr_mux_r[127:96] <= 32'b0;
                stats_ctr_mux_r[95 :64] <= mtip_enable? endcr_stats : int_stats_endcr_mux;
                stats_ctr_mux_r[63 :32] <= 32'b0;
                stats_ctr_mux_r[31 :0 ] <= 32'b0;
            end
            else if ( invl_pkt_cyc_r == 2'd2 ) begin
                stats_ctr_mux_r[127:96] <= 32'b0;
                stats_ctr_mux_r[95 :64] <= 32'b0;
                stats_ctr_mux_r[63 :48] <= 16'b0;
                stats_ctr_mux_r[47 :16] <= frame_drop_stats;
                stats_ctr_mux_r[15 :0 ] <= 16'b0;
            end
            else
                stats_ctr_mux_r[127:0] <= 128'b0;
        end
        default: begin
            stats_ctr_mux_r[128:0] <= 129'b0;
        end
    endcase
end

*/


always_ff @( posedge clk ) 
    unique case ( {pkt_1_sel, pkt_2_sel, pkt_3_sel} )
        // Packet 1
        3'b100: begin
            interval_fifo_wd_r[128  ] <= ~channel_0_sel;
            case ( invl_pkt_cyc_r )
                2'b00: begin
                    interval_fifo_wd_r[127:96] <= {32{mtip_enable}} & losync_stats;
                    interval_fifo_wd_r[95:64] <=  losig_stats;
                    interval_fifo_wd_r[63 :0 ] <= {stats_timestamp_r, 4'b0, DAL_INVL_TYPE};
                end
                2'b01: begin
                    interval_fifo_wd_r[127:96] <= {32{mtip_enable}} & link_up_stats;
                    interval_fifo_wd_r[95 :64] <= {32{mtip_enable}} & lr_lrr_stats;
                    interval_fifo_wd_r[63 :32] <= {32{mtip_enable}} & nos_los_stats;
                    interval_fifo_wd_r[31 :0 ] <= {32{1'b0}};
                end
                2'b10: begin
                    interval_fifo_wd_r[127:96] <= {32{mtip_enable}} & badeof_stats;
                    interval_fifo_wd_r[95 :64] <= {32{mtip_enable}} & trunc_stats;
                    interval_fifo_wd_r[63 :32] <= {32{mtip_enable}} & crc_err_stats;
                    interval_fifo_wd_r[31 :0 ] <= {32{mtip_enable}} & code_err_stats;
                end
                2'b11: begin
                    interval_fifo_wd_r[127:125] <= {3{1'b0}};
                    interval_fifo_wd_r[124]     <= ~channel_0_sel;
                    interval_fifo_wd_r[123:120] <= iLINK_ID;
                    interval_fifo_wd_r[119:104] <= {16{1'b0}};
                    interval_fifo_wd_r[103:96 ] <= {8{mtip_enable}} &  flag_latch_stats[7:0];
                    interval_fifo_wd_r[95 :64 ] <= mtip_enable? maxcr_stats : int_stats_maxcr_mux;
                    interval_fifo_wd_r[63 :32 ] <= mtip_enable? mincr_stats : int_stats_mincr_mux;
                    interval_fifo_wd_r[31 :0  ] <= mtip_enable? timecr_stats: int_stats_timecr_mux;
                end
            endcase
        end
        // Packet 2
        3'b010: begin
            interval_fifo_wd_r[128  ] <= ~channel_0_sel;
            case ( invl_pkt_cyc_r )
                2'b00: begin
                    interval_fifo_wd_r[127:112] <= {16{1'b0}};
                    interval_fifo_wd_r[111:96 ] <= iUCR_STATS_TEMP;
                    interval_fifo_wd_r[95 :80 ] <= iUCR_STATS_RXPWR;
                    interval_fifo_wd_r[79 :64 ] <= iUCR_STATS_TXPWR;
                    interval_fifo_wd_r[63 :0  ] <= {stats_timestamp_r, 4'b0, DAL_INVL_TYPE};
                end
                2'b01: begin
                    interval_fifo_wd_r[127:96] <= {24'b0, lk_speed_eoi_r};
                    interval_fifo_wd_r[95 :64] <= mtip_enable? endcr_stats : int_stats_endcr_mux;
                    interval_fifo_wd_r[63 :32] <= iUCR_STATS_WARN;
                    interval_fifo_wd_r[31 :0 ] <= iUCR_STATS_ALARM;
                end
                2'b10: begin
                    interval_fifo_wd_r[127:96] <= {32{1'b0}};
                    interval_fifo_wd_r[95 :64] <= {32{1'b0}};
                    interval_fifo_wd_r[63 :48] <= {16{1'b0}};
                    interval_fifo_wd_r[47 :16] <= frame_drop_stats;
                    interval_fifo_wd_r[15 :0 ] <= {16{1'b0}};
                end
                2'b11: begin
                    interval_fifo_wd_r[127:125] <= 3'b0;
                    interval_fifo_wd_r[124]     <= ~channel_0_sel;
                    interval_fifo_wd_r[123:120] <= iLINK_ID;
                    interval_fifo_wd_r[119:112] <= 8'd1;     // packet number
                    interval_fifo_wd_r[111:96 ] <= 16'b0;
                    interval_fifo_wd_r[95 :64]  <= {32{1'b0}};
                    interval_fifo_wd_r[63 :32]  <= {32{1'b0}};
                    interval_fifo_wd_r[31 :0 ]  <= {32{1'b0}};
                end
            endcase
        end


        // Packet 3
        3'b001: begin
            interval_fifo_wd_r[128  ] <= ~channel_0_sel;
            case ( invl_pkt_cyc_r )
                2'b00: begin
                    interval_fifo_wd_r[127:96] <= !mtip_enable ? INT_STATS_FC1_CORR_EVENT_CNT : 'h0;
                    interval_fifo_wd_r[95 :64] <= !mtip_enable ? mac_int_stats.loss_sync_cnt : 'h0;
                    interval_fifo_wd_r[63 :0  ] <= {stats_timestamp_r, 4'b0, DAL_INVL_TYPE};
                end
                2'b01: begin
                    interval_fifo_wd_r[127:96] <= !mtip_enable ? mac_int_stats.link_up_cnt : 'h0;
                    interval_fifo_wd_r[95 :64] <= !mtip_enable ? mac_int_stats.code_viol_cnt : 'h0;
                    interval_fifo_wd_r[63 :32] <= !mtip_enable ? mac_int_stats.crc_err_cnt : 'h0;
                    interval_fifo_wd_r[32 :0]  <= !mtip_enable ? mac_int_stats.length_err_cnt : 'h0;
                end
                2'b10: begin
                    interval_fifo_wd_r[127:96] <= !mtip_enable ? INT_STATS_FC1_UNCORR_EVENT_CNT :'h0;
                    interval_fifo_wd_r[95 :64] <= !mtip_enable ? mac_int_stats.nos_ols_cnt : 'h0;
                    interval_fifo_wd_r[63 :32] <= !mtip_enable ? mac_int_stats.lr_lrr_cnt : 'h0;
                    interval_fifo_wd_r[31 :0]  <= !mtip_enable ? mac_int_stats.bad_eof_cnt : 'h0;
                end
                2'b11: begin
                    interval_fifo_wd_r[127:125] <= 3'b0;
                    interval_fifo_wd_r[124]     <= ~channel_0_sel;
                    interval_fifo_wd_r[123:120] <= iLINK_ID;
                    interval_fifo_wd_r[119:112] <= 8'd2;     // packet number
                    interval_fifo_wd_r[111:0 ] <= {112{1'b0}};
                end
            endcase
        end
        default: begin
            interval_fifo_wd_r[128:0] <= 129'b0;
        end
    endcase

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        interval_fifo_push_r <= 1'b0;
    else
        interval_fifo_push_r <= ( pkt_1_sel | iUCR_STATS_FIFO_PUSH[0] | iUCR_STATS_FIFO_PUSH[1] |
                                  ( pkt_2_sel & invl_pkt_cyc_r[1] ) | pkt_3_sel ) & ~invl_discard_lat_r;

///////////////////////////////////////////////////////////////////////////////
// Interval Packet Discard
///////////////////////////////////////////////////////////////////////////////
// When link FIFO is back pressured for long period of time, interval packets are
// discarded to avoid FIFO overflow. 
// FIFO level is checked at interval expiration to ensure 24 entries are available.
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        invl_discard_lat_r <= 1'b0;
    else if ( uc_rd_start_r )
        invl_discard_lat_r <= ( interval_fifo_usedw_r > 7'd40 );

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oREG_INVLDATADROPCTR_EN <= 1'b0;
    else
        oREG_INVLDATADROPCTR_EN <= uc_rd_start_r & ( interval_fifo_usedw_r > 7'd40 );

///////////////////////////////////////////////////////////////////////////////
// Counter Latch
///////////////////////////////////////////////////////////////////////////////
// iEND_OF_INTERVAL is gated off if monitor mode is OFF.
// Otherwise iEND_OF_INTERVAL is generated then oINVL_FTS_VALID before
// monitor is turned on. oINVL_FTS_VALID may prevent time arbiter from
// performing zero fill function.
assign end_of_invl = end_of_interval_r & ( invl_monitormode != 4'b0 );

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        end_interval_d1_r <= 1'b0;
        oINT_STATS_LATCH_CLR <= 1'b0;
    end
    else begin
        end_interval_d1_r <= end_of_invl;
        oINT_STATS_LATCH_CLR <= end_interval_edge;
    end

assign end_interval_edge = end_of_invl & ~end_interval_d1_r;

///////////////////////////////////////////////////////////////////////////////
// Time Arbiter Interface
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        oINVL_GTS_VALID <= 1'b0;
    else
        oINVL_GTS_VALID <= ( invl_pkt_cyc_nxt == 2'd3 ) & ~invl_discard_lat_r;

always_ff @( posedge clk ) begin
    oINVL_GOOD_FIRST <= invl_state_r[ INVL_CH0_PKT1_ST ];
    oINVL_GOOD_LAST  <= invl_state_r[ INVL_CH1_PKT3_ST ];
end

assign sample_timestamp = channel_0_sel & pkt_1_sel & ( invl_pkt_cyc_nxt == 2'd1 );

// oINVL_GTS_VALID and oINVL_GOOD_TS are forwarded one cycle early to
// help timestamp data forwarding timing in the Time Arbiter.
always_ff @( posedge clk )
    if ( sample_timestamp )
        oINVL_GOOD_TS <= stats_timestamp_r;

///////////////////////////////////////////////////////////////////////////////
// Errors
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oREG_INVLSTATSTOP_TOOSOON <= 1'b0;
    else if ( end_of_interval_r & ~invl_state_r[ INVL_IDLE_ST ] )
        oREG_INVLSTATSTOP_TOOSOON <= 1'b1;

///////////////////////////////////////////////////////////////////////////////
// uC Read Request
///////////////////////////////////////////////////////////////////////////////
// oLE_UCSTATS_REQ must be generated for link 0 even its monitor mode is off.
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        ucstats_req_off_r <= 1'b0;
    else
        ucstats_req_off_r <= ucstats_req_off_nxt;

always_comb begin
    if ( ucstats_req_off_r )
        ucstats_req_off_nxt = ~ucstat_gnt_r;
    else
        ucstats_req_off_nxt = uc_rd_start_r & ( invl_monitormode == 4'b0 );
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oLE_UCSTATS_REQ <= 1'b0;
    else
        oLE_UCSTATS_REQ <= invl_state_nxt[ INVL_UCSTAT_REQ_ST ] | ucstats_req_off_nxt;

///////////////////////////////////////////////////////////////////////////////
// uC Read Start
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oINT_STATS_UC_START <= 1'b0;
    else
        oINT_STATS_UC_START <= ( invl_state_r[ INVL_UCSTAT_REQ_ST ] & invl_state_nxt[ INVL_CH0_UCSTAT_ST ] ) |
                               ( invl_state_r[ INVL_CH1_PKT1_ST   ] & invl_state_nxt[ INVL_CH1_UCSTAT_ST ] );


always_ff @( posedge clk )
    oINT_STATS_UC_CH_ID <= ~channel_0_sel;

///////////////////////////////////////////////////////////////////////////////
// To Other Link Engine
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oLE_UC_RD_DONE <= 1'b0;
    else
        oLE_UC_RD_DONE <= ( invl_state_r[ INVL_CH1_PKT3_ST ] & invl_state_nxt[ INVL_IDLE_ST ] ) |
                          ( uc_rd_start_r & ( invl_monitormode == 4'b0 ) );

///////////////////////////////////////////////////////////////////////////////
// Synchronization FIFO Read
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        oINT_STATS_CH0_MEM_RA <= 'h0;
        oINT_STATS_CH1_MEM_RA <= 'h0;
    end
    else begin
        if ( invl_state_nxt[ INVL_CH0_PKT1_ST ] || invl_state_nxt[ INVL_CH0_PKT2_ST   ] ) begin
            if ( invl_pkt_cyc_nxt == 2'd3 )
                oINT_STATS_CH0_MEM_RA <= {invl_state_nxt[ INVL_CH0_PKT2_ST], 2'd3};
            else
                oINT_STATS_CH0_MEM_RA <= {invl_state_nxt[ INVL_CH0_PKT2_ST], invl_pkt_cyc_nxt + 2'b1};
        end
        else if ( invl_state_nxt[ INVL_UCSTAT_REQ_ST ] | invl_state_nxt[ INVL_CH0_UCSTAT_ST ] )
            oINT_STATS_CH0_MEM_RA <= oINT_STATS_CH0_MEM_RA;
        else
            oINT_STATS_CH0_MEM_RA <= 3'b0;

        if ( invl_state_nxt[ INVL_CH1_PKT1_ST ] || invl_state_nxt[ INVL_CH1_PKT2_ST   ])
            if ( invl_pkt_cyc_nxt == 2'd3 )
                oINT_STATS_CH1_MEM_RA <= {invl_state_nxt[ INVL_CH1_PKT2_ST   ], 2'd3};
            else
                oINT_STATS_CH1_MEM_RA <= {invl_state_nxt[ INVL_CH1_PKT2_ST   ], invl_pkt_cyc_nxt + 2'b1};
        else if ( invl_state_nxt[ INVL_CH1_UCSTAT_ST ] )
            oINT_STATS_CH1_MEM_RA <= oINT_STATS_CH1_MEM_RA;
        else
            oINT_STATS_CH1_MEM_RA <= 3'b0;
    end


///////////////////////////////////////////////////////////////////////////////
//// Link Speed
/////////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk )
    if ( oINT_STATS_BOTH_CH_DONE )
        case ( linkspeed_r )
            3'b010: lk_speed_eoi_r <= 8'd4;
            3'b011: lk_speed_eoi_r <= 8'd8;
            3'b100: lk_speed_eoi_r <= 8'd16;
            default: lk_speed_eoi_r <= 8'd16;
        endcase
/////////////////////////////////////////////////////////////////////////////////
// Latch Stats Flags
/////////////////////////////////////////////////////////////////////////////////
// Speed change stats is not synchronized and separated from other latched status
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        spd_chng_latch_stats_r <= 1'b0;
    else if ( end_interval_edge )
        spd_chng_latch_stats_r <= 1'b0;
    else if ( linkspeed_r != linkspeed_d1_r )
        spd_chng_latch_stats_r <= 1'b1;

///////////////////////////////////////////////////////////////////////////////
// Both Channel Latch Done 
///////////////////////////////////////////////////////////////////////////////
// oINT_STATS_BOTH_CH_DONE always one cycle wide.
assign and_latch_clr_done = &iSTATS_LATCH_CLR_DONE_LAT;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        and_latch_clr_done_d1_r <= 1'b0;
        oINT_STATS_BOTH_CH_DONE <= 1'b0;
    end
    else begin
        and_latch_clr_done_d1_r <= and_latch_clr_done;
        oINT_STATS_BOTH_CH_DONE <= and_latch_clr_done & ~and_latch_clr_done_d1_r;
    end

///////////////////////////////////////////////////////////////////////////////
// Latch Clear Done
///////////////////////////////////////////////////////////////////////////////
// oINT_STATS_BOTH_CH_DONE arrives before iLE_UC_RD_START for all link engines
// except LE0. oINT_STATS_BOTH_CH_DONE is latched until invl_state_r[ INVL_SYNC_ST ].
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        both_ch_clr_done_lat_r <= 1'b0;
    else begin
        if ( both_ch_clr_done_lat_r )
            both_ch_clr_done_lat_r <= ~invl_state_r[ INVL_SYNC_ST ];
        else
            both_ch_clr_done_lat_r <= oINT_STATS_BOTH_CH_DONE & ~invl_state_r[ INVL_SYNC_ST ];
    end



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
// end of interval occurs too soom
assert_end_of_interval_too_soon: assert property ( @( posedge clk )
    iEND_OF_INTERVAL |-> invl_state_r[ INVL_IDLE_ST ] );

// Interval too short
assert_interval_period_too_short: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( oREG_INVLSTATSTOP_TOOSOON ) );



// synopsys translate_on

endmodule
