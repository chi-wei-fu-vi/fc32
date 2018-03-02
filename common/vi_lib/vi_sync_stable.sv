/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: vi_sync_stable.v$
* $Author: honda.yang $
* $Date: 2013-05-30 10:42:23 -0700 (Thu, 30 May 2013) $
* $Revision: 2395 $
* Description: vi_sync_stable is a one stage pipeline stage synchronizer
*              in_bus input must be stable couples of cycle prior to
*              sample signal
*
*  Parameters:
*  SIZE - Bus width
*
***************************************************************************/

module vi_sync_stable #(

parameter SIZE          = 8,                // Bus Width
parameter ASSERT        = 0 )               // Assertion Check

(

output logic [SIZE-1:0]     out_sync_bus_r,

input                       clk,
input                       rst_n,

input                       sample,         // Data Sample

input  [SIZE-1:0]           in_bus

);

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        out_sync_bus_r <= {SIZE{1'b0}};
    else if ( sample ) 
        out_sync_bus_r <= in_bus;


// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
assert_stable_prior_check_one_cycle: assert property ( @( posedge clk )
    ( sample & ASSERT ) |-> ( $past( in_bus ) == $past( in_bus, 2 ) ) );

// synopsys translate_on

endmodule

