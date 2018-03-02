/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-08-29 15:11:33 -0700 (Wed, 29 Aug 2012) $
* $Revision: 144 $
* Description:
*
* This module interfaces with the PCIE HIP RX Avalon interface and decodes the
* TLP packets.
*
*
* Pipeline latency = ?
*
* Upper level dependencies: bali_pcie_app.sv
* Lower level dependencies: none
*
* Revision History Notes:
* 2012/06/22 Tim - initial release
* 2012/08/29 Tim - fixed bug caused by poison TLP followed by valid MRd.
*
*
***************************************************************************/


///////////////////////////////////////////////////////////////////////////////
//
// Include
//
///////////////////////////////////////////////////////////////////////////////



module rx_tlp_decode
#(
  parameter BALI = 0
)
(
  input iRST,
  input iCLK,

  // RX PCIE AVALON-ST I/F
  input [255:0]             iRX_ST_DATA,
  output                    oRX_ST_READY,
  input                     iRX_ST_SOP,
  input                     iRX_ST_VALID,
  input  [1:0]              iRX_ST_EMPTY,
  input                     iRX_ST_EOP,
  input                     iRX_ST_ERR,
//input [31 :0]             iRX_ST_PARITY,   // NOT USED
  input [31 :0]             iRX_ST_BE,
  output                    oRX_ST_MASK,
  input [7 : 0]             iRX_ST_BAR,

  // control inputs
  input                     iDONE_PULSE,    // don't process another TLP until other state m/cs IDLE

  // decoded outputs
  output logic              oDECODE_VALID,
  output pcie_app_pkg::hdr0_type    oHDR0,
  output pcie_app_pkg::hdr1_type    oHDR1,
  output logic [29:0]       oADDR,
  output logic [63:0]       oWR_DATA,

  output pcie_app_pkg::trans_type_e oTRANS_TYPE,
  output logic              oTLP_MRD,
  output logic              oTLP_MWR,
  output logic              oTLP_UR, // unsupported request
  output logic              oTLP_NON_POSTED,
  output logic              oTLP_EP, // poison (error forwarding)
  output logic              oTLP_3DW_4DW_n,
  output logic              oTLP_ADDR_QWALIGNED
);
import pcie_app_pkg::*;

// 256-bits = 32-bytes = 8xDWORDS
// TLP
// DW0=HDR0=hdr0_type
// DW1=HDR1=hdr1_type
// DW2=ADDR
// DW3=WR_DATA[31:0]  - For MWr
// DW4=WR_DATA[63:32] - For MWr

typedef enum {IDLE_ST,
              RD_FIFO_ST,
              DECODE_HOLD_ST
              } state_e;

state_e           ps, ns;
rx_st_avalon_type rx_st_in;
rx_st_avalon_type rx_st;

logic [255:0]     rx_st_data;
logic             fifo_empty;
logic             fifo_rd;
logic             decode_valid;
logic             decode_valid_r1;

logic tlp_ur_int;
logic tlp_non_posted_int;
logic tlp_non_posted;

logic tlp_addr_qwaligned;
logic tlp_3dw_4dw_n;

trans_type_e trans_type;
logic tlp_mrd;
logic tlp_mwr;
logic tlp_ur; // unsupported request
logic tlp_ep; // poison
logic tlp_ep_int; // poison

hdr0_type hdr0, hdr0_r1;
hdr1_type hdr1, hdr1_r1;
hdr2_type hdr2, hdr2_r1;
logic [63:0] wrdata, wrdata_r1;


assign tlp_ep_int = tlp_ep & decode_valid_r1; // internal signal needed to transition s/m to IDLE since dropping poison packet

