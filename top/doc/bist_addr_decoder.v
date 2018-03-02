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
module bist_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [16:0]          XX03_PCIE_ADDR,
  output logic [63:0]          XX03_PCIE_WR_DATA,
  output logic                 XX03_PCIE_WR_EN,
  output logic                 XX03_PCIE_RD_EN,
  output logic [16:0]          TX_CH0_ADDR,
  output logic [63:0]          TX_CH0_WR_DATA,
  output logic                 TX_CH0_WR_EN,
  output logic                 TX_CH0_RD_EN,
  output logic [16:0]          TX_CH1_ADDR,
  output logic [63:0]          TX_CH1_WR_DATA,
  output logic                 TX_CH1_WR_EN,
  output logic                 TX_CH1_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [16:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          XX03_PCIE_RD_DATA,
  input                        XX03_PCIE_RD_DATA_V,
  input                        XX03_PCIE_clk,
  input                        XX03_PCIE_rst_n,
  input        [63:0]          TX_CH0_RD_DATA,
  input                        TX_CH0_RD_DATA_V,
  input                        TX_CH0_clk,
  input                        TX_CH0_rst_n,
  input        [63:0]          TX_CH1_RD_DATA,
  input                        TX_CH1_RD_DATA_V,
  input                        TX_CH1_clk,
  input                        TX_CH1_rst_n
);

  wire   [63:0]                lxx03_pcie_rd_data;
  wire                         lxx03_pcie_rd_data_v;
  wire   [63:0]                ltx_ch0_rd_data;
  wire                         ltx_ch0_rd_data_v;
  wire   [63:0]                ltx_ch1_rd_data;
  wire                         ltx_ch1_rd_data_v;
  logic  [63:0]                rd_data;
  logic                        rd_data_v;
  logic  [16:0]                laddr;
  logic  [63:0]                ldata;
  logic                        ldata_v;
  logic                        ldata_vd;
  logic                        lwen;
  logic                        lren;
  logic  [63:0]                lwdata;
  logic                        lxx03_pcie_wren;
  logic                        lxx03_pcie_rden;
  logic                        ltx_ch0_wren;
  logic                        ltx_ch0_rden;
  logic                        ltx_ch1_wren;
  logic                        ltx_ch1_rden;
  always_comb begin
    lxx03_pcie_wren           = 0;
    lxx03_pcie_rden           = 0;
    ltx_ch0_wren              = 0;
    ltx_ch0_rden              = 0;
    ltx_ch1_wren              = 0;
    ltx_ch1_rden              = 0;
    unique casez(laddr)
      17'b001zzzzzzzzzzzzzz: begin  // xx03_pcie
        lxx03_pcie_wren           = lwen;
        lxx03_pcie_rden           = lren;
        ldata                    = lxx03_pcie_rd_data;
        ldata_v                  = lxx03_pcie_rd_data_v;
      end
      17'b010zzzzzzzzzzzzzz: begin  // tx_ch0
        ltx_ch0_wren              = lwen;
        ltx_ch0_rden              = lren;
        ldata                    = ltx_ch0_rd_data;
        ldata_v                  = ltx_ch0_rd_data_v;
      end
      17'b011zzzzzzzzzzzzzz: begin  // tx_ch1
        ltx_ch1_wren              = lwen;
        ltx_ch1_rden              = lren;
        ldata                    = ltx_ch1_rd_data;
        ldata_v                  = ltx_ch1_rd_data_v;
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


  ///////////////////////////////////////////
  //
  // Pulse Sync for XX03_PCIE
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_XX03_PCIE (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lxx03_pcie_wren                                    ), // input
    . iRDEN_A                                            ( lxx03_pcie_rden                                    ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lxx03_pcie_rd_data_v                               ), // output
    . oRD_DATA_A                                         ( lxx03_pcie_rd_data                                 ), // output [63:0]
    . iRST_N_B                                           ( XX03_PCIE_rst_n                                    ), // input
    . iCLK_B                                             ( XX03_PCIE_clk                                      ), // input
    . iRD_DATA_B                                         ( XX03_PCIE_RD_DATA                                  ), // input [63:0]
    . iACK_B                                             ( XX03_PCIE_RD_DATA_V                                ), // input
    . oWREN_B                                            ( XX03_PCIE_WR_EN                                    ), // output
    . oRDEN_B                                            ( XX03_PCIE_RD_EN                                    ), // output
    . oWR_DATA_B                                         ( XX03_PCIE_WR_DATA                                  ), // output [63:0]
    . oADDR_B                                            ( XX03_PCIE_ADDR                                     )  // output [20:0]
  );


  ///////////////////////////////////////////
  //
  // Pulse Sync for TX_CH0
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_TX_CH0 (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( ltx_ch0_wren                                       ), // input
    . iRDEN_A                                            ( ltx_ch0_rden                                       ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( ltx_ch0_rd_data_v                                  ), // output
    . oRD_DATA_A                                         ( ltx_ch0_rd_data                                    ), // output [63:0]
    . iRST_N_B                                           ( TX_CH0_rst_n                                       ), // input
    . iCLK_B                                             ( TX_CH0_clk                                         ), // input
    . iRD_DATA_B                                         ( TX_CH0_RD_DATA                                     ), // input [63:0]
    . iACK_B                                             ( TX_CH0_RD_DATA_V                                   ), // input
    . oWREN_B                                            ( TX_CH0_WR_EN                                       ), // output
    . oRDEN_B                                            ( TX_CH0_RD_EN                                       ), // output
    . oWR_DATA_B                                         ( TX_CH0_WR_DATA                                     ), // output [63:0]
    . oADDR_B                                            ( TX_CH0_ADDR                                        )  // output [20:0]
  );


  ///////////////////////////////////////////
  //
  // Pulse Sync for TX_CH1
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_TX_CH1 (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( ltx_ch1_wren                                       ), // input
    . iRDEN_A                                            ( ltx_ch1_rden                                       ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( ltx_ch1_rd_data_v                                  ), // output
    . oRD_DATA_A                                         ( ltx_ch1_rd_data                                    ), // output [63:0]
    . iRST_N_B                                           ( TX_CH1_rst_n                                       ), // input
    . iCLK_B                                             ( TX_CH1_clk                                         ), // input
    . iRD_DATA_B                                         ( TX_CH1_RD_DATA                                     ), // input [63:0]
    . iACK_B                                             ( TX_CH1_RD_DATA_V                                   ), // input
    . oWREN_B                                            ( TX_CH1_WR_EN                                       ), // output
    . oRDEN_B                                            ( TX_CH1_RD_EN                                       ), // output
    . oWR_DATA_B                                         ( TX_CH1_WR_DATA                                     ), // output [63:0]
    . oADDR_B                                            ( TX_CH1_ADDR                                        )  // output [20:0]
  );


endmodule