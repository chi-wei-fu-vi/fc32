/*WARNING****WARNING****WARNING****
This File is auto-generated.  DO NOT EDIT.
All changes will be lost....
WARNING****WARNING****WARNING******/


/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-02-16 09:42:40 -0800 (Sun, 16 Feb 2014) $
* $Revision: 4697 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


module err_detect(
	input   CLK,
	input   RST,
	input   [31:0] SYNDR,
	input   SYNDR_VAL,
	output  reg     [64:0] CORR_VECTOR,
	output  reg     [9:0]  CARRY_VECTOR,
	output  reg     CORR_VAL,
	output  reg     [10:0] CORR_FIELD
);

/////////////////////////////////////
// rotated syndrome register
// SYNDR => rot_syndrome_p65 : 3 lvl, 353mhz
// rot_syndrome_p65 c2c : 3 lvl, 450mhz
/////////////////////////////////////

reg     [31:0] rot_syndrome, rot_syndrome_p32, rot_syndrome_p65;
wire    [31:0] next_rot_32, next_rot_0, next_rot_65, next_rot_n2112, next_rot_n2112_p32, next_rot_n2112_p64, next_rot_n2112_p65;

fec_rot_32 fr32_p0  (.c(rot_syndrome_p65), .co (next_rot_0));
fec_rot_32 fr32_p32 (.c(next_rot_0), .co       (next_rot_32));
fec_rot_1  fr32_p64 (.c(next_rot_32), .co      (next_rot_65));

fec_rot_n2112 frn2112      (.c (SYNDR), .co    (next_rot_n2112));
fec_rot_32    frn2112_fr32 (.c (next_rot_n2112), .co   (next_rot_n2112_p32));
fec_rot_32    frn2112_fr64 (.c (next_rot_n2112_p32), .co       (next_rot_n2112_p64));
fec_rot_1     frn2112_fr65 (.c (next_rot_n2112_p64), .co       (next_rot_n2112_p65));

always @(posedge CLK) begin
	if (RST) 
	begin
		rot_syndrome     <= 0;
		rot_syndrome_p32 <= 0;
		rot_syndrome_p65 <= 0;
	end
	else 
	begin
		rot_syndrome     <= SYNDR_VAL ? next_rot_n2112_p32 : next_rot_0;
		rot_syndrome_p32 <= SYNDR_VAL ? next_rot_n2112_p64 : next_rot_32;
		rot_syndrome_p65 <= SYNDR_VAL ? next_rot_n2112_p65 : next_rot_65;
	end
end

/////////////////////////////////////
// unroll 1 word by bits
/////////////////////////////////////

wire    [65*32-1:0] rsyns_w;
reg     [65*32-1:0] rsyns;
//wire [32*32-1:0] rsyns_w1;
//reg  [32*32-1:0] rsyns1;

wire    [31:0] rsyns_w_0;
reg     [31:0] rsyns_w_s_0;
wire    [31:0] rsyns_w_1;
reg     [31:0] rsyns_w_s_1;
wire    [31:0] rsyns_w_2;
reg     [31:0] rsyns_w_s_2;
wire    [31:0] rsyns_w_3;
reg     [31:0] rsyns_w_s_3;
wire    [31:0] rsyns_w_4;
reg     [31:0] rsyns_w_s_4;
wire    [31:0] rsyns_w_5;
reg     [31:0] rsyns_w_s_5;
wire    [31:0] rsyns_w_6;
reg     [31:0] rsyns_w_s_6;
wire    [31:0] rsyns_w_7;
reg     [31:0] rsyns_w_s_7;
wire    [31:0] rsyns_w_8;
reg     [31:0] rsyns_w_s_8;
wire    [31:0] rsyns_w_9;
reg     [31:0] rsyns_w_s_9;
wire    [31:0] rsyns_w_10;
reg     [31:0] rsyns_w_s_10;
wire    [31:0] rsyns_w_11;
reg     [31:0] rsyns_w_s_11;
wire    [31:0] rsyns_w_12;
reg     [31:0] rsyns_w_s_12;
wire    [31:0] rsyns_w_13;
reg     [31:0] rsyns_w_s_13;
wire    [31:0] rsyns_w_14;
reg     [31:0] rsyns_w_s_14;
wire    [31:0] rsyns_w_15;
reg     [31:0] rsyns_w_s_15;
wire    [31:0] rsyns_w_16;
reg     [31:0] rsyns_w_s_16;
wire    [31:0] rsyns_w_17;
reg     [31:0] rsyns_w_s_17;
wire    [31:0] rsyns_w_18;
reg     [31:0] rsyns_w_s_18;
wire    [31:0] rsyns_w_19;
reg     [31:0] rsyns_w_s_19;
wire    [31:0] rsyns_w_20;
reg     [31:0] rsyns_w_s_20;
wire    [31:0] rsyns_w_21;
reg     [31:0] rsyns_w_s_21;
wire    [31:0] rsyns_w_22;
reg     [31:0] rsyns_w_s_22;
wire    [31:0] rsyns_w_23;
reg     [31:0] rsyns_w_s_23;
wire    [31:0] rsyns_w_24;
reg     [31:0] rsyns_w_s_24;
wire    [31:0] rsyns_w_25;
reg     [31:0] rsyns_w_s_25;
wire    [31:0] rsyns_w_26;
reg     [31:0] rsyns_w_s_26;
wire    [31:0] rsyns_w_27;
reg     [31:0] rsyns_w_s_27;
wire    [31:0] rsyns_w_28;
reg     [31:0] rsyns_w_s_28;
wire    [31:0] rsyns_w_29;
reg     [31:0] rsyns_w_s_29;
wire    [31:0] rsyns_w_30;
reg     [31:0] rsyns_w_s_30;
wire    [31:0] rsyns_w_31;
reg     [31:0] rsyns_w_s_31;
wire    [31:0] rsyns_w_32;
reg     [31:0] rsyns_w_s_32;
wire    [31:0] rsyns_w_33;
reg     [31:0] rsyns_w_s_33;
wire    [31:0] rsyns_w_34;
reg     [31:0] rsyns_w_s_34;
wire    [31:0] rsyns_w_35;
reg     [31:0] rsyns_w_s_35;
wire    [31:0] rsyns_w_36;
reg     [31:0] rsyns_w_s_36;
wire    [31:0] rsyns_w_37;
reg     [31:0] rsyns_w_s_37;
wire    [31:0] rsyns_w_38;
reg     [31:0] rsyns_w_s_38;
wire    [31:0] rsyns_w_39;
reg     [31:0] rsyns_w_s_39;
wire    [31:0] rsyns_w_40;
reg     [31:0] rsyns_w_s_40;
wire    [31:0] rsyns_w_41;
reg     [31:0] rsyns_w_s_41;
wire    [31:0] rsyns_w_42;
reg     [31:0] rsyns_w_s_42;
wire    [31:0] rsyns_w_43;
reg     [31:0] rsyns_w_s_43;
wire    [31:0] rsyns_w_44;
reg     [31:0] rsyns_w_s_44;
wire    [31:0] rsyns_w_45;
reg     [31:0] rsyns_w_s_45;
wire    [31:0] rsyns_w_46;
reg     [31:0] rsyns_w_s_46;
wire    [31:0] rsyns_w_47;
reg     [31:0] rsyns_w_s_47;
wire    [31:0] rsyns_w_48;
reg     [31:0] rsyns_w_s_48;
wire    [31:0] rsyns_w_49;
reg     [31:0] rsyns_w_s_49;
wire    [31:0] rsyns_w_50;
reg     [31:0] rsyns_w_s_50;
wire    [31:0] rsyns_w_51;
reg     [31:0] rsyns_w_s_51;
wire    [31:0] rsyns_w_52;
reg     [31:0] rsyns_w_s_52;
wire    [31:0] rsyns_w_53;
reg     [31:0] rsyns_w_s_53;
wire    [31:0] rsyns_w_54;
reg     [31:0] rsyns_w_s_54;
wire    [31:0] rsyns_w_55;
reg     [31:0] rsyns_w_s_55;
wire    [31:0] rsyns_w_56;
reg     [31:0] rsyns_w_s_56;
wire    [31:0] rsyns_w_57;
reg     [31:0] rsyns_w_s_57;
wire    [31:0] rsyns_w_58;
reg     [31:0] rsyns_w_s_58;
wire    [31:0] rsyns_w_59;
reg     [31:0] rsyns_w_s_59;
wire    [31:0] rsyns_w_60;
reg     [31:0] rsyns_w_s_60;
wire    [31:0] rsyns_w_61;
reg     [31:0] rsyns_w_s_61;
wire    [31:0] rsyns_w_62;
reg     [31:0] rsyns_w_s_62;
wire    [31:0] rsyns_w_63;
reg     [31:0] rsyns_w_s_63;
wire    [31:0] rsyns_w_64;
reg     [31:0] rsyns_w_s_64;

wire [64:0]    err_trap_pre;
reg  [64:0]    err_trap;

