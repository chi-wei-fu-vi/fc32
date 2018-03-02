/********************************CONFIDENTIAL****************************
* Copyright (c) 2014 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
* This module decodes address and mux/demux read/write data among configuration registers.
* This was generated from bist_addr_decoder.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.
***************************************************************************/
module link1_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [16:0]          XX04_G_ADDR,
  output logic [63:0]          XX04_G_WR_DATA,
  output logic                 XX04_G_WR_EN,
  output logic                 XX04_G_RD_EN,
  output logic [16:0]          CH0_ADDR,
  output logic [63:0]          CH0_WR_DATA,
  output logic                 CH0_WR_EN,
  output logic                 CH0_RD_EN,
  output logic [16:0]          CH1_ADDR,
  output logic [63:0]          CH1_WR_DATA,
  output logic                 CH1_WR_EN,
  output logic                 CH1_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [16:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          XX04_G_RD_DATA,
  input                        XX04_G_RD_DATA_V,
  input        [63:0]          CH0_RD_DATA,
  input                        CH0_RD_DATA_V,
  input        [63:0]          CH1_RD_DATA,
  input                        CH1_RD_DATA_V
);

  logic  [63:0]                rd_data;
  logic                        rd_data_v;
  logic  [16:0]                laddr;
  logic  [63:0]                ldata;
  logic                        ldata_v;
  logic                        ldata_vd;
  logic                        lwen;
  logic                        lren;
  logic  [63:0]                lwdata;
  logic                        lxx04_g_wren;
  logic                        lxx04_g_rden;
  logic                        lch0_wren;
  logic                        lch0_rden;
  logic                        lch1_wren;
  logic                        lch1_rden;
  always_comb begin
    lxx04_g_wren              = 0;
    lxx04_g_rden              = 0;
    lch0_wren                 = 0;
    lch0_rden                 = 0;
    lch1_wren                 = 0;
    lch1_rden                 = 0;
    unique casez(laddr)
      17'b000zzzzzzzzzzzzzz: begin  // xx04_g
        lxx04_g_wren              = lwen;
        lxx04_g_rden              = lren;
        ldata                    = XX04_G_RD_DATA;
        ldata_v                  = XX04_G_RD_DATA_V;
      end
      17'b001zzzzzzzzzzzzzz: begin  // ch0
        lch0_wren                 = lwen;
        lch0_rden                 = lren;
        ldata                    = CH0_RD_DATA;
        ldata_v                  = CH0_RD_DATA_V;
      end
      17'b010zzzzzzzzzzzzzz: begin  // ch1
        lch1_wren                 = lwen;
        lch1_rden                 = lren;
        ldata                    = CH1_RD_DATA;
        ldata_v                  = CH1_RD_DATA_V;
      end

      default: begin
        ldata                    = {32'h5555_AAAA,15'b0,laddr};
        ldata_v                  = lren;
      end
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      rd_data           <= 0;
      rd_data_v         <= 0;
      laddr             <= 'h0;
      lwen              <= 0;
      lren              <= 0;
      lwdata            <= 'h0;
    end
    else begin
      rd_data           <= ldata;
      ldata_vd          <= ldata_v;
      rd_data_v         <= ldata_vd;
      laddr             <= iMM_ADDR;
      lwen              <= iMM_WR_EN;
      lren              <= iMM_RD_EN;
      lwdata            <= iMM_WR_DATA;
    end
  end
  assign oMM_RD_DATA     = rd_data;
  assign oMM_RD_DATA_V   = rd_data_v;

  assign XX04_G_ADDR               = laddr;
  assign XX04_G_WR_EN              = lxx04_g_wren;
  assign XX04_G_RD_EN              = lxx04_g_rden;
  assign XX04_G_WR_DATA            = lwdata;
  assign CH0_ADDR                  = laddr;
  assign CH0_WR_EN                 = lch0_wren;
  assign CH0_RD_EN                 = lch0_rden;
  assign CH0_WR_DATA               = lwdata;
  assign CH1_ADDR                  = laddr;
  assign CH1_WR_EN                 = lch1_wren;
  assign CH1_RD_EN                 = lch1_rden;
  assign CH1_WR_DATA               = lwdata;

endmodule