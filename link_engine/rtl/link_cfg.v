/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: link_cfg.v$
* $Author: honda.yang $
* $Date: 2013-07-26 14:39:03 -0700 (Fri, 26 Jul 2013) $
* $Revision: 3053 $
* Description: Link Engine module parameter definitions
*
***************************************************************************/

package link_cfg;

///////////////////////////////////////////////////////////////////////////////
// Control Link FIFO
///////////////////////////////////////////////////////////////////////////////
parameter   CTL_LINK_FIFO_DATA_WIDTH            = 256;
parameter   CTL_LINK_FIFO_ADDR_WIDTH            = 10;
parameter   CTL_LINK_FIFO_DEPTH                 = 1024;

///////////////////////////////////////////////////////////////////////////////
// Data Link FIFO
///////////////////////////////////////////////////////////////////////////////
parameter   DAT_LINK_FIFO_DATA_WIDTH            = 256;
parameter   DAT_LINK_FIFO_ADDR_WIDTH            = 12;
parameter   DAT_LINK_FIFO_DEPTH                 = 4096;

endpackage
