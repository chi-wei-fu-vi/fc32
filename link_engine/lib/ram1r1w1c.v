/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: ram1r1w1c.v$
* $Author: honda.yang $
* $Date: 2013-07-23 14:41:48 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2958 $
* Description: ram1r1w1c is a parameterized simple one read, one write dual 
*              ported memory with one clock domain. 
*
*  Parameters:
*  ADDR_WIDTH - RAM read / write address bus width
*  DEPTH      - Number of entries in the RAM. Needed since the depth may not 
*               always be powers of two
*  DATA_WIDTH - RAM read / write data bus width
*  PIPE       - RAM read data pipeline option. 
*               0=read data pass-through. 1=registered read data output
*
***************************************************************************/

module ram1r1w1c #(

parameter ADDR_WIDTH    = 2,                // Address Width
parameter DEPTH         = (1<<ADDR_WIDTH),  // Depth of RAM
parameter DATA_WIDTH    = 8,                // Data Width 
parameter PIPE          = 0 )               // Pipeline Option

(

// Read Port
output reg [DATA_WIDTH-1:0] rddata,         // Read Data

// Global
input                       clk,            // Clock

// Read Port
input [ADDR_WIDTH-1:0]      rdaddr,         // Read Address

// Write Port
input [ADDR_WIDTH-1:0]      wraddr,         // Write Address
input [DATA_WIDTH-1:0]      wrdata,         // Write Data
input                       wren            // Write Enable

);


///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
// no_rw_check indicates that the output of the inferred RAM is don't care
// when there are simultaneous reads and writes to the same address.
// Memory timing is improved without the extra logic.
reg [DATA_WIDTH-1:0] memory [DEPTH-1:0] /* synthesis ramstyle = "no_rw_check" */;
logic [ADDR_WIDTH-1:0] rdaddr_d1_r;

///////////////////////////////////////////////////////////////////////////////
// Memory Read
///////////////////////////////////////////////////////////////////////////////
always @( posedge clk )
    if ( PIPE ) begin
        rdaddr_d1_r <= rdaddr;
        rddata <= memory[ rdaddr_d1_r ];
    end
    else
        rddata <= memory[ rdaddr ];

///////////////////////////////////////////////////////////////////////////////
// Memory Write
///////////////////////////////////////////////////////////////////////////////
always @( posedge clk )
    if ( wren ) 
        memory[ wraddr ] <= wrdata;

endmodule

