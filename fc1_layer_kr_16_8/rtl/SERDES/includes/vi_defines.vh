/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author: jaedon.kim $
* $Date: 2013-07-18 10:19:25 -0700 (Thu, 18 Jul 2013) $
* $Revision: 2862 $
* $HeadURL$
***********************************************************************************************************/

// ------------
// 10b symbols
// ------------
// These 10b symbols were taken from Altera's Stratix GX Device Handbook and formatted using emacs macros
// Note the endianess is little-endian (abcdei_fghj).  Generally, incoming symbols need to be bit reveresed
// to match these defines. 

// control symbols - RD negative, abcdei_fghj
`define   K28_0_N            10'b001111_0100
`define   K28_1_N            10'b001111_1001
`define   K28_2_N            10'b001111_0101
`define   K28_3_N            10'b001111_0011
`define   K28_4_N            10'b001111_0010
`define   K28_5_N            10'b001111_1010
`define   K28_6_N            10'b001111_0110
`define   K28_7_N            10'b001111_1000
`define   K23_7_N            10'b111010_1000
`define   K27_7_N            10'b110110_1000
`define   K29_7_N            10'b101110_1000
`define   K30_7_N            10'b011110_1000

// control symbols - RD positive, abcdei_fghj
`define   K28_0_P            10'b110000_1011
`define   K28_1_P            10'b110000_0110
`define   K28_2_P            10'b110000_1010
`define   K28_3_P            10'b110000_1100
`define   K28_4_P            10'b110000_1101
`define   K28_5_P            10'b110000_0101
`define   K28_6_P            10'b110000_1001
`define   K28_7_P            10'b110000_0111
`define   K23_7_P            10'b000101_0111
`define   K27_7_P            10'b001001_0111
`define   K29_7_P            10'b010001_0111
`define   K30_7_P            10'b100001_0111

// data symbols - RD negative, abcdei_fghj
`define   D0_0_N             10'b100111_0100
`define   D1_0_N             10'b011101_0100
`define   D2_0_N             10'b101101_0100
`define   D3_0_N             10'b110001_1011
`define   D4_0_N             10'b110101_0100
`define   D5_0_N             10'b101001_1011
`define   D6_0_N             10'b011001_1011
`define   D7_0_N             10'b111000_1011
`define   D8_0_N             10'b111001_0100
`define   D9_0_N             10'b100101_1011
`define   D10_0_N            10'b010101_1011
`define   D11_0_N            10'b110100_1011
`define   D12_0_N            10'b001101_1011
`define   D13_0_N            10'b101100_1011
`define   D14_0_N            10'b011100_1011
`define   D15_0_N            10'b010111_0100
`define   D16_0_N            10'b011011_0100
`define   D17_0_N            10'b100011_1011
`define   D18_0_N            10'b010011_1011
`define   D19_0_N            10'b110010_1011
`define   D20_0_N            10'b001011_1011
`define   D21_0_N            10'b101010_1011
`define   D22_0_N            10'b011010_1011
`define   D23_0_N            10'b111010_0100
`define   D24_0_N            10'b110011_0100
`define   D25_0_N            10'b100110_1011
`define   D26_0_N            10'b010110_1011
`define   D27_0_N            10'b110110_0100
`define   D28_0_N            10'b001110_1011
`define   D29_0_N            10'b101110_0100
`define   D30_0_N            10'b011110_0100
`define   D31_0_N            10'b101011_0100

// data symbols - RD negative, abcdei_fghj
`define   D0_1_N             10'b100111_1001
`define   D1_1_N             10'b011101_1001
`define   D2_1_N             10'b101101_1001
`define   D3_1_N             10'b110001_1001
`define   D4_1_N             10'b110101_1001
`define   D5_1_N             10'b101001_1001
`define   D6_1_N             10'b011001_1001
`define   D7_1_N             10'b111000_1001
`define   D8_1_N             10'b111001_1001
`define   D9_1_N             10'b100101_1001
`define   D10_1_N            10'b010101_1001
`define   D11_1_N            10'b110100_1001
`define   D12_1_N            10'b001101_1001
`define   D13_1_N            10'b101100_1001
`define   D14_1_N            10'b011100_1001
`define   D15_1_N            10'b010111_1001
`define   D16_1_N            10'b011011_1001
`define   D17_1_N            10'b100011_1001
`define   D18_1_N            10'b010011_1001
`define   D19_1_N            10'b110010_1001
`define   D20_1_N            10'b001011_1001
`define   D21_1_N            10'b101010_1001
`define   D22_1_N            10'b011010_1001
`define   D23_1_N            10'b111010_1001
`define   D24_1_N            10'b110011_1001
`define   D25_1_N            10'b100110_1001
`define   D26_1_N            10'b010110_1001
`define   D27_1_N            10'b110110_1001
`define   D28_1_N            10'b001110_1001
`define   D29_1_N            10'b101110_1001
`define   D30_1_N            10'b011110_1001
`define   D31_1_N            10'b101011_1001

