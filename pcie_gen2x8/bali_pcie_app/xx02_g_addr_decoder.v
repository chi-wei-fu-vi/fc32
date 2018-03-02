/********************************CONFIDENTIAL****************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: jaedon.kim $
* $Date: 2013-05-08 15:18:12 -0700 (Wed, 08 May 2013) $
* $Revision: 2204 $
* Description:
* This module decodes address and mux/demux read/write data among configuration registers.
* This is generated from xx02_g_addr_decoder.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.

***************************************************************************/
module xx02_g_addr_decoder (clk,rst_n,iMM_ADDR,iMM_WR_EN,iMM_RD_EN,iMM_WR_DATA,oMM_RD_DATA,oMM_RD_DATA_V,CSR_ADDR,CSR_WR_DATA,CSR_WR_EN,CSR_RD_EN,CSR_RD_DATA,CSR_RD_DATA_V,PERF_ADDR,PERF_WR_DATA,PERF_WR_EN,PERF_RD_EN,PERF_RD_DATA,PERF_RD_DATA_V);
input clk;
input rst_n;
input [13:0] iMM_ADDR;
input iMM_WR_EN;
input iMM_RD_EN;
input [63:0] iMM_WR_DATA;
output [63:0] oMM_RD_DATA;
output oMM_RD_DATA_V;
output [13:0] CSR_ADDR;
output [63:0] CSR_WR_DATA;
output CSR_WR_EN;
output CSR_RD_EN;
input [63:0] CSR_RD_DATA;
input CSR_RD_DATA_V;
output [13:0] PERF_ADDR;
output [63:0] PERF_WR_DATA;
output PERF_WR_EN;
output PERF_RD_EN;
input [63:0] PERF_RD_DATA;
input PERF_RD_DATA_V;

reg [63:0] rd_data;
reg rd_data_v;
reg [63:0] ldata;
reg ldata_v;
reg ldata_vd;
reg [13:0] laddr;
reg lwen;
reg lren;
reg [63:0] lwdata;
reg lcsr_wren;
reg lcsr_rden;
reg lperf_wren;
reg lperf_rden;

always @*
  begin
    lperf_wren = 0;
    lperf_rden = 0;
    lcsr_wren = 0;
    lcsr_rden = 0;
    
casez (laddr) // synopsys parallel_case
    14'b0000zzzzzzzzzz :
    begin  // csr
    lcsr_wren = lwen;
    lcsr_rden = lren;
    ldata_v = CSR_RD_DATA_V;
    ldata = CSR_RD_DATA;
    end
    14'b0001zzzzzzzzzz :
    begin  // perf
    lperf_wren = lwen;
    lperf_rden = lren;
    ldata_v = PERF_RD_DATA_V;
    ldata = PERF_RD_DATA;
    end
    default :
    begin
      ldata = {32'h5555_AAAA,{18{1'b0}},laddr};
      ldata_v = lren;
    end
    endcase

  end

   always @(posedge clk or negedge rst_n)
    begin
      if (~rst_n)
        begin
          rd_data <= 0;
          rd_data_v <= 0;
          laddr <= 'h0;
          lwen <= 0;
          lren <= 0;
          lwdata <= 'h0;
        end
      else
        begin
           rd_data <= ldata;
           ldata_vd <= ldata_v;
           rd_data_v <= ldata_vd;
           laddr <= iMM_ADDR;
           lwen <= iMM_WR_EN;
           lren <= iMM_RD_EN;
           lwdata <= iMM_WR_DATA;           
         end // else: !if(~rst_n)
    end // always @ (posedge clk)

    assign oMM_RD_DATA = rd_data;
    assign oMM_RD_DATA_V = rd_data_v;

    assign CSR_ADDR = laddr;
    assign CSR_WR_EN = lcsr_wren;
    assign CSR_RD_EN = lcsr_rden;
    assign CSR_WR_DATA = lwdata;

    assign PERF_ADDR = laddr;
    assign PERF_WR_EN = lperf_wren;
    assign PERF_RD_EN = lperf_rden;
    assign PERF_WR_DATA = lwdata;


endmodule
