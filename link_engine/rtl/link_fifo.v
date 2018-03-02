/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: link_fifo.v$
* $Author: honda.yang $
* $Date: 2014-03-31 11:16:44 -0700 (Mon, 31 Mar 2014) $
* $Revision: 5056 $
* Description: Link FIFO storing DAL packets after time arbitration
*
***************************************************************************/
module link_fifo #(

parameter   LINK_FIFO_DATA_WIDTH        = 256,
parameter   LINK_FIFO_ADDR_WIDTH        = 10,
parameter   LINK_FIFO_DEPTH             = 1024 )

(

// Transfer State Machine
output logic            oLKF_FIFO_NEMPTY,
output logic            oLKF_BLK_AEMPTY,

// PCIE
output logic [255:0]    oDAT_DPLBUF_DATA,

// Time Arbiter
output logic            oLKF_TA_AFULL,
output logic [6:0]      oLKF_TA_OFST_WA,
output logic            oLKF_TA_EMPTY,

// Register
output logic            oLKF_REG_LINKFIFOSTAT_UNDERFLOW,
output logic            oLKF_REG_LINKFIFOSTAT_OVERFLOW,
output logic [LINK_FIFO_ADDR_WIDTH:0] oLKF_REG_LINKFIFOSTAT_WORDS,
output logic            oLKF_REG_LINKFIFOLEVEL_V,
output logic [LINK_FIFO_ADDR_WIDTH:0] oLKF_REG_LINKFIFOLEVEL_RD,

// Global
input                   wr_clk,
input                   rd_clk,
input                   wr_rst_n,
input                   rd_rst_n,

// Time Arbiter
input  [255:0]          iTA_LKF_DAL_DATA,
input                   iTA_LKF_DAL_VALID,

// Transfer State Machine
input                   iXFR_AHEAD_ST,
input                   iDPLBUF_DATA_V,

// Register
input  [LINK_FIFO_ADDR_WIDTH:0] iREG_LINKFIFOLEVEL_WR,
input                   iREG_LINKFIFOLEVEL_WR_EN,
input                   iREG_LINKFIFOLEVEL_RD_EN

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
// The block pointer is one bit larger than required to differentiate
// full vs. empty condition.
localparam  FIFO_BLK_ADDR_WIDTH         = LINK_FIFO_ADDR_WIDTH - 6;
localparam  FIFO_BLK_DEPTH              = 1 << (FIFO_BLK_ADDR_WIDTH-1);

logic [LINK_FIFO_DATA_WIDTH-1:0] lk_fifo_rd;
logic lk_fifo_we, incr_blk_wa_r;
logic [FIFO_BLK_ADDR_WIDTH-1:0] fifo_blk_wa_nxt, fifo_blk_wa_r;
logic [FIFO_BLK_ADDR_WIDTH-1:0] fifo_blk_ra_nxt, fifo_blk_ra_r, curr_fifo_blk_ra_r;
logic [LINK_FIFO_ADDR_WIDTH-1:0] lk_fifo_wa_r, lk_fifo_ra;
logic lk_fifo_re, incr_blk_ra;
logic [6:0] fifo_ofst_ra_nxt, fifo_ofst_ra_r, fifo_ofst_wa_d1_r;
logic [FIFO_BLK_ADDR_WIDTH-1:0] fifo_blk_wa_gray_nxt, fifo_blk_wa_gray_r;
logic [FIFO_BLK_ADDR_WIDTH-1:0] fifo_blk_wa_gray_rclk_r, fifo_blk_wa_rclk_nxt, fifo_blk_wa_rclk_r;
logic [FIFO_BLK_ADDR_WIDTH-1:0] fifo_blk_ra_gray_nxt, fifo_blk_ra_gray_r;
logic [FIFO_BLK_ADDR_WIDTH-1:0] fifo_blk_ra_gray_wclk_r, fifo_blk_ra_wclk_nxt, fifo_blk_ra_wclk_r;
logic [FIFO_BLK_ADDR_WIDTH-1:0] blk_cnt_wclk, blk_cnt_rclk;
logic blk_going_empty_r, fifo_ofst_wa_max, fifo_underflow_r;
logic [255:0] lk_fifo_rd_lat_r;
logic fifo_empty_wclk_r;
logic [7:0] empty_dly_wclk_r;
logic ofst_wa_zero_r, ofst_wa_zero_d1_r;

///////////////////////////////////////////////////////////////////////////////
// Memory Instantiation
///////////////////////////////////////////////////////////////////////////////
ram1r1w2c #(
    .ADDR_WIDTH ( LINK_FIFO_ADDR_WIDTH  ),
    .DEPTH      ( LINK_FIFO_DEPTH       ),
    .DATA_WIDTH ( LINK_FIFO_DATA_WIDTH  ),
    .PIPE       ( 0                     )
)
u_link_fifo_ram (
    .rddata             ( lk_fifo_rd                ),
    .rdclk              ( rd_clk                    ),
    .rdaddr             ( lk_fifo_ra                ),
    .wrclk              ( wr_clk                    ),
    .wraddr             ( lk_fifo_wa_r              ),
    .wrdata             ( iTA_LKF_DAL_DATA          ),
    .wren               ( lk_fifo_we                )
);

///////////////////////////////////////////////////////////////////////////////
// Write Pointer
///////////////////////////////////////////////////////////////////////////////
// Link FIFO always works on 4KB boundary. The 4KB block read/write 
// addresses are compared with each other. The offset address within
// the 4KB block is always incremented and rolled over.
assign lk_fifo_we = iTA_LKF_DAL_VALID;

always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        oLKF_TA_OFST_WA <= 7'b0;
    else if ( lk_fifo_we )
        oLKF_TA_OFST_WA <= oLKF_TA_OFST_WA + 7'b1;

always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        incr_blk_wa_r <= 1'b0;
    else
        incr_blk_wa_r <= lk_fifo_we & ( oLKF_TA_OFST_WA == 7'h7f );

assign fifo_blk_wa_nxt = incr_blk_wa_r ? ( fifo_blk_wa_r + {{(FIFO_BLK_ADDR_WIDTH-1){1'b0}},1'b1} ) : fifo_blk_wa_r;

// Block address has one extra bit to differentiate full vs. empty
always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        fifo_blk_wa_r <= {FIFO_BLK_ADDR_WIDTH{1'b0}};
    else
        fifo_blk_wa_r <= fifo_blk_wa_nxt;

assign lk_fifo_wa_r = {fifo_blk_wa_r[FIFO_BLK_ADDR_WIDTH-2:0], oLKF_TA_OFST_WA};

///////////////////////////////////////////////////////////////////////////////
// Read Pointer
///////////////////////////////////////////////////////////////////////////////
assign lk_fifo_re = iXFR_AHEAD_ST | ( iDPLBUF_DATA_V & ~blk_going_empty_r );

assign fifo_ofst_ra_nxt = lk_fifo_re ? ( fifo_ofst_ra_r + 7'b1 ) : fifo_ofst_ra_r;

always_ff @( posedge rd_clk or negedge rd_rst_n )
    if ( ~rd_rst_n )
        fifo_ofst_ra_r <= 7'b0;
    else
        fifo_ofst_ra_r <= fifo_ofst_ra_nxt;

assign incr_blk_ra = iDPLBUF_DATA_V & oLKF_BLK_AEMPTY;

assign fifo_blk_ra_nxt = incr_blk_ra ? ( fifo_blk_ra_r + {{(FIFO_BLK_ADDR_WIDTH-1){1'b0}},1'b1} ) : fifo_blk_ra_r;

always_ff @( posedge rd_clk or negedge rd_rst_n )
    if ( ~rd_rst_n )
        fifo_blk_ra_r <= {FIFO_BLK_ADDR_WIDTH{1'b0}};
    else
        fifo_blk_ra_r <= fifo_blk_ra_nxt;

// The block read address is latched when a 4K transfer is granted.
// This allows fifo_blk_ra_r is incremented ahead of time for early block count
// calculation.
always_ff @( posedge rd_clk or negedge rd_rst_n )
    if ( ~rd_rst_n )
        curr_fifo_blk_ra_r <= {FIFO_BLK_ADDR_WIDTH{1'b0}};
    else if ( lk_fifo_ra[6:0] == 7'h00 )
        curr_fifo_blk_ra_r <= fifo_blk_ra_r;

assign lk_fifo_ra = {curr_fifo_blk_ra_r[FIFO_BLK_ADDR_WIDTH-2:0], fifo_ofst_ra_nxt};

///////////////////////////////////////////////////////////////////////////////
// Read Pipeline
///////////////////////////////////////////////////////////////////////////////
// FIFO data is forced to 0 if not reading.
// The control and data FIFO can then be OR'ed together at link_engine level
always_ff @( posedge rd_clk )
    if ( lk_fifo_re ) 
        lk_fifo_rd_lat_r <= lk_fifo_rd;

assign oDAT_DPLBUF_DATA = iDPLBUF_DATA_V ? lk_fifo_rd_lat_r : 256'b0;

///////////////////////////////////////////////////////////////////////////////
// Block Write Address Entering Read Clock Domain
///////////////////////////////////////////////////////////////////////////////
vi_bin2gray #(
    .SIZE       ( FIFO_BLK_ADDR_WIDTH   )
)
u_fifo_blk_wa_vi_bin2gray (
    .gray               ( fifo_blk_wa_gray_nxt      ),
    .bin                ( fifo_blk_wa_nxt           )
);

always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        fifo_blk_wa_gray_r <= {FIFO_BLK_ADDR_WIDTH{1'b0}};
    else
        fifo_blk_wa_gray_r <= fifo_blk_wa_gray_nxt;

vi_sync_level #(
    .SIZE           ( FIFO_BLK_ADDR_WIDTH   ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_blk_wa_gray (
    .out_level          ( fifo_blk_wa_gray_rclk_r   ),
    .clk                ( rd_clk                    ),
    .rst_n              ( rd_rst_n                  ),
    .in_level           ( fifo_blk_wa_gray_r        )
);

vi_gray2bin #(
    .SIZE       ( FIFO_BLK_ADDR_WIDTH   )
)
u_fifo_blk_wa_vi_gray2bin (
    .bin                ( fifo_blk_wa_rclk_nxt      ),
    .gray               ( fifo_blk_wa_gray_rclk_r   )
);

always_ff @( posedge rd_clk or negedge rd_rst_n )
    if ( ~rd_rst_n )
        fifo_blk_wa_rclk_r <= {FIFO_BLK_ADDR_WIDTH{1'b0}};
    else
        fifo_blk_wa_rclk_r <= fifo_blk_wa_rclk_nxt;

///////////////////////////////////////////////////////////////////////////////
// Block Read Address Entering Write Clock Domain
///////////////////////////////////////////////////////////////////////////////
vi_bin2gray #(
    .SIZE       ( FIFO_BLK_ADDR_WIDTH   )
)
u_fifo_blk_ra_vi_bin2gray (
    .gray               ( fifo_blk_ra_gray_nxt      ),
    .bin                ( fifo_blk_ra_nxt           )
);

always_ff @( posedge rd_clk or negedge rd_rst_n )
    if ( ~rd_rst_n )
        fifo_blk_ra_gray_r <= {FIFO_BLK_ADDR_WIDTH{1'b0}};
    else
        fifo_blk_ra_gray_r <= fifo_blk_ra_gray_nxt;

vi_sync_level #(
    .SIZE           ( FIFO_BLK_ADDR_WIDTH   ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_blk_ra_gray (
    .out_level          ( fifo_blk_ra_gray_wclk_r   ),
    .clk                ( wr_clk                    ),
    .rst_n              ( wr_rst_n                  ),
    .in_level           ( fifo_blk_ra_gray_r        )
);

vi_gray2bin #(
    .SIZE       ( FIFO_BLK_ADDR_WIDTH   )
)
u_fifo_blk_ra_vi_gray2bin (
    .bin                ( fifo_blk_ra_wclk_nxt      ),
    .gray               ( fifo_blk_ra_gray_wclk_r   )
);

always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        fifo_blk_ra_wclk_r <= {FIFO_BLK_ADDR_WIDTH{1'b0}};
    else
        fifo_blk_ra_wclk_r <= fifo_blk_ra_wclk_nxt;

///////////////////////////////////////////////////////////////////////////////
// Block Count in Write Clock Domain
///////////////////////////////////////////////////////////////////////////////
assign blk_cnt_wclk = fifo_blk_wa_r - fifo_blk_ra_wclk_r;

always_ff @( posedge wr_clk )
    fifo_ofst_wa_d1_r <= oLKF_TA_OFST_WA;

always_ff @( posedge wr_clk )
    oLKF_REG_LINKFIFOSTAT_WORDS <= { blk_cnt_wclk, fifo_ofst_wa_d1_r };

always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        oLKF_REG_LINKFIFOSTAT_OVERFLOW <= 1'b0;
    else
        oLKF_REG_LINKFIFOSTAT_OVERFLOW <= lk_fifo_we & ( oLKF_REG_LINKFIFOSTAT_WORDS == 
                                                         {1'b1,{LINK_FIFO_ADDR_WIDTH{1'b0}}} );

assign fifo_ofst_wa_max = ( oLKF_TA_OFST_WA >= 7'h7e ) | ( fifo_ofst_wa_d1_r >= 7'h7e );

always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        oLKF_TA_AFULL <= 1'b0;
    else
        oLKF_TA_AFULL <= ( blk_cnt_wclk == FIFO_BLK_DEPTH ) |
                         ( ( blk_cnt_wclk == FIFO_BLK_DEPTH - 1 ) & fifo_ofst_wa_max );

always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n ) begin
        fifo_empty_wclk_r <= 1'b1;
        empty_dly_wclk_r <= 8'hff;
        ofst_wa_zero_r <= 1'b1;
        ofst_wa_zero_d1_r <= 1'b1;
        oLKF_TA_EMPTY <= 1'b1;
    end
    else begin
        fifo_empty_wclk_r <= ( blk_cnt_wclk == {FIFO_BLK_ADDR_WIDTH{1'b0}} );
        empty_dly_wclk_r <= {empty_dly_wclk_r[6:0], fifo_empty_wclk_r};
        ofst_wa_zero_r <= ( oLKF_TA_OFST_WA == 7'h00 );
        ofst_wa_zero_d1_r <= ofst_wa_zero_r;
        oLKF_TA_EMPTY <= fifo_empty_wclk_r & empty_dly_wclk_r[7] &
                         ofst_wa_zero_r & ofst_wa_zero_d1_r;
    end

///////////////////////////////////////////////////////////////////////////////
// FIFO Empty in Read Clock Domain
///////////////////////////////////////////////////////////////////////////////
assign blk_cnt_rclk = fifo_blk_wa_rclk_r - fifo_blk_ra_r;

assign oLKF_FIFO_NEMPTY = ( blk_cnt_rclk != {FIFO_BLK_ADDR_WIDTH{1'b0}} );

always_ff @( posedge rd_clk or negedge rd_rst_n )
    if ( ~rd_rst_n )
        oLKF_BLK_AEMPTY <= 1'b0;
    else
        oLKF_BLK_AEMPTY <= ( lk_fifo_ra[6:0] == 7'h7a );

always_ff @( posedge rd_clk or negedge rd_rst_n )
    if ( ~rd_rst_n )
        blk_going_empty_r <= 1'b0;
    else
        blk_going_empty_r <= ( lk_fifo_ra[6:0] == 7'h00 );

always_ff @( posedge rd_clk or negedge rd_rst_n )
    if ( ~rd_rst_n )
        fifo_underflow_r <= 1'b0;
    else
        fifo_underflow_r <= incr_blk_ra & ( blk_cnt_rclk == {FIFO_BLK_ADDR_WIDTH{1'b0}} );

vi_sync_level #(
    .SIZE           ( 1                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_underflow (
    .out_level          ( oLKF_REG_LINKFIFOSTAT_UNDERFLOW   ),
    .clk                ( wr_clk                            ),
    .rst_n              ( wr_rst_n                          ),
    .in_level           ( fifo_underflow_r                  )
);

///////////////////////////////////////////////////////////////////////////////
// FIFO Level Monitor
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        oLKF_REG_LINKFIFOLEVEL_RD <= {LINK_FIFO_ADDR_WIDTH{1'b0}};
    else if ( iREG_LINKFIFOLEVEL_WR_EN )
        oLKF_REG_LINKFIFOLEVEL_RD <= iREG_LINKFIFOLEVEL_WR;
    else if ( oLKF_REG_LINKFIFOSTAT_WORDS > oLKF_REG_LINKFIFOLEVEL_RD )
        oLKF_REG_LINKFIFOLEVEL_RD <= oLKF_REG_LINKFIFOSTAT_WORDS;

always_ff @( posedge wr_clk or negedge wr_rst_n )
    if ( ~wr_rst_n )
        oLKF_REG_LINKFIFOLEVEL_V <= 1'b0;
    else
        oLKF_REG_LINKFIFOLEVEL_V <= iREG_LINKFIFOLEVEL_RD_EN;



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
// FIFO underflow
assert_link_fifo_underflow: assert property ( @( posedge rd_clk )
    disable iff ( ~rd_rst_n )
    !$rose( fifo_underflow_r ) );

// FIFO overflow
assert_link_fifo_overflow: assert property ( @( posedge wr_clk )
    disable iff ( ~wr_rst_n )
    !$rose( oLKF_REG_LINKFIFOSTAT_OVERFLOW ) );

final begin
    assert_link_fifo_empty: assert ( lk_fifo_ra == lk_fifo_wa_r );
    assert_link_fifo_empty_wclk: assert ( oLKF_TA_EMPTY == 1 );
end


// synopsys translate_on

endmodule


