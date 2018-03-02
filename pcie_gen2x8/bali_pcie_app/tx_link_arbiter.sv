/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: 2012-06-07 16:35:27 -0700 (Thu, 07 Jun 2012) $
* $Revision:  $
* Description:
* This module provides a multi-port interface designed allow bursts of 4KB
* of data destined for CPU memory via a DMA transfer.
*
* Pipeline latency = ~131 clocks (variable due to fifo i/f)
*
* readyLatency = 0. If GNT then may write immediately and continuously w/out interruption
* exactly 4KB of data.
* DPLBUF I/F
* 1 clock latency from initial request to grant.
* 2 clock latency from de-assert request to issuing grant to another port
*
* Upper level dependencies: bali_pcie_app.sv
* Lower level dependencies: tx_link_arbiter_sc_fifo_512x256, tx_link_arbiter_misc_sc_fifo_4x4
*
* Revision History Notes:
* 2012/07/12 Tim - initial release
* 2012/08/20 Tim - Added iDPLBUF_FULL condition necessary for transitioning into GNT_LATCH_ST.
*
***************************************************************************/
//
// Input Control/Data Signals for delivering 4 clock cycles of data.
// Must send exactly 4KB of data per request.
//
//                _   _   _   _   _   _   _   _   _   _   _   _
// iCLK        |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_|
//                    _ _ _ _                _ _ _ _
// iREQ         _ _ _|       |_ _ _ _ _ _ _ |        |_ _ _ _ _ _
//                        _ _                     _ _
// oGNT         _ _ _ _ _|   |_ _ _ _ _ _ _ _ _ _|   | _ _ _ _ _
//                            _ _ _ _ _ _ _ _ _ _ _ _ _ _
// iDATA_V      _ _ _ _ _ _ _|                           |_ _ _ _
//                            _ _ _ _ _ _ _ _ _ _ _ _ _ _
// iDATA        _ _ _ _ _ _ _|_1_|_2_|_3_|_4_|_5_|_6_|_7_|_ _ _


///////////////////////////////////////////////////////////////////////////////
//
// Includes
//
///////////////////////////////////////////////////////////////////////////////

module tx_link_arbiter #(

parameter   PORTS                       = 12,
parameter   PORT_WIDTH                  = $clog2( PORTS )    )

(
  input                                    iRST,
  input                                    iCLK,

  input  [PORTS-1:0]                       iDPLBUF_FULL,

  // Link Arbiter FIFO Write I/F
  input  [PORTS-1:0]                       iDPLBUF_REQ,
  output [PORTS-1:0]                       oDPLBUF_GNT,
  input  [255:0]                           iDPLBUF_DATA,
  input  [PORTS-1:0]                       iDPLBUF_DATA_V,

  // Link Arbiter FIFO Read I/F
  output                                   oFIFO_FULL,
  output  [7:0]                            oFIFO_USED,          // 4096 bytes / 32 = 128. So 256 elements in FIFO
  output  [255:0]                          oFIFO_DATA,
  output                                   oFIFO_EMPTY,
  output  [PORT_WIDTH-1:0]                 oLINK_NUMBER,
  input                                    iFIFO_RD_ACK,
  input                                    iBLK_DONE_PULSE,

  // HIP Arbiter
  input                                    iHIP_BLK_DONE,
  input   [PORT_WIDTH-1:0]                 iHIP_LINK_NUMBER,

  // Register
  output logic [PORTS-1:0]                 oREG_FLUSHSTATUS,
  output logic [PORTS-1:0][2:0]            oREG_FLUSH_CTR_BLK_FLUSH_CTR,
  output logic                             oREG_HIP_BLK_DONE_CNT_EN,
  output logic                             oREG_GNT_CNT_EN,
  output logic                             oREG_DPL_FIFO_WRREQ_CNT_EN,
  output logic                             oREG_TX_BLK_DONE_CNT_EN,
  output logic                             oREG_LINK_NUM_FIFO_WR_PULSE_EN,
  output logic [7:0]                       oREG_DEBUG_LINK_ARB_FIFO_USED,
  output logic                             oREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_FULL,
  output logic                             oREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_EMPTY,
  output logic                             oREG_DEBUG_LINK_ARB_FIFO_EMPTY,
  output logic                             oREG_DEBUG_LINK_ARB_FIFO_FULL,
  output logic                             oREG_DEBUG_LINK_ARB_FIFO_BLK_AVAIL,
  output logic [2:0]                       oREG_DEBUG_LINK_ARB_ARB_PS
  );
import bali_lib_pkg::*;

parameter   PORTS_ROUNDUP               = 2 ** PORT_WIDTH;

  logic [PORTS_ROUNDUP-1:0] gnt_r, gnt_next;
  logic [PORT_WIDTH-1:0] link_number, link_number_nxt;
  logic [7-PORT_WIDTH:0] link_numer_fifo_msb;
  logic       fifo_full;
  logic [7:0] fifo_used;
  logic       fifo_blk_avail; // space for 4KB block;
  logic       blk_almost_done_r;
  logic       any_data_v;
  logic       any_data_v_d1_r;
  logic [6:0] blk_cyc_ctr_r;

  typedef enum {IDLE_ST,
                REQ_ST,
                GNT_LATCH_ST,
                XFER_ST
              } state_e;

  state_e ps, ns;

  logic [255:0] dplbuf_data;
  logic [PORTS-1:0]  dplbuf_data_v;

  // For debug / assertions.
  logic       link_number_fifo_wr_pulse;
  logic       link_number_fifo_empty;
  logic       link_number_fifo_full;

  logic [PORTS-1:0] dec_blk_ctr_r;
  logic [PORTS-1:0][2:0] blk_flush_ctr;

  assign fifo_blk_avail = (fifo_used > 8'd128 || fifo_full)? 1'b0 : 1'b1;  // is there space for 4KB block (FIFO depth = 128)

  ///////////////////////////////////////////////////////////////////////////
  //
  // Assign outputs
  //
  ///////////////////////////////////////////////////////////////////////////
  assign oDPLBUF_GNT = gnt_r[PORTS-1:0];
  assign oFIFO_FULL  = fifo_full;
  assign oFIFO_USED  = fifo_used;
  assign oREG_HIP_BLK_DONE_CNT_EN                = iHIP_BLK_DONE;
  assign oREG_GNT_CNT_EN                         = |gnt_r[PORTS_ROUNDUP-1:0];
  assign oREG_DPL_FIFO_WRREQ_CNT_EN              = |dplbuf_data_v;
  assign oREG_TX_BLK_DONE_CNT_EN                 = iBLK_DONE_PULSE;
  assign oREG_LINK_NUM_FIFO_WR_PULSE_EN          = link_number_fifo_wr_pulse;
  assign oREG_DEBUG_LINK_ARB_FIFO_USED           = fifo_used;
  assign oREG_DEBUG_LINK_ARB_FIFO_EMPTY          = oFIFO_EMPTY;
  assign oREG_DEBUG_LINK_ARB_FIFO_FULL           = fifo_full;
  assign oREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_FULL  = link_number_fifo_full;
  assign oREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_EMPTY = link_number_fifo_empty;
  assign oREG_DEBUG_LINK_ARB_FIFO_BLK_AVAIL      = fifo_blk_avail;
  assign oREG_DEBUG_LINK_ARB_ARB_PS              = ps;


  ///////////////////////////////////////////////////////////////////////////
  //
  // FLOP Data Inputs
  //
  ///////////////////////////////////////////////////////////////////////////
  always_ff @(posedge iCLK or posedge iRST)
  begin
    if(iRST)
    begin
      dplbuf_data       <= '{default:0};
      dplbuf_data_v     <= '{default:0};
    end
    else
    begin
      dplbuf_data       <= iDPLBUF_DATA;
      dplbuf_data_v     <= iDPLBUF_DATA_V;
    end
  end


//////////////////////////////////////////////////////////////////////////////
//
// Arbiter
//
//////////////////////////////////////////////////////////////////////////////
arbiter_round_robin
#(
  .WIDTH   (PORTS_ROUNDUP)
)
arbiter_round_robin_inst
(
  .iRST    ( iRST                                                           ),
  .iCLK    ( iCLK                                                           ),
  .iREQ    ( {{(PORTS_ROUNDUP-PORTS){1'b0}}, (iDPLBUF_REQ & ~iDPLBUF_FULL)} ),
  .oGNT    ( gnt_next                                                       )
);


//////////////////////////////////////////////////////////////////////////////
//
// FSM Sequenctial Logic
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
//
//////////////////////////////////////////////////////////////////////////////
always_comb
begin
  case(ps)
                  IDLE_ST: begin
                            if(|(iDPLBUF_REQ & ~iDPLBUF_FULL) && fifo_blk_avail)
                                                     ns = REQ_ST;
                            else
                                                     ns = IDLE_ST;
                           end
                   REQ_ST: begin
                                                     ns = GNT_LATCH_ST;
                           end
             GNT_LATCH_ST: begin
                                                     ns = XFER_ST;
                           end
                  XFER_ST: begin
                            if(blk_almost_done_r)
                                                     ns = IDLE_ST;
                            else
                                                     ns = XFER_ST;
                          end
  endcase
end


//////////////////////////////////////////////////////////////////////////////
//
// FSM Registered Outputs
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    gnt_r   <= {PORTS_ROUNDUP{1'b0}};
    link_number <= '0;
    link_number_fifo_wr_pulse <= 1'b0;
  end
  else
  begin
    case (ns)
                IDLE_ST: begin
                                gnt_r       <= {PORTS_ROUNDUP{1'b0}};
                                link_number <= '0;
                                link_number_fifo_wr_pulse <= 1'b0;
                         end
           GNT_LATCH_ST: begin
                                gnt_r       <= gnt_next; // only offer grant to a requester if corresponding DPLBUF not full
                                link_number <= link_number_nxt;
                                link_number_fifo_wr_pulse <= 1'b1;
                         end
                XFER_ST: begin
                                gnt_r       <= {PORTS_ROUNDUP{1'b0}};
                                link_number <= link_number; // hold
                                link_number_fifo_wr_pulse <= 1'b0;
                         end
    endcase
  end
end

vi_onehot_to_bin #(
        .ONEHOT_WIDTH       ( PORTS_ROUNDUP     ),
        .BIN_WIDTH          ( PORT_WIDTH        )
) u_onehot_to_bin (
    .onehot         ( gnt_next          ),
    .bin            ( link_number_nxt   )
);

// show-ahead. rdreq is actually an ack.
//tx_link_arbiter_sc_fifo_512x256 tx_link_arbiter_sc_fifo_512x256_inst

wire                  almost_full;
wire                  almost_empty;
wire                  underflow;
wire                  wr_rst_busy;
wire                  rd_rst_busy;
wire                  overflow;
tx_link_arbiter_sc_fifo_256x256 tx_link_arbiter_sc_fifo_256x256_inst
(//inputs
 . almost_full          ( almost_full                                        ), // output
 . almost_empty         ( almost_empty                                       ), // output
 . underflow            ( underflow                                          ), // output
 . wr_rst_busy          ( wr_rst_busy                                        ), // output
 . rd_rst_busy          ( rd_rst_busy                                        ), // output
 . overflow             ( overflow                                           ), // output
 . din                  ( dplbuf_data                                        ), 
 . full                 ( fifo_full                                          ), 
 . dout                 ( oFIFO_DATA                                         ), 
 . data_count           ( fifo_used                                          ), // fixme 8 vs 9
 . clk                  ( iCLK                                               ), //outputs
 . wr_en                ( |dplbuf_data_v                                     ), // only port w/ grant can write fifo.
 . rd_en                ( iFIFO_RD_ACK                                       ), 
 . rst                  ( iRST                                               ), 
 . empty                ( oFIFO_EMPTY                                        )  
);


// show-ahead. rdreq is actually an ack.

wire      misc_almost_full;
wire      misc_almost_empty;
wire      misc_underflow;
wire      misc_wr_rst_busy;
wire      misc_rd_rst_busy;
wire      misc_overflow;
tx_link_arbiter_misc_sc_fifo_4x8 link_number_sc_fifo_4x8
(
 . almost_full          ( misc_almost_full                                   ), // output
 . almost_empty         ( misc_almost_empty                                  ), // output
 . underflow            ( misc_underflow                                     ), // output
 . wr_rst_busy          ( misc_wr_rst_busy                                   ), // output
 . rd_rst_busy          ( misc_rd_rst_busy                                   ), // output
 . overflow             ( misc_overflow                                      ), // output
 . din                  ( {{(8-PORT_WIDTH){1'b0}}, link_number[PORT_WIDTH-1:0]} ), 
 . full                 ( link_number_fifo_full                              ), 
 . dout                 ( {link_numer_fifo_msb, oLINK_NUMBER[PORT_WIDTH-1:0]} ), 
 . data_count           (                                                    ), // fixme 2 vs 5
 . clk                  ( iCLK                                               ), 
 . wr_en                ( link_number_fifo_wr_pulse                          ), 
 . rd_en                ( iBLK_DONE_PULSE                                    ), 
 . rst                  ( iRST                                               ), 
 . empty                ( link_number_fifo_empty                             )  
);


//////////////////////////////////////////////////////////////////////////////
//
// 4KB Data Transfer Cycle Counter
//
//////////////////////////////////////////////////////////////////////////////
assign any_data_v = |iDPLBUF_DATA_V;

always_ff @(posedge iCLK)
    any_data_v_d1_r <= any_data_v;

always_ff @(posedge iRST or posedge iCLK)
    if( iRST )
        blk_cyc_ctr_r <= 7'b0;
    else if ( any_data_v & ~any_data_v_d1_r )
        blk_cyc_ctr_r <= 7'b1;
    else if ( any_data_v )
        blk_cyc_ctr_r <= blk_cyc_ctr_r + 7'b1;

always_ff @(posedge iRST or posedge iCLK)
    if( iRST )
        blk_almost_done_r <= 1'b0;
    else
        blk_almost_done_r <= ( blk_cyc_ctr_r == 7'd120 );

//////////////////////////////////////////////////////////////////////////////
//
// 4KB Block Flush Counter
//
//////////////////////////////////////////////////////////////////////////////
genvar ii;
generate
    for ( ii=0; ii<PORTS; ii++ ) begin: flush_ctr_generate
        always_ff @(posedge iRST or posedge iCLK)
            if( iRST )
                dec_blk_ctr_r[ii] <= 1'b0;
            else
                dec_blk_ctr_r[ii] <= iHIP_BLK_DONE & (iHIP_LINK_NUMBER == ii);

        always_ff @(posedge iRST or posedge iCLK)
            if( iRST )
                blk_flush_ctr[ii] <= 3'b0;
            else
                case ({gnt_r[ii], dec_blk_ctr_r[ii]})
                    2'b00: blk_flush_ctr[ii] <= blk_flush_ctr[ii];
                    2'b01: blk_flush_ctr[ii] <= blk_flush_ctr[ii] - 3'b1;
                    2'b10: blk_flush_ctr[ii] <= blk_flush_ctr[ii] + 3'b1;
                    2'b11: blk_flush_ctr[ii] <= blk_flush_ctr[ii];
                endcase

        always_ff @(posedge iRST or posedge iCLK)
            if( iRST )
                oREG_FLUSHSTATUS[ii] <= 1'b0;
            else
                oREG_FLUSHSTATUS[ii] <= (blk_flush_ctr[ii] == 3'b0);

       assign oREG_FLUSH_CTR_BLK_FLUSH_CTR[ii][2:0]    = blk_flush_ctr[ii][2:0];

    end
endgenerate

// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////

final begin
    assert_blk_flush_done: assert ( oREG_FLUSHSTATUS == {PORTS{1'b1}} );
end



// synopsys translate_on



endmodule

