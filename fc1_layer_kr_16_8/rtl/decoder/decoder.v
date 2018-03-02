/********************************CONFIDENTIAL**************************** * Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-04-21 12:03:32 -0700 (Mon, 21 Apr 2014) $
* $Revision: 5375 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


module
decoder
#(
        parameter CH   =  0
)
(
        /*AUTOARG*/
        // Outputs
        CSR_STAT_FEC_LOCK, CSR_STAT_SLIP_COUNT, CSR_EXPT_FEC_LOCK_TO,
        CSR_STAT_CORR_BIT_CNT, CSR_STAT_CORR_BIT_CNT_VAL,
        CSR_STAT_CORR_EVENT_CNT, CSR_STAT_UNCORR_EVENT_CNT,
        CSR_EXPT_LOSS_BLOCKLOCK, CSR_STAT_BLOCK_LOCK, PCS_DOUT_BLOCK_SYNC,
        PCS_DOUT, PCS_DOUT_SH, PCS_DOUT_EN, DEC_BITSLIP,
        // Inputs
        RST, CLK, iTX_CLK, iTX_RST, DEC_IN_PMA_BLK, CSR_DEC_IN_ENDIAN_SWAP,
        CSR_DEC_OUT_ENDIAN_SWAP, CSR_DEC_DESCRAM_IN_ENDIAN_SWAP,
        CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP, CSR_DEC_INV, CSR_PCS_FORCE_NO_FEC,
        CSR_PCS_DESCRAMB_DIS
);

// clk/rst
input   RST;
input   CLK;
input   iTX_CLK;
input   iTX_RST;

// din
input   [63:0] DEC_IN_PMA_BLK;

// config
input   CSR_DEC_IN_ENDIAN_SWAP;
input   CSR_DEC_OUT_ENDIAN_SWAP;
input   CSR_DEC_DESCRAM_IN_ENDIAN_SWAP;
input   CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP;
input   CSR_DEC_INV;
input   CSR_PCS_FORCE_NO_FEC;
input   CSR_PCS_DESCRAMB_DIS;
output  CSR_STAT_FEC_LOCK;
output  [12:0] CSR_STAT_SLIP_COUNT;
output  CSR_EXPT_FEC_LOCK_TO;
output  CSR_STAT_CORR_BIT_CNT;
output  [3:0]  CSR_STAT_CORR_BIT_CNT_VAL;
output  CSR_STAT_CORR_EVENT_CNT;
output  CSR_STAT_UNCORR_EVENT_CNT;
output  CSR_EXPT_LOSS_BLOCKLOCK;// From block_sync_inst of block_sync.v
output  CSR_STAT_BLOCK_LOCK;    // From block_sync_inst of block_sync.v

// dout
output  PCS_DOUT_BLOCK_SYNC;
output  [63:0] PCS_DOUT;
output  [1:0]  PCS_DOUT_SH;
output  PCS_DOUT_EN;
output  DEC_BITSLIP;



/*AUTOREG*/
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire    [63:0]    BS_BLK;       // From block_sync_inst of block_sync.v
wire    BS_ENA;                 // From block_sync_inst of block_sync.v
wire    [1:0]    BS_SH;         // From block_sync_inst of block_sync.v
wire    [9:0]    CARRY_VECTOR;          // From err_detect_inst of err_detect.v
wire    [10:0]    CORR_FIELD;           // From err_detect_inst of err_detect.v
wire    CORR_VAL;       // From err_detect_inst of err_detect.v
wire    [64:0]    CORR_VECTOR;          // From err_detect_inst of err_detect.v
wire    CRC_FAIL;       // From decoder_dec_crc_comp_inst of dec_crc_comp.v
wire    [64:0]    C_BLK;        // From correction_inst of correction.v
wire    C_BLK_ENA;              // From correction_inst of correction.v
wire    [31:0]    DEC_CRC;      // From decoder_crc32_galois_d65_inst of crc32_galois_d65.v
wire    [65:0]    DEC_OUT_FEC_BLK;      // From decoder_decomp_inst of decomp.v
wire    DEC_OUT_FEC_BLK_ENA;            // From decoder_decomp_inst of decomp.v
wire    FEC_SLIP;       // From decoder_dec_crc_comp_inst of dec_crc_comp.v
wire    [65:0]    GB_BLK;       // From gb64_66_inst of gb64_66.v
wire    GB_BLK_ENA;             // From gb64_66_inst of gb64_66.v
wire    [63:0]    PN2112_CW;    // From decoder_pn2112_sl_inst of pn2112_sl.v
wire    SLIP;                   // From block_sync_inst of block_sync.v
wire    [63:0]    SLIP_DOUT;    // From decoder_bit_slip_inst of bit_slip.v
wire    SLIP_DOUT_VAL;          // From decoder_bit_slip_inst of bit_slip.v
wire    SLIP_PN_START;          // From decoder_bit_slip_inst of bit_slip.v
wire    [31:0]    SYNDR;        // From decoder_dec_crc_comp_inst of dec_crc_comp.v
wire    SYNDR_VAL;              // From decoder_dec_crc_comp_inst of dec_crc_comp.v
wire    [64:0]    T_BLK;        // From decoder_gb64_65_inst of gb64_65.v
wire    T_BLK_ENA;              // From decoder_gb64_65_inst of gb64_65.v
wire    [31:0]    T_CRC;        // From decoder_gb64_65_inst of gb64_65.v
wire    T_CRC_ENA;              // From decoder_gb64_65_inst of gb64_65.v
wire    fec_lock;               // From decoder_dec_crc_comp_inst of dec_crc_comp.v
// End of automatics


/* bit_slip
    * Slip bits in case CRC mismatch
    */
/* bit_slip AUTO_TEMPLATE (
    .PMA_DIN(DEC_IN_PMA_BLK),
    .ENDIAN_SWAP(CSR_DEC_IN_ENDIAN_SWAP),
    );
    */
bit_slip
decoder_bit_slip_inst
(
        /*AUTOINST*/
        // Outputs
        .SLIP_DOUT             (SLIP_DOUT[63:0]),
        .SLIP_DOUT_VAL         (SLIP_DOUT_VAL),
        .SLIP_PN_START         (SLIP_PN_START),
        .CSR_STAT_SLIP_COUNT           (CSR_STAT_SLIP_COUNT[12:0]),
        .DEC_BITSLIP                   (DEC_BITSLIP),
        // Inputs
        .RST           (RST),
        .CLK           (CLK),
        .PMA_DIN               (DEC_IN_PMA_BLK),        // Templated
        .ENDIAN_SWAP           (CSR_DEC_IN_ENDIAN_SWAP),        // Templated
        .CSR_DEC_INV           (CSR_DEC_INV),
        .SLIP                  (SLIP));

//Verification test point
//============================
wire    [63:0] rev_DEC_IN_PMA_BLK;
wire    [63:0] rev_SLIP_DOUT;
reverse #(64) DEC_IN_PMA_BLK_inst (.ENA(1), .IN(DEC_IN_PMA_BLK), .OUT  (rev_DEC_IN_PMA_BLK));
reverse #(64) SLIP_DOUT_inst (.ENA     (1), .IN(SLIP_DOUT), .OUT       (rev_SLIP_DOUT));
//============================

//================================== PCS DATA PATH =====
/* gb64_66
    * Gearbox for PCS (aka non-FEC) data flow
    */
/* gb64_66 AUTO_TEMPLATE (
    .PMA_BLK(SLIP_DOUT),
    .PMA_BLK_ENA(SLIP_DOUT_VAL),
    );
    */
gb64_66
gb64_66_inst
(
        /*AUTOINST*/
        // Outputs
        .GB_BLK        (GB_BLK[65:0]),
        .GB_BLK_ENA            (GB_BLK_ENA),
        // Inputs
        .CLK                   (CLK),
        .RST                   (RST),
        .PMA_BLK               (SLIP_DOUT),     // Templated
        .PMA_BLK_ENA           (SLIP_DOUT_VAL));        // Templated

/* block_sync  
    * Other than finding sync header for non-FEC data, it also arbitrates the
    * "SLIP" signal to the bit_slip module.  This module supports auto
    * detection of FEC vs. non-FEC data.  It uses the appropriate decoding data
    * path based on the detected format.  
    * User can optionally disable auto-detection and force non-FEC mode.  This
    * can speed up initialization significantly.  The default mode is
    * FEC-protected data stream.
    */
/* block_sync AUTO_TEMPLATE (
    .BLK_SLIP(SLIP), 
    );
    */
block_sync
block_sync_inst
(
        /*AUTOINST*/
        // Outputs
        .CSR_EXPT_FEC_LOCK_TO          (CSR_EXPT_FEC_LOCK_TO),
        .BS_BLK        (BS_BLK[63:0]),
        .BS_SH                 (BS_SH[1:0]),
        .BS_ENA                (BS_ENA),
        .BLK_SLIP              (SLIP),          // Templated
        .CSR_STAT_BLOCK_LOCK           (CSR_STAT_BLOCK_LOCK),
        //.CSR_EXPT_LOSS_BLOCKLOCK       (CSR_EXPT_LOSS_BLOCKLOCK),
        // Inputs
        .CLK           (CLK),
        .RST           (RST),
        .GB_BLK        (GB_BLK[65:0]),
        .GB_BLK_ENA            (GB_BLK_ENA),
        .FEC_SLIP              (FEC_SLIP),
        .CSR_PCS_FORCE_NO_FEC          (CSR_PCS_FORCE_NO_FEC),
        .DEC_OUT_FEC_BLK               (DEC_OUT_FEC_BLK[65:0]),
        .DEC_OUT_FEC_BLK_ENA           (DEC_OUT_FEC_BLK_ENA),
        .CSR_STAT_FEC_LOCK             (CSR_STAT_FEC_LOCK));

assign CSR_EXPT_LOSS_BLOCKLOCK = SLIP;

//================================== END PCS DATA PATH =====

//================================== FEC DATA PATH =====

/* pseudo-noise (wrapper)
    * generates PN2112 seq in free running mode
    */
/* pn2112_sl AUTO_TEMPLATE (
    .ENA(SLIP_PN_START),
    );
    */
pn2112_sl
decoder_pn2112_sl_inst
(
        /*AUTOINST*/
        // Outputs
        .PN2112_CW             (PN2112_CW[63:0]),
        // Inputs
        .CLK                   (CLK),
        .RST                   (RST),
        .ENA                   (SLIP_PN_START));        // Templated

/* Gearbox 64/65 + CRC parsing
    */
/* gb64_65 AUTO_TEMPLATE (
    .P_BLK_ENA(SLIP_DOUT_VAL),
    .P_BLK(SLIP_DOUT ^ PN2112_CW),
    .ENA(SLIP_DOUT_VAL),
    );
    */
gb64_65
decoder_gb64_65_inst
(
        /*AUTOINST*/
        // Outputs
        .T_BLK                 (T_BLK[64:0]),
        .T_CRC                 (T_CRC[31:0]),
        .T_BLK_ENA             (T_BLK_ENA),
        .T_CRC_ENA             (T_CRC_ENA),
        // Inputs
        .CLK                   (CLK),
        .RST                   (RST),
        .P_BLK                 (SLIP_DOUT ^ PN2112_CW), // Templated
        .P_BLK_ENA             (SLIP_DOUT_VAL));        // Templated

//Verification test point
//============================
wire    [64:0] rev_T_BLK;
wire    [31:0] rev_T_CRC;
wire    [63:0] rev_PN2112_CW;
reverse #(64) rev_PN2112_CW_inst (.ENA (1), .IN(PN2112_CW), .OUT       (rev_PN2112_CW));
reverse #(65) T_BLK_REV_INST (.ENA     (1), .IN(T_BLK), .OUT   (rev_T_BLK));
reverse #(32) T_CRC_REV_INST (.ENA     (1), .IN(T_CRC), .OUT   (rev_T_CRC));
//============================

/* crc32_galois_d65
    */
/* crc32_galois_d65 AUTO_TEMPLATE (
    .DIN (T_BLK),
    .ENA (T_BLK_ENA),
    .CRC (DEC_CRC[31:0]),
    .RST (RST || T_CRC_ENA),
    );
    */
crc32_galois_d65
decoder_crc32_galois_d65_inst
(
        /*AUTOINST*/
        // Outputs
        .CRC           (DEC_CRC[31:0]),         // Templated
        // Inputs
        .DIN           (T_BLK),         // Templated
        .ENA           (T_BLK_ENA),     // Templated
        .RST           (RST || T_CRC_ENA),      // Templated
        .CLK           (CLK));

/* dec_crc_comp
    * compares locally generated CRC against CRC in data stream
    * produces syndrome vector
    */
/* dec_crc_comp AUTO_TEMPLATE (
    .FEC_LOCK      (fec_lock),
    .SLIP (FEC_SLIP),
    );
    */
dec_crc_comp
decoder_dec_crc_comp_inst
(
        /*AUTOINST*/
        // Outputs
        .CRC_FAIL              (CRC_FAIL),
        .SYNDR                 (SYNDR[31:0]),
        .SYNDR_VAL             (SYNDR_VAL),
        .FEC_LOCK              (fec_lock),      // Templated
        .SLIP                  (FEC_SLIP),      // Templated
        // Inputs
        .CLK                   (CLK),
        .RST                   (RST),
        .T_CRC                 (T_CRC[31:0]),
        .T_CRC_ENA             (T_CRC_ENA),
        .DEC_CRC               (DEC_CRC[31:0]));

/* err_detect
    * Detects error based on syndrom vector
    */
err_detect
err_detect_inst
(
        /*AUTOINST*/
        // Outputs
        .CORR_VECTOR           (CORR_VECTOR[64:0]),
        .CARRY_VECTOR          (CARRY_VECTOR[9:0]),
        .CORR_VAL              (CORR_VAL),
        .CORR_FIELD            (CORR_FIELD[10:0]),
        // Inputs
        .CLK                   (CLK),
        .RST                   (RST),
        .SYNDR                 (SYNDR[31:0]),
        .SYNDR_VAL             (SYNDR_VAL));

/* correction AUTO_TEMPLATE (
    .FEC_LOCK (fec_lock),
    );
    */
/* err_correction
    * Makes corrections to the data stream based on the err_detect outputs
    */
correction
correction_inst
(
        /*AUTOINST*/
        // Outputs
        .C_BLK_ENA             (C_BLK_ENA),
        .C_BLK                 (C_BLK[64:0]),
        .CSR_STAT_FEC_LOCK             (CSR_STAT_FEC_LOCK),
        // Inputs
        .CLK           (CLK),
        .RST           (RST),
        .FEC_LOCK              (fec_lock),      // Templated
        .T_BLK_ENA             (T_BLK_ENA),
        .T_BLK                 (T_BLK[64:0]),
        .CORR_VAL              (CORR_VAL),
        .CORR_VECTOR           (CORR_VECTOR[64:0]),
        .CARRY_VECTOR          (CARRY_VECTOR[9:0]));

/* decomp
    * decompress data to restore 66-bit code word from T-word
    */
/* decomp AUTO_TEMPLATE (
    .ENDIAN_SWAP(CSR_DEC_OUT_ENDIAN_SWAP),
    .PCS_BLK(DEC_OUT_FEC_BLK[65:0]),
    .PCS_BLK_ENA(DEC_OUT_FEC_BLK_ENA),
    );
    */
decomp
decoder_decomp_inst
(
        /*AUTOINST*/
        // Outputs
        .PCS_BLK               (DEC_OUT_FEC_BLK[65:0]), // Templated
        .PCS_BLK_ENA           (DEC_OUT_FEC_BLK_ENA),   // Templated
        // Inputs
        .CLK                   (CLK),
        .RST                   (RST),
        .C_BLK                 (C_BLK[64:0]),
        .C_BLK_ENA             (C_BLK_ENA),
        .ENDIAN_SWAP           (CSR_DEC_OUT_ENDIAN_SWAP));      // Templated

