// megafunction wizard: %LPM_MUX%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_MUX 

// ============================================================
// File Name: s5_mux14_96b_1cycle.v
// Megafunction Name(s):
// 			LPM_MUX
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 12.1 Build 177 11/07/2012 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2012 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module s5_mux14_96b_1cycle (
	aclr,
	clock,
	data0x,
	data10x,
	data11x,
	data12x,
	data13x,
	data1x,
	data2x,
	data3x,
	data4x,
	data5x,
	data6x,
	data7x,
	data8x,
	data9x,
	sel,
	result);

	input	  aclr;
	input	  clock;
	input	[95:0]  data0x;
	input	[95:0]  data10x;
	input	[95:0]  data11x;
	input	[95:0]  data12x;
	input	[95:0]  data13x;
	input	[95:0]  data1x;
	input	[95:0]  data2x;
	input	[95:0]  data3x;
	input	[95:0]  data4x;
	input	[95:0]  data5x;
	input	[95:0]  data6x;
	input	[95:0]  data7x;
	input	[95:0]  data8x;
	input	[95:0]  data9x;
	input	[3:0]  sel;
	output	[95:0]  result;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0	  aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [95:0] sub_wire0;
	wire [95:0] sub_wire15 = data13x[95:0];
	wire [95:0] sub_wire14 = data12x[95:0];
	wire [95:0] sub_wire13 = data11x[95:0];
	wire [95:0] sub_wire12 = data10x[95:0];
	wire [95:0] sub_wire11 = data9x[95:0];
	wire [95:0] sub_wire10 = data8x[95:0];
	wire [95:0] sub_wire9 = data7x[95:0];
	wire [95:0] sub_wire8 = data6x[95:0];
	wire [95:0] sub_wire7 = data5x[95:0];
	wire [95:0] sub_wire6 = data4x[95:0];
	wire [95:0] sub_wire5 = data3x[95:0];
	wire [95:0] sub_wire4 = data2x[95:0];
	wire [95:0] sub_wire3 = data1x[95:0];
	wire [95:0] result = sub_wire0[95:0];
	wire [95:0] sub_wire1 = data0x[95:0];
	wire [1343:0] sub_wire2 = {sub_wire15, sub_wire14, sub_wire13, sub_wire12, sub_wire11, sub_wire10, sub_wire9, sub_wire8, sub_wire7, sub_wire6, sub_wire5, sub_wire4, sub_wire3, sub_wire1};

	lpm_mux	LPM_MUX_component (
				.aclr (aclr),
				.clock (clock),
				.data (sub_wire2),
				.sel (sel),
				.result (sub_wire0)
				// synopsys translate_off
				,
				.clken ()
				// synopsys translate_on
				);
	defparam
		LPM_MUX_component.lpm_pipeline = 1,
		LPM_MUX_component.lpm_size = 14,
		LPM_MUX_component.lpm_type = "LPM_MUX",
		LPM_MUX_component.lpm_width = 96,
		LPM_MUX_component.lpm_widths = 4;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix V"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "1"
// Retrieval info: CONSTANT: LPM_SIZE NUMERIC "14"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_MUX"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "96"
// Retrieval info: CONSTANT: LPM_WIDTHS NUMERIC "4"
// Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT GND "aclr"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: data0x 0 0 96 0 INPUT NODEFVAL "data0x[95..0]"
// Retrieval info: USED_PORT: data10x 0 0 96 0 INPUT NODEFVAL "data10x[95..0]"
// Retrieval info: USED_PORT: data11x 0 0 96 0 INPUT NODEFVAL "data11x[95..0]"
// Retrieval info: USED_PORT: data12x 0 0 96 0 INPUT NODEFVAL "data12x[95..0]"
// Retrieval info: USED_PORT: data13x 0 0 96 0 INPUT NODEFVAL "data13x[95..0]"
// Retrieval info: USED_PORT: data1x 0 0 96 0 INPUT NODEFVAL "data1x[95..0]"
// Retrieval info: USED_PORT: data2x 0 0 96 0 INPUT NODEFVAL "data2x[95..0]"
// Retrieval info: USED_PORT: data3x 0 0 96 0 INPUT NODEFVAL "data3x[95..0]"
// Retrieval info: USED_PORT: data4x 0 0 96 0 INPUT NODEFVAL "data4x[95..0]"
// Retrieval info: USED_PORT: data5x 0 0 96 0 INPUT NODEFVAL "data5x[95..0]"
// Retrieval info: USED_PORT: data6x 0 0 96 0 INPUT NODEFVAL "data6x[95..0]"
// Retrieval info: USED_PORT: data7x 0 0 96 0 INPUT NODEFVAL "data7x[95..0]"
// Retrieval info: USED_PORT: data8x 0 0 96 0 INPUT NODEFVAL "data8x[95..0]"
// Retrieval info: USED_PORT: data9x 0 0 96 0 INPUT NODEFVAL "data9x[95..0]"
// Retrieval info: USED_PORT: result 0 0 96 0 OUTPUT NODEFVAL "result[95..0]"
// Retrieval info: USED_PORT: sel 0 0 4 0 INPUT NODEFVAL "sel[3..0]"
// Retrieval info: CONNECT: @aclr 0 0 0 0 aclr 0 0 0 0
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @data 0 0 96 0 data0x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 960 data10x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 1056 data11x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 1152 data12x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 1248 data13x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 96 data1x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 192 data2x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 288 data3x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 384 data4x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 480 data5x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 576 data6x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 672 data7x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 768 data8x 0 0 96 0
// Retrieval info: CONNECT: @data 0 0 96 864 data9x 0 0 96 0
// Retrieval info: CONNECT: @sel 0 0 4 0 sel 0 0 4 0
// Retrieval info: CONNECT: result 0 0 96 0 @result 0 0 96 0
// Retrieval info: GEN_FILE: TYPE_NORMAL s5_mux14_96b_1cycle.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL s5_mux14_96b_1cycle.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL s5_mux14_96b_1cycle.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL s5_mux14_96b_1cycle.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL s5_mux14_96b_1cycle_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL s5_mux14_96b_1cycle_bb.v TRUE
// Retrieval info: LIB_FILE: lpm
