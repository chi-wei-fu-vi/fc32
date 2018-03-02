/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.  * 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: channel_engine.v$
* $Author: jaedon.kim $
* $Date: 2013-08-13 16:39:37 -0700 (Tue, 13 Aug 2013) $
* $Revision: 3177 $
* Description: Top level Channel Engine
*
***************************************************************************/
import fmac_pkg::*;

module channel_engine
#(
        parameter SIM_ONLY     =  0,
        parameter LINK_ID      =  0,
        parameter CH_ID        =  0
)
(
        //////////////////////////////////////////////////////////////////////
        // Reset & Clocks
        //////////////////////////////////////////////////////////////////////
        input   iRST_RX_N,
        input   iRST_LINK_FC_CORE_N,
        input   iCLK_RX,                        //  219MHz
        input   iRST_CORE_N,
        input   iRST_CORE219_N,
        input   fcrxrst_n,
        input   iCLK_CORE,                      //  212MHz
        input   iCLK_CORE219,                   //  219MHz
        input   iCLK_100M,
        input   iRST_100M_N,

        //////////////////////////////////////////////////////////////////////
        // credit stat interface
        //////////////////////////////////////////////////////////////////////
        output logic [31:0]    int_stats_endcr,         // From fmac_credit_stats of fmac_credit_stats.v
        output logic [31:0]    int_stats_maxcr,         // From fmac_credit_stats of fmac_credit_stats.v
        output logic [31:0]    int_stats_mincr,         // From fmac_credit_stats of fmac_credit_stats.v
        output logic [31:0]   int_stats_timecr,        // From fmac_credit_stats of fmac_credit_stats.v
        input  logic [31:0]    reg_fmac_credit_start,         // From fmac_regs of fmac_regs.v
        
        //////////////////////////////////////////////////////////////////////
        // Global
        //////////////////////////////////////////////////////////////////////
        input   [55:0]                         iGLOBAL_TIMESTAMP,
        input   iCHANNEL_ID,
        input   mtip_enable,
        output  [63:0]                         fmac_xbar_rx_data,
        output  [1:0]                          fmac_xbar_rx_sh,
        output  fmac_xbar_rx_valid,
        input   rx_is_lockedtodata,

        
        //////////////////////////////////////////////////////////////////////
        // MM I/F
        //////////////////////////////////////////////////////////////////////
        input   [63:0]                         iMM_WR_DATA,
        input   [16:0]                         iMM_ADDR,
        input   iMM_WR_EN,
        input   iMM_RD_EN,
        output  [63:0]                         oMM_RD_DATA,
        output  oMM_RD_DATA_V,
        
        //////////////////////////////////////////////////////////////////////
        // SFP
        //////////////////////////////////////////////////////////////////////
        input   iSFP_PHY_LOSIG,
        output  sm_linkup,
        
        //////////////////////////////////////////////////////////////////////
        // INTERVAL STATS PKG I/F
        //////////////////////////////////////////////////////////////////////
        input   iINT_STATS_LATCH_CLR,
        output  fmac_pkg::fmac_interval_stats        oINT_STATS_FMAC,
        
        output  [31:0]                         oINT_STATS_FC_CRC,
        output  [31:0]                         oINT_STATS_TRUNC,
        output  [31:0]                         oINT_STATS_BADEOF,
        output  [31:0]                         oINT_STATS_LOSIG,
        output  [31:0]                         oINT_STATS_LOSYNC,
        output  [31:0]                         oINT_STATS_FC_CODE,
        output  [31:0]                         oINT_STATS_LIP,
        output  [31:0]                         oINT_STATS_NOS_OLS,
        output  [31:0]                         oINT_STATS_LR_LRR,
        output  [31:0]                         oINT_STATS_LINK_UP,
        output  [31:0]                         oINT_STATS_FRAME_DROP,
        output  oINT_STATS_UP_LATCH,
        output  oINT_STATS_LR_LRR_LATCH,
        output  oINT_STATS_NOS_LOS_LATCH,
        output  oINT_STATS_LOSIG_LATCH,
        output  oINT_STATS_LOSYNC_LATCH,
        
        
        //////////////////////////////////////////////////////////////////////
        // STATS Clear Synchronization
        //////////////////////////////////////////////////////////////////////
        input   iSTATS_LATCH_CLR_RXCLK,
        
        
        //////////////////////////////////////////////////////////////////////
        // TO/FROM PCS
        //////////////////////////////////////////////////////////////////////
        input   [63:0]                        rx_parallel_data_pma,
				input   [1:0]                          iFC1_RX_SH,
        input   [63:0]                         iFC1_RX_DATA,
        input   iFC1_RX_VAL,
        input   iFC1_RX_BLOCK_SYNC,
        
        
        //////////////////////////////////////////////////////////////////////
        // Serdes
        //////////////////////////////////////////////////////////////////////
        output  [63:0]                         oSERDES_MM_WR_DATA,
        output  logic [13:0]                         oSERDES_MM_ADDR,
        output  logic                                oSERDES_MM_WR_EN,
        output  logic                                oSERDES_MM_RD_EN,
        input   [63:0]                         iSERDES_MM_RD_DATA,
        input   iSERDES_MM_RD_DATA_V,
        
        //////////////////////////////////////////////////////////////////////
        // FC1 KR
        //////////////////////////////////////////////////////////////////////
        output  [63:0]                         oFC1_LAYER_KR_MM_WR_DATA,
        output  logic [13:0]                         oFC1_LAYER_KR_MM_ADDR,
        output  logic                                oFC1_LAYER_KR_MM_WR_EN,
        output  logic                                oFC1_LAYER_KR_MM_RD_EN,
        input   [63:0]                         iFC1_LAYER_KR_MM_RD_DATA,
        input   iFC1_LAYER_KR_MM_RD_DATA_V,
        
        
        
        //////////////////////////////////////////////////////////////////////
        // Time Arbiter I/F
        //////////////////////////////////////////////////////////////////////
        input   iTA_DAT_DAL_READ,
        input   iTA_OFF_FILL_DONE,
        output  [127:0]                        oEXTR_DAT_DAL_DATA,
        output  [55:0]                         oEXTR_DAT_GOOD_TS,
        output  oEXTR_DAT_GTS_VALID,
        output  [75:0]                         oFCE_DAT_FUTURE_TS,
        output  oFCE_DAT_FTS_VALID,
        //output       [127:0]                        oFCE_CTL_DAL_DATA,
        //output                                      oFCE_CTL_GTS_VALID,
        //output       [55:0]                         oFCE_CTL_GOOD_TS,
        //output                                      oFCE_CTL_FTS_VALID,
        //output       [75:0]                         oFCE_CTL_FUTURE_TS,
        
        output  [107:0]                        oMIF_DAT_FUTURE_TS,
        output  oMIF_DAT_FTS_VALID,
        output  oMIF_LOSYNC,
        output  oMIF_OFF_FILL_REQ,
        
        //////////////////////////////////////////////////////////////////////
        // Credit Stats
        //////////////////////////////////////////////////////////////////////
        output  [11:0]                         oRX_PRIMITIVE,
        output  oRX_CLASS_VAL,
        output  oLINK_UP_EVENT,
        
        
        //////////////////////////////////////////////////////////////////////
        // Link Engine Register
        //////////////////////////////////////////////////////////////////////
        //input   [1:0]                          iREG_LINKCTRL_DALCTLSZ,
        input   iREG_LINKCTRL_WR_EN,
        input   iREG_LINKCTRL_SCRMENBL,
        input   [3:0]                          iREG_LINKCTRL_MONITORMODE,
        input   [3:0]                          monitor_mode_masked,
        output  oCHF_DROPPING,
        output  oMIF_LOSIG,
        
        output    REG_TSFIFOSTAT_OVERFLOW,
        output    REG_TSFIFOSTAT_UNDERFLOW,
        output    [4:0] REG_TSFIFOSTAT_WORDS,
        //////////////////////////////////////////////////////////////////////
        // uC Stats
        //////////////////////////////////////////////////////////////////////
        input   [31:0]                         iUCS_LE_MM_RD_DATA,
        input   iUCS_LE_MM_RD_DATA_V,
        output  logic                                oLE_UCS_MM_RD_EN,
        output  logic [4:0]                          oLE_UCS_MM_ADDR,
        
        
        //////////////////////////////////////////////////////////////////////
        // uC Stats
        //////////////////////////////////////////////////////////////////////
        output  logic [1:0]                          fmac_credit_out_r_rdy,
        input   logic [1:0]                          credit_in_r_rdy,
        
        //////////////////////////////////////////////////////////////////////
        // Other Link Engine
        //////////////////////////////////////////////////////////////////////
        input   iINTERVAL_ANY_LINK
        
        
);

        logic   [31:0] ucs_le_mm_rd_data;
        logic   ucs_le_mm_rd_data_v;

logic                                 iCLK_FC_CORE;
logic                                 iRST_FC_CORE_N;
logic                                 iCLK_FC_RX;
logic                                 iRST_FC_RX_N;
logic                                 iRST_LINK_ENGINE_RX_N;
logic  [39:0]                         iRX_PHY_DATA;

logic                                 iCLK_FC_TX       =  0;
logic                                 iRST_FC_TX_N     =  0;

assign  iRST_FC_CORE_N             =  iRST_LINK_FC_CORE_N;
assign  iRST_LINK_ENGINE_RX_N      =  iRST_RX_N;
assign  iCLK_FC_CORE               =  iCLK_CORE;
assign  iCLK_FC_RX                 =  iCLK_RX;
assign  iRST_FC_RX_N               =  iRST_RX_N;

assign  iRX_PHY_DATA               =  rx_parallel_data_pma[39:0];

wire    [13:0]                         MTIP_FC1_ADDR;
wire    [63:0]                         MTIP_FC1_RD_DATA;
wire    [63:0]                         MTIP_FC1_WR_DATA;
wire    MTIP_FC1_RD_DATA_V;
wire    MTIP_FC1_RD_EN;
wire    MTIP_FC1_WR_EN;
//wire   [13:0]                         MTIP_FC2_ADDR;
wire    [63:0]                         MTIP_FC2_RD_DATA;
wire    [63:0]                         MTIP_FC2_WR_DATA;
wire    MTIP_FC2_RD_DATA_V;
logic                                 MTIP_FC2_RD_EN;
logic                                 MTIP_FC2_WR_EN;
wire    mtip_mm_rd_data_v;
logic  [13:0]                         mtip_mm_addr;
wire    [63:0]                         mtip_mm_rd_data;
wire    [63:0]                         mtip_mm_wr_data;
logic                                 mtip_mm_rd_en;
logic                                 mtip_mm_wr_en;
wire    [63:0]                         MIF_EXTR_DATA;
wire    [2:0]                          MIF_EXTR_EMPTY;
wire    MIF_EXTR_SOP;
wire    MIF_EXTR_EOP;
wire    MIF_EXTR_ERR;
wire    MIF_EXTR_VALID;
wire    [2:0]                          MIF_EXTR_INDEX;
//wire    [107:0]                        MIF_EXTR_FUTURE_TS;
wire    MIF_EXTR_EXTRENABLE;
logic  [63:0]                         mux_st_data;
logic  [2:0]                          mux_st_empty;
logic                                 mux_st_sop;
logic                                 mux_st_eop;
logic                                 mux_st_err;
logic                                 mux_st_valid;
logic  [2:0]                          mux_extr_index;
logic  [107:0]                        mux_extr_future_ts;
wire    [13:0]                         mtip_fc2_mm_addr;
wire    mtip_fc2_mm_rd_en;
wire    mtip_fc2_mm_wr_en;

///////////////////////////////////////////////////////////////////////////////
// Manual Declaration
///////////////////////////////////////////////////////////////////////////////
logic  [8:0]                          uc_addr_msb;
logic  [4:0]                          uc_addr_lsb;
logic  [13:0]                         MTIP_FC2_ADDR, EXTR_ADDR, SERDES_MM_ADDR          /* synthesis preserve */;
logic  [4:0]                          LE_UCS_MM_ADDR            /* synthesis preserve */;

///////////////////////////////////////////////////////////////////////////////
// Auto Declaration
///////////////////////////////////////////////////////////////////////////////
wire    EXTR_FCE_TS_FIFO_POP;
wire    ts_fifo_pop_16g;
wire    ts_fifo_pop_8g;
wire    [63:0]                         EXTR_RD_DATA;
wire    EXTR_RD_DATA_V;
wire    EXTR_RD_EN;
wire    EXTR_REG_EXTRENABLE;
wire    [75:0]                         EXTR_REG_FUTURE_TS;
wire    [63:0]                         EXTR_WR_DATA;
wire    EXTR_WR_EN;
wire    [13:0]                         FMAC_ADDR;
wire    [63:0]                         FMAC_RD_DATA;
wire    FMAC_RD_DATA_V;
wire    FMAC_RD_EN;
wire    [63:0]                         FMAC_WR_DATA;
wire    FMAC_WR_EN;
logic                                 fmac_st_avail;
logic  [63:0]                         fmac_st_data;
logic                                 fmac_st_empty;
logic                                 fmac_st_eop;
logic                                 fmac_st_err;
logic  [7:0]                          fmac_st_err_stat;
logic                                 fmac_st_sop;
logic                                 fmac_st_valid;
logic  [11:0]                         fmac_st_vf_id;
wire    [13:0]                         serdes_mm_addr;
wire    serdes_mm_rd_en;
wire    serdes_mm_wr_en;
wire    uc_mm_rd_en;
// End of automatics
wire    [2:0]                          MAC_FCE_INDEX;

logic   sfp_los, sfp_los_r;

always @(posedge iCLK_RX or negedge iRST_RX_N)
  if (!iRST_RX_N)
	begin
		sfp_los   <= 1'b0;
		sfp_los_r <= 1'b0;
	end
	else
  begin
		sfp_los   <= iSFP_PHY_LOSIG;
		sfp_los_r <= sfp_los;
	end

///////////////////////////////////////////////////////////////////////////////
// FMAC Instantiation
///////////////////////////////////////////////////////////////////////////////
/* fmac_wrap AUTO_TEMPLATE (
   .ofmac_interval_stats (oINT_STATS_FMAC),
   .clk(iCLK_CORE),
   .rst_n(iRST_LINK_FC_CORE_N),
   .rx_clk(iCLK_RX),
   .rx_rst_n(iRST_RX_N),
   .mm_fmac_addr(FMAC_ADDR),
   .mm_fmac_rd_en(FMAC_RD_EN),
   .mm_fmac_wr_data(FMAC_WR_DATA),
   .mm_fmac_wr_en(FMAC_WR_EN),
   .pcs_rx_data(iFC1_RX_DATA),
   .pcs_rx_hdr(iFC1_RX_SH),
   .pcs_rx_valid(iFC1_RX_VAL),
   .pcs_rx_sync(iFC1_RX_BLOCK_SYNC),

   .fmac_mm_ack(FMAC_RD_DATA_V),
   .fmac_mm_rd_data(FMAC_RD_DATA[63:0]),

 );
*/
fmac_wrap #(
        . SIM_ONLY                                             ( SIM_ONLY                                           ),
        . CH_ID                                                ( CH_ID                                              ),
        . LINK_ID                                              ( LINK_ID                                            )
) fmac (
        . iREG_LINKCTRL_MONITORMODE                            ( monitor_mode_masked                          ),
				. iSFP_PHY_LOSIG                                       ( sfp_los_r ),
        . rx_is_lockedtodata (rx_is_lockedtodata),
        . sm_linkup                                            ( sm_linkup                                          ),
        . ofmac_interval_stats                                 ( oINT_STATS_FMAC                                    ),  // fmac_interval_stats 
        . mm_fmac_addr                                         ( FMAC_ADDR                                          ),  // input [13:0]
        . clk                                                  ( iCLK_CORE                                          ),  // input
        . credit_in_r_rdy                                      ( credit_in_r_rdy[1:0]                               ),  // input [1:0]
        . int_stats_latch_clr                                  ( iINT_STATS_LATCH_CLR                                ),         // input
        . mm_fmac_rd_en                                        ( FMAC_RD_EN                                         ),          // input
        . mm_fmac_wr_data                                      ( FMAC_WR_DATA                                       ),          // input [63:0]
        . mm_fmac_wr_en                                        ( FMAC_WR_EN                                         ),          // input
        . pcs_rx_data                                          ( iFC1_RX_DATA                                       ),          // input [63:0]
        . pcs_rx_hdr                                           ( iFC1_RX_SH                                         ),          // input [1:0]
        . pcs_rx_sync                                          ( iFC1_RX_BLOCK_SYNC                                 ),          // input
        . pcs_rx_valid                                         ( iFC1_RX_VAL                                        ),          // input
        . rst_n                                                ( iRST_LINK_FC_CORE_N                                ),          // input
        . rx_clk                                               ( iCLK_RX                                            ),          // input
        . rx_rst_n                                             ( iRST_RX_N                                          ),          // input
        . fmac_credit_out_r_rdy                                ( fmac_credit_out_r_rdy[1:0]                         ),          // output [1:0]
        . int_stats_endcr (int_stats_endcr),      
        . int_stats_maxcr (int_stats_maxcr),      
        . int_stats_mincr (int_stats_mincr),      
        . int_stats_timecr (int_stats_timecr),     
        . reg_fmac_credit_start (reg_fmac_credit_start),
        . fmac_st_avail                                        ( fmac_st_avail                                      ),          // output
        . fmac_st_data                                         ( fmac_st_data[63:0]                                 ),          // output [63:0]
        . fmac_st_empty                                        ( fmac_st_empty                                      ),          // output
        . fmac_st_eop                                          ( fmac_st_eop                                        ),          // output
        . fmac_st_err                                          ( fmac_st_err                                        ),          // output
        . fmac_st_err_stat                                     ( fmac_st_err_stat[7:0]                              ),          // output [7:0]
        . fmac_st_sop                                          ( fmac_st_sop                                        ),          // output
        . fmac_st_valid                                        ( fmac_st_valid                                      ),          // output
        . fmac_st_vf_id                                        ( fmac_st_vf_id[11:0]                                ),          // output [11:0]
        . fmac_xbar_rx_data                                    ( fmac_xbar_rx_data[63:0]                            ),          // output [63:0]
        . fmac_xbar_rx_sh                                      ( fmac_xbar_rx_sh[1:0]                            ),             // output [63:0]
        . fmac_xbar_rx_valid                                   ( fmac_xbar_rx_valid                                 ),          // output
        . fmac_mm_ack                                          ( FMAC_RD_DATA_V                                     ),          // output
        . fmac_mm_rd_data                                      ( FMAC_RD_DATA[63:0]                                 )           // output [63:0]
);

/*
generate
  if (LINK_ID == 0 && CH_ID == 0) begin: sigtap_gen_EXTR
//signaltap
wire [127:0] EXTR_acq_data_in;
wire         EXTR_acq_clk;

assign EXTR_acq_clk = iCLK_CORE;

signaltap EXTR_signaltap_inst (
  .acq_clk(EXTR_acq_clk),
  .acq_data_in(EXTR_acq_data_in),
  .acq_trigger_in(EXTR_acq_data_in)
);

assign EXTR_acq_data_in = {
//128
//112
//104
//96
//90
//64
//48
//32
//16
oEXTR_DAT_DAL_DATA[119:0],
1'b0,
EXTR_REG_EXTRENABLE,
fmac_st_sop,
fmac_st_eop,
fmac_st_err,
fmac_st_valid,
fmac_st_empty,
iRST_CORE_N
};

  end  // if LINK_ID, CH_ID
endgenerate
*/
///////////////////////////////////////////////////////////////////////////////
// Extractor Top Instantiation
///////////////////////////////////////////////////////////////////////////////
/* extractor_top AUTO_TEMPLATE (
    .iCORE_CLK          ( iCLK_CORE            ),
    .iRST_n             ( iRST_LINK_FC_CORE_N          ),
    .iFC8_MODE          ( 1'b1                  ),
    .iFC_DAT_\(.*\)     ( oFCE_DAT_\1[]         ),
    .oEXTR_FC_\(.*\)    ( EXTR_FCE_\1[]         ),
    .oEXTR_REG_\(.*\)   ( EXTR_REG_\1[]         ),
    .\([a-z]\)MM_\(.*\)  ( EXTR_\2[]             ),
    .iFC_EXTR_DATA ( fmac_st_data),
    .iFC_EXTR_EMPTY  ( {fmac_st_empty, 1'b0, 1'b0}),
    .iFC_EXTR_SOP  ( fmac_st_sop         ),
    .iFC_EXTR_EOP  ( fmac_st_eop         ),
    .iFC_EXTR_ERR  ( fmac_st_err         ),
    .iFC_EXTR_VALID  ( fmac_st_valid         ),
    .iFC_EXTR_INDEX  ( 3'b001         ), // hard coded
    .iFC_EXTR_FUTURE_TS( EXTR_REG_FUTURE_TS[75:0]         ),
    .iFC_EXTR_EXTRENABLE( EXTR_REG_EXTRENABLE         ),


   );
*/
logic extr_enable;

always @(posedge iCLK_CORE)
  extr_enable <= mtip_enable ? MIF_EXTR_EXTRENABLE : EXTR_REG_EXTRENABLE;

extractor_top u_extractor_top (
        . iRST_n                                               ( iRST_LINK_FC_CORE_N                                        ),          // input
        . iCORE_CLK                                            ( iCLK_CORE                                          ),          // input
        . iCHANNEL_ID                                          ( iCHANNEL_ID                                        ),          // input
        . iEXT_MODE                                            ( mtip_enable                                        ),          // input
        . iPKG_MODE                                            ( 1'b1                                               ),          // input
        . iMM_WR_DATA                                          ( EXTR_WR_DATA[63:0]                                 ),          // input [63:0]
        . iMM_ADDR                                             ( EXTR_ADDR[13:0]                                    ),          // input [13:0]
        . iMM_WR_EN                                            ( EXTR_WR_EN                                         ),          // input
        . iMM_RD_EN                                            ( EXTR_RD_EN                                         ),          // input
        . oMM_RD_DATA                                          ( EXTR_RD_DATA[63:0]                                 ),          // output [63:0]
        . oMM_RD_DATA_V                                        ( EXTR_RD_DATA_V                                     ),          // output
        . oEXTR_FC_TS_FIFO_POP                                 ( EXTR_FCE_TS_FIFO_POP                               ),          // output
        . oEXTR_REG_EXTRENABLE                                 ( EXTR_REG_EXTRENABLE                                ),          // output
        . iFC_EXTR_DATA                                        ( mux_st_data                                        ),          // input [63:0]
        . iFC_EXTR_EMPTY                                       ( mux_st_empty                                       ),          // input [2:0]
        . iFC_EXTR_SOP                                         ( mux_st_sop                                         ),          // input
        . iFC_EXTR_EOP                                         ( mux_st_eop                                         ),          // input
        . iFC_EXTR_ERR                                         ( mux_st_err                                         ),          // input
        . iFC_EXTR_VALID                                       ( mux_st_valid                                       ),          // input
        . iFC_EXTR_INDEX                                       ( mux_extr_index[2:0]                                ),          // input [2:0]
        . iFC_EXTR_FUTURE_TS                                   ( mux_extr_future_ts[107:0]                          ),          // input [107:0]
        . iFC_EXTR_EXTRENABLE                                  ( extr_enable ),     // input
        //. iFC_EXTR_EXTRENABLE                                  ( EXTR_REG_EXTRENABLE ),     // input
        . oEXTR_DAT_DAL_DATA                                   ( oEXTR_DAT_DAL_DATA[127:0]                          ),          // output [127:0]
        . oEXTR_DAT_GOOD_TS                                    ( oEXTR_DAT_GOOD_TS[55:0]                            ),          // output [55:0]
        . oEXTR_DAT_GTS_VALID                                  ( oEXTR_DAT_GTS_VALID                                ),          // output
        . iTA_DAT_DAL_READ                                     ( iTA_DAT_DAL_READ                                   ),          // input
        . oINT_STATS_FRAME_DROP                                ( oINT_STATS_FRAME_DROP[31:0]                        ),          // output [31:0]
        . iINT_STATS_LATCH_CLR                                 ( iINT_STATS_LATCH_CLR                               ),          // input
        . oCHF_DROPPING                                        ( oCHF_DROPPING                                      )           // output
);

gatekeeper gatekeeper_inst(

. iRST_LINK_FC_CORE_N(iRST_LINK_FC_CORE_N),
. iCLK_CORE(iCLK_CORE),

. mtip_enable(mtip_enable),

. MIF_EXTR_DATA(MIF_EXTR_DATA),
. MIF_EXTR_EMPTY(MIF_EXTR_EMPTY),
. MIF_EXTR_SOP(MIF_EXTR_SOP),
. MIF_EXTR_EOP(MIF_EXTR_EOP),
. MIF_EXTR_ERR(MIF_EXTR_ERR),
. MIF_EXTR_VALID(MIF_EXTR_VALID),

. fmac_st_data(fmac_st_data),
. fmac_st_empty({fmac_st_empty,1'b0,1'b0}),
. fmac_st_eop(fmac_st_eop),
. fmac_st_err(fmac_st_err),
. fmac_st_sop(fmac_st_sop),
. fmac_st_valid(fmac_st_valid),

. mux_st_data(mux_st_data),
. mux_st_empty(mux_st_empty),
. mux_st_sop(mux_st_sop),
. mux_st_eop(mux_st_eop),
. mux_st_err(mux_st_err),
. mux_st_valid(mux_st_valid)

);



assign ts_fifo_pop_16g = EXTR_FCE_TS_FIFO_POP && ~mtip_enable;
assign ts_fifo_pop_8g = EXTR_FCE_TS_FIFO_POP && mtip_enable;


///////////////////////////////////////////////////////////////////////////////
// Timestamp FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
/*
ts_fifo_wrap AUTO_TEMPLATE (
  //inputs
  .CLK_CORE(iCLK_CORE),
  .RST_CORE_N(iRST_LINK_FC_CORE_N),

  .FMAC_ST_SOP(mux_st_sop),
  .FMAC_ST_VALID(mux_st_valid),
  .GLOBAL_TIMESTAMP(iGLOBAL_TIMESTAMP),
  .TIME_FIFO_WR_DATA(time_fifo_wr_data),

  //outputs
  .FCE_DAT_FUTURE_TS(oFCE_DAT_FUTURE_TS),
  .FCE_DAT_FTS_VALID(oFCE_DAT_FTS_VALID),
  .FCE_EXTR_FUTURE_TS(EXTR_REG_FUTURE_TS[75:0]),

  .REG_TSFIFOSTAT_WORDS(REG_TSFIFOSTAT_WORDS),
  .REG_TSFIFOSTAT_OVERFLOW(REG_TSFIFOSTAT_OVERFLOW),
  .REG_TSFIFOSTAT_UNDERFLOW(REG_TSFIFOSTAT_UNDERFLOW),

);
*/
ts_fifo_wrap ts_fifo_wrap_inst (
        . CLK_CORE                                             ( iCLK_CORE                                          ),          // input
        . RST_CORE_N                                           ( iRST_LINK_FC_CORE_N                                        ),          // input
        . FMAC_ST_SOP                                          ( mux_st_sop                                        ),          // input
        . FMAC_ST_VALID                                        ( mux_st_valid                                      ),          // input
        . GLOBAL_TIMESTAMP                                     ( iGLOBAL_TIMESTAMP                                  ),          // input [55:0]
        //. TIME_FIFO_WR_DATA                                    ( time_fifo_wr_data                                  ),          // input [75:0]
        . EXTR_FCE_TS_FIFO_POP                                 ( EXTR_FCE_TS_FIFO_POP                               ),          // input
        . FCE_DAT_FUTURE_TS                                    ( oFCE_DAT_FUTURE_TS                                 ),          // output [75:0]
        . FCE_DAT_FTS_VALID                                    ( oFCE_DAT_FTS_VALID                                 ),          // output
        . FCE_EXTR_FUTURE_TS                                   ( EXTR_REG_FUTURE_TS[75:0]                           ),          // output [75:0]
        . REG_TSFIFOSTAT_WORDS                                 ( REG_TSFIFOSTAT_WORDS                               ),          // output [4:0]
        . REG_TSFIFOSTAT_OVERFLOW                              ( REG_TSFIFOSTAT_OVERFLOW                            ),          // output
        . REG_TSFIFOSTAT_UNDERFLOW                             ( REG_TSFIFOSTAT_UNDERFLOW                           )           // output
);

always @(posedge iCLK_CORE or negedge iRST_CORE_N)
  if (!iRST_CORE_N)
	begin
	  ucs_le_mm_rd_data <= {32{1'b0}};
		ucs_le_mm_rd_data_v <= 1'b0;
	end
	else
	begin
	  ucs_le_mm_rd_data <= iUCS_LE_MM_RD_DATA;
		ucs_le_mm_rd_data_v <= iUCS_LE_MM_RD_DATA_V;
	end

///////////////////////////////////////////////////////////////////////////////
// Channel Addr Decoder
///////////////////////////////////////////////////////////////////////////////
/* ch0_addr_decoder AUTO_TEMPLATE (
          .clk      (iCLK_CORE),
         .rst_n      (iRST_CORE_N),
                                 .FC1_LAYER_KR_\(.*\)   (oFC1_LAYER_KR_MM_\1[]),
                                 .FC1_LAYER_KR_RD_DATA  (iFC1_LAYER_KR_MM_RD_DATA[63:0]),
                                 .FC1_LAYER_KR_RD_DATA_V(iFC1_LAYER_KR_MM_RD_DATA_V),

                                 .EXTR_\(.*\)   (EXTR_\1[]),
                                 .UCSTATS_ADDR           ( {uc_addr_msb, uc_addr_lsb}        ),
                                 .UCSTATS_RD_EN          ( uc_mm_rd_en[]                     ),
                                 .UCSTATS_RD_DATA        ( {32'b0, ucs_le_mm_rd_data}       ),
                                 .UCSTATS_RD_DATA_V      ( ucs_le_mm_rd_data_v              ),
                                 .UCSTATS_WR\(.*\)       (),
                                 .SERDES_RD_D\(.*\)      ( iSERDES_MM_RD_D\1[]               ),
                                 .SERDES_WR_DATA          ( oSERDES_MM_WR_DATA[]              ),
                                 .SERDES_ADDR            ( serdes_mm_addr[]                ),
                                 .SERDES_WR_EN           ( serdes_mm_wr_en                    ),
                                 .SERDES_RD_EN           ( serdes_mm_rd_en                    ),


 
 );
 */



ch0_addr_decoder u_addr_dec (
        . clk                                                  ( iCLK_CORE                                          ),          // input
        . rst_n                                                ( iRST_CORE_N                                        ),          // input
        . iMM_ADDR                                             ( iMM_ADDR[13:0]                                     ),          // input [13:0]
        . iMM_WR_EN                                            ( iMM_WR_EN                                          ),          // input
        . iMM_RD_EN                                            ( iMM_RD_EN                                          ),          // input
        . iMM_WR_DATA                                          ( iMM_WR_DATA[63:0]                                  ),          // input [63:0]
        . oMM_RD_DATA                                          ( oMM_RD_DATA[63:0]                                  ),          // output [63:0]
        . oMM_RD_DATA_V                                        ( oMM_RD_DATA_V                                      ),          // output
        . SERDES_ADDR                                          ( serdes_mm_addr[13:0]                               ),          // output [13:0]
        . SERDES_WR_DATA                                       ( oSERDES_MM_WR_DATA[63:0]                           ),          // output [63:0]
        . SERDES_WR_EN                                         ( serdes_mm_wr_en                                    ),          // output
        . SERDES_RD_EN                                         ( serdes_mm_rd_en                                    ),          // output
        . SERDES_RD_DATA                                       ( iSERDES_MM_RD_DATA[63:0]                           ),          // input [63:0]
        . SERDES_RD_DATA_V                                     ( iSERDES_MM_RD_DATA_V                               ),          // input
        . SERDES_clk                                           ( iCLK_CORE219                                       ),
        . SERDES_rst_n                                         ( iRST_CORE219_N                                     ),
        
        . FC1_LAYER_KR_ADDR                                    ( oFC1_LAYER_KR_MM_ADDR[13:0]                        ),          // output [13:0]
        . FC1_LAYER_KR_WR_DATA                                 ( oFC1_LAYER_KR_MM_WR_DATA[63:0]                     ),          // output [63:0]
        . FC1_LAYER_KR_WR_EN                                   ( oFC1_LAYER_KR_MM_WR_EN                             ),          // output
        . FC1_LAYER_KR_RD_EN                                   ( oFC1_LAYER_KR_MM_RD_EN                             ),          // output
        . FC1_LAYER_KR_RD_DATA                                 ( iFC1_LAYER_KR_MM_RD_DATA[63:0]                     ),          // input [63:0]
        . FC1_LAYER_KR_RD_DATA_V                               ( iFC1_LAYER_KR_MM_RD_DATA_V                         ),          // input
        . FMAC_ADDR                                            ( FMAC_ADDR[13:0]                                    ),          // output [13:0]
        . FMAC_WR_DATA                                         ( FMAC_WR_DATA[63:0]                                 ),          // output [63:0]
        . FMAC_WR_EN                                           ( FMAC_WR_EN                                         ),          // output
        . FMAC_RD_EN                                           ( FMAC_RD_EN                                         ),          // output
        . FMAC_RD_DATA                                         ( FMAC_RD_DATA[63:0]                                 ),          // input [63:0]
        . FMAC_RD_DATA_V                                       ( FMAC_RD_DATA_V                                     ),          // input
        . EXTR_ADDR                                            ( EXTR_ADDR[13:0]                                    ),          // output [13:0]
        . EXTR_WR_DATA                                         ( EXTR_WR_DATA[63:0]                                 ),          // output [63:0]
        . EXTR_WR_EN                                           ( EXTR_WR_EN                                         ),          // output
        . EXTR_RD_EN                                           ( EXTR_RD_EN                                         ),          // output
        . EXTR_RD_DATA                                         ( EXTR_RD_DATA[63:0]                                 ),          // input [63:0]
        . EXTR_RD_DATA_V                                       ( EXTR_RD_DATA_V                                     ),          // input
        . UCSTATS_ADDR                                         ( {uc_addr_msb, uc_addr_lsb}                         ),          // output [13:0]
        . UCSTATS_WR_DATA                                      ( ),     // output [63:0]
        . UCSTATS_WR_EN                                        ( ),     // output
        . UCSTATS_RD_EN                                        ( uc_mm_rd_en                                        ),  // output
        . UCSTATS_RD_DATA                                      ( {32'b0, ucs_le_mm_rd_data}                        ),  // input [63:0]
        . UCSTATS_RD_DATA_V                                    ( ucs_le_mm_rd_data_v                               ),  // input
        
        . MTIP_ADDR                                            ( mtip_mm_addr[13:0]                                 ),  // output [13:0]
        . MTIP_WR_DATA                                         ( mtip_mm_wr_data[63:0]                              ),  // output [63:0]
        . MTIP_WR_EN                                           ( mtip_mm_wr_en                                      ),  // output
        . MTIP_RD_EN                                           ( mtip_mm_rd_en                                      ),  // output
        . MTIP_RD_DATA                                         ( mtip_mm_rd_data[63:0]                              ),  // input [63:0]
        . MTIP_RD_DATA_V                                       ( mtip_mm_rd_data_v                                  ),  // input
        
        . MTIP_clk                                             ( iCLK_100M                                          ),  // input
        . MTIP_rst_n                                           ( iRST_100M_N                                        ),  // input
        . MTIP_FC1_ADDR                                        ( MTIP_FC1_ADDR                                      ),  // output [13:0]
        . MTIP_FC1_WR_DATA                                     ( MTIP_FC1_WR_DATA                                   ),  // output [63:0]
        . MTIP_FC1_WR_EN                                       ( MTIP_FC1_WR_EN                                     ),  // output
        . MTIP_FC1_RD_EN                                       ( MTIP_FC1_RD_EN                                     ),  // output
        . MTIP_FC1_RD_DATA                                     ( MTIP_FC1_RD_DATA                                   ),  // input [63:0]
        . MTIP_FC1_RD_DATA_V                                   ( MTIP_FC1_RD_DATA_V                                 ),  // input
        . MTIP_FC1_clk                                         ( iCLK_FC_RX                                         ),  // input
        . MTIP_FC1_rst_n                                       ( iRST_FC_RX_N                                       ),  // input
        . MTIP_FC2_ADDR                                        ( mtip_fc2_mm_addr[13:0]                             ),  // output [13:0]
        . MTIP_FC2_WR_DATA                                     ( MTIP_FC2_WR_DATA[63:0]                             ),  // output [63:0]
        . MTIP_FC2_WR_EN                                       ( mtip_fc2_mm_wr_en                                  ),  // output
        . MTIP_FC2_RD_EN                                       ( mtip_fc2_mm_rd_en                                  ),  // output
        . MTIP_FC2_RD_DATA                                     ( MTIP_FC2_RD_DATA[63:0]                             ),  // input [63:0]
        . MTIP_FC2_RD_DATA_V                                   ( MTIP_FC2_RD_DATA_V                                 )   // input
);


always_ff @( posedge iCLK_CORE or negedge iRST_CORE_N)
if (!iRST_CORE_N) 
begin
        LE_UCS_MM_ADDR <= 'h0;
        oLE_UCS_MM_RD_EN <= 'h0;
end
else
begin
        LE_UCS_MM_ADDR <= uc_addr_lsb;
        oLE_UCS_MM_RD_EN <= uc_mm_rd_en;
end

always_ff @( posedge iCLK_CORE219 or negedge iRST_CORE219_N) 
if (!iRST_CORE219_N)
begin
        SERDES_MM_ADDR <= 'h0;
        oSERDES_MM_WR_EN <= 'h0;
        oSERDES_MM_RD_EN <= 'h0;
end
else
begin
        SERDES_MM_ADDR <= serdes_mm_addr;
        oSERDES_MM_WR_EN <= serdes_mm_wr_en;
        oSERDES_MM_RD_EN <= serdes_mm_rd_en;      
end

assign  oLE_UCS_MM_ADDR    =  LE_UCS_MM_ADDR;
assign  oSERDES_MM_ADDR    =  SERDES_MM_ADDR;



wire    omif_off_fill_req;
assign  oMIF_OFF_FILL_REQ  =  mtip_enable ? omif_off_fill_req : 1'b0;

mtip_wrap mtip_wrap_inst (
        . iCLK_100M                                            ( iCLK_100M                                          ),  // input 
        . iCLK_FC_CORE                                         ( iCLK_FC_CORE                                       ),  // input 
        . iCLK_FC_RX                                           ( iCLK_FC_RX                                         ),  // input 
        . iCLK_FC_TX                                           ( iCLK_FC_TX                                         ),  // input 
        . iRST_100M_N                                          ( iRST_100M_N                                        ),  // input 
        . iRST_FC_CORE_N                                       ( iRST_FC_CORE_N                                     ),  // input 
        //. iRST_FC_RX_N                                         ( iRST_FC_RX_N                                       ),  // input 
        . iRST_FC_RX_N                                         ( fcrxrst_n                                       ),  // input 
        . iRST_FC_TX_N                                         ( iRST_FC_TX_N                                       ),  // input 
        . iRST_LINK_ENGINE_RX_N                                ( iRST_LINK_ENGINE_RX_N                              ),  // input 
        . iGLOBAL_TIMESTAMP                                    ( iGLOBAL_TIMESTAMP                                  ),  // input [55:0]
        . iINT_STATS_LATCH_CLR                                 ( iINT_STATS_LATCH_CLR                               ),  // input 
        . oINT_STATS_BADEOF                                    ( oINT_STATS_BADEOF                                  ),  // output [31:0]
        . oINT_STATS_FC_CODE                                   ( oINT_STATS_FC_CODE                                 ),  // output [31:0]
        . oINT_STATS_FC_CRC                                    ( oINT_STATS_FC_CRC                                  ),  // output [31:0]
        . oINT_STATS_LINK_UP                                   ( oINT_STATS_LINK_UP                                 ),  // output [31:0]
        . oINT_STATS_LIP                                       ( oINT_STATS_LIP                                     ),  // output [31:0]
        . oINT_STATS_LOSIG                                     ( oINT_STATS_LOSIG                                   ),  // output [31:0]
        . oINT_STATS_LOSYNC                                    ( oINT_STATS_LOSYNC                                  ),  // output [31:0]
        . oINT_STATS_LR_LRR                                    ( oINT_STATS_LR_LRR                                  ),  // output [31:0]
        . oINT_STATS_NOS_OLS                                   ( oINT_STATS_NOS_OLS                                 ),  // output [31:0]
        . oINT_STATS_TRUNC                                     ( oINT_STATS_TRUNC                                   ),  // output [31:0]
        . oINT_STATS_LOSIG_LATCH                               ( oINT_STATS_LOSIG_LATCH                             ),  // output 
        . oINT_STATS_LOSYNC_LATCH                              ( oINT_STATS_LOSYNC_LATCH                            ),  // output 
        . oINT_STATS_LR_LRR_LATCH                              ( oINT_STATS_LR_LRR_LATCH                            ),  // output 
        . oINT_STATS_NOS_LOS_LATCH                             ( oINT_STATS_NOS_LOS_LATCH                           ),  // output 
        . oINT_STATS_UP_LATCH                                  ( oINT_STATS_UP_LATCH                                ),  // output 
        . iSTATS_LATCH_CLR_RXCLK                               ( iSTATS_LATCH_CLR_RXCLK                             ),    // input 
        . iRX_PHY_DATA                                         ( iRX_PHY_DATA                                       ),  // input [39:0]
        . iTA_OFF_FILL_DONE                                    ( iTA_OFF_FILL_DONE                                  ),  // input 
        . oMIF_DAT_FUTURE_TS                                   ( oMIF_DAT_FUTURE_TS                                 ),  // output [107:0]
        . oMIF_DAT_FTS_VALID                                   ( oMIF_DAT_FTS_VALID                                 ),  // output 
        . oMIF_LOSIG                                           ( oMIF_LOSIG                                         ),  // output 
        . oMIF_LOSYNC                                          ( oMIF_LOSYNC                                        ),  // output 
        . oMIF_OFF_FILL_REQ                                    ( omif_off_fill_req                                  ),  // output 
        . oRX_PRIMITIVE                                        ( oRX_PRIMITIVE                                      ),  // output [11:0]
        . oRX_CLASS_VAL                                        ( oRX_CLASS_VAL                                      ),  // output 
        . oLINK_UP_EVENT                                       ( oLINK_UP_EVENT                                     ),  // output 
        . iREG_LINKCTRL_MONITORMODE                            ( iREG_LINKCTRL_MONITORMODE[3:0]                     ),  // input [3:0]
        . iREG_LINKCTRL_SCRMENBL                               ( iREG_LINKCTRL_SCRMENBL                             ),  // input 
        . iREG_LINKCTRL_WR_EN                                  ( iREG_LINKCTRL_WR_EN                                ),  // input 
        . iSFP_PHY_LOSIG                                       ( sfp_los_r                                     ),  // input 
        . iINTERVAL_ANY_LINK                                   ( iINTERVAL_ANY_LINK                                 ),  // input 
        //. EXTR_MIF_TS_FIFO_POP                                 ( ts_fifo_pop_8g                               ),  // input 
        . EXTR_REG_EXTRENABLE                                  ( EXTR_REG_EXTRENABLE                                ),  // input 
        . MIF_EXTR_DATA                                        ( MIF_EXTR_DATA                                      ),  // output [63:0]
        . MIF_EXTR_EMPTY                                       ( MIF_EXTR_EMPTY                                     ),  // output [2:0]
        . MIF_EXTR_SOP                                         ( MIF_EXTR_SOP                                       ),  // output 
        . MIF_EXTR_EOP                                         ( MIF_EXTR_EOP                                       ),  // output 
        . MIF_EXTR_ERR                                         ( MIF_EXTR_ERR                                       ),  // output 
        . MIF_EXTR_VALID                                       ( MIF_EXTR_VALID                                     ),  // output 
        . MIF_EXTR_INDEX                                       ( MIF_EXTR_INDEX                                     ),  // output [2:0]
        //. MIF_EXTR_FUTURE_TS                                   ( MIF_EXTR_FUTURE_TS                                 ),  // output [107:0]
        . MIF_EXTR_EXTRENABLE                                  ( MIF_EXTR_EXTRENABLE                                ),  // output 
        . MTIP_FC1_ADDR                                        ( MTIP_FC1_ADDR                                      ),  // input [13:0]
        . MTIP_FC1_RD_DATA_V                                   ( MTIP_FC1_RD_DATA_V                                 ),  // output 
        . MTIP_FC1_RD_DATA                                     ( MTIP_FC1_RD_DATA                                   ),  // output [63:0]
        . MTIP_FC1_RD_EN                                       ( MTIP_FC1_RD_EN                                     ),  // input 
        . MTIP_FC1_WR_DATA                                     ( MTIP_FC1_WR_DATA                                   ),  // input [63:0]
        . MTIP_FC1_WR_EN                                       ( MTIP_FC1_WR_EN                                     ),  // input 
        . MTIP_FC2_ADDR                                        ( MTIP_FC2_ADDR                                      ),  // input [13:0]
        . MTIP_FC2_RD_DATA_V                                   ( MTIP_FC2_RD_DATA_V                                 ),  // output 
        . MTIP_FC2_RD_DATA                                     ( MTIP_FC2_RD_DATA                                   ),  // output [63:0]
        . MTIP_FC2_RD_EN                                       ( MTIP_FC2_RD_EN                                     ),  // input 
        . MTIP_FC2_WR_DATA                                     ( MTIP_FC2_WR_DATA                                   ),  // input [63:0]
        . MTIP_FC2_WR_EN                                       ( MTIP_FC2_WR_EN                                     )  // input 
        //. mtip_mm_addr                                         ( mtip_mm_addr                                       ),  // input [13:0]
        //. mtip_mm_rd_data_v                                    ( mtip_mm_rd_data_v                                  ),  // output 
        //. mtip_mm_rd_data                                      ( mtip_mm_rd_data                                    ),  // output [63:0]
        //. mtip_mm_rd_en                                        ( mtip_mm_rd_en                                      ),  // input 
        //. mtip_mm_wr_data                                      ( mtip_mm_wr_data                                    ),  // input [63:0]
        //. mtip_mm_wr_en                                        ( mtip_mm_wr_en                                      )   // input 
);
always_ff @( posedge iCLK_FC_CORE ) begin
        MTIP_FC2_ADDR               <= mtip_fc2_mm_addr;
        MTIP_FC2_WR_EN              <= mtip_fc2_mm_wr_en;
        MTIP_FC2_RD_EN              <= mtip_fc2_mm_rd_en;
        //mux_st_valid                <= mtip_enable ? MIF_EXTR_VALID                          : fmac_st_valid;
        //mux_st_sop                  <= mtip_enable ? MIF_EXTR_SOP                            : fmac_st_sop; 
        //mux_st_err                  <= mtip_enable ? MIF_EXTR_ERR                            : fmac_st_err;
        //mux_st_eop                  <= mtip_enable ? MIF_EXTR_EOP                            : fmac_st_eop;
        //mux_st_empty                <= mtip_enable ? MIF_EXTR_EMPTY[2:0]                     : {fmac_st_empty,1'b0,1'b0};
        //mux_st_data                 <= mtip_enable ? MIF_EXTR_DATA[63:0]                     : fmac_st_data;
        
        mux_extr_index              <= mtip_enable ? MIF_EXTR_INDEX[2:0]                     : 3'b001;
        mux_extr_future_ts          <= EXTR_REG_FUTURE_TS[75:0];
end

endmodule
