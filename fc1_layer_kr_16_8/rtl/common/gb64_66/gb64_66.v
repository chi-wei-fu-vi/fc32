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
* $Date: 2014-04-09 15:15:58 -0700 (Wed, 09 Apr 2014) $
* $Revision: 5190 $
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

module gb64_66 (
	input   CLK,
	input   RST,
	input   [63:0] PMA_BLK,
	input   PMA_BLK_ENA,
	output  reg     [65:0] GB_BLK,
	output  reg     GB_BLK_ENA
);

reg     [63:0] p_blk_preflop, p_blk_s0, p_blk_s1;
reg     p_blk_ena_preflop, p_blk_ena_s0, p_blk_ena_s1;
reg     [5:0] blk_cnt;

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
	p_blk_preflop <= PMA_BLK;
	p_blk_ena_preflop <= PMA_BLK_ENA;
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
else if (pipe_adv)
	blk_cnt <= blk_cnt + 1;

/* Mux for the gear change
*/
always @(posedge CLK)
if (RST)
begin
	GB_BLK <= 'h0;
	GB_BLK_ENA <= 1'b0;
end

else if (pipe_adv)
begin
	case (blk_cnt)
	6'd0 : begin
		GB_BLK <= {p_blk_s0[1:0], p_blk_s1[63:0]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd1 : begin
		GB_BLK <= {p_blk_s0[3:0], p_blk_s1[63:2]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd2 : begin
		GB_BLK <= {p_blk_s0[5:0], p_blk_s1[63:4]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd3 : begin
		GB_BLK <= {p_blk_s0[7:0], p_blk_s1[63:6]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd4 : begin
		GB_BLK <= {p_blk_s0[9:0], p_blk_s1[63:8]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd5 : begin
		GB_BLK <= {p_blk_s0[11:0], p_blk_s1[63:10]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd6 : begin
		GB_BLK <= {p_blk_s0[13:0], p_blk_s1[63:12]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd7 : begin
		GB_BLK <= {p_blk_s0[15:0], p_blk_s1[63:14]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd8 : begin
		GB_BLK <= {p_blk_s0[17:0], p_blk_s1[63:16]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd9 : begin
		GB_BLK <= {p_blk_s0[19:0], p_blk_s1[63:18]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd10 : begin
		GB_BLK <= {p_blk_s0[21:0], p_blk_s1[63:20]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd11 : begin
		GB_BLK <= {p_blk_s0[23:0], p_blk_s1[63:22]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd12 : begin
		GB_BLK <= {p_blk_s0[25:0], p_blk_s1[63:24]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd13 : begin
		GB_BLK <= {p_blk_s0[27:0], p_blk_s1[63:26]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd14 : begin
		GB_BLK <= {p_blk_s0[29:0], p_blk_s1[63:28]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd15 : begin
		GB_BLK <= {p_blk_s0[31:0], p_blk_s1[63:30]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd16 : begin
		GB_BLK <= {p_blk_s0[33:0], p_blk_s1[63:32]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd17 : begin
		GB_BLK <= {p_blk_s0[35:0], p_blk_s1[63:34]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd18 : begin
		GB_BLK <= {p_blk_s0[37:0], p_blk_s1[63:36]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd19 : begin
		GB_BLK <= {p_blk_s0[39:0], p_blk_s1[63:38]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd20 : begin
		GB_BLK <= {p_blk_s0[41:0], p_blk_s1[63:40]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd21 : begin
		GB_BLK <= {p_blk_s0[43:0], p_blk_s1[63:42]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd22 : begin
		GB_BLK <= {p_blk_s0[45:0], p_blk_s1[63:44]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd23 : begin
		GB_BLK <= {p_blk_s0[47:0], p_blk_s1[63:46]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd24 : begin
		GB_BLK <= {p_blk_s0[49:0], p_blk_s1[63:48]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd25 : begin
		GB_BLK <= {p_blk_s0[51:0], p_blk_s1[63:50]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd26 : begin
		GB_BLK <= {p_blk_s0[53:0], p_blk_s1[63:52]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd27 : begin
		GB_BLK <= {p_blk_s0[55:0], p_blk_s1[63:54]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd28 : begin
		GB_BLK <= {p_blk_s0[57:0], p_blk_s1[63:56]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd29 : begin
		GB_BLK <= {p_blk_s0[59:0], p_blk_s1[63:58]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd30 : begin
		GB_BLK <= {p_blk_s0[61:0], p_blk_s1[63:60]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	6'd31 : begin
		GB_BLK <= {p_blk_s0[63:0], p_blk_s1[63:62]};
		GB_BLK_ENA <= p_blk_ena_s0 && p_blk_ena_s1;
	end
	
	
	default : begin
		GB_BLK_ENA <= 1'b0;
	end
	
	endcase
end

else
begin
	GB_BLK <= 'h0;
	GB_BLK_ENA <= 1'b0;
end


endmodule

