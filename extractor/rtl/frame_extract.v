/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: frame_extract.v$
* $Author: honda.yang $
* $Date: 2013-07-22 16:29:59 -0700 (Mon, 22 Jul 2013) $
* $Revision: 2925 $
* Description: Frame Extractor applies the extraction templates stored
*              in the Template RAM to the Fibre Channel frames
*
***************************************************************************/

module frame_extract (

// Packager
output logic [63:0]     oFMEX_FMPG_DATA,
output logic            oFMEX_FMPG_SOP,
output logic            oFMEX_FMPG_EOP,
output logic            oFMEX_FMPG_ERR,
output logic            oFMEX_FMPG_VALID,
output logic            oFMEX_FMPG_ZERO,
output logic [13:0]     oFMEX_FMPG_LENGTH,

// Registers
output logic [63:0]     oFMEX_REG_TEMPLATERAM_RD,
output logic            oFMEX_REG_TEMPLATERAM_V,
output logic            oFMEX_REG_TEMPLSTOP_ZEROBYTE,
output logic            oFMEX_REG_TEMPLSTOP_OFSTORDER,
output logic            oFMEX_REG_TEMPLSTOP_OVERFLOW,
output logic            oFMEX_REG_TEMPLSTOP_INIT,

// Global
input                   clk,
input                   rst_n,
input                   iFC8_MODE,

// FCoE
input  [63:0]           iFC_EXTR_DATA,
input  [2:0]            iFC_EXTR_EMPTY,
input                   iFC_EXTR_SOP,
input                   iFC_EXTR_EOP,
input                   iFC_EXTR_ERR,
input                   iFC_EXTR_VALID,
input  [2:0]            iFC_EXTR_INDEX,
input                   iFC_EXTR_EXTRENABLE,

// Registers
input  [7:0]            iREG_TEMPLATERAM_ADDR,
input  [63:0]           iREG_TEMPLATERAM_WR,
input                   iREG_TEMPLATERAM_WR_EN,
input                   iREG_TEMPLATERAM_RD_EN

);

///////////////////////////////////////////////////////////////////////////////
// Packages
///////////////////////////////////////////////////////////////////////////////
import extractor_cfg::*;
import common_cfg::*;

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
parameter   FRM_INT_IDLE_ST        = 0;
parameter   FRM_INT_OFF_ST         = 1;
parameter   FRM_INT_ON_ST          = 2;
parameter   FRM_INT_FOUND_ST       = 3;

// user defined types
template_mem_bus prgm_instr_p2_r, prgm_instr_p3_r, prgm_instr_p4_r;

logic [63:0] frm_data_r;
logic [2:0] frm_empty_r;
logic frm_sop_r, frm_eop_r, frm_err_r, frm_valid_r;
logic frm_sop_enbl, frm_eop_enbl, frm_valid_enbl;
logic [2:0] frm_index_r;
logic [71:0] template_mem_rd_a, template_mem_rd_b;
logic [7:0] template_mem_ra_r;
logic reg_templ_rd_en_r;
logic frm_sop_p1_r, frm_sop_p2_r, frm_sop_p3_r, frm_sop_p4_r, frm_sop_p5_r;
logic frm_eop_p1_r, frm_eop_p2_r, frm_eop_p3_r, frm_eop_p4_r, frm_eop_p5_r;
logic frm_eop_p6_r;
logic frm_valid_p1_r, frm_valid_p2_r, frm_valid_p3_r;
logic frm_valid_p4_r, frm_valid_p5_r, frm_valid_p6_r;
logic [2:0] frm_empty_p1_r, frm_empty_p2_r, frm_empty_p3_r, frm_empty_p4_r;
logic frm_err_p1_r, frm_err_p2_r, frm_err_p3_r, frm_err_p4_r;
logic frm_err_p5_r, frm_err_p6_r, frm_err_p7_r;
logic [63:0] frm_data_p1_r, frm_data_p2_r, frm_data_p3_r;
logic [2:0] frm_index_p1_r;
logic pipe_init, incr_pc, incr_pc_p1_r, incr_pc_p2_r, incr_pc_p3_r;
logic [5:0] prgm_ctr_r;
logic [1:0] instr_opc_p2, instr_opc_p3_r, instr_opc_p4_r;
logic [8:0] instr_ofst_p2, instr_ofst_p3_r, instr_ofst_p4_r;
logic [7:0] instr_mask_p2_r, instr_mask_p3_r, instr_mask_p4_r;
logic [23:0] instr_flip_p2_r, instr_flip_p3_r, instr_flip_p4_r;
logic [8:0] frm_ofst_ctr_p2_r;
logic ofst_match_p2, ofst_match_p3, ofst_match_p4, offset_match;
logic [1:0] exec_opc_p3_r, exec_opc_p4_r;
logic [7:0] exec_mask_p3_r, exec_mask_p4_r;
logic [23:0] exec_flip_p3_r;
logic [63:0] flip_data_p4_r, extr_data_p6_r, extr_data_p7_r;
logic [31:0] extr_lo_data_p5_r, extr_hi_data_p5_r;
logic [2:0] extr_lo_bcnt_p5_r, extr_hi_bcnt_p5_r;
logic [7:0] LO_B0, LO_B1, LO_B2, LO_B3, HI_B1, HI_B2, HI_B3;
logic [7:0] EX_B0, EX_B1, EX_B2, EX_B3, EX_B4, EX_B5, EX_B6, EX_B7;
logic [3:0] extr_bcnt_p5, extr_bcnt_p6_r, ovfl_bcnt_p6_r;
logic extr_bcnt_nz_p6, accum_done_p6_r;
logic [2:0] ovfl_bcnt_term_p7_r, ovfl_bcnt_term_p6;
logic [55:0] ovfl_data_p7_r;
logic [7:0] OV_B0, OV_B1, OV_B2, OV_B3, OV_B4, OV_B5, OV_B6;
logic terminate_p6, terminate_dly_p7_r, wait_first_done_p6_r;
logic [13:0] frame_len_bctr_p5_r, frame_len_bctr_p6_r;
logic [5:0] total_extr_bcnt_p6_r;
logic total_bcnt_nz_p6, total_bcnt_lt8_p6, total_bcnt_zero_p7_r;
logic [7:0] flip_valid_p3, valid_pat_p3;
logic [3:0] frm_int_state_r, frm_int_state_nxt;
logic frame_interrupted_r, fc8_match_time_r, extr_enable_r, opcode_end_lat_r;

///////////////////////////////////////////////////////////////////////////////
// Flop All Inputs
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk ) begin
    frm_data_r      <= iFC_EXTR_DATA;
    frm_empty_r     <= iFC_EXTR_EMPTY;
    frm_sop_r       <= iFC_EXTR_SOP;
    frm_eop_r       <= iFC_EXTR_EOP;
    frm_err_r       <= iFC_EXTR_ERR;
    frm_valid_r     <= iFC_EXTR_VALID;
    frm_index_r     <= iFC_EXTR_INDEX;
end	

///////////////////////////////////////////////////////////////////////////////
// Template RAM Instantiation
///////////////////////////////////////////////////////////////////////////////
// Port A is for extraction engine exclusively
// Port B is for software access exclusively

template_ram u_template_ram (

    .douta                ( template_mem_rd_a             ),

    .doutb                ( template_mem_rd_b             ),

    .clka                 ( clk                           ),
    .clkb                 ( clk                           ),

    .addra                ( template_mem_ra_r             ),

    .addrb                ( iREG_TEMPLATERAM_ADDR         ),

    .dina                 ( 72'b0                         ),

    .dinb                 ( {8'b0, iREG_TEMPLATERAM_WR}   ),

    .wea                  ( 1'b0                          ),

    .web                  ( iREG_TEMPLATERAM_WR_EN        )

);

always_ff @( posedge clk ) 
    oFMEX_REG_TEMPLATERAM_RD <= template_mem_rd_b[63:0];

always_ff @( posedge clk ) begin
    reg_templ_rd_en_r <= iREG_TEMPLATERAM_RD_EN;
    oFMEX_REG_TEMPLATERAM_V <= reg_templ_rd_en_r;
end

///////////////////////////////////////////////////////////////////////////////
// Extractor Enable
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        extr_enable_r <= 1'b0;
    else
        extr_enable_r <= iFC_EXTR_EXTRENABLE;

assign frm_sop_enbl = frm_sop_r & extr_enable_r;
assign frm_eop_enbl = frm_eop_r & extr_enable_r;
assign frm_valid_enbl = frm_valid_r & extr_enable_r;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oFMEX_REG_TEMPLSTOP_INIT <= 1'b0;
    else if ( frm_sop_r & ~extr_enable_r )
        oFMEX_REG_TEMPLSTOP_INIT <= 1'b1;

///////////////////////////////////////////////////////////////////////////////
// Pipelines
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        frm_sop_p1_r <= 1'b0;
        frm_sop_p2_r <= 1'b0;
        frm_sop_p3_r <= 1'b0;
        frm_sop_p4_r <= 1'b0;
        frm_sop_p5_r <= 1'b0;
        frm_eop_p1_r <= 1'b0;
        frm_eop_p2_r <= 1'b0;
        frm_eop_p3_r <= 1'b0;
        frm_eop_p4_r <= 1'b0;
        frm_eop_p5_r <= 1'b0;
        frm_eop_p6_r <= 1'b0;
        frm_valid_p1_r <= 1'b0;
        frm_valid_p2_r <= 1'b0;
        frm_valid_p3_r <= 1'b0;
        frm_valid_p4_r <= 1'b0;
        frm_valid_p5_r <= 1'b0;
        frm_valid_p6_r <= 1'b0;
    end
    else begin
        frm_sop_p1_r <= frm_sop_enbl;
        frm_sop_p2_r <= frm_sop_p1_r;
        frm_sop_p3_r <= frm_sop_p2_r;
        frm_sop_p4_r <= frm_sop_p3_r;
        frm_sop_p5_r <= frm_sop_p4_r;
        frm_eop_p1_r <= frm_eop_enbl;
        frm_eop_p2_r <= frm_eop_p1_r;
        frm_eop_p3_r <= frm_eop_p2_r;
        frm_eop_p4_r <= frm_eop_p3_r;
        frm_eop_p5_r <= frm_eop_p4_r;
        frm_eop_p6_r <= frm_eop_p5_r;
        frm_valid_p1_r <= frm_valid_enbl;
        frm_valid_p2_r <= frm_valid_p1_r;
        frm_valid_p3_r <= frm_valid_p2_r;
        frm_valid_p4_r <= frm_valid_p3_r;
        frm_valid_p5_r <= frm_valid_p4_r;
        frm_valid_p6_r <= frm_valid_p5_r;
    end

always_ff @( posedge clk ) begin
    frm_empty_p1_r  <= frm_empty_r;
    frm_empty_p2_r  <= frm_empty_p1_r;
    frm_empty_p3_r  <= frm_empty_p2_r;
    frm_empty_p4_r  <= frm_empty_p3_r;
end

always_ff @( posedge clk ) begin
    frm_err_p1_r <= frm_err_r;
    frm_err_p2_r <= frm_err_p1_r;
    frm_err_p3_r <= frm_err_p2_r;
    frm_err_p4_r <= frm_err_p3_r;
    frm_err_p5_r <= frm_err_p4_r;
    frm_err_p6_r <= frm_err_p5_r;
    frm_err_p7_r <= frm_err_p6_r;
end

always_ff @( posedge clk ) begin
    frm_data_p1_r <= frm_data_r;
    frm_data_p2_r <= frm_data_p1_r;
    frm_data_p3_r <= frm_data_p2_r;
end

always_ff @( posedge clk ) 
    frm_index_p1_r <= frm_index_r;

///////////////////////////////////////////////////////////////////////////////
// Program Counter
///////////////////////////////////////////////////////////////////////////////
// Every template RAM segment is 64-deep. There are 4 segments indexed
// by iFC_EXTR_INDEX.
//
// The program counter is incremented for pipeline initialization or
// offset match.
//
// In Dominica design, iFC_EXTR_VALID arrives every other cycle.
// Pipeline is initialized the same way.
assign pipe_init = frm_sop_enbl | frm_sop_p1_r | frm_sop_p2_r;
assign incr_pc = pipe_init | ( offset_match & ( instr_opc_p2 == EXTR_OP_XDAT ) );

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) begin
        incr_pc_p1_r <= 1'b0;
        incr_pc_p2_r <= 1'b0;
        incr_pc_p3_r <= 1'b0;
    end
    else begin 
        incr_pc_p1_r <= incr_pc;
        incr_pc_p2_r <= incr_pc_p1_r;
        incr_pc_p3_r <= incr_pc_p2_r;
    end

// prgm_ctr_r not incremented after EOP (frm_eop_p1_r and frm_eop_p2_r)
// frm_sop_p1_r and frm_sop_enbl indicate next frame starting. prgm_ctr_r is
// controlled by incr_pc.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        prgm_ctr_r <= 6'b0;
    else if ( frm_eop_p1_r | ( frm_eop_p2_r & ~frm_sop_p1_r & ~frm_sop_enbl ) ) 
        prgm_ctr_r <= 6'b0;
    else if ( incr_pc )
        prgm_ctr_r <= prgm_ctr_r + 6'b1;

assign template_mem_ra_r = {1'b0, frm_index_p1_r[ FRM_INDEX_PAUSE ], prgm_ctr_r};

///////////////////////////////////////////////////////////////////////////////
// END Instruction Latch
///////////////////////////////////////////////////////////////////////////////
// Any instrunction following END is ignored. The template RAM stores a sample
// instruction. If the sample code is partially overwritten by new instruction,
// anything after the new END instruction is invalid.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        opcode_end_lat_r <= 1'b0;
    else begin
        if ( opcode_end_lat_r )
            opcode_end_lat_r <= ~frm_sop_enbl;
        else
            opcode_end_lat_r <= incr_pc_p2_r & ( instr_opc_p2 == EXTR_OP_END ) & 
                                ~frm_sop_enbl & ~frm_sop_p1_r;
    end

///////////////////////////////////////////////////////////////////////////////
// Instruction Pipeline
///////////////////////////////////////////////////////////////////////////////
// There are 3 stages in the pipeline. Any one of the three could be the one
// that matches the index.
// Until the offset value is read and compared with the current frame
// position, the decision of executing the next instruction can then
// be made.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        prgm_instr_p2_r <= 64'b0;
    else if ( incr_pc_p1_r )
        prgm_instr_p2_r <= template_mem_rd_a[63:0];

assign instr_opc_p2    = opcode_end_lat_r ? EXTR_OP_END : prgm_instr_p2_r.opcode;
assign instr_ofst_p2   = opcode_end_lat_r ? 9'h1ff : prgm_instr_p2_r.offset;
assign instr_mask_p2_r = prgm_instr_p2_r.mask;
assign instr_flip_p2_r = prgm_instr_p2_r.flip;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        prgm_instr_p3_r <= 64'b0;
    else if ( incr_pc_p1_r )
        prgm_instr_p3_r <= prgm_instr_p2_r;

assign instr_opc_p3_r  = prgm_instr_p3_r.opcode;
assign instr_ofst_p3_r = prgm_instr_p3_r.offset;
assign instr_mask_p3_r = prgm_instr_p3_r.mask;
assign instr_flip_p3_r = prgm_instr_p3_r.flip;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        prgm_instr_p4_r <= 64'b0;
    else if ( incr_pc_p1_r )
        prgm_instr_p4_r <= prgm_instr_p3_r;

assign instr_opc_p4_r  = prgm_instr_p4_r.opcode;
assign instr_ofst_p4_r = prgm_instr_p4_r.offset;
assign instr_mask_p4_r = prgm_instr_p4_r.mask;
assign instr_flip_p4_r = prgm_instr_p4_r.flip;

///////////////////////////////////////////////////////////////////////////////
// Instruction Offset Error Check
///////////////////////////////////////////////////////////////////////////////
// Instruction offsets must be in increasing order
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oFMEX_REG_TEMPLSTOP_OFSTORDER <= 1'b0;
    else if ( incr_pc_p3_r & ( instr_opc_p2 == EXTR_OP_XDAT ) &
              ( instr_ofst_p2 <= instr_ofst_p3_r ) & 
                ~( iFC8_MODE & frm_sop_p3_r ) & ~frm_eop_p4_r & ~frm_eop_p5_r )
        oFMEX_REG_TEMPLSTOP_OFSTORDER <= 1'b1;

///////////////////////////////////////////////////////////////////////////////
// Frame Offset
///////////////////////////////////////////////////////////////////////////////
// Frame offset is 8-byte units.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        frm_ofst_ctr_p2_r <= 9'b0;
    else if ( frm_eop_p2_r )
        frm_ofst_ctr_p2_r <= 9'b0;
    else if ( frm_sop_p2_r )
        frm_ofst_ctr_p2_r <= 9'b1;
    else if ( frm_valid_p2_r )
        frm_ofst_ctr_p2_r <= frm_ofst_ctr_p2_r + 9'b1;

always_ff @( posedge clk ) 
    fc8_match_time_r <= frame_interrupted_r ? frm_valid_p1_r : frm_valid_p3_r;

// Offset comparison stops after EOP
assign ofst_match_p2 = ( instr_ofst_p2 == frm_ofst_ctr_p2_r ) & frm_valid_p2_r;
assign ofst_match_p3 = ( instr_ofst_p3_r == frm_ofst_ctr_p2_r ) & 
                       ( iFC8_MODE ? fc8_match_time_r : frm_valid_p3_r ) & ~frm_eop_p3_r;
assign ofst_match_p4 = ( instr_ofst_p4_r == frm_ofst_ctr_p2_r ) & 
                       fc8_match_time_r & ~frm_eop_p4_r & ~frm_eop_p3_r;
assign offset_match = ofst_match_p2 | ofst_match_p3 | ofst_match_p4;

///////////////////////////////////////////////////////////////////////////////
// Instruction Execution
///////////////////////////////////////////////////////////////////////////////
// After the frame offset match, the matched instruction is selected from
// one of the 3 pipeline stages.
always_ff @( posedge clk ) begin
    exec_opc_p3_r  <= ( {2{ofst_match_p2}} & instr_opc_p2   ) |
                      ( {2{ofst_match_p3}} & instr_opc_p3_r ) |
                      ( {2{ofst_match_p4}} & instr_opc_p4_r );
    exec_mask_p3_r <= ( {8{ofst_match_p2}} & instr_mask_p2_r ) |
                      ( {8{ofst_match_p3}} & instr_mask_p3_r ) |
                      ( {8{ofst_match_p4}} & instr_mask_p4_r );
    exec_flip_p3_r <= ( {24{ofst_match_p2}} & instr_flip_p2_r ) |
                      ( {24{ofst_match_p3}} & instr_flip_p3_r ) |
                      ( {24{ofst_match_p4}} & instr_flip_p4_r );
end

///////////////////////////////////////////////////////////////////////////////
// Endian Flipper
///////////////////////////////////////////////////////////////////////////////
// Endian field flipper re-arranges the bytes in the 64-bit words BEFORE
// the extract pattern applied to the flipped words.
//
// The 24-bit flipper field selects each byte individually from the word.
// For example, 000 001 010 011 100 101 110 111 keeps all the bytes in
// exactly the same order as the original data.
// 111 110 101 100 011 010 001 000 reverse the bytes into little endian format
function [7:0] endian_flip_data;
    input [63:0] data;
    input [2:0] flip;
begin
    case ( flip )
        3'd7: endian_flip_data = data[7:0];
        3'd6: endian_flip_data = data[15:8];
        3'd5: endian_flip_data = data[23:16];
        3'd4: endian_flip_data = data[31:24];
        3'd3: endian_flip_data = data[39:32];
        3'd2: endian_flip_data = data[47:40];
        3'd1: endian_flip_data = data[55:48];
        3'd0: endian_flip_data = data[63:56];
    endcase
end
endfunction

function endian_flip_valid;
    input [7:0] valid;
    input [2:0] flip;
begin
    case ( flip )
        3'd7: endian_flip_valid = valid[0];
        3'd6: endian_flip_valid = valid[1];
        3'd5: endian_flip_valid = valid[2];
        3'd4: endian_flip_valid = valid[3];
        3'd3: endian_flip_valid = valid[4];
        3'd2: endian_flip_valid = valid[5];
        3'd1: endian_flip_valid = valid[6];
        3'd0: endian_flip_valid = valid[7];
    endcase
end
endfunction

always_ff @( posedge clk ) begin
    flip_data_p4_r[7:0]   <= endian_flip_data( frm_data_p3_r, exec_flip_p3_r[2:0]   );
    flip_data_p4_r[15:8]  <= endian_flip_data( frm_data_p3_r, exec_flip_p3_r[5:3]   );
    flip_data_p4_r[23:16] <= endian_flip_data( frm_data_p3_r, exec_flip_p3_r[8:6]   );
    flip_data_p4_r[31:24] <= endian_flip_data( frm_data_p3_r, exec_flip_p3_r[11:9]  );
    flip_data_p4_r[39:32] <= endian_flip_data( frm_data_p3_r, exec_flip_p3_r[14:12] );
    flip_data_p4_r[47:40] <= endian_flip_data( frm_data_p3_r, exec_flip_p3_r[17:15] );
    flip_data_p4_r[55:48] <= endian_flip_data( frm_data_p3_r, exec_flip_p3_r[20:18] );
    flip_data_p4_r[63:56] <= endian_flip_data( frm_data_p3_r, exec_flip_p3_r[23:21] );
end	

// Number of valid bytes are represented by valid bit pattern.
// The valid pattern is flipped the same way as data to mask off potential
// extracted pattern.
assign valid_pat_p3 = ( frm_empty_p3_r == 4'd4 ) ? 8'b11110000 : 8'b11111111;

assign flip_valid_p3[0] = endian_flip_valid( valid_pat_p3, exec_flip_p3_r[2:0]   );
assign flip_valid_p3[1] = endian_flip_valid( valid_pat_p3, exec_flip_p3_r[5:3]   );
assign flip_valid_p3[2] = endian_flip_valid( valid_pat_p3, exec_flip_p3_r[8:6]   );
assign flip_valid_p3[3] = endian_flip_valid( valid_pat_p3, exec_flip_p3_r[11:9]  );
assign flip_valid_p3[4] = endian_flip_valid( valid_pat_p3, exec_flip_p3_r[14:12] );
assign flip_valid_p3[5] = endian_flip_valid( valid_pat_p3, exec_flip_p3_r[17:15] );
assign flip_valid_p3[6] = endian_flip_valid( valid_pat_p3, exec_flip_p3_r[20:18] );
assign flip_valid_p3[7] = endian_flip_valid( valid_pat_p3, exec_flip_p3_r[23:21] );

///////////////////////////////////////////////////////////////////////////////
// Extraction Two 32-bit Words
///////////////////////////////////////////////////////////////////////////////
// Extract pattern or mask bit 1 indicates a corresponding byte should be
// extracted and a 0 indicates a byte should not be extracted.
always_ff @( posedge clk ) 
    exec_opc_p4_r  <= exec_opc_p3_r;

// Mask bits are gated off if extracted from last 4 invalid bytes at EOP cycle
always_ff @( posedge clk ) 
    exec_mask_p4_r <= exec_mask_p3_r & flip_valid_p3;

// Pack 32-bit dword into the format that extracted bytes are shifted
// towards MSB
function [31:0] pack_data;
    input [31:0] data;
    input [3:0] mask;
begin
    reg [7:0] B0, B1, B2, B3;
    B0 = data[7:0];
    B1 = data[15:8];
    B2 = data[23:16];
    B3 = data[31:24];
    case ( mask )
        4'b0000: pack_data = 32'b0;
        4'b0001: pack_data = {B0,  8'b0, 8'b0, 8'b0};
        4'b0010: pack_data = {B1,  8'b0, 8'b0, 8'b0};
        4'b0011: pack_data = {B1,  B0  , 8'b0, 8'b0};
        4'b0100: pack_data = {B2,  8'b0, 8'b0, 8'b0};
        4'b0101: pack_data = {B2,  B0  , 8'b0, 8'b0};
        4'b0110: pack_data = {B2,  B1  , 8'b0, 8'b0};
        4'b0111: pack_data = {B2,  B1  , B0  , 8'b0};
        4'b1000: pack_data = {B3,  8'b0, 8'b0, 8'b0};
        4'b1001: pack_data = {B3,  B0  , 8'b0, 8'b0};
        4'b1010: pack_data = {B3,  B1  , 8'b0, 8'b0};
        4'b1011: pack_data = {B3,  B1  , B0  , 8'b0};
        4'b1100: pack_data = {B3,  B2  , 8'b0, 8'b0};
        4'b1101: pack_data = {B3,  B2  , B0  , 8'b0};
        4'b1110: pack_data = {B3,  B2  , B1  , 8'b0};
        4'b1111: pack_data = {B3,  B2  , B1  , B0  };
    endcase
end
endfunction

// Number of extracted bytes in a 32-bit dword
function [2:0] pack_bcnt;
    input [3:0] mask;
begin
    case ( mask )
        4'b0000: pack_bcnt = 3'd0;
        4'b0001: pack_bcnt = 3'd1;
        4'b0010: pack_bcnt = 3'd1;
        4'b0011: pack_bcnt = 3'd2;
        4'b0100: pack_bcnt = 3'd1;
        4'b0101: pack_bcnt = 3'd2;
        4'b0110: pack_bcnt = 3'd2;
        4'b0111: pack_bcnt = 3'd3;
        4'b1000: pack_bcnt = 3'd1;
        4'b1001: pack_bcnt = 3'd2;
        4'b1010: pack_bcnt = 3'd2;
        4'b1011: pack_bcnt = 3'd3;
        4'b1100: pack_bcnt = 3'd2;
        4'b1101: pack_bcnt = 3'd3;
        4'b1110: pack_bcnt = 3'd3;
        4'b1111: pack_bcnt = 3'd4;
    endcase
end
endfunction

always_ff @( posedge clk ) begin
    extr_lo_data_p5_r <= pack_data( flip_data_p4_r[31:0],  exec_mask_p4_r[3:0] );
    extr_hi_data_p5_r <= pack_data( flip_data_p4_r[63:32], exec_mask_p4_r[7:4] );
end

// Extraction stops after EOP
// Low byte count forced to 0 for data after EOP
always_ff @( posedge clk ) begin
    if ( exec_opc_p4_r == EXTR_OP_XDAT ) begin
        extr_lo_bcnt_p5_r <= pack_bcnt( exec_mask_p4_r[3:0] );
        extr_hi_bcnt_p5_r <= pack_bcnt( exec_mask_p4_r[7:4] );
    end
    else begin
        extr_lo_bcnt_p5_r <= 3'b0;
        extr_hi_bcnt_p5_r <= 3'b0;
    end
end

assign LO_B0 = extr_lo_data_p5_r[7:0];
assign LO_B1 = extr_lo_data_p5_r[15:8];
assign LO_B2 = extr_lo_data_p5_r[23:16];
assign LO_B3 = extr_lo_data_p5_r[31:24];
assign HI_B1 = extr_hi_data_p5_r[15:8];
assign HI_B2 = extr_hi_data_p5_r[23:16];
assign HI_B3 = extr_hi_data_p5_r[31:24];

///////////////////////////////////////////////////////////////////////////////
// Extraction within 64-bit Word
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk ) begin
    if ( extr_hi_bcnt_p5_r[2] )     // 4 high bytes 
        extr_data_p6_r <= {extr_hi_data_p5_r, extr_lo_data_p5_r};
    else
        case ( extr_hi_bcnt_p5_r[1:0] )
            2'd0: extr_data_p6_r <= {LO_B3, LO_B2, LO_B1, LO_B0, 8'b0 , 8'b0 , 8'b0 , 8'b0 };
            2'd1: extr_data_p6_r <= {HI_B3, LO_B3, LO_B2, LO_B1, LO_B0, 8'b0 , 8'b0 , 8'b0 };
            2'd2: extr_data_p6_r <= {HI_B3, HI_B2, LO_B3, LO_B2, LO_B1, LO_B0, 8'b0 , 8'b0 };
            2'd3: extr_data_p6_r <= {HI_B3, HI_B2, HI_B1, LO_B3, LO_B2, LO_B1, LO_B0, 8'b0 };
        endcase
end

assign EX_B0 = extr_data_p6_r[7:0];
assign EX_B1 = extr_data_p6_r[15:8];
assign EX_B2 = extr_data_p6_r[23:16];
assign EX_B3 = extr_data_p6_r[31:24];
assign EX_B4 = extr_data_p6_r[39:32];
assign EX_B5 = extr_data_p6_r[47:40];
assign EX_B6 = extr_data_p6_r[55:48];
assign EX_B7 = extr_data_p6_r[63:56];

assign extr_bcnt_p5 = extr_hi_bcnt_p5_r + extr_lo_bcnt_p5_r;

always_ff @( posedge clk ) 
    extr_bcnt_p6_r <= extr_bcnt_p5;

assign extr_bcnt_nz_p6 = ( extr_bcnt_p6_r != 4'b0 );

// The extracted frame is discarded if total extracted bytes are zero.
// This can happen if extracted patterns are all zero or frame length is
// less than the smallest offset.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        total_extr_bcnt_p6_r <= 6'b0;
    else if ( frm_valid_p5_r ) begin
        if ( frm_sop_p5_r ) 
            total_extr_bcnt_p6_r <= extr_bcnt_p5;
        else
            total_extr_bcnt_p6_r <= total_extr_bcnt_p6_r + extr_bcnt_p5;
    end

assign total_bcnt_nz_p6 = ( total_extr_bcnt_p6_r != 6'b0 );
assign total_bcnt_lt8_p6 = ( total_extr_bcnt_p6_r < 6'd8 );

always_ff @( posedge clk ) 
    total_bcnt_zero_p7_r <= ( total_extr_bcnt_p6_r == 6'b0 );

///////////////////////////////////////////////////////////////////////////////
// Extraction across Multiple 64-bit Words
///////////////////////////////////////////////////////////////////////////////
// Combine valid bytes from successive 64-bit words so that there are
// 8 valid bytes per clock cycle.
always_ff @( posedge clk ) 
    ovfl_bcnt_p6_r[3:0] <= extr_bcnt_p5[3:0] + ovfl_bcnt_term_p6[2:0];

assign accum_done_p6_r = ovfl_bcnt_p6_r[3];

always_comb begin
    if ( terminate_dly_p7_r ) 
        ovfl_bcnt_term_p6 = 3'b0;
    else if ( extr_bcnt_nz_p6 )
        ovfl_bcnt_term_p6 = ovfl_bcnt_p6_r[2:0];
    else
        ovfl_bcnt_term_p6 = ovfl_bcnt_term_p7_r;
end

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        ovfl_bcnt_term_p7_r <= 3'b0;
    else 
        ovfl_bcnt_term_p7_r <= ovfl_bcnt_term_p6;

assign OV_B0 = ovfl_data_p7_r[7:0];
assign OV_B1 = ovfl_data_p7_r[15:8];
assign OV_B2 = ovfl_data_p7_r[23:16];
assign OV_B3 = ovfl_data_p7_r[31:24];
assign OV_B4 = ovfl_data_p7_r[39:32];
assign OV_B5 = ovfl_data_p7_r[47:40];
assign OV_B6 = ovfl_data_p7_r[55:48];

always_ff @( posedge clk )
    if ( accum_done_p6_r | terminate_dly_p7_r ) begin
        case ( ovfl_bcnt_term_p7_r )
            3'd0: extr_data_p7_r <= {EX_B7, EX_B6, EX_B5, EX_B4, EX_B3, EX_B2, EX_B1, EX_B0};
            3'd1: begin
                if ( total_bcnt_lt8_p6 )
                    extr_data_p7_r <= {OV_B6,  8'b0,  8'b0,  8'b0,  8'b0,  8'b0,  8'b0,  8'b0};
                else
                    extr_data_p7_r <= {OV_B6, EX_B7, EX_B6, EX_B5, EX_B4, EX_B3, EX_B2, EX_B1};
                ovfl_data_p7_r <= {EX_B0, 8'b0 , 8'b0 , 8'b0 , 8'b0 , 8'b0 , 8'b0 };
            end
            3'd2: begin
                if ( total_bcnt_lt8_p6 )
                    extr_data_p7_r <= {OV_B6, OV_B5,  8'b0,  8'b0,  8'b0,  8'b0,  8'b0,  8'b0};
                else
                    extr_data_p7_r <= {OV_B6, OV_B5, EX_B7, EX_B6, EX_B5, EX_B4, EX_B3, EX_B2};
                ovfl_data_p7_r <= {EX_B1, EX_B0, 8'b0 , 8'b0 , 8'b0 , 8'b0 , 8'b0 };
            end
            3'd3: begin
                if ( total_bcnt_lt8_p6 )
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4,  8'b0,  8'b0,  8'b0,  8'b0,  8'b0};
                else
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, EX_B7, EX_B6, EX_B5, EX_B4, EX_B3};
                ovfl_data_p7_r <= {EX_B2, EX_B1, EX_B0, 8'b0 , 8'b0 , 8'b0 , 8'b0 };
            end
            3'd4: begin
                if ( total_bcnt_lt8_p6 )
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3,  8'b0,  8'b0,  8'b0,  8'b0};
                else
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, EX_B7, EX_B6, EX_B5, EX_B4};
                ovfl_data_p7_r <= {EX_B3, EX_B2, EX_B1, EX_B0, 8'b0 , 8'b0 , 8'b0 };
            end
            3'd5: begin
                if ( total_bcnt_lt8_p6 )
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2,  8'b0,  8'b0,  8'b0};
                else
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2, EX_B7, EX_B6, EX_B5};
                ovfl_data_p7_r <= {EX_B4, EX_B3, EX_B2, EX_B1, EX_B0, 8'b0 , 8'b0 };
            end
            3'd6: begin
                if ( total_bcnt_lt8_p6 )
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2, OV_B1,  8'b0,  8'b0};
                else
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2, OV_B1, EX_B7, EX_B6};
                ovfl_data_p7_r <= {EX_B5, EX_B4, EX_B3, EX_B2, EX_B1, EX_B0, 8'b0 };
            end
            3'd7: begin
                if ( total_bcnt_lt8_p6 )
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2, OV_B1, OV_B0,  8'b0};
                else
                    extr_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2, OV_B1, OV_B0, EX_B7};
                ovfl_data_p7_r <= {EX_B6, EX_B5, EX_B4, EX_B3, EX_B2, EX_B1, EX_B0};
            end
        endcase
    end
    else begin
        extr_data_p7_r <= 64'b0;
        case ( ovfl_bcnt_term_p7_r )
            3'd0: ovfl_data_p7_r <= {EX_B7, EX_B6, EX_B5, EX_B4, EX_B3, EX_B2, EX_B1};
            3'd1: ovfl_data_p7_r <= {OV_B6, EX_B7, EX_B6, EX_B5, EX_B4, EX_B3, EX_B2};
            3'd2: ovfl_data_p7_r <= {OV_B6, OV_B5, EX_B7, EX_B6, EX_B5, EX_B4, EX_B3};
            3'd3: ovfl_data_p7_r <= {OV_B6, OV_B5, OV_B4, EX_B7, EX_B6, EX_B5, EX_B4};
            3'd4: ovfl_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, EX_B7, EX_B6, EX_B5};
            3'd5: ovfl_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2, EX_B7, EX_B6};
            3'd6: ovfl_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2, OV_B1, EX_B7};
            3'd7: ovfl_data_p7_r <= {OV_B6, OV_B5, OV_B4, OV_B3, OV_B2, OV_B1, OV_B0};
        endcase
    end

///////////////////////////////////////////////////////////////////////////////
// Termination
///////////////////////////////////////////////////////////////////////////////
// Extraction is terminated upon
// 1) EOP
// 2) END instruction
//
// If END is reached before EOP, the last extracted data is held off
// until EOP so that error status and frame length information are
// available.
//
// If EOP causes overlow, oFMEX_FMPG_EOP is set one cycle later.
assign terminate_p6 = frm_eop_p6_r & accum_done_p6_r & ~ovfl_bcnt_p6_r[3];

// The extracted frame is discarded if total extracted bytes are zero.
// SOP and EOP are still generated with FMEX_FMPG_ZERO.
// Packager can use the ZERO signal to discard the packet, but it must
// pop the timestamp FIFO.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        terminate_dly_p7_r <= 1'b0;
    else
        terminate_dly_p7_r <= frm_eop_p6_r & ~( accum_done_p6_r & ~ovfl_bcnt_p6_r[3] );

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oFMEX_REG_TEMPLSTOP_ZEROBYTE <= 1'b0;
    else if ( frm_eop_p6_r & ~total_bcnt_nz_p6 )
        oFMEX_REG_TEMPLSTOP_ZEROBYTE <= 1'b1;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oFMEX_REG_TEMPLSTOP_OVERFLOW <= 1'b0;
    else if ( frm_valid_p6_r & ( total_extr_bcnt_p6_r > MAX_EXTR_BCNT ) )
        oFMEX_REG_TEMPLSTOP_OVERFLOW <= 1'b1;

///////////////////////////////////////////////////////////////////////////////
// Packager Interface
///////////////////////////////////////////////////////////////////////////////
assign oFMEX_FMPG_DATA = extr_data_p7_r;

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oFMEX_FMPG_VALID <= 1'b0;
    else
        oFMEX_FMPG_VALID <= accum_done_p6_r | terminate_dly_p7_r;

// wait_first_done_p6_r is not cleared by accum_done_p6_r, terminate_dly_p7_r
// if next frame arrives indicated by frm_sop_p5_r
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        wait_first_done_p6_r <= 1'b0;
    else begin
        if ( wait_first_done_p6_r )
            wait_first_done_p6_r <= ~( ( accum_done_p6_r | terminate_dly_p7_r ) & ~frm_sop_p5_r );
        else
            wait_first_done_p6_r <= frm_sop_p5_r;
    end

// If total extracted bytes are less than or equal to 8, SOP and EOP overlap.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oFMEX_FMPG_SOP <= 1'b0;
    else
        oFMEX_FMPG_SOP <= wait_first_done_p6_r & ( accum_done_p6_r | terminate_dly_p7_r );

always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        oFMEX_FMPG_EOP <= 1'b0;
    else 
        oFMEX_FMPG_EOP <= terminate_p6 | terminate_dly_p7_r;

always_ff @( posedge clk ) 
    oFMEX_FMPG_ERR <= ( terminate_p6 & frm_err_p6_r ) | 
                      ( terminate_dly_p7_r & frm_err_p7_r );

always_ff @( posedge clk ) 
    oFMEX_FMPG_ZERO <= total_bcnt_zero_p7_r & terminate_dly_p7_r;

///////////////////////////////////////////////////////////////////////////////
// Frame Length
///////////////////////////////////////////////////////////////////////////////
// As frame is being extracted, the frame length counter is accumulated.
always_ff @( posedge clk or negedge rst_n ) 
    if ( ~rst_n ) 
        frame_len_bctr_p5_r <= 14'b0;
    else if ( frm_sop_p4_r )
        frame_len_bctr_p5_r <= 4'd8 - frm_empty_p4_r;
    else if ( frm_valid_p4_r )
        frame_len_bctr_p5_r <= frame_len_bctr_p5_r + 4'd8 - frm_empty_p4_r;

always_ff @( posedge clk ) begin
    frame_len_bctr_p6_r <= frame_len_bctr_p5_r;
    oFMEX_FMPG_LENGTH   <= frame_len_bctr_p6_r;
end

///////////////////////////////////////////////////////////////////////////////
// FC8 Frame Interruption State Machine
///////////////////////////////////////////////////////////////////////////////
// If frame is interrupted from MTIP due to 1/2/4G FC speed mismatch,
// The offset counter match logic timing is adjusted when the same frame
// is restarted.
always_comb begin
    frm_int_state_nxt = 4'b0;
    unique case ( 1'b1 )
        frm_int_state_r[ FRM_INT_IDLE_ST ]: begin
            if ( iFC8_MODE & frm_sop_enbl )
                frm_int_state_nxt[ FRM_INT_OFF_ST ] = 1'b1;
            else
                frm_int_state_nxt[ FRM_INT_IDLE_ST ] = 1'b1;
        end
        frm_int_state_r[ FRM_INT_OFF_ST ]: begin
            frm_int_state_nxt[ FRM_INT_ON_ST ] = 1'b1;
        end
        frm_int_state_r[ FRM_INT_ON_ST ]: begin
            if ( frm_eop_enbl )
                frm_int_state_nxt[ FRM_INT_IDLE_ST ] = 1'b1;
            else if ( frm_valid_enbl )
                frm_int_state_nxt[ FRM_INT_OFF_ST ] = 1'b1;
            else
                frm_int_state_nxt[ FRM_INT_FOUND_ST ] = 1'b1;
        end
        frm_int_state_r[ FRM_INT_FOUND_ST ]: begin
            if ( frm_eop_enbl )
                frm_int_state_nxt[ FRM_INT_IDLE_ST ] = 1'b1;
            else
                frm_int_state_nxt[ FRM_INT_FOUND_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        frm_int_state_r <= 4'b0;
        frm_int_state_r[ FRM_INT_IDLE_ST ] <= 1'b1;
    end
    else
        frm_int_state_r <= frm_int_state_nxt;

assign frame_interrupted_r = frm_int_state_r[ FRM_INT_FOUND_ST ];



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
pkt_mbst_checker #(
    .DATA_WIDTH ( 64                    )
)
u_frame_extract_pkt_mbst_checker (
    .clk                ( clk                               ),
    .rst_n              ( rst_n                             ),
    .data               ( oFMEX_FMPG_DATA                   ),
    .sop                ( oFMEX_FMPG_SOP                    ),
    .eop                ( oFMEX_FMPG_EOP                    ),
    .valid              ( oFMEX_FMPG_VALID                  ),
    .zero               ( oFMEX_FMPG_ZERO | oFMEX_FMPG_ERR  )
);

// Template offsets not in increasing order
assert_template_offset_order: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( oFMEX_REG_TEMPLSTOP_OFSTORDER ) );

// Extract more than 54 bytes
assert_extract_more_than_54: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( oFMEX_REG_TEMPLSTOP_OVERFLOW ) );

// Error is asserted at EOP time
assert_error_and_eop: assert property ( @( posedge clk )
    oFMEX_FMPG_ERR |-> oFMEX_FMPG_EOP );

final begin
    assert_program_ctr_zero: assert ( prgm_ctr_r == 0 );
end

// synopsys translate_on

endmodule
