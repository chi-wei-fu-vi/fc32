/***************************************************************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: ctl_interval_stats.v$
* $Author: honda.yang $
* $Date: 2013-08-05 11:22:53 -0700 (Mon, 05 Aug 2013) $
* $Revision: 3104 $
* Description: Control Path Interval Stats Packager
*
***************************************************************************/

module ctl_interval_stats (

// Time Arbiter
output logic [127:0]    oINVL_DAL_DATA,
output logic [55:0]     oINVL_GOOD_TS,
output logic            oINVL_GOOD_FIRST,
output logic            oINVL_GOOD_LAST,
output logic            oINVL_GTS_VALID,

// Register
output logic            oREG_INVLCTRLDROPCTR_EN,

// Global
input                   clk,
input                   rst_n,

// Configuration
input  [3:0]            iLINK_ID,

// Global Timer
input  [55:0]           iGLOBAL_TIMESTAMP,
input                   iEND_OF_INTERVAL,

// Other Link Engine
input                   iLE_UC_RD_START,

// Time Arbiter
input                   iTA_INVL_DAL_READ,

// Register
input  [3:0]            iREG_LINKCTRL_MONITORMODE,
input  [1:0]            iREG_LINKCTRL_DALCTLSZ

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic [5:0] invl_pkt_cyc_r, invl_pkt_cyc_nxt;
logic end_of_interval_r, pkt_cyc_nxt_max, pkt_cyc_max_r;
logic [3:0] monitormode_r, monitormode_lat_r, invl_monitormode;
logic [1:0] dalctlsz_r;
logic uc_rd_start_r;
logic gts_valid_nxt, invl_req_active_r;

///////////////////////////////////////////////////////////////////////////////
// Flop Inputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        end_of_interval_r <= 1'b0;
        uc_rd_start_r <= 1'b0;
    end
    else begin
        end_of_interval_r <= iEND_OF_INTERVAL;
        uc_rd_start_r <= iLE_UC_RD_START;
    end

always_ff @( posedge clk ) begin
    monitormode_r <= iREG_LINKCTRL_MONITORMODE;
    dalctlsz_r <= iREG_LINKCTRL_DALCTLSZ;
end

always_ff @( posedge clk )
    if ( ~rst_n )
        monitormode_lat_r <= 4'b0;
    else if ( end_of_interval_r )
        monitormode_lat_r <= monitormode_r;

assign invl_monitormode = end_of_interval_r ? monitormode_r : monitormode_lat_r;

///////////////////////////////////////////////////////////////////////////////
// Packet Cycle Counter
///////////////////////////////////////////////////////////////////////////////
// Every interval packet takes 8-64 cycles to build depending on iREG_LINKCTRL_DALCTLSZ
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        invl_pkt_cyc_r <= 6'b0;
    else if ( pkt_cyc_max_r )
        invl_pkt_cyc_r <= 6'b0;
    else
        invl_pkt_cyc_r <= invl_pkt_cyc_nxt;

always_comb begin
    case ( dalctlsz_r )
        2'b00: pkt_cyc_nxt_max = ( invl_pkt_cyc_r == 6'd6 );
        2'b01: pkt_cyc_nxt_max = ( invl_pkt_cyc_r == 6'd14 );
        2'b10: pkt_cyc_nxt_max = ( invl_pkt_cyc_r == 6'd30 );
        2'b11: pkt_cyc_nxt_max = ( invl_pkt_cyc_r == 6'd62 );
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        pkt_cyc_max_r <= 1'b0;
    else
        pkt_cyc_max_r <= pkt_cyc_nxt_max;

always_comb
    if ( iTA_INVL_DAL_READ )
        invl_pkt_cyc_nxt = invl_pkt_cyc_r + 6'b1;
    else
        invl_pkt_cyc_nxt = invl_pkt_cyc_r;

///////////////////////////////////////////////////////////////////////////////
// Timestamp
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk )
    if ( end_of_interval_r )
        oINVL_GOOD_TS <= iGLOBAL_TIMESTAMP;

///////////////////////////////////////////////////////////////////////////////
// Interval FIFO Write
///////////////////////////////////////////////////////////////////////////////
// PCIe is little endian. Command type is at byte position 0.
// Timestamp is from byte 7 to 1 without byte swapping.
always_ff @( posedge clk ) 
    if ( invl_pkt_cyc_nxt == 6'd0 ) begin
        oINVL_DAL_DATA[127:64] <= 64'b0;
        oINVL_DAL_DATA[63 :0 ] <= {oINVL_GOOD_TS, 4'b0, DAL_C_INVL_TYPE};
    end
    else if ( pkt_cyc_nxt_max ) begin
        oINVL_DAL_DATA[127:125] <= 3'b0;
        oINVL_DAL_DATA[124]     <= 1'b0;
        oINVL_DAL_DATA[123:120] <= iLINK_ID;
        oINVL_DAL_DATA[119:112] <= 8'b0;     // packet number
        oINVL_DAL_DATA[111:96 ] <= 16'b0;
        oINVL_DAL_DATA[95 :0  ] <= 96'b0;
    end
    else begin
        oINVL_DAL_DATA[127:0 ] <= 128'b0;
    end

///////////////////////////////////////////////////////////////////////////////
// Time Arbiter Interface
///////////////////////////////////////////////////////////////////////////////
assign gts_valid_nxt = uc_rd_start_r & ( invl_monitormode != 4'b0 );

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        oINVL_GTS_VALID <= 1'b0;
    else
        oINVL_GTS_VALID <= gts_valid_nxt;

assign oINVL_GOOD_FIRST = 1'b1;
assign oINVL_GOOD_LAST  = 1'b1;

///////////////////////////////////////////////////////////////////////////////
// Interval Packet Discard
///////////////////////////////////////////////////////////////////////////////
// When link FIFO is back pressured for long period of time, interval packets are
// discarded to avoid FIFO overflow. 
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        invl_req_active_r <= 1'b0;
    else begin
        if ( invl_req_active_r )
            invl_req_active_r <= ~pkt_cyc_max_r;
        else
            invl_req_active_r <= gts_valid_nxt;
    end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oREG_INVLCTRLDROPCTR_EN <= 1'b0;
    else
        oREG_INVLCTRLDROPCTR_EN <= gts_valid_nxt & invl_req_active_r;




// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////



// synopsys translate_on

endmodule
