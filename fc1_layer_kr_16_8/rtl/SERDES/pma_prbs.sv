/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author$
* $Date$
* $Revision$
* $HeadURL$
* Description: PRBS generation and checking
***********************************************************************************************************/

module pma_prbs
(
        
        output  reg     [63:0]         tx_prbs,                 // 64b PRBS pattern to transmit
        output  reg     [15:0]         prbs_error_cnt,          // PRBS errors
        output  reg     [47:0]         prbs_bit_cnt,            // PRBS bits received
        output  reg     [15:0]         prbs_inj_err_cnt,        // PRBS inject error requests - tx clock domain
        output  reg     [31:0]         prbs_not_locked_cnt,     // cycles not locked but PRBS enabled
        output  reg     prbs_lock_state,                        // shift register containing last 64 values of prbs_locked
        input                      iSFP_LOS,
        input   [63:0]             rx_pma_parallel_data,        // 64b parallel data from receive
				input   [3:0]              data_rate,
        input   [1:0]              prbs_mode_rx,                // PRBS transmission mode, 00=off, 01=prbs7, 10=prbs31
        input   [1:0]              prbs_mode_tx,                // PRBS transmission mode, 00=off, 01=prbs7, 10=prbs31
        input   prbs_error_cnt_clr,             // clear prbs_error_cnt register
        input   prbs_error_cnt_clr_tx,          // clear prbs_inj_err_cnt register
        input   prbs_bit_cnt_clr,               // clear prbs_bit_cnt register
        input   prbs_not_locked_cnt_clr,        // clear prbs_not_locked_cnt register
        input   prbs_inj_error,                 // on assertion edge, randomly flips a bit. 
        
        input   rx_clk,
        input   tx_clk,
        input   rx_rst_n,
        input   tx_rst_n
        
);

