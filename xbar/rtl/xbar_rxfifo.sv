/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author: gene.shen $
* $Date: 2013-10-21 12:51:52 -0700 (Mon, 21 Oct 2013) $
* $Revision: 3716 $
* $HeadURL: http://vi-bugs/svn/pld/trunk/dominica_dal/design/xbar/rtl/xbar_rxfifo.sv $
***********************************************************************************************************/
// auto_wire_reg ignore STORE_FORWARD
module xbar_rxfifo #(parameter STORE_FORWARD=0)      // store and forward mode, read waits until full frame
   (


    output reg [41:0]         tx_data_out,           // rx_data stream from RXFIFO with idle insertion
    output reg                tx_data_val,           // tx_data_out is valid
    output reg                rxfifo_overflow,       // RXFIFO overflow - sticky
    output reg                rxfifo_underflow,      // RXFIFO underflow - sticky

    output                    rx_sof_cnt_en,         // increment SOF counter
    output                    rx_eof_cnt_en,         // increment EOF counter
    output                    rx_idle_cnt_en,        // increment IDLE counter

    input                     rx_data_val,           // rx data valid, used as write enable to RXFIFO
    input [39:0]              rx_data_in,            // rx_data from each link, synchronized to rx_clk
    input                     rx_clk,                // rx clock, difference frequency and phase from core clock
    input                     rx_rst_n,              // rx async reset
    input                     tx_clk,                // transmit clock, same frequency as core clock but different phase
    input                     tx_rst_n,              // rx async reset
    input                     rst_n                  // core clock async reset

   );

`include "xbar_rxfifo_autoreg.vh"
`include "vi_defines.vh"

   localparam   SOF   = 2'd1;
   localparam   EOF   = 2'd2;
   localparam   IDLE  = 2'd3;

   vi_fc_dec_40b vi_fc_dec_40b_inst
     (// Inputs
      .rx_data    (rx_data_in[39:0]),
      // Outputs
      .sof        (sof),
      .eof        (eof),
      .idle       (idle),
      .nos        (nos),
      .ols        (ols),
      .lr         (lr),
      .lrr        (lrr)
      );
   
   // ----------
   // RXFIFO CTL
   // ----------

   localparam SM_IDLE        = 3'h0;
   localparam SM_RD          = 3'h1;
   localparam SM_ERROR       = 3'h7;

   always @(posedge tx_clk or negedge tx_rst_n) begin
      if (~tx_rst_n)
        sm_state[2:0] <= SM_IDLE;
      else begin
         case (sm_state[2:0])

           // IDLE - wait for EOF
           SM_IDLE :
             sm_state[2:0] <= ~rxctl_rd_empty ? SM_RD : SM_IDLE;

           // IDLE - wait for EOF
           SM_RD :
             sm_state[2:0] <= sof_in_rxfifo ? SM_IDLE : SM_RD;

           default :
             sm_state[2:0] <= SM_IDLE;
         endcase // case (sm_state[2:0])
      end // else: !if(~tx_rst_n)
   end // always @ (posedge tx_clk or negedge tx_rst_n)

   assign sm_in_idle = (sm_state[2:0]==SM_IDLE);
   assign sm_in_rd   = (sm_state[2:0]==SM_RD);

   
   // ------
   // RXFIFO
   // ------
   // The RXFIFO operates in two modes.  In store and forward mode.  It decodes the incoming frame, and
   // identifies SOF, EOF, and IDLE primitives.  Frame data is written into the first word fall through
   // FIFO.  EOF primitives are passed through a separate control FIFO to the read interface to initiate
   // store and forward operation.

   s5_afifo_1024x42b s5_afifo_1024x42b_inst
     (// Outputs
      .q                      (rxfifo_rd_data[41:0]),
      .rdempty                (rxfifo_rd_empty),
      .rdfull                 (rxfifo_rd_full),
      .rdusedw                (rxfifo_rd_usedw[9:0]),
      .wrempty                (rxfifo_wr_empty),
      .wrfull                 (rxfifo_wr_full),
      .wrusedw                (rxfifo_wr_usedw[9:0]),
      // Inputs
      .aclr                   (~rst_n),
      .data                   ({rx_type_q[1:0],rx_data_q[39:0]}),
      .rdclk                  (tx_clk),
      .rdreq                  (rxfifo_rd_en),
      .wrclk                  (rx_clk),
      .wrreq                  (rx_data_val_q)
      );

   s5_afifo_32x1b s5_afifo_32x1b_inst
     (// Outputs
      .q                                (rxctl_rd_data),
      .rdempty                          (rxctl_rd_empty),
      .wrfull                           (rxctl_wr_full),
      // Inputs
      .data                             (1'b1),
      .rdclk                            (tx_clk),
      .rdreq                            (rxctl_rd_en),
      .wrclk                            (rx_clk),
      .wrreq                            (eof));
   
   always @(posedge rx_clk or negedge rx_rst_n) 
      rxfifo_overflow <= ~rx_rst_n ? 1'b0 :
                         (rxfifo_wr_full & rx_data_val_q) ? 1'b1 : rxfifo_overflow;
   always @(posedge rx_clk or negedge rx_rst_n) 
      rxfifo_underflow <= ~rx_rst_n ? 1'b0 :
                          (rxfifo_rd_empty & rxfifo_rd_en) ? 1'b1 : rxfifo_underflow;
   

   // RXFIFO Write
   // ------------
   // Incoming write data is pipelined to allow decode.  Write when rx_data is valid

   // pipeline all the signals by one cycle to allow idle/eof/sof decode
   always @(posedge rx_clk or negedge rx_rst_n) begin
      rx_data_q[39:0] <= ~rx_rst_n ? 40'd0 : rx_data_in;
      rx_type_q[1:0]  <= ~rx_rst_n ? 2'd0  : 
                         sof       ? SOF   :
                         eof       ? EOF   :
                         (idle | nos | ols | lr | lrr) ? IDLE  : 2'd0;
      rx_data_val_q   <= ~rx_rst_n ? 1'd0  : rx_data_val;
   end

   // RXFIFO Read
   // ------------
   // The RXFIFO is a FWFT FIFO.  In regular (non store and forward mode), the FIFO is read whenever
   // it is non-empty.  In store and forward mode, the reads are triggered on a EOF in the control FIFO.
   // Reads continue until a SOF is detected in the next word.  Idles are always read,
   
   always @(posedge tx_clk or negedge tx_rst_n) begin
      tx_data_out[41:0] <= ~tx_rst_n          ? 42'd0 : rxfifo_rd_data[41:0];
      tx_data_val       <= ~tx_rst_n          ? 1'b0  :
                           (STORE_FORWARD==1) ? rxfifo_rd_en : rxfifo_rd_empty;
   end
   
//   always @(posedge tx_clk or negedge tx_rst_n) begin
//      rxfifo_reading_q   <= ~tx_rst_n     ? 1'b0 : 
//                          rxctl_rd_en   ? 1'b1 :
//                          sof_in_rxfifo ? 1'b0 : rxfifo_reading_q;
//   end

   assign rxfifo_rd_en = (sm_in_rd & ~sof_in_rxfifo) | rxctl_rd_en | idle_in_rxfifo;
   assign rxctl_rd_en  = (sm_in_idle & ~rxctl_rd_empty);

   // decode
   assign sof_in_rxfifo  =  (rxfifo_rd_data[41:40]==SOF);
   assign idle_in_rxfifo =  (rxfifo_rd_data[41:40]==IDLE);
   
   
   // ---------------
   // Stats and Debug
   // ---------------

   assign rx_sof_cnt_en  = sof;
   assign rx_eof_cnt_en  = eof;
   assign rx_idle_cnt_en = idle;
   

endmodule 

// Local Variables:
// verilog-library-directories:("." "auto/" "ip/")
// verilog-library-extensions:(".v" ".sv" ".h" "v.h")
// End:
