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
* This is generated from ch0_addr_decoder.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.

***************************************************************************/
module chan_addr_decoder (clk,rst_n,iMM_ADDR,iMM_WR_EN,iMM_RD_EN,iMM_WR_DATA,oMM_RD_DATA,oMM_RD_DATA_V,SERDES_ADDR,SERDES_WR_DATA,SERDES_WR_EN,SERDES_RD_EN,SERDES_RD_DATA,SERDES_RD_DATA_V,ETH_MAC_ADDR,ETH_MAC_WR_DATA,ETH_MAC_WR_EN,ETH_MAC_RD_EN,ETH_MAC_RD_DATA,ETH_MAC_RD_DATA_V,FCE_ADDR,FCE_WR_DATA,FCE_WR_EN,FCE_RD_EN,FCE_RD_DATA,FCE_RD_DATA_V,EXTR_ADDR,EXTR_WR_DATA,EXTR_WR_EN,EXTR_RD_EN,EXTR_RD_DATA,EXTR_RD_DATA_V,UCSTATS_ADDR,UCSTATS_WR_DATA,UCSTATS_WR_EN,UCSTATS_RD_EN,UCSTATS_RD_DATA,UCSTATS_RD_DATA_V);
input clk;
input rst_n;
input [13:0] iMM_ADDR;
input iMM_WR_EN;
input iMM_RD_EN;
input [63:0] iMM_WR_DATA;
output [63:0] oMM_RD_DATA;
output oMM_RD_DATA_V;
output [13:0] SERDES_ADDR;
output [63:0] SERDES_WR_DATA;
output SERDES_WR_EN;
output SERDES_RD_EN;
input [63:0] SERDES_RD_DATA;
input SERDES_RD_DATA_V;
output [13:0] ETH_MAC_ADDR;
output [63:0] ETH_MAC_WR_DATA;
output ETH_MAC_WR_EN;
output ETH_MAC_RD_EN;
input [63:0] ETH_MAC_RD_DATA;
input ETH_MAC_RD_DATA_V;
output [13:0] FCE_ADDR;
output [63:0] FCE_WR_DATA;
output FCE_WR_EN;
output FCE_RD_EN;
input [63:0] FCE_RD_DATA;
input FCE_RD_DATA_V;
output [13:0] EXTR_ADDR;
output [63:0] EXTR_WR_DATA;
output EXTR_WR_EN;
output EXTR_RD_EN;
input [63:0] EXTR_RD_DATA;
input EXTR_RD_DATA_V;
output [13:0] UCSTATS_ADDR;
output [63:0] UCSTATS_WR_DATA;
output UCSTATS_WR_EN;
output UCSTATS_RD_EN;
input [63:0] UCSTATS_RD_DATA;
input UCSTATS_RD_DATA_V;

reg [63:0] rd_data;
reg rd_data_v;
reg [63:0] ldata;
reg ldata_v;
reg ldata_vd;
reg [13:0] laddr;
reg lwen;
reg lren;
reg [63:0] lwdata;
reg lserdes_wren;
reg lserdes_rden;
reg leth_mac_wren;
reg leth_mac_rden;
reg lfce_wren;
reg lfce_rden;
reg lextr_wren;
reg lextr_rden;
reg lucstats_wren;
reg lucstats_rden;

always @*
  begin
    lucstats_wren = 0;
    lucstats_rden = 0;
    lextr_wren = 0;
    lextr_rden = 0;
    lfce_wren = 0;
    lfce_rden = 0;
    leth_mac_wren = 0;
    leth_mac_rden = 0;
    lserdes_wren = 0;
    lserdes_rden = 0;
    
casez (laddr) // synopsys parallel_case
    14'b0000zzzzzzzzzz :
    begin  // serdes
    lserdes_wren = lwen;
    lserdes_rden = lren;
    ldata_v = SERDES_RD_DATA_V;
    ldata = SERDES_RD_DATA;
    end
    14'b0001zzzzzzzzzz :
    begin  // eth_mac
    leth_mac_wren = lwen;
    leth_mac_rden = lren;
    ldata_v = ETH_MAC_RD_DATA_V;
    ldata = ETH_MAC_RD_DATA;
    end
    14'b0010zzzzzzzzzz :
    begin  // fce
    lfce_wren = lwen;
    lfce_rden = lren;
    ldata_v = FCE_RD_DATA_V;
    ldata = FCE_RD_DATA;
    end
    14'b0011zzzzzzzzzz :
    begin  // extr
    lextr_wren = lwen;
    lextr_rden = lren;
    ldata_v = EXTR_RD_DATA_V;
    ldata = EXTR_RD_DATA;
    end
    14'b0100zzzzzzzzzz :
    begin  // ucstats
    lucstats_wren = lwen;
    lucstats_rden = lren;
    ldata_v = UCSTATS_RD_DATA_V;
    ldata = UCSTATS_RD_DATA;
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

    assign SERDES_ADDR = laddr;
    assign SERDES_WR_EN = lserdes_wren;
    assign SERDES_RD_EN = lserdes_rden;
    assign SERDES_WR_DATA = lwdata;

    assign ETH_MAC_ADDR = laddr;
    assign ETH_MAC_WR_EN = leth_mac_wren;
    assign ETH_MAC_RD_EN = leth_mac_rden;
    assign ETH_MAC_WR_DATA = lwdata;

    assign FCE_ADDR = laddr;
    assign FCE_WR_EN = lfce_wren;
    assign FCE_RD_EN = lfce_rden;
    assign FCE_WR_DATA = lwdata;

    assign EXTR_ADDR = laddr;
    assign EXTR_WR_EN = lextr_wren;
    assign EXTR_RD_EN = lextr_rden;
    assign EXTR_WR_DATA = lwdata;

    assign UCSTATS_ADDR = laddr;
    assign UCSTATS_WR_EN = lucstats_wren;
    assign UCSTATS_RD_EN = lucstats_rden;
    assign UCSTATS_WR_DATA = lwdata;


endmodule
