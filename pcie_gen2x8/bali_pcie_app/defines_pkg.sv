/********************************CONFIDENTIAL**********************************
 * Copyright (c) 2010 Nuvation Research Corp.
 * 3590 North First St., Suite 210 San Jose, CA 95134
 * +1.408.228.5580, www.nuvation.com
 ******************************************************************************

 *  Upper level dependencies: (VI02_top)
 *  Lower level dependencies:
 *
 ******************************************************************************
 * Description: Global defines for the VI02 DAL Board FPGA
 ******************************************************************************
 *
 *
 *
 ******************************************************************************
 * Comments:
 *       Adub - December 20, 2010:
 *          :added read timout from MM bus
 *       Adub - January 08, 2011:
 *          :increased read timout for MM bus - from 16 to 24
 *       DGroen - January 16, 2011:
 *          :updated the LF_THROTTLE_CTRL defines; removed obsolete defines
 *       DGroen - January 18, 2011:
 *          :added a minimum iSTATS_INTERVAL value; updated link FIFO thresholds
 *       Adub - January 25, 2011:
 *          :added Define to include status of defines inthe upper 32 bits of FPGA_ID
 *       Adub - January 27, 2011:
 *          : ENABLE SWAPPING XCVRS
 *       DGroen - March 1, 2011:
 *          : added `define _USE_PLLGEN_50_CLK_; not to be used currently.
 *       DGroen - 05/09/2011
 *          : changed depth of LinkFF to 4k; changed threshold values and names for
 *             linkFF; added size, depth, and thresholds for channel FIFOs;
 *             changed the time-arbiter state-counter thresholds.
 *       DGroen/KCovey - 05-17-2011:
 *          : changed the link FIFO depth; changed channel FIFO depth; changed extraction
 *             mode thresholds.
 *       DGroen - 05-26-2011:
 *          : added the linkFF data-width-rd and data-width-wr defines; also the EC_READ_SIZE define.
 *       DGroen - 05-31-2011:
 *          : changed the linkFF write width to 256; a little clean-up.
 *       DGroen - 06-04-2011:
 *          : changed the depth, usedw, and thresholds in ChFF.
 *       DGroen - 07-07-2011:
 *          : removed the data generator `define
 *       DGroen - 08-04-2011:
 *          : replaced the FC data generator `define to enable it.
 *       TBeyers  04-30-2012:
 *          : removed COMPILE_PCIE_RST from build. Removes glitch showing up in Quartus.
 *       TBeyers  05-03-2012:
 *          : FPGA returns -1. Re-introducing COMPILE_PCIE_RST.
 *
 *********************************CONFIDENTIAL*********************************/
package defines_pkg;

  function integer log2;
    input [31:0] value;
    for (log2=0; value>0; log2=log2+1)
        value = value>>1;
  endfunction

  
  
  
  ///////////////////////////////////////////////////////////////////////////////
  //
  //  FPGA Capabilities Defines
  //
  ///////////////////////////////////////////////////////////////////////////////
  
  // (2012-03-27) Tim - added capabilities register and moved the above 'defines from vi02_top into this file.
  localparam NUM_DDR_IF             = 4'h0;
  localparam PROTOCOL               = 4'h1;      //1=FC,2=FCOE
  localparam NUM_TRANSCEIVERS       = 8'h16;     // decimal
  localparam NUM_PCIE_EP            = 4'h1;
  localparam PCIE_GEN               = 4'h2;
  localparam NUM_PCIE_LANES         = 8'h08;
  localparam MAX_TRANSCEIVER_SPEED = 12'h008;    // decimal
  
  
   // Enable adding the defines status to the FPGA ID - Placed Above 32 bits
  
  localparam SET_RATESELECT_FROM_REGISTER = 1;
  localparam RATE_SEL_DEF = 1'b0; //0 for < 8.5 Gbps, 1 for 8.5Gbps
  localparam _USE_CROSSBAR_SWITCH_ = 1;
  localparam _USE_MTIP_TX_DATA_GENERATOR_ = 1;
  
  
  
  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////
  
  
   // Some useful variables
  //localparam BYTE0  = 7:0;
  //localparam BYTE1 = 15:8;
  //localparam BYTE2 = 23:16;
  //localparam BYTE3 = 31:24;
  
  // Invalid register Read value
  localparam DalRdBadData  = 64'hDEAD_DEAD_DEAD_DEAD;
  
  // Read Aribiter timeouts
  localparam DalRdTimoutData   = 16'h5555;
  localparam DalRdTimoutCount  = 24;
  
  // Packet Types
  localparam EMPTY       = 0;
  localparam NORMAL      = 1;
  localparam REDUCED     = 2;
  localparam EMERGENCY   = 3;
  localparam INTERVAL    = 8'h04;
  
  // For Primitive Counter; link-status indication
  localparam LINK_UP    = 1'b1;
  localparam LINK_DOWN  = 1'b0;
  
  // Used in the packet-type of the interval frame to differentiate the two types of packets for each channel.
  localparam INT_FRM_PK1 = 1'b0;
  localparam INT_FRM_PK2 = 1'b1;
  
  // Number of valid links and channels
  localparam MAX_NUM_FC_LINKS       = 8;
  localparam MAX_NUM_FC_CHANNELS     = (MAX_NUM_FC_LINKS*2);
  
  //the following defines are used in altgx_reset_ctrl.v
  localparam DLY_RCFGBSY_TO_ARST_RELEASE = 4'hA; //this value is supposed to be at least 'two parallel clock cycles'
  
  
  //These two bits are used as input to the frame engine module from the link engine's MM i/f
  //00 = off, 01=emergency, 10=reduced, 11=normal
  localparam EXTR_MODE_OFF       = 2'b00;
  localparam EXTR_MODE_EMERGENCY = 2'b11;
  localparam EXTR_MODE_REDUCED   = 2'b10;
  localparam EXTR_MODE_NORMAL    = 2'b01;
  localparam EXTRACTION_MODE_DEF = 2'b01;
  
  //From the LinkControl register's MonitorMode bits
  //000 = off, 001=stats only, 010=emergency, 011=reduced, 100=normal
  localparam MON_MODE_ALL_OFF    = 3'b000;
  localparam MON_MODE_STATS_ONLY = 3'b001;
  localparam MON_MODE_EMERGENCY  = 3'b010;
  localparam MON_MODE_REDUCED    = 3'b011;
  localparam MON_MODE_NORMAL     = 3'b100;
  
  // for the link FIFO throttle-control
  localparam LF_DEPTH_WORDS                        = (2048);                     // depth determined in MW config and write side depth.
  localparam LF_DATA_WIDTH_WR                      = (128);
  localparam LF_DATA_WIDTH_RD                      = (128);                      // Tim (12/16/2011) - changed from 256 to 128 since elasticity buffer must match PCIE bus width
  //`define LF_BIT_WIDTH_RD                       (log2(`LF_DEPTH_WORDS)-1)  // Tim - should this be 11 or 10 for 128in:128out FIFO??
  localparam LF_BIT_WIDTH_RD                        = log2(LF_DEPTH_WORDS);
  // `define LF_BIT_WIDTH_RD_PORTSIZE              (10)      // Doug - do not change unless the RD-usedw is less than 10 // Tim - this should be 11 for 128in:128out FIFO?
  // `define LF_BIT_WIDTH_RD_PORTSIZE              (11)   // Tim (2012-01-27) - changed to 11, since 2048 elements. Modified LinkEngine as well so entire usedw port passed to ec_emulator for retrieving 4K blocks
  localparam LF_BIT_WIDTH_RD_PORTSIZE              = (12);   // Tim (2012-04-26) - changed to 12, since 2048 elements is full requires 12-bits to describe full.
  localparam LF_BIT_WIDTH_WR                        = (log2(LF_DEPTH_WORDS));    // Tim - This is 11.
  localparam LINKFF_THRES_HI                        = (LF_DEPTH_WORDS - 128);    // Tim - Write side
  localparam LINKFF_THRES_MID                       = (LF_DEPTH_WORDS - 512);    // Tim - Write side
  localparam LINKFF_THRES_LO                        = (LF_DEPTH_WORDS - 1024);   // Tim - Write side
  
  // link arbiter fifo in (link_arbiter_*.v)
  localparam ARB_FIFO_USEDW_W                      = (9);
  localparam ARB_FIFO_DEPTH                        = (512);
  
  // for the channel FIFO thresholds
  localparam CF_DEPTH_WORDS                        = (512);//from the read-side
  localparam CF_DATA_WIDTH                         = (128);//read-side
  localparam CF_NUM_CLOCKS_PER_PKT                 = (4);
  localparam CF_USEDW_WIDTH                         = (log2(CF_DEPTH_WORDS)+1);//selected the 'add 1MSB to usedw' option in MegaWizard; read-side
  localparam CHFF_THRES_HI                          = (CF_DEPTH_WORDS - 64);
  localparam CHFF_THRES_MID                         = (CF_DEPTH_WORDS - 128);
  localparam CHFF_THRES_LO                          = (CF_DEPTH_WORDS - 256);
  
  //the number of bytes read by the EC at a time (the minimum fullness level of the linkFF)
   localparam EC_READ_SIZE                         = (4096);
  
  //for the time-arbiter to determine if data is to be written to the link FIFO or not
  localparam LF_EXTR_DATA_MAX  = (LF_DEPTH_WORDS - 45);//leave headroom for two cf-pkts and one int stats
  localparam LF_INT_STATS_MAX  = (LF_DEPTH_WORDS - 33);//leave room for one int-stats pkt
  
  //for the time-arbiter, counting the number of reads from the preceding FIFOs - ch0, ch1, intstats
  localparam TA_WIDTH_OF_PKT_CNTR = 5;
  localparam [TA_WIDTH_OF_PKT_CNTR-1:0] TA_SIZEOF_CF_DATA   = 'd4;
  localparam [TA_WIDTH_OF_PKT_CNTR-1:0] TA_SIZEOF_INTSTATS  = 'd16;
  
  //the STATS_INTERVAL value should have a minimum that it can be set to; in # of 212.5 MHz clock cycles
  localparam MIN_STATS_INTERVAL_VALUE     = 50;
  
  localparam MTIP_REG_MAX_FRAME_SIZE_ADDR = 8'h0F;
  localparam MTIP_REG_CMD_CFG_ADDR        = 8'h02;
  
  // elasticity control registers
  localparam DPL_BUF_THRESH_INTERVAL_DEF           = 32'h10000;
  localparam DPL_BUF_THRESH_PANIC_STOP_DEF         = 32'h2000;
  localparam DPL_BUF_FRAMES_DROPPED_DEF            = 64'h0;
  localparam DPL_TOTAL_FRAMES_PROCESSED_DEF        = 64'h0;
  
  localparam DAL_BUF_THRESH_HIGH_DEF                = 32'h40000;
  localparam DAL_BUF_THRESH_MID_DEF                 = 32'h20000;
  localparam DAL_BUF_THRESH_LOW_DEF                 = 32'h10000;
  
  localparam DDR_FM_BUF_LEN_DEF                      = 32'h80000;
  
  // byte address width of DPL DMA address
  localparam DMA_ADDR_W            = 44;
  localparam DMA_ADDR_HI  = (DMA_ADDR_W-32);
  
  // Elasticity Buffer
  localparam REG_W = 64;      // max register width in bits
  
  // MTIP FF-RX-STAT defines - these signals are from the MTIP ref guide
  localparam MTIP_FFRXERRSTAT_FFOFLOW  = 4'h4;
  localparam MTIP_FFRXERRSTAT_CRCERR   = 4'h2;
  localparam MTIP_FFRXERRSTAT_TRUNCERR = 4'h1;
endpackage
