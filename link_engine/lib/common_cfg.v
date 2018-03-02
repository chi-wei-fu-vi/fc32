/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: common_cfg.v$
* $Author: honda.yang $
* $Date: 2013-06-21 19:28:53 -0700 (Fri, 21 Jun 2013) $
* $Revision: 2677 $
* Description: Common parameter definitions shared by multiple modules
*
***************************************************************************/

package common_cfg;

///////////////////////////////////////////////////////////////////////////////
// Frame Index
///////////////////////////////////////////////////////////////////////////////
localparam      FRM_INDEX_DATA                  = 0;
localparam      FRM_INDEX_PAUSE                 = 1;
localparam      FRM_INDEX_CTL                   = 2;

///////////////////////////////////////////////////////////////////////////////
// DAL Packet Type
///////////////////////////////////////////////////////////////////////////////
localparam      DAL_EMPTY_TYPE                  = 4'd0;
localparam      DAL_DATA_TYPE                   = 4'd1;
localparam      DAL_PAUSE_TYPE                  = 4'd2;
localparam      DAL_CTRL_TYPE                   = 4'd3;
localparam      DAL_INVL_TYPE                   = 4'd4;
localparam      DAL_C_INVL_TYPE                 = 4'd5;

///////////////////////////////////////////////////////////////////////////////
// Timestamp FIFO Fields
///////////////////////////////////////////////////////////////////////////////
typedef struct packed {
    bit [7:0]       reserved;
    bit [23:0]      fcmap;
    bit [15:0]      vlan;
    bit             vlan_vld;
    bit [2:0]       index;
    bit [55:0]      timestamp;
} timestamp_bus;

///////////////////////////////////////////////////////////////////////////////
// Control Channel FIFO
///////////////////////////////////////////////////////////////////////////////
localparam  CTL_CHNL_FIFO_DATA_WIDTH            = 134;
localparam  CTL_CHNL_FIFO_ADDR_WIDTH            = 10;
localparam  CTL_CHNL_FIFO_DEPTH                 = 1024;

///////////////////////////////////////////////////////////////////////////////
// Data Channel FIFO
///////////////////////////////////////////////////////////////////////////////
localparam  DAT_CHNL_FIFO_DATA_WIDTH            = 128;
localparam  DAT_CHNL_FIFO_ADDR_WIDTH            = 9;
localparam  DAT_CHNL_FIFO_DEPTH                 = 512;

///////////////////////////////////////////////////////////////////////////////
// Interval Stats FIFO
///////////////////////////////////////////////////////////////////////////////
localparam  INT_STAT_FIFO_DATA_WIDTH            = 129;
localparam  INT_STAT_FIFO_ADDR_WIDTH            = 5;
localparam  INT_STAT_FIFO_DEPTH                 = 32;

///////////////////////////////////////////////////////////////////////////////
// MTIP Primitives
///////////////////////////////////////////////////////////////////////////////
localparam      MTIP_PRIM_IDLE                  = 0;
localparam      MTIP_PRIM_R_RDY                 = 1;
localparam      MTIP_PRIM_VC_RDY                = 2;
localparam      MTIP_PRIM_BB_SCS                = 3;
localparam      MTIP_PRIM_BB_SCR                = 4;
localparam      MTIP_PRIM_NOS                   = 5;
localparam      MTIP_PRIM_OLS                   = 6;
localparam      MTIP_PRIM_LR                    = 7;
localparam      MTIP_PRIM_LRR                   = 8;
localparam      MTIP_PRIM_OPN                   = 9;
localparam      MTIP_PRIM_CLS                   = 10;
localparam      MTIP_PRIM_LIP                   = 11;


endpackage
