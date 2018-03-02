/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: fifo1c.v$
* $Author: honda.yang $
* $Date: 2013-07-23 14:41:48 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2958 $
* Description: fifo1c is a parameterized simple FIFO
*              with one clock domain.
*
*  Parameters:
*  ADDR_WIDTH - RAM read / write address bus width
*  DEPTH      - Number of entries in the RAM. Needed since the depth may not 
*               always be powers of two
*  DATA_WIDTH - RAM read / write data bus width
*  AFUL_THRES - Almost full threshold level
*  AEMP_THRES - Almost empty threshold level
*
***************************************************************************/

module fifo1c #(

parameter ADDR_WIDTH    = 2,                // Address Width
parameter DEPTH         = (1<<ADDR_WIDTH),  // Depth of RAM
parameter DATA_WIDTH    = 8,                // Data Width 
parameter AFUL_THRES    = 8,                // Almost Full Threshold
parameter AEMP_THRES    = 2,                // Almost Empty Threshold
parameter WRREQ_EARLY   = 0,                // Write Request Early
parameter PIPE          = 1 )               // Output Data/Stats Registered

(

// Read
output logic [DATA_WIDTH-1:0]   q,

// Status
output logic                    almost_empty,
output logic                    almost_full,
output logic                    empty,
output logic                    full,
output logic [ADDR_WIDTH:0]     usedw,
output logic [ADDR_WIDTH:0]     highest_dw,
output logic                    overflow,
output logic                    underflow,

// Global
input                           clk,
input                           rst_n,

// Write
input  [DATA_WIDTH-1:0]         data,
input                           wrreq,

// Read
input                           rdreq,

// Clear
input                           highest_clr

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic [ADDR_WIDTH-1:0] fifo_wa_r, fifo_ra_nxt;
logic [DATA_WIDTH-1:0] fifo_rd;
logic wrreq_mem_mux;

///////////////////////////////////////////////////////////////////////////////
// Memory Instantiation
///////////////////////////////////////////////////////////////////////////////
ram1r1w1c #(
    .ADDR_WIDTH     ( ADDR_WIDTH            ),
    .DEPTH          ( DEPTH                 ),
    .DATA_WIDTH     ( DATA_WIDTH            ),
    .PIPE           ( 0                     )
)
u_fifo_ram (
    .rddata             ( fifo_rd                   ),
    .clk                ( clk                       ),
    .rdaddr             ( fifo_ra_nxt               ),
    .wraddr             ( fifo_wa_r                 ),
    .wrdata             ( data                      ),
    .wren               ( wrreq_mem_mux             )
);

///////////////////////////////////////////////////////////////////////////////
// Controller Instantiation
///////////////////////////////////////////////////////////////////////////////
fifo1c_ctl #(
    .ADDR_WIDTH     ( ADDR_WIDTH            ),
    .DEPTH          ( DEPTH                 ),
    .DATA_WIDTH     ( DATA_WIDTH            ),
    .AFUL_THRES     ( AFUL_THRES            ),
    .AEMP_THRES     ( AEMP_THRES            ),
    .WRREQ_EARLY    ( WRREQ_EARLY           ),
    .PIPE           ( PIPE                  )
)
u_fifo1c_ctl (
    .q                  ( q                         ),
    .almost_empty       ( almost_empty              ),
    .almost_full        ( almost_full               ),
    .empty              ( empty                     ),
    .full               ( full                      ),
    .usedw              ( usedw                     ),
    .highest_dw         ( highest_dw                ),
    .overflow           ( overflow                  ),
    .underflow          ( underflow                 ),
    .fifo_ra_nxt        ( fifo_ra_nxt               ),
    .fifo_wa_r          ( fifo_wa_r                 ),
    .wrreq_mem_mux      ( wrreq_mem_mux             ),
    .clk                ( clk                       ),
    .rst_n              ( rst_n                     ),
    .data               ( data                      ),
    .wrreq              ( wrreq                     ),
    .rdreq              ( rdreq                     ),
    .highest_clr        ( highest_clr               ),
    .fifo_rd            ( fifo_rd                   )
);





endmodule
