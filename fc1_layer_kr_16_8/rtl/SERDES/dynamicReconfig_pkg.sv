/***************************************************************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: $
* $Revision: $
* Description:
*
***************************************************************************/
package dynamicReconfig_pkg;

  // Data Rate
  localparam  [3:0]           DataRate2G                = 4'b0001;
  localparam  [3:0]           DataRate4G                = 4'b0010;
  localparam  [3:0]           DataRate8G                = 4'b0011;
  localparam  [3:0]           DataRate16G               = 4'b0100;
  localparam  [3:0]           DefaultRate               = DataRate16G;

  // MIF ROM base address
  localparam  [11:0]          ROM4GAddr                 = 12'h000;
  localparam  [11:0]          ROM8GAddr                 = 12'h200;
  localparam  [11:0]          ROM16GAddr                = 12'h400;

  localparam                  TriSpeedATXLCH            = 26; 

  // Reconfigure base address for each register groups

  localparam  [6:0]           AnalogControlAddr         = 1 << 3;
  localparam  [6:0]           EyeQAddr                  = 2 << 3;
  localparam  [6:0]           DFEAddr                   = 3 << 3;

  localparam  [6:0]           AEQAddr                   = 5 << 3;
  localparam  [6:0]           ATXPLLAddr                = 6 << 3;
  localparam  [6:0]           StreamerAddr              = 7 << 3;
  localparam  [6:0]           PLLAddr                   = 8 << 3;

  // Direct Registers
  localparam  [6:0]           LogicalChanNo             = StreamerAddr + 3'd0;
  localparam  [6:0]           PhysicalChanNo            = StreamerAddr + 3'd1;
  localparam  [6:0]           ControlStatus             = StreamerAddr + 3'd2;
  localparam  [6:0]           AddrOffset                = StreamerAddr + 3'd3;
  localparam  [6:0]           DataReg                   = StreamerAddr + 3'd4;

  // Stream direct register bit map
  localparam  [31:0]          StreamerErrorMask         = 32'h0000_0200;
  localparam  [31:0]          StreamerBusyMask          = 32'h0000_0100;
  localparam  [31:0]          StreamerMode0Mask         = 32'h0000_0000;
  localparam  [31:0]          StreamerMode1Mask         = 32'h0000_0004;
  localparam  [31:0]          StreamerReadMask          = 32'h0000_0002;
  localparam  [31:0]          StreamerWriteMask         = 32'h0000_0001;


  // Streamer indirect registers
  localparam  [15:0]          MIFBaseAddr               = 16'h0000;
  localparam  [15:0]          MIFControl                = 16'h0001;
  localparam  [15:0]          MIFStatus                 = 16'h0002;

  // Stream indirect register bit map
  localparam  [31:0]          MIFClrErrMask             = 32'h0000_0004;
  localparam  [31:0]          MIFAddrModeMask           = 32'h0000_0002;
  localparam  [31:0]          MIFStartMask              = 32'h0000_0001;

  localparam  [31:0]          MIFChMisMatchMask         = 32'h0000_0010;
  localparam  [31:0]          MIFRecnfgErrMask          = 32'h0000_0004;
  localparam  [31:0]          MIFCodeErrMask            = 32'h0000_0002;
  localparam  [31:0]          MIFInvalidRegErrMask      = 32'h0000_0001;

endpackage
