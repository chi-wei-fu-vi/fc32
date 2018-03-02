/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: gbl_timer.v$
* $Author: honda.yang $
* $Date: 2013-05-31 10:21:18 -0700 (Fri, 31 May 2013) $
* $Revision: 278 $
* Description: Global Timers for timestamps and interval stats.
*
* 2/21/2013 - tmb - Added reset port for both clk domains.
* 3/8/2013  - tmb - added ">=" to allow shorter interval to be programmed 
*                   to speed up verification.
* 3/27/2013 - tmb - Reduced wrap edge of oGLOBAL_TIMESTAMP from bit 8 to bit 7.
*
***************************************************************************/
module gbl_timer (

// Link Engine
output logic [55:0] oGLOBAL_TIMESTAMP,
output logic 	    oEND_OF_INTERVAL,

// Register
output logic [55:0] oREG_RD_TIMESTAMP,

// Global
input 		        iRST_100M_n,
input 		        iCLK_100M,

input 		        iRST_PCIE_REF_n,
input 		        iCLK_PCIE_REF,

input 		        iRST_FC_CORE_n,
input 		        iCLK_FC_CORE,

input             iRST_GLB_TIMESTAMP_FR,
input             iRST_GLB_TIMESTAMP_FC,
input             iRST_GLB_TIMESTAMP_PCIE,

// Register
input 		        iREG_STATSINTERVAL_ENABLE,
input [39:0] 	    iREG_STATSINTERVAL_CLOCKS

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic [7:0] timestamp_pcie_r, timestamp_pcie_gray_nxt, timestamp_pcie_gray_r;
logic [7:0] timestamp_cclk_nxt, timestamp_cclk_r, timestamp_cclk_p1_r;
logic [7:0] timestamp_core_gray_r, timestamp_core_100m_r, timestamp_100m_gray_r;
logic [7:0] timestamp_100m_nxt, timestamp_100m_r, timestamp_100m_p1_r;
logic timestamp_wrap_cclk, timestamp_wrap_100m;
logic max_interval_r, max_interval_d1_r, max_interval_edge;
logic [39:0] interval_timer_r, interval_minus2_r;
logic move_clocks_pcie_r;

///////////////////////////////////////////////////////////////////////////////
// Timestamp in PCIe Reference Clock Domain
///////////////////////////////////////////////////////////////////////////////
// The 56-bit timestamp is too large to go through gray code coversion
// in one clock cycle. Only 8 bits reside in PCIE clock domain.
// Whenever the 8-bit counter wraps, the upper 48-bit value is then
// incremented by one in core clock domain.
always_ff @( posedge iCLK_PCIE_REF or negedge iRST_PCIE_REF_n )
    if ( ~iRST_PCIE_REF_n )
        timestamp_pcie_r <= 8'b0;
		else if (iRST_GLB_TIMESTAMP_PCIE)
        timestamp_pcie_r <= 8'b0;
    else
        timestamp_pcie_r <= timestamp_pcie_r + 8'b1;

///////////////////////////////////////////////////////////////////////////////
// Timestamp Entering Core Clock Domain
///////////////////////////////////////////////////////////////////////////////
vi_bin2gray #(
    .SIZE       ( 8         )
)
u_timestamp_pcie_bin2gray (
    .gray               ( timestamp_pcie_gray_nxt   ),
    .bin                ( timestamp_pcie_r          )
);

always_ff @( posedge iCLK_PCIE_REF or negedge iRST_PCIE_REF_n )
    if ( ~iRST_PCIE_REF_n )
        timestamp_pcie_gray_r <= 8'b0;
	  else if (iRST_GLB_TIMESTAMP_PCIE)
        timestamp_pcie_gray_r <= 8'b0;
    else
        timestamp_pcie_gray_r <= timestamp_pcie_gray_nxt;

vi_sync_level #(
    .SIZE           ( 8                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_timestamp_gray_core (
    .out_level          ( timestamp_core_gray_r     ),
    .clk                ( iCLK_FC_CORE              ),
    .rst_n              ( iRST_FC_CORE_n            ),
    .in_level           ( timestamp_pcie_gray_r     )
);

vi_gray2bin #(
    .SIZE       ( 8         )
)
u_timestamp_core_gray2bin (
    .bin                ( timestamp_cclk_nxt        ),
    .gray               ( timestamp_core_gray_r     )
);

always_ff @( posedge iCLK_FC_CORE or negedge iRST_FC_CORE_n )
    if ( ~iRST_FC_CORE_n ) begin
        timestamp_cclk_r <= 8'b0;
        timestamp_cclk_p1_r <= 8'b0;
    end
		else if (iRST_GLB_TIMESTAMP_FC) begin
        timestamp_cclk_r <= 8'b0;
        timestamp_cclk_p1_r <= 8'b0;
		end
    else begin
        timestamp_cclk_r <= timestamp_cclk_nxt;
        timestamp_cclk_p1_r <= timestamp_cclk_r;
    end

