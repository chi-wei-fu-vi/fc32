/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: frame_packager.v$
* $Author: honda.yang $
* $Date: 2014-01-14 14:57:04 -0800 (Tue, 14 Jan 2014) $
* $Revision: 4192 $
* Description: Frame Packager organizes the extracted frames from
*              Frame Extractor into 64 byte packets.
*
***************************************************************************/

module frame_packager (

// Channel FIFO
output logic [127:0]    oFMPG_CHF_DATA,
output logic            oFMPG_CHF_SOP,
output logic            oFMPG_CHF_EOP,
output logic            oFMPG_CHF_VALID,

// Timestamp FIFO
output logic            oEXTR_FC_TS_FIFO_POP,

// Global
input                   clk,
input                   rst_n,
input                   iFC8_MODE,
input                   iCHANNEL_ID,

// Timestamp FIFO
input  [107:0]          iFC_EXTR_FUTURE_TS,

// Frame Extractor
input  [63:0]           iFMEX_FMPG_DATA,
input                   iFMEX_FMPG_SOP,
input                   iFMEX_FMPG_EOP,
input                   iFMEX_FMPG_ERR,
input                   iFMEX_FMPG_VALID,
input                   iFMEX_FMPG_ZERO,
input  [13:0]           iFMEX_FMPG_LENGTH,

// Channel FIFO
input                   iCHF_DATCHNL_FIFO_AFULL

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import extractor_cfg::*;
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   RD_WAIT_S0_ST           = 0;
parameter   RD_S0_START_ST          = 1;
parameter   RD_WAIT_S1_ST           = 2;
parameter   RD_S1_START_ST          = 3;

// user defined types
timestamp_bus time_fifo_rd_data;
assign time_fifo_rd_data = iFC_EXTR_FUTURE_TS;

logic [63:0] package_hi_mem_rd_r, package_lo_mem_rd_r;
logic [2:0] package_hi_mem_wa_r, package_lo_mem_wa_r, package_mem_ra_r;
logic [63:0] package_hi_mem_wd_r, package_lo_mem_wd_r;
logic [55:0] seg_0_extra_pkg_mem_r, seg_1_extra_pkg_mem_r;
logic frm_sop_p1_r, frm_eop_p1_r, frm_valid_p1_r, frm_err_p1_r;
logic sel_wr_segment_1_r, sel_wr_hi_bank_r;
logic package_hi_mem_we_r, package_lo_mem_we_r;
logic wr_last_8byte, extra_lo_bank_we_r;
logic segment_0_avail_r, segment_0_error_r, segment_1_avail_r, segment_1_error_r;
logic segment_0_extra_r, segment_1_extra_r;
logic [1:0] seg_0_hi_last_wa_r, seg_0_lo_last_wa_r;
logic [1:0] seg_1_hi_last_wa_r, seg_1_lo_last_wa_r;
logic [1:0] hi_last_wa_r, lo_last_wa_r;
logic [1:0] hi_bank_mem_ptr_r, lo_bank_wr_ptr_r;
logic [1:0] mem_rd_ptr_r, mem_rd_ptr_p1_r, mem_rd_ptr_p2_r;
logic sel_rd_segment_1_r, sel_ra_segment_1_r;
logic [3:0] pkg_rd_state_nxt, pkg_rd_state_r;
logic frame_discard_r, incr_mem_rd_ptr, extra_valid_r;
logic first_mem_rd_p1_r, first_mem_rd_p2_r;
logic last_mem_rd_p1_r, last_mem_rd_p2_r;
logic incr_mem_rd_p1_r, incr_mem_rd_p2_r;
logic [13:0] eth_frame_len;
logic [13:0] extr_frm_len_lat_r, extr_frm_length;
logic seg_0_extra_we_dly_r, seg_1_extra_we_dly_r;
logic [55:0] mux_extra_pkg_mem;

///////////////////////////////////////////////////////////////////////////////
// Packager RAM Instantiation
///////////////////////////////////////////////////////////////////////////////
// There are two packager memory instances, 64-bit wide each.
// Frame Packager is responsible adding timestamp and length info in
// addition to frames from extractor. The additional info will require
// extra bandwidth which is achieved by doubling the data bus width.
ram1r1w1c #(
    .ADDR_WIDTH ( 3                     ),
    .DEPTH      ( 8                     ),
    .DATA_WIDTH ( 64                    ),
    .PIPE       ( 1                     )
)
u_package_hi_bank_ram (
    .rddata             ( package_hi_mem_rd_r       ),
    .clk                ( clk                       ),
    .rdaddr             ( package_mem_ra_r          ),
    .wraddr             ( package_hi_mem_wa_r       ),
    .wrdata             ( package_hi_mem_wd_r       ),
    .wren               ( package_hi_mem_we_r       )
);

ram1r1w1c #(
    .ADDR_WIDTH ( 3                     ),
    .DEPTH      ( 8                     ),
    .DATA_WIDTH ( 64                    ),
    .PIPE       ( 1                     )
)
u_package_lo_bank_ram (
    .rddata             ( package_lo_mem_rd_r       ),
    .clk                ( clk                       ),
    .rdaddr             ( package_mem_ra_r          ),
    .wraddr             ( package_lo_mem_wa_r       ),
    .wrdata             ( package_lo_mem_wd_r       ),
    .wren               ( package_lo_mem_we_r       )
);

///////////////////////////////////////////////////////////////////////////////
// Extra Low Packager Memory
///////////////////////////////////////////////////////////////////////////////
// At EOP time, if there are less than 48 byte extracted data, Frame Length 
// is written to the last 8 byte location.
// The frame length write requires one extra write operation following EOP 
// if extracted data is written to low memory bank.
// Instead of writing to the main memory array, the extra storage space is 
// implemented in flops to avoid contention with the next frame.
// The worst case IPG timing is zero cycle between two Pause frames from the
// Frame Extractor.
always_ff @( posedge clk ) 
    if ( ( ~sel_wr_segment_1_r & extra_lo_bank_we_r ) | seg_0_extra_we_dly_r ) begin
        seg_0_extra_pkg_mem_r[55:32] <= time_fifo_rd_data.fcmap;
        seg_0_extra_pkg_mem_r[31:16] <= time_fifo_rd_data.vlan;
        seg_0_extra_pkg_mem_r[15:0]  <= {iCHANNEL_ID, 1'b0, eth_frame_len};
    end

always_ff @( posedge clk ) 
    if ( ( sel_wr_segment_1_r & extra_lo_bank_we_r ) | seg_1_extra_we_dly_r ) begin
        seg_1_extra_pkg_mem_r[55:32] <= time_fifo_rd_data.fcmap;
        seg_1_extra_pkg_mem_r[31:16] <= time_fifo_rd_data.vlan;
        seg_1_extra_pkg_mem_r[15:0]  <= {iCHANNEL_ID, 1'b0, eth_frame_len};
    end

// If the extractor packet is only one cycle wide (i.e. <= 8 bytes or
// iFMEX_FMPG_SOP overlaps with iFMEX_FMPG_EOP ), time_fifo_rd_data
// may not be valid as oEXTR_FC_TS_FIFO_POP is derived from first_mem_rd_p2_r.
// seg_extra_pkg_mem_r is written one more time following extra_lo_bank_we_r for
// the correct time_fifo_rd_data.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        seg_0_extra_we_dly_r <= 1'b0;
        seg_1_extra_we_dly_r <= 1'b0;
    end
    else begin
        seg_0_extra_we_dly_r <= ~sel_wr_segment_1_r & extra_lo_bank_we_r & frm_sop_p1_r & frm_eop_p1_r;
        seg_1_extra_we_dly_r <=  sel_wr_segment_1_r & extra_lo_bank_we_r & frm_sop_p1_r & frm_eop_p1_r;
    end

///////////////////////////////////////////////////////////////////////////////
// Pipelines
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        frm_sop_p1_r <= 1'b0;
        frm_eop_p1_r <= 1'b0;
        frm_valid_p1_r <= 1'b0;
    end
    else begin
        frm_sop_p1_r <= iFMEX_FMPG_SOP;
        frm_eop_p1_r <= iFMEX_FMPG_EOP;
        frm_valid_p1_r <= iFMEX_FMPG_VALID;
    end

always_ff @( posedge clk ) 
    frm_err_p1_r  <= iFMEX_FMPG_ERR | iFMEX_FMPG_ZERO;

///////////////////////////////////////////////////////////////////////////////
// Package Memory Write Segment Select 
///////////////////////////////////////////////////////////////////////////////
// The memory has two 64 byte segments acting as a ping-pong buffer.
// While one segment is being written by the Frame Extractor, the
// other segment is being read to the Channel FIFO.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        sel_wr_segment_1_r <= 1'b0;
    else if ( frm_eop_p1_r )
        sel_wr_segment_1_r <= ~sel_wr_segment_1_r;

///////////////////////////////////////////////////////////////////////////////
// Package Memory Write Control 
///////////////////////////////////////////////////////////////////////////////
// 1) SOP time: 
//    Timestamp and Frame Type are written to the high memory bank
//    while extracted data is written to the low memory bank.
// 2) The subsequent data is ping-pong between high and low memory banks.
// 3) EOP time: 
//    A) 48 byte extracted data has been written
//       Frame Length is written along with extracted data
//    B) Less than 48 byte extracted data has been written
//       Extracted data is written to its regular location
//       Frame Length is written to the last 8 byte location
//       The frame length write requires one extra write operation 
//       following EOP if extracted data is written to low memory bank.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        package_hi_mem_we_r <= 1'b0;
        package_lo_mem_we_r <= 1'b0;
    end
    else begin
        package_hi_mem_we_r <= iFMEX_FMPG_SOP | 
                               (  sel_wr_hi_bank_r & iFMEX_FMPG_VALID );
        package_lo_mem_we_r <= iFMEX_FMPG_SOP |
                               ( ~sel_wr_hi_bank_r & iFMEX_FMPG_VALID );
    end

assign wr_last_8byte = ( lo_bank_wr_ptr_r == 2'd3 ) & ~sel_wr_hi_bank_r;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        extra_lo_bank_we_r <= 1'b0;
    else 
        extra_lo_bank_we_r <= iFMEX_FMPG_EOP & ~wr_last_8byte;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        sel_wr_hi_bank_r <= 1'b1;
    else if ( iFMEX_FMPG_SOP )
        sel_wr_hi_bank_r <= 1'b1;
    else if ( iFMEX_FMPG_VALID )
        sel_wr_hi_bank_r <= ~sel_wr_hi_bank_r;

///////////////////////////////////////////////////////////////////////////////
// Segment Status
///////////////////////////////////////////////////////////////////////////////
// Segment 0
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        segment_0_avail_r <= 1'b0;
    else if ( ~sel_wr_segment_1_r & frm_eop_p1_r )
        segment_0_avail_r <= 1'b1;
    else if ( ~sel_rd_segment_1_r & last_mem_rd_p1_r )
        segment_0_avail_r <= 1'b0;

// Zero frames are treated as errors as they are eventually discarded.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        segment_0_error_r <= 1'b0;
    else if ( ~sel_wr_segment_1_r & frm_valid_p1_r & frm_err_p1_r )
        segment_0_error_r <= 1'b1;
    else if ( ~sel_rd_segment_1_r & last_mem_rd_p1_r )
        segment_0_error_r <= 1'b0;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        segment_0_extra_r <= 1'b0;
    else if ( ~sel_wr_segment_1_r & extra_lo_bank_we_r )
        segment_0_extra_r <= 1'b1;
    else if ( ~sel_rd_segment_1_r & last_mem_rd_p1_r )
        segment_0_extra_r <= 1'b0;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        seg_0_hi_last_wa_r <= 2'b0;
    else if ( ~sel_wr_segment_1_r & package_hi_mem_we_r ) 
        seg_0_hi_last_wa_r <= hi_bank_mem_ptr_r;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        seg_0_lo_last_wa_r <= 2'b0;
    else if ( ~sel_wr_segment_1_r & package_lo_mem_we_r ) 
        seg_0_lo_last_wa_r <= lo_bank_wr_ptr_r;

// Segment 1
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        segment_1_avail_r <= 1'b0;
    else if ( sel_wr_segment_1_r & frm_eop_p1_r )
        segment_1_avail_r <= 1'b1;
    else if ( sel_rd_segment_1_r & last_mem_rd_p1_r )
        segment_1_avail_r <= 1'b0;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        segment_1_error_r <= 1'b0;
    else if ( sel_wr_segment_1_r & frm_valid_p1_r & frm_err_p1_r )
        segment_1_error_r <= 1'b1;
    else if ( sel_rd_segment_1_r & last_mem_rd_p1_r )
        segment_1_error_r <= 1'b0;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        segment_1_extra_r <= 1'b0;
    else if ( sel_wr_segment_1_r & extra_lo_bank_we_r )
        segment_1_extra_r <= 1'b1;
    else if ( sel_rd_segment_1_r & last_mem_rd_p1_r )
        segment_1_extra_r <= 1'b0;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        seg_1_hi_last_wa_r <= 2'b0;
    else if ( sel_wr_segment_1_r & package_hi_mem_we_r ) 
        seg_1_hi_last_wa_r <= hi_bank_mem_ptr_r;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        seg_1_lo_last_wa_r <= 2'b0;
    else if ( sel_wr_segment_1_r & package_lo_mem_we_r ) 
        seg_1_lo_last_wa_r <= lo_bank_wr_ptr_r;

///////////////////////////////////////////////////////////////////////////////
// High Memory Bank Write
///////////////////////////////////////////////////////////////////////////////
// Timestamp and frame type fields are place holders. They are filled when
// reading from packager FIFO to pop the timestamp FIFO as late as possible.
always_ff @( posedge clk ) 
    if ( iFMEX_FMPG_SOP ) 
        package_hi_mem_wd_r <= 64'b0;
    else 
        package_hi_mem_wd_r <= iFMEX_FMPG_DATA[63:0];

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        hi_bank_mem_ptr_r <= 2'b0;
    else if ( frm_eop_p1_r )
        hi_bank_mem_ptr_r <= 2'b0;
    else if ( package_hi_mem_we_r ) 
        hi_bank_mem_ptr_r <= hi_bank_mem_ptr_r + 2'b1;

assign package_hi_mem_wa_r = {sel_wr_segment_1_r, hi_bank_mem_ptr_r};

///////////////////////////////////////////////////////////////////////////////
// Low Memory Bank Write
///////////////////////////////////////////////////////////////////////////////
// FCoE data frames:
// The following overhead bytes are not included in iFMEX_FMPG_LENGTH
// 1) Ethernet MAC header and CRC 
//    a) VLAN on:  22 bytes
//    b) VLAN off: 18 bytes
// 2) FCoE reserved fields prior to and include SOF: 14 bytes
// 3) FC CRC: 4 bytes
// 4) FCoE EOF: 4 bytes
//
// Pause frames:
// iFMEX_FMPG_LENGTH includes MAC header and CRC
//
// iFMEX_FMPG_LENGTH is valid at and after EOP
//
// FC data frames:
// FC CRC is added without receiving from MTIP
//
always_ff @( posedge clk ) 
    if ( iFMEX_FMPG_EOP )
        extr_frm_len_lat_r <= iFMEX_FMPG_LENGTH;

assign extr_frm_length = iFMEX_FMPG_EOP ? iFMEX_FMPG_LENGTH : extr_frm_len_lat_r;

always_comb
    if ( time_fifo_rd_data.index[ FRM_INDEX_PAUSE ] )
        eth_frame_len = extr_frm_length;
    else begin
        if ( iFC8_MODE )
            eth_frame_len = extr_frm_length + 14'd4;
        else begin
            if ( time_fifo_rd_data.vlan_vld )
                eth_frame_len = extr_frm_length + 14'd44;
            else
                eth_frame_len = extr_frm_length + 14'd40;
        end
    end

// Frame length is lower 2 bytes
always_ff @( posedge clk ) 
    if ( iFMEX_FMPG_EOP & wr_last_8byte ) begin
        package_lo_mem_wd_r[63:56] <= iFMEX_FMPG_DATA[63:56];
        if ( iFC8_MODE )
            package_lo_mem_wd_r[55:32] <= iFMEX_FMPG_DATA[55:32];
        else
            package_lo_mem_wd_r[55:32] <= time_fifo_rd_data.fcmap;
        package_lo_mem_wd_r[31:16] <= time_fifo_rd_data.vlan;
        package_lo_mem_wd_r[15:0]  <= {iCHANNEL_ID, 1'b0, eth_frame_len};
    end
    else 
        package_lo_mem_wd_r <= iFMEX_FMPG_DATA[63:0];

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        lo_bank_wr_ptr_r <= 2'b0;
    else if ( frm_eop_p1_r )
        lo_bank_wr_ptr_r <= 2'b0;
    else if ( package_lo_mem_we_r ) 
        lo_bank_wr_ptr_r <= lo_bank_wr_ptr_r + 2'b1;

assign package_lo_mem_wa_r = {sel_wr_segment_1_r, lo_bank_wr_ptr_r};

///////////////////////////////////////////////////////////////////////////////
// Package Memory Read Segment Select 
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        sel_rd_segment_1_r <= 1'b0;
    else if ( last_mem_rd_p2_r )
        sel_rd_segment_1_r <= ~sel_rd_segment_1_r;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        sel_ra_segment_1_r <= 1'b0;
    else if ( last_mem_rd_p1_r )
        sel_ra_segment_1_r <= ~sel_ra_segment_1_r;

///////////////////////////////////////////////////////////////////////////////
// Package Memory Read State Machine
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    pkg_rd_state_nxt = 4'b0;
    unique case ( 1'b1 )
        pkg_rd_state_r[ RD_WAIT_S0_ST ]: begin
            if ( segment_0_avail_r )
                pkg_rd_state_nxt[ RD_S0_START_ST ] = 1'b1;
            else
                pkg_rd_state_nxt[ RD_WAIT_S0_ST ] = 1'b1;
        end
        pkg_rd_state_r[ RD_S0_START_ST ]: begin
            if ( mem_rd_ptr_r == 2'd0 )
                pkg_rd_state_nxt[ RD_WAIT_S1_ST ] = 1'b1;
            else
                pkg_rd_state_nxt[ RD_S0_START_ST ] = 1'b1;
        end
        pkg_rd_state_r[ RD_WAIT_S1_ST ]: begin
            if ( segment_1_avail_r )
                pkg_rd_state_nxt[ RD_S1_START_ST ] = 1'b1;
            else
                pkg_rd_state_nxt[ RD_WAIT_S1_ST ] = 1'b1;
        end
        pkg_rd_state_r[ RD_S1_START_ST ]: begin
            if ( mem_rd_ptr_r == 2'd0 )
                pkg_rd_state_nxt[ RD_WAIT_S0_ST ] = 1'b1;
            else
                pkg_rd_state_nxt[ RD_S1_START_ST ] = 1'b1;
        end
        default: begin
            pkg_rd_state_nxt[ RD_WAIT_S0_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        pkg_rd_state_r <= 4'b0;
        pkg_rd_state_r[ RD_WAIT_S0_ST ] <= 1'b1;
    end
    else
        pkg_rd_state_r <= pkg_rd_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Memory Bank Read Pointer
///////////////////////////////////////////////////////////////////////////////
assign incr_mem_rd_ptr = pkg_rd_state_nxt[ RD_S0_START_ST ] | 
                         pkg_rd_state_nxt[ RD_S1_START_ST ];

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        mem_rd_ptr_r <= 2'b0;
    else if ( incr_mem_rd_ptr )
        mem_rd_ptr_r <= mem_rd_ptr_r + 2'b1;

assign package_mem_ra_r = {sel_ra_segment_1_r, mem_rd_ptr_r};

always_ff @( posedge clk ) begin
   mem_rd_ptr_p1_r <= mem_rd_ptr_r;
   mem_rd_ptr_p2_r <= mem_rd_ptr_p1_r;
end

///////////////////////////////////////////////////////////////////////////////
// Memory Bank Read Data
///////////////////////////////////////////////////////////////////////////////
// PCIe is little endian. Command type is at byte position 0.
// Timestamp is from byte 7 to 1 without byte swapping.
always_ff @( posedge clk ) begin
    if ( first_mem_rd_p2_r ) begin
        oFMPG_CHF_DATA[7:6]  <= 2'b0;
        // First Packet bit is a place holder. It is filled by Time Arbiter
        oFMPG_CHF_DATA[5]    <= 1'b0;
        oFMPG_CHF_DATA[4]    <= time_fifo_rd_data.vlan_vld;
        oFMPG_CHF_DATA[3:0]  <= dal_type( time_fifo_rd_data.index );
        oFMPG_CHF_DATA[63:8] <= time_fifo_rd_data.timestamp;
    end
    // Undefined extracted frame data is zero out
    // Data field is byte reversed. 
    else if ( mem_rd_ptr_p2_r > hi_last_wa_r )
        oFMPG_CHF_DATA[63:0] <= 64'b0;
    else 
        oFMPG_CHF_DATA[63:0] <= endian_swap_64( package_hi_mem_rd_r[63:0] );

    // Undefined extracted frame data is zero out
    // Frame length is lower 2 bytes
    // VLAN is before Frame Length
    if ( mem_rd_ptr_p2_r == 2'd3 ) begin
        if ( extra_valid_r ) begin
            oFMPG_CHF_DATA[71:64  ] <= 8'b0;
            oFMPG_CHF_DATA[95:72  ] <= mux_extra_pkg_mem[55:32];
            oFMPG_CHF_DATA[111:96 ] <= mux_extra_pkg_mem[31:16];
            oFMPG_CHF_DATA[127:112] <= mux_extra_pkg_mem[15:0];
        end
        else begin
            // 2-byte length field is not byte swapped
            if ( iFC8_MODE )
                oFMPG_CHF_DATA[127:64 ] <= {package_lo_mem_rd_r[15:0], package_lo_mem_rd_r[31:16], 
                                            endian_swap_32( package_lo_mem_rd_r[63:32] )};
            // 2-byte VLAN field is not byte swapped
            // 3-byte FCMAP field is not byte swapped
            else
                oFMPG_CHF_DATA[127:64 ] <= {package_lo_mem_rd_r[15:0], package_lo_mem_rd_r[31:16], 
                                            package_lo_mem_rd_r[55:32], package_lo_mem_rd_r[63:56]};
        end
    end
    else if ( mem_rd_ptr_p2_r > lo_last_wa_r ) 
        oFMPG_CHF_DATA[127:64] <= 64'b0;
    else
        oFMPG_CHF_DATA[127:64] <= endian_swap_64( package_lo_mem_rd_r[63:0] );
end

assign mux_extra_pkg_mem = sel_rd_segment_1_r ? seg_1_extra_pkg_mem_r : seg_0_extra_pkg_mem_r;

// Byte swapping within QWORD
function [63:0] endian_swap_64;
    input [63:0] data;
begin
    endian_swap_64[63:56] = data[7:0];
    endian_swap_64[55:48] = data[15:8];
    endian_swap_64[47:40] = data[23:16];
    endian_swap_64[39:32] = data[31:24];
    endian_swap_64[31:24] = data[39:32];
    endian_swap_64[23:16] = data[47:40];
    endian_swap_64[15:8]  = data[55:48];
    endian_swap_64[7:0]   = data[63:56];
end
endfunction

function [31:0] endian_swap_32;
    input [31:0] data;
begin
    endian_swap_32[31:24] = data[7:0];
    endian_swap_32[23:16] = data[15:8];
    endian_swap_32[15:8]  = data[23:16];
    endian_swap_32[7:0]   = data[31:24];
end
endfunction

///////////////////////////////////////////////////////////////////////////////
// Channel FIFO Interface
///////////////////////////////////////////////////////////////////////////////
// Error frames are discarded by de-asserting SOP, EOP, VALID
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        frame_discard_r <= 1'b0;
    else if ( first_mem_rd_p1_r )
        frame_discard_r <= sel_rd_segment_1_r ? segment_1_error_r : segment_0_error_r;

// Extra storage valid
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        extra_valid_r <= 1'b0;
    else if ( first_mem_rd_p1_r )
        extra_valid_r <= sel_rd_segment_1_r ? segment_1_extra_r : segment_0_extra_r;

// Undefined extracted frame data is zero out
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        hi_last_wa_r <= 2'b0;
        lo_last_wa_r <= 2'b0;
    end
    else if ( first_mem_rd_p1_r ) begin
        hi_last_wa_r <= sel_rd_segment_1_r ? seg_1_hi_last_wa_r : seg_0_hi_last_wa_r;
        lo_last_wa_r <= sel_rd_segment_1_r ? seg_1_lo_last_wa_r : seg_0_lo_last_wa_r;
    end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        first_mem_rd_p1_r <= 1'b0;
        first_mem_rd_p2_r <= 1'b0;
        oFMPG_CHF_SOP <= 1'b0;
    end
    else begin
        first_mem_rd_p1_r <= incr_mem_rd_ptr & ( mem_rd_ptr_r == 2'd0 );
        first_mem_rd_p2_r <= first_mem_rd_p1_r;
        oFMPG_CHF_SOP <= first_mem_rd_p2_r & ~frame_discard_r;
    end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        last_mem_rd_p1_r <= 1'b0;
        last_mem_rd_p2_r <= 1'b0;
        oFMPG_CHF_EOP <= 1'b0;
    end
    else begin
        last_mem_rd_p1_r <= incr_mem_rd_ptr & ( mem_rd_ptr_r == 2'd3 );
        last_mem_rd_p2_r <= last_mem_rd_p1_r;
        oFMPG_CHF_EOP <= last_mem_rd_p2_r & ~frame_discard_r;
    end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        incr_mem_rd_p1_r <= 1'b0;
        incr_mem_rd_p2_r <= 1'b0;
        oFMPG_CHF_VALID <= 1'b0;
    end
    else begin
        incr_mem_rd_p1_r <= incr_mem_rd_ptr;
        incr_mem_rd_p2_r <= incr_mem_rd_p1_r;
        oFMPG_CHF_VALID <= incr_mem_rd_p2_r & ~frame_discard_r;
    end

///////////////////////////////////////////////////////////////////////////////
// Timestamp FIFO Pop
///////////////////////////////////////////////////////////////////////////////
// After timestamp FIFO information is sent to channel FIFO, the next entry
// is then popped. It is a show-through FIFO.
assign oEXTR_FC_TS_FIFO_POP = first_mem_rd_p2_r;

///////////////////////////////////////////////////////////////////////////////
// Frame Type
///////////////////////////////////////////////////////////////////////////////
function [3:0] dal_type;
    input [2:0] index;
begin
    dal_type = 4'b0;
    unique case ( 1'b1 )
        index[ FRM_INDEX_DATA  ]: dal_type = DAL_DATA_TYPE;
        index[ FRM_INDEX_PAUSE ]: dal_type = DAL_PAUSE_TYPE;
        index[ FRM_INDEX_CTL   ]: dal_type = DAL_CTRL_TYPE;
    endcase
end
endfunction




// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
pkt_prop_checker #(
    .DATA_WIDTH ( 128                   )
)
u_frame_package_pkt_prop_checker (
    .clk                ( clk                   ),
    .rst_n              ( rst_n                 ),
    .data               ( oFMPG_CHF_DATA        ),
    .sop                ( oFMPG_CHF_SOP         ),
    .eop                ( oFMPG_CHF_EOP         ),
    .valid              ( oFMPG_CHF_VALID       )
);

final begin
    assert_pkg_hi_bank_ram_empty: assert ( package_mem_ra_r == package_hi_mem_wa_r );
    assert_pkg_lo_bank_ram_empty: assert ( package_mem_ra_r == package_lo_mem_wa_r );
    assert_segment_0_empty: assert ( segment_0_avail_r == 0 );
    assert_segment_1_empty: assert ( segment_1_avail_r == 0 );
end

// synopsys translate_on

endmodule
