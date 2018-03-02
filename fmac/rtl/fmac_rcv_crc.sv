//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_rcv_crc.sv $
// $Author: leon.zhou $
// $Date: 2014-03-19 15:24:38 -0700 (Wed, 19 Mar 2014) $
//**************************************************************************/

// Description: This is a pipelined CRC generator for Fiber Channel protocol
//              CRC polynomial is
//              x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + 
//              x^7 + x^5 + x^4 + x^2 + x + 1
//              The first DWORD complement and bit reversal within a byte
//              is handled internally. The final complement of the CRC result
//              (crc_out output) is done in the external logic at EOP
//              time which is unknown to this module.

import fmac_pkg::bit_reversal;
module fmac_rcv_crc 
  (

   // NOTE : All data and CRC values are big endiane (LSB at higher order bytes)
   output logic [31:0]     crc_out,    // CRC Output
   input 	           clk,        // Clock
   input [63:0]            data_in,    // User Payload Data
   input 	           sop,        // Start of Packet
   input 	           dw_cnt,     // DWord Count, 1=32b, 0=64b
   input [31:0]            crc_in      // CRC Input -

   );


///////////////////////////////////////////////////////////////////////////////
// Manual Declarations
///////////////////////////////////////////////////////////////////////////////
reg sop_p1_r;
reg dw_cnt_p1_r;
wire [31:0] crc_in_seed;
reg [31:0] crc_out_64b_hi_p1_r, crc_out_64b_lo_p1_r;
reg [31:0] crc_out_32b_hi_p1_r, crc_out_32b_lo_p1_r;
wire [31:0] data_hi_reverse, data_lo_reverse;
wire [63:0] data_in_map;

///////////////////////////////////////////////////////////////////////////////
// Control Pipeline
///////////////////////////////////////////////////////////////////////////////
always @( posedge clk ) begin
    sop_p1_r <= sop;
    dw_cnt_p1_r <= dw_cnt;
end

///////////////////////////////////////////////////////////////////////////////
// Data
///////////////////////////////////////////////////////////////////////////////
// Reverse the bit orders within a byte
// First 32 bits of user data are complemented
assign data_hi_reverse = {bit_reversal(data_in[63:56]),
                          bit_reversal(data_in[55:48]),
                          bit_reversal(data_in[47:40]),
                          bit_reversal(data_in[39:32])};
assign data_lo_reverse = {bit_reversal(data_in[31:24]),
                          bit_reversal(data_in[23:16]),
                          bit_reversal(data_in[15:8]),
                          bit_reversal(data_in[7:0])};
assign data_in_map = sop ? {~data_hi_reverse, data_lo_reverse} 
                         : {data_hi_reverse, data_lo_reverse};

///////////////////////////////////////////////////////////////////////////////
// CRC Seed
///////////////////////////////////////////////////////////////////////////////
// CRC seed value is 32'b0
assign crc_in_seed = sop_p1_r ? 32'b0 : crc_in;

///////////////////////////////////////////////////////////////////////////////
// First Pipeline Stage
///////////////////////////////////////////////////////////////////////////////
always @( posedge clk ) begin
    crc_out_64b_hi_p1_r  <= crc32_d64_hi_pipe1  ( data_in_map[63:0]  );
    crc_out_64b_lo_p1_r  <= crc32_d64_lo_pipe1  ( data_in_map[63:0]  );
    crc_out_32b_hi_p1_r  <= crc32_d32_hi_pipe1  ( data_in_map[63:32]  );
    crc_out_32b_lo_p1_r  <= crc32_d32_lo_pipe1  ( data_in_map[63:32]  );
end

///////////////////////////////////////////////////////////////////////////////
// Second Pipeline Stage
///////////////////////////////////////////////////////////////////////////////
always @*
    if ( dw_cnt_p1_r )
        crc_out = crc32_d32_pipe2 ( crc_out_32b_hi_p1_r,  crc_out_32b_lo_p1_r,  crc_in_seed );
    else
        crc_out = crc32_d64_pipe2 ( crc_out_64b_hi_p1_r,  crc_out_64b_lo_p1_r,  crc_in_seed );

///////////////////////////////////////////////////////////////////////////////
// 64-bit CRC Generators
///////////////////////////////////////////////////////////////////////////////
function [31:0] crc32_d64_hi_pipe1;

    input [63:0] D;

    reg [31:0] Q;

begin

Q[ 0] = D[ 63] ^ D[ 61] ^ D[ 60] ^ D[ 58] ^ D[ 55] ^ D[ 54] ^ D[ 53] ^ D[ 50] ^ 
        D[ 48] ^ D[ 47] ^ D[ 45] ^ D[ 44] ^ D[ 37] ^ D[ 34] ^ D[ 32];

Q[ 1] = D[ 63] ^ D[ 62] ^ D[ 60] ^ D[ 59] ^ D[ 58] ^ D[ 56] ^ D[ 53] ^ D[ 51] ^ 
        D[ 50] ^ D[ 49] ^ D[ 47] ^ D[ 46] ^ D[ 44] ^ D[ 38] ^ D[ 37] ^ D[ 35] ^ 
        D[ 34] ^ D[ 33];

Q[ 2] = D[ 59] ^ D[ 58] ^ D[ 57] ^ D[ 55] ^ D[ 53] ^ D[ 52] ^ D[ 51] ^ D[ 44] ^ 
        D[ 39] ^ D[ 38] ^ D[ 37] ^ D[ 36] ^ D[ 35] ^ D[ 32];

Q[ 3] = D[ 60] ^ D[ 59] ^ D[ 58] ^ D[ 56] ^ D[ 54] ^ D[ 53] ^ D[ 52] ^ D[ 45] ^ 
        D[ 40] ^ D[ 39] ^ D[ 38] ^ D[ 37] ^ D[ 36] ^ D[ 33] ^ D[ 32];

Q[ 4] = D[ 63] ^ D[ 59] ^ D[ 58] ^ D[ 57] ^ D[ 50] ^ D[ 48] ^ D[ 47] ^ D[ 46] ^ 
        D[ 45] ^ D[ 44] ^ D[ 41] ^ D[ 40] ^ D[ 39] ^ D[ 38] ^ D[ 33];

Q[ 5] = D[ 63] ^ D[ 61] ^ D[ 59] ^ D[ 55] ^ D[ 54] ^ D[ 53] ^ D[ 51] ^ D[ 50] ^ 
        D[ 49] ^ D[ 46] ^ D[ 44] ^ D[ 42] ^ D[ 41] ^ D[ 40] ^ D[ 39] ^ D[ 37];

Q[ 6] = D[ 62] ^ D[ 60] ^ D[ 56] ^ D[ 55] ^ D[ 54] ^ D[ 52] ^ D[ 51] ^ D[ 50] ^ 
        D[ 47] ^ D[ 45] ^ D[ 43] ^ D[ 42] ^ D[ 41] ^ D[ 40] ^ D[ 38];

Q[ 7] = D[ 60] ^ D[ 58] ^ D[ 57] ^ D[ 56] ^ D[ 54] ^ D[ 52] ^ D[ 51] ^ D[ 50] ^ 
        D[ 47] ^ D[ 46] ^ D[ 45] ^ D[ 43] ^ D[ 42] ^ D[ 41] ^ D[ 39] ^ D[ 37] ^ 
        D[ 34] ^ D[ 32];

Q[ 8] = D[ 63] ^ D[ 60] ^ D[ 59] ^ D[ 57] ^ D[ 54] ^ D[ 52] ^ D[ 51] ^ D[ 50] ^ 
        D[ 46] ^ D[ 45] ^ D[ 43] ^ D[ 42] ^ D[ 40] ^ D[ 38] ^ D[ 37] ^ D[ 35] ^ 
        D[ 34] ^ D[ 33] ^ D[ 32];

Q[ 9] = D[ 61] ^ D[ 60] ^ D[ 58] ^ D[ 55] ^ D[ 53] ^ D[ 52] ^ D[ 51] ^ D[ 47] ^ 
        D[ 46] ^ D[ 44] ^ D[ 43] ^ D[ 41] ^ D[ 39] ^ D[ 38] ^ D[ 36] ^ D[ 35] ^ 
        D[ 34] ^ D[ 33] ^ D[ 32];

Q[10] = D[ 63] ^ D[ 62] ^ D[ 60] ^ D[ 59] ^ D[ 58] ^ D[ 56] ^ D[ 55] ^ D[ 52] ^ 
        D[ 50] ^ D[ 42] ^ D[ 40] ^ D[ 39] ^ D[ 36] ^ D[ 35] ^ D[ 33] ^ D[ 32];

Q[11] = D[ 59] ^ D[ 58] ^ D[ 57] ^ D[ 56] ^ D[ 55] ^ D[ 54] ^ D[ 51] ^ D[ 50] ^ 
        D[ 48] ^ D[ 47] ^ D[ 45] ^ D[ 44] ^ D[ 43] ^ D[ 41] ^ D[ 40] ^ D[ 36] ^ 
        D[ 33];

Q[12] = D[ 63] ^ D[ 61] ^ D[ 59] ^ D[ 57] ^ D[ 56] ^ D[ 54] ^ D[ 53] ^ D[ 52] ^ 
        D[ 51] ^ D[ 50] ^ D[ 49] ^ D[ 47] ^ D[ 46] ^ D[ 42] ^ D[ 41];

Q[13] = D[ 62] ^ D[ 60] ^ D[ 58] ^ D[ 57] ^ D[ 55] ^ D[ 54] ^ D[ 53] ^ D[ 52] ^ 
        D[ 51] ^ D[ 50] ^ D[ 48] ^ D[ 47] ^ D[ 43] ^ D[ 42] ^ D[ 32];

Q[14] = D[ 63] ^ D[ 61] ^ D[ 59] ^ D[ 58] ^ D[ 56] ^ D[ 55] ^ D[ 54] ^ D[ 53] ^ 
        D[ 52] ^ D[ 51] ^ D[ 49] ^ D[ 48] ^ D[ 44] ^ D[ 43] ^ D[ 33] ^ D[ 32];

Q[15] = D[ 62] ^ D[ 60] ^ D[ 59] ^ D[ 57] ^ D[ 56] ^ D[ 55] ^ D[ 54] ^ D[ 53] ^ 
        D[ 52] ^ D[ 50] ^ D[ 49] ^ D[ 45] ^ D[ 44] ^ D[ 34] ^ D[ 33];

Q[16] = D[ 57] ^ D[ 56] ^ D[ 51] ^ D[ 48] ^ D[ 47] ^ D[ 46] ^ D[ 44] ^ D[ 37] ^ 
        D[ 35] ^ D[ 32];

Q[17] = D[ 58] ^ D[ 57] ^ D[ 52] ^ D[ 49] ^ D[ 48] ^ D[ 47] ^ D[ 45] ^ D[ 38] ^ 
        D[ 36] ^ D[ 33];

Q[18] = D[ 59] ^ D[ 58] ^ D[ 53] ^ D[ 50] ^ D[ 49] ^ D[ 48] ^ D[ 46] ^ D[ 39] ^ 
        D[ 37] ^ D[ 34] ^ D[ 32];

Q[19] = D[ 60] ^ D[ 59] ^ D[ 54] ^ D[ 51] ^ D[ 50] ^ D[ 49] ^ D[ 47] ^ D[ 40] ^ 
        D[ 38] ^ D[ 35] ^ D[ 33] ^ D[ 32];

Q[20] = D[ 61] ^ D[ 60] ^ D[ 55] ^ D[ 52] ^ D[ 51] ^ D[ 50] ^ D[ 48] ^ D[ 41] ^ 
        D[ 39] ^ D[ 36] ^ D[ 34] ^ D[ 33];

Q[21] = D[ 62] ^ D[ 61] ^ D[ 56] ^ D[ 53] ^ D[ 52] ^ D[ 51] ^ D[ 49] ^ D[ 42] ^ 
        D[ 40] ^ D[ 37] ^ D[ 35] ^ D[ 34];

Q[22] = D[ 62] ^ D[ 61] ^ D[ 60] ^ D[ 58] ^ D[ 57] ^ D[ 55] ^ D[ 52] ^ D[ 48] ^ 
        D[ 47] ^ D[ 45] ^ D[ 44] ^ D[ 43] ^ D[ 41] ^ D[ 38] ^ D[ 37] ^ D[ 36] ^ 
        D[ 35] ^ D[ 34];

Q[23] = D[ 62] ^ D[ 60] ^ D[ 59] ^ D[ 56] ^ D[ 55] ^ D[ 54] ^ D[ 50] ^ D[ 49] ^ 
        D[ 47] ^ D[ 46] ^ D[ 42] ^ D[ 39] ^ D[ 38] ^ D[ 36] ^ D[ 35] ^ D[ 34];

Q[24] = D[ 63] ^ D[ 61] ^ D[ 60] ^ D[ 57] ^ D[ 56] ^ D[ 55] ^ D[ 51] ^ D[ 50] ^ 
        D[ 48] ^ D[ 47] ^ D[ 43] ^ D[ 40] ^ D[ 39] ^ D[ 37] ^ D[ 36] ^ D[ 35] ^ 
        D[ 32];

Q[25] = D[ 62] ^ D[ 61] ^ D[ 58] ^ D[ 57] ^ D[ 56] ^ D[ 52] ^ D[ 51] ^ D[ 49] ^ 
        D[ 48] ^ D[ 44] ^ D[ 41] ^ D[ 40] ^ D[ 38] ^ D[ 37] ^ D[ 36] ^ D[ 33];

Q[26] = D[ 62] ^ D[ 61] ^ D[ 60] ^ D[ 59] ^ D[ 57] ^ D[ 55] ^ D[ 54] ^ D[ 52] ^ 
        D[ 49] ^ D[ 48] ^ D[ 47] ^ D[ 44] ^ D[ 42] ^ D[ 41] ^ D[ 39] ^ D[ 38];

Q[27] = D[ 63] ^ D[ 62] ^ D[ 61] ^ D[ 60] ^ D[ 58] ^ D[ 56] ^ D[ 55] ^ D[ 53] ^ 
        D[ 50] ^ D[ 49] ^ D[ 48] ^ D[ 45] ^ D[ 43] ^ D[ 42] ^ D[ 40] ^ D[ 39] ^ 
        D[ 32];

Q[28] = D[ 63] ^ D[ 62] ^ D[ 61] ^ D[ 59] ^ D[ 57] ^ D[ 56] ^ D[ 54] ^ D[ 51] ^ 
        D[ 50] ^ D[ 49] ^ D[ 46] ^ D[ 44] ^ D[ 43] ^ D[ 41] ^ D[ 40] ^ D[ 33];

Q[29] = D[ 63] ^ D[ 62] ^ D[ 60] ^ D[ 58] ^ D[ 57] ^ D[ 55] ^ D[ 52] ^ D[ 51] ^ 
        D[ 50] ^ D[ 47] ^ D[ 45] ^ D[ 44] ^ D[ 42] ^ D[ 41] ^ D[ 34];

Q[30] = D[ 63] ^ D[ 61] ^ D[ 59] ^ D[ 58] ^ D[ 56] ^ D[ 53] ^ D[ 52] ^ D[ 51] ^ 
        D[ 48] ^ D[ 46] ^ D[ 45] ^ D[ 43] ^ D[ 42] ^ D[ 35] ^ D[ 32];

