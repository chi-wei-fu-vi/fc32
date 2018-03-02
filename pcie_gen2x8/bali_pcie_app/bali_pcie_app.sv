/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: honda.yang $
* $Date: 2013-08-29 10:28:02 -0700 (Thu, 29 Aug 2013) $
* $Revision: 3301 $
* Description:
* This module is the PCIe application that provides an interface to the FPGA fabric
* as well as the Stratix V PCIe HIP core.
* Interface 1: A single-cycle memory mapped register interface
* Interface 2: A 4KB DMA burst to CPU physical memory
*
* DPLBUF I/F: FPGA fabric DMA write interface:
* readyLatency = 0. If GNT then may write immediately and continuously w/out interruption
* exactly 4KB of data.
*
* Upper level dependencies: bali_pcie_gen2x8_wrap.sv
* Lower level dependencies: PCIe app modules
*
* Revision History Notes:
* 2012/07/12 Tim - initial release
* 2012/07/26 Tim - Added MM address decode and register modules.
* 2012/08/02 Tim - Removed reset sync logic since Altera indicates iHIP2A_RESET_STATUS
*                  already sync to iCLK_PCIE_GLOBAL.
* 2012/08/27 Tim - Added iHIP2A_PLD_CLK_INUSE to hip_rst_blk
* 2013/05/17 Tim - Tied iREG_TICKS_SINCE_LAST_LATCH_EN to '1'.
*
***************************************************************************/

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// Signal naming conventions: Signal direction implied:
// HIP2A = Hard IP to APP
// A2HIP = APP to HIP
//
// reference module from Altera: altpcied_sv_hwtcl.v


///////////////////////////////////////////////////////////////////////////////
//
// Includes
//
///////////////////////////////////////////////////////////////////////////////

module bali_pcie_app #(

  parameter                            MAX_NUM_FUNC_SUPPORT           = 8,
  parameter                            num_of_func_hwtcl              = MAX_NUM_FUNC_SUPPORT,
  parameter                            PORTS                          = 12,
  parameter                            BALI                           = 0 
 ) 
(

  //////////////////////////////////////////////////////////////////////
  // PCIe credit monitoring
  //////////////////////////////////////////////////////////////////////
  input [11 : 0]       tx_cred_datafccp,
  input [11 : 0]       tx_cred_datafcnp,
  input [11 : 0]       tx_cred_datafcp,
  input [5 : 0]        tx_cred_fchipcons,
  input [5 : 0]        tx_cred_fcinfinite,
  input [7 : 0]        tx_cred_hdrfccp,
  input [7 : 0]        tx_cred_hdrfcnp,
  input [7 : 0]        tx_cred_hdrfcp,

  //////////////////////////////////////////////////////////////////////
  // Reset signals
  //////////////////////////////////////////////////////////////////////
  input                                       iHIP2A_RESET_STATUS,
  input                                       iHIP2A_SERDES_PLL_LOCKED,
  input                                       iHIP2A_PLD_CLK_INUSE,
  input                                       iRST_100M_N,
  input        [PORTS-1:0]                    iRST_PCIE_N,
  input                                       iRST_CHIP_PCIE_N,
  output                                      oA2HIP_PLD_CORE_READY,
  output                                      oAPP_RST_n_STATUS,

  //////////////////////////////////////////////////////////////////////
  // Clock
  //////////////////////////////////////////////////////////////////////
  input                                       iCLK_PCIE_GLOBAL,
  input                                       iCLK_100M,
  input                                       iRECONFIG_XCVR_CLK,
  input                                       iCLK_PCIE_CORECLKOUT_HIP,

  //////////////////////////////////////////////////////////////////////
  // TO/FROM MM REG DECODE I/F
  //////////////////////////////////////////////////////////////////////
  output       [63:0]                         oPCIE2MM_WR_DATA,
  output       [20:0]                         oPCIE2MM_ADDRESS,
  output                                      oPCIE2MM_WR_EN,
  output                                      oPCIE2MM_RD_EN,
  input                                       iMM2PCIE_ACK,                  //  WR_EN & RD_EN ACK
  input        [63:0]                         iMM2PCIE_RD_DATA,
  //  input                  iMM2PCIE_RD_DATA_V,

  //////////////////////////////////////////////////////////////////////
  // PCIE MM Register I/F
  //////////////////////////////////////////////////////////////////////
  input        [63:0]                         iMM_WR_DATA,
  input        [20:0]                         iMM_ADDR,
  input                                       iMM_WR_EN,
  input                                       iMM_RD_EN,
  output       [63:0]                         oMM_RD_DATA,
  output                                      oMM_RD_DATA_V,

  //////////////////////////////////////////////////////////////////////
  // DMA WRITE to DPL BUFFER I/F
  //////////////////////////////////////////////////////////////////////
  input        [PORTS-1:0]                    iDPLBUF_REQ,
  output       [PORTS-1:0]                    oDPLBUF_GNT,
  input        [255:0]                        iDPLBUF_DATA,
  input        [PORTS-1:0]                    iDPLBUF_DATA_V,

  //////////////////////////////////////////////////////////////////////
  // Reconfig GXB SERDES
  //////////////////////////////////////////////////////////////////////
  //  output [700-1:0]       oA2HIP_RECONFIG_TO_XCVR,
  //  input  [460-1:0]       iHIP2APP_RECONFIG_FROM_XCVR,
  //  output                 oA2HIP_BUSY_XCVR_RECONFIG,
  //  input                  iHIP2A_FIXEDCLK_LOCKED,

  //////////////////////////////////////////////////////////////////////
  // Transaction Layer Configuration
  //////////////////////////////////////////////////////////////////////
  input        [6 : 0]                        iHIP2A_TL_CFG_ADD,
  input        [31 : 0]                       iHIP2A_TL_CFG_CTL,
  input        [122 : 0]                      iHIP2A_TL_CFG_STS,

  //////////////////////////////////////////////////////////////////////
  // Local Management Interface (LMI)
  //////////////////////////////////////////////////////////////////////
  // 128x32-bit registers - Debug only
  input                                       iHIP2A_LMI_ACK,                //  NC
  input        [31 : 0]                       iHIP2A_LMI_DOUT,               //  NC
  output       [14 : 0]                       oA2HIP_LMI_ADDR,
  output       [31 : 0]                       oA2HIP_LMI_DIN,
  output                                      oA2HIP_LMI_RDEN,
  output                                      oA2HIP_LMI_WREN,


  //////////////////////////////////////////////////////////////////////
  // Power Management - Not Used
  //////////////////////////////////////////////////////////////////////
  input                                       iHIP2A_PME_TO_SR,              //  NC
  output                                      oA2HIP_PM_AUXPWR,
  output       [9 : 0]                        oA2HIP_PM_DATA,
  output                                      oA2HIP_PME_TO_CR,
  output                                      oA2HIP_PM_EVENT,
  //output  [2 : 0]        oA2HIP_PM_EVENT_FUNC,

  //////////////////////////////////////////////////////////////////////
  // TX PCIE AVALON-ST I/F
  //////////////////////////////////////////////////////////////////////
  output       [255 : 0]                      oTX_ST_DATA,
  output       [1:0]                          oTX_ST_EMPTY,
  output                                      oTX_ST_EOP,
  output                                      oTX_ST_ERR,
  output                                      oTX_ST_SOP,
  output                                      oTX_ST_VALID,
  output       [31:0]                         oTX_ST_PARITY,
  input                                       iTX_ST_READY,


  //////////////////////////////////////////////////////////////////////
  // RX PCIE AVALON-ST I/F
  //////////////////////////////////////////////////////////////////////
  input        [255:0]                        iRX_ST_DATA,
  output                                      oRX_ST_READY,
  input                                       iRX_ST_SOP,
  input                                       iRX_ST_VALID,
  input        [1:0]                          iRX_ST_EMPTY,
  input                                       iRX_ST_EOP,
  input                                       iRX_ST_ERR,
  //input [31 :0]          iRX_ST_PARITY,   // NOT USED
  input        [31 :0]                        iRX_ST_BE,
  output                                      oRX_ST_MASK,
  input        [7 : 0]                        iRX_ST_BAR,

  //output  [12:0]         oCFGLINK2CSRPLD,  // misc HIP generate ctl

  //////////////////////////////////////////////////////////////////////
  // HIP Completion I/F
  //////////////////////////////////////////////////////////////////////
  output logic [6 :0]                         oA2HIP_CPL_ERR,
  output                                      oA2HIP_CPL_PENDING,
  //output  [2 :0]         oA2HIP_CPL_ERR_FUNC,  // tmb - NC currently

  //////////////////////////////////////////////////////////////////////
  // Input HIP Status signals
  //////////////////////////////////////////////////////////////////////
  input        [1 : 0]                        iHIP2A_CURRENTSPEED,
  input                                       iHIP2A_DERR_COR_EXT_RCV,
  input                                       iHIP2A_DERR_COR_EXT_RPL,
  input                                       iHIP2A_DERR_RPL,
  input                                       iHIP2A_RX_PAR_ERR,
  input        [1:0]                          iHIP2A_TX_PAR_ERR,
  input                                       iHIP2A_CFG_PAR_ERR,
  input                                       iHIP2A_DLUP,
  input                                       iHIP2A_DLUP_EXIT_n,
  input                                       iHIP2A_EV128NS,
  input                                       iHIP2A_EV1US,
  input                                       iHIP2A_HOTRST_EXIT_n,
  input        [3 : 0]                        iHIP2A_INT_STATUS,
  input                                       iHIP2A_L2_EXIT_n,
  input        [3:0]                          iHIP2A_LANE_ACT,
  input        [4 : 0]                        iHIP2A_LTSSMSTATE,
  input        [7:0]                          iHIP2A_KO_CPL_SPC_HEADER,
  input        [11:0]                         iHIP2A_KO_CPL_SPC_DATA,
  input                                       testin_zero,
  output       [(2**addr_width_delta(num_of_func_hwtcl))-1 : 0] app_int_sts,
  output       [4 : 0]                        app_msi_num,
  output                                      app_msi_req,
  output       [2 : 0]                        app_msi_tc,
  input                                       app_int_ack,
  input                                       app_msi_ack,

  // Output HIP status signals
  output                                      derr_cor_ext_rcv_drv,
  output                                      derr_cor_ext_rpl_drv,
  output                                      derr_rpl_drv,
  output                                      dlup_drv,
  output                                      dlup_exit_drv,
  output                                      ev128ns_drv,
  output                                      ev1us_drv,
  output                                      hotrst_exit_drv,
  output       [3 : 0]                        int_status_drv,
  output                                      l2_exit_drv,
  output       [3:0]                          lane_act_drv,
  output       [4 : 0]                        ltssmstate_drv,
  output                                      rx_par_err_drv,
  output       [1:0]                          tx_par_err_drv,
  output                                      cfg_par_err_drv,
  output       [7:0]                          ko_cpl_spc_header_drv,
  output       [11:0]                         ko_cpl_spc_data_drv,
  // HIP control signals
  output       [4 : 0]                        hpg_ctrler 


  );
import pcie_app_pkg::*;
import bali_lib_pkg::*;
// PLD_CLK is 125MHz - Gen2x8 w/ 256-bit I/F
localparam PLD_CLK_IS_250MHZ =0;
localparam port_width_be_hwtcl=32;
localparam PORT_WIDTH = $clog2( PORTS );

function integer clogb2 (input integer depth);
begin
   clogb2 = 0;
   for(clogb2=0; depth>1; clogb2=clogb2+1)
      depth = depth >> 1;
end
endfunction

function integer addr_width_delta (input integer num_of_func);
begin
   if (num_of_func > 1) begin
      addr_width_delta = clogb2(MAX_NUM_FUNC_SUPPORT);
   end
   else begin
      addr_width_delta = 0;
   end
end
endfunction

  wire                                  crst;
//logic  [3:0]                          iHIP2A_TL_CFG_ADD; // [6:0] ???????????? delete
//logic  [52:0]                         iHIP2A_TL_CFG_STS; // [122:0] ?????????????? delete
//logic  [16:0]                         iMM_ADDR[16:0]; // [20:0] ????????? delete
//logic  [1:0]                          iREG_DEBUG_LINK_ARB_ARB_PS; //old fixme
  wire   [2:0]                          iREG_DEBUG_LINK_ARB_ARB_PS; // old fixme
  wire   [29:0]                         rx_addr_qwaligned;

  logic                                 app_rstn;
  logic  [12:0]                         cfg_busdev;
  wire   [31:0]                         cfg_devcsr;
  wire   [19:0]                         cfg_io_bas;
  wire   [19:0]                         cfg_io_lim;
  wire   [31:0]                         cfg_linkcsr;
  wire   [15:0]                         cfg_msicsr;
  wire   [11:0]                         cfg_np_bas;
  wire   [11:0]                         cfg_np_lim;
  logic                                 cfg_par_err_r;
  wire   [43:0]                         cfg_pr_bas;
  wire   [43:0]                         cfg_pr_lim;
  wire   [31:0]                         cfg_prmcsr;
  wire   [23:0]                         cfg_tcvmap;
  wire                                  coreclkout_app_rstn;
  logic  [1:0]                          currentspeed_r;
  logic                                 derr_cor_ext_rcv_r;
  logic                                 derr_cor_ext_rpl_r;
  logic                                 derr_rpl_r;
  logic                                 dlup_exit_r;
  logic                                 dlup_r;
  logic  [PORTS-1:0][13:0]              DPLBUF_ADDR;
  logic  [PORTS-1:0][31:0]              dplbuf_free;
  logic  [PORTS-1:0]                    dplbuf_full;
  logic  [PORTS-1:0]                    dplbuf_gnt;
  logic  [PORTS-1:0]                    dplbuf_inc_wr_ptr;
  logic  [PORTS-1:0]                    dplbufptr_rst;
  logic  [PORTS-1:0][63:0]              DPLBUF_RD_DATA;
  logic  [PORTS-1:0]                    DPLBUF_RD_DATA_V;
  logic  [PORTS-1:0]                    DPLBUF_RD_EN;
  logic  [PORTS-1:0][63:0]              DPLBUF_WR_DATA;
  logic  [PORTS-1:0]                    DPLBUF_WR_EN;
  logic  [PORTS-1:0][31:0]              dplbuf_wr_ptr;
  logic                                 ev128ns_r;
  logic                                 ev1us_r;
  logic                                 fr_tx_done_pulse;
  wire   [1:0]                          hip2a_currentspeed_sync;
  wire                                  hip2a_derr_cor_ext_rcv_sync;
  wire                                  hip2a_derr_cor_ext_rpl_sync;
  wire                                  hip2a_derr_rpl_sync;
  wire                                  hip2a_dlup_exit_n_sync;
  wire                                  hip2a_l2_exit_n_sync;
  wire   [3:0]                          hip2a_lane_act_sync;
  wire                                  hip2a_serdes_pll_locked_sync;
  logic  [PORT_WIDTH-1:0]               hip_arb_link_number;
  wire                                  hip_blk_done;
  wire   [PORT_WIDTH-1:0]               hip_link_number;
  logic                                 hotrst_exit_r;
  logic  [3:0]                          int_status_r;
  logic                                 iREG_DEBUG_LINK_ARB_FIFO_BLK_AVAIL;
  logic                                 iREG_DEBUG_LINK_ARB_FIFO_EMPTY;
  logic                                 iREG_DEBUG_LINK_ARB_FIFO_FULL;
  logic  [7:0]                          iREG_DEBUG_LINK_ARB_FIFO_USED;
  logic                                 iREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_EMPTY;
  logic                                 iREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_FULL;
  logic                                 iREG_DPL_FIFO_WRREQ_CNT_EN;
  logic  [PORTS-1:0][2:0]               iREG_FLUSH_CTR_BLK_FLUSH_CTR;
  logic                                 iREG_GNT_CNT_EN;
  logic                                 iREG_HIP_BLK_DONE_CNT_EN;
  logic                                 iREG_LINK_NUM_FIFO_WR_PULSE_EN;
  logic                                 iREG_TX_BLK_DONE_CNT_EN;
  logic  [11:0]                         ko_cpl_spc_data_r;
  logic  [7:0]                          ko_cpl_spc_header_r;
  logic                                 l2_exit_r;
  logic  [3:0]                          lane_act_r;
  logic  [4:0]                          ltssmstate_r;
  logic  [2:0]                          max_pyld_size;
  logic                                 mgmt_rst_reset_n;
  logic  [20:0]                         mm_address;
  logic                                 mm_rd_en_pulse;
  logic  [63:0]                         mm_wr_data;
  logic                                 mm_wr_en_pulse;
  logic                                 oA2HIP_BUSY_XCVR_RECONFIG;
  wire   [13:0]                         PCIECTRL_ADDR; // From u_pg_addr_dec of xx02_g_addr_decoder.v
  wire                                  PCIEPERF_RD_DATA_V;
  wire                                  PCIECTRL_RD_DATA_V;
  wire   [63:0]                         PCIECTRL_RD_DATA;
  wire   [63:0]                         PCIEPERF_RD_DATA;
  wire                                  PCIECTRL_RD_EN; // From u_pg_addr_dec of xx02_g_addr_decoder.v
  wire   [63:0]                         PCIECTRL_WR_DATA; // From u_pg_addr_dec of xx02_g_addr_decoder.v
  wire                                  PCIECTRL_WR_EN; // From u_pg_addr_dec of xx02_g_addr_decoder.v
  logic  [2:0]                          pcie_perf_byte_ctr;
  logic                                 pcie_perf_latch;
  logic  [PORTS-1:0]                    pcie_perf_link_done;
  logic  [PORTS-1:0]                    pcie_perf_link_req;
  logic                                 pcie_perf_rdy_n;
  wire   [PORTS-1:0][31:0]              pcie_perf_req;
  logic  [PORTS-1:0][31:0]              pcie_perf_reqtic_max;
  logic                                 pcie_perf_sop_ctr;
  wire   [63:0]                         PCIEPERF_WR_DATA; // From u_pg_addr_dec of xx02_g_addr_decoder.v
  wire                                  PCIEPERF_WR_EN; // From u_pg_addr_dec of xx02_g_addr_decoder.v
  logic                                 pcierdtimeoutctr_en;
  logic  [0:0]                          pcie_test_reg;
  logic  [19:0]                         pcietimeoutperiod;
  logic                                 pciewrtimeoutctr_en;
  wire   [6:0]                          reconfig_mgmt_address; // reconfig_mgmt.address              input  wire
  wire                                  reconfig_mgmt_read; // .read                 input  wire
  wire   [31:0]                         reconfig_mgmt_writedata; // .writedata            input  wire
  wire                                  reconfig_mgmt_write; // .write                input  wire
  logic  [1:0]                          tx_par_err_r;
  logic  [PORTS-1:0][31:0]              reg_dplbuf_last_pfn;
  logic  [PORTS-1:0][31:0]              reg_dplbuf_rd_ptr;
  logic  [PORTS-1:0][31:0]              reg_dplbuf_start_pfn;
  logic  [PORTS-1:0]                    reg_flushstatus;
  logic  [1:0]                          rx_decode_valid_pipe;
  logic                                 rx_decode_valid;
  logic                                 rx_par_err_r;
  logic                                 rx_tlp_3dw_4dw_n; // not used
  logic                                 rx_tlp_addr_qwaligned; // not used
  logic                                 rx_tlp_ep;
  logic                                 rx_tlp_mrd;
  logic                                 rx_tlp_mwr;
  logic                                 rx_tlp_non_posted;
  logic                                 rx_tlp_non_posted_r1;
  logic                                 rx_tlp_ur;
  logic                                 rx_tlp_ur_r1;
  logic  [63:0]                         rx_wr_data;
  logic  [3:0]                          tl_cfg_add_r;
  logic  [31:0]                         tl_cfg_ctl_r;
  logic  [52:0]                         tl_cfg_sts_r;
  logic                                 to_decode_done_pulse;
  logic  [255:0]                        tx_app2hip_st_data;
  logic                                 tx_blk_done_pulse;
  logic  [255:0]                        tx_fifo_data;
  logic                                 tx_fifo_empty;
  logic                                 tx_fifo_full;
  logic                                 tx_fifo_rd_ack;
  logic  [7:0]                          tx_fifo_used;
  logic  [PORT_WIDTH-1:0]               tx_link_number;
  logic  [2:0][255:0]                   tx_st_data;
  logic  [2:0]                          tx_tlp_gnt;
  logic  [2:0]                          tx_tlp_req;
wire [255:0] ZEROS = 256'h0;
assign app_int_sts = 'h0;
assign app_msi_num = 'h0;
assign app_msi_req = 'h0;
assign app_msi_tc = 'h0;

assign                derr_cor_ext_rcv_drv = iHIP2A_DERR_COR_EXT_RCV;
assign                derr_cor_ext_rpl_drv = iHIP2A_DERR_COR_EXT_RPL;
assign                derr_rpl_drv = iHIP2A_DERR_RPL;
assign                dlup_drv = iHIP2A_DLUP;
assign                dlup_exit_drv = iHIP2A_DLUP_EXIT_n;
assign                ev128ns_drv = iHIP2A_EV128NS;
assign                ev1us_drv =  iHIP2A_EV1US;
assign                hotrst_exit_drv = iHIP2A_HOTRST_EXIT_n;
assign                int_status_drv = iHIP2A_INT_STATUS;
assign                l2_exit_drv = iHIP2A_L2_EXIT_n;
assign                lane_act_drv = iHIP2A_LANE_ACT;
assign                ltssmstate_drv = iHIP2A_LTSSMSTATE;
assign                rx_par_err_drv = iHIP2A_RX_PAR_ERR;
assign                tx_par_err_drv = iHIP2A_TX_PAR_ERR;
assign                cfg_par_err_drv = iHIP2A_CFG_PAR_ERR;
assign                ko_cpl_spc_header_drv = iHIP2A_KO_CPL_SPC_HEADER;
assign                ko_cpl_spc_data_drv = iHIP2A_KO_CPL_SPC_DATA;





// tl_cfg strobes not used in SV Reva Silicon
//wire tl_cfg_ctl_wr=1'b0;
//wire tl_cfg_sts_wr=1'b0;






hdr0_type     rx_tlp_hdr0;
hdr1_type     rx_tlp_hdr1;
trans_type_e  rx_trans_type;  // not used




tx_st_avalon_type [2:0] tx_st;

tx_st_avalon_type tx_app2hip_st;










assign dplbuf_gnt = oDPLBUF_GNT[PORTS-1:0];




//////////////////////////////////////////////////////////////////////////////
//
// Assign Outputs
//
//////////////////////////////////////////////////////////////////////////////
assign oAPP_RST_n_STATUS = app_rstn; // status only for debug at top-level

// TO HIP
assign oTX_ST_EMPTY  = tx_app2hip_st.empty;
assign oTX_ST_EOP    = tx_app2hip_st.eop;
assign oTX_ST_ERR    = tx_app2hip_st.err;
assign oTX_ST_SOP    = tx_app2hip_st.sop;
assign oTX_ST_VALID  = tx_app2hip_st.valid;
assign oTX_ST_PARITY = tx_app2hip_st.parity;
assign oTX_ST_DATA   = tx_app2hip_st_data;

// TO/FROM MEMORY-MAPPED FPGA FABRIC
assign oPCIE2MM_WR_DATA = mm_wr_data;
assign oPCIE2MM_ADDRESS = mm_address;
assign oPCIE2MM_WR_EN   = mm_wr_en_pulse;
assign oPCIE2MM_RD_EN   = mm_rd_en_pulse;

//assign oCFGLINK2CSRPLD = 13'h0;
assign tl_app_msi_func = 3'd0;

//assign tx_tlp_req[2] = 1'b0; // unused
//assign tx_st_data[2] = '0;
//assign tx_st[2]      = '0;

// Power management
assign oA2HIP_PM_AUXPWR     = 1'b0;
assign oA2HIP_PME_TO_CR     = 1'b0;
assign oA2HIP_PM_EVENT      = 1'b0;
//assign oA2HIP_PM_EVENT_FUNC = 3'b0;
assign hpg_ctrler           = 5'h0;    // Hot plug


// Reconfiguration
assign reconfig_mgmt_address   = 7'h0;    //     reconfig_mgmt.address              input  wire
assign reconfig_mgmt_read      = 1'b0;    //                  .read                 input  wire
assign reconfig_mgmt_write     = 1'b0;    //                  .write                input  wire
assign reconfig_mgmt_writedata = 32'h0;   //                  .writedata            input  wire

lt_cfg_demux lt_cfg_demux (
  . iRST                                               ( ~app_rstn                                          ), // input
  . iPLD_CLK                                           ( iCLK_PCIE_GLOBAL                                   ), // input
  . iTL_CFG_ADD                                        ( iHIP2A_TL_CFG_ADD[3:0]                             ), // input [3:0]
  . iTL_CFG_CTL                                        ( iHIP2A_TL_CFG_CTL[31:0]                            ), // input [31:0]
  . iTL_CFG_STS                                        ( iHIP2A_TL_CFG_STS[52:0]                            ), // input [52:0]
  . oCFG_DEVCSR                                        ( cfg_devcsr[31:0]                                   ), // output [31:0]
  . oCFG_LINKCSR                                       ( cfg_linkcsr[31:0]                                  ), // output [31:0]
  . oCFG_PRMCSR                                        ( cfg_prmcsr[31:0]                                   ), // output [31:0]
  . oCFG_IO_BAS                                        ( cfg_io_bas[19:0]                                   ), // output [19:0]
  . oCFG_IO_LIM                                        ( cfg_io_lim[19:0]                                   ), // output [19:0]
  . oCFG_NP_BAS                                        ( cfg_np_bas[11:0]                                   ), // output [11:0]
  . oCFG_NP_LIM                                        ( cfg_np_lim[11:0]                                   ), // output [11:0]
  . oCFG_PR_BAS                                        ( cfg_pr_bas[43:0]                                   ), // output [43:0]
  . oCFG_PR_LIM                                        ( cfg_pr_lim[43:0]                                   ), // output [43:0]
  . oCFG_TCVMAP                                        ( cfg_tcvmap[23:0]                                   ), // output [23:0]
  . oCFG_MSICSR                                        ( cfg_msicsr[15:0]                                   ), // output [15:0]
  . oCFG_BUSDEV                                        ( cfg_busdev[12:0]                                   )  // output [12:0]
);


hip_rst_blk hip_rst_blk_inst (
  . iPLD_CLK                                           ( iCLK_PCIE_GLOBAL                                   ), // input
  // assume always locked since free running clock
  . iHIP2A_FIXEDCLK_LOCKED                             ( 1'b1                                               ), // input
  . iHIP2A_PLD_CLK_INUSE                               ( iHIP2A_PLD_CLK_INUSE                               ), // input
  . iDLUP_EXIT_n                                       ( iHIP2A_DLUP_EXIT_n                                 ), // input
  . iHOTRST_EXIT_n                                     ( iHIP2A_HOTRST_EXIT_n                               ), // input
  . iL2_EXIT_n                                         ( iHIP2A_L2_EXIT_n                                   ), // input
  . iLTSSMSTATE                                        ( iHIP2A_LTSSMSTATE[4:0]                             ), // input [4:0]
  . iNPOR_n                                            ( ~iHIP2A_RESET_STATUS                               ), // input
  . iBUSY_XCVR_RECONFIG                                ( oA2HIP_BUSY_XCVR_RECONFIG                          ), // input
   // Speeds up simulation. Removed in synthesis
  . iSIMULATION_FORCE_DEASSERT                         ( 1'b1                                               ), // input

  . oAPP_RST_n                                         ( app_rstn                                           ), // output
  . oCRST                                              ( crst                                               )  // output
);


///////////////////////////////////////////////////////////////////////////////
//
//  RX - decode the TLP
//
///////////////////////////////////////////////////////////////////////////////
rx_tlp_decode #(
  . BALI                                               ( BALI                                               )
) rx_tlp_decode_inst (
  . iRST                                               ( ~app_rstn                                          ), // input
  . iCLK                                               ( iCLK_PCIE_GLOBAL                                   ), // input
  // RX PCIE AVALON-ST I/F
  . iRX_ST_DATA                                        ( iRX_ST_DATA                                        ), // input [255:0]
  . oRX_ST_READY                                       ( oRX_ST_READY                                       ), // output
  . iRX_ST_SOP                                         ( iRX_ST_SOP                                         ), // input
  . iRX_ST_VALID                                       ( iRX_ST_VALID                                       ), // input
  . iRX_ST_EMPTY                                       ( iRX_ST_EMPTY                                       ), // input [1:0]
  . iRX_ST_EOP                                         ( iRX_ST_EOP                                         ), // input
  . iRX_ST_ERR                                         ( iRX_ST_ERR                                         ), // input
  . iRX_ST_BE                                          ( iRX_ST_BE                                          ), // input [31:0]
  . oRX_ST_MASK                                        ( oRX_ST_MASK                                        ), // output
  . iRX_ST_BAR                                         ( iRX_ST_BAR                                         ), // input [7:0]
  // control inputs
  . iDONE_PULSE                                        ( to_decode_done_pulse                               ), // input

  // decoded outputs
  . oDECODE_VALID                                      ( rx_decode_valid                                    ), // output
  . oHDR0                                              ( rx_tlp_hdr0                                        ), // output
  . oHDR1                                              ( rx_tlp_hdr1                                        ), // output
  . oADDR                                              ( rx_addr_qwaligned                                  ), // output [29:0]
  . oWR_DATA                                           ( rx_wr_data                                         ), // output [63:0]
  . oTRANS_TYPE                                        ( rx_trans_type                                      ), // output
  . oTLP_MRD                                           ( rx_tlp_mrd                                         ), // output
  . oTLP_MWR                                           ( rx_tlp_mwr                                         ), // output
  . oTLP_UR                                            ( rx_tlp_ur                                          ), // output
  . oTLP_NON_POSTED                                    ( rx_tlp_non_posted                                  ), // output
  . oTLP_EP                                            ( rx_tlp_ep                                          ), // output
  . oTLP_3DW_4DW_n                                     ( rx_tlp_3dw_4dw_n                                   ), // output
  . oTLP_ADDR_QWALIGNED                                ( rx_tlp_addr_qwaligned                              )  // output
);


///////////////////////////////////////////////////////////////////////////////
//
//  RX - Generate MM Signals
//
///////////////////////////////////////////////////////////////////////////////
rx_tlp2mm_if rx_tlp2mm_if_inst (
  . iRST                                               ( ~app_rstn                                          ), // input
  . iCLK                                               ( iCLK_PCIE_GLOBAL                                   ), // input

  . iREG_PCIETIMEOUTPERIOD                             ( pcietimeoutperiod                                  ), // input [19:0]
  . oREG_PCIEWRTIMEOUTCTR_EN                           ( pciewrtimeoutctr_en                                ), // output

  . iFR_TX_DONE_PULSE                                  ( fr_tx_done_pulse                                   ), // input
  . oTO_DECODE_DONE_PULSE                              ( to_decode_done_pulse                               ), // output

  // decoded inputs
  . iDECODE_VALID                                      ( rx_decode_valid                                    ), // input
  . iTLP_HDR0                                          ( rx_tlp_hdr0                                        ), // input
  . iTLP_HDR1                                          ( rx_tlp_hdr1                                        ), // input
  . iTLP_ADDR                                          ( rx_addr_qwaligned                                  ), // input [29:0]
  . iTLP_WR_DATA                                       ( rx_wr_data                                         ), // input [63:0]
  . iTLP_MRD                                           ( rx_tlp_mrd & (~rx_tlp_ep)                          ), // input
  . iTLP_MWR                                           ( rx_tlp_mwr & (~rx_tlp_ep)                          ), // input
  . iTLP_UR                                            ( rx_tlp_ur                                          ), // input
  . iTLP_NON_POSTED                                    ( rx_tlp_non_posted                                  ), // input

  . iMM_ACK_PULSE                                      ( iMM2PCIE_ACK                                       ), // input
  . oMM_WR_DATA                                        ( mm_wr_data                                         ), // output [63:0]
  . oMM_ADDRESS                                        ( mm_address                                         ), // output [20:0]
  . oMM_WR_EN_PULSE                                    ( mm_wr_en_pulse                                     ), // output
  . oMM_RD_EN_PULSE                                    ( mm_rd_en_pulse                                     )  // output
);


///////////////////////////////////////////////////////////////////////////////
//
//  TX - Generate CplD and Cpl TLP Packets
//
///////////////////////////////////////////////////////////////////////////////
tx_mm2tlp_if tx_mm2tlp_if_inst (
  . iRST                                               ( ~app_rstn                                          ), // input
  . iRST_100M                                          ( ~iRST_100M_N                                       ), // input
  . iCLK                                               ( iCLK_PCIE_GLOBAL                                   ), // input
  . iCLK_100M                                          ( iCLK_100M                                          ), // input

  . oFR_TX_DONE_PULSE                                  ( fr_tx_done_pulse                                   ), // output

  // decoded rx tlp inputs
  . iDECODE_VALID                                      ( rx_decode_valid                                    ), // input
  . iTLP_HDR0                                          ( rx_tlp_hdr0                                        ), // input
  . iTLP_HDR1                                          ( rx_tlp_hdr1                                        ), // input
  . iADDR_QWALIGNED                                    ( rx_addr_qwaligned                                  ), // input [29:0]

  . iTLP_MRD                                           ( rx_tlp_mrd                                         ), // input
  . iTLP_MWR                                           ( rx_tlp_mwr & (~rx_tlp_ep)                          ), // input
  . iTLP_UR                                            ( rx_tlp_ur                                          ), // input
  . iTLP_NON_POSTED                                    ( rx_tlp_non_posted                                  ), // input

  . iCFG_BUSDEV                                        ( cfg_busdev                                         ), // input [12:0]
  . iFN_NUM                                            ( 3'b0                                               ), // input [2:0]

  // From FPGA Register Modules
  . iMM_RD_DATA                                        ( iMM2PCIE_RD_DATA                                   ), // input [63:0]
  . iMM_RD_DATA_VALID                                  ( iMM2PCIE_ACK                                       ), // input

  // arbitrate to transmit TLP Completion
  . oTX_REQ                                            ( tx_tlp_req[0]                                      ), // output
  . iTX_GNT                                            ( tx_tlp_gnt[0]                                      ), // input

  // TX PCIE AVALON-ST I/F
  . oTX_ST                                             ( tx_st[0]                                           ), // output
  . oTX_ST_DATA                                        ( tx_st_data[0]                                      ), // output [255:0]

  . iREG_PCIETIMEOUTPERIOD                             ( pcietimeoutperiod[19:0]                            ), // input [19:0]
  . oREG_PCIETIMEOUTCTR_EN                             ( pcierdtimeoutctr_en                                )  // output
);

assign oA2HIP_PM_DATA = 10'b0;
assign oA2HIP_CPL_PENDING = 1'b0;


///////////////////////////////////////////////////////////////////////////////
//
//  TX - arbitrate between CplD from MRd and DMA MWr (4KB)
//
///////////////////////////////////////////////////////////////////////////////
tx_app2hip_arbiter #(
  . PORTS                                              ( PORTS                                              ),
  . BALI                                               ( BALI                                               )
) tx_app2hip_arbiter_inst (
  . iRST                                               ( ~app_rstn | ~iRST_CHIP_PCIE_N                      ), // input
  . iCLK                                               ( iCLK_PCIE_GLOBAL                                   ), // input
  // Arbitration
  . iREQ                                               ( tx_tlp_req                                         ), // input [2:0]
  . oGNT                                               ( tx_tlp_gnt                                         ), // output [2:0]
  // Single-Cycle & DMA Avalon Streaming I/F
  . iTX_ST                                             ( tx_st                                              ), // input
  . iTX_ST_DATA                                        ( tx_st_data                                         ), // input [2:0][255:0]
  . iLINK_NUMBER                                       ( hip_arb_link_number                                ), // input [PORT_WIDTH-1:0]
  . iBLK_DONE_PULSE                                    ( tx_blk_done_pulse                                  ), // input
  // HIP Avalon Streaming Bus I/F
  . iTX_ST_READY                                       ( iTX_ST_READY                                       ), // input
  . oTX_ST                                             ( tx_app2hip_st                                      ), // output
  . oTX_ST_DATA                                        ( tx_app2hip_st_data                                 ), // output [255:0]
  // Link Arbiter
  . oHIP_BLK_DONE                                      ( hip_blk_done                                       ), // output
  . oHIP_LINK_NUMBER                                   ( hip_link_number                                    )  // output [PORT_WIDTH-1:0]
);

tx_tlp_test tx_tlp_test_inst (
  . iRST                                               ( ~app_rstn | ~iRST_CHIP_PCIE_N                      ), // input
  . iCLK                                               ( iCLK_PCIE_GLOBAL                                   ), // input

  . iSEND_TLP                                          ( pcie_test_reg[0]                                   ), // input

  // Arbitration
  . oREQ                                               ( tx_tlp_req[2]                                      ), // output
  . iGNT                                               ( tx_tlp_gnt[2]                                      ), // input

  // App Avalon Streaming Bus I/F
  . oTX_ST                                             ( tx_st[2]                                           ), // output
  . oTX_DATA                                           ( tx_st_data[2]                                      ), // output [255:0]

  // from HIP
  . iCFG_BUSDEV                                        ( cfg_busdev                                         ), // input [12:0]
  . iFN_NUM                                            ( 3'b0                                               )  // input [2:0]
);





///////////////////////////////////////////////////////////////////////////////
//
//  TX - DMA MWr (4KB)
//
///////////////////////////////////////////////////////////////////////////////
tx_tlp_dma #(
  . PORTS                                              ( PORTS                                              )
) tx_tlp_dma_inst (
  . iRST                                               ( ~app_rstn | ~iRST_CHIP_PCIE_N                      ), // input
  . iCLK                                               ( iCLK_PCIE_GLOBAL                                   ), // input

  // Link Arbiter FIFO I/F
  . iFIFO_FULL                                         ( tx_fifo_full                                       ), // input
  . iFIFO_USED                                         ( tx_fifo_used                                       ), // input [7:0]
  . iFIFO_DATA                                         ( tx_fifo_data                                       ), // input [255:0]
  . iFIFO_EMPTY                                        ( tx_fifo_empty                                      ), // input
  . oFIFO_RD_ACK                                       ( tx_fifo_rd_ack                                     ), // output
  . oBLK_DONE_PULSE                                    ( tx_blk_done_pulse                                  ), // output
  . iLINK_NUMBER                                       ( tx_link_number                                     ), // input [PORT_WIDTH-1:0]
  . iREG_MAXPYLD                                       ( max_pyld_size[2:0]                                 ), // input [2:0]

  // Arbitration
  . oREQ                                               ( tx_tlp_req[1]                                      ), // output
  . iGNT                                               ( tx_tlp_gnt[1]                                      ), // input

  // App Avalon Streaming Bus I/F
  . oTX_ST                                             ( tx_st[1]                                           ), // output
  . oTX_DATA                                           ( tx_st_data[1]                                      ), // output [255:0]
  . oLINK_NUMBER                                       ( hip_arb_link_number                                ), // output [PORT_WIDTH-1:0]

  . iCFG_BUSDEV                                        ( cfg_busdev                                         ), // input [12:0]
  . iFN_NUM                                            ( 3'b0                                               ), // input [2:0]

  // Next DPL PFN
  . iDPLBUF_WR_PTR                                     ( dplbuf_wr_ptr                                      ), // input [PORTS-1:0][31:0]
  . oDPLBUF_INC_WR_PTR                                 ( dplbuf_inc_wr_ptr                                  )  // output [PORTS-1:0]
);

tx_link_arbiter #(
  . PORTS                                              ( PORTS                                              )
  //. PORTS_ROUNDUP                                      ( 2                                                  )
) tx_link_arbiter_inst (
  . iRST                                               ( ~app_rstn | ~iRST_CHIP_PCIE_N                      ), // input
  . iCLK                                               ( iCLK_PCIE_GLOBAL                                   ), // input

   // Link Arbiter FIFO Write I/F
  . iDPLBUF_FULL                                       ( dplbuf_full                                        ), // input [PORTS-1:0]
  . iDPLBUF_REQ                                        ( iDPLBUF_REQ                                        ), // input [PORTS-1:0]
  . oDPLBUF_GNT                                        ( oDPLBUF_GNT                                        ), // output [PORTS-1:0]
  . iDPLBUF_DATA                                       ( iDPLBUF_DATA                                       ), // input [255:0]
  . iDPLBUF_DATA_V                                     ( iDPLBUF_DATA_V                                     ), // input [PORTS-1:0]

   // Link Arbiter FIFO Read I/F
  . oFIFO_FULL                                         ( tx_fifo_full                                       ), // output
  . oFIFO_USED                                         ( tx_fifo_used                                       ), // output [7:0]
  . oFIFO_DATA                                         ( tx_fifo_data                                       ), // output [255:0]
  . oFIFO_EMPTY                                        ( tx_fifo_empty                                      ), // output
  . oLINK_NUMBER                                       ( tx_link_number                                     ), // output [PORT_WIDTH-1:0]
  . iFIFO_RD_ACK                                       ( tx_fifo_rd_ack                                     ), // input
  . iBLK_DONE_PULSE                                    ( tx_blk_done_pulse                                  ), // input

   // HIP Arbiter
  . iHIP_BLK_DONE                                      ( hip_blk_done                                       ), // input
  . iHIP_LINK_NUMBER                                   ( hip_link_number                                    ), // input [PORT_WIDTH-1:0]

   // Register
  . oREG_FLUSHSTATUS                                   ( reg_flushstatus                                    ), // output [PORTS-1:0]
  . oREG_FLUSH_CTR_BLK_FLUSH_CTR                       ( iREG_FLUSH_CTR_BLK_FLUSH_CTR                       ), // output [PORTS-1:0][2:0]
  . oREG_HIP_BLK_DONE_CNT_EN                           ( iREG_HIP_BLK_DONE_CNT_EN                           ), // output
  . oREG_GNT_CNT_EN                                    ( iREG_GNT_CNT_EN                                    ), // output
  . oREG_DPL_FIFO_WRREQ_CNT_EN                         ( iREG_DPL_FIFO_WRREQ_CNT_EN                         ), // output
  . oREG_TX_BLK_DONE_CNT_EN                            ( iREG_TX_BLK_DONE_CNT_EN                            ), // output
  . oREG_LINK_NUM_FIFO_WR_PULSE_EN                     ( iREG_LINK_NUM_FIFO_WR_PULSE_EN                     ), // output
  . oREG_DEBUG_LINK_ARB_FIFO_USED                      ( iREG_DEBUG_LINK_ARB_FIFO_USED[7:0]                 ), // output [7:0]
  . oREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_FULL             ( iREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_FULL             ), // output
  . oREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_EMPTY            ( iREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_EMPTY            ), // output
  . oREG_DEBUG_LINK_ARB_FIFO_EMPTY                     ( iREG_DEBUG_LINK_ARB_FIFO_EMPTY                     ), // output
  . oREG_DEBUG_LINK_ARB_FIFO_FULL                      ( iREG_DEBUG_LINK_ARB_FIFO_FULL                      ), // output
  . oREG_DEBUG_LINK_ARB_FIFO_BLK_AVAIL                 ( iREG_DEBUG_LINK_ARB_FIFO_BLK_AVAIL                 ), // output
  . oREG_DEBUG_LINK_ARB_ARB_PS                         ( iREG_DEBUG_LINK_ARB_ARB_PS[1:0]                    )  // output [2:0] fixme
);



///////////////////////////////////////////////////////////////////////////////
//
// DPL REGISTERS & DMA WRITE PTR MANAGEMENT
//
///////////////////////////////////////////////////////////////////////////////
genvar ii;
generate for (ii = 0; ii < PORTS; ii++)
begin: gen_dplbuf_regs_ptr

bali_dplbuf_regs #(
  . LITE                                               ( 0                                                  )
) bali_dplbuf_regs_inst (
  . clk                                                ( iCLK_PCIE_GLOBAL                                   ), // input
  . rst_n                                              ( app_rstn & iRST_PCIE_N[ii]                         ), // input
  . wr_en                                              ( DPLBUF_WR_EN[ii]                                   ), // input
  . rd_en                                              ( DPLBUF_RD_EN[ii]                                   ), // input
  . addr                                               ( DPLBUF_ADDR[ii][9:0]                               ), // input [9:0]
  . wr_data                                            ( DPLBUF_WR_DATA[ii]                                 ), // input [63:0]
  . rd_data                                            ( DPLBUF_RD_DATA[ii]                                 ), // output [63:0]
  . rd_data_v                                          ( DPLBUF_RD_DATA_V[ii]                               ), // output
  . oREG__SCRATCH                                      ( ), // output [63:0]
  . oREG_DPLBUFSTARTPFN                                ( reg_dplbuf_start_pfn[ii]                           ), // output [31:0]
  . oREG_DPLBUFLASTPFN                                 ( reg_dplbuf_last_pfn[ii]                            ), // output [31:0]
  . oREG_DPLBUFRDPTR                                   ( reg_dplbuf_rd_ptr[ii]                              ), // output [31:0]
  . iREG_DPLBUFWRPTR                                   ( dplbuf_wr_ptr[ii]                                  ), // input [31:0]
  . iREG_DPLBUFFREEPFN                                 ( dplbuf_free[ii]                                    ), // input [31:0]
  . oREG_DPLBUFPTRRST                                  ( dplbufptr_rst[ii]                                  )  // output
);

dplbuf_ptr_mgmt #(
  . BALI                                               ( BALI                                               )
) dplbuf_ptr_mgmt_inst (
  . iRST                                               ( ~app_rstn | ~iRST_PCIE_N[ii]                       ), // input
  . iCLK                                               ( iCLK_PCIE_GLOBAL                                   ), // input
  . iRST_PTR                                           ( dplbufptr_rst[ii]                                  ), // input
  . iDPLBUF_INC_WR_PTR                                 ( dplbuf_inc_wr_ptr[ii]                              ), // input
  . iDPLBUF_START_PFN                                  ( reg_dplbuf_start_pfn[ii]                           ), // input [31:0]
  . iDPLBUF_LAST_PFN                                   ( reg_dplbuf_last_pfn[ii]                            ), // input [31:0]
  . iDPLBUF_RD_PTR                                     ( reg_dplbuf_rd_ptr[ii]                              ), // input [31:0]
  . oDPLBUF_WR_PTR                                     ( dplbuf_wr_ptr[ii]                                  ), // output [31:0]
  . oDPLBUF_FREE                                       ( dplbuf_free[ii]                                    ), // output [31:0]
  . oDPLBUF_FULL                                       ( dplbuf_full[ii]                                    )  // output
);
end
endgenerate

///////////////////////////////////////////////////////////////////////////////
//
//  Auto-generated register modules
//
///////////////////////////////////////////////////////////////////////////////

   // synchronize the app_rstn signal into the pcie_coreclkout_hip clock domain

   vi_rst_sync_async rst_sync_pcie_hip_inst
     (.iRST_ASYNC_N (app_rstn),
      .iCLK         (iCLK_PCIE_CORECLKOUT_HIP),
      .oRST_SYNC_N  (coreclkout_app_rstn));

   // syncronize the enables.  The source clock for these enables uses the local PCIE clock
   // These signals are level signals

   vi_sync_level #(.SIZE(9)) vi_sync_level_inst
   (.clk       (iCLK_PCIE_GLOBAL),
    .rst_n     (app_rstn),
    .in_level  ({iHIP2A_CURRENTSPEED[1:0],
                 iHIP2A_LANE_ACT[3:0],
                 iHIP2A_SERDES_PLL_LOCKED,
                 iHIP2A_DLUP_EXIT_n,
                 iHIP2A_L2_EXIT_n
                 }),
    .out_level  ({hip2a_currentspeed_sync[1:0],
                  hip2a_lane_act_sync[3:0],
                  hip2a_serdes_pll_locked_sync,
                  hip2a_dlup_exit_n_sync,
                  hip2a_l2_exit_n_sync
                 })
    );

   // syncronize the enables.  The source clock for these enables uses the local PCIE clock
   // These signals are converted to pulses

   vi_sync_pulse vi_sync_pulse_0
   (// source
    .clka       (iCLK_PCIE_CORECLKOUT_HIP),
    .rsta_n     (coreclkout_app_rstn),
    .in_pulse   (iHIP2A_DERR_COR_EXT_RCV),
    // dest
    .clkb       (iCLK_PCIE_GLOBAL),
    .rstb_n     (app_rstn),
    .out_pulse  (hip2a_derr_cor_ext_rcv_sync));

   vi_sync_pulse vi_sync_pulse_1
   (// source
    .clka       (iCLK_PCIE_CORECLKOUT_HIP),
    .rsta_n     (coreclkout_app_rstn),
    .in_pulse   (iHIP2A_DERR_RPL),
    // dest
    .clkb       (iCLK_PCIE_GLOBAL),
    .rstb_n     (app_rstn),
    .out_pulse  (hip2a_derr_rpl_sync));

   vi_sync_pulse vi_sync_pulse_2
   (// source
    .clka       (iCLK_PCIE_CORECLKOUT_HIP),
    .rsta_n     (coreclkout_app_rstn),
    .in_pulse   (iHIP2A_DERR_COR_EXT_RPL),
    // dest
    .clkb       (iCLK_PCIE_GLOBAL),
    .rstb_n     (app_rstn),
    .out_pulse  (hip2a_derr_cor_ext_rpl_sync));

bali_pcie_regs #(
  . LITE                                               ( 0                                                  )
) bali_pcie_regs_inst (
  . clk                                                ( iCLK_PCIE_GLOBAL                                   ), // input
  . rst_n                                              ( app_rstn & iRST_CHIP_PCIE_N                        ), // input
  . wr_en                                              ( PCIECTRL_WR_EN                                     ), // input
  . rd_en                                              ( PCIECTRL_RD_EN                                     ), // input
  . addr                                               ( {6'h0,PCIECTRL_ADDR}                               ), // input [9:0]
  . wr_data                                            ( PCIECTRL_WR_DATA                                   ), // input [63:0]
  . rd_data                                            ( PCIECTRL_RD_DATA                                   ), // output [63:0]
  . rd_data_v                                          ( PCIECTRL_RD_DATA_V                                 ), // output
  . oREG__SCRATCH                                      ( ), // output [63:0]
  . oREG_PCIEAPPCTL                                    ( pcie_test_reg[0]                                   ), // output
  . iREG_PCIESTATUS_CURRENTLANES                       ( hip2a_lane_act_sync[3:0]                           ), // input [3:0]
  . iREG_PCIESTATUS_CURRENTSPEED                       ( hip2a_currentspeed_sync[1:0]                       ), // input [1:0]
  . iREG_PCIESTATUS_FIXEDCLK_LOCKED                    ( 1'b1                                               ), // input
  . iREG_PCIESTATUS_SERDES_PLL_LOCKED                  ( hip2a_serdes_pll_locked_sync                       ), // input
  . iREG_SERDES_PLL_LOCKED_CTR_EN                      ( ~hip2a_serdes_pll_locked_sync                      ), // input
  . iREG_DLUP_EXIT_CTR_EN                              ( ~hip2a_dlup_exit_n_sync                            ), // input
  . iREG_L2_EXIT_CTR_EN                                ( ~hip2a_l2_exit_n_sync                              ), // input
  . iREG_ECC_DERR_COR_EXT_RCV_EN                       ( hip2a_derr_cor_ext_rcv_sync                        ), // input
  . iREG_ECC_DERR_RPL_EN                               ( hip2a_derr_rpl_sync                                ), // input
  . iREG_ECC_DERR_COR_EXT_RPL_EN                       ( hip2a_derr_cor_ext_rpl_sync                        ), // input
  . iREG_POISON_TLP_RECEIVED_CNT_EN                    ( rx_tlp_ep & rx_decode_valid                        ), // input
  . iREG_UR_NP_TLP_RECEIVED_CNT_EN                     ( rx_tlp_ur & rx_tlp_non_posted & rx_decode_valid    ), // input
  . iREG_UR_TLP_RECEIVED_CNT_EN                        ( rx_tlp_ur & rx_decode_valid                        ), // input
  . oREG_MAXPYLD                                       ( max_pyld_size[2:0]                                 ), // output [2:0]
  . oREG_PCIETIMEOUTPERIOD                             ( pcietimeoutperiod[19:0]                            ), // output [19:0]
  . iREG_PCIERDTIMEOUTCTR_EN                           ( pcierdtimeoutctr_en                                ), // input
  . iREG_PCIEWRTIMEOUTCTR_EN                           ( pciewrtimeoutctr_en                                ), // input
  . iREG_FLUSHSTATUS                                   ( reg_flushstatus                                    ), // input [23:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_11                    ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[11][2:0]              ), // input [2:0] old fixme
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_10                    ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[10][2:0]              ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_9                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[9][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_8                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[8][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_7                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[7][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_6                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[6][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_5                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[5][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_4                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[4][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_3                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[3][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_2                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[2][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_1                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[1][2:0]               ), // input [2:0]
  . iREG_FLUSH_CTR_BLK_FLUSH_CTR_0                     ( iREG_FLUSH_CTR_BLK_FLUSH_CTR[0][2:0]               ), // input [2:0]
  . iREG_HIP_BLK_DONE_CNT_EN                           ( iREG_HIP_BLK_DONE_CNT_EN                           ), // input
  . iREG_GNT_CNT_EN                                    ( iREG_GNT_CNT_EN                                    ), // input
  . iREG_DPL_FIFO_WRREQ_CNT_EN                         ( iREG_DPL_FIFO_WRREQ_CNT_EN                         ), // input
  . iREG_TX_BLK_DONE_CNT_EN                            ( iREG_TX_BLK_DONE_CNT_EN                            ), // input
  . iREG_LINK_NUM_FIFO_WR_PULSE_EN                     ( iREG_LINK_NUM_FIFO_WR_PULSE_EN                     ), // input
  . iREG_DEBUG_LINK_ARB_FIFO_USED                      ( iREG_DEBUG_LINK_ARB_FIFO_USED[7:0]                 ), // input [7:0]
  . iREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_FULL             ( iREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_FULL             ), // input
  . iREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_EMPTY            ( iREG_DEBUG_LINK_ARB_LINK_NUM_FIFO_EMPTY            ), // input
  . iREG_DEBUG_LINK_ARB_FIFO_EMPTY                     ( iREG_DEBUG_LINK_ARB_FIFO_EMPTY                     ), // input
  . iREG_DEBUG_LINK_ARB_FIFO_FULL                      ( iREG_DEBUG_LINK_ARB_FIFO_FULL                      ), // input
  . iREG_DEBUG_LINK_ARB_FIFO_BLK_AVAIL                 ( iREG_DEBUG_LINK_ARB_FIFO_BLK_AVAIL                 ), // input
  . iREG_DEBUG_LINK_ARB_ARB_PS                         ( iREG_DEBUG_LINK_ARB_ARB_PS[1:0]                    )  // input [1:0]
);

///////////////////////////////////////////////////////////////////////////////
//
//  Performance counters
//
///////////////////////////////////////////////////////////////////////////////

pcie_perf_ctl #(
  . PORTS                                              ( PORTS                                              )
) pcie_perf_ctl_inst (
  . clk                                                ( iCLK_PCIE_GLOBAL                                   ), // input
  . rst_n                                              ( app_rstn & iRST_CHIP_PCIE_N                        ), // input
  . iST_SOP                                            ( tx_app2hip_st.sop                                  ), // input
  . iST_VAL                                            ( tx_app2hip_st.valid                                ), // input
  . iST_EMPTY                                          ( tx_app2hip_st.empty                                ), // input [1:0]
  . iST_RDY_N                                          ( ~iTX_ST_READY                                      ), // input
  . iDPLBUF_REQ                                        ( iDPLBUF_REQ                                        ), // input [PORTS-1:0]
  . iDPLBUF_GNT                                        ( dplbuf_gnt                                         ), // input [PORTS-1:0]
  . iBLK_DONE                                          ( tx_blk_done_pulse                                  ), // input
  . iLINK_NUM                                          ( tx_link_number                                     ), // input [PORT_WIDTH-1:0]
  . iLATCH                                             ( pcie_perf_latch                                    ), // input
  . iPERF_REQ_TICKS                                    ( pcie_perf_req                                      ), // input [PORTS-1:0][31:0]
  . oPERF_SOP_CTR                                      ( pcie_perf_sop_ctr                                  ), // output
  . oPERF_BYTE_CTR                                     ( pcie_perf_byte_ctr                                 ), // output [2:0]
  . oPERF_RDY_N                                        ( pcie_perf_rdy_n                                    ), // output
  . oPERF_LINK_REQ                                     ( pcie_perf_link_req                                 ), // output [PORTS-1:0]
  . oPERF_LINK_DONE                                    ( pcie_perf_link_done                                ), // output [PORTS-1:0]
  . oPERF_TICKS_MAX                                    ( pcie_perf_reqtic_max                               )  // output [PORTS-1:0][31:0]
);

// reset synchronizer to PCIe Reconfig Controller
vi_rst_sync_async rst_sync_recfg_inst
(
  .iRST_ASYNC_N (~iHIP2A_RESET_STATUS),  // in PCIe clk domain
  .iCLK         (iRECONFIG_XCVR_CLK),
  .oRST_SYNC_N  (mgmt_rst_reset_n)
);

assign mgmt_rst_reset = ~mgmt_rst_reset_n;


//assign oA2HIP_BUSY_XCVR_RECONFIG = reconfig_busy;
   assign oA2HIP_BUSY_XCVR_RECONFIG = 1'b0;

assign oA2HIP_PLD_CORE_READY =  iHIP2A_SERDES_PLL_LOCKED;

//   generate begin : g_hip_coreclkout_gclk
//      if  (PLD_CLK_IS_250MHZ==1) begin
//         wire fbclkout;
//         wire open_locked;
//         wire open_fbclkout;
//         //                                                                _______
//         //                                 |-------oA2HIP_PLD_CLK_HIP----------->|      |
//         //                                 |   (pldclk_hip_phase_shift)   |      |
//         //                               __^_                             | HIP  |
//         //                              |    |                            |      |
//         //                              |PLL |                            |      |
//         //   <------pld_clk<-----------<|____|<iHIP2A_CORECLKOUT_HIP---<|______|
//         //    (pldclk_phaseshift)
//         //
//         // PLL to generate phase shifted pld_clk to apps i.e. apps_clk
//         generic_pll #       ( .reference_clock_frequency("250.0 MHz"), .output_clock_frequency("250.0 MHz"), .phase_shift("0 ps"/*pldclk_phaseshift*/))
//            u_pll_coreclkout ( .refclk(iHIP2A_CORECLKOUT_HIP), .outclk(pld_clk), .locked(coreclkout_pll_locked), .fboutclk(fbclkout), .rst(~iHIP2A_SERDES_PLL_LOCKED), .fbclk(fbclkout));
//
//
//         // PLL to generate phase shifted iHIP2A_CORECLKOUT_HIP to HIP
//         // Cascaded PLL module requires : .locked(open_locked), .fboutclk(open_fbclkout),
//         generic_pll #       ( .reference_clock_frequency("250.0 MHz"), .output_clock_frequency("250.0 MHz"),  .phase_shift("0 ps" /*pldclk_hip_phase_shift*/))
//            u_pll_pldclk     ( .refclk(iHIP2A_CORECLKOUT_HIP), .outclk(oA2HIP_PLD_CLK_HIP), .locked(open_locked), .fboutclk(open_fbclkout), .rst(~iHIP2A_SERDES_PLL_LOCKED), .fbclk(fbclkout));
//      end
//      else begin
//
//         //synthesis translate_off
//         assign pld_clk = iHIP2A_CORECLKOUT_HIP;
//         //synthesis translate_on
//
//         //synthesis read_comments_as_HDL on
//         //global u_global_buffer_coreclkout (.in(iHIP2A_CORECLKOUT_HIP), .out(pld_clk));
//         //synthesis read_comments_as_HDL off
//
//         assign oA2HIP_PLD_CLK_HIP   = iHIP2A_CORECLKOUT_HIP;
//      end
//   end
//   endgenerate


///////////////////////////////////////////////////////////////////////////////
//
//  Address decode module
//
///////////////////////////////////////////////////////////////////////////////
pcie_addr_dec_wrap #(
  . PORTS                                              ( PORTS                                              )
) pcie_addr_dec_wrap_inst (
  . tx_cred_datafccp(tx_cred_datafccp),
  . tx_cred_datafcnp(tx_cred_datafcnp),
  . tx_cred_datafcp(tx_cred_datafcp),
  . tx_cred_fchipcons(tx_cred_fchipcons),
  . tx_cred_fcinfinite(tx_cred_fcinfinite),
  . tx_cred_hdrfccp(tx_cred_hdrfccp),
  . tx_cred_hdrfcnp(tx_cred_hdrfcnp),
  . tx_cred_hdrfcp(tx_cred_hdrfcp),


  . iRST_N                                             ( app_rstn & iRST_CHIP_PCIE_N                        ), // input
  . iCLK_PCIE_GLOBAL                                   ( iCLK_PCIE_GLOBAL                                   ), // input

  . oPCIECTRL_ADDR                                     ( PCIECTRL_ADDR                                      ), // output [13:0]
  . oPCIECTRL_WR_DATA                                  ( PCIECTRL_WR_DATA                                   ), // output [63:0]
  . oPCIECTRL_WR_EN                                    ( PCIECTRL_WR_EN                                     ), // output
  . oPCIECTRL_RD_EN                                    ( PCIECTRL_RD_EN                                     ), // output

  . oDPLBUF_ADDR                                       ( DPLBUF_ADDR                                        ), // output [PORTS-1:0][13:0]
  . oDPLBUF_WR_DATA                                    ( DPLBUF_WR_DATA                                     ), // output [PORTS-1:0][63:0]
  . oDPLBUF_WR_EN                                      ( DPLBUF_WR_EN                                       ), // output [PORTS-1:0]
  . oDPLBUF_RD_EN                                      ( DPLBUF_RD_EN                                       ), // output [PORTS-1:0]


  . iMM_ADDR                                           ( iMM_ADDR[16:0]                                     ), // input [16:0]
  . iMM_WR_EN                                          ( iMM_WR_EN                                          ), // input
  . iMM_RD_EN                                          ( iMM_RD_EN                                          ), // input
  . iMM_WR_DATA                                        ( iMM_WR_DATA                                        ), // input [63:0]

  . oPERF_LATCH                                        ( pcie_perf_latch                                    ), // output
  . oPERF_REQ                                          ( pcie_perf_req                                      ), // output [PORTS-1:0][31:0]

  . iPERF_SOP_CTR                                      ( pcie_perf_sop_ctr                                  ), // input
  . iPERF_RDY_N                                        ( pcie_perf_rdy_n                                    ), // input
  . iPERF_LINK_REQ                                     ( pcie_perf_link_req                                 ), // input [PORTS-1:0]
  . iPERF_REQTIC_MAX                                   ( pcie_perf_reqtic_max                               ), // input [PORTS-1:0][31:0]
  . iPERF_LINK_DONE                                    ( pcie_perf_link_done                                ), // input [PORTS-1:0]
  . iPERF_BYTE_CTR                                     ( pcie_perf_byte_ctr                                 ), // input [2:0]

  . oMM_RD_DATA                                        ( oMM_RD_DATA                                        ), // output [63:0]
  . oMM_RD_DATA_V                                      ( oMM_RD_DATA_V                                      ), // output

  . iPCIECTRL_RD_DATA                                  ( PCIECTRL_RD_DATA                                   ), // input [63:0]
  . iPCIECTRL_RD_DATA_V                                ( PCIECTRL_RD_DATA_V                                 ), // input

  . iDPLBUF_DATA_V                                     ( iDPLBUF_DATA_V                                     ), // input [PORTS-1:0]
  . iDPLBUF_RD_DATA                                    ( DPLBUF_RD_DATA                                     ), // input [PORTS-1:0][63:0]
  . iDPLBUF_RD_DATA_V                                  ( DPLBUF_RD_DATA_V                                   )  // input [PORTS-1:0]
);

//
// From Altera Stratix V USER GUIDE - November 2011:
// reset_status - Reset Status signal. When asserted, this signal indicates that the Hard IP clock is in reset.
// The reset_status signal is "synchronous" to the iCLK_PCIE_GLOBAL and is deasserted only when the
// iCLK_PCIE_GLOBAL is stable.
//
// The Altera sample code in altpcied_sv_hwtcl.v used additional logic in fabric to synchronize
// resets to iCLK_PCIE_GLOBAL.  According to above note from guide this is unnecessary so it had been removed.


///////////////////////////////////////////////////////////////////////////////
//
//  FLOP Signals from HIP
//
///////////////////////////////////////////////////////////////////////////////
always @(posedge iCLK_PCIE_GLOBAL or posedge iHIP2A_RESET_STATUS)
begin
  if (iHIP2A_RESET_STATUS == 1'b1)
  begin
    currentspeed_r      <= ZEROS[1 : 0];
    derr_cor_ext_rcv_r  <= 1'b0;
    derr_cor_ext_rpl_r  <= 1'b0;
    derr_rpl_r          <= 1'b0;
    rx_par_err_r        <= 1'b0;
    tx_par_err_r        <= ZEROS[1:0];
    cfg_par_err_r       <= 1'b0;
    dlup_r              <= 1'b0;
    dlup_exit_r         <= 1'b0;
    ev128ns_r           <= 1'b0;
    ev1us_r             <= 1'b0;
    hotrst_exit_r       <= 1'b0;
    int_status_r        <= ZEROS[3 : 0];
    l2_exit_r           <= 1'b0;
    lane_act_r          <= ZEROS[3:0];
    ltssmstate_r        <= ZEROS[4 : 0];
    ko_cpl_spc_header_r <= ZEROS[7:0];
    ko_cpl_spc_data_r   <= ZEROS[11:0];
    tl_cfg_add_r        <= ZEROS[3 : 0];
    tl_cfg_ctl_r        <= ZEROS[31 : 0];
    tl_cfg_sts_r        <= ZEROS[52 : 0];
  end
  else
  begin
    currentspeed_r      <=  iHIP2A_CURRENTSPEED;
    derr_cor_ext_rcv_r  <=  iHIP2A_DERR_COR_EXT_RCV;
    derr_cor_ext_rpl_r  <=  iHIP2A_DERR_COR_EXT_RPL;
    derr_rpl_r          <=  iHIP2A_DERR_RPL;
    rx_par_err_r        <=  iHIP2A_RX_PAR_ERR;
    tx_par_err_r        <=  iHIP2A_TX_PAR_ERR;
    cfg_par_err_r       <=  iHIP2A_CFG_PAR_ERR;
    dlup_r              <=  iHIP2A_DLUP;
    dlup_exit_r         <=  iHIP2A_DLUP_EXIT_n;
    ev128ns_r           <=  iHIP2A_EV128NS;
    ev1us_r             <=  iHIP2A_EV1US;
    hotrst_exit_r       <=  iHIP2A_HOTRST_EXIT_n;
    int_status_r        <=  iHIP2A_INT_STATUS;
    l2_exit_r           <=  iHIP2A_L2_EXIT_n;
    lane_act_r          <=  iHIP2A_LANE_ACT;
    ltssmstate_r        <=  iHIP2A_LTSSMSTATE;
    ko_cpl_spc_header_r <=  iHIP2A_KO_CPL_SPC_HEADER;
    ko_cpl_spc_data_r   <=  iHIP2A_KO_CPL_SPC_DATA;
    tl_cfg_add_r        <=  iHIP2A_TL_CFG_ADD;
    tl_cfg_ctl_r        <=  iHIP2A_TL_CFG_CTL;
    tl_cfg_sts_r        <=  iHIP2A_TL_CFG_STS;
  end
end


always_ff @(posedge iCLK_PCIE_GLOBAL or posedge iHIP2A_RESET_STATUS)
begin
  if(iHIP2A_RESET_STATUS)
  begin
    rx_decode_valid_pipe <= '{default:0};
    rx_tlp_ur_r1         <= 1'b0;
    rx_tlp_non_posted_r1 <= 1'b0;
    oA2HIP_CPL_ERR[6:0]  <= 2'b0;
  end
  else
  begin
    rx_decode_valid_pipe <= {rx_decode_valid_pipe[0], rx_decode_valid};
    rx_tlp_ur_r1         <= rx_tlp_ur;
    rx_tlp_non_posted_r1 <= rx_tlp_non_posted;

    oA2HIP_CPL_ERR[6:0] <= '0;

    // rising-edge
    if(!rx_decode_valid_pipe[1] && rx_decode_valid_pipe[0])
    begin
      if(rx_tlp_ur_r1 && !rx_tlp_non_posted_r1)
        oA2HIP_CPL_ERR[4] <= 1'b1;
      if(rx_tlp_ur_r1 && rx_tlp_non_posted_r1)
        oA2HIP_CPL_ERR[5] <= 1'b1;
    end
  end
end



endmodule
// Local Variables:
// verilog-library-directories:("." "./regs")
// End:

///////////////////////////////////////////////////////////////////////////////
//
//  ASSERTIONS
//
///////////////////////////////////////////////////////////////////////////////

// tx_fifo_rd_ack when tx_fifo_empty ==1.
