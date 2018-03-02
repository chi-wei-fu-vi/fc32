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
module xx02_g_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [13:0]          CSR_ADDR,
  output logic [63:0]          CSR_WR_DATA,
  output logic                 CSR_WR_EN,
  output logic                 CSR_RD_EN,
  output logic [13:0]          PERF_ADDR,
  output logic [63:0]          PERF_WR_DATA,
  output logic                 PERF_WR_EN,
  output logic                 PERF_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [13:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          CSR_RD_DATA,
  input                        CSR_RD_DATA_V,
  input        [63:0]          PERF_RD_DATA,
  input                        PERF_RD_DATA_V
);

  logic  [63:0]                rd_data;
  logic                        rd_data_v;
  logic  [13:0]                laddr;
  logic  [63:0]                ldata;
  logic                        ldata_v;
  logic                        ldata_vd;
  logic                        lwen;
  logic                        lren;
  logic  [63:0]                lwdata;
  logic                        lcsr_wren;
  logic                        lcsr_rden;
  logic                        lperf_wren;
  logic                        lperf_rden;
  always_comb begin
    lcsr_wren                 = 0;
    lcsr_rden                 = 0;
    lperf_wren                = 0;
    lperf_rden                = 0;
    unique casez(laddr)
      14'b0000zzzzzzzzzz: begin  // csr
        lcsr_wren                 = lwen;
        lcsr_rden                 = lren;
        ldata                    = CSR_RD_DATA;
        ldata_v                  = CSR_RD_DATA_V;
      end
      14'b0001zzzzzzzzzz: begin  // perf
        lperf_wren                = lwen;
        lperf_rden                = lren;
        ldata                    = PERF_RD_DATA;
        ldata_v                  = PERF_RD_DATA_V;
      end

      default: begin
        ldata                    = {32'h5555_AAAA,18'b0,laddr};
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

  assign CSR_ADDR                  = laddr;
  assign CSR_WR_EN                 = lcsr_wren;
  assign CSR_RD_EN                 = lcsr_rden;
  assign CSR_WR_DATA               = lwdata;
  assign PERF_ADDR                 = laddr;
  assign PERF_WR_EN                = lperf_wren;
  assign PERF_RD_EN                = lperf_rden;
  assign PERF_WR_DATA              = lwdata;

endmodule