// Error trap
reg     [10:0] corr_field0;
wire    [10:0] corr_field_s0;
reg     [10:0] corr_field1;
wire    [10:0] corr_field_s1;
reg     [10:0] corr_field2;
wire    [10:0] corr_field_s2;
reg     [10:0] corr_field3;
wire    [10:0] corr_field_s3;
reg     [10:0] corr_field4;
wire    [10:0] corr_field_s4;
reg     [10:0] corr_field5;
wire    [10:0] corr_field_s5;
reg     [10:0] corr_field6;
wire    [10:0] corr_field_s6;
reg     [10:0] corr_field7;
wire    [10:0] corr_field_s7;
reg     [10:0] corr_field8;
wire    [10:0] corr_field_s8;
reg     [10:0] corr_field9;
wire    [10:0] corr_field_s9;
reg     [10:0] corr_field10;
wire    [10:0] corr_field_s10;
reg     [10:0] corr_field11;
wire    [10:0] corr_field_s11;
reg     [10:0] corr_field12;
wire    [10:0] corr_field_s12;
reg     [10:0] corr_field13;
wire    [10:0] corr_field_s13;
reg     [10:0] corr_field14;
wire    [10:0] corr_field_s14;
reg     [10:0] corr_field15;
wire    [10:0] corr_field_s15;
reg     [10:0] corr_field16;
wire    [10:0] corr_field_s16;
reg     [10:0] corr_field17;
wire    [10:0] corr_field_s17;
reg     [10:0] corr_field18;
wire    [10:0] corr_field_s18;
reg     [10:0] corr_field19;
wire    [10:0] corr_field_s19;
reg     [10:0] corr_field20;
wire    [10:0] corr_field_s20;
reg     [10:0] corr_field21;
wire    [10:0] corr_field_s21;
reg     [10:0] corr_field22;
wire    [10:0] corr_field_s22;
reg     [10:0] corr_field23;
wire    [10:0] corr_field_s23;
reg     [10:0] corr_field24;
wire    [10:0] corr_field_s24;
reg     [10:0] corr_field25;
wire    [10:0] corr_field_s25;
reg     [10:0] corr_field26;
wire    [10:0] corr_field_s26;
reg     [10:0] corr_field27;
wire    [10:0] corr_field_s27;
reg     [10:0] corr_field28;
wire    [10:0] corr_field_s28;
reg     [10:0] corr_field29;
wire    [10:0] corr_field_s29;
reg     [10:0] corr_field30;
wire    [10:0] corr_field_s30;
reg     [10:0] corr_field31;
wire    [10:0] corr_field_s31;
reg     [10:0] corr_field32;
wire    [10:0] corr_field_s32;
reg     [10:0] corr_field33;
wire    [10:0] corr_field_s33;
reg     [10:0] corr_field34;
wire    [10:0] corr_field_s34;
reg     [10:0] corr_field35;
wire    [10:0] corr_field_s35;
reg     [10:0] corr_field36;
wire    [10:0] corr_field_s36;
reg     [10:0] corr_field37;
wire    [10:0] corr_field_s37;
reg     [10:0] corr_field38;
wire    [10:0] corr_field_s38;
reg     [10:0] corr_field39;
wire    [10:0] corr_field_s39;
reg     [10:0] corr_field40;
wire    [10:0] corr_field_s40;
reg     [10:0] corr_field41;
wire    [10:0] corr_field_s41;
reg     [10:0] corr_field42;
wire    [10:0] corr_field_s42;
reg     [10:0] corr_field43;
wire    [10:0] corr_field_s43;
reg     [10:0] corr_field44;
wire    [10:0] corr_field_s44;
reg     [10:0] corr_field45;
wire    [10:0] corr_field_s45;
reg     [10:0] corr_field46;
wire    [10:0] corr_field_s46;
reg     [10:0] corr_field47;
wire    [10:0] corr_field_s47;
reg     [10:0] corr_field48;
wire    [10:0] corr_field_s48;
reg     [10:0] corr_field49;
wire    [10:0] corr_field_s49;
reg     [10:0] corr_field50;
wire    [10:0] corr_field_s50;
reg     [10:0] corr_field51;
wire    [10:0] corr_field_s51;
reg     [10:0] corr_field52;
wire    [10:0] corr_field_s52;
reg     [10:0] corr_field53;
wire    [10:0] corr_field_s53;
reg     [10:0] corr_field54;
wire    [10:0] corr_field_s54;
reg     [10:0] corr_field55;
wire    [10:0] corr_field_s55;
reg     [10:0] corr_field56;
wire    [10:0] corr_field_s56;
reg     [10:0] corr_field57;
wire    [10:0] corr_field_s57;
reg     [10:0] corr_field58;
wire    [10:0] corr_field_s58;
reg     [10:0] corr_field59;
wire    [10:0] corr_field_s59;
reg     [10:0] corr_field60;
wire    [10:0] corr_field_s60;
reg     [10:0] corr_field61;
wire    [10:0] corr_field_s61;
reg     [10:0] corr_field62;
wire    [10:0] corr_field_s62;
reg     [10:0] corr_field63;
wire    [10:0] corr_field_s63;
reg     [10:0] corr_field64;
wire    [10:0] corr_field_s64;
reg     err_trap_s;
//reg        err_trap_ss;


assign  rsyns_w [31:0] =  rot_syndrome;
fec_rot_1 fr_0_1 (.c (rot_syndrome), .co     (rsyns_w[63:32]));
fec_rot_2 fr_0_2 (.c (rot_syndrome), .co     (rsyns_w[95:64]));
fec_rot_3 fr_0_3 (.c (rot_syndrome), .co     (rsyns_w[127:96]));
fec_rot_4 fr_0_4 (.c (rot_syndrome), .co     (rsyns_w[159:128]));
fec_rot_5 fr_0_5 (.c (rot_syndrome), .co     (rsyns_w[191:160]));
fec_rot_6 fr_0_6 (.c (rot_syndrome), .co     (rsyns_w[223:192]));
fec_rot_7 fr_0_7 (.c (rot_syndrome), .co     (rsyns_w[255:224]));
fec_rot_8 fr_0_8 (.c (rot_syndrome), .co     (rsyns_w[287:256]));
fec_rot_9 fr_0_9 (.c (rot_syndrome), .co     (rsyns_w[319:288]));
fec_rot_10 fr_0_10 (.c (rot_syndrome), .co     (rsyns_w[351:320]));
fec_rot_11 fr_0_11 (.c (rot_syndrome), .co     (rsyns_w[383:352]));
fec_rot_12 fr_0_12 (.c (rot_syndrome), .co     (rsyns_w[415:384]));
fec_rot_13 fr_0_13 (.c (rot_syndrome), .co     (rsyns_w[447:416]));
fec_rot_14 fr_0_14 (.c (rot_syndrome), .co     (rsyns_w[479:448]));
fec_rot_15 fr_0_15 (.c (rot_syndrome), .co     (rsyns_w[511:480]));
fec_rot_16 fr_0_16 (.c (rot_syndrome), .co     (rsyns_w[543:512]));
fec_rot_17 fr_0_17 (.c (rot_syndrome), .co     (rsyns_w[575:544]));
fec_rot_18 fr_0_18 (.c (rot_syndrome), .co     (rsyns_w[607:576]));
fec_rot_19 fr_0_19 (.c (rot_syndrome), .co     (rsyns_w[639:608]));
fec_rot_20 fr_0_20 (.c (rot_syndrome), .co     (rsyns_w[671:640]));
fec_rot_21 fr_0_21 (.c (rot_syndrome), .co     (rsyns_w[703:672]));
fec_rot_22 fr_0_22 (.c (rot_syndrome), .co     (rsyns_w[735:704]));
fec_rot_23 fr_0_23 (.c (rot_syndrome), .co     (rsyns_w[767:736]));
fec_rot_24 fr_0_24 (.c (rot_syndrome), .co     (rsyns_w[799:768]));
fec_rot_25 fr_0_25 (.c (rot_syndrome), .co     (rsyns_w[831:800]));
fec_rot_26 fr_0_26 (.c (rot_syndrome), .co     (rsyns_w[863:832]));
fec_rot_27 fr_0_27 (.c (rot_syndrome), .co     (rsyns_w[895:864]));
fec_rot_28 fr_0_28 (.c (rot_syndrome), .co     (rsyns_w[927:896]));
fec_rot_29 fr_0_29 (.c (rot_syndrome), .co     (rsyns_w[959:928]));
fec_rot_30 fr_0_30 (.c (rot_syndrome), .co     (rsyns_w[991:960]));
fec_rot_31 fr_0_31 (.c (rot_syndrome), .co     (rsyns_w[1023:992]));
assign  rsyns_w[1055:1024] =  rot_syndrome_p32;
fec_rot_1 fr_1_1 (.c (rot_syndrome_p32), .co (rsyns_w[1087:1056]));
fec_rot_2 fr_1_2 (.c (rot_syndrome_p32), .co (rsyns_w[1119:1088]));
fec_rot_3 fr_1_3 (.c (rot_syndrome_p32), .co (rsyns_w[1151:1120]));
fec_rot_4 fr_1_4 (.c (rot_syndrome_p32), .co (rsyns_w[1183:1152]));
fec_rot_5 fr_1_5 (.c (rot_syndrome_p32), .co (rsyns_w[1215:1184]));
fec_rot_6 fr_1_6 (.c (rot_syndrome_p32), .co (rsyns_w[1247:1216]));
fec_rot_7 fr_1_7 (.c (rot_syndrome_p32), .co (rsyns_w[1279:1248]));
fec_rot_8 fr_1_8 (.c (rot_syndrome_p32), .co (rsyns_w[1311:1280]));
fec_rot_9 fr_1_9 (.c (rot_syndrome_p32), .co (rsyns_w[1343:1312]));
fec_rot_10 fr_1_10 (.c (rot_syndrome_p32), .co (rsyns_w[1375:1344]));
fec_rot_11 fr_1_11 (.c (rot_syndrome_p32), .co (rsyns_w[1407:1376]));
fec_rot_12 fr_1_12 (.c (rot_syndrome_p32), .co (rsyns_w[1439:1408]));
fec_rot_13 fr_1_13 (.c (rot_syndrome_p32), .co (rsyns_w[1471:1440]));
fec_rot_14 fr_1_14 (.c (rot_syndrome_p32), .co (rsyns_w[1503:1472]));
fec_rot_15 fr_1_15 (.c (rot_syndrome_p32), .co (rsyns_w[1535:1504]));
fec_rot_16 fr_1_16 (.c (rot_syndrome_p32), .co (rsyns_w[1567:1536]));
fec_rot_17 fr_1_17 (.c (rot_syndrome_p32), .co (rsyns_w[1599:1568]));
fec_rot_18 fr_1_18 (.c (rot_syndrome_p32), .co (rsyns_w[1631:1600]));
fec_rot_19 fr_1_19 (.c (rot_syndrome_p32), .co (rsyns_w[1663:1632]));
fec_rot_20 fr_1_20 (.c (rot_syndrome_p32), .co (rsyns_w[1695:1664]));
fec_rot_21 fr_1_21 (.c (rot_syndrome_p32), .co (rsyns_w[1727:1696]));
fec_rot_22 fr_1_22 (.c (rot_syndrome_p32), .co (rsyns_w[1759:1728]));
fec_rot_23 fr_1_23 (.c (rot_syndrome_p32), .co (rsyns_w[1791:1760]));
fec_rot_24 fr_1_24 (.c (rot_syndrome_p32), .co (rsyns_w[1823:1792]));
fec_rot_25 fr_1_25 (.c (rot_syndrome_p32), .co (rsyns_w[1855:1824]));
fec_rot_26 fr_1_26 (.c (rot_syndrome_p32), .co (rsyns_w[1887:1856]));
fec_rot_27 fr_1_27 (.c (rot_syndrome_p32), .co (rsyns_w[1919:1888]));
fec_rot_28 fr_1_28 (.c (rot_syndrome_p32), .co (rsyns_w[1951:1920]));
fec_rot_29 fr_1_29 (.c (rot_syndrome_p32), .co (rsyns_w[1983:1952]));
fec_rot_30 fr_1_30 (.c (rot_syndrome_p32), .co (rsyns_w[2015:1984]));
fec_rot_31 fr_1_31 (.c (rot_syndrome_p32), .co (rsyns_w[2047:2016]));
assign  rsyns_w[2079:2048] =  rot_syndrome_p65;

assign  rsyns_w_0 =  rsyns_w[31:0];
assign  rsyns_w_1 =  rsyns_w[63:32];
assign  rsyns_w_2 =  rsyns_w[95:64];
assign  rsyns_w_3 =  rsyns_w[127:96];
assign  rsyns_w_4 =  rsyns_w[159:128];
assign  rsyns_w_5 =  rsyns_w[191:160];
assign  rsyns_w_6 =  rsyns_w[223:192];
assign  rsyns_w_7 =  rsyns_w[255:224];
assign  rsyns_w_8 =  rsyns_w[287:256];
assign  rsyns_w_9 =  rsyns_w[319:288];
assign  rsyns_w_10 =  rsyns_w[351:320];
assign  rsyns_w_11 =  rsyns_w[383:352];
assign  rsyns_w_12 =  rsyns_w[415:384];
assign  rsyns_w_13 =  rsyns_w[447:416];
assign  rsyns_w_14 =  rsyns_w[479:448];
assign  rsyns_w_15 =  rsyns_w[511:480];
assign  rsyns_w_16 =  rsyns_w[543:512];
assign  rsyns_w_17 =  rsyns_w[575:544];
assign  rsyns_w_18 =  rsyns_w[607:576];
assign  rsyns_w_19 =  rsyns_w[639:608];
assign  rsyns_w_20 =  rsyns_w[671:640];
assign  rsyns_w_21 =  rsyns_w[703:672];
assign  rsyns_w_22 =  rsyns_w[735:704];
assign  rsyns_w_23 =  rsyns_w[767:736];
assign  rsyns_w_24 =  rsyns_w[799:768];
assign  rsyns_w_25 =  rsyns_w[831:800];
assign  rsyns_w_26 =  rsyns_w[863:832];
assign  rsyns_w_27 =  rsyns_w[895:864];
assign  rsyns_w_28 =  rsyns_w[927:896];
assign  rsyns_w_29 =  rsyns_w[959:928];
assign  rsyns_w_30 =  rsyns_w[991:960];
assign  rsyns_w_31 =  rsyns_w[1023:992];
assign  rsyns_w_32 =  rsyns_w[1055:1024];
assign  rsyns_w_33 =  rsyns_w[1087:1056];
assign  rsyns_w_34 =  rsyns_w[1119:1088];
assign  rsyns_w_35 =  rsyns_w[1151:1120];
assign  rsyns_w_36 =  rsyns_w[1183:1152];
assign  rsyns_w_37 =  rsyns_w[1215:1184];
assign  rsyns_w_38 =  rsyns_w[1247:1216];
assign  rsyns_w_39 =  rsyns_w[1279:1248];
assign  rsyns_w_40 =  rsyns_w[1311:1280];
assign  rsyns_w_41 =  rsyns_w[1343:1312];
assign  rsyns_w_42 =  rsyns_w[1375:1344];
assign  rsyns_w_43 =  rsyns_w[1407:1376];
assign  rsyns_w_44 =  rsyns_w[1439:1408];
assign  rsyns_w_45 =  rsyns_w[1471:1440];
assign  rsyns_w_46 =  rsyns_w[1503:1472];
assign  rsyns_w_47 =  rsyns_w[1535:1504];
assign  rsyns_w_48 =  rsyns_w[1567:1536];
assign  rsyns_w_49 =  rsyns_w[1599:1568];
assign  rsyns_w_50 =  rsyns_w[1631:1600];
assign  rsyns_w_51 =  rsyns_w[1663:1632];
assign  rsyns_w_52 =  rsyns_w[1695:1664];
assign  rsyns_w_53 =  rsyns_w[1727:1696];
assign  rsyns_w_54 =  rsyns_w[1759:1728];
assign  rsyns_w_55 =  rsyns_w[1791:1760];
assign  rsyns_w_56 =  rsyns_w[1823:1792];
assign  rsyns_w_57 =  rsyns_w[1855:1824];
assign  rsyns_w_58 =  rsyns_w[1887:1856];
assign  rsyns_w_59 =  rsyns_w[1919:1888];
assign  rsyns_w_60 =  rsyns_w[1951:1920];
assign  rsyns_w_61 =  rsyns_w[1983:1952];
assign  rsyns_w_62 =  rsyns_w[2015:1984];
assign  rsyns_w_63 =  rsyns_w[2047:2016];
assign  rsyns_w_64 =  rsyns_w[2079:2048];

always @(posedge CLK) if (RST) rsyns_w_s_0 <= 'h0; else rsyns_w_s_0 <= rsyns_w_0;
always @(posedge CLK) if (RST) rsyns_w_s_1 <= 'h0; else rsyns_w_s_1 <= rsyns_w_1;
always @(posedge CLK) if (RST) rsyns_w_s_2 <= 'h0; else rsyns_w_s_2 <= rsyns_w_2;
always @(posedge CLK) if (RST) rsyns_w_s_3 <= 'h0; else rsyns_w_s_3 <= rsyns_w_3;
always @(posedge CLK) if (RST) rsyns_w_s_4 <= 'h0; else rsyns_w_s_4 <= rsyns_w_4;
always @(posedge CLK) if (RST) rsyns_w_s_5 <= 'h0; else rsyns_w_s_5 <= rsyns_w_5;
always @(posedge CLK) if (RST) rsyns_w_s_6 <= 'h0; else rsyns_w_s_6 <= rsyns_w_6;
always @(posedge CLK) if (RST) rsyns_w_s_7 <= 'h0; else rsyns_w_s_7 <= rsyns_w_7;
always @(posedge CLK) if (RST) rsyns_w_s_8 <= 'h0; else rsyns_w_s_8 <= rsyns_w_8;
always @(posedge CLK) if (RST) rsyns_w_s_9 <= 'h0; else rsyns_w_s_9 <= rsyns_w_9;
always @(posedge CLK) if (RST) rsyns_w_s_10 <= 'h0; else rsyns_w_s_10 <= rsyns_w_10;
always @(posedge CLK) if (RST) rsyns_w_s_11 <= 'h0; else rsyns_w_s_11 <= rsyns_w_11;
always @(posedge CLK) if (RST) rsyns_w_s_12 <= 'h0; else rsyns_w_s_12 <= rsyns_w_12;
always @(posedge CLK) if (RST) rsyns_w_s_13 <= 'h0; else rsyns_w_s_13 <= rsyns_w_13;
always @(posedge CLK) if (RST) rsyns_w_s_14 <= 'h0; else rsyns_w_s_14 <= rsyns_w_14;
always @(posedge CLK) if (RST) rsyns_w_s_15 <= 'h0; else rsyns_w_s_15 <= rsyns_w_15;
always @(posedge CLK) if (RST) rsyns_w_s_16 <= 'h0; else rsyns_w_s_16 <= rsyns_w_16;
always @(posedge CLK) if (RST) rsyns_w_s_17 <= 'h0; else rsyns_w_s_17 <= rsyns_w_17;
always @(posedge CLK) if (RST) rsyns_w_s_18 <= 'h0; else rsyns_w_s_18 <= rsyns_w_18;
always @(posedge CLK) if (RST) rsyns_w_s_19 <= 'h0; else rsyns_w_s_19 <= rsyns_w_19;
always @(posedge CLK) if (RST) rsyns_w_s_20 <= 'h0; else rsyns_w_s_20 <= rsyns_w_20;
always @(posedge CLK) if (RST) rsyns_w_s_21 <= 'h0; else rsyns_w_s_21 <= rsyns_w_21;
always @(posedge CLK) if (RST) rsyns_w_s_22 <= 'h0; else rsyns_w_s_22 <= rsyns_w_22;
always @(posedge CLK) if (RST) rsyns_w_s_23 <= 'h0; else rsyns_w_s_23 <= rsyns_w_23;
always @(posedge CLK) if (RST) rsyns_w_s_24 <= 'h0; else rsyns_w_s_24 <= rsyns_w_24;
always @(posedge CLK) if (RST) rsyns_w_s_25 <= 'h0; else rsyns_w_s_25 <= rsyns_w_25;
always @(posedge CLK) if (RST) rsyns_w_s_26 <= 'h0; else rsyns_w_s_26 <= rsyns_w_26;
always @(posedge CLK) if (RST) rsyns_w_s_27 <= 'h0; else rsyns_w_s_27 <= rsyns_w_27;
always @(posedge CLK) if (RST) rsyns_w_s_28 <= 'h0; else rsyns_w_s_28 <= rsyns_w_28;
always @(posedge CLK) if (RST) rsyns_w_s_29 <= 'h0; else rsyns_w_s_29 <= rsyns_w_29;
always @(posedge CLK) if (RST) rsyns_w_s_30 <= 'h0; else rsyns_w_s_30 <= rsyns_w_30;
always @(posedge CLK) if (RST) rsyns_w_s_31 <= 'h0; else rsyns_w_s_31 <= rsyns_w_31;
always @(posedge CLK) if (RST) rsyns_w_s_32 <= 'h0; else rsyns_w_s_32 <= rsyns_w_32;
always @(posedge CLK) if (RST) rsyns_w_s_33 <= 'h0; else rsyns_w_s_33 <= rsyns_w_33;
always @(posedge CLK) if (RST) rsyns_w_s_34 <= 'h0; else rsyns_w_s_34 <= rsyns_w_34;
always @(posedge CLK) if (RST) rsyns_w_s_35 <= 'h0; else rsyns_w_s_35 <= rsyns_w_35;
always @(posedge CLK) if (RST) rsyns_w_s_36 <= 'h0; else rsyns_w_s_36 <= rsyns_w_36;
always @(posedge CLK) if (RST) rsyns_w_s_37 <= 'h0; else rsyns_w_s_37 <= rsyns_w_37;
always @(posedge CLK) if (RST) rsyns_w_s_38 <= 'h0; else rsyns_w_s_38 <= rsyns_w_38;
always @(posedge CLK) if (RST) rsyns_w_s_39 <= 'h0; else rsyns_w_s_39 <= rsyns_w_39;
always @(posedge CLK) if (RST) rsyns_w_s_40 <= 'h0; else rsyns_w_s_40 <= rsyns_w_40;
always @(posedge CLK) if (RST) rsyns_w_s_41 <= 'h0; else rsyns_w_s_41 <= rsyns_w_41;
always @(posedge CLK) if (RST) rsyns_w_s_42 <= 'h0; else rsyns_w_s_42 <= rsyns_w_42;
always @(posedge CLK) if (RST) rsyns_w_s_43 <= 'h0; else rsyns_w_s_43 <= rsyns_w_43;
always @(posedge CLK) if (RST) rsyns_w_s_44 <= 'h0; else rsyns_w_s_44 <= rsyns_w_44;
always @(posedge CLK) if (RST) rsyns_w_s_45 <= 'h0; else rsyns_w_s_45 <= rsyns_w_45;
always @(posedge CLK) if (RST) rsyns_w_s_46 <= 'h0; else rsyns_w_s_46 <= rsyns_w_46;
always @(posedge CLK) if (RST) rsyns_w_s_47 <= 'h0; else rsyns_w_s_47 <= rsyns_w_47;
always @(posedge CLK) if (RST) rsyns_w_s_48 <= 'h0; else rsyns_w_s_48 <= rsyns_w_48;
always @(posedge CLK) if (RST) rsyns_w_s_49 <= 'h0; else rsyns_w_s_49 <= rsyns_w_49;
always @(posedge CLK) if (RST) rsyns_w_s_50 <= 'h0; else rsyns_w_s_50 <= rsyns_w_50;
always @(posedge CLK) if (RST) rsyns_w_s_51 <= 'h0; else rsyns_w_s_51 <= rsyns_w_51;
always @(posedge CLK) if (RST) rsyns_w_s_52 <= 'h0; else rsyns_w_s_52 <= rsyns_w_52;
always @(posedge CLK) if (RST) rsyns_w_s_53 <= 'h0; else rsyns_w_s_53 <= rsyns_w_53;
always @(posedge CLK) if (RST) rsyns_w_s_54 <= 'h0; else rsyns_w_s_54 <= rsyns_w_54;
always @(posedge CLK) if (RST) rsyns_w_s_55 <= 'h0; else rsyns_w_s_55 <= rsyns_w_55;
always @(posedge CLK) if (RST) rsyns_w_s_56 <= 'h0; else rsyns_w_s_56 <= rsyns_w_56;
always @(posedge CLK) if (RST) rsyns_w_s_57 <= 'h0; else rsyns_w_s_57 <= rsyns_w_57;
always @(posedge CLK) if (RST) rsyns_w_s_58 <= 'h0; else rsyns_w_s_58 <= rsyns_w_58;
always @(posedge CLK) if (RST) rsyns_w_s_59 <= 'h0; else rsyns_w_s_59 <= rsyns_w_59;
always @(posedge CLK) if (RST) rsyns_w_s_60 <= 'h0; else rsyns_w_s_60 <= rsyns_w_60;
always @(posedge CLK) if (RST) rsyns_w_s_61 <= 'h0; else rsyns_w_s_61 <= rsyns_w_61;
always @(posedge CLK) if (RST) rsyns_w_s_62 <= 'h0; else rsyns_w_s_62 <= rsyns_w_62;
always @(posedge CLK) if (RST) rsyns_w_s_63 <= 'h0; else rsyns_w_s_63 <= rsyns_w_63;
always @(posedge CLK) if (RST) rsyns_w_s_64 <= 'h0; else rsyns_w_s_64 <= rsyns_w_64;

/////////////////////////////////////
// Error trap  2 lev, 555mhz
/////////////////////////////////////
assign err_trap_pre[0] = ~|rsyns_w_s_0[20:0] && |rsyns_w_s_0[31:21];
assign err_trap_pre[1] = ~|rsyns_w_s_1[20:0] && |rsyns_w_s_1[31:21];
assign err_trap_pre[2] = ~|rsyns_w_s_2[20:0] && |rsyns_w_s_2[31:21];
assign err_trap_pre[3] = ~|rsyns_w_s_3[20:0] && |rsyns_w_s_3[31:21];
assign err_trap_pre[4] = ~|rsyns_w_s_4[20:0] && |rsyns_w_s_4[31:21];
assign err_trap_pre[5] = ~|rsyns_w_s_5[20:0] && |rsyns_w_s_5[31:21];
assign err_trap_pre[6] = ~|rsyns_w_s_6[20:0] && |rsyns_w_s_6[31:21];
assign err_trap_pre[7] = ~|rsyns_w_s_7[20:0] && |rsyns_w_s_7[31:21];
assign err_trap_pre[8] = ~|rsyns_w_s_8[20:0] && |rsyns_w_s_8[31:21];
assign err_trap_pre[9] = ~|rsyns_w_s_9[20:0] && |rsyns_w_s_9[31:21];
assign err_trap_pre[10] = ~|rsyns_w_s_10[20:0] && |rsyns_w_s_10[31:21];
assign err_trap_pre[11] = ~|rsyns_w_s_11[20:0] && |rsyns_w_s_11[31:21];
assign err_trap_pre[12] = ~|rsyns_w_s_12[20:0] && |rsyns_w_s_12[31:21];
assign err_trap_pre[13] = ~|rsyns_w_s_13[20:0] && |rsyns_w_s_13[31:21];
assign err_trap_pre[14] = ~|rsyns_w_s_14[20:0] && |rsyns_w_s_14[31:21];
assign err_trap_pre[15] = ~|rsyns_w_s_15[20:0] && |rsyns_w_s_15[31:21];
assign err_trap_pre[16] = ~|rsyns_w_s_16[20:0] && |rsyns_w_s_16[31:21];
assign err_trap_pre[17] = ~|rsyns_w_s_17[20:0] && |rsyns_w_s_17[31:21];
assign err_trap_pre[18] = ~|rsyns_w_s_18[20:0] && |rsyns_w_s_18[31:21];
assign err_trap_pre[19] = ~|rsyns_w_s_19[20:0] && |rsyns_w_s_19[31:21];
assign err_trap_pre[20] = ~|rsyns_w_s_20[20:0] && |rsyns_w_s_20[31:21];
assign err_trap_pre[21] = ~|rsyns_w_s_21[20:0] && |rsyns_w_s_21[31:21];
assign err_trap_pre[22] = ~|rsyns_w_s_22[20:0] && |rsyns_w_s_22[31:21];
assign err_trap_pre[23] = ~|rsyns_w_s_23[20:0] && |rsyns_w_s_23[31:21];
assign err_trap_pre[24] = ~|rsyns_w_s_24[20:0] && |rsyns_w_s_24[31:21];
assign err_trap_pre[25] = ~|rsyns_w_s_25[20:0] && |rsyns_w_s_25[31:21];
assign err_trap_pre[26] = ~|rsyns_w_s_26[20:0] && |rsyns_w_s_26[31:21];
assign err_trap_pre[27] = ~|rsyns_w_s_27[20:0] && |rsyns_w_s_27[31:21];
assign err_trap_pre[28] = ~|rsyns_w_s_28[20:0] && |rsyns_w_s_28[31:21];
assign err_trap_pre[29] = ~|rsyns_w_s_29[20:0] && |rsyns_w_s_29[31:21];
assign err_trap_pre[30] = ~|rsyns_w_s_30[20:0] && |rsyns_w_s_30[31:21];
assign err_trap_pre[31] = ~|rsyns_w_s_31[20:0] && |rsyns_w_s_31[31:21];
assign err_trap_pre[32] = ~|rsyns_w_s_32[20:0] && |rsyns_w_s_32[31:21];
assign err_trap_pre[33] = ~|rsyns_w_s_33[20:0] && |rsyns_w_s_33[31:21];
assign err_trap_pre[34] = ~|rsyns_w_s_34[20:0] && |rsyns_w_s_34[31:21];
assign err_trap_pre[35] = ~|rsyns_w_s_35[20:0] && |rsyns_w_s_35[31:21];
assign err_trap_pre[36] = ~|rsyns_w_s_36[20:0] && |rsyns_w_s_36[31:21];
assign err_trap_pre[37] = ~|rsyns_w_s_37[20:0] && |rsyns_w_s_37[31:21];
assign err_trap_pre[38] = ~|rsyns_w_s_38[20:0] && |rsyns_w_s_38[31:21];
assign err_trap_pre[39] = ~|rsyns_w_s_39[20:0] && |rsyns_w_s_39[31:21];
assign err_trap_pre[40] = ~|rsyns_w_s_40[20:0] && |rsyns_w_s_40[31:21];
assign err_trap_pre[41] = ~|rsyns_w_s_41[20:0] && |rsyns_w_s_41[31:21];
assign err_trap_pre[42] = ~|rsyns_w_s_42[20:0] && |rsyns_w_s_42[31:21];
assign err_trap_pre[43] = ~|rsyns_w_s_43[20:0] && |rsyns_w_s_43[31:21];
assign err_trap_pre[44] = ~|rsyns_w_s_44[20:0] && |rsyns_w_s_44[31:21];
assign err_trap_pre[45] = ~|rsyns_w_s_45[20:0] && |rsyns_w_s_45[31:21];
assign err_trap_pre[46] = ~|rsyns_w_s_46[20:0] && |rsyns_w_s_46[31:21];
assign err_trap_pre[47] = ~|rsyns_w_s_47[20:0] && |rsyns_w_s_47[31:21];
assign err_trap_pre[48] = ~|rsyns_w_s_48[20:0] && |rsyns_w_s_48[31:21];
assign err_trap_pre[49] = ~|rsyns_w_s_49[20:0] && |rsyns_w_s_49[31:21];
assign err_trap_pre[50] = ~|rsyns_w_s_50[20:0] && |rsyns_w_s_50[31:21];
assign err_trap_pre[51] = ~|rsyns_w_s_51[20:0] && |rsyns_w_s_51[31:21];
assign err_trap_pre[52] = ~|rsyns_w_s_52[20:0] && |rsyns_w_s_52[31:21];
assign err_trap_pre[53] = ~|rsyns_w_s_53[20:0] && |rsyns_w_s_53[31:21];
assign err_trap_pre[54] = ~|rsyns_w_s_54[20:0] && |rsyns_w_s_54[31:21];
assign err_trap_pre[55] = ~|rsyns_w_s_55[20:0] && |rsyns_w_s_55[31:21];
assign err_trap_pre[56] = ~|rsyns_w_s_56[20:0] && |rsyns_w_s_56[31:21];
assign err_trap_pre[57] = ~|rsyns_w_s_57[20:0] && |rsyns_w_s_57[31:21];
assign err_trap_pre[58] = ~|rsyns_w_s_58[20:0] && |rsyns_w_s_58[31:21];
assign err_trap_pre[59] = ~|rsyns_w_s_59[20:0] && |rsyns_w_s_59[31:21];
assign err_trap_pre[60] = ~|rsyns_w_s_60[20:0] && |rsyns_w_s_60[31:21];
assign err_trap_pre[61] = ~|rsyns_w_s_61[20:0] && |rsyns_w_s_61[31:21];
assign err_trap_pre[62] = ~|rsyns_w_s_62[20:0] && |rsyns_w_s_62[31:21];
assign err_trap_pre[63] = ~|rsyns_w_s_63[20:0] && |rsyns_w_s_63[31:21];
assign err_trap_pre[64] = ~|rsyns_w_s_64[20:0] && |rsyns_w_s_64[31:21];

always @(posedge CLK) if (RST) err_trap[0] <= 'h0; else err_trap[0] <= err_trap_pre[0];
always @(posedge CLK) if (RST) err_trap[1] <= 'h0; else err_trap[1] <= err_trap_pre[1] && ~|err_trap_pre[0:0];
always @(posedge CLK) if (RST) err_trap[2] <= 'h0; else err_trap[2] <= err_trap_pre[2] && ~|err_trap_pre[1:0];
always @(posedge CLK) if (RST) err_trap[3] <= 'h0; else err_trap[3] <= err_trap_pre[3] && ~|err_trap_pre[2:0];
always @(posedge CLK) if (RST) err_trap[4] <= 'h0; else err_trap[4] <= err_trap_pre[4] && ~|err_trap_pre[3:0];
always @(posedge CLK) if (RST) err_trap[5] <= 'h0; else err_trap[5] <= err_trap_pre[5] && ~|err_trap_pre[4:0];
always @(posedge CLK) if (RST) err_trap[6] <= 'h0; else err_trap[6] <= err_trap_pre[6] && ~|err_trap_pre[5:0];
always @(posedge CLK) if (RST) err_trap[7] <= 'h0; else err_trap[7] <= err_trap_pre[7] && ~|err_trap_pre[6:0];
always @(posedge CLK) if (RST) err_trap[8] <= 'h0; else err_trap[8] <= err_trap_pre[8] && ~|err_trap_pre[7:0];
always @(posedge CLK) if (RST) err_trap[9] <= 'h0; else err_trap[9] <= err_trap_pre[9] && ~|err_trap_pre[8:0];
always @(posedge CLK) if (RST) err_trap[10] <= 'h0; else err_trap[10] <= err_trap_pre[10] && ~|err_trap_pre[9:0];
always @(posedge CLK) if (RST) err_trap[11] <= 'h0; else err_trap[11] <= err_trap_pre[11] && ~|err_trap_pre[10:0];
always @(posedge CLK) if (RST) err_trap[12] <= 'h0; else err_trap[12] <= err_trap_pre[12] && ~|err_trap_pre[11:0];
always @(posedge CLK) if (RST) err_trap[13] <= 'h0; else err_trap[13] <= err_trap_pre[13] && ~|err_trap_pre[12:0];
always @(posedge CLK) if (RST) err_trap[14] <= 'h0; else err_trap[14] <= err_trap_pre[14] && ~|err_trap_pre[13:0];
always @(posedge CLK) if (RST) err_trap[15] <= 'h0; else err_trap[15] <= err_trap_pre[15] && ~|err_trap_pre[14:0];
always @(posedge CLK) if (RST) err_trap[16] <= 'h0; else err_trap[16] <= err_trap_pre[16] && ~|err_trap_pre[15:0];
always @(posedge CLK) if (RST) err_trap[17] <= 'h0; else err_trap[17] <= err_trap_pre[17] && ~|err_trap_pre[16:0];
always @(posedge CLK) if (RST) err_trap[18] <= 'h0; else err_trap[18] <= err_trap_pre[18] && ~|err_trap_pre[17:0];
always @(posedge CLK) if (RST) err_trap[19] <= 'h0; else err_trap[19] <= err_trap_pre[19] && ~|err_trap_pre[18:0];
always @(posedge CLK) if (RST) err_trap[20] <= 'h0; else err_trap[20] <= err_trap_pre[20] && ~|err_trap_pre[19:0];
always @(posedge CLK) if (RST) err_trap[21] <= 'h0; else err_trap[21] <= err_trap_pre[21] && ~|err_trap_pre[20:0];
always @(posedge CLK) if (RST) err_trap[22] <= 'h0; else err_trap[22] <= err_trap_pre[22] && ~|err_trap_pre[21:0];
always @(posedge CLK) if (RST) err_trap[23] <= 'h0; else err_trap[23] <= err_trap_pre[23] && ~|err_trap_pre[22:0];
always @(posedge CLK) if (RST) err_trap[24] <= 'h0; else err_trap[24] <= err_trap_pre[24] && ~|err_trap_pre[23:0];
always @(posedge CLK) if (RST) err_trap[25] <= 'h0; else err_trap[25] <= err_trap_pre[25] && ~|err_trap_pre[24:0];
always @(posedge CLK) if (RST) err_trap[26] <= 'h0; else err_trap[26] <= err_trap_pre[26] && ~|err_trap_pre[25:0];
always @(posedge CLK) if (RST) err_trap[27] <= 'h0; else err_trap[27] <= err_trap_pre[27] && ~|err_trap_pre[26:0];
always @(posedge CLK) if (RST) err_trap[28] <= 'h0; else err_trap[28] <= err_trap_pre[28] && ~|err_trap_pre[27:0];
always @(posedge CLK) if (RST) err_trap[29] <= 'h0; else err_trap[29] <= err_trap_pre[29] && ~|err_trap_pre[28:0];
always @(posedge CLK) if (RST) err_trap[30] <= 'h0; else err_trap[30] <= err_trap_pre[30] && ~|err_trap_pre[29:0];
always @(posedge CLK) if (RST) err_trap[31] <= 'h0; else err_trap[31] <= err_trap_pre[31] && ~|err_trap_pre[30:0];
always @(posedge CLK) if (RST) err_trap[32] <= 'h0; else err_trap[32] <= err_trap_pre[32] && ~|err_trap_pre[31:0];
always @(posedge CLK) if (RST) err_trap[33] <= 'h0; else err_trap[33] <= err_trap_pre[33] && ~|err_trap_pre[32:0];
always @(posedge CLK) if (RST) err_trap[34] <= 'h0; else err_trap[34] <= err_trap_pre[34] && ~|err_trap_pre[33:0];
always @(posedge CLK) if (RST) err_trap[35] <= 'h0; else err_trap[35] <= err_trap_pre[35] && ~|err_trap_pre[34:0];
always @(posedge CLK) if (RST) err_trap[36] <= 'h0; else err_trap[36] <= err_trap_pre[36] && ~|err_trap_pre[35:0];
always @(posedge CLK) if (RST) err_trap[37] <= 'h0; else err_trap[37] <= err_trap_pre[37] && ~|err_trap_pre[36:0];
always @(posedge CLK) if (RST) err_trap[38] <= 'h0; else err_trap[38] <= err_trap_pre[38] && ~|err_trap_pre[37:0];
always @(posedge CLK) if (RST) err_trap[39] <= 'h0; else err_trap[39] <= err_trap_pre[39] && ~|err_trap_pre[38:0];
always @(posedge CLK) if (RST) err_trap[40] <= 'h0; else err_trap[40] <= err_trap_pre[40] && ~|err_trap_pre[39:0];
always @(posedge CLK) if (RST) err_trap[41] <= 'h0; else err_trap[41] <= err_trap_pre[41] && ~|err_trap_pre[40:0];
always @(posedge CLK) if (RST) err_trap[42] <= 'h0; else err_trap[42] <= err_trap_pre[42] && ~|err_trap_pre[41:0];
always @(posedge CLK) if (RST) err_trap[43] <= 'h0; else err_trap[43] <= err_trap_pre[43] && ~|err_trap_pre[42:0];
always @(posedge CLK) if (RST) err_trap[44] <= 'h0; else err_trap[44] <= err_trap_pre[44] && ~|err_trap_pre[43:0];
always @(posedge CLK) if (RST) err_trap[45] <= 'h0; else err_trap[45] <= err_trap_pre[45] && ~|err_trap_pre[44:0];
always @(posedge CLK) if (RST) err_trap[46] <= 'h0; else err_trap[46] <= err_trap_pre[46] && ~|err_trap_pre[45:0];
always @(posedge CLK) if (RST) err_trap[47] <= 'h0; else err_trap[47] <= err_trap_pre[47] && ~|err_trap_pre[46:0];
always @(posedge CLK) if (RST) err_trap[48] <= 'h0; else err_trap[48] <= err_trap_pre[48] && ~|err_trap_pre[47:0];
always @(posedge CLK) if (RST) err_trap[49] <= 'h0; else err_trap[49] <= err_trap_pre[49] && ~|err_trap_pre[48:0];
always @(posedge CLK) if (RST) err_trap[50] <= 'h0; else err_trap[50] <= err_trap_pre[50] && ~|err_trap_pre[49:0];
always @(posedge CLK) if (RST) err_trap[51] <= 'h0; else err_trap[51] <= err_trap_pre[51] && ~|err_trap_pre[50:0];
always @(posedge CLK) if (RST) err_trap[52] <= 'h0; else err_trap[52] <= err_trap_pre[52] && ~|err_trap_pre[51:0];
always @(posedge CLK) if (RST) err_trap[53] <= 'h0; else err_trap[53] <= err_trap_pre[53] && ~|err_trap_pre[52:0];
always @(posedge CLK) if (RST) err_trap[54] <= 'h0; else err_trap[54] <= err_trap_pre[54] && ~|err_trap_pre[53:0];
always @(posedge CLK) if (RST) err_trap[55] <= 'h0; else err_trap[55] <= err_trap_pre[55] && ~|err_trap_pre[54:0];
always @(posedge CLK) if (RST) err_trap[56] <= 'h0; else err_trap[56] <= err_trap_pre[56] && ~|err_trap_pre[55:0];
always @(posedge CLK) if (RST) err_trap[57] <= 'h0; else err_trap[57] <= err_trap_pre[57] && ~|err_trap_pre[56:0];
always @(posedge CLK) if (RST) err_trap[58] <= 'h0; else err_trap[58] <= err_trap_pre[58] && ~|err_trap_pre[57:0];
always @(posedge CLK) if (RST) err_trap[59] <= 'h0; else err_trap[59] <= err_trap_pre[59] && ~|err_trap_pre[58:0];
always @(posedge CLK) if (RST) err_trap[60] <= 'h0; else err_trap[60] <= err_trap_pre[60] && ~|err_trap_pre[59:0];
always @(posedge CLK) if (RST) err_trap[61] <= 'h0; else err_trap[61] <= err_trap_pre[61] && ~|err_trap_pre[60:0];
always @(posedge CLK) if (RST) err_trap[62] <= 'h0; else err_trap[62] <= err_trap_pre[62] && ~|err_trap_pre[61:0];
always @(posedge CLK) if (RST) err_trap[63] <= 'h0; else err_trap[63] <= err_trap_pre[63] && ~|err_trap_pre[62:0];
always @(posedge CLK) if (RST) err_trap[64] <= 'h0; else err_trap[64] <= err_trap_pre[64] && ~|err_trap_pre[63:0];

always @(posedge CLK) 
if (RST) 
	err_trap_s <= 1'b0;
else
	err_trap_s <= 
	err_trap[0] |	
	err_trap[1] |	
	err_trap[2] |	
	err_trap[3] |	
	err_trap[4] |	
	err_trap[5] |	
	err_trap[6] |	
	err_trap[7] |	
	err_trap[8] |	
	err_trap[9] |	
	err_trap[10] |	
	err_trap[11] |	
	err_trap[12] |	
	err_trap[13] |	
	err_trap[14] |	
	err_trap[15] |	
	err_trap[16] |	
	err_trap[17] |	
	err_trap[18] |	
	err_trap[19] |	
	err_trap[20] |	
	err_trap[21] |	
	err_trap[22] |	
	err_trap[23] |	
	err_trap[24] |	
	err_trap[25] |	
	err_trap[26] |	
	err_trap[27] |	
	err_trap[28] |	
	err_trap[29] |	
	err_trap[30] |	
	err_trap[31] |	
	err_trap[32] |	
	err_trap[33] |	
	err_trap[34] |	
	err_trap[35] |	
	err_trap[36] |	
	err_trap[37] |	
	err_trap[38] |	
	err_trap[39] |	
	err_trap[40] |	
	err_trap[41] |	
	err_trap[42] |	
	err_trap[43] |	
	err_trap[44] |	
	err_trap[45] |	
	err_trap[46] |	
	err_trap[47] |	
	err_trap[48] |	
	err_trap[49] |	
	err_trap[50] |	
	err_trap[51] |	
	err_trap[52] |	
	err_trap[53] |	
	err_trap[54] |	
	err_trap[55] |	
	err_trap[56] |	
	err_trap[57] |	
	err_trap[58] |	
	err_trap[59] |	
	err_trap[60] |	
	err_trap[61] |	
	err_trap[62] |	
	err_trap[63] |	
	err_trap[64] |	
	1'b0;

//always @(posedge CLK) if (RST) err_trap_ss <= 'h0; else err_trap_ss <= err_trap_s;

/* correction field
	 * w/ optional reversing logic
	 * corr_field => corr_sum, 2 lvl 450mhz
*/
always @(posedge CLK) if (RST) corr_field0 <= 'h0; else corr_field0 <= rsyns_w_s_0[31:21];
always @(posedge CLK) if (RST) corr_field1 <= 'h0; else corr_field1 <= rsyns_w_s_1[31:21];
always @(posedge CLK) if (RST) corr_field2 <= 'h0; else corr_field2 <= rsyns_w_s_2[31:21];
always @(posedge CLK) if (RST) corr_field3 <= 'h0; else corr_field3 <= rsyns_w_s_3[31:21];
always @(posedge CLK) if (RST) corr_field4 <= 'h0; else corr_field4 <= rsyns_w_s_4[31:21];
always @(posedge CLK) if (RST) corr_field5 <= 'h0; else corr_field5 <= rsyns_w_s_5[31:21];
always @(posedge CLK) if (RST) corr_field6 <= 'h0; else corr_field6 <= rsyns_w_s_6[31:21];
always @(posedge CLK) if (RST) corr_field7 <= 'h0; else corr_field7 <= rsyns_w_s_7[31:21];
always @(posedge CLK) if (RST) corr_field8 <= 'h0; else corr_field8 <= rsyns_w_s_8[31:21];
always @(posedge CLK) if (RST) corr_field9 <= 'h0; else corr_field9 <= rsyns_w_s_9[31:21];
always @(posedge CLK) if (RST) corr_field10 <= 'h0; else corr_field10 <= rsyns_w_s_10[31:21];
always @(posedge CLK) if (RST) corr_field11 <= 'h0; else corr_field11 <= rsyns_w_s_11[31:21];
always @(posedge CLK) if (RST) corr_field12 <= 'h0; else corr_field12 <= rsyns_w_s_12[31:21];
always @(posedge CLK) if (RST) corr_field13 <= 'h0; else corr_field13 <= rsyns_w_s_13[31:21];
always @(posedge CLK) if (RST) corr_field14 <= 'h0; else corr_field14 <= rsyns_w_s_14[31:21];
always @(posedge CLK) if (RST) corr_field15 <= 'h0; else corr_field15 <= rsyns_w_s_15[31:21];
always @(posedge CLK) if (RST) corr_field16 <= 'h0; else corr_field16 <= rsyns_w_s_16[31:21];
always @(posedge CLK) if (RST) corr_field17 <= 'h0; else corr_field17 <= rsyns_w_s_17[31:21];
always @(posedge CLK) if (RST) corr_field18 <= 'h0; else corr_field18 <= rsyns_w_s_18[31:21];
always @(posedge CLK) if (RST) corr_field19 <= 'h0; else corr_field19 <= rsyns_w_s_19[31:21];
always @(posedge CLK) if (RST) corr_field20 <= 'h0; else corr_field20 <= rsyns_w_s_20[31:21];
always @(posedge CLK) if (RST) corr_field21 <= 'h0; else corr_field21 <= rsyns_w_s_21[31:21];
always @(posedge CLK) if (RST) corr_field22 <= 'h0; else corr_field22 <= rsyns_w_s_22[31:21];
always @(posedge CLK) if (RST) corr_field23 <= 'h0; else corr_field23 <= rsyns_w_s_23[31:21];
always @(posedge CLK) if (RST) corr_field24 <= 'h0; else corr_field24 <= rsyns_w_s_24[31:21];
always @(posedge CLK) if (RST) corr_field25 <= 'h0; else corr_field25 <= rsyns_w_s_25[31:21];
always @(posedge CLK) if (RST) corr_field26 <= 'h0; else corr_field26 <= rsyns_w_s_26[31:21];
always @(posedge CLK) if (RST) corr_field27 <= 'h0; else corr_field27 <= rsyns_w_s_27[31:21];
always @(posedge CLK) if (RST) corr_field28 <= 'h0; else corr_field28 <= rsyns_w_s_28[31:21];
always @(posedge CLK) if (RST) corr_field29 <= 'h0; else corr_field29 <= rsyns_w_s_29[31:21];
always @(posedge CLK) if (RST) corr_field30 <= 'h0; else corr_field30 <= rsyns_w_s_30[31:21];
always @(posedge CLK) if (RST) corr_field31 <= 'h0; else corr_field31 <= rsyns_w_s_31[31:21];
always @(posedge CLK) if (RST) corr_field32 <= 'h0; else corr_field32 <= rsyns_w_s_32[31:21];
always @(posedge CLK) if (RST) corr_field33 <= 'h0; else corr_field33 <= rsyns_w_s_33[31:21];
always @(posedge CLK) if (RST) corr_field34 <= 'h0; else corr_field34 <= rsyns_w_s_34[31:21];
always @(posedge CLK) if (RST) corr_field35 <= 'h0; else corr_field35 <= rsyns_w_s_35[31:21];
always @(posedge CLK) if (RST) corr_field36 <= 'h0; else corr_field36 <= rsyns_w_s_36[31:21];
always @(posedge CLK) if (RST) corr_field37 <= 'h0; else corr_field37 <= rsyns_w_s_37[31:21];
always @(posedge CLK) if (RST) corr_field38 <= 'h0; else corr_field38 <= rsyns_w_s_38[31:21];
always @(posedge CLK) if (RST) corr_field39 <= 'h0; else corr_field39 <= rsyns_w_s_39[31:21];
always @(posedge CLK) if (RST) corr_field40 <= 'h0; else corr_field40 <= rsyns_w_s_40[31:21];
always @(posedge CLK) if (RST) corr_field41 <= 'h0; else corr_field41 <= rsyns_w_s_41[31:21];
always @(posedge CLK) if (RST) corr_field42 <= 'h0; else corr_field42 <= rsyns_w_s_42[31:21];
always @(posedge CLK) if (RST) corr_field43 <= 'h0; else corr_field43 <= rsyns_w_s_43[31:21];
always @(posedge CLK) if (RST) corr_field44 <= 'h0; else corr_field44 <= rsyns_w_s_44[31:21];
always @(posedge CLK) if (RST) corr_field45 <= 'h0; else corr_field45 <= rsyns_w_s_45[31:21];
always @(posedge CLK) if (RST) corr_field46 <= 'h0; else corr_field46 <= rsyns_w_s_46[31:21];
always @(posedge CLK) if (RST) corr_field47 <= 'h0; else corr_field47 <= rsyns_w_s_47[31:21];
always @(posedge CLK) if (RST) corr_field48 <= 'h0; else corr_field48 <= rsyns_w_s_48[31:21];
always @(posedge CLK) if (RST) corr_field49 <= 'h0; else corr_field49 <= rsyns_w_s_49[31:21];
always @(posedge CLK) if (RST) corr_field50 <= 'h0; else corr_field50 <= rsyns_w_s_50[31:21];
always @(posedge CLK) if (RST) corr_field51 <= 'h0; else corr_field51 <= rsyns_w_s_51[31:21];
always @(posedge CLK) if (RST) corr_field52 <= 'h0; else corr_field52 <= rsyns_w_s_52[31:21];
always @(posedge CLK) if (RST) corr_field53 <= 'h0; else corr_field53 <= rsyns_w_s_53[31:21];
always @(posedge CLK) if (RST) corr_field54 <= 'h0; else corr_field54 <= rsyns_w_s_54[31:21];
always @(posedge CLK) if (RST) corr_field55 <= 'h0; else corr_field55 <= rsyns_w_s_55[31:21];
always @(posedge CLK) if (RST) corr_field56 <= 'h0; else corr_field56 <= rsyns_w_s_56[31:21];
always @(posedge CLK) if (RST) corr_field57 <= 'h0; else corr_field57 <= rsyns_w_s_57[31:21];
always @(posedge CLK) if (RST) corr_field58 <= 'h0; else corr_field58 <= rsyns_w_s_58[31:21];
always @(posedge CLK) if (RST) corr_field59 <= 'h0; else corr_field59 <= rsyns_w_s_59[31:21];
always @(posedge CLK) if (RST) corr_field60 <= 'h0; else corr_field60 <= rsyns_w_s_60[31:21];
always @(posedge CLK) if (RST) corr_field61 <= 'h0; else corr_field61 <= rsyns_w_s_61[31:21];
always @(posedge CLK) if (RST) corr_field62 <= 'h0; else corr_field62 <= rsyns_w_s_62[31:21];
always @(posedge CLK) if (RST) corr_field63 <= 'h0; else corr_field63 <= rsyns_w_s_63[31:21];
always @(posedge CLK) if (RST) corr_field64 <= 'h0; else corr_field64 <= rsyns_w_s_64[31:21];

/* correction field gated w/ error trap
	 * vector is all zero if error trap is negative
*/
assign  corr_field_s0 =  corr_field0 & {11{err_trap[0]}};
assign  corr_field_s1 =  corr_field1 & {11{err_trap[1]}};
assign  corr_field_s2 =  corr_field2 & {11{err_trap[2]}};
assign  corr_field_s3 =  corr_field3 & {11{err_trap[3]}};
assign  corr_field_s4 =  corr_field4 & {11{err_trap[4]}};
assign  corr_field_s5 =  corr_field5 & {11{err_trap[5]}};
assign  corr_field_s6 =  corr_field6 & {11{err_trap[6]}};
assign  corr_field_s7 =  corr_field7 & {11{err_trap[7]}};
assign  corr_field_s8 =  corr_field8 & {11{err_trap[8]}};
assign  corr_field_s9 =  corr_field9 & {11{err_trap[9]}};
assign  corr_field_s10 =  corr_field10 & {11{err_trap[10]}};
assign  corr_field_s11 =  corr_field11 & {11{err_trap[11]}};
assign  corr_field_s12 =  corr_field12 & {11{err_trap[12]}};
assign  corr_field_s13 =  corr_field13 & {11{err_trap[13]}};
assign  corr_field_s14 =  corr_field14 & {11{err_trap[14]}};
assign  corr_field_s15 =  corr_field15 & {11{err_trap[15]}};
assign  corr_field_s16 =  corr_field16 & {11{err_trap[16]}};
assign  corr_field_s17 =  corr_field17 & {11{err_trap[17]}};
assign  corr_field_s18 =  corr_field18 & {11{err_trap[18]}};
assign  corr_field_s19 =  corr_field19 & {11{err_trap[19]}};
assign  corr_field_s20 =  corr_field20 & {11{err_trap[20]}};
assign  corr_field_s21 =  corr_field21 & {11{err_trap[21]}};
assign  corr_field_s22 =  corr_field22 & {11{err_trap[22]}};
assign  corr_field_s23 =  corr_field23 & {11{err_trap[23]}};
assign  corr_field_s24 =  corr_field24 & {11{err_trap[24]}};
assign  corr_field_s25 =  corr_field25 & {11{err_trap[25]}};
assign  corr_field_s26 =  corr_field26 & {11{err_trap[26]}};
assign  corr_field_s27 =  corr_field27 & {11{err_trap[27]}};
assign  corr_field_s28 =  corr_field28 & {11{err_trap[28]}};
assign  corr_field_s29 =  corr_field29 & {11{err_trap[29]}};
assign  corr_field_s30 =  corr_field30 & {11{err_trap[30]}};
assign  corr_field_s31 =  corr_field31 & {11{err_trap[31]}};
assign  corr_field_s32 =  corr_field32 & {11{err_trap[32]}};
assign  corr_field_s33 =  corr_field33 & {11{err_trap[33]}};
assign  corr_field_s34 =  corr_field34 & {11{err_trap[34]}};
assign  corr_field_s35 =  corr_field35 & {11{err_trap[35]}};
assign  corr_field_s36 =  corr_field36 & {11{err_trap[36]}};
assign  corr_field_s37 =  corr_field37 & {11{err_trap[37]}};
assign  corr_field_s38 =  corr_field38 & {11{err_trap[38]}};
assign  corr_field_s39 =  corr_field39 & {11{err_trap[39]}};
assign  corr_field_s40 =  corr_field40 & {11{err_trap[40]}};
assign  corr_field_s41 =  corr_field41 & {11{err_trap[41]}};
assign  corr_field_s42 =  corr_field42 & {11{err_trap[42]}};
assign  corr_field_s43 =  corr_field43 & {11{err_trap[43]}};
assign  corr_field_s44 =  corr_field44 & {11{err_trap[44]}};
assign  corr_field_s45 =  corr_field45 & {11{err_trap[45]}};
assign  corr_field_s46 =  corr_field46 & {11{err_trap[46]}};
assign  corr_field_s47 =  corr_field47 & {11{err_trap[47]}};
assign  corr_field_s48 =  corr_field48 & {11{err_trap[48]}};
assign  corr_field_s49 =  corr_field49 & {11{err_trap[49]}};
assign  corr_field_s50 =  corr_field50 & {11{err_trap[50]}};
assign  corr_field_s51 =  corr_field51 & {11{err_trap[51]}};
assign  corr_field_s52 =  corr_field52 & {11{err_trap[52]}};
assign  corr_field_s53 =  corr_field53 & {11{err_trap[53]}};
assign  corr_field_s54 =  corr_field54 & {11{err_trap[54]}};
assign  corr_field_s55 =  corr_field55 & {11{err_trap[55]}};
assign  corr_field_s56 =  corr_field56 & {11{err_trap[56]}};
assign  corr_field_s57 =  corr_field57 & {11{err_trap[57]}};
assign  corr_field_s58 =  corr_field58 & {11{err_trap[58]}};
assign  corr_field_s59 =  corr_field59 & {11{err_trap[59]}};
assign  corr_field_s60 =  corr_field60 & {11{err_trap[60]}};
assign  corr_field_s61 =  corr_field61 & {11{err_trap[61]}};
assign  corr_field_s62 =  corr_field62 & {11{err_trap[62]}};
assign  corr_field_s63 =  corr_field63 & {11{err_trap[63]}};
assign  corr_field_s64 =  corr_field64 & {11{err_trap[64]}};

reg     [10:0] corr_field_sum;

always @(posedge CLK)
if (RST)
	corr_field_sum <= 'h0;
else
	corr_field_sum <=
	corr_field_s0	|
	corr_field_s1	|
	corr_field_s2	|
	corr_field_s3	|
	corr_field_s4	|
	corr_field_s5	|
	corr_field_s6	|
	corr_field_s7	|
	corr_field_s8	|
	corr_field_s9	|
	corr_field_s10	|
	corr_field_s11	|
	corr_field_s12	|
	corr_field_s13	|
	corr_field_s14	|
	corr_field_s15	|
	corr_field_s16	|
	corr_field_s17	|
	corr_field_s18	|
	corr_field_s19	|
	corr_field_s20	|
	corr_field_s21	|
	corr_field_s22	|
	corr_field_s23	|
	corr_field_s24	|
	corr_field_s25	|
	corr_field_s26	|
	corr_field_s27	|
	corr_field_s28	|
	corr_field_s29	|
	corr_field_s30	|
	corr_field_s31	|
	corr_field_s32	|
	corr_field_s33	|
	corr_field_s34	|
	corr_field_s35	|
	corr_field_s36	|
	corr_field_s37	|
	corr_field_s38	|
	corr_field_s39	|
	corr_field_s40	|
	corr_field_s41	|
	corr_field_s42	|
	corr_field_s43	|
	corr_field_s44	|
	corr_field_s45	|
	corr_field_s46	|
	corr_field_s47	|
	corr_field_s48	|
	corr_field_s49	|
	corr_field_s50	|
	corr_field_s51	|
	corr_field_s52	|
	corr_field_s53	|
	corr_field_s54	|
	corr_field_s55	|
	corr_field_s56	|
	corr_field_s57	|
	corr_field_s58	|
	corr_field_s59	|
	corr_field_s60	|
	corr_field_s61	|
	corr_field_s62	|
	corr_field_s63	|
	corr_field_s64	|
	{11{1'b0}};


reg     [74:0] corr_sum;

always @(posedge CLK)
if (RST)
	corr_sum <= 'h0;
else
	corr_sum <= 
	({{64{1'b0}}, corr_field_s0} << 64) |
	({{64{1'b0}}, corr_field_s1} << 63) |
	({{64{1'b0}}, corr_field_s2} << 62) |
	({{64{1'b0}}, corr_field_s3} << 61) |
	({{64{1'b0}}, corr_field_s4} << 60) |
	({{64{1'b0}}, corr_field_s5} << 59) |
	({{64{1'b0}}, corr_field_s6} << 58) |
	({{64{1'b0}}, corr_field_s7} << 57) |
	({{64{1'b0}}, corr_field_s8} << 56) |
	({{64{1'b0}}, corr_field_s9} << 55) |
	({{64{1'b0}}, corr_field_s10} << 54) |
	({{64{1'b0}}, corr_field_s11} << 53) |
	({{64{1'b0}}, corr_field_s12} << 52) |
	({{64{1'b0}}, corr_field_s13} << 51) |
	({{64{1'b0}}, corr_field_s14} << 50) |
	({{64{1'b0}}, corr_field_s15} << 49) |
	({{64{1'b0}}, corr_field_s16} << 48) |
	({{64{1'b0}}, corr_field_s17} << 47) |
	({{64{1'b0}}, corr_field_s18} << 46) |
	({{64{1'b0}}, corr_field_s19} << 45) |
	({{64{1'b0}}, corr_field_s20} << 44) |
	({{64{1'b0}}, corr_field_s21} << 43) |
	({{64{1'b0}}, corr_field_s22} << 42) |
	({{64{1'b0}}, corr_field_s23} << 41) |
	({{64{1'b0}}, corr_field_s24} << 40) |
	({{64{1'b0}}, corr_field_s25} << 39) |
	({{64{1'b0}}, corr_field_s26} << 38) |
	({{64{1'b0}}, corr_field_s27} << 37) |
	({{64{1'b0}}, corr_field_s28} << 36) |
	({{64{1'b0}}, corr_field_s29} << 35) |
	({{64{1'b0}}, corr_field_s30} << 34) |
	({{64{1'b0}}, corr_field_s31} << 33) |
	({{64{1'b0}}, corr_field_s32} << 32) |
	({{64{1'b0}}, corr_field_s33} << 31) |
	({{64{1'b0}}, corr_field_s34} << 30) |
	({{64{1'b0}}, corr_field_s35} << 29) |
	({{64{1'b0}}, corr_field_s36} << 28) |
	({{64{1'b0}}, corr_field_s37} << 27) |
	({{64{1'b0}}, corr_field_s38} << 26) |
	({{64{1'b0}}, corr_field_s39} << 25) |
	({{64{1'b0}}, corr_field_s40} << 24) |
	({{64{1'b0}}, corr_field_s41} << 23) |
	({{64{1'b0}}, corr_field_s42} << 22) |
	({{64{1'b0}}, corr_field_s43} << 21) |
	({{64{1'b0}}, corr_field_s44} << 20) |
	({{64{1'b0}}, corr_field_s45} << 19) |
	({{64{1'b0}}, corr_field_s46} << 18) |
	({{64{1'b0}}, corr_field_s47} << 17) |
	({{64{1'b0}}, corr_field_s48} << 16) |
	({{64{1'b0}}, corr_field_s49} << 15) |
	({{64{1'b0}}, corr_field_s50} << 14) |
	({{64{1'b0}}, corr_field_s51} << 13) |
	({{64{1'b0}}, corr_field_s52} << 12) |
	({{64{1'b0}}, corr_field_s53} << 11) |
	({{64{1'b0}}, corr_field_s54} << 10) |
	({{64{1'b0}}, corr_field_s55} << 9) |
	({{64{1'b0}}, corr_field_s56} << 8) |
	({{64{1'b0}}, corr_field_s57} << 7) |
	({{64{1'b0}}, corr_field_s58} << 6) |
	({{64{1'b0}}, corr_field_s59} << 5) |
	({{64{1'b0}}, corr_field_s60} << 4) |
	({{64{1'b0}}, corr_field_s61} << 3) |
	({{64{1'b0}}, corr_field_s62} << 2) |
	({{64{1'b0}}, corr_field_s63} << 1) |
	({{64{1'b0}}, corr_field_s64} << 0) |
	{75{1'b0}};

always @(posedge CLK)
if (RST)
begin
	CORR_VECTOR <= 'h0;
	CARRY_VECTOR <= 'h0;
	CORR_VAL <= 1'b0;
	CORR_FIELD <= 'h0;
end
else
begin
	CORR_VECTOR <= corr_sum[74:10];
	CARRY_VECTOR <= corr_sum[9:0];
	CORR_VAL <= err_trap_s; 
	CORR_FIELD <= corr_field_sum;
end	

endmodule


