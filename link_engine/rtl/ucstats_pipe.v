/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: ucstats_pipe.v$
* $Author: honda.yang $
* $Date: 2013-07-23 09:59:09 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2942 $
* Description: Pipelines between Multiple Link Engines and uC Stats modules
*
***************************************************************************/

module ucstats_pipe #( parameter LINKS = 4 )
(

// uC Stats
output logic                oLE_UCSTATS_REQ,
output logic [9:0]          oLE_UCSTATS_ADDR,
output logic                oLE_UCSTATS_DONE,

output logic [9:0]          oLE_UCSTATS_MM_ADDR,

// Link Engines
output logic                oUCSTATS_LE_GNT,

output logic [31:0]         oUCS_LE_MM_RD_DATA,
output logic [2*LINKS-1:0]  oUCS_LE_MM_RD_DATA_V,

// Global
input                       iCLK,
input                       iRST_n,

// Link Engines
input  [LINKS-1:0]          iLE_UCSTATS_REQ,
input  [LINKS-1:0][5:0]     iLE_UCSTATS_ADDR,
input                       iLAST_LE_UC_RD_DONE,

input  [2*LINKS-1:0]        iLE_UCS_MM_RD_EN,
input  [2*LINKS-1:0][4:0]   iLE_UCS_MM_ADDR,

// uC Stats
input                       iUCSTATS_GNT,

input  [31:0]               iUCSTATS_MM_RD_DATA

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic [5:0] invl_ucs_addr_lsb;
logic [3:0] invl_ucs_addr_msb;
logic [4:0] mm_ucs_addr_msb, mm_ucs_addr_lsb;
logic [2*LINKS-1:0] mm_rd_en_d1_r, mm_rd_en_d2_r, mm_rd_en_d3_r;
logic stats_req0_d1_r, ucstat_le_gnt_d1_r;
logic [LINKS-1:0] req_vector_lat_r;

///////////////////////////////////////////////////////////////////////////////
// Interval Address One-hot to Binary 
///////////////////////////////////////////////////////////////////////////////
onehot_to_bin #(.ONEHOT_WIDTH(LINKS), .BIN_WIDTH(4)) u_invl_onehot_to_bin (
    .onehot         ( req_vector_lat_r      ),
    .bin            ( invl_ucs_addr_msb     )
);

///////////////////////////////////////////////////////////////////////////////
// Interval uC Stats Outputs
///////////////////////////////////////////////////////////////////////////////
assign invl_ucs_addr_lsb = add_addr_6( iLE_UCSTATS_ADDR );

always_ff @( posedge iCLK or negedge iRST_n )
  if (~iRST_n)
    oLE_UCSTATS_ADDR <= 'h0;
	else
    oLE_UCSTATS_ADDR <= {invl_ucs_addr_msb, invl_ucs_addr_lsb};

always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) 
        stats_req0_d1_r <= 1'b0;
    else 
        stats_req0_d1_r <= iLE_UCSTATS_REQ[0];

// uC stats request is active only for first link engine
always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) 
        oLE_UCSTATS_REQ  <= 1'b0;
    else
        if ( oLE_UCSTATS_REQ )
            oLE_UCSTATS_REQ <= ~iUCSTATS_GNT;
        else
            oLE_UCSTATS_REQ <= iLE_UCSTATS_REQ[0] & ~stats_req0_d1_r;

// uC stats done is active after the last link engine
always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) 
        oLE_UCSTATS_DONE <= 1'b0;
    else 
        oLE_UCSTATS_DONE <= iLAST_LE_UC_RD_DONE;

function [5:0] add_addr_6;
  input [LINKS-1:0][5:0] address;
  integer i;
  logic [5:0] result;
  begin
    result = 6'b0;
    for (i = 0; i < LINKS; i++)
      result = result | address[i];
    add_addr_6 = result;
  end
endfunction

///////////////////////////////////////////////////////////////////////////////
// Link Engine Interval Outputs
///////////////////////////////////////////////////////////////////////////////
// Without asserting stats request for subsequent link engines, grant is
// forced immediately after request.
always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) begin
        oUCSTATS_LE_GNT <= 1'b0;
        ucstat_le_gnt_d1_r <= 1'b0;
    end
    else begin
        oUCSTATS_LE_GNT <= iUCSTATS_GNT | (|iLE_UCSTATS_REQ[LINKS-1:1]);
        ucstat_le_gnt_d1_r <= oUCSTATS_LE_GNT;
    end

///////////////////////////////////////////////////////////////////////////////
// Request Vector Latch
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) 
        req_vector_lat_r <= 1'b0;
    else if ( oUCSTATS_LE_GNT & ~ucstat_le_gnt_d1_r )
        req_vector_lat_r <= iLE_UCSTATS_REQ;

///////////////////////////////////////////////////////////////////////////////
// MM Address One-hot to Binary 
///////////////////////////////////////////////////////////////////////////////
onehot_to_bin #(.ONEHOT_WIDTH(2*LINKS), .BIN_WIDTH(5)) u_mm_onehot_to_bin (
    .onehot         ( iLE_UCS_MM_RD_EN      ),
    .bin            ( mm_ucs_addr_msb       )
);

///////////////////////////////////////////////////////////////////////////////
// MM uC Stats Outputs
///////////////////////////////////////////////////////////////////////////////
assign mm_ucs_addr_lsb = mux_addr_5( iLE_UCS_MM_RD_EN, iLE_UCS_MM_ADDR );

always_ff @( posedge iCLK or negedge iRST_n )
  if ( ~iRST_n )
    oLE_UCSTATS_MM_ADDR <= 'h0;
	else if (iLE_UCS_MM_RD_EN)
    oLE_UCSTATS_MM_ADDR <= {mm_ucs_addr_msb, mm_ucs_addr_lsb};


/*lzhou
 * removed gating of address bus w/ read enable.  Rather, just use read_en to
 * "enable" sampling of the address bus.  The address should remain constant
 * until the next read is made.
 */
function [4:0] mux_addr_5;
  input [2*LINKS-1:0] sel;
  input [2*LINKS-1:0][4:0] address;
  integer i;
  logic [4:0] result;
  begin
    result = 5'b0;
    for (i = 0; i < 2*LINKS; i++)
      //result = result | ( {5{sel[i]}} & address[i] );
      result = result | address[i];
    mux_addr_5 = result;
  end
endfunction

///////////////////////////////////////////////////////////////////////////////
// MM Link Engine Outputs
///////////////////////////////////////////////////////////////////////////////
/* lzhou
 * No reason to qualify data bus w/ read valid here.  The xx02 addr decoder
 * already does this qualification
 */
always_ff @( posedge iCLK or negedge iRST_n )
    //if ( mm_rd_en_d2_r )
	if ( ~iRST_n )
    oUCS_LE_MM_RD_DATA <= 'h0;
  else
    oUCS_LE_MM_RD_DATA <= iUCSTATS_MM_RD_DATA;

/*lzhou
 * Increase latency by 1 cycle due to addition address decode pipe
 */

always_ff @( posedge iCLK or negedge iRST_n )
    if ( ~iRST_n ) begin
        mm_rd_en_d1_r <= {(2*LINKS){1'b0}};
        mm_rd_en_d2_r <= {(2*LINKS){1'b0}};
        mm_rd_en_d3_r <= {(2*LINKS){1'b0}};
        oUCS_LE_MM_RD_DATA_V <= {(2*LINKS){1'b0}};
    end
    else begin
        mm_rd_en_d1_r <= iLE_UCS_MM_RD_EN;
        mm_rd_en_d2_r <= mm_rd_en_d1_r;
        mm_rd_en_d3_r <= mm_rd_en_d2_r;
        oUCS_LE_MM_RD_DATA_V <= mm_rd_en_d3_r;
    end


// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
// oLE_UCSTATS_REQ and oLE_UCSTATS_DONE pair must alternate
// Two oLE_UCSTATS_REQ must not happen back-to-back
assert_ucstats_req_req_done: assert property ( @( posedge iCLK )
    disable iff ( oLE_UCSTATS_DONE ) 
    ( oLE_UCSTATS_REQ & iUCSTATS_GNT & ~oLE_UCSTATS_DONE ) |=> ~( oLE_UCSTATS_REQ & iUCSTATS_GNT )[*1:$] );

// Two oLE_UCSTATS_DONE must not happen back-to-back
assert_ucstats_done_done_req: assert property ( @( posedge iCLK )
    disable iff ( oLE_UCSTATS_REQ ) 
    ( oLE_UCSTATS_DONE & ~oLE_UCSTATS_REQ ) |=> ~oLE_UCSTATS_DONE[*1:$] );



// synopsys translate_on

endmodule
