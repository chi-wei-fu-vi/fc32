/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-09-06 06:53:33 -0700 (Thu, 06 Sep 2012) $
* $Revision: 159 $
* Description:
*
* This module receives decoded MWr/MRd TLP's and translates to
* an Avalon bus.
*
* Upper level dependencies:
* Lower level dependencies:  none
*
* Revision History Notes:
* 2012/06/22 Tim - initial release
* 2013/04/17 Tim - Added iMM_WR_ACK_PULSE, iREG_PCIETIMEOUTPERIOD
* 2013/04/19 Tim - Changed iMM_WR_ACK_PULSE to iMM_ACK_PULSE. Now also read data valid.
*
***************************************************************************/

///////////////////////////////////////////////////////////////////////////////
//
// Includes
//
///////////////////////////////////////////////////////////////////////////////



module rx_tlp2mm_if
(
  input                 iRST,
  input                 iCLK,

  input [19:0]          iREG_PCIETIMEOUTPERIOD,   // connect to register
  output logic          oREG_PCIEWRTIMEOUTCTR_EN, // connect to register
  input                 iFR_TX_DONE_PULSE,        // Indicates MWr TLP sent to HIP
  output logic          oTO_DECODE_DONE_PULSE,    // Indicates transaction done to rx_tlp_decode

  // decoded inputs
  input                 iDECODE_VALID,            // Indicates TLP decodes are valid from rx_tlp_decode
  input pcie_app_pkg::hdr0_type       iTLP_HDR0,
  input pcie_app_pkg::hdr1_type       iTLP_HDR1,
  input [29:0]          iTLP_ADDR,
  input [63:0]          iTLP_WR_DATA,

  input                 iTLP_MRD,
  input                 iTLP_MWR,
  input                 iTLP_UR,
  input                 iTLP_NON_POSTED,

  // Status/Control Register Bus Interface
  input                 iMM_ACK_PULSE,         // indicates register write has completed
  output logic [63:0]   oMM_WR_DATA,
  output logic [20:0]   oMM_ADDRESS,              // Address is 8-byte aligned
  output logic          oMM_WR_EN_PULSE,
  output logic          oMM_RD_EN_PULSE
);
import pcie_app_pkg::*;

logic [19:0]  wen_ctr;
logic [63:0] wr_data;
logic [20:0] address;

logic  to_decode_done_pulse;
logic  wr_en_pulse;
logic  rd_en_pulse;


typedef enum {IDLE_ST,
              MM_WEN_ST,
              MM_REN_ST,
              WAIT_TX_TLP_ST,
              WAIT_WEN_ST,
              DONE_ST,
              WAIT_DEASSERT
              } state_e;

state_e       ps, ns;

// timeout counter
always_ff @(posedge iRST or posedge iCLK)
begin
  if (iRST)
    wen_ctr <= '0;
  else
  begin
    if (ps == WAIT_WEN_ST)
      wen_ctr <= wen_ctr + 1'b1;
    else
      wen_ctr <= '0;
  end
end

// if timeout occurs, strobe timeout enable
// to increment counter
always_ff @(posedge iRST or posedge iCLK)
begin
  if (iRST)
    oREG_PCIEWRTIMEOUTCTR_EN <= 1'b0;
  else
  begin
    if (wen_ctr == iREG_PCIETIMEOUTPERIOD)
      oREG_PCIEWRTIMEOUTCTR_EN <= 1'b1;
    else
      oREG_PCIEWRTIMEOUTCTR_EN <= 1'b0;
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
    oTO_DECODE_DONE_PULSE <= '0;
    oMM_WR_DATA           <= '0;
    oMM_ADDRESS           <= '0;
    oMM_WR_EN_PULSE       <= '0;
    oMM_RD_EN_PULSE       <= '0;
  end
  else
  begin
    oTO_DECODE_DONE_PULSE <= to_decode_done_pulse;
    oMM_WR_DATA           <= wr_data;
    oMM_ADDRESS           <= address;
    oMM_WR_EN_PULSE       <= wr_en_pulse;
    oMM_RD_EN_PULSE       <= rd_en_pulse;
  end
end

//////////////////////////////////////////////////////////////////////////////
//
// Pipeline Registers
//
//////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    wr_data  <= '0;
    address  <= '0;
  end
  else
  begin
    wr_data <= iTLP_WR_DATA;
    address <= iTLP_ADDR[20:0];
  end
end


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

  to_decode_done_pulse = 1'b0;
  wr_en_pulse          = 1'b0;
  rd_en_pulse          = 1'b0;

  case(ps)
                 IDLE_ST: begin
                            if     (iDECODE_VALID && iTLP_MWR)  ns = MM_WEN_ST;
                            else if(iDECODE_VALID && iTLP_MRD)  ns = MM_REN_ST;
                            else if(iTLP_UR && iTLP_NON_POSTED) ns = WAIT_TX_TLP_ST;
                            else                                ns = IDLE_ST;
                          end
               MM_WEN_ST: begin
                                                                wr_en_pulse = 1'b1;
                                                                ns = WAIT_WEN_ST;
                          end
             WAIT_WEN_ST: begin
                            if (iMM_ACK_PULSE ||
                                wen_ctr==iREG_PCIETIMEOUTPERIOD)ns = DONE_ST;
                            else                                ns = WAIT_WEN_ST;

                          end
               MM_REN_ST: begin
                                                                rd_en_pulse  = 1'b1;
                                                                ns = WAIT_TX_TLP_ST;
                          end
             WAIT_TX_TLP_ST: begin
                           if      (iFR_TX_DONE_PULSE)          ns  = DONE_ST;
                           else                                 ns = WAIT_TX_TLP_ST;
                          end
                 DONE_ST: begin
                                                                to_decode_done_pulse = 1'b1;
                                                                ns = WAIT_DEASSERT;
                          end
           WAIT_DEASSERT: begin
                            if      (!iDECODE_VALID)            ns = IDLE_ST;
                            else                                ns = WAIT_DEASSERT;
                          end
                 default: begin
                                                                ns = IDLE_ST;
                          end
  endcase
end


///////////////////////////////////////////////////////////////////////////
//
// Assertion
//
///////////////////////////////////////////////////////////////////////////
// synopsys translate_off
// Register read timeout
assert_memory_write_timeout: assert property ( @( posedge iCLK )
    disable iff ( iRST )
        !$rose( oREG_PCIEWRTIMEOUTCTR_EN ) );
// synopsys translate_on



endmodule
