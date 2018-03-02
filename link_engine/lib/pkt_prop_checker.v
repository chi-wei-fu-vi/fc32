/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: honda.yang $
* $Date: 2013-07-23 14:41:48 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2958 $
* Description: Assertion property checks of packet delimiter
*
***************************************************************************/

module pkt_prop_checker #(

parameter DATA_WIDTH    = 8  )              // Data Width 

(

// Global
input                   clk,
input                   rst_n,

// Packet Signals
input  [DATA_WIDTH-1:0] data,
input                   sop,
input                   eop,
input                   valid   

);

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
// Two SOP must be separated at least 7 cycles
assert_sop_spacing: assert property ( @( posedge clk )
    sop |=> ~sop[*1:7] );

// SOP and EOP pair must alternate
// Two SOPs must not happen back-to-back
assert_sop_sop_eop: assert property ( @( posedge clk )
    disable iff ( eop ) 
    ( sop & ~eop ) |=> ~sop[*1:$] );

// Two EOPs must not happen back-to-back
assert_eop_eop_sop: assert property ( @( posedge clk )
    disable iff ( sop )
    ( eop & ~sop ) |=> ~eop[*1:$] );

// EOP must accompany by VALID
assert_eop_no_valid: assert property ( @( posedge clk )
    eop |-> valid );

// VALID after EOP without SOP
assert_eop_valid_no_sop: assert property ( @( posedge clk )
    eop ##1 valid |-> sop );

// VALID first asserted without SOP
assert_first_valid_no_sop: assert property ( @( posedge clk )
    $rose( valid ) |-> sop );

// VALID last de-asserted without EOP
assert_last_valid_no_eop: assert property ( @( posedge clk )
    ( $fell( valid ) && rst_n ) |-> $past(eop, 1) );

// Data shall not be x when VALID
assert_data_unknown: assert property ( @( posedge clk )
    valid |-> !$isunknown( data ) );

endmodule