///////////////////////////////////////////////////////////////////////////////
//
// Assign Outputs
//
///////////////////////////////////////////////////////////////////////////////
always @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    oDECODE_VALID       <= 1'b0;
    oTLP_ADDR_QWALIGNED <= 1'b0;
    oTLP_3DW_4DW_n      <= 1'b0;

    oHDR0               <=  '{default:0};
    oHDR1               <=  '{default:0};
    oADDR               <=  '0; // pass double_qword_aligned address (8byte)
    oWR_DATA            <=  '0;

    oTRANS_TYPE         <= None;
    oTLP_MRD            <= 1'b0;
    oTLP_MWR            <= 1'b0;
    oTLP_UR             <= 1'b0;
    oTLP_NON_POSTED     <= 1'b0;
    oTLP_EP             <= 1'b0;
  end
  else
  begin
    decode_valid_r1     <= decode_valid;
    oDECODE_VALID       <= decode_valid_r1 & decode_valid; // force valid low when in IDLE, and take extra cycle before asserting
    oTLP_ADDR_QWALIGNED <= tlp_addr_qwaligned;
    oTLP_3DW_4DW_n      <= tlp_3dw_4dw_n;

    oHDR0               <= hdr0_r1;
    oHDR1               <= hdr1_r1;
    oADDR               <= hdr2_r1.addr[29:1]; // pass double_qword_aligned address (8byte)
    oWR_DATA            <= wrdata_r1;

    oTRANS_TYPE         <= trans_type;
    oTLP_MRD            <= tlp_mrd;
    oTLP_MWR            <= tlp_mwr;
    oTLP_UR             <= tlp_ur;
    oTLP_NON_POSTED     <= tlp_non_posted;
    oTLP_EP             <= tlp_ep;
  end
end


//Insert pipeline here to break timing path across Gen3 HSSI 
//Avalon datapath. 
generate

// The following control throttles backpressure.
// It could be changed to almost_full for better performance.
assign oRX_ST_READY = (fifo_empty) ? 1'b1 : 1'b0;
assign oRX_ST_MASK  = 1'b0;

if (BALI == 0) begin : gen_no_bali
// assign inputs to struct
assign rx_st_in.sop   = iRX_ST_SOP;
assign rx_st_in.eop   = iRX_ST_EOP;
assign rx_st_in.valid = iRX_ST_VALID;
assign rx_st_in.be    = iRX_ST_BE;
assign rx_st_in.empty = iRX_ST_EMPTY;
assign rx_st_in.err   = iRX_ST_ERR;
assign rx_st_in.bar   = iRX_ST_BAR;

// The following fifos are used to throttle the arrival of the TLP packets.

// FIFO - write the RX AVALON CONTROL SIGNALS

wire      ctrl_almost_full;
wire      ctrl_almost_empty;
wire      ctrl_underflow;
wire      ctrl_wr_rst_busy;
wire      ctrl_rd_rst_busy;
wire      ctrl_overflow;
tlp_decode_sc_fifo_48x8 sc_fifo_48x8_inst
(
 . almost_full          ( ctrl_almost_full                                   ), // output
 . almost_empty         ( ctrl_almost_empty                                  ), // output
 . underflow            ( ctrl_underflow                                     ), // output
 . wr_rst_busy          ( ctrl_wr_rst_busy                                   ), // output
 . rd_rst_busy          ( ctrl_rd_rst_busy                                   ), // output
 . overflow             ( ctrl_overflow                                      ), // output
 . din                  ( rx_st_in                                           ), 
 . full                 (                                                    ), 
 . dout                 ( rx_st                                              ), 
 . data_count           (                                                    ), // fixme 3 vs 4
 . clk                  ( iCLK                                               ), 
 . wr_en                ( iRX_ST_VALID                                       ), 
 . rd_en                ( fifo_rd                                            ), 
 . rst                  ( iRST                                               ), 
 . empty                ( fifo_empty                                         )  
);



// FIFO - write the RX AVALON DATA

wire      data_almost_full;
wire      data_almost_empty;
wire      data_underflow;
wire      data_wr_rst_busy;
wire      data_rd_rst_busy;
wire      data_overflow;
tlp_decode_sc_fifo_256x8 sc_fifo_256x8_inst
(
 . almost_full          ( data_almost_full                                   ), // output
 . almost_empty         ( data_almost_empty                                  ), // output
 . underflow            ( data_underflow                                     ), // output
 . wr_rst_busy          ( data_wr_rst_busy                                   ), // output
 . rd_rst_busy          ( data_rd_rst_busy                                   ), // output
 . overflow             ( data_overflow                                      ), // output
 . din                  ( iRX_ST_DATA                                        ), 
 . full                 (                                                    ), 
 . dout                 ( rx_st_data                                         ), 
 . data_count           (                                                    ), 
 . clk                  ( iCLK                                               ), 
 . wr_en                ( iRX_ST_VALID                                       ), 
 . rd_en                ( fifo_rd                                            ), 
 . rst                  ( iRST                                               ), 
 . empty                (                                                    )  
);

