/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-04-02 09:26:11 -0700 (Wed, 02 Apr 2014) $
* $Revision: 5082 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


/* FEC encoder
 */


module encoder (
        /*AUTOARG*/
        // Outputs
        CSR_EXPT_ENC_FULL, CSR_EXPT_ENC_EMPT, ENC_OUT_PMA_BLK,
        // Inputs
        RXCLK, RXRST, CLK, RST, CLK219, RST219, RX_DAT, RX_SH, RX_VAL, RX_SYNC,
        REG_CTL_FARLOOPBACKEN, ENC_IN_PCS_SH, ENC_IN_PCS_BLK,
        ENC_IN_PCS_BLK_ENA, CSR_ENC_IN_ENDIAN_SWAP, CSR_ENC_OUT_ENDIAN_SWAP,
        CSR_ENC_INV, CSR_PCS_SCRAMB_DIS, CSR_PCS_ENC_FEC_ENA
);
// clk/reset
input   RXCLK;
input   RXRST;
input   CLK;            // To compressor_inst of compressor.v, ...
input   RST;            // To encode_pn2112_inst of pn2112.v, ...
input   CLK219;
input   RST219;

// input
input   [63:0] RX_DAT;
input   [1:0]  RX_SH;
input   RX_VAL;
input   RX_SYNC;
input   REG_CTL_FARLOOPBACKEN; 

input   [1:0]    ENC_IN_PCS_SH;         // To compressor_inst of compressor.v
input   [63:0]   ENC_IN_PCS_BLK;        // To compressor_inst of compressor.v
input   ENC_IN_PCS_BLK_ENA;             // To compressor_inst of compressor.v

// config
input   CSR_ENC_IN_ENDIAN_SWAP;                 // To compressor_inst of compressor.v
input   CSR_ENC_OUT_ENDIAN_SWAP;                // To compressor_inst of compressor.v
input   CSR_ENC_INV;
input   CSR_PCS_SCRAMB_DIS;
input   CSR_PCS_ENC_FEC_ENA;
output  CSR_EXPT_ENC_FULL;
output  CSR_EXPT_ENC_EMPT;

// output
output  [63:0]   ENC_OUT_PMA_BLK;               // From out_regs_inst of regs.v



wire    par_rst;

/*AUTOREG*/
// Beginning of automatic regs (for this module's undeclared outputs)
reg     [63:0]    ENC_OUT_PMA_BLK;
// End of automatics
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire    [63:0]    GB66_BLK;     // From gb66_64_inst of gb66_64.v
wire    [63:0]    MUX_DAT;      // From data_mux_inst of data_mux.v
wire    [1:0]    MUX_SH;        // From data_mux_inst of data_mux.v
wire    MUX_VAL;                // From data_mux_inst of data_mux.v
wire    [65:0]    scramb_dout;          // From pcs_scrambler_inst of pcs_scrambler.v
wire    scramb_dout_en;                 // From pcs_scrambler_inst of pcs_scrambler.v
wire    simonly_expt_gb66_64_empty;     // From gb66_64_inst of gb66_64.v
wire    simonly_expt_gb66_64_full;      // From gb66_64_inst of gb66_64.v
// End of automatics

assign  CSR_EXPT_ENC_FULL  =  1'b0;
assign  CSR_EXPT_ENC_EMPT  =  1'b0;


logic CSR_PCS_SCRAMB_DIS_sync;
logic CSR_ENC_IN_ENDIAN_SWAP_sync;
logic CSR_ENC_INV_sync;
logic REG_CTL_FARLOOPBACKEN_sync;


vi_sync_level #(
        .SIZE                  ( 4                     ),
        .TWO_DST_FLOPS         ( 1                     ),
        .ASSERT                ( 1                     )
)
reg_config_sync (
        .out_level             ( {CSR_PCS_SCRAMB_DIS_sync, 
        CSR_ENC_IN_ENDIAN_SWAP_sync, 
        CSR_ENC_INV_sync,
        REG_CTL_FARLOOPBACKEN_sync}      ),
        .clk                   ( CLK219                    ),
        .rst_n                 ( ~RST219                  ),
        .in_level              ( {CSR_PCS_SCRAMB_DIS, 
        CSR_ENC_IN_ENDIAN_SWAP, 
        CSR_ENC_INV,
        REG_CTL_FARLOOPBACKEN}         )
);

/* data_mux AUTO_TEMPLATE (
  .BIST_DAT (ENC_IN_PCS_BLK),
  .BIST_SH  (ENC_IN_PCS_SH),
  .BIST_VAL (ENC_IN_PCS_BLK_ENA),
  .lpbk_en  (REG_CTL_FARLOOPBACKEN_sync),
 );
*/
data_mux 
data_mux_inst
(
        /*AUTOINST*/
        // Outputs
        .MUX_DAT               (MUX_DAT[63:0]),
        .MUX_SH                (MUX_SH[1:0]),
        .MUX_VAL               (MUX_VAL),
        // Inputs
        .RXCLK                 (RXCLK),
        .RXRST                 (RXRST),
        .CLK219                (CLK219),
        .RST219                (RST219),
        .lpbk_en               (REG_CTL_FARLOOPBACKEN_sync),    // Templated
        .RX_DAT                (RX_DAT[63:0]),
        .RX_SH                 (RX_SH[1:0]),
        .RX_VAL                (RX_VAL),
        .RX_SYNC               (RX_SYNC),
        .BIST_DAT              (ENC_IN_PCS_BLK),                // Templated
        .BIST_SH               (ENC_IN_PCS_SH),                 // Templated
        .BIST_VAL              (ENC_IN_PCS_BLK_ENA));           // Templated

/* pcs_scrambler
    * X^58 + X19 + 1 self-synchronizing scrambler.  Reduse long run-length
    */
/* pcs_scrambler AUTO_TEMPLATE (
    .CLK (CLK219),
    .RST (RST219),
    .DIN_EN (MUX_VAL),
    .DIN (MUX_DAT),
    .DIN_SH (MUX_SH),
    .DOUT (scramb_dout[65:0]),
    .DOUT_EN (scramb_dout_en),
        .CSR_PCS_SCRAMB_DIS            (CSR_PCS_SCRAMB_DIS_sync),
        .CSR_ENC_IN_ENDIAN_SWAP        (CSR_ENC_IN_ENDIAN_SWAP_sync),
    );
    */
pcs_scrambler
pcs_scrambler_inst
(
        /*AUTOINST*/
        // Outputs
        .DOUT          (scramb_dout[65:0]),     // Templated
        .DOUT_EN               (scramb_dout_en),        // Templated
        // Inputs
        .CLK                   (CLK219),        // Templated
        .RST                   (RST219),        // Templated
        .CSR_PCS_SCRAMB_DIS            (CSR_PCS_SCRAMB_DIS_sync),       // Templated
        .CSR_ENC_IN_ENDIAN_SWAP        (CSR_ENC_IN_ENDIAN_SWAP_sync),   // Templated
        .DIN_EN        (MUX_VAL),       // Templated
        .DIN           (MUX_DAT),       // Templated
        .DIN_SH        (MUX_SH));       // Templated

wire    [63:0] rev_scramb_dout;
wire    [63:0] scramb_dout_dat;
assign  scramb_dout_dat    =  scramb_dout[65:2];
reverse #(64) rev_scramb_dout_inst (.ENA       (1'b1), .IN     (scramb_dout[65:2]), .OUT       (rev_scramb_dout));

/* gb66_64
    * gearbox to downstep 66bit to 64bit interface for PMA
    * this is the bypass path for FEC
    */
/* gb66_64 AUTO_TEMPLATE (
        .CLK           (CLK219),
        .RST           (RST219),
    .P_BLK(scramb_dout[65:0]),
    .P_BLK_ENA(scramb_dout_en),
    .T_BLK (GB66_BLK[63:0]),
    );
    */
gb66_64
gb66_64_inst
(
        /*AUTOINST*/
        // Outputs
        .T_BLK                 (GB66_BLK[63:0]),        // Templated
        // Inputs
        .CLK           (CLK219),        // Templated
        .RST           (RST219),        // Templated
        .P_BLK                 (scramb_dout[65:0]),     // Templated
        .P_BLK_ENA             (scramb_dout_en));       // Templated


always @(posedge CLK219)
if (RST219)
        ENC_OUT_PMA_BLK <= 'h0;
else
        ENC_OUT_PMA_BLK <= CSR_ENC_INV_sync ? ~GB66_BLK[63:0] : GB66_BLK[63:0];



endmodule

// Local Variables:
// verilog-library-directories:("." "./data_mux/" "./pcs_out_sel/" "./pcs_scrambler/" "./encoder_fifo_in/" "./compressor" "../common/crc32_galois_d65" "../common/reverse" "../common/pn2112" "../common/gb65_64" "../common/gb66_64" "../common/regs")
// verilog-library-extensions:(".v" ".h")
// End:
