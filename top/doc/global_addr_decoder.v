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
module global_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [16:0]          XX01_G_ADDR,
  output logic [63:0]          XX01_G_WR_DATA,
  output logic                 XX01_G_WR_EN,
  output logic                 XX01_G_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [16:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          XX01_G_RD_DATA,
  input                        XX01_G_RD_DATA_V
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
  logic                        lxx01_g_wren;
  logic                        lxx01_g_rden;
  always_comb begin
    lxx01_g_wren              = 0;
    lxx01_g_rden              = 0;
    unique casez(laddr)
      17'b000zzzzzzzzzzzzzz: begin  // xx01_g
        lxx01_g_wren              = lwen;
        lxx01_g_rden              = lren;
        ldata                    = XX01_G_RD_DATA;
        ldata_v                  = XX01_G_RD_DATA_V;
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

  assign XX01_G_ADDR               = laddr;
  assign XX01_G_WR_EN              = lxx01_g_wren;
  assign XX01_G_RD_EN              = lxx01_g_rden;
  assign XX01_G_WR_DATA            = lwdata;

endmodule