/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-06-03 15:21:21 -0700 (Tue, 03 Jun 2014) $
* $Revision: 6169 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/
import fc1_pkg::*;

module 
fc1_kr  
#(
        parameter CH   =  0,
        parameter SIM_ONLY =  0
)
(
        input   iCLK_CORE,
        input   iRST_CORE,
        input   iRST_LINK_SERDES_TX212_N,
        input   iRST_LINK_SERDES_TX219_N,
        input   iTX_RST,
        input   iTX_CLK,
        input   iTX_RST219,
        input   iTX_CLK219,
        input   iRX_RST,
        input   iRX_CLK,
        
        /*Encoder IO*/
        // input
        input   [1:0]  iENC_IN_PCS_SH,                  // To compressor_inst of compressor.v
        input   [63:0] iENC_IN_PCS_BLK,                 // To compressor_inst of compressor.v
        input   iENC_IN_PCS_BLK_ENA,                    // To compressor_inst of compressor.v
        input   REG_CTL_FARLOOPBACKEN,
        
        // output
        output  [63:0] oENC_OUT_PMA_BLK,                // From out_regs_inst of regs.v
        
        
        
        /*Decoder IO*/
        // din
        input   [63:0]  iDEC_IN_PMA_BLK,
        
        // dout
        output  oPCS_DOUT_BLOCK_SYNC,
        output  [63:0] oPCS_DOUT,
        output  [1:0]  oPCS_DOUT_SH,
        output  oPCS_DOUT_EN,
        output  oDEC_BITSLIP,
        
        
        /*ENC register interface*/
        //din
        input   iCSR_WR_EN,
        input   iCSR_RD_EN,
        input   [13:0]  iCSR_ADDR,
        input   [63:0]  iCSR_WR_DATA,
        //dout
        output  [63:0] oCSR_RD_DATA,
        output  oCSR_RD_DATA_V,
        
        /*Interval Stats*/
        input   iINT_STATS_LATCH_CLR,
        //output  fc1_pkg::fc1_interval_stats oINT_STATS_FC1
        output  [31:0] oINT_STATS_FC1_CORR_EVENT_CNT,
        output  [31:0] oINT_STATS_FC1_UNCORR_EVENT_CNT,
        output  [31:0] oINT_STATS_FC1_PCS_LOS_CNT
        
);



/*AUTOREG*/
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire    CSR_DEC_DESCRAM_IN_ENDIAN_SWAP; // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP;// From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_DEC_INV;    // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_DEC_IN_ENDIAN_SWAP;         // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_DEC_OUT_ENDIAN_SWAP;        // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_ENC_INV;    // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_ENC_IN_ENDIAN_SWAP;         // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_ENC_OUT_ENDIAN_SWAP;        // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_EXPT_ENC_EMPT;              // From encoder_inst of encoder.v
wire    CSR_EXPT_ENC_FULL;              // From encoder_inst of encoder.v
wire    CSR_EXPT_FEC_LOCK_TO;           // From decoder_inst of decoder.v
wire    CSR_EXPT_LOSS_BLOCKLOCK;        // From decoder_inst of decoder.v
wire    CSR_PCS_DESCRAMB_DIS;           // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_PCS_ENC_FEC_ENA;            // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_PCS_FORCE_NO_FEC;           // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_PCS_SCRAMB_DIS;             // From fc1_layer_csr_inst of fc1_layer_csr.v
wire    CSR_STAT_BLOCK_LOCK;            // From decoder_inst of decoder.v
wire    CSR_STAT_CORR_BIT_CNT;          // From decoder_inst of decoder.v
wire    [3:0]    CSR_STAT_CORR_BIT_CNT_VAL;     // From decoder_inst of decoder.v
wire    CSR_STAT_CORR_EVENT_CNT;// From decoder_inst of decoder.v
wire    CSR_STAT_FEC_LOCK;      // From decoder_inst of decoder.v
wire    [12:0]    CSR_STAT_SLIP_COUNT;  // From decoder_inst of decoder.v
wire    CSR_STAT_UNCORR_EVENT_CNT;      // From decoder_inst of decoder.v
wire    [63:0]    oREG__SCRATCH;        // From fc1_layer_csr_inst of fc1_layer_csr.v
// End of automatics


