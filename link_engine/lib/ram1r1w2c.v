/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: ram1r1w2c.v$
* $Author: honda.yang $
* $Date: 2013-07-23 14:41:48 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2958 $
* Description: ram1r1w2c is a parameterized simple one read, one write dual 
*              ported memory with two clock domains. 
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

module ram1r1w2c #(

parameter ADDR_WIDTH    = 2,                // Address Width
parameter DEPTH         = (1<<ADDR_WIDTH),  // Depth of RAM
parameter DATA_WIDTH    = 8,                // Data Width 
parameter PIPE          = 0 )               // Pipeline Option

(

// Read Port
output logic [DATA_WIDTH-1:0] rddata,         // Read Data

// Read Port
input                       rdclk,          // Read Clock
input [ADDR_WIDTH-1:0]      rdaddr,         // Read Address

// Write Port
input                       wrclk,          // Write Clock
input [ADDR_WIDTH-1:0]      wraddr,         // Write Address
input [DATA_WIDTH-1:0]      wrdata,         // Write Data
input                       wren            // Write Enable

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];
logic [ADDR_WIDTH-1:0] rdaddr_d1_r;

///////////////////////////////////////////////////////////////////////////////
// Memory Read
///////////////////////////////////////////////////////////////////////////////
always @( posedge rdclk )
    if ( PIPE ) begin
        rdaddr_d1_r <= rdaddr;
        rddata <= memory[ rdaddr_d1_r ];
    end
    else
        rddata <= memory[ rdaddr ];

///////////////////////////////////////////////////////////////////////////////
// Memory Write
///////////////////////////////////////////////////////////////////////////////
always @( posedge wrclk )
    if ( wren ) 
        memory[ wraddr ] <= wrdata;

endmodule

