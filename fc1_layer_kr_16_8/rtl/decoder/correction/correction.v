/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: leon.zhou $
* $Date: 2014-04-09 14:34:07 -0700 (Wed, 09 Apr 2014) $
* $Revision: 5183 $
* Description:
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
*
***************************************************************************/


module correction (
	input   CLK,
	input   RST,
	input   FEC_LOCK,
	input   T_BLK_ENA,
	input   [64:0] T_BLK,
	
	input   CORR_VAL,
	input   [64:0] CORR_VECTOR,
	input   [9:0] CARRY_VECTOR,
	
	output  reg     C_BLK_ENA,
	output  reg     [64:0] C_BLK,
	output  reg CSR_STAT_FEC_LOCK
);

/* Write controller 
	 * This machine is active only after FEC_LOCK
	 * At this point, wait for a new T-block to show up
	 * Start writing into the FIFO until losing FEC_LOCK
	 * T-BLK and its CRC are written into the FIFO.  The
	 * CRC cycle is not really used, the read side should
	 * drop it. 
	 */

localparam WIDTH_W_SM  =  2;
localparam W_SM_IDLE   =  0;
localparam W_SM_INIT   =  1;
localparam W_SM_NORM   =  2;

reg     [WIDTH_W_SM-1:0] w_sm_s, w_sm_ns;
wire    wr_en_t_blk;

always @(posedge CLK)
if (RST)
	w_sm_s <= W_SM_IDLE;
else
	w_sm_s <= w_sm_ns;

always @(*)
begin
	w_sm_ns        =  w_sm_s;
	case (w_sm_s)
	W_SM_IDLE : if (FEC_LOCK) w_sm_ns  =  W_SM_INIT;
	W_SM_INIT : if (!T_BLK_ENA) w_sm_ns    =  W_SM_NORM;
	W_SM_NORM : if (!FEC_LOCK) w_sm_ns     =  W_SM_IDLE;
	default : w_sm_ns = W_SM_IDLE;
	endcase
end

assign  wr_en_t_blk    =  w_sm_s==W_SM_NORM;



/* Latency tracker
	 * It takes 1 FEC block + N cycles for the machine to calculate correction
	 * value.  Once synchronized, the period is static until losing FEC_LOCK.
	 * Read occurs every 32/33 cycles.
	 */
localparam LATENCY     =  37;

reg     [5:0] latency_cnt;
reg     rd_en_t_blk, rd_en_t_blk_r;

always @(posedge CLK)
if (RST || !FEC_LOCK)
	latency_cnt <= 'h0;
else if ((latency_cnt != LATENCY) && wr_en_t_blk)
	latency_cnt <= latency_cnt + 1;

always @(posedge CLK)
if (RST)
begin
	rd_en_t_blk <= 1'b0;
	rd_en_t_blk_r <= 1'b0;
	CSR_STAT_FEC_LOCK <= 1'b0;
end
else
begin
	rd_en_t_blk <= latency_cnt == LATENCY;
	rd_en_t_blk_r <= rd_en_t_blk;
  CSR_STAT_FEC_LOCK <= rd_en_t_blk_r;	
end


/* Read valid
	 * Once "read_rdy" state is reached, this machine starts reading out of the
	 * FIFO continuously. It needs to drop 1 CRC cycle for every 32 blocks that
	 * it reads.  It is implemented this way to make the rd/wr machine a bit
	 * simpler.  Hit on FIFO depth is 1 cycle, which will not affect anything,
	 * since the FIFO is expected to be somewhere around 2/3 full only anyway.
	 *
	 * This machine is synchronized to the data stream via the LATENCY
	 * parameter.
	 */

reg     [5:0] rd_val_cnt;

always @(posedge CLK)
if (RST)
	rd_val_cnt <= 'h0;
else if (rd_val_cnt[5])
	rd_val_cnt <= 'h0;
else if (rd_en_t_blk)
	rd_val_cnt <= rd_val_cnt + 1;


/*FEC is capable of 11-bit burst correction over FEC frame. 
 * If a correction is already applied, then the rest of the frame should be assumed to be 
 * uncorrectable regardless of whether bits are corrupted or not. 
 * corr_flag_s denotes that a correction cycle 2 clocks ago.  When this signal
 * is asserted, no correction should take place.  When corr_flag is asserted
 * but not corr_flag_s, then correction based on CARRY can still take place.
 */

reg corr_flag, corr_flag_s;
wire crc_cycle;

assign crc_cycle = ~|rd_val_cnt;

always @(posedge CLK)
if (RST || crc_cycle)
begin
	corr_flag <= 1'b0;
	corr_flag_s <= 1'b0;
end
else
begin
	corr_flag <= corr_flag || CORR_VAL;
	corr_flag_s <= corr_flag;
end


/* Data buffer
	 * It is synchronously flushed at !FEC_LOCK
	 */
wire    [64:0] t_blk;


wire                  almost_full;
wire                  almost_empty;
wire                  underflow;
wire                  wr_rst_busy;
wire                  rd_rst_busy;
wire                  overflow;
corr_buff corr_buff_inst (
 . almost_full          ( almost_full                                        ), // output
 . almost_empty         ( almost_empty                                       ), // output
 . underflow            ( underflow                                          ), // output
 . wr_rst_busy          ( wr_rst_busy                                        ), // output
 . rd_rst_busy          ( rd_rst_busy                                        ), // output
 . overflow             ( overflow                                           ), // output
 . din                  ( T_BLK                                              ), 
 . full                 (                                                    ), 
 . dout                 ( t_blk                                              ), 
 . data_count           (                                                    ), 
 . clk                  ( CLK                                                ), 
 . wr_en                ( wr_en_t_blk                                        ), 
 . rd_en                ( rd_en_t_blk                                        ), 
 . rst                  ( !FEC_LOCK                                          ), 
 . empty                (                                                    )  
);


/* C_BLK output
	 * Correction happens here...
	 * The correction vector are carry vector are always consistent that they
	 * will not conflict w/ each other.  In other words, they will not try to
	 * correct the same bits.  (However, it is worthwhile to check this claim)
	 * Also, both vectors are zero when there is nothing to correct.  So, the
	 * CORR_VAL bit is really redundant and should just be used to signal
	 * correction events.
	 * CORR_CARRY needs to be flopped 1 cycle to correct the next cycle.  There
	 * should not be any carry hanging off the last cycle.  This is probably
	 * a good corner case.
	 */
reg     [9:0] carry_s;
always @(posedge CLK)
if (RST)
	carry_s <= 'h0;
else
	carry_s <= CARRY_VECTOR;

always @(posedge CLK)
if (RST)
begin
	C_BLK <= 'h0;
	C_BLK_ENA <= 'h0;
end
else if (corr_flag && corr_flag_s)  // already corrected burst error once in FEC word, now just drive as-is
begin
	C_BLK <= t_blk;
	C_BLK_ENA <= ~crc_cycle;
end
else if (corr_flag && !corr_flag_s)  // already corrected burst error once in FEC word, now just drive as-is
begin
	C_BLK <= t_blk ^ {carry_s, {55{1'b0}}};
	C_BLK_ENA <= ~crc_cycle;
end
else  // apply correction
begin
	C_BLK <= t_blk ^ CORR_VECTOR ^ {carry_s, {55{1'b0}}};
	C_BLK_ENA <= ~crc_cycle;
end

endmodule
