/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: mtip_if_top.v$
* $Author: honda.yang $
* $Date: 2013-11-27 10:15:55 -0800 (Wed, 27 Nov 2013) $
* $Revision: 4019 $
* Description: Top level MoreThanIP Interface module
*
***************************************************************************/

module mtip_if_top
(
  //////////////////////////////////////////////////////////////////////
  // Reset & Clocks
  //////////////////////////////////////////////////////////////////////
  input 	iRST_FC_CORE_N,
  input 	iRST_FC_RX_N,
  input 	iRST_100M_N,

  input 	iCLK_FC_CORE, /* 212.5MHz */
  input 	iCLK_FC_RX, // recovered clock
  input 	iCLK_100M,

  //////////////////////////////////////////////////////////////////////
  // Global
  //////////////////////////////////////////////////////////////////////
  input [55:0] 	iGLOBAL_TIMESTAMP,

  //////////////////////////////////////////////////////////////////////
  // MM I/F
  //////////////////////////////////////////////////////////////////////
  input [63:0] 	iMM0_WR_DATA,
  input [13:0] 	iMM0_ADDR,
  input 	iMM0_WR_EN,
  input 	iMM0_RD_EN,
  output [63:0] oMM0_RD_DATA,
  output 	oMM0_RD_DATA_V,

  input [63:0] 	iMM1_WR_DATA,
  input [13:0] 	iMM1_ADDR,
  input 	iMM1_WR_EN,
  input 	iMM1_RD_EN,
  output [63:0] oMM1_RD_DATA,
  output 	oMM1_RD_DATA_V,
 
  input [63:0] 	iMTIP_MM_WR_DATA,
  input [13:0] 	iMTIP_MM_ADDR,
  input 	iMTIP_MM_WR_EN,
  input 	iMTIP_MM_RD_EN,
  output [63:0] oMTIP_MM_RD_DATA,
  output 	oMTIP_MM_RD_DATA_V,

  //////////////////////////////////////////////////////////////////////
  // SFP
  //////////////////////////////////////////////////////////////////////
  input 	iSFP_PHY_LOSIG,

  //////////////////////////////////////////////////////////////////////
  // MoreThanIP I/F 
  //////////////////////////////////////////////////////////////////////
  input [31:0] 	iFF_RX_DATA,
  input 	iFF_RX_SOP,
  input 	iFF_RX_DVAL,
  input 	iFF_RX_EOP,
  input 	iFF_RX_ERR,
  input [7:0] 	iFF_RX_ERR_STAT,
  input [31:0] 	iRX_FC1_DATA,
  input 	iRX_FC1_KCHN,
  input 	iRX_FC1_ERR,
  input [11:0] 	iRX_PRIMITIVE,
  input 	iRX_DISP_ERR,
  input 	iRX_CHAR_ERR,
  input 	iFC_LINK_SYNC,
  input [63:0] 	iMTIP_DEBUG,

  input [31:0] 	iMTIP_REG_DATA_OUT,
  input 	iMTIP_REG_BUSY,
  output [31:0] oMTIP_REG_DATA_IN,
  output [9:0] 	oMTIP_REG_ADDR,
  output 	oMTIP_REG_RD,
  output 	oMTIP_REG_WR,

  //////////////////////////////////////////////////////////////////////
  // Extractor Engine I/F
  //////////////////////////////////////////////////////////////////////
  input 	iEXTR_MIF_TS_FIFO_POP,
  input 	iEXTR_REG_EXTRENABLE,
  output [63:0] oMIF_EXTR_DATA,
  output [2:0] 	oMIF_EXTR_EMPTY,
  output 	oMIF_EXTR_SOP,
  output 	oMIF_EXTR_EOP,
  output 	oMIF_EXTR_ERR,
  output 	oMIF_EXTR_VALID,
  output [2:0] 	 oMIF_EXTR_INDEX,
  output [107:0] oMIF_EXTR_FUTURE_TS,
  output 	oMIF_EXTR_EXTRENABLE,

  //////////////////////////////////////////////////////////////////////
  // Time Arbiter I/F
  //////////////////////////////////////////////////////////////////////
  input 	iTA_OFF_FILL_DONE,
  output [107:0] oMIF_DAT_FUTURE_TS,
  output 	oMIF_DAT_FTS_VALID,
  output 	oMIF_LOSYNC,
  output 	oMIF_OFF_FILL_REQ,

  //////////////////////////////////////////////////////////////////////
  // INTERVAL STATS PKG I/F
  //////////////////////////////////////////////////////////////////////
  input 	iINT_STATS_LATCH_CLR,
  output [31:0] oINT_STATS_FC_CRC,
  output [31:0] oINT_STATS_TRUNC,
  output [31:0] oINT_STATS_BADEOF,
  output [31:0] oINT_STATS_LOSIG,
  output [31:0] oINT_STATS_LOSYNC,
  output [31:0] oINT_STATS_FC_CODE,
  output [31:0] oINT_STATS_LIP,
  output [31:0] oINT_STATS_NOS_OLS,
  output [31:0] oINT_STATS_LR_LRR,
  output [31:0] oINT_STATS_LINK_UP,
  output    oINT_STATS_UP_LATCH,
  output    oINT_STATS_LR_LRR_LATCH,
  output    oINT_STATS_NOS_LOS_LATCH,
  output    oINT_STATS_LOSIG_LATCH,
  output    oINT_STATS_LOSYNC_LATCH,

  //////////////////////////////////////////////////////////////////////
  // STATS Clear Synchronization
  //////////////////////////////////////////////////////////////////////
  input 	iSTATS_LATCH_CLR_RXCLK,

  //////////////////////////////////////////////////////////////////////
  // Credit STATS 
  //////////////////////////////////////////////////////////////////////
  output 	oLINK_UP_EVENT,

  //////////////////////////////////////////////////////////////////////
  // Link Registers
  //////////////////////////////////////////////////////////////////////
  input 	iREG_LINKCTRL_WR_EN,
  input 	iREG_LINKCTRL_SCRMENBL,
  input [3:0] 	iREG_LINKCTRL_MONITORMODE,
  output 	oMIF_LOSIG,

  //////////////////////////////////////////////////////////////////////
  // Other Link Engine
  //////////////////////////////////////////////////////////////////////
  input 	iINTERVAL_ANY_LINK

  );

