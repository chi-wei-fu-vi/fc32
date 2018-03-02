module data_mux
(
  input RXCLK,
	input RXRST,
	input CLK219,
	input RST219,
  
	input lpbk_en,

	input [63:0] RX_DAT,
	input [1:0]  RX_SH,
	input        RX_VAL,
	input        RX_SYNC,

	input [63:0] BIST_DAT,
	input [1:0]  BIST_SH,
	input        BIST_VAL,

	output logic [63:0] MUX_DAT,
	output logic [1:0]  MUX_SH,
	output logic        MUX_VAL

);

localparam HIGH_MARK = 5'h15;
localparam LOW_MARK = 5'h8;

/****************************** RXCLK domain **************************/
logic expt_gb66_64_empty;
logic simonly_expt_gb66_64_full;
logic [4:0] async_rdusedw;
logic [4:0] async_wrusedw;

logic [63:0] RX_DAT_r;
logic [1:0]  RX_SH_r;
logic        RX_VAL_r;
logic [63:0] RX_DAT_r2;
logic [1:0]  RX_SH_r2;
logic        RX_VAL_r2;

logic delete_state;
logic delete_idle;

logic [63:0] rx_dat;
logic [1:0]  rx_sh;
logic        rx_val;
logic        rx_rden;

always @(posedge RXCLK or posedge RXRST)
  if (RXRST)
		delete_state <= 1'b0;
	else
		delete_state <= async_wrusedw >= HIGH_MARK;

assign delete_idle = RX_VAL_r && (RX_SH_r == 2'b01) && (RX_DAT_r[7:0] == 8'h1E) &&
                     RX_VAL_r2 && (RX_SH_r2 == 2'b01) && (RX_DAT_r2[7:0] == 8'h1E) &&
										 delete_state;
                     

always @(posedge RXCLK or posedge RXRST)
  if (RXRST)
	begin
    RX_DAT_r  <= 'h0;
    RX_SH_r   <= 'h0;
    RX_VAL_r  <= 'h0;
    RX_DAT_r2 <= 'h0;
    RX_SH_r2  <= 'h0;
    RX_VAL_r2 <= 'h0;
	end
	else
  begin
    RX_DAT_r  <= RX_DAT;
    RX_SH_r   <= RX_SH;
    RX_VAL_r  <= RX_VAL;
    RX_DAT_r2 <= RX_DAT_r;
    RX_SH_r2  <= RX_SH_r;
    RX_VAL_r2 <= RX_VAL_r && ~delete_idle;
	end

alt_fifo_async_66_66
  alt_fifo_async_66_66_inst (
  .rst(1'b0),                      // input wire rst
  .wr_rst_busy(),      // output wire wr_rst_busy
  .rd_rst_busy(),     // output wire rd_rst_busy
  .din({RX_SH_r2, RX_DAT_r2}),
  .rd_clk(CLK219),
  .rd_en(rx_rden),
  .wr_clk(RXCLK),
  .wr_en(RX_VAL_r2),
  .dout({rx_sh, rx_dat}),
  .empty(expt_gb66_64_empty),
  .rd_data_count(async_rdusedw),
  .wr_data_count(async_wrusedw),
  .full(simonly_expt_gb66_64_full)
  );

// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file alt_fifo_async_66_66.v when simulating
// the core, alt_fifo_async_66_66. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

/****************************** TXCLK domain **************************/

logic insert_state;
logic insert, insert_r, insert_r2;
logic [63:0] rx_dat_buf;
logic [1:0]  rx_sh_buf;
logic        rx_val_buf;
logic [63:0] rx_dat_r;
logic [1:0]  rx_sh_r;
logic        rx_val_r;
logic [63:0] rx_dat_r2;
logic [1:0]  rx_sh_r2;
logic        rx_val_r2;
logic [4:0] sync_usewd;
logic       sync_empty;
logic half_full_flag;
logic sync_rd_en;
logic [5:0] fifo_val_cnt;


always @(posedge CLK219)
  if (RST219)
		rx_val <= 1'b0;
	else
		rx_val <= rx_rden;

always @(posedge CLK219)
  if (RST219)
  begin
		insert_state   <= 1'b0;
  end
	else
  begin
		insert_state   <= (async_rdusedw <= LOW_MARK);
  end

always @(posedge CLK219)
  if (RST219)
  begin
		insert_r  <= 1'b0;
		insert_r2 <= 1'b0;
  end
	else
  begin
		insert_r  <= insert;
		insert_r2 <= insert_r;
  end

assign insert = rx_val_r && (rx_sh_r == 2'b01) && (rx_dat_r[7:0] == 8'h1e) && insert_state;
assign rx_rden = ~insert && ~expt_gb66_64_empty && ~sync_usewd[4];

always @(posedge CLK219)
  if (RST219)
  begin
	  rx_dat_r <= 'h0;
	  rx_sh_r  <= 'h0;
	  rx_val_r <= 'h0;
	  rx_dat_buf <= 'h0;
	  rx_sh_buf  <= 'h0;
	  rx_val_buf <= 'h0;
	end
	else 
	begin
	  rx_dat_r <= rx_dat;
	  rx_sh_r  <= rx_sh;
	  rx_val_r <= rx_val;
	  rx_dat_buf <= rx_dat_r;
	  rx_sh_buf  <= rx_sh_r;
	  rx_val_buf <= rx_val_r;
	end


logic fifo_empty;
always @(posedge CLK219)
  if (RST219)
    fifo_empty <= 1'b0;
  else
    fifo_empty <= expt_gb66_64_empty;

always @(posedge CLK219)
  if (RST219)
  begin
    rx_dat_r2 <= 'h0;
    rx_val_r2 <= 'h0;
  end
  else if (insert_r)
  begin
    rx_dat_r2 <= {56'h0, 8'h1e};
    rx_val_r2 <= 1'b1;
  end
  else if (insert_r2)
  begin
    rx_dat_r2 <= rx_dat_buf;
    rx_val_r2 <= rx_val_buf;
  end
  else
  begin
    rx_dat_r2 <= rx_dat_r;
    rx_val_r2 <= rx_val_r;
  end

always @(posedge CLK219)
  if (RST219)
  begin
    rx_sh_r2  <= 'h0;
  end
  else if (fifo_empty)  //If the input data were to stop, then driven all zero
  begin
    rx_sh_r2  <= 2'b00;  //induce LOSYNC on the other side
  end
  else if (insert_r)
  begin
    rx_sh_r2  <= 2'b01;
  end
  else if (insert_r2)
  begin
    rx_sh_r2  <= rx_sh_buf;
  end
  else
  begin
    rx_sh_r2  <= rx_sh_r;
  end


logic [63:0] mux_dat;
logic [1:0]  mux_sh;
logic        mux_val;



always @(posedge CLK219)
  if (RST219 || sync_empty)
		half_full_flag <= 1'b0;
  else if (sync_usewd[4])
		half_full_flag <= 1'b1;

always @(posedge CLK219)
  if (RST219)
    fifo_val_cnt <= 'h0;
  else if (fifo_val_cnt[5])
    fifo_val_cnt <= 'h0;
  else
    fifo_val_cnt <= fifo_val_cnt + 1;

always @(posedge CLK219)
  if (RST219)
  begin
		sync_rd_en <= 1'b0;
		mux_val    <= 1'b0;
  end 
  else
  begin
		sync_rd_en <= ~fifo_val_cnt[5] && half_full_flag;
		mux_val    <= sync_rd_en;
  end

logic rxsync;
vi_sync_level #(.SIZE(1),
    .TWO_DST_FLOPS(1))
losync_level_sync
  (
   .out_level    ( rxsync  ),
   .clk          ( CLK219          ),
   .rst_n        ( ~RST219        ),
   .in_level     ( RX_SYNC )
   );

always @(posedge CLK219)
  if (RST219)
  begin
    MUX_SH     <= 'h0;
    MUX_DAT    <= 'h0;
    MUX_VAL    <= 1'b0;
  end
  else if (lpbk_en)
  begin
    MUX_SH     <= rxsync ?  mux_sh : 2'h0;
    MUX_DAT    <= rxsync ?  mux_dat: 64'h0;
    MUX_VAL    <= rxsync ?  mux_val: 1'b1;
  end
  else
  begin
    MUX_SH     <= BIST_SH;
    MUX_DAT    <= BIST_DAT;
    MUX_VAL    <= BIST_VAL;
  end

		
endmodule
