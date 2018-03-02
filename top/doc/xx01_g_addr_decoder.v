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
module xx01_g_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [13:0]          FPGA_ADDR,
  output logic [63:0]          FPGA_WR_DATA,
  output logic                 FPGA_WR_EN,
  output logic                 FPGA_RD_EN,
  output logic [13:0]          CLKRST_ADDR,
  output logic [63:0]          CLKRST_WR_DATA,
  output logic                 CLKRST_WR_EN,
  output logic                 CLKRST_RD_EN,
  output logic [13:0]          UCSTATS_ADDR,
  output logic [63:0]          UCSTATS_WR_DATA,
  output logic                 UCSTATS_WR_EN,
  output logic                 UCSTATS_RD_EN,
  output logic [13:0]          XBAR_ADDR,
  output logic [63:0]          XBAR_WR_DATA,
  output logic                 XBAR_WR_EN,
  output logic                 XBAR_RD_EN,
  output logic [13:0]          CROSS_CH0_ADDR,
  output logic [63:0]          CROSS_CH0_WR_DATA,
  output logic                 CROSS_CH0_WR_EN,
  output logic                 CROSS_CH0_RD_EN,
  output logic [13:0]          CROSS_CH1_ADDR,
  output logic [63:0]          CROSS_CH1_WR_DATA,
  output logic                 CROSS_CH1_WR_EN,
  output logic                 CROSS_CH1_RD_EN,
  output logic [13:0]          RCFG_ADDR,
  output logic [63:0]          RCFG_WR_DATA,
  output logic                 RCFG_WR_EN,
  output logic                 RCFG_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [13:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          FPGA_RD_DATA,
  input                        FPGA_RD_DATA_V,
  input                        FPGA_clk,
  input                        FPGA_rst_n,
  input        [63:0]          CLKRST_RD_DATA,
  input                        CLKRST_RD_DATA_V,
  input                        CLKRST_clk,
  input                        CLKRST_rst_n,
  input        [63:0]          UCSTATS_RD_DATA,
  input                        UCSTATS_RD_DATA_V,
  input        [63:0]          XBAR_RD_DATA,
  input                        XBAR_RD_DATA_V,
  input                        XBAR_clk,
  input                        XBAR_rst_n,
  input        [63:0]          CROSS_CH0_RD_DATA,
  input                        CROSS_CH0_RD_DATA_V,
  input        [63:0]          CROSS_CH1_RD_DATA,
  input                        CROSS_CH1_RD_DATA_V,
  input        [63:0]          RCFG_RD_DATA,
  input                        RCFG_RD_DATA_V,
  input                        RCFG_clk,
  input                        RCFG_rst_n
);

  wire   [63:0]                lfpga_rd_data;
  wire                         lfpga_rd_data_v;
  wire   [63:0]                lclkrst_rd_data;
  wire                         lclkrst_rd_data_v;
  wire   [63:0]                lxbar_rd_data;
  wire                         lxbar_rd_data_v;
  wire   [63:0]                lrcfg_rd_data;
  wire                         lrcfg_rd_data_v;
  logic  [63:0]                rd_data;
  logic                        rd_data_v;
  logic  [13:0]                laddr;
  logic  [63:0]                ldata;
  logic                        ldata_v;
  logic                        ldata_vd;
  logic                        lwen;
  logic                        lren;
  logic  [63:0]                lwdata;
  logic                        lfpga_wren;
  logic                        lfpga_rden;
  logic                        lclkrst_wren;
  logic                        lclkrst_rden;
  logic                        lucstats_wren;
  logic                        lucstats_rden;
  logic                        lxbar_wren;
  logic                        lxbar_rden;
  logic                        lcross_ch0_wren;
  logic                        lcross_ch0_rden;
  logic                        lcross_ch1_wren;
  logic                        lcross_ch1_rden;
  logic                        lrcfg_wren;
  logic                        lrcfg_rden;
  always_comb begin
    lfpga_wren                = 0;
    lfpga_rden                = 0;
    lclkrst_wren              = 0;
    lclkrst_rden              = 0;
    lucstats_wren             = 0;
    lucstats_rden             = 0;
    lxbar_wren                = 0;
    lxbar_rden                = 0;
    lcross_ch0_wren           = 0;
    lcross_ch0_rden           = 0;
    lcross_ch1_wren           = 0;
    lcross_ch1_rden           = 0;
    lrcfg_wren                = 0;
    lrcfg_rden                = 0;
    unique casez(laddr)
      14'b0000zzzzzzzzzz: begin  // fpga
        lfpga_wren                = lwen;
        lfpga_rden                = lren;
        ldata                    = lfpga_rd_data;
        ldata_v                  = lfpga_rd_data_v;
      end
      14'b0001zzzzzzzzzz: begin  // clkrst
        lclkrst_wren              = lwen;
        lclkrst_rden              = lren;
        ldata                    = lclkrst_rd_data;
        ldata_v                  = lclkrst_rd_data_v;
      end
      14'b0010zzzzzzzzzz: begin  // ucstats
        lucstats_wren             = lwen;
        lucstats_rden             = lren;
        ldata                    = UCSTATS_RD_DATA;
        ldata_v                  = UCSTATS_RD_DATA_V;
      end
      14'b0011zzzzzzzzzz: begin  // xbar
        lxbar_wren                = lwen;
        lxbar_rden                = lren;
        ldata                    = lxbar_rd_data;
        ldata_v                  = lxbar_rd_data_v;
      end
      14'b0100zzzzzzzzzz: begin  // cross_ch0
        lcross_ch0_wren           = lwen;
        lcross_ch0_rden           = lren;
        ldata                    = CROSS_CH0_RD_DATA;
        ldata_v                  = CROSS_CH0_RD_DATA_V;
      end
      14'b0101zzzzzzzzzz: begin  // cross_ch1
        lcross_ch1_wren           = lwen;
        lcross_ch1_rden           = lren;
        ldata                    = CROSS_CH1_RD_DATA;
        ldata_v                  = CROSS_CH1_RD_DATA_V;
      end
      14'b0110zzzzzzzzzz: begin  // rcfg
        lrcfg_wren                = lwen;
        lrcfg_rden                = lren;
        ldata                    = lrcfg_rd_data;
        ldata_v                  = lrcfg_rd_data_v;
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


  ///////////////////////////////////////////
  //
  // Pulse Sync for FPGA
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_FPGA (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lfpga_wren                                         ), // input
    . iRDEN_A                                            ( lfpga_rden                                         ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lfpga_rd_data_v                                    ), // output
    . oRD_DATA_A                                         ( lfpga_rd_data                                      ), // output [63:0]
    . iRST_N_B                                           ( FPGA_rst_n                                         ), // input
    . iCLK_B                                             ( FPGA_clk                                           ), // input
    . iRD_DATA_B                                         ( FPGA_RD_DATA                                       ), // input [63:0]
    . iACK_B                                             ( FPGA_RD_DATA_V                                     ), // input
    . oWREN_B                                            ( FPGA_WR_EN                                         ), // output
    . oRDEN_B                                            ( FPGA_RD_EN                                         ), // output
    . oWR_DATA_B                                         ( FPGA_WR_DATA                                       ), // output [63:0]
    . oADDR_B                                            ( FPGA_ADDR                                          )  // output [20:0]
  );


  ///////////////////////////////////////////
  //
  // Pulse Sync for CLKRST
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_CLKRST (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lclkrst_wren                                       ), // input
    . iRDEN_A                                            ( lclkrst_rden                                       ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lclkrst_rd_data_v                                  ), // output
    . oRD_DATA_A                                         ( lclkrst_rd_data                                    ), // output [63:0]
    . iRST_N_B                                           ( CLKRST_rst_n                                       ), // input
    . iCLK_B                                             ( CLKRST_clk                                         ), // input
    . iRD_DATA_B                                         ( CLKRST_RD_DATA                                     ), // input [63:0]
    . iACK_B                                             ( CLKRST_RD_DATA_V                                   ), // input
    . oWREN_B                                            ( CLKRST_WR_EN                                       ), // output
    . oRDEN_B                                            ( CLKRST_RD_EN                                       ), // output
    . oWR_DATA_B                                         ( CLKRST_WR_DATA                                     ), // output [63:0]
    . oADDR_B                                            ( CLKRST_ADDR                                        )  // output [20:0]
  );

  assign UCSTATS_ADDR              = laddr;
  assign UCSTATS_WR_EN             = lucstats_wren;
  assign UCSTATS_RD_EN             = lucstats_rden;
  assign UCSTATS_WR_DATA           = lwdata;

  ///////////////////////////////////////////
  //
  // Pulse Sync for XBAR
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_XBAR (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lxbar_wren                                         ), // input
    . iRDEN_A                                            ( lxbar_rden                                         ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lxbar_rd_data_v                                    ), // output
    . oRD_DATA_A                                         ( lxbar_rd_data                                      ), // output [63:0]
    . iRST_N_B                                           ( XBAR_rst_n                                         ), // input
    . iCLK_B                                             ( XBAR_clk                                           ), // input
    . iRD_DATA_B                                         ( XBAR_RD_DATA                                       ), // input [63:0]
    . iACK_B                                             ( XBAR_RD_DATA_V                                     ), // input
    . oWREN_B                                            ( XBAR_WR_EN                                         ), // output
    . oRDEN_B                                            ( XBAR_RD_EN                                         ), // output
    . oWR_DATA_B                                         ( XBAR_WR_DATA                                       ), // output [63:0]
    . oADDR_B                                            ( XBAR_ADDR                                          )  // output [20:0]
  );

  assign CROSS_CH0_ADDR            = laddr;
  assign CROSS_CH0_WR_EN           = lcross_ch0_wren;
  assign CROSS_CH0_RD_EN           = lcross_ch0_rden;
  assign CROSS_CH0_WR_DATA         = lwdata;
  assign CROSS_CH1_ADDR            = laddr;
  assign CROSS_CH1_WR_EN           = lcross_ch1_wren;
  assign CROSS_CH1_RD_EN           = lcross_ch1_rden;
  assign CROSS_CH1_WR_DATA         = lwdata;

  ///////////////////////////////////////////
  //
  // Pulse Sync for RCFG
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_RCFG (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lrcfg_wren                                         ), // input
    . iRDEN_A                                            ( lrcfg_rden                                         ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lrcfg_rd_data_v                                    ), // output
    . oRD_DATA_A                                         ( lrcfg_rd_data                                      ), // output [63:0]
    . iRST_N_B                                           ( RCFG_rst_n                                         ), // input
    . iCLK_B                                             ( RCFG_clk                                           ), // input
    . iRD_DATA_B                                         ( RCFG_RD_DATA                                       ), // input [63:0]
    . iACK_B                                             ( RCFG_RD_DATA_V                                     ), // input
    . oWREN_B                                            ( RCFG_WR_EN                                         ), // output
    . oRDEN_B                                            ( RCFG_RD_EN                                         ), // output
    . oWR_DATA_B                                         ( RCFG_WR_DATA                                       ), // output [63:0]
    . oADDR_B                                            ( RCFG_ADDR                                          )  // output [20:0]
  );


endmodule