//Verification test point
//============================
wire    [65:0] rev_DEC_OUT_FEC_BLK;
reverse #(66) rev_PCS_BLK_inst (.ENA   (1), .IN(DEC_OUT_FEC_BLK), .OUT (rev_DEC_OUT_FEC_BLK));
//============================


/* dec_stats
    * Decoder statistics block.
    * outputs # of bits corrected and # of correction events
    */
/* dec_stats AUTO_TEMPLATE (
    ); 
    */
dec_stats
dec_stats_inst
(
        /*AUTOINST*/
        // Outputs
        .CSR_STAT_CORR_BIT_CNT         (CSR_STAT_CORR_BIT_CNT),
        .CSR_STAT_CORR_BIT_CNT_VAL     (CSR_STAT_CORR_BIT_CNT_VAL[3:0]),
        .CSR_STAT_CORR_EVENT_CNT       (CSR_STAT_CORR_EVENT_CNT),
        .CSR_STAT_UNCORR_EVENT_CNT     (CSR_STAT_UNCORR_EVENT_CNT),
        // Inputs
        .CLK           (CLK),
        .RST           (RST),
        .iTX_CLK               (iTX_CLK),
        .iTX_RST               (iTX_RST),
        .CORR_FIELD            (CORR_FIELD[10:0]),
        .CORR_VAL              (CORR_VAL),
        .CRC_FAIL              (CRC_FAIL),
        .CSR_STAT_FEC_LOCK             (CSR_STAT_FEC_LOCK));
//================================== END FEC DATA PATH =====

/* pcs_descrambler
    * descrambles data with X^58 + X^19 + 1 polynomial as per standard
    */
/* pcs_descrambler AUTO_TEMPLATE (
    .DIN(BS_BLK),
    .DIN_SH(BS_SH),
    .DIN_EN(BS_ENA),
    .DIN_BLOCK_SYNC(CSR_STAT_BLOCK_LOCK),
    .DOUT_BLOCK_SYNC (PCS_DOUT_BLOCK_SYNC),
    .DOUT (PCS_DOUT),
    .DOUT_SH (PCS_DOUT_SH),
    .DOUT_EN (PCS_DOUT_EN),
    ); 
    */

pcs_descrambler #(.CH                  (CH), .WIDTH    (64))
pcs_descrambler_inst
(
        /*AUTOINST*/
        // Outputs
        .DOUT_BLOCK_SYNC       (PCS_DOUT_BLOCK_SYNC),   // Templated
        .DOUT                  (PCS_DOUT),              // Templated
        .DOUT_SH               (PCS_DOUT_SH),           // Templated
        .DOUT_EN               (PCS_DOUT_EN),           // Templated
        // Inputs
        .CLK                   (CLK),
        .RST                   (RST),
        .CSR_PCS_DESCRAMB_DIS          (CSR_PCS_DESCRAMB_DIS),
        .CSR_DEC_DESCRAM_IN_ENDIAN_SWAP        (CSR_DEC_DESCRAM_IN_ENDIAN_SWAP),
        .CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP       (CSR_DEC_DESCRAM_OUT_ENDIAN_SWAP),
        .DIN           (BS_BLK),        // Templated
        .DIN_SH        (BS_SH),         // Templated
        .DIN_EN        (BS_ENA),        // Templated
        .DIN_BLOCK_SYNC        (CSR_STAT_BLOCK_LOCK));          // Templated


//Verif test point
always @(CSR_STAT_FEC_LOCK)
if (CSR_STAT_FEC_LOCK)
        $display("FEC LOCK!!!");
wire    [63:0] rev_BS_BLK;
reverse #(64) rev_BS_BLK_inst (.ENA    (1), .IN(BS_BLK), .OUT  (rev_BS_BLK));
//

endmodule

// Local Variables:
// verilog-library-directories:("." "./pcs_descrambler/" "./block_sync/" "./dec_stats/" "./correction/" "./err_detect/" "./bit_slip/" "../common/pn2112/" "./dec_crc_comp/" "./decomp/" "../common/crc32_galois_d65" "../common/gb64_65/" "../common/gb64_66/")
// verilog-library-extensions:(".v" ".h")
// End:

