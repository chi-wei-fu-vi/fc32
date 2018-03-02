package reg_defines_pkg;
          /* Verilog header file generated by Excel spreadsheet */
          /* DATE:        1/13/2012 14:01 */
  
  
          // +++++++++++++++++++++++To be added in next release++++++++++++++++++++++++++++++++++
  
  localparam LinkControlShadow = 8'h24;//link-global, link-num, 8'h24
  localparam FIFOHighestUsedW  = 8'h25;//link-global, link-num, 8'h25
  localparam TA_CH0_INFO  = 8'h26;//link-global, link-num, 8'h26
  localparam TA_CH1_INFO  = 8'h27;//link-global, link-num, 8'h27
  localparam TA_INTFRM_INFO  = 8'h28;//link-global, link-num, 8'h28
  localparam LINK_EXTR_DBG = 8'h29;//link_global, link_num, 8'h29
  
  localparam FWD_DROP_STEP_CTL_OFFSET  = 8'h30;
  localparam FWD_DROP_CNT_OFFSET  = 8'h31;
  
  
  // The following 5 counters are in the 19b shipping bitfile.
  // They were not exposed in the driver until 2012-03-09.
  localparam DBG_COUNTER_0 = 8'h73;//channel reg
  localparam DBG_COUNTER_1 = 8'h74;//channel reg
  localparam DBG_COUNTER_2 = 8'h75;//channel reg
  localparam DBG_COUNTER_3 = 8'h76;//channel reg
  localparam DBG_COUNTER_4 = 8'h77;//channel reg
  
  localparam SOF_SOURCE_SEL = 8'h78;//channel reg
  // Tim added (2012-03-09)
  //`define DBG_COUNTER_5  8'h78 //channel reg
  localparam DBG_COUNTER_6  = 8'h79; //channel reg
  localparam DBG_COUNTER_7  = 8'h7A; //channel reg
  localparam DBG_COUNTER_8  = 8'h7B; //channel reg
  localparam DBG_COUNTER_9  = 8'h7C; //channel reg
  localparam DBG_COUNTER_10 = 8'h7D; //channel reg
  localparam DBG_COUNTER_11 = 8'h7E; //channel reg
  localparam DBG_COUNTER_12 = 8'h7F; //channel reg
  
  
  
     /* Global Registers */
  localparam DBG_DebugControl = 8'h22;
  localparam DBG_DebugControl_DEF  = 64'h0;
  localparam DBG_DebugStatus = 8'h23;
  localparam DBG_DebugStatus_DEF  = 64'h0;
  localparam FC_DATARATESWAP_MMADDR    = 8'h24;//{REG_GROUP_GLOBAL, REG_SUBGROUP_GLOBAL, FC_DATARATESWAP_MMADDR}
  localparam FC_DATARATESWAP_DEF    = 64'h0;
  
     /* Link Registers */ /* Base Address */      /* Register Location */
  localparam DintegCntrl = 8'h20; //{link_num, global, DintegCntrl}
  localparam DintegCntrl_DEF = 64'h0;
  
     /* Special registers -  */
  //`define  FC_TX_GEN_SOPEOP  8'h18//{4'b1000, `REG_SUBGROUP_LINK_GLOBAL, `FC_TX_GEN_SOPEOP}
  //`define  FC_DYNRCFG_WAIT  8'h19 //{4'h1, `REG_SUBGROUP_LINK_GLOBAL, `FC_DYNRCFG_WAIT};
  
  localparam DYNRCFG_WAIT_DELAY_DEF = 64'h500; //number of 50MHz clock cycles; 20ns period per cycle.
  //`define  IntStatsByteSwap 8'h21 //{link_num, global, intstatsbyteswap}
  localparam LinkFIFOUsedW = 8'h22; //{link_num, global, LinkFIFOUsedW}
    /* Channel registers */
  //`define Chan_Err_Latch  8'h72
  
  //this is a bit that goes into the link-control-register
  //`define       bLinkControl_MTIP_SCRMBL_ENA    10
  // +++++++++++++++++++++++To be added in next release++++++++++++++++++++++++++++++++++
  
  
  // new stuff from doug - after march 25, 2011
  localparam LinkErrLatch = 8'h23; //{link_num, global, LinkErrLatch}
  
  localparam LinkDroppedFrames = 8'h23; //{link_num, global, LinkDroppedFrames}
  localparam LinkPassedFrames = 8'h24;  //{link_num, global, LinkPassedFrames}
  
  localparam FC_VODCTRL_0      = 8'h30; //{REG_GROUP_GLOBAL, REG_SUBGROUP_GLOBAL, FC_VODCTRL_0};
  localparam FC_VODCTRL_1      = 8'h31; //{REG_GROUP_GLOBAL, REG_SUBGROUP_GLOBAL, FC_VODCTRL_1};
  localparam FC_VODCTRL_2      = 8'h32; //{REG_GROUP_GLOBAL, REG_SUBGROUP_GLOBAL, FC_VODCTRL_2};
  localparam FC_VODCTRL_3      = 8'h33; //{REG_GROUP_GLOBAL, REG_SUBGROUP_GLOBAL, FC_VODCTRL_3};
  // end of new stuff from doug
  
  
          /* Global Registers */  /* Base Address */      /* Register Location */
          //Standard Registers
  localparam HardwareRevision        = 8'h00;        //global/top
  localparam FPGAVersion     = 8'h01;        //global/top
  localparam ProbeSerialNumber       = 8'h02;        //global/top
          //Clock and Timing Registers
  localparam Timestamp       = 8'h03;        //global
          //Interval Control Registers
  localparam StatsInterval   = 8'h04;        //global
  localparam TransceiverStatsInterval        = 8'h05;        //i2c controller or global
          //DAL Status & Control
  localparam DALControl      = 8'h06;        //global
  localparam DALStatus       = 8'h07;        //global
          //FPGA Temperature Status & Control
  localparam FPGATempStatus  = 8'h08;        //I2C IF
  localparam FPGATempAlarmSetMM      = 8'h09;        //I2C IF
  localparam FPGATempAlarmSetMAX     = 8'h0A;        //I2C IF
  localparam FPGAVoltStatus  = 8'h0B;        //I2C IF
  localparam FPGAVoltAlarmSetMM      = 8'h0C;        //I2C IF
  localparam FPGAVoltAlarmSetMAX     = 8'h0D;        //I2C IF
  localparam FPGAMonitorCntrl        = 8'h0E;        //I2C IF
          //DAL Temperature Status & Control
  localparam DALTempStatus   = 8'h0F;        //I2C IF
  localparam DALTempCfg      = 8'h10;        //I2C IF
  localparam DALTempHystMM   = 8'h11;        //I2C IF
  localparam DALTempHystLM   = 8'h12;        //I2C IF
  localparam DALTempOverTempMM       = 8'h13;        //I2C IF
  localparam DALTempOverTempLM       = 8'h14;        //I2C IF
          //CPLD Image Select Status & Control
  localparam CPLD2FPGAImageCntrl     = 8'h15;        //I2C IF
  localparam CPLD2FPGAImageStatus    = 8'h16;        //I2C IF
          //I2C Status & Control
  localparam I2CDevUpdateCntrl       = 8'h17;        //I2C IF
  localparam I2CDirectIOAccess       = 8'h18;        //I2C IF
  localparam I2CDirectIOStatus       = 8'h19;        //I2C IF
          //Debug LED Control
  localparam DBG_LEDControl  = 8'h1A;        //global
          //Flash Status & Control
  localparam FlashControl    = 8'h20;        //global
  localparam FlashStatus     = 8'h21;        //global
  localparam DebugControl    = 8'h22;        //global
  localparam DebugStatus     = 8'h23;        //global
  
  
  
          /* Link Registers */    /* Base Address */      /* Register Location */
          //Link Control Register
  localparam LinkControl     = 8'h00;        //Link engine
  localparam LinkStatus      = 8'h01;        //Link engine
  localparam LinkStatsReset  = 8'h02;        //Link engine
          //Crossbar Switch
  localparam XbarOutConfig   = 8'h03;        //fc_serdes
  localparam XbarOutStatus   = 8'h04;        //fc_serdes
          //DPL Frame Monitoring Destination Registers
  localparam DPLBufBasePFN   = 8'h05;        //dma
  localparam DPLBufLastPFN   = 8'h06;        //dma
  localparam DPLBufDonePFN   = 8'h07;        //dma
  localparam DPLBufNextPFN   = 8'h08;        //dma
  localparam DPLBufMinFreePFN        = 8'h09;        //dma
          //Handling DPL Buffer Problems
  localparam DPLBufThreshInterval    = 8'h0A;        //elasticity_control
  localparam DPLBufThreshPanicStop   = 8'h0B;        //elasticity_control
  localparam DPLBufFramesDropped     = 8'h0C;        //
  localparam TotalFramesProcessed    = 8'h0D;        //
          //DAL Frame Monitoring Internal DDR3 Registers
  localparam DDRFMBufBase    = 8'h0E;        //elasticity_control
  localparam DDRFMBufStart   = 8'h0F;        //elasticity_control
  localparam DDRFMBufEnd     = 8'h10;        //elasticity_control
  localparam DDRFMBufMinFree = 8'h11;        //elasticity_control
  localparam DDRFMBufLen     = 8'h12;        //elasticity_control
          //Thresholds for Compressing Frame Monitoring Data
  localparam DALBufThreshHigh        = 8'h13;        //elasticity_control
  localparam DALBufThreshMid = 8'h14;        //elasticity_control
  localparam DALBufThreshLow = 8'h15;        //elasticity_control
          //Link Interval Stats
  localparam LinkSpeedEOI    = 8'h16;        //Link engine
          //FC Tx Data Generation Control
  localparam FC_TX_GEN_CONTROL       = 8'h17;        //fc_serdes
          //FC Tx Data Generation SOP/EOP
  localparam FC_TX_GEN_SOPEOP        = 8'h18;        //fc-serdes
          //FC Dynamic Reconfiguration Delay
  localparam FC_DYNRCFG_WAIT = 8'h19;        //fc_serdes
          //Data Integrity
  localparam DataIntegrityControl    = 8'h20;        //data_integrity
          //Interval Statistics Byte-Swap
  localparam IntStatsByteSwap        = 8'h21;        //Link engine
  
  
  
          /* Channel Registers */ /* Base Address */      /* Register Location */
          //Transceiver Stats Registers
  localparam XcvrPins        = 8'h00;        //transceiver stats
  localparam XcvrLOSIG       = 8'h01;        //transceiver stats
  localparam XcvrTemp        = 8'h02;        //transceiver stats
  localparam XcvrVoltage     = 8'h03;        //transceiver stats
  localparam XcvrTxBias      = 8'h04;        //transceiver stats
  localparam XcvrTxPower     = 8'h05;        //transceiver stats
  localparam XcvrRxPower     = 8'h06;        //transceiver stats
  localparam XcvrAlarmFlags  = 8'h07;        //transceiver stats
  localparam XcvrWarningFlags        = 8'h08;        //transceiver stats
          //SERDES Registers
  localparam SERDESStatus    = 8'h09;        //fc_serdes
          //FC Decode Registers
  localparam FCDStatus       = 8'h0A;        //frame stats
  localparam FCDErrDisparity = 8'h0B;        //frame stats
  localparam FCDErrInvalidChar       = 8'h0C;        //frame stats
  localparam FCDErrLOSI      = 8'h0D;        //frame stats
  localparam FCDErrLOS       = 8'h0E;        //frame stats
  localparam FCDErrCRC       = 8'h0F;        //frame stats
  localparam FCDErrSOF       = 8'h10;        //frame stats
  localparam FCDErrEOF       = 8'h11;        //frame stats
  localparam FCDErrTrunc     = 8'h12;        //frame stats
  localparam FCDErrEOFx      = 8'h13;        //frame stats
          //Primitive Counters Registers
  localparam PrimitiveLIPEvents      = 8'h14;        //primitive counter
  localparam PrimitiveNOSOLSEvents   = 8'h15;        //primitive counter
  localparam PrimitiveLRLRREvents    = 8'h16;        //primitive counter
  localparam PrimitiveLinkUpEvents   = 8'h17;        //primitive counter
          //Credit Counters & Timers Registers
  localparam CreditTimeAtMinimumCredit       = 8'h18;        //credit counter / timer
  localparam CreditBBCMin    = 8'h19;        //credit counter / timer
  localparam CreditBBCMax    = 8'h1A;        //credit counter / timer
  localparam CreditCounter   = 8'h1B;        //credit counter / timer
  localparam CreditStartValue        = 8'h1C;        //credit counter / timer
          //Time Arbiter Registers
  localparam TimeArbStatus   = 8'h1D;        //link engine (on a per-channel basis)
          //Transceiver Vendor Info
  localparam XcvrVendorOUI   = 8'h1E;        //transceiver stats
  localparam XcvrVendorPartNum_L     = 8'h1F;        //transceiver stats
  localparam XcvrVendorPartNum_H     = 8'h20;        //transceiver stats
  localparam XcvrVendorRevNum        = 8'h21;        //transceiver stats
  localparam XcvrVendorSerNum_L      = 8'h22;        //transceiver stats
  localparam XcvrVendorSerNum_H      = 8'h23;        //transceiver stats
  localparam LEDControl      = 8'h24;        //I2C controller
          //Template RAM
  //`define       TemplateRamInstruction  8'h25-6D             //template_ram
          //Reduced Extractor Registers
  localparam RedExtTotalFrames4FPP   = 8'h6E;        //frame_extractor
  localparam RedExtTotalFrames17FPP  = 8'h6F;        //frame_extractor
          //MTIP Register Interface Access
  localparam MTIP_RegIF_Access       = 8'h70;        //channel_engine.v
          //SFP Register I/f
  localparam SFP_I2C_DataRate        = 8'h71;        //channel_engine.v
          //Channel Error Latch
  localparam Chan_Err_Latch  = 8'h72;        //channel_engine.v
  
  localparam DropFrmCtr  = 64'h80;
  
          /* Perf Ctrs */ /* Base Address */      /* Register Location */
          //DMA Performance Counters
  localparam PerfCtl = 7'h00;        //perf_ctrs_dbg.v
          //All the registers in this section are latched by PerfCtrCtrl. Upon asserting the latch, the counters are copied to the following memory mapped locations and the underlying counters are reset
  localparam TicksSinceLastLatch     = 7'h01;        //perf_ctrs_dbg.v
  localparam DmaAck  = 7'h02;        //perf_ctrs_dbg.v
  localparam DmaComplete     = 7'h03;        //perf_ctrs_dbg.v
  localparam DmaActiveTicks  = 7'h04;        //perf_ctrs_dbg.v
  localparam DmaErrors       = 7'h05;        //perf_ctrs_dbg.v
  localparam Link1ReqTicks   = 7'h06;        //perf_ctrs_dbg.v
  localparam Link2ReqTicks   = 7'h07;        //perf_ctrs_dbg.v
  localparam Link3ReqTicks   = 7'h08;        //perf_ctrs_dbg.v
  localparam Link4ReqTicks   = 7'h09;        //perf_ctrs_dbg.v
  localparam Link5ReqTicks   = 7'h0A;        //perf_ctrs_dbg.v
  localparam Link6ReqTicks   = 7'h0B;        //perf_ctrs_dbg.v
  localparam Link7ReqTicks   = 7'h0C;        //perf_ctrs_dbg.v
  localparam Link8ReqTicks   = 7'h0D;        //perf_ctrs_dbg.v
  localparam Link1ReqTicksMax        = 7'h0E;        //perf_ctrs_dbg.v
  localparam Link2ReqTicksMax        = 7'h0F;        //perf_ctrs_dbg.v
  localparam Link3ReqTicksMax        = 7'h10;        //perf_ctrs_dbg.v
  localparam Link4ReqTicksMax        = 7'h11;        //perf_ctrs_dbg.v
  localparam Link5ReqTicksMax        = 7'h12;        //perf_ctrs_dbg.v
  localparam Link6ReqTicksMax        = 7'h13;        //perf_ctrs_dbg.v
  localparam Link7ReqTicksMax        = 7'h14;        //perf_ctrs_dbg.v
  localparam Link8ReqTicksMax        = 7'h15;        //perf_ctrs_dbg.v
  localparam Link1ActiveTicks        = 7'h16;        //perf_ctrs_dbg.v
  localparam Link2ActiveTicks        = 7'h17;        //perf_ctrs_dbg.v
  localparam Link3ActiveTicks        = 7'h18;        //perf_ctrs_dbg.v
  localparam Link4ActiveTicks        = 7'h19;        //perf_ctrs_dbg.v
  localparam Link5ActiveTicks        = 7'h1A;        //perf_ctrs_dbg.v
  localparam Link6ActiveTicks        = 7'h1B;        //perf_ctrs_dbg.v
  localparam Link7ActiveTicks        = 7'h1C;        //perf_ctrs_dbg.v
  localparam Link8ActiveTicks        = 7'h1D;        //perf_ctrs_dbg.v
  localparam Link1Complete   = 7'h1E;        //perf_ctrs_dbg.v
  localparam Link2Complete   = 7'h1F;        //perf_ctrs_dbg.v
  localparam Link3Complete   = 7'h20;        //perf_ctrs_dbg.v
  localparam Link4Complete   = 7'h21;        //perf_ctrs_dbg.v
  localparam Link5Complete   = 7'h22;        //perf_ctrs_dbg.v
  localparam Link6Complete   = 7'h23;        //perf_ctrs_dbg.v
  localparam Link7Complete   = 7'h24;        //perf_ctrs_dbg.v
  localparam Link8Complete   = 7'h25;        //perf_ctrs_dbg.v
  localparam Link1ArbFFUsedMax       = 7'h26;        //perf_ctrs_dbg.v
  localparam Link2ArbFFUsedMax       = 7'h27;        //perf_ctrs_dbg.v
  localparam Link3ArbFFUsedMax       = 7'h28;        //perf_ctrs_dbg.v
  localparam Link4ArbFFUsedMax       = 7'h29;        //perf_ctrs_dbg.v
  localparam Link5ArbFFUsedMax       = 7'h2A;        //perf_ctrs_dbg.v
  localparam Link6ArbFFUsedMax       = 7'h2B;        //perf_ctrs_dbg.v
  localparam Link7ArbFFUsedMax       = 7'h2C;        //perf_ctrs_dbg.v
  localparam Link8ArbFFUsedMax       = 7'h2D;        //perf_ctrs_dbg.v
  localparam Link1LFFUsedMax = 7'h2E;        //perf_ctrs_dbg.v
  localparam Link2LFFUsedMax = 7'h2F;        //perf_ctrs_dbg.v
  localparam Link3LFFUsedMax = 7'h30;        //perf_ctrs_dbg.v
  localparam Link4LFFUsedMax = 7'h31;        //perf_ctrs_dbg.v
  localparam Link5LFFUsedMax = 7'h32;        //perf_ctrs_dbg.v
  localparam Link6LFFUsedMax = 7'h33;        //perf_ctrs_dbg.v
  localparam Link7LFFUsedMax = 7'h34;        //perf_ctrs_dbg.v
  localparam Link8LFFUsedMax = 7'h35;        //perf_ctrs_dbg.v
  localparam Link1CH0FFUsedMax       = 7'h36;        //perf_ctrs_dbg.v
  localparam Link1CH1FFUsedMax       = 7'h37;        //perf_ctrs_dbg.v
  localparam Link2CH0FFUsedMax       = 7'h38;        //perf_ctrs_dbg.v
  localparam Link2CH1FFUsedMax       = 7'h39;        //perf_ctrs_dbg.v
  localparam Link3CH0FFUsedMax       = 7'h3A;        //perf_ctrs_dbg.v
  localparam Link3CH1FFUsedMax       = 7'h3B;        //perf_ctrs_dbg.v
  localparam Link4CH0FFUsedMax       = 7'h3C;        //perf_ctrs_dbg.v
  localparam Link4CH1FFUsedMax       = 7'h3D;        //perf_ctrs_dbg.v
  localparam Link5CH0FFUsedMax       = 7'h3E;        //perf_ctrs_dbg.v
  localparam Link5CH1FFUsedMax       = 7'h3F;        //perf_ctrs_dbg.v
  localparam Link6CH0FFUsedMax       = 7'h40;        //perf_ctrs_dbg.v
  localparam Link6CH1FFUsedMax       = 7'h41;        //perf_ctrs_dbg.v
  localparam Link7CH0FFUsedMax       = 7'h42;        //perf_ctrs_dbg.v
  localparam Link7CH1FFUsedMax       = 7'h43;        //perf_ctrs_dbg.v
  localparam Link8CH0FFUsedMax       = 7'h44;        //perf_ctrs_dbg.v
  localparam Link8CH1FFUsedMax       = 7'h45;        //perf_ctrs_dbg.v
  localparam SER_RX_FREQ_LOCKED      = 7'h46;        //perf_ctrs_dbg.v
  
  
  
  
  
          /* Global Registers */  /* DEFAULT */
  localparam HardwareRevision_DEF    = 64'hxxxxxxxx;         //N/A
  localparam FPGAVersion_DEF = 64'h20;       //N/A
  localparam ProbeSerialNumber_DEF   = 64'h0;        //N/A
          //Clock and Timing Registers
  //      Timestamp_DEF                //N/A
          //Interval Control Registers
  localparam StatsInterval_DEF       = 64'hCAA7E20;          //N/A
  localparam TransceiverStatsInterval_DEF    = 64'h7A120;            //N/A
          //DAL Status & Control
  localparam DALControl_DEF  = 64'h0;        //N/A
  localparam DALStatus_DEF   = 64'h0;        //N/A
          //FPGA Temperature Status & Control
  localparam FPGATempStatus_DEF      = 64'h0;        //YES
  localparam FPGATempAlarmSetMM_DEF  = 64'h0;        //TBD
  localparam FPGATempAlarmSetMAX_DEF = 64'h0;        //YES
  localparam FPGAVoltStatus_DEF      = 64'h0;        //YES
  localparam FPGAVoltAlarmSetMM_DEF  = 64'h0;        //YES
  localparam FPGAVoltAlarmSetMAX_DEF = 64'h0;        //YES
  localparam FPGAMonitorCntrl_DEF    = 64'h0;        //YES
          //DAL Temperature Status & Control
  localparam DALTempStatus_DEF       = 64'h0;        //YES
  localparam DALTempCfg_DEF  = 64'h0;        //YES
  localparam DALTempHystMM_DEF       = 64'h0;        //YES
  localparam DALTempHystLM_DEF       = 64'h0;        //YES
  localparam DALTempOverTempMM_DEF   = 64'h0;        //YES
  localparam DALTempOverTempLM_DEF   = 64'h0;        //YES
          //CPLD Image Select Status & Control
  localparam CPLD2FPGAImageCntrl_DEF = 16'h14;       //YES
  localparam CPLD2FPGAImageStatus_DEF        = 64'h0;        //YES
          //I2C Status & Control
  localparam I2CDevUpdateCntrl_DEF   = 16'h0;        //Only I2C_8 and I2C_16 are completed
  localparam I2CDirectIOAccess_DEF   = 32'h0;        //YES
  localparam I2CDirectIOStatus_DEF   = 32'h0;        //YES
          //Debug LED Control
  localparam DBG_LEDControl_DEF      = 4'h0;         //
          //Flash Status & Control
  localparam FlashControl_DEF        = 64'h0;        //
  localparam FlashStatus_DEF = 64'h0;        //
  localparam DebugControl_DEF        = 64'h0;        //
  localparam DebugStatus_DEF = 64'h0;        //
  
  
  
          /* Link Registers */    /* DEFAULT */
          //Link Control Register
  localparam LinkControl_DEF = 32'h1C000007;       // Tim(2012-03-28) - enable bit 28 so s/w doesn't have to change to enable frame forwarding on startup
  localparam LinkStatus_DEF  = 64'h0;
  localparam LinkStatsReset_DEF      = 64'h0;
          //Crossbar Switch
  localparam XbarOutConfig_DEF       = 64'h0;
  localparam XbarOutStatus_DEF       = 64'h0;
          //DPL Frame Monitoring Destination Registers
  localparam DPLBufBasePFN_DEF       = 64'h0;
  localparam DPLBufLastPFN_DEF       = 64'h0;
  localparam DPLBufDonePFN_DEF       = 64'h0;
  localparam DPLBufNextPFN_DEF       = 64'h0;
  localparam DPLBufMinFreePFN_DEF    = 64'h0;
          //Handling DPL Buffer Problems
  localparam DPLBufThreshInterval_DEF        = 64'h10000;
  localparam DPLBufThreshPanicStop_DEF       = 64'h2000;
  localparam DPLBufFramesDropped_DEF = 64'h0;
  localparam TotalFramesProcessed_DEF        = 64'h0;
          //DAL Frame Monitoring Internal DDR3 Registers
  localparam DDRFMBufBase_DEF        = 0;
  localparam DDRFMBufStart_DEF       = 0;
  localparam DDRFMBufEnd_DEF = 0;
  localparam DDRFMBufMinFree_DEF     = 64'h0;
  localparam DDRFMBufLen_DEF = 64'h40000;
          //Thresholds for Compressing Frame Monitoring Data
  localparam DALBufThreshHigh_DEF    = 64'h40000;
  localparam DALBufThreshMid_DEF     = 64'h20000;
  localparam DALBufThreshLow_DEF     = 64'h10000;
          //Link Interval Stats
  localparam LinkSpeedEOI_DEF        = 64'h0;
          //FC Tx Data Generation Control
  localparam FC_TX_GEN_CONTROL_DEF   = 64'h0050005000250025;
          //FC Tx Data Generation SOP/EOP
  localparam FC_TX_GEN_SOPEOP_DEF    = 64'h33;
          //FC Dynamic Reconfiguration Delay
  localparam FC_DYNRCFG_WAIT_DEF     = 64'h50000;
          //Data Integrity
  localparam DataIntegrityControl_DEF        = 64'h0;
          //Interval Statistics Byte-Swap
  localparam IntStatsByteSwap_DEF    = 64'h0;
  
  
  
          /* Channel Registers */ /* DEFAULT */
          //Transceiver Stats Registers
  localparam XcvrPins_DEF    = 64'b0;
  localparam XcvrLOSIG_DEF   = 64'b0;
  localparam XcvrTemp_DEF    = 64'b0;
  localparam XcvrVoltage_DEF = 64'b0;
  localparam XcvrTxBias_DEF  = 64'b0;
  localparam XcvrTxPower_DEF = 64'b0;
  localparam XcvrRxPower_DEF = 64'b0;
  localparam XcvrAlarmFlags_DEF      = 64'b0;
  localparam XcvrWarningFlags_DEF    = 64'b0;
          //SERDES Registers
  localparam SERDESStatus_DEF        = 64'b0;
          //FC Decode Registers
  localparam FCDStatus_DEF   = 64'h0;
  localparam FCDErrDisparity_DEF     = 64'h0;
  localparam FCDErrInvalidChar_DEF   = 64'h0;
  localparam FCDErrLOSI_DEF  = 64'h0;
  localparam FCDErrLOS_DEF   = 64'h0;
  localparam FCDErrCRC_DEF   = 64'h0;
  localparam FCDErrSOF_DEF   = 64'h0;
  localparam FCDErrEOF_DEF   = 64'h0;
  localparam FCDErrTrunc_DEF = 64'h0;
  localparam FCDErrEOFx_DEF  = 64'h0;
          //Primitive Counters Registers
  localparam PrimitiveLIPEvents_DEF  = 64'h0;
  localparam PrimitiveNOSOLSEvents_DEF       = 64'h0;
  localparam PrimitiveLRLRREvents_DEF        = 64'h0;
  localparam PrimitiveLinkUpEvents_DEF       = 64'h0;
          //Credit Counters & Timers Registers
  localparam CreditTimeAtMinimumCredit_DEF   = 32'h0;
  localparam CreditBBCMin_DEF        = 32'hFFFFFFFF;
  localparam CreditBBCMax_DEF        = 32'h0;
  localparam CreditCounter_DEF       = 32'h1000000;
  localparam CreditStartValue_DEF    = 32'h1000000;
          //Time Arbiter Registers
  localparam TimeArbStatus_DEF       = 64'h0;
          //Transceiver Vendor Info
  localparam XcvrVendorOUI_DEF       = 64'h00659000;
  localparam XcvrVendorPartNum_L_DEF = 64'h0;
  localparam XcvrVendorPartNum_H_DEF = 64'h0;
  localparam XcvrVendorRevNum_DEF    = 64'h0;
  localparam XcvrVendorSerNum_L_DEF  = 64'h0;
  localparam XcvrVendorSerNum_H_DEF  = 64'h0;
  localparam LEDControl_DEF  = 64'h0;
          //Template RAM
  //      //TemplateRamInstruction
          //Reduced Extractor Registers
  localparam RedExtTotalFrames4FPP_DEF       = 64'h0;
  localparam RedExtTotalFrames17FPP_DEF      = 64'h0;
          //MTIP Register Interface Access
  localparam MTIP_RegIF_Access_DEF   = 64'h0;
          //SFP Register I/f
  localparam SFP_I2C_DataRate_DEF    = 64'h0;
          //Channel Error Latch
  localparam Chan_Err_Latch_DEF      = 64'h0;
  
  
          //DMA Performance Counters
  localparam PerfCtrCtrl_DEF = 64'b0;        //bit 0 - on assertion latches and resets counters underneath. (auto-clears)
          //All the registers in this section are latched by PerfCtrCtrl. Upon asserting the latch, the counters are copied to the following memory mapped locations and the underlying counters are reset
  localparam TicksSinceLastLatch_DEF = 64'b0;        //total number of ticks (250MHz-->4ns/tick) since last assertion of PerfCtrCtrl
  localparam DmaAck_DEF      = 64'b0;        //total number of DMA's acks from PCIE. Should match DmaCmpt if no errors
  localparam DmaCmpt_DEF     = 64'b0;        //total number of DMA's completed
  localparam DmaActiveTicks_DEF      = 64'b0;        //total number of ticks needed for all DMA's
  localparam DmaErrors_DEF   = 64'b0;        //total number of DMA errors
  localparam Link1ReqTicks_DEF       = 64'b0;        //total number of ticks this link asserts request (total time waiting  to being serviced)
  localparam Link2ReqTicks_DEF       = 64'b0;        //same as above
  localparam Link3ReqTicks_DEF       = 64'b0;        //same as above
  localparam Link4ReqTicks_DEF       = 64'b0;        //same as above
  localparam Link5ReqTicks_DEF       = 64'h0;        //same as above
  localparam Link6ReqTicks_DEF       = 64'h0;        //same as above
  localparam Link7ReqTicks_DEF       = 64'h0;        //same as above
  localparam Link8ReqTicks_DEF       = 64'h0;        //same as above
  localparam Link1ReqTicksMax_DEF    = 64'h0;        //max number of ticks this link asserted request before being serviced
  localparam Link2ReqTicksMax_DEF    = 64'h0;        //same as above
  localparam Link3ReqTicksMax_DEF    = 64'h0;        //same as above
  localparam Link4ReqTicksMax_DEF    = 64'h0;        //same as above
  localparam Link5ReqTicksMax_DEF    = 64'h0;        //same as above
  localparam Link6ReqTicksMax_DEF    = 64'h0;        //same as above
  localparam Link7ReqTicksMax_DEF    = 64'h0;        //same as above
  localparam Link8ReqTicksMax_DEF    = 64'h0;        //same as above
  localparam Link1ActiveTicks_DEF    = 64'h0;        //total number of ticks for all DMA transfers
  localparam Link2ActiveTicks_DEF    = 64'h0;        //same as above
  localparam Link3ActiveTicks_DEF    = 64'h0;        //same as above
  localparam Link4ActiveTicks_DEF    = 64'h0;        //same as above
  localparam Link5ActiveTicks_DEF    = 64'h0;        //same as above
  localparam Link6ActiveTicks_DEF    = 64'h0;        //same as above
  localparam Link7ActiveTicks_DEF    = 64'h0;        //same as above
  localparam Link8ActiveTicks_DEF    = 64'h0;        //same as above
  
  
  
  
  
  //      Register Groups
  localparam REG_GROUP_GLOBAL        = 4'h0;
  localparam REG_GROUP_LINK_1        = 4'h1;
  localparam REG_GROUP_LINK_8        = 4'h8;
  localparam REG_GROUP_FC_RAMCH14    = 4'hE;
  localparam REG_GROUP_FC_RAMCH15    = 4'hF;
  
  //      Register Subgroups
  localparam REG_SUBGROUP_LINK_CHANNEL_0     = 4'h0;
  localparam REG_SUBGROUP_LINK_CHANNEL_1     = 4'h1;
  localparam REG_SUBGROUP_LINK_GLOBAL                = 4'h2;
  localparam REG_SUBGROUP_GLOBAL                             = 4'h3;
  localparam REG_SUBGROUP_PERF_GLOBAL                = 4'h4;
  //`define       REG_SUBGROUP_LINK_RESERVED_A    4'bx1xx
  //`define       REG_SUBGROUP_LINK_RESERVED_B    4'b1xxx
  
  //      Global Regs
  localparam REG_GLOBAL_HARDWARE_REV = 8'h7;
  localparam REG_GLOBAL_STATS_INTREVAL       = 8'hA;
  localparam REG_GLOBAL_XVR_STATS_INTERVAL   = 8'hB;
  
  //      Link Global Regs
  localparam REG_LINK_DPL_BUF_BASE   = 8'h7;
  localparam REG_LINK_DPL_BUF_LEN    = 8'h8;
  localparam REG_LINK_DPL_BUF_DONE_ADDR      = 8'h9;
  localparam REG_LINK_DPL_BUF_NEXT_ADDR      = 8'hA;
  localparam REG_LINK_DPL_BUF_MIN_FREE       = 8'hB;
  
  
  localparam bfwd_drop_step_ctl  = 0;
  
          /* Bitfields */ /* Bus offset */
          //LinkControl Register
  localparam bLinkControl_FWD       = 28;
  
  localparam bLinkControl_FORCE_NORMAL = 29;
  localparam bLinkControl_FC1        = 7;
  localparam bLinkControl_DPL        = 6;
  localparam bLinkControl_RRETFC     = 8;
  localparam bLinkControl_MonMode_Hi = 5;
  localparam bLinkControl_MonMode_Lo = 3;
  localparam bLinkControl_LinkSpd_Hi = 1;
  localparam bLinkControl_LinkSpd_Lo = 0;
  localparam bLinkControl_MTIP_FrmSz_Hi      = 27;
  localparam bLinkControl_MTIP_FrmSz_Lo      = 16;
  localparam bLinkControl_RateSel    = 2;
  localparam bLinkControl_INTPKTPTRN = 62;
  localparam bLinkControl_LINKFF     = 63;
  localparam bLinkControl_SRST_LINK  = 9;
  localparam bLinkControl_MTIP_SCRMBL_ENA    = 10;
          //LinkStatus Register
  localparam bLinkStatus_DMA = 6;
  localparam bLinkStatus_MonMode_Hi  = 5;
  localparam bLinkStatus_MonMode_Lo  = 3;
  localparam bLinkStatus_SYNC        = 8;
          //LinkStatsReset Register
  localparam bLinkStatsReset_LOSI    = 0;
  localparam bLinkStatsReset_LOS     = 1;
  localparam bLinkStatsReset_LIP     = 2;
  localparam bLinkStatsReset_NOSOLS  = 3;
  localparam bLinkStatsReset_LRLRR   = 4;
  localparam bLinkStatsReset_LINKUP  = 5;
  localparam bLinkStatsReset_DISP    = 6;
  localparam bLinkStatsReset_DEC     = 7;
  localparam bLinkStatsReset_CRC     = 8;
  localparam bLinkStatsReset_SOF     = 9;
  localparam bLinkStatsReset_EOF     = 10;
  localparam bLinkStatsReset_TRUNC   = 11;
  localparam bLinkStatsReset_EOFx    = 12;
  localparam bLinkStatsReset_TIMECR  = 13;
  localparam bLinkStatsReset_MINCR   = 14;
  localparam bLinkStatsReset_MAXCR   = 15;
  localparam bLinkStatsReset_EMCNTR  = 16;
  localparam bLinkStatsReset_RECNTR  = 17;
  localparam bLinkStatsReset_DROPCNTR        = 18;
  localparam bLinkStatsReset_PASSCNTR        = 19;
  
          //DALControl Register
  localparam bDALControl_RESET       = 31;
  localparam bDALControl_DDR3        = 30;
  
  localparam bLEDControl_ON  = 0;
  localparam bLEDControl_Blink       = 1;
  localparam bLEDControl_Color_Hi    = 3;
  localparam bLEDControl_Color_Lo    = 2;
          //FCDStatus Register
  localparam bFCDStatus_COMMA        = 0;
  localparam bFCDStatus_I2C_ERR      = 1;
          //XcvrAlarmFlags Register
  localparam bXcvrAlarmFlags_TEMPH   = 0;
  localparam bXcvrAlarmFlags_TEMPL   = 1;
  localparam bXcvrAlarmFlags_VCCH    = 2;
  localparam bXcvrAlarmFlags_VCCL    = 3;
  localparam bXcvrAlarmFlags_BIASH   = 4;
  localparam bXcvrAlarmFlags_BIASL   = 5;
  localparam bXcvrAlarmFlags_TXPWRH  = 6;
  localparam bXcvrAlarmFlags_TXPWRL  = 7;
  localparam bXcvrAlarmFlags_RXPWRH  = 8;
  localparam bXcvrAlarmFlags_RXPWRL  = 9;
          //XcvrWarnFlags Register
  localparam bXcvrWarnFlags_TEMPH    = 0;
  localparam bXcvrWarnFlags_TEMPL    = 1;
  localparam bXcvrWarnFlags_VCCH     = 2;
  localparam bXcvrWarnFlags_VCCL     = 3;
  localparam bXcvrWarnFlags_BIASH    = 4;
  localparam bXcvrWarnFlags_BIASL    = 5;
  localparam bXcvrWarnFlags_TXPWRH   = 6;
  localparam bXcvrWarnFlags_TXPWRL   = 7;
  localparam bXcvrWarnFlags_RXPWRH   = 8;
  localparam bXcvrWarnFlags_RXPWRL   = 9;
          //SERDESStatus Register
  localparam bSerdesStatus_REF       = 0;
  localparam bSerdesStatus_SYNC      = 1;
          //DALStatus Register
  localparam bDALStatus_DDR3 = 0;
  localparam bDALStatus_ERR  = 1;
endpackage