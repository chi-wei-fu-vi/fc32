/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: 2012-07-13 14:28:26 -0700 (Fri, 13 Jul 2012) $
* $Revision: 71 $
* Description:
*
* This file should contain reusable modules that are portable across blocks
* or applications
*
* Revision History Notes:
* 2012/07/26 Tim - initial release
*
***************************************************************************/

//----------------------------------------------------------------------
// arbiter - arbitrary width
// iBASE sets port with highest priority
// iBASE=1 means iREQ[0] has highest priority
// iBASE=2^(WIDTH-1) means iREQ[WIDTH-1] has highest priority
// iBASE is one-hot
//----------------------------------------------------------------------
module arbiter_fixed_priority
#(
   parameter WIDTH = 8
)(
  input  [WIDTH-1:0]  iREQ,
  output [WIDTH-1:0]  oGNT,
  input  [WIDTH-1:0]  iBASE
);
import bali_lib_pkg::*;
  wire [2*WIDTH-1:0] double_req = {iREQ,iREQ};
  wire [2*WIDTH-1:0] double_grant = double_req & ~(double_req-iBASE);
  assign oGNT = double_grant[WIDTH-1:0] | double_grant[2*WIDTH-1:WIDTH];
endmodule

//----------------------------------------------------------------------
// arbiter_round_robin
// After a port completes, they must de-assert request for a single-cycle
// to allow round-robin to select next port.
// WIDTH = # ports (2-8 ports are supported)
//----------------------------------------------------------------------
module arbiter_round_robin
#(
   parameter WIDTH = 16
)(
  input               iRST,
  input               iCLK,
  input  [WIDTH-1:0]  iREQ,
  output [WIDTH-1:0]  oGNT
);
import bali_lib_pkg::*;

logic [WIDTH-1:0] gnt;
logic [WIDTH-1:0] gnt_r1;
logic [WIDTH-1:0] next_base;
logic req_r1;

assign oGNT = gnt_r1;

always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    req_r1   <= 0;
    next_base <= 1;
  end
  else
  begin
    req_r1 <= iREQ[encoder_16_4(gnt_r1)];

    // if request is de-asserting then pick next base.
    if( req_r1 && !iREQ[encoder_16_4(gnt_r1)])
      next_base <= {gnt_r1[WIDTH-2:0], gnt_r1[WIDTH-1]}; // shift left
  end
end

always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    gnt_r1 <= '0;
  else
    gnt_r1 <= gnt;
end

arbiter_fixed_priority
#(
   .WIDTH (WIDTH)
)
arbiter_fixed_priority_inst

(
  .iREQ  (iREQ),
  .oGNT  (gnt),
  .iBASE (next_base)  // base must be one-hot
);

endmodule

//----------------------------------------------------------------------
// arbiter - LSB is highest priority
//----------------------------------------------------------------------
module arbiter_3port
(
  input        [2:0] iREQ,
  output logic [2:0] oGNT
);
import bali_lib_pkg::*;

  assign oGNT[0] =  iREQ[0];
  assign oGNT[1] = ~iREQ[0] &  iREQ[1];
  assign oGNT[2] = ~iREQ[0] & ~iREQ[1] & iREQ[2];
endmodule


//----------------------------------------------------------------------
// 8to1 256-bit wide mux with one-hot select
//----------------------------------------------------------------------
module mux8x256
(
input  [7:0][255:0] iDATA_VEC,
input  [7:0]        iSEL,
output      [255:0] oDATA
);
import bali_lib_pkg::*;

assign  oDATA = ({256{iSEL[0]}} & iDATA_VEC[0]) |
                ({256{iSEL[1]}} & iDATA_VEC[1]) |
                ({256{iSEL[2]}} & iDATA_VEC[2]) |
                ({256{iSEL[3]}} & iDATA_VEC[3]) |
                ({256{iSEL[4]}} & iDATA_VEC[4]) |
                ({256{iSEL[5]}} & iDATA_VEC[5]) |
                ({256{iSEL[6]}} & iDATA_VEC[6]) |
                ({256{iSEL[7]}} & iDATA_VEC[7]);
endmodule


//----------------------------------------------------------------------
// one-hot input to binary encoded output
// WIDTHs supported are: 2 to 8 one-hot inputs
//----------------------------------------------------------------------
module encode(data_in, data_out);
import bali_lib_pkg::*;

   function integer clogb(input integer argument);
      integer i;
      begin
   clogb = 0;
   for(i = argument - 1; i > 0; i = i >> 1)
     clogb = clogb + 1;
      end
   endfunction

   parameter  IN_WIDTH = 8; // one-hot input data width
   localparam OUT_WIDTH = clogb(IN_WIDTH);

   input        [0:IN_WIDTH-1]   data_in;    // one-hot input data
   output logic [0:OUT_WIDTH-1]  data_out;    // binary encoded output data

   generate
      // synopsys translate_off
     if(IN_WIDTH < 2)
     begin
       initial
       begin
         $display("ERROR: Encoder module %m needs at least two inputs.");
         $stop;
       end
     end
      // synopsys translate_on
      if(IN_WIDTH == 2)
        always@(data_in)
          begin
             case(data_in)
               2'b10:
                 data_out = (1) % 2;
               2'b01:
                 data_out = (0) % 2;
               default:
                 data_out = {1{1'bx}};
             endcase
          end
      else if(IN_WIDTH == 3)
        always@(data_in)
          begin
             case(data_in)
               3'b100:
                 data_out = (2) % 3;
               3'b010:
                 data_out = (1) % 3;
               3'b001:
                 data_out = (0) % 3;
               default:
                 data_out = {2{1'bx}};
             endcase
          end
      else if(IN_WIDTH == 4)
        always@(data_in)
          begin
             case(data_in)
               4'b1000:
                 data_out = (3) % 4;
               4'b0100:
                 data_out = (2) % 4;
               4'b0010:
                 data_out = (1) % 4;
               4'b0001:
                 data_out = (0) % 4;
               default:
                 data_out = {2{1'bx}};
             endcase
          end
      else if(IN_WIDTH == 5)
        always@(data_in)
          begin
             case(data_in)
               5'b10000:
                 data_out = (4) % 5;
               5'b01000:
                 data_out = (3) % 5;
               5'b00100:
                 data_out = (2) % 5;
               5'b00010:
                 data_out = (1) % 5;
               5'b00001:
                 data_out = (0) % 5;
               default:
                 data_out = {3{1'bx}};
             endcase
          end
      else if(IN_WIDTH == 6)
        always@(data_in)
          begin
             case(data_in)
               6'b100000:
                 data_out = (5) % 6;
               6'b010000:
                 data_out = (4) % 6;
               6'b001000:
                 data_out = (3) % 6;
               6'b000100:
                 data_out = (2) % 6;
               6'b000010:
                 data_out = (1) % 6;
               6'b000001:
                 data_out = (0) % 6;
               default:
                 data_out = {3{1'bx}};
             endcase
          end
      else if(IN_WIDTH == 7)
        always@(data_in)
          begin
             case(data_in)
               7'b1000000:
                 data_out = (6) % 7;
               7'b0100000:
                 data_out = (5) % 7;
               7'b0010000:
                 data_out = (4) % 7;
               7'b0001000:
                 data_out = (3) % 7;
               7'b0000100:
                 data_out = (2) % 7;
               7'b0000010:
                 data_out = (1) % 7;
               7'b0000001:
                 data_out = (0) % 7;
               default:
                 data_out = {3{1'bx}};
             endcase
          end
      else if(IN_WIDTH == 8)
        always@(data_in)
          begin
             case(data_in)
               8'b10000000:
                 data_out = (7) % 8;
               8'b01000000:
                 data_out = (6) % 8;
               8'b00100000:
                 data_out = (5) % 8;
               8'b00010000:
                 data_out = (4) % 8;
               8'b00001000:
                 data_out = (3) % 8;
               8'b00000100:
                 data_out = (2) % 8;
               8'b00000010:
                 data_out = (1) % 8;
               8'b00000001:
                 data_out = (0) % 8;
               default:
                 data_out = {3{1'bx}};
             endcase
          end
  endgenerate
endmodule