// data symbols - RD negative, abcdei_fghj
`define   D0_2_N             10'b100111_0101
`define   D1_2_N             10'b011101_0101
`define   D2_2_N             10'b101101_0101
`define   D3_2_N             10'b110001_0101
`define   D4_2_N             10'b110101_0101
`define   D5_2_N             10'b101001_0101
`define   D6_2_N             10'b011001_0101
`define   D7_2_N             10'b111000_0101
`define   D8_2_N             10'b111001_0101
`define   D9_2_N             10'b100101_0101
`define   D10_2_N            10'b010101_0101
`define   D11_2_N            10'b110100_0101
`define   D12_2_N            10'b001101_0101
`define   D13_2_N            10'b101100_0101
`define   D14_2_N            10'b011100_0101
`define   D15_2_N            10'b010111_0101
`define   D16_2_N            10'b011011_0101
`define   D17_2_N            10'b100011_0101
`define   D18_2_N            10'b010011_0101
`define   D19_2_N            10'b110010_0101
`define   D20_2_N            10'b001011_0101
`define   D21_2_N            10'b101010_0101
`define   D22_2_N            10'b011010_0101
`define   D23_2_N            10'b111010_0101
`define   D24_2_N            10'b110011_0101
`define   D25_2_N            10'b100110_0101
`define   D26_2_N            10'b010110_0101
`define   D27_2_N            10'b110110_0101
`define   D28_2_N            10'b001110_0101
`define   D29_2_N            10'b101110_0101
`define   D30_2_N            10'b011110_0101
`define   D31_2_N            10'b101011_0101

`define   D0_3_N             10'b100111_0011
`define   D1_3_N             10'b011101_0011
`define   D2_3_N             10'b101101_0011
`define   D3_3_N             10'b110001_1100
`define   D4_3_N             10'b110101_0011
`define   D5_3_N             10'b101001_1100
`define   D6_3_N             10'b011001_1100
`define   D7_3_N             10'b111000_1100
`define   D8_3_N             10'b111001_0011
`define   D9_3_N             10'b100101_1100
`define   D10_3_N            10'b010101_1100
`define   D11_3_N            10'b110100_1100
`define   D12_3_N            10'b001101_1100
`define   D13_3_N            10'b101100_1100
`define   D14_3_N            10'b011100_1100
`define   D15_3_N            10'b010111_0011
`define   D16_3_N            10'b011011_0011
`define   D17_3_N            10'b100011_1100
`define   D18_3_N            10'b010011_1100
`define   D19_3_N            10'b110010_1100
`define   D20_3_N            10'b001011_1100
`define   D21_3_N            10'b101010_1100
`define   D22_3_N            10'b011010_1100
`define   D23_3_N            10'b111010_0011
`define   D24_3_N            10'b110011_0011
`define   D25_3_N            10'b100110_1100
`define   D26_3_N            10'b010110_1100
`define   D27_3_N            10'b110110_0011
`define   D28_3_N            10'b001110_1100
`define   D29_3_N            10'b101110_0011
`define   D30_3_N            10'b011110_0011
`define   D31_3_N            10'b101011_0011

// data symbols - RD negative, abcdei_fghj
`define   D0_4_N             10'b100111_0010
`define   D1_4_N             10'b011101_0010
`define   D2_4_N             10'b101101_0010
`define   D3_4_N             10'b110001_1101
`define   D4_4_N             10'b110101_0010
`define   D5_4_N             10'b101001_1101
`define   D6_4_N             10'b011001_1101
`define   D7_4_N             10'b111000_1101
`define   D8_4_N             10'b111001_0010
`define   D9_4_N             10'b100101_1101
`define   D10_4_N            10'b010101_1101
`define   D11_4_N            10'b110100_1101
`define   D12_4_N            10'b001101_1101
`define   D13_4_N            10'b101100_1101
`define   D14_4_N            10'b011100_1101
`define   D15_4_N            10'b010111_0010
`define   D16_4_N            10'b011011_0010
`define   D17_4_N            10'b100011_1101
`define   D18_4_N            10'b010011_1101
`define   D19_4_N            10'b110010_1101
`define   D20_4_N            10'b001011_1101
`define   D21_4_N            10'b101010_1101
`define   D22_4_N            10'b011010_1101
`define   D23_4_N            10'b111010_0010
`define   D24_4_N            10'b110011_0010
`define   D25_4_N            10'b100110_1101
`define   D26_4_N            10'b010110_1101
`define   D27_4_N            10'b110110_0010
`define   D28_4_N            10'b001110_1101
`define   D29_4_N            10'b101110_0010
`define   D30_4_N            10'b011110_0010
`define   D31_4_N            10'b101011_0010

// data symbols - RD negative, abcdei_fghj
`define   D0_5_N             10'b100111_1010
`define   D1_5_N             10'b011101_1010
`define   D2_5_N             10'b101101_1010
`define   D3_5_N             10'b110001_1010
`define   D4_5_N             10'b110101_1010
`define   D5_5_N             10'b101001_1010
`define   D6_5_N             10'b011001_1010
`define   D7_5_N             10'b111000_1010
`define   D8_5_N             10'b111001_1010
`define   D9_5_N             10'b100101_1010
`define   D10_5_N            10'b010101_1010
`define   D11_5_N            10'b110100_1010
`define   D12_5_N            10'b001101_1010
`define   D13_5_N            10'b101100_1010
`define   D14_5_N            10'b011100_1010
`define   D15_5_N            10'b010111_1010
`define   D16_5_N            10'b011011_1010
`define   D17_5_N            10'b100011_1010
`define   D18_5_N            10'b010011_1010
`define   D19_5_N            10'b110010_1010
`define   D20_5_N            10'b001011_1010
`define   D21_5_N            10'b101010_1010
`define   D22_5_N            10'b011010_1010
`define   D23_5_N            10'b111010_1010
`define   D24_5_N            10'b110011_1010
`define   D25_5_N            10'b100110_1010
`define   D26_5_N            10'b010110_1010
`define   D27_5_N            10'b110110_1010
`define   D28_5_N            10'b001110_1010
`define   D29_5_N            10'b101110_1010
`define   D30_5_N            10'b011110_1010
`define   D31_5_N            10'b101011_1010

