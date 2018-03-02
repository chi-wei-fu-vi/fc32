/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: extractor_top.v$
* $Author: honda.yang $
* $Date: 2013-11-26 14:14:27 -0800 (Tue, 26 Nov 2013) $
* $Revision: 4009 $
* Description: Top level Extractor module
*
***************************************************************************/

module extractor_top
(
  //////////////////////////////////////////////////////////////////////
  // Reset & Clocks
  //////////////////////////////////////////////////////////////////////
  input                                       iRST_n,
  input                                       iCORE_CLK,

  //////////////////////////////////////////////////////////////////////
  // Global
  //////////////////////////////////////////////////////////////////////
  input                                       iCHANNEL_ID,
  input                                       iEXT_MODE,
  input                                       iPKG_MODE,

  //////////////////////////////////////////////////////////////////////
  // MM I/F
  //////////////////////////////////////////////////////////////////////
  input        [63:0]                         iMM_WR_DATA,
  input        [13:0]                         iMM_ADDR,
  input                                       iMM_WR_EN,
  input                                       iMM_RD_EN,
  output       [63:0]                         oMM_RD_DATA,
  output                                      oMM_RD_DATA_V,

  //////////////////////////////////////////////////////////////////////
  // MTIP_IF/FCoE I/F
  //////////////////////////////////////////////////////////////////////
  output                                      oEXTR_FC_TS_FIFO_POP,
  output                                      oEXTR_REG_EXTRENABLE,
  input        [63:0]                         iFC_EXTR_DATA,
  input        [2:0]                          iFC_EXTR_EMPTY,
  input                                       iFC_EXTR_SOP,
  input                                       iFC_EXTR_EOP,
  input                                       iFC_EXTR_ERR,
  input                                       iFC_EXTR_VALID,
  input        [2:0]                          iFC_EXTR_INDEX, 
  input        [107:0]                        iFC_EXTR_FUTURE_TS,
  input                                       iFC_EXTR_EXTRENABLE,
  
  //////////////////////////////////////////////////////////////////////
  // Time Arbiter I/F
  //////////////////////////////////////////////////////////////////////
  output       [127:0]                        oEXTR_DAT_DAL_DATA,
  output       [55:0]                         oEXTR_DAT_GOOD_TS,
  output                                      oEXTR_DAT_GTS_VALID,
  input                                       iTA_DAT_DAL_READ,

  //////////////////////////////////////////////////////////////////////
  // Interval Stats I/F
  //////////////////////////////////////////////////////////////////////
  output       [31:0]                         oINT_STATS_FRAME_DROP,
  input                                       iINT_STATS_LATCH_CLR,

  //////////////////////////////////////////////////////////////////////
  // Link Registers
  //////////////////////////////////////////////////////////////////////
  output                                      oCHF_DROPPING

  );