end : gen_no_bali

// BALI mode : i.e. PCIe Gen3 and extra pipe.

if (BALI == 1) begin : gen_bali
// assign inputs to struct

logic [255:0] irx_st_data;

always @(posedge iCLK or posedge iRST) 
  if (iRST)
  begin
    rx_st_in.sop   <= 'h0;
    rx_st_in.eop   <= 'h0;
    rx_st_in.valid <= 'h0;
    rx_st_in.be    <= 'h0;
    rx_st_in.empty <= 'h0;
    rx_st_in.err   <= 'h0;
    rx_st_in.bar   <= 'h0;
    irx_st_data    <= 'h0;
  end
  else
  begin
    rx_st_in.sop   <= iRX_ST_SOP;
    rx_st_in.eop   <= iRX_ST_EOP;
    rx_st_in.valid <= iRX_ST_VALID;
    rx_st_in.be    <= iRX_ST_BE;
    rx_st_in.empty <= iRX_ST_EMPTY;
    rx_st_in.err   <= iRX_ST_ERR;
    rx_st_in.bar   <= iRX_ST_BAR;
    irx_st_data    <= iRX_ST_DATA;
  end

// The following fifos are used to throttle the arrival of the TLP packets.

// FIFO - write the RX AVALON CONTROL SIGNALS

wire      ctrl_almost_full;
wire      ctrl_almost_empty;
wire      ctrl_underflow;
wire      ctrl_wr_rst_busy;
wire      ctrl_rd_rst_busy;
wire      ctrl_overflow;
tlp_decode_sc_fifo_48x8 sc_fifo_48x8_inst
(
 . almost_full          ( ctrl_almost_full                                   ), // output
 . almost_empty         ( ctrl_almost_empty                                  ), // output
 . underflow            ( ctrl_underflow                                     ), // output
 . wr_rst_busy          ( ctrl_wr_rst_busy                                   ), // output
 . rd_rst_busy          ( ctrl_rd_rst_busy                                   ), // output
 . overflow             ( ctrl_overflow                                      ), // output
 . din                  ( rx_st_in                                           ), 
 . full                 (                                                    ), 
 . dout                 ( rx_st                                              ), 
 . data_count           (                                                    ), // fixme 3 vs 4
 . clk                  ( iCLK                                               ), 
 . wr_en                ( rx_st_in.valid                                     ), 
 . rd_en                ( fifo_rd                                            ), 
 . rst                  ( iRST                                               ), 
 . empty                ( fifo_empty                                         )  
);



// FIFO - write the RX AVALON DATA

wire      data_almost_full;
wire      data_almost_empty;
wire      data_underflow;
wire      data_wr_rst_busy;
wire      data_rd_rst_busy;
wire      data_overflow;
tlp_decode_sc_fifo_256x8 sc_fifo_256x8_inst
(
 . almost_full          ( data_almost_full                                   ), // output
 . almost_empty         ( data_almost_empty                                  ), // output
 . underflow            ( data_underflow                                     ), // output
 . wr_rst_busy          ( data_wr_rst_busy                                   ), // output
 . rd_rst_busy          ( data_rd_rst_busy                                   ), // output
 . overflow             ( data_overflow                                      ), // output
 . din                  ( irx_st_data                                        ), 
 . full                 (                                                    ), 
 . dout                 ( rx_st_data                                         ), 
 . data_count           (                                                    ), 
 . clk                  ( iCLK                                               ), 
 . wr_en                ( rx_st_in.valid                                     ), 
 . rd_en                ( fifo_rd                                            ), 
 . rst                  ( iRST                                               ), 
 . empty                (                                                    )  
);


end : gen_bali

endgenerate

//////////////////////////////////////////////////////////////////////////////
//
// TLP Decode Logic
//
//////////////////////////////////////////////////////////////////////////////
assign  hdr0 = hdr0_type'(rx_st_data[31:0]);
assign  hdr1 = hdr1_type'(rx_st_data[63:32]);
assign  hdr2 = hdr2_type'(rx_st_data[95:64]);
//      RSVD = rx_st_data[127:96]; // See Altera table A-10. MWr 32-bit addressing, this is reserved so data offset same with 64-bit addressing
assign  wrdata[63:0] = rx_st_data[191:128];


is_unsupported_request is_unsupported_request_inst
(
  .fmt      (hdr0.fmt),
  .frm_type (hdr0.frm_type),
  .out      (tlp_ur_int)
);

is_non_posted is_non_posted_inst
(
 .fmt      (hdr0.fmt),
 .frm_type (hdr0.frm_type),
 .out      (tlp_non_posted_int)
);

always @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    hdr0_r1   <= '{default:0};
    hdr1_r1   <= '{default:0};
    hdr2_r1   <= '{default:0};
    wrdata_r1 <= '0;

    tlp_3dw_4dw_n      <= 1'b0;
    tlp_addr_qwaligned <= 1'b0;

    trans_type <= None;
    tlp_mrd    <= 1'b0;
    tlp_mwr    <= 1'b0;
    tlp_ur     <= 1'b0;
    tlp_non_posted <= 1'b0;
    tlp_ep     <= 1'b0;
  end
  else
  begin
    if(rx_st.valid && rx_st.sop)
    begin
      hdr0_r1 <= hdr0;
      hdr1_r1 <= hdr1;
      hdr2_r1 <= hdr2;
      wrdata_r1 <= wrdata;

      tlp_ep <= hdr0.ep; // poison (error fwd) (only applies to MWr & CplD)
      tlp_ur <= tlp_ur_int;
      tlp_non_posted <= tlp_non_posted_int;

      if(hdr0.fmt[0] == 1'b0) // If 3DW
      begin
        tlp_3dw_4dw_n <= 1'b1;
        tlp_addr_qwaligned <= (hdr2.addr[0]) ? 1'b0 : 1'b1; // bits 0/1=0=reserved so only check bit 2
      end
      else                   // then 4DW (not supported)
      begin
        tlp_3dw_4dw_n <= 1'b0;
        tlp_addr_qwaligned <= 1'b0; // should never happen.
      end

      if(hdr0.fmt[1] == 1'b0 && hdr0.frm_type == 5'b0)      // MRd Request
      begin
        trans_type <= MRd;
        tlp_mrd <= 1'b1;
        tlp_mwr <= 1'b0;
      end
      else if(hdr0.fmt[1] == 1'b1 && hdr0.frm_type == 5'b0) // MWr Request
      begin
        trans_type <= MWr;
        tlp_mrd <= 1'b0;
        tlp_mwr <= 1'b1;
      end
      else  // otherwise unsupported request
      begin
        // PCIe Spec: 2.7.2.2:
        // A Poisoned I/O or Memory Write Request, or a Message with data (except for vendor-defined
        // 25 Messages), that addresses a control register or control structure in the Completer must be
        // handled as an Unsupported Request (UR) by the Completer (see Section 2.2.9).
        trans_type <= Unsupported;
        tlp_mrd <= 1'b0;
        tlp_mwr <= 1'b0;
        // optional todo: assert pulse on: cpl_err[5:4] to update cfg space with UR for posted/non-posted TLP
      end
    end
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
  fifo_rd      = 1'b0;
  decode_valid = 1'b0;

  case(ps)
                 IDLE_ST: begin
                            if(!fifo_empty)          ns = RD_FIFO_ST;
                            else                     ns = IDLE_ST;
                          end
              RD_FIFO_ST: begin
                                                     fifo_rd      = 1'b1;
                                                     ns = DECODE_HOLD_ST;
                          end
          DECODE_HOLD_ST: begin
                                                     decode_valid = 1'b1;
                            //
                            // If a error-free and supported TLP received then wait for downstream modoule to
                            // finish, otherwise return immediately.  Or wait until Completion w/ unsupported status sent
                            if(iDONE_PULSE || tlp_ep_int || (!tlp_ur && !tlp_non_posted && (trans_type == Unsupported)))
                                                     ns = IDLE_ST;
                            else                     ns = DECODE_HOLD_ST;
                          end
                 default: begin
                                                     ns = IDLE_ST;
                          end
  endcase
end


endmodule
