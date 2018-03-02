/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-09-06 11:53:05 -0700 (Thu, 06 Sep 2012) $
* $Revision: 162 $
* Description:
*
* This module interfaces with the PCIE HIP RX Avalon interface and decodes the
* TLP packets.
*
* Upper level dependencies:  bali_pcie_app.sv
* Lower level dependencies:  none
*
* Revision History Notes:
* 2012/06/22 Tim - initial release
* 2012/09/06 Tim - Set tx_hdr0.td = 0, set tx_hdr2.lower_addr
*
***************************************************************************/


module tx_mm2tlp_if
(
  input                  iRST,
  input                  iRST_100M,
  input                  iCLK,
  input                  iCLK_100M,

  output logic           oFR_TX_DONE_PULSE,

  // decoded rx tlp inputs
  input                  iDECODE_VALID,
  input pcie_app_pkg::hdr0_type        iTLP_HDR0,
  input pcie_app_pkg::hdr1_type        iTLP_HDR1,
  input [29:0]           iADDR_QWALIGNED,

  input                  iTLP_MRD,
  input                  iTLP_MWR,
  input                  iTLP_UR,
  input                  iTLP_NON_POSTED,

  input [12:0]           iCFG_BUSDEV,   // from HIP
  input [2:0]            iFN_NUM,

  // From FPGA Register Modules
  input [63:0]           iMM_RD_DATA,
  input                  iMM_RD_DATA_VALID,

  // arbitrate to transmit TLP Completion
  output logic           oTX_REQ,
  input                  iTX_GNT,

  // TX PCIE AVALON-ST I/F
  output pcie_app_pkg::tx_st_avalon_type oTX_ST,
  output logic [255:0]     oTX_ST_DATA,

  // Register
  input [19:0]           iREG_PCIETIMEOUTPERIOD,
  output logic           oREG_PCIETIMEOUTCTR_EN
);
import pcie_app_pkg::*;


logic [63:0] rd_data_hold;

typedef enum {IDLE_ST,
              REQ_ST,
              TX_TLP_ST,
              DONE_ST
              } state_e;
state_e       ps, ns;

hdr0_type     tx_hdr0;
cpl_hdr1_type tx_hdr1;
cpl_hdr2_type tx_hdr2;

logic [1:0]   tlp_ur_pipe;
logic         tlp_ur_pulse;
logic         mrd_decode_vld, mrd_decode_vld_d1;
logic [7:0]   timestamp_100m, timestamp_100m_gray_nxt, timestamp_100m_gray;
logic [7:0]   timestamp_pclk_gray, timestamp_lsb_pclk_nxt, timestamp_lsb_pclk;
logic [7:0]   timestamp_lsb_pclk_p1;
logic         timestamp_wrap, mrd_start, mrd_cpl_pending;
logic [55:0]  timestamp_pclk, end_timestamp;
logic         mrd_timeout, mrd_timeout_d1;

//////////////////////////////////////////////////////////////////////////////
//
// Hold input rd data
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    rd_data_hold  <= '0;
  end
  else
  begin
    if(iTLP_MRD && iDECODE_VALID && iMM_RD_DATA_VALID)
      rd_data_hold <= iMM_RD_DATA;
    else if(!iTLP_MRD && iDECODE_VALID)
      rd_data_hold <= '0;
    else if(oREG_PCIETIMEOUTCTR_EN)
      rd_data_hold <= {32'hBADBADAD, iADDR_QWALIGNED[28:0], 3'b0};
  end
end

//////////////////////////////////////////////////////////////////////////////
//
// Unsupported Request Pulse Generation
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    tlp_ur_pipe  <= 2'b0;
    tlp_ur_pulse <= 1'b0;
  end
  else
  begin
    tlp_ur_pipe <= {tlp_ur_pipe[0], iTLP_UR & iTLP_NON_POSTED}; // shift-in
    tlp_ur_pulse <= !tlp_ur_pipe[1] & tlp_ur_pipe[0]; // catch 0-to-1 transition
  end
end




// 256-bits = 32-bytes = 8xDWORDS
// TLP - All Cpl have 3DW in Header
//
// DW0=HDR0=hdr0_type
// DW1=HDR1=cpl_hdr1_type
// DW2=cpl_hdr2_type
// DW3=RD_DATA[31:0]  - For MWr
// DW4=RD_DATA[63:32] - For MWr
//
// See table 6-30 in Altera for 256-bit i/f
// and Cpl with qword aligned address.
// and st_st_empty[1:0] = 0x1
//
// tx_st_data[255:192] = xxxxxxxx, xxxxxxxx
// tx_st_data[191:128] =    data1,    data0
// tx_st_data[127:64]  = xxxxxxxx,     hdr2
// tx_st_data[63:0]    =     hdr1,     hdr0


