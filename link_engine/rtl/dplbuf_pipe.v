/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: dplbuf_pipe.v$
* $Author: honda.yang $
* $Date: 2013-02-19 09:34:11 -0800 (Tue, 19 Feb 2013) $
* $Revision: 1484 $
* Description: Pipelines between Multiple Link Engines and PCIE modules
*
***************************************************************************/

module dplbuf_pipe #(

parameter   LINKS        =      12,
parameter   PORTS        =      12  )

(

// PCIE
output logic [255:0]        oPCIE_DPLBUF_DATA,
output logic [PORTS-1:0]    oPCIE_DPLBUF_DATA_V,
output logic [PORTS-1:0]    oPCIE_DPLBUF_REQ,

// Link Engines
output logic                oDPLBUF_ANY_DATA_VLD,
output logic [PORTS-1:0]    oDAT_DPLBUF_GNT,

// Global
input                       iCLK,
input                       iRST_n,

// Link Engines
input  [LINKS-1:0][255:0]   iLE_DPLBUF_DATA,
input  [PORTS-1:0]          iLE_DPLBUF_REQ,
input  [PORTS-1:0]          iLE_DPLBUF_DATA_V,

// PCIE BIST
input  [255:0]              iBIST_DPLBUF_DATA,
input  [PORTS-1:0]          iBIST_DPLBUF_REQ,
input  [PORTS-1:0]          iBIST_DPLBUF_DATA_V,

// PCIE
input  [PORTS-1:0]          iPCIE_DPLBUF_GNT

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic [255:0] le_dplbuf_data_r;
logic [PORTS-1:0] le_dplbuf_data_v_r, le_dplbuf_req_r;

///////////////////////////////////////////////////////////////////////////////
// Any Link Engine Active
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n )
        oDPLBUF_ANY_DATA_VLD <= 1'b0;
    else
        oDPLBUF_ANY_DATA_VLD <= |iLE_DPLBUF_DATA_V;

///////////////////////////////////////////////////////////////////////////////
// Link Engine Grants
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) 
        oDAT_DPLBUF_GNT <= {PORTS{1'b0}};
    else 
        oDAT_DPLBUF_GNT <= iPCIE_DPLBUF_GNT[PORTS-1:0];

///////////////////////////////////////////////////////////////////////////////
// Link Engine Mux
///////////////////////////////////////////////////////////////////////////////
// FIFO data is always 0 if not active in the Link Engine
// ALl the FIFO data can then be OR'ed together to form a single 256-bit data bus
// to reduce top level wiring.
function [255:0] mux_dplbuf_data;
  input [PORTS-1:0][255:0] data;
  integer i;
  logic [255:0] result;
  begin
    result = 256'b0;
    for (i = 0; i < PORTS; i++)
      result = result | data[i];
    mux_dplbuf_data = result;
  end
endfunction

always_ff @( posedge iCLK )
    le_dplbuf_data_r <= mux_dplbuf_data( iLE_DPLBUF_DATA );

always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) begin
        le_dplbuf_data_v_r <= {PORTS{1'b0}};
        le_dplbuf_req_r    <= {PORTS{1'b0}};
    end
    else begin
        le_dplbuf_data_v_r <= iLE_DPLBUF_DATA_V;
        le_dplbuf_req_r    <= iLE_DPLBUF_REQ;
    end

///////////////////////////////////////////////////////////////////////////////
// PCIE DPLBUF Final Pipeline 
///////////////////////////////////////////////////////////////////////////////
// Merge link engine and BIST data paths
always_ff @( posedge iCLK )
    oPCIE_DPLBUF_DATA <= le_dplbuf_data_r | iBIST_DPLBUF_DATA;

always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) begin
        oPCIE_DPLBUF_REQ    <= 1'b0;
        oPCIE_DPLBUF_DATA_V <= 1'b0;
    end
    else begin
        oPCIE_DPLBUF_REQ    <= le_dplbuf_req_r | iBIST_DPLBUF_REQ;
        oPCIE_DPLBUF_DATA_V <= le_dplbuf_data_v_r | iBIST_DPLBUF_DATA_V;
    end


// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////



// synopsys translate_on

endmodule
