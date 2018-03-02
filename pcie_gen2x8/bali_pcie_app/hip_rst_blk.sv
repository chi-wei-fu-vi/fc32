/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-08-24 14:18:24 -0700 (Fri, 24 Aug 2012) $
* $Revision: 130 $
* Description:
* This module receives rst input pulses from various sources and applies an 
* appropriate reset to the HIP block for an appropriate duration.
*
*
* Upper level dependencies:  bali_pcie_app.sv
* Lower level dependencies:  none
*
* Revision History Notes:
* 2012/06/15 Tim - initial release
* 2012/06/28 Tim - Per Altera documenatation added iHIP2A_FIXEDCLK_LOCKED iHIP2A_PLD_CLK_INUSE.
*
***************************************************************************/



// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030


module hip_rst_blk 
(
// inputs
input        iPLD_CLK,
input        iHIP2A_FIXEDCLK_LOCKED,
input        iHIP2A_PLD_CLK_INUSE,
input        iDLUP_EXIT_n,   
input        iHOTRST_EXIT_n, 
input        iL2_EXIT_n,     
input [4:0]  iLTSSMSTATE,  
input        iNPOR_n,            // PLD_CLK reset
input        iBUSY_XCVR_RECONFIG, 
input        iSIMULATION_FORCE_DEASSERT,

// outputs  
output logic oAPP_RST_n,   // PCIE APPLICATION RESET
output logic oCRST         // CFG RESET
);



logic npor_r1      /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102 ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
logic npor_sync    /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102 ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;

logic              any_rstn_r /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102 ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
logic              any_rstn_rr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102 ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
logic              app_rstn;
logic              app_rstn0;
logic              crst;
logic              crst0;
logic     [4:0]    dl_ltssm_r1;
logic              dlup_exit_n_r1;
logic              exits_r1;
logic              hotrst_exit_n_r1;
logic              l2_exit_n_r1;
logic              fixedclk_locked_r1;
logic              pld_clk_inuse_r1;

logic     [10:0]   rsnt_cntn;
logic              srst;
  
///////////////////////////////////////////////////////////////////////////////
//  
// Reset Synchronizer
//
///////////////////////////////////////////////////////////////////////////////
always @(posedge iPLD_CLK or negedge iNPOR_n)
begin
  if (!iNPOR_n)
  begin
      npor_r1 <= 0;
      npor_sync <= 0;
  end
  else
  begin
    npor_r1   <= 1'b1;
    npor_sync <= npor_r1;
  end
end
  
  
///////////////////////////////////////////////////////////////////////////////
//  
// Pipe line exit conditions
//
///////////////////////////////////////////////////////////////////////////////  
always @(posedge iPLD_CLK or negedge npor_sync)
begin
  if (npor_sync == 0)
  begin
    dlup_exit_n_r1     <= 1'b1;
    hotrst_exit_n_r1   <= 1'b1;
    l2_exit_n_r1       <= 1'b1;
    exits_r1           <= 1'b0;
    fixedclk_locked_r1 <= 1'b0;
    pld_clk_inuse_r1   <= 1'b0;
  end
  else
  begin
    dlup_exit_n_r1     <= iDLUP_EXIT_n;
    hotrst_exit_n_r1   <= iHOTRST_EXIT_n;
    l2_exit_n_r1       <= iL2_EXIT_n;
    fixedclk_locked_r1 <= iHIP2A_FIXEDCLK_LOCKED;
    pld_clk_inuse_r1   <= iHIP2A_PLD_CLK_INUSE;
    exits_r1           <= (!l2_exit_n_r1) | 
                          (!hotrst_exit_n_r1) | 
                          (!dlup_exit_n_r1) |       // held low for 1-cycle when HIP leaves DLCSM DLUP state.
                          (dl_ltssm_r1 == 5'h10) | 
                          (!fixedclk_locked_r1) |
                          (!pld_clk_inuse_r1);      // ltssm=1_0000=disable
  end
end

///////////////////////////////////////////////////////////////////////////////  
//
// LTSSM 
//
///////////////////////////////////////////////////////////////////////////////  
always @(posedge iPLD_CLK or negedge npor_sync)
begin
  if (npor_sync == 0)
    dl_ltssm_r1 <= 0;
  else
    dl_ltssm_r1 <= iLTSSMSTATE;
end



///////////////////////////////////////////////////////////////////////////////  
//
// Reset counter
//
// Altera User Guide: Page: 8-2
// "The exact duration of reset using the hard reset controller is pending characterization"
// The following reset durations pulled from Altera sample code.
//
// The following reset behavior holds the app in reset (app_rstn0==0) while
// any of the reset conditions are true and after the reset conditions de-assert then
// the logic is held in reset for additional clock cycles as characterized by Altera.
//
// 
///////////////////////////////////////////////////////////////////////////////    
always @(posedge iPLD_CLK or negedge npor_sync)
begin
  if (npor_sync == 0)
    rsnt_cntn <= 0;
  else if (exits_r1 == 1'b1)
    rsnt_cntn <= 11'h3f0;
  else if (rsnt_cntn != 11'd1024)
    rsnt_cntn <= rsnt_cntn + 1;
end

///////////////////////////////////////////////////////////////////////////////    
//
// Sync and config reset
//
///////////////////////////////////////////////////////////////////////////////      
always @(posedge iPLD_CLK or negedge npor_sync)
begin
  if (npor_sync == 0)
  begin
    app_rstn0 <= 0;     // assert reset
    crst0     <= 1'b1;  // assert reset
  end
  else if (exits_r1 == 1'b1)
  begin
    app_rstn0 <= 1'b0; // assert reset
    crst0     <= 1'b1; // assert reset
  end
  else // synthesis translate_off
  if ((iSIMULATION_FORCE_DEASSERT == 1'b1) & (rsnt_cntn >= 11'd32))
  begin
    app_rstn0 <= 1'b1;    // de-assert reset
    crst0     <= 1'b0;    // de-assert reset
  end
  else // synthesis translate_on
  if (rsnt_cntn == 11'd1024)
  begin
    app_rstn0 <= 1'b1;  // de-assert reset
    crst0     <= 1'b0;  // de-assert reset
  end
end


///////////////////////////////////////////////////////////////////////////////      
//
// Reset outputs
//
///////////////////////////////////////////////////////////////////////////////      
always @(posedge iPLD_CLK or negedge npor_sync)
begin
  if (!npor_sync)
  begin
    oAPP_RST_n <= 1'b0;
    oCRST      <= 1'b1;
  end
  else
  begin
    oAPP_RST_n <= app_rstn0;
    oCRST      <= crst0;
  end
end

endmodule

