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
module ch0_addr_decoder (
  output logic [63:0]          oMM_RD_DATA,
  output logic                 oMM_RD_DATA_V,
  output logic [13:0]          SERDES_ADDR,
  output logic [63:0]          SERDES_WR_DATA,
  output logic                 SERDES_WR_EN,
  output logic                 SERDES_RD_EN,
  output logic [13:0]          FC1_LAYER_KR_ADDR,
  output logic [63:0]          FC1_LAYER_KR_WR_DATA,
  output logic                 FC1_LAYER_KR_WR_EN,
  output logic                 FC1_LAYER_KR_RD_EN,
  output logic [13:0]          FMAC_ADDR,
  output logic [63:0]          FMAC_WR_DATA,
  output logic                 FMAC_WR_EN,
  output logic                 FMAC_RD_EN,
  output logic [13:0]          EXTR_ADDR,
  output logic [63:0]          EXTR_WR_DATA,
  output logic                 EXTR_WR_EN,
  output logic                 EXTR_RD_EN,
  output logic [13:0]          UCSTATS_ADDR,
  output logic [63:0]          UCSTATS_WR_DATA,
  output logic                 UCSTATS_WR_EN,
  output logic                 UCSTATS_RD_EN,
  output logic [13:0]          MTIP_ADDR,
  output logic [63:0]          MTIP_WR_DATA,
  output logic                 MTIP_WR_EN,
  output logic                 MTIP_RD_EN,
  output logic [13:0]          MTIP_FC1_ADDR,
  output logic [63:0]          MTIP_FC1_WR_DATA,
  output logic                 MTIP_FC1_WR_EN,
  output logic                 MTIP_FC1_RD_EN,
  output logic [13:0]          MTIP_FC2_ADDR,
  output logic [63:0]          MTIP_FC2_WR_DATA,
  output logic                 MTIP_FC2_WR_EN,
  output logic                 MTIP_FC2_RD_EN,
  input                        clk,
  input                        rst_n,
  input                        iMM_WR_EN,
  input                        iMM_RD_EN,
  input        [13:0]          iMM_ADDR,
  input        [63:0]          iMM_WR_DATA,
  input        [63:0]          SERDES_RD_DATA,
  input                        SERDES_RD_DATA_V,
  input                        SERDES_clk,
  input                        SERDES_rst_n,
  input        [63:0]          FC1_LAYER_KR_RD_DATA,
  input                        FC1_LAYER_KR_RD_DATA_V,
  input        [63:0]          FMAC_RD_DATA,
  input                        FMAC_RD_DATA_V,
  input        [63:0]          EXTR_RD_DATA,
  input                        EXTR_RD_DATA_V,
  input        [63:0]          UCSTATS_RD_DATA,
  input                        UCSTATS_RD_DATA_V,
  input        [63:0]          MTIP_RD_DATA,
  input                        MTIP_RD_DATA_V,
  input                        MTIP_clk,
  input                        MTIP_rst_n,
  input        [63:0]          MTIP_FC1_RD_DATA,
  input                        MTIP_FC1_RD_DATA_V,
  input                        MTIP_FC1_clk,
  input                        MTIP_FC1_rst_n,
  input        [63:0]          MTIP_FC2_RD_DATA,
  input                        MTIP_FC2_RD_DATA_V
);

  wire   [63:0]                lserdes_rd_data;
  wire                         lserdes_rd_data_v;
  wire   [63:0]                lmtip_rd_data;
  wire                         lmtip_rd_data_v;
  wire   [63:0]                lmtip_fc1_rd_data;
  wire                         lmtip_fc1_rd_data_v;
  logic  [63:0]                rd_data;
  logic                        rd_data_v;
  logic  [13:0]                laddr;
  logic  [63:0]                ldata;
  logic                        ldata_v;
  logic                        ldata_vd;
  logic                        lwen;
  logic                        lren;
  logic  [63:0]                lwdata;
  logic                        lserdes_wren;
  logic                        lserdes_rden;
  logic                        lfc1_layer_kr_wren;
  logic                        lfc1_layer_kr_rden;
  logic                        lfmac_wren;
  logic                        lfmac_rden;
  logic                        lextr_wren;
  logic                        lextr_rden;
  logic                        lucstats_wren;
  logic                        lucstats_rden;
  logic                        lmtip_wren;
  logic                        lmtip_rden;
  logic                        lmtip_fc1_wren;
  logic                        lmtip_fc1_rden;
  logic                        lmtip_fc2_wren;
  logic                        lmtip_fc2_rden;
  always_comb begin
    lserdes_wren              = 0;
    lserdes_rden              = 0;
    lfc1_layer_kr_wren        = 0;
    lfc1_layer_kr_rden        = 0;
    lfmac_wren                = 0;
    lfmac_rden                = 0;
    lextr_wren                = 0;
    lextr_rden                = 0;
    lucstats_wren             = 0;
    lucstats_rden             = 0;
    lmtip_wren                = 0;
    lmtip_rden                = 0;
    lmtip_fc1_wren            = 0;
    lmtip_fc1_rden            = 0;
    lmtip_fc2_wren            = 0;
    lmtip_fc2_rden            = 0;
    unique casez(laddr)
      14'b0000zzzzzzzzzz: begin  // serdes
        lserdes_wren              = lwen;
        lserdes_rden              = lren;
        ldata                    = lserdes_rd_data;
        ldata_v                  = lserdes_rd_data_v;
      end
      14'b0001zzzzzzzzzz: begin  // fc1_layer_kr
        lfc1_layer_kr_wren        = lwen;
        lfc1_layer_kr_rden        = lren;
        ldata                    = FC1_LAYER_KR_RD_DATA;
        ldata_v                  = FC1_LAYER_KR_RD_DATA_V;
      end
      14'b0010zzzzzzzzzz: begin  // fmac
        lfmac_wren                = lwen;
        lfmac_rden                = lren;
        ldata                    = FMAC_RD_DATA;
        ldata_v                  = FMAC_RD_DATA_V;
      end
      14'b0011zzzzzzzzzz: begin  // extr
        lextr_wren                = lwen;
        lextr_rden                = lren;
        ldata                    = EXTR_RD_DATA;
        ldata_v                  = EXTR_RD_DATA_V;
      end
      14'b0100zzzzzzzzzz: begin  // ucstats
        lucstats_wren             = lwen;
        lucstats_rden             = lren;
        ldata                    = UCSTATS_RD_DATA;
        ldata_v                  = UCSTATS_RD_DATA_V;
      end
      14'b0101zzzzzzzzzz: begin  // mtip
        lmtip_wren                = lwen;
        lmtip_rden                = lren;
        ldata                    = lmtip_rd_data;
        ldata_v                  = lmtip_rd_data_v;
      end
      14'b0110zzzzzzzzzz: begin  // mtip_fc1
        lmtip_fc1_wren            = lwen;
        lmtip_fc1_rden            = lren;
        ldata                    = lmtip_fc1_rd_data;
        ldata_v                  = lmtip_fc1_rd_data_v;
      end
      14'b0111zzzzzzzzzz: begin  // mtip_fc2
        lmtip_fc2_wren            = lwen;
        lmtip_fc2_rden            = lren;
        ldata                    = MTIP_FC2_RD_DATA;
        ldata_v                  = MTIP_FC2_RD_DATA_V;
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
  // Pulse Sync for SERDES
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_SERDES (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lserdes_wren                                       ), // input
    . iRDEN_A                                            ( lserdes_rden                                       ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lserdes_rd_data_v                                  ), // output
    . oRD_DATA_A                                         ( lserdes_rd_data                                    ), // output [63:0]
    . iRST_N_B                                           ( SERDES_rst_n                                       ), // input
    . iCLK_B                                             ( SERDES_clk                                         ), // input
    . iRD_DATA_B                                         ( SERDES_RD_DATA                                     ), // input [63:0]
    . iACK_B                                             ( SERDES_RD_DATA_V                                   ), // input
    . oWREN_B                                            ( SERDES_WR_EN                                       ), // output
    . oRDEN_B                                            ( SERDES_RD_EN                                       ), // output
    . oWR_DATA_B                                         ( SERDES_WR_DATA                                     ), // output [63:0]
    . oADDR_B                                            ( SERDES_ADDR                                        )  // output [20:0]
  );

  assign FC1_LAYER_KR_ADDR         = laddr;
  assign FC1_LAYER_KR_WR_EN        = lfc1_layer_kr_wren;
  assign FC1_LAYER_KR_RD_EN        = lfc1_layer_kr_rden;
  assign FC1_LAYER_KR_WR_DATA      = lwdata;
  assign FMAC_ADDR                 = laddr;
  assign FMAC_WR_EN                = lfmac_wren;
  assign FMAC_RD_EN                = lfmac_rden;
  assign FMAC_WR_DATA              = lwdata;
  assign EXTR_ADDR                 = laddr;
  assign EXTR_WR_EN                = lextr_wren;
  assign EXTR_RD_EN                = lextr_rden;
  assign EXTR_WR_DATA              = lwdata;
  assign UCSTATS_ADDR              = laddr;
  assign UCSTATS_WR_EN             = lucstats_wren;
  assign UCSTATS_RD_EN             = lucstats_rden;
  assign UCSTATS_WR_DATA           = lwdata;

  ///////////////////////////////////////////
  //
  // Pulse Sync for MTIP
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_MTIP (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lmtip_wren                                         ), // input
    . iRDEN_A                                            ( lmtip_rden                                         ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lmtip_rd_data_v                                    ), // output
    . oRD_DATA_A                                         ( lmtip_rd_data                                      ), // output [63:0]
    . iRST_N_B                                           ( MTIP_rst_n                                         ), // input
    . iCLK_B                                             ( MTIP_clk                                           ), // input
    . iRD_DATA_B                                         ( MTIP_RD_DATA                                       ), // input [63:0]
    . iACK_B                                             ( MTIP_RD_DATA_V                                     ), // input
    . oWREN_B                                            ( MTIP_WR_EN                                         ), // output
    . oRDEN_B                                            ( MTIP_RD_EN                                         ), // output
    . oWR_DATA_B                                         ( MTIP_WR_DATA                                       ), // output [63:0]
    . oADDR_B                                            ( MTIP_ADDR                                          )  // output [20:0]
  );


  ///////////////////////////////////////////
  //
  // Pulse Sync for MTIP_FC1
  //
  ///////////////////////////////////////////
  vi_sync_csr sync_MTIP_FC1 (
    . iRST_N_A                                           ( rst_n                                              ), // input
    . iCLK_A                                             ( clk                                                ), // input
    . iWREN_A                                            ( lmtip_fc1_wren                                     ), // input
    . iRDEN_A                                            ( lmtip_fc1_rden                                     ), // input
    . iADDR_A                                            ( laddr                                              ), // input [20:0]
    . iWR_DATA_A                                         ( lwdata                                             ), // input [63:0]
    . oACK_A                                             ( lmtip_fc1_rd_data_v                                ), // output
    . oRD_DATA_A                                         ( lmtip_fc1_rd_data                                  ), // output [63:0]
    . iRST_N_B                                           ( MTIP_FC1_rst_n                                     ), // input
    . iCLK_B                                             ( MTIP_FC1_clk                                       ), // input
    . iRD_DATA_B                                         ( MTIP_FC1_RD_DATA                                   ), // input [63:0]
    . iACK_B                                             ( MTIP_FC1_RD_DATA_V                                 ), // input
    . oWREN_B                                            ( MTIP_FC1_WR_EN                                     ), // output
    . oRDEN_B                                            ( MTIP_FC1_RD_EN                                     ), // output
    . oWR_DATA_B                                         ( MTIP_FC1_WR_DATA                                   ), // output [63:0]
    . oADDR_B                                            ( MTIP_FC1_ADDR                                      )  // output [20:0]
  );

  assign MTIP_FC2_ADDR             = laddr;
  assign MTIP_FC2_WR_EN            = lmtip_fc2_wren;
  assign MTIP_FC2_RD_EN            = lmtip_fc2_rden;
  assign MTIP_FC2_WR_DATA          = lwdata;

endmodule