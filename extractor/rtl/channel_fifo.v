/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: channel_fifo.v$
* $Author: honda.yang $
* $Date: 2013-07-22 16:29:59 -0700 (Mon, 22 Jul 2013) $
* $Revision: 2925 $
* Description: Channel FIFO storing extracted frames
*
***************************************************************************/

module channel_fifo (

// Time Arbiter
output logic [127:0]    oEXTR_DAT_DAL_DATA,
output logic            oEXTR_DAT_GTS_VALID,
output logic [55:0]     oEXTR_DAT_GOOD_TS,

// Packager
output logic            oCHF_DATCHNL_FIFO_AFULL,

// Interval Stats
output logic [31:0]     oINT_STATS_FRAME_DROP,

// Register
output logic            oCHF_REG_DATAFRAMEBPCTR_EN,
output logic            oCHF_REG_DATCHNLFIFOSTAT_UNDERFLOW,
output logic            oCHF_REG_DATCHNLFIFOSTAT_OVERFLOW,
output logic [9:0]      oCHF_REG_DATCHNLFIFOSTAT_WORDS,
output logic            oCHF_REG_DATCHNLFIFOLEVEL_V,
output logic [9:0]      oCHF_REG_DATCHNLFIFOLEVEL_RD,

// Link Engine Register
output logic            oCHF_DROPPING,

// Global
input                   clk,
input                   rst_n,

// Packager
input  [127:0]          iFMPG_CHF_DATA,
input                   iFMPG_CHF_SOP,
input                   iFMPG_CHF_VALID,

// Time Arbiter
input                   iTA_DAT_DAL_READ,

// Interval Stats
input                   iINT_STATS_LATCH_CLR,

// Register
input  [9:0]            iREG_DATCHNLFIFOLEVEL_WR,
input                   iREG_DATCHNLFIFOLEVEL_WR_EN,
input                   iREG_DATCHNLFIFOLEVEL_RD_EN  

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   CH_IDLE_ST                  = 0;
parameter   CH_SOP_ST                   = 1;
parameter   CH_READ2_ST                 = 2;
parameter   CH_READ3_ST                 = 3;
parameter   CH_READ4_ST                 = 4;
parameter   CH_GAP_ST                   = 5;

logic [127:0] channel_fifo_wd_r;
logic channel_fifo_push_r, channel_fifo_aempty;
logic channel_fifo_empty, channel_fifo_full;
logic fifo_afull_lat_r, frame_discard, chnl_fifo_nempty_r;
logic [5:0] ch_rd_state_nxt, ch_rd_state_r;
logic [55:0] timestamp_p1_r;
logic ts_valid_p1_r;

///////////////////////////////////////////////////////////////////////////////
// Data Frame Channel FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
fifo1c #(
    .ADDR_WIDTH ( DAT_CHNL_FIFO_ADDR_WIDTH      ),
    .DEPTH      ( DAT_CHNL_FIFO_DEPTH           ),
    .DATA_WIDTH ( DAT_CHNL_FIFO_DATA_WIDTH      ),
    .AFUL_THRES ( DAT_CHNL_FIFO_DEPTH - 10      ),
    .AEMP_THRES ( 6                             ),
    .PIPE       ( 1                             )
)
u_extr_chnl_fifo (
    .clk                ( clk                               ),
    .rst_n              ( rst_n                             ),
    .data               ( channel_fifo_wd_r                 ),
    .rdreq              ( iTA_DAT_DAL_READ                  ),
    .wrreq              ( channel_fifo_push_r               ),
    .highest_clr        ( iREG_DATCHNLFIFOLEVEL_WR_EN       ),
    .almost_empty       ( channel_fifo_aempty               ),
    .almost_full        ( oCHF_DATCHNL_FIFO_AFULL           ),
    .empty              ( channel_fifo_empty                ),
    .full               ( channel_fifo_full                 ),
    .q                  ( oEXTR_DAT_DAL_DATA                ),
    .usedw              ( oCHF_REG_DATCHNLFIFOSTAT_WORDS    ),
    .highest_dw         ( oCHF_REG_DATCHNLFIFOLEVEL_RD      ),
    .overflow           ( oCHF_REG_DATCHNLFIFOSTAT_OVERFLOW ),
    .underflow          ( oCHF_REG_DATCHNLFIFOSTAT_UNDERFLOW)
);

///////////////////////////////////////////////////////////////////////////////
// Channel FIFO Write
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        channel_fifo_push_r <= 1'b0;
    else 
        channel_fifo_push_r <= iFMPG_CHF_VALID & ~frame_discard;

always_ff @( posedge clk ) 
    channel_fifo_wd_r <= iFMPG_CHF_DATA;

///////////////////////////////////////////////////////////////////////////////
// FIFO Overflow
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        fifo_afull_lat_r <= 1'b0;
    else if ( iFMPG_CHF_SOP )
        fifo_afull_lat_r <= oCHF_DATCHNL_FIFO_AFULL;

assign frame_discard = iFMPG_CHF_SOP ? oCHF_DATCHNL_FIFO_AFULL : fifo_afull_lat_r;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oCHF_DROPPING <= 1'b0;
    else 
        oCHF_DROPPING <= iFMPG_CHF_VALID & frame_discard;

///////////////////////////////////////////////////////////////////////////////
// Drop Counter
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oCHF_REG_DATAFRAMEBPCTR_EN <= 1'b0;
    else
        oCHF_REG_DATAFRAMEBPCTR_EN <= iFMPG_CHF_SOP & oCHF_DATCHNL_FIFO_AFULL;

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Packager Interface
///////////////////////////////////////////////////////////////////////////////
// These counters are declared as FRC type in register space so the free
// running counter value is readable for debug purpose.
// The same counter is implemented here for Interval Stats purpose.
// The counter is latched to a shadow register and cleared at the same time
// upon iINT_STATS_LATCH_CLR.
invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_frame_drop_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_FRAME_DROP         ),
    .clk                    ( clk                           ),
    .rst_n                  ( rst_n                         ),
    .latch_clr              ( iINT_STATS_LATCH_CLR          ),
    .increment              ( oCHF_REG_DATAFRAMEBPCTR_EN    )
);

///////////////////////////////////////////////////////////////////////////////
// FIFO Empty
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        chnl_fifo_nempty_r <= 1'b0;
    else
        chnl_fifo_nempty_r <= ~channel_fifo_empty;

///////////////////////////////////////////////////////////////////////////////
// Time Arbiter Request State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    ch_rd_state_nxt = 6'b0;
    unique case ( 1'b1 )
        ch_rd_state_r[ CH_IDLE_ST ]: begin
            if ( chnl_fifo_nempty_r )
                ch_rd_state_nxt[ CH_SOP_ST ] = 1'b1;
            else
                ch_rd_state_nxt[ CH_IDLE_ST ] = 1'b1;
        end
        ch_rd_state_r[ CH_SOP_ST ]: begin
            if ( iTA_DAT_DAL_READ )
                ch_rd_state_nxt[ CH_READ2_ST ] = 1'b1;
            else
                ch_rd_state_nxt[ CH_SOP_ST ] = 1'b1;
        end
        ch_rd_state_r[ CH_READ2_ST ]: begin
            ch_rd_state_nxt[ CH_READ3_ST ] = 1'b1;
        end
        ch_rd_state_r[ CH_READ3_ST ]: begin
            ch_rd_state_nxt[ CH_READ4_ST ] = 1'b1;
        end
        ch_rd_state_r[ CH_READ4_ST ]: begin
            if ( channel_fifo_aempty )
                ch_rd_state_nxt[ CH_GAP_ST ] = 1'b1;
            else
                ch_rd_state_nxt[ CH_SOP_ST ] = 1'b1;
        end
        ch_rd_state_r[ CH_GAP_ST ]: begin
            if ( iTA_DAT_DAL_READ )
                ch_rd_state_nxt[ CH_READ2_ST ] = 1'b1;
            else
                ch_rd_state_nxt[ CH_IDLE_ST ] = 1'b1;
        end
        default: begin
            ch_rd_state_nxt[ CH_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        ch_rd_state_r <= 6'b0;
        ch_rd_state_r[ CH_IDLE_ST ] <= 1'b1;
    end
    else
        ch_rd_state_r <= ch_rd_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Time Arbiter Timestamp Interface
///////////////////////////////////////////////////////////////////////////////
// When a timestamp is written to channel FIFO, it is also forwarded to
// Time Arbiter. Escentially Time Arbiter has advanced information to
// compare two timestamp ahead of time for subsequent frames.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        ts_valid_p1_r    <= 1'b0;
        oEXTR_DAT_GTS_VALID <= 1'b0;
    end
    else begin
        ts_valid_p1_r    <= iFMPG_CHF_SOP & ~frame_discard;
        oEXTR_DAT_GTS_VALID <= ts_valid_p1_r;
    end

// oEXTR_DAT_GTS_VALID and oEXTR_DAT_GOOD_TS are forwarded one cycle early to
// help timestamp data forwarding timing in the Time Arbiter.
// Timestamp is at least significant byte position for little endianess format
// going to pcie.
always_ff @( posedge clk ) begin
    timestamp_p1_r    <= iFMPG_CHF_DATA[63:8];
    oEXTR_DAT_GOOD_TS <= timestamp_p1_r;
end

///////////////////////////////////////////////////////////////////////////////
// FIFO Level Monitor
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oCHF_REG_DATCHNLFIFOLEVEL_V <= 1'b0;
    else
        oCHF_REG_DATCHNLFIFOLEVEL_V <= iREG_DATCHNLFIFOLEVEL_RD_EN;



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
final begin
    assert_channel_fifo_empty: assert ( channel_fifo_empty == 1 );
    assert_state_machine_idle: assert ( ch_rd_state_r[ CH_IDLE_ST ] == 1 );
end


// synopsys translate_on

endmodule
