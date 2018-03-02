/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: fc2_frame_stats.v$
* $Author: honda.yang $
* $Date: 2013-12-12 18:29:30 -0800 (Thu, 12 Dec 2013) $
* $Revision: 4074 $
* Description: FC Frame Statistics
*
***************************************************************************/

module fc2_frame_stats (

// Interval Stats Packager
output logic [31:0]     oINT_STATS_FC_CRC,
output logic [31:0]     oINT_STATS_TRUNC,
output logic [31:0]     oINT_STATS_BADEOF,
output logic [31:0]     oINT_STATS_LOSIG,
output logic [31:0]     oINT_STATS_LOSYNC,
output logic            oINT_STATS_LOSIG_LATCH,
output logic            oINT_STATS_LOSYNC_LATCH,

// Registers
output logic            oFC2_REG_FCCRCERRCTR_EN,
output logic            oFC2_REG_FCTRUNCERRCTR_EN,
output logic            oFC2_REG_FCEOFERRCTR_EN,
output logic            oFC2_REG_FCLOSERRCTR_EN,
output logic            oFC2_REG_FCLOSIERRCTR_EN,

// Time Arbiter
output logic            oMIF_LOSYNC,

// Link Engine
output logic            oMIF_LOSIG,

// Global
input                   clk,
input                   rst_n,

// MoreThanIP
input                   iFF_RX_EOP,
input                   iFF_RX_DVAL,
input                   iFF_RX_ERR,
input  [7:0]            iFF_RX_ERR_STAT,
input                   iFC_LINK_SYNC, 

// SFP
input                   iSFP_PHY_LOSIG, //loss of optical signal from SFP; '1' means we have lost the optical signal


// Interval Stats Packager
input                   iINT_STATS_LATCH_CLR

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import mtip_if_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   MTIP_STAT_FFOFLOW       = 2;
parameter   MTIP_STAT_CRCERR        = 1;
parameter   MTIP_STAT_TRUNCERR      = 0;

logic fc2_rx_eop_r, fc2_rx_dval_r, fc2_rx_err_r;
logic [7:0] fc2_rx_err_stat_r;
logic mtip_losync_fcclk_r, sfp_losig_fcclk_r;
logic valid_input;
logic mtip_losync_fcclk_d1_r, sfp_losig_d1_r;
logic sfp_losig_latch_r, mtip_losync_latch_r;

///////////////////////////////////////////////////////////////////////////////
// Flop All Inputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk ) begin
    fc2_rx_eop_r      <= iFF_RX_EOP;
    fc2_rx_dval_r     <= iFF_RX_DVAL;
    fc2_rx_err_r      <= iFF_RX_ERR;
    fc2_rx_err_stat_r <= iFF_RX_ERR_STAT;
end

///////////////////////////////////////////////////////////////////////////////
// Synchronization
///////////////////////////////////////////////////////////////////////////////
// These signals are essentially DC levels, so missing a clock or two
// isn't an issue 
vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_losync (
    .out_level          ( mtip_losync_fcclk_r       ),
    .clk                ( clk                       ),
    .rst_n              ( rst_n                     ),
    .in_level           ( ~iFC_LINK_SYNC            )
);

vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_losig (
    .out_level          ( sfp_losig_fcclk_r         ),
    .clk                ( clk                       ),
    .rst_n              ( rst_n                     ),
    .in_level           ( iSFP_PHY_LOSIG            )
);

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        oMIF_LOSYNC <= 1'b1;
        oMIF_LOSIG  <= 1'b1;
    end
    else begin
        oMIF_LOSYNC <= mtip_losync_fcclk_r;
        oMIF_LOSIG  <= sfp_losig_fcclk_r;
    end

///////////////////////////////////////////////////////////////////////////////
// CRC, Truncate Error 
///////////////////////////////////////////////////////////////////////////////
// only increment the counters when we have an optical signal AND comma-aligned data
assign valid_input = ~sfp_losig_fcclk_r & ~mtip_losync_fcclk_r;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        oFC2_REG_FCCRCERRCTR_EN   <= 1'b0;
        oFC2_REG_FCTRUNCERRCTR_EN <= 1'b0;
    end
    else begin
        oFC2_REG_FCCRCERRCTR_EN   <= valid_input & fc2_rx_err_r & fc2_rx_err_stat_r[ MTIP_STAT_CRCERR ];
        oFC2_REG_FCTRUNCERRCTR_EN <= valid_input & fc2_rx_err_r & fc2_rx_err_stat_r[ MTIP_STAT_TRUNCERR ];
    end

///////////////////////////////////////////////////////////////////////////////
// EOF Error 
///////////////////////////////////////////////////////////////////////////////
//For the EOF errors, bits 7:4 of rx_stat indicate the encoded EOF sequence
// The EOF sequences are as follows (from table 3 of June 2010 version of the MTIP Ref Guide):
//     ff_rx_err_stat[7:4]    FC Abbrv.      Function
//           0000               EOFf         EOF Terminate
//           0001               EOFdt        EOF Disc-Term-Class 1 or Deact-Term-Class 4
//           0010               EOFa         EOF abort
//           0011               EOFn         EOF normal
//           0100               EOFni        EOF normal-invalid
//           0101               EOFdti       EOF disc-term-invalid class 1 or disc-deact-invalid class 4
//           0110               EOFrt        EOF Remove-Terminate Class 4
//           0111               EOFrti       EOF remove-terminate invalid class 4
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oFC2_REG_FCEOFERRCTR_EN <= 1'b0;
    else
        oFC2_REG_FCEOFERRCTR_EN <= fc2_rx_eop_r & fc2_rx_dval_r & 
                                  ( ( fc2_rx_err_stat_r[7:4] == 4'b0100 ) | 
                                    ( fc2_rx_err_stat_r[7:4] == 4'b0101 ) |
                                    ( fc2_rx_err_stat_r[7:4] == 4'b0111 ) | 
                                    ( fc2_rx_err_stat_r[7:4] == 4'b0010 ) );

///////////////////////////////////////////////////////////////////////////////
// Loss of Sync Error 
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk )
    mtip_losync_fcclk_d1_r <= mtip_losync_fcclk_r;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oFC2_REG_FCLOSERRCTR_EN <= 1'b0;
    else
        oFC2_REG_FCLOSERRCTR_EN <= mtip_losync_fcclk_r & ~mtip_losync_fcclk_d1_r;

///////////////////////////////////////////////////////////////////////////////
// Loss of Signal Error 
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk )
    sfp_losig_d1_r <= sfp_losig_fcclk_r;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        oFC2_REG_FCLOSIERRCTR_EN <= 1'b0;
    else
        oFC2_REG_FCLOSIERRCTR_EN <= sfp_losig_fcclk_r & ~sfp_losig_d1_r;

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Packager Interface
///////////////////////////////////////////////////////////////////////////////
invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_fc_crc_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_FC_CRC         ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iINT_STATS_LATCH_CLR      ),
    .increment              ( oFC2_REG_FCCRCERRCTR_EN   )
);

invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_trunc_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_TRUNC          ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iINT_STATS_LATCH_CLR      ),
    .increment              ( oFC2_REG_FCTRUNCERRCTR_EN )
);

invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_bad_eof_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_BADEOF         ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iINT_STATS_LATCH_CLR      ),
    .increment              ( oFC2_REG_FCEOFERRCTR_EN   )
);

invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_losig_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_LOSIG          ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iINT_STATS_LATCH_CLR      ),
    .increment              ( oFC2_REG_FCLOSIERRCTR_EN  )
);

invl_stats_ctr #(
    .SIZE       ( 32                    )
)
u_invl_stats_losync_ctr (
    .latched_stats_ctr_r    ( oINT_STATS_LOSYNC         ),
    .clk                    ( clk                       ),
    .rst_n                  ( rst_n                     ),
    .latch_clr              ( iINT_STATS_LATCH_CLR      ),
    .increment              ( oFC2_REG_FCLOSERRCTR_EN   )
);

///////////////////////////////////////////////////////////////////////////////
// Interval Stats Flags
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        sfp_losig_latch_r <= 1'b0;
    else if ( iINT_STATS_LATCH_CLR )
        sfp_losig_latch_r <= 1'b0;
    else if ( sfp_losig_fcclk_r )
        sfp_losig_latch_r <= 1'b1;

always_ff @( posedge clk )
    if ( iINT_STATS_LATCH_CLR )
        oINT_STATS_LOSIG_LATCH <= sfp_losig_latch_r;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        mtip_losync_latch_r <= 1'b0;
    else if ( iINT_STATS_LATCH_CLR )
        mtip_losync_latch_r <= 1'b0;
    else if ( mtip_losync_fcclk_r )
        mtip_losync_latch_r <= 1'b1;

always_ff @( posedge clk )
    if ( iINT_STATS_LATCH_CLR )
        oINT_STATS_LOSYNC_LATCH <= mtip_losync_latch_r;


// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////



// synopsys translate_on

endmodule
