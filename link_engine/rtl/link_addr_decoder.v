/********************************CONFIDENTIAL****************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: jaedon.kim $
* $Date: 2013-08-13 16:39:37 -0700 (Tue, 13 Aug 2013) $
* $Revision: 3177 $
* Description:
* This module decodes address and mux/demux read/write data among configuration registers.
* This is generated from link0_addr_decoder.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.

***************************************************************************/
module link_addr_decoder (clk,rst_n,iMM_ADDR,iMM_WR_EN,iMM_RD_EN,iMM_WR_DATA,oMM_RD_DATA,oMM_RD_DATA_V,XX04_G_ADDR,XX04_G_WR_DATA,XX04_G_WR_EN,XX04_G_RD_EN,XX04_G_RD_DATA,XX04_G_RD_DATA_V,CH0_ADDR,CH0_WR_DATA,CH0_WR_EN,CH0_RD_EN,CH0_RD_DATA,CH0_RD_DATA_V,CH1_ADDR,CH1_WR_DATA,CH1_WR_EN,CH1_RD_EN,CH1_RD_DATA,CH1_RD_DATA_V);
input clk;
input rst_n;
input [16:0] iMM_ADDR;
input iMM_WR_EN;
input iMM_RD_EN;
input [63:0] iMM_WR_DATA;
output [63:0] oMM_RD_DATA;
output oMM_RD_DATA_V;
output [16:0] XX04_G_ADDR;
output [63:0] XX04_G_WR_DATA;
output XX04_G_WR_EN;
output XX04_G_RD_EN;
input [63:0] XX04_G_RD_DATA;
input XX04_G_RD_DATA_V;
output [16:0] CH0_ADDR;
output [63:0] CH0_WR_DATA;
output CH0_WR_EN;
output CH0_RD_EN;
input [63:0] CH0_RD_DATA;
input CH0_RD_DATA_V;
output [16:0] CH1_ADDR;
output [63:0] CH1_WR_DATA;
output CH1_WR_EN;
output CH1_RD_EN;
input [63:0] CH1_RD_DATA;
input CH1_RD_DATA_V;

reg [63:0] rd_data;
reg rd_data_v;
reg [63:0] ldata;
reg ldata_v;
reg ldata_vd;
reg [16:0] laddr;
reg lwen;
reg lren;
reg [63:0] lwdata;
reg lxx04_g_wren;
reg lxx04_g_rden;
reg lch0_wren;
reg lch0_rden;
reg lch1_wren;
reg lch1_rden;

always @*
  begin
    lch1_wren = 0;
    lch1_rden = 0;
    lch0_wren = 0;
    lch0_rden = 0;
    lxx04_g_wren = 0;
    lxx04_g_rden = 0;
    
casez (laddr) // synopsys parallel_case
    17'b000zzzzzzzzzzzzzz :
    begin  // xx04_g
    lxx04_g_wren = lwen;
    lxx04_g_rden = lren;
    ldata_v = XX04_G_RD_DATA_V;
    ldata = XX04_G_RD_DATA;
    end
    17'b001zzzzzzzzzzzzzz :
    begin  // ch0
    lch0_wren = lwen;
    lch0_rden = lren;
    ldata_v = CH0_RD_DATA_V;
    ldata = CH0_RD_DATA;
    end
    17'b010zzzzzzzzzzzzzz :
    begin  // ch1
    lch1_wren = lwen;
    lch1_rden = lren;
    ldata_v = CH1_RD_DATA_V;
    ldata = CH1_RD_DATA;
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

    assign XX04_G_ADDR = laddr;
    assign XX04_G_WR_EN = lxx04_g_wren;
    assign XX04_G_RD_EN = lxx04_g_rden;
    assign XX04_G_WR_DATA = lwdata;

    assign CH0_ADDR = laddr;
    assign CH0_WR_EN = lch0_wren;
    assign CH0_RD_EN = lch0_rden;
    assign CH0_WR_DATA = lwdata;

    assign CH1_ADDR = laddr;
    assign CH1_WR_EN = lch1_wren;
    assign CH1_RD_EN = lch1_rden;
    assign CH1_WR_DATA = lwdata;


endmodule
