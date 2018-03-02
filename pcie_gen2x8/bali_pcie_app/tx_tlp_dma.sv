/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-06-07 16:35:27 -0700 (Thu, 07 Jun 2012) $
* $Revision:  $
* Description:
* This module reads a 4KB data block from a FIFO and constructs two 2048-byte
* TLP and packetizes using the Avalon streaming interface.
*
*
* Upper level dependencies:  bali_pcie_app.sv
* Lower level dependencies:  none
*
* Revision History Notes:
* 2012/07/17 Tim - initial release
* 2012/08/21 Tim - Increment write pointer (oDPLBUF_INC_WR_PTR) earlier
*                  (XFER_TLP1_SOP_ST) to avoid issuing grant earlier in pipeline
*                  to a full buffer.
*
* The X8DTL-iF motherboard only supports maximum of 256 byte payload TLP
* To accommodate this reduction in payload size, a workaround has been implemented
* to so the 4KB block is transferred across 16 TLP's, each TLP being 256 bytes.
* Since there is 128-bits of header in each TLP, each TLP is 9 clock ticks,
* with the final tick using the empty signal to indicate only 128-bits in size.
*
*
***************************************************************************/

module tx_tlp_dma #(

parameter   PORTS                       = 12,
parameter   PORT_WIDTH                  = $clog2( PORTS )    )

(
  input                          iRST,
  input                          iCLK,

  // Link Arbiter FIFO I/F
  input                          iFIFO_FULL,
  input  [7:0]                   iFIFO_USED,          // 4096 bytes / 32 = 128. So 256 elements in FIFO
  input  [255:0]                 iFIFO_DATA,
  input                          iFIFO_EMPTY,
  output logic                   oFIFO_RD_ACK,
  output logic                   oBLK_DONE_PULSE,

  input logic [PORT_WIDTH-1:0]   iLINK_NUMBER,

  // Register
  input  [2:0]                   iREG_MAXPYLD,

  // Arbitration
  output logic                   oREQ,
  input                          iGNT,

  // App Avalon Streaming Bus I/F
  output pcie_app_pkg::tx_st_avalon_type       oTX_ST,
  output logic [255:0]           oTX_DATA,
  output logic [PORT_WIDTH-1:0]  oLINK_NUMBER,

  input [12:0]                   iCFG_BUSDEV,   // from HIP
  input [2:0]                    iFN_NUM,

  // Next DPL Address
  input  [PORTS-1:0][31:0]       iDPLBUF_WR_PTR,
  output logic [PORTS-1:0]       oDPLBUF_INC_WR_PTR
);
import pcie_app_pkg::*;



typedef enum {IDLE_ST,
              REQ_ST,
              XFER_TLP_SOP_ST,
              XFER_TLP_ST,
              XFER_TLP_EOP_ST,
              DONE_ST
              } state_e;

state_e       ps, ns;

hdr0_type     mwr_hdr0;
hdr1_type     mwr_hdr1;
hdr2_3_type   mwr_hdr2_3;

logic [63:0] dplbuf_wr_ptr_bytewise;
logic [63:0] dplbuf_wr_ptr_nextaddr;

logic [6:0]   payld_tick_ctr, payld_tick_max;
logic [127:0] fifo_data_hold;

logic blk_ready;

logic [5:0] tlp_ctr, tlp_ctr_max;

// Notes:
// 4KB is 2x2048byte TLP's or 2x0x800
// Posted = "fire and forget"
// All read-requests and non-posted Write requests require completions
// All I/O Read/Write are non-posted and require completions
//


assign dplbuf_wr_ptr_bytewise = {iDPLBUF_WR_PTR[iLINK_NUMBER], 12'b0}; // convert PFN that is 4KB aligned to byte address
//assign dplbuf_wr_ptr_nextaddr = (ps == DONE_ST) ? dplbuf_wr_ptr_bytewise + 12'h800 : dplbuf_wr_ptr_bytewise;


//////////////////////////////////////////////////////////////////////////////
//
// Next address
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    dplbuf_wr_ptr_nextaddr <= '0;
    oDPLBUF_INC_WR_PTR <= 1'b0; // default
  end
  else
  begin
    // oDPLBUF_INC_WR_PTR is a pulse asserted once for each 4KB transfer.
    // It must be done before XFER_TLP_SOP_ST to ensure address ready for first TLP.
    oDPLBUF_INC_WR_PTR <= 1'b0; // default
    if(ns == REQ_ST)
      dplbuf_wr_ptr_nextaddr <= dplbuf_wr_ptr_bytewise;

    // Latch wr_ptr to be used for subsequent TLP's.
    else if(ns == XFER_TLP_SOP_ST && tlp_ctr == 0)
      oDPLBUF_INC_WR_PTR[iLINK_NUMBER] <= 1'b1;
    else if (ns == XFER_TLP_EOP_ST)
      case ( iREG_MAXPYLD )
        3'd0:    dplbuf_wr_ptr_nextaddr <= dplbuf_wr_ptr_nextaddr + 12'h80;    // if tlp = 128 bytes
        3'd1:    dplbuf_wr_ptr_nextaddr <= dplbuf_wr_ptr_nextaddr + 12'h100;   // if tlp = 256 bytes
        3'd2:    dplbuf_wr_ptr_nextaddr <= dplbuf_wr_ptr_nextaddr + 12'h200;   // if tlp = 512 bytes
        3'd3:    dplbuf_wr_ptr_nextaddr <= dplbuf_wr_ptr_nextaddr + 12'h400;   // if tlp = 1024 bytes
        default: dplbuf_wr_ptr_nextaddr <= dplbuf_wr_ptr_nextaddr + 12'h800;   // if tlp = 2048 bytes
      endcase
    else
      dplbuf_wr_ptr_nextaddr <= dplbuf_wr_ptr_nextaddr;
  end
end

//////////////////////////////////////////////////////////////////////////////
//
// Construct TX TLP Header
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    mwr_hdr0   <= '{default:0};
    mwr_hdr1   <= '{default:0};
    mwr_hdr2_3 <= '{default:0};
  end
  else
  begin


    mwr_hdr0.fmt            <= FMT_4DW_W_DATA;
    mwr_hdr0.frm_type       <= TYPE_MWR;
    mwr_hdr0.tc             <= TC0_BEST_EFFORT; // "000"=TC0=Best effort servic class (all devices support)
    mwr_hdr0.td             <= TD_ECRC_NOT_PRESENT;
    mwr_hdr0.ep             <= EP_NOT_POISONED;
    mwr_hdr0.attr           <= {ATTR_DEFAULT_ORDERING,ATTR_DEFAULT_CACHE_COH};
    mwr_hdr0.at             <= AT_DEFAULT_UNTRANSLATED;   // PCIe Spec: table 2-5 (address translation off)

    case ( iREG_MAXPYLD )
        3'd0:    mwr_hdr0.length <= 10'd32;
        3'd1:    mwr_hdr0.length <= 10'd64;
        3'd2:    mwr_hdr0.length <= 10'd128;
        3'd3:    mwr_hdr0.length <= 10'd256;
        default: mwr_hdr0.length <= 10'd512;
    endcase

    mwr_hdr1.req_id.bus_num <= iCFG_BUSDEV[12:5];
    mwr_hdr1.req_id.dev_num <= iCFG_BUSDEV[4:0];
    mwr_hdr1.req_id.fn_num  <= iFN_NUM;

    mwr_hdr1.tag            <= 8'b0; // undefined for posted MWr.
    mwr_hdr1.lbe            <= 4'hF; // (2048mod4=0)
    mwr_hdr1.fbe            <= 4'hF; // (2048mod4=0)

    // Assumed that all TLP MWr use (4DW) 64-bit addressing.
    // System software agrees to setup buffers above 4GB.
    mwr_hdr2_3.upper_addr     <= dplbuf_wr_ptr_nextaddr[63:32];
    mwr_hdr2_3.lower_addr     <= dplbuf_wr_ptr_nextaddr[31:2]; // TLP address is 4-byte aligned
    mwr_hdr2_3.rsv1           <= 2'b0; // lower 2-bits of address reserved (always zero).
  end
end


//////////////////////////////////////////////////////////////////////////////
//
// FIFO DATA HOLD REGISTER
// This register is needed because on the 32-bytes of the TLP, 16-bytes
// of header is sent so only the first 16-bytes of data is sent requiring
// the second group of 16-bytes to be held for the next tick.
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    fifo_data_hold <= '0;
  else
  begin
    if(oFIFO_RD_ACK)
      fifo_data_hold <= iFIFO_DATA[255:128];
  end
end

//////////////////////////////////////////////////////////////////////////////
//
// Payload Tick Counter
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    payld_tick_ctr <= '0;
  else
  begin
    if(ps == XFER_TLP_ST)
      payld_tick_ctr <= payld_tick_ctr + 1'b1;
    else
      payld_tick_ctr <= '0;
  end
end

always_comb
    case ( iREG_MAXPYLD )
        3'd0:    payld_tick_max = 7'd2;    // payload = 5   ticks, minus sop minus eop minus count == 0...
        3'd1:    payld_tick_max = 7'd6;    // payload = 9   ticks, minus sop minus eop minus count == 0...
        3'd2:    payld_tick_max = 7'd14;   // payload = 17  ticks, minus sop minus eop minus count == 0...
        3'd3:    payld_tick_max = 7'd30;   // payload = 33  ticks, minus sop minus eop minus count == 0...
        default: payld_tick_max = 7'd62;   // payload = 65  ticks, minus sop minus eop minus count == 0...
    endcase

//////////////////////////////////////////////////////////////////////////////
//
// TLP Counter
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    tlp_ctr <= '0;
  else
  begin
    if(ps == IDLE_ST)
      tlp_ctr <= '0;
    else if(ps == XFER_TLP_SOP_ST)
      tlp_ctr <= tlp_ctr + 1;
  end
end

always_comb
    case ( iREG_MAXPYLD )
        3'd0:    tlp_ctr_max = 6'd32;   // # tlp's @ 128  bytes = 32
        3'd1:    tlp_ctr_max = 6'd16;   // # tlp's @ 256  bytes = 16
        3'd2:    tlp_ctr_max = 6'd8;    // # tlp's @ 512  bytes = 8
        3'd3:    tlp_ctr_max = 6'd4;    // # tlp's @ 1024 bytes = 4
        default: tlp_ctr_max = 6'd2;    // # tlp's @ 2048 bytes = 2
    endcase

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


assign blk_ready = (iFIFO_USED[7] | iFIFO_FULL) ? 1'b1 : 1'b0; // is a 4KB block ready in  tx_link_arbiter fifo

//////////////////////////////////////////////////////////////////////////////
//
// FSM Next State Logic
//
//////////////////////////////////////////////////////////////////////////////
always_comb
begin

  case(ps)
                 IDLE_ST: begin
                            if(blk_ready)               ns = REQ_ST;
                            else                        ns = IDLE_ST;
                          end
                  REQ_ST: begin
                            if(iGNT)                    ns = XFER_TLP_SOP_ST;
                            else                        ns = REQ_ST;
                          end
         XFER_TLP_SOP_ST: begin
                                                        ns = XFER_TLP_ST;
                          end
             XFER_TLP_ST: begin
                            if(payld_tick_ctr == payld_tick_max)  ns = XFER_TLP_EOP_ST;
                            else                        ns = XFER_TLP_ST;
                          end
        XFER_TLP_EOP_ST:  begin
                                                // iterate until entire 4KB transferred
                            if(tlp_ctr < tlp_ctr_max)
                                                        ns = XFER_TLP_SOP_ST;
                            else
                                                        ns = DONE_ST;
                          end
                 // wait at DONE_ST until request de-asserts and tx_app2hip_arbiter de-asserts gnt
                 DONE_ST: begin
                                                        ns = IDLE_ST;
                          end
                 default: begin
                                                        ns = IDLE_ST;
                          end
   endcase
 end



assign oBLK_DONE_PULSE = (ps == XFER_TLP_EOP_ST && ns == DONE_ST) ? 1'b1 : 1'b0; // must be pulse to avoid double-reading the link number

//////////////////////////////////////////////////////////////////////////////
//
// FSM Output
//
//////////////////////////////////////////////////////////////////////////////
always_comb
begin
  // default
  oREQ            = 1'b0;
  oFIFO_RD_ACK    = 1'b0;
  oTX_ST.sop    = 1'b0;
  oTX_ST.eop    = 1'b0;
  oTX_ST.valid  = 1'b0;
  oTX_ST.empty  = AVALON_255_0_VALID;
  oTX_ST.err    = 1'b0;
  oTX_ST.parity = 32'b0;
  oTX_DATA      = '0;

  unique case(ps)
                   IDLE_ST: begin
                              oREQ = 1'b0;
                              oFIFO_RD_ACK = 1'b0;
                            end
                    REQ_ST: begin
                              oREQ = 1'b1;
                              oFIFO_RD_ACK = 1'b0;
                            end
           XFER_TLP_SOP_ST: begin
                              oREQ = 1'b1;
                              oFIFO_RD_ACK = 1'b1;
                              oTX_ST.sop = 1'b1;
                              oTX_ST.valid  = 1'b1;
                              oTX_DATA = {iFIFO_DATA[127:0], mwr_hdr2_3, mwr_hdr1, mwr_hdr0}; // MWr (4DW)
                            end
               XFER_TLP_ST: begin
                              oREQ = 1'b1;
                              oFIFO_RD_ACK = 1'b1;
                              oTX_ST.valid  = 1'b1;
                              oTX_DATA = {iFIFO_DATA[127:0], fifo_data_hold};
                            end
           XFER_TLP_EOP_ST: begin
                              oREQ = 1'b1;
                              oFIFO_RD_ACK = 1'b0;  // don't ack since only sending [127:0] from holding reg.
                              oTX_ST.eop = 1'b1;
                              oTX_ST.empty = AVALON_127_0_VALID;
                              oTX_ST.valid  = 1'b1;
                              oTX_DATA = {128'b0, fifo_data_hold};
                            end
                   DONE_ST: begin
                              oREQ = 1'b0;
                              oFIFO_RD_ACK = 1'b0;  // don't ack since only sending [127:0] from holding reg.
                            end
  endcase
end

//////////////////////////////////////////////////////////////////////////////
//
// Link Number
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iCLK or posedge iRST)
  if(iRST)
    oLINK_NUMBER <= {PORT_WIDTH{1'b0}};
  else if (ps == REQ_ST)
    oLINK_NUMBER <= iLINK_NUMBER;

//////////////////////////////////////////////////////////////////////////////
//
// Assertion
//
/////////////////////////////////////////////////////////////////////////////
// re-introduce assertion in consideration of new TLP packet size of 256 bytes.
// // altera translate_off
//
//    property check_addr;
//       @(posedge iCLK)
//       (ps == XFER_TLP_SOP_ST) |->
//       (mwr_hdr2_3.upper_addr > 32'h1 && mwr_hdr2_3.lower_addr[8:0] == 9'h0);
//    endproperty
//
// // altera translate_on
endmodule
