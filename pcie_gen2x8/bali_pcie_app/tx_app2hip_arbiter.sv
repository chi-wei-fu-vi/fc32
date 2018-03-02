/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: tim.beyers $
* $Date: 2012-08-24 14:18:24 -0700 (Fri, 24 Aug 2012) $
* $Revision: 130 $
* Description:
* This module arbitrates between up to three ports that deliver TLP packets
* to the Altera HIP core via the Avalon streaming interface.
*
* Pipeline latency = 2 clocks
*
* Upper level dependencies: bali_pcie_app.sv
* Lower level dependencies: tx_app2hip_sc_fifo_256x256, tx_app2hip_sc_fifo_48x256
*
* Revision History Notes:
* 2012/07/09 Tim - initial release
* 2012/08/23 Tim - Moved gnt_r1 to always_ff
* 2013/03/29 Tim - Adjust iTX_ST_READY latency
* 2013/03/31 Tim - Adjusted criteria for fifo_has_room_4k (DFPE-21)
*
***************************************************************************/


///////////////////////////////////////////////////////////////////////////////
//
// Includes
//
///////////////////////////////////////////////////////////////////////////////

module tx_app2hip_arbiter #(

parameter   BALI                        = 0,
parameter   PORTS                       = 12,
parameter   PORT_WIDTH                  = $clog2( PORTS )    )

(
  input                           iRST,
  input                           iCLK,

  // Arbitration
  input  [2:0]                    iREQ,
  output [2:0]                    oGNT,

  // Single-Cycle & DMA Avalon Streaming I/F
  input  pcie_app_pkg::tx_st_avalon_type [2:0]  iTX_ST,
  input  [2:0][255:0]             iTX_ST_DATA,
  input  [PORT_WIDTH-1:0]         iLINK_NUMBER,
  input                           iBLK_DONE_PULSE,

  // HIP Avalon Streaming Bus I/F
  input                           iTX_ST_READY,
  output pcie_app_pkg::tx_st_avalon_type        oTX_ST,
  output logic [255:0]                  oTX_ST_DATA,

  // Link Arbiter
  output logic                    oHIP_BLK_DONE,
  output logic [PORT_WIDTH-1:0]   oHIP_LINK_NUMBER
);
import pcie_app_pkg::*;
import bali_lib_pkg::*;


  logic fifo_rd_en;
  logic fifo_wr_en;
  logic fifo_empty;
  logic fifo_has_room_4k;
  logic [255:0] fifo_data;
  logic [8:0] fifo_usedw;
  logic       fifo_full;
  logic fifo_data_valid;

  logic [1:0] hip_ready_pipe;

  typedef enum {IDLE_ST,
                REQ_ST,
                GNT_ST
              } state_e;

  state_e ps, ns;

  logic [2:0] gnt_r1, gnt_next;
  logic [1:0] gnt_enc;

  tx_st_avalon_type tx_st_ctrl;

  logic [PORT_WIDTH-1:0] hip_link_number;
  logic hip_4kb_done, dma_4kb_done;

//////////////////////////////////////////////////////////////////////////////
//
// Outputs
//
//////////////////////////////////////////////////////////////////////////////
// Pull in oGNT one cycle using ns
assign oGNT = gnt_r1 | ({3{(ns == REQ_ST)}} & gnt_next);


//lz (4/12/2014) : add extra stage flop to help w/ meeting timing for PCIe
//Gen3

generate

if (BALI == 0) begin : gen_no_bali
// The fifo continues to drive it's output after becoming empty
// so must validate output
//assign oTX_ST_DATA   = fifo_data      & {256{fifo_data_valid}};
assign oTX_ST_DATA   = fifo_data; //  & {256{fifo_data_valid}}; // tmb (3/29/2013) - removed force to zero when valid de-asserted.

assign oTX_ST.sop    = tx_st_ctrl.sop   & fifo_data_valid;
assign oTX_ST.eop    = tx_st_ctrl.eop   & fifo_data_valid;
assign oTX_ST.valid  = tx_st_ctrl.valid & fifo_data_valid;
assign oTX_ST.empty  = tx_st_ctrl.empty;
assign oTX_ST.err    = tx_st_ctrl.err;
assign oTX_ST.parity = tx_st_ctrl.parity;

