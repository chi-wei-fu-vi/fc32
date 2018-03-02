/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-05-01 11:45:12 -0700 (Thu, 01 May 2014) $
* $Revision: 5583 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/



module pcs_descrambler
#(
	parameter WIDTH=  64,
	parameter CH = 0
)
(
	input   CLK,
	input   RST,		// Active low
	input   CSR_PCS_DESCRAMB_DIS,
	input   CSR_DEC_DESCRAM_IN_ENDIAN_SWAP,
	input   CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP,
	
	input   [WIDTH-1:0] DIN,
	input   [1:0] DIN_SH,
	input   DIN_EN,
	input   DIN_BLOCK_SYNC,
	output  reg DOUT_BLOCK_SYNC,
	output  [WIDTH-1:0] DOUT,
	
	output  reg     [1:0] DOUT_SH,
	output  reg     DOUT_EN
	
);

reg     [WIDTH-1:0] dout, dout_s;
reg     [WIDTH-1:0] dout_int;
wire    [WIDTH+58-1:0] history;
reg     [57:0] s;

wire [WIDTH-1:0] din;

//reverse #(64) descram_in_reverse_inst (.ENA(CSR_DEC_DESCRAM_IN_ENDIAN_SWAP), .IN      (DIN), .OUT (din));

assign din = DIN;

reg     dvld;
reg     [1:0] sh_reg;
reg     [WIDTH-1:0] din_s;
wire    [WIDTH-1:0] dout_w;
reg     block_sync, block_sync_s;

wire descramb_dis;

vi_sync_level
#(.SIZE(1)) descramb_dis_sync (
    .out_level(descramb_dis),
    .clk(CLK),
    .rst_n(~RST),
    .in_level(CSR_PCS_DESCRAMB_DIS)
);


always @(posedge CLK) begin
	if (RST)
	begin
		sh_reg <= 2'b00;
		dvld <= 0;
		din_s <= 'h0;
		block_sync <= 'h0;
		block_sync_s <= 'h0;
	end
	else 
	begin
		dvld <= DIN_EN; 
		sh_reg <= DIN_SH;
		din_s <= din;
		block_sync <= DIN_BLOCK_SYNC;
		block_sync_s <= block_sync;
  end
end


assign history =  {din[WIDTH-1:0],s[57:0]};

genvar i;
generate 
  for (i=0; i<WIDTH; i =i+1) begin : next_s_gen
		assign dout_w[i] = history[58+i-58] ^ history[58+i-39] ^ history[58+i];
	end
endgenerate

//polynomial x58 + x19 + 1
always @(posedge CLK)
	if (RST || !DIN_BLOCK_SYNC) 
	begin
		dout_int <= 'h0;
		s[57:0] <= {58{1'b1}};
	end
	else if (DIN_EN)
	begin
		dout_int <= dout_w;
		s[57:0] <= history[WIDTH+58-1:WIDTH];      //history[121:64]
	end


always @(posedge CLK) begin
	if (RST)  
	begin
		dout <= 0;
		DOUT_EN <= 0;
		DOUT_SH <= 0;
		DOUT_BLOCK_SYNC <= 1'b0;
	end
	else if(!DIN_BLOCK_SYNC) 
	begin
		dout <= 0;
		DOUT_EN <= 0;
		DOUT_SH <= 0;
		DOUT_BLOCK_SYNC <= 1'b0;
	end
	else begin
		DOUT_EN <= dvld;
		DOUT_SH <= sh_reg;
		dout <= !descramb_dis ? dout_int[WIDTH-1:0] : din_s; 
		DOUT_BLOCK_SYNC <= block_sync_s;
	end
end

assign DOUT = dout;
/*
//SIGNALTAP
//==========================================================
generate
  if (CH == 0) begin: sigtap_gen_DESC1
//signaltap
wire [127:0] DESC1_acq_data_in;
wire         DESC1_acq_clk;

assign DESC1_acq_clk = CLK;

signaltap DESC1_signaltap_inst (
  .acq_clk(DESC1_acq_clk),
  .acq_data_in(DESC1_acq_data_in),
  .acq_trigger_in(DESC1_acq_data_in)
);

assign DESC1_acq_data_in = {
//128
dout_int[63:0],
//112
//104
//96
//90
//64
dout_w[63:0]
//48
//32
//16
};

  end  // if LINK_ID, CH_ID
endgenerate


generate
  if (CH == 0) begin: sigtap_gen_DESC0
//signaltap
wire [127:0] DESC0_acq_data_in;
wire         DESC0_acq_clk;

assign DESC0_acq_clk = CLK;

signaltap DESC0_signaltap_inst (
  .acq_clk(DESC0_acq_clk),
  .acq_data_in(DESC0_acq_data_in),
  .acq_trigger_in(DESC0_acq_data_in)
);

assign DESC0_acq_data_in = {
//128
DIN_EN,
DIN_SH[1:0],
RST,
DIN_BLOCK_SYNC,
descramb_dis,

s[57:0],
//112
//104
//96
//90
//64
din[63:0]
//48
//32
//16
};

  end  // if LINK_ID, CH_ID
endgenerate

//==========================================================

*/

//reverse #(64) descram_out_reverse_inst (.ENA(CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP), .IN  (dout), .OUT (DOUT));

endmodule
