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


/* P block (64bit) to T block (65bit) gearbox.
 * Always assume that RST is de-asserted before ENA is asserted.  Do not 
 * use it the other way around.
*/

module gb64_65 (
	input   CLK,
	input   RST,
	input   [63:0] P_BLK,
	input   P_BLK_ENA,
	output  reg     [64:0] T_BLK,
	output  reg     [31:0] T_CRC,
	output  reg     T_BLK_ENA,
	output  reg     T_CRC_ENA
);

reg     [63:0] p_blk_preflop, p_blk_s0, p_blk_s1;
reg     p_blk_ena_preflop, p_blk_ena_s0, p_blk_ena_s1;
reg     [5:0] blk_cnt;
//reg crc_cycle;

wire    pipe_adv;


/* preflop stage
*/
always @(posedge CLK)
if (RST)
begin
	p_blk_preflop <= 'h0;
	p_blk_ena_preflop <= 1'b0;
end
else
begin
	p_blk_preflop <= P_BLK;
	p_blk_ena_preflop <= P_BLK_ENA;
end



assign  pipe_adv   =  p_blk_ena_preflop && p_blk_ena_s0 && p_blk_ena_s1;

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
	p_blk_s0 <= p_blk_preflop;
	p_blk_ena_s0 <= p_blk_ena_preflop;
	p_blk_s1 <= p_blk_s0;
	p_blk_ena_s1 <= p_blk_ena_s0;
end


/*incoming BLK counterp_blk_ena_s0.
	 * Free-running after ENA.
	 * Counts 32 T-blocks and 1 CRC block
*/
always @(posedge CLK)
if (RST || !p_blk_ena_s1)
	blk_cnt <= 'h0;
else if (blk_cnt[5])
	blk_cnt <= 'h0;
else  
	blk_cnt <= blk_cnt + 1;

/*crc cycle indicator
*/
//always @(posedge CLK)
//if (RST)
//crc_cycle <= 1'b0;
//else if (pipe_adv)
//crc_cycle <= &blk_cnt;

reg [64:0] t_blk;
reg [31:0] t_crc;
/* Mux for the gear change
*/
always @(posedge CLK)
if (RST)
begin
	t_blk <= 'h0;
	T_BLK_ENA <= 1'b0;
	t_crc <= 'h0;
	T_CRC_ENA <= 1'b0;
end

else 
begin
	case (blk_cnt)
	6'd0 : begin
		t_blk <= {p_blk_s0[0:0], p_blk_s1[63:0]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd1 : begin
		t_blk <= {p_blk_s0[1:0], p_blk_s1[63:1]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd2 : begin
		t_blk <= {p_blk_s0[2:0], p_blk_s1[63:2]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd3 : begin
		t_blk <= {p_blk_s0[3:0], p_blk_s1[63:3]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd4 : begin
		t_blk <= {p_blk_s0[4:0], p_blk_s1[63:4]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd5 : begin
		t_blk <= {p_blk_s0[5:0], p_blk_s1[63:5]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd6 : begin
		t_blk <= {p_blk_s0[6:0], p_blk_s1[63:6]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd7 : begin
		t_blk <= {p_blk_s0[7:0], p_blk_s1[63:7]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd8 : begin
		t_blk <= {p_blk_s0[8:0], p_blk_s1[63:8]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd9 : begin
		t_blk <= {p_blk_s0[9:0], p_blk_s1[63:9]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd10 : begin
		t_blk <= {p_blk_s0[10:0], p_blk_s1[63:10]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd11 : begin
		t_blk <= {p_blk_s0[11:0], p_blk_s1[63:11]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd12 : begin
		t_blk <= {p_blk_s0[12:0], p_blk_s1[63:12]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd13 : begin
		t_blk <= {p_blk_s0[13:0], p_blk_s1[63:13]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd14 : begin
		t_blk <= {p_blk_s0[14:0], p_blk_s1[63:14]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd15 : begin
		t_blk <= {p_blk_s0[15:0], p_blk_s1[63:15]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd16 : begin
		t_blk <= {p_blk_s0[16:0], p_blk_s1[63:16]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd17 : begin
		t_blk <= {p_blk_s0[17:0], p_blk_s1[63:17]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd18 : begin
		t_blk <= {p_blk_s0[18:0], p_blk_s1[63:18]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd19 : begin
		t_blk <= {p_blk_s0[19:0], p_blk_s1[63:19]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd20 : begin
		t_blk <= {p_blk_s0[20:0], p_blk_s1[63:20]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd21 : begin
		t_blk <= {p_blk_s0[21:0], p_blk_s1[63:21]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd22 : begin
		t_blk <= {p_blk_s0[22:0], p_blk_s1[63:22]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd23 : begin
		t_blk <= {p_blk_s0[23:0], p_blk_s1[63:23]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd24 : begin
		t_blk <= {p_blk_s0[24:0], p_blk_s1[63:24]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd25 : begin
		t_blk <= {p_blk_s0[25:0], p_blk_s1[63:25]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd26 : begin
		t_blk <= {p_blk_s0[26:0], p_blk_s1[63:26]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd27 : begin
		t_blk <= {p_blk_s0[27:0], p_blk_s1[63:27]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd28 : begin
		t_blk <= {p_blk_s0[28:0], p_blk_s1[63:28]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd29 : begin
		t_blk <= {p_blk_s0[29:0], p_blk_s1[63:29]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd30 : begin
		t_blk <= {p_blk_s0[30:0], p_blk_s1[63:30]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	6'd31 : begin
		t_blk <= {p_blk_s0[31:0], p_blk_s1[63:31]};
		T_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
		T_CRC_ENA <= 1'b0;
	end
	
	
	6'd32 : begin
		T_BLK_ENA <= 1'b0;
		t_crc <= p_blk_s1[63:32];
		T_CRC_ENA <= 1'b1;
	end
	
	default : begin
		T_BLK_ENA <= 1'b0;
		T_CRC_ENA <= 1'b0;
	end
	
	endcase
end
/*
else
begin
	t_blk <= 'h0;
	T_BLK_ENA <= 1'b0;
	t_crc <= 'h0;
	T_CRC_ENA <= 1'b0;
end
*/
reverse #(65) t_blk_rev (.ENA(1), .IN(t_blk), .OUT(T_BLK));
reverse #(32) t_crc_rev (.ENA(1), .IN(t_crc), .OUT(T_CRC));
//============================


endmodule