/*fc1_layer_csr AUTO_TEMPLATE (
    .clk(iCLK_CORE),
    .rst_n(~iRST_CORE),
    .wr_en(iCSR_WR_EN),
    .rd_en(iCSR_RD_EN),
    .addr(iCSR_ADDR),
    .wr_data(iCSR_WR_DATA),
    .rd_data(oCSR_RD_DATA),
    .rd_data_v(oCSR_RD_DATA_V),
    .oREG_ENC_CONFIG_CSR_PCS_ENC_FEC_ENA(CSR_PCS_ENC_FEC_ENA),
    .oREG_ENC_CONFIG_CSR_PCS_SCRAMB_DIS(CSR_PCS_SCRAMB_DIS),
    .oREG_ENC_CONFIG_CSR_ENC_OUT_ENDIAN_SWAP(CSR_ENC_OUT_ENDIAN_SWAP),
    .oREG_ENC_CONFIG_CSR_ENC_IN_ENDIAN_SWAP(CSR_ENC_IN_ENDIAN_SWAP),
    .oREG_ENC_CONFIG_CSR_PCS_ENC_INV(CSR_ENC_INV),
    .iREG_ENC_EXCEPTION_CSR_EXPT_ENC_EMPT(CSR_EXPT_ENC_EMPT),
    .iREG_ENC_EXCEPTION_CSR_EXPT_ENC_FULL(CSR_EXPT_ENC_FULL),
    .oREG_DEC_CONFIG_CSR_PCS_DESCRAMB_DIS(CSR_PCS_DESCRAMB_DIS),
    .oREG_DEC_CONFIG_CSR_PCS_FORCE_NO_FEC(CSR_PCS_FORCE_NO_FEC),
    .oREG_DEC_CONFIG_CSR_DEC_OUT_ENDIAN_SWAP(CSR_DEC_OUT_ENDIAN_SWAP),
    .oREG_DEC_CONFIG_CSR_DEC_IN_ENDIAN_SWAP(CSR_DEC_IN_ENDIAN_SWAP),
    .oREG_DEC_CONFIG_CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP(CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP),
    .oREG_DEC_CONFIG_CSR_DEC_DESCRAM_IN_ENDIAN_SWAP(CSR_DEC_DESCRAM_IN_ENDIAN_SWAP),
    .oREG_DEC_CONFIG_CSR_PCS_DEC_INV(CSR_DEC_INV),
    .iREG_DEC_EXCEPTION_CSR_STAT_BLOCK_LOCK(CSR_STAT_BLOCK_LOCK),
    .iREG_DEC_EXCEPTION_CSR_EXPT_LOSS_BLOCKLOCK(CSR_EXPT_LOSS_BLOCKLOCK),
    .iREG_DEC_EXCEPTION_CSR_STAT_FEC_LOCK(CSR_STAT_FEC_LOCK),
    .iREG_DEC_EXCEPTION_CSR_EXPT_FEC_LOCK_TO(CSR_EXPT_FEC_LOCK_TO),
    .iREG_DEC_SLIP_COUNT(CSR_STAT_SLIP_COUNT),
    .iREG_DEC_CORR_BIT_COUNT_EN(CSR_STAT_CORR_BIT_CNT),
    .iREG_DEC_CORR_BIT_COUNT_INC(CSR_STAT_CORR_BIT_CNT_VAL),
    .iREG_DEC_CORR_EVENT_COUNT_EN(CSR_STAT_CORR_EVENT_CNT),
    .iREG_DEC_UNCORR_EVENT_COUNT_EN(CSR_STAT_UNCORR_EVENT_CNT),

    );
    */
fc1_layer_csr
fc1_layer_csr_inst
(
        /*AUTOINST*/
        // Outputs
        .rd_data               (oCSR_RD_DATA),          // Templated
        .rd_data_v             (oCSR_RD_DATA_V),        // Templated
        .oREG__SCRATCH         (oREG__SCRATCH[63:0]),
        .oREG_ENC_CONFIG_CSR_PCS_ENC_INV       (CSR_ENC_INV),           // Templated
        .oREG_ENC_CONFIG_CSR_PCS_ENC_FEC_ENA   (CSR_PCS_ENC_FEC_ENA),   // Templated
        .oREG_ENC_CONFIG_CSR_PCS_SCRAMB_DIS    (CSR_PCS_SCRAMB_DIS),    // Templated
        .oREG_ENC_CONFIG_CSR_ENC_OUT_ENDIAN_SWAP       (CSR_ENC_OUT_ENDIAN_SWAP),       // Templated
        .oREG_ENC_CONFIG_CSR_ENC_IN_ENDIAN_SWAP        (CSR_ENC_IN_ENDIAN_SWAP),        // Templated
        .oREG_DEC_CONFIG_CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP       (CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP),       // Templated
        .oREG_DEC_CONFIG_CSR_DEC_DESCRAM_IN_ENDIAN_SWAP        (CSR_DEC_DESCRAM_IN_ENDIAN_SWAP),        // Templated
        .oREG_DEC_CONFIG_CSR_PCS_DEC_INV       (CSR_DEC_INV),           // Templated
        .oREG_DEC_CONFIG_CSR_PCS_DESCRAMB_DIS  (CSR_PCS_DESCRAMB_DIS),          // Templated
        .oREG_DEC_CONFIG_CSR_PCS_FORCE_NO_FEC  (CSR_PCS_FORCE_NO_FEC),          // Templated
        .oREG_DEC_CONFIG_CSR_DEC_OUT_ENDIAN_SWAP       (CSR_DEC_OUT_ENDIAN_SWAP),       // Templated
        .oREG_DEC_CONFIG_CSR_DEC_IN_ENDIAN_SWAP        (CSR_DEC_IN_ENDIAN_SWAP),        // Templated
        // Inputs
        .clk           (iCLK_CORE),     // Templated
        .rst_n                 (~iRST_CORE),            // Templated
        .wr_en                 (iCSR_WR_EN),            // Templated
        .rd_en                 (iCSR_RD_EN),            // Templated
        .addr                  (iCSR_ADDR),             // Templated
        .wr_data               (iCSR_WR_DATA),          // Templated
        .iREG_ENC_EXCEPTION_CSR_EXPT_ENC_EMPT  (CSR_EXPT_ENC_EMPT),     // Templated
        .iREG_ENC_EXCEPTION_CSR_EXPT_ENC_FULL  (CSR_EXPT_ENC_FULL),     // Templated
        .iREG_DEC_EXCEPTION_CSR_STAT_BLOCK_LOCK(CSR_STAT_BLOCK_LOCK),   // Templated
        .iREG_DEC_EXCEPTION_CSR_EXPT_LOSS_BLOCKLOCK    (CSR_EXPT_LOSS_BLOCKLOCK),       // Templated
        .iREG_DEC_EXCEPTION_CSR_STAT_FEC_LOCK          (CSR_STAT_FEC_LOCK),             // Templated
        .iREG_DEC_EXCEPTION_CSR_EXPT_FEC_LOCK_TO       (CSR_EXPT_FEC_LOCK_TO),          // Templated
        .iREG_DEC_SLIP_COUNT           (CSR_STAT_SLIP_COUNT),   // Templated
        .iREG_DEC_CORR_BIT_COUNT_EN    (CSR_STAT_CORR_BIT_CNT), // Templated
        .iREG_DEC_CORR_BIT_COUNT_INC           (CSR_STAT_CORR_BIT_CNT_VAL),     // Templated
        .iREG_DEC_CORR_EVENT_COUNT_EN          (CSR_STAT_CORR_EVENT_CNT),       // Templated
        .iREG_DEC_UNCORR_EVENT_COUNT_EN        (CSR_STAT_UNCORR_EVENT_CNT));    // Templated