`include "vi_defines.vh"
wire                                prbs7_en_tx;                   
wire                                prbs31_en_tx;                  
wire                                prbs7_en_rx;                   
wire                                prbs31_en_rx;                  
reg  [63:0]                         tx_prbs_premux;                
reg  [63:0]                         prbs_random_bit;               
wire                                prbs_en_tx;                    
wire                                prbs_en_rx;                    
reg  [3:0]                          prbs_lock_count;               
wire                                prbs_locked;                   
reg                                 rx_data_is_not_zero_d0;        
reg                                 rx_data_is_not_zero_d1;        
reg  [63:0]                         prbs_chk_err_vec;              
reg                                 prbs_chk_err;                  
wire [63:0]                         tx64_prbs7_gen;                  
wire [63:0]                         tx64_prbs31_gen;                 
wire [63:0]                         tx40_prbs7_gen;                  
wire [63:0]                         tx40_prbs31_gen;                 
wire [63:0]                         rx64_prbs7_chk_err;                 
wire [63:0]                         rx64_prbs31_chk_err;                
wire [63:0]                         rx40_prbs7_chk_err;                 
wire [63:0]                         rx40_prbs31_chk_err;                


// --------------------------
// 64bit PRBS TX - Generators
// --------------------------

prbs_parm #(.CHK_MODE  (0),
        .POLY_LENGTH   (7),
        .POLY_TAP      (6),
        .DWIDTH        (64))
prbs7_gen64_inst
(
        .iRST          (~tx_rst_n),
        .iCLK          (tx_clk),
        .iINVERT       (1'b0),                  // PRBS7 should NOT be inverted according to spec.
        .iDATA         (64'd0),
        .iEN           (1'b1),
        .oDATA         (tx64_prbs7_gen[63:0]));

prbs_parm #(.CHK_MODE  (0),
        .POLY_LENGTH   (31),
        .POLY_TAP      (28),
        .DWIDTH        (64))
prbs31_gen64_inst
(
        .iRST          (~tx_rst_n),
        .iCLK          (tx_clk),
        .iINVERT       (1'b1),                  // PRBS31 should be inverted according to spec.
        .iDATA         (64'd0),
        .iEN           (1'b1),
        .oDATA         (tx64_prbs31_gen[63:0]));

// --------------------------
// 40bit PRBS TX - Generators
// --------------------------

prbs_parm #(.CHK_MODE  (0),
        .POLY_LENGTH   (7),
        .POLY_TAP      (6),
        .DWIDTH        (40))
prbs7_gen40_inst
(
        .iRST          (~tx_rst_n),
        .iCLK          (tx_clk),
        .iINVERT       (1'b0),                  // PRBS7 should NOT be inverted according to spec.
        .iDATA         (64'd0),
        .iEN           (1'b1),
        .oDATA         (tx40_prbs7_gen[63:0]));

prbs_parm #(.CHK_MODE  (0),
        .POLY_LENGTH   (31),
        .POLY_TAP      (28),
        .DWIDTH        (40))
prbs31_gen40_inst
(
        .iRST          (~tx_rst_n),
        .iCLK          (tx_clk),
        .iINVERT       (1'b1),                  // PRBS31 should be inverted according to spec.
        .iDATA         (64'd0),
        .iEN           (1'b1),
        .oDATA         (tx40_prbs31_gen[63:0]));




assign  prbs7_en_tx    =  (prbs_mode_tx[1:0]==2'b01);
assign  prbs31_en_tx   =  (prbs_mode_tx[1:0]==2'b10);
assign  prbs7_en_rx    =  (prbs_mode_rx[1:0]==2'b01);
assign  prbs31_en_rx   =  (prbs_mode_rx[1:0]==2'b10);

always @(posedge tx_clk or negedge tx_rst_n) 
   if (!tx_rst_n)
        tx_prbs_premux[63:0] <= {64{1'b0}};
   else if (data_rate == 4'h4)  //16g mode
        tx_prbs_premux[63:0] <= prbs7_en_tx  ? tx64_prbs7_gen[63:0]  : tx64_prbs31_gen[63:0];
   else                         //8g/4g mode
        tx_prbs_premux[63:0] <= prbs7_en_tx  ? tx40_prbs7_gen[63:0]  : tx40_prbs31_gen[63:0];

/*lzhou
 * simplify error injection:
 * since output is serial, it does not matter which bit to corrupt.  Therefore
 * bit 0 is corrupted whenever prbs_inj_error is asserted
 */
always @(posedge tx_clk or negedge tx_rst_n) begin
        //prbs_random_bit[63:0] <= ~tx_rst_n ? 64'd1 :
        //{prbs_random_bit[62:0],prbs_random_bit[63]};
        prbs_inj_err_cnt[15:0] <= ~tx_rst_n              ? 16'd0 :
        prbs_error_cnt_clr_tx  ? 16'd0 :
        prbs_inj_error         ? (prbs_inj_err_cnt[15:0]+16'd1) :
        prbs_inj_err_cnt[15:0];
end
/*
genvar gi;
generate
for (gi=  0; gi<64; gi =  gi+1) begin : gen_prbs_inj_error
        always @(posedge tx_clk or negedge tx_rst_n) 
                tx_prbs[gi] <= ~tx_rst_n ? 1'b0 :
                (prbs_inj_error & prbs_random_bit[gi]) ? ~tx_prbs_premux[gi] :
                tx_prbs_premux[gi];
end
endgenerate
*/

always @(posedge tx_clk or negedge tx_rst_n) 
  if (!tx_rst_n)
		tx_prbs <= {64{1'b0}};
	else
		tx_prbs <= {tx_prbs_premux[63:1], prbs_inj_error ^ tx_prbs_premux[0]};


// --------------------------
// 64bit PRBS RX - Checkers
// --------------------------

prbs_parm #(.CHK_MODE  (1),
        .POLY_LENGTH   (7),
        .POLY_TAP      (6),
        .DWIDTH        (64))
prbs7_chk64_inst
(
        .iRST          (~rx_rst_n),
        .iCLK          (rx_clk),
        .iINVERT       (1'b0),                  // PRBS7 should NOT be inverted according to spec.
        .iDATA         (rx_pma_parallel_data[63:0]),
        .iEN           (1'b1),
        .oDATA         (rx64_prbs7_chk_err[63:0]));

prbs_parm #(.CHK_MODE  (1),
        .POLY_LENGTH   (31),
        .POLY_TAP      (28),
        .DWIDTH        (64))
prbs31_chk64_inst
(
        .iRST          (~rx_rst_n),
        .iCLK          (rx_clk),
        .iINVERT       (1'b1),                  // PRBS31 should be inverted according to spec.
        .iDATA         (rx_pma_parallel_data[63:0]),
        .iEN           (1'b1),
        .oDATA         (rx64_prbs31_chk_err[63:0]));


// --------------------------
// 40bit PRBS RX - Checkers
// --------------------------

prbs_parm #(.CHK_MODE  (1),
        .POLY_LENGTH   (7),
        .POLY_TAP      (6),
        .DWIDTH        (40))
prbs7_chk40_inst
(
        .iRST          (~rx_rst_n),
        .iCLK          (rx_clk),
        .iINVERT       (1'b0),                  // PRBS7 should NOT be inverted according to spec.
        .iDATA         (rx_pma_parallel_data[63:0]),
        .iEN           (1'b1),
        .oDATA         (rx40_prbs7_chk_err[63:0]));

prbs_parm #(.CHK_MODE  (1),
        .POLY_LENGTH   (31),
        .POLY_TAP      (28),
        .DWIDTH        (40))
prbs31_chk40_inst
(
        .iRST          (~rx_rst_n),
        .iCLK          (rx_clk),
        .iINVERT       (1'b1),                  // PRBS31 should be inverted according to spec.
        .iDATA         (rx_pma_parallel_data[63:0]),
        .iEN           (1'b1),
        .oDATA         (rx40_prbs31_chk_err[63:0]));




assign  prbs_en_tx     =  (prbs7_en_tx | prbs31_en_tx);
assign  prbs_en_rx     =  (prbs7_en_rx | prbs31_en_rx);

always @(posedge rx_clk or negedge rx_rst_n) 
        prbs_lock_count[3:0] <= ~rx_rst_n       ? 4'd0 :
        prbs_chk_err ? 4'd0 :
        (prbs_en_rx & ~prbs_chk_err & rx_data_is_not_zero_d1 & 
        (prbs_lock_count[3:0]!=4'hf)) ? (prbs_lock_count[3:0]+4'd1) :
        prbs_lock_count[3:0];

assign  prbs_locked    =  prbs_lock_count[3];

always @(posedge rx_clk or negedge rx_rst_n) begin
        rx_data_is_not_zero_d0  <= ~rx_rst_n                     ? 1'b0  : (rx_pma_parallel_data[63:0]!=64'd0) && ~iSFP_LOS;
        rx_data_is_not_zero_d1  <= ~rx_rst_n                     ? 1'b0  : rx_data_is_not_zero_d0;
        prbs_chk_err            <= ~rx_rst_n                     ? 1'b0  : |prbs_chk_err_vec[63:0];
        prbs_lock_state         <= ~rx_rst_n                     ? 1'd0  : prbs_locked;
        prbs_error_cnt[15:0]    <= ~rx_rst_n                     ? 16'd0 :
        prbs_error_cnt_clr            ? 16'd0 : 
        (prbs_chk_err & prbs_locked & (prbs_error_cnt[15:0]!=`MAX_VALUE_16)) ? 
        (prbs_error_cnt[15:0] + 16'd1) : prbs_error_cnt[15:0];
        prbs_bit_cnt[47:0]      <= ~rx_rst_n                     ? 48'd0 :
        prbs_bit_cnt_clr              ? 48'd0 :
        (prbs_locked & (prbs_bit_cnt[47:0]!=`MAX_VALUE_48)) ? 
        (prbs_bit_cnt[47:0] + 48'd1) : prbs_bit_cnt[47:0];
        prbs_not_locked_cnt[31:0] <= ~rx_rst_n                     ? 32'd0 :
        prbs_not_locked_cnt_clr       ? 32'd0 :
        (~prbs_locked & (prbs_not_locked_cnt[31:0]!=`MAX_VALUE_32) & prbs_en_rx) ? 
        (prbs_not_locked_cnt[31:0] + 32'd1) : prbs_not_locked_cnt[31:0];
end

always @(posedge rx_clk or negedge rx_rst_n) begin
  if (!rx_rst_n)
        prbs_chk_err_vec[63:0]  <= {64{1'b0}};
  else if (data_rate == 4'h4)
        prbs_chk_err_vec[63:0]  <= prbs7_en_rx  ? rx64_prbs7_chk_err[63:0] :rx64_prbs31_chk_err[63:0];
  else
        prbs_chk_err_vec[63:0]  <= {{24{1'b0}}, prbs7_en_rx  ? rx40_prbs7_chk_err[39:0] :rx40_prbs31_chk_err[39:0]};
end

// ----------------------
// Assertions
// ----------------------

// synthesis translate_off

// synthesis translate_on

endmodule

// Local Variables:
// verilog-library-directories:("." "../../../lib" "../../stratixv/s5_sfifo_42bx8")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:

