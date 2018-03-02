/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: timestamp_fifo.v$
* $Author: honda.yang $
* $Date: 2013-11-26 14:14:27 -0800 (Tue, 26 Nov 2013) $
* $Revision: 4009 $
* Description: Timestamp FIFO
*
***************************************************************************/

module timestamp_fifo (

// Time Arbiter
output logic [107:0]        oFUTURE_TS,
output logic                oFTS_VALID,

// Extractor
output logic [107:0]        oEXTR_FUTURE_TS,

// Register
output logic [4:0]          oREG_TSFIFOSTAT_WORDS,
output logic                oREG_TSFIFOSTAT_OVERFLOW,
output logic                oREG_TSFIFOSTAT_UNDERFLOW,

// Global
input                       clk,
input                       rst_n,

// FIFO Push
input                       iTS_FIFO_PUSH,
input  [107:0]              iTS_FIFO_WD,

// FIFO Pop
input                       iTS_FIFO_POP

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   FTS_VLD_IDLE_ST             = 0;
parameter   FTS_VLD_NEMP_ST             = 1;
parameter   FTS_VLD_SET_ST              = 2;
parameter   FTS_VLD_EMP1_ST             = 3;
parameter   FTS_VLD_EMP2_ST             = 4;

logic [4:0] fts_vld_state_r, fts_vld_state_nxt;
logic [107:0] ts_fifo_rd_d1_r, ts_fifo_rd_d2_r, ts_fifo_wd_r;
logic ts_fifo_empty_r, ts_fifo_we_r;
logic [107:0] ts_fifo_rd_r;

///////////////////////////////////////////////////////////////////////////////
// Flop Write Path
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        ts_fifo_we_r <= 1'b0;
    else
        ts_fifo_we_r <= iTS_FIFO_PUSH;

always_ff @( posedge clk )
    ts_fifo_wd_r <= iTS_FIFO_WD;

///////////////////////////////////////////////////////////////////////////////
// Timestamp FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
fifo1c16x108 #(
    .PIPE       ( 1         )
)
u_fifo1c16x108 (
    .clk                ( clk                       ),
    .rst_n              ( rst_n                     ),
    .data               ( ts_fifo_wd_r              ),
    .rdreq              ( iTS_FIFO_POP              ),
    .wrreq              ( ts_fifo_we_r              ),
    .highest_clr        ( 1'b0                      ),
    .almost_empty       (                           ),
    .almost_full        (                           ),
    .empty              ( ts_fifo_empty_r           ),
    .full               (                           ),
    .q                  ( ts_fifo_rd_r              ),
    .usedw              (                           ),
    .highest_dw         ( oREG_TSFIFOSTAT_WORDS     ),
    .overflow           ( oREG_TSFIFOSTAT_OVERFLOW  ),
    .underflow          ( oREG_TSFIFOSTAT_UNDERFLOW )
);

assign oEXTR_FUTURE_TS = ts_fifo_rd_r[107:0];

///////////////////////////////////////////////////////////////////////////////
// Future Timestamp Valid State Machine
///////////////////////////////////////////////////////////////////////////////
// The state machine controls the timing of oFUTURE_TS and oFTS_VALID.
// Especially when the FIFO transitions in and out of empty state.
always_comb begin
    fts_vld_state_nxt = 5'b0;
    case ( 1'b1 )       // synopsys parallel_case
        fts_vld_state_r[ FTS_VLD_IDLE_ST ]: begin
            if ( ts_fifo_empty_r )
                fts_vld_state_nxt[ FTS_VLD_IDLE_ST ] = 1'b1;
            else
                fts_vld_state_nxt[ FTS_VLD_NEMP_ST ] = 1'b1;
        end
        fts_vld_state_r[ FTS_VLD_NEMP_ST ]: begin
            fts_vld_state_nxt[ FTS_VLD_SET_ST ] = 1'b1;
        end
        fts_vld_state_r[ FTS_VLD_SET_ST ]: begin
            if ( ts_fifo_empty_r )
                fts_vld_state_nxt[ FTS_VLD_EMP1_ST ] = 1'b1;
            else
                fts_vld_state_nxt[ FTS_VLD_SET_ST ] = 1'b1;
        end
        fts_vld_state_r[ FTS_VLD_EMP1_ST ]: begin
            fts_vld_state_nxt[ FTS_VLD_EMP2_ST ] = 1'b1;
        end
        fts_vld_state_r[ FTS_VLD_EMP2_ST ]: begin
            fts_vld_state_nxt[ FTS_VLD_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        fts_vld_state_r <= 5'b0;
        fts_vld_state_r[ FTS_VLD_IDLE_ST ] <= 1'b1;
    end
    else
        fts_vld_state_r <= fts_vld_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// FIFO Outputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk ) begin
    ts_fifo_rd_d1_r <= oEXTR_FUTURE_TS;
    ts_fifo_rd_d2_r <= ts_fifo_rd_d1_r;
end

always_ff @( posedge clk )
    if ( fts_vld_state_r[ FTS_VLD_IDLE_ST ] )
        oFUTURE_TS <= oEXTR_FUTURE_TS;
    else if ( fts_vld_state_r[ FTS_VLD_NEMP_ST ] )
        oFUTURE_TS <= ts_fifo_rd_d1_r;
    else
        oFUTURE_TS <= ts_fifo_rd_d2_r;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oFTS_VALID <= 1'b0;
    else
        oFTS_VALID <= fts_vld_state_nxt[ FTS_VLD_SET_ST  ] |
                      fts_vld_state_nxt[ FTS_VLD_EMP1_ST ] |
                      fts_vld_state_nxt[ FTS_VLD_EMP2_ST ] |
                      fts_vld_state_r[ FTS_VLD_EMP2_ST ];

// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
// FIFO underflow
assert_timestamp_fifo_underflow: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( oREG_TSFIFOSTAT_UNDERFLOW ) );

// FIFO overflow
assert_timestamp_fifo_overflow: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( oREG_TSFIFOSTAT_OVERFLOW ) );

// synopsys translate_on


endmodule