/*encoder AUTO_TEMPLATE (
    .RXCLK (iRX_CLK),
    .RXRST (iRX_RST),
    .CLK(iTX_CLK),
    //.RST(~iRST_LINK_SERDES_TX212_N),
    .RST           (iTX_RST),
    .CLK219(iTX_CLK219),
    //.RST219(~iRST_LINK_SERDES_TX219_N),
    .RST219        (iTX_RST219),
    .RX_DAT(oPCS_DOUT),
    .RX_SH(oPCS_DOUT_SH),
    .RX_VAL(oPCS_DOUT_EN),
    .ENC_OUT_PMA_BLK(oENC_OUT_PMA_BLK[63:0]),
    .ENC_IN_PCS_SH (iENC_IN_PCS_SH[1:0]),
    .ENC_IN_PCS_BLK(iENC_IN_PCS_BLK[63:0]),
    .ENC_IN_PCS_BLK_ENA(iENC_IN_PCS_BLK_ENA),
    .CSR_PCS_ENC_FEC_ENA           (CSR_PCS_ENC_FEC_ENA && SIM_ONLY));
    );
    */
encoder
encoder_inst
(
        /*AUTOINST*/
        // Outputs
        .CSR_EXPT_ENC_FULL             (CSR_EXPT_ENC_FULL),
        .CSR_EXPT_ENC_EMPT             (CSR_EXPT_ENC_EMPT),
        .ENC_OUT_PMA_BLK               (oENC_OUT_PMA_BLK[63:0]),        // Templated
        // Inputs
        .RXCLK                         (iRX_CLK),       // Templated
        .RXRST                         (iRX_RST),       // Templated
        .CLK           (iTX_CLK),       // Templated
        .RST           (iTX_RST),       // Templated
        .CLK219        (iTX_CLK219),            // Templated
        .RST219        (iTX_RST219),            // Templated
        .RX_DAT        (oPCS_DOUT),             // Templated
        .RX_SH                 (oPCS_DOUT_SH),          // Templated
        .RX_VAL                (oPCS_DOUT_EN),          // Templated
        .RX_SYNC               (CSR_STAT_BLOCK_LOCK),          // Templated
        .REG_CTL_FARLOOPBACKEN         (REG_CTL_FARLOOPBACKEN),
        .ENC_IN_PCS_SH                 (iENC_IN_PCS_SH[1:0]),   // Templated
        .ENC_IN_PCS_BLK                (iENC_IN_PCS_BLK[63:0]), // Templated
        .ENC_IN_PCS_BLK_ENA            (iENC_IN_PCS_BLK_ENA),   // Templated
        .CSR_ENC_IN_ENDIAN_SWAP        (CSR_ENC_IN_ENDIAN_SWAP),
        .CSR_ENC_OUT_ENDIAN_SWAP       (CSR_ENC_OUT_ENDIAN_SWAP),
        .CSR_ENC_INV                   (CSR_ENC_INV),
        .CSR_PCS_SCRAMB_DIS            (CSR_PCS_SCRAMB_DIS),
        .CSR_PCS_ENC_FEC_ENA           (CSR_PCS_ENC_FEC_ENA));      // Templated

/*decoder AUTO_TEMPLATE (
    .CLK(iRX_CLK),
    .RST(iRX_RST),
    .DEC_IN_PMA_BLK             (iDEC_IN_PMA_BLK[63:0]),
    .PCS_DOUT_BLOCK_SYNC               (oPCS_DOUT_BLOCK_SYNC),
    .PCS_DOUT                   (oPCS_DOUT[63:0]),
    .PCS_DOUT_SH               (oPCS_DOUT_SH[1:0]),
    .PCS_DOUT_EN               (oPCS_DOUT_EN),
    .DEC_BITSLIP               (oDEC_BITSLIP),
    );
    */
