/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: 2012-07-13 14:28:26 -0700 (Fri, 13 Jul 2012) $
* $Revision: 71 $
* Description:
*
* This file contains defines, structs and functions useful for
* implementing PCIe application.
*
* Revision History Notes:
* 2012/07/26 Tim - initial release
* 2012/08/28 Tim - Added is_unsupported_request and pipe_if_type
*
***************************************************************************/
package pcie_app_pkg;
  
  
  // PCIe Table 2-2 - Fmt[1:0] Field Values
  localparam FMT_3DW_NO_DATA = 2'b00;
  localparam FMT_4DW_NO_DATA = 2'b01;
  localparam FMT_3DW_W_DATA  = 2'b10;
  localparam FMT_4DW_W_DATA  = 2'b11;
  
  localparam TYPE_CPL        = 5'b01010;
  localparam TYPE_MWR        = 5'b00000;
  
  // PCIE Table 2-21 - Completion Status Field Values
  localparam CPL_SC  = 3'b000;    // Successful completion
  localparam CPL_UR  = 3'b001;    // Unsupported request
  localparam CPL_CRS = 3'b010;    // Configuration Request Retry Status
  localparam CPL_CA  = 3'b100;    // Completer Abort (CA)
  
  
  localparam TC0_BEST_EFFORT     = 3'b000;
  localparam TD_ECRC_NOT_PRESENT = 1'b0;
  localparam EP_NOT_POISONED     = 1'b0;
  
  localparam ATTR_DEFAULT_ORDERING  = 1'b0;
  localparam ATTR_DEFAULT_CACHE_COH = 1'b0;
  
  localparam AT_DEFAULT_UNTRANSLATED = 2'b0;
  
  localparam MAX_TLP_PAYLD_SIZE_BYTE  = 2048;
  localparam MAX_TLP_PAYLD_SIZE_DW     = (MAX_TLP_PAYLD_SIZE_BYTE/4);
  
  
  
  localparam AVALON_255_0_VALID = 2'd0;
  localparam AVALON_191_0_VALID = 2'd1;
  localparam AVALON_127_0_VALID = 2'd2;
  localparam AVALON_63_0_VALID  = 2'd3;
  
  
  
  
  typedef enum
  {
    None,
    Unsupported,
    MRd,
    MRdLk,
    MWr,
    IORd,
    IOWr,
    CfgRd0,
    CfgWr0,
    CfgRd1,
    CfgWr1,
    TCfgRd,
    TCfgWr,
    Msg,
    MsgD,
    Cpl,
    CplD,
    CplLk,
    CplDLk
  } trans_type_e;
  
  
  // see Table 2-3 of PCIe Spec 2.0.
  function trans_type_e get_trans_type( [6:0] trans_type);
  
    priority case (trans_type)
  //  7'b0x00000 : get_trans_type = MRd;
      7'b0000000 : get_trans_type = MRd;
      7'b0100000 : get_trans_type = MRd;
  //  7'b0x00001 : get_trans_type = MRdLk;
  //  7'b1x00000 : get_trans_type = MWr;
      7'b1000000 : get_trans_type = MWr;
      7'b1100000 : get_trans_type = MWr;
      7'b0000010 : get_trans_type = IORd;
      7'b1000010 : get_trans_type = IOWr;
      7'b0000100 : get_trans_type = CfgRd0;
      7'b1000100 : get_trans_type = CfgWr0;
      7'b0000101 : get_trans_type = CfgRd1;
      7'b1000101 : get_trans_type = CfgWr1;
      7'b0011011 : get_trans_type = TCfgRd;
      7'b1011011 : get_trans_type = TCfgWr;
  //  7'b0110xxx : get_trans_type = Msg;
      7'b0110000 : get_trans_type = Msg;
  //  7'b1110xxx : get_trans_type = MsgD;
      7'b1110000 : get_trans_type = MsgD;
      7'b0001010 : get_trans_type = Cpl;
      7'b1001010 : get_trans_type = CplD;
      7'b0001011 : get_trans_type = CplLk;
      7'b1001011 : get_trans_type = CplDLk;
      default    : get_trans_type = None;
    endcase
  endfunction
  
  
  
  //
  // see Table 2-3 of PCIe Spec 2.0
  
  
  // Non-posted requires a completion
  // The Altera documentation has conflicting documentation wrt whether
  // the HIP absorbs non_posted unsupported requests.
  
  
  
  // supported transactions include:
  // RC MRd 3DW (non-posted) & FPGA CplD
  // FPGA MWr 4DW (posted) if address > 4GB...otherwise 3DW.
  typedef enum
  {
    DW3NoData,
    DW4NoData,
    DW3Data,
    DW4Data
  } fmt_type_e;
  
  
  typedef struct packed
  {
    logic       rsv3;
    logic [1:0] fmt;
    logic [4:0] frm_type;
    logic       rsv2;
    logic [2:0] tc;      // traffic class (default = 3'b0)
    logic [3:0] rsv1;
    logic       td;      // indicates TLP digest
    logic       ep;
    logic [1:0] attr;
    logic [1:0] at;
    logic [9:0] length;
  } hdr0_type;
  
  typedef struct packed
  {
    logic [7:0] bus_num;
    logic [4:0] dev_num;
    logic [2:0] fn_num;
  } req_id_type;
  
  typedef struct packed
  {
    req_id_type req_id;
    logic [7:0] tag;
  } trans_id_type;
  
  
  typedef struct packed
  {
    req_id_type req_id;
    logic [7:0] tag;
    logic [3:0] lbe;
    logic [3:0] fbe;
  } hdr1_type;
  
  typedef struct packed
  {
    logic [29:0] addr;
    logic [1:0]  rsv1;
  } hdr2_type;
  
  typedef struct packed
  {
    logic [29:0] lower_addr;
    logic [1:0]  rsv1;
    logic [31:0] upper_addr;
  } hdr2_3_type;
  
  
  
  
  typedef struct packed
  {
    req_id_type  cpl_id;
    logic [2:0]  cpl_status;
    logic        bcm;
    logic [11:0] byte_cnt;
  } cpl_hdr1_type;
  
  typedef struct packed
  {
    req_id_type req_id;
    logic [7:0] tag;
    logic       rsv1;
    logic [6:0] lower_addr;
  } cpl_hdr2_type;
  
  typedef struct packed
  {
    logic                  sop;
    logic                  eop;
    logic                  valid;
    logic [31:0]           be;
    logic [1:0]            empty;
    logic                  err;
    logic [7:0]            bar;
  } rx_st_avalon_type;
  
  
  typedef struct packed
  {
    logic           sop;
    logic           eop;
    logic           valid;
    logic [1:0]     empty;
    logic           err;
    logic [31:0]    parity;
  } tx_st_avalon_type;
  
  typedef struct packed
  {
  logic [57:0] rsvd;
  logic        lanereversalenable;
  logic [2:0]  eidleinfersel;
  logic        txdeemph;
  logic [2:0]  txmargin;
  logic [1:0]  rate;
  logic [2:0]  rxstatus0;
  logic        rxelecidle0;
  logic        phystatus0;
  logic        rxvalid0;
  logic        rxblkst0;
  logic [1:0]  rxsynchd0;
  logic        rxdataskip0;
  logic [3:0]  rxdatak0;
  logic [31:0] rxdata0;
  logic [1:0]  powerdown0;
  logic        rxpolarity0;
  logic        txcompl0;
  logic        txelecidle0;
  logic        txdetectrx0;
  logic        txblkst0;
  logic [1:0]  txsynchd0;
  logic        txdataskip0;
  logic [3:0]  txdatak0;
  logic [31:0] txdata0;
  } pipe_if_type;
  
  
  typedef struct packed
  {
    logic [31:0] iter;
    logic [23:0] link_en;
    logic [23:0] pat_type;
    logic        run;
  } pcie_bist_ctrl_ty;
  
  
  typedef struct packed
  {
    logic [31:0] iter;
    logic        run_dyn;
  } pcie_bist_status_ty;
  
  
  
endpackage