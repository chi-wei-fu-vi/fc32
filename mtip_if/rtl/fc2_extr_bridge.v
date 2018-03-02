/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: fc2_extr_bridge.v$
* $Author: honda.yang $
* $Date: 2013-11-26 14:15:47 -0800 (Tue, 26 Nov 2013) $
* $Revision: 4010 $
* Description: MoreThanIP interface data path
*
***************************************************************************/

module fc2_extr_bridge (

// EXTRACTOR
output logic [63:0]     oMIF_EXTR_DATA,
output logic [2:0]      oMIF_EXTR_EMPTY,
output logic            oMIF_EXTR_SOP,
output logic            oMIF_EXTR_EOP,
output logic            oMIF_EXTR_ERR,
output logic            oMIF_EXTR_VALID,
output logic [2:0]      oMIF_EXTR_INDEX,
output logic            oMIF_EXTR_EXTRENABLE,

// Timestamp FIFO
output logic [107:0]    oDP_TIME_FIFO_WD,
output logic            oDP_TIME_FIFO_PUSH,

// Registers
output logic            oREG_FCSHORTERRCTR_EN,
output logic            oREG_FCFRMCTR_EN,
output logic            oREG_FRAMINGSTOP_B2BSOP,
output logic            oREG_FRAMINGSTOP_B2BEOP,

// Time Arbiter
output logic            oMIF_OFF_FILL_REQ,

// Global
input                   clk,
input                   rst_n,
input  [55:0]           iGLOBAL_TIMESTAMP,

// MoreThanIP
input  [31:0]           iFEB_BRG_DATA,
input                   iFEB_BRG_SOP,
input                   iFEB_BRG_DVAL,
input                   iFEB_BRG_EOP,
input                   iFEB_BRG_ERR,

// EXTRACTOR
input                   iEXTR_REG_EXTRENABLE,

// Time Arbiter
input                   iTA_OFF_FILL_DONE,

// Registers
input                   iREG_SINGLESTEP_MODE,
input                   iREG_SINGLESTEP_START,
input  [7:0]            iREG_SINGLESTEP_CNT,
input  [3:0]            iREG_LINKCTRL_MONITORMODE,

// Other Link Engine
input                   iINTERVAL_ANY_LINK

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import mtip_if_cfg::*;
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   STEP_IDLE_ST            = 0;
parameter   STEP_READY_ST           = 1;
parameter   STEP_CHECK_ST           = 2;
parameter   STEP_ENABLE_ST          = 3;

parameter   ACCU_IDLE_ST            = 0;
parameter   ACCU_SOP_ST             = 1;
parameter   ACCU_PARTIAL_ST         = 2;
parameter   ACCU_DONE_ST            = 3;
parameter   ACCU_PAUSE_ST           = 4;
parameter   ACCU_EOP_GAP_ST         = 5;

parameter   MONITOR_IDLE_ST         = 0;
parameter   MONITOR_CHK_ON_ST       = 1;
parameter   MONITOR_ENABLE_ST       = 2;
parameter   MONITOR_CHK_OFF_ST      = 3;
parameter   MONITOR_FLUSH_ST        = 4;
parameter   MONITOR_OTHER_ST        = 5;
parameter   MONITOR_ZERO_ST         = 6;

timestamp_bus time_fifo_wr_data;

logic [55:0] gbl_timestamp_r;
logic [31:0] mtip_rx_data_r, prev_mtip_data_r;
logic mtip_rx_sop_r, mtip_rx_dval_r, mtip_rx_eop_r, mtip_rx_err_r;
logic mif_extr_eop_nxt, mif_extr_err_nxt, mif_extr_sop_nxt;
logic mif_extr_vld_nxt, receive_enbl;
logic mtip_sop_p0, mtip_eop_p0, mtip_eop_p1_r, mtip_dval_p0, mtip_err_p0;
logic mtip_err_lat_r;
logic [7:0] step_frame_ctr_r;
logic [3:0] step_state_r, step_state_nxt;
logic [6:0] monitor_state_r, monitor_state_nxt;
logic [2:0] extr_empty_p1_r;
logic [5:0] accu_state_r, accu_state_nxt;
logic mtip_rx_sop_d1_r, mtip_sop_filter, mtip_eop_filter, mtip_dval_filter;
logic [2:0] mtip_len_dw_r;
logic short_force_err, frame_started_r, frame_ended_r;
logic [5:0] flush_ctr_r;
logic [3:0] monitormode_r;
logic extrenable_r, invl_any_link_r;

///////////////////////////////////////////////////////////////////////////////
// Flop All Inputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk )
    gbl_timestamp_r <= iGLOBAL_TIMESTAMP;

always_ff @( posedge clk ) begin
    mtip_rx_data_r   <= iFEB_BRG_DATA;
    mtip_rx_sop_r    <= iFEB_BRG_SOP;
    mtip_rx_dval_r   <= iFEB_BRG_DVAL;
    mtip_rx_eop_r    <= iFEB_BRG_EOP;
    mtip_rx_err_r    <= iFEB_BRG_ERR | short_force_err;
    mtip_rx_sop_d1_r <= mtip_rx_sop_r;
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        monitormode_r <= 4'b0;
        extrenable_r <= 1'b0;
    end
    else begin
        monitormode_r <= iREG_LINKCTRL_MONITORMODE;
        extrenable_r <= iEXTR_REG_EXTRENABLE;
    end

always_ff @( posedge clk ) begin
    invl_any_link_r <= iINTERVAL_ANY_LINK;
end

///////////////////////////////////////////////////////////////////////////////
// Short Frame Filter
///////////////////////////////////////////////////////////////////////////////
// Any incoming frames less than 3 cycles in length are filtered out.
assign mtip_sop_filter = mtip_rx_sop_r & ~iFEB_BRG_EOP & ~mtip_rx_eop_r;
assign mtip_eop_filter = mtip_rx_eop_r & ~mtip_rx_sop_d1_r & ~mtip_rx_sop_r;
assign mtip_dval_filter = mtip_rx_dval_r &
                          ~( ( mtip_rx_sop_r & ( iFEB_BRG_EOP     | mtip_rx_eop_r ) ) |
                             ( mtip_rx_eop_r & ( mtip_rx_sop_d1_r | mtip_rx_sop_r ) ) );

assign oREG_FCSHORTERRCTR_EN = mtip_rx_sop_r & ( iFEB_BRG_EOP | mtip_rx_eop_r );

assign oREG_FCFRMCTR_EN = mtip_rx_eop_r & mtip_rx_dval_r;

///////////////////////////////////////////////////////////////////////////////
// Pipeline Stage
///////////////////////////////////////////////////////////////////////////////
assign mtip_sop_p0   = mtip_sop_filter & mtip_dval_filter & receive_enbl;
assign mtip_eop_p0   = mtip_eop_filter & mtip_dval_filter & receive_enbl;
assign mtip_dval_p0  = mtip_dval_filter & receive_enbl;
assign mtip_err_p0   = mtip_rx_err_r & mtip_dval_filter & receive_enbl;

always_ff @( posedge clk ) 
    mtip_eop_p1_r <= mtip_eop_p0;

always_ff @( posedge clk ) 
    if ( mtip_eop_p0 )
        mtip_err_lat_r <= mtip_err_p0;

always_ff @( posedge clk ) 
    if ( mtip_dval_filter )
        prev_mtip_data_r  <= mtip_rx_data_r;

///////////////////////////////////////////////////////////////////////////////
// Extractor Output Enable
///////////////////////////////////////////////////////////////////////////////
// The last 32-bit may be sent out alone without the companion 32 bits at EOP time.
assign mif_extr_eop_nxt = ( mtip_eop_p0 & accu_state_r[ ACCU_PARTIAL_ST ] ) | accu_state_r[ ACCU_EOP_GAP_ST ];
assign mif_extr_err_nxt = ( mtip_err_p0 & mtip_eop_p0 & accu_state_r[ ACCU_PARTIAL_ST ] ) |
                          ( mtip_err_lat_r & accu_state_r[ ACCU_EOP_GAP_ST ] );

assign mif_extr_sop_nxt = accu_state_r[ ACCU_SOP_ST ] & mtip_dval_p0;

assign mif_extr_vld_nxt = accu_state_nxt[ ACCU_DONE_ST ] | accu_state_r[ ACCU_EOP_GAP_ST ];

///////////////////////////////////////////////////////////////////////////////
// DWORD Accumulation State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    accu_state_nxt = 6'b0;
    unique case ( 1'b1 )
        accu_state_r[ ACCU_IDLE_ST ]: begin
            if ( mtip_sop_p0 )
                accu_state_nxt[ ACCU_SOP_ST ] = 1'b1;
            else
                accu_state_nxt[ ACCU_IDLE_ST ] = 1'b1;
        end
        accu_state_r[ ACCU_SOP_ST ]: begin
            if ( mtip_dval_p0 )
                accu_state_nxt[ ACCU_DONE_ST ] = 1'b1;
            else
                accu_state_nxt[ ACCU_SOP_ST ] = 1'b1;
        end
        accu_state_r[ ACCU_PARTIAL_ST ]: begin
            if ( mtip_dval_p0 )
                accu_state_nxt[ ACCU_DONE_ST ] = 1'b1;
            else
                accu_state_nxt[ ACCU_PARTIAL_ST ] = 1'b1;
        end
        accu_state_r[ ACCU_DONE_ST ]: begin
            if ( mtip_eop_p1_r )
                accu_state_nxt[ ACCU_IDLE_ST ] = 1'b1;
            else if ( mtip_eop_p0 )
                accu_state_nxt[ ACCU_EOP_GAP_ST ] = 1'b1;
            else if ( mtip_dval_p0 )
                accu_state_nxt[ ACCU_PARTIAL_ST ] = 1'b1;
            else
                accu_state_nxt[ ACCU_PAUSE_ST ] = 1'b1;
        end
        accu_state_r[ ACCU_PAUSE_ST ]: begin
            if ( mtip_dval_p0 )
                accu_state_nxt[ ACCU_PARTIAL_ST ] = 1'b1;
            else
                accu_state_nxt[ ACCU_PAUSE_ST ] = 1'b1;
        end
        accu_state_r[ ACCU_EOP_GAP_ST ]: begin
            accu_state_nxt[ ACCU_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        accu_state_r <= 6'b0;
        accu_state_r[ ACCU_IDLE_ST ] <= 1'b1;
    end
    else
        accu_state_r <= accu_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Extractor Outputs 
///////////////////////////////////////////////////////////////////////////////
assign oMIF_EXTR_INDEX = 3'b1;

always_ff @( posedge clk )
    if ( ~rst_n ) begin
        oMIF_EXTR_SOP <= 1'b0;
        oMIF_EXTR_EOP <= 1'b0;
        oMIF_EXTR_ERR <= 1'b0;
        oMIF_EXTR_VALID <= 1'b0;
    end
    else begin
        oMIF_EXTR_SOP <= mif_extr_sop_nxt;
        oMIF_EXTR_EOP <= mif_extr_eop_nxt;
        oMIF_EXTR_ERR <= mif_extr_err_nxt;
        oMIF_EXTR_VALID <= mif_extr_vld_nxt;
    end

always_ff @( posedge clk )
    oMIF_EXTR_DATA <= {prev_mtip_data_r, mtip_rx_data_r};

always_ff @( posedge clk )
    if ( mtip_eop_p0 & ~mif_extr_vld_nxt )
        extr_empty_p1_r <= 3'd4;
    else
        extr_empty_p1_r <= 3'd0;

always_ff @( posedge clk )
    oMIF_EXTR_EMPTY <= extr_empty_p1_r;

///////////////////////////////////////////////////////////////////////////////
// Short Error Frames
///////////////////////////////////////////////////////////////////////////////
// Sometimes MTIP does not assert ff_rx_err for truncated small frames.
// Error is enforced if frames are less than or equal to 16 bytes.
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        mtip_len_dw_r <= 3'b0;
    else if ( iFEB_BRG_SOP )
        mtip_len_dw_r <= 3'b1;
    else if ( iFEB_BRG_DVAL ) begin
        if ( mtip_len_dw_r < 3'd7)
            mtip_len_dw_r <= mtip_len_dw_r + 3'b1;
        else
            mtip_len_dw_r <= mtip_len_dw_r;
    end

assign short_force_err = iFEB_BRG_EOP & iFEB_BRG_DVAL & ( mtip_len_dw_r < 3'd4 );

///////////////////////////////////////////////////////////////////////////////
// Timestamp FIFO Push
///////////////////////////////////////////////////////////////////////////////
// When a frame arrives from MTIP, timestamp and other attributes are
// pushed into a FIFO. After the frame is extracted, it is popped from the
// FIFO. Otherwise, many pipeline registers are required to store these
// attributes along with the frames.

assign time_fifo_wr_data.timestamp = gbl_timestamp_r;
assign time_fifo_wr_data.index     = 3'b1;
assign time_fifo_wr_data.vlan_vld  = 1'b0;
assign time_fifo_wr_data.vlan      = 16'b0;
assign time_fifo_wr_data.fcmap     = 24'b0;
assign time_fifo_wr_data.reserved  = 8'b0;

assign oDP_TIME_FIFO_PUSH = mtip_sop_p0;
assign oDP_TIME_FIFO_WD = time_fifo_wr_data;

///////////////////////////////////////////////////////////////////////////////
// Single Step State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    step_state_nxt = 4'b0;
    unique case ( 1'b1 )
        step_state_r[ STEP_IDLE_ST ]: begin
            if ( iREG_SINGLESTEP_MODE & ~mtip_dval_filter )
                step_state_nxt[ STEP_READY_ST ] = 1'b1;
            else
                step_state_nxt[ STEP_IDLE_ST ] = 1'b1;
        end
        step_state_r[ STEP_READY_ST ]: begin
            if ( iREG_SINGLESTEP_MODE ) begin
                if ( iREG_SINGLESTEP_START )
                    step_state_nxt[ STEP_CHECK_ST ] = 1'b1;
                else
                    step_state_nxt[ STEP_READY_ST ] = 1'b1;
            end
            else
                step_state_nxt[ STEP_IDLE_ST ] = 1'b1;
        end
        // Make sure frame is not flowing before enabling
        step_state_r[ STEP_CHECK_ST ]: begin
            if ( mtip_dval_filter )
                step_state_nxt[ STEP_CHECK_ST ] = 1'b1;
            else
                step_state_nxt[ STEP_ENABLE_ST ] = 1'b1;
        end
        step_state_r[ STEP_ENABLE_ST ]: begin
            if ( step_frame_ctr_r == iREG_SINGLESTEP_CNT )
                step_state_nxt[ STEP_IDLE_ST ] = 1'b1;
            else
                step_state_nxt[ STEP_ENABLE_ST ] = 1'b1;
        end
        default: begin
            step_state_nxt[ STEP_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        step_state_r <= 4'b0;
        step_state_r[ STEP_IDLE_ST ] <= 1'b1;
    end
    else
        step_state_r <= step_state_nxt;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        step_frame_ctr_r <= 8'b0;
    else if ( step_state_r[ STEP_CHECK_ST ] )
        step_frame_ctr_r <= 8'b0;
    else if ( mtip_eop_filter & step_state_r[ STEP_ENABLE_ST ] )
        step_frame_ctr_r <= step_frame_ctr_r + 8'b1;

///////////////////////////////////////////////////////////////////////////////
// Monitor Mode State Machine
///////////////////////////////////////////////////////////////////////////////
// Monitor mode must be set to normal AND Extractor must be enabled for
// frames to flow through.
//
// When either monitor mode is not normal OR Extractor is disabled,
// the receive gate is closed after the current frame in-flight.
// The timestamp FIFO is not written.
// Then we wait for the worst case pipeline latency through Extractor 
// and Packager for the last frame in-flight. The Extractor can then be safely 
// disabled. This delay is independent of frame size.
always_comb begin
    monitor_state_nxt = 7'b0;
    unique case ( 1'b1 )
        monitor_state_r[ MONITOR_IDLE_ST ]: begin
            if ( ( monitormode_r == 4'd2 ) && extrenable_r )
                monitor_state_nxt[ MONITOR_CHK_ON_ST ] = 1'b1;
            else
                monitor_state_nxt[ MONITOR_IDLE_ST ] = 1'b1;
        end
        // Make sure frame is not flowing before enabling
        monitor_state_r[ MONITOR_CHK_ON_ST ]: begin
            if ( mtip_dval_filter )
                monitor_state_nxt[ MONITOR_CHK_ON_ST ] = 1'b1;
            else
                monitor_state_nxt[ MONITOR_ENABLE_ST ] = 1'b1;
        end
        monitor_state_r[ MONITOR_ENABLE_ST ]: begin
            if ( ( monitormode_r != 4'd2 ) | ~extrenable_r )
                monitor_state_nxt[ MONITOR_CHK_OFF_ST ] = 1'b1;
            else
                monitor_state_nxt[ MONITOR_ENABLE_ST ] = 1'b1;
        end
        monitor_state_r[ MONITOR_CHK_OFF_ST ]: begin
            if ( mtip_dval_filter )
                monitor_state_nxt[ MONITOR_CHK_OFF_ST ] = 1'b1;
            else
                monitor_state_nxt[ MONITOR_FLUSH_ST ] = 1'b1;
        end
        monitor_state_r[ MONITOR_FLUSH_ST ]: begin
            if ( flush_ctr_r != 6'b0 )
                monitor_state_nxt[ MONITOR_FLUSH_ST ] = 1'b1;
            else
                monitor_state_nxt[ MONITOR_OTHER_ST ] = 1'b1;
        end
        monitor_state_r[ MONITOR_OTHER_ST ]: begin
            if ( invl_any_link_r )
                monitor_state_nxt[ MONITOR_OTHER_ST ] = 1'b1;
            else
                monitor_state_nxt[ MONITOR_ZERO_ST ] = 1'b1;
        end
        monitor_state_r[ MONITOR_ZERO_ST ]: begin
            if ( iTA_OFF_FILL_DONE )
                monitor_state_nxt[ MONITOR_IDLE_ST ] = 1'b1;
            else
                monitor_state_nxt[ MONITOR_ZERO_ST ] = 1'b1;
        end
        default: begin
            monitor_state_nxt[ MONITOR_IDLE_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        monitor_state_r <= 7'b0;
        monitor_state_r[ MONITOR_IDLE_ST ] <= 1'b1;
    end
    else
        monitor_state_r <= monitor_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Pipeline Flush Timer
///////////////////////////////////////////////////////////////////////////////
// The flush timer considers Extractor pipeline delay only.
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        flush_ctr_r <= 6'b0;
    else if ( monitor_state_r[ MONITOR_CHK_OFF_ST ] & monitor_state_nxt[ MONITOR_FLUSH_ST ] )
        flush_ctr_r <= 6'h3f;
    else if ( flush_ctr_r != 6'b0 )
        flush_ctr_r <= flush_ctr_r - 6'b1;

///////////////////////////////////////////////////////////////////////////////
// Monitor Off Flush Request
///////////////////////////////////////////////////////////////////////////////
assign oMIF_OFF_FILL_REQ = monitor_state_r[ MONITOR_ZERO_ST ];

///////////////////////////////////////////////////////////////////////////////
// Receive Enable
///////////////////////////////////////////////////////////////////////////////
assign receive_enbl = ( step_state_r[ STEP_IDLE_ST ] | step_state_r[ STEP_ENABLE_ST ] ) &
                      ( monitor_state_r[ MONITOR_ENABLE_ST ] | monitor_state_r[ MONITOR_CHK_OFF_ST ] );

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        oMIF_EXTR_EXTRENABLE <= 1'b0;
    else
        oMIF_EXTR_EXTRENABLE <= monitor_state_r[ MONITOR_ENABLE_ST  ] | 
                                monitor_state_r[ MONITOR_CHK_OFF_ST ] |
                                monitor_state_r[ MONITOR_FLUSH_ST   ];

///////////////////////////////////////////////////////////////////////////////
// Stop Error Register
///////////////////////////////////////////////////////////////////////////////
// Use filtered frame delimiter signal for back-to-back error detections.
// Un-filtered signals trigger oREG_FCSHORTERRCTR_EN.
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        frame_started_r <= 1'b0;
    else begin
        if ( frame_started_r )
            frame_started_r <= ~mtip_eop_filter;
        else
            frame_started_r <= mtip_sop_filter & mtip_dval_filter;
    end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        oREG_FRAMINGSTOP_B2BSOP <= 1'b0;
    else if ( mtip_sop_filter & frame_started_r )
        oREG_FRAMINGSTOP_B2BSOP <= 1'b1;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        frame_ended_r <= 1'b0;
    else begin
        if ( frame_ended_r )
            frame_ended_r <= ~mtip_sop_filter;
        else
            frame_ended_r <= mtip_eop_filter & mtip_dval_filter;
    end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        oREG_FRAMINGSTOP_B2BEOP <= 1'b0;
    else if ( mtip_eop_filter & frame_ended_r )
        oREG_FRAMINGSTOP_B2BEOP <= 1'b1;



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
pkt_mbst_checker #(
    .DATA_WIDTH ( 64                    )
)
u_mif_extr_pkt_prop_checker (
    .clk                ( clk                   ),
    .rst_n              ( rst_n                 ),
    .data               ( oMIF_EXTR_DATA        ),
    .sop                ( oMIF_EXTR_SOP         ),
    .eop                ( oMIF_EXTR_EOP         ),
    .valid              ( oMIF_EXTR_VALID       ),
    .zero               ( 1'b0                  )
);

assert_back_to_back_sop: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( oREG_FRAMINGSTOP_B2BSOP ) );

assert_back_to_back_eop: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( oREG_FRAMINGSTOP_B2BEOP ) );


final begin
    assert_accumulate_state_idle: assert ( accu_state_r[ ACCU_IDLE_ST ] == 1 );
end



// synopsys translate_on

endmodule
