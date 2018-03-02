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
module top_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [20:0]          GLOBAL_ADDR,
  output logic [63:0]          GLOBAL_WR_DATA,
  output logic                 GLOBAL_WR_EN,
  output logic                 GLOBAL_RD_EN,
  output logic [20:0]          PCIE_ADDR,
  output logic [63:0]          PCIE_WR_DATA,
  output logic                 PCIE_WR_EN,
  output logic                 PCIE_RD_EN,
  output logic [20:0]          BIST_ADDR,
  output logic [63:0]          BIST_WR_DATA,
  output logic                 BIST_WR_EN,
  output logic                 BIST_RD_EN,
  output logic [20:0]          LINK0_ADDR,
  output logic [63:0]          LINK0_WR_DATA,
  output logic                 LINK0_WR_EN,
  output logic                 LINK0_RD_EN,
  output logic [20:0]          LINK1_ADDR,
  output logic [63:0]          LINK1_WR_DATA,
  output logic                 LINK1_WR_EN,
  output logic                 LINK1_RD_EN,
  output logic [20:0]          LINK2_ADDR,
  output logic [63:0]          LINK2_WR_DATA,
  output logic                 LINK2_WR_EN,
  output logic                 LINK2_RD_EN,
  output logic [20:0]          LINK3_ADDR,
  output logic [63:0]          LINK3_WR_DATA,
  output logic                 LINK3_WR_EN,
  output logic                 LINK3_RD_EN,
  output logic [20:0]          LINK4_ADDR,
  output logic [63:0]          LINK4_WR_DATA,
  output logic                 LINK4_WR_EN,
  output logic                 LINK4_RD_EN,
  output logic [20:0]          LINK5_ADDR,
  output logic [63:0]          LINK5_WR_DATA,
  output logic                 LINK5_WR_EN,
  output logic                 LINK5_RD_EN,
  output logic [20:0]          LINK6_ADDR,
  output logic [63:0]          LINK6_WR_DATA,
  output logic                 LINK6_WR_EN,
  output logic                 LINK6_RD_EN,
  output logic [20:0]          LINK7_ADDR,
  output logic [63:0]          LINK7_WR_DATA,
  output logic                 LINK7_WR_EN,
  output logic                 LINK7_RD_EN,
  output logic [20:0]          LINK8_ADDR,
  output logic [63:0]          LINK8_WR_DATA,
  output logic                 LINK8_WR_EN,
  output logic                 LINK8_RD_EN,
  output logic [20:0]          LINK9_ADDR,
  output logic [63:0]          LINK9_WR_DATA,
  output logic                 LINK9_WR_EN,
  output logic                 LINK9_RD_EN,
  output logic [20:0]          LINK10_ADDR,
  output logic [63:0]          LINK10_WR_DATA,
  output logic                 LINK10_WR_EN,
  output logic                 LINK10_RD_EN,
  output logic [20:0]          LINK11_ADDR,
  output logic [63:0]          LINK11_WR_DATA,
  output logic                 LINK11_WR_EN,
  output logic                 LINK11_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [20:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          GLOBAL_RD_DATA,
  input                        GLOBAL_RD_DATA_V,
  input        [63:0]          PCIE_RD_DATA,
  input                        PCIE_RD_DATA_V,
  input                        PCIE_clk,
  input                        PCIE_rst_n,
  input        [63:0]          BIST_RD_DATA,
  input                        BIST_RD_DATA_V,
  input        [63:0]          LINK0_RD_DATA,
  input                        LINK0_RD_DATA_V,
  input        [63:0]          LINK1_RD_DATA,
  input                        LINK1_RD_DATA_V,
  input        [63:0]          LINK2_RD_DATA,
  input                        LINK2_RD_DATA_V,
  input        [63:0]          LINK3_RD_DATA,
  input                        LINK3_RD_DATA_V,
  input        [63:0]          LINK4_RD_DATA,
  input                        LINK4_RD_DATA_V,
  input        [63:0]          LINK5_RD_DATA,
  input                        LINK5_RD_DATA_V,
  input        [63:0]          LINK6_RD_DATA,
  input                        LINK6_RD_DATA_V,
  input        [63:0]          LINK7_RD_DATA,
  input                        LINK7_RD_DATA_V,
  input        [63:0]          LINK8_RD_DATA,
  input                        LINK8_RD_DATA_V,
  input        [63:0]          LINK9_RD_DATA,
  input                        LINK9_RD_DATA_V,
  input        [63:0]          LINK10_RD_DATA,
  input                        LINK10_RD_DATA_V,
  input        [63:0]          LINK11_RD_DATA,
  input                        LINK11_RD_DATA_V
);

  wire   [63:0]                lpcie_rd_data;
  wire                         lpcie_rd_data_v;
  logic  [63:0]                rd_data;
  logic                        rd_data_v;
  logic  [20:0]                laddr;
  logic  [63:0]                ldata;
  logic                        ldata_v;
  logic                        ldata_vd;
  logic                        lwen;
  logic                        lren;
  logic  [63:0]                lwdata;
  logic                        lglobal_wren;
  logic                        lglobal_rden;
  logic                        lpcie_wren;
  logic                        lpcie_rden;
  logic                        lbist_wren;
  logic                        lbist_rden;
  logic                        llink0_wren;
  logic                        llink0_rden;
  logic                        llink1_wren;
  logic                        llink1_rden;
  logic                        llink2_wren;
  logic                        llink2_rden;
  logic                        llink3_wren;
  logic                        llink3_rden;
  logic                        llink4_wren;
  logic                        llink4_rden;
  logic                        llink5_wren;
  logic                        llink5_rden;
  logic                        llink6_wren;
  logic                        llink6_rden;
  logic                        llink7_wren;
  logic                        llink7_rden;
  logic                        llink8_wren;
  logic                        llink8_rden;
  logic                        llink9_wren;
  logic                        llink9_rden;
  logic                        llink10_wren;
  logic                        llink10_rden;
  logic                        llink11_wren;
  logic                        llink11_rden;
  always_comb begin
    lglobal_wren              = 0;
    lglobal_rden              = 0;
    lpcie_wren                = 0;
    lpcie_rden                = 0;
    lbist_wren                = 0;
    lbist_rden                = 0;
    llink0_wren               = 0;
    llink0_rden               = 0;
    llink1_wren               = 0;
    llink1_rden               = 0;
    llink2_wren               = 0;
    llink2_rden               = 0;
    llink3_wren               = 0;
    llink3_rden               = 0;
    llink4_wren               = 0;
    llink4_rden               = 0;
    llink5_wren               = 0;
    llink5_rden               = 0;
    llink6_wren               = 0;
    llink6_rden               = 0;
    llink7_wren               = 0;
    llink7_rden               = 0;
    llink8_wren               = 0;
    llink8_rden               = 0;
    llink9_wren               = 0;
    llink9_rden               = 0;
    llink10_wren              = 0;
    llink10_rden              = 0;
    llink11_wren              = 0;
    llink11_rden              = 0;
    unique casez(laddr)
      21'b0000zzzzzzzzzzzzzzzzz: begin  // global
        lglobal_wren              = lwen;
        lglobal_rden              = lren;
        ldata                    = GLOBAL_RD_DATA;
        ldata_v                  = GLOBAL_RD_DATA_V;
      end
      21'b0001zzzzzzzzzzzzzzzzz: begin  // pcie
        lpcie_wren                = lwen;
        lpcie_rden                = lren;
        ldata                    = lpcie_rd_data;
        ldata_v                  = lpcie_rd_data_v;
      end
      21'b0011zzzzzzzzzzzzzzzzz: begin  // bist
        lbist_wren                = lwen;
        lbist_rden                = lren;
        ldata                    = BIST_RD_DATA;
        ldata_v                  = BIST_RD_DATA_V;
      end
      21'b0100zzzzzzzzzzzzzzzzz: begin  // link0
        llink0_wren               = lwen;
        llink0_rden               = lren;
        ldata                    = LINK0_RD_DATA;
        ldata_v                  = LINK0_RD_DATA_V;
      end
      21'b0101zzzzzzzzzzzzzzzzz: begin  // link1
        llink1_wren               = lwen;
        llink1_rden               = lren;
        ldata                    = LINK1_RD_DATA;
        ldata_v                  = LINK1_RD_DATA_V;
      end
      21'b0110zzzzzzzzzzzzzzzzz: begin  // link2
        llink2_wren               = lwen;
        llink2_rden               = lren;
        ldata                    = LINK2_RD_DATA;
        ldata_v                  = LINK2_RD_DATA_V;
      end
      21'b0111zzzzzzzzzzzzzzzzz: begin  // link3
        llink3_wren               = lwen;
        llink3_rden               = lren;
        ldata                    = LINK3_RD_DATA;
        ldata_v                  = LINK3_RD_DATA_V;
      end
      21'b1000zzzzzzzzzzzzzzzzz: begin  // link4
        llink4_wren               = lwen;
        llink4_rden               = lren;
        ldata                    = LINK4_RD_DATA;
        ldata_v                  = LINK4_RD_DATA_V;
      end
      21'b1001zzzzzzzzzzzzzzzzz: begin  // link5
        llink5_wren               = lwen;
        llink5_rden               = lren;
        ldata                    = LINK5_RD_DATA;
        ldata_v                  = LINK5_RD_DATA_V;
      end
      21'b1010zzzzzzzzzzzzzzzzz: begin  // link6
        llink6_wren               = lwen;
        llink6_rden               = lren;
        ldata                    = LINK6_RD_DATA;
        ldata_v                  = LINK6_RD_DATA_V;
      end
      21'b1011zzzzzzzzzzzzzzzzz: begin  // link7
        llink7_wren               = lwen;
        llink7_rden               = lren;
        ldata                    = LINK7_RD_DATA;
        ldata_v                  = LINK7_RD_DATA_V;
      end
      21'b1100zzzzzzzzzzzzzzzzz: begin  // link8
        llink8_wren               = lwen;
        llink8_rden               = lren;
        ldata                    = LINK8_RD_DATA;
        ldata_v                  = LINK8_RD_DATA_V;
      end
      21'b1101zzzzzzzzzzzzzzzzz: begin  // link9
        llink9_wren               = lwen;
        llink9_rden               = lren;
        ldata                    = LINK9_RD_DATA;
        ldata_v                  = LINK9_RD_DATA_V;
      end
      21'b1110zzzzzzzzzzzzzzzzz: begin  // link10
        llink10_wren              = lwen;
        llink10_rden              = lren;
        ldata                    = LINK10_RD_DATA;
        ldata_v                  = LINK10_RD_DATA_V;
      end
      21'b1111zzzzzzzzzzzzzzzzz: begin  // link11
        llink11_wren              = lwen;
        llink11_rden              = lren;
        ldata                    = LINK11_RD_DATA;
        ldata_v                  = LINK11_RD_DATA_V;
      end

      default: begin
        ldata                    = {32'h5555_AAAA,11'b0,laddr};
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

  assign GLOBAL_ADDR               = laddr;
  assign GLOBAL_WR_EN              = lglobal_wren;
  assign GLOBAL_RD_EN              = lglobal_rden;
  assign GLOBAL_WR_DATA            = lwdata;

  ///////////////////////////////////////////
  //
  // Pulse Sync for PCIE
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_PCIE (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lpcie_wren                                         ), // input
    . iRDEN_A                                            ( lpcie_rden                                         ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lpcie_rd_data_v                                    ), // output
    . oRD_DATA_A                                         ( lpcie_rd_data                                      ), // output [63:0]
    . iRST_N_B                                           ( PCIE_rst_n                                         ), // input
    . iCLK_B                                             ( PCIE_clk                                           ), // input
    . iRD_DATA_B                                         ( PCIE_RD_DATA                                       ), // input [63:0]
    . iACK_B                                             ( PCIE_RD_DATA_V                                     ), // input
    . oWREN_B                                            ( PCIE_WR_EN                                         ), // output
    . oRDEN_B                                            ( PCIE_RD_EN                                         ), // output
    . oWR_DATA_B                                         ( PCIE_WR_DATA                                       ), // output [63:0]
    . oADDR_B                                            ( PCIE_ADDR                                          )  // output [20:0]
  );

  assign BIST_ADDR                 = laddr;
  assign BIST_WR_EN                = lbist_wren;
  assign BIST_RD_EN                = lbist_rden;
  assign BIST_WR_DATA              = lwdata;
  assign LINK0_ADDR                = laddr;
  assign LINK0_WR_EN               = llink0_wren;
  assign LINK0_RD_EN               = llink0_rden;
  assign LINK0_WR_DATA             = lwdata;
  assign LINK1_ADDR                = laddr;
  assign LINK1_WR_EN               = llink1_wren;
  assign LINK1_RD_EN               = llink1_rden;
  assign LINK1_WR_DATA             = lwdata;
  assign LINK2_ADDR                = laddr;
  assign LINK2_WR_EN               = llink2_wren;
  assign LINK2_RD_EN               = llink2_rden;
  assign LINK2_WR_DATA             = lwdata;
  assign LINK3_ADDR                = laddr;
  assign LINK3_WR_EN               = llink3_wren;
  assign LINK3_RD_EN               = llink3_rden;
  assign LINK3_WR_DATA             = lwdata;
  assign LINK4_ADDR                = laddr;
  assign LINK4_WR_EN               = llink4_wren;
  assign LINK4_RD_EN               = llink4_rden;
  assign LINK4_WR_DATA             = lwdata;
  assign LINK5_ADDR                = laddr;
  assign LINK5_WR_EN               = llink5_wren;
  assign LINK5_RD_EN               = llink5_rden;
  assign LINK5_WR_DATA             = lwdata;
  assign LINK6_ADDR                = laddr;
  assign LINK6_WR_EN               = llink6_wren;
  assign LINK6_RD_EN               = llink6_rden;
  assign LINK6_WR_DATA             = lwdata;
  assign LINK7_ADDR                = laddr;
  assign LINK7_WR_EN               = llink7_wren;
  assign LINK7_RD_EN               = llink7_rden;
  assign LINK7_WR_DATA             = lwdata;
  assign LINK8_ADDR                = laddr;
  assign LINK8_WR_EN               = llink8_wren;
  assign LINK8_RD_EN               = llink8_rden;
  assign LINK8_WR_DATA             = lwdata;
  assign LINK9_ADDR                = laddr;
  assign LINK9_WR_EN               = llink9_wren;
  assign LINK9_RD_EN               = llink9_rden;
  assign LINK9_WR_DATA             = lwdata;
  assign LINK10_ADDR               = laddr;
  assign LINK10_WR_EN              = llink10_wren;
  assign LINK10_RD_EN              = llink10_rden;
  assign LINK10_WR_DATA            = lwdata;
  assign LINK11_ADDR               = laddr;
  assign LINK11_WR_EN              = llink11_wren;
  assign LINK11_RD_EN              = llink11_rden;
  assign LINK11_WR_DATA            = lwdata;

endmodule