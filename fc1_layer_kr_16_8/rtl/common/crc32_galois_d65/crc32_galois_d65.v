/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-04-01 09:59:13 -0700 (Tue, 01 Apr 2014) $
* $Revision: 5062 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/



//-----------------------------------------------------------------------------
// CRC module for
//	 data[64:0]
//	 crc[31:0]=1+x^2+x^11+x^21+x^23+x^32;
//
module crc32_galois_d65(
	input   [64:0] DIN,
	input   ENA,
	output  [31:0] CRC,
	input   RST,
	input   CLK);

reg     [31:0] srq, srd;
assign  CRC    =  srq;
always @(*) begin
	srd[0] =  srq[0] ^ srq[3] ^ srq[6] ^ srq[9] ^ srq[10] ^ srq[11] ^ srq[12] ^ srq[14] ^ srq[15] ^ srq[17] ^ srq[18] ^ srq[19] ^ srq[22] ^ srq[24] ^ srq[25] ^ srq[27] ^ srq[29] ^ srq[31] ^ DIN[0] ^ DIN[9] ^ DIN[11] ^ DIN[18] ^ DIN[21] ^ DIN[22] ^ DIN[27] ^ DIN[29] ^ DIN[30] ^ DIN[31] ^ DIN[32] ^ DIN[33] ^ DIN[36] ^ DIN[39] ^ DIN[42] ^ DIN[43] ^ DIN[44] ^ DIN[45] ^ DIN[47] ^ DIN[48] ^ DIN[50] ^ DIN[51] ^ DIN[52] ^ DIN[55] ^ DIN[57] ^ DIN[58] ^ DIN[60] ^ DIN[62] ^ DIN[64];
	srd[1] =  srq[0] ^ srq[1] ^ srq[4] ^ srq[7] ^ srq[10] ^ srq[11] ^ srq[12] ^ srq[13] ^ srq[15] ^ srq[16] ^ srq[18] ^ srq[19] ^ srq[20] ^ srq[23] ^ srq[25] ^ srq[26] ^ srq[28] ^ srq[30] ^ DIN[1] ^ DIN[10] ^ DIN[12] ^ DIN[19] ^ DIN[22] ^ DIN[23] ^ DIN[28] ^ DIN[30] ^ DIN[31] ^ DIN[32] ^ DIN[33] ^ DIN[34] ^ DIN[37] ^ DIN[40] ^ DIN[43] ^ DIN[44] ^ DIN[45] ^ DIN[46] ^ DIN[48] ^ DIN[49] ^ DIN[51] ^ DIN[52] ^ DIN[53] ^ DIN[56] ^ DIN[58] ^ DIN[59] ^ DIN[61] ^ DIN[63];
	srd[2] =  srq[1] ^ srq[2] ^ srq[3] ^ srq[5] ^ srq[6] ^ srq[8] ^ srq[9] ^ srq[10] ^ srq[13] ^ srq[15] ^ srq[16] ^ srq[18] ^ srq[20] ^ srq[21] ^ srq[22] ^ srq[25] ^ srq[26] ^ DIN[0] ^ DIN[2] ^ DIN[9] ^ DIN[13] ^ DIN[18] ^ DIN[20] ^ DIN[21] ^ DIN[22] ^ DIN[23] ^ DIN[24] ^ DIN[27] ^ DIN[30] ^ DIN[34] ^ DIN[35] ^ DIN[36] ^ DIN[38] ^ DIN[39] ^ DIN[41] ^ DIN[42] ^ DIN[43] ^ DIN[46] ^ DIN[48] ^ DIN[49] ^ DIN[51] ^ DIN[53] ^ DIN[54] ^ DIN[55] ^ DIN[58] ^ DIN[59];
	srd[3] =  srq[2] ^ srq[3] ^ srq[4] ^ srq[6] ^ srq[7] ^ srq[9] ^ srq[10] ^ srq[11] ^ srq[14] ^ srq[16] ^ srq[17] ^ srq[19] ^ srq[21] ^ srq[22] ^ srq[23] ^ srq[26] ^ srq[27] ^ DIN[1] ^ DIN[3] ^ DIN[10] ^ DIN[14] ^ DIN[19] ^ DIN[21] ^ DIN[22] ^ DIN[23] ^ DIN[24] ^ DIN[25] ^ DIN[28] ^ DIN[31] ^ DIN[35] ^ DIN[36] ^ DIN[37] ^ DIN[39] ^ DIN[40] ^ DIN[42] ^ DIN[43] ^ DIN[44] ^ DIN[47] ^ DIN[49] ^ DIN[50] ^ DIN[52] ^ DIN[54] ^ DIN[55] ^ DIN[56] ^ DIN[59] ^ DIN[60];
	srd[4] =  srq[3] ^ srq[4] ^ srq[5] ^ srq[7] ^ srq[8] ^ srq[10] ^ srq[11] ^ srq[12] ^ srq[15] ^ srq[17] ^ srq[18] ^ srq[20] ^ srq[22] ^ srq[23] ^ srq[24] ^ srq[27] ^ srq[28] ^ DIN[2] ^ DIN[4] ^ DIN[11] ^ DIN[15] ^ DIN[20] ^ DIN[22] ^ DIN[23] ^ DIN[24] ^ DIN[25] ^ DIN[26] ^ DIN[29] ^ DIN[32] ^ DIN[36] ^ DIN[37] ^ DIN[38] ^ DIN[40] ^ DIN[41] ^ DIN[43] ^ DIN[44] ^ DIN[45] ^ DIN[48] ^ DIN[50] ^ DIN[51] ^ DIN[53] ^ DIN[55] ^ DIN[56] ^ DIN[57] ^ DIN[60] ^ DIN[61];
	srd[5] =  srq[0] ^ srq[4] ^ srq[5] ^ srq[6] ^ srq[8] ^ srq[9] ^ srq[11] ^ srq[12] ^ srq[13] ^ srq[16] ^ srq[18] ^ srq[19] ^ srq[21] ^ srq[23] ^ srq[24] ^ srq[25] ^ srq[28] ^ srq[29] ^ DIN[3] ^ DIN[5] ^ DIN[12] ^ DIN[16] ^ DIN[21] ^ DIN[23] ^ DIN[24] ^ DIN[25] ^ DIN[26] ^ DIN[27] ^ DIN[30] ^ DIN[33] ^ DIN[37] ^ DIN[38] ^ DIN[39] ^ DIN[41] ^ DIN[42] ^ DIN[44] ^ DIN[45] ^ DIN[46] ^ DIN[49] ^ DIN[51] ^ DIN[52] ^ DIN[54] ^ DIN[56] ^ DIN[57] ^ DIN[58] ^ DIN[61] ^ DIN[62];
	srd[6] =  srq[1] ^ srq[5] ^ srq[6] ^ srq[7] ^ srq[9] ^ srq[10] ^ srq[12] ^ srq[13] ^ srq[14] ^ srq[17] ^ srq[19] ^ srq[20] ^ srq[22] ^ srq[24] ^ srq[25] ^ srq[26] ^ srq[29] ^ srq[30] ^ DIN[4] ^ DIN[6] ^ DIN[13] ^ DIN[17] ^ DIN[22] ^ DIN[24] ^ DIN[25] ^ DIN[26] ^ DIN[27] ^ DIN[28] ^ DIN[31] ^ DIN[34] ^ DIN[38] ^ DIN[39] ^ DIN[40] ^ DIN[42] ^ DIN[43] ^ DIN[45] ^ DIN[46] ^ DIN[47] ^ DIN[50] ^ DIN[52] ^ DIN[53] ^ DIN[55] ^ DIN[57] ^ DIN[58] ^ DIN[59] ^ DIN[62] ^ DIN[63];
	srd[7] =  srq[2] ^ srq[6] ^ srq[7] ^ srq[8] ^ srq[10] ^ srq[11] ^ srq[13] ^ srq[14] ^ srq[15] ^ srq[18] ^ srq[20] ^ srq[21] ^ srq[23] ^ srq[25] ^ srq[26] ^ srq[27] ^ srq[30] ^ srq[31] ^ DIN[5] ^ DIN[7] ^ DIN[14] ^ DIN[18] ^ DIN[23] ^ DIN[25] ^ DIN[26] ^ DIN[27] ^ DIN[28] ^ DIN[29] ^ DIN[32] ^ DIN[35] ^ DIN[39] ^ DIN[40] ^ DIN[41] ^ DIN[43] ^ DIN[44] ^ DIN[46] ^ DIN[47] ^ DIN[48] ^ DIN[51] ^ DIN[53] ^ DIN[54] ^ DIN[56] ^ DIN[58] ^ DIN[59] ^ DIN[60] ^ DIN[63] ^ DIN[64];
	srd[8] =  srq[0] ^ srq[3] ^ srq[7] ^ srq[8] ^ srq[9] ^ srq[11] ^ srq[12] ^ srq[14] ^ srq[15] ^ srq[16] ^ srq[19] ^ srq[21] ^ srq[22] ^ srq[24] ^ srq[26] ^ srq[27] ^ srq[28] ^ srq[31] ^ DIN[6] ^ DIN[8] ^ DIN[15] ^ DIN[19] ^ DIN[24] ^ DIN[26] ^ DIN[27] ^ DIN[28] ^ DIN[29] ^ DIN[30] ^ DIN[33] ^ DIN[36] ^ DIN[40] ^ DIN[41] ^ DIN[42] ^ DIN[44] ^ DIN[45] ^ DIN[47] ^ DIN[48] ^ DIN[49] ^ DIN[52] ^ DIN[54] ^ DIN[55] ^ DIN[57] ^ DIN[59] ^ DIN[60] ^ DIN[61] ^ DIN[64];
	srd[9] =  srq[1] ^ srq[4] ^ srq[8] ^ srq[9] ^ srq[10] ^ srq[12] ^ srq[13] ^ srq[15] ^ srq[16] ^ srq[17] ^ srq[20] ^ srq[22] ^ srq[23] ^ srq[25] ^ srq[27] ^ srq[28] ^ srq[29] ^ DIN[7] ^ DIN[9] ^ DIN[16] ^ DIN[20] ^ DIN[25] ^ DIN[27] ^ DIN[28] ^ DIN[29] ^ DIN[30] ^ DIN[31] ^ DIN[34] ^ DIN[37] ^ DIN[41] ^ DIN[42] ^ DIN[43] ^ DIN[45] ^ DIN[46] ^ DIN[48] ^ DIN[49] ^ DIN[50] ^ DIN[53] ^ DIN[55] ^ DIN[56] ^ DIN[58] ^ DIN[60] ^ DIN[61] ^ DIN[62];
	srd[10]    =  srq[2] ^ srq[5] ^ srq[9] ^ srq[10] ^ srq[11] ^ srq[13] ^ srq[14] ^ srq[16] ^ srq[17] ^ srq[18] ^ srq[21] ^ srq[23] ^ srq[24] ^ srq[26] ^ srq[28] ^ srq[29] ^ srq[30] ^ DIN[8] ^ DIN[10] ^ DIN[17] ^ DIN[21] ^ DIN[26] ^ DIN[28] ^ DIN[29] ^ DIN[30] ^ DIN[31] ^ DIN[32] ^ DIN[35] ^ DIN[38] ^ DIN[42] ^ DIN[43] ^ DIN[44] ^ DIN[46] ^ DIN[47] ^ DIN[49] ^ DIN[50] ^ DIN[51] ^ DIN[54] ^ DIN[56] ^ DIN[57] ^ DIN[59] ^ DIN[61] ^ DIN[62] ^ DIN[63];
	srd[11]    =  srq[9] ^ srq[30] ^ DIN[0] ^ DIN[21] ^ DIN[42] ^ DIN[63];
	srd[12]    =  srq[10] ^ srq[31] ^ DIN[1] ^ DIN[22] ^ DIN[43] ^ DIN[64];
	srd[13]    =  srq[11] ^ DIN[2] ^ DIN[23] ^ DIN[44];
	srd[14]    =  srq[12] ^ DIN[3] ^ DIN[24] ^ DIN[45];
	srd[15]    =  srq[13] ^ DIN[4] ^ DIN[25] ^ DIN[46];
	srd[16]    =  srq[14] ^ DIN[5] ^ DIN[26] ^ DIN[47];
	srd[17]    =  srq[15] ^ DIN[6] ^ DIN[27] ^ DIN[48];
	srd[18]    =  srq[16] ^ DIN[7] ^ DIN[28] ^ DIN[49];
	srd[19]    =  srq[17] ^ DIN[8] ^ DIN[29] ^ DIN[50];
	srd[20]    =  srq[18] ^ DIN[9] ^ DIN[30] ^ DIN[51];
	srd[21]    =  srq[0] ^ srq[3] ^ srq[6] ^ srq[9] ^ srq[10] ^ srq[11] ^ srq[12] ^ srq[14] ^ srq[15] ^ srq[17] ^ srq[18] ^ srq[22] ^ srq[24] ^ srq[25] ^ srq[27] ^ srq[29] ^ srq[31] ^ DIN[0] ^ DIN[9] ^ DIN[10] ^ DIN[11] ^ DIN[18] ^ DIN[21] ^ DIN[22] ^ DIN[27] ^ DIN[29] ^ DIN[30] ^ DIN[32] ^ DIN[33] ^ DIN[36] ^ DIN[39] ^ DIN[42] ^ DIN[43] ^ DIN[44] ^ DIN[45] ^ DIN[47] ^ DIN[48] ^ DIN[50] ^ DIN[51] ^ DIN[55] ^ DIN[57] ^ DIN[58] ^ DIN[60] ^ DIN[62] ^ DIN[64];
	srd[22]    =  srq[0] ^ srq[1] ^ srq[4] ^ srq[7] ^ srq[10] ^ srq[11] ^ srq[12] ^ srq[13] ^ srq[15] ^ srq[16] ^ srq[18] ^ srq[19] ^ srq[23] ^ srq[25] ^ srq[26] ^ srq[28] ^ srq[30] ^ DIN[1] ^ DIN[10] ^ DIN[11] ^ DIN[12] ^ DIN[19] ^ DIN[22] ^ DIN[23] ^ DIN[28] ^ DIN[30] ^ DIN[31] ^ DIN[33] ^ DIN[34] ^ DIN[37] ^ DIN[40] ^ DIN[43] ^ DIN[44] ^ DIN[45] ^ DIN[46] ^ DIN[48] ^ DIN[49] ^ DIN[51] ^ DIN[52] ^ DIN[56] ^ DIN[58] ^ DIN[59] ^ DIN[61] ^ DIN[63];
	srd[23]    =  srq[0] ^ srq[1] ^ srq[2] ^ srq[3] ^ srq[5] ^ srq[6] ^ srq[8] ^ srq[9] ^ srq[10] ^ srq[13] ^ srq[15] ^ srq[16] ^ srq[18] ^ srq[20] ^ srq[22] ^ srq[25] ^ srq[26] ^ DIN[0] ^ DIN[2] ^ DIN[9] ^ DIN[12] ^ DIN[13] ^ DIN[18] ^ DIN[20] ^ DIN[21] ^ DIN[22] ^ DIN[23] ^ DIN[24] ^ DIN[27] ^ DIN[30] ^ DIN[33] ^ DIN[34] ^ DIN[35] ^ DIN[36] ^ DIN[38] ^ DIN[39] ^ DIN[41] ^ DIN[42] ^ DIN[43] ^ DIN[46] ^ DIN[48] ^ DIN[49] ^ DIN[51] ^ DIN[53] ^ DIN[55] ^ DIN[58] ^ DIN[59];
	srd[24]    =  srq[1] ^ srq[2] ^ srq[3] ^ srq[4] ^ srq[6] ^ srq[7] ^ srq[9] ^ srq[10] ^ srq[11] ^ srq[14] ^ srq[16] ^ srq[17] ^ srq[19] ^ srq[21] ^ srq[23] ^ srq[26] ^ srq[27] ^ DIN[1] ^ DIN[3] ^ DIN[10] ^ DIN[13] ^ DIN[14] ^ DIN[19] ^ DIN[21] ^ DIN[22] ^ DIN[23] ^ DIN[24] ^ DIN[25] ^ DIN[28] ^ DIN[31] ^ DIN[34] ^ DIN[35] ^ DIN[36] ^ DIN[37] ^ DIN[39] ^ DIN[40] ^ DIN[42] ^ DIN[43] ^ DIN[44] ^ DIN[47] ^ DIN[49] ^ DIN[50] ^ DIN[52] ^ DIN[54] ^ DIN[56] ^ DIN[59] ^ DIN[60];
	srd[25]    =  srq[2] ^ srq[3] ^ srq[4] ^ srq[5] ^ srq[7] ^ srq[8] ^ srq[10] ^ srq[11] ^ srq[12] ^ srq[15] ^ srq[17] ^ srq[18] ^ srq[20] ^ srq[22] ^ srq[24] ^ srq[27] ^ srq[28] ^ DIN[2] ^ DIN[4] ^ DIN[11] ^ DIN[14] ^ DIN[15] ^ DIN[20] ^ DIN[22] ^ DIN[23] ^ DIN[24] ^ DIN[25] ^ DIN[26] ^ DIN[29] ^ DIN[32] ^ DIN[35] ^ DIN[36] ^ DIN[37] ^ DIN[38] ^ DIN[40] ^ DIN[41] ^ DIN[43] ^ DIN[44] ^ DIN[45] ^ DIN[48] ^ DIN[50] ^ DIN[51] ^ DIN[53] ^ DIN[55] ^ DIN[57] ^ DIN[60] ^ DIN[61];
	srd[26]    =  srq[0] ^ srq[3] ^ srq[4] ^ srq[5] ^ srq[6] ^ srq[8] ^ srq[9] ^ srq[11] ^ srq[12] ^ srq[13] ^ srq[16] ^ srq[18] ^ srq[19] ^ srq[21] ^ srq[23] ^ srq[25] ^ srq[28] ^ srq[29] ^ DIN[3] ^ DIN[5] ^ DIN[12] ^ DIN[15] ^ DIN[16] ^ DIN[21] ^ DIN[23] ^ DIN[24] ^ DIN[25] ^ DIN[26] ^ DIN[27] ^ DIN[30] ^ DIN[33] ^ DIN[36] ^ DIN[37] ^ DIN[38] ^ DIN[39] ^ DIN[41] ^ DIN[42] ^ DIN[44] ^ DIN[45] ^ DIN[46] ^ DIN[49] ^ DIN[51] ^ DIN[52] ^ DIN[54] ^ DIN[56] ^ DIN[58] ^ DIN[61] ^ DIN[62];
	srd[27]    =  srq[1] ^ srq[4] ^ srq[5] ^ srq[6] ^ srq[7] ^ srq[9] ^ srq[10] ^ srq[12] ^ srq[13] ^ srq[14] ^ srq[17] ^ srq[19] ^ srq[20] ^ srq[22] ^ srq[24] ^ srq[26] ^ srq[29] ^ srq[30] ^ DIN[4] ^ DIN[6] ^ DIN[13] ^ DIN[16] ^ DIN[17] ^ DIN[22] ^ DIN[24] ^ DIN[25] ^ DIN[26] ^ DIN[27] ^ DIN[28] ^ DIN[31] ^ DIN[34] ^ DIN[37] ^ DIN[38] ^ DIN[39] ^ DIN[40] ^ DIN[42] ^ DIN[43] ^ DIN[45] ^ DIN[46] ^ DIN[47] ^ DIN[50] ^ DIN[52] ^ DIN[53] ^ DIN[55] ^ DIN[57] ^ DIN[59] ^ DIN[62] ^ DIN[63];
	srd[28]    =  srq[2] ^ srq[5] ^ srq[6] ^ srq[7] ^ srq[8] ^ srq[10] ^ srq[11] ^ srq[13] ^ srq[14] ^ srq[15] ^ srq[18] ^ srq[20] ^ srq[21] ^ srq[23] ^ srq[25] ^ srq[27] ^ srq[30] ^ srq[31] ^ DIN[5] ^ DIN[7] ^ DIN[14] ^ DIN[17] ^ DIN[18] ^ DIN[23] ^ DIN[25] ^ DIN[26] ^ DIN[27] ^ DIN[28] ^ DIN[29] ^ DIN[32] ^ DIN[35] ^ DIN[38] ^ DIN[39] ^ DIN[40] ^ DIN[41] ^ DIN[43] ^ DIN[44] ^ DIN[46] ^ DIN[47] ^ DIN[48] ^ DIN[51] ^ DIN[53] ^ DIN[54] ^ DIN[56] ^ DIN[58] ^ DIN[60] ^ DIN[63] ^ DIN[64];
	srd[29]    =  srq[0] ^ srq[3] ^ srq[6] ^ srq[7] ^ srq[8] ^ srq[9] ^ srq[11] ^ srq[12] ^ srq[14] ^ srq[15] ^ srq[16] ^ srq[19] ^ srq[21] ^ srq[22] ^ srq[24] ^ srq[26] ^ srq[28] ^ srq[31] ^ DIN[6] ^ DIN[8] ^ DIN[15] ^ DIN[18] ^ DIN[19] ^ DIN[24] ^ DIN[26] ^ DIN[27] ^ DIN[28] ^ DIN[29] ^ DIN[30] ^ DIN[33] ^ DIN[36] ^ DIN[39] ^ DIN[40] ^ DIN[41] ^ DIN[42] ^ DIN[44] ^ DIN[45] ^ DIN[47] ^ DIN[48] ^ DIN[49] ^ DIN[52] ^ DIN[54] ^ DIN[55] ^ DIN[57] ^ DIN[59] ^ DIN[61] ^ DIN[64];
	srd[30]    =  srq[1] ^ srq[4] ^ srq[7] ^ srq[8] ^ srq[9] ^ srq[10] ^ srq[12] ^ srq[13] ^ srq[15] ^ srq[16] ^ srq[17] ^ srq[20] ^ srq[22] ^ srq[23] ^ srq[25] ^ srq[27] ^ srq[29] ^ DIN[7] ^ DIN[9] ^ DIN[16] ^ DIN[19] ^ DIN[20] ^ DIN[25] ^ DIN[27] ^ DIN[28] ^ DIN[29] ^ DIN[30] ^ DIN[31] ^ DIN[34] ^ DIN[37] ^ DIN[40] ^ DIN[41] ^ DIN[42] ^ DIN[43] ^ DIN[45] ^ DIN[46] ^ DIN[48] ^ DIN[49] ^ DIN[50] ^ DIN[53] ^ DIN[55] ^ DIN[56] ^ DIN[58] ^ DIN[60] ^ DIN[62];
	srd[31]    =  srq[2] ^ srq[5] ^ srq[8] ^ srq[9] ^ srq[10] ^ srq[11] ^ srq[13] ^ srq[14] ^ srq[16] ^ srq[17] ^ srq[18] ^ srq[21] ^ srq[23] ^ srq[24] ^ srq[26] ^ srq[28] ^ srq[30] ^ DIN[8] ^ DIN[10] ^ DIN[17] ^ DIN[20] ^ DIN[21] ^ DIN[26] ^ DIN[28] ^ DIN[29] ^ DIN[30] ^ DIN[31] ^ DIN[32] ^ DIN[35] ^ DIN[38] ^ DIN[41] ^ DIN[42] ^ DIN[43] ^ DIN[44] ^ DIN[46] ^ DIN[47] ^ DIN[49] ^ DIN[50] ^ DIN[51] ^ DIN[54] ^ DIN[56] ^ DIN[57] ^ DIN[59] ^ DIN[61] ^ DIN[63];
	
	
end

always @(posedge CLK)
if(RST || !ENA)
	srq  <= {32{1'b0}};
else
	srq  <= srd;

endmodule
