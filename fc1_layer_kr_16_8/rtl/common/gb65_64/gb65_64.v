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
* $Date: 2014-05-01 10:24:41 -0700 (Thu, 01 May 2014) $
* $Revision: 5573 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


/* gearbox 65bit to 64bit in fire code 2112/2080 FEC block format
*/

module gb65_64 (
  input   CLK,
  input   RST,
	input   [5:0] BLK_CNT,
	input   [64:0] T_BLK,
	input   T_BLK_ENA,
input   [31:0] CRC32, // lags T_BLK by 1 clk
	
	output  reg     [63:0] GB_BLK,
  output  PN_ENA

);


logic [5:0] blk_cnt;
always @(posedge CLK)
  blk_cnt <= BLK_CNT;

logic [64:0] rev_t_blk_s;
logic [31:0] rev_crc32;
logic [63:0] rev_gb_blk;
logic [31:0] buffer;

reverse #(65) rev_t_blk_s_inst (.ENA(1'b1), .IN(T_BLK), .OUT(rev_t_blk_s));
reverse #(32) rev_crc32_inst (.ENA(1'b1), .IN(CRC32), .OUT(rev_crc32));
reverse #(64) rev_gb_blk_inst (.ENA(1'b1), .IN(GB_BLK), .OUT(rev_gb_blk));

assign  PN_ENA = T_BLK_ENA;


always @(posedge CLK)
if (RST)
begin
	GB_BLK <= 64'h0;
	buffer <= 32'h0;
end
else
begin   
	case (blk_cnt)
	6'd0 : begin
		GB_BLK <= rev_t_blk_s[63:0];
		buffer[0:0] <= rev_t_blk_s[64:64];
	end
	
	6'd1 : begin
		GB_BLK <= {rev_t_blk_s[62:0], buffer[0:0]};
		buffer[1:0] <= rev_t_blk_s[64:63];
	end
	
	6'd2 : begin
		GB_BLK <= {rev_t_blk_s[61:0], buffer[1:0]};
		buffer[2:0] <= rev_t_blk_s[64:62];
	end
	
	6'd3 : begin
		GB_BLK <= {rev_t_blk_s[60:0], buffer[2:0]};
		buffer[3:0] <= rev_t_blk_s[64:61];
	end
	
	6'd4 : begin
		GB_BLK <= {rev_t_blk_s[59:0], buffer[3:0]};
		buffer[4:0] <= rev_t_blk_s[64:60];
	end
	
	6'd5 : begin
		GB_BLK <= {rev_t_blk_s[58:0], buffer[4:0]};
		buffer[5:0] <= rev_t_blk_s[64:59];
	end
	
	6'd6 : begin
		GB_BLK <= {rev_t_blk_s[57:0], buffer[5:0]};
		buffer[6:0] <= rev_t_blk_s[64:58];
	end
	
	6'd7 : begin
		GB_BLK <= {rev_t_blk_s[56:0], buffer[6:0]};
		buffer[7:0] <= rev_t_blk_s[64:57];
	end
	
	6'd8 : begin
		GB_BLK <= {rev_t_blk_s[55:0], buffer[7:0]};
		buffer[8:0] <= rev_t_blk_s[64:56];
	end
	
	6'd9 : begin
		GB_BLK <= {rev_t_blk_s[54:0], buffer[8:0]};
		buffer[9:0] <= rev_t_blk_s[64:55];
	end
	
	6'd10 : begin
		GB_BLK <= {rev_t_blk_s[53:0], buffer[9:0]};
		buffer[10:0] <= rev_t_blk_s[64:54];
	end
	
	6'd11 : begin
		GB_BLK <= {rev_t_blk_s[52:0], buffer[10:0]};
		buffer[11:0] <= rev_t_blk_s[64:53];
	end
	
	6'd12 : begin
		GB_BLK <= {rev_t_blk_s[51:0], buffer[11:0]};
		buffer[12:0] <= rev_t_blk_s[64:52];
	end
	
	6'd13 : begin
		GB_BLK <= {rev_t_blk_s[50:0], buffer[12:0]};
		buffer[13:0] <= rev_t_blk_s[64:51];
	end
	
	6'd14 : begin
		GB_BLK <= {rev_t_blk_s[49:0], buffer[13:0]};
		buffer[14:0] <= rev_t_blk_s[64:50];
	end
	
	6'd15 : begin
		GB_BLK <= {rev_t_blk_s[48:0], buffer[14:0]};
		buffer[15:0] <= rev_t_blk_s[64:49];
	end
	
	6'd16 : begin
		GB_BLK <= {rev_t_blk_s[47:0], buffer[15:0]};
		buffer[16:0] <= rev_t_blk_s[64:48];
	end
	
	6'd17 : begin
		GB_BLK <= {rev_t_blk_s[46:0], buffer[16:0]};
		buffer[17:0] <= rev_t_blk_s[64:47];
	end
	
	6'd18 : begin
		GB_BLK <= {rev_t_blk_s[45:0], buffer[17:0]};
		buffer[18:0] <= rev_t_blk_s[64:46];
	end
	
	6'd19 : begin
		GB_BLK <= {rev_t_blk_s[44:0], buffer[18:0]};
		buffer[19:0] <= rev_t_blk_s[64:45];
	end
	
	6'd20 : begin
		GB_BLK <= {rev_t_blk_s[43:0], buffer[19:0]};
		buffer[20:0] <= rev_t_blk_s[64:44];
	end
	
	6'd21 : begin
		GB_BLK <= {rev_t_blk_s[42:0], buffer[20:0]};
		buffer[21:0] <= rev_t_blk_s[64:43];
	end
	
	6'd22 : begin
		GB_BLK <= {rev_t_blk_s[41:0], buffer[21:0]};
		buffer[22:0] <= rev_t_blk_s[64:42];
	end
	
	6'd23 : begin
		GB_BLK <= {rev_t_blk_s[40:0], buffer[22:0]};
		buffer[23:0] <= rev_t_blk_s[64:41];
	end
	
	6'd24 : begin
		GB_BLK <= {rev_t_blk_s[39:0], buffer[23:0]};
		buffer[24:0] <= rev_t_blk_s[64:40];
	end
	
	6'd25 : begin
		GB_BLK <= {rev_t_blk_s[38:0], buffer[24:0]};
		buffer[25:0] <= rev_t_blk_s[64:39];
	end
	
	6'd26 : begin
		GB_BLK <= {rev_t_blk_s[37:0], buffer[25:0]};
		buffer[26:0] <= rev_t_blk_s[64:38];
	end
	
	6'd27 : begin
		GB_BLK <= {rev_t_blk_s[36:0], buffer[26:0]};
		buffer[27:0] <= rev_t_blk_s[64:37];
	end
	
	6'd28 : begin
		GB_BLK <= {rev_t_blk_s[35:0], buffer[27:0]};
		buffer[28:0] <= rev_t_blk_s[64:36];
	end
	
	6'd29 : begin
		GB_BLK <= {rev_t_blk_s[34:0], buffer[28:0]};
		buffer[29:0] <= rev_t_blk_s[64:35];
	end
	
	6'd30 : begin
		GB_BLK <= {rev_t_blk_s[33:0], buffer[29:0]};
		buffer[30:0] <= rev_t_blk_s[64:34];
	end
	
	6'd31 : begin
		GB_BLK <= {rev_t_blk_s[32:0], buffer[30:0]};
		buffer[31:0] <= rev_t_blk_s[64:33];
	end
	
	6'd32 : begin
		GB_BLK <= {rev_crc32, buffer[31:0]};
	end
	
	endcase
end
endmodule

