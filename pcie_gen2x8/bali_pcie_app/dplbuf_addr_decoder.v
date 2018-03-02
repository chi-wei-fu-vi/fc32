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
* This is generated from dplbuf_addr_decoder.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.

***************************************************************************/
module dplbuf_addr_decoder (clk,rst_n,iMM_ADDR,iMM_WR_EN,iMM_RD_EN,iMM_WR_DATA,oMM_RD_DATA,oMM_RD_DATA_V,LINK0_ADDR,LINK0_WR_DATA,LINK0_WR_EN,LINK0_RD_EN,LINK0_RD_DATA,LINK0_RD_DATA_V,LINK1_ADDR,LINK1_WR_DATA,LINK1_WR_EN,LINK1_RD_EN,LINK1_RD_DATA,LINK1_RD_DATA_V,LINK2_ADDR,LINK2_WR_DATA,LINK2_WR_EN,LINK2_RD_EN,LINK2_RD_DATA,LINK2_RD_DATA_V,LINK3_ADDR,LINK3_WR_DATA,LINK3_WR_EN,LINK3_RD_EN,LINK3_RD_DATA,LINK3_RD_DATA_V,LINK4_ADDR,LINK4_WR_DATA,LINK4_WR_EN,LINK4_RD_EN,LINK4_RD_DATA,LINK4_RD_DATA_V,LINK5_ADDR,LINK5_WR_DATA,LINK5_WR_EN,LINK5_RD_EN,LINK5_RD_DATA,LINK5_RD_DATA_V,LINK6_ADDR,LINK6_WR_DATA,LINK6_WR_EN,LINK6_RD_EN,LINK6_RD_DATA,LINK6_RD_DATA_V,LINK7_ADDR,LINK7_WR_DATA,LINK7_WR_EN,LINK7_RD_EN,LINK7_RD_DATA,LINK7_RD_DATA_V,LINK8_ADDR,LINK8_WR_DATA,LINK8_WR_EN,LINK8_RD_EN,LINK8_RD_DATA,LINK8_RD_DATA_V,LINK9_ADDR,LINK9_WR_DATA,LINK9_WR_EN,LINK9_RD_EN,LINK9_RD_DATA,LINK9_RD_DATA_V,LINK10_ADDR,LINK10_WR_DATA,LINK10_WR_EN,LINK10_RD_EN,LINK10_RD_DATA,LINK10_RD_DATA_V,LINK11_ADDR,LINK11_WR_DATA,LINK11_WR_EN,LINK11_RD_EN,LINK11_RD_DATA,LINK11_RD_DATA_V);
input clk;
input rst_n;
input [13:0] iMM_ADDR;
input iMM_WR_EN;
input iMM_RD_EN;
input [63:0] iMM_WR_DATA;
output [63:0] oMM_RD_DATA;
output oMM_RD_DATA_V;
output [13:0] LINK0_ADDR;
output [63:0] LINK0_WR_DATA;
output LINK0_WR_EN;
output LINK0_RD_EN;
input [63:0] LINK0_RD_DATA;
input LINK0_RD_DATA_V;
output [13:0] LINK1_ADDR;
output [63:0] LINK1_WR_DATA;
output LINK1_WR_EN;
output LINK1_RD_EN;
input [63:0] LINK1_RD_DATA;
input LINK1_RD_DATA_V;
output [13:0] LINK2_ADDR;
output [63:0] LINK2_WR_DATA;
output LINK2_WR_EN;
output LINK2_RD_EN;
input [63:0] LINK2_RD_DATA;
input LINK2_RD_DATA_V;
output [13:0] LINK3_ADDR;
output [63:0] LINK3_WR_DATA;
output LINK3_WR_EN;
output LINK3_RD_EN;
input [63:0] LINK3_RD_DATA;
input LINK3_RD_DATA_V;
output [13:0] LINK4_ADDR;
output [63:0] LINK4_WR_DATA;
output LINK4_WR_EN;
output LINK4_RD_EN;
input [63:0] LINK4_RD_DATA;
input LINK4_RD_DATA_V;
output [13:0] LINK5_ADDR;
output [63:0] LINK5_WR_DATA;
output LINK5_WR_EN;
output LINK5_RD_EN;
input [63:0] LINK5_RD_DATA;
input LINK5_RD_DATA_V;
output [13:0] LINK6_ADDR;
output [63:0] LINK6_WR_DATA;
output LINK6_WR_EN;
output LINK6_RD_EN;
input [63:0] LINK6_RD_DATA;
input LINK6_RD_DATA_V;
output [13:0] LINK7_ADDR;
output [63:0] LINK7_WR_DATA;
output LINK7_WR_EN;
output LINK7_RD_EN;
input [63:0] LINK7_RD_DATA;
input LINK7_RD_DATA_V;
output [13:0] LINK8_ADDR;
output [63:0] LINK8_WR_DATA;
output LINK8_WR_EN;
output LINK8_RD_EN;
input [63:0] LINK8_RD_DATA;
input LINK8_RD_DATA_V;
output [13:0] LINK9_ADDR;
output [63:0] LINK9_WR_DATA;
output LINK9_WR_EN;
output LINK9_RD_EN;
input [63:0] LINK9_RD_DATA;
input LINK9_RD_DATA_V;
output [13:0] LINK10_ADDR;
output [63:0] LINK10_WR_DATA;
output LINK10_WR_EN;
output LINK10_RD_EN;
input [63:0] LINK10_RD_DATA;
input LINK10_RD_DATA_V;
output [13:0] LINK11_ADDR;
output [63:0] LINK11_WR_DATA;
output LINK11_WR_EN;
output LINK11_RD_EN;
input [63:0] LINK11_RD_DATA;
input LINK11_RD_DATA_V;

reg [63:0] rd_data;
reg rd_data_v;
reg [63:0] ldata;
reg ldata_v;
reg ldata_vd;
reg [13:0] laddr;
reg lwen;
reg lren;
reg [63:0] lwdata;
reg llink0_wren;
reg llink0_rden;
reg llink1_wren;
reg llink1_rden;
reg llink2_wren;
reg llink2_rden;
reg llink3_wren;
reg llink3_rden;
reg llink4_wren;
reg llink4_rden;
reg llink5_wren;
reg llink5_rden;
reg llink6_wren;
reg llink6_rden;
reg llink7_wren;
reg llink7_rden;
reg llink8_wren;
reg llink8_rden;
reg llink9_wren;
reg llink9_rden;
reg llink10_wren;
reg llink10_rden;
reg llink11_wren;
reg llink11_rden;

always @*
  begin
    llink11_wren = 0;
    llink11_rden = 0;
    llink10_wren = 0;
    llink10_rden = 0;
    llink9_wren = 0;
    llink9_rden = 0;
    llink8_wren = 0;
    llink8_rden = 0;
    llink7_wren = 0;
    llink7_rden = 0;
    llink6_wren = 0;
    llink6_rden = 0;
    llink5_wren = 0;
    llink5_rden = 0;
    llink4_wren = 0;
    llink4_rden = 0;
    llink3_wren = 0;
    llink3_rden = 0;
    llink2_wren = 0;
    llink2_rden = 0;
    llink1_wren = 0;
    llink1_rden = 0;
    llink0_wren = 0;
    llink0_rden = 0;
    
casez (laddr) // synopsys parallel_case
    14'b0000zzzzzzzzzz :
    begin  // link0
    llink0_wren = lwen;
    llink0_rden = lren;
    ldata_v = LINK0_RD_DATA_V;
    ldata = LINK0_RD_DATA;
    end
    14'b0001zzzzzzzzzz :
    begin  // link1
    llink1_wren = lwen;
    llink1_rden = lren;
    ldata_v = LINK1_RD_DATA_V;
    ldata = LINK1_RD_DATA;
    end
    14'b0010zzzzzzzzzz :
    begin  // link2
    llink2_wren = lwen;
    llink2_rden = lren;
    ldata_v = LINK2_RD_DATA_V;
    ldata = LINK2_RD_DATA;
    end
    14'b0011zzzzzzzzzz :
    begin  // link3
    llink3_wren = lwen;
    llink3_rden = lren;
    ldata_v = LINK3_RD_DATA_V;
    ldata = LINK3_RD_DATA;
    end
    14'b0100zzzzzzzzzz :
    begin  // link4
    llink4_wren = lwen;
    llink4_rden = lren;
    ldata_v = LINK4_RD_DATA_V;
    ldata = LINK4_RD_DATA;
    end
    14'b0101zzzzzzzzzz :
    begin  // link5
    llink5_wren = lwen;
    llink5_rden = lren;
    ldata_v = LINK5_RD_DATA_V;
    ldata = LINK5_RD_DATA;
    end
    14'b0110zzzzzzzzzz :
    begin  // link6
    llink6_wren = lwen;
    llink6_rden = lren;
    ldata_v = LINK6_RD_DATA_V;
    ldata = LINK6_RD_DATA;
    end
    14'b0111zzzzzzzzzz :
    begin  // link7
    llink7_wren = lwen;
    llink7_rden = lren;
    ldata_v = LINK7_RD_DATA_V;
    ldata = LINK7_RD_DATA;
    end
    14'b1000zzzzzzzzzz :
    begin  // link8
    llink8_wren = lwen;
    llink8_rden = lren;
    ldata_v = LINK8_RD_DATA_V;
    ldata = LINK8_RD_DATA;
    end
    14'b1001zzzzzzzzzz :
    begin  // link9
    llink9_wren = lwen;
    llink9_rden = lren;
    ldata_v = LINK9_RD_DATA_V;
    ldata = LINK9_RD_DATA;
    end
    14'b1010zzzzzzzzzz :
    begin  // link10
    llink10_wren = lwen;
    llink10_rden = lren;
    ldata_v = LINK10_RD_DATA_V;
    ldata = LINK10_RD_DATA;
    end
    14'b1011zzzzzzzzzz :
    begin  // link11
    llink11_wren = lwen;
    llink11_rden = lren;
    ldata_v = LINK11_RD_DATA_V;
    ldata = LINK11_RD_DATA;
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

    assign LINK0_ADDR = laddr;
    assign LINK0_WR_EN = llink0_wren;
    assign LINK0_RD_EN = llink0_rden;
    assign LINK0_WR_DATA = lwdata;

    assign LINK1_ADDR = laddr;
    assign LINK1_WR_EN = llink1_wren;
    assign LINK1_RD_EN = llink1_rden;
    assign LINK1_WR_DATA = lwdata;

    assign LINK2_ADDR = laddr;
    assign LINK2_WR_EN = llink2_wren;
    assign LINK2_RD_EN = llink2_rden;
    assign LINK2_WR_DATA = lwdata;

    assign LINK3_ADDR = laddr;
    assign LINK3_WR_EN = llink3_wren;
    assign LINK3_RD_EN = llink3_rden;
    assign LINK3_WR_DATA = lwdata;

    assign LINK4_ADDR = laddr;
    assign LINK4_WR_EN = llink4_wren;
    assign LINK4_RD_EN = llink4_rden;
    assign LINK4_WR_DATA = lwdata;

    assign LINK5_ADDR = laddr;
    assign LINK5_WR_EN = llink5_wren;
    assign LINK5_RD_EN = llink5_rden;
    assign LINK5_WR_DATA = lwdata;

    assign LINK6_ADDR = laddr;
    assign LINK6_WR_EN = llink6_wren;
    assign LINK6_RD_EN = llink6_rden;
    assign LINK6_WR_DATA = lwdata;

    assign LINK7_ADDR = laddr;
    assign LINK7_WR_EN = llink7_wren;
    assign LINK7_RD_EN = llink7_rden;
    assign LINK7_WR_DATA = lwdata;

    assign LINK8_ADDR = laddr;
    assign LINK8_WR_EN = llink8_wren;
    assign LINK8_RD_EN = llink8_rden;
    assign LINK8_WR_DATA = lwdata;

    assign LINK9_ADDR = laddr;
    assign LINK9_WR_EN = llink9_wren;
    assign LINK9_RD_EN = llink9_rden;
    assign LINK9_WR_DATA = lwdata;

    assign LINK10_ADDR = laddr;
    assign LINK10_WR_EN = llink10_wren;
    assign LINK10_RD_EN = llink10_rden;
    assign LINK10_WR_DATA = lwdata;

    assign LINK11_ADDR = laddr;
    assign LINK11_WR_EN = llink11_wren;
    assign LINK11_RD_EN = llink11_rden;
    assign LINK11_WR_DATA = lwdata;


endmodule