///////////////////////////////////////////////////////////////////////////////
// Timestamp Wrap in Core Clock Domain
///////////////////////////////////////////////////////////////////////////////
assign timestamp_wrap_cclk = timestamp_cclk_r[7] ^ timestamp_cclk_p1_r[7];

always_ff @( posedge iCLK_FC_CORE or negedge iRST_FC_CORE_n )
    if ( ~iRST_FC_CORE_n ) 
        oGLOBAL_TIMESTAMP <= 56'b0;
	  else if (iRST_GLB_TIMESTAMP_FC)
        oGLOBAL_TIMESTAMP <= 56'b0;
    else begin
        oGLOBAL_TIMESTAMP[6:0]  <= timestamp_cclk_r[6:0];
        if ( timestamp_wrap_cclk )
            oGLOBAL_TIMESTAMP[55:7] <= oGLOBAL_TIMESTAMP[55:7] + 49'b1;
    end

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Timer
///////////////////////////////////////////////////////////////////////////////
// Interval timer can not be shared with timestamp counter because it
// is wrapped around to zero after end of interval.
always_ff @( posedge iCLK_PCIE_REF )
    interval_minus2_r <= iREG_STATSINTERVAL_CLOCKS - 40'd2;

always_ff @( posedge iCLK_PCIE_REF or negedge iRST_PCIE_REF_n )
    if ( ~iRST_PCIE_REF_n ) 
        interval_timer_r <= 40'b0;
    else if ( max_interval_edge )
        interval_timer_r <= 40'b0;
    else
        interval_timer_r <= interval_timer_r + 40'b1;

always_ff @( posedge iCLK_PCIE_REF or negedge iRST_PCIE_REF_n )
    if ( ~iRST_PCIE_REF_n ) begin
        max_interval_r    <= 1'b0;
        max_interval_d1_r <= 1'b0;
    end
    else begin
        max_interval_r <= iREG_STATSINTERVAL_ENABLE & 
                          ( interval_timer_r >= interval_minus2_r ); // tmb(3/8/2013) - added ">=" per request from verification.
        max_interval_d1_r <= max_interval_r;
    end

assign max_interval_edge = max_interval_r & ~max_interval_d1_r;

vi_sync_pulse u_sync_pulse_end_interval (
    .out_pulse          ( oEND_OF_INTERVAL          ),
    .clka               ( iCLK_PCIE_REF             ),
    .clkb               ( iCLK_FC_CORE              ),
    .rsta_n             ( iRST_PCIE_REF_n           ),
    .rstb_n             ( iRST_FC_CORE_n            ),
    .in_pulse           ( max_interval_edge         )
);

///////////////////////////////////////////////////////////////////////////////
// Timestamp Entering 100MHz Clock Domain
///////////////////////////////////////////////////////////////////////////////
// oGLOBAL_TIMESTAMP is transferred from core to 100MHz domain for
// register read.
vi_sync_level #(
    .SIZE           ( 8                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_timestamp_gray_100m (
    .out_level          ( timestamp_100m_gray_r     ),
    .clk                ( iCLK_100M                 ),
    .rst_n              ( iRST_100M_n               ),
    .in_level           ( timestamp_pcie_gray_r     )
);

vi_gray2bin #(
    .SIZE       ( 8         )
)
u_timestamp_100m_gray2bin (
    .bin                ( timestamp_100m_nxt        ),
    .gray               ( timestamp_100m_gray_r     )
);

always_ff @( posedge iCLK_100M or negedge iRST_100M_n )
    if ( ~iRST_100M_n ) begin
        timestamp_100m_r <= 8'b0;
        timestamp_100m_p1_r <= 8'b0;
    end
		else if (iRST_GLB_TIMESTAMP_FR)
		begin
        timestamp_100m_r <= 8'b0;
        timestamp_100m_p1_r <= 8'b0;
    end
    else begin
        timestamp_100m_r <= timestamp_100m_nxt;
        timestamp_100m_p1_r <= timestamp_100m_r;
    end

///////////////////////////////////////////////////////////////////////////////
// Timestamp Wrap in 100MHz Clock Domain
///////////////////////////////////////////////////////////////////////////////
assign timestamp_wrap_100m = timestamp_100m_r[7] ^ timestamp_100m_p1_r[7];

always_ff @( posedge iCLK_100M or negedge iRST_100M_n )
    if ( ~iRST_100M_n ) 
        oREG_RD_TIMESTAMP <= 56'b0;
		else if (iRST_GLB_TIMESTAMP_FR)
        oREG_RD_TIMESTAMP <= 56'b0;
    else begin
        oREG_RD_TIMESTAMP[6:0]  <= timestamp_100m_r[6:0];
        if ( timestamp_wrap_100m )
            oREG_RD_TIMESTAMP[55:7] <= oREG_RD_TIMESTAMP[55:7] + 49'b1;
    end

// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////


// synopsys translate_on

endmodule


