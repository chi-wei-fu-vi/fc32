/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: invl_stats_ctr.v$
* $Author: honda.yang $
* $Date: 2013-07-23 14:41:48 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2958 $
* Description: Interval Stats Counter
*
***************************************************************************/

module invl_stats_ctr #(

parameter SIZE = 32 )

(

output logic [SIZE-1:0]     latched_stats_ctr_r,

input                       clk,
input                       rst_n,

input                       latch_clr,
input                       increment

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic [SIZE-1:0] stats_ctr_r;

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Counter
///////////////////////////////////////////////////////////////////////////////
// These counters are declared as FRC type in register space so the free
// running counter value is readable for debug purpose.
// The same counter is implemented here for Interval Stats purpose.
// The counter is latched to a shadow register and cleared at the same time
// upon latch_clr.
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        stats_ctr_r <= {SIZE{1'b0}};
    else
        case ( {latch_clr, increment} )
            2'b00: stats_ctr_r <= stats_ctr_r;
            2'b01: stats_ctr_r <= stats_ctr_r + {{(SIZE-1){1'b0}}, 1'b1};
            2'b10: stats_ctr_r <= {SIZE{1'b0}};
            2'b11: stats_ctr_r <= {{(SIZE-1){1'b0}}, 1'b1};
        endcase

always_ff @( posedge clk )
    if ( latch_clr ) 
        latched_stats_ctr_r <= stats_ctr_r;

endmodule

