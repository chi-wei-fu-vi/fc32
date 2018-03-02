/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-08-29 13:25:12 -0700 (Wed, 29 Aug 2012) $
* $Revision: 141 $
* Description:
*
* This module performs generation of 4KB blocks to drive into the PCIe app.
*
*
* Upper level dependencies:
* Lower level dependencies:  none
*
* Revision History Notes:
* 2012/09/10 Tim - initial release
*
*
***************************************************************************/

module pcie_mwr_bist
#(
     parameter pLINK_NUM = 4'h0    //default value for this link
)
(
  //////////////////////////////////////////////////////////////////////
  // Resets & clock
  //////////////////////////////////////////////////////////////////////
  input                     iRST,
  input                     iCLK,

  //////////////////////////////////////////////////////////////////////
  // Status/Control
  //////////////////////////////////////////////////////////////////////
  input pcie_app_pkg::pcie_bist_ctrl_ty   iCTRL,
  output                    oRUN_DYN,
  output [31:0]             oITER,

  //////////////////////////////////////////////////////////////////////
  // DMA WRITE to DPL BUFFER I/F
  //////////////////////////////////////////////////////////////////////
  output logic              oDPLBUF_REQ,
  input                     iDPLBUF_GNT,
  input                     iANY_DPL_DATA_V,

  output logic [255:0]      oDPLBUF_DATA,
  output logic              oDPLBUF_DATA_V
);
import pcie_app_pkg::*;


logic [15:0]  tx_ctr;
logic [15:0]  payld_ctr;
logic [31:0]  iter_ctr;

logic         dplbuf_req;
logic [255:0] dplbuf_data;
logic         dplbuf_data_v;

typedef enum {IDLE_ST,
              REQ_ST,
              GNT_ST,
              DONE_ST
              } state_e;

state_e       ps, ns;

logic run_pulse;
logic run_r1;
logic [31:0] link_num;
logic grant_pending_r;
logic enter_gnt_st_r;

//////////////////////////////////////////////////////////////////////////////
//
// Detect start
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    run_pulse <= 1'b0;
    run_r1      <= 1'b0;
  end
  else
  begin
    run_r1 <= iCTRL.run;
    if(!run_r1 && iCTRL.run)
      run_pulse <= 1'b1;
    else
      run_pulse <= 1'b0;
  end
end


//////////////////////////////////////////////////////////////////////////////
//
// Registered Outputs
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    oDPLBUF_REQ           <= '0;
    oDPLBUF_DATA_V        <= '0;
  end
  else
  begin
    oDPLBUF_REQ           <= dplbuf_req;
    oDPLBUF_DATA_V        <= dplbuf_data_v;
  end
end

// FIFO data is forced to 0 if not active.
// The BIST data can then be OR'ed together at top level
always_ff @(posedge iCLK)
    oDPLBUF_DATA          <= dplbuf_data_v ? dplbuf_data : '0;

assign oRUN_DYN = (ps == IDLE_ST) ? 1'b0 : 1'b1;
assign oITER = iter_ctr; // number of iterations completed



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
// FSM Next State Logic and Outputs
//
//////////////////////////////////////////////////////////////////////////////
always_comb
begin

  dplbuf_req = 1'b0;

  case(ps)
                 IDLE_ST: begin

                            if(run_pulse && iCTRL.link_en[pLINK_NUM])
                                                                ns = REQ_ST;
                            else                                ns = IDLE_ST;
                          end
                  REQ_ST: begin
                                                                dplbuf_req = 1'b1;
                            if((iDPLBUF_GNT || grant_pending_r)&&!iANY_DPL_DATA_V)
                                                                ns = GNT_ST;
                            else                                ns = REQ_ST;
                          end
                  GNT_ST: begin
                                                                dplbuf_req = 1'b0;
                          if(tx_ctr == 127)
                          begin
                                                              ns = DONE_ST;
                          end
                          else                                ns = GNT_ST;

                          end
                 DONE_ST: begin
                           if(!iCTRL.run)
                                                                ns = IDLE_ST;
                           // iter==0 means run forever
                           else if((iCTRL.iter == 0) ||
                                  (iter_ctr < iCTRL.iter))
                                                                ns = REQ_ST;
                           else // iter_ctr == iCTRL.iter)
                                                                ns = IDLE_ST;
                          end
                 default: begin
                                                                ns = IDLE_ST;
                          end
  endcase
end


assign link_num = pLINK_NUM;
assign dplbuf_data = (payld_ctr == 0) ? {iter_ctr, iter_ctr, iter_ctr, iter_ctr, iter_ctr, iter_ctr, iter_ctr, link_num}
                                      : {payld_ctr+16'd3,payld_ctr+16'd3,payld_ctr+16'd3,payld_ctr+16'd3,
                                         payld_ctr+16'd2,payld_ctr+16'd2,payld_ctr+16'd2,payld_ctr+16'd2,
                                         payld_ctr+16'd1,payld_ctr+16'd1,payld_ctr+16'd1,payld_ctr+16'd1,
                                         payld_ctr,      payld_ctr,      payld_ctr,      payld_ctr};



assign dplbuf_data_v = (ns == GNT_ST || ns == DONE_ST) ? 1'b1 : 1'b0;

//////////////////////////////////////////////////////////////////////////////
//
// FSM Counters
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iCLK or posedge iRST)
begin
  if(iRST)
  begin
    tx_ctr <= '0;
    payld_ctr <= '0;
  end
  else
    case(ns)
          REQ_ST :
            begin
              tx_ctr <= '0;
              payld_ctr <= '0;
            end
          GNT_ST :
            begin
              tx_ctr <= tx_ctr + 1;
              payld_ctr <= payld_ctr +16'd4;
            end
    endcase
end

always_ff @(posedge iCLK or posedge iRST)
begin
  if(iRST)
    iter_ctr <= '0;
  else
    case(ns)
          DONE_ST : iter_ctr <= iter_ctr + 1;
          IDLE_ST : iter_ctr <= '0;
          default : iter_ctr <= iter_ctr; // hold
    endcase
end

//////////////////////////////////////////////////////////////////////////////
//
// Grant Pending
//
//////////////////////////////////////////////////////////////////////////////
// If grant is received while any BIST modules is transmitting, the
// grant is latched until the previous 4K transfer is completed.
always_ff @( posedge iCLK )
    enter_gnt_st_r <= (ps == REQ_ST) && (ns == GNT_ST);

always_ff @( posedge iCLK or posedge iRST )
    if ( iRST )
        grant_pending_r <= 1'b0;
    else begin
        if ( grant_pending_r )
            grant_pending_r <= ~enter_gnt_st_r;
        else
            grant_pending_r <= iDPLBUF_GNT;
    end



endmodule