///////////////////////////////////////////////////////////////////////////////
// Auto Declaration
///////////////////////////////////////////////////////////////////////////////
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic			CHF_DATCHNL_FIFO_AFULL;	// From u_channel_fifo of channel_fifo.v
logic			DATAFRAMEBPCTR_EN;	// From u_channel_fifo of channel_fifo.v
logic [9:0]		DATCHNLFIFOLEVEL_RD;	// From u_channel_fifo of channel_fifo.v
wire			DATCHNLFIFOLEVEL_RD_EN;	// From u_extractor_regs of extractor_regs.v
logic			DATCHNLFIFOLEVEL_V;	// From u_channel_fifo of channel_fifo.v
wire [9:0]		DATCHNLFIFOLEVEL_WR;	// From u_extractor_regs of extractor_regs.v
wire			DATCHNLFIFOLEVEL_WR_EN;	// From u_extractor_regs of extractor_regs.v
logic			DATCHNLFIFOSTAT_OVERFLOW;// From u_channel_fifo of channel_fifo.v
logic			DATCHNLFIFOSTAT_UNDERFLOW;// From u_channel_fifo of channel_fifo.v
logic [9:0]		DATCHNLFIFOSTAT_WORDS;	// From u_channel_fifo of channel_fifo.v
logic [63:0]		FMEX_FMPG_DATA;		// From u_frame_extract of frame_extract.v
logic			FMEX_FMPG_EOP;		// From u_frame_extract of frame_extract.v
logic			FMEX_FMPG_ERR;		// From u_frame_extract of frame_extract.v
logic [13:0]		FMEX_FMPG_LENGTH;	// From u_frame_extract of frame_extract.v
logic			FMEX_FMPG_SOP;		// From u_frame_extract of frame_extract.v
logic			FMEX_FMPG_VALID;	// From u_frame_extract of frame_extract.v
logic			FMEX_FMPG_ZERO;		// From u_frame_extract of frame_extract.v
logic [127:0]		FMPG_CHF_DATA;		// From u_frame_packager of frame_packager.v
logic			FMPG_CHF_EOP;		// From u_frame_packager of frame_packager.v
logic			FMPG_CHF_SOP;		// From u_frame_packager of frame_packager.v
logic			FMPG_CHF_VALID;		// From u_frame_packager of frame_packager.v
wire [7:0]		TEMPLATERAM_ADDR;	// From u_extractor_regs of extractor_regs.v
logic [63:0]		TEMPLATERAM_RD;		// From u_frame_extract of frame_extract.v
wire			TEMPLATERAM_RD_EN;	// From u_extractor_regs of extractor_regs.v
logic			TEMPLATERAM_V;		// From u_frame_extract of frame_extract.v
wire [63:0]		TEMPLATERAM_WR;		// From u_extractor_regs of extractor_regs.v
wire			TEMPLATERAM_WR_EN;	// From u_extractor_regs of extractor_regs.v
logic			TEMPLSTOP_INIT;		// From u_frame_extract of frame_extract.v
logic			TEMPLSTOP_OFSTORDER;	// From u_frame_extract of frame_extract.v
logic			TEMPLSTOP_OVERFLOW;	// From u_frame_extract of frame_extract.v
logic			TEMPLSTOP_ZEROBYTE;	// From u_frame_extract of frame_extract.v
wire [63:0]		_SCRATCH;		// From u_extractor_regs of extractor_regs.v
// End of automatics

///////////////////////////////////////////////////////////////////////////////
// Frame Extractor Instantiation
///////////////////////////////////////////////////////////////////////////////
/* frame_extract AUTO_TEMPLATE (
    .clk                ( iCORE_CLK             ),
    .rst_n              ( iRST_n                ),
    .oFMEX_FMPG_\(.*\)  ( FMEX_FMPG_\1[]        ),
    .iREG_LINKCTRL\(.*\)( iREG_LINKCTRL\1[]     ),
    .iREG_\(.*\)        ( \1[]                  ),
    .oFMEX_REG_\(.*\)   ( \1[]                  ),
   );
*/

frame_extract u_frame_extract (
    /*AUTOINST*/
			       // Outputs
			       .oFMEX_FMPG_DATA	( FMEX_FMPG_DATA[63:0]        ), // Templated
			       .oFMEX_FMPG_SOP	( FMEX_FMPG_SOP        ), // Templated
			       .oFMEX_FMPG_EOP	( FMEX_FMPG_EOP        ), // Templated
			       .oFMEX_FMPG_ERR	( FMEX_FMPG_ERR        ), // Templated
			       .oFMEX_FMPG_VALID( FMEX_FMPG_VALID        ), // Templated
			       .oFMEX_FMPG_ZERO	( FMEX_FMPG_ZERO        ), // Templated
			       .oFMEX_FMPG_LENGTH( FMEX_FMPG_LENGTH[13:0]        ), // Templated
			       .oFMEX_REG_TEMPLATERAM_RD( TEMPLATERAM_RD[63:0]                  ), // Templated
			       .oFMEX_REG_TEMPLATERAM_V( TEMPLATERAM_V                  ), // Templated
			       .oFMEX_REG_TEMPLSTOP_ZEROBYTE( TEMPLSTOP_ZEROBYTE                  ), // Templated
			       .oFMEX_REG_TEMPLSTOP_OFSTORDER( TEMPLSTOP_OFSTORDER                  ), // Templated
			       .oFMEX_REG_TEMPLSTOP_OVERFLOW( TEMPLSTOP_OVERFLOW                  ), // Templated
			       .oFMEX_REG_TEMPLSTOP_INIT( TEMPLSTOP_INIT                  ), // Templated
			       // Inputs
			       .clk		( iCORE_CLK             ), // Templated
			       .rst_n		( iRST_n                ), // Templated
			       .iFC8_MODE	(iEXT_MODE),
			       .iFC_EXTR_DATA	(iFC_EXTR_DATA[63:0]),
			       .iFC_EXTR_EMPTY	(iFC_EXTR_EMPTY[2:0]),
			       .iFC_EXTR_SOP	(iFC_EXTR_SOP),
			       .iFC_EXTR_EOP	(iFC_EXTR_EOP),
			       .iFC_EXTR_ERR	(iFC_EXTR_ERR),
			       .iFC_EXTR_VALID	(iFC_EXTR_VALID),
			       .iFC_EXTR_INDEX	(iFC_EXTR_INDEX[2:0]),
			       .iFC_EXTR_EXTRENABLE(iFC_EXTR_EXTRENABLE),
			       .iREG_TEMPLATERAM_ADDR( TEMPLATERAM_ADDR[7:0]                  ), // Templated
			       .iREG_TEMPLATERAM_WR( TEMPLATERAM_WR[63:0]                  ), // Templated
			       .iREG_TEMPLATERAM_WR_EN( TEMPLATERAM_WR_EN                  ), // Templated
			       .iREG_TEMPLATERAM_RD_EN( TEMPLATERAM_RD_EN                  )); // Templated

///////////////////////////////////////////////////////////////////////////////
// Frame Packager Instantiation
///////////////////////////////////////////////////////////////////////////////
/* frame_packager AUTO_TEMPLATE (
    .clk                ( iCORE_CLK             ),
    .rst_n              ( iRST_n                ),
    .oFMPG_CHF_\(.*\)   ( FMPG_CHF_\1[]         ),
    .iFMEX_FMPG_\(.*\)  ( FMEX_FMPG_\1[]        ),
    .iCHF_\(.*\)        ( CHF_\1[]              ),
   );
*/

frame_packager u_frame_packager (
    /*AUTOINST*/
				 // Outputs
				 .oFMPG_CHF_DATA	( FMPG_CHF_DATA[127:0]         ), // Templated
				 .oFMPG_CHF_SOP		( FMPG_CHF_SOP         ), // Templated
				 .oFMPG_CHF_EOP		( FMPG_CHF_EOP         ), // Templated
				 .oFMPG_CHF_VALID	( FMPG_CHF_VALID         ), // Templated
				 .oEXTR_FC_TS_FIFO_POP	(oEXTR_FC_TS_FIFO_POP),
				 // Inputs
				 .clk			( iCORE_CLK             ), // Templated
				 .rst_n			( iRST_n                ), // Templated
				 .iFC8_MODE		(iPKG_MODE),
				 .iCHANNEL_ID		(iCHANNEL_ID),
				 .iFC_EXTR_FUTURE_TS	(iFC_EXTR_FUTURE_TS[107:0]),
				 .iFMEX_FMPG_DATA	( FMEX_FMPG_DATA[63:0]        ), // Templated
				 .iFMEX_FMPG_SOP	( FMEX_FMPG_SOP        ), // Templated
				 .iFMEX_FMPG_EOP	( FMEX_FMPG_EOP        ), // Templated
				 .iFMEX_FMPG_ERR	( FMEX_FMPG_ERR        ), // Templated
				 .iFMEX_FMPG_VALID	( FMEX_FMPG_VALID        ), // Templated
				 .iFMEX_FMPG_ZERO	( FMEX_FMPG_ZERO        ), // Templated
				 .iFMEX_FMPG_LENGTH	( FMEX_FMPG_LENGTH[13:0]        ), // Templated
				 .iCHF_DATCHNL_FIFO_AFULL( CHF_DATCHNL_FIFO_AFULL              )); // Templated

///////////////////////////////////////////////////////////////////////////////
// Channel FIFO Instantiation
///////////////////////////////////////////////////////////////////////////////
/* channel_fifo AUTO_TEMPLATE (
    .clk                ( iCORE_CLK             ),
    .rst_n              ( iRST_n                ),
    .iFMPG_CHF_\(.*\)   ( FMPG_CHF_\1[]         ),
    .oCHF_REG_\(.*\)    ( \1[]                  ),
    .oCHF_DAT\(.*\)     ( CHF_DAT\1[]           ),
    .iREG_\(.*\)        ( \1[]                  ),
   );
*/

channel_fifo u_channel_fifo (
    /*AUTOINST*/
			     // Outputs
			     .oEXTR_DAT_DAL_DATA(oEXTR_DAT_DAL_DATA[127:0]),
			     .oEXTR_DAT_GTS_VALID(oEXTR_DAT_GTS_VALID),
			     .oEXTR_DAT_GOOD_TS	(oEXTR_DAT_GOOD_TS[55:0]),
			     .oCHF_DATCHNL_FIFO_AFULL( CHF_DATCHNL_FIFO_AFULL           ), // Templated
			     .oINT_STATS_FRAME_DROP(oINT_STATS_FRAME_DROP[31:0]),
			     .oCHF_REG_DATAFRAMEBPCTR_EN( DATAFRAMEBPCTR_EN                  ), // Templated
			     .oCHF_REG_DATCHNLFIFOSTAT_UNDERFLOW( DATCHNLFIFOSTAT_UNDERFLOW                  ), // Templated
			     .oCHF_REG_DATCHNLFIFOSTAT_OVERFLOW( DATCHNLFIFOSTAT_OVERFLOW                  ), // Templated
			     .oCHF_REG_DATCHNLFIFOSTAT_WORDS( DATCHNLFIFOSTAT_WORDS[9:0]                  ), // Templated
			     .oCHF_REG_DATCHNLFIFOLEVEL_V( DATCHNLFIFOLEVEL_V                  ), // Templated
			     .oCHF_REG_DATCHNLFIFOLEVEL_RD( DATCHNLFIFOLEVEL_RD[9:0]                  ), // Templated
			     .oCHF_DROPPING	(oCHF_DROPPING),
			     // Inputs
			     .clk		( iCORE_CLK             ), // Templated
			     .rst_n		( iRST_n                ), // Templated
			     .iFMPG_CHF_DATA	( FMPG_CHF_DATA[127:0]         ), // Templated
			     .iFMPG_CHF_SOP	( FMPG_CHF_SOP         ), // Templated
			     .iFMPG_CHF_VALID	( FMPG_CHF_VALID         ), // Templated
			     .iTA_DAT_DAL_READ	(iTA_DAT_DAL_READ),
			     .iINT_STATS_LATCH_CLR(iINT_STATS_LATCH_CLR),
			     .iREG_DATCHNLFIFOLEVEL_WR( DATCHNLFIFOLEVEL_WR[9:0]                  ), // Templated
			     .iREG_DATCHNLFIFOLEVEL_WR_EN( DATCHNLFIFOLEVEL_WR_EN                  ), // Templated
			     .iREG_DATCHNLFIFOLEVEL_RD_EN( DATCHNLFIFOLEVEL_RD_EN                  )); // Templated

///////////////////////////////////////////////////////////////////////////////
// Extractor Registers Instantiation
///////////////////////////////////////////////////////////////////////////////
/* extractor_regs AUTO_TEMPLATE (
    .clk                ( iCORE_CLK             ),
    .rst_n              ( iRST_n                ),
    .wr_data            ( iMM_WR_DATA           ),
    .addr               ( iMM_ADDR[9:0]         ),
    .wr_en              ( iMM_WR_EN             ),
    .rd_en              ( iMM_RD_EN             ),
    .rd_data            ( oMM_RD_DATA           ),
    .rd_data_v          ( oMM_RD_DATA_V         ),
    .iREG_\(.*\)        ( \1[]                  ),
    .oREG_EXTRENABLE    ( oEXTR_REG_EXTRENABLE  ),
    .oREG_\(.*\)        ( \1[]                  ),
   );
*/

extractor_regs u_extractor_regs (
    /*AUTOINST*/
				 // Outputs
				 .rd_data		( oMM_RD_DATA           ), // Templated
				 .rd_data_v		( oMM_RD_DATA_V         ), // Templated
				 .oREG__SCRATCH		( _SCRATCH[63:0]                  ), // Templated
				 .oREG_EXTRENABLE	( oEXTR_REG_EXTRENABLE  ), // Templated
				 .oREG_DATCHNLFIFOLEVEL_WR( DATCHNLFIFOLEVEL_WR[9:0]                  ), // Templated
				 .oREG_DATCHNLFIFOLEVEL_WR_EN( DATCHNLFIFOLEVEL_WR_EN                  ), // Templated
				 .oREG_DATCHNLFIFOLEVEL_RD_EN( DATCHNLFIFOLEVEL_RD_EN                  ), // Templated
				 .oREG_TEMPLATERAM_ADDR	( TEMPLATERAM_ADDR[7:0]                  ), // Templated
				 .oREG_TEMPLATERAM_WR	( TEMPLATERAM_WR[63:0]                  ), // Templated
				 .oREG_TEMPLATERAM_WR_EN( TEMPLATERAM_WR_EN                  ), // Templated
				 .oREG_TEMPLATERAM_RD_EN( TEMPLATERAM_RD_EN                  ), // Templated
				 // Inputs
				 .clk			( iCORE_CLK             ), // Templated
				 .rst_n			( iRST_n                ), // Templated
				 .wr_en			( iMM_WR_EN             ), // Templated
				 .rd_en			( iMM_RD_EN             ), // Templated
				 .addr			( iMM_ADDR[9:0]         ), // Templated
				 .wr_data		( iMM_WR_DATA           ), // Templated
				 .iREG_DATAFRAMEBPCTR_EN( DATAFRAMEBPCTR_EN                  ), // Templated
				 .iREG_DATCHNLFIFOSTAT_UNDERFLOW( DATCHNLFIFOSTAT_UNDERFLOW                  ), // Templated
				 .iREG_DATCHNLFIFOSTAT_OVERFLOW( DATCHNLFIFOSTAT_OVERFLOW                  ), // Templated
				 .iREG_DATCHNLFIFOSTAT_WORDS( DATCHNLFIFOSTAT_WORDS[9:0]                  ), // Templated
				 .iREG_DATCHNLFIFOLEVEL_V( DATCHNLFIFOLEVEL_V                  ), // Templated
				 .iREG_DATCHNLFIFOLEVEL_RD( DATCHNLFIFOLEVEL_RD[9:0]                  ), // Templated
				 .iREG_TEMPLSTOP_INIT	( TEMPLSTOP_INIT                  ), // Templated
				 .iREG_TEMPLSTOP_OVERFLOW( TEMPLSTOP_OVERFLOW                  ), // Templated
				 .iREG_TEMPLSTOP_OFSTORDER( TEMPLSTOP_OFSTORDER                  ), // Templated
				 .iREG_TEMPLSTOP_ZEROBYTE( TEMPLSTOP_ZEROBYTE                  ), // Templated
				 .iREG_TEMPLATERAM_V	( TEMPLATERAM_V                  ), // Templated
				 .iREG_TEMPLATERAM_RD	( TEMPLATERAM_RD[63:0]                  )); // Templated

endmodule

// Local Variables:
// verilog-library-directories:("." "../doc")
// verilog-library-extensions:(".v" ".h")
// End:
