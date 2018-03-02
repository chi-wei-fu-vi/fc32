/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: lk_dpl_xfr.v$
* $Author: honda.yang $
* $Date: 2013-07-23 09:59:09 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2942 $
* Description: Link DPL Buffer Transfer State Machine
*
***************************************************************************/
module lk_dpl_xfr (

// PCIE
output logic            oDPLBUF_REQ,
output logic            oDPLBUF_DATA_V,

// Link FIFO
output logic            oXFR_AHEAD_ST,
output logic            oXFR_DATA_V_NXT,

// Global
input                   clk,
input                   rst_n,

// Link FIFO
input                   iLKF_FIFO_NEMPTY,
input                   iLKF_BLK_AEMPTY,

// PCIE
input                   iDPLBUF_GNT,
input                   iDPLBUF_ANY_DATA_VLD

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
localparam  REQ_IDLE_ST                 = 0;
localparam  REQ_SET_ST                  = 1;
localparam  REQ_WAIT_ST                 = 2;

localparam  XFR_IDLE_ST                 = 0;
localparam  XFR_AHEAD1_ST               = 1;
localparam  XFR_GNT_ST                  = 2;
localparam  XFR_WAIT_ST                 = 3;
localparam  XFR_POP_ST                  = 4;
localparam  XFR_AHEAD2_ST               = 5;

logic [2:0] req_state_r, req_state_nxt;
logic [5:0] xfr_state_r, xfr_state_nxt;
logic [6:0] dplbuf_xfr_ctr_r;
logic last_dplbuf_xfr_r, grant_pending_r;

///////////////////////////////////////////////////////////////////////////////
// PCIE Request State Machine
///////////////////////////////////////////////////////////////////////////////
// PCIE request and data transfers are de-coupled to sustain higher bandwidth
// Request / Grant pair can be overlapped with data transfers
always_comb begin
    req_state_nxt = 3'b0;
    case ( 1'b1 )       // synopsys parallel_case
        req_state_r[ REQ_IDLE_ST ]: begin
            if ( iLKF_FIFO_NEMPTY )
                req_state_nxt[ REQ_SET_ST ] = 1'b1;
            else
                req_state_nxt[ REQ_IDLE_ST ] = 1'b1;
        end
        req_state_r[ REQ_SET_ST ]: begin
            if ( iDPLBUF_GNT ) 
                req_state_nxt[ REQ_WAIT_ST ] = 1'b1;
            else
                req_state_nxt[ REQ_SET_ST ] = 1'b1;
        end
        // wait until own data transfer almost done, then fifo level can be checked
        req_state_r[ REQ_WAIT_ST ]: begin
            if ( iLKF_BLK_AEMPTY ) 
                req_state_nxt[ REQ_IDLE_ST ] = 1'b1;
            else
                req_state_nxt[ REQ_WAIT_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        req_state_r <= 3'b0;
        req_state_r[ REQ_IDLE_ST ] <= 1'b1;
    end
    else
        req_state_r <= req_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// PCIE Data Transfer State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    xfr_state_nxt = 6'b0;
    case ( 1'b1 )       // synopsys parallel_case
        xfr_state_r[ XFR_IDLE_ST ]: begin
            if ( iLKF_FIFO_NEMPTY )
                xfr_state_nxt[ XFR_AHEAD1_ST ] = 1'b1;
            else
                xfr_state_nxt[ XFR_IDLE_ST ] = 1'b1;
        end
        xfr_state_r[ XFR_AHEAD1_ST ]: begin
            xfr_state_nxt[ XFR_GNT_ST ] = 1'b1;
        end
        xfr_state_r[ XFR_GNT_ST ]: begin
            if ( iDPLBUF_GNT | grant_pending_r ) 
                xfr_state_nxt[ XFR_WAIT_ST ] = 1'b1;
            else
                xfr_state_nxt[ XFR_GNT_ST ] = 1'b1;
        end
        // wait until no link engine is transferring data
        xfr_state_r[ XFR_WAIT_ST ]: begin
            if ( iDPLBUF_ANY_DATA_VLD ) 
                xfr_state_nxt[ XFR_WAIT_ST ] = 1'b1;
            else
                xfr_state_nxt[ XFR_POP_ST ] = 1'b1;
        end
        xfr_state_r[ XFR_POP_ST ]: begin
            if ( last_dplbuf_xfr_r ) begin
                if ( grant_pending_r )
                    xfr_state_nxt[ XFR_AHEAD2_ST ] = 1'b1;
                else
                    xfr_state_nxt[ XFR_IDLE_ST ] = 1'b1;
            end
            else
                xfr_state_nxt[ XFR_POP_ST ] = 1'b1;
        end
        // Does not go to XFR_GNT_ST as grant has been checked
        // Save one clock cycle between two DPLBUF_DATA_V. 
        // The DPLBUF_DATA_V gap is two cycles.
        xfr_state_r[ XFR_AHEAD2_ST ]: begin
            xfr_state_nxt[ XFR_WAIT_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        xfr_state_r <= 6'b0;
        xfr_state_r[ XFR_IDLE_ST ] <= 1'b1;
    end
    else
        xfr_state_r <= xfr_state_nxt;

assign oXFR_AHEAD_ST = xfr_state_r[ XFR_AHEAD1_ST ] | xfr_state_r[ XFR_AHEAD2_ST ];

///////////////////////////////////////////////////////////////////////////////
// PCIE Grant Pending 
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        grant_pending_r <= 1'b0;
    else begin
        if ( grant_pending_r )
            grant_pending_r <= ~( xfr_state_r[ XFR_WAIT_ST ] & xfr_state_nxt[ XFR_POP_ST ] );
        else
            grant_pending_r <= iDPLBUF_GNT;
    end

///////////////////////////////////////////////////////////////////////////////
// PCIE Request 
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        oDPLBUF_REQ <= 1'b0;
        oDPLBUF_DATA_V <= 1'b0;
    end
    else begin
        oDPLBUF_REQ <= req_state_nxt[ REQ_SET_ST ];
        oDPLBUF_DATA_V <= oXFR_DATA_V_NXT;
    end

assign oXFR_DATA_V_NXT = xfr_state_nxt[ XFR_POP_ST ];

///////////////////////////////////////////////////////////////////////////////
// 4KB Data Transfer Counter
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        dplbuf_xfr_ctr_r <= 7'b0;
    else if ( xfr_state_r[ XFR_POP_ST ] )
        dplbuf_xfr_ctr_r <= dplbuf_xfr_ctr_r + 7'b1;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        last_dplbuf_xfr_r <= 1'b0;
    else
        last_dplbuf_xfr_r <= ( dplbuf_xfr_ctr_r == 7'd126 );




// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
final begin
    assert_req_state_machine_idle: assert ( req_state_r[ REQ_IDLE_ST ] == 1 );
    assert_xfr_state_machine_idle: assert ( xfr_state_r[ XFR_IDLE_ST ] == 1 );
end



// synopsys translate_on

endmodule


