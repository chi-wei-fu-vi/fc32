/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author$
* $Date$
* $Revision$
* $HeadURL$
* Description: Parameterized LFSR
***********************************************************************************************************/

module vi_lfsr #(parameter WIDTH = 64) 
   (
    input                     clk,
    input                     rst_n,
    input 		      load,        // load a value into the LFSR
    input                     enable,      // clock the LFSR
    input [WIDTH-1:0] 	      new_seed,    // new seed value loaded when load is asserted
    output reg [WIDTH-1:0]    lfsr 
    );

   wire 		      fb;


   // initialization value is all 1's
   always @(posedge clk or negedge rst_n)
     if (~rst_n)
       lfsr[WIDTH-1:0] <= {WIDTH{1'b1}};
     else if (load)
       lfsr[WIDTH-1:0] <= new_seed[WIDTH-1:0];
     else if (enable) 
       lfsr[WIDTH-1:0] <= {lfsr[WIDTH-2:0],fb};

   // Fibonacci polynomials, maximum-length, lockup state is all zeros. 
  generate

     // x^5 + x^3 + 1
     if (WIDTH == 5) begin: width_eq_5
	assign fb = lfsr[4] ^ lfsr[2] ;
     end 

     // x^7 + x^6 + 1
     if (WIDTH == 7) begin: width_eq_7
	assign fb = lfsr[6] ^ lfsr[5] ;
     end 

     // x^24 + x^23 + x^22 + x^17 + 1
     else if (WIDTH == 24) begin: width_eq_24
	assign fb = lfsr[23] ^ lfsr[22]  ^ lfsr[21]  ^ lfsr[16] ;
     end

     // x^31 + x^28 + 1
     else if (WIDTH == 31) begin: width_eq_31
	assign fb = lfsr[30] ^ lfsr[27] ;
     end
     
     // x^32 + x^22 + x^2 + x^1 + 1
     else if (WIDTH == 32) begin: width_eq_32
	assign fb = lfsr[31] ^ lfsr[21]  ^ lfsr[1]  ^ lfsr[0] ;
     end
     
     else begin : other
	assign fb = 1'b0;
     end
     
  endgenerate
endmodule
