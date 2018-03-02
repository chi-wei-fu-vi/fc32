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

module pcie_mwr_bist_wrap #(

parameter   LINKS                       = 12    )

(
  //////////////////////////////////////////////////////////////////////
  // Resets & clock
  //////////////////////////////////////////////////////////////////////
  input                 iRST,
  input                 iCLK,

  //////////////////////////////////////////////////////////////////////
  // PCIE MM Register I/F
  //////////////////////////////////////////////////////////////////////
  input  [63:0]         iMM_WR_DATA,
  input  [9:0]          iMM_ADDRESS,
  input                 iMM_WR_EN,
  input                 iMM_RD_EN,
  output [63:0]         oMM_RD_DATA,
  output                oMM_RD_DATA_V,

  //////////////////////////////////////////////////////////////////////
  // DMA WRITE to DPL BUFFER I/F
  //////////////////////////////////////////////////////////////////////
  output [LINKS-1:0]    oDPLBUF_REQ,
  input  [LINKS-1:0]    iDPLBUF_GNT,

  output logic [255:0]  oDPLBUF_DATA,
  output logic [LINKS-1:0] oDPLBUF_DATA_V
);
import pcie_app_pkg::*;


typedef enum {IDLE_ST,
              REQ_ST,
              GNT_ST,
              DONE_ST
              } state_e;

state_e       ps, ns;

pcie_bist_ctrl_ty ctrl;
pcie_bist_status_ty [LINKS-1:0] status;

logic [LINKS-1:0][255:0] bist_dplbuf_data;
logic [LINKS-1:0] bist_dplbuf_data_v;
logic any_bist_dpl_data_v;

pcie_mwr_bist_regs pcie_mwr_bist_regs_inst
(
 .clk                    (iCLK),
 .rst_n                  (~iRST),
 .wr_en                  (iMM_WR_EN),
 .rd_en                  (iMM_RD_EN),
 .addr                   (iMM_ADDRESS),
 .wr_data                (iMM_WR_DATA),
 .rd_data                (oMM_RD_DATA),
 .rd_data_v              (oMM_RD_DATA_V),
 .oREG_TEST_REG          (),
 .oREG_CTRL_RUN          (ctrl.run),
 .oREG_CTRL_PAT_TYPE     (ctrl.pat_type),
 .oREG_CTRL_LINK_EN      (ctrl.link_en),
 .oREG_CTRL_ITERATIONS   (ctrl.iter),
 .iREG_STATUS0_ITERATIONS(status[0].iter),
 .iREG_STATUS0_RUN_DYN   (status[0].run_dyn),
 .iREG_STATUS1_ITERATIONS(status[1].iter),
 .iREG_STATUS1_RUN_DYN   (status[1].run_dyn),
 .iREG_STATUS2_ITERATIONS(status[2].iter),
 .iREG_STATUS2_RUN_DYN   (status[2].run_dyn),
 .iREG_STATUS3_ITERATIONS(status[3].iter),
 .iREG_STATUS3_RUN_DYN   (status[3].run_dyn),
 .iREG_STATUS4_ITERATIONS(status[4].iter),
 .iREG_STATUS4_RUN_DYN   (status[4].run_dyn),
 .iREG_STATUS5_ITERATIONS(status[5].iter),
 .iREG_STATUS5_RUN_DYN   (status[5].run_dyn),
 .iREG_STATUS6_ITERATIONS(status[6].iter),
 .iREG_STATUS6_RUN_DYN   (status[6].run_dyn),
 .iREG_STATUS7_ITERATIONS(status[7].iter),
 .iREG_STATUS7_RUN_DYN   (status[7].run_dyn),
 .iREG_STATUS8_ITERATIONS(status[8].iter),
 .iREG_STATUS8_RUN_DYN   (status[8].run_dyn),
 .iREG_STATUS9_ITERATIONS(status[9].iter),
 .iREG_STATUS9_RUN_DYN   (status[9].run_dyn),
 .iREG_STATUS10_ITERATIONS(status[10].iter),
 .iREG_STATUS10_RUN_DYN   (status[10].run_dyn),
 .iREG_STATUS11_ITERATIONS(status[11].iter),
 .iREG_STATUS11_RUN_DYN   (status[11].run_dyn)
);


genvar ii;
generate for (ii = 0; ii < 12; ii++)
begin: gen_pcie_mwr_bist

pcie_mwr_bist
#(
   .pLINK_NUM (ii)     //default value for this link
)
pcie_mwr_bist_inst
(
  //////////////////////////////////////////////////////////////////////
  // Resets & clock
  //////////////////////////////////////////////////////////////////////
  .iRST               (iRST),
  .iCLK               (iCLK),

  //////////////////////////////////////////////////////////////////////
  // Control
  //////////////////////////////////////////////////////////////////////
  .iCTRL              (ctrl),
  .oRUN_DYN           (status[ii].run_dyn),
  .oITER              (status[ii].iter),

  //////////////////////////////////////////////////////////////////////
  // DMA WRITE to DPL BUFFER I/F
  //////////////////////////////////////////////////////////////////////
  .oDPLBUF_REQ        (oDPLBUF_REQ[ii]),
  .iDPLBUF_GNT        (iDPLBUF_GNT[ii]),
  .iANY_DPL_DATA_V    (any_bist_dpl_data_v),

  .oDPLBUF_DATA       (bist_dplbuf_data[ii]),
  .oDPLBUF_DATA_V     (bist_dplbuf_data_v[ii])
);


end
endgenerate

//////////////////////////////////////////////////////////////////////
// DMA WRITE to DPL BUFFER I/F
//////////////////////////////////////////////////////////////////////
function [255:0] or_dplbuf_data;
  input [LINKS-1:0][255:0] data;
  integer i;
  logic [255:0] result;
  begin
    result = 256'b0;
    for (i = 0; i < LINKS; i++)
      result = result | data[i];
    or_dplbuf_data = result;
  end
endfunction

always_ff @( posedge iCLK ) begin
    oDPLBUF_DATA <= or_dplbuf_data( bist_dplbuf_data );
    oDPLBUF_DATA_V <= bist_dplbuf_data_v;
    any_bist_dpl_data_v <= |bist_dplbuf_data_v;
end




endmodule