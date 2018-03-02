module vi_x4_encoder_8b10b 
  (
    input                   clk,
    input 		    rst,
    input 		    force_rd_negative,   // force running disparity in to be negative			 
    input [3:0] 	    kin_ena,             // Data in is a special code, not all are legal.      
    input [31:0] 	    ein_dat,             // 8b data in
    output [3:0] 	    eout_rdcomb,         // running disparity out (combinatorial version)
    output [39:0] 	    eout_dat,            // data out
    output [39:0] 	    eout_dat_be          // data out (big endian)
);

   parameter METHOD = 1;
   
   wire [3:0] 	  eout_rdreg;
   wire [3:0] 	  eout_val;                   // not used, since ein_ena not used in cascaded version
   wire 	  rd_in_enc0;
   
   assign   rd_in_enc0 = force_rd_negative ? 1'b0 : eout_rdreg[3];
   
   encoder_8b10b enc0
     (
      .clk (clk),
      .rst (rst),
      .kin_ena(kin_ena[0]),             // Data in is a special code, not all are legal.      
      .ein_ena(1'b1),                   // Data (or code) input enable
      .ein_dat(ein_dat[7 : 0]),         // 8b data in
      .ein_rd(rd_in_enc0),              // running disparity input
      .eout_val(eout_val[0]),           // data out is valid
      .eout_dat(eout_dat[9 : 0]),       // data out
      .eout_rdcomb(eout_rdcomb[0]),     // running disparity output (comb)
      .eout_rdreg(eout_rdreg[0])        // running disparity output (reg)
      );
   defparam enc0.METHOD = METHOD;
   
   encoder_8b10b enc1
     (
      .clk (clk),
      .rst (rst),
      .kin_ena(kin_ena[1]),             // Data in is a special code, not all are legal.      
      .ein_ena(1'b1),                   // Data (or code) input enable
      .ein_dat(ein_dat[15 : 8]),        // 8b data in
      .ein_rd(eout_rdcomb[0]),          // running disparity input
      .eout_val(eout_val[1]),           // data out is valid
      .eout_dat(eout_dat[19 : 10]),     // data out
      .eout_rdcomb(eout_rdcomb[1]),     // running disparity output (comb)
      .eout_rdreg(eout_rdreg[1])        // running disparity output (reg)
      );
   defparam enc1.METHOD = METHOD;
   
   encoder_8b10b enc2
     (
      .clk (clk),
      .rst (rst),
      .kin_ena(kin_ena[2]),             // Data in is a special code, not all are legal.      
      .ein_ena(1'b1),                   // Data (or code) input enable
      .ein_dat(ein_dat[23 : 16]),       // 8b data in
      .ein_rd(eout_rdcomb[1]),          // running disparity input
      .eout_val(eout_val[2]),           // data out is valid
      .eout_dat(eout_dat[29 : 20]),     // data out
      .eout_rdcomb(eout_rdcomb[2]),     // running disparity output (comb)
      .eout_rdreg(eout_rdreg[2])        // running disparity output (reg)
      );
   defparam enc2.METHOD = METHOD;
   
   encoder_8b10b enc3
     (
      .clk (clk),
      .rst (rst),
      .kin_ena(kin_ena[3]),             // Data in is a special code, not all are legal.      
      .ein_ena(1'b1),                   // Data (or code) input enable
      .ein_dat(ein_dat[31 : 24]),       // 8b data in
      .ein_rd(eout_rdcomb[2]),           // running disparity input
      .eout_val(eout_val[3]),           // data out is valid
      .eout_dat(eout_dat[39 : 30]),     // data out
      .eout_rdcomb(eout_rdcomb[3]),     // running disparity output (comb)
      .eout_rdreg(eout_rdreg[3])        // running disparity output (reg)
      );
   defparam enc3.METHOD = METHOD;
   
   assign eout_dat_be[39:0] = {eout_dat[30], eout_dat[31], eout_dat[32], eout_dat[33], eout_dat[34],
			       eout_dat[35], eout_dat[36], eout_dat[37], eout_dat[38], eout_dat[39],
			       eout_dat[20], eout_dat[21], eout_dat[22], eout_dat[23], eout_dat[24],
			       eout_dat[25], eout_dat[26], eout_dat[27], eout_dat[28], eout_dat[29],
			       eout_dat[10], eout_dat[11], eout_dat[12], eout_dat[13], eout_dat[14],
			       eout_dat[15], eout_dat[16], eout_dat[17], eout_dat[18], eout_dat[19],
			       eout_dat[0],  eout_dat[1],  eout_dat[2],  eout_dat[3],  eout_dat[4],
			       eout_dat[5],  eout_dat[6],  eout_dat[7],  eout_dat[8],  eout_dat[9]};
   
endmodule