end : gen_no_bali


// Add extra flop 
if (BALI == 1) begin : gen_bali
  always @(posedge iCLK or posedge iRST)
  if (iRST)
  begin
    oTX_ST_DATA   <= 'h0;
    oTX_ST.sop    <= 'h0;
    oTX_ST.eop    <= 'h0;
    oTX_ST.valid  <= 'h0;
    oTX_ST.empty  <= 'h0;
    oTX_ST.err    <= 'h0;
    oTX_ST.parity <= 'h0;
  end
  else
  begin
    oTX_ST_DATA   <= fifo_data;
    oTX_ST.sop    <= tx_st_ctrl.sop   & fifo_data_valid;
    oTX_ST.eop    <= tx_st_ctrl.eop   & fifo_data_valid;
    oTX_ST.valid  <= tx_st_ctrl.valid & fifo_data_valid;
    oTX_ST.empty  <= tx_st_ctrl.empty;
    oTX_ST.err    <= tx_st_ctrl.err;
    oTX_ST.parity <= tx_st_ctrl.parity;
  end
end : gen_bali

endgenerate
//////////////////////////////////////////////////////////////////////////////
//
// Arbiter
//
//////////////////////////////////////////////////////////////////////////////
arbiter_fixed_priority
#(
  .WIDTH   (3)
)
arbiter_fixed_priority_inst
(
  .iREQ   (iREQ),
  .oGNT   (gnt_next),
  .iBASE  (8'b1)  // least-significant port gets highest priority (registers)
);


//////////////////////////////////////////////////////////////////////////////
//
// FSM Sequential Logic
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iCLK or posedge iRST)
  if(iRST)
    ps <= IDLE_ST;
  else
    ps <= ns;

//////////////////////////////////////////////////////////////////////////////
//
// FSM Next State Logic
// Each requester must write entire TLP into FIFO.
// Upon completion the requester deasserts request and the grant
// will de-assert only after the FIFO has finished draining. This simplification
// removes the requirement of backpressure to requester.
//
//////////////////////////////////////////////////////////////////////////////
always_comb
begin

  case(ps)
                 IDLE_ST: begin
                            if(|iREQ && fifo_has_room_4k)  ns = REQ_ST;
                            else                     ns = IDLE_ST;
                          end
                  REQ_ST: begin
                                                     ns = GNT_ST;
                          end
                  GNT_ST: begin
                            if(!iREQ[gnt_enc])       ns = IDLE_ST;
                            else                     ns = GNT_ST;
                          end
                 default: begin
                                                     ns = IDLE_ST;
                          end
  endcase
end


//////////////////////////////////////////////////////////////////////////////
//
// FSM Registered Output
//
//////////////////////////////////////////////////////////////////////////////
// Pull in gnt_r1 one cycle using ns
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    gnt_r1 <= 1'b0;
  else
    if(ns == IDLE_ST)
      gnt_r1 <= 3'b0;
    else if(ns == REQ_ST)
      gnt_r1 <= gnt_next;
end

assign gnt_enc = encoder_4_2(gnt_r1);

