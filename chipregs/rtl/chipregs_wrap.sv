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
* Contains the timestamp counter and a MM I/F to miscellaneous register such as
* revision, capabilities, etc...
*
* Upper level dependencies:  top-level
* Lower level dependencies:  gbl_timer
*
* Revision History Notes:
* 2013/02/21 Tim - initial release
*
*
***************************************************************************/

`timescale 1 ns / 100 ps

module chipregs_wrap
#(
 parameter pLITE            = 1'd0,
 parameter pBISTTX32B       = 1'd0,
 parameter pBISTPRBSXCVR    = 1'd0,
 parameter pBISTPCIE1       = 1'd0,
 parameter pBISTPCIE0       = 1'd0,
 parameter pXBAR            = 1'd0,
 parameter pXCVRSPEEDMAX    = 12'd0,
 parameter pNUMPCIELANES    = 8'd0,
 parameter pPCIEGENMAX      = 4'd0,
 parameter pNUMPCIEEP       = 4'd0,
 parameter pNUMXCVR         = 8'd0,
 parameter pPROTOCOL        = 4'd0,
 parameter pNUMLINKENGINES  = 4'd0,
 parameter pNUMDPLBUF       = 4'd0,

//FPGA device register
 parameter pFVENDOR = 16'h0a17,
 parameter pFFAMILY = 8'hA5,
 parameter pFPACKAGE = 24'hA70F40,
 parameter pFSPEEDGRADE = 8'h02 ,
 parameter pFSERDESGRADE = 8'h02 ,

//BALI ISL global timestamp reset
 parameter pGBLTIMESTAMPRST = 1'b0

)
(

  input 	iRST_100M_n,
  input 	iCLK_100M,
  
  input 	iRST_PCIE_REF_n,
  input 	iCLK_PCIE_REF,
  
  input 	iRST_FC_CORE_n,
  input 	iCLK_FC_CORE,

  input [23:0] 	iSFP_LOS,
  output [23:0] sfp_los_qual,

  output        ioCRC_ERROR,

 //////////////////////////////////////////////////////////////////////
 // External IO to debug register
 //////////////////////////////////////////////////////////////////////

  input 	iFPGA_RSTN,
  input 	iFPGA_CLRN,
  input 	iBUS_CLK, 
  input 	iBUS_EN, 
  input 	iBUS_MASTER, 
  input 	iBUS_RST, 
  input [1:0] 	ioBUS_SPARE, 
  input [7:0] 	ioFPGA_DATA, 
  input 	ioEXT1, 
  input 	ioEXT2, 
  input 	ioEXT3, 
  input 	ioEXT4, 
  input [11:0] 	oFC_RATE_SEL,
  input [1:0] 	iBD_NO,
  input [3:0] 	iASY, 
  input 	iFPGA_ID_N,
  input [15:0] 	oLED_N, 
  input 	iRXD,
  input 	oTXD,
  input 	ioOPT_1, 
  input 	ioOPT_2, 
  input 	ioOPT_3,
  input 	ioOPT_4,
  input 	ioOPT_5,
  input 	ioOPT_6,
  input 	ioOPT_7,
  input 	ioOPT_8,
  input 	ioOPT_ROT_1, 
  input 	ioOPT_ROT_2,
  input 	ioOPT_ROT_4,
  input 	ioOPT_ROT_3,

  //////////////////////////////////////////////////////////////////////
  // MM Register I/F
  //////////////////////////////////////////////////////////////////////
  input [63:0] 	iMM_WR_DATA,
  input [9:0] 	iMM_ADDRESS,
  input 	iMM_WR_EN,
  input 	iMM_RD_EN,
  output [63:0] oMM_RD_DATA,
  output 	oMM_RD_DATA_V,
  
  input 	iFPGA_RIGHT_LEFT_N,
//  input         iFPGA_DAL_TOP_BTM_N,
  input [3:0] 	iPCBREV,

  input 	iRCFG_TIMEOUT,
  input 	iRCFG_BUSY,
  input [3:0] 	iRCFG_ERROR,
  input [7:0] 	iREG_PCIE_AUTORESET_CNT,
  input [31:0] 	iREG_MIN_LINKSPEED_RECONFIG,
  input [31:0] 	iREG_MAX_LINKSPEED_RECONFIG,
  output 	oRCFG_RETRY,
  output 	oRCFG_DIRECT,
  output [3:0] 	oREG_LOOPBACKSERDESCFG_PRODUCT,
  output [3:0] 	oREG_LOOPBACKSERDESCFG_REV,
  output [3:0] 	oREG_LOOPBACKSERDESCFG_MODE,
  output 	oREG_FPGA_CTL_LED_OUTPUT_DISABLE,
  output 	oREG_FPGA_CTL_LOGIC_ANALYZER_INF_DISABLE,
  output 	oREG_FPGA_CTL_RX_SERDES_DISABLE,
  output 	oREG_FPGA_CTL_TX_SERDES_DISABLE,
  output 	oREG_FPGA_CTL_PCIE_AUTORESET_DISABLE,
  output 	oREG_FPGA_CTL_FORCE_RXDATA_ON_LOSSIG_DISABLE,
  output [63:0] fpga_rev,
		
		input   iRST_GLB_TIMESTAMP_FR,
		input   iRST_GLB_TIMESTAMP_FC,
		input   iRST_GLB_TIMESTAMP_PCIE,

  output [55:0] oGLOBAL_TIMESTAMP, 
  output 	oEND_OF_INTERVAL
);

   logic [55:0] timestamp;
   logic [55:0] reg_rd_timestamp;
   logic        end_of_interval;
   logic [39:0] interval_period;
   logic [3:0] 	RCFG_ERROR_SYNC;
   logic 	RCFG_BUSY_SYNC;
   logic 	RCFG_TIMEOUT_SYNC;
   logic [3:0] 	loopbackserdescfg_product_int;
   logic [23:0] oREG_SFP_LOSIG_FORCE_EN;
   logic [23:0] oREG_SFP_LOSIG_FORCE_VALUE;
   logic 	daltopbtm;
   logic 	invlperiod_wr_100m_r, invlperiod_wr_100m_d1_r, invlperiod_wr_pcie;
   logic [39:0] invlperiod_wr_data_r, REG_STATSINTERVAL_CLOCKS;
   logic [67:0] crc_error_emr;
   logic 	crc_error_event;
   
   
///////////////////////////////////////////////////////////////////////////////
//
// Assign Outputs
//
///////////////////////////////////////////////////////////////////////////////
assign oGLOBAL_TIMESTAMP = timestamp;
assign oEND_OF_INTERVAL  = end_of_interval;



///////////////////////////////////////////////////////////////////////////////
//
// Instances
//
///////////////////////////////////////////////////////////////////////////////
generate 
if (pGBLTIMESTAMPRST) begin : gbl_timer_w_glb_rst
gbl_timer gbl_timer_inst
(
  // Link Engine
  .oGLOBAL_TIMESTAMP         (timestamp),
  .oEND_OF_INTERVAL          (end_of_interval),

  .oREG_RD_TIMESTAMP         (reg_rd_timestamp),
  
  // Global
  .iRST_100M_n               (iRST_100M_n),
  .iCLK_100M                 (iCLK_100M),
  .iRST_PCIE_REF_n           (iRST_PCIE_REF_n),
  .iCLK_PCIE_REF             (iCLK_PCIE_REF),
  .iRST_FC_CORE_n            (iRST_FC_CORE_n),
  .iCLK_FC_CORE              (iCLK_FC_CORE),
	.iRST_GLB_TIMESTAMP_FR     (iRST_GLB_TIMESTAMP_FR),
	.iRST_GLB_TIMESTAMP_FC     (iRST_GLB_TIMESTAMP_FC),
	.iRST_GLB_TIMESTAMP_PCIE   (iRST_GLB_TIMESTAMP_PCIE),

  // Register
  .iREG_STATSINTERVAL_ENABLE (1'b1),
  .iREG_STATSINTERVAL_CLOCKS (REG_STATSINTERVAL_CLOCKS)
);
end : gbl_timer_w_glb_rst
else begin : gbl_timer_no_glb_rst
gbl_timer gbl_timer_inst
(
  // Link Engine
  .oGLOBAL_TIMESTAMP         (timestamp),
  .oEND_OF_INTERVAL          (end_of_interval),

  .oREG_RD_TIMESTAMP         (reg_rd_timestamp),

  // Global
  .iRST_100M_n               (iRST_100M_n),
  .iCLK_100M                 (iCLK_100M),
  .iRST_PCIE_REF_n           (iRST_PCIE_REF_n),
  .iCLK_PCIE_REF             (iCLK_PCIE_REF),
  .iRST_FC_CORE_n            (iRST_FC_CORE_n),
  .iCLK_FC_CORE              (iCLK_FC_CORE),
  .iRST_GLB_TIMESTAMP_FR     (1'b0),
  .iRST_GLB_TIMESTAMP_FC     (1'b0),
  .iRST_GLB_TIMESTAMP_PCIE   (1'b0),

  // Register
  .iREG_STATSINTERVAL_ENABLE (1'b1),
  .iREG_STATSINTERVAL_CLOCKS (REG_STATSINTERVAL_CLOCKS)
);
end : gbl_timer_no_glb_rst
endgenerate



//use a ROM to store revision (see fpga_rev_rom.mif)

fpga_rev_rom  fpga_rev_rom_inst

(

   .a       (5'd0),

   .clk     (iCLK_100M),

   .qspo    (fpga_rev)

);  




///////////////////////////////////////////////////////////////////////////////
//
// Registers
//
///////////////////////////////////////////////////////////////////////////////

   vi_sync_1c #(4,1) rcfg_error_sync
     (// Outputs
      .out                              (RCFG_ERROR_SYNC[3:0]),
      // Inputs
      .clk_dst                          (iCLK_100M),
      .rst_n_dst                        (iRST_100M_n),
      .in                               (iRCFG_ERROR[3:0])
       );      

   vi_sync_1c #(1,1) rcfg_busy_sync
     (// Outputs
      .out                              (RCFG_BUSY_SYNC),
      // Inputs
      .clk_dst                          (iCLK_100M),
      .rst_n_dst                        (iRST_100M_n),
      .in                               (iRCFG_BUSY)
       );      

   vi_sync_1c #(1,1) rcfg_timeout_sync
     (// Outputs
      .out                              (RCFG_TIMEOUT_SYNC),
      // Inputs
      .clk_dst                          (iCLK_100M),
      .rst_n_dst                        (iRST_100M_n),
      .in                               (iRCFG_TIMEOUT)
       );      

   // FIXME : workaround requested by Duane for Bali.  iBD_NO[0] needs to be tied off in Bali because it is not connected.  
   //         In dominica, it is connected to a jumpter to indicate top/bottom DAL board.  NUMXCVR is being used as a proxy for 
   //         dominca.  Would be better to have an explicit indicator.
   
   assign daltopbtm = (pNUMXCVR>=24) ? iBD_NO[0] : 1'b0;

chipregs chipregs_inst
(
  .clk       (iCLK_100M),
  .rst_n     (iRST_100M_n),
  .wr_en     (iMM_WR_EN),
  .rd_en     (iMM_RD_EN),
  .addr      (iMM_ADDRESS),
  .wr_data   (iMM_WR_DATA),
  .rd_data   (oMM_RD_DATA),
  .rd_data_v (oMM_RD_DATA_V),
  
  .oREG__SCRATCH                      (), 
  .oREG_LOOPBACKSERDESCFG_PRODUCT     (loopbackserdescfg_product_int[3:0]),
  .oREG_LOOPBACKSERDESCFG_REV         (oREG_LOOPBACKSERDESCFG_REV),
  .oREG_LOOPBACKSERDESCFG_MODE        (oREG_LOOPBACKSERDESCFG_MODE),
  .iREG_FPGACAP_FPGARIGHTLEFT_N       (iFPGA_RIGHT_LEFT_N),
  .iREG_FPGACAP_DALIDRESERVED	      (3'd0),
  .iREG_FPGACAP_DALTOPBTM             (daltopbtm),
  .iREG_FPGACAP_BISTTX32B             (pBISTTX32B),
  .iREG_FPGACAP_BISTPRBSXCVR          (pBISTPRBSXCVR),
  .iREG_FPGACAP_BISTPCIE1             (pBISTPCIE1),
  .iREG_FPGACAP_BISTPCIE0             (pBISTPCIE0),
  .iREG_FPGACAP_XBAR                  (pXBAR),
  .iREG_FPGACAP_XCVRSPEEDMAX          (pXCVRSPEEDMAX),
  .iREG_FPGACAP_NUMPCIELANESMAX       (pNUMPCIELANES),
  .iREG_FPGACAP_PCIEGENMAX            (pPCIEGENMAX),
  .iREG_FPGACAP_NUMPCIEEP             (pNUMPCIEEP),
  .iREG_FPGACAP_NUMXCVR               (pNUMXCVR),
  .iREG_FPGACAP_PROTOCOL              (pPROTOCOL),
  .iREG_FPGACAP_NUMLINKENGINES        (pNUMLINKENGINES),
  .iREG_FPGACAP_NUMDPLBUF             (pNUMDPLBUF),
  .iREG_FPGACAP_LITE                  (pLITE),
  .iREG_FPGADEV_VENDOR                (pFVENDOR),
  .iREG_FPGADEV_FAMILY                (pFFAMILY),
  .iREG_FPGADEV_PACKAGE               (pFPACKAGE),
  .iREG_FPGADEV_SPEEDGRADE            (pFSPEEDGRADE),
	.iREG_FPGADEV_SERDESGRADE           (pFSERDESGRADE),
  
  .iREG_FPGAREV_YYMMDD                (fpga_rev[63:40]),
  .iREG_FPGAREV_REPOREV               (fpga_rev[39:16]),
  .iREG_FPGAREV_AUTHOR                (fpga_rev[15:8]),  
  .iREG_FPGAREV_BITFILEREV            (fpga_rev[7:0]),
  .iREG_PCBREV                        (iPCBREV),
  .oREG_RECONFIGCTRL_RETRY            (oRCFG_RETRY),
  .oREG_RECONFIGCTRL_DIRECT           (oRCFG_DIRECT),
  .iREG_RECONFIGSTATUS_TIMEOUT        (RCFG_TIMEOUT_SYNC),
  .iREG_RECONFIGSTATUS_BUSY           (RCFG_BUSY_SYNC),
  .iREG_RECONFIGSTATUS_ERROR          (RCFG_ERROR_SYNC[3:0]), 
  .iREG_TIMESTAMP                     (reg_rd_timestamp),
  .oREG_INTERVALPERIOD                (interval_period),
 // Inputs ExtIO
 .iREG_EXTIODEBUG_IOOPT_ROT_2           (ioOPT_ROT_2),
 .iREG_EXTIODEBUG_IOOPT_ROT_1           (ioOPT_ROT_1),
 .iREG_EXTIODEBUG_IOOPT_6               (ioOPT_6),
 .iREG_EXTIODEBUG_IOOPT_5               (ioOPT_5),
 .iREG_EXTIODEBUG_IOOPT_4               (ioOPT_4),
 .iREG_EXTIODEBUG_IOOPT_3               (ioOPT_3),
 .iREG_EXTIODEBUG_IOOPT_2               (ioOPT_2),
 .iREG_EXTIODEBUG_IOOPT_1               (ioOPT_1),
 .iREG_EXTIODEBUG_OFC_RATE_SEL          (oFC_RATE_SEL[11:0]),
 .iREG_EXTIODEBUG_IOEXT4                (ioEXT4),
 .iREG_EXTIODEBUG_IOEXT3                (ioEXT3),
 .iREG_EXTIODEBUG_IOEXT2                (ioEXT2),
 .iREG_EXTIODEBUG_IOEXT1                (ioEXT1),
 .iREG_EXTIODEBUG_IBD_NO		(iBD_NO[1:0]),
 .iREG_EXTIODEBUG_IOFPGA_DATA           (ioFPGA_DATA[7:0]),
 .iREG_EXTIODEBUG_IOBUS_SPARE           (ioBUS_SPARE[1:0]),
 .iREG_EXTIODEBUG_IBUS_MASTER           (iBUS_MASTER),
 .iREG_EXTIODEBUG_IBUS_EN               (iBUS_EN),
 .iREG_EXTIODEBUG_IBUS_CLK              (iBUS_CLK),
 .iREG_EXTIODEBUG_IFPGA_CLRN            (iFPGA_CLRN),
 .iREG_EXTIODEBUG_IFPGA_RSTN            (iFPGA_RSTN),
 .iREG_EXTIODEBUG_OTXD                  (oTXD),
 .iREG_EXTIODEBUG_IRXD                  (iRXD),
 .iREG_EXTIODEBUG_OLED_N                (oLED_N[15:0]),
 .iREG_EXTIODEBUG_IFPGA_ID_N            (iFPGA_ID_N),
 .iREG_EXTIODEBUG_IASY                  (iASY[3:0]),
 .iREG_ISFP_LOSIG			(iSFP_LOS[23:0]),
 .iREG_CRC_ERROR_CNT_EN			(crc_error_event),
 .iREG_CRC_ERROR_MESSAGE_REGISTER0	(crc_error_emr[63:0]),
 .iREG_CRC_ERROR_MESSAGE_REGISTER1	({60'd0,crc_error_emr[67:64]}),
 /*AUTOINST*/
 // Outputs
 .oREG_SFP_LOSIG_FORCE_EN		(oREG_SFP_LOSIG_FORCE_EN[23:0]),
 .oREG_SFP_LOSIG_FORCE_VALUE		(oREG_SFP_LOSIG_FORCE_VALUE[23:0]),
 .oREG_FPGA_CTL_FORCE_RXDATA_ON_LOSSIG_DISABLE(oREG_FPGA_CTL_FORCE_RXDATA_ON_LOSSIG_DISABLE),
 .oREG_FPGA_CTL_PCIE_AUTORESET_DISABLE	(oREG_FPGA_CTL_PCIE_AUTORESET_DISABLE),
 .oREG_FPGA_CTL_LED_OUTPUT_DISABLE	(oREG_FPGA_CTL_LED_OUTPUT_DISABLE),
 .oREG_FPGA_CTL_LOGIC_ANALYZER_INF_DISABLE(oREG_FPGA_CTL_LOGIC_ANALYZER_INF_DISABLE),
 .oREG_FPGA_CTL_RX_SERDES_DISABLE	(oREG_FPGA_CTL_RX_SERDES_DISABLE),
 .oREG_FPGA_CTL_TX_SERDES_DISABLE	(oREG_FPGA_CTL_TX_SERDES_DISABLE),
 // Inputs
 .iREG_PCIE_AUTORESET_CNT		(iREG_PCIE_AUTORESET_CNT[7:0]),
 .iREG_MIN_LINKSPEED_RECONFIG		(iREG_MIN_LINKSPEED_RECONFIG[31:0]),
 .iREG_MAX_LINKSPEED_RECONFIG		(iREG_MAX_LINKSPEED_RECONFIG[31:0]));

   generate
      if (pNUMXCVR<24) begin : gen_loopbackserdescfg_product
         assign oREG_LOOPBACKSERDESCFG_PRODUCT[3:0] = (loopbackserdescfg_product_int[3:0]==4'h0) ? 4'h1 : loopbackserdescfg_product_int[3:0];
      end
      else begin : gen_loopbackserdescfg_product
         assign oREG_LOOPBACKSERDESCFG_PRODUCT[3:0] = (loopbackserdescfg_product_int[3:0]==4'h0) ? 4'h2 : loopbackserdescfg_product_int[3:0];
      end
   endgenerate

   genvar gi;
   generate
      for (gi = 0; gi < 24; gi = gi + 1) begin : gen_sfp_losig
	 assign sfp_los_qual[gi] = oREG_SFP_LOSIG_FORCE_EN[gi] ? oREG_SFP_LOSIG_FORCE_VALUE[gi] : iSFP_LOS[gi];
      end
   endgenerate

///////////////////////////////////////////////////////////////////////////////
// Interval Period Register
///////////////////////////////////////////////////////////////////////////////
// Interval period in chipregs module is in 100M clock domain.
// The same register is replicated in PCIE clock domain for gbl_timer module.
always_ff @( posedge iCLK_100M or negedge iRST_100M_n )
    if ( ~iRST_100M_n ) begin
        invlperiod_wr_100m_r <= 1'b0;
        invlperiod_wr_100m_d1_r <= 1'b0;
    end
    else begin
        invlperiod_wr_100m_r <= (iMM_ADDRESS[9:0] == 17) & (iMM_WR_EN == 1'b1);
        invlperiod_wr_100m_d1_r <= invlperiod_wr_100m_r;
    end

always_ff @( posedge iCLK_100M )
    if ( invlperiod_wr_100m_r )
        invlperiod_wr_data_r <= iMM_WR_DATA[39:0];

vi_sync_pulse u_sync_pulse_period_wr (
    .out_pulse          ( invlperiod_wr_pcie        ),
    .clka               ( iCLK_100M                 ),
    .clkb               ( iCLK_PCIE_REF             ),
    .rsta_n             ( iRST_100M_n               ),
    .rstb_n             ( iRST_PCIE_REF_n           ),
    .in_pulse           ( invlperiod_wr_100m_d1_r   )
);

always_ff @( posedge iCLK_PCIE_REF or negedge iRST_PCIE_REF_n )
    if ( ~iRST_PCIE_REF_n )
       REG_STATSINTERVAL_CLOCKS <= 40'h5f5e100;
    else if ( invlperiod_wr_pcie )
       REG_STATSINTERVAL_CLOCKS <= invlperiod_wr_data_r;


// CRC Error

assign crc_error_event = 0;
assign crc_error_emr[67:0] = 0;
assign ioCRC_ERROR = 0;
/*
vi_stratixv_crcblock vi_stratixv_crcblock
  (// Outputs
   .crc_error_event			(crc_error_event),
   .crc_error_emr			(crc_error_emr[67:0]),
   .io_crc_error			(ioCRC_ERROR),
   // Inputs
   .clk_fr				(iCLK_100M),
   .clk					(iCLK_FC_CORE),
   .rst_fr_n				(iRST_100M_n),
   .rst_n				(iRST_FC_CORE_n));
*/

endmodule

// Local Variables:
// verilog-library-directories:("../doc" "../../../vi_lib/")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:
