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
* $Date: 2014-03-05 13:46:52 -0800 (Wed, 05 Mar 2014) $
* $Revision: 4799 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


/* P block (64bit) to T block (66bit) gearbox.
 * Always assume that RST is de-asserted before ENA is asserted.  Do not 
 * use it the other way around.
*/

module gb66_64 (
  input   CLK,
	input   RST,
	input   [65:0] P_BLK,
	input   P_BLK_ENA,
	output  reg     [63:0] T_BLK

);

reg     [65:0] p_blk_s0, p_blk_s1;
reg     p_blk_ena_s0, p_blk_ena_s1;
reg     [5:0] blk_cnt;
reg     crc_cycle;

wire [4:0] used_wd;
reg half_full_flag;
reg [5:0] rdreq_cnt;
wire rdreq;

/*----------------212 domain ---------------------------*/


/*2 stage buffer for mux select
	 * Pipe stalls on !p_blk_ena_preflop.  Bubbles are filtered at stage 0 D
*/
always @(posedge CLK)
if (RST)
begin
	p_blk_s0 <= 'h0;
	p_blk_ena_s0 <= 1'b0;
	p_blk_s1 <= 'h0;
	p_blk_ena_s1 <= 1'b0;
end
else
begin
	p_blk_s0 <= P_BLK;
	p_blk_ena_s0 <= P_BLK_ENA;
	p_blk_s1 <= p_blk_s0;
	p_blk_ena_s1 <= p_blk_ena_s0;
end


/*incoming BLK counterp_blk_ena_s0.
	 * Free-running after ENA.
	 * Counts 32 T-blocks and 1 CRC block
*/
always @(posedge CLK)
if (RST)
	blk_cnt <= 'h0;
else if (!p_blk_ena_s0)
	blk_cnt <= 'h0;
else 
	blk_cnt <= blk_cnt + 1;


/* Mux for the gear change
*/
always @(posedge CLK)
if (RST)
begin
	T_BLK <= 'h0;
end

else
begin
	case (blk_cnt)
	6'd0 : begin
		T_BLK <= p_blk_s0[63:0];
	end
	
	6'd1 : begin
		T_BLK <= {p_blk_s0[61:0], p_blk_s1[65:64]};
	end
	6'd2 : begin
		T_BLK <= {p_blk_s0[59:0], p_blk_s1[65:62]};
	end
	6'd3 : begin
		T_BLK <= {p_blk_s0[57:0], p_blk_s1[65:60]};
	end
	6'd4 : begin
		T_BLK <= {p_blk_s0[55:0], p_blk_s1[65:58]};
	end
	6'd5 : begin
		T_BLK <= {p_blk_s0[53:0], p_blk_s1[65:56]};
	end
	6'd6 : begin
		T_BLK <= {p_blk_s0[51:0], p_blk_s1[65:54]};
	end
	6'd7 : begin
		T_BLK <= {p_blk_s0[49:0], p_blk_s1[65:52]};
	end
	6'd8 : begin
		T_BLK <= {p_blk_s0[47:0], p_blk_s1[65:50]};
	end
	6'd9 : begin
		T_BLK <= {p_blk_s0[45:0], p_blk_s1[65:48]};
	end
	6'd10 : begin
		T_BLK <= {p_blk_s0[43:0], p_blk_s1[65:46]};
	end
	6'd11 : begin
		T_BLK <= {p_blk_s0[41:0], p_blk_s1[65:44]};
	end
	6'd12 : begin
		T_BLK <= {p_blk_s0[39:0], p_blk_s1[65:42]};
	end
	6'd13 : begin
		T_BLK <= {p_blk_s0[37:0], p_blk_s1[65:40]};
	end
	6'd14 : begin
		T_BLK <= {p_blk_s0[35:0], p_blk_s1[65:38]};
	end
	6'd15 : begin
		T_BLK <= {p_blk_s0[33:0], p_blk_s1[65:36]};
	end
	6'd16 : begin
		T_BLK <= {p_blk_s0[31:0], p_blk_s1[65:34]};
	end
	6'd17 : begin
		T_BLK <= {p_blk_s0[29:0], p_blk_s1[65:32]};
	end
	6'd18 : begin
		T_BLK <= {p_blk_s0[27:0], p_blk_s1[65:30]};
	end
	6'd19 : begin
		T_BLK <= {p_blk_s0[25:0], p_blk_s1[65:28]};
	end
	6'd20 : begin
		T_BLK <= {p_blk_s0[23:0], p_blk_s1[65:26]};
	end
	6'd21 : begin
		T_BLK <= {p_blk_s0[21:0], p_blk_s1[65:24]};
	end
	6'd22 : begin
		T_BLK <= {p_blk_s0[19:0], p_blk_s1[65:22]};
	end
	6'd23 : begin
		T_BLK <= {p_blk_s0[17:0], p_blk_s1[65:20]};
	end
	6'd24 : begin
		T_BLK <= {p_blk_s0[15:0], p_blk_s1[65:18]};
	end
	6'd25 : begin
		T_BLK <= {p_blk_s0[13:0], p_blk_s1[65:16]};
	end
	6'd26 : begin
		T_BLK <= {p_blk_s0[11:0], p_blk_s1[65:14]};
	end
	6'd27 : begin
		T_BLK <= {p_blk_s0[9:0], p_blk_s1[65:12]};
	end
	6'd28 : begin
		T_BLK <= {p_blk_s0[7:0], p_blk_s1[65:10]};
	end
	6'd29 : begin
		T_BLK <= {p_blk_s0[5:0], p_blk_s1[65:8]};
	end
	6'd30 : begin
		T_BLK <= {p_blk_s0[3:0], p_blk_s1[65:6]};
	end
	6'd31 : begin
		T_BLK <= {p_blk_s0[1:0], p_blk_s1[65:4]};
	end
	6'd32 : begin
		T_BLK <= p_blk_s1[65:2];
	end
	
	default : begin
	T_BLK <= 'h0;
	end
	
	endcase
end

endmodule

