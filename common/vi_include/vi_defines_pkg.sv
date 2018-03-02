/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author: jaedon.kim $
* $Date: 2013-07-18 10:19:25 -0700 (Thu, 18 Jul 2013) $
* $Revision: 2862 $
* $HeadURL$
***********************************************************************************************************/

package vi_defines_pkg;

// ------------
// 10b symbols
// ------------
// These 10b symbols were taken from Altera's Stratix GX Device Handbook and formatted using emacs macros
// Note the endianess is little-endian (abcdei_fghj).  Generally, incoming symbols need to be bit reveresed
// to match these defines. 

// control symbols - RD negative, abcdei_fghj
localparam  K28_0_N           = 10'b001111_0100;
localparam  K28_1_N           = 10'b001111_1001;
localparam  K28_2_N           = 10'b001111_0101;
localparam  K28_3_N           = 10'b001111_0011;
localparam  K28_4_N           = 10'b001111_0010;
localparam  K28_5_N           = 10'b001111_1010;
localparam  K28_6_N           = 10'b001111_0110;
localparam  K28_7_N           = 10'b001111_1000;
localparam  K23_7_N           = 10'b111010_1000;
localparam  K27_7_N           = 10'b110110_1000;
localparam  K29_7_N           = 10'b101110_1000;
localparam  K30_7_N           = 10'b011110_1000;

// control symbols - RD positive, abcdei_fghj
localparam  K28_0_P           = 10'b110000_1011;
localparam  K28_1_P           = 10'b110000_0110;
localparam  K28_2_P           = 10'b110000_1010;
localparam  K28_3_P           = 10'b110000_1100;
localparam  K28_4_P           = 10'b110000_1101;
localparam  K28_5_P           = 10'b110000_0101;
localparam  K28_6_P           = 10'b110000_1001;
localparam  K28_7_P           = 10'b110000_0111;
localparam  K23_7_P           = 10'b000101_0111;
localparam  K27_7_P           = 10'b001001_0111;
localparam  K29_7_P           = 10'b010001_0111;
localparam  K30_7_P           = 10'b100001_0111;

// data symbols - RD negative, abcdei_fghj
localparam  D0_0_N            = 10'b100111_0100;
localparam  D1_0_N            = 10'b011101_0100;
localparam  D2_0_N            = 10'b101101_0100;
localparam  D3_0_N            = 10'b110001_1011;
localparam  D4_0_N            = 10'b110101_0100;
localparam  D5_0_N            = 10'b101001_1011;
localparam  D6_0_N            = 10'b011001_1011;
localparam  D7_0_N            = 10'b111000_1011;
localparam  D8_0_N            = 10'b111001_0100;
localparam  D9_0_N            = 10'b100101_1011;
localparam  D10_0_N           = 10'b010101_1011;
localparam  D11_0_N           = 10'b110100_1011;
localparam  D12_0_N           = 10'b001101_1011;
localparam  D13_0_N           = 10'b101100_1011;
localparam  D14_0_N           = 10'b011100_1011;
localparam  D15_0_N           = 10'b010111_0100;
localparam  D16_0_N           = 10'b011011_0100;
localparam  D17_0_N           = 10'b100011_1011;
localparam  D18_0_N           = 10'b010011_1011;
localparam  D19_0_N           = 10'b110010_1011;
localparam  D20_0_N           = 10'b001011_1011;
localparam  D21_0_N           = 10'b101010_1011;
localparam  D22_0_N           = 10'b011010_1011;
localparam  D23_0_N           = 10'b111010_0100;
localparam  D24_0_N           = 10'b110011_0100;
localparam  D25_0_N           = 10'b100110_1011;
localparam  D26_0_N           = 10'b010110_1011;
localparam  D27_0_N           = 10'b110110_0100;
localparam  D28_0_N           = 10'b001110_1011;
localparam  D29_0_N           = 10'b101110_0100;
localparam  D30_0_N           = 10'b011110_0100;
localparam  D31_0_N           = 10'b101011_0100;

// data symbols - RD negative, abcdei_fghj
localparam  D0_1_N            = 10'b100111_1001;
localparam  D1_1_N            = 10'b011101_1001;
localparam  D2_1_N            = 10'b101101_1001;
localparam  D3_1_N            = 10'b110001_1001;
localparam  D4_1_N            = 10'b110101_1001;
localparam  D5_1_N            = 10'b101001_1001;
localparam  D6_1_N            = 10'b011001_1001;
localparam  D7_1_N            = 10'b111000_1001;
localparam  D8_1_N            = 10'b111001_1001;
localparam  D9_1_N            = 10'b100101_1001;
localparam  D10_1_N           = 10'b010101_1001;
localparam  D11_1_N           = 10'b110100_1001;
localparam  D12_1_N           = 10'b001101_1001;
localparam  D13_1_N           = 10'b101100_1001;
localparam  D14_1_N           = 10'b011100_1001;
localparam  D15_1_N           = 10'b010111_1001;
localparam  D16_1_N           = 10'b011011_1001;
localparam  D17_1_N           = 10'b100011_1001;
localparam  D18_1_N           = 10'b010011_1001;
localparam  D19_1_N           = 10'b110010_1001;
localparam  D20_1_N           = 10'b001011_1001;
localparam  D21_1_N           = 10'b101010_1001;
localparam  D22_1_N           = 10'b011010_1001;
localparam  D23_1_N           = 10'b111010_1001;
localparam  D24_1_N           = 10'b110011_1001;
localparam  D25_1_N           = 10'b100110_1001;
localparam  D26_1_N           = 10'b010110_1001;
localparam  D27_1_N           = 10'b110110_1001;
localparam  D28_1_N           = 10'b001110_1001;
localparam  D29_1_N           = 10'b101110_1001;
localparam  D30_1_N           = 10'b011110_1001;
localparam  D31_1_N           = 10'b101011_1001;

// data symbols - RD negative, abcdei_fghj
localparam  D0_2_N            = 10'b100111_0101;
localparam  D1_2_N            = 10'b011101_0101;
localparam  D2_2_N            = 10'b101101_0101;
localparam  D3_2_N            = 10'b110001_0101;
localparam  D4_2_N            = 10'b110101_0101;
localparam  D5_2_N            = 10'b101001_0101;
localparam  D6_2_N            = 10'b011001_0101;
localparam  D7_2_N            = 10'b111000_0101;
localparam  D8_2_N            = 10'b111001_0101;
localparam  D9_2_N            = 10'b100101_0101;
localparam  D10_2_N           = 10'b010101_0101;
localparam  D11_2_N           = 10'b110100_0101;
localparam  D12_2_N           = 10'b001101_0101;
localparam  D13_2_N           = 10'b101100_0101;
localparam  D14_2_N           = 10'b011100_0101;
localparam  D15_2_N           = 10'b010111_0101;
localparam  D16_2_N           = 10'b011011_0101;
localparam  D17_2_N           = 10'b100011_0101;
localparam  D18_2_N           = 10'b010011_0101;
localparam  D19_2_N           = 10'b110010_0101;
localparam  D20_2_N           = 10'b001011_0101;
localparam  D21_2_N           = 10'b101010_0101;
localparam  D22_2_N           = 10'b011010_0101;
localparam  D23_2_N           = 10'b111010_0101;
localparam  D24_2_N           = 10'b110011_0101;
localparam  D25_2_N           = 10'b100110_0101;
localparam  D26_2_N           = 10'b010110_0101;
localparam  D27_2_N           = 10'b110110_0101;
localparam  D28_2_N           = 10'b001110_0101;
localparam  D29_2_N           = 10'b101110_0101;
localparam  D30_2_N           = 10'b011110_0101;
localparam  D31_2_N           = 10'b101011_0101;

localparam  D0_3_N            = 10'b100111_0011;
localparam  D1_3_N            = 10'b011101_0011;
localparam  D2_3_N            = 10'b101101_0011;
localparam  D3_3_N            = 10'b110001_1100;
localparam  D4_3_N            = 10'b110101_0011;
localparam  D5_3_N            = 10'b101001_1100;
localparam  D6_3_N            = 10'b011001_1100;
localparam  D7_3_N            = 10'b111000_1100;
localparam  D8_3_N            = 10'b111001_0011;
localparam  D9_3_N            = 10'b100101_1100;
localparam  D10_3_N           = 10'b010101_1100;
localparam  D11_3_N           = 10'b110100_1100;
localparam  D12_3_N           = 10'b001101_1100;
localparam  D13_3_N           = 10'b101100_1100;
localparam  D14_3_N           = 10'b011100_1100;
localparam  D15_3_N           = 10'b010111_0011;
localparam  D16_3_N           = 10'b011011_0011;
localparam  D17_3_N           = 10'b100011_1100;
localparam  D18_3_N           = 10'b010011_1100;
localparam  D19_3_N           = 10'b110010_1100;
localparam  D20_3_N           = 10'b001011_1100;
localparam  D21_3_N           = 10'b101010_1100;
localparam  D22_3_N           = 10'b011010_1100;
localparam  D23_3_N           = 10'b111010_0011;
localparam  D24_3_N           = 10'b110011_0011;
localparam  D25_3_N           = 10'b100110_1100;
localparam  D26_3_N           = 10'b010110_1100;
localparam  D27_3_N           = 10'b110110_0011;
localparam  D28_3_N           = 10'b001110_1100;
localparam  D29_3_N           = 10'b101110_0011;
localparam  D30_3_N           = 10'b011110_0011;
localparam  D31_3_N           = 10'b101011_0011;

// data symbols - RD negative, abcdei_fghj
localparam  D0_4_N            = 10'b100111_0010;
localparam  D1_4_N            = 10'b011101_0010;
localparam  D2_4_N            = 10'b101101_0010;
localparam  D3_4_N            = 10'b110001_1101;
localparam  D4_4_N            = 10'b110101_0010;
localparam  D5_4_N            = 10'b101001_1101;
localparam  D6_4_N            = 10'b011001_1101;
localparam  D7_4_N            = 10'b111000_1101;
localparam  D8_4_N            = 10'b111001_0010;
localparam  D9_4_N            = 10'b100101_1101;
localparam  D10_4_N           = 10'b010101_1101;
localparam  D11_4_N           = 10'b110100_1101;
localparam  D12_4_N           = 10'b001101_1101;
localparam  D13_4_N           = 10'b101100_1101;
localparam  D14_4_N           = 10'b011100_1101;
localparam  D15_4_N           = 10'b010111_0010;
localparam  D16_4_N           = 10'b011011_0010;
localparam  D17_4_N           = 10'b100011_1101;
localparam  D18_4_N           = 10'b010011_1101;
localparam  D19_4_N           = 10'b110010_1101;
localparam  D20_4_N           = 10'b001011_1101;
localparam  D21_4_N           = 10'b101010_1101;
localparam  D22_4_N           = 10'b011010_1101;
localparam  D23_4_N           = 10'b111010_0010;
localparam  D24_4_N           = 10'b110011_0010;
localparam  D25_4_N           = 10'b100110_1101;
localparam  D26_4_N           = 10'b010110_1101;
localparam  D27_4_N           = 10'b110110_0010;
localparam  D28_4_N           = 10'b001110_1101;
localparam  D29_4_N           = 10'b101110_0010;
localparam  D30_4_N           = 10'b011110_0010;
localparam  D31_4_N           = 10'b101011_0010;

// data symbols - RD negative, abcdei_fghj
localparam  D0_5_N            = 10'b100111_1010;
localparam  D1_5_N            = 10'b011101_1010;
localparam  D2_5_N            = 10'b101101_1010;
localparam  D3_5_N            = 10'b110001_1010;
localparam  D4_5_N            = 10'b110101_1010;
localparam  D5_5_N            = 10'b101001_1010;
localparam  D6_5_N            = 10'b011001_1010;
localparam  D7_5_N            = 10'b111000_1010;
localparam  D8_5_N            = 10'b111001_1010;
localparam  D9_5_N            = 10'b100101_1010;
localparam  D10_5_N           = 10'b010101_1010;
localparam  D11_5_N           = 10'b110100_1010;
localparam  D12_5_N           = 10'b001101_1010;
localparam  D13_5_N           = 10'b101100_1010;
localparam  D14_5_N           = 10'b011100_1010;
localparam  D15_5_N           = 10'b010111_1010;
localparam  D16_5_N           = 10'b011011_1010;
localparam  D17_5_N           = 10'b100011_1010;
localparam  D18_5_N           = 10'b010011_1010;
localparam  D19_5_N           = 10'b110010_1010;
localparam  D20_5_N           = 10'b001011_1010;
localparam  D21_5_N           = 10'b101010_1010;
localparam  D22_5_N           = 10'b011010_1010;
localparam  D23_5_N           = 10'b111010_1010;
localparam  D24_5_N           = 10'b110011_1010;
localparam  D25_5_N           = 10'b100110_1010;
localparam  D26_5_N           = 10'b010110_1010;
localparam  D27_5_N           = 10'b110110_1010;
localparam  D28_5_N           = 10'b001110_1010;
localparam  D29_5_N           = 10'b101110_1010;
localparam  D30_5_N           = 10'b011110_1010;
localparam  D31_5_N           = 10'b101011_1010;

// data symbols - RD negative, abcdei_fghj
localparam  D0_6_N            = 10'b100111_0110;
localparam  D1_6_N            = 10'b011101_0110;
localparam  D2_6_N            = 10'b101101_0110;
localparam  D3_6_N            = 10'b110001_0110;
localparam  D4_6_N            = 10'b110101_0110;
localparam  D5_6_N            = 10'b101001_0110;
localparam  D6_6_N            = 10'b011001_0110;
localparam  D7_6_N            = 10'b111000_0110;
localparam  D8_6_N            = 10'b111001_0110;
localparam  D9_6_N            = 10'b100101_0110;
localparam  D10_6_N           = 10'b010101_0110;
localparam  D11_6_N           = 10'b110100_0110;
localparam  D12_6_N           = 10'b001101_0110;
localparam  D13_6_N           = 10'b101100_0110;
localparam  D14_6_N           = 10'b011100_0110;
localparam  D15_6_N           = 10'b010111_0110;
localparam  D16_6_N           = 10'b011011_0110;
localparam  D17_6_N           = 10'b100011_0110;
localparam  D18_6_N           = 10'b010011_0110;
localparam  D19_6_N           = 10'b110010_0110;
localparam  D20_6_N           = 10'b001011_0110;
localparam  D21_6_N           = 10'b101010_0110;
localparam  D22_6_N           = 10'b011010_0110;
localparam  D23_6_N           = 10'b111010_0110;
localparam  D24_6_N           = 10'b110011_0110;
localparam  D25_6_N           = 10'b100110_0110;
localparam  D26_6_N           = 10'b010110_0110;
localparam  D27_6_N           = 10'b110110_0110;
localparam  D28_6_N           = 10'b001110_0110;
localparam  D29_6_N           = 10'b101110_0110;
localparam  D30_6_N           = 10'b011110_0110;
localparam  D31_6_N           = 10'b101011_0110;

// data symbols - RD negative, abcdei_fghj
localparam  D0_7_N            = 10'b100111_0001;
localparam  D1_7_N            = 10'b011101_0001;
localparam  D2_7_N            = 10'b101101_0001;
localparam  D3_7_N            = 10'b110001_1110;
localparam  D4_7_N            = 10'b110101_0001;
localparam  D5_7_N            = 10'b101001_1110;
localparam  D6_7_N            = 10'b011001_1110;
localparam  D7_7_N            = 10'b111000_1110;
localparam  D8_7_N            = 10'b111001_0001;
localparam  D9_7_N            = 10'b100101_1110;
localparam  D10_7_N           = 10'b010101_1110;
localparam  D11_7_N           = 10'b110100_1110;
localparam  D12_7_N           = 10'b001101_1110;
localparam  D13_7_N           = 10'b101100_1110;
localparam  D14_7_N           = 10'b011100_1110;
localparam  D15_7_N           = 10'b010111_0001;
localparam  D16_7_N           = 10'b011011_0001;
localparam  D17_7_N           = 10'b100011_0111;
localparam  D18_7_N           = 10'b010011_0111;
localparam  D19_7_N           = 10'b110010_1110;
localparam  D20_7_N           = 10'b001011_0111;
localparam  D21_7_N           = 10'b101010_1110;
localparam  D22_7_N           = 10'b011010_1110;
localparam  D23_7_N           = 10'b111010_0001;
localparam  D24_7_N           = 10'b110011_0001;
localparam  D25_7_N           = 10'b100110_1110;
localparam  D26_7_N           = 10'b010110_1110;
localparam  D27_7_N           = 10'b110110_0001;
localparam  D28_7_N           = 10'b001110_1110;
localparam  D29_7_N           = 10'b101110_0001;
localparam  D30_7_N           = 10'b011110_0001;
localparam  D31_7_N           = 10'b101011_0001;

// data symbols - RD positive, abcdei_fghj
localparam  D0_0_P            = 10'b011000_1011;
localparam  D1_0_P            = 10'b100010_1011;
localparam  D2_0_P            = 10'b010010_1011;
localparam  D3_0_P            = 10'b110001_0100;
localparam  D4_0_P            = 10'b001010_1011;
localparam  D5_0_P            = 10'b101001_0100;
localparam  D6_0_P            = 10'b011001_0100;
localparam  D7_0_P            = 10'b000111_0100;
localparam  D8_0_P            = 10'b000110_1011;
localparam  D9_0_P            = 10'b100101_0100;
localparam  D10_0_P           = 10'b010101_0100;
localparam  D11_0_P           = 10'b110100_0100;
localparam  D12_0_P           = 10'b001101_0100;
localparam  D13_0_P           = 10'b101100_0100;
localparam  D14_0_P           = 10'b011100_0100;
localparam  D15_0_P           = 10'b101000_1011;
localparam  D16_0_P           = 10'b100100_1011;
localparam  D17_0_P           = 10'b100011_0100;
localparam  D18_0_P           = 10'b010011_0100;
localparam  D19_0_P           = 10'b110010_0100;
localparam  D20_0_P           = 10'b001011_0100;
localparam  D21_0_P           = 10'b101010_0100;
localparam  D22_0_P           = 10'b011010_0100;
localparam  D23_0_P           = 10'b000101_1011;
localparam  D24_0_P           = 10'b001100_1011;
localparam  D25_0_P           = 10'b100110_0100;
localparam  D26_0_P           = 10'b010110_0100;
localparam  D27_0_P           = 10'b001001_1011;
localparam  D28_0_P           = 10'b001110_0100;
localparam  D29_0_P           = 10'b010001_1011;
localparam  D30_0_P           = 10'b100001_1011;
localparam  D31_0_P           = 10'b010100_1011;

