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


/* pseudo-noise short latency
 * This block will free-run upon reset de-assertion.  It will generate all
 * 33 PN2112 code words continuously.  It supports bubble insertion.
 */


module pn2112_sl
(
	input   CLK,
	input   RST,
	input   ENA,
	output  [63:0] PN2112_CW
);

reg     [5:0] lword_c;
reg     [63:0] pn2112;

always @(posedge CLK)
if (RST || !ENA)
	lword_c <= 'h0;
else if (lword_c[5])
	lword_c <= 'h0;
else 
	lword_c <= lword_c + 1;

always @ (posedge CLK)
	case (lword_c)
	6'd0 : pn2112 <= 64'hffffffffff555540;
6'd1 : pn2112 <= 64'h00015555555552aa;
6'd2 : pn2112 <= 64'haafffff000015555;
6'd3 : pn2112 <= 64'h5ffffeaaaaeaaaaa;
6'd4 : pn2112 <= 64'haaaa7fffeffffe55;
6'd5 : pn2112 <= 64'h5540000755551555;
6'd6 : pn2112 <= 64'h5eaaabfffff80000;
6'd7 : pn2112 <= 64'h55550ffffeaaaa0a;
6'd8 : pn2112 <= 64'haabeaaabbfffffff;
6'd9 : pn2112 <= 64'hf8d55510000e5554;

6'd10 : pn2112 <= 64'h155558aaabbfffb4;
6'd11 : pn2112 <= 64'h0001555587ffefaa;
6'd12 : pn2112 <= 64'hab5aaabeaaad5fff;
6'd13 : pn2112 <= 64'habfff51554000000;
6'd14 : pn2112 <= 64'hd555455501aaaabf;
6'd15 : pn2112 <= 64'hff52001515540bff;
6'd16 : pn2112 <= 64'hfeaaad52aaffaaa5;
6'd17 : pn2112 <= 64'h0ffeabfff5f55414;
6'd18 : pn2112 <= 64'h004115555555872a;
6'd19 : pn2112 <= 64'hbaeffe5b00141552;

6'd20 : pn2112 <= 64'h0dffbeeaa11eabfe;
6'd21 : pn2112 <= 64'haaad87ffbaffa4a5;
6'd22 : pn2112 <= 64'h541400a7f5410154;
6'd23 : pn2112 <= 64'h4aeaabfff8d58045;
6'd24 : pn2112 <= 64'h455b54febfeaa7f8;
6'd25 : pn2112 <= 64'habaaeae00bfeabff;
6'd26 : pn2112 <= 64'h2aad455501ffa540;
6'd27 : pn2112 <= 64'h0152aa0affebf554;
6'd28 : pn2112 <= 64'h41555555527fffba;
6'd29 : pn2112 <= 64'hfff1aaabea000dea;

6'd30 : pn2112 <= 64'habbeaae1555407ff;
6'd31 : pn2112 <= 64'h2d00105aab5bffeb;
6'd32 : pn2112 <= 64'hf552a15501155fbf;

default : pn2112 <= 64'h0000000000000000;

endcase

reverse #(64) pn_reverse_inst (.ENA(1'b1), .IN(pn2112), .OUT(PN2112_CW));

endmodule
