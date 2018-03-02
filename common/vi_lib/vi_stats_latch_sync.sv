module vi_stats_latch_sync
# (
  parameter TIMEOUT_WIDTH = 4,  // log 2 width for timeout count. timeout = 2^TIMEOUT_WIDTH
	parameter CLKB_WIDTH = 4      // pipe stage latency in the clkb domain.  Latency = CLKB_WIDTH
)
(
  input  clka,
	input  clkb,
	input  rsta_n,
	input  rstb_n,
	input  invl_latch_pulse,
	output logic invl_clr_done_pulse,
	output logic invl_clr_timeout_level
);

//clka domain
logic [TIMEOUT_WIDTH-1 : 0] timeout_cnt;
logic                       latch_clr_done_clka;
//clkb domain
logic                       latch_clr_clkb;
logic [CLKB_WIDTH-1 : 0]    clr_clkb_dly_r;

logic invl_clr_timeout_pulse;

//clka domain
always @ (posedge clka or negedge rsta_n)
  if (!rsta_n)
	  timeout_cnt <= 'h0;
  else if (latch_clr_done_clka)
    timeout_cnt <= 'h0;
	else if (invl_latch_pulse)
		timeout_cnt <= {TIMEOUT_WIDTH{1'b1}};
	else if (|timeout_cnt)
		timeout_cnt <= timeout_cnt - 1;

always @ (posedge clka or negedge rsta_n)
  if (!rsta_n)
    invl_clr_timeout_pulse <= 'h0;
	else
    invl_clr_timeout_pulse <= timeout_cnt == 1;

always @ (posedge clka or negedge rsta_n)
  if (!rsta_n)
    invl_clr_timeout_level <= 'h0;
  else if (invl_latch_pulse)
    invl_clr_timeout_level <= 'h0;
	else
    invl_clr_timeout_level <= invl_clr_timeout_pulse || invl_clr_timeout_level;

always @ (posedge clka or negedge rsta_n)
  if (!rsta_n)
    invl_clr_done_pulse    <= 'h0;
  else
    invl_clr_done_pulse    <= (latch_clr_done_clka && |timeout_cnt[TIMEOUT_WIDTH-1 : 1]) || invl_clr_timeout_pulse;



//clka -> clkb domain
vi_sync_pulse u_sync_pls_latch_clr_a2b (
            .out_pulse          ( latch_clr_clkb        ),
            .clka               ( clka                  ),
            .clkb               ( clkb                  ),
            .rsta_n             ( rsta_n                ),
            .rstb_n             ( rstb_n                ),
            .in_pulse           ( invl_latch_pulse      )
);

//clkb domain
always @( posedge clkb or negedge rstb_n )
    if ( ~rstb_n )
        clr_clkb_dly_r <= {CLKB_WIDTH{1'b0}};
    else
        clr_clkb_dly_r <= {clr_clkb_dly_r[CLKB_WIDTH-2:0], latch_clr_clkb};


//clkb -> clka domain
vi_sync_pulse u_sync_pls_latch_clr_b2a (
            .out_pulse          ( latch_clr_done_clka           ),
            .clka               ( clkb                          ),
            .clkb               ( clka                          ),
            .rsta_n             ( rstb_n                        ),
            .rstb_n             ( rsta_n                        ),
            .in_pulse           ( clr_clkb_dly_r[CLKB_WIDTH-1]  )
);



endmodule
