/********************************CONFIDENTIAL****************************
* Copyright (c) 2014 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
* This module contains configuration registers and counters.
* This was generated from eth_mac/doc/eth_mac_regs.xml and vgen script. Do not manually modify it
* All manual changes will be overwritten by script whenever new file is generated.

***************************************************************************/
module fc1_layer_csr #(
  parameter LITE=0
) (
  output logic [63:0]          rd_data,
  output logic                 rd_data_v,
  output logic [63:0]          oREG__SCRATCH,
  output logic                 oREG_ENC_CONFIG_CSR_ENC_IN_ENDIAN_SWAP,
  output logic                 oREG_ENC_CONFIG_CSR_ENC_OUT_ENDIAN_SWAP,
  output logic                 oREG_ENC_CONFIG_CSR_PCS_SCRAMB_DIS,
  output logic                 oREG_ENC_CONFIG_CSR_PCS_ENC_FEC_ENA,
  output logic                 oREG_ENC_CONFIG_CSR_PCS_ENC_INV,
  output logic                 oREG_DEC_CONFIG_CSR_DEC_IN_ENDIAN_SWAP,
  output logic                 oREG_DEC_CONFIG_CSR_DEC_OUT_ENDIAN_SWAP,
  output logic                 oREG_DEC_CONFIG_CSR_PCS_FORCE_NO_FEC,
  output logic                 oREG_DEC_CONFIG_CSR_PCS_DESCRAMB_DIS,
  output logic                 oREG_DEC_CONFIG_CSR_PCS_DEC_INV,
  output logic                 oREG_DEC_CONFIG_CSR_DEC_DESCRAM_IN_ENDIAN_SWAP,
  output logic                 oREG_DEC_CONFIG_CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP,
  input                        clk,
  input                        rst_n,
  input                        wr_en,
  input                        rd_en,
  input        [9:0]           addr,
  input        [63:0]          wr_data,
  input                        iREG_ENC_EXCEPTION_CSR_EXPT_ENC_FULL,
  input                        iREG_ENC_EXCEPTION_CSR_EXPT_ENC_EMPT,
  input                        iREG_DEC_EXCEPTION_CSR_EXPT_FEC_LOCK_TO,
  input                        iREG_DEC_EXCEPTION_CSR_STAT_FEC_LOCK,
  input                        iREG_DEC_EXCEPTION_CSR_EXPT_LOSS_BLOCKLOCK,
  input                        iREG_DEC_EXCEPTION_CSR_STAT_BLOCK_LOCK,
  input        [12:0]          iREG_DEC_SLIP_COUNT,
  input                        iREG_DEC_CORR_BIT_COUNT_EN,
  input        [3:0]           iREG_DEC_CORR_BIT_COUNT_INC,
  input                        iREG_DEC_CORR_EVENT_COUNT_EN,
  input                        iREG_DEC_UNCORR_EVENT_COUNT_EN
);


  wire                         _SCRATCH_wr_sel;
  wire                         _SCRATCH_rd_sel;
  wire                         ENC_CONFIG_wr_sel;
  wire                         ENC_CONFIG_rd_sel;
  wire                         ENC_EXCEPTION_rd_sel;
  wire   [1:0]                 ENC_EXCEPTION;
  wire                         DEC_CONFIG_wr_sel;
  wire                         DEC_CONFIG_rd_sel;
  wire                         DEC_EXCEPTION_rd_sel;
  wire   [3:0]                 DEC_EXCEPTION;
  wire                         DEC_SLIP_COUNT_rd_sel;
  wire   [12:0]                DEC_SLIP_COUNT;
  wire                         DEC_CORR_BIT_COUNT_wr_sel;
  wire                         DEC_CORR_BIT_COUNT_rd_sel;
  wire                         DEC_CORR_EVENT_COUNT_wr_sel;
  wire                         DEC_CORR_EVENT_COUNT_rd_sel;
  wire                         DEC_UNCORR_EVENT_COUNT_wr_sel;
  wire                         DEC_UNCORR_EVENT_COUNT_rd_sel;
  logic                        memrd_en_latch;
  logic                        lwr_en;
  logic  [63:0]                lwr_data;
  logic  [63:0]                ldata;
  logic                        memrd_en;
  logic                        memrd_v;
  logic  [63:0]                WREG__SCRATCH;
  logic  [4:0]                 WREG_ENC_CONFIG;
  logic  [6:0]                 WREG_DEC_CONFIG;
  logic  [15:0]                DEC_CORR_BIT_COUNT;
  logic  [15:0]                DEC_CORR_EVENT_COUNT;
  logic  [15:0]                DEC_UNCORR_EVENT_COUNT;

// address decode
  assign _SCRATCH_wr_sel                          = (addr[9:0] == 10'h0     ) & (lwr_en == 1'b1);
  assign _SCRATCH_rd_sel                          = (addr[9:0] == 10'h0     ) & (rd_en == 1'b1);
  assign ENC_CONFIG_rd_sel                        = (addr[9:0] == 10'h10    ) & (rd_en == 1'b1);
  assign ENC_CONFIG_wr_sel                        = (addr[9:0] == 10'h10    ) & (lwr_en == 1'b1);
  assign ENC_EXCEPTION_rd_sel                     = (addr[9:0] == 10'h20    ) & (rd_en == 1'b1);
  assign DEC_CONFIG_rd_sel                        = (addr[9:0] == 10'h90    ) & (rd_en == 1'b1);
  assign DEC_CONFIG_wr_sel                        = (addr[9:0] == 10'h90    ) & (lwr_en == 1'b1);
  assign DEC_EXCEPTION_rd_sel                     = (addr[9:0] == 10'ha0    ) & (rd_en == 1'b1);
  assign DEC_SLIP_COUNT_rd_sel                    = (addr[9:0] == 10'hb0    ) & (rd_en == 1'b1);
  assign DEC_CORR_BIT_COUNT_rd_sel                = (addr[9:0] == 10'hb1    ) & (rd_en == 1'b1);
  assign DEC_CORR_BIT_COUNT_wr_sel                = (addr[9:0] == 10'hb1    ) & (lwr_en == 1'b1) & (lwr_data[0] == 1'b1);
  assign DEC_CORR_EVENT_COUNT_rd_sel              = (addr[9:0] == 10'hb2    ) & (rd_en == 1'b1);
  assign DEC_CORR_EVENT_COUNT_wr_sel              = (addr[9:0] == 10'hb2    ) & (lwr_en == 1'b1) & (lwr_data[0] == 1'b1);
  assign DEC_UNCORR_EVENT_COUNT_rd_sel            = (addr[9:0] == 10'hb3    ) & (rd_en == 1'b1);
  assign DEC_UNCORR_EVENT_COUNT_wr_sel            = (addr[9:0] == 10'hb3    ) & (lwr_en == 1'b1) & (lwr_data[0] == 1'b1);
  assign memrd_v = 1'b0;

  always_comb begin
    case(1'b1)
      _SCRATCH_rd_sel                          : ldata = WREG__SCRATCH;
      ENC_CONFIG_rd_sel                        : ldata = {59'b0,WREG_ENC_CONFIG};
      ENC_EXCEPTION_rd_sel                     : ldata = {62'b0,ENC_EXCEPTION};
      DEC_CONFIG_rd_sel                        : ldata = {57'b0,WREG_DEC_CONFIG};
      DEC_EXCEPTION_rd_sel                     : ldata = {60'b0,DEC_EXCEPTION};
      DEC_SLIP_COUNT_rd_sel                    : ldata = {51'b0,DEC_SLIP_COUNT};
      DEC_CORR_BIT_COUNT_rd_sel                : ldata = {48'b0,DEC_CORR_BIT_COUNT};
      DEC_CORR_EVENT_COUNT_rd_sel              : ldata = {48'b0,DEC_CORR_EVENT_COUNT};
      DEC_UNCORR_EVENT_COUNT_rd_sel            : ldata = {48'b0,DEC_UNCORR_EVENT_COUNT};
      default : ldata = {32'h5555_AAAA,{22{1'b0}},addr[9:0]};
    endcase
  end

// memrd latch
  assign memrd_en_latch = 1'b0;

// global ff
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       rd_data <= 64'h0;
       rd_data_v <= 1'b0;
       memrd_en <=  1'b0;
       lwr_en <=  1'b0;
       lwr_data <= 64'h0;
    end else begin
       lwr_en <= wr_en;
       lwr_data <= wr_data;
       memrd_en <= (memrd_en_latch | memrd_v)? ~memrd_en : memrd_en;
       rd_data <= (memrd_v | rd_en)? ldata : rd_data;
       rd_data_v <= ((wr_en|rd_en) & ~memrd_en_latch) | memrd_v;
    end
  end

 // rw: _SCRATCH
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       WREG__SCRATCH                            <= 64'h0;
    end else begin
       WREG__SCRATCH                            <= (_SCRATCH_wr_sel == 1'b1)? lwr_data[63:0] : WREG__SCRATCH;
    end
  end

  assign oREG__SCRATCH                            = WREG__SCRATCH[63:0];
 // rw: ENC_CONFIG
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       WREG_ENC_CONFIG                          <= 5'h0;
    end else begin
       WREG_ENC_CONFIG[0]                       <= (ENC_CONFIG_wr_sel == 1'b1)? lwr_data[0] : WREG_ENC_CONFIG[0];
       WREG_ENC_CONFIG[1]                       <= (ENC_CONFIG_wr_sel == 1'b1)? lwr_data[1] : WREG_ENC_CONFIG[1];
       WREG_ENC_CONFIG[2]                       <= (ENC_CONFIG_wr_sel == 1'b1)? lwr_data[2] : WREG_ENC_CONFIG[2];
       WREG_ENC_CONFIG[3]                       <= (ENC_CONFIG_wr_sel == 1'b1)? lwr_data[3] : WREG_ENC_CONFIG[3];
       WREG_ENC_CONFIG[4]                       <= (ENC_CONFIG_wr_sel == 1'b1)? lwr_data[4] : WREG_ENC_CONFIG[4];
    end
  end

  assign oREG_ENC_CONFIG_CSR_ENC_IN_ENDIAN_SWAP   = WREG_ENC_CONFIG[0];
  assign oREG_ENC_CONFIG_CSR_ENC_OUT_ENDIAN_SWAP  = WREG_ENC_CONFIG[1];
  assign oREG_ENC_CONFIG_CSR_PCS_SCRAMB_DIS       = WREG_ENC_CONFIG[2];
  assign oREG_ENC_CONFIG_CSR_PCS_ENC_FEC_ENA      = WREG_ENC_CONFIG[3];
  assign oREG_ENC_CONFIG_CSR_PCS_ENC_INV          = WREG_ENC_CONFIG[4];
 // ro: ENC_EXCEPTION
  assign ENC_EXCEPTION                            = {iREG_ENC_EXCEPTION_CSR_EXPT_ENC_EMPT,iREG_ENC_EXCEPTION_CSR_EXPT_ENC_FULL};

 // rw: DEC_CONFIG
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n) begin
       WREG_DEC_CONFIG                          <= 7'h0;
    end else begin
       WREG_DEC_CONFIG[0]                       <= (DEC_CONFIG_wr_sel == 1'b1)? lwr_data[0] : WREG_DEC_CONFIG[0];
       WREG_DEC_CONFIG[1]                       <= (DEC_CONFIG_wr_sel == 1'b1)? lwr_data[1] : WREG_DEC_CONFIG[1];
       WREG_DEC_CONFIG[2]                       <= (DEC_CONFIG_wr_sel == 1'b1)? lwr_data[2] : WREG_DEC_CONFIG[2];
       WREG_DEC_CONFIG[3]                       <= (DEC_CONFIG_wr_sel == 1'b1)? lwr_data[3] : WREG_DEC_CONFIG[3];
       WREG_DEC_CONFIG[4]                       <= (DEC_CONFIG_wr_sel == 1'b1)? lwr_data[4] : WREG_DEC_CONFIG[4];
       WREG_DEC_CONFIG[5]                       <= (DEC_CONFIG_wr_sel == 1'b1)? lwr_data[5] : WREG_DEC_CONFIG[5];
       WREG_DEC_CONFIG[6]                       <= (DEC_CONFIG_wr_sel == 1'b1)? lwr_data[6] : WREG_DEC_CONFIG[6];
    end
  end

  assign oREG_DEC_CONFIG_CSR_DEC_IN_ENDIAN_SWAP   = WREG_DEC_CONFIG[0];
  assign oREG_DEC_CONFIG_CSR_DEC_OUT_ENDIAN_SWAP  = WREG_DEC_CONFIG[1];
  assign oREG_DEC_CONFIG_CSR_PCS_FORCE_NO_FEC     = WREG_DEC_CONFIG[2];
  assign oREG_DEC_CONFIG_CSR_PCS_DESCRAMB_DIS     = WREG_DEC_CONFIG[3];
  assign oREG_DEC_CONFIG_CSR_PCS_DEC_INV          = WREG_DEC_CONFIG[4];
  assign oREG_DEC_CONFIG_CSR_DEC_DESCRAM_IN_ENDIAN_SWAP = WREG_DEC_CONFIG[5];
  assign oREG_DEC_CONFIG_CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP = WREG_DEC_CONFIG[6];
 // ro: DEC_EXCEPTION
  assign DEC_EXCEPTION                            = {iREG_DEC_EXCEPTION_CSR_STAT_BLOCK_LOCK,iREG_DEC_EXCEPTION_CSR_EXPT_LOSS_BLOCKLOCK,iREG_DEC_EXCEPTION_CSR_STAT_FEC_LOCK,iREG_DEC_EXCEPTION_CSR_EXPT_FEC_LOCK_TO};

 // ro: DEC_SLIP_COUNT
  assign DEC_SLIP_COUNT                           = iREG_DEC_SLIP_COUNT[12:0];

 // frc: DEC_CORR_BIT_COUNT
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      DEC_CORR_BIT_COUNT                       <= 16'h0;
    else if (DEC_CORR_BIT_COUNT_wr_sel == 1'b1)
      DEC_CORR_BIT_COUNT                       <= 16'h0;
    else
      DEC_CORR_BIT_COUNT                       <= (iREG_DEC_CORR_BIT_COUNT_EN == 1'b1)? DEC_CORR_BIT_COUNT + iREG_DEC_CORR_BIT_COUNT_INC : DEC_CORR_BIT_COUNT;
  end

 // frc: DEC_CORR_EVENT_COUNT
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      DEC_CORR_EVENT_COUNT                     <= 16'h0;
    else if (DEC_CORR_EVENT_COUNT_wr_sel == 1'b1)
      DEC_CORR_EVENT_COUNT                     <= 16'h0;
    else
      DEC_CORR_EVENT_COUNT                     <= (iREG_DEC_CORR_EVENT_COUNT_EN == 1'b1)? DEC_CORR_EVENT_COUNT + 1 : DEC_CORR_EVENT_COUNT;
  end

 // frc: DEC_UNCORR_EVENT_COUNT
  always_ff @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      DEC_UNCORR_EVENT_COUNT                   <= 16'h0;
    else if (DEC_UNCORR_EVENT_COUNT_wr_sel == 1'b1)
      DEC_UNCORR_EVENT_COUNT                   <= 16'h0;
    else
      DEC_UNCORR_EVENT_COUNT                   <= (iREG_DEC_UNCORR_EVENT_COUNT_EN == 1'b1)? DEC_UNCORR_EVENT_COUNT + 1 : DEC_UNCORR_EVENT_COUNT;
  end

endmodule