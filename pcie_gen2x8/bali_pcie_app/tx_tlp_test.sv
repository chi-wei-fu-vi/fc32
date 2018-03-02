/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-06-07 16:35:27 -0700 (Thu, 07 Jun 2012) $
* $Revision:  $
* Description:
*
*
* Upper level dependencies:  bali_pcie_app.sv
* Lower level dependencies:  none
*
* Revision History Notes:
*
*
***************************************************************************/

module tx_tlp_test
(
  input                          iRST,
  input                          iCLK,

  input                          iSEND_TLP,

  // Arbitration
  output logic                   oREQ,
  input                          iGNT,

  // App Avalon Streaming Bus I/F
  output pcie_app_pkg::tx_st_avalon_type       oTX_ST,
  output logic [255:0]           oTX_DATA,

  input [12:0]                   iCFG_BUSDEV,   // from HIP
  input [2:0]                    iFN_NUM

);
import pcie_app_pkg::*;



typedef enum {IDLE_ST,
              REQ_ST,
              XFER_TLP0_SOP_ST,
              XFER_TLP0_ST,
              XFER_TLP0_EOP_ST,
              DONE_ST
              } state_e;

state_e       ps, ns;

logic [127:0] tlp_data,tlp_st,tlp_ed;

logic [7:0]   wait_ctr;

hdr0_type     mwr_hdr0;
hdr1_type     mwr_hdr1;
hdr2_3_type   mwr_hdr2_3;

logic [5:0]   payld_tick_ctr;
   localparam my_pay_sz = 512;
   localparam paysz_st = my_pay_sz - 32;
   localparam paycyc = paysz_st / 32 - 1;
   localparam paydw = my_pay_sz / 4;
// Notes:
// 4KB is 2x2048byte TLP's or 2x0x800
// Posted = "fire and forget"
// All read-requests and non-posted Write requests require completions
// All I/O Read/Write are non-posted and require completions
//


assign tlp_data[127:0] =
{
32'haaaa1111,
32'haaaa2222,
32'haaaa3333,
32'haaaa4444
};

   assign tlp_st[127:0] = {4{32'hbab0bab0}};
   assign tlp_ed[127:0] = {4{32'hedfaedfa}};

 always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    payld_tick_ctr <= '0;
  else
  begin
    if(ps == XFER_TLP0_ST)
      payld_tick_ctr <= payld_tick_ctr + 1'b1;
    else
      payld_tick_ctr <= '0;
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
    mwr_hdr0.length         <= paydw;   // Altera Table 1-3 / PCIE Spec 2.2.2 - integral #DW

    mwr_hdr1.req_id.bus_num <= iCFG_BUSDEV[12:5];
    mwr_hdr1.req_id.dev_num <= iCFG_BUSDEV[4:0];
    mwr_hdr1.req_id.fn_num  <= iFN_NUM;

    mwr_hdr1.tag            <= 8'b0; // undefined for posted MWr.
    mwr_hdr1.lbe            <= 4'hF; // (2048mod4=0)
    mwr_hdr1.fbe            <= 4'hF; // (2048mod4=0)

    // Assumed that all TLP MWr use (4DW) 64-bit addressing.
    // System software agrees to setup buffers above 4GB.
    mwr_hdr2_3.upper_addr     <= 32'h2;
    mwr_hdr2_3.lower_addr     <= 0;    // TLP address is 4-byte aligned
    mwr_hdr2_3.rsv1           <= 2'b0; // lower 2-bits of address reserved (always zero).
  end
end


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
//
//////////////////////////////////////////////////////////////////////////////
always_comb
begin

  case(ps)
                 IDLE_ST: begin
                            if(iSEND_TLP)               ns = REQ_ST;
                            else                        ns = IDLE_ST;
                          end
                  REQ_ST: begin
                            if(iGNT)                    ns = XFER_TLP0_SOP_ST;
                            else                        ns = REQ_ST;
                          end
         XFER_TLP0_SOP_ST: begin
                                                        ns = XFER_TLP0_ST;
                          end
            XFER_TLP0_ST: begin
                          if(payld_tick_ctr == paycyc) ns = XFER_TLP0_EOP_ST;
                            else                        ns = XFER_TLP0_ST;
                          end
        XFER_TLP0_EOP_ST: begin
                                                        ns = DONE_ST;
                          end

                 DONE_ST: begin
                            if(!iGNT)                   ns = IDLE_ST;
                            else                        ns = DONE_ST;
                          end
                 default: begin
                                                        ns = IDLE_ST;
                          end
   endcase
 end


//////////////////////////////////////////////////////////////////////////////
//
// FSM Output
//
//////////////////////////////////////////////////////////////////////////////
always_comb
begin
  // default
  oREQ            = 1'b0;

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
                            end
                    REQ_ST: begin
                              oREQ = 1'b1;
                            end
          XFER_TLP0_SOP_ST: begin
                              oREQ = 1'b1;
                              oTX_ST.sop = 1'b1;
                              oTX_ST.valid  = 1'b1;
                              oTX_DATA = {tlp_st[127:0], mwr_hdr2_3, mwr_hdr1, mwr_hdr0}; // MWr (4DW)
                            end
           XFER_TLP0_ST : begin
              oREQ = 1'b1;
              oTX_ST.valid = 1'b1;
              oTX_DATA = {tlp_data[127:0],tlp_data[127:0]};
           end
           XFER_TLP0_EOP_ST: begin
              oREQ = 1'b1;
              oTX_ST.eop = 1'b1;
              oTX_ST.empty = AVALON_127_0_VALID;
              oTX_ST.valid  = 1'b1;
              oTX_DATA = {128'b0, tlp_ed[127:0]};
           end
                   DONE_ST: begin
                              oREQ = 1'b0;
                            end
  endcase
end


endmodule