// data symbols - RD positive, abcdei_fghj
localparam  D0_1_P            = 10'b011000_1001;
localparam  D1_1_P            = 10'b100010_1001;
localparam  D2_1_P            = 10'b010010_1001;
localparam  D3_1_P            = 10'b110001_1001;
localparam  D4_1_P            = 10'b001010_1001;
localparam  D5_1_P            = 10'b101001_1001;
localparam  D6_1_P            = 10'b011001_1001;
localparam  D7_1_P            = 10'b000111_1001;
localparam  D8_1_P            = 10'b000110_1001;
localparam  D9_1_P            = 10'b100101_1001;
localparam  D10_1_P           = 10'b010101_1001;
localparam  D11_1_P           = 10'b110100_1001;
localparam  D12_1_P           = 10'b001101_1001;
localparam  D13_1_P           = 10'b101100_1001;
localparam  D14_1_P           = 10'b011100_1001;
localparam  D15_1_P           = 10'b101000_1001;
localparam  D16_1_P           = 10'b100100_1001;
localparam  D17_1_P           = 10'b100011_1001;
localparam  D18_1_P           = 10'b010011_1001;
localparam  D19_1_P           = 10'b110010_1001;
localparam  D20_1_P           = 10'b001011_1001;
localparam  D21_1_P           = 10'b101010_1001;
localparam  D22_1_P           = 10'b011010_1001;
localparam  D23_1_P           = 10'b000101_1001;
localparam  D24_1_P           = 10'b001100_1001;
localparam  D25_1_P           = 10'b100110_1001;
localparam  D26_1_P           = 10'b010110_1001;
localparam  D27_1_P           = 10'b001001_1001;
localparam  D28_1_P           = 10'b001110_1001;
localparam  D29_1_P           = 10'b010001_1001;
localparam  D30_1_P           = 10'b100001_1001;
localparam  D31_1_P           = 10'b010100_1001;

// data symbols - RD positive, abcdei_fghj
localparam  D0_2_P            = 10'b011000_0101;
localparam  D1_2_P            = 10'b100010_0101;
localparam  D2_2_P            = 10'b010010_0101;
localparam  D3_2_P            = 10'b110001_0101;
localparam  D4_2_P            = 10'b001010_0101;
localparam  D5_2_P            = 10'b101001_0101;
localparam  D6_2_P            = 10'b011001_0101;
localparam  D7_2_P            = 10'b000111_0101;
localparam  D8_2_P            = 10'b000110_0101;
localparam  D9_2_P            = 10'b100101_0101;
localparam  D10_2_P           = 10'b010101_0101;
localparam  D11_2_P           = 10'b110100_0101;
localparam  D12_2_P           = 10'b001101_0101;
localparam  D13_2_P           = 10'b101100_0101;
localparam  D14_2_P           = 10'b011100_0101;
localparam  D15_2_P           = 10'b101000_0101;
localparam  D16_2_P           = 10'b100100_0101;
localparam  D17_2_P           = 10'b100011_0101;
localparam  D18_2_P           = 10'b010011_0101;
localparam  D19_2_P           = 10'b110010_0101;
localparam  D20_2_P           = 10'b001011_0101;
localparam  D21_2_P           = 10'b101010_0101;
localparam  D22_2_P           = 10'b011010_0101;
localparam  D23_2_P           = 10'b000101_0101;
localparam  D24_2_P           = 10'b001100_0101;
localparam  D25_2_P           = 10'b100110_0101;
localparam  D26_2_P           = 10'b010110_0101;
localparam  D27_2_P           = 10'b001001_0101;
localparam  D28_2_P           = 10'b001110_0101;
localparam  D29_2_P           = 10'b010001_0101;
localparam  D30_2_P           = 10'b100001_0101;
localparam  D31_2_P           = 10'b010100_0101;

// data symbols - RD positive, abcdei_fghj
localparam  D0_3_P            = 10'b011000_1100;
localparam  D1_3_P            = 10'b100010_1100;
localparam  D2_3_P            = 10'b010010_1100;
localparam  D3_3_P            = 10'b110001_0011;
localparam  D4_3_P            = 10'b001010_1100;
localparam  D5_3_P            = 10'b101001_0011;
localparam  D6_3_P            = 10'b011001_0011;
localparam  D7_3_P            = 10'b000111_0011;
localparam  D8_3_P            = 10'b000110_1100;
localparam  D9_3_P            = 10'b100101_0011;
localparam  D10_3_P           = 10'b010101_0011;
localparam  D11_3_P           = 10'b110100_0011;
localparam  D12_3_P           = 10'b001101_0011;
localparam  D13_3_P           = 10'b101100_0011;
localparam  D14_3_P           = 10'b011100_0011;
localparam  D15_3_P           = 10'b101000_1100;
localparam  D16_3_P           = 10'b100100_1100;
localparam  D17_3_P           = 10'b100011_0011;
localparam  D18_3_P           = 10'b010011_0011;
localparam  D19_3_P           = 10'b110010_0011;
localparam  D20_3_P           = 10'b001011_0011;
localparam  D21_3_P           = 10'b101010_0011;
localparam  D22_3_P           = 10'b011010_0011;
localparam  D23_3_P           = 10'b000101_1100;
localparam  D24_3_P           = 10'b001100_1100;
localparam  D25_3_P           = 10'b100110_0011;
localparam  D26_3_P           = 10'b010110_0011;
localparam  D27_3_P           = 10'b001001_1100;
localparam  D28_3_P           = 10'b001110_0011;
localparam  D29_3_P           = 10'b010001_1100;
localparam  D30_3_P           = 10'b100001_1100;
localparam  D31_3_P           = 10'b010100_1100;

// data symbols - RD positive, abcdei_fghj
localparam  D0_4_P            = 10'b011000_1101;
localparam  D1_4_P            = 10'b100010_1101;
localparam  D2_4_P            = 10'b010010_1101;
localparam  D3_4_P            = 10'b110001_0010;
localparam  D4_4_P            = 10'b001010_1101;
localparam  D5_4_P            = 10'b101001_0010;
localparam  D6_4_P            = 10'b011001_0010;
localparam  D7_4_P            = 10'b000111_0010;
localparam  D8_4_P            = 10'b000110_1101;
localparam  D9_4_P            = 10'b100101_0010;
localparam  D10_4_P           = 10'b010101_0010;
localparam  D11_4_P           = 10'b110100_0010;
localparam  D12_4_P           = 10'b001101_0010;
localparam  D13_4_P           = 10'b101100_0010;
localparam  D14_4_P           = 10'b011100_0010;
localparam  D15_4_P           = 10'b101000_1101;
localparam  D16_4_P           = 10'b100100_1101;
localparam  D17_4_P           = 10'b100011_0010;
localparam  D18_4_P           = 10'b010011_0010;
localparam  D19_4_P           = 10'b110010_0010;
localparam  D20_4_P           = 10'b001011_0010;
localparam  D21_4_P           = 10'b101010_0010;
localparam  D22_4_P           = 10'b011010_0010;
localparam  D23_4_P           = 10'b000101_1101;
localparam  D24_4_P           = 10'b001100_1101;
localparam  D25_4_P           = 10'b100110_0010;
localparam  D26_4_P           = 10'b010110_0010;
localparam  D27_4_P           = 10'b001001_1101;
localparam  D28_4_P           = 10'b001110_0010;
localparam  D29_4_P           = 10'b010001_1101;
localparam  D30_4_P           = 10'b100001_1101;
localparam  D31_4_P           = 10'b010100_1101;

// data symbols - RD positive, abcdei_fghj
localparam  D0_5_P            = 10'b011000_1010;
localparam  D1_5_P            = 10'b100010_1010;
localparam  D2_5_P            = 10'b010010_1010;
localparam  D3_5_P            = 10'b110001_1010;
localparam  D4_5_P            = 10'b001010_1010;
localparam  D5_5_P            = 10'b101001_1010;
localparam  D6_5_P            = 10'b011001_1010;
localparam  D7_5_P            = 10'b000111_1010;
localparam  D8_5_P            = 10'b000110_1010;
localparam  D9_5_P            = 10'b100101_1010;
localparam  D10_5_P           = 10'b010101_1010;
localparam  D11_5_P           = 10'b110100_1010;
localparam  D12_5_P           = 10'b001101_1010;
localparam  D13_5_P           = 10'b101100_1010;
localparam  D14_5_P           = 10'b011100_1010;
localparam  D15_5_P           = 10'b101000_1010;
localparam  D16_5_P           = 10'b100100_1010;
localparam  D17_5_P           = 10'b100011_1010;
localparam  D18_5_P           = 10'b010011_1010;
localparam  D19_5_P           = 10'b110010_1010;
localparam  D20_5_P           = 10'b001011_1010;
localparam  D21_5_P           = 10'b101010_1010;
localparam  D22_5_P           = 10'b011010_1010;
localparam  D23_5_P           = 10'b000101_1010;
localparam  D24_5_P           = 10'b001100_1010;
localparam  D25_5_P           = 10'b100110_1010;
localparam  D26_5_P           = 10'b010110_1010;
localparam  D27_5_P           = 10'b001001_1010;
localparam  D28_5_P           = 10'b001110_1010;
localparam  D29_5_P           = 10'b010001_1010;
localparam  D30_5_P           = 10'b100001_1010;
localparam  D31_5_P           = 10'b010100_1010;

// data symbols - RD positive, abcdei_fghj
localparam  D0_6_P            = 10'b011000_0110;
localparam  D1_6_P            = 10'b100010_0110;
localparam  D2_6_P            = 10'b010010_0110;
localparam  D3_6_P            = 10'b110001_0110;
localparam  D4_6_P            = 10'b001010_0110;
localparam  D5_6_P            = 10'b101001_0110;
localparam  D6_6_P            = 10'b011001_0110;
localparam  D7_6_P            = 10'b000111_0110;
localparam  D8_6_P            = 10'b000110_0110;
localparam  D9_6_P            = 10'b100101_0110;
localparam  D10_6_P           = 10'b010101_0110;
localparam  D11_6_P           = 10'b110100_0110;
localparam  D12_6_P           = 10'b001101_0110;
localparam  D13_6_P           = 10'b101100_0110;
localparam  D14_6_P           = 10'b011100_0110;
localparam  D15_6_P           = 10'b101000_0110;
localparam  D16_6_P           = 10'b100100_0110;
localparam  D17_6_P           = 10'b100011_0110;
localparam  D18_6_P           = 10'b010011_0110;
localparam  D19_6_P           = 10'b110010_0110;
localparam  D20_6_P           = 10'b001011_0110;
localparam  D21_6_P           = 10'b101010_0110;
localparam  D22_6_P           = 10'b011010_0110;
localparam  D23_6_P           = 10'b000101_0110;
localparam  D24_6_P           = 10'b001100_0110;
localparam  D25_6_P           = 10'b100110_0110;
localparam  D26_6_P           = 10'b010110_0110;
localparam  D27_6_P           = 10'b001001_0110;
localparam  D28_6_P           = 10'b001110_0110;
localparam  D29_6_P           = 10'b010001_0110;
localparam  D30_6_P           = 10'b100001_0110;
localparam  D31_6_P           = 10'b010100_0110;

// data symbols - RD positive, abcdei_fghj
localparam  D0_7_P            = 10'b011000_1110;
localparam  D1_7_P            = 10'b100010_1110;
localparam  D2_7_P            = 10'b010010_1110;
localparam  D3_7_P            = 10'b110001_0001;
localparam  D4_7_P            = 10'b001010_1110;
localparam  D5_7_P            = 10'b101001_0001;
localparam  D6_7_P            = 10'b011001_0001;
localparam  D7_7_P            = 10'b000111_0001;
localparam  D8_7_P            = 10'b000110_1110;
localparam  D9_7_P            = 10'b100101_0001;
localparam  D10_7_P           = 10'b010101_0001;
localparam  D11_7_P           = 10'b110100_1000;
localparam  D12_7_P           = 10'b001101_0001;
localparam  D13_7_P           = 10'b101100_1000;
localparam  D14_7_P           = 10'b011100_1000;
localparam  D15_7_P           = 10'b101000_1110;
localparam  D16_7_P           = 10'b100100_1110;
localparam  D17_7_P           = 10'b100011_0001;
localparam  D18_7_P           = 10'b010011_0001;
localparam  D19_7_P           = 10'b110010_0001;
localparam  D20_7_P           = 10'b001011_0001;
localparam  D21_7_P           = 10'b101010_0001;
localparam  D22_7_P           = 10'b011010_0001;
localparam  D23_7_P           = 10'b000101_1110;
localparam  D24_7_P           = 10'b001100_1110;
localparam  D25_7_P           = 10'b100110_0001;
localparam  D26_7_P           = 10'b010110_0001;
localparam  D27_7_P           = 10'b001001_1110;
localparam  D28_7_P           = 10'b001110_0001;
localparam  D29_7_P           = 10'b010001_1110;
localparam  D30_7_P           = 10'b100001_1110;
localparam  D31_7_P           = 10'b010100_1110;

// ------------
// 8b symbols
// ------------

// control symbols
localparam  K28_0_8B          = 8'h1C;
localparam  K28_1_8B          = 8'h3C;
localparam  K28_2_8B          = 8'h5C;
localparam  K28_3_8B          = 8'h7C;
localparam  K28_4_8B          = 8'h9C;
localparam  K28_5_8B          = 8'hBC;
localparam  K28_6_8B          = 8'hDC;
localparam  K28_7_8B          = 8'hFC;
localparam  K23_7_8B          = 8'hF7;
localparam  K27_7_8B          = 8'hFB;
localparam  K29_7_8B          = 8'hFD;
localparam  K30_7_8B          = 8'hFE;


// data symbols

localparam  D0_0_8B           = 8'h00;
localparam  D1_0_8B           = 8'h01;
localparam  D2_0_8B           = 8'h02;
localparam  D3_0_8B           = 8'h03;
localparam  D4_0_8B           = 8'h04;
localparam  D5_0_8B           = 8'h05;
localparam  D6_0_8B           = 8'h06;
localparam  D7_0_8B           = 8'h07;
localparam  D8_0_8B           = 8'h08;
localparam  D9_0_8B           = 8'h09;
localparam  D10_0_8B          = 8'h0A;
localparam  D11_0_8B          = 8'h0B;
localparam  D12_0_8B          = 8'h0C;
localparam  D13_0_8B          = 8'h0D;
localparam  D14_0_8B          = 8'h0E;
localparam  D15_0_8B          = 8'h0F;
localparam  D16_0_8B          = 8'h10;
localparam  D17_0_8B          = 8'h11;
localparam  D18_0_8B          = 8'h12;
localparam  D19_0_8B          = 8'h13;
localparam  D20_0_8B          = 8'h14;
localparam  D21_0_8B          = 8'h15;
localparam  D22_0_8B          = 8'h16;
localparam  D23_0_8B          = 8'h17;
localparam  D24_0_8B          = 8'h18;
localparam  D25_0_8B          = 8'h19;
localparam  D26_0_8B          = 8'h1A;
localparam  D27_0_8B          = 8'h1B;
localparam  D28_0_8B          = 8'h1C;
localparam  D29_0_8B          = 8'h1D;
localparam  D30_0_8B          = 8'h1E;
localparam  D31_0_8B          = 8'h1F;

localparam  D0_1_8B           = 8'h20;
localparam  D1_1_8B           = 8'h21;
localparam  D2_1_8B           = 8'h22;
localparam  D3_1_8B           = 8'h23;
localparam  D4_1_8B           = 8'h24;
localparam  D5_1_8B           = 8'h25;
localparam  D6_1_8B           = 8'h26;
localparam  D7_1_8B           = 8'h27;
localparam  D8_1_8B           = 8'h28;
localparam  D9_1_8B           = 8'h29;
localparam  D10_1_8B          = 8'h2A;
localparam  D11_1_8B          = 8'h2B;
localparam  D12_1_8B          = 8'h2C;
localparam  D13_1_8B          = 8'h2D;
localparam  D14_1_8B          = 8'h2E;
localparam  D15_1_8B          = 8'h2F;
localparam  D16_1_8B          = 8'h30;
localparam  D17_1_8B          = 8'h31;
localparam  D18_1_8B          = 8'h32;
localparam  D19_1_8B          = 8'h33;
localparam  D20_1_8B          = 8'h34;
localparam  D21_1_8B          = 8'h35;
localparam  D22_1_8B          = 8'h36;
localparam  D23_1_8B          = 8'h37;
localparam  D24_1_8B          = 8'h38;
localparam  D25_1_8B          = 8'h39;
localparam  D26_1_8B          = 8'h3A;
localparam  D27_1_8B          = 8'h3B;
localparam  D28_1_8B          = 8'h3C;
localparam  D29_1_8B          = 8'h3D;
localparam  D30_1_8B          = 8'h3E;
localparam  D31_1_8B          = 8'h3F;

localparam  D0_2_8B           = 8'h40;
localparam  D1_2_8B           = 8'h41;
localparam  D2_2_8B           = 8'h42;
localparam  D3_2_8B           = 8'h43;
localparam  D4_2_8B           = 8'h44;
localparam  D5_2_8B           = 8'h45;
localparam  D6_2_8B           = 8'h46;
localparam  D7_2_8B           = 8'h47;
localparam  D8_2_8B           = 8'h48;
localparam  D9_2_8B           = 8'h49;
localparam  D10_2_8B          = 8'h4A;
localparam  D11_2_8B          = 8'h4B;
localparam  D12_2_8B          = 8'h4C;
localparam  D13_2_8B          = 8'h4D;
localparam  D14_2_8B          = 8'h4E;
localparam  D15_2_8B          = 8'h4F;
localparam  D16_2_8B          = 8'h50;
localparam  D17_2_8B          = 8'h51;
localparam  D18_2_8B          = 8'h52;
localparam  D19_2_8B          = 8'h53;
localparam  D20_2_8B          = 8'h54;
localparam  D21_2_8B          = 8'h55;
localparam  D22_2_8B          = 8'h56;
localparam  D23_2_8B          = 8'h57;
localparam  D24_2_8B          = 8'h58;
localparam  D25_2_8B          = 8'h59;
localparam  D26_2_8B          = 8'h5A;
localparam  D27_2_8B          = 8'h5B;
localparam  D28_2_8B          = 8'h5C;
localparam  D29_2_8B          = 8'h5D;
localparam  D30_2_8B          = 8'h5E;
localparam  D31_2_8B          = 8'h5F;

localparam  D0_3_8B           = 8'h60;
localparam  D1_3_8B           = 8'h61;
localparam  D2_3_8B           = 8'h62;
localparam  D3_3_8B           = 8'h63;
localparam  D4_3_8B           = 8'h64;
localparam  D5_3_8B           = 8'h65;
localparam  D6_3_8B           = 8'h66;
localparam  D7_3_8B           = 8'h67;
localparam  D8_3_8B           = 8'h68;
localparam  D9_3_8B           = 8'h69;
localparam  D10_3_8B          = 8'h6A;
localparam  D11_3_8B          = 8'h6B;
localparam  D12_3_8B          = 8'h6C;
localparam  D13_3_8B          = 8'h6D;
localparam  D14_3_8B          = 8'h6E;
localparam  D15_3_8B          = 8'h6F;
localparam  D16_3_8B          = 8'h70;
localparam  D17_3_8B          = 8'h71;
localparam  D18_3_8B          = 8'h72;
localparam  D19_3_8B          = 8'h73;
localparam  D20_3_8B          = 8'h74;
localparam  D21_3_8B          = 8'h75;
localparam  D22_3_8B          = 8'h76;
localparam  D23_3_8B          = 8'h77;
localparam  D24_3_8B          = 8'h78;
localparam  D25_3_8B          = 8'h79;
localparam  D26_3_8B          = 8'h7A;
localparam  D27_3_8B          = 8'h7B;
localparam  D28_3_8B          = 8'h7C;
localparam  D29_3_8B          = 8'h7D;
localparam  D30_3_8B          = 8'h7E;
localparam  D31_3_8B          = 8'h7F;

localparam  D0_4_8B           = 8'h80;
localparam  D1_4_8B           = 8'h81;
localparam  D2_4_8B           = 8'h82;
localparam  D3_4_8B           = 8'h83;
localparam  D4_4_8B           = 8'h84;
localparam  D5_4_8B           = 8'h85;
localparam  D6_4_8B           = 8'h86;
localparam  D7_4_8B           = 8'h87;
localparam  D8_4_8B           = 8'h88;
localparam  D9_4_8B           = 8'h89;
localparam  D10_4_8B          = 8'h8A;
localparam  D11_4_8B          = 8'h8B;
localparam  D12_4_8B          = 8'h8C;
localparam  D13_4_8B          = 8'h8D;
localparam  D14_4_8B          = 8'h8E;
localparam  D15_4_8B          = 8'h8F;
localparam  D16_4_8B          = 8'h90;
localparam  D17_4_8B          = 8'h91;
localparam  D18_4_8B          = 8'h92;
localparam  D19_4_8B          = 8'h93;
localparam  D20_4_8B          = 8'h94;
localparam  D21_4_8B          = 8'h95;
localparam  D22_4_8B          = 8'h96;
localparam  D23_4_8B          = 8'h97;
localparam  D24_4_8B          = 8'h98;
localparam  D25_4_8B          = 8'h99;
localparam  D26_4_8B          = 8'h9A;
localparam  D27_4_8B          = 8'h9B;
localparam  D28_4_8B          = 8'h9C;
localparam  D29_4_8B          = 8'h9D;
localparam  D30_4_8B          = 8'h9E;
localparam  D31_4_8B          = 8'h9F;

localparam  D0_5_8B           = 8'hA0;
localparam  D1_5_8B           = 8'hA1;
localparam  D2_5_8B           = 8'hA2;
localparam  D3_5_8B           = 8'hA3;
localparam  D4_5_8B           = 8'hA4;
localparam  D5_5_8B           = 8'hA5;
localparam  D6_5_8B           = 8'hA6;
localparam  D7_5_8B           = 8'hA7;
localparam  D8_5_8B           = 8'hA8;
localparam  D9_5_8B           = 8'hA9;
localparam  D10_5_8B          = 8'hAA;
localparam  D11_5_8B          = 8'hAB;
localparam  D12_5_8B          = 8'hAC;
localparam  D13_5_8B          = 8'hAD;
localparam  D14_5_8B          = 8'hAE;
localparam  D15_5_8B          = 8'hAF;
localparam  D16_5_8B          = 8'hB0;
localparam  D17_5_8B          = 8'hB1;
localparam  D18_5_8B          = 8'hB2;
localparam  D19_5_8B          = 8'hB3;
localparam  D20_5_8B          = 8'hB4;
localparam  D21_5_8B          = 8'hB5;
localparam  D22_5_8B          = 8'hB6;
localparam  D23_5_8B          = 8'hB7;
localparam  D24_5_8B          = 8'hB8;
localparam  D25_5_8B          = 8'hB9;
localparam  D26_5_8B          = 8'hBA;
localparam  D27_5_8B          = 8'hBB;
localparam  D28_5_8B          = 8'hBC;
localparam  D29_5_8B          = 8'hBD;
localparam  D30_5_8B          = 8'hBE;
localparam  D31_5_8B          = 8'hBF;

localparam  D0_6_8B           = 8'hC0;
localparam  D1_6_8B           = 8'hC1;
localparam  D2_6_8B           = 8'hC2;
localparam  D3_6_8B           = 8'hC3;
localparam  D4_6_8B           = 8'hC4;
localparam  D5_6_8B           = 8'hC5;
localparam  D6_6_8B           = 8'hC6;
localparam  D7_6_8B           = 8'hC7;
localparam  D8_6_8B           = 8'hC8;
localparam  D9_6_8B           = 8'hC9;
localparam  D10_6_8B          = 8'hCA;
localparam  D11_6_8B          = 8'hCB;
localparam  D12_6_8B          = 8'hCC;
localparam  D13_6_8B          = 8'hCD;
localparam  D14_6_8B          = 8'hCE;
localparam  D15_6_8B          = 8'hCF;
localparam  D16_6_8B          = 8'hD0;
localparam  D17_6_8B          = 8'hD1;
localparam  D18_6_8B          = 8'hD2;
localparam  D19_6_8B          = 8'hD3;
localparam  D20_6_8B          = 8'hD4;
localparam  D21_6_8B          = 8'hD5;
localparam  D22_6_8B          = 8'hD6;
localparam  D23_6_8B          = 8'hD7;
localparam  D24_6_8B          = 8'hD8;
localparam  D25_6_8B          = 8'hD9;
localparam  D26_6_8B          = 8'hDA;
localparam  D27_6_8B          = 8'hDB;
localparam  D28_6_8B          = 8'hDC;
localparam  D29_6_8B          = 8'hDD;
localparam  D30_6_8B          = 8'hDE;
localparam  D31_6_8B          = 8'hDF;

localparam  D0_7_8B           = 8'hE0;
localparam  D1_7_8B           = 8'hE1;
localparam  D2_7_8B           = 8'hE2;
localparam  D3_7_8B           = 8'hE3;
localparam  D4_7_8B           = 8'hE4;
localparam  D5_7_8B           = 8'hE5;
localparam  D6_7_8B           = 8'hE6;
localparam  D7_7_8B           = 8'hE7;
localparam  D8_7_8B           = 8'hE8;
localparam  D9_7_8B           = 8'hE9;
localparam  D10_7_8B          = 8'hEA;
localparam  D11_7_8B          = 8'hEB;
localparam  D12_7_8B          = 8'hEC;
localparam  D13_7_8B          = 8'hED;
localparam  D14_7_8B          = 8'hEE;
localparam  D15_7_8B          = 8'hEF;
localparam  D16_7_8B          = 8'hF0;
localparam  D17_7_8B          = 8'hF1;
localparam  D18_7_8B          = 8'hF2;
localparam  D19_7_8B          = 8'hF3;
localparam  D20_7_8B          = 8'hF4;
localparam  D21_7_8B          = 8'hF5;
localparam  D22_7_8B          = 8'hF6;
localparam  D23_7_8B          = 8'hF7;
localparam  D24_7_8B          = 8'hF8;
localparam  D25_7_8B          = 8'hF9;
localparam  D26_7_8B          = 8'hFA;
localparam  D27_7_8B          = 8'hFB;
localparam  D28_7_8B          = 8'hFC;
localparam  D29_7_8B          = 8'hFD;
localparam  D30_7_8B          = 8'hFE;
localparam  D31_7_8B          = 8'hFF;

// --------------
// 40b primitives 
// ---------------

localparam   FC_IDLE0_PRIM        = { D21_5_P, D21_5_N, D21_4_N, K28_5_P};
localparam   FC_IDLE1_PRIM        = { D21_5_P, D21_5_N, D21_4_P, K28_5_N};
localparam   FC_ARBFF0_PRIM       = { D31_7_P, D31_7_N, D20_4_P, K28_5_N};
localparam   FC_ARBFF1_PRIM       = { D31_7_N, D31_7_P, D20_4_N, K28_5_P};


// --------------
// 32b primitives 
// ---------------

// EOF primitives, positive and negative disparity
// use positive disparity ordered set if beginning disparity is positive, and vice versa
   localparam   EOF_F_N_8B           = { D21_3_8B, D21_3_8B, D21_4_8B, K28_5_8B };         // EOF terminate
   localparam   EOF_F_P_8B           = { D21_3_8B, D21_3_8B, D21_5_8B, K28_5_8B };         // EOF terminate
   localparam   EOF_DT_N_8B          = { D21_4_8B, D21_4_8B, D21_4_8B, K28_5_8B };         // EOF disconnect-terminate (class 1 or class 4)
   localparam   EOF_DT_P_8B          = { D21_4_8B, D21_4_8B, D21_5_8B, K28_5_8B };         // EOF disconnect-terminate (class 1 or class 4)
   localparam   EOF_A_N_8B           = { D21_7_8B, D21_7_8B, D21_4_8B, K28_5_8B };         // EOF abort
   localparam   EOF_A_P_8B           = { D21_7_8B, D21_7_8B, D21_5_8B, K28_5_8B };         // EOF abort
   localparam   EOF_N_N_8B           = { D21_6_8B, D21_6_8B, D21_4_8B, K28_5_8B };         // EOF normal
   localparam   EOF_N_P_8B           = { D21_6_8B, D21_6_8B, D21_5_8B, K28_5_8B };         // EOF normal
   localparam   EOF_NI_N_8B          = { D21_6_8B, D21_6_8B, D10_4_8B, K28_5_8B };         // EOF normal-invalid
   localparam   EOF_NI_P_8B          = { D21_6_8B, D21_6_8B, D10_5_8B, K28_5_8B };         // EOF normal-invalis
   localparam   EOF_DTI_N_8B         = { D21_4_8B, D21_4_8B, D10_4_8B, K28_5_8B };         // EOF disconnect-terminate-invalid (class 1 or class 4)
   localparam   EOF_DTI_P_8B         = { D21_4_8B, D21_4_8B, D10_5_8B, K28_5_8B };         // EOF disconnect-terminate-invalid (class 1 or class 4)
   localparam   EOF_RT_N_8B          = { D25_4_8B, D25_4_8B, D21_4_8B, K28_5_8B };         // EOF remove-terminate (class 4)
   localparam   EOF_RT_P_8B          = { D25_4_8B, D25_4_8B, D21_5_8B, K28_5_8B };         // EOF remove-terminate (class 4)
   localparam   EOF_RTI_N_8B         = { D25_4_8B, D25_4_8B, D10_4_8B, K28_5_8B };         // EOF remove-terminate-invalid (class 4)
   localparam   EOF_RTI_P_8B         = { D25_4_8B, D25_4_8B, D10_5_8B, K28_5_8B };         // EOF remove-terminate-invalid (class 4)               

// SOF primitives, always starts with negative disparity
   localparam   SOF_C1_8B            = { D23_0_8B, D23_0_8B, D21_5_8B, K28_5_8B };         // SOF connect  class 1
   localparam   SOF_I1_8B            = { D23_2_8B, D23_2_8B, D21_5_8B, K28_5_8B };         // SOF initiate class 1
   localparam   SOF_N1_8B            = { D23_1_8B, D23_1_8B, D21_5_8B, K28_5_8B };         // SOF normal   class 1
   localparam   SOF_I2_8B            = { D21_2_8B, D21_2_8B, D21_5_8B, K28_5_8B };         // SOF initiate class 2
   localparam   SOF_N2_8B            = { D21_1_8B, D21_1_8B, D21_5_8B, K28_5_8B };         // SOF normal   class 2
   localparam   SOF_I3_8B            = { D22_2_8B, D22_2_8B, D21_5_8B, K28_5_8B };         // SOF initiate class 3
   localparam   SOF_N3_8B            = { D22_1_8B, D22_1_8B, D21_5_8B, K28_5_8B };         // SOF normal   class 3
   localparam   SOF_A4_8B            = { D25_0_8B, D25_0_8B, D21_5_8B, K28_5_8B };         // SOF active   class 4
   localparam   SOF_I4_8B            = { D25_2_8B, D25_2_8B, D21_5_8B, K28_5_8B };         // SOF initiate class 4
   localparam   SOF_N4_8B            = { D25_1_8B, D25_1_8B, D21_5_8B, K28_5_8B };         // SOF normal   class 4
   localparam   SOF_F_8B             = { D24_2_8B, D24_2_8B, D21_5_8B, K28_5_8B };         // SOF fabric        

// IDLE primitives, always starts with negative disparity
   localparam   IDLE0_8B            = { D21_5_8B, D21_5_8B, D21_4_8B, K28_5_8B };          // IDLE
   localparam   IDLE1_8B            = { D31_7_8B, D31_7_8B, D20_4_8B, K28_5_8B };          // IDLE

// --------------
// Misc
// ---------------

localparam MAX_VALUE_16          = 16'hFFFF;
localparam MAX_VALUE_32          = 32'hFFFF_FFFF;
localparam MAX_VALUE_48          = 48'hFFFF_FFFF_FFFF;
localparam MAX_VALUE_64          = 64'hFFFF_FFFF_FFFF_FFFF;

endpackage // vi_defines_pkg
   