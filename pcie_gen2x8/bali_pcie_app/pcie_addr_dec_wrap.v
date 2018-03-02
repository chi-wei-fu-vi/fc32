/********************************CONFIDENTIAL****************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: honda.yang $
* $Date: 2013-08-28 17:01:43 -0700 (Wed, 28 Aug 2013) $
* $Revision: 3293 $
* Description:
*
***************************************************************************/

module pcie_addr_dec_wrap #(

parameter   PORTS                       = 12    )

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


// MM 
output [63:0]               oMM_RD_DATA,
output                      oMM_RD_DATA_V,

// Control Register
output [13:0]               oPCIECTRL_ADDR,
output [63:0]               oPCIECTRL_WR_DATA,
output                      oPCIECTRL_WR_EN,
output                      oPCIECTRL_RD_EN,

// Performance
output                      oPERF_LATCH,
output [PORTS-1:0][31:0]    oPERF_REQ,

// DPLBUF
output [PORTS-1:0][13:0]    oDPLBUF_ADDR,
output [PORTS-1:0][63:0]    oDPLBUF_WR_DATA,
output [PORTS-1:0]          oDPLBUF_WR_EN,
output [PORTS-1:0]          oDPLBUF_RD_EN,


// Reset 
input                       iRST_N,

// Clock
input                       iCLK_PCIE_GLOBAL,

// MM 
input  [16:0]               iMM_ADDR,
input                       iMM_WR_EN,
input                       iMM_RD_EN,
input  [63:0]               iMM_WR_DATA,

// Control Register
input  [63:0]               iPCIECTRL_RD_DATA,
input                       iPCIECTRL_RD_DATA_V,

// Performance
input                       iPERF_SOP_CTR,
input                       iPERF_RDY_N,
input  [PORTS-1:0]          iPERF_LINK_REQ,
input  [PORTS-1:0][31:0]    iPERF_REQTIC_MAX,
input  [PORTS-1:0]          iPERF_LINK_DONE,
input  [2:0]                iPERF_BYTE_CTR,
input  [PORTS-1:0]          iDPLBUF_DATA_V,

// DPLBUF
input  [PORTS-1:0][63:0]    iDPLBUF_RD_DATA,
input  [PORTS-1:0]          iDPLBUF_RD_DATA_V


);

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [16:0]             DPLBUF_ADDR;            // From u_pcie_addr_dec of pcie_addr_decoder.v
wire [63:0]             DPLBUF_RD_DATA;         // From u_dplbuf_addr_dec of dplbuf_addr_decoder.v
wire                    DPLBUF_RD_DATA_V;       // From u_dplbuf_addr_dec of dplbuf_addr_decoder.v
wire                    DPLBUF_RD_EN;           // From u_pcie_addr_dec of pcie_addr_decoder.v
wire [63:0]             DPLBUF_WR_DATA;         // From u_pcie_addr_dec of pcie_addr_decoder.v
wire                    DPLBUF_WR_EN;           // From u_pcie_addr_dec of pcie_addr_decoder.v
wire [16:0]             PCIE_GLOBAL_ADDR;       // From u_pcie_addr_dec of pcie_addr_decoder.v
wire [63:0]             PCIE_GLOBAL_RD_DATA;    // From u_pg_addr_dec of xx02_g_addr_decoder.v
wire                    PCIE_GLOBAL_RD_DATA_V;  // From u_pg_addr_dec of xx02_g_addr_decoder.v
wire                    PCIE_GLOBAL_RD_EN;      // From u_pcie_addr_dec of pcie_addr_decoder.v
wire [63:0]             PCIE_GLOBAL_WR_DATA;    // From u_pcie_addr_dec of pcie_addr_decoder.v
wire                    PCIE_GLOBAL_WR_EN;      // From u_pcie_addr_dec of pcie_addr_decoder.v
// End of automatics

