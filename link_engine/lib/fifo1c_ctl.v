/***************************************************************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: fifo1c_ctl.v$
* $Author: honda.yang $
* $Date: 2013-07-23 14:41:48 -0700 (Tue, 23 Jul 2013) $
* $Revision: 2958 $
* Description: fifo1c_ctl is a parameterized simple FIFO controller
*              with one clock domain.
*
*  Parameters:
*  ADDR_WIDTH - RAM read / write address bus width
*  DEPTH      - Number of entries in the RAM. Needed since the depth may not 
*               always be powers of two
*  DATA_WIDTH - RAM read / write data bus width
*  AFUL_THRES - Almost full threshold level
*  AEMP_THRES - Almost empty threshold level
*
***************************************************************************/

module fifo1c_ctl #(

parameter ADDR_WIDTH    = 2,                // Address Width
parameter DEPTH         = (1<<ADDR_WIDTH),  // Depth of RAM
parameter DATA_WIDTH    = 8,                // Data Width 
parameter AFUL_THRES    = 8,                // Almost Full Threshold
parameter AEMP_THRES    = 2,                // Almost Empty Threshold
parameter WRREQ_EARLY   = 0,                // Write Request Early
parameter PIPE          = 1 )               // Output Data/Stats Registered

(

// Read
output logic [DATA_WIDTH-1:0]   q,

// Status
output logic                    almost_empty,
output logic                    almost_full,
output logic                    empty,
output logic                    full,
output logic [ADDR_WIDTH:0]     usedw,
output logic [ADDR_WIDTH:0]     highest_dw,
output logic                    overflow,
output logic                    underflow,

// Memory
output logic [ADDR_WIDTH-1:0]   fifo_ra_nxt,
output logic [ADDR_WIDTH-1:0]   fifo_wa_r,
output logic                    wrreq_mem_mux,

// Global
input                           clk,
input                           rst_n,

// Write
input  [DATA_WIDTH-1:0]         data,
input                           wrreq,

// Read
input                           rdreq,

// Clear
input                           highest_clr,

// Memory
input  [DATA_WIDTH-1:0]         fifo_rd

);

///////////////////////////////////////////////////////////////////////////////
// Declarations
///////////////////////////////////////////////////////////////////////////////
localparam   RD_IDLE_ST              = 0;
localparam   RD_AHEAD_ST             = 1;
localparam   RD_POP_ST               = 2;
localparam   RD_WAIT_ST              = 3;

logic [ADDR_WIDTH-1:0] fifo_ra_r;
logic [ADDR_WIDTH:0] usedw_nxt;
logic [DATA_WIDTH-1:0] data_d1_r;
logic [3:0] rd_state_nxt, rd_state_r;
logic usedw_one_r, usedw_one_nxt, usedw_not_one_r, first_write_r, incr_fifo_ra;
logic aempty_nxt, afull_nxt, empty_nxt, full_nxt, empty_early;
logic aempty_r, afull_r, empty_r, full_r;
logic [DATA_WIDTH-1:0] outdata_r, outdata_nxt;
logic wr_fwd_rd_one_r;
logic wr_fwd_rd_r, wrreq_mem_d1_r, wrreq_d1_r, wrreq_empty_mux_d1_r /* synthesis preserve */;
logic wrreq_mux;
logic wrreq_empty_r, wrreq_empty_mux;

///////////////////////////////////////////////////////////////////////////////
// Write Request Flop
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        wrreq_mem_d1_r <= 1'b0;
        wrreq_d1_r     <= 1'b0;
    end
    else begin
        wrreq_mem_d1_r <= wrreq;
        wrreq_d1_r     <= wrreq;
        wrreq_empty_r  <= wrreq & empty_nxt;
    end

assign wrreq_mem_mux = WRREQ_EARLY ? wrreq_mem_d1_r : wrreq;
assign wrreq_mux = WRREQ_EARLY ? wrreq_d1_r : wrreq;

assign wrreq_empty_mux = WRREQ_EARLY ? wrreq_empty_r : ( wrreq & empty_r );

always_ff @( posedge clk )
    wrreq_empty_mux_d1_r <= wrreq_empty_mux;

///////////////////////////////////////////////////////////////////////////////
// Write Pointer
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        fifo_wa_r <= {ADDR_WIDTH{1'b0}};
    else if ( wrreq_mux )
        fifo_wa_r <= fifo_wa_r + {{(ADDR_WIDTH-1){1'b0}}, 1'b1};

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        first_write_r <= 1'b0;
    else
        first_write_r <= empty_r & wrreq_mux;

///////////////////////////////////////////////////////////////////////////////
// Read Pointer
///////////////////////////////////////////////////////////////////////////////
assign incr_fifo_ra = rd_state_r[ RD_AHEAD_ST ] | ( rdreq & usedw_not_one_r );

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        fifo_ra_r <= {ADDR_WIDTH{1'b0}};
    else 
        fifo_ra_r <= fifo_ra_nxt;

always_comb
    if ( incr_fifo_ra )
        fifo_ra_nxt = fifo_ra_r + {{(ADDR_WIDTH-1){1'b0}}, 1'b1};
    else
        fifo_ra_nxt = fifo_ra_r;

///////////////////////////////////////////////////////////////////////////////
// Count
///////////////////////////////////////////////////////////////////////////////
always_comb begin
    case ( {wrreq_mux, rdreq} )
        2'b00: usedw_nxt = usedw;
        2'b01: usedw_nxt = usedw - {{ADDR_WIDTH{1'b0}}, 1'b1};
        2'b10: usedw_nxt = usedw + {{ADDR_WIDTH{1'b0}}, 1'b1};
        2'b11: usedw_nxt = usedw;
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        usedw <= {(ADDR_WIDTH+1){1'b0}};
    else 
        usedw <= usedw_nxt;

///////////////////////////////////////////////////////////////////////////////
// Status
///////////////////////////////////////////////////////////////////////////////
assign aempty_nxt = ( usedw_nxt < AEMP_THRES );
assign afull_nxt  = ( usedw_nxt > AFUL_THRES );
assign empty_nxt  = ( usedw_nxt == 0 );
assign full_nxt   = ( usedw_nxt == DEPTH );
assign usedw_one_nxt = ( usedw_nxt == 1 );

// empty_early is not derived from counter to speed up timing path when PIPE=0
assign empty_early = ( empty_r & ~wrreq_mux ) | ( ~empty_r & usedw_one_r & rdreq & ~wrreq_mux );

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        aempty_r    <= 1'b1;
        afull_r     <= 1'b0;
        empty_r     <= 1'b1;
        full_r      <= 1'b0;
        usedw_one_r <= 1'b0;
        usedw_not_one_r <= 1'b1;
    end
    else begin
        aempty_r    <= aempty_nxt;
        afull_r     <= afull_nxt;
        empty_r     <= empty_nxt;
        full_r      <= full_nxt;
        usedw_one_r <= usedw_one_nxt;
        usedw_not_one_r <= ~usedw_one_nxt;
    end

assign almost_empty = PIPE ? aempty_r : aempty_nxt;
assign almost_full  = PIPE ? afull_r  : afull_nxt;
assign empty        = PIPE ? empty_r  : empty_early;
assign full         = PIPE ? full_r   : full_nxt;

///////////////////////////////////////////////////////////////////////////////
// Read State Machine
///////////////////////////////////////////////////////////////////////////////
// The FIFO prefetches the next read data to hide the memory read latency.
// When the FIFO first becomes non-empty, the first data is read and stored
// in the output register while the read pointer moves to next location.
always_comb begin
    rd_state_nxt = 3'b0;
    case ( 1'b1 )       // synopsys parallel_case
        rd_state_r[ RD_IDLE_ST ]: begin
            if ( first_write_r )
                rd_state_nxt[ RD_AHEAD_ST ] = 1'b1;
            else
                rd_state_nxt[ RD_IDLE_ST ] = 1'b1;
        end
        rd_state_r[ RD_AHEAD_ST ]: begin
            if ( rdreq & ~wrreq_mux & usedw_one_r ) 
                rd_state_nxt[ RD_IDLE_ST ] = 1'b1;
            else
                rd_state_nxt[ RD_POP_ST ] = 1'b1;
        end
        rd_state_r[ RD_POP_ST ]: begin
            if ( rdreq & usedw_one_r ) begin
                // If another write occurs when FIFO was supposed to become
                // empty, go to RD_WAIT_ST then RD_AHEAD_ST to allow write
                // operation to complete before reading.
                if ( wrreq_mux )
                    rd_state_nxt[ RD_WAIT_ST ] = 1'b1;
                else
                    rd_state_nxt[ RD_IDLE_ST ] = 1'b1;
            end
            else
                rd_state_nxt[ RD_POP_ST ] = 1'b1;
        end
        rd_state_r[ RD_WAIT_ST ]: begin
            rd_state_nxt[ RD_AHEAD_ST ] = 1'b1;
        end
    endcase
end

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) begin
        rd_state_r <= 3'b0;
        rd_state_r[ RD_IDLE_ST ] <= 1'b1;
    end
    else
        rd_state_r <= rd_state_nxt;

///////////////////////////////////////////////////////////////////////////////
// Read Pipeline
///////////////////////////////////////////////////////////////////////////////
// If new data is being written while reading the same location, the new
// data is forwarded to q.
always_ff @( posedge clk ) begin
    wr_fwd_rd_r <= wrreq_mux & ( fifo_wa_r == fifo_ra_nxt );
    wr_fwd_rd_one_r <= wrreq_mux & ( fifo_wa_r == fifo_ra_nxt ) & usedw_one_nxt;
end

always_ff @( posedge clk )
    data_d1_r <= data;

// When wrreq_mux and rdreq collide, wr_fwd_rd_r forwards new write data to
// read side if FIFO is almost empty. 
always_comb begin
    if ( wrreq_empty_mux & ~PIPE )
        outdata_nxt = data;
    else if ( incr_fifo_ra | wr_fwd_rd_one_r )
        outdata_nxt = wr_fwd_rd_r ? data_d1_r : fifo_rd;
    else
        outdata_nxt = outdata_r;
end

always_ff @( posedge clk )
    outdata_r <= outdata_nxt;

assign q = PIPE ? ( wrreq_empty_mux_d1_r ? data_d1_r : outdata_r ) : outdata_nxt;

///////////////////////////////////////////////////////////////////////////////
// Errors
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        overflow  <= 1'b0;
    else if ( full_r & wrreq_mux )
        overflow  <= 1'b1;

always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n ) 
        underflow <= 1'b0;
    else if ( empty_r & rdreq )
        underflow <= 1'b1;

///////////////////////////////////////////////////////////////////////////////
// Highest FIFO Level Reached
///////////////////////////////////////////////////////////////////////////////
always_ff @( posedge clk or negedge rst_n )
    if ( ~rst_n )
        highest_dw <= {(ADDR_WIDTH+1){1'b0}};
    else if ( highest_clr )
        highest_dw <= {(ADDR_WIDTH+1){1'b0}};
    else if ( usedw > highest_dw )
        highest_dw <= usedw;



// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
assert_fifo_overflow: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( overflow ) );

assert_fifo_underflow: assert property ( @( posedge clk )
    disable iff ( ~rst_n )
    !$rose( underflow ) );




// synopsys translate_on

endmodule
