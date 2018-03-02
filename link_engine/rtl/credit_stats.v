/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: credit_stats.v$
* $Author: honda.yang $
* $Date: 2013-05-31 10:22:10 -0700 (Fri, 31 May 2013) $
* $Revision: 2423 $
* Description: Credit Statistics between Two Channels
*
***************************************************************************/

module credit_stats (

// Interval Stats Packager
output logic [31:0]     oINT_STATS_TIMECR,
output logic [31:0]     oINT_STATS_MINCR,
output logic [31:0]     oINT_STATS_MAXCR,
output logic [31:0]     oINT_STATS_ENDCR,

// Global
input  [1:0]            clk,
input  [1:0]            rst_n,

// First Channel MoreThanIP
input  [11:0]           iRX_PRIMITIVE,

// Second Channel MoreThanIP
input                   iRX_CLASS_VAL,

// SFP
input  [1:0]            iSFP_PHY_LOSIG,

// Interval Stats Packager
input                   iSTATS_LATCH_CLR_RXCLK,

// FC1 Stats
input  [1:0]            iLINK_UP_EVENT,

// Register
input  [31:0]           iREG_CREDITSTART

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic any_link_up_event, new_credit_value_r;
logic [31:0] credit_start_d1_r;
logic [1:0] sfp_losig_rxclk_r, link_up_evnt_rxclk_r;
logic [11:0] fc1_rx_primitive_r;
logic fc1_rx_class_val_r, rrdy_primitive, rx_frame, rrdy_prim_rxclk_r;
logic [31:0] credit_ctr_r, time_min_credit_r, minimum_credit_r, maximum_credit_r;
logic rrdy_no_losig_rxclk;

///////////////////////////////////////////////////////////////////////////////
// Flop All Inputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk[0] ) 
    fc1_rx_class_val_r <= iRX_CLASS_VAL;

always_ff @( posedge clk[1] ) 
    fc1_rx_primitive_r <= iRX_PRIMITIVE;

///////////////////////////////////////////////////////////////////////////////
// Synchronization
///////////////////////////////////////////////////////////////////////////////
vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_los_losig0 (
    .out_level          ( sfp_losig_rxclk_r[0]      ),
    .clk                ( clk[0]                    ),
    .rst_n              ( rst_n[0]                  ),
    .in_level           ( iSFP_PHY_LOSIG[0]         )
);

vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_los_losig1 (
    .out_level          ( sfp_losig_rxclk_r[1]      ),
    .clk                ( clk[0]                    ),
    .rst_n              ( rst_n[0]                  ),
    .in_level           ( iSFP_PHY_LOSIG[1]         )
);

vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_link_up_event0 (
    .out_level          ( link_up_evnt_rxclk_r[0]   ),
    .clk                ( clk[0]                    ),
    .rst_n              ( rst_n[0]                  ),
    .in_level           ( iLINK_UP_EVENT[0]         )
);

vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_link_up_event1 (
    .out_level          ( link_up_evnt_rxclk_r[1]   ),
    .clk                ( clk[0]                    ),
    .rst_n              ( rst_n[0]                  ),
    .in_level           ( iLINK_UP_EVENT[1]         )
);

vi_sync_pulse u_sync_pls_rrdy_prim (
    .out_pulse          ( rrdy_prim_rxclk_r         ),
    .clka               ( clk[1]                    ),
    .clkb               ( clk[0]                    ),
    .rsta_n             ( rst_n[1]                  ),
    .rstb_n             ( rst_n[0]                  ),
    .in_pulse           ( rrdy_primitive            )
);

///////////////////////////////////////////////////////////////////////////////
// RRDY Primitive
///////////////////////////////////////////////////////////////////////////////
assign rrdy_primitive = fc1_rx_primitive_r[ MTIP_PRIM_R_RDY ]; 

assign rrdy_no_losig_rxclk = rrdy_prim_rxclk_r & ~sfp_losig_rxclk_r[1];

///////////////////////////////////////////////////////////////////////////////
// Receive Frame
///////////////////////////////////////////////////////////////////////////////
assign rx_frame = fc1_rx_class_val_r & ~sfp_losig_rxclk_r[0];

///////////////////////////////////////////////////////////////////////////////
// Credit Counter
///////////////////////////////////////////////////////////////////////////////
assign any_link_up_event = |link_up_evnt_rxclk_r;

always_ff @( posedge clk[0] or negedge rst_n[0] )
    if ( ~rst_n[0] )
        credit_ctr_r <= 32'h1000000;
    else begin
        //a cntr reset event: a new value written to the start-reg, or a new link-up event.
        if ( new_credit_value_r | any_link_up_event )
            credit_ctr_r <= iREG_CREDITSTART;
        // if not '0', subtract
        else if ( rx_frame & ( credit_ctr_r != 32'b0 ) & ~rrdy_no_losig_rxclk )
            credit_ctr_r <= credit_ctr_r - 32'b1;
        //if not max, add
        else if ( rrdy_no_losig_rxclk & ( credit_ctr_r != 32'hFFFFFFFF ) & ~rx_frame )
            credit_ctr_r <= credit_ctr_r + 32'b1;
        //nothing rx'd, or simultaneous rrdy and frame, or we are sitting at max or min, 
        //so leave the counter as it is.
        else
            credit_ctr_r <= credit_ctr_r;
    end

always_ff @( posedge clk[0] )
    if ( iSTATS_LATCH_CLR_RXCLK )
        oINT_STATS_ENDCR <= credit_ctr_r;

///////////////////////////////////////////////////////////////////////////////
// Time at Minimum Credit 
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk[0] or negedge rst_n[0] )
    if ( ~rst_n[0] )
        time_min_credit_r <= 32'b0;
    else begin
        if ( iSTATS_LATCH_CLR_RXCLK | new_credit_value_r | any_link_up_event )
            time_min_credit_r <= 32'b0;
        else if ( ( credit_ctr_r == minimum_credit_r) & (time_min_credit_r != 32'hFFFF_FFFF) )
            time_min_credit_r <= time_min_credit_r + 1'b1;
        else if (credit_ctr_r < minimum_credit_r)
            time_min_credit_r <= 32'b1;
        else
            time_min_credit_r <= time_min_credit_r;
    end

always_ff @( posedge clk[0] )
    if ( iSTATS_LATCH_CLR_RXCLK )
        oINT_STATS_TIMECR <= time_min_credit_r;

///////////////////////////////////////////////////////////////////////////////
// Minimum Credit 
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk[0] or negedge rst_n[0] )
    if ( ~rst_n[0] )
        minimum_credit_r <= 32'hFFFFFFFF;
    else begin
        if ( iSTATS_LATCH_CLR_RXCLK | new_credit_value_r | any_link_up_event )
            minimum_credit_r <= 32'hFFFFFFFF;
        else if ( credit_ctr_r < minimum_credit_r)
            minimum_credit_r <= credit_ctr_r;
        else
            minimum_credit_r <= minimum_credit_r;
    end

always_ff @( posedge clk[0] )
    if ( iSTATS_LATCH_CLR_RXCLK )
        oINT_STATS_MINCR <= minimum_credit_r;

///////////////////////////////////////////////////////////////////////////////
// Maximum Credit 
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk[0] or negedge rst_n[0] )
    if ( ~rst_n[0] )
        maximum_credit_r <= 32'b0;
    else begin
        if ( iSTATS_LATCH_CLR_RXCLK | new_credit_value_r | any_link_up_event )
            maximum_credit_r <= 32'b0;
        else if ( credit_ctr_r > maximum_credit_r )
            maximum_credit_r <= credit_ctr_r;
        else
            maximum_credit_r <= maximum_credit_r;
    end

always_ff @( posedge clk[0] )
    if ( iSTATS_LATCH_CLR_RXCLK )
        oINT_STATS_MAXCR <= maximum_credit_r;

///////////////////////////////////////////////////////////////////////////////
// Credit Start Value
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk[0] )
    credit_start_d1_r <= iREG_CREDITSTART;

always_ff @( posedge clk[0] or negedge rst_n[0] )
    if ( ~rst_n[0] )
        new_credit_value_r <= 1'b0;
    else 
        new_credit_value_r <= ( credit_start_d1_r != iREG_CREDITSTART );





// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////



// synopsys translate_on

endmodule
