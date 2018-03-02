/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: stats_clr_syn.v$
* $Author: honda.yang $
* $Date: 2013-12-12 18:29:54 -0800 (Thu, 12 Dec 2013) $
* $Revision: 4075 $
* Description: Interval Stats Clear Synchronization
*
***************************************************************************/

module stats_clr_syn (

// Stats Source Modules
output logic            oSTATS_LATCH_CLR_RXCLK,

// Interval Stats
output logic            oSTATS_LATCH_CLR_DONE_LAT,
output logic [127:0]    oSTATS_MEM_DATA,

// Global
input                   iRST_FC_CORE_N,
input                   iRST_FC_RX_N,
input                   iCLK_FC_CORE,     /* 212.5MHz */
input                   iCLK_FC_RX,       // recovered clock

// Interval Stats
input                   iINT_STATS_LATCH_CLR,
input  [2:0]            iINT_STATS_MEM_RA,
input                   iINT_STATS_BOTH_CH_DONE,

// Credit Stats
input  [31:0]           iINT_STATS_TIMECR,
input  [31:0]           iINT_STATS_MINCR,
input  [31:0]           iINT_STATS_MAXCR,
input  [31:0]           iINT_STATS_ENDCR,

// MTIP Interface
input  [31:0]           iINT_STATS_FC_CODE,
input  [31:0]           iINT_STATS_NOS_OLS,
input  [31:0]           iINT_STATS_LR_LRR,
input  [31:0]           iINT_STATS_LINK_UP,
input                   iINT_STATS_UP_LATCH,
input                   iINT_STATS_LR_LRR_LATCH,
input                   iINT_STATS_NOS_LOS_LATCH

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
logic latch_clr_done_fcclk;
logic latch_clr_timeout_fcclk;
logic latch_clr_done_both, latch_clr_done_both_d1_r;
logic [3:0] clr_rxclk_dly_r;
logic stats_mem_we_r;
logic [1:0] stats_mem_wa_r;
logic [127:0] stats_mem_wd_r;
logic [7:0] flag_status_wd_r;
logic [127:0]    stats_mem_data;

/*
 * lzhou :
 * The following logic needs a reliable iCLK_FC_RX to operate correctly.  When
 * the RX clock is missing, the latch_clr_done_fcclk pulse will halt and the
 * interval stats will halt.  This causes a system wide PCIe halt.
 *
 * The fix is to introduct timeout in the iCLK_FC_CORE domain, which is
 * a reliable board-sourced clock.  When timeout happens, the latch clear
 * pulse will be forwarded to the downstream block.
 */
/*
///////////////////////////////////////////////////////////////////////////////
// Stats Latch Synchronizer from iCLK_FC_CORE to iCLK_FC_RX Domain
///////////////////////////////////////////////////////////////////////////////
vi_sync_pulse u_sync_pls_latch_clr_rxclk (
            .out_pulse          ( oSTATS_LATCH_CLR_RXCLK        ),
            .clka               ( iCLK_FC_CORE                  ),
            .clkb               ( iCLK_FC_RX                    ),
            .rsta_n             ( iRST_FC_CORE_N                ),
            .rstb_n             ( iRST_FC_RX_N                  ),
            .in_pulse           ( iINT_STATS_LATCH_CLR          )
);

always_ff @( posedge iCLK_FC_RX or negedge iRST_FC_RX_N )
    if ( ~iRST_FC_RX_N ) 
        clr_rxclk_dly_r <= 4'b0;
    else 
        clr_rxclk_dly_r <= {clr_rxclk_dly_r[2:0], oSTATS_LATCH_CLR_RXCLK};

///////////////////////////////////////////////////////////////////////////////
// Stats Latch Synchronizer from iCLK_FC_RX to iCLK_FC_CORE Domain
///////////////////////////////////////////////////////////////////////////////
vi_sync_pulse u_sync_pls_latch_clr_core_clk (
            .out_pulse          ( latch_clr_done_fcclk          ),
            .clka               ( iCLK_FC_RX                    ),
            .clkb               ( iCLK_FC_CORE                  ),
            .rsta_n             ( iRST_FC_RX_N                  ),
            .rstb_n             ( iRST_FC_CORE_N                ),
            .in_pulse           ( clr_rxclk_dly_r[3]            )
);
*/

vi_stats_latch_sync
# (  /* 5 cycle latency in clkb domain.  Timeout = 16 clocks in clka domain */
  .TIMEOUT_WIDTH(6),
  .CLKB_WIDTH(5)
) vi_stats_latch_sync_inst
(
  .clka(iCLK_FC_CORE),
  .clkb(iCLK_FC_RX),
  .rsta_n(iRST_FC_CORE_N),
  .rstb_n(iRST_FC_RX_N),
  .invl_latch_pulse(iINT_STATS_LATCH_CLR),
  .invl_clr_done_pulse(latch_clr_done_fcclk),
  .invl_clr_timeout_level(latch_clr_timeout_fcclk)
);

vi_sync_pulse u_sync_pls_latch_clr_rxclk (
            .out_pulse          ( oSTATS_LATCH_CLR_RXCLK        ),
            .clka               ( iCLK_FC_CORE                  ),
            .clkb               ( iCLK_FC_RX                    ),
            .rsta_n             ( iRST_FC_CORE_N                ),
            .rstb_n             ( iRST_FC_RX_N                  ),
            .in_pulse           ( iINT_STATS_LATCH_CLR          )
);

always_ff @( posedge iCLK_FC_CORE or negedge iRST_FC_CORE_N )
    if ( ~iRST_FC_CORE_N ) 
        clr_rxclk_dly_r <= 4'b0;
    else 
        clr_rxclk_dly_r <= {clr_rxclk_dly_r[2:0], latch_clr_done_fcclk};



///////////////////////////////////////////////////////////////////////////////
// Stats Latch Done 
///////////////////////////////////////////////////////////////////////////////
// latch_clr_done_fcclk may be separated by multiple cycles for slower speed.
// One clock cycle difference between two oSTATS_LATCH_CLR_RXCLK may be
// many cycles in iCLK_FC_CORE domain.
always_ff @( posedge iCLK_FC_CORE or negedge iRST_FC_CORE_N )
    if ( ~iRST_FC_CORE_N ) 
        oSTATS_LATCH_CLR_DONE_LAT <= 1'b0;
    else begin
        if ( oSTATS_LATCH_CLR_DONE_LAT )
            oSTATS_LATCH_CLR_DONE_LAT <= ~iINT_STATS_BOTH_CH_DONE;
        else
            oSTATS_LATCH_CLR_DONE_LAT <= latch_clr_done_fcclk;
    end

///////////////////////////////////////////////////////////////////////////////
// Latch Stats Flags
///////////////////////////////////////////////////////////////////////////////
assign flag_status_wd_r[7:4] = 4'b0;
assign flag_status_wd_r[3] = iINT_STATS_LR_LRR_LATCH;
assign flag_status_wd_r[2] = iINT_STATS_NOS_LOS_LATCH;
assign flag_status_wd_r[1] = iINT_STATS_UP_LATCH;
assign flag_status_wd_r[0] = 1'b0;

/* synchronization not needed, since latched status is static.  Latching is done 
 * at the conclusion of oSTATS_LATCH_CLR_DONE_LAT.  This means the source
 * latched counts are stable for sure.  INVL_LATCH_CLR are sent to the target
 * in both CORE_CLK and RX_CLK versions.
 */
always_ff @( posedge iCLK_FC_CORE or negedge iRST_FC_CORE_N )
    if (!iRST_FC_CORE_N)
        oSTATS_MEM_DATA[127:0 ] <= 128'b0;
    else
    unique case ( {latch_clr_timeout_fcclk, iINT_STATS_MEM_RA} )
        4'b0001: begin
            oSTATS_MEM_DATA[127:96] <= iINT_STATS_LINK_UP;
            oSTATS_MEM_DATA[95 :64] <= iINT_STATS_LR_LRR;
            oSTATS_MEM_DATA[63 :32] <= iINT_STATS_NOS_OLS;
            oSTATS_MEM_DATA[31 :0 ] <= {32{1'b0}};
        end
        4'b0010: begin
            oSTATS_MEM_DATA[127:96] <= {32{1'b0}};
            oSTATS_MEM_DATA[95 :64] <= {32{1'b0}};
            oSTATS_MEM_DATA[63 :32] <= {32{1'b0}};
            oSTATS_MEM_DATA[31 :0 ] <= iINT_STATS_FC_CODE; 
        end
        4'b0011: begin
            oSTATS_MEM_DATA[127:96] <= {24'b0, flag_status_wd_r};
            oSTATS_MEM_DATA[95 :64] <= iINT_STATS_MAXCR;
            oSTATS_MEM_DATA[63 :32] <= iINT_STATS_MINCR;
            oSTATS_MEM_DATA[31 :0 ] <= iINT_STATS_TIMECR;
        end
        4'b0101: begin
            oSTATS_MEM_DATA[127:96] <= {32{1'b0}};
            oSTATS_MEM_DATA[95 :64] <= iINT_STATS_ENDCR;
            oSTATS_MEM_DATA[63 :32] <= {32{1'b0}};
            oSTATS_MEM_DATA[31 :0 ] <= {32{1'b0}};
        end
        default: begin
            oSTATS_MEM_DATA[127:0 ] <= 128'b0;
        end

    endcase



endmodule
