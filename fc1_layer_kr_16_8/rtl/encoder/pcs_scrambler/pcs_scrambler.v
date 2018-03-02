/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-03-11 09:51:01 -0700 (Tue, 11 Mar 2014) $
* $Revision: 4823 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


//self-synchronizer scrambler 
//Uses along pattern length to reduce possibility of jamming. 
//The polynomial is: 1 + X58 + X19


module pcs_scrambler (
	input   CLK,
	input   RST,		// Active high
	input   CSR_PCS_SCRAMB_DIS,		//scrambler enable  from Register Interface block
	input   CSR_ENC_IN_ENDIAN_SWAP,
	
	input   DIN_EN,
	input   [63:0] DIN,     // bit 0 is to be sent first
	input   [1:0]  DIN_SH,     // bit 0 is to be sent first
	
	output  reg     [65:0] DOUT,
	output  reg     DOUT_EN
);

parameter WIDTH    =  64;



reg     [57:0] s;

wire    [WIDTH+58-1:0] history; 


wire    [63:0] din_swap;

//reverse #(64) reverse_inst (.ENA       (CSR_ENC_IN_ENDIAN_SWAP), .IN   (DIN), .OUT     (din_swap));
assign din_swap = DIN;


always @(posedge CLK)
	if (RST)
  begin  
		DOUT <= 'h0;
		DOUT_EN <= 1'b0;
	end

  else if (!CSR_PCS_SCRAMB_DIS)  
	begin
		DOUT <= {history[WIDTH+58-1:58], DIN_SH};
		DOUT_EN <=   DIN_EN; 
	end  
	
	else 
	begin
		DOUT <= {din_swap, DIN_SH};
		DOUT_EN <=   DIN_EN; 
	end  

assign  history [57:0]   =  s[57:0];

genvar i;
generate   
  for (i  =  58; i < WIDTH + 58; i = i + 1) begin: history_gen
  	assign  history[i]   =  din_swap[i-58] ^  history[i-39] ^ history[i-58];
  end
endgenerate

always @(posedge CLK) begin
	if (RST) 
		s <= {58{1'b1}};
	else if (!CSR_PCS_SCRAMB_DIS && DIN_EN)
		s[57:0] <= history[WIDTH+58-1:WIDTH];   
	
end



endmodule
