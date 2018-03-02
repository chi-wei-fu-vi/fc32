/********************************CONFIDENTIAL****************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-05-23 00:45:19 -0700 (Wed, 23 May 2012) $
* $Revision: 35 $
* Description:
*   This module generates or check a PRBS pattern. Using parameters 
*   the tap position, polynomial length and parallel output width 
*   can be specified.
*
* Upper level dependencies:  
* Lower level dependencies:
* Revision History Notes:
*
* 05/22/2012 tmb - Initial release
*
***************************************************************************/
//    
// 
//--------------------------------------------------------------------------
// PARAMETERS 
//--------------------------------------------------------------------------
//   CHK_MODE     : '1' => check mode
//                  '0' => generate mode
//   POLY_LENGTH  : length of the polynomial (= number of shift register stages)
//   POLY_TAP     : intermediate stage that is xor-ed with the last stage to generate to next prbs bit 
//   DWIDTH: bus size of iDATA and oDATA
//
//--------------------------------------------------------------------------
// NOTES
//--------------------------------------------------------------------------
//
//   References: xapp884
//   Set paramaters to the following values for a ITU-T compliant PRBS
//------------------------------------------------------------------------------
// POLY_LENGTH POLY_TAP INV_PATTERN  || nbr of   bit seq.   max 0      feedback   
//                                   || stages    length  sequence      stages  
//------------------------------------------------------------------------------ 
//     7          6       false      ||    7         127      6 ni        6, 7   (*)
//     9          5       false      ||    9         511      8 ni        5, 9   
//    11          9       false      ||   11        2047     10 ni        9,11   
//    15         14       true       ||   15       32767     15 i        14,15   
//    20          3       false      ||   20     1048575     19 ni        3,20   
//    23         18       true       ||   23     8388607     23 i        18,23   
//    29         27       true       ||   29   536870911     29 i        27,29   
//    31         28       true       ||   31  2147483647     31 i        28,31   
//
// i=inverted, ni= non-inverted
// (*) non standard
//----------------------------------------------------------------------------
//
//
// Example showing parallel PRBS construction:
// Primitive Polynomial: X^2 + 1. POLY_LENGTH = 2, POLY_TAP = 0
//
// SEED   = 3'b111,    
// WORD 1 = 3'b010
// WORD 2 = 3'b011
// WORD 3 = 3'b101
// WORD 4 = 3'b001
// WORD 5 = 3'b110
// WORD 6 = 3'b100
// WORD 7 = 3'b111 (repeats).
// Primitive polynomial since max length w/ no repeats until word 7.
//     |--+----------|
//     |-R2----R1----R0
//
//x^1  |2^0  |  2  |  1  |
//x^2  |2^1^0|2^0  |  2  |
//x^3  |1^0  |2^1^0|2^0  |
//  
// For parallel output of 3-bits
// data_out[0] = R[2]^R[0] 
// data_out[1] = R[2]^R[1]^R[0] 
// data_out[2] = R[1]^R[0] 
//  
// pseudo-code - prbs is a 2-dimensional array.
// i = 0, prbs_xor_a = 2 ^ 0, prbs_xor_b = 2 ^ 0 ^ iData[0], prbs[1]= {prbs_xor_b, prbs[0][1:2]}
// i = 1, prbs_xor_a = (2 ^ 0 ^ iData[0]) ^( 1), prbs_xor_b = prbs_xor_a ^ iData[1], prbs[2]= {prbs_xor_b, prbs[1][1:2]}
// i = 2, prbs_xor_a = (1 ^ 0 ^ iData[1]) , prbs_xor_b = prbs_xor_a ^ iData[2], prbs[3]= {prbs_xor_b, prbs[2][1:2]}


module prbs_parm 
#(
   parameter CHK_MODE = 0,
   parameter POLY_LENGTH = 31,
   parameter POLY_TAP = 3,
   parameter DWIDTH = 16
)(  
   input 			                iRST,
   input 	                    iCLK,
   input                      iEN,   
   input                      iINVERT,
   input  [DWIDTH-1:0] iDATA,
   output [DWIDTH-1:0] oDATA
);
   
   
logic [DWIDTH:0][1:POLY_LENGTH] prbs;
logic [DWIDTH - 1:0]    data_in_i;
logic [DWIDTH - 1:0]    prbs_xor_a;
logic [DWIDTH - 1:0]    prbs_xor_b;
logic [DWIDTH:1]        prbs_msb;
logic [1:POLY_LENGTH]          prbs_reg; 
logic [DWIDTH - 1:0]    data_reg; 
  


////////////////////////////////////////////////////////////////////////////
//
// Assignments
//
////////////////////////////////////////////////////////////////////////////
assign oDATA = data_reg;
assign data_in_i = (iINVERT) ? ~iDATA : iDATA;
assign prbs[0] = prbs_reg; 

////////////////////////////////////////////////////////////////////////////
//
// Combinational - Parameterized XOR Tree 
//
////////////////////////////////////////////////////////////////////////////
genvar i;
generate for (i=0; i<DWIDTH; i=i+1) 
begin : gen_xor
   assign prbs_xor_a[i] = prbs[i][POLY_TAP] ^ prbs[i][POLY_LENGTH];
   assign prbs_xor_b[i] = prbs_xor_a[i] ^ data_in_i[i];
   assign prbs_msb[i+1] = CHK_MODE == 0 ? prbs_xor_a[i]  :  data_in_i[i];  
   assign prbs[i+1] = {prbs_msb[i+1] , prbs[i][1:POLY_LENGTH-1]};  // shift-in new value to msb
end
endgenerate


////////////////////////////////////////////////////////////////////////////
//
// Clocked Registers
//
////////////////////////////////////////////////////////////////////////////
always @(posedge iCLK, posedge iRST) 
begin
  if(iRST) 
  begin
    prbs_reg <= '1; // {POLY_LENGTH{1'b1}};     // default seed - all ones.
    data_reg <= '1; // {DWIDTH{1'b1}};           // default output all ones
  end
  else
  begin
    if(iEN) 
    begin
      prbs_reg <= prbs[DWIDTH];
      data_reg <= prbs_xor_b;                   // next prbs output value     
    end
  end
end

endmodule