///////////////////////////////////////////////////////////////////////////////
// Auto Declaration
///////////////////////////////////////////////////////////////////////////////
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic			DP_TIME_FIFO_PUSH;	// From u_fc2_extr_bridge of fc2_extr_bridge.v
logic [107:0]		DP_TIME_FIFO_WD;	// From u_fc2_extr_bridge of fc2_extr_bridge.v
wire [31:0]		FEB_BRG_DATA;		// From u_mtip_ipg of mtip_ipg.v
wire			FEB_BRG_DVAL;		// From u_mtip_ipg of mtip_ipg.v
wire			FEB_BRG_EOP;		// From u_mtip_ipg of mtip_ipg.v
wire			FEB_BRG_ERR;		// From u_mtip_ipg of mtip_ipg.v
wire			FEB_BRG_SOP;		// From u_mtip_ipg of mtip_ipg.v
logic			REG_DISPERRCTR_EN;	// From u_fc1_decode_stats of fc1_decode_stats.v
logic			REG_EOFERRCTR_EN;	// From u_fc1_decode_stats of fc1_decode_stats.v
logic			REG_FCCRCERRCTR_EN;	// From u_fc2_frame_stats of fc2_frame_stats.v
logic			REG_FCEOFERRCTR_EN;	// From u_fc2_frame_stats of fc2_frame_stats.v
logic			REG_FCFRMCTR_EN;	// From u_fc2_extr_bridge of fc2_extr_bridge.v
logic			REG_FCLOSERRCTR_EN;	// From u_fc2_frame_stats of fc2_frame_stats.v
logic			REG_FCLOSIERRCTR_EN;	// From u_fc2_frame_stats of fc2_frame_stats.v
logic			REG_FCSHORTERRCTR_EN;	// From u_fc2_extr_bridge of fc2_extr_bridge.v
logic			REG_FCTRUNCERRCTR_EN;	// From u_fc2_frame_stats of fc2_frame_stats.v
logic			REG_FRAMINGSTOP_B2BEOP;	// From u_fc2_extr_bridge of fc2_extr_bridge.v
logic			REG_FRAMINGSTOP_B2BSOP;	// From u_fc2_extr_bridge of fc2_extr_bridge.v
logic			REG_INVLDERRCTR_EN;	// From u_fc1_decode_stats of fc1_decode_stats.v
logic			REG_PRIMLINKUPCTR_EN;	// From u_fc1_decode_stats of fc1_decode_stats.v
logic			REG_PRIMLIPCTR_EN;	// From u_fc1_decode_stats of fc1_decode_stats.v
logic			REG_PRIMLRLRRCTR_EN;	// From u_fc1_decode_stats of fc1_decode_stats.v
logic			REG_PRIMNOSOLSCTR_EN;	// From u_fc1_decode_stats of fc1_decode_stats.v
wire [7:0]		REG_SINGLESTEP_CNT;	// From u_mtip_if_fc2_regs of mtip_if_fc2_regs.v
wire			REG_SINGLESTEP_MODE;	// From u_mtip_if_fc2_regs of mtip_if_fc2_regs.v
wire			REG_SINGLESTEP_START;	// From u_mtip_if_fc2_regs of mtip_if_fc2_regs.v
logic			REG_SOFERRCTR_EN;	// From u_fc1_decode_stats of fc1_decode_stats.v
logic			REG_TSFIFOSTAT_OVERFLOW;// From u_timestamp_fifo of timestamp_fifo.v
logic			REG_TSFIFOSTAT_UNDERFLOW;// From u_timestamp_fifo of timestamp_fifo.v
logic [4:0]		REG_TSFIFOSTAT_WORDS;	// From u_timestamp_fifo of timestamp_fifo.v
wire [63:0]		REG__SCRATCH;		// From u_mtip_if_fc1_regs of mtip_if_fc1_regs.v, ...
// End of automatics

///////////////////////////////////////////////////////////////////////////////
// Manual Declaration
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// FE Buffer Instantiation
///////////////////////////////////////////////////////////////////////////////
// MTIP core sometimes sends zero IPG to the client interface where iFF_RX_EOP
// is immediately followed by iFF_RX_SOP with no gap. mtip_ipg module ensure
// frame gap.
/* mtip_ipg AUTO_TEMPLATE (
    .iCLK               ( iCLK_FC_CORE          ),
    .iRESET_n           ( iRST_FC_CORE_N        ),
    .iMTIP_\(.*\)       ( iFF_RX_\1[]           ),
    .o\(.*\)_P0         ( FEB_BRG_\1[]          ),
    .o\(.*\)            (                       ),
   );
*/

mtip_ipg u_mtip_ipg (
    /*AUTOINST*/
		     // Outputs
		     .oSOP		(                       ), // Templated
		     .oEOP		(                       ), // Templated
		     .oERR		(                       ), // Templated
		     .oDVAL		(                       ), // Templated
		     .oDATA_P0		( FEB_BRG_DATA[31:0]          ), // Templated
		     .oSOP_P0		( FEB_BRG_SOP          ), // Templated
		     .oEOP_P0		( FEB_BRG_EOP          ), // Templated
		     .oERR_P0		( FEB_BRG_ERR          ), // Templated
		     .oDVAL_P0		( FEB_BRG_DVAL          ), // Templated
		     .oFIFO_FULL	(                       ), // Templated
		     // Inputs
		     .iRESET_n		( iRST_FC_CORE_N        ), // Templated
		     .iCLK		( iCLK_FC_CORE          ), // Templated
		     .iMTIP_DATA	( iFF_RX_DATA[31:0]           ), // Templated
		     .iMTIP_DVAL	( iFF_RX_DVAL           ), // Templated
		     .iMTIP_SOP		( iFF_RX_SOP           ), // Templated
		     .iMTIP_EOP		( iFF_RX_EOP           ), // Templated
		     .iMTIP_ERR		( iFF_RX_ERR           )); // Templated

///////////////////////////////////////////////////////////////////////////////
// MoreThanIP Extractor Bridge Instantiation
///////////////////////////////////////////////////////////////////////////////
/* fc2_extr_bridge AUTO_TEMPLATE (
    .clk                ( iCLK_FC_CORE          ),
    .rst_n              ( iRST_FC_CORE_N        ),
    .iREG_LINK\(.*\)    ( iREG_LINK\1[]         ),
    .iREG_\(.*\)        ( REG_\1[]              ),
    .iFEB_BRG_\(.*\)    ( FEB_BRG_\1[]          ),
    .oDP_TIME_\(.*\)    ( DP_TIME_\1[]          ),
    .oREG_\(.*\)        ( REG_\1[]              ),
   );
*/

fc2_extr_bridge u_fc2_extr_bridge (
    /*AUTOINST*/
				   // Outputs
				   .oMIF_EXTR_DATA	(oMIF_EXTR_DATA[63:0]),
				   .oMIF_EXTR_EMPTY	(oMIF_EXTR_EMPTY[2:0]),
				   .oMIF_EXTR_SOP	(oMIF_EXTR_SOP),
				   .oMIF_EXTR_EOP	(oMIF_EXTR_EOP),
				   .oMIF_EXTR_ERR	(oMIF_EXTR_ERR),
				   .oMIF_EXTR_VALID	(oMIF_EXTR_VALID),
				   .oMIF_EXTR_INDEX	(oMIF_EXTR_INDEX[2:0]),
				   .oMIF_EXTR_EXTRENABLE(oMIF_EXTR_EXTRENABLE),
				   .oDP_TIME_FIFO_WD	( DP_TIME_FIFO_WD[107:0]          ), // Templated
				   .oDP_TIME_FIFO_PUSH	( DP_TIME_FIFO_PUSH          ), // Templated
				   .oREG_FCSHORTERRCTR_EN( REG_FCSHORTERRCTR_EN              ), // Templated
				   .oREG_FCFRMCTR_EN	( REG_FCFRMCTR_EN              ), // Templated
				   .oREG_FRAMINGSTOP_B2BSOP( REG_FRAMINGSTOP_B2BSOP              ), // Templated
				   .oREG_FRAMINGSTOP_B2BEOP( REG_FRAMINGSTOP_B2BEOP              ), // Templated
				   .oMIF_OFF_FILL_REQ	(oMIF_OFF_FILL_REQ),
				   // Inputs
				   .clk			( iCLK_FC_CORE          ), // Templated
				   .rst_n		( iRST_FC_CORE_N        ), // Templated
				   .iGLOBAL_TIMESTAMP	(iGLOBAL_TIMESTAMP[55:0]),
				   .iFEB_BRG_DATA	( FEB_BRG_DATA[31:0]          ), // Templated
				   .iFEB_BRG_SOP	( FEB_BRG_SOP          ), // Templated
				   .iFEB_BRG_DVAL	( FEB_BRG_DVAL          ), // Templated
				   .iFEB_BRG_EOP	( FEB_BRG_EOP          ), // Templated
				   .iFEB_BRG_ERR	( FEB_BRG_ERR          ), // Templated
				   .iEXTR_REG_EXTRENABLE(iEXTR_REG_EXTRENABLE),
				   .iTA_OFF_FILL_DONE	(iTA_OFF_FILL_DONE),
				   .iREG_SINGLESTEP_MODE( REG_SINGLESTEP_MODE              ), // Templated
				   .iREG_SINGLESTEP_START( REG_SINGLESTEP_START              ), // Templated
				   .iREG_SINGLESTEP_CNT	( REG_SINGLESTEP_CNT[7:0]              ), // Templated
				   .iREG_LINKCTRL_MONITORMODE( iREG_LINKCTRL_MONITORMODE[3:0]         ), // Templated
				   .iINTERVAL_ANY_LINK	(iINTERVAL_ANY_LINK));

///////////////////////////////////////////////////////////////////////////////
// Timestamp FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
/* timestamp_fifo AUTO_TEMPLATE (
    .clk                ( iCLK_FC_CORE          ),
    .rst_n              ( iRST_FC_CORE_N        ),
    .iTS_FIFO_PUSH      ( DP_TIME_FIFO_PUSH     ),
    .iTS_FIFO_WD        ( DP_TIME_FIFO_WD[]     ),
    .iTS_FIFO_POP       ( iEXTR_MIF_TS_FIFO_POP ),
    .oEXTR_\(.*\)       ( oMIF_EXTR_\1[]        ),
    .oREG_\(.*\)        ( REG_\1[]              ),
    .o\(.*\)            ( oMIF_DAT_\1[]         ),
   );
*/
//
//timestamp_fifo u_timestamp_fifo (
    ///*AUTOINST*/
				 //// Outputs
				 //.oFUTURE_TS		( oMIF_DAT_FUTURE_TS[107:0]         ), // Templated
				 //.oFTS_VALID		( oMIF_DAT_FTS_VALID         ), // Templated
				 //.oEXTR_FUTURE_TS	( oMIF_EXTR_FUTURE_TS[107:0]        ), // Templated
				 //.oREG_TSFIFOSTAT_WORDS	( REG_TSFIFOSTAT_WORDS[4:0]              ), // Templated
				 //.oREG_TSFIFOSTAT_OVERFLOW( REG_TSFIFOSTAT_OVERFLOW              ), // Templated
				 //.oREG_TSFIFOSTAT_UNDERFLOW( REG_TSFIFOSTAT_UNDERFLOW              ), // Templated
				 //// Inputs
				 //.clk			( iCLK_FC_CORE          ), // Templated
				 //.rst_n			( iRST_FC_CORE_N        ), // Templated
				 //.iTS_FIFO_PUSH		( DP_TIME_FIFO_PUSH     ), // Templated
				 //.iTS_FIFO_WD		( DP_TIME_FIFO_WD[107:0]     ), // Templated
				 //.iTS_FIFO_POP		( iEXTR_MIF_TS_FIFO_POP )); // Templated

///////////////////////////////////////////////////////////////////////////////
// FC1 Decode Stats Instantiation
///////////////////////////////////////////////////////////////////////////////
/* fc1_decode_stats AUTO_TEMPLATE (
    .clk                ( iCLK_FC_RX            ),
    .rst_n              ( iRST_FC_RX_N          ),
    .iREG_\(.*\)        ( REG_\1[]              ),
    .oFC1_REG_\(.*\)    ( REG_\1[]              ),
   );
*/

fc1_decode_stats u_fc1_decode_stats (
    /*AUTOINST*/
				     // Outputs
				     .oINT_STATS_FC_CODE(oINT_STATS_FC_CODE[31:0]),
				     .oINT_STATS_LIP	(oINT_STATS_LIP[31:0]),
				     .oINT_STATS_NOS_OLS(oINT_STATS_NOS_OLS[31:0]),
				     .oINT_STATS_LR_LRR	(oINT_STATS_LR_LRR[31:0]),
				     .oINT_STATS_LINK_UP(oINT_STATS_LINK_UP[31:0]),
				     .oINT_STATS_UP_LATCH(oINT_STATS_UP_LATCH),
				     .oINT_STATS_LR_LRR_LATCH(oINT_STATS_LR_LRR_LATCH),
				     .oINT_STATS_NOS_LOS_LATCH(oINT_STATS_NOS_LOS_LATCH),
				     .oLINK_UP_EVENT	(oLINK_UP_EVENT),
				     .oFC1_REG_DISPERRCTR_EN( REG_DISPERRCTR_EN              ), // Templated
				     .oFC1_REG_INVLDERRCTR_EN( REG_INVLDERRCTR_EN              ), // Templated
				     .oFC1_REG_SOFERRCTR_EN( REG_SOFERRCTR_EN              ), // Templated
				     .oFC1_REG_EOFERRCTR_EN( REG_EOFERRCTR_EN              ), // Templated
				     .oFC1_REG_PRIMLIPCTR_EN( REG_PRIMLIPCTR_EN              ), // Templated
				     .oFC1_REG_PRIMNOSOLSCTR_EN( REG_PRIMNOSOLSCTR_EN              ), // Templated
				     .oFC1_REG_PRIMLRLRRCTR_EN( REG_PRIMLRLRRCTR_EN              ), // Templated
				     .oFC1_REG_PRIMLINKUPCTR_EN( REG_PRIMLINKUPCTR_EN              ), // Templated
				     // Inputs
				     .clk		( iCLK_FC_RX            ), // Templated
				     .rst_n		( iRST_FC_RX_N          ), // Templated
				     .iGLOBAL_TIMESTAMP	(iGLOBAL_TIMESTAMP[55:0]),
				     .iRX_FC1_DATA	(iRX_FC1_DATA[31:0]),
				     .iRX_FC1_KCHN	(iRX_FC1_KCHN),
				     .iRX_FC1_ERR	(iRX_FC1_ERR),
				     .iRX_PRIMITIVE	(iRX_PRIMITIVE[11:0]),
				     .iRX_DISP_ERR	(iRX_DISP_ERR),
				     .iRX_CHAR_ERR	(iRX_CHAR_ERR),
				     .iFC_LINK_SYNC	(iFC_LINK_SYNC),
				     .iSFP_PHY_LOSIG	(iSFP_PHY_LOSIG),
				     .iSTATS_LATCH_CLR_RXCLK(iSTATS_LATCH_CLR_RXCLK));

///////////////////////////////////////////////////////////////////////////////
// FC2 Frame Stats Instantiation
///////////////////////////////////////////////////////////////////////////////
/* fc2_frame_stats AUTO_TEMPLATE (
    .clk                ( iCLK_FC_CORE          ),
    .rst_n              ( iRST_FC_CORE_N        ),
    .iREG_\(.*\)        ( REG_\1[]              ),
    .oFC2_REG_\(.*\)    ( REG_\1[]              ),
   );
*/

fc2_frame_stats u_fc2_frame_stats (
    /*AUTOINST*/
				   // Outputs
				   .oINT_STATS_FC_CRC	(oINT_STATS_FC_CRC[31:0]),
				   .oINT_STATS_TRUNC	(oINT_STATS_TRUNC[31:0]),
				   .oINT_STATS_BADEOF	(oINT_STATS_BADEOF[31:0]),
				   .oINT_STATS_LOSIG	(oINT_STATS_LOSIG[31:0]),
				   .oINT_STATS_LOSYNC	(oINT_STATS_LOSYNC[31:0]),
				   .oINT_STATS_LOSIG_LATCH(oINT_STATS_LOSIG_LATCH),
				   .oINT_STATS_LOSYNC_LATCH(oINT_STATS_LOSYNC_LATCH),
				   .oFC2_REG_FCCRCERRCTR_EN( REG_FCCRCERRCTR_EN              ), // Templated
				   .oFC2_REG_FCTRUNCERRCTR_EN( REG_FCTRUNCERRCTR_EN              ), // Templated
				   .oFC2_REG_FCEOFERRCTR_EN( REG_FCEOFERRCTR_EN              ), // Templated
				   .oFC2_REG_FCLOSERRCTR_EN( REG_FCLOSERRCTR_EN              ), // Templated
				   .oFC2_REG_FCLOSIERRCTR_EN( REG_FCLOSIERRCTR_EN              ), // Templated
				   .oMIF_LOSYNC		(oMIF_LOSYNC),
				   .oMIF_LOSIG		(oMIF_LOSIG),
				   // Inputs
				   .clk			( iCLK_FC_CORE          ), // Templated
				   .rst_n		( iRST_FC_CORE_N        ), // Templated
				   .iFF_RX_EOP		(iFF_RX_EOP),
				   .iFF_RX_DVAL		(iFF_RX_DVAL),
				   .iFF_RX_ERR		(iFF_RX_ERR),
				   .iFF_RX_ERR_STAT	(iFF_RX_ERR_STAT[7:0]),
				   .iFC_LINK_SYNC	(iFC_LINK_SYNC),
				   .iSFP_PHY_LOSIG	(iSFP_PHY_LOSIG),
				   .iINT_STATS_LATCH_CLR(iINT_STATS_LATCH_CLR));

///////////////////////////////////////////////////////////////////////////////
// FC1 Registers Instantiation
///////////////////////////////////////////////////////////////////////////////
/* mtip_if_fc1_regs AUTO_TEMPLATE (
    .clk                ( iCLK_FC_RX            ),
    .rst_n              ( iRST_FC_RX_N          ),
    .wr_data            ( iMM0_WR_DATA[63:0]    ),
    .addr               ( iMM0_ADDR[9:0]        ),
    .wr_en              ( iMM0_WR_EN            ),
    .rd_en              ( iMM0_RD_EN            ),
    .rd_data            ( oMM0_RD_DATA[63:0]    ),
    .rd_data_v          ( oMM0_RD_DATA_V        ),
    .iREG_\(.*\)        ( REG_\1[]              ),
    .oREG_\(.*\)        ( REG_\1[]              ),
   );
*/

mtip_if_fc1_regs u_mtip_if_fc1_regs (
    /*AUTOINST*/
				     // Outputs
				     .rd_data		( oMM0_RD_DATA[63:0]    ), // Templated
				     .rd_data_v		( oMM0_RD_DATA_V        ), // Templated
				     .oREG__SCRATCH	( REG__SCRATCH[63:0]              ), // Templated
				     // Inputs
				     .clk		( iCLK_FC_RX            ), // Templated
				     .rst_n		( iRST_FC_RX_N          ), // Templated
				     .wr_en		( iMM0_WR_EN            ), // Templated
				     .rd_en		( iMM0_RD_EN            ), // Templated
				     .addr		( iMM0_ADDR[9:0]        ), // Templated
				     .wr_data		( iMM0_WR_DATA[63:0]    ), // Templated
				     .iREG_DISPERRCTR_EN( REG_DISPERRCTR_EN              ), // Templated
				     .iREG_INVLDERRCTR_EN( REG_INVLDERRCTR_EN              ), // Templated
				     .iREG_SOFERRCTR_EN	( REG_SOFERRCTR_EN              ), // Templated
				     .iREG_EOFERRCTR_EN	( REG_EOFERRCTR_EN              ), // Templated
				     .iREG_PRIMLIPCTR_EN( REG_PRIMLIPCTR_EN              ), // Templated
				     .iREG_PRIMNOSOLSCTR_EN( REG_PRIMNOSOLSCTR_EN              ), // Templated
				     .iREG_PRIMLRLRRCTR_EN( REG_PRIMLRLRRCTR_EN              ), // Templated
				     .iREG_PRIMLINKUPCTR_EN( REG_PRIMLINKUPCTR_EN              )); // Templated

///////////////////////////////////////////////////////////////////////////////
// FC2 Registers Instantiation
///////////////////////////////////////////////////////////////////////////////
/* mtip_if_fc2_regs AUTO_TEMPLATE (
    .clk                ( iCLK_FC_CORE          ),
    .rst_n              ( iRST_FC_CORE_N        ),
    .wr_data            ( iMM1_WR_DATA[63:0]    ),
    .addr               ( iMM1_ADDR[9:0]        ),
    .wr_en              ( iMM1_WR_EN            ),
    .rd_en              ( iMM1_RD_EN            ),
    .rd_data            ( oMM1_RD_DATA[63:0]    ),
    .rd_data_v          ( oMM1_RD_DATA_V        ),
    .iREG_\(.*\)        ( REG_\1[]              ),
    .oREG_\(.*\)        ( REG_\1[]              ),
   );
*/

mtip_if_fc2_regs u_mtip_if_fc2_regs 
  ( // Manual
    .iREG_MTIP_DEBUG_RESERVED        ( 15'd0 ),
    .iREG_MTIP_DEBUG_RX_CLASS_VAL    ( iMTIP_DEBUG[48] ),
    .iREG_MTIP_DEBUG_RX_CLASS        ( iMTIP_DEBUG[47:44] ),
    .iREG_MTIP_DEBUG_RX_END_CODE_VAL ( iMTIP_DEBUG[43] ),
    .iREG_MTIP_DEBUG_RX_END_CODE     ( iMTIP_DEBUG[42:39] ),
    .iREG_MTIP_DEBUG_RX_PRIMITIVE    ( iMTIP_DEBUG[38:27] ),
    .iREG_MTIP_DEBUG_RX_FC1_KCHN     ( iMTIP_DEBUG[26] ),
    .iREG_MTIP_DEBUG_RX_FC1_ERR      ( iMTIP_DEBUG[25] ),
    .iREG_MTIP_DEBUG_RX_DISP_ERR     ( iMTIP_DEBUG[24] ),
    .iREG_MTIP_DEBUG_RX_CHAR_ERR     ( iMTIP_DEBUG[23] ),
    .iREG_MTIP_DEBUG_LED_LINK_SYNC   ( iMTIP_DEBUG[22] ),
    .iREG_MTIP_DEBUG_LED_LINK_ONLINE ( iMTIP_DEBUG[21] ),
    .iREG_MTIP_DEBUG_FF_TX_MOD       ( iMTIP_DEBUG[20:19] ),
    .iREG_MTIP_DEBUG_FF_RX_DSAV      ( iMTIP_DEBUG[18] ),
    .iREG_MTIP_DEBUG_FF_RX_SOP       ( iMTIP_DEBUG[17] ),
    .iREG_MTIP_DEBUG_FF_RX_EOP       ( iMTIP_DEBUG[16] ),
    .iREG_MTIP_DEBUG_FF_RX_ERR       ( iMTIP_DEBUG[15] ),
    .iREG_MTIP_DEBUG_FF_RX_RDY       ( iMTIP_DEBUG[14] ),
    .iREG_MTIP_DEBUG_FF_RX_DVAL      ( iMTIP_DEBUG[13] ),
    .iREG_MTIP_DEBUG_COMMA_DET       ( iMTIP_DEBUG[12] ),
    .iREG_MTIP_DEBUG_RX_PHY_LOS      ( iMTIP_DEBUG[11] ),
    .iREG_MTIP_DEBUG_SCRB_ENA        ( iMTIP_DEBUG[10] ),
    .iREG_MTIP_DEBUG_RX_CRC_ERR      ( iMTIP_DEBUG[9] ),
    .iREG_MTIP_DEBUG_RX_FRM_DISCARD  ( iMTIP_DEBUG[8] ),
    .iREG_MTIP_DEBUG_RX_LENGTH_ERR   ( iMTIP_DEBUG[7] ),
    .iREG_MTIP_DEBUG_RX_FRM_RCV      ( iMTIP_DEBUG[6] ),
    .iREG_MTIP_DEBUG_DEC_ERROR       ( iMTIP_DEBUG[5] ),
    .iREG_MTIP_DEBUG_SYNC_ACQURD     ( iMTIP_DEBUG[4] ),
    .iREG_MTIP_DEBUG_NODE_OFF_LINE   ( iMTIP_DEBUG[3] ),
    .iREG_MTIP_DEBUG_NODE_ON_LINE    ( iMTIP_DEBUG[2] ),
    .iREG_MTIP_DEBUG_NODE_FAULT      ( iMTIP_DEBUG[1] ),
    .iREG_MTIP_DEBUG_NODE_RECOVERY   ( iMTIP_DEBUG[0] ),
    /*AUTOINST*/
   // Outputs
   .rd_data				( oMM1_RD_DATA[63:0]    ), // Templated
   .rd_data_v				( oMM1_RD_DATA_V        ), // Templated
   .oREG__SCRATCH			( REG__SCRATCH[63:0]              ), // Templated
   .oREG_SINGLESTEP_MODE		( REG_SINGLESTEP_MODE              ), // Templated
   .oREG_SINGLESTEP_START		( REG_SINGLESTEP_START              ), // Templated
   .oREG_SINGLESTEP_CNT			( REG_SINGLESTEP_CNT[7:0]              ), // Templated
   // Inputs
   .clk					( iCLK_FC_CORE          ), // Templated
   .rst_n				( iRST_FC_CORE_N        ), // Templated
   .wr_en				( iMM1_WR_EN            ), // Templated
   .rd_en				( iMM1_RD_EN            ), // Templated
   .addr				( iMM1_ADDR[9:0]        ), // Templated
   .wr_data				( iMM1_WR_DATA[63:0]    ), // Templated
   .iREG_FCFRMCTR_EN			( REG_FCFRMCTR_EN              ), // Templated
   .iREG_FCCRCERRCTR_EN			( REG_FCCRCERRCTR_EN              ), // Templated
   .iREG_FCTRUNCERRCTR_EN		( REG_FCTRUNCERRCTR_EN              ), // Templated
   .iREG_FCEOFERRCTR_EN			( REG_FCEOFERRCTR_EN              ), // Templated
   .iREG_FCLOSERRCTR_EN			( REG_FCLOSERRCTR_EN              ), // Templated
   .iREG_FCLOSIERRCTR_EN		( REG_FCLOSIERRCTR_EN              ), // Templated
   .iREG_FCSHORTERRCTR_EN		( REG_FCSHORTERRCTR_EN              ), // Templated
   //.iREG_TSFIFOSTAT_UNDERFLOW		( REG_TSFIFOSTAT_UNDERFLOW              ), // Templated
   //.iREG_TSFIFOSTAT_OVERFLOW		( REG_TSFIFOSTAT_OVERFLOW              ), // Templated
   //.iREG_TSFIFOSTAT_WORDS		( REG_TSFIFOSTAT_WORDS[4:0]              ), // Templated
   .iREG_TSFIFOSTAT_UNDERFLOW		( 1'b0              ), // Templated
   .iREG_TSFIFOSTAT_OVERFLOW		( 1'b0              ), // Templated
   .iREG_TSFIFOSTAT_WORDS		( {5{1'b0}}              ), // Templated
   .iREG_FRAMINGSTOP_B2BEOP		( REG_FRAMINGSTOP_B2BEOP              ), // Templated
   .iREG_FRAMINGSTOP_B2BSOP		( REG_FRAMINGSTOP_B2BSOP              )); // Templated

///////////////////////////////////////////////////////////////////////////////
// MoreThanIP Core PIO Instantiation
///////////////////////////////////////////////////////////////////////////////
/* mtip_pio AUTO_TEMPLATE (
   );
*/

mtip_pio u_mtip_pio (
    /*AUTOINST*/
		     // Outputs
		     .oMTIP_REG_DATA_IN	(oMTIP_REG_DATA_IN[31:0]),
		     .oMTIP_REG_ADDR	(oMTIP_REG_ADDR[9:0]),
		     .oMTIP_REG_RD	(oMTIP_REG_RD),
		     .oMTIP_REG_WR	(oMTIP_REG_WR),
		     .oMTIP_MM_RD_DATA	(oMTIP_MM_RD_DATA[63:0]),
		     .oMTIP_MM_RD_DATA_V(oMTIP_MM_RD_DATA_V),
		     // Inputs
		     .iCLK_100M		(iCLK_100M),
		     .iCLK_FC_CORE	(iCLK_FC_CORE),
		     .iRST_100M_N	(iRST_100M_N),
		     .iRST_FC_CORE_N	(iRST_FC_CORE_N),
		     .iMTIP_REG_DATA_OUT(iMTIP_REG_DATA_OUT[31:0]),
		     .iMTIP_REG_BUSY	(iMTIP_REG_BUSY),
		     .iMTIP_MM_WR_DATA	(iMTIP_MM_WR_DATA[63:0]),
		     .iMTIP_MM_ADDR	(iMTIP_MM_ADDR[13:0]),
		     .iMTIP_MM_WR_EN	(iMTIP_MM_WR_EN),
		     .iMTIP_MM_RD_EN	(iMTIP_MM_RD_EN),
		     .iREG_LINKCTRL_WR_EN(iREG_LINKCTRL_WR_EN),
		     .iREG_LINKCTRL_SCRMENBL(iREG_LINKCTRL_SCRMENBL));


// synopsys translate_off

///////////////////////////////////////////////////////////////////////////////
// Assertion
///////////////////////////////////////////////////////////////////////////////
pkt_mbst_checker #(
    .DATA_WIDTH ( 32                    )
)
u_mtip_core_pkt_prop_checker (
    .clk                ( iCLK_FC_CORE          ),
    .rst_n              ( iRST_FC_CORE_N        ),
    .data               ( iFF_RX_DATA           ),
    .sop                ( iFF_RX_SOP            ),
    .eop                ( iFF_RX_EOP            ),
    .valid              ( iFF_RX_DVAL           ),
    .zero               ( 1'b0                  )
);

// The following errors should not occur during normal operation
assert_net_err_mtip_error: assert property ( @( posedge iCLK_FC_CORE )
    disable iff ( ~iRST_FC_CORE_N )
    iFF_RX_EOP |-> ~iFF_RX_ERR );

assert_net_err_mtip_length_error: assert property ( @( posedge iCLK_FC_CORE )
    disable iff ( ~iRST_FC_CORE_N )
    iFF_RX_EOP |-> ~( iFF_RX_ERR & iFF_RX_ERR_STAT[0] ) );

assert_net_err_mtip_crc_error: assert property ( @( posedge iCLK_FC_CORE )
    disable iff ( ~iRST_FC_CORE_N )
    iFF_RX_EOP |-> ~( iFF_RX_ERR & iFF_RX_ERR_STAT[1] ) );

assert_net_err_mtip_overflow_error: assert property ( @( posedge iCLK_FC_CORE )
    disable iff ( ~iRST_FC_CORE_N )
    iFF_RX_EOP |-> ~( iFF_RX_ERR & iFF_RX_ERR_STAT[2] ) );

assert_net_err_mtip_eof_error: assert property ( @( posedge iCLK_FC_CORE )
    disable iff ( ~iRST_FC_CORE_N )
    iFF_RX_EOP |-> ~( iFF_RX_ERR & iFF_RX_ERR_STAT[3] ) );

// Ensure minimum inter frame gap after mtip_ipg
assert_inter_frame_gap_eop_sop: assert property ( @( posedge iCLK_FC_CORE )
    FEB_BRG_EOP |=> ~FEB_BRG_SOP ##1 ~FEB_BRG_SOP );

assert_inter_frame_gap_eop_valid: assert property ( @( posedge iCLK_FC_CORE )
    FEB_BRG_EOP |=> ~FEB_BRG_DVAL ##1 ~FEB_BRG_DVAL );


// synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:("." "../doc" "../../link_engine/lib")
// verilog-library-extensions:(".v" ".h")
// End:
