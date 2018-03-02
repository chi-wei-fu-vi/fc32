/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-09-06 11:53:05 -0700 (Thu, 06 Sep 2012) $
* $Revision: 162 $
* Description:
*
*
* Upper level dependencies:  bali_pcie_app.sv
* Lower level dependencies:  none
*
* Revision History Notes:
* 2012/06/12 Tim - initial release
*
***************************************************************************/



module lt_cfg_demux
(
// inputs
input         iRST,
input         iPLD_CLK,     
input [3:0]   iTL_CFG_ADD,
input [31:0]  iTL_CFG_CTL,
input [52:0]  iTL_CFG_STS,

// outputs
output [31:0] oCFG_DEVCSR,
output [31:0] oCFG_LINKCSR, 
output [31:0] oCFG_PRMCSR,  

output [19:0] oCFG_IO_BAS,  
output [19:0] oCFG_IO_LIM,  
output [11:0] oCFG_NP_BAS,  
output [11:0] oCFG_NP_LIM,  
output [43:0] oCFG_PR_BAS,  
output [43:0] oCFG_PR_LIM,  
output [23:0] oCFG_TCVMAP,  
output [15:0] oCFG_MSICSR,  
output [12:0] oCFG_BUSDEV  
);


//////////////////////////////////////////////////////////////////////////////
//
// Signals
//
//////////////////////////////////////////////////////////////////////////////
logic [31:0] cfg_devcsr;
logic [31:0] cfg_linkcsr;
logic [31:0] cfg_prmcsr;

logic [19:0] cfg_io_bas;
logic [19:0] cfg_io_lim;
logic [11:0] cfg_np_bas;
logic [11:0] cfg_np_lim;
logic [43:0] cfg_pr_bas;
logic [43:0] cfg_pr_lim;
logic [23:0] cfg_tcvcmap;
logic [15:0] cfg_msicsr;
logic [12:0] cfg_busdev; 

logic [3:0]  rd_addr;
logic [31:0] rd_cfg;
logic [52:0] rd_cfg_sts;


//////////////////////////////////////////////////////////////////////////////
//
// Assign Outputs
//
//////////////////////////////////////////////////////////////////////////////
assign oCFG_DEVCSR  = cfg_devcsr;
assign oCFG_LINKCSR = cfg_linkcsr;
assign oCFG_PRMCSR  = cfg_prmcsr;

assign oCFG_IO_BAS  = cfg_io_bas;
assign oCFG_IO_LIM  = cfg_io_lim;
assign oCFG_NP_BAS  = cfg_np_bas;
assign oCFG_NP_LIM  = cfg_np_lim;
assign oCFG_PR_BAS  = cfg_pr_bas;
assign oCFG_PR_LIM  = cfg_pr_lim;
assign oCFG_TCVMAP  = cfg_tcvcmap;
assign oCFG_MSICSR  = cfg_msicsr;
assign oCFG_BUSDEV  = cfg_busdev; 


//////////////////////////////////////////////////////////////////////////////
//
// Register Inputs
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge iPLD_CLK or posedge iRST)
begin
  if(iRST)
  begin
    rd_addr       <= '0;
    rd_cfg        <= '0;
    rd_cfg_sts    <= '0;
  end
  else
  begin
    rd_addr       <= iTL_CFG_ADD;
    rd_cfg        <= iTL_CFG_CTL;
    rd_cfg_sts    <= iTL_CFG_STS;  
  end
end

//////////////////////////////////////////////////////////////////////////////
//
// Sample CFGSPACE Registers arriving from HIP on time-multiplexed bus.
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge iPLD_CLK or posedge iRST)
begin
  if(iRST)
  begin
    cfg_devcsr    <= '0;
    cfg_linkcsr   <= '0;
    cfg_prmcsr    <= '0;
    cfg_np_bas    <= '0;
    cfg_pr_bas    <= '0;
    cfg_pr_lim    <= '0;
    cfg_msicsr    <= '0;
    cfg_tcvcmap   <= '0;
    cfg_io_bas    <= '0;
    cfg_busdev    <= '0;
  end
  else
  begin  
    cfg_prmcsr[26:25] <= 2'h0;
    cfg_prmcsr[23:16] <= 8'h0;
    cfg_devcsr[31:20] <= 12'h0;

    cfg_devcsr[19:16]  <= rd_cfg_sts[52:49];
    cfg_linkcsr[31:16] <= rd_cfg_sts[46:31];
    cfg_prmcsr[31:27]  <= rd_cfg_sts[29:25];
    cfg_prmcsr[24]     <= rd_cfg_sts[24];

  
    case(rd_addr) 
      4'h0: cfg_devcsr[15:0]  <= rd_cfg[31:16];       
//    4'h1: 
      4'h2: cfg_linkcsr[15:0] <= rd_cfg[31:16]; 
      4'h3: cfg_prmcsr[15:0]  <= rd_cfg[23:8];
//    4'h4: 
      4'h5: cfg_io_bas        <= rd_cfg[19:0];
      4'h6: cfg_io_lim        <= rd_cfg[19:0];
      4'h7: cfg_np_bas        <= rd_cfg[23:12];
      4'h8: cfg_pr_bas[31:0]  <= rd_cfg[31:0];
      4'h9: cfg_pr_bas[43:32] <= rd_cfg[11:0];
      4'hA: cfg_pr_lim[31:0]  <= rd_cfg[31:0];
      4'hB: cfg_pr_lim[43:32] <= rd_cfg[11:0];
//    4'hC:
      4'hD: cfg_msicsr[15:0]  <= rd_cfg[15:0];
      4'hE: cfg_tcvcmap[23:0] <= rd_cfg[23:0];
      4'hF: cfg_busdev        <= rd_cfg[12:0];
//    default:
    endcase
  end
end

endmodule