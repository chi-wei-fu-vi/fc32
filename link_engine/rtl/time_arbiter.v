/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: time_arbiter.v$
* $Author: honda.yang $
* $Date: 2013-11-26 14:14:27 -0800 (Tue, 26 Nov 2013) $
* $Revision: 4009 $
* Description: Timestamp arbitration between two channel FIFOS
*
***************************************************************************/

module

time_arbiter
#(
  parameter LINK_ID  =  0
)
(

// Channel FIFO 0
output logic            oTA_CH0_DAL_READ,
output logic            oTA_CH0_TS_FIFO_AFULL,

// Channel FIFO 1
output logic            oTA_CH1_DAL_READ,
output logic            oTA_CH1_TS_FIFO_AFULL,

// Interval Stats Packager
output logic            oTA_INVL_DAL_READ,

// Link FIFO
output logic [255:0]    oTA_LKF_DAL_DATA,
output logic            oTA_LKF_DAL_VALID,

// Register
output logic            oTA_REG_DALDATACTR_EN,
output logic            oTA_REG_DALSTATCTR_EN,
output logic            oTA_REG_DALZEROCTR_EN,
output logic            oREG_TAFIFOSTOP_CH0OVERFLOW,
output logic            oREG_TAFIFOSTOP_CH0UNDERFLOW,
output logic            oREG_TAFIFOSTOP_CH1OVERFLOW,
output logic            oREG_TAFIFOSTOP_CH1UNDERFLOW,
output logic            oREG_TAFIFOSTOP_INVLOVERFLOW,
output logic            oREG_TAFIFOSTOP_INVLUNDERFLOW,
output logic            oREG_LINKFLUSH,

// MTIP Interface
output logic            oTA_OFF_FILL_DONE,

// Global
input                   clk,
input                   rst_n,

// Configuration
input                   iDAL_CTL_DAT,               // 0=DAT, 1=CTL
input  [1:0]            iREG_LINKCTRL_DALCTLSZ,
input  [3:0]            iREG_LINKCTRL_MONITORMODE,

// Channel FIFO 0
input  [127:0]          iCH0_DAL_DATA,
input  [55:0]           iCH0_GOOD_TS,
input                   iCH0_GTS_VALID,

// Channel FIFO 1
input  [127:0]          iCH1_DAL_DATA,
input  [55:0]           iCH1_GOOD_TS,
input                   iCH1_GTS_VALID,

// Interval Stats Packager
input  [127:0]          iINVL_DAL_DATA,
input                   iINVL_DAL_CH_ID,
input  [55:0]           iINVL_GOOD_TS,       
input                   iINVL_GOOD_FIRST,
input                   iINVL_GOOD_LAST,
input                   iINVL_GTS_VALID,
input                   iINVL_FTS_VALID,

// Link FIFO
input                   iLKF_TA_AFULL,
input  [6:0]            iLKF_TA_OFST_WA,
input                   iLKF_TA_EMPTY,

// Future Timestamp FIFO 0
input  [107:0]          iCH0_FUTURE_TS,
input                   iCH0_FTS_VALID,

// Future Timestamp FIFO 1
input  [107:0]          iCH1_FUTURE_TS,
input                   iCH1_FTS_VALID, 

// MTIP Interface
input                   iCH0_OFF_FILL_REQ,
input                   iCH1_OFF_FILL_REQ

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
// user defined types
timestamp_bus ch0_future_fifo_rd, ch1_future_fifo_rd;
assign ch0_future_fifo_rd = iCH0_FUTURE_TS;
assign ch1_future_fifo_rd = iCH1_FUTURE_TS;

parameter   ARB_IDLE_ST                 = 0;
parameter   ARB_REQ_THREE_ST            = 1;
parameter   ARB_REQ_INVL_CH0_ST         = 2;
parameter   ARB_REQ_INVL_CH1_ST         = 3;
parameter   ARB_REQ_CH0_CH1_ST          = 4;
parameter   ARB_CHK_CH0_ST              = 5;
parameter   ARB_CHK_CH1_ST              = 6;
parameter   ARB_CHK_CH0_CH1_ST          = 7;
parameter   ARB_GNT_CH0_ST              = 8;
parameter   ARB_GNT_CH1_ST              = 9;
parameter   ARB_GNT_INVL_ST             = 10;
parameter   ARB_CHK_ZERO_ST             = 11;
parameter   ARB_GNT_ZERO_ST             = 12;
parameter   ARB_WAIT_CH0_ST             = 13;
parameter   ARB_WAIT_CH1_ST             = 14;
parameter   ARB_WAIT_INVL_ST            = 15;
parameter   ARB_DROP_ST                 = 16;
parameter   ARB_GAP_ST                  = 17;

parameter   FIRST_IDLE_ST               = 0;
parameter   FIRST_PEND_ST               = 1;
parameter   FIRST_SENT_ST               = 2;

parameter   OFF_FILL_IDLE_ST            = 0;
parameter   OFF_FILL_EMPTY_ST           = 1;
parameter   OFF_FILL_WAIT1_ST           = 2;
parameter   OFF_FILL_WAIT2_ST           = 3;
parameter   OFF_FILL_WAIT3_ST           = 4;
parameter   OFF_FILL_OFST_ST            = 5;
parameter   OFF_FILL_START_ST           = 6;
parameter   OFF_FILL_DONE_ST            = 7;

logic [17:0] arb_state_nxt, arb_state_r;
logic good_ch0_lt_good_ch1_r, good_ch0_lt_fut_ch1_r;
logic good_ch1_lt_fut_ch0_r, good_ch0_lt_good_invl_r;
logic good_ch1_lt_good_invl_r, good_invl_lt_fut_ch0_r;
logic good_invl_lt_fut_ch1_r;
logic gnt_ch0_st_d1_r, gnt_ch1_st_d1_r, gnt_invl_st_d1_r, gnt_zero_st_d1_r;
logic ch0_good_fifo_pop_r, ch0_good_fifo_mem_pop_r /* synthesis preserve */;
logic ch1_good_fifo_pop_r, ch1_good_fifo_mem_pop_r /* synthesis preserve */;
logic invl_good_fifo_pop_r, invl_good_fifo_mem_pop_r /* synthesis preserve */;
logic [127:0] prev_ch_fifo_data_r;
logic last_wr_in_blk, blk_assemble_st_r, wait_more_stats_r;
logic [5:0] chnl_read_ctr_r;
logic [63:0] ch0_good_timestamp_nxt, ch1_good_timestamp_nxt;
logic [55:0] invl_good_timestamp_nxt;
logic [55:0] ch0_good_ts_fwd_r, ch1_good_ts_fwd_r, invl_good_ts_fwd_r;
logic ch0_good_fifo_empty_r, ch0_good_fifo_empty_nxt;
logic ch1_good_fifo_empty_r, ch1_good_fifo_empty_nxt;
logic invl_good_fifo_empty_r, invl_good_fifo_empty_nxt;
logic last_chnl_read_r, read_ctr_odd_r, pkt_drop_window_r;
logic ch0_dat_invl_pop, ch1_dat_invl_pop, invl_first_pending;
logic [127:0] ch0_dal_data, ch1_dal_data, invl_dal_data;
logic [2:0] ch0_first_state_nxt, ch0_first_state_r;
logic [2:0] ch1_first_state_nxt, ch1_first_state_r;
logic ch0_first_pending_r, ch1_first_pending_r;
logic [57:0] invl_good_fifo_wd_r;
logic [63:0] invl_good_fifo_rd_nxt;
logic invl_good_last_r, invl_good_first_r;
logic ch0_gts_empty_fwd_r, ch1_gts_empty_fwd_r, invl_gts_empty_fwd_r;
logic invl_waiting_r, chan_waiting_r;
logic int_ch0_dal_read_r, int_ch1_dal_read_r, int_invl_dal_read_r /* synthesis preserve */;
logic int_ch0_dal_read_nxt, int_ch1_dal_read_nxt, int_invl_dal_read_nxt;
logic ext_ch0_dal_read_r, ext_ch1_dal_read_r, ext_invl_dal_read_r /* synthesis preserve */;
logic [3:0] monitormode_r;
logic [1:0] dalctlsz_r;
logic off_fill_start_st_r;
logic [7:0] off_fill_state_r, off_fill_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Good Channel 0 Timestamp FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
// FIFO read data and status are not flopped to help data forwarding 
// (ch0_good_ts_fwd_r) timing. 
fifo1c128x64 #(
    .PIPE       ( 0                             )
)
u_ch0_good_timestamp_fifo (
    .clk                ( clk                               ),
    .rst_n              ( rst_n                             ),
    .data               ( {8'b0, iCH0_GOOD_TS}              ),
    .rdreq              ( ch0_good_fifo_mem_pop_r           ),
    .wrreq              ( iCH0_GTS_VALID                    ),
    .highest_clr        ( 1'b0                              ),
    .almost_empty       (                                   ),
    .almost_full        ( oTA_CH0_TS_FIFO_AFULL             ),
    .empty              ( ch0_good_fifo_empty_nxt           ),
    .full               (                                   ),
    .q                  ( ch0_good_timestamp_nxt            ),
    .usedw              (                                   ),
    .highest_dw         (                                   ),
    .overflow           ( oREG_TAFIFOSTOP_CH0OVERFLOW       ),
    .underflow          ( oREG_TAFIFOSTOP_CH0UNDERFLOW      )
);

always_ff @( posedge clk ) 
    ch0_good_fifo_empty_r <= ch0_good_fifo_empty_nxt;

///////////////////////////////////////////////////////////////////////////////
// Good Channel 1 Timestamp FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
fifo1c128x64 #(
    .PIPE       ( 0                             )
)
u_ch1_good_timestamp_fifo (
    .clk                ( clk                               ),
    .rst_n              ( rst_n                             ),
    .data               ( {8'b0, iCH1_GOOD_TS}              ),
    .rdreq              ( ch1_good_fifo_mem_pop_r           ),
    .wrreq              ( iCH1_GTS_VALID                    ),
    .highest_clr        ( 1'b0                              ),
    .almost_empty       (                                   ),
    .almost_full        ( oTA_CH1_TS_FIFO_AFULL             ),
    .empty              ( ch1_good_fifo_empty_nxt           ),
    .full               (                                   ),
    .q                  ( ch1_good_timestamp_nxt            ),
    .usedw              (                                   ),
    .highest_dw         (                                   ),
    .overflow           ( oREG_TAFIFOSTOP_CH1OVERFLOW       ),
    .underflow          ( oREG_TAFIFOSTOP_CH1UNDERFLOW      )
);

always_ff @( posedge clk ) 
    ch1_good_fifo_empty_r <= ch1_good_fifo_empty_nxt;

///////////////////////////////////////////////////////////////////////////////
// Good Interval Stats Timestamp FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
fifo1c16x64 #(
    .PIPE       ( 0                             )
)
u_invl_stats_good_timestamp_fifo (
    .clk                ( clk                               ),
    .rst_n              ( rst_n                             ),
    .data               ( {6'b0, invl_good_fifo_wd_r}       ),
    .rdreq              ( invl_good_fifo_mem_pop_r          ),
    .wrreq              ( iINVL_GTS_VALID                   ),
    .highest_clr        ( 1'b0                              ),
    .almost_empty       (                                   ),
    .almost_full        (                                   ),
    .empty              ( invl_good_fifo_empty_nxt          ),
    .full               (                                   ),
    .q                  ( invl_good_fifo_rd_nxt             ),
    .usedw              (                                   ),
    .highest_dw         (                                   ),
    .overflow           ( oREG_TAFIFOSTOP_INVLOVERFLOW      ),
    .underflow          ( oREG_TAFIFOSTOP_INVLUNDERFLOW     )
);

assign invl_good_fifo_wd_r[57] = iINVL_GOOD_LAST;
assign invl_good_fifo_wd_r[56] = iINVL_GOOD_FIRST;
assign invl_good_fifo_wd_r[55:0] = iINVL_GOOD_TS;

always_ff @( posedge clk ) begin
    invl_good_fifo_empty_r <= invl_good_fifo_empty_nxt;
    invl_good_last_r       <= invl_good_fifo_rd_nxt[57];
    invl_good_first_r      <= invl_good_fifo_rd_nxt[56];
end

assign invl_good_timestamp_nxt = invl_good_fifo_rd_nxt[55:0];

///////////////////////////////////////////////////////////////////////////////
// Flop Inputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk ) begin
    monitormode_r <= iREG_LINKCTRL_MONITORMODE;
    dalctlsz_r <= iREG_LINKCTRL_DALCTLSZ;
end

///////////////////////////////////////////////////////////////////////////////
// Arbitration State Machine
///////////////////////////////////////////////////////////////////////////////
// 1) If all three Good timestamp FIFOS have at least one entry, three 
//    timestamps are simply compared.
// 2) If two Good timestamp FIFOS have at least one entry, 
//    A) If one of the requests is Interval Stats, check the Future timestamp 
//       FIFO of not-requesting channel
//       a) If Future timestamp FIFO is also empty, two Good timestamps are compared.
//       b) If Future timestamp FIFO is not empty, use the Future timestamp
//          for comparison.
//    B) If none of the requests is Interval Stats
//       Two channel Good timestamps are compared.
// 3) If only one Good timestamp FIFO has at least one entry, always check 
//    non-requesting Future timestamp FIFO.
//    A) If Future timestamp FIFO is also empty, grant the requesting FIFO.
//    B) If Future timestamp FIFO is not empty, use the Future timestamp 
//       for comparison.
//       a) If Future timestamp is smaller, wait for that channel FIFO to
//          become populated.
//       b) If Future timestamp is larger, grant the requesting FIFO.
//
// If interval good FIFO is about to be filled, wait for timestamp to become valid.
/*
generate
  if (LINK_ID == 5) begin: sigtap_gen_time_arb
//signaltap
wire [127:0] DEC_acq_data_in;
wire         DEC_acq_clk;

assign DEC_acq_clk = clk;

signaltap ARB_signaltap_inst (
  .acq_clk(DEC_acq_clk),
  .acq_data_in(DEC_acq_data_in),
  .acq_trigger_in(DEC_acq_data_in)
);

assign DEC_acq_data_in = {
//128
//112
//104
//96
//90
//72
//64
good_ch0_lt_good_ch1_r,
good_ch0_lt_good_invl_r,
good_ch1_lt_good_invl_r,
iCH1_FTS_VALID,
good_ch0_lt_fut_ch1_r,
good_invl_lt_fut_ch1_r,
iCH0_FTS_VALID,
good_ch1_lt_fut_ch0_r,
//56
chnl_read_ctr_r,
invl_waiting_r,
chan_waiting_r,
ch1_good_fifo_empty_r,
ch0_good_fifo_empty_r,
invl_good_fifo_empty_r,
arb_state_nxt[17:0],
//32
4'h0,
iINVL_GTS_VALID,
blk_assemble_st_r,
off_fill_start_st_r,
invl_gts_empty_fwd_r,
ch0_gts_empty_fwd_r,
ch1_gts_empty_fwd_r,
wait_more_stats_r,
iINVL_FTS_VALID,
invl_good_fifo_empty_r,
iLKF_TA_AFULL,
arb_state_r[17:0]
//16
//8
};

  end  // if LINK_ID, CH_ID
endgenerate
*/
always_comb begin
    arb_state_nxt = 18'b0;
    case ( 1'b1 )       // synopsys parallel_case
        arb_state_r[ ARB_IDLE_ST ]: begin
            if ( iLKF_TA_AFULL | ( iINVL_FTS_VALID & invl_good_fifo_empty_r ) )
                arb_state_nxt[ ARB_IDLE_ST ] = 1'b1;
            else if ( wait_more_stats_r )
                arb_state_nxt[ ARB_WAIT_INVL_ST ] = 1'b1;
            else
                case ( {invl_gts_empty_fwd_r, ch0_gts_empty_fwd_r, ch1_gts_empty_fwd_r} )
                    3'b000: arb_state_nxt[ ARB_REQ_THREE_ST    ] = 1'b1;
                    3'b001: arb_state_nxt[ ARB_REQ_INVL_CH0_ST ] = 1'b1;
                    3'b010: arb_state_nxt[ ARB_REQ_INVL_CH1_ST ] = 1'b1;
                    3'b011: arb_state_nxt[ ARB_CHK_CH0_CH1_ST  ] = 1'b1;
                    3'b100: arb_state_nxt[ ARB_REQ_CH0_CH1_ST  ] = 1'b1;
                    3'b101: arb_state_nxt[ ARB_CHK_CH1_ST      ] = 1'b1;
                    3'b110: arb_state_nxt[ ARB_CHK_CH0_ST      ] = 1'b1;
                    3'b111: begin
                            if ( blk_assemble_st_r | off_fill_start_st_r )
                                arb_state_nxt[ ARB_CHK_ZERO_ST ] = 1'b1;
                            else
                                arb_state_nxt[ ARB_IDLE_ST     ] = 1'b1;
                    end
                endcase
        end
        arb_state_r[ ARB_REQ_THREE_ST ]: begin
            if ( good_ch0_lt_good_ch1_r & good_ch0_lt_good_invl_r )
                arb_state_nxt[ ARB_GNT_CH0_ST ] = 1'b1;
            else if ( ~good_ch0_lt_good_ch1_r & good_ch1_lt_good_invl_r )
                arb_state_nxt[ ARB_GNT_CH1_ST ] = 1'b1;
            else
                arb_state_nxt[ ARB_GNT_INVL_ST ] = 1'b1;
        end
        arb_state_r[ ARB_REQ_INVL_CH0_ST ]: begin
            if ( good_ch0_lt_good_invl_r ) begin
                if ( ~iCH1_FTS_VALID | good_ch0_lt_fut_ch1_r )
                    arb_state_nxt[ ARB_GNT_CH0_ST ] = 1'b1;
                else
                    arb_state_nxt[ ARB_WAIT_CH1_ST ] = 1'b1;
            end
            else begin
                if ( ~iCH1_FTS_VALID | good_invl_lt_fut_ch1_r )
                    arb_state_nxt[ ARB_GNT_INVL_ST ] = 1'b1;
                else
                    arb_state_nxt[ ARB_WAIT_CH1_ST ] = 1'b1;
            end
        end
        arb_state_r[ ARB_REQ_INVL_CH1_ST ]: begin
            if ( good_ch1_lt_good_invl_r ) begin
                if ( ~iCH0_FTS_VALID | good_ch1_lt_fut_ch0_r )
                    arb_state_nxt[ ARB_GNT_CH1_ST ] = 1'b1;
                else
                    arb_state_nxt[ ARB_WAIT_CH0_ST ] = 1'b1;
            end
            else begin
                if ( ~iCH0_FTS_VALID | good_invl_lt_fut_ch0_r )
                    arb_state_nxt[ ARB_GNT_INVL_ST ] = 1'b1;
                else
                    arb_state_nxt[ ARB_WAIT_CH0_ST ] = 1'b1;
            end
        end
        arb_state_r[ ARB_REQ_CH0_CH1_ST ]: begin
            if ( good_ch0_lt_good_ch1_r ) 
                arb_state_nxt[ ARB_GNT_CH0_ST ] = 1'b1;
            else 
                arb_state_nxt[ ARB_GNT_CH1_ST ] = 1'b1;
        end
        arb_state_r[ ARB_CHK_CH0_ST ]: begin
            if ( ~iCH0_FTS_VALID | good_ch1_lt_fut_ch0_r )
                arb_state_nxt[ ARB_GNT_CH1_ST ] = 1'b1;
            else
                arb_state_nxt[ ARB_WAIT_CH0_ST ] = 1'b1;
        end
        arb_state_r[ ARB_CHK_CH1_ST ]: begin
            if ( ~iCH1_FTS_VALID | good_ch0_lt_fut_ch1_r )
                arb_state_nxt[ ARB_GNT_CH0_ST ] = 1'b1;
            else
                arb_state_nxt[ ARB_WAIT_CH1_ST ] = 1'b1;
        end
        arb_state_r[ ARB_CHK_CH0_CH1_ST ]: begin
            case ( {iCH0_FTS_VALID, iCH1_FTS_VALID} )
                2'b00: begin
                    arb_state_nxt[ ARB_GNT_INVL_ST ] = 1'b1;
                end
                2'b01: begin
                    if ( good_invl_lt_fut_ch1_r )
                        arb_state_nxt[ ARB_GNT_INVL_ST ] = 1'b1;
                    else
                        arb_state_nxt[ ARB_WAIT_CH1_ST ] = 1'b1;
                end
                2'b10: begin
                    if ( good_invl_lt_fut_ch0_r )
                        arb_state_nxt[ ARB_GNT_INVL_ST ] = 1'b1;
                    else
                        arb_state_nxt[ ARB_WAIT_CH0_ST ] = 1'b1;
                end
                2'b11: begin
                    case ( {good_invl_lt_fut_ch0_r, good_invl_lt_fut_ch1_r} )
                        2'b00: arb_state_nxt[ ARB_IDLE_ST     ] = 1'b1;
                        2'b01: arb_state_nxt[ ARB_WAIT_CH0_ST ] = 1'b1;
                        2'b10: arb_state_nxt[ ARB_WAIT_CH1_ST ] = 1'b1;
                        2'b11: arb_state_nxt[ ARB_GNT_INVL_ST ] = 1'b1;
                    endcase
                end
            endcase
        end
        arb_state_r[ ARB_GNT_CH0_ST ]: begin
            arb_state_nxt[ ARB_GAP_ST ] = 1'b1;
        end
        arb_state_r[ ARB_GNT_CH1_ST ]: begin
            arb_state_nxt[ ARB_GAP_ST ] = 1'b1;
        end
        arb_state_r[ ARB_GNT_INVL_ST ]: begin
            arb_state_nxt[ ARB_GAP_ST ] = 1'b1;
        end
        arb_state_r[ ARB_CHK_ZERO_ST ]: begin
            arb_state_nxt[ ARB_GNT_ZERO_ST ] = 1'b1;
        end
        arb_state_r[ ARB_GNT_ZERO_ST ]: begin
            arb_state_nxt[ ARB_GAP_ST ] = 1'b1;
        end
        arb_state_r[ ARB_WAIT_CH0_ST ]: begin
            // If frame is discarded in the pipeline, timestamp comparison resumes
            // after timestamp FIFO is popped.
            if ( ch0_good_fifo_empty_r ) begin
                if ( iCH0_FTS_VALID ) begin
                    if ( ( invl_waiting_r & good_invl_lt_fut_ch0_r ) | 
                         ( chan_waiting_r & good_ch1_lt_fut_ch0_r  ) )
                        arb_state_nxt[ ARB_DROP_ST ] = 1'b1;
                    else
                        arb_state_nxt[ ARB_WAIT_CH0_ST ] = 1'b1;
                end
                else
                    arb_state_nxt[ ARB_DROP_ST ] = 1'b1;
            end
            else
                arb_state_nxt[ ARB_GNT_CH0_ST ] = 1'b1;
        end
        arb_state_r[ ARB_WAIT_CH1_ST ]: begin
            if ( ch1_good_fifo_empty_r ) begin
                if ( iCH1_FTS_VALID ) begin
                    if ( ( invl_waiting_r & good_invl_lt_fut_ch1_r ) | 
                         ( chan_waiting_r & good_ch0_lt_fut_ch1_r  ) )
                        arb_state_nxt[ ARB_DROP_ST ] = 1'b1;
                    else
                        arb_state_nxt[ ARB_WAIT_CH1_ST ] = 1'b1;
                end
                else
                    arb_state_nxt[ ARB_DROP_ST ] = 1'b1;
            end
            else
                arb_state_nxt[ ARB_GNT_CH1_ST ] = 1'b1;
        end
        arb_state_r[ ARB_WAIT_INVL_ST ]: begin
            if ( invl_good_fifo_empty_r )
                arb_state_nxt[ ARB_WAIT_INVL_ST ] = 1'b1;
            else
                arb_state_nxt[ ARB_GNT_INVL_ST ] = 1'b1;
        end
        arb_state_r[ ARB_DROP_ST ]: begin
            arb_state_nxt[ ARB_GAP_ST ] = 1'b1;
        end
        arb_state_r[ ARB_GAP_ST ]: begin
            if ( chnl_read_ctr_r == 6'd2 )
                arb_state_nxt[ ARB_IDLE_ST ] = 1'b1;
            else
                arb_state_nxt[ ARB_GAP_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        arb_state_r <= 18'b0;
        arb_state_r[ ARB_IDLE_ST ] <= 1'b1;
    end
    else
        arb_state_r <= arb_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Timestamp Comparators
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk ) begin
    ch0_gts_empty_fwd_r  <= ch0_good_fifo_empty_nxt & ~iCH0_GTS_VALID;
    ch1_gts_empty_fwd_r  <= ch1_good_fifo_empty_nxt & ~iCH1_GTS_VALID;
    invl_gts_empty_fwd_r <= invl_good_fifo_empty_nxt & ~iINVL_GTS_VALID;
end

// Timestamp forwarding logic is flopped to optimize 56-bit comparison timing.
always_ff @( posedge clk ) begin
    ch0_good_ts_fwd_r  <= ( iCH0_GTS_VALID & ch0_good_fifo_empty_nxt ) ? iCH0_GOOD_TS : ch0_good_timestamp_nxt[55:0];
    ch1_good_ts_fwd_r  <= ( iCH1_GTS_VALID & ch1_good_fifo_empty_nxt ) ? iCH1_GOOD_TS : ch1_good_timestamp_nxt[55:0];
    invl_good_ts_fwd_r <= ( iINVL_GTS_VALID & invl_good_fifo_empty_nxt ) ? iINVL_GOOD_TS : invl_good_timestamp_nxt;
end

always_ff @( posedge clk ) begin
    good_ch0_lt_good_ch1_r  <= ch0_good_ts_fwd_r < ch1_good_ts_fwd_r;
    good_ch0_lt_fut_ch1_r   <= ch0_good_ts_fwd_r < ch1_future_fifo_rd.timestamp;
    good_ch1_lt_fut_ch0_r   <= ch1_good_ts_fwd_r < ch0_future_fifo_rd.timestamp;
    good_ch0_lt_good_invl_r <= ch0_good_ts_fwd_r < invl_good_ts_fwd_r;
    good_ch1_lt_good_invl_r <= ch1_good_ts_fwd_r < invl_good_ts_fwd_r;
    good_invl_lt_fut_ch0_r  <= invl_good_ts_fwd_r < ch0_future_fifo_rd.timestamp;
    good_invl_lt_fut_ch1_r  <= invl_good_ts_fwd_r < ch1_future_fifo_rd.timestamp;
end

///////////////////////////////////////////////////////////////////////////////
// Previous State
///////////////////////////////////////////////////////////////////////////////
// If frame is discarded in the pipeline, timestamp comparison resumes
// after future timestamp FIFO is popped.
// Either interval or one channel is waiting in ARB_WAIT_CH0_ST or
// ARB_WAIT_CH1_ST, the previous state is remembered to select proper
// comparator.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        invl_waiting_r <= 1'b0;
    else begin
        if ( invl_waiting_r )
            invl_waiting_r <= ~arb_state_r[ ARB_IDLE_ST ];
        else
            invl_waiting_r <= arb_state_r[ ARB_CHK_CH0_CH1_ST ] &
                              ( arb_state_nxt[ ARB_WAIT_CH0_ST ] | arb_state_nxt[ ARB_WAIT_CH1_ST ] );
    end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        chan_waiting_r <= 1'b0;
    else begin
        if ( chan_waiting_r )
            chan_waiting_r <= ~arb_state_r[ ARB_IDLE_ST ];
        else
            chan_waiting_r <= ( ~arb_state_r[ ARB_WAIT_CH0_ST ] & arb_state_nxt[ ARB_WAIT_CH0_ST ] ) |
                              ( ~arb_state_r[ ARB_WAIT_CH1_ST ] & arb_state_nxt[ ARB_WAIT_CH1_ST ] );
    end

///////////////////////////////////////////////////////////////////////////////
// 4KB Block Assemble
///////////////////////////////////////////////////////////////////////////////
// After Interval Stats are granted, block assemble state is entered until
// 4KB is completed. If there is no active requests during this time, all
// zero patterns are written to link FIFO.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        blk_assemble_st_r <= 1'b0;
    else begin
        if ( blk_assemble_st_r )
            blk_assemble_st_r <= ~last_wr_in_blk;
        else
            blk_assemble_st_r <= arb_state_r[ ARB_GNT_INVL_ST ] & ~last_wr_in_blk;
    end

assign last_wr_in_blk = ( iLKF_TA_OFST_WA == 7'h7e );

///////////////////////////////////////////////////////////////////////////////
// Monitor Mode Off Zero Fill
///////////////////////////////////////////////////////////////////////////////
// After monitor mode is turned off for a link, both channels are flushing 
// their last frames into the channel FIFO, then link FIFO. The link FIFO
// must be zero filled to complete the monitor mode transition.
//
// There is 4 cycle delay from ch_good_fifo_mem_pop_r (which results in timestamp
// FIFO empty) to the last oTA_LKF_DAL_VALID, then iLKF_TA_OFST_WA.
// Additional wait states are inserted following FIFO empty check in OFF_FILL_EMPTY_ST.
always_comb begin
    off_fill_state_nxt = 8'b0;
    unique case ( 1'b1 )
        off_fill_state_r[ OFF_FILL_IDLE_ST ]: begin
            if ( iCH0_OFF_FILL_REQ & iCH1_OFF_FILL_REQ )
                off_fill_state_nxt[ OFF_FILL_EMPTY_ST ] = 1'b1;
            else
                off_fill_state_nxt[ OFF_FILL_IDLE_ST ] = 1'b1;
        end
        off_fill_state_r[ OFF_FILL_EMPTY_ST ]: begin
            if ( invl_gts_empty_fwd_r & ch0_gts_empty_fwd_r & ch1_gts_empty_fwd_r & ~blk_assemble_st_r )
                off_fill_state_nxt[ OFF_FILL_WAIT1_ST ] = 1'b1;
            else
                off_fill_state_nxt[ OFF_FILL_EMPTY_ST ] = 1'b1;
        end
        off_fill_state_r[ OFF_FILL_WAIT1_ST ]: begin
            off_fill_state_nxt[ OFF_FILL_WAIT2_ST ] = 1'b1;
        end
        off_fill_state_r[ OFF_FILL_WAIT2_ST ]: begin
            off_fill_state_nxt[ OFF_FILL_WAIT3_ST ] = 1'b1;
        end
        off_fill_state_r[ OFF_FILL_WAIT3_ST ]: begin
            off_fill_state_nxt[ OFF_FILL_OFST_ST ] = 1'b1;
        end
        off_fill_state_r[ OFF_FILL_OFST_ST ]: begin
            if ( iLKF_TA_OFST_WA == 7'h00 )
                off_fill_state_nxt[ OFF_FILL_DONE_ST ] = 1'b1;
            else
                off_fill_state_nxt[ OFF_FILL_START_ST ] = 1'b1;
        end
        off_fill_state_r[ OFF_FILL_START_ST ]: begin
            if ( last_wr_in_blk )
                off_fill_state_nxt[ OFF_FILL_DONE_ST ] = 1'b1;
            else
                off_fill_state_nxt[ OFF_FILL_START_ST ] = 1'b1;
        end
        off_fill_state_r[ OFF_FILL_DONE_ST ]: begin
            if ( iCH0_OFF_FILL_REQ | iCH1_OFF_FILL_REQ )
                off_fill_state_nxt[ OFF_FILL_DONE_ST ] = 1'b1;
            else
                off_fill_state_nxt[ OFF_FILL_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        off_fill_state_r <= 8'b0;
        off_fill_state_r[ OFF_FILL_IDLE_ST ] <= 1'b1;
    end
    else
        off_fill_state_r <= off_fill_state_nxt;

assign off_fill_start_st_r = off_fill_state_r[ OFF_FILL_START_ST ];

assign oTA_OFF_FILL_DONE = off_fill_state_r[ OFF_FILL_DONE_ST ];

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Wait
///////////////////////////////////////////////////////////////////////////////
// Once the first interval stats is granted, the arbiter wait for the rest of
// stats packets as they all have the same timestamps.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        wait_more_stats_r <= 1'b0;
    else begin
        if ( wait_more_stats_r )
            wait_more_stats_r <= ~( arb_state_r[ ARB_GNT_INVL_ST ] & invl_good_last_r );
        else
            wait_more_stats_r <= arb_state_r[ ARB_GNT_INVL_ST ] & invl_good_first_r & ~iDAL_CTL_DAT;
    end

///////////////////////////////////////////////////////////////////////////////
// Channel FIFO Read
///////////////////////////////////////////////////////////////////////////////
// 1) Data DAL time arbiter
//    After channel is selected, the corresponding channel FIFO is read in
//    4 consecutive cycles.
// 2) Control DAL time arbiter
//    The control packet size is determined by iREG_LINKCTRL_DALCTLSZ
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        chnl_read_ctr_r <= 6'b0;
    else if ( arb_state_nxt[ ARB_GNT_CH0_ST  ] | arb_state_nxt[ ARB_GNT_CH1_ST  ] | 
              arb_state_nxt[ ARB_GNT_INVL_ST ] | arb_state_nxt[ ARB_GNT_ZERO_ST ] | 
              arb_state_nxt[ ARB_DROP_ST     ] ) begin
        if ( iDAL_CTL_DAT )
            case ( dalctlsz_r )
                2'b00: chnl_read_ctr_r <= 6'd7;
                2'b01: chnl_read_ctr_r <= 6'd15;
                2'b10: chnl_read_ctr_r <= 6'd31;
                2'b11: chnl_read_ctr_r <= 6'd63;
            endcase
        else
            chnl_read_ctr_r <= 6'd3;
    end
    else if ( chnl_read_ctr_r != 6'b0 )
        chnl_read_ctr_r <= chnl_read_ctr_r - 6'd1;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        gnt_ch0_st_d1_r <= 1'b0;
        gnt_ch1_st_d1_r <= 1'b0;
        gnt_invl_st_d1_r <= 1'b0;
        gnt_zero_st_d1_r <= 1'b0;
    end
    else begin
        gnt_ch0_st_d1_r <= arb_state_r[ ARB_GNT_CH0_ST ];
        gnt_ch1_st_d1_r <= arb_state_r[ ARB_GNT_CH1_ST ];
        gnt_invl_st_d1_r <= arb_state_r[ ARB_GNT_INVL_ST ];
        gnt_zero_st_d1_r <= arb_state_r[ ARB_GNT_ZERO_ST ];
    end

// Replicate ext_ch0_dal_read_r and int_ch0_dal_read_r flops. 
// ext_ch0_dal_read_r drives external FIFO while int_ch0_dal_read_r drives internal logic.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        ext_ch0_dal_read_r <= 1'b0;
        ext_ch1_dal_read_r <= 1'b0;
        ext_invl_dal_read_r <= 1'b0;
        int_ch0_dal_read_r <= 1'b0;
        int_ch1_dal_read_r <= 1'b0;
        int_invl_dal_read_r <= 1'b0;
    end
    else begin
        ext_ch0_dal_read_r <= int_ch0_dal_read_nxt;
        ext_ch1_dal_read_r <= int_ch1_dal_read_nxt;
        ext_invl_dal_read_r <= int_invl_dal_read_nxt;
        int_ch0_dal_read_r <= int_ch0_dal_read_nxt;
        int_ch1_dal_read_r <= int_ch1_dal_read_nxt;
        int_invl_dal_read_r <= int_invl_dal_read_nxt;
    end

always_comb begin
    if ( int_ch0_dal_read_r )
        int_ch0_dal_read_nxt = ~( chnl_read_ctr_r == 6'd0 ) | arb_state_nxt[ ARB_GNT_CH0_ST ];
    else
        int_ch0_dal_read_nxt = arb_state_nxt[ ARB_GNT_CH0_ST ];
    if ( int_ch1_dal_read_r )
        int_ch1_dal_read_nxt = ~( chnl_read_ctr_r == 6'd0 ) | arb_state_nxt[ ARB_GNT_CH1_ST ];
    else
        int_ch1_dal_read_nxt = arb_state_nxt[ ARB_GNT_CH1_ST ];
    if ( int_invl_dal_read_r )
        int_invl_dal_read_nxt = ~( chnl_read_ctr_r == 6'd0 ) | arb_state_nxt[ ARB_GNT_INVL_ST ];
    else
        int_invl_dal_read_nxt = arb_state_nxt[ ARB_GNT_INVL_ST ];
end

assign oTA_CH0_DAL_READ = ext_ch0_dal_read_r;
assign oTA_CH1_DAL_READ = ext_ch1_dal_read_r;
assign oTA_INVL_DAL_READ = ext_invl_dal_read_r;

///////////////////////////////////////////////////////////////////////////////
// Look-ahead Timestamp FIFO Pop
///////////////////////////////////////////////////////////////////////////////
// Look-ahead FIFO is popped when grant to read the next FIFO entry.
//
// Replicate ch*_good_fifo_pop_r and ch*_good_fifo_mem_pop_r
// ch*_good_fifo_mem_pop_r is dedicated to drive FIFO logic to speed up timing path
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        ch0_good_fifo_pop_r     <= 1'b0;
        ch0_good_fifo_mem_pop_r <= 1'b0;
        ch1_good_fifo_pop_r     <= 1'b0;
        ch1_good_fifo_mem_pop_r <= 1'b0;
    end
    else begin
        ch0_good_fifo_pop_r     <= arb_state_nxt[ ARB_GNT_CH0_ST ];
        ch0_good_fifo_mem_pop_r <= arb_state_nxt[ ARB_GNT_CH0_ST ];
        ch1_good_fifo_pop_r     <= arb_state_nxt[ ARB_GNT_CH1_ST ];
        ch1_good_fifo_mem_pop_r <= arb_state_nxt[ ARB_GNT_CH1_ST ];
    end

// Replicate invl_good_fifo_pop_r and invl_good_fifo_mem_pop_r
// invl_good_fifo_mem_pop_r is dedicated to drive FIFO logic to speed up timing path
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        invl_good_fifo_pop_r     <= 1'b0;
        invl_good_fifo_mem_pop_r <= 1'b0;
    end
    else begin
        invl_good_fifo_pop_r     <= arb_state_nxt[ ARB_GNT_INVL_ST ];
        invl_good_fifo_mem_pop_r <= arb_state_nxt[ ARB_GNT_INVL_ST ];
    end

///////////////////////////////////////////////////////////////////////////////
// Link FIFO Interface
///////////////////////////////////////////////////////////////////////////////
// ARB_DROP_ST state is extended to cover entire packet drop duration.
// oTA_LKF_DAL_VALID is gated off.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        pkt_drop_window_r <= 1'b0;
    else begin
        if ( pkt_drop_window_r )
            pkt_drop_window_r <= ~( chnl_read_ctr_r == 6'b1 );
        else
            pkt_drop_window_r <= arb_state_r[ ARB_DROP_ST ];
    end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        read_ctr_odd_r    <= 1'b0;
        oTA_LKF_DAL_VALID <= 1'b0;
    end
    else begin
        read_ctr_odd_r    <= chnl_read_ctr_r[0] & ~arb_state_r[ ARB_DROP_ST ] & ~pkt_drop_window_r;
        oTA_LKF_DAL_VALID <= read_ctr_odd_r;
    end

// First packet after link up in the first cycle
assign ch0_dat_invl_pop = ch0_good_fifo_pop_r | ( ~iINVL_DAL_CH_ID & invl_good_fifo_pop_r );
assign ch1_dat_invl_pop = ch1_good_fifo_pop_r | (  iINVL_DAL_CH_ID & invl_good_fifo_pop_r );

assign invl_first_pending = iINVL_DAL_CH_ID ? ch1_first_pending_r : ch0_first_pending_r;

// Packet type field is byte 0
// First packet bit is bit 7
assign ch0_dal_data = ch0_good_fifo_pop_r ? 
                      {iCH0_DAL_DATA[127:8], ch0_first_pending_r, iCH0_DAL_DATA[6:0]} : iCH0_DAL_DATA[127:0];
assign ch1_dal_data = ch1_good_fifo_pop_r ? 
                      {iCH1_DAL_DATA[127:8], ch1_first_pending_r, iCH1_DAL_DATA[6:0]} : iCH1_DAL_DATA[127:0];
assign invl_dal_data = invl_good_fifo_pop_r ? 
                      {iINVL_DAL_DATA[127:8], invl_first_pending, iINVL_DAL_DATA[6:0]} : iINVL_DAL_DATA[127:0];

// 128 to 256-bit conversion
// DAL command type and timestamp is at least significant position
// on either 128 or 256 bus.
always_ff @( posedge clk ) 
    case ( {int_ch0_dal_read_r, int_ch1_dal_read_r} )
        2'b10: prev_ch_fifo_data_r <= ch0_dal_data;
        2'b01: prev_ch_fifo_data_r <= ch1_dal_data;
        default: prev_ch_fifo_data_r <= invl_dal_data;
    endcase

always_ff @( posedge clk ) 
    case ( {int_ch0_dal_read_r, int_ch1_dal_read_r, int_invl_dal_read_r} )
        3'b100: oTA_LKF_DAL_DATA <= {iCH0_DAL_DATA,  prev_ch_fifo_data_r};
        3'b010: oTA_LKF_DAL_DATA <= {iCH1_DAL_DATA,  prev_ch_fifo_data_r};
        3'b001: oTA_LKF_DAL_DATA <= {iINVL_DAL_DATA, prev_ch_fifo_data_r};
        default: oTA_LKF_DAL_DATA <= 256'b0;
    endcase

///////////////////////////////////////////////////////////////////////////////
// Register Interface
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        oTA_REG_DALDATACTR_EN <= 1'b0;
        oTA_REG_DALSTATCTR_EN <= 1'b0;
        oTA_REG_DALZEROCTR_EN <= 1'b0;
    end
    else begin
        oTA_REG_DALDATACTR_EN <= gnt_ch0_st_d1_r | gnt_ch1_st_d1_r;
        oTA_REG_DALSTATCTR_EN <= gnt_invl_st_d1_r;
        oTA_REG_DALZEROCTR_EN <= gnt_zero_st_d1_r;
    end

///////////////////////////////////////////////////////////////////////////////
// Channel 0 First Packet after Loss of Sync
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    ch0_first_state_nxt = 3'b0;
    unique case ( 1'b1 )
        ch0_first_state_r[ FIRST_IDLE_ST ]: begin
            if ( monitormode_r == 4'b0 )
                ch0_first_state_nxt[ FIRST_IDLE_ST ] = 1'b1;
            else
                ch0_first_state_nxt[ FIRST_PEND_ST ] = 1'b1;
        end
        ch0_first_state_r[ FIRST_PEND_ST ]: begin
            if ( ch0_dat_invl_pop )
                ch0_first_state_nxt[ FIRST_SENT_ST ] = 1'b1;
            else
                ch0_first_state_nxt[ FIRST_PEND_ST ] = 1'b1;
        end
        ch0_first_state_r[ FIRST_SENT_ST ]: begin
            if ( monitormode_r == 4'b0 )
                ch0_first_state_nxt[ FIRST_IDLE_ST ] = 1'b1;
            else
                ch0_first_state_nxt[ FIRST_SENT_ST ] = 1'b1;
        end
        default: begin
            ch0_first_state_nxt[ FIRST_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        ch0_first_state_r <= 3'b0;
        ch0_first_state_r[ FIRST_IDLE_ST ] <= 1'b1;
    end
    else
        ch0_first_state_r <= ch0_first_state_nxt;

assign ch0_first_pending_r = ch0_first_state_r[ FIRST_PEND_ST ];

///////////////////////////////////////////////////////////////////////////////
// Channel 1 First Packet after Loss of Sync
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    ch1_first_state_nxt = 3'b0;
    unique case ( 1'b1 )
        ch1_first_state_r[ FIRST_IDLE_ST ]: begin
            if ( monitormode_r == 4'b0 )
                ch1_first_state_nxt[ FIRST_IDLE_ST ] = 1'b1;
            else
                ch1_first_state_nxt[ FIRST_PEND_ST ] = 1'b1;
        end
        ch1_first_state_r[ FIRST_PEND_ST ]: begin
            if ( ch1_dat_invl_pop )
                ch1_first_state_nxt[ FIRST_SENT_ST ] = 1'b1;
            else
                ch1_first_state_nxt[ FIRST_PEND_ST ] = 1'b1;
        end
        ch1_first_state_r[ FIRST_SENT_ST ]: begin
            if ( monitormode_r == 4'b0 )
                ch1_first_state_nxt[ FIRST_IDLE_ST ] = 1'b1;
            else
                ch1_first_state_nxt[ FIRST_SENT_ST ] = 1'b1;
        end
        default: begin
            ch1_first_state_nxt[ FIRST_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        ch1_first_state_r <= 3'b0;
        ch1_first_state_r[ FIRST_IDLE_ST ] <= 1'b1;
    end
    else
        ch1_first_state_r <= ch1_first_state_nxt;

assign ch1_first_pending_r = ch1_first_state_r[ FIRST_PEND_ST ];

///////////////////////////////////////////////////////////////////////////////
// Flush Done
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        oREG_LINKFLUSH <= 1'b1;
    else
        oREG_LINKFLUSH <= ch0_good_fifo_empty_r & ch1_good_fifo_empty_r &
                          invl_good_fifo_empty_r & iLKF_TA_EMPTY;



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////

final begin
    assert_arbiter_sm_idle: assert ( arb_state_r[ ARB_IDLE_ST ] == 1 );
end



// synopsys translate_on

endmodule