wire [13:0]             PCIEPERF_ADDR;
wire [63:0]             PCIEPERF_WR_DATA;
wire                    PCIEPERF_WR_EN;
wire                    PCIEPERF_RD_EN;
wire [63:0]             PCIEPERF_RD_DATA;
wire                    PCIEPERF_RD_DATA_V;



logic      tx_cred_datafcnp_inc;
logic      tx_cred_datafcp_inc;
logic      tx_cred_hdrfcnp_inc;
logic      tx_cred_hdrfcp_inc;
logic      tx_cred_datafcnp_inc_r;
logic      tx_cred_datafcp_inc_r;
logic      tx_cred_hdrfcnp_inc_r;
logic      tx_cred_hdrfcp_inc_r;

always @(posedge iCLK_PCIE_GLOBAL or negedge iRST_N)
  if (!iRST_N)
	begin
    tx_cred_datafcnp_inc <= 1'b0;
    tx_cred_datafcp_inc  <= 1'b0;
    tx_cred_hdrfcnp_inc  <= 1'b0;
    tx_cred_hdrfcp_inc   <= 1'b0;
    tx_cred_datafcnp_inc_r <= 1'b0;
    tx_cred_datafcp_inc_r  <= 1'b0;
    tx_cred_hdrfcnp_inc_r  <= 1'b0;
    tx_cred_hdrfcp_inc_r   <= 1'b0;
  end
  else
  begin
    tx_cred_datafcnp_inc_r <= tx_cred_datafcnp == 'h0;
    tx_cred_datafcp_inc_r  <= tx_cred_datafcp  == 'h0;
    tx_cred_hdrfcnp_inc_r  <= tx_cred_hdrfcnp  == 'h0;
    tx_cred_hdrfcp_inc_r   <= tx_cred_hdrfcp   == 'h0;
    tx_cred_datafcnp_inc <= tx_cred_datafcnp_inc_r;
    tx_cred_datafcp_inc  <= tx_cred_datafcp_inc_r;
    tx_cred_hdrfcnp_inc  <= tx_cred_hdrfcnp_inc_r;
    tx_cred_hdrfcp_inc   <= tx_cred_hdrfcp_inc_r;
  end


/* pcie_addr_decoder AUTO_TEMPLATE(
                                  .clk                  (iCLK_PCIE_GLOBAL),
                                  .rst_n                (iRST_N),
                                  .XX02_G_\(.*\)        (PCIE_GLOBAL_\1[]),
);

*/
   
pcie_addr_decoder u_pcie_addr_dec(/*AUTOINST*/
                                  // Outputs
                                  .oMM_RD_DATA          (oMM_RD_DATA[63:0]),
                                  .oMM_RD_DATA_V        (oMM_RD_DATA_V),
                                  .XX02_G_ADDR          (PCIE_GLOBAL_ADDR[16:0]), // Templated
                                  .XX02_G_WR_DATA       (PCIE_GLOBAL_WR_DATA[63:0]), // Templated
                                  .XX02_G_WR_EN         (PCIE_GLOBAL_WR_EN), // Templated
                                  .XX02_G_RD_EN         (PCIE_GLOBAL_RD_EN), // Templated
                                  .DPLBUF_ADDR          (DPLBUF_ADDR[16:0]),
                                  .DPLBUF_WR_DATA       (DPLBUF_WR_DATA[63:0]),
                                  .DPLBUF_WR_EN         (DPLBUF_WR_EN),
                                  .DPLBUF_RD_EN         (DPLBUF_RD_EN),
                                  // Inputs
                                  .clk                  (iCLK_PCIE_GLOBAL), // Templated
                                  .rst_n                (iRST_N),      // Templated
                                  .iMM_ADDR             (iMM_ADDR[16:0]),
                                  .iMM_WR_EN            (iMM_WR_EN),
                                  .iMM_RD_EN            (iMM_RD_EN),
                                  .iMM_WR_DATA          (iMM_WR_DATA[63:0]),
                                  .XX02_G_RD_DATA       (PCIE_GLOBAL_RD_DATA[63:0]), // Templated
                                  .XX02_G_RD_DATA_V     (PCIE_GLOBAL_RD_DATA_V), // Templated
                                  .DPLBUF_RD_DATA       (DPLBUF_RD_DATA[63:0]),
                                  .DPLBUF_RD_DATA_V     (DPLBUF_RD_DATA_V));


/* xx02_g_addr_decoder AUTO_TEMPLATE(
                                       .clk                  (iCLK_PCIE_GLOBAL),
                                       .rst_n                (iRST_N),
                                       .\([a-z]\)MM_\(.*\)   (PCIE_GLOBAL_\2[]),
                                       .CSR_\(.*\)           (PCIECTRL_\1[]),
                                       .PERF_\(.*\)          (PCIEPERF_\1[]),
);
*/

   xx02_g_addr_decoder u_pg_addr_dec
     (/*AUTOINST*/
      // Outputs
      .oMM_RD_DATA                      (PCIE_GLOBAL_RD_DATA[63:0]), // Templated
      .oMM_RD_DATA_V                    (PCIE_GLOBAL_RD_DATA_V), // Templated
      .CSR_ADDR                         (oPCIECTRL_ADDR[13:0]),   // Templated
      .CSR_WR_DATA                      (oPCIECTRL_WR_DATA[63:0]), // Templated
      .CSR_WR_EN                        (oPCIECTRL_WR_EN),        // Templated
      .CSR_RD_EN                        (oPCIECTRL_RD_EN),        // Templated
      .PERF_ADDR                        (PCIEPERF_ADDR[13:0]),   // Templated
      .PERF_WR_DATA                     (PCIEPERF_WR_DATA[63:0]), // Templated
      .PERF_WR_EN                       (PCIEPERF_WR_EN),        // Templated
      .PERF_RD_EN                       (PCIEPERF_RD_EN),        // Templated
      // Inputs
      .clk                              (iCLK_PCIE_GLOBAL),      // Templated
      .rst_n                            (iRST_N),              // Templated
      .iMM_ADDR                         (PCIE_GLOBAL_ADDR[13:0]), // Templated
      .iMM_WR_EN                        (PCIE_GLOBAL_WR_EN),     // Templated
      .iMM_RD_EN                        (PCIE_GLOBAL_RD_EN),     // Templated
      .iMM_WR_DATA                      (PCIE_GLOBAL_WR_DATA[63:0]), // Templated
      .CSR_RD_DATA                      (iPCIECTRL_RD_DATA[63:0]), // Templated
      .CSR_RD_DATA_V                    (iPCIECTRL_RD_DATA_V),    // Templated
      .PERF_RD_DATA                     (PCIEPERF_RD_DATA[63:0]), // Templated
      .PERF_RD_DATA_V                   (PCIEPERF_RD_DATA_V));    // Templated



/* dplbuf_addr_decoder AUTO_TEMPLATE(
                                       .clk             (iCLK_PCIE_GLOBAL),
                                       .rst_n           (iRST_N),
                                       .\([a-z]\)MM_\(.*\)    (DPLBUF_\2[]),
                                       .LINK1@_\(.*\)         (pcie_regs_@"(downcase (substring vl-name 7))"[1\1]), 
                                       .LINK@_\(.*\)          (pcie_regs_@"(downcase (substring vl-name 6))"[\1]), 

 );
*/   
dplbuf_addr_decoder u_dplbuf_addr_dec(/*AUTOINST*/
                                      // Outputs
                                      .oMM_RD_DATA      (DPLBUF_RD_DATA[63:0]), // Templated
                                      .oMM_RD_DATA_V    (DPLBUF_RD_DATA_V), // Templated
                                      .LINK0_ADDR       (oDPLBUF_ADDR[0]), // Templated
                                      .LINK0_WR_DATA    (oDPLBUF_WR_DATA[0]), // Templated
                                      .LINK0_WR_EN      (oDPLBUF_WR_EN[0]), // Templated
                                      .LINK0_RD_EN      (oDPLBUF_RD_EN[0]), // Templated
                                      .LINK1_ADDR       (oDPLBUF_ADDR[1]), // Templated
                                      .LINK1_WR_DATA    (oDPLBUF_WR_DATA[1]), // Templated
                                      .LINK1_WR_EN      (oDPLBUF_WR_EN[1]), // Templated
                                      .LINK1_RD_EN      (oDPLBUF_RD_EN[1]), // Templated
                                      .LINK2_ADDR       (oDPLBUF_ADDR[2]), // Templated
                                      .LINK2_WR_DATA    (oDPLBUF_WR_DATA[2]), // Templated
                                      .LINK2_WR_EN      (oDPLBUF_WR_EN[2]), // Templated
                                      .LINK2_RD_EN      (oDPLBUF_RD_EN[2]), // Templated
                                      .LINK3_ADDR       (oDPLBUF_ADDR[3]), // Templated
                                      .LINK3_WR_DATA    (oDPLBUF_WR_DATA[3]), // Templated
                                      .LINK3_WR_EN      (oDPLBUF_WR_EN[3]), // Templated
                                      .LINK3_RD_EN      (oDPLBUF_RD_EN[3]), // Templated
                                      .LINK4_ADDR       (oDPLBUF_ADDR[4]), // Templated
                                      .LINK4_WR_DATA    (oDPLBUF_WR_DATA[4]), // Templated
                                      .LINK4_WR_EN      (oDPLBUF_WR_EN[4]), // Templated
                                      .LINK4_RD_EN      (oDPLBUF_RD_EN[4]), // Templated
                                      .LINK5_ADDR       (oDPLBUF_ADDR[5]), // Templated
                                      .LINK5_WR_DATA    (oDPLBUF_WR_DATA[5]), // Templated
                                      .LINK5_WR_EN      (oDPLBUF_WR_EN[5]), // Templated
                                      .LINK5_RD_EN      (oDPLBUF_RD_EN[5]), // Templated
                                      .LINK6_ADDR       (oDPLBUF_ADDR[6]), // Templated
                                      .LINK6_WR_DATA    (oDPLBUF_WR_DATA[6]), // Templated
                                      .LINK6_WR_EN      (oDPLBUF_WR_EN[6]), // Templated
                                      .LINK6_RD_EN      (oDPLBUF_RD_EN[6]), // Templated
                                      .LINK7_ADDR       (oDPLBUF_ADDR[7]), // Templated
                                      .LINK7_WR_DATA    (oDPLBUF_WR_DATA[7]), // Templated
                                      .LINK7_WR_EN      (oDPLBUF_WR_EN[7]), // Templated
                                      .LINK7_RD_EN      (oDPLBUF_RD_EN[7]), // Templated
                                      .LINK8_ADDR       (oDPLBUF_ADDR[8]), // Templated
                                      .LINK8_WR_DATA    (oDPLBUF_WR_DATA[8]), // Templated
                                      .LINK8_WR_EN      (oDPLBUF_WR_EN[8]), // Templated
                                      .LINK8_RD_EN      (oDPLBUF_RD_EN[8]), // Templated
                                      .LINK9_ADDR       (oDPLBUF_ADDR[9]), // Templated
                                      .LINK9_WR_DATA    (oDPLBUF_WR_DATA[9]), // Templated
                                      .LINK9_WR_EN      (oDPLBUF_WR_EN[9]), // Templated
                                      .LINK9_RD_EN      (oDPLBUF_RD_EN[9]), // Templated
                                      .LINK10_ADDR      (oDPLBUF_ADDR[10]), // Templated
                                      .LINK10_WR_DATA   (oDPLBUF_WR_DATA[10]), // Templated
                                      .LINK10_WR_EN     (oDPLBUF_WR_EN[10]), // Templated
                                      .LINK10_RD_EN     (oDPLBUF_RD_EN[10]), // Templated
                                      .LINK11_ADDR      (oDPLBUF_ADDR[11]), // Templated
                                      .LINK11_WR_DATA   (oDPLBUF_WR_DATA[11]), // Templated
                                      .LINK11_WR_EN     (oDPLBUF_WR_EN[11]), // Templated
                                      .LINK11_RD_EN     (oDPLBUF_RD_EN[11]), // Templated
                                      // Inputs
                                      .clk              (iCLK_PCIE_GLOBAL), // Templated
                                      .rst_n            (iRST_N),      // Templated
                                      .iMM_ADDR         (DPLBUF_ADDR[13:0]), // Templated
                                      .iMM_WR_EN        (DPLBUF_WR_EN),  // Templated
                                      .iMM_RD_EN        (DPLBUF_RD_EN),  // Templated
                                      .iMM_WR_DATA      (DPLBUF_WR_DATA[63:0]), // Templated
                                      .LINK0_RD_DATA    (iDPLBUF_RD_DATA[0]), // Templated
                                      .LINK0_RD_DATA_V  (iDPLBUF_RD_DATA_V[0]), // Templated
                                      .LINK1_RD_DATA    (iDPLBUF_RD_DATA[1]), // Templated
                                      .LINK1_RD_DATA_V  (iDPLBUF_RD_DATA_V[1]), // Templated
                                      .LINK2_RD_DATA    (iDPLBUF_RD_DATA[2]), // Templated
                                      .LINK2_RD_DATA_V  (iDPLBUF_RD_DATA_V[2]), // Templated
                                      .LINK3_RD_DATA    (iDPLBUF_RD_DATA[3]), // Templated
                                      .LINK3_RD_DATA_V  (iDPLBUF_RD_DATA_V[3]), // Templated
                                      .LINK4_RD_DATA    (iDPLBUF_RD_DATA[4]), // Templated
                                      .LINK4_RD_DATA_V  (iDPLBUF_RD_DATA_V[4]), // Templated
                                      .LINK5_RD_DATA    (iDPLBUF_RD_DATA[5]), // Templated
                                      .LINK5_RD_DATA_V  (iDPLBUF_RD_DATA_V[5]), // Templated
                                      .LINK6_RD_DATA    (iDPLBUF_RD_DATA[6]), // Templated
                                      .LINK6_RD_DATA_V  (iDPLBUF_RD_DATA_V[6]), // Templated
                                      .LINK7_RD_DATA    (iDPLBUF_RD_DATA[7]), // Templated
                                      .LINK7_RD_DATA_V  (iDPLBUF_RD_DATA_V[7]), // Templated
                                      .LINK8_RD_DATA    (iDPLBUF_RD_DATA[8]), // Templated
                                      .LINK8_RD_DATA_V  (iDPLBUF_RD_DATA_V[8]), // Templated
                                      .LINK9_RD_DATA    (iDPLBUF_RD_DATA[9]), // Templated
                                      .LINK9_RD_DATA_V  (iDPLBUF_RD_DATA_V[9]), // Templated
                                      .LINK10_RD_DATA   (iDPLBUF_RD_DATA[10]), // Templated
                                      .LINK10_RD_DATA_V (iDPLBUF_RD_DATA_V[10]), // Templated
                                      .LINK11_RD_DATA   (iDPLBUF_RD_DATA[11]), // Templated
                                      .LINK11_RD_DATA_V (iDPLBUF_RD_DATA_V[11])); // Templated




pcie_perf_regs pcie_perf_regs_inst
(
.clk                                 (iCLK_PCIE_GLOBAL),
.rst_n                               (iRST_N),
.wr_en                               (PCIEPERF_WR_EN),
.rd_en                               (PCIEPERF_RD_EN),
.addr                                (PCIEPERF_ADDR[9:0]),
.wr_data                             (PCIEPERF_WR_DATA[63:0]),
.rd_data                             (PCIEPERF_RD_DATA[63:0]),
.rd_data_v                           (PCIEPERF_RD_DATA_V),
.oREG__SCRATCH                       (),
.oREG_CTRL                           (oPERF_LATCH),

.iREG_TICKS_SINCE_LAST_LATCH_EN      (1'b1),
.iREG_TICKS_SINCE_LAST_LATCH_LATCH   (oPERF_LATCH),

.iREG_TX_ST_SOP_CTR_EN               (iPERF_SOP_CTR),
.iREG_TX_ST_SOP_CTR_LATCH            (oPERF_LATCH),

.iREG_TX_ST_READY_N_CTR_EN           (iPERF_RDY_N),
.iREG_TX_ST_READY_N_CTR_LATCH        (oPERF_LATCH),

.iREG_LINK0_REQ_TICKS_EN             (iPERF_LINK_REQ[0]),
.iREG_LINK0_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK1_REQ_TICKS_EN             (iPERF_LINK_REQ[1]),
.iREG_LINK1_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK2_REQ_TICKS_EN             (iPERF_LINK_REQ[2]),
.iREG_LINK2_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK3_REQ_TICKS_EN             (iPERF_LINK_REQ[3]),
.iREG_LINK3_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK4_REQ_TICKS_EN             (iPERF_LINK_REQ[4]),
.iREG_LINK4_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK5_REQ_TICKS_EN             (iPERF_LINK_REQ[5]),
.iREG_LINK5_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK6_REQ_TICKS_EN             (iPERF_LINK_REQ[6]),
.iREG_LINK6_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK7_REQ_TICKS_EN             (iPERF_LINK_REQ[7]),
.iREG_LINK7_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK8_REQ_TICKS_EN             (iPERF_LINK_REQ[8]),
.iREG_LINK8_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK9_REQ_TICKS_EN             (iPERF_LINK_REQ[9]),
.iREG_LINK9_REQ_TICKS_LATCH          (oPERF_LATCH),
.iREG_LINK10_REQ_TICKS_EN            (iPERF_LINK_REQ[10]),
.iREG_LINK10_REQ_TICKS_LATCH         (oPERF_LATCH),
.iREG_LINK11_REQ_TICKS_EN            (iPERF_LINK_REQ[11]),
.iREG_LINK11_REQ_TICKS_LATCH         (oPERF_LATCH),

.oREG_LINK0_REQ_TICKS_USR            (oPERF_REQ[0]),
.oREG_LINK1_REQ_TICKS_USR            (oPERF_REQ[1]),
.oREG_LINK2_REQ_TICKS_USR            (oPERF_REQ[2]),
.oREG_LINK3_REQ_TICKS_USR            (oPERF_REQ[3]),
.oREG_LINK4_REQ_TICKS_USR            (oPERF_REQ[4]),
.oREG_LINK5_REQ_TICKS_USR            (oPERF_REQ[5]),
.oREG_LINK6_REQ_TICKS_USR            (oPERF_REQ[6]),
.oREG_LINK7_REQ_TICKS_USR            (oPERF_REQ[7]),
.oREG_LINK8_REQ_TICKS_USR            (oPERF_REQ[8]),
.oREG_LINK9_REQ_TICKS_USR            (oPERF_REQ[9]),
.oREG_LINK10_REQ_TICKS_USR           (oPERF_REQ[10]),
.oREG_LINK11_REQ_TICKS_USR           (oPERF_REQ[11]),
 
.iREG_LINK0_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[0]),
.iREG_LINK1_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[1]),
.iREG_LINK2_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[2]),
.iREG_LINK3_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[3]),
.iREG_LINK4_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[4]),
.iREG_LINK5_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[5]),
.iREG_LINK6_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[6]),
.iREG_LINK7_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[7]),
.iREG_LINK8_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[8]),
.iREG_LINK9_REQ_TICKS_MAX            (iPERF_REQTIC_MAX[9]),
.iREG_LINK10_REQ_TICKS_MAX           (iPERF_REQTIC_MAX[10]),
.iREG_LINK11_REQ_TICKS_MAX           (iPERF_REQTIC_MAX[11]),

.iREG_LINK0_VALID_TICKS_EN           (iDPLBUF_DATA_V[0]),
.iREG_LINK0_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK1_VALID_TICKS_EN           (iDPLBUF_DATA_V[1]),
.iREG_LINK1_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK2_VALID_TICKS_EN           (iDPLBUF_DATA_V[2]),
.iREG_LINK2_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK3_VALID_TICKS_EN           (iDPLBUF_DATA_V[3]),
.iREG_LINK3_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK4_VALID_TICKS_EN           (iDPLBUF_DATA_V[4]),
.iREG_LINK4_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK5_VALID_TICKS_EN           (iDPLBUF_DATA_V[5]),
.iREG_LINK5_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK6_VALID_TICKS_EN           (iDPLBUF_DATA_V[6]),
.iREG_LINK6_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK7_VALID_TICKS_EN           (iDPLBUF_DATA_V[7]),
.iREG_LINK7_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK8_VALID_TICKS_EN           (iDPLBUF_DATA_V[8]),
.iREG_LINK8_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK9_VALID_TICKS_EN           (iDPLBUF_DATA_V[9]),
.iREG_LINK9_VALID_TICKS_LATCH        (oPERF_LATCH),
.iREG_LINK10_VALID_TICKS_EN          (iDPLBUF_DATA_V[10]),
.iREG_LINK10_VALID_TICKS_LATCH       (oPERF_LATCH),
.iREG_LINK11_VALID_TICKS_EN          (iDPLBUF_DATA_V[11]),
.iREG_LINK11_VALID_TICKS_LATCH       (oPERF_LATCH),

.iREG_LINK0_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[0]),
.iREG_LINK0_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK1_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[1]),
.iREG_LINK1_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK2_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[2]),
.iREG_LINK2_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK3_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[3]),
.iREG_LINK3_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK4_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[4]),
.iREG_LINK4_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK5_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[5]),
.iREG_LINK5_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK6_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[6]),
.iREG_LINK6_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK7_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[7]),
.iREG_LINK7_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK8_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[8]),
.iREG_LINK8_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK9_COMPLETE_TICKS_EN        (iPERF_LINK_DONE[9]),
.iREG_LINK9_COMPLETE_TICKS_LATCH     (oPERF_LATCH),
.iREG_LINK10_COMPLETE_TICKS_EN       (iPERF_LINK_DONE[10]),
.iREG_LINK10_COMPLETE_TICKS_LATCH    (oPERF_LATCH),
.iREG_LINK11_COMPLETE_TICKS_EN       (iPERF_LINK_DONE[11]),
.iREG_LINK11_COMPLETE_TICKS_LATCH    (oPERF_LATCH),

.iREG_TX_ST_32BYTE_CTR_EN            (iPERF_BYTE_CTR[2]),
.iREG_TX_ST_32BYTE_CTR_LATCH         (oPERF_LATCH),
.iREG_TX_ST_24BYTE_CTR_EN            (iPERF_BYTE_CTR[1]),
.iREG_TX_ST_24BYTE_CTR_LATCH         (oPERF_LATCH),
.iREG_TX_ST_16BYTE_CTR_EN            (iPERF_BYTE_CTR[0]),
.iREG_TX_ST_16BYTE_CTR_LATCH         (oPERF_LATCH),

.iREG_TX_POST_HDR_ZERO_CRED_CTR_EN(tx_cred_hdrfcp_inc),
.iREG_TX_POST_HDR_ZERO_CRED_CTR_LATCH(oPERF_LATCH),
.iREG_TX_POST_DAT_ZERO_CRED_CTR_EN(tx_cred_datafcp_inc),
.iREG_TX_POST_DAT_ZERO_CRED_CTR_LATCH(oPERF_LATCH),
.iREG_TX_NON_POST_HDR_ZERO_CRED_CTR_EN(tx_cred_hdrfcnp_inc),
.iREG_TX_NON_POST_HDR_ZERO_CRED_CTR_LATCH(oPERF_LATCH),
.iREG_TX_NON_POST_DAT_ZERO_CRED_CTR_EN(tx_cred_datafcnp_inc),
.iREG_TX_NON_POST_DAT_ZERO_CRED_CTR_LATCH(oPERF_LATCH)

 );

endmodule
