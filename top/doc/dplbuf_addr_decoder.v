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
module dplbuf_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [13:0]          DATA0_ADDR,
  output logic [63:0]          DATA0_WR_DATA,
  output logic                 DATA0_WR_EN,
  output logic                 DATA0_RD_EN,
  output logic [13:0]          DATA1_ADDR,
  output logic [63:0]          DATA1_WR_DATA,
  output logic                 DATA1_WR_EN,
  output logic                 DATA1_RD_EN,
  output logic [13:0]          DATA2_ADDR,
  output logic [63:0]          DATA2_WR_DATA,
  output logic                 DATA2_WR_EN,
  output logic                 DATA2_RD_EN,
  output logic [13:0]          DATA3_ADDR,
  output logic [63:0]          DATA3_WR_DATA,
  output logic                 DATA3_WR_EN,
  output logic                 DATA3_RD_EN,
  output logic [13:0]          DATA4_ADDR,
  output logic [63:0]          DATA4_WR_DATA,
  output logic                 DATA4_WR_EN,
  output logic                 DATA4_RD_EN,
  output logic [13:0]          DATA5_ADDR,
  output logic [63:0]          DATA5_WR_DATA,
  output logic                 DATA5_WR_EN,
  output logic                 DATA5_RD_EN,
  output logic [13:0]          DATA6_ADDR,
  output logic [63:0]          DATA6_WR_DATA,
  output logic                 DATA6_WR_EN,
  output logic                 DATA6_RD_EN,
  output logic [13:0]          DATA7_ADDR,
  output logic [63:0]          DATA7_WR_DATA,
  output logic                 DATA7_WR_EN,
  output logic                 DATA7_RD_EN,
  output logic [13:0]          DATA8_ADDR,
  output logic [63:0]          DATA8_WR_DATA,
  output logic                 DATA8_WR_EN,
  output logic                 DATA8_RD_EN,
  output logic [13:0]          DATA9_ADDR,
  output logic [63:0]          DATA9_WR_DATA,
  output logic                 DATA9_WR_EN,
  output logic                 DATA9_RD_EN,
  output logic [13:0]          DATA10_ADDR,
  output logic [63:0]          DATA10_WR_DATA,
  output logic                 DATA10_WR_EN,
  output logic                 DATA10_RD_EN,
  output logic [13:0]          DATA11_ADDR,
  output logic [63:0]          DATA11_WR_DATA,
  output logic                 DATA11_WR_EN,
  output logic                 DATA11_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [13:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          DATA0_RD_DATA,
  input                        DATA0_RD_DATA_V,
  input        [63:0]          DATA1_RD_DATA,
  input                        DATA1_RD_DATA_V,
  input        [63:0]          DATA2_RD_DATA,
  input                        DATA2_RD_DATA_V,
  input        [63:0]          DATA3_RD_DATA,
  input                        DATA3_RD_DATA_V,
  input        [63:0]          DATA4_RD_DATA,
  input                        DATA4_RD_DATA_V,
  input        [63:0]          DATA5_RD_DATA,
  input                        DATA5_RD_DATA_V,
  input        [63:0]          DATA6_RD_DATA,
  input                        DATA6_RD_DATA_V,
  input        [63:0]          DATA7_RD_DATA,
  input                        DATA7_RD_DATA_V,
  input        [63:0]          DATA8_RD_DATA,
  input                        DATA8_RD_DATA_V,
  input        [63:0]          DATA9_RD_DATA,
  input                        DATA9_RD_DATA_V,
  input        [63:0]          DATA10_RD_DATA,
  input                        DATA10_RD_DATA_V,
  input        [63:0]          DATA11_RD_DATA,
  input                        DATA11_RD_DATA_V
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
  logic                        ldata0_wren;
  logic                        ldata0_rden;
  logic                        ldata1_wren;
  logic                        ldata1_rden;
  logic                        ldata2_wren;
  logic                        ldata2_rden;
  logic                        ldata3_wren;
  logic                        ldata3_rden;
  logic                        ldata4_wren;
  logic                        ldata4_rden;
  logic                        ldata5_wren;
  logic                        ldata5_rden;
  logic                        ldata6_wren;
  logic                        ldata6_rden;
  logic                        ldata7_wren;
  logic                        ldata7_rden;
  logic                        ldata8_wren;
  logic                        ldata8_rden;
  logic                        ldata9_wren;
  logic                        ldata9_rden;
  logic                        ldata10_wren;
  logic                        ldata10_rden;
  logic                        ldata11_wren;
  logic                        ldata11_rden;
  always_comb begin
    ldata0_wren               = 0;
    ldata0_rden               = 0;
    ldata1_wren               = 0;
    ldata1_rden               = 0;
    ldata2_wren               = 0;
    ldata2_rden               = 0;
    ldata3_wren               = 0;
    ldata3_rden               = 0;
    ldata4_wren               = 0;
    ldata4_rden               = 0;
    ldata5_wren               = 0;
    ldata5_rden               = 0;
    ldata6_wren               = 0;
    ldata6_rden               = 0;
    ldata7_wren               = 0;
    ldata7_rden               = 0;
    ldata8_wren               = 0;
    ldata8_rden               = 0;
    ldata9_wren               = 0;
    ldata9_rden               = 0;
    ldata10_wren              = 0;
    ldata10_rden              = 0;
    ldata11_wren              = 0;
    ldata11_rden              = 0;
    unique casez(laddr)
      14'b0000zzzzzzzzzz: begin  // data0
        ldata0_wren               = lwen;
        ldata0_rden               = lren;
        ldata                    = DATA0_RD_DATA;
        ldata_v                  = DATA0_RD_DATA_V;
      end
      14'b0001zzzzzzzzzz: begin  // data1
        ldata1_wren               = lwen;
        ldata1_rden               = lren;
        ldata                    = DATA1_RD_DATA;
        ldata_v                  = DATA1_RD_DATA_V;
      end
      14'b0010zzzzzzzzzz: begin  // data2
        ldata2_wren               = lwen;
        ldata2_rden               = lren;
        ldata                    = DATA2_RD_DATA;
        ldata_v                  = DATA2_RD_DATA_V;
      end
      14'b0011zzzzzzzzzz: begin  // data3
        ldata3_wren               = lwen;
        ldata3_rden               = lren;
        ldata                    = DATA3_RD_DATA;
        ldata_v                  = DATA3_RD_DATA_V;
      end
      14'b0100zzzzzzzzzz: begin  // data4
        ldata4_wren               = lwen;
        ldata4_rden               = lren;
        ldata                    = DATA4_RD_DATA;
        ldata_v                  = DATA4_RD_DATA_V;
      end
      14'b0101zzzzzzzzzz: begin  // data5
        ldata5_wren               = lwen;
        ldata5_rden               = lren;
        ldata                    = DATA5_RD_DATA;
        ldata_v                  = DATA5_RD_DATA_V;
      end
      14'b0110zzzzzzzzzz: begin  // data6
        ldata6_wren               = lwen;
        ldata6_rden               = lren;
        ldata                    = DATA6_RD_DATA;
        ldata_v                  = DATA6_RD_DATA_V;
      end
      14'b0111zzzzzzzzzz: begin  // data7
        ldata7_wren               = lwen;
        ldata7_rden               = lren;
        ldata                    = DATA7_RD_DATA;
        ldata_v                  = DATA7_RD_DATA_V;
      end
      14'b1000zzzzzzzzzz: begin  // data8
        ldata8_wren               = lwen;
        ldata8_rden               = lren;
        ldata                    = DATA8_RD_DATA;
        ldata_v                  = DATA8_RD_DATA_V;
      end
      14'b1001zzzzzzzzzz: begin  // data9
        ldata9_wren               = lwen;
        ldata9_rden               = lren;
        ldata                    = DATA9_RD_DATA;
        ldata_v                  = DATA9_RD_DATA_V;
      end
      14'b1010zzzzzzzzzz: begin  // data10
        ldata10_wren              = lwen;
        ldata10_rden              = lren;
        ldata                    = DATA10_RD_DATA;
        ldata_v                  = DATA10_RD_DATA_V;
      end
      14'b1011zzzzzzzzzz: begin  // data11
        ldata11_wren              = lwen;
        ldata11_rden              = lren;
        ldata                    = DATA11_RD_DATA;
        ldata_v                  = DATA11_RD_DATA_V;
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

  assign DATA0_ADDR                = laddr;
  assign DATA0_WR_EN               = ldata0_wren;
  assign DATA0_RD_EN               = ldata0_rden;
  assign DATA0_WR_DATA             = lwdata;
  assign DATA1_ADDR                = laddr;
  assign DATA1_WR_EN               = ldata1_wren;
  assign DATA1_RD_EN               = ldata1_rden;
  assign DATA1_WR_DATA             = lwdata;
  assign DATA2_ADDR                = laddr;
  assign DATA2_WR_EN               = ldata2_wren;
  assign DATA2_RD_EN               = ldata2_rden;
  assign DATA2_WR_DATA             = lwdata;
  assign DATA3_ADDR                = laddr;
  assign DATA3_WR_EN               = ldata3_wren;
  assign DATA3_RD_EN               = ldata3_rden;
  assign DATA3_WR_DATA             = lwdata;
  assign DATA4_ADDR                = laddr;
  assign DATA4_WR_EN               = ldata4_wren;
  assign DATA4_RD_EN               = ldata4_rden;
  assign DATA4_WR_DATA             = lwdata;
  assign DATA5_ADDR                = laddr;
  assign DATA5_WR_EN               = ldata5_wren;
  assign DATA5_RD_EN               = ldata5_rden;
  assign DATA5_WR_DATA             = lwdata;
  assign DATA6_ADDR                = laddr;
  assign DATA6_WR_EN               = ldata6_wren;
  assign DATA6_RD_EN               = ldata6_rden;
  assign DATA6_WR_DATA             = lwdata;
  assign DATA7_ADDR                = laddr;
  assign DATA7_WR_EN               = ldata7_wren;
  assign DATA7_RD_EN               = ldata7_rden;
  assign DATA7_WR_DATA             = lwdata;
  assign DATA8_ADDR                = laddr;
  assign DATA8_WR_EN               = ldata8_wren;
  assign DATA8_RD_EN               = ldata8_rden;
  assign DATA8_WR_DATA             = lwdata;
  assign DATA9_ADDR                = laddr;
  assign DATA9_WR_EN               = ldata9_wren;
  assign DATA9_RD_EN               = ldata9_rden;
  assign DATA9_WR_DATA             = lwdata;
  assign DATA10_ADDR               = laddr;
  assign DATA10_WR_EN              = ldata10_wren;
  assign DATA10_RD_EN              = ldata10_rden;
  assign DATA10_WR_DATA            = lwdata;
  assign DATA11_ADDR               = laddr;
  assign DATA11_WR_EN              = ldata11_wren;
  assign DATA11_RD_EN              = ldata11_rden;
  assign DATA11_WR_DATA            = lwdata;

endmodule