//////////////////////////////////////////////////////////////////////////////
//
// FIFO Control signals
//
// If TLP payload size is 128 bytes then there are 32 TLP's in a 4KB transfer.
// Each TLP header is 4DW but bubble so each header takes 32 bytes
// 4KB data + 32x32 header = 5120 bytes
// 5120 / 32 = 160 (slots in 256x512 FIFO).
// So fifo_usedw <= (512-160) <= 352
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iCLK)
    fifo_has_room_4k <= (fifo_usedw < 9'd350 && !fifo_full) ? 1'b1 : 1'b0; // tmb (2013-03-31) (Bug fix - DFPE-21)

// if ready==0 || ready[0]==0 || ready[1]==0 then de-assert read
// if ready && ready[0] && ready[1] then assert read

assign fifo_wr_en = iTX_ST[gnt_enc].valid;
// assign fifo_rd_en = hip_ready_pipe[1] & !fifo_empty;

// assign fifo_rd_en = (iTX_ST_READY & !fifo_empty ) ? 1'b1 : 1'b0; // tmb - de-assert/assert latency 1 cycle
assign fifo_rd_en = (hip_ready_pipe[0] & !fifo_empty) ? 1'b1 : 1'b0; // tmb - de-assert/assert latency 2 cycles


always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    fifo_data_valid <= 1'b0;
  else
    fifo_data_valid <= fifo_rd_en; // 1 cycle after fifo_rd_en valid data is returned
end


// ready latency is 1-3 clocks. Altera documentation is unclear.
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    hip_ready_pipe <= '0;
  else
    hip_ready_pipe <= {hip_ready_pipe[0], iTX_ST_READY};

end

//////////////////////////////////////////////////////////////////////////////
//
// FIFOs
//
//////////////////////////////////////////////////////////////////////////////

wire             data_almost_full;
wire             data_almost_empty;
wire             data_underflow;
wire             data_wr_rst_busy;
wire             data_rd_rst_busy;
wire             data_overflow;
tx_app2hip_sc_fifo_256x512 data_sc_fifo_256x512_inst
(
 . almost_full          ( data_almost_full                                   ), // output
 . almost_empty         ( data_almost_empty                                  ), // output
 . underflow            ( data_underflow                                     ), // output
 . wr_rst_busy          ( data_wr_rst_busy                                   ), // output
 . rd_rst_busy          ( data_rd_rst_busy                                   ), // output
 . overflow             ( overflow                                           ), // output
 . din                  ( iTX_ST_DATA[gnt_enc]                               ), 
 . full                 ( fifo_full                                          ), 
 . dout                 ( fifo_data                                          ), 
 . data_count           ( fifo_usedw                                         ), 
 . clk                  ( iCLK                                               ), 
 . wr_en                ( fifo_wr_en                                         ), 
 . rd_en                ( fifo_rd_en                                         ), 
 . rst                  ( iRST                                               ), 
 . empty                ( fifo_empty                                         )  
);


assign dma_4kb_done = iBLK_DONE_PULSE & iTX_ST[gnt_enc].valid;


wire      ctrl_almost_full;
wire      ctrl_almost_empty;
wire      ctrl_underflow;
wire      ctrl_wr_rst_busy;
wire      ctrl_rd_rst_busy;
wire      ctrl_overflow;
tx_app2hip_sc_fifo_48x512 ctrl_sc_fifo_48x512_inst
(
 . almost_full          ( ctrl_almost_full                                   ), // output
 . almost_empty         ( ctrl_almost_empty                                  ), // output
 . underflow            ( ctrl_underflow                                     ), // output
 . wr_rst_busy          ( ctrl_wr_rst_busy                                   ), // output
 . rd_rst_busy          ( ctrl_rd_rst_busy                                   ), // output
 . overflow             ( ctrl_overflow                                      ), // output
 . din                  ( {dma_4kb_done, iLINK_NUMBER, iTX_ST[gnt_enc]}      ), 
 . full                 (                                                    ), 
 . dout                 ( {hip_4kb_done, hip_link_number, tx_st_ctrl}        ), 
 . data_count           (                                                    ), 
 . clk                  ( iCLK                                               ), 
 . wr_en                ( fifo_wr_en                                         ), 
 . rd_en                ( fifo_rd_en                                         ), 
 . rst                  ( iRST                                               ), 
 . empty                (                                                    )  
);


//////////////////////////////////////////////////////////////////////////////
//
// 4K Block Completion
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    oHIP_BLK_DONE <= '0;
  else
    oHIP_BLK_DONE <= hip_4kb_done & fifo_data_valid;
end

always_ff @(posedge iCLK)
    oHIP_LINK_NUMBER <= hip_link_number;


// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
// Data shall not be x when VALID
assert_avalon_tx_data_unknown: assert property ( @( posedge iCLK )
    oTX_ST.valid |-> !$isunknown( oTX_ST_DATA ) );

// Temporary assertion
// Check whether iTX_ST_READY is ever de-asserted.
assert_avalon_tx_ready_deassert: assert property ( @( posedge iCLK )
    disable iff ( iRST )
    !$fall( iTX_ST_READY ) );


// synopsys translate_on

endmodule
