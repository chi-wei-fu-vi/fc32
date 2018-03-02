// Modified for little-endian (byte 0 at [7:0] and byte 3 at [39:30])

module vi_x4_decoder_8b10b (
	input         clk,
	input         rst,
	input [39:0]  din_dat,         // 10b data input
	output [31:0] dout_dat,        // data out
	output [3:0]  dout_k,          // special code
	output [3:0]  dout_kerr,       // coding mistake detected
	output [3:0]  dout_rderr,      // running disparity mistake detected
	output [3:0]  dout_rdcomb,     // running dispartiy output (comb)
	output [3:0]  dout_rdreg       // running disparity output (reg)
);

parameter METHOD = 1;

decoder_8b10b dec3(
    .clk (clk),
    .rst (rst),
    .din_ena(1'b1),                   // Data (or code) input enable
    .din_dat(din_dat[39 : 30]),       // 8b data in
    //.din_rd(dout_rdreg[0]),           // running disparity input
	 .din_rd(dout_rdcomb[2]),           // running disparity input
    .dout_val(),
    .dout_kerr(dout_kerr[3]),
    .dout_dat(dout_dat[31 : 24]),     // data out
    .dout_k(dout_k[3]),
    .dout_rderr(dout_rderr[3]),
    .dout_rdcomb(dout_rdcomb[3]),     // running disparity output (comb)
    .dout_rdreg(dout_rdreg[3])        // running disparity output (reg)
);
defparam dec3.METHOD = METHOD;
	
decoder_8b10b dec2(
    .clk (clk),
    .rst (rst),
    .din_ena(1'b1),                   // Data (or code) input enable
    .din_dat(din_dat[29 : 20]),       // 8b data in
   // .din_rd(dout_rdcomb[3]),          // running disparity input
	 .din_rd(dout_rdcomb[1]),           // running disparity input
    .dout_val(),
    .dout_kerr(dout_kerr[2]),
    .dout_dat(dout_dat[23 : 16]),     // data out
    .dout_k(dout_k[2]),
    .dout_rderr(dout_rderr[2]),
    .dout_rdcomb(dout_rdcomb[2]),     // running disparity output (comb)
    .dout_rdreg(dout_rdreg[2])        // running disparity output (reg)
);
defparam dec2.METHOD = METHOD;
	
decoder_8b10b dec1(
    .clk (clk),
    .rst (rst),
    .din_ena(1'b1),                   // Data (or code) input enable
    .din_dat(din_dat[19 : 10]),       // 8b data in
    //.din_rd(dout_rdcomb[2]),          // running disparity input
	 .din_rd(dout_rdcomb[0]),          // running disparity input
    .dout_val(),
    .dout_kerr(dout_kerr[1]),
    .dout_dat(dout_dat[15 : 8]),      // data out
    .dout_k(dout_k[1]),
    .dout_rderr(dout_rderr[1]),
    .dout_rdcomb(dout_rdcomb[1]),     // running disparity output (comb)
    .dout_rdreg(dout_rdreg[1])        // running disparity output (reg)
);
defparam dec1.METHOD = METHOD;

decoder_8b10b dec0(
    .clk (clk),
    .rst (rst),
    .din_ena(1'b1),                   // Data (or code) input enable
    .din_dat(din_dat[9 : 0]),         // 8b data in
    //.din_rd(dout_rdcomb[1]),          // running disparity input
	 .din_rd(dout_rdreg[3]),           // running disparity input
    .dout_val(),
    .dout_kerr(dout_kerr[0]),
    .dout_dat(dout_dat[7 : 0]),       // data out
    .dout_k(dout_k[0]),
    .dout_rderr(dout_rderr[0]),
    .dout_rdcomb(dout_rdcomb[0]),     // running disparity output (comb)
    .dout_rdreg(dout_rdreg[0])        // running disparity output (reg)
);
defparam dec0.METHOD = METHOD;

endmodule
