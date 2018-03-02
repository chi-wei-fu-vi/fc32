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

// auto_wire_reg ignore CH
module txbist72b_gen #(
  parameter                            CH                             = 0,
  parameter                            EMERALD                        = 0,
  parameter                            DOMINICA                       = 0,
  parameter                            BALI                           = 1,
  parameter                            REPEAT_OP_CODE                 = 8'h55 
) (
        
  // --------------------------
  // Control Settings
  // --------------------------
  input        [3:0]                          linkspeed,

  input        [63:0]                         oREG_TXBIST_WR_DATA,           //  write data to transmit RAM. bottom 32b is data. Upper 4b indicates
  // K-code (=1) or D-code (=0). Shared between both RAMS.

  input        [13:0]                         oREG_TXBIST_RD_ADDR,           //  transmit RAM read address, loaded on assertion of cr_ram_rd_en_edge,

  input                                       cr_ram_rd_en_edge,             //  pulse used to launch transmit RAM read using txbist_rd_addr. Data
  // is returned out on txbist_rd_data. txbist_rd_addr must be stable
  // when rd_en_edge is asserted.

  input        [13:0]                         oREG_TXBIST_WR_ADDR,           //  transmit RAN write address. loaded on assertion of cr_ram_wr_addr_ld.

  input                                       oREG_TXBIST_CTL_CONTROL_SPACE, //  1: Perform control data operation, 0: Perform data data operation
  input                                       oREG_TXBIST_CTL_BISTOUT_EN,    //  1: enable output, 0: disable output

  input                                       cr_ram_wr_en_edge,             //  pulse used as write enable to RAMs. On pulse, data from cr_ram_wr_data[35:0]
  // will be written into the transmit RAM. At the end of the write, the
  // write address register is auto incremented.

  input                                       cr_ram_wr_addr_ld,             //  load the value on cr_ram_wr_addr into the transmit write write address
  // asserted on write to txbist RAM by SW.

  input        [63:0]                         oREG_TXBIST_REG_PRIMITIVE,     //  4 symbol primitive register. upper 4b indicates K-code (=1) or D-code (=0).
  // specifies the ordered set to be transmitted when BIST transmit mode is set to
  // continuous transmission from register.

  input        [63:0]                         oREG_TXBIST_IDLE_PRIMITIVE,    //  4 symbol primitive register. upper 4b indicates K-code (=1) or D-code (=0).
  // specifies the IDLE primitive to be used between frames - duration is
  // specified thorugh ipg_min/offset registers.

  input        [2:0]                          oREG_TXBIST_CTL_MODE,          //  BIST transmit mode:
  //    000 - disabled
  //    001 - from RAM, continuous, IPG specified by ipg_min/offset
  //    010 - from register, continuous
  //    011 - reserved
  //    1xx - reserved

  input                                       oREG_TXBIST_CTL_FEC_MODE,      //  loop 1st FEC frame
  input                                       oREG_TXBIST_CTL_SYNC_START,
  input                                       global_sync,
  input        [15:0]                         oREG_TXBIST_IPG_MIN,           //  IPG min size, in 4B quantities. The IDLE primitive is specified by the
  // cr_idle_prim[35:0] register. IDLES are inserted at the end of the
  // last frame in the txbist RAM.

  input        [3:0]                          oREG_TXBIST_IPG_OFFSET,        //  IPG max offset (in 4B quantities). The offset value is (2^ipg_offset)-1.
  // For example, an ipg_offset=3 would result in a max offset up to 7. The
  // offset value is randomized up to the max value, and added to ipg_min to
  // determine the IPG length. A value of 0 creates a fixed IPG length
  // determined by ipg_min.

  input                                       oREG_TXBIST_CTL_10B_ERR_INJ,   //  Writing this bit to 1 injects an invalid 10b code into the next transmitted
  // word

  input                                       oREG_TXBIST_CTL_INTERVAL_SYNC_EN, //  Setting this bit to 1 instructs the transmit unit to delay transmission until
  // the next interval stats pulse. On the interval stats pulse, tranmission starts
  // and continues based on txbist control mode settings.

  input        [13:0]                         oREG_TXBIST_RAM_END,           //  pointer to last valid double word in RAM. During transmit from the RAM,
  // the bist engine will dispatch from address 0 to cr_ram_end[13:0].

  input        [31:0]                         oREG_TXBIST_LOOP_CNT,          //  number of times to transmit from RAM. Min value is 1. After completing
  // transmission, the bist engine will transmit IDLEs specified by cr_idle_prim.

  input                                       oREG_TXBIST_CTL_CRC_ERR_INJ,   //  HW performs an edge detect on this signal. On the rising edge, a payload
  // CRC error is injected into the next frame.

  input                                       oREG_TXBIST_CTL_CRC_AUTO_EN,   //  enables HW calculation of payload CRC during transmission from RAM. The
  // location of the CRC field is determined by the bist engine by SOF/EOF decoding

  output reg   [63:0]                         iREG_TXBIST_RD_DATA,           //  read data from txbist RAM.

  output reg                                  iREG_TXBIST_CRC_ERR_INJ_CNT_EN, //  increment count register

  output reg                                  iREG_TXBIST_TX_FRAME_CNT_EN,   //  increment count register

  output reg                                  iREG_TXBIST_TX_PRIM_CNT_EN,    //  increment count register


  //-----------------
  // Clocks and Reset
  //------------------

  input                                       rst_n,                         //  asynchronous reset, active low
  input                                       rst,                           //  asynchronous reset, active high
  input                                       clk,                           //  core clock, 212.5Mhz


  //-----------------
  // TX BIST Interface
  //------------------

  input                                       end_of_interval,
  output reg                                  txbist_data_val,               //  txbist data is valid
  output reg   [71:0]                         txbist_data                    //  40b 10b encoded transmit to crossbar
        
        
);

   import vi_defines_pkg::*;



localparam TXBIST_PRIM_MODE    =  3'b010;
localparam TXBIST_RAM_LOOP_MODE    =  3'b001;

localparam FEC_END = 13'd31; 

typedef enum bit[3:0] {
        SM_TXBIST_IDLE     =  4'h0,
        SM_TXBIST_PRIM     =  4'h1,
        SM_TXBIST_RAM_START    =  4'h2,
        SM_TXBIST_RAM_TRANSMIT =  4'h3,
        SM_TXBIST_RAM_REPEAT   =  4'h7,
        SM_TXBIST_RAM_END      =  4'h4,
        SM_TXBIST_RAM_IPG      =  4'h5,
        SM_TXBIST_RAM_IDLE     =  4'h6,
        SM_TXBIST_WAIT_16G     =  4'h8
				
} stateType;
stateType        sm_txbist_state;

logic [13:0]       ram_rd_addr, ram_rd_addr_next;
logic         ram_rd_en, ram_rd_val, ram_rd_val_p0, ram_rd_val_p1, ram_rd_val_p2, ram_rd_val_p3, ram_rd_val_p4, ram_rd_val_p5;
logic [13:0]       ram_wr_addr;
logic [71:0]       ram_rd_data, ram_rd_data_p0, ram_rd_data_p1, ram_rd_data_p2, ram_rd_data_p3, ram_rd_data_p4, ram_rd_data_p5;


logic [15:0]       ipg_count;
logic [15:0]       ipg_length;
logic [15:0]       ipg_length_d;

logic [3:0]       rdcomb;
logic [7:0]       txbist_8b_ctl;
logic [3:0]       txbist_8b_ctl_q1;
logic [3:0]       txbist_8b_ctl_q2;

logic [31:0]       crc32_data_in;
logic [31:0]       crc32_final;
logic [31:0]       crc32_in;
logic [31:0]       crc32_in_q;
logic [31:0]       crc32_out;
logic [31:0]       crc32_tx;
logic [31:0]       eof_final;
logic [31:0]       eof_n_final;
logic [31:0]       eof_p_final;

logic [31:0]       lfsr32;
logic [31:0]       ram_loop_cnt;
logic [31:0]       shift32;

logic [63:0]       txbist_8b_data;
logic [31:0]       txbist_8b_data_q1;
logic [31:0]       txbist_8b_data_q2;
logic [39:0]       txbist_data_d;
logic [8:0]       ram_wr_byteen;
logic         crc_en;
logic         cr_ram_rd_en_edge_q;
logic         cr_ram_rd_en_edge_qq;
logic         eof;
logic         eof_a;
logic         eof_dt;
logic         eof_dti;
logic         eof_f;
logic         eof_n;
logic         eof_ni;
logic         eof_q;
logic         eof_rt;
logic         eof_rti;
logic         force_rd_negative;
logic         prim_mode;
logic         ram_cont_mode;
logic         ram_loop_mode;
logic         reg_txbist_ctl_10b_err_inj;
logic         sof;
logic         txbist_active;
logic         txbist_active_d0;
logic         txbist_active_d1;
logic         txbist_active_d2;
logic         txbist_active_d3;
logic         txbist_active_d4;
logic         txbist_active_d5;
logic         txbist_active_d6;
logic         txbist_crc_err_inj_sticky;
logic         txbist_ctl_10b_err_inj;
logic         txbist_from_ram;
logic         txbist_from_ram_q;
logic         txbist_from_ram_qq;
logic         txbist_in_idle;
logic         txbist_in_ram_end;
logic         txbist_in_ram_start;
logic         tx_ipg_done;
logic         tx_last_loop;
logic         tx_ram_at_end;

logic repeat_en;
logic [31:0] repeat_count;
logic [31:0] repeat_count_max;
logic repeat_inst, repeat_inst_s, repeat_inst_r;

logic txbist_data_val_int;        // txbist data is valid
logic [71:0] txbist_data_int;        // 40b 10b encoded transmit to crossbar
logic loop_dec;
logic ram_end;
// ----------

logic [5:0] fifo_val_cnt;
logic skip_16g;
logic skip_16g_qualify;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    fifo_val_cnt <= 'h0;
  else if (fifo_val_cnt[5])
    fifo_val_cnt <= 'h0;
  else
    fifo_val_cnt <= fifo_val_cnt + 1;

always @(posedge clk or negedge rst_n)
  skip_16g <= ~rst_n ? 1'b0 : fifo_val_cnt[5] && linkspeed[2];

// Decode
// ----------

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
        prim_mode  <= (oREG_TXBIST_CTL_MODE[2:0]==TXBIST_PRIM_MODE);
        ram_loop_mode <= (oREG_TXBIST_CTL_MODE[2:0]==TXBIST_RAM_LOOP_MODE) & (oREG_TXBIST_LOOP_CNT[31:0]!=32'd0);
        ram_cont_mode <= (oREG_TXBIST_CTL_MODE[2:0]==TXBIST_RAM_LOOP_MODE) & (oREG_TXBIST_LOOP_CNT[31:0]==32'd0);
        txbist_active <= (prim_mode | ram_loop_mode | ram_cont_mode) & (oREG_TXBIST_CTL_SYNC_START == global_sync);
        ram_wr_byteen <= oREG_TXBIST_CTL_CONTROL_SPACE ? 9'h100 : 9'h0FF;
end
else
begin
        prim_mode  <= (oREG_TXBIST_CTL_MODE[2:0]==TXBIST_PRIM_MODE);
        ram_loop_mode <= (oREG_TXBIST_CTL_MODE[2:0]==TXBIST_RAM_LOOP_MODE) & (oREG_TXBIST_LOOP_CNT[31:0]!=32'd0);
        ram_cont_mode <= (oREG_TXBIST_CTL_MODE[2:0]==TXBIST_RAM_LOOP_MODE) & (oREG_TXBIST_LOOP_CNT[31:0]==32'd0);
        txbist_active <= (prim_mode | ram_loop_mode | ram_cont_mode) & (oREG_TXBIST_CTL_SYNC_START == global_sync);
        ram_wr_byteen <= oREG_TXBIST_CTL_CONTROL_SPACE ? 9'h100 : 9'h0FF;
end


// -------------
// State Machine
// -------------


always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
                sm_txbist_state <= SM_TXBIST_IDLE;
        else
					if (!(skip_16g & skip_16g_qualify))
                case (sm_txbist_state)
                
                // IDLE - wait to transmit
                SM_TXBIST_IDLE :
        if ( ((oREG_TXBIST_CTL_INTERVAL_SYNC_EN & end_of_interval) | ~oREG_TXBIST_CTL_INTERVAL_SYNC_EN) 
             & txbist_active
           ) 
            begin
                if (prim_mode) 
                        sm_txbist_state <= SM_TXBIST_PRIM;
                else if (ram_loop_mode | ram_cont_mode)
									//if (linkspeed[2])
                        //sm_txbist_state <= SM_TXBIST_WAIT_16G;
									//else
                        sm_txbist_state <= SM_TXBIST_RAM_START;
        end
        
                // PRIM mode - continue transmitting until done
        SM_TXBIST_PRIM : 
        if (~prim_mode) sm_txbist_state <= SM_TXBIST_IDLE;
        
                // RAM mode start - zero read address
        //SM_TXBIST_WAIT_16G : 
				//if ((skip_16g & skip_16g_qualify))  // align w/ regular beat in 16G.  Ignore beat in 8/4g
          //sm_txbist_state <= SM_TXBIST_RAM_TRANSMIT;
        
        SM_TXBIST_RAM_START : 
          sm_txbist_state <= SM_TXBIST_RAM_TRANSMIT;

                // RAM mode transmit - transmit frame
        SM_TXBIST_RAM_TRANSMIT : 
        if ( (!(ram_loop_mode || ram_cont_mode) && ram_end) || (loop_dec && tx_last_loop && ram_loop_mode))
            sm_txbist_state <= SM_TXBIST_RAM_IDLE;
        else if (repeat_inst) sm_txbist_state <= SM_TXBIST_RAM_REPEAT;
        
        SM_TXBIST_RAM_REPEAT :
        if (!repeat_en) sm_txbist_state <= SM_TXBIST_RAM_TRANSMIT; 
        
                // RAM mode idle - transmit idles
        SM_TXBIST_RAM_IDLE : 
        if (!(ram_loop_mode || ram_cont_mode)) sm_txbist_state <= SM_TXBIST_IDLE;
        
        default :
        sm_txbist_state[3:0] <= SM_TXBIST_IDLE;
        
        endcase
end


always @(posedge clk or negedge rst_n)
if (!rst_n)
        ram_end <= 1'b0;
else if (sm_txbist_state == SM_TXBIST_RAM_TRANSMIT)
        ram_end <= ram_rd_addr_next >= oREG_TXBIST_RAM_END;

//===============loop count

always @(posedge clk or negedge rst_n)
if (!rst_n)
        loop_dec <= 1'b0;
else if (sm_txbist_state == SM_TXBIST_RAM_TRANSMIT)
        loop_dec <= ram_rd_addr_next >= oREG_TXBIST_RAM_END && |ram_loop_cnt;

always @(posedge clk or negedge rst_n)
if (!rst_n)
        tx_last_loop <= 1'b0;
else
        tx_last_loop <= ram_loop_cnt == 'h1;


always @(posedge clk or negedge rst_n)
if (!rst_n)
        ram_loop_cnt <= 'h0;
else if (ram_loop_mode && sm_txbist_state == SM_TXBIST_IDLE)
        ram_loop_cnt <= oREG_TXBIST_LOOP_CNT;
else if (loop_dec)
        ram_loop_cnt <= ram_loop_cnt - 1;

//===RAM RAM RAM===============================


always @(posedge clk or negedge rst_n)
if (!rst_n)
        ram_wr_addr <= 'h0;
else if (cr_ram_wr_addr_ld)
        ram_wr_addr <= oREG_TXBIST_WR_ADDR;
else if (cr_ram_wr_en_edge)
        ram_wr_addr <= ram_wr_addr + 1;


// current RAM addr. 00 in rst. preload addr in start. nxt addr in txmit.
always @(posedge clk or negedge rst_n)
if (!rst_n)
        ram_rd_addr <= 'h0;
else if (cr_ram_rd_en_edge)
        ram_rd_addr <= oREG_TXBIST_RD_ADDR;
else if (sm_txbist_state == SM_TXBIST_RAM_START)
        ram_rd_addr <= 'h0;
else 
        ram_rd_addr <= ram_rd_addr_next;

// addr increment w/ enable for loop support
always @(*)
begin
        ram_rd_addr_next       =  ram_rd_addr;
        if (ram_rd_en)
        if ((ram_rd_addr >= oREG_TXBIST_RAM_END) ||
         (oREG_TXBIST_CTL_FEC_MODE && (ram_rd_addr == FEC_END))
         )
                ram_rd_addr_next   =  'h0;
        else
                ram_rd_addr_next   =  ram_rd_addr + 1;
end

// FIFO FIFO FIFO

logic [3:0] fifo_usedw;
logic       fifo_rd_req;
logic       fifo_rd_val;
logic [71:0] fifo_dword;
logic        fifo_empty, fifo_empty_r;

always @(posedge clk or negedge rst_n)
if (!rst_n)
        ram_rd_en <= 1'b0;
else if ((sm_txbist_state == SM_TXBIST_RAM_TRANSMIT) || (sm_txbist_state == SM_TXBIST_RAM_START))
        ram_rd_en <= ~fifo_usedw[3] && !(loop_dec && tx_last_loop && ram_loop_mode);
else
        ram_rd_en <= 1'b0;

//data valid generated based on rd enable 
always @(posedge clk or negedge rst_n)
if (!rst_n)
        ram_rd_val <= 'h0;
else
        ram_rd_val <= ram_rd_en;

generate
if (CH==0) begin : gen_s5_ram1w1r1c_16kx72b_ch0

wire               rsta_busy;
wire               rstb_busy;
s5_ram1w1r1c_16kx72b_ch0 s5_ram1w1r1c_16kx72b_ch0_inst (
 . rsta_busy            ( rsta_busy                                          ), // output
 . rstb_busy            ( rstb_busy                                          ), // output
 . rstb                 ( rst                                                ), // input
 . wea                  ( cr_ram_wr_en_edge ? ram_wr_byteen[8:0] : 0         ), // input [8:0]
 . clka                 ( clk                                                ), // input
 . clkb                 ( clk                                                ), // input
 . dina                 ( { oREG_TXBIST_WR_DATA[7:0], oREG_TXBIST_WR_DATA[63:0] } ), // input [71:0]
 . addrb                ( ram_rd_addr[13:0]                                  ), // input [10:0]
 . addra                ( ram_wr_addr[13:0]                                  ), // input [10:0]
 //. wea                  ( cr_ram_wr_en_edge                                  ), // input fixme 1 vs 9
 . doutb                ( ram_rd_data[71:0]                                  )  
);

end
else begin : gen_s5_ram1w1r1c_16kx72b_ch1

wire                  rsta_busy;
wire                  rstb_busy;
s5_ram1w1r1c_16kx72b_ch1 s5_ram1w1r1c_16kx72b_ch1_inst (
 . rsta_busy            ( rsta_busy                                          ), // output
 . rstb_busy            ( rstb_busy                                          ), // output
 . rstb                 ( rst                                                ), // input
 . wea                  ( cr_ram_wr_en_edge ? ram_wr_byteen[8:0] : 0         ), // input [8:0]
 . clka                 ( clk                                                ), // input
 . clkb                 ( clk                                                ), // input
 . dina                 ( { oREG_TXBIST_WR_DATA[7:0], oREG_TXBIST_WR_DATA[63:0] } ), // input [71:0]
 . addra                ( ram_wr_addr[13:0]                                  ), // input [10:0]
 //. wea                  ( cr_ram_wr_en_edge                                  ), // input fixme 1 vs 9
 . addrb                ( ram_rd_addr[13:0]                                  ), // input [10:0]
 . doutb                ( ram_rd_data[71:0]                                  )  
);

end
endgenerate

// --------
// Stats
// --------
assign  iREG_TXBIST_TX_FRAME_CNT_EN    =  eof;         // defeatured.
assign  iREG_TXBIST_TX_PRIM_CNT_EN     =  (sm_txbist_state[3:0]==SM_TXBIST_PRIM);
assign  iREG_TXBIST_CRC_ERR_INJ_CNT_EN =  oREG_TXBIST_CTL_CRC_ERR_INJ;



always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
        ram_rd_data_p0 <= 72'h0;
        ram_rd_val_p0 <= 1'b0;
end
else
begin
        ram_rd_data_p0 <= ram_rd_data;
        ram_rd_val_p0 <= ram_rd_val;
end


wire                  fifo_almost_empty;
logic                 fifo_rst = 0;  // fixme
wire                  fifo_overflow;
wire                  fifo_almost_full;
wire                  fifo_underflow;
alt_fifo_sync_72_72 data_fifo (
 . almost_empty         ( fifo_almost_empty                                  ), // output
 . rst                  ( fifo_rst                                           ), // input
 . overflow             ( fifo_overflow                                      ), // output
 . almost_full          ( fifo_almost_full                                   ), // output
 . underflow            ( fifo_underflow                                     ), // output
 . din                  ( ram_rd_data_p0                                     ), 
 . full                 (                                                    ), 
 . dout                 ( fifo_dword                                         ), 
 . data_count           ( fifo_usedw                                         ), 
 . clk                  ( clk                                                ), 
 . wr_en                ( ram_rd_val_p0                                      ), 
 . rd_en                ( fifo_rd_req                                        ), 
 . empty                ( fifo_empty                                         )  
);



always @(posedge clk or negedge rst_n)
if (!rst_n)
        fifo_empty_r <= 1'b1;
else
        fifo_empty_r <= fifo_empty;
        
//data valid
always @(posedge clk or negedge rst_n)
if (!rst_n)
        fifo_rd_val <= 'h0;
else
        fifo_rd_val <= fifo_rd_req;

assign  fifo_rd_req    =  ((!repeat_inst && !fifo_empty && (sm_txbist_state != SM_TXBIST_RAM_REPEAT)) ||
        ((sm_txbist_state == SM_TXBIST_RAM_REPEAT) && !repeat_en))
        && !(skip_16g & skip_16g_qualify);  // 16G skip 1 cycle for every 32 cycles to account for 66/64 difference



//============== REPEAT support  Min repeat by 8

logic [71:0] repeat_dword;

assign  repeat_inst    =  fifo_rd_val && (fifo_dword[71:64] == REPEAT_OP_CODE);

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
        repeat_count <= 'h0;
end
else if (repeat_inst)
begin
        repeat_count <= fifo_dword[31:0] - 2;
end
else if (|repeat_count && !(skip_16g & skip_16g_qualify))
begin
        repeat_count <= repeat_count - 1;
end

always @(posedge clk or negedge rst_n)
if (!rst_n)
        repeat_en <= 1'b0;
else if ((skip_16g & skip_16g_qualify))
        repeat_en <= repeat_en;
else
        repeat_en <= repeat_inst || repeat_count > 1;


always @(posedge clk or negedge rst_n)
if (!rst_n)
        repeat_dword <= 72'h0;
else if ((sm_txbist_state == SM_TXBIST_RAM_TRANSMIT) && !repeat_inst)
        repeat_dword <= fifo_dword;

// Emerald specific here :
// =======================================================
generate 
if (EMERALD == 1) begin : gen_emerald

assign skip_16g_qualify = 0;
always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
        txbist_data <= 'h0;
        txbist_data_val <= 1'b0;
end
else if (txbist_data_val_int)
begin
        txbist_data <= txbist_data_int;
        txbist_data_val <= txbist_data_val_int;
end
else
begin
        txbist_data <= {8'hff, 64'h0707_0707_0707_0707};
        txbist_data_val <= 1'b1;
end



//OUTPUT machine
always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
        txbist_data_int <= {8'hff, 64'h0707_0707_0707_0707};
        txbist_data_val_int <= 1'b0;
end
else if (sm_txbist_state == SM_TXBIST_PRIM)
begin
        txbist_data_int <=  {8'hff, oREG_TXBIST_REG_PRIMITIVE[63:0]};
        txbist_data_val_int <= 1'b1;
end
else if ((sm_txbist_state == SM_TXBIST_RAM_REPEAT) || (repeat_inst && sm_txbist_state != SM_TXBIST_RAM_IDLE))
begin
        txbist_data_int <=  repeat_dword;
        txbist_data_val_int <= 1'b1;
end
else if (~fifo_empty_r)
begin
        txbist_data_int <=  fifo_dword;
        txbist_data_val_int <= fifo_rd_val;
end
else   // transfer IDLE by default
begin
        txbist_data_int <= {8'hff, oREG_TXBIST_IDLE_PRIMITIVE};
        txbist_data_val_int <= 1'b1;
end

// Frame count

assign txbist_8b_ctl = txbist_data_int[71:64];
assign txbist_8b_data = txbist_data_int[63:0];

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    eof <= 1'b0;
  else
    eof     <= {txbist_8b_ctl[0],txbist_8b_data[0  +:8]} == 9'h1_fd ||
               {txbist_8b_ctl[1],txbist_8b_data[8  +:8]} == 9'h1_fd ||
               {txbist_8b_ctl[2],txbist_8b_data[16 +:8]} == 9'h1_fd ||
               {txbist_8b_ctl[3],txbist_8b_data[24 +:8]} == 9'h1_fd ||
               {txbist_8b_ctl[4],txbist_8b_data[32 +:8]} == 9'h1_fd ||
               {txbist_8b_ctl[5],txbist_8b_data[40 +:8]} == 9'h1_fd ||
               {txbist_8b_ctl[6],txbist_8b_data[48 +:8]} == 9'h1_fd ||
               {txbist_8b_ctl[7],txbist_8b_data[56 +:8]} == 9'h1_fd;

end : gen_emerald
endgenerate 
// =======================================================



// Bali specific here :
// =======================================================
generate
if (BALI == 1) begin : gen_bali
assign skip_16g_qualify = 1;
logic mode_16g;
logic eof_8g;
logic eof_16g;

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
        txbist_data <= 'h0;
        txbist_data_val <= 1'b0;
end
else //if (txbist_data_val_int)
begin
        txbist_data <= txbist_data_int;
        txbist_data_val <= txbist_data_val_int;
end
/*
else
begin
        txbist_data <= {8'h01, oREG_TXBIST_IDLE_PRIMITIVE};
        txbist_data_val <= 1'b1;
end
*/


//OUTPUT machine
always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
        txbist_data_int <= 'h0;
        txbist_data_val_int <= 1'b0;
end
else if (sm_txbist_state == SM_TXBIST_PRIM)
begin
        txbist_data_int <=  {8'h01, oREG_TXBIST_REG_PRIMITIVE[63:0]};
        txbist_data_val_int <= !(skip_16g & skip_16g_qualify);
end
else if (sm_txbist_state == SM_TXBIST_RAM_REPEAT)
begin
        txbist_data_int <=  repeat_dword;
        txbist_data_val_int <= !(skip_16g & skip_16g_qualify);
end
else if (repeat_inst && sm_txbist_state != SM_TXBIST_RAM_IDLE)
begin
        txbist_data_int <=  repeat_dword;
        txbist_data_val_int <= 1'b1;
end
else if (~fifo_empty_r)
begin
        txbist_data_int <=  fifo_dword;
        txbist_data_val_int <= fifo_rd_val;
end
else    // transfer IDLE by default
begin
        txbist_data_int <= {8'h01, oREG_TXBIST_IDLE_PRIMITIVE};
        txbist_data_val_int <= !(skip_16g & skip_16g_qualify);
end


/* EOF counting is different in 16G mode vs. 8G mode.
 */

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    mode_16g <= 1'b1;
  else
    mode_16g <= linkspeed[2]; 

/*8g mode EOF parsing */

  logic [31:0] bist_8b_data;

vi_x4_decoder_8b10b #(.METHOD(0)) dec_8b10b (
  .clk(clk),
  .rst(~rst_n),
  .din_dat(txbist_data_int[39:0]),         // 10b data input
  .dout_dat(bist_8b_data),        // data out
  .dout_k(),          // special code
  .dout_kerr(),       // coding mistake detected
  .dout_rderr(),      // running disparity mistake detected
  .dout_rdcomb(),     // running dispartiy output (comb)
  .dout_rdreg()       // running disparity output (reg)
);


   assign eof_f   = ((bist_8b_data[31:0]==EOF_F_P_8B)   | (bist_8b_data[31:0]==EOF_F_N_8B));
   assign eof_dt  = ((bist_8b_data[31:0]==EOF_DT_P_8B)  | (bist_8b_data[31:0]==EOF_DT_N_8B));
   assign eof_a   = ((bist_8b_data[31:0]==EOF_A_P_8B)   | (bist_8b_data[31:0]==EOF_A_N_8B));
   assign eof_n   = ((bist_8b_data[31:0]==EOF_N_P_8B)   | (bist_8b_data[31:0]==EOF_N_N_8B));
   assign eof_ni  = ((bist_8b_data[31:0]==EOF_NI_P_8B)  | (bist_8b_data[31:0]==EOF_NI_N_8B));
   assign eof_dti = ((bist_8b_data[31:0]==EOF_DTI_P_8B) | (bist_8b_data[31:0]==EOF_DTI_N_8B));
   assign eof_rt  = ((bist_8b_data[31:0]==EOF_RT_P_8B)  | (bist_8b_data[31:0]==EOF_RT_N_8B));
   assign eof_rti = ((bist_8b_data[31:0]==EOF_RTI_P_8B) | (bist_8b_data[31:0]==EOF_RTI_N_8B));

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    eof_8g <= 1'b0;
  else
    eof_8g <= eof_f | eof_dt | eof_a | eof_n | eof_ni | eof_dti | eof_rt | eof_rti;


/*16G mode EOF parsing */
always @(posedge clk or negedge rst_n)
  if (!rst_n)
    eof_16g <= 1'b0;
  else
    eof_16g <= txbist_data_val_int && (txbist_data_int[65:64] == 2'b01)  && (
           (txbist_data_int[7:0] == 8'hB4) ||   //EOF Special Function followed by Idle or LPI Special Function 
           (txbist_data_int[7:0] == 8'hFF)      //Word of data followed by EOF Special Function 
           );

/*eof flag*/
always @(posedge clk or negedge rst_n)
  if (!rst_n)
    eof <= 1'b0;
  else
    eof <= mode_16g ? eof_16g : eof_8g;


end : gen_bali
endgenerate

// =======================================================


//REG read
always @(posedge clk or negedge rst_n)
        cr_ram_rd_en_edge_q       <= ~rst_n              ? 1'd0  : cr_ram_rd_en_edge;

always @(posedge clk or negedge rst_n)
        cr_ram_rd_en_edge_qq      <= ~rst_n              ? 1'd0  : cr_ram_rd_en_edge_q;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    iREG_TXBIST_RD_DATA[63:0] <= 64'd0;
  else if (cr_ram_rd_en_edge_qq)
    if (oREG_TXBIST_CTL_CONTROL_SPACE)
      iREG_TXBIST_RD_DATA[63:0] <= ram_rd_data[71:64];
    else
      iREG_TXBIST_RD_DATA[63:0] <= ram_rd_data[63:0];


endmodule




