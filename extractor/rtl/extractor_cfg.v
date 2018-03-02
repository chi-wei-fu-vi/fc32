/***************************************************************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: extractor_cfg.v$
* $Author: honda.yang $
* $Date: 2013-07-22 16:29:59 -0700 (Mon, 22 Jul 2013) $
* $Revision: 2925 $
* Description: EXTRACTOR module parameter definitions
*
***************************************************************************/

package extractor_cfg;

///////////////////////////////////////////////////////////////////////////////
// Extraction Opcode
///////////////////////////////////////////////////////////////////////////////
parameter       EXTR_OP_END                     = 2'b0;
parameter       EXTR_OP_XDAT                    = 2'b1;

///////////////////////////////////////////////////////////////////////////////
// Extraction Template Memory Fields
///////////////////////////////////////////////////////////////////////////////
typedef struct packed {
    bit [20:0]      reserved;
    bit [23:0]      flip;
    bit [7:0]       mask;
    bit [8:0]       offset;
    bit [1:0]       opcode;
} template_mem_bus;

///////////////////////////////////////////////////////////////////////////////
// Maximum Extraction Bytes
///////////////////////////////////////////////////////////////////////////////
parameter       MAX_EXTR_BCNT                   = 6'd54;

endpackage