decoder
#(CH)
decoder_inst
(
        /*AUTOINST*/
        // Outputs
        .CSR_STAT_FEC_LOCK             (CSR_STAT_FEC_LOCK),
        .CSR_STAT_SLIP_COUNT           (CSR_STAT_SLIP_COUNT[12:0]),
        .CSR_EXPT_FEC_LOCK_TO          (CSR_EXPT_FEC_LOCK_TO),
        .CSR_STAT_CORR_BIT_CNT         (CSR_STAT_CORR_BIT_CNT),
        .CSR_STAT_CORR_BIT_CNT_VAL     (CSR_STAT_CORR_BIT_CNT_VAL[3:0]),
        .CSR_STAT_CORR_EVENT_CNT       (CSR_STAT_CORR_EVENT_CNT),
        .CSR_STAT_UNCORR_EVENT_CNT     (CSR_STAT_UNCORR_EVENT_CNT),
        .CSR_EXPT_LOSS_BLOCKLOCK       (CSR_EXPT_LOSS_BLOCKLOCK),
        .CSR_STAT_BLOCK_LOCK           (CSR_STAT_BLOCK_LOCK),
        .PCS_DOUT_BLOCK_SYNC           (oPCS_DOUT_BLOCK_SYNC),          // Templated
        .PCS_DOUT                      (oPCS_DOUT[63:0]),               // Templated
        .PCS_DOUT_SH                   (oPCS_DOUT_SH[1:0]),             // Templated
        .PCS_DOUT_EN                   (oPCS_DOUT_EN),                  // Templated
        .DEC_BITSLIP                   (oDEC_BITSLIP),                  // Templated
        // Inputs
        .RST           (iRX_RST),       // Templated
        .CLK           (iRX_CLK),       // Templated
        .iTX_CLK               (iTX_CLK),
        .iTX_RST               (iTX_RST),
        .DEC_IN_PMA_BLK        (iDEC_IN_PMA_BLK[63:0]), // Templated
        .CSR_DEC_IN_ENDIAN_SWAP        (CSR_DEC_IN_ENDIAN_SWAP),
        .CSR_DEC_OUT_ENDIAN_SWAP       (CSR_DEC_OUT_ENDIAN_SWAP),
        .CSR_DEC_DESCRAM_IN_ENDIAN_SWAP        (CSR_DEC_DESCRAM_IN_ENDIAN_SWAP),
        .CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP       (CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP),
        .CSR_DEC_INV           (CSR_DEC_INV),
        .CSR_PCS_FORCE_NO_FEC          (CSR_PCS_FORCE_NO_FEC),
        .CSR_PCS_DESCRAMB_DIS          (CSR_PCS_DESCRAMB_DIS));

/*
 fc1_intstat AUTO_TEMPLATE (

        //.iTX_RST               (~iRST_LINK_SERDES_TX212_N),
 );
 */
fc1_intstat fc1_intstat_inst (  /*AUTOINST*/
        // Outputs
        .oINT_STATS_FC1_CORR_EVENT_CNT (oINT_STATS_FC1_CORR_EVENT_CNT[31:0]),
        .oINT_STATS_FC1_UNCORR_EVENT_CNT       (oINT_STATS_FC1_UNCORR_EVENT_CNT[31:0]),
        .oINT_STATS_FC1_PCS_LOS_CNT            (oINT_STATS_FC1_PCS_LOS_CNT[31:0]),
        // Inputs
        .iRX_CLK       (iRX_CLK),
        .iRX_RST       (iRX_RST),
        .iTX_CLK       (iTX_CLK),
        .iTX_RST       (iTX_RST),
        .iINT_STATS_LATCH_CLR  (iINT_STATS_LATCH_CLR),
        .CSR_EXPT_ENC_FULL     (CSR_EXPT_ENC_FULL),
        .CSR_EXPT_ENC_EMPT     (CSR_EXPT_ENC_EMPT),
        .CSR_STAT_CORR_EVENT_CNT       (CSR_STAT_CORR_EVENT_CNT),
        .CSR_STAT_UNCORR_EVENT_CNT     (CSR_STAT_UNCORR_EVENT_CNT),
        .CSR_EXPT_LOSS_BLOCKLOCK       (CSR_EXPT_LOSS_BLOCKLOCK));

endmodule

// Local Variables:
// verilog-library-directories:("." "./fc1_intstat" "./encoder" "./decoder" "../doc")
// verilog-library-extensions:(".v" ".h")
// End:

