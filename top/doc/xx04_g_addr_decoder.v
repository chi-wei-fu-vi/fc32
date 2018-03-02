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
module xx04_g_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [13:0]          CSR_ADDR,
  output logic [63:0]          CSR_WR_DATA,
  output logic                 CSR_WR_EN,
  output logic                 CSR_RD_EN,
  output logic [13:0]          CREDIT_STATS0_ADDR,
  output logic [63:0]          CREDIT_STATS0_WR_DATA,
  output logic                 CREDIT_STATS0_WR_EN,
  output logic                 CREDIT_STATS0_RD_EN,
  output logic [13:0]          CREDIT_STATS1_ADDR,
  output logic [63:0]          CREDIT_STATS1_WR_DATA,
  output logic                 CREDIT_STATS1_WR_EN,
  output logic                 CREDIT_STATS1_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [13:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          CSR_RD_DATA,
  input                        CSR_RD_DATA_V,
  input        [63:0]          CREDIT_STATS0_RD_DATA,
  input                        CREDIT_STATS0_RD_DATA_V,
  input                        CREDIT_STATS0_clk,
  input                        CREDIT_STATS0_rst_n,
  input        [63:0]          CREDIT_STATS1_RD_DATA,
  input                        CREDIT_STATS1_RD_DATA_V,
  input                        CREDIT_STATS1_clk,
  input                        CREDIT_STATS1_rst_n
);

  wire   [63:0]                lcredit_stats0_rd_data;
  wire                         lcredit_stats0_rd_data_v;
  wire   [63:0]                lcredit_stats1_rd_data;
  wire                         lcredit_stats1_rd_data_v;
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
  logic                        lcredit_stats0_wren;
  logic                        lcredit_stats0_rden;
  logic                        lcredit_stats1_wren;
  logic                        lcredit_stats1_rden;
  always_comb begin
    lcsr_wren                 = 0;
    lcsr_rden                 = 0;
    lcredit_stats0_wren       = 0;
    lcredit_stats0_rden       = 0;
    lcredit_stats1_wren       = 0;
    lcredit_stats1_rden       = 0;
    unique casez(laddr)
      14'b0000zzzzzzzzzz: begin  // csr
        lcsr_wren                 = lwen;
        lcsr_rden                 = lren;
        ldata                    = CSR_RD_DATA;
        ldata_v                  = CSR_RD_DATA_V;
      end
      14'b0001zzzzzzzzzz: begin  // credit_stats0
        lcredit_stats0_wren       = lwen;
        lcredit_stats0_rden       = lren;
        ldata                    = lcredit_stats0_rd_data;
        ldata_v                  = lcredit_stats0_rd_data_v;
      end
      14'b0010zzzzzzzzzz: begin  // credit_stats1
        lcredit_stats1_wren       = lwen;
        lcredit_stats1_rden       = lren;
        ldata                    = lcredit_stats1_rd_data;
        ldata_v                  = lcredit_stats1_rd_data_v;
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

  ///////////////////////////////////////////
  //
  // Pulse Sync for CREDIT_STATS0
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_CREDIT_STATS0 (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lcredit_stats0_wren                                ), // input
    . iRDEN_A                                            ( lcredit_stats0_rden                                ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lcredit_stats0_rd_data_v                           ), // output
    . oRD_DATA_A                                         ( lcredit_stats0_rd_data                             ), // output [63:0]
    . iRST_N_B                                           ( CREDIT_STATS0_rst_n                                ), // input
    . iCLK_B                                             ( CREDIT_STATS0_clk                                  ), // input
    . iRD_DATA_B                                         ( CREDIT_STATS0_RD_DATA                              ), // input [63:0]
    . iACK_B                                             ( CREDIT_STATS0_RD_DATA_V                            ), // input
    . oWREN_B                                            ( CREDIT_STATS0_WR_EN                                ), // output
    . oRDEN_B                                            ( CREDIT_STATS0_RD_EN                                ), // output
    . oWR_DATA_B                                         ( CREDIT_STATS0_WR_DATA                              ), // output [63:0]
    . oADDR_B                                            ( CREDIT_STATS0_ADDR                                 )  // output [20:0]
  );


  ///////////////////////////////////////////
  //
  // Pulse Sync for CREDIT_STATS1
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_CREDIT_STATS1 (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lcredit_stats1_wren                                ), // input
    . iRDEN_A                                            ( lcredit_stats1_rden                                ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lcredit_stats1_rd_data_v                           ), // output
    . oRD_DATA_A                                         ( lcredit_stats1_rd_data                             ), // output [63:0]
    . iRST_N_B                                           ( CREDIT_STATS1_rst_n                                ), // input
    . iCLK_B                                             ( CREDIT_STATS1_clk                                  ), // input
    . iRD_DATA_B                                         ( CREDIT_STATS1_RD_DATA                              ), // input [63:0]
    . iACK_B                                             ( CREDIT_STATS1_RD_DATA_V                            ), // input
    . oWREN_B                                            ( CREDIT_STATS1_WR_EN                                ), // output
    . oRDEN_B                                            ( CREDIT_STATS1_RD_EN                                ), // output
    . oWR_DATA_B                                         ( CREDIT_STATS1_WR_DATA                              ), // output [63:0]
    . oADDR_B                                            ( CREDIT_STATS1_ADDR                                 )  // output [20:0]
  );


endmodule