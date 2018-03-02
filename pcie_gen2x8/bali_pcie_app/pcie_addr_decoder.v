/********************************CONFIDENTIAL****************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
* This module decodes address and mux/demux read/write data among configuration registers.
* This is generated from pcie_addr_decoder.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.

***************************************************************************/
module pcie_addr_decoder (clk,rst_n,iMM_ADDR,iMM_WR_EN,iMM_RD_EN,iMM_WR_DATA,oMM_RD_DATA,oMM_RD_DATA_V,XX02_G_ADDR,XX02_G_WR_DATA,XX02_G_WR_EN,XX02_G_RD_EN,XX02_G_RD_DATA,XX02_G_RD_DATA_V,DPLBUF_ADDR,DPLBUF_WR_DATA,DPLBUF_WR_EN,DPLBUF_RD_EN,DPLBUF_RD_DATA,DPLBUF_RD_DATA_V);
input clk;
input rst_n;
input [16:0] iMM_ADDR;
input iMM_WR_EN;
input iMM_RD_EN;
input [63:0] iMM_WR_DATA;
output [63:0] oMM_RD_DATA;
output oMM_RD_DATA_V;
output [16:0] XX02_G_ADDR;
output [63:0] XX02_G_WR_DATA;
output XX02_G_WR_EN;
output XX02_G_RD_EN;
input [63:0] XX02_G_RD_DATA;
input XX02_G_RD_DATA_V;
output [16:0] DPLBUF_ADDR;
output [63:0] DPLBUF_WR_DATA;
output DPLBUF_WR_EN;
output DPLBUF_RD_EN;
input [63:0] DPLBUF_RD_DATA;
input DPLBUF_RD_DATA_V;

reg [63:0] rd_data;
reg rd_data_v;
reg [63:0] ldata;
reg ldata_v;
reg ldata_vd;
reg [16:0] laddr;
reg lwen;
reg lren;
reg [63:0] lwdata;
reg lxx02_g_wren;
reg lxx02_g_rden;
reg ldplbuf_wren;
reg ldplbuf_rden;

always @*
  begin
    ldplbuf_wren = 0;
    ldplbuf_rden = 0;
    lxx02_g_wren = 0;
    lxx02_g_rden = 0;
    
casez (laddr) // synopsys parallel_case
    17'b000zzzzzzzzzzzzzz :
    begin  // xx02_g
    lxx02_g_wren = lwen;
    lxx02_g_rden = lren;
    ldata_v = XX02_G_RD_DATA_V;
    ldata = XX02_G_RD_DATA;
    end
    17'b001zzzzzzzzzzzzzz :
    begin  // dplbuf
    ldplbuf_wren = lwen;
    ldplbuf_rden = lren;
    ldata_v = DPLBUF_RD_DATA_V;
    ldata = DPLBUF_RD_DATA;
    end
    default :
    begin
      ldata = {32'h5555_AAAA,{15{1'b0}},laddr};
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

    assign XX02_G_ADDR = laddr;
    assign XX02_G_WR_EN = lxx02_g_wren;
    assign XX02_G_RD_EN = lxx02_g_rden;
    assign XX02_G_WR_DATA = lwdata;

    assign DPLBUF_ADDR = laddr;
    assign DPLBUF_WR_EN = ldplbuf_wren;
    assign DPLBUF_RD_EN = ldplbuf_rden;
    assign DPLBUF_WR_DATA = lwdata;


endmodule