Q[31] = D[ 62] ^ D[ 60] ^ D[ 59] ^ D[ 57] ^ D[ 54] ^ D[ 53] ^ D[ 52] ^ D[ 49] ^ 
        D[ 47] ^ D[ 46] ^ D[ 44] ^ D[ 43] ^ D[ 36] ^ D[ 33];


crc32_d64_hi_pipe1 = Q;

end
endfunction

function [31:0] crc32_d64_lo_pipe1;

    input [63:0] D;

    reg [31:0] Q;

begin

Q[ 0] = D[ 31] ^ D[ 30] ^ D[ 29] ^ D[ 28] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 16] ^ 
        D[ 12] ^ D[ 10] ^ D[  9] ^ D[  6] ^ D[  0];

Q[ 1] = D[ 28] ^ D[ 27] ^ D[ 24] ^ D[ 17] ^ D[ 16] ^ D[ 13] ^ D[ 12] ^ D[ 11] ^ 
        D[  9] ^ D[  7] ^ D[  6] ^ D[  1] ^ D[  0];

Q[ 2] = D[ 31] ^ D[ 30] ^ D[ 26] ^ D[ 24] ^ D[ 18] ^ D[ 17] ^ D[ 16] ^ D[ 14] ^ 
        D[ 13] ^ D[  9] ^ D[  8] ^ D[  7] ^ D[  6] ^ D[  2] ^ D[  1] ^ D[  0];

Q[ 3] = D[ 31] ^ D[ 27] ^ D[ 25] ^ D[ 19] ^ D[ 18] ^ D[ 17] ^ D[ 15] ^ D[ 14] ^ 
        D[ 10] ^ D[  9] ^ D[  8] ^ D[  7] ^ D[  3] ^ D[  2] ^ D[  1];

Q[ 4] = D[ 31] ^ D[ 30] ^ D[ 29] ^ D[ 25] ^ D[ 24] ^ D[ 20] ^ D[ 19] ^ D[ 18] ^ 
        D[ 15] ^ D[ 12] ^ D[ 11] ^ D[  8] ^ D[  6] ^ D[  4] ^ D[  3] ^ D[  2] ^ 
        D[  0];

Q[ 5] = D[ 29] ^ D[ 28] ^ D[ 24] ^ D[ 21] ^ D[ 20] ^ D[ 19] ^ D[ 13] ^ D[ 10] ^ 
        D[  7] ^ D[  6] ^ D[  5] ^ D[  4] ^ D[  3] ^ D[  1] ^ D[  0];

Q[ 6] = D[ 30] ^ D[ 29] ^ D[ 25] ^ D[ 22] ^ D[ 21] ^ D[ 20] ^ D[ 14] ^ D[ 11] ^ 
        D[  8] ^ D[  7] ^ D[  6] ^ D[  5] ^ D[  4] ^ D[  2] ^ D[  1];

Q[ 7] = D[ 29] ^ D[ 28] ^ D[ 25] ^ D[ 24] ^ D[ 23] ^ D[ 22] ^ D[ 21] ^ D[ 16] ^ 
        D[ 15] ^ D[ 10] ^ D[  8] ^ D[  7] ^ D[  5] ^ D[  3] ^ D[  2] ^ D[  0];

Q[ 8] = D[ 31] ^ D[ 28] ^ D[ 23] ^ D[ 22] ^ D[ 17] ^ D[ 12] ^ D[ 11] ^ D[ 10] ^ 
        D[  8] ^ D[  4] ^ D[  3] ^ D[  1] ^ D[  0];

Q[ 9] = D[ 29] ^ D[ 24] ^ D[ 23] ^ D[ 18] ^ D[ 13] ^ D[ 12] ^ D[ 11] ^ D[  9] ^ 
        D[  5] ^ D[  4] ^ D[  2] ^ D[  1];

Q[10] = D[ 31] ^ D[ 29] ^ D[ 28] ^ D[ 26] ^ D[ 19] ^ D[ 16] ^ D[ 14] ^ D[ 13] ^ 
        D[  9] ^ D[  5] ^ D[  3] ^ D[  2] ^ D[  0];

Q[11] = D[ 31] ^ D[ 28] ^ D[ 27] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 20] ^ D[ 17] ^ 
        D[ 16] ^ D[ 15] ^ D[ 14] ^ D[ 12] ^ D[  9] ^ D[  4] ^ D[  3] ^ D[  1] ^ 
        D[  0];

Q[12] = D[ 31] ^ D[ 30] ^ D[ 27] ^ D[ 24] ^ D[ 21] ^ D[ 18] ^ D[ 17] ^ D[ 15] ^ 
        D[ 13] ^ D[ 12] ^ D[  9] ^ D[  6] ^ D[  5] ^ D[  4] ^ D[  2] ^ D[  1] ^ 
        D[  0];

Q[13] = D[ 31] ^ D[ 28] ^ D[ 25] ^ D[ 22] ^ D[ 19] ^ D[ 18] ^ D[ 16] ^ D[ 14] ^ 
        D[ 13] ^ D[ 10] ^ D[  7] ^ D[  6] ^ D[  5] ^ D[  3] ^ D[  2] ^ D[  1];

Q[14] = D[ 29] ^ D[ 26] ^ D[ 23] ^ D[ 20] ^ D[ 19] ^ D[ 17] ^ D[ 15] ^ D[ 14] ^ 
        D[ 11] ^ D[  8] ^ D[  7] ^ D[  6] ^ D[  4] ^ D[  3] ^ D[  2];

Q[15] = D[ 30] ^ D[ 27] ^ D[ 24] ^ D[ 21] ^ D[ 20] ^ D[ 18] ^ D[ 16] ^ D[ 15] ^ 
        D[ 12] ^ D[  9] ^ D[  8] ^ D[  7] ^ D[  5] ^ D[  4] ^ D[  3];

Q[16] = D[ 30] ^ D[ 29] ^ D[ 26] ^ D[ 24] ^ D[ 22] ^ D[ 21] ^ D[ 19] ^ D[ 17] ^ 
        D[ 13] ^ D[ 12] ^ D[  8] ^ D[  5] ^ D[  4] ^ D[  0];

Q[17] = D[ 31] ^ D[ 30] ^ D[ 27] ^ D[ 25] ^ D[ 23] ^ D[ 22] ^ D[ 20] ^ D[ 18] ^ 
        D[ 14] ^ D[ 13] ^ D[  9] ^ D[  6] ^ D[  5] ^ D[  1];

Q[18] = D[ 31] ^ D[ 28] ^ D[ 26] ^ D[ 24] ^ D[ 23] ^ D[ 21] ^ D[ 19] ^ D[ 15] ^ 
        D[ 14] ^ D[ 10] ^ D[  7] ^ D[  6] ^ D[  2];

Q[19] = D[ 29] ^ D[ 27] ^ D[ 25] ^ D[ 24] ^ D[ 22] ^ D[ 20] ^ D[ 16] ^ D[ 15] ^ 
        D[ 11] ^ D[  8] ^ D[  7] ^ D[  3];

Q[20] = D[ 30] ^ D[ 28] ^ D[ 26] ^ D[ 25] ^ D[ 23] ^ D[ 21] ^ D[ 17] ^ D[ 16] ^ 
        D[ 12] ^ D[  9] ^ D[  8] ^ D[  4];

Q[21] = D[ 31] ^ D[ 29] ^ D[ 27] ^ D[ 26] ^ D[ 24] ^ D[ 22] ^ D[ 18] ^ D[ 17] ^ 
        D[ 13] ^ D[ 10] ^ D[  9] ^ D[  5];

Q[22] = D[ 31] ^ D[ 29] ^ D[ 27] ^ D[ 26] ^ D[ 24] ^ D[ 23] ^ D[ 19] ^ D[ 18] ^ 
        D[ 16] ^ D[ 14] ^ D[ 12] ^ D[ 11] ^ D[  9] ^ D[  0];

Q[23] = D[ 31] ^ D[ 29] ^ D[ 27] ^ D[ 26] ^ D[ 20] ^ D[ 19] ^ D[ 17] ^ D[ 16] ^ 
        D[ 15] ^ D[ 13] ^ D[  9] ^ D[  6] ^ D[  1] ^ D[  0];

Q[24] = D[ 30] ^ D[ 28] ^ D[ 27] ^ D[ 21] ^ D[ 20] ^ D[ 18] ^ D[ 17] ^ D[ 16] ^ 
        D[ 14] ^ D[ 10] ^ D[  7] ^ D[  2] ^ D[  1];

Q[25] = D[ 31] ^ D[ 29] ^ D[ 28] ^ D[ 22] ^ D[ 21] ^ D[ 19] ^ D[ 18] ^ D[ 17] ^ 
        D[ 15] ^ D[ 11] ^ D[  8] ^ D[  3] ^ D[  2];

Q[26] = D[ 31] ^ D[ 28] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 23] ^ D[ 22] ^ D[ 20] ^ 
        D[ 19] ^ D[ 18] ^ D[ 10] ^ D[  6] ^ D[  4] ^ D[  3] ^ D[  0];

Q[27] = D[ 29] ^ D[ 27] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 23] ^ D[ 21] ^ D[ 20] ^ 
        D[ 19] ^ D[ 11] ^ D[  7] ^ D[  5] ^ D[  4] ^ D[  1];

Q[28] = D[ 30] ^ D[ 28] ^ D[ 27] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 22] ^ D[ 21] ^ 
        D[ 20] ^ D[ 12] ^ D[  8] ^ D[  6] ^ D[  5] ^ D[  2];

Q[29] = D[ 31] ^ D[ 29] ^ D[ 28] ^ D[ 27] ^ D[ 26] ^ D[ 25] ^ D[ 23] ^ D[ 22] ^ 
        D[ 21] ^ D[ 13] ^ D[  9] ^ D[  7] ^ D[  6] ^ D[  3];

Q[30] = D[ 30] ^ D[ 29] ^ D[ 28] ^ D[ 27] ^ D[ 26] ^ D[ 24] ^ D[ 23] ^ D[ 22] ^ 
        D[ 14] ^ D[ 10] ^ D[  8] ^ D[  7] ^ D[  4];

Q[31] = D[ 31] ^ D[ 30] ^ D[ 29] ^ D[ 28] ^ D[ 27] ^ D[ 25] ^ D[ 24] ^ D[ 23] ^ 
        D[ 15] ^ D[ 11] ^ D[  9] ^ D[  8] ^ D[  5];


crc32_d64_lo_pipe1 = Q;

end
endfunction

function [31:0] crc32_d64_pipe2;

    input [31:0] D1;
    input [31:0] D2;
    input [31:0] C;

    reg [31:0] Q;

begin

Q[ 0] = D1[ 0] ^ D2[ 0] ^
        C[  0] ^ C[  2] ^ C[  5] ^ C[ 12] ^ C[ 13] ^ C[ 15] ^ C[ 16] ^ C[ 18] ^ 
        C[ 21] ^ C[ 22] ^ C[ 23] ^ C[ 26] ^ C[ 28] ^ C[ 29] ^ C[ 31];

Q[ 1] = D1[ 1] ^ D2[ 1] ^
        C[  1] ^ C[  2] ^ C[  3] ^ C[  5] ^ C[  6] ^ C[ 12] ^ C[ 14] ^ C[ 15] ^ 
        C[ 17] ^ C[ 18] ^ C[ 19] ^ C[ 21] ^ C[ 24] ^ C[ 26] ^ C[ 27] ^ C[ 28] ^ 
        C[ 30] ^ C[ 31];

Q[ 2] = D1[ 2] ^ D2[ 2] ^
        C[  0] ^ C[  3] ^ C[  4] ^ C[  5] ^ C[  6] ^ C[  7] ^ C[ 12] ^ C[ 19] ^ 
        C[ 20] ^ C[ 21] ^ C[ 23] ^ C[ 25] ^ C[ 26] ^ C[ 27];

Q[ 3] = D1[ 3] ^ D2[ 3] ^
        C[  0] ^ C[  1] ^ C[  4] ^ C[  5] ^ C[  6] ^ C[  7] ^ C[  8] ^ C[ 13] ^ 
        C[ 20] ^ C[ 21] ^ C[ 22] ^ C[ 24] ^ C[ 26] ^ C[ 27] ^ C[ 28];

Q[ 4] = D1[ 4] ^ D2[ 4] ^
        C[  1] ^ C[  6] ^ C[  7] ^ C[  8] ^ C[  9] ^ C[ 12] ^ C[ 13] ^ C[ 14] ^ 
        C[ 15] ^ C[ 16] ^ C[ 18] ^ C[ 25] ^ C[ 26] ^ C[ 27] ^ C[ 31];

Q[ 5] = D1[ 5] ^ D2[ 5] ^
        C[  5] ^ C[  7] ^ C[  8] ^ C[  9] ^ C[ 10] ^ C[ 12] ^ C[ 14] ^ C[ 17] ^ 
        C[ 18] ^ C[ 19] ^ C[ 21] ^ C[ 22] ^ C[ 23] ^ C[ 27] ^ C[ 29] ^ C[ 31];

Q[ 6] = D1[ 6] ^ D2[ 6] ^
        C[  6] ^ C[  8] ^ C[  9] ^ C[ 10] ^ C[ 11] ^ C[ 13] ^ C[ 15] ^ C[ 18] ^ 
        C[ 19] ^ C[ 20] ^ C[ 22] ^ C[ 23] ^ C[ 24] ^ C[ 28] ^ C[ 30];

Q[ 7] = D1[ 7] ^ D2[ 7] ^
        C[  0] ^ C[  2] ^ C[  5] ^ C[  7] ^ C[  9] ^ C[ 10] ^ C[ 11] ^ C[ 13] ^ 
        C[ 14] ^ C[ 15] ^ C[ 18] ^ C[ 19] ^ C[ 20] ^ C[ 22] ^ C[ 24] ^ C[ 25] ^ 
        C[ 26] ^ C[ 28];

Q[ 8] = D1[ 8] ^ D2[ 8] ^
        C[  0] ^ C[  1] ^ C[  2] ^ C[  3] ^ C[  5] ^ C[  6] ^ C[  8] ^ C[ 10] ^ 
        C[ 11] ^ C[ 13] ^ C[ 14] ^ C[ 18] ^ C[ 19] ^ C[ 20] ^ C[ 22] ^ C[ 25] ^ 
        C[ 27] ^ C[ 28] ^ C[ 31];

Q[ 9] = D1[ 9] ^ D2[ 9] ^
        C[  0] ^ C[  1] ^ C[  2] ^ C[  3] ^ C[  4] ^ C[  6] ^ C[  7] ^ C[  9] ^ 
        C[ 11] ^ C[ 12] ^ C[ 14] ^ C[ 15] ^ C[ 19] ^ C[ 20] ^ C[ 21] ^ C[ 23] ^ 
        C[ 26] ^ C[ 28] ^ C[ 29];

Q[10] = D1[10] ^ D2[10] ^
        C[  0] ^ C[  1] ^ C[  3] ^ C[  4] ^ C[  7] ^ C[  8] ^ C[ 10] ^ C[ 18] ^ 
        C[ 20] ^ C[ 23] ^ C[ 24] ^ C[ 26] ^ C[ 27] ^ C[ 28] ^ C[ 30] ^ C[ 31];

Q[11] = D1[11] ^ D2[11] ^
        C[  1] ^ C[  4] ^ C[  8] ^ C[  9] ^ C[ 11] ^ C[ 12] ^ C[ 13] ^ C[ 15] ^ 
        C[ 16] ^ C[ 18] ^ C[ 19] ^ C[ 22] ^ C[ 23] ^ C[ 24] ^ C[ 25] ^ C[ 26] ^ 
        C[ 27];

Q[12] = D1[12] ^ D2[12] ^
        C[  9] ^ C[ 10] ^ C[ 14] ^ C[ 15] ^ C[ 17] ^ C[ 18] ^ C[ 19] ^ C[ 20] ^ 
        C[ 21] ^ C[ 22] ^ C[ 24] ^ C[ 25] ^ C[ 27] ^ C[ 29] ^ C[ 31];

Q[13] = D1[13] ^ D2[13] ^
        C[  0] ^ C[ 10] ^ C[ 11] ^ C[ 15] ^ C[ 16] ^ C[ 18] ^ C[ 19] ^ C[ 20] ^ 
        C[ 21] ^ C[ 22] ^ C[ 23] ^ C[ 25] ^ C[ 26] ^ C[ 28] ^ C[ 30];

Q[14] = D1[14] ^ D2[14] ^
        C[  0] ^ C[  1] ^ C[ 11] ^ C[ 12] ^ C[ 16] ^ C[ 17] ^ C[ 19] ^ C[ 20] ^ 
        C[ 21] ^ C[ 22] ^ C[ 23] ^ C[ 24] ^ C[ 26] ^ C[ 27] ^ C[ 29] ^ C[ 31];

Q[15] = D1[15] ^ D2[15] ^
        C[  1] ^ C[  2] ^ C[ 12] ^ C[ 13] ^ C[ 17] ^ C[ 18] ^ C[ 20] ^ C[ 21] ^ 
        C[ 22] ^ C[ 23] ^ C[ 24] ^ C[ 25] ^ C[ 27] ^ C[ 28] ^ C[ 30];

Q[16] = D1[16] ^ D2[16] ^
        C[  0] ^ C[  3] ^ C[  5] ^ C[ 12] ^ C[ 14] ^ C[ 15] ^ C[ 16] ^ C[ 19] ^ 
        C[ 24] ^ C[ 25];

Q[17] = D1[17] ^ D2[17] ^
        C[  1] ^ C[  4] ^ C[  6] ^ C[ 13] ^ C[ 15] ^ C[ 16] ^ C[ 17] ^ C[ 20] ^ 
        C[ 25] ^ C[ 26];

Q[18] = D1[18] ^ D2[18] ^
        C[  0] ^ C[  2] ^ C[  5] ^ C[  7] ^ C[ 14] ^ C[ 16] ^ C[ 17] ^ C[ 18] ^ 
        C[ 21] ^ C[ 26] ^ C[ 27];

Q[19] = D1[19] ^ D2[19] ^
        C[  0] ^ C[  1] ^ C[  3] ^ C[  6] ^ C[  8] ^ C[ 15] ^ C[ 17] ^ C[ 18] ^ 
        C[ 19] ^ C[ 22] ^ C[ 27] ^ C[ 28];

Q[20] = D1[20] ^ D2[20] ^
        C[  1] ^ C[  2] ^ C[  4] ^ C[  7] ^ C[  9] ^ C[ 16] ^ C[ 18] ^ C[ 19] ^ 
        C[ 20] ^ C[ 23] ^ C[ 28] ^ C[ 29];

Q[21] = D1[21] ^ D2[21] ^
        C[  2] ^ C[  3] ^ C[  5] ^ C[  8] ^ C[ 10] ^ C[ 17] ^ C[ 19] ^ C[ 20] ^ 
        C[ 21] ^ C[ 24] ^ C[ 29] ^ C[ 30];

Q[22] = D1[22] ^ D2[22] ^
        C[  2] ^ C[  3] ^ C[  4] ^ C[  5] ^ C[  6] ^ C[  9] ^ C[ 11] ^ C[ 12] ^ 
        C[ 13] ^ C[ 15] ^ C[ 16] ^ C[ 20] ^ C[ 23] ^ C[ 25] ^ C[ 26] ^ C[ 28] ^ 
        C[ 29] ^ C[ 30];

Q[23] = D1[23] ^ D2[23] ^
        C[  2] ^ C[  3] ^ C[  4] ^ C[  6] ^ C[  7] ^ C[ 10] ^ C[ 14] ^ C[ 15] ^ 
        C[ 17] ^ C[ 18] ^ C[ 22] ^ C[ 23] ^ C[ 24] ^ C[ 27] ^ C[ 28] ^ C[ 30];

Q[24] = D1[24] ^ D2[24] ^
        C[  0] ^ C[  3] ^ C[  4] ^ C[  5] ^ C[  7] ^ C[  8] ^ C[ 11] ^ C[ 15] ^ 
        C[ 16] ^ C[ 18] ^ C[ 19] ^ C[ 23] ^ C[ 24] ^ C[ 25] ^ C[ 28] ^ C[ 29] ^ 
        C[ 31];

Q[25] = D1[25] ^ D2[25] ^
        C[  1] ^ C[  4] ^ C[  5] ^ C[  6] ^ C[  8] ^ C[  9] ^ C[ 12] ^ C[ 16] ^ 
        C[ 17] ^ C[ 19] ^ C[ 20] ^ C[ 24] ^ C[ 25] ^ C[ 26] ^ C[ 29] ^ C[ 30];

Q[26] = D1[26] ^ D2[26] ^
        C[  6] ^ C[  7] ^ C[  9] ^ C[ 10] ^ C[ 12] ^ C[ 15] ^ C[ 16] ^ C[ 17] ^ 
        C[ 20] ^ C[ 22] ^ C[ 23] ^ C[ 25] ^ C[ 27] ^ C[ 28] ^ C[ 29] ^ C[ 30];

Q[27] = D1[27] ^ D2[27] ^
        C[  0] ^ C[  7] ^ C[  8] ^ C[ 10] ^ C[ 11] ^ C[ 13] ^ C[ 16] ^ C[ 17] ^ 
        C[ 18] ^ C[ 21] ^ C[ 23] ^ C[ 24] ^ C[ 26] ^ C[ 28] ^ C[ 29] ^ C[ 30] ^ 
        C[ 31];

Q[28] = D1[28] ^ D2[28] ^
        C[  1] ^ C[  8] ^ C[  9] ^ C[ 11] ^ C[ 12] ^ C[ 14] ^ C[ 17] ^ C[ 18] ^ 
        C[ 19] ^ C[ 22] ^ C[ 24] ^ C[ 25] ^ C[ 27] ^ C[ 29] ^ C[ 30] ^ C[ 31];

Q[29] = D1[29] ^ D2[29] ^
        C[  2] ^ C[  9] ^ C[ 10] ^ C[ 12] ^ C[ 13] ^ C[ 15] ^ C[ 18] ^ C[ 19] ^ 
        C[ 20] ^ C[ 23] ^ C[ 25] ^ C[ 26] ^ C[ 28] ^ C[ 30] ^ C[ 31];

Q[30] = D1[30] ^ D2[30] ^
        C[  0] ^ C[  3] ^ C[ 10] ^ C[ 11] ^ C[ 13] ^ C[ 14] ^ C[ 16] ^ C[ 19] ^ 
        C[ 20] ^ C[ 21] ^ C[ 24] ^ C[ 26] ^ C[ 27] ^ C[ 29] ^ C[ 31];

Q[31] = D1[31] ^ D2[31] ^
        C[  1] ^ C[  4] ^ C[ 11] ^ C[ 12] ^ C[ 14] ^ C[ 15] ^ C[ 17] ^ C[ 20] ^ 
        C[ 21] ^ C[ 22] ^ C[ 25] ^ C[ 27] ^ C[ 28] ^ C[ 30];


crc32_d64_pipe2 = Q;

end
endfunction


///////////////////////////////////////////////////////////////////////////////
// 32-bit CRC Generators
///////////////////////////////////////////////////////////////////////////////
function [31:0] crc32_d32_hi_pipe1;

    input [31:0] D;

    reg [31:0] Q;

begin

Q[ 0] = D[ 31] ^ D[ 30] ^ D[ 29] ^ D[ 28] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 16];

Q[ 1] = D[ 28] ^ D[ 27] ^ D[ 24] ^ D[ 17] ^ D[ 16];

Q[ 2] = D[ 31] ^ D[ 30] ^ D[ 26] ^ D[ 24] ^ D[ 18] ^ D[ 17] ^ D[ 16];

Q[ 3] = D[ 31] ^ D[ 27] ^ D[ 25] ^ D[ 19] ^ D[ 18] ^ D[ 17];

Q[ 4] = D[ 31] ^ D[ 30] ^ D[ 29] ^ D[ 25] ^ D[ 24] ^ D[ 20] ^ D[ 19] ^ D[ 18];

Q[ 5] = D[ 29] ^ D[ 28] ^ D[ 24] ^ D[ 21] ^ D[ 20] ^ D[ 19];

Q[ 6] = D[ 30] ^ D[ 29] ^ D[ 25] ^ D[ 22] ^ D[ 21] ^ D[ 20];

Q[ 7] = D[ 29] ^ D[ 28] ^ D[ 25] ^ D[ 24] ^ D[ 23] ^ D[ 22] ^ D[ 21] ^ D[ 16];

Q[ 8] = D[ 31] ^ D[ 28] ^ D[ 23] ^ D[ 22] ^ D[ 17];

Q[ 9] = D[ 29] ^ D[ 24] ^ D[ 23] ^ D[ 18];

Q[10] = D[ 31] ^ D[ 29] ^ D[ 28] ^ D[ 26] ^ D[ 19] ^ D[ 16];

Q[11] = D[ 31] ^ D[ 28] ^ D[ 27] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 20] ^ D[ 17] ^ 
        D[ 16];

Q[12] = D[ 31] ^ D[ 30] ^ D[ 27] ^ D[ 24] ^ D[ 21] ^ D[ 18] ^ D[ 17];

Q[13] = D[ 31] ^ D[ 28] ^ D[ 25] ^ D[ 22] ^ D[ 19] ^ D[ 18] ^ D[ 16];

Q[14] = D[ 29] ^ D[ 26] ^ D[ 23] ^ D[ 20] ^ D[ 19] ^ D[ 17];

Q[15] = D[ 30] ^ D[ 27] ^ D[ 24] ^ D[ 21] ^ D[ 20] ^ D[ 18] ^ D[ 16];

Q[16] = D[ 30] ^ D[ 29] ^ D[ 26] ^ D[ 24] ^ D[ 22] ^ D[ 21] ^ D[ 19] ^ D[ 17];

Q[17] = D[ 31] ^ D[ 30] ^ D[ 27] ^ D[ 25] ^ D[ 23] ^ D[ 22] ^ D[ 20] ^ D[ 18];

Q[18] = D[ 31] ^ D[ 28] ^ D[ 26] ^ D[ 24] ^ D[ 23] ^ D[ 21] ^ D[ 19];

Q[19] = D[ 29] ^ D[ 27] ^ D[ 25] ^ D[ 24] ^ D[ 22] ^ D[ 20] ^ D[ 16];

Q[20] = D[ 30] ^ D[ 28] ^ D[ 26] ^ D[ 25] ^ D[ 23] ^ D[ 21] ^ D[ 17] ^ D[ 16];

Q[21] = D[ 31] ^ D[ 29] ^ D[ 27] ^ D[ 26] ^ D[ 24] ^ D[ 22] ^ D[ 18] ^ D[ 17];

Q[22] = D[ 31] ^ D[ 29] ^ D[ 27] ^ D[ 26] ^ D[ 24] ^ D[ 23] ^ D[ 19] ^ D[ 18] ^ 
        D[ 16];

Q[23] = D[ 31] ^ D[ 29] ^ D[ 27] ^ D[ 26] ^ D[ 20] ^ D[ 19] ^ D[ 17] ^ D[ 16];

Q[24] = D[ 30] ^ D[ 28] ^ D[ 27] ^ D[ 21] ^ D[ 20] ^ D[ 18] ^ D[ 17] ^ D[ 16];

Q[25] = D[ 31] ^ D[ 29] ^ D[ 28] ^ D[ 22] ^ D[ 21] ^ D[ 19] ^ D[ 18] ^ D[ 17];

Q[26] = D[ 31] ^ D[ 28] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 23] ^ D[ 22] ^ D[ 20] ^ 
        D[ 19] ^ D[ 18];

Q[27] = D[ 29] ^ D[ 27] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 23] ^ D[ 21] ^ D[ 20] ^ 
        D[ 19];

Q[28] = D[ 30] ^ D[ 28] ^ D[ 27] ^ D[ 26] ^ D[ 25] ^ D[ 24] ^ D[ 22] ^ D[ 21] ^ 
        D[ 20];

Q[29] = D[ 31] ^ D[ 29] ^ D[ 28] ^ D[ 27] ^ D[ 26] ^ D[ 25] ^ D[ 23] ^ D[ 22] ^ 
        D[ 21];

Q[30] = D[ 30] ^ D[ 29] ^ D[ 28] ^ D[ 27] ^ D[ 26] ^ D[ 24] ^ D[ 23] ^ D[ 22];

Q[31] = D[ 31] ^ D[ 30] ^ D[ 29] ^ D[ 28] ^ D[ 27] ^ D[ 25] ^ D[ 24] ^ D[ 23];


crc32_d32_hi_pipe1 = Q;

end
endfunction

function [31:0] crc32_d32_lo_pipe1;

    input [31:0] D;

    reg [31:0] Q;

begin

Q[ 0] = D[ 12] ^ D[ 10] ^ D[  9] ^ D[  6] ^ D[  0];

Q[ 1] = D[ 13] ^ D[ 12] ^ D[ 11] ^ D[  9] ^ D[  7] ^ D[  6] ^ D[  1] ^ D[  0];

Q[ 2] = D[ 14] ^ D[ 13] ^ D[  9] ^ D[  8] ^ D[  7] ^ D[  6] ^ D[  2] ^ D[  1] ^ 
        D[  0];

Q[ 3] = D[ 15] ^ D[ 14] ^ D[ 10] ^ D[  9] ^ D[  8] ^ D[  7] ^ D[  3] ^ D[  2] ^ 
        D[  1];

Q[ 4] = D[ 15] ^ D[ 12] ^ D[ 11] ^ D[  8] ^ D[  6] ^ D[  4] ^ D[  3] ^ D[  2] ^ 
        D[  0];

Q[ 5] = D[ 13] ^ D[ 10] ^ D[  7] ^ D[  6] ^ D[  5] ^ D[  4] ^ D[  3] ^ D[  1] ^ 
        D[  0];

Q[ 6] = D[ 14] ^ D[ 11] ^ D[  8] ^ D[  7] ^ D[  6] ^ D[  5] ^ D[  4] ^ D[  2] ^ 
        D[  1];

Q[ 7] = D[ 15] ^ D[ 10] ^ D[  8] ^ D[  7] ^ D[  5] ^ D[  3] ^ D[  2] ^ D[  0];

Q[ 8] = D[ 12] ^ D[ 11] ^ D[ 10] ^ D[  8] ^ D[  4] ^ D[  3] ^ D[  1] ^ D[  0];

Q[ 9] = D[ 13] ^ D[ 12] ^ D[ 11] ^ D[  9] ^ D[  5] ^ D[  4] ^ D[  2] ^ D[  1];

Q[10] = D[ 14] ^ D[ 13] ^ D[  9] ^ D[  5] ^ D[  3] ^ D[  2] ^ D[  0];

Q[11] = D[ 15] ^ D[ 14] ^ D[ 12] ^ D[  9] ^ D[  4] ^ D[  3] ^ D[  1] ^ D[  0];

Q[12] = D[ 15] ^ D[ 13] ^ D[ 12] ^ D[  9] ^ D[  6] ^ D[  5] ^ D[  4] ^ D[  2] ^ 
        D[  1] ^ D[  0];

Q[13] = D[ 14] ^ D[ 13] ^ D[ 10] ^ D[  7] ^ D[  6] ^ D[  5] ^ D[  3] ^ D[  2] ^ 
        D[  1];

Q[14] = D[ 15] ^ D[ 14] ^ D[ 11] ^ D[  8] ^ D[  7] ^ D[  6] ^ D[  4] ^ D[  3] ^ 
        D[  2];

Q[15] = D[ 15] ^ D[ 12] ^ D[  9] ^ D[  8] ^ D[  7] ^ D[  5] ^ D[  4] ^ D[  3];

Q[16] = D[ 13] ^ D[ 12] ^ D[  8] ^ D[  5] ^ D[  4] ^ D[  0];

Q[17] = D[ 14] ^ D[ 13] ^ D[  9] ^ D[  6] ^ D[  5] ^ D[  1];

Q[18] = D[ 15] ^ D[ 14] ^ D[ 10] ^ D[  7] ^ D[  6] ^ D[  2];

Q[19] = D[ 15] ^ D[ 11] ^ D[  8] ^ D[  7] ^ D[  3];

Q[20] = D[ 12] ^ D[  9] ^ D[  8] ^ D[  4];

Q[21] = D[ 13] ^ D[ 10] ^ D[  9] ^ D[  5];

Q[22] = D[ 14] ^ D[ 12] ^ D[ 11] ^ D[  9] ^ D[  0];

Q[23] = D[ 15] ^ D[ 13] ^ D[  9] ^ D[  6] ^ D[  1] ^ D[  0];

Q[24] = D[ 14] ^ D[ 10] ^ D[  7] ^ D[  2] ^ D[  1];

Q[25] = D[ 15] ^ D[ 11] ^ D[  8] ^ D[  3] ^ D[  2];

Q[26] = D[ 10] ^ D[  6] ^ D[  4] ^ D[  3] ^ D[  0];

Q[27] = D[ 11] ^ D[  7] ^ D[  5] ^ D[  4] ^ D[  1];

Q[28] = D[ 12] ^ D[  8] ^ D[  6] ^ D[  5] ^ D[  2];

Q[29] = D[ 13] ^ D[  9] ^ D[  7] ^ D[  6] ^ D[  3];

Q[30] = D[ 14] ^ D[ 10] ^ D[  8] ^ D[  7] ^ D[  4];

Q[31] = D[ 15] ^ D[ 11] ^ D[  9] ^ D[  8] ^ D[  5];


crc32_d32_lo_pipe1 = Q;

end
endfunction

function [31:0] crc32_d32_pipe2;

    input [31:0] D1;
    input [31:0] D2;
    input [31:0] C;

    reg [31:0] Q;

begin

Q[ 0] = D1[ 0] ^ D2[ 0] ^
        C[  0] ^ C[  6] ^ C[  9] ^ C[ 10] ^ C[ 12] ^ C[ 16] ^ C[ 24] ^ C[ 25] ^ 
        C[ 26] ^ C[ 28] ^ C[ 29] ^ C[ 30] ^ C[ 31];

Q[ 1] = D1[ 1] ^ D2[ 1] ^
        C[  0] ^ C[  1] ^ C[  6] ^ C[  7] ^ C[  9] ^ C[ 11] ^ C[ 12] ^ C[ 13] ^ 
        C[ 16] ^ C[ 17] ^ C[ 24] ^ C[ 27] ^ C[ 28];

Q[ 2] = D1[ 2] ^ D2[ 2] ^
        C[  0] ^ C[  1] ^ C[  2] ^ C[  6] ^ C[  7] ^ C[  8] ^ C[  9] ^ C[ 13] ^ 
        C[ 14] ^ C[ 16] ^ C[ 17] ^ C[ 18] ^ C[ 24] ^ C[ 26] ^ C[ 30] ^ C[ 31];

Q[ 3] = D1[ 3] ^ D2[ 3] ^
        C[  1] ^ C[  2] ^ C[  3] ^ C[  7] ^ C[  8] ^ C[  9] ^ C[ 10] ^ C[ 14] ^ 
        C[ 15] ^ C[ 17] ^ C[ 18] ^ C[ 19] ^ C[ 25] ^ C[ 27] ^ C[ 31];

Q[ 4] = D1[ 4] ^ D2[ 4] ^
        C[  0] ^ C[  2] ^ C[  3] ^ C[  4] ^ C[  6] ^ C[  8] ^ C[ 11] ^ C[ 12] ^ 
        C[ 15] ^ C[ 18] ^ C[ 19] ^ C[ 20] ^ C[ 24] ^ C[ 25] ^ C[ 29] ^ C[ 30] ^ 
        C[ 31];

Q[ 5] = D1[ 5] ^ D2[ 5] ^
        C[  0] ^ C[  1] ^ C[  3] ^ C[  4] ^ C[  5] ^ C[  6] ^ C[  7] ^ C[ 10] ^ 
        C[ 13] ^ C[ 19] ^ C[ 20] ^ C[ 21] ^ C[ 24] ^ C[ 28] ^ C[ 29];

Q[ 6] = D1[ 6] ^ D2[ 6] ^
        C[  1] ^ C[  2] ^ C[  4] ^ C[  5] ^ C[  6] ^ C[  7] ^ C[  8] ^ C[ 11] ^ 
        C[ 14] ^ C[ 20] ^ C[ 21] ^ C[ 22] ^ C[ 25] ^ C[ 29] ^ C[ 30];

Q[ 7] = D1[ 7] ^ D2[ 7] ^
        C[  0] ^ C[  2] ^ C[  3] ^ C[  5] ^ C[  7] ^ C[  8] ^ C[ 10] ^ C[ 15] ^ 
        C[ 16] ^ C[ 21] ^ C[ 22] ^ C[ 23] ^ C[ 24] ^ C[ 25] ^ C[ 28] ^ C[ 29];

Q[ 8] = D1[ 8] ^ D2[ 8] ^
        C[  0] ^ C[  1] ^ C[  3] ^ C[  4] ^ C[  8] ^ C[ 10] ^ C[ 11] ^ C[ 12] ^ 
        C[ 17] ^ C[ 22] ^ C[ 23] ^ C[ 28] ^ C[ 31];

Q[ 9] = D1[ 9] ^ D2[ 9] ^
        C[  1] ^ C[  2] ^ C[  4] ^ C[  5] ^ C[  9] ^ C[ 11] ^ C[ 12] ^ C[ 13] ^ 
        C[ 18] ^ C[ 23] ^ C[ 24] ^ C[ 29];

Q[10] = D1[10] ^ D2[10] ^
        C[  0] ^ C[  2] ^ C[  3] ^ C[  5] ^ C[  9] ^ C[ 13] ^ C[ 14] ^ C[ 16] ^ 
        C[ 19] ^ C[ 26] ^ C[ 28] ^ C[ 29] ^ C[ 31];

Q[11] = D1[11] ^ D2[11] ^
        C[  0] ^ C[  1] ^ C[  3] ^ C[  4] ^ C[  9] ^ C[ 12] ^ C[ 14] ^ C[ 15] ^ 
        C[ 16] ^ C[ 17] ^ C[ 20] ^ C[ 24] ^ C[ 25] ^ C[ 26] ^ C[ 27] ^ C[ 28] ^ 
        C[ 31];

Q[12] = D1[12] ^ D2[12] ^
        C[  0] ^ C[  1] ^ C[  2] ^ C[  4] ^ C[  5] ^ C[  6] ^ C[  9] ^ C[ 12] ^ 
        C[ 13] ^ C[ 15] ^ C[ 17] ^ C[ 18] ^ C[ 21] ^ C[ 24] ^ C[ 27] ^ C[ 30] ^ 
        C[ 31];

Q[13] = D1[13] ^ D2[13] ^
        C[  1] ^ C[  2] ^ C[  3] ^ C[  5] ^ C[  6] ^ C[  7] ^ C[ 10] ^ C[ 13] ^ 
        C[ 14] ^ C[ 16] ^ C[ 18] ^ C[ 19] ^ C[ 22] ^ C[ 25] ^ C[ 28] ^ C[ 31];

Q[14] = D1[14] ^ D2[14] ^
        C[  2] ^ C[  3] ^ C[  4] ^ C[  6] ^ C[  7] ^ C[  8] ^ C[ 11] ^ C[ 14] ^ 
        C[ 15] ^ C[ 17] ^ C[ 19] ^ C[ 20] ^ C[ 23] ^ C[ 26] ^ C[ 29];

Q[15] = D1[15] ^ D2[15] ^
        C[  3] ^ C[  4] ^ C[  5] ^ C[  7] ^ C[  8] ^ C[  9] ^ C[ 12] ^ C[ 15] ^ 
        C[ 16] ^ C[ 18] ^ C[ 20] ^ C[ 21] ^ C[ 24] ^ C[ 27] ^ C[ 30];

Q[16] = D1[16] ^ D2[16] ^
        C[  0] ^ C[  4] ^ C[  5] ^ C[  8] ^ C[ 12] ^ C[ 13] ^ C[ 17] ^ C[ 19] ^ 
        C[ 21] ^ C[ 22] ^ C[ 24] ^ C[ 26] ^ C[ 29] ^ C[ 30];

Q[17] = D1[17] ^ D2[17] ^
        C[  1] ^ C[  5] ^ C[  6] ^ C[  9] ^ C[ 13] ^ C[ 14] ^ C[ 18] ^ C[ 20] ^ 
        C[ 22] ^ C[ 23] ^ C[ 25] ^ C[ 27] ^ C[ 30] ^ C[ 31];

Q[18] = D1[18] ^ D2[18] ^
        C[  2] ^ C[  6] ^ C[  7] ^ C[ 10] ^ C[ 14] ^ C[ 15] ^ C[ 19] ^ C[ 21] ^ 
        C[ 23] ^ C[ 24] ^ C[ 26] ^ C[ 28] ^ C[ 31];

Q[19] = D1[19] ^ D2[19] ^
        C[  3] ^ C[  7] ^ C[  8] ^ C[ 11] ^ C[ 15] ^ C[ 16] ^ C[ 20] ^ C[ 22] ^ 
        C[ 24] ^ C[ 25] ^ C[ 27] ^ C[ 29];

Q[20] = D1[20] ^ D2[20] ^
        C[  4] ^ C[  8] ^ C[  9] ^ C[ 12] ^ C[ 16] ^ C[ 17] ^ C[ 21] ^ C[ 23] ^ 
        C[ 25] ^ C[ 26] ^ C[ 28] ^ C[ 30];

Q[21] = D1[21] ^ D2[21] ^
        C[  5] ^ C[  9] ^ C[ 10] ^ C[ 13] ^ C[ 17] ^ C[ 18] ^ C[ 22] ^ C[ 24] ^ 
        C[ 26] ^ C[ 27] ^ C[ 29] ^ C[ 31];

Q[22] = D1[22] ^ D2[22] ^
        C[  0] ^ C[  9] ^ C[ 11] ^ C[ 12] ^ C[ 14] ^ C[ 16] ^ C[ 18] ^ C[ 19] ^ 
        C[ 23] ^ C[ 24] ^ C[ 26] ^ C[ 27] ^ C[ 29] ^ C[ 31];

Q[23] = D1[23] ^ D2[23] ^
        C[  0] ^ C[  1] ^ C[  6] ^ C[  9] ^ C[ 13] ^ C[ 15] ^ C[ 16] ^ C[ 17] ^ 
        C[ 19] ^ C[ 20] ^ C[ 26] ^ C[ 27] ^ C[ 29] ^ C[ 31];

Q[24] = D1[24] ^ D2[24] ^
        C[  1] ^ C[  2] ^ C[  7] ^ C[ 10] ^ C[ 14] ^ C[ 16] ^ C[ 17] ^ C[ 18] ^ 
        C[ 20] ^ C[ 21] ^ C[ 27] ^ C[ 28] ^ C[ 30];

Q[25] = D1[25] ^ D2[25] ^
        C[  2] ^ C[  3] ^ C[  8] ^ C[ 11] ^ C[ 15] ^ C[ 17] ^ C[ 18] ^ C[ 19] ^ 
        C[ 21] ^ C[ 22] ^ C[ 28] ^ C[ 29] ^ C[ 31];

Q[26] = D1[26] ^ D2[26] ^
        C[  0] ^ C[  3] ^ C[  4] ^ C[  6] ^ C[ 10] ^ C[ 18] ^ C[ 19] ^ C[ 20] ^ 
        C[ 22] ^ C[ 23] ^ C[ 24] ^ C[ 25] ^ C[ 26] ^ C[ 28] ^ C[ 31];

Q[27] = D1[27] ^ D2[27] ^
        C[  1] ^ C[  4] ^ C[  5] ^ C[  7] ^ C[ 11] ^ C[ 19] ^ C[ 20] ^ C[ 21] ^ 
        C[ 23] ^ C[ 24] ^ C[ 25] ^ C[ 26] ^ C[ 27] ^ C[ 29];

Q[28] = D1[28] ^ D2[28] ^
        C[  2] ^ C[  5] ^ C[  6] ^ C[  8] ^ C[ 12] ^ C[ 20] ^ C[ 21] ^ C[ 22] ^ 
        C[ 24] ^ C[ 25] ^ C[ 26] ^ C[ 27] ^ C[ 28] ^ C[ 30];

Q[29] = D1[29] ^ D2[29] ^
        C[  3] ^ C[  6] ^ C[  7] ^ C[  9] ^ C[ 13] ^ C[ 21] ^ C[ 22] ^ C[ 23] ^ 
        C[ 25] ^ C[ 26] ^ C[ 27] ^ C[ 28] ^ C[ 29] ^ C[ 31];

Q[30] = D1[30] ^ D2[30] ^
        C[  4] ^ C[  7] ^ C[  8] ^ C[ 10] ^ C[ 14] ^ C[ 22] ^ C[ 23] ^ C[ 24] ^ 
        C[ 26] ^ C[ 27] ^ C[ 28] ^ C[ 29] ^ C[ 30];

Q[31] = D1[31] ^ D2[31] ^
        C[  5] ^ C[  8] ^ C[  9] ^ C[ 11] ^ C[ 15] ^ C[ 23] ^ C[ 24] ^ C[ 25] ^ 
        C[ 27] ^ C[ 28] ^ C[ 29] ^ C[ 30] ^ C[ 31];


crc32_d32_pipe2 = Q;

end
endfunction


endmodule