assign oTX_ST.empty  = (tlp_ur_pipe[0]) ? 2'h2 : 2'h1;
assign oTX_ST.err    = 1'b0;
assign oTX_ST.parity = 32'b0;

assign oTX_ST_DATA[255:192] = '0;
assign oTX_ST_DATA[191:160] = rd_data_hold[63:32];
assign oTX_ST_DATA[159:128] = rd_data_hold[31:0];
assign oTX_ST_DATA[127:96]  = 32'b0;
assign oTX_ST_DATA[95:64]   = tx_hdr2;
assign oTX_ST_DATA[63:32]   = tx_hdr1;
assign oTX_ST_DATA[31:0]    = tx_hdr0;

//
// posted = fire and forget
// All read-requests and non-posted Write requests require completions
// All I/O Read/Write are non-posted and require completions
//
//


//////////////////////////////////////////////////////////////////////////////
//
// Construct TX TLP Packet
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    tx_hdr0 <= '{default:0};
    tx_hdr1 <= '{default:0};
    tx_hdr2 <= '{default:0};
  end
  else
  begin
    tx_hdr0                <= iTLP_HDR0;
    // override values to be changed
    tx_hdr0.at             <= 2'b0;   // Per PCIE Spec 2.2.9: item 10
    tx_hdr0.fmt            <= (tlp_ur_pipe[0]) ? FMT_3DW_NO_DATA : FMT_3DW_W_DATA;
    tx_hdr0.frm_type       <= TYPE_CPL;
    tx_hdr0.td             <= 1'b0; // no TLP digest (ECRC)

    tx_hdr1.cpl_id.bus_num <= iCFG_BUSDEV[12:5];
    tx_hdr1.cpl_id.dev_num <= iCFG_BUSDEV[4:0];
    tx_hdr1.cpl_id.fn_num  <= iFN_NUM;
    tx_hdr1.cpl_status     <= (tlp_ur_pipe[0]) ? CPL_UR : CPL_SC;
    tx_hdr1.bcm            <= 1'b0;
    tx_hdr1.byte_cnt       <= (tlp_ur_pipe[0]) ? 12'h0 : 12'h8;  // 2x DWORDS = 8 bytes

    tx_hdr2.req_id         <= iTLP_HDR1.req_id;
    tx_hdr2.tag            <= iTLP_HDR1.tag;
    tx_hdr2.lower_addr     <= {iADDR_QWALIGNED[3:0], 3'b0}; // tmb (2012-09-05) - lower 7 address bits needed by root port
  end
end



//////////////////////////////////////////////////////////////////////////////
//
// FSM Sequenctial Logic
//
//////////////////////////////////////////////////////////////////////////////
always @(posedge iCLK or posedge iRST)
  if(iRST)
    ps <= IDLE_ST;
  else
    ps <= ns;

//////////////////////////////////////////////////////////////////////////////
//
// FSM Next State Logic
//
//////////////////////////////////////////////////////////////////////////////
always_comb
begin

  oTX_REQ = 1'b0;
  oTX_ST.sop = 1'b0;
  oTX_ST.eop = 1'b0;
  oTX_ST.valid = 1'b0;
  oFR_TX_DONE_PULSE = 1'b0;


  case(ps)
                 IDLE_ST: begin
                            if((iTLP_MRD && iDECODE_VALID &&
                               iMM_RD_DATA_VALID ) ||
                               tlp_ur_pulse || oREG_PCIETIMEOUTCTR_EN)
                                                     ns = REQ_ST;
                            else                     ns = IDLE_ST;
                          end
                  REQ_ST: begin
                             oTX_REQ = 1'b1;
                             if(iTX_GNT)             ns = TX_TLP_ST;
                             else                    ns = REQ_ST;
                          end
               TX_TLP_ST: begin
                                                     oTX_REQ      = 1'b1;
                                                     oTX_ST.sop   = 1'b1;
                                                     oTX_ST.eop   = 1'b1;
                                                     oTX_ST.valid = 1'b1;
                                                     oFR_TX_DONE_PULSE = 1'b1;

                                                     ns = DONE_ST;
                          end

                 DONE_ST: begin
                            if(!iTX_GNT)             ns = IDLE_ST;  // wait until gnt is de-asserted indicating transfer done.
                            else                     ns = DONE_ST;

                          end
                 default: begin
                                                     ns = IDLE_ST;
                          end
  endcase
end

///////////////////////////////////////////////////////////////////////////////
// Timestamp in 100MHz Clock Domain
///////////////////////////////////////////////////////////////////////////////
// The 56-bit timestamp is too large to go through gray code coversion
// in one clock cycle. Only 8 bits reside in 100MHz clock domain.
// Whenever the 8-bit counter wraps, the upper 48-bit value is then
// incremented by one in PCIE clock domain.
always_ff @( posedge iCLK_100M or posedge iRST_100M )
    if ( iRST_100M )
        timestamp_100m <= 8'b0;
    else
        timestamp_100m <= timestamp_100m + 8'b1;

///////////////////////////////////////////////////////////////////////////////
// Timestamp Entering PCIE Clock Domain
///////////////////////////////////////////////////////////////////////////////
vi_bin2gray #(
    .SIZE       ( 8         )
)
u_timestamp_100m_bin2gray (
    .gray               ( timestamp_100m_gray_nxt   ),
    .bin                ( timestamp_100m            )
);

always_ff @( posedge iCLK_100M or posedge iRST_100M )
    if ( iRST_100M )
        timestamp_100m_gray <= 8'b0;
    else
        timestamp_100m_gray <= timestamp_100m_gray_nxt;

vi_sync_level #(
    .SIZE           ( 8                     ),
    .TWO_DST_FLOPS  ( 1                     ),
    .ASSERT         ( 1                     )
)
u_sync_level_timestamp_gray (
    .out_level          ( timestamp_pclk_gray       ),
    .clk                ( iCLK                      ),
    .rst_n              ( ~iRST                     ),
    .in_level           ( timestamp_100m_gray       )
);

vi_gray2bin #(
    .SIZE       ( 8         )
)
u_timestamp_pcie_gray2bin (
    .bin                ( timestamp_lsb_pclk_nxt    ),
    .gray               ( timestamp_pclk_gray       )
);

always_ff @( posedge iCLK or posedge iRST )
    if ( iRST ) begin
        timestamp_lsb_pclk <= 8'b0;
        timestamp_lsb_pclk_p1 <= 8'b0;
    end
    else begin
        timestamp_lsb_pclk <= timestamp_lsb_pclk_nxt;
        timestamp_lsb_pclk_p1 <= timestamp_lsb_pclk;
    end

///////////////////////////////////////////////////////////////////////////////
// Timestamp Wrap
///////////////////////////////////////////////////////////////////////////////
assign timestamp_wrap = timestamp_lsb_pclk[7] ^ timestamp_lsb_pclk_p1[7];

always_ff @( posedge iCLK or posedge iRST )
    if ( iRST )
        timestamp_pclk <= 56'b0;
    else begin
        timestamp_pclk[6:0]  <= timestamp_lsb_pclk[6:0];
        if ( timestamp_wrap )
            timestamp_pclk[55:7] <= timestamp_pclk[55:7] + 49'b1;
    end

//////////////////////////////////////////////////////////////////////////////
//
// Register Read Completion Timeout
//
//////////////////////////////////////////////////////////////////////////////
// Allow 10us for downstream modules to respond
assign mrd_decode_vld = iTLP_MRD && iDECODE_VALID;

always @(posedge iCLK or posedge iRST)
  if(iRST)
    mrd_decode_vld_d1 <= 1'b0;
  else
    mrd_decode_vld_d1 <= mrd_decode_vld;

assign mrd_start = mrd_decode_vld && ~mrd_decode_vld_d1;

always @(posedge iCLK)
  if (mrd_start)
    end_timestamp <= timestamp_pclk + iREG_PCIETIMEOUTPERIOD;

always @(posedge iCLK or posedge iRST)
  if(iRST)
    mrd_cpl_pending <= 1'd0;
  else begin
    if ( mrd_cpl_pending )
      mrd_cpl_pending <= ~( iMM_RD_DATA_VALID || tlp_ur_pulse || oREG_PCIETIMEOUTCTR_EN );
    else
      mrd_cpl_pending <= mrd_start;
  end

always @(posedge iCLK or posedge iRST)
  if(iRST) begin
    mrd_timeout <= 1'b0;
    mrd_timeout_d1 <= 1'b0;
    oREG_PCIETIMEOUTCTR_EN <= 1'b0;
  end
  else begin
    mrd_timeout <= mrd_cpl_pending && ( timestamp_pclk > end_timestamp );
    mrd_timeout_d1 <= mrd_timeout;
    oREG_PCIETIMEOUTCTR_EN <= mrd_timeout & ~mrd_timeout_d1;
  end

//////////////////////////////////////////////////////////////////////////////
//
// Assertion
//
//////////////////////////////////////////////////////////////////////////////
// synopsys translate_off

// Register read timeout
assert_memory_read_timeout: assert property ( @( posedge iCLK )
    disable iff ( iRST )
    !$rose( oREG_PCIETIMEOUTCTR_EN ) );

// synopsys translate_on


endmodule