// data symbols - RD negative, abcdei_fghj
`define   D0_6_N             10'b100111_0110
`define   D1_6_N             10'b011101_0110
`define   D2_6_N             10'b101101_0110
`define   D3_6_N             10'b110001_0110
`define   D4_6_N             10'b110101_0110
`define   D5_6_N             10'b101001_0110
`define   D6_6_N             10'b011001_0110
`define   D7_6_N             10'b111000_0110
`define   D8_6_N             10'b111001_0110
`define   D9_6_N             10'b100101_0110
`define   D10_6_N            10'b010101_0110
`define   D11_6_N            10'b110100_0110
`define   D12_6_N            10'b001101_0110
`define   D13_6_N            10'b101100_0110
`define   D14_6_N            10'b011100_0110
`define   D15_6_N            10'b010111_0110
`define   D16_6_N            10'b011011_0110
`define   D17_6_N            10'b100011_0110
`define   D18_6_N            10'b010011_0110
`define   D19_6_N            10'b110010_0110
`define   D20_6_N            10'b001011_0110
`define   D21_6_N            10'b101010_0110
`define   D22_6_N            10'b011010_0110
`define   D23_6_N            10'b111010_0110
`define   D24_6_N            10'b110011_0110
`define   D25_6_N            10'b100110_0110
`define   D26_6_N            10'b010110_0110
`define   D27_6_N            10'b110110_0110
`define   D28_6_N            10'b001110_0110
`define   D29_6_N            10'b101110_0110
`define   D30_6_N            10'b011110_0110
`define   D31_6_N            10'b101011_0110

// data symbols - RD negative, abcdei_fghj
`define   D0_7_N             10'b100111_0001
`define   D1_7_N             10'b011101_0001
`define   D2_7_N             10'b101101_0001
`define   D3_7_N             10'b110001_1110
`define   D4_7_N             10'b110101_0001
`define   D5_7_N             10'b101001_1110
`define   D6_7_N             10'b011001_1110
`define   D7_7_N             10'b111000_1110
`define   D8_7_N             10'b111001_0001
`define   D9_7_N             10'b100101_1110
`define   D10_7_N            10'b010101_1110
`define   D11_7_N            10'b110100_1110
`define   D12_7_N            10'b001101_1110
`define   D13_7_N            10'b101100_1110
`define   D14_7_N            10'b011100_1110
`define   D15_7_N            10'b010111_0001
`define   D16_7_N            10'b011011_0001
`define   D17_7_N            10'b100011_0111
`define   D18_7_N            10'b010011_0111
`define   D19_7_N            10'b110010_1110
`define   D20_7_N            10'b001011_0111
`define   D21_7_N            10'b101010_1110
`define   D22_7_N            10'b011010_1110
`define   D23_7_N            10'b111010_0001
`define   D24_7_N            10'b110011_0001
`define   D25_7_N            10'b100110_1110
`define   D26_7_N            10'b010110_1110
`define   D27_7_N            10'b110110_0001
`define   D28_7_N            10'b001110_1110
`define   D29_7_N            10'b101110_0001
`define   D30_7_N            10'b011110_0001
`define   D31_7_N            10'b101011_0001

// data symbols - RD positive, abcdei_fghj
`define   D0_0_P             10'b011000_1011
`define   D1_0_P             10'b100010_1011
`define   D2_0_P             10'b010010_1011
`define   D3_0_P             10'b110001_0100
`define   D4_0_P             10'b001010_1011
`define   D5_0_P             10'b101001_0100
`define   D6_0_P             10'b011001_0100
`define   D7_0_P             10'b000111_0100
`define   D8_0_P             10'b000110_1011
`define   D9_0_P             10'b100101_0100
`define   D10_0_P            10'b010101_0100
`define   D11_0_P            10'b110100_0100
`define   D12_0_P            10'b001101_0100
`define   D13_0_P            10'b101100_0100
`define   D14_0_P            10'b011100_0100
`define   D15_0_P            10'b101000_1011
`define   D16_0_P            10'b100100_1011
`define   D17_0_P            10'b100011_0100
`define   D18_0_P            10'b010011_0100
`define   D19_0_P            10'b110010_0100
`define   D20_0_P            10'b001011_0100
`define   D21_0_P            10'b101010_0100
`define   D22_0_P            10'b011010_0100
`define   D23_0_P            10'b000101_1011
`define   D24_0_P            10'b001100_1011
`define   D25_0_P            10'b100110_0100
`define   D26_0_P            10'b010110_0100
`define   D27_0_P            10'b001001_1011
`define   D28_0_P            10'b001110_0100
`define   D29_0_P            10'b010001_1011
`define   D30_0_P            10'b100001_1011
`define   D31_0_P            10'b010100_1011

// data symbols - RD positive, abcdei_fghj
`define   D0_1_P             10'b011000_1001
`define   D1_1_P             10'b100010_1001
`define   D2_1_P             10'b010010_1001
`define   D3_1_P             10'b110001_1001
`define   D4_1_P             10'b001010_1001
`define   D5_1_P             10'b101001_1001
`define   D6_1_P             10'b011001_1001
`define   D7_1_P             10'b000111_1001
`define   D8_1_P             10'b000110_1001
`define   D9_1_P             10'b100101_1001
`define   D10_1_P            10'b010101_1001
`define   D11_1_P            10'b110100_1001
`define   D12_1_P            10'b001101_1001
`define   D13_1_P            10'b101100_1001
`define   D14_1_P            10'b011100_1001
`define   D15_1_P            10'b101000_1001
`define   D16_1_P            10'b100100_1001
`define   D17_1_P            10'b100011_1001
`define   D18_1_P            10'b010011_1001
`define   D19_1_P            10'b110010_1001
`define   D20_1_P            10'b001011_1001
`define   D21_1_P            10'b101010_1001
`define   D22_1_P            10'b011010_1001
`define   D23_1_P            10'b000101_1001
`define   D24_1_P            10'b001100_1001
`define   D25_1_P            10'b100110_1001
`define   D26_1_P            10'b010110_1001
`define   D27_1_P            10'b001001_1001
`define   D28_1_P            10'b001110_1001
`define   D29_1_P            10'b010001_1001
`define   D30_1_P            10'b100001_1001
`define   D31_1_P            10'b010100_1001

// data symbols - RD positive, abcdei_fghj
`define   D0_2_P             10'b011000_0101
`define   D1_2_P             10'b100010_0101
`define   D2_2_P             10'b010010_0101
`define   D3_2_P             10'b110001_0101
`define   D4_2_P             10'b001010_0101
`define   D5_2_P             10'b101001_0101
`define   D6_2_P             10'b011001_0101
`define   D7_2_P             10'b000111_0101
`define   D8_2_P             10'b000110_0101
`define   D9_2_P             10'b100101_0101
`define   D10_2_P            10'b010101_0101
`define   D11_2_P            10'b110100_0101
`define   D12_2_P            10'b001101_0101
`define   D13_2_P            10'b101100_0101
`define   D14_2_P            10'b011100_0101
`define   D15_2_P            10'b101000_0101
`define   D16_2_P            10'b100100_0101
`define   D17_2_P            10'b100011_0101
`define   D18_2_P            10'b010011_0101
`define   D19_2_P            10'b110010_0101
`define   D20_2_P            10'b001011_0101
`define   D21_2_P            10'b101010_0101
`define   D22_2_P            10'b011010_0101
`define   D23_2_P            10'b000101_0101
`define   D24_2_P            10'b001100_0101
`define   D25_2_P            10'b100110_0101
`define   D26_2_P            10'b010110_0101
`define   D27_2_P            10'b001001_0101
`define   D28_2_P            10'b001110_0101
`define   D29_2_P            10'b010001_0101
`define   D30_2_P            10'b100001_0101
`define   D31_2_P            10'b010100_0101

// data symbols - RD positive, abcdei_fghj
`define   D0_3_P             10'b011000_1100
`define   D1_3_P             10'b100010_1100
`define   D2_3_P             10'b010010_1100
`define   D3_3_P             10'b110001_0011
`define   D4_3_P             10'b001010_1100
`define   D5_3_P             10'b101001_0011
`define   D6_3_P             10'b011001_0011
`define   D7_3_P             10'b000111_0011
`define   D8_3_P             10'b000110_1100
`define   D9_3_P             10'b100101_0011
`define   D10_3_P            10'b010101_0011
`define   D11_3_P            10'b110100_0011
`define   D12_3_P            10'b001101_0011
`define   D13_3_P            10'b101100_0011
`define   D14_3_P            10'b011100_0011
`define   D15_3_P            10'b101000_1100
`define   D16_3_P            10'b100100_1100
`define   D17_3_P            10'b100011_0011
`define   D18_3_P            10'b010011_0011
`define   D19_3_P            10'b110010_0011
`define   D20_3_P            10'b001011_0011
`define   D21_3_P            10'b101010_0011
`define   D22_3_P            10'b011010_0011
`define   D23_3_P            10'b000101_1100
`define   D24_3_P            10'b001100_1100
`define   D25_3_P            10'b100110_0011
`define   D26_3_P            10'b010110_0011
`define   D27_3_P            10'b001001_1100
`define   D28_3_P            10'b001110_0011
`define   D29_3_P            10'b010001_1100
`define   D30_3_P            10'b100001_1100
`define   D31_3_P            10'b010100_1100

// data symbols - RD positive, abcdei_fghj
`define   D0_4_P             10'b011000_1101
`define   D1_4_P             10'b100010_1101
`define   D2_4_P             10'b010010_1101
`define   D3_4_P             10'b110001_0010
`define   D4_4_P             10'b001010_1101
`define   D5_4_P             10'b101001_0010
`define   D6_4_P             10'b011001_0010
`define   D7_4_P             10'b000111_0010
`define   D8_4_P             10'b000110_1101
`define   D9_4_P             10'b100101_0010
`define   D10_4_P            10'b010101_0010
`define   D11_4_P            10'b110100_0010
`define   D12_4_P            10'b001101_0010
`define   D13_4_P            10'b101100_0010
`define   D14_4_P            10'b011100_0010
`define   D15_4_P            10'b101000_1101
`define   D16_4_P            10'b100100_1101
`define   D17_4_P            10'b100011_0010
`define   D18_4_P            10'b010011_0010
`define   D19_4_P            10'b110010_0010
`define   D20_4_P            10'b001011_0010
`define   D21_4_P            10'b101010_0010
`define   D22_4_P            10'b011010_0010
`define   D23_4_P            10'b000101_1101
`define   D24_4_P            10'b001100_1101
`define   D25_4_P            10'b100110_0010
`define   D26_4_P            10'b010110_0010
`define   D27_4_P            10'b001001_1101
`define   D28_4_P            10'b001110_0010
`define   D29_4_P            10'b010001_1101
`define   D30_4_P            10'b100001_1101
`define   D31_4_P            10'b010100_1101

// data symbols - RD positive, abcdei_fghj
`define   D0_5_P             10'b011000_1010
`define   D1_5_P             10'b100010_1010
`define   D2_5_P             10'b010010_1010
`define   D3_5_P             10'b110001_1010
`define   D4_5_P             10'b001010_1010
`define   D5_5_P             10'b101001_1010
`define   D6_5_P             10'b011001_1010
`define   D7_5_P             10'b000111_1010
`define   D8_5_P             10'b000110_1010
`define   D9_5_P             10'b100101_1010
`define   D10_5_P            10'b010101_1010
`define   D11_5_P            10'b110100_1010
`define   D12_5_P            10'b001101_1010
`define   D13_5_P            10'b101100_1010
`define   D14_5_P            10'b011100_1010
`define   D15_5_P            10'b101000_1010
`define   D16_5_P            10'b100100_1010
`define   D17_5_P            10'b100011_1010
`define   D18_5_P            10'b010011_1010
`define   D19_5_P            10'b110010_1010
`define   D20_5_P            10'b001011_1010
`define   D21_5_P            10'b101010_1010
`define   D22_5_P            10'b011010_1010
`define   D23_5_P            10'b000101_1010
`define   D24_5_P            10'b001100_1010
`define   D25_5_P            10'b100110_1010
`define   D26_5_P            10'b010110_1010
`define   D27_5_P            10'b001001_1010
`define   D28_5_P            10'b001110_1010
`define   D29_5_P            10'b010001_1010
`define   D30_5_P            10'b100001_1010
`define   D31_5_P            10'b010100_1010

// data symbols - RD positive, abcdei_fghj
`define   D0_6_P             10'b011000_0110
`define   D1_6_P             10'b100010_0110
`define   D2_6_P             10'b010010_0110
`define   D3_6_P             10'b110001_0110
`define   D4_6_P             10'b001010_0110
`define   D5_6_P             10'b101001_0110
`define   D6_6_P             10'b011001_0110
`define   D7_6_P             10'b000111_0110
`define   D8_6_P             10'b000110_0110
`define   D9_6_P             10'b100101_0110
`define   D10_6_P            10'b010101_0110
`define   D11_6_P            10'b110100_0110
`define   D12_6_P            10'b001101_0110
`define   D13_6_P            10'b101100_0110
`define   D14_6_P            10'b011100_0110
`define   D15_6_P            10'b101000_0110
`define   D16_6_P            10'b100100_0110
`define   D17_6_P            10'b100011_0110
`define   D18_6_P            10'b010011_0110
`define   D19_6_P            10'b110010_0110
`define   D20_6_P            10'b001011_0110
`define   D21_6_P            10'b101010_0110
`define   D22_6_P            10'b011010_0110
`define   D23_6_P            10'b000101_0110
`define   D24_6_P            10'b001100_0110
`define   D25_6_P            10'b100110_0110
`define   D26_6_P            10'b010110_0110
`define   D27_6_P            10'b001001_0110
`define   D28_6_P            10'b001110_0110
`define   D29_6_P            10'b010001_0110
`define   D30_6_P            10'b100001_0110
`define   D31_6_P            10'b010100_0110

// data symbols - RD positive, abcdei_fghj
`define   D0_7_P             10'b011000_1110
`define   D1_7_P             10'b100010_1110
`define   D2_7_P             10'b010010_1110
`define   D3_7_P             10'b110001_0001
`define   D4_7_P             10'b001010_1110
`define   D5_7_P             10'b101001_0001
`define   D6_7_P             10'b011001_0001
`define   D7_7_P             10'b000111_0001
`define   D8_7_P             10'b000110_1110
`define   D9_7_P             10'b100101_0001
`define   D10_7_P            10'b010101_0001
`define   D11_7_P            10'b110100_1000
`define   D12_7_P            10'b001101_0001
`define   D13_7_P            10'b101100_1000
`define   D14_7_P            10'b011100_1000
`define   D15_7_P            10'b101000_1110
`define   D16_7_P            10'b100100_1110
`define   D17_7_P            10'b100011_0001
`define   D18_7_P            10'b010011_0001
`define   D19_7_P            10'b110010_0001
`define   D20_7_P            10'b001011_0001
`define   D21_7_P            10'b101010_0001
`define   D22_7_P            10'b011010_0001
`define   D23_7_P            10'b000101_1110
`define   D24_7_P            10'b001100_1110
`define   D25_7_P            10'b100110_0001
`define   D26_7_P            10'b010110_0001
`define   D27_7_P            10'b001001_1110
`define   D28_7_P            10'b001110_0001
`define   D29_7_P            10'b010001_1110
`define   D30_7_P            10'b100001_1110
`define   D31_7_P            10'b010100_1110

// ------------
// 8b symbols
// ------------

// control symbols
`define   K28_0_8B           8'h1C
`define   K28_1_8B           8'h3C
`define   K28_2_8B           8'h5C
`define   K28_3_8B           8'h7C
`define   K28_4_8B           8'h9C
`define   K28_5_8B           8'hBC
`define   K28_6_8B           8'hDC
`define   K28_7_8B           8'hFC
`define   K23_7_8B           8'hF7
`define   K27_7_8B           8'hFB
`define   K29_7_8B           8'hFD
`define   K30_7_8B           8'hFE


// data symbols

`define   D0_0_8B            8'h00
`define   D1_0_8B            8'h01
`define   D2_0_8B            8'h02
`define   D3_0_8B            8'h03
`define   D4_0_8B            8'h04
`define   D5_0_8B            8'h05
`define   D6_0_8B            8'h06
`define   D7_0_8B            8'h07
`define   D8_0_8B            8'h08
`define   D9_0_8B            8'h09
`define   D10_0_8B           8'h0A
`define   D11_0_8B           8'h0B
`define   D12_0_8B           8'h0C
`define   D13_0_8B           8'h0D
`define   D14_0_8B           8'h0E
`define   D15_0_8B           8'h0F
`define   D16_0_8B           8'h10
`define   D17_0_8B           8'h11
`define   D18_0_8B           8'h12
`define   D19_0_8B           8'h13
`define   D20_0_8B           8'h14
`define   D21_0_8B           8'h15
`define   D22_0_8B           8'h16
`define   D23_0_8B           8'h17
`define   D24_0_8B           8'h18
`define   D25_0_8B           8'h19
`define   D26_0_8B           8'h1A
`define   D27_0_8B           8'h1B
`define   D28_0_8B           8'h1C
`define   D29_0_8B           8'h1D
`define   D30_0_8B           8'h1E
`define   D31_0_8B           8'h1F

`define   D0_1_8B            8'h20
`define   D1_1_8B            8'h21
`define   D2_1_8B            8'h22
`define   D3_1_8B            8'h23
`define   D4_1_8B            8'h24
`define   D5_1_8B            8'h25
`define   D6_1_8B            8'h26
`define   D7_1_8B            8'h27
`define   D8_1_8B            8'h28
`define   D9_1_8B            8'h29
`define   D10_1_8B           8'h2A
`define   D11_1_8B           8'h2B
`define   D12_1_8B           8'h2C
`define   D13_1_8B           8'h2D
`define   D14_1_8B           8'h2E
`define   D15_1_8B           8'h2F
`define   D16_1_8B           8'h30
`define   D17_1_8B           8'h31
`define   D18_1_8B           8'h32
`define   D19_1_8B           8'h33
`define   D20_1_8B           8'h34
`define   D21_1_8B           8'h35
`define   D22_1_8B           8'h36
`define   D23_1_8B           8'h37
`define   D24_1_8B           8'h38
`define   D25_1_8B           8'h39
`define   D26_1_8B           8'h3A
`define   D27_1_8B           8'h3B
`define   D28_1_8B           8'h3C
`define   D29_1_8B           8'h3D
`define   D30_1_8B           8'h3E
`define   D31_1_8B           8'h3F

`define   D0_2_8B            8'h40
`define   D1_2_8B            8'h41
`define   D2_2_8B            8'h42
`define   D3_2_8B            8'h43
`define   D4_2_8B            8'h44
`define   D5_2_8B            8'h45
`define   D6_2_8B            8'h46
`define   D7_2_8B            8'h47
`define   D8_2_8B            8'h48
`define   D9_2_8B            8'h49
`define   D10_2_8B           8'h4A
`define   D11_2_8B           8'h4B
`define   D12_2_8B           8'h4C
`define   D13_2_8B           8'h4D
`define   D14_2_8B           8'h4E
`define   D15_2_8B           8'h4F
`define   D16_2_8B           8'h50
`define   D17_2_8B           8'h51
`define   D18_2_8B           8'h52
`define   D19_2_8B           8'h53
`define   D20_2_8B           8'h54
`define   D21_2_8B           8'h55
`define   D22_2_8B           8'h56
`define   D23_2_8B           8'h57
`define   D24_2_8B           8'h58
`define   D25_2_8B           8'h59
`define   D26_2_8B           8'h5A
`define   D27_2_8B           8'h5B
`define   D28_2_8B           8'h5C
`define   D29_2_8B           8'h5D
`define   D30_2_8B           8'h5E
`define   D31_2_8B           8'h5F

`define   D0_3_8B            8'h60
`define   D1_3_8B            8'h61
`define   D2_3_8B            8'h62
`define   D3_3_8B            8'h63
`define   D4_3_8B            8'h64
`define   D5_3_8B            8'h65
`define   D6_3_8B            8'h66
`define   D7_3_8B            8'h67
`define   D8_3_8B            8'h68
`define   D9_3_8B            8'h69
`define   D10_3_8B           8'h6A
`define   D11_3_8B           8'h6B
`define   D12_3_8B           8'h6C
`define   D13_3_8B           8'h6D
`define   D14_3_8B           8'h6E
`define   D15_3_8B           8'h6F
`define   D16_3_8B           8'h70
`define   D17_3_8B           8'h71
`define   D18_3_8B           8'h72
`define   D19_3_8B           8'h73
`define   D20_3_8B           8'h74
`define   D21_3_8B           8'h75
`define   D22_3_8B           8'h76
`define   D23_3_8B           8'h77
`define   D24_3_8B           8'h78
`define   D25_3_8B           8'h79
`define   D26_3_8B           8'h7A
`define   D27_3_8B           8'h7B
`define   D28_3_8B           8'h7C
`define   D29_3_8B           8'h7D
`define   D30_3_8B           8'h7E
`define   D31_3_8B           8'h7F

`define   D0_4_8B            8'h80
`define   D1_4_8B            8'h81
`define   D2_4_8B            8'h82
`define   D3_4_8B            8'h83
`define   D4_4_8B            8'h84
`define   D5_4_8B            8'h85
`define   D6_4_8B            8'h86
`define   D7_4_8B            8'h87
`define   D8_4_8B            8'h88
`define   D9_4_8B            8'h89
`define   D10_4_8B           8'h8A
`define   D11_4_8B           8'h8B
`define   D12_4_8B           8'h8C
`define   D13_4_8B           8'h8D
`define   D14_4_8B           8'h8E
`define   D15_4_8B           8'h8F
`define   D16_4_8B           8'h90
`define   D17_4_8B           8'h91
`define   D18_4_8B           8'h92
`define   D19_4_8B           8'h93
`define   D20_4_8B           8'h94
`define   D21_4_8B           8'h95
`define   D22_4_8B           8'h96
`define   D23_4_8B           8'h97
`define   D24_4_8B           8'h98
`define   D25_4_8B           8'h99
`define   D26_4_8B           8'h9A
`define   D27_4_8B           8'h9B
`define   D28_4_8B           8'h9C
`define   D29_4_8B           8'h9D
`define   D30_4_8B           8'h9E
`define   D31_4_8B           8'h9F

`define   D0_5_8B            8'hA0
`define   D1_5_8B            8'hA1
`define   D2_5_8B            8'hA2
`define   D3_5_8B            8'hA3
`define   D4_5_8B            8'hA4
`define   D5_5_8B            8'hA5
`define   D6_5_8B            8'hA6
`define   D7_5_8B            8'hA7
`define   D8_5_8B            8'hA8
`define   D9_5_8B            8'hA9
`define   D10_5_8B           8'hAA
`define   D11_5_8B           8'hAB
`define   D12_5_8B           8'hAC
`define   D13_5_8B           8'hAD
`define   D14_5_8B           8'hAE
`define   D15_5_8B           8'hAF
`define   D16_5_8B           8'hB0
`define   D17_5_8B           8'hB1
`define   D18_5_8B           8'hB2
`define   D19_5_8B           8'hB3
`define   D20_5_8B           8'hB4
`define   D21_5_8B           8'hB5
`define   D22_5_8B           8'hB6
`define   D23_5_8B           8'hB7
`define   D24_5_8B           8'hB8
`define   D25_5_8B           8'hB9
`define   D26_5_8B           8'hBA
`define   D27_5_8B           8'hBB
`define   D28_5_8B           8'hBC
`define   D29_5_8B           8'hBD
`define   D30_5_8B           8'hBE
`define   D31_5_8B           8'hBF

`define   D0_6_8B            8'hC0
`define   D1_6_8B            8'hC1
`define   D2_6_8B            8'hC2
`define   D3_6_8B            8'hC3
`define   D4_6_8B            8'hC4
`define   D5_6_8B            8'hC5
`define   D6_6_8B            8'hC6
`define   D7_6_8B            8'hC7
`define   D8_6_8B            8'hC8
`define   D9_6_8B            8'hC9
`define   D10_6_8B           8'hCA
`define   D11_6_8B           8'hCB
`define   D12_6_8B           8'hCC
`define   D13_6_8B           8'hCD
`define   D14_6_8B           8'hCE
`define   D15_6_8B           8'hCF
`define   D16_6_8B           8'hD0
`define   D17_6_8B           8'hD1
`define   D18_6_8B           8'hD2
`define   D19_6_8B           8'hD3
`define   D20_6_8B           8'hD4
`define   D21_6_8B           8'hD5
`define   D22_6_8B           8'hD6
`define   D23_6_8B           8'hD7
`define   D24_6_8B           8'hD8
`define   D25_6_8B           8'hD9
`define   D26_6_8B           8'hDA
`define   D27_6_8B           8'hDB
`define   D28_6_8B           8'hDC
`define   D29_6_8B           8'hDD
`define   D30_6_8B           8'hDE
`define   D31_6_8B           8'hDF

`define   D0_7_8B            8'hE0
`define   D1_7_8B            8'hE1
`define   D2_7_8B            8'hE2
`define   D3_7_8B            8'hE3
`define   D4_7_8B            8'hE4
`define   D5_7_8B            8'hE5
`define   D6_7_8B            8'hE6
`define   D7_7_8B            8'hE7
`define   D8_7_8B            8'hE8
`define   D9_7_8B            8'hE9
`define   D10_7_8B           8'hEA
`define   D11_7_8B           8'hEB
`define   D12_7_8B           8'hEC
`define   D13_7_8B           8'hED
`define   D14_7_8B           8'hEE
`define   D15_7_8B           8'hEF
`define   D16_7_8B           8'hF0
`define   D17_7_8B           8'hF1
`define   D18_7_8B           8'hF2
`define   D19_7_8B           8'hF3
`define   D20_7_8B           8'hF4
`define   D21_7_8B           8'hF5
`define   D22_7_8B           8'hF6
`define   D23_7_8B           8'hF7
`define   D24_7_8B           8'hF8
`define   D25_7_8B           8'hF9
`define   D26_7_8B           8'hFA
`define   D27_7_8B           8'hFB
`define   D28_7_8B           8'hFC
`define   D29_7_8B           8'hFD
`define   D30_7_8B           8'hFE
`define   D31_7_8B           8'hFF

// --------------
// 40b primitives 
// ---------------

`define   FC_IDLE0_PRIM        { `D21_5_P, `D21_5_N, `D21_4_N, `K28_5_P }
`define   FC_IDLE1_PRIM        { `D21_5_P, `D21_5_N, `D21_4_P, `K28_5_N }
`define   FC_ARBFF0_PRIM       { `D31_7_P, `D31_7_N, `D20_4_P, `K28_5_N }
`define   FC_ARBFF1_PRIM       { `D31_7_N, `D31_7_P, `D20_4_N, `K28_5_P }


// --------------
// 32b primitives 
// ---------------

// EOF primitives, positive and negative disparity
// use positive disparity ordered set if beginning disparity is positive, and vice versa
`define   EOF_F_N_8B           { `D21_3_8B, `D21_3_8B, `D21_4_8B, `K28_5_8B }         // EOF terminate
`define   EOF_F_P_8B           { `D21_3_8B, `D21_3_8B, `D21_5_8B, `K28_5_8B }         // EOF terminate
`define   EOF_DT_N_8B          { `D21_4_8B, `D21_4_8B, `D21_4_8B, `K28_5_8B }         // EOF disconnect-terminate (class 1 or class 4)
`define   EOF_DT_P_8B          { `D21_4_8B, `D21_4_8B, `D21_5_8B, `K28_5_8B }         // EOF disconnect-terminate (class 1 or class 4)
`define   EOF_A_N_8B           { `D21_7_8B, `D21_7_8B, `D21_4_8B, `K28_5_8B }         // EOF abort
`define   EOF_A_P_8B           { `D21_7_8B, `D21_7_8B, `D21_5_8B, `K28_5_8B }         // EOF abort
`define   EOF_N_N_8B           { `D21_6_8B, `D21_6_8B, `D21_4_8B, `K28_5_8B }         // EOF normal
`define   EOF_N_P_8B           { `D21_6_8B, `D21_6_8B, `D21_5_8B, `K28_5_8B }         // EOF normal
`define   EOF_NI_N_8B          { `D21_6_8B, `D21_6_8B, `D10_4_8B, `K28_5_8B }         // EOF normal-invalid
`define   EOF_NI_P_8B          { `D21_6_8B, `D21_6_8B, `D10_5_8B, `K28_5_8B }         // EOF normal-invalis
`define   EOF_DTI_N_8B         { `D21_4_8B, `D21_4_8B, `D10_4_8B, `K28_5_8B }         // EOF disconnect-terminate-invalid (class 1 or class 4)
`define   EOF_DTI_P_8B         { `D21_4_8B, `D21_4_8B, `D10_5_8B, `K28_5_8B }         // EOF disconnect-terminate-invalid (class 1 or class 4)
`define   EOF_RT_N_8B          { `D25_4_8B, `D25_4_8B, `D21_4_8B, `K28_5_8B }         // EOF remove-terminate (class 4)
`define   EOF_RT_P_8B          { `D25_4_8B, `D25_4_8B, `D21_5_8B, `K28_5_8B }         // EOF remove-terminate (class 4)
`define   EOF_RTI_N_8B         { `D25_4_8B, `D25_4_8B, `D10_4_8B, `K28_5_8B }         // EOF remove-terminate-invalid (class 4)
`define   EOF_RTI_P_8B         { `D25_4_8B, `D25_4_8B, `D10_5_8B, `K28_5_8B }         // EOF remove-terminate-invalid (class 4)               

// SOF primitives, always starts with negative disparity
`define   SOF_C1_8B            { `D23_0_8B, `D23_0_8B, `D21_5_8B, `K28_5_8B }         // SOF connect  class 1
`define   SOF_I1_8B            { `D23_2_8B, `D23_2_8B, `D21_5_8B, `K28_5_8B }         // SOF initiate class 1
`define   SOF_N1_8B            { `D23_1_8B, `D23_1_8B, `D21_5_8B, `K28_5_8B }         // SOF normal   class 1
`define   SOF_I2_8B            { `D21_2_8B, `D21_2_8B, `D21_5_8B, `K28_5_8B }         // SOF initiate class 2
`define   SOF_N2_8B            { `D21_1_8B, `D21_1_8B, `D21_5_8B, `K28_5_8B }         // SOF normal   class 2
`define   SOF_I3_8B            { `D22_2_8B, `D22_2_8B, `D21_5_8B, `K28_5_8B }         // SOF initiate class 3
`define   SOF_N3_8B            { `D22_1_8B, `D22_1_8B, `D21_5_8B, `K28_5_8B }         // SOF normal   class 3
`define   SOF_A4_8B            { `D25_0_8B, `D25_0_8B, `D21_5_8B, `K28_5_8B }         // SOF active   class 4
`define   SOF_I4_8B            { `D25_2_8B, `D25_2_8B, `D21_5_8B, `K28_5_8B }         // SOF initiate class 4
`define   SOF_N4_8B            { `D25_1_8B, `D25_1_8B, `D21_5_8B, `K28_5_8B }         // SOF normal   class 4
`define   SOF_F_8B             { `D24_2_8B, `D24_2_8B, `D21_5_8B, `K28_5_8B }         // SOF fabric        

// IDLE primitives, always starts with negative disparity
`define   IDLE0_8B            { `D21_5_8B, `D21_5_8B, `D21_4_8B, `K28_5_8B }          // IDLE
`define   IDLE1_8B            { `D31_7_8B, `D31_7_8B, `D20_4_8B, `K28_5_8B }          // IDLE

// --------------
// Misc
// ---------------

`define MAX_VALUE_16          16'hFFFF
`define MAX_VALUE_32          32'hFFFF_FFFF
`define MAX_VALUE_48          48'hFFFF_FFFF_FFFF
`define MAX_VALUE_64          64'hFFFF_FFFF_FFFF_FFFF
