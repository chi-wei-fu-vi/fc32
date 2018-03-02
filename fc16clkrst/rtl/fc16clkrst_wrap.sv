/********************************CONFIDENTIAL**************************** * Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-09-06 06:53:33 -0700 (Thu, 06 Sep 2012) $
* $Revision: 159 $
* Description:
*
* FPGA global clock synthesis and synchronous reset management for 12 link FC8
* platform
*
* Upper level dependencies:  top-level
* Lower level dependencies:  vi_rst_sync_async, clk_cnt_sampler
*
* Revision History Notes:
* 2013/02/15 Tim - initial release
* 2013/02/20 Tim - added support for iCLK_SERDES_RXREC & iCLK_SERDES_TXCLK
* 2013/02/25 Tim - oRST_LINK_FC_CORE_N and oRST_FC_CORE212_N held in reset until PLL locks (FCPllFcCoreLocked)
* 2013/02/25 Tim - Added clksyn - to synthesize oCLK_CORE_219 clock (156.25 MHz).
*
*
***************************************************************************/

`timescale 1 ns / 100 ps

module fc16clkrst_wrap
#(
  parameter pCNT_CMP_THRESH = 1973790
)
(
  //////////////////////////////////////////////////////////////////////
  // MM Register I/F
  //////////////////////////////////////////////////////////////////////
  input  [63:0]       iMM_WR_DATA,
  input  [9:0]        iMM_ADDRESS,
  input               iMM_WR_EN,
  input               iMM_RD_EN,
  output [63:0]       oMM_RD_DATA,
  output              oMM_RD_DATA_V,

  //////////////////////////////////////////////////////////////////////
  // Off-chip Reset Inputs
  //////////////////////////////////////////////////////////////////////
  input               iUC2FPGA_RST_PAD_N,        // drives reset of PCIe HIP and subsequently entire pcie domain
  input               iUC2FPGA_CLR_PAD_N,        // connected to DEVCLRn net. Quartus build determines pin fn: DEVCLRn or input.

  //////////////////////////////////////////////////////////////////////
  // Synchronous Reset Outputs
  //////////////////////////////////////////////////////////////////////
  output              oRST_PCIE_HIP_N,           // this should connect to bali_pcie_gen2x8_wrap which provides sync reset to rest of clk domain.
  output              oRST_PCIE_REF_N,           // this should connect to gbl_timer.
  output              oRST_PCIE_APP_N,           // app layer reset in chipRst network synced to oCLK_PCIE_GLOBAL
  output [11:0]       oRST_LINK_PCIE_N,          // resets the DPLBUF pointer registers
  output [12:0]       oRST_LINK_FC_CORE_N,       // 212 digital domain per link reset
  output [12:0]       oRST_LINK_FC_SER_N,       // 212 digital domain per link reset
  output [25:0]       oRST_LINK_SERDES_RXREC_N,  // rx recovered clock domain [0]=link[0]chan[0], [1]=link[0]chann[1],[2]=link[1]chan[0],...
  output [25:0]       oRST_LINK_SERDES_TX219_N,     // tx clock domain           [0]=link[0]chan[0], [1]=link[0]chann[1],[2]=link[1]chan[0],...
  output [25:0]       oRST_LINK_SERDES_TX212_N,     // tx clock domain           [0]=link[0]chan[0], [1]=link[0]chann[1],[2]=link[1]chan[0],...
  output              oRST_FR_100M_N,            // reset chipregs/gbl_timer
  output              oRST_FC_CORE212_N,            // reset txbist32b & gbl_timer
  output              oRST_FC_SER219_N,            // reset txbist32b & gbl_timer
  output              oRST_FC_SER212_N,            // reset txbist32b & gbl_timer
  output              oRST_TXBIST_N,             // async reset for txbist clock
  output              oRST_XBAR_N,               // async reset for xbar clock

	output              oRST_GLB_TIMESTAMP_FR,
	output              oRST_GLB_TIMESTAMP_FC,
	output              oRST_GLB_TIMESTAMP_PCIE,

	inout               ioSYNC_RIBBON,
	inout               ioSYNC_NEIGHBOR,

  //////////////////////////////////////////////////////////////////////
  // Clock Inputs
  //////////////////////////////////////////////////////////////////////
  input               iCLK_FR_100M_PAD,          // 100MHz -> Free-running from programmable oscillator
  input               iCLK_PCIE_REF_PAD,         // 100MHz -> PCIe reference clock
  input [1:0]         iCLK_425M_PAD,             // to synthesize FC_CORE_CLK
  input               iCLK_PCIE_CORECLKOUT_HIP,  // PCIe HIP outputs this clock. Gen2=125M,Gen3=250M

  input [25:0]        iCLK_SERDES_RXREC,
  input [25:0]        iCLK_SERDES_TXCLK,
    
  //////////////////////////////////////////////////////////////////////
  // From SERDES
  ////////////////////////////////////////////////////////////////////// 
  input [25:0]         iATX_PLL_LOCKED,          // per channel PLL locked from ATX PLLs
  input [25:0]         iRX_READY,                // per channel rx_ready

  //////////////////////////////////////////////////////////////////////
  // Global Clock Outputs
  ////////////////////////////////////////////////////////////////////// 
	input               iCLK_FC_219REF,
  output              oCLK_100M_GLOBAL,          // 100MHz
  output              oCLK_PCIE_GLOBAL,          // Gen2=125M,Gen=250M                      
  output              oCLK_PCIE_REF_GLOBAL,      // 100MHz
  output              oCLK_CORE_212,       // 212.5  (425 source)
  output              oCLK_SER_212,       // 212.5  (425 source)
  output              oCLK_BIST,       // double speed clk mux synthesized from pad
  output              oCLK_SER_PMA         // triple speed 
  
);


logic               oSYNC_RIBBON;
logic               oSYNC_NEIGHBOR;
logic        PllFcCoreRst, PllXbarRst;
logic        PllFcCoreLocked, PllXbarLocked;
logic [1:0]  TxBistLinkSpeed;
//logic        TxBistPllLock;

logic [11:0] LinkPcieRstReg;
logic [11:0] LinkPcieRst_n;
logic [11:0] LinkFcCoreRstReg;
logic [12:0] LinkFcCoreRst_n;
logic [12:0] LinkSerdesRxRstReg;
logic [12:0] LinkSerdesRxRst_n;
logic [12:0] LinkSerdesTxRstReg;
logic [12:0] LinkSerdesTxRst_n;

logic [12:0] LinkRstReg;
logic        ChipRstReg;
logic        ChipRst_n;
logic        clk_cnt_fccore_rst, clk_cnt_pcie_rst, clk_cnt_txbist_rst, clk_cnt_xbar_rst;

logic        ClkCtrLatch;
logic [23:0] ClkCtrPcie;
logic [23:0] ClkCtrFcCore;
logic [23:0] ClkCtrTxBist;
logic [23:0] ClkCtrXbar;
logic [23:0] clk_cnt_rxreclk_rst, clk_cnt_txclk_rst;

logic [23:0][23:0] ClkCtrRxRec;
logic [23:0][23:0] ClkCtrTx;

logic [25:0] rx_ready_sticky;

logic glb_timestamp_rst;
logic glb_timestamp_rst_reg;
logic ribbon_rst_n;
logic neighbor_rst_n;

logic ribbon_ena;
logic neighbor_ena;


///////////////////////////////////////////////////////////////////////////////
//
// PLL
//
///////////////////////////////////////////////////////////////////////////////

wire clk_core_212;

s5_altpll_219in_212out
core_clock_pll_inst
(
  .refclk(iCLK_425M_PAD[0]),   //  refclk.clk
  .rst(PllFcCoreRst),      //   reset.reset
  .outclk_0(clk_core_212), // outclk0.clk
  .outclk_1(), // outclk1.clk
  .locked(PllFcCoreLocked)    //  locked.export
  );

assign PllXbarLocked = PllFcCoreLocked;

/* TX BIST engine clock select :
  16G    : 212.50MHz 219 source (select = 2'b10)
  8G     : 212.50MHz 425 source (select = 2'b11)
  4G     : 106.25MHz 425 source (select = 2'b11)
*/
/*
wire clk_16g;

s5_altpll_219in_212out
bist_clock_pll_inst
(
  .refclk(iCLK_SERDES_TXCLK[0]),   //  refclk.clk
  .rst(PllXbarRst),      //   reset.reset
  .outclk_0(clk_16g), // outclk0.clk
  .outclk_1(), // outclk1.clk
  .locked(PllXbarLocked)    //  locked.export
  );

s5_altclkmux_auto_altclkctrl_nrg
bist_clk_mux_inst
  (
  .clkselect({1'b1, |TxBistLinkSpeed}),
  .ena(1'b1),
  .inclk({iCLK_SERDES_TXCLK[0], clk_16g, iCLK_425M_PAD[0], iCLK_425M_PAD[0]}),
  .outclk(oCLK_BIST)
);
*/


assign oCLK_BIST = iCLK_SERDES_TXCLK[0];


///////////////////////////////////////////////////////////////////////////////
//
// Global Clock Buffers (Auto mode - let fitter decide if global or regional)
//
///////////////////////////////////////////////////////////////////////////////

assign oCLK_SER_PMA = iCLK_SERDES_TXCLK[0];

//lz 
//Core does not have 219 domain.  219MHz digital logic are localized to per
//channel TX logic.  This logic should be constrained to the same source as
//the TX 212MHz domain.  Therefore, the 219 source clock is just the
//tx_pma_clkout from channel 25 (which only runs at 14Gbps).  212Mhz is
//synthesized from this source.
//RX side is in the recovery domain, and has add/drop mechanism to cross into
//the core 212MHz (425 sourced) domain.  These 2 domains always have ppm
//difference.

/*
BUFG altclkctrl_ser_212_inst
(
	.I   (clk_core_212),
	.O  (oCLK_CORE_212)
);
*/
assign oCLK_CORE_212 = clk_core_212;
assign oCLK_SER_212 = oCLK_CORE_212;

BUFG altclkctrl_100m_inst
(
	.I   (iCLK_FR_100M_PAD),
	.O  (oCLK_100M_GLOBAL)
);
//assign oCLK_100M_GLOBAL = iCLK_FR_100M_PAD;
BUFG altclkctrl_pcie_inst
(
	.I   (iCLK_PCIE_CORECLKOUT_HIP),
	.O  (oCLK_PCIE_GLOBAL)
);
//assign oCLK_PCIE_GLOBAL = iCLK_PCIE_CORECLKOUT_HIP;

BUFG altclkctrl_pcie_ref_inst
(
	.I   (iCLK_PCIE_REF_PAD),
	.O  (oCLK_PCIE_REF_GLOBAL)
);
//assign oCLK_PCIE_REF_GLOBAL = iCLK_PCIE_REF_PAD;

///////////////////////////////////////////////////////////////////////////////
//
// Reset Synchronizers
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// uC invoked reset to PCIe HIP
///////////////////////////////////////////////////////////////////////////////
vi_rst_sync_async rst_sync_pcie_hip_inst
(  
  .iRST_ASYNC_N (iUC2FPGA_CLR_PAD_N),
  .iCLK         (oCLK_PCIE_GLOBAL), 
  .oRST_SYNC_N  (oRST_PCIE_HIP_N)
);


///////////////////////////////////////////////////////////////////////////////
// CHIP Reset
///////////////////////////////////////////////////////////////////////////////
assign ChipRst_n          =   iUC2FPGA_RST_PAD_N  & (~ChipRstReg); 

///////////////////////////////////////////////////////////////////////////////
// Link Based Resets
///////////////////////////////////////////////////////////////////////////////
assign LinkPcieRst_n      = (~LinkPcieRstReg)     & (~LinkRstReg[11:0]) & {12{ChipRst_n}};
assign LinkFcCoreRst_n    = ({1'b1, ~LinkFcCoreRstReg})   & (~LinkRstReg[12:0]) & {13{ChipRst_n}} & {13{PllFcCoreLocked}} & {13{PllXbarLocked}};
assign LinkSerdesTxRst_n  = (~LinkSerdesTxRstReg) & (~LinkRstReg[12:0]) & {13{ChipRst_n}};
assign LinkSerdesRxRst_n  = (~LinkSerdesRxRstReg) & (~LinkRstReg[12:0]) & {13{ChipRst_n}};

genvar j;
generate
for (j=0; j<13; j=j+1) begin : lnk_rst_gen
  vi_rst_sync_async rst_sync_fc_core_inst
  (  
    .iRST_ASYNC_N (LinkFcCoreRst_n[j]),
    .iCLK         (oCLK_CORE_212), 
    .oRST_SYNC_N  (oRST_LINK_FC_CORE_N[j])
  );
  
  vi_rst_sync_async rst_sync_fc_ser_inst
  (  
    .iRST_ASYNC_N (LinkFcCoreRst_n[j]),
    .iCLK         (oCLK_CORE_212), 
    .oRST_SYNC_N  (oRST_LINK_FC_SER_N[j])
  );
  
end : lnk_rst_gen 

for (j=0; j<12; j=j+1)
begin : rst_gen
  vi_rst_sync_async rst_sync_pcie_inst
  (  
    .iRST_ASYNC_N (LinkPcieRst_n[j]),
    .iCLK         (oCLK_PCIE_GLOBAL), 
    .oRST_SYNC_N  (oRST_LINK_PCIE_N[j])
  );
  
  //tx - even channel
  vi_rst_sync_async rst_sync_tx_inst
  (  
    .iRST_ASYNC_N (LinkSerdesTxRst_n[j] & iATX_PLL_LOCKED[j*2]),
    .iCLK         (oCLK_SER_PMA), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_TX219_N[j*2])
  );
  
  vi_rst_sync_async rst_sync_tx212_inst
  (  
    .iRST_ASYNC_N (LinkSerdesTxRst_n[j] & iATX_PLL_LOCKED[j*2]),
    .iCLK         (oCLK_CORE_212), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_TX212_N[j*2])
  );
  
  //tx - odd channel
  vi_rst_sync_async rst_sync_tx_odd_inst
  (  
    .iRST_ASYNC_N (LinkSerdesTxRst_n[j] & iATX_PLL_LOCKED[j*2+1]),
    .iCLK         (oCLK_SER_PMA), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_TX219_N[j*2+1])
  );
  
  vi_rst_sync_async rst_sync_tx212_odd_inst
  (  
    .iRST_ASYNC_N (LinkSerdesTxRst_n[j] & iATX_PLL_LOCKED[j*2+1]),
    .iCLK         (oCLK_CORE_212), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_TX212_N[j*2+1])
  );
  
  //rx - even channel
  vi_rst_sync_async rst_sync_rxrec_inst
  (  
    .iRST_ASYNC_N (LinkSerdesRxRst_n[j]),
    .iCLK         (oCLK_SER_PMA), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_RXREC_N[j*2])
  );
  
  //rx - odd channel
  vi_rst_sync_async rst_sync_rxrec_odd_inst
  (  
    .iRST_ASYNC_N (LinkSerdesRxRst_n[j]),
    .iCLK         (oCLK_SER_PMA), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_RXREC_N[j*2+1])
  );

end 
endgenerate


/* LZ :
 * DO NOT asynchronously reset the following flops.
 * ChipRst_n is self clearing reg bit reset by oRST_FR_100M_N.
 * The goal here is to delay the resetting of ChipRst_n until AFTER it self
 * clears.
 * If there is an asynchonous clear on the following flops, then the ChipRst_n
 * reg will clear asynchronously after set, which defeats the purpose of
 * delaying reset.
 * Synchronous reset will not break things, but shortens the latency to
 * 1 clock.  
 */
logic chprst_nr, chprst_nrr;
always @ (posedge oCLK_100M_GLOBAL)
begin
  chprst_nr <= ChipRst_n;
  chprst_nrr <= chprst_nr;
end

vi_rst_sync_async rst_sync_100_inst
(  
  .iRST_ASYNC_N (chprst_nrr),
  .iCLK         (oCLK_100M_GLOBAL), 
  .oRST_SYNC_N  (oRST_FR_100M_N)
);

vi_rst_sync_async rst_sync_ref_inst
(  
  .iRST_ASYNC_N (ChipRst_n),
  .iCLK         (oCLK_PCIE_REF_GLOBAL), 
  .oRST_SYNC_N  (oRST_PCIE_REF_N)
);

vi_rst_sync_async rst_sync_app_inst
(  
  .iRST_ASYNC_N (ChipRst_n),
  .iCLK         (oCLK_PCIE_GLOBAL), 
  .oRST_SYNC_N  (oRST_PCIE_APP_N)
);

vi_rst_sync_async rst_sync_fc_core212_inst
(  
  .iRST_ASYNC_N (ChipRst_n & PllFcCoreLocked),
  .iCLK         (oCLK_CORE_212), 
  .oRST_SYNC_N  (oRST_FC_CORE212_N)
);

vi_rst_sync_async rst_sync_fc_ser219_inst
(  
  .iRST_ASYNC_N (ChipRst_n & PllFcCoreLocked),
  .iCLK         (oCLK_SER_PMA), 
  .oRST_SYNC_N  (oRST_FC_SER219_N)
);

vi_rst_sync_async rst_sync_fc_ser212_inst
(  
  .iRST_ASYNC_N (ChipRst_n & PllFcCoreLocked),
  .iCLK         (oCLK_CORE_212), 
  .oRST_SYNC_N  (oRST_FC_SER212_N)
);


vi_rst_sync_async rst_sync_txbist_inst
(  
  .iRST_ASYNC_N (ChipRst_n & PllXbarLocked),
  .iCLK         (oCLK_CORE_212), 
  .oRST_SYNC_N  (oRST_TXBIST_N)
);

vi_rst_sync_async rst_sync_xbar_inst
(  
  .iRST_ASYNC_N (ChipRst_n & PllXbarLocked),
  .iCLK         (oCLK_CORE_212), 
  .oRST_SYNC_N  (oRST_XBAR_N)
);



///////////////////////////////////////////////////////////////////////////////
//
// CrossLink Resets
//
///////////////////////////////////////////////////////////////////////////////
 //tx - even channel
  vi_rst_sync_async rst_sync_tx_cross_inst
  (  
    .iRST_ASYNC_N (LinkSerdesTxRst_n[12]),
    .iCLK         (oCLK_SER_PMA), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_TX219_N[24])
  );

  vi_rst_sync_async rst_sync_tx212_cross_inst
  (  
    .iRST_ASYNC_N (LinkSerdesTxRst_n[12]),
    .iCLK         (oCLK_CORE_212), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_TX212_N[24])
  );
  
  
  //tx - odd channel
  vi_rst_sync_async rst_sync_tx_odd_cross_inst
  (  
    .iRST_ASYNC_N (LinkSerdesTxRst_n[12]),
    .iCLK         (oCLK_SER_PMA), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_TX219_N[25])
  );
  
  vi_rst_sync_async rst_sync_tx212_odd_cross_inst
  (  
    .iRST_ASYNC_N (LinkSerdesTxRst_n[12]),
    .iCLK         (oCLK_CORE_212), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_TX212_N[25])
  );
  
  //rx - even channel
  vi_rst_sync_async rst_sync_rxrec_cross_inst
  (  
    .iRST_ASYNC_N (LinkSerdesRxRst_n[12]),
    .iCLK         (oCLK_SER_PMA), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_RXREC_N[24])
  );
  
  //rx - odd channel
  vi_rst_sync_async rst_sync_rxrec_odd_cross_inst
  (  
    .iRST_ASYNC_N (LinkSerdesRxRst_n[12]),
    .iCLK         (oCLK_SER_PMA), 
    .oRST_SYNC_N  (oRST_LINK_SERDES_RXREC_N[25])
  );

///////////////////////////////////////////////////////////////////////////////
//
// Clock Frequency Counters
//
///////////////////////////////////////////////////////////////////////////////
   
assign clk_cnt_fccore_rst = (ClkCtrLatch | ~oRST_FC_CORE212_N);
assign clk_cnt_pcie_rst   = (ClkCtrLatch | ~oRST_PCIE_HIP_N);
assign clk_cnt_txbist_rst = (ClkCtrLatch | ~oRST_TXBIST_N);
assign clk_cnt_xbar_rst   = (ClkCtrLatch | ~oRST_XBAR_N);
   
clk_cnt_sampler 
#(
  .CNT_CMP_THRESH (pCNT_CMP_THRESH)
)
clk_cnt_fccore_inst
(
  .iRST_50M     (~oRST_FR_100M_N),
  .iRST_SAMPLE  (clk_cnt_fccore_rst),
  .iCLK_50M     (oCLK_100M_GLOBAL),
  .iCLK_SAMPLE  (oCLK_CORE_212),
  .oCLK_CNT     (ClkCtrFcCore)
);

clk_cnt_sampler 
#(
  .CNT_CMP_THRESH (pCNT_CMP_THRESH)
)
clk_cnt_pcie_inst
(
  .iRST_50M     (~oRST_FR_100M_N),
  .iRST_SAMPLE  (clk_cnt_pcie_rst),
  .iCLK_50M     (oCLK_100M_GLOBAL),
  .iCLK_SAMPLE  (oCLK_PCIE_GLOBAL),
  .oCLK_CNT     (ClkCtrPcie)
);

clk_cnt_sampler 
#(
  .CNT_CMP_THRESH (pCNT_CMP_THRESH)
)
clk_cnt_txbist_inst
(
  .iRST_50M     (~oRST_FR_100M_N),
  .iRST_SAMPLE  (clk_cnt_txbist_rst),
  .iCLK_50M     (oCLK_100M_GLOBAL),
  .iCLK_SAMPLE  (oCLK_BIST),
  .oCLK_CNT     (ClkCtrTxBist)
);

clk_cnt_sampler 
#(
  .CNT_CMP_THRESH (pCNT_CMP_THRESH)
)
clk_cnt_xbar_inst
(
  .iRST_50M     (~oRST_FR_100M_N),
  .iRST_SAMPLE  (clk_cnt_xbar_rst),
  .iCLK_50M     (oCLK_100M_GLOBAL),
  .iCLK_SAMPLE  (oCLK_BIST),
  .oCLK_CNT     (ClkCtrXbar)
);



///////////////////////////////////////////////////////////////////////////////
// Channel Based Clock Frequency Counters
///////////////////////////////////////////////////////////////////////////////
generate
for (j=0; j<24; j=j+1)
  begin : clk_cnt_gen

     assign clk_cnt_rxreclk_rst[j] = (ClkCtrLatch | ~oRST_LINK_SERDES_RXREC_N[j]);
     assign clk_cnt_txclk_rst[j]   = (ClkCtrLatch | ~oRST_LINK_SERDES_TX219_N[j]);

     clk_cnt_sampler 
       #(
	 .CNT_CMP_THRESH (pCNT_CMP_THRESH)
	 )
     clk_cnt_rxrecclk_inst
       (
	.iRST_50M     (~oRST_FR_100M_N),
	.iRST_SAMPLE  (clk_cnt_rxreclk_rst[j]),
	.iCLK_50M     (oCLK_100M_GLOBAL),
	.iCLK_SAMPLE  (iCLK_SERDES_RXREC[j]),
	
	.oCLK_CNT     (ClkCtrRxRec[j])
	);

     clk_cnt_sampler 
       #(
	 .CNT_CMP_THRESH (pCNT_CMP_THRESH)
	 )
     clk_cnt_txclk_inst
       (
	.iRST_50M     (~oRST_FR_100M_N),
	.iRST_SAMPLE  (clk_cnt_txclk_rst[j]),
	.iCLK_50M     (oCLK_100M_GLOBAL),
	.iCLK_SAMPLE  (iCLK_SERDES_TXCLK[j]),
	
	.oCLK_CNT     (ClkCtrTx[j])
	);
     
  end 
endgenerate


///////////////////////////////////////////////////////////////////////////////
//
// CDR locked
//
///////////////////////////////////////////////////////////////////////////////
// In the absence of a receive signal, the RX_READY signal may flap.
// The following logic gets set on the first assertion of RX_READY
// and remains set until reset.  This prevents us from continually flapping
// the per link RX reset.  

generate
   for (j=0; j<26; j=j+1)
	begin: rx_ready_gen
	   always @(posedge iCLK_SERDES_RXREC[j] or negedge oRST_LINK_SERDES_RXREC_N[j])
	     rx_ready_sticky[j] <= ~oRST_LINK_SERDES_RXREC_N[j] ? 1'b0 :
					iRX_READY[j] ? 1'b1 : rx_ready_sticky[j];
	end
endgenerate
	   
      


///////////////////////////////////////////////////////////////////////////////
//
// Registers
//
///////////////////////////////////////////////////////////////////////////////



   

fc16clkrst_regs fc16clkrst_regs_inst
(
  .clk                                (oCLK_100M_GLOBAL),
  .rst_n                              (oRST_FR_100M_N),
  .wr_en                              (iMM_WR_EN),
  .rd_en                              (iMM_RD_EN),
  .addr                               (iMM_ADDRESS),
  .wr_data                            (iMM_WR_DATA),
  .rd_data                            (oMM_RD_DATA),
  .rd_data_v                          (oMM_RD_DATA_V),
  
  .oREG__SCRATCH     (),
	.oREG_RSTCTRL_0_GLBTIMESTAMPRST     (glb_timestamp_rst_reg),
  .oREG_RSTCTRL_0_LINKRST             (LinkRstReg),
  .oREG_RSTCTRL_0_PLLFCCORERST        (PllFcCoreRst),
  .oREG_RSTCTRL_0_PLLXBARRST          (PllXbarRst),
  .oREG_RSTCTRL_0_CHIPRST             (ChipRstReg),
  .oREG_RSTCTRL_1_LINKPCIERST         (LinkPcieRstReg),
  .oREG_RSTCTRL_1_LINKFCCORERST       (LinkFcCoreRstReg),
  .oREG_RSTCTRL_1_LINKSERDESTXRST     (LinkSerdesTxRstReg),
  .oREG_RSTCTRL_1_LINKSERDESRXRST     (LinkSerdesRxRstReg),
  .iREG_RSTSTATUS_PLLFCCORELOCKED     (PllFcCoreLocked),
  .iREG_RSTSTATUS_CHIPSTATUS          (1'b0),  
  .oREG_TXBISTCTRL                    (TxBistLinkSpeed),
  .iREG_TXBISTSTATUS                  (PllXbarLocked),
  .oREG_CLKCTRCTRL                    (ClkCtrLatch),
  .iREG_CLKCTRFCCORE                  (ClkCtrFcCore),
  .iREG_CLKCTRPCIE                    (ClkCtrPcie),
  .iREG_CLKCTRTXBIST                  (ClkCtrTxBist),
  .iREG_CLKCTRXBAR                    (ClkCtrXbar),
  
  .iREG_CLKCTRSERDES0_0_TXCLK       (ClkCtrTx[0]),
  .iREG_CLKCTRSERDES0_0_RXRECCLK    (ClkCtrRxRec[0]),
  .iREG_CLKCTRSERDES0_1_TXCLK       (ClkCtrTx[1]),
  .iREG_CLKCTRSERDES0_1_RXRECCLK    (ClkCtrRxRec[1]),
  .iREG_CLKCTRSERDES1_0_TXCLK       (ClkCtrTx[2]),
  .iREG_CLKCTRSERDES1_0_RXRECCLK    (ClkCtrRxRec[2]),
  .iREG_CLKCTRSERDES1_1_TXCLK       (ClkCtrTx[3]),
  .iREG_CLKCTRSERDES1_1_RXRECCLK    (ClkCtrRxRec[3]),
  .iREG_CLKCTRSERDES2_0_TXCLK       (ClkCtrTx[4]),
  .iREG_CLKCTRSERDES2_0_RXRECCLK    (ClkCtrRxRec[4]),
  .iREG_CLKCTRSERDES2_1_TXCLK       (ClkCtrTx[5]),
  .iREG_CLKCTRSERDES2_1_RXRECCLK    (ClkCtrRxRec[5]),
  .iREG_CLKCTRSERDES3_0_TXCLK       (ClkCtrTx[6]),
  .iREG_CLKCTRSERDES3_0_RXRECCLK    (ClkCtrRxRec[6]),
  .iREG_CLKCTRSERDES3_1_TXCLK       (ClkCtrTx[7]),
  .iREG_CLKCTRSERDES3_1_RXRECCLK    (ClkCtrRxRec[7]),
  .iREG_CLKCTRSERDES4_0_TXCLK       (ClkCtrTx[8]),
  .iREG_CLKCTRSERDES4_0_RXRECCLK    (ClkCtrRxRec[8]),
  .iREG_CLKCTRSERDES4_1_TXCLK       (ClkCtrTx[9]),
  .iREG_CLKCTRSERDES4_1_RXRECCLK    (ClkCtrRxRec[9]),
  .iREG_CLKCTRSERDES5_0_TXCLK       (ClkCtrTx[10]),
  .iREG_CLKCTRSERDES5_0_RXRECCLK    (ClkCtrRxRec[10]),
  .iREG_CLKCTRSERDES5_1_TXCLK       (ClkCtrTx[11]),
  .iREG_CLKCTRSERDES5_1_RXRECCLK    (ClkCtrRxRec[11]), 
  .iREG_CLKCTRSERDES6_0_TXCLK       (ClkCtrTx[12]),
  .iREG_CLKCTRSERDES6_0_RXRECCLK    (ClkCtrRxRec[12]),
  .iREG_CLKCTRSERDES6_1_TXCLK       (ClkCtrTx[13]),
  .iREG_CLKCTRSERDES6_1_RXRECCLK    (ClkCtrRxRec[13]),
  .iREG_CLKCTRSERDES7_0_TXCLK       (ClkCtrTx[14]),
  .iREG_CLKCTRSERDES7_0_RXRECCLK    (ClkCtrRxRec[14]),
  .iREG_CLKCTRSERDES7_1_TXCLK       (ClkCtrTx[15]),
  .iREG_CLKCTRSERDES7_1_RXRECCLK    (ClkCtrRxRec[15]),
  .iREG_CLKCTRSERDES8_0_TXCLK       (ClkCtrTx[16]),
  .iREG_CLKCTRSERDES8_0_RXRECCLK    (ClkCtrRxRec[16]),
  .iREG_CLKCTRSERDES8_1_TXCLK       (ClkCtrTx[17]),
  .iREG_CLKCTRSERDES8_1_RXRECCLK    (ClkCtrRxRec[17]),
  .iREG_CLKCTRSERDES9_0_TXCLK       (ClkCtrTx[18]),
  .iREG_CLKCTRSERDES9_0_RXRECCLK    (ClkCtrRxRec[18]),
  .iREG_CLKCTRSERDES9_1_TXCLK       (ClkCtrTx[19]),
  .iREG_CLKCTRSERDES9_1_RXRECCLK    (ClkCtrRxRec[19]),
  .iREG_CLKCTRSERDES10_0_TXCLK      (ClkCtrTx[20]),
  .iREG_CLKCTRSERDES10_0_RXRECCLK   (ClkCtrRxRec[20]),
  .iREG_CLKCTRSERDES10_1_TXCLK      (ClkCtrTx[21]),
  .iREG_CLKCTRSERDES10_1_RXRECCLK   (ClkCtrRxRec[21]),
  .iREG_CLKCTRSERDES11_0_TXCLK      (ClkCtrTx[22]),
  .iREG_CLKCTRSERDES11_0_RXRECCLK   (ClkCtrRxRec[22]),
  .iREG_CLKCTRSERDES11_1_TXCLK      (ClkCtrTx[23]),
  .iREG_CLKCTRSERDES11_1_RXRECCLK   (ClkCtrRxRec[23])
 
);

///////////////////////////////////////////////////////////////////////////////
//
// Clock Synthesizer for txbist32 module
//
///////////////////////////////////////////////////////////////////////////////

vi_rst_sync_async rst_sync_ribbon
(
  .iRST_ASYNC_N(oSYNC_RIBBON),
	.iCLK(oCLK_100M_GLOBAL),
	.oRST_SYNC_N(ribbon_rst_n)
);

vi_rst_sync_async rst_sync_neighbor
(
  .iRST_ASYNC_N(oSYNC_NEIGHBOR),
	.iCLK(oCLK_100M_GLOBAL),
	.oRST_SYNC_N(neighbor_rst_n)
);

assign glb_timestamp_rst = glb_timestamp_rst_reg ? 1'b1 : !neighbor_rst_n || !ribbon_rst_n;

vi_sync_level #(.SIZE(1)) rst_sync_global_timestamp_fc_inst
(  
  .in_level (glb_timestamp_rst),
  .clk      (oCLK_CORE_212), 
	.rst_n    (oRST_FC_CORE212_N),
  .out_level(oRST_GLB_TIMESTAMP_FC)
);

vi_sync_level #(.SIZE(1)) rst_sync_global_timestamp_fr_inst
(  
  .in_level (glb_timestamp_rst),
  .clk      (oCLK_100M_GLOBAL), 
	.rst_n    (oRST_FR_100M_N),
  .out_level(oRST_GLB_TIMESTAMP_FR)
);

vi_sync_level #(.SIZE(1)) rst_sync_global_timestamp_pcie_inst
(  
  .in_level (glb_timestamp_rst),
  .clk      (oCLK_PCIE_REF_GLOBAL), 
	.rst_n    (oRST_PCIE_APP_N),
  .out_level(oRST_GLB_TIMESTAMP_PCIE)
);



assign ribbon_ena = glb_timestamp_rst_reg;
assign neighbor_ena = glb_timestamp_rst_reg || !ribbon_rst_n;

assign ioSYNC_RIBBON = ribbon_ena ? 1'b0 : 1'bz;
assign ioSYNC_NEIGHBOR = neighbor_ena ? 1'b0 : 1'bz;
assign oSYNC_RIBBON =  ioSYNC_RIBBON ;
assign oSYNC_NEIGHBOR = ioSYNC_NEIGHBOR ;
/*
IOBUF ioSYNC_RIBBON_0 (
  .I  (0),       
  .T  (ribbon_enable),     
  .IO (ioSYNC_RIBBON),  
  .O  (oSYNC_RIBBON) 
)
IOBUF ioSYNC_NEIGHBOR_0 (
  .I  (0),       
  .T  (neighbor_enable),     
  .IO (ioSYNC_NEIGHBOR),  
  .O  (oSYNC_NEIGHBOR) 
)
*/

endmodule
