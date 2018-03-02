/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author$
* $Date$
* $Revision$
* $HeadURL$
* Description: Single channel PHY module
***********************************************************************************************************/

module pma_1ch #(
        parameter SIM_ONLY             =  0,
        parameter LOW_LATENCY_PHY  =  0,
        parameter PHASE_COMP       =  0
) (
        //-----------------
        // Clocks and Reset
        //------------------
        
        output  rx_pma_clkout,                  //  recovered clock from CDR
        output  tx_pma_clkout,          // transmit clock
        input   ext_pll_clk_425,                    //  bit time clock
        input   ext_pll_clk_219,                    //  bit time clock
        input   clk,                            //  core clock (219Mhz)
        input   rst_n,                          //  asynchronous reset
        input   tx_rst_n,                       //  asynchronous reset
        input   rx_rst_n,                       //  rx clock domain reset
        input   rst,                            //  asynchronous reset
        input   rx_cdr_refclk_425,                  //  reference clock for RX phase frequency detector (PFD)
        input   rx_cdr_refclk_219,                  //  reference clock for RX phase frequency detector (PFD)
        input   tx_pma_clk,
        
        
        // --------------------------
        // Control Register Interface
        // --------------------------
        
        input   [63:0]                         oSERDES_MM_WR_DATA,
        input   [13:0]                         oSERDES_MM_ADDR,
        input   oSERDES_MM_WR_EN,
        input   oSERDES_MM_RD_EN,
        output  [63:0]                         iSERDES_MM_RD_DATA,
        output  iSERDES_MM_RD_DATA_V,
        input   cfg_tx_invert,
        input   cfg_rx_invert,
				input   cfg_rx_slip,
        
        
        //-----------------
        // PHY Interface
        //------------------
        
        // link engine
        
        // reset controller
        input   rx_ready,                       //  rx_ready from reset controller - output in debug status register
        input   rx_analogreset,
        input   rx_digitalreset,
        input   tx_ready,                       //  tx_ready from reset controller - output in debug status register
        input   tx_analogreset,
        input   tx_digitalreset,
        output  rx_cal_busy,
        output  tx_cal_busy,
        //    output            cdr_is_locked,
        output  rx_is_lockedtodata,
        input iSFP_LOS,
        
        // reconfiguration controller
        input   pll_powerdown_425,
        input   pll_powerdown_219,
        input   [69:0]                         reconfig_to_xcvr,
        output  [45:0]                         reconfig_from_xcvr,
        input   logic                                phy_mgmt_clk,
        input   logic                                phy_mgmt_clk_reset,
        input   logic [8:0]                          phy_mgmt_address,
        input   logic                                phy_mgmt_read,
        input   logic                                phy_mgmt_write,
        input   logic [31:0]                         phy_mgmt_writedata,
        output  wire    [31:0]                         phy_mgmt_readdata,
        output  wire    phy_mgmt_waitrequest,
        
        // Debug
        output  [15:0]                               debug, 
        
        // ATX PLL
        input   pll_locked_425,                     //  ATX PLL locked - output in debug status register
        input   pll_locked_219,                     //  ATX PLL locked - output in debug status register
        
        // data
        input   rx_serial_data,
        output  tx_serial_data,
        input   [63:0]                         tx_pma_parallel_data,            //  parallel data
        output  logic [63:0]                   rx_pma_parallel_data,             //  parallel data
        output  logic [63:0]           rx_parallel_data_pma,
        input   [63:0]           tx_parallel_data_pma,
				input   [3:0] data_rate,
				output logic locked_to_data

        
);


`include "vi_defines.vh"
`include "pma_1ch_autoreg.vh"

wire    [63:0]          unused_rx_data_phy, tx_data_phy, rx_data_phy;
reg     [63:0] rx_data_s;
wire    reg_ctl_rxinvert_sync, reg_ctl_txinvert_sync;
wire    phy_tx_pma_clkout       /* synthesis keep */;  
wire    phy_rx_pma_clkout       /* synthesis keep */;  
logic  [63:0] tx_data_mux;
logic [63:0] bist_data;

logic  sfp_los, sfp_los_r;

s5_altclkctrl_auto altclkctrl_rx_pma_inst
(.inclk        (phy_rx_pma_clkout),
        .outclk        (rx_pma_clkout));

logic data_rate_16g_txclk;

   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   data_rate_sync_tx
     (
      .out_level    ( data_rate_16g_txclk  ),
      .clk          ( tx_pma_clk          ),
      .rst_n        ( tx_rst_n        ),
      .in_level     ( data_rate[2]   )
      );


// flop parallel data - helps timing.  source flop driving into TxFIFO may be far away
always @(posedge tx_pma_clk) begin
        tx_pma_parallel_data_q[63:0] <= (data_rate_16g_txclk) ? tx_pma_parallel_data[63:0] : tx_parallel_data_pma;
        tx_data[63:0]                <= (reg_ctl_txinvert_sync ^ cfg_tx_invert) ? ~tx_data_mux[63:0] : tx_data_mux[63:0];
end

always @(posedge rx_pma_clkout or negedge rx_rst_n)
  if (!rx_rst_n)
	begin
    sfp_los   <= 1'b1;
    sfp_los_r <= 1'b1;
	end
	else 
	begin
    sfp_los   <= iSFP_LOS;
    sfp_los_r <= sfp_los;
	end

logic reg_ctl_rxinvert_sync_r, reg_ctl_rxinvert_sync_rr;
logic cfg_rx_invert_r, cfg_rx_invert_rr;

always @(posedge rx_pma_clkout) begin
  reg_ctl_rxinvert_sync_r <= reg_ctl_rxinvert_sync;
	reg_ctl_rxinvert_sync_rr <= reg_ctl_rxinvert_sync_r;
	cfg_rx_invert_r <= cfg_rx_invert;
	cfg_rx_invert_rr <= cfg_rx_invert_r;
end

localparam   D21_5  = 10'b101010_1010;
logic data_rate_16g_rxclk;

   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   data_rate_sync_rx
     (
      .out_level    ( data_rate_16g_rxclk  ),
      .clk          ( rx_pma_clkout          ),
      .rst_n        ( rx_rst_n        ),
      .in_level     ( data_rate[2]   )
     );

logic [23:0] lock_count;
logic pma_loslock;

   vi_sync_level #(.SIZE(1),
       .TWO_DST_FLOPS(1))
   pma_loslock_sync
     (
      .out_level    ( pma_loslock  ),
      .clk          ( rx_pma_clkout          ),
      .rst_n        ( rx_rst_n        ),
      .in_level     ( rx_analogreset || rx_digitalreset   )
     );

always @(posedge rx_pma_clkout or negedge rx_rst_n)
  if (!rx_rst_n)
		lock_count <= 'h0;
  else if (pma_loslock)
		lock_count <= 'h0;
	else if (~locked_to_data)
		lock_count <= lock_count + 1;

generate
  if (SIM_ONLY == 1)
    assign locked_to_data = 1'b1;	
	else

always @(posedge rx_pma_clkout or negedge rx_rst_n)
  if (!rx_rst_n)
		locked_to_data <= 1'b0;
	else
		locked_to_data <= lock_count[23];

endgenerate

// two pipeline register for timing.  
always @(posedge rx_pma_clkout) begin
        rx_data[63:0] <= rx_data_phy[63:0];
        //rx_data[63:0]               <= rx_data_s[63:0];
        rx_pma_parallel_data[63:0]  <= (~locked_to_data | sfp_los_r | ~data_rate_16g_rxclk) ? 64'h0 : bist_data;
        bist_data[63:0]  <= (reg_ctl_rxinvert_sync_rr ^ cfg_rx_invert_rr) ? ~rx_data[63:0] : rx_data[63:0];
        rx_parallel_data_pma[63:0]  <= (~locked_to_data | sfp_los_r | data_rate_16g_rxclk) ? {24'h0, D21_5,D21_5,D21_5,D21_5} : bist_data;
end


always @(posedge tx_pma_clk)
  tx_data_mux[63:0]              <=  (prbsctl_prbssel_tx_sync[1:0]!=2'd0)    ? tx_prbs[63:0]  : tx_pma_parallel_data_q[63:0];

wire    tx_ready_i;
wire    rx_ready_i;
wire    oREG_CTL_CDRLOCKOVERRIDE;
wire                 rx_set_locktodata;
wire                 rx_set_locktoref;


//assign rx_parallel_data_pma = rx_pma_parallel_data;

s5_native_phy_16gbps s5_native_phy_16gbps_inst(
    .pll_powerdown({pll_powerdown_425, pll_powerdown_219}),      //      pll_powerdown.pll_powerdown
    .tx_analogreset(tx_analogreset),     //     tx_analogreset.tx_analogreset
    .tx_digitalreset(tx_digitalreset),    //    tx_digitalreset.tx_digitalreset
    .tx_serial_data(tx_serial_data),     //     tx_serial_data.tx_serial_data
    .ext_pll_clk({ext_pll_clk_425, ext_pll_clk_219}),        //        ext_pll_clk.ext_pll_clk
    .rx_analogreset(rx_analogreset),     //     rx_analogreset.rx_analogreset
    .rx_digitalreset(rx_digitalreset),    //    rx_digitalreset.rx_digitalreset
    .rx_cdr_refclk({rx_cdr_refclk_425, rx_cdr_refclk_219}),      //      rx_cdr_refclk.rx_cdr_refclk
    .rx_pma_clkout(),      //      rx_pma_clkout.rx_pma_clkout
    .rx_serial_data(rx_serial_data),     //     rx_serial_data.rx_serial_data
    .rx_clkslip(cfg_rx_slip),         //         rx_clkslip.rx_clkslip
    .rx_set_locktodata(rx_set_locktodata),  //  rx_set_locktodata.rx_set_locktodata
    .rx_set_locktoref(rx_set_locktoref),   //   rx_set_locktoref.rx_set_locktoref
    .rx_is_lockedtoref(rx_is_lockedtoref),  //  rx_is_lockedtoref.rx_is_lockedtoref
    .rx_is_lockedtodata(rx_is_lockedtodata), // rx_is_lockedtodata.rx_is_lockedtodata
    .rx_seriallpbken(oREG_CTL_SERIALLPBKEN),    //    rx_seriallpbken.rx_seriallpbken
    .tx_parallel_data(tx_data),   //   tx_parallel_data.tx_parallel_data
    .rx_parallel_data(rx_data_phy),   //   rx_parallel_data.rx_parallel_data
    .tx_10g_coreclkin(tx_pma_clk),   //   tx_10g_coreclkin.tx_10g_coreclkin
    .rx_10g_coreclkin(rx_pma_clkout),   //   rx_10g_coreclkin.rx_10g_coreclkin
    .tx_10g_clkout(tx_pma_clkout),      //      tx_10g_clkout.tx_10g_clkout  <<<< NC
    .rx_10g_clkout(phy_rx_pma_clkout),      //      rx_10g_clkout.rx_10g_clkout
    .tx_10g_control({9{1'b0}}),     //     tx_10g_control.tx_10g_control
    .rx_10g_control(),     //     rx_10g_control.rx_10g_control
    .tx_10g_data_valid(1'b1),  //  tx_10g_data_valid.tx_10g_data_valid 
		.tx_cal_busy(tx_cal_busy),        //        tx_cal_busy.tx_cal_busy
    .rx_cal_busy(rx_cal_busy),        //        rx_cal_busy.rx_cal_busy
    .reconfig_to_xcvr(reconfig_to_xcvr[69:0]),   //   reconfig_to_xcvr.reconfig_to_xcvr
    .reconfig_from_xcvr(reconfig_from_xcvr[45:0])  // reconfig_from_xcvr.reconfig_from_xcvr
  );

//-------------------------
// PRBS Instantiation
//-------------------------

pma_prbs pma_prbs_inst
(
        // Outputs
        .tx_prbs                               (tx_prbs[63:0]),
        .prbs_error_cnt                        (prbs_error_cnt[15:0]),
        .prbs_bit_cnt                          (prbs_bit_cnt[47:0]),
        .prbs_inj_err_cnt                      (prbs_inj_err_cnt[15:0]),
        .prbs_not_locked_cnt                   (prbs_not_locked_cnt[31:0]),
        .prbs_lock_state                       (prbs_lock_state),
        // Inputs
				.iSFP_LOS                              (sfp_los_r && ~oREG_CTL_SERIALLPBKEN),
        .rx_pma_parallel_data                  (bist_data[63:0]),
				.data_rate                             (data_rate),
        .prbs_mode_rx                          (prbsctl_prbssel_rx_sync[1:0]),
        .prbs_mode_tx                          (prbsctl_prbssel_tx_sync[1:0]),
        .prbs_error_cnt_clr                    (prbs_error_cnt_clr),
        .prbs_error_cnt_clr_tx                 (prbs_error_cnt_clr_tx),
        .prbs_bit_cnt_clr                      (prbs_bit_cnt_clr),
        .prbs_not_locked_cnt_clr               (prbs_not_locked_cnt_clr),
        .prbs_inj_error                        (prbs_inj_error),
        .rx_clk                                (rx_pma_clkout),
        //      .tx_clk                         (tx_pma_clkout),
        .tx_clk                                (tx_pma_clk),
        .rx_rst_n                              (rx_rst_n),
        .tx_rst_n                              (tx_rst_n));


//-------------------------
// Control/Debug Registers
//-------------------------
// The control registers are in the core clock domain to provide a constant clock.  The inputs are from different clock domains
// and are not synchronized to save on flops.

pma_1ch_regs pma_1ch_regs_inst
(       // Manual Inputs
        .wr_en                                 (oSERDES_MM_WR_EN),
        .rd_en                                 (oSERDES_MM_RD_EN),
        .addr                                  (oSERDES_MM_ADDR[9:0]),
        .wr_data                               (oSERDES_MM_WR_DATA),
        .iREG_STATUS_TXREADY                   (tx_ready),
        .iREG_STATUS_RXREADY                   (rx_ready),
        .iREG_STATUS_LINKSPEED                 (data_rate),
        .iREG_STATUS_PLLLOCKED_425                 (pll_locked_425),
        .iREG_STATUS_PLLLOCKED_219                 (pll_locked_219),
        .iREG_STATUS_RXLOCKEDTODATA            (rx_is_lockedtodata),
        .iREG_STATUS_RXLOCKEDTOREF             (rx_is_lockedtoref),
        .iREG_STATUS_RXCALBUSY                 (rx_cal_busy),
        .iREG_STATUS_TXCALBUSY                 (tx_cal_busy),
        .iREG_STATUS_RXANALOGRST               (rx_analogreset),
        .iREG_STATUS_RXDIGITALRST              (rx_digitalreset),
        .iREG_STATUS_TXANALOGRST               (tx_analogreset),
        .iREG_STATUS_TXDIGITALRST              (tx_digitalreset),
        .iREG_STATUS_PLLPWRDN                  (pll_powerdown),
        .iREG_RXDATA                           (bist_data[63:0]),
        .iREG_TXDATA                           (tx_pma_parallel_data_q[63:0]),
        .iREG_PRBSERRCNT                       (prbs_error_cnt[15:0]),
        .iREG_PRBSRXCNT                        (prbs_bit_cnt[47:0]),
        .iREG_PRBSNOTLOCKEDCNT                 (prbs_not_locked_cnt[31:0]),
        .iREG_PRBSLOCK                         (prbs_lock_state),
        .iREG_PRBSINJERRCNT		       (prbs_inj_err_cnt[15:0]),
        .clk                                   (clk),
        .rst_n                                 (rst_n),
        // Manual Outputs
        .rd_data                               (iSERDES_MM_RD_DATA[63:0]),
        .rd_data_v                             (iSERDES_MM_RD_DATA_V),
        /*AUTOINST*/
        // Outputs
        .oREG_CTL_RXINVERT		       (oREG_CTL_RXINVERT),
        .oREG_CTL_TXINVERT		       (oREG_CTL_TXINVERT),
        .oREG_CTL_EYEVCLEAR		       (oREG_CTL_EYEVCLEAR),
        .oREG_CTL_EYEHCLEAR		       (oREG_CTL_EYEHCLEAR),
        .oREG_CTL_CDRLOCKOVERRIDE                           ( oREG_CTL_CDRLOCKOVERRIDE                           ), // output
        .oREG_CTL_TXMUXSEL		       (oREG_CTL_TXMUXSEL),
        .oREG_CTL_CDRLOCKMODE		       (oREG_CTL_CDRLOCKMODE[1:0]),
        .oREG_CTL_SERIALLPBKEN		       (oREG_CTL_SERIALLPBKEN),
        .oREG_CTL_RXRESET			       (oREG_CTL_RXRESET),
        .oREG_CTL_TXRESET			       (oREG_CTL_TXRESET),
        .oREG_PRBSCTL_NOTLOCKEDCNTCLR	               (oREG_PRBSCTL_NOTLOCKEDCNTCLR),
        .oREG_PRBSCTL_RXCNTCLR		               (oREG_PRBSCTL_RXCNTCLR),
        .oREG_PRBSCTL_ERRCNTCLR		               (oREG_PRBSCTL_ERRCNTCLR),
        .oREG_PRBSCTL_INJERR		               (oREG_PRBSCTL_INJERR),
        .oREG_PRBSCTL_PRBSSEL		               (oREG_PRBSCTL_PRBSSEL[1:0]),
        .oREG__SCRATCH			               (oREG_SCRATCH[63:0]));

vi_sync_level #(.SIZE  (3)) vi_sync_level_tx_clk
(       // Outputs
        .out_level             ({prbsctl_prbssel_tx_sync[1:0],
        reg_ctl_txinvert_sync}),
        // Inputs
        .clk                   (tx_pma_clk),
        .rst_n                 (tx_rst_n),
        .in_level              ({oREG_PRBSCTL_PRBSSEL[1:0],
        oREG_CTL_TXINVERT}));

vi_sync_level #(.SIZE          (3)) vi_sync_level_rx_clk
(       // Outputs
        .out_level             ({reg_ctl_rxinvert_sync,
        prbsctl_prbssel_rx_sync[1:0]}),
        // Inputs
        .clk                   (rx_pma_clkout),
        .rst_n                 (rx_rst_n),
        .in_level              ({oREG_CTL_RXINVERT,
        oREG_PRBSCTL_PRBSSEL[1:0]}));

// edge detect to generate a single cycle pulse

always @(posedge clk or negedge rst_n) begin
        prbs_error_cnt_clr_q      <= ~rst_n ? 1'd0 : oREG_PRBSCTL_ERRCNTCLR;
        prbs_bit_cnt_clr_q        <= ~rst_n ? 1'd0 : oREG_PRBSCTL_RXCNTCLR;
        prbs_not_locked_cnt_clr_q <= ~rst_n ? 1'd0 : oREG_PRBSCTL_NOTLOCKEDCNTCLR;
        prbs_inj_error_q          <= ~rst_n ? 1'd0 : oREG_PRBSCTL_INJERR;
end

assign  prbs_error_cnt_clr_edge        =  (~prbs_error_cnt_clr_q & oREG_PRBSCTL_ERRCNTCLR);
assign  prbs_bit_cnt_clr_edge          =  (~prbs_bit_cnt_clr_q & oREG_PRBSCTL_RXCNTCLR);
assign  prbs_not_locked_cnt_clr_edge   =  (~prbs_not_locked_cnt_clr_q & oREG_PRBSCTL_NOTLOCKEDCNTCLR);
assign  prbs_inj_error_edge            =  (~prbs_inj_error_q & oREG_PRBSCTL_INJERR);

// transfer the pulses from core clock domain to RX clock domain

vi_sync_pulse vi_sync_pulse_error_cnt_clr_tx
(       // Outputs
        .out_pulse                             (prbs_error_cnt_clr_tx),
        // Inputs
        .rsta_n                                (rst_n),
        .clka                                  (clk),
        .in_pulse                              (prbs_error_cnt_clr_edge),
        .rstb_n                                (tx_rst_n),
        .clkb                                  (tx_pma_clk));

vi_sync_pulse vi_sync_pulse_error_cnt_clr
(       // Outputs
        .out_pulse                             (prbs_error_cnt_clr),
        // Inputs
        .rsta_n                                (rst_n),
        .clka                                  (clk),
        .in_pulse                              (prbs_error_cnt_clr_edge),
        .rstb_n                                (rx_rst_n),
        .clkb                                  (rx_pma_clkout));
vi_sync_pulse vi_sync_pulse_bit_cnt_clr
(       // Outputs
        .out_pulse                             (prbs_bit_cnt_clr),
        // Inputs
        .rsta_n                                (rst_n),
        .clka                                  (clk),
        .in_pulse                              (prbs_bit_cnt_clr_edge),
        .rstb_n                                (rx_rst_n),
        .clkb                                  (rx_pma_clkout));
vi_sync_pulse vi_sync_pulse_not_locked_cnt_clr
(       // Outputs
        .out_pulse                             (prbs_not_locked_cnt_clr),
        // Inputs
        .rsta_n                                (rst_n),
        .clka                                  (clk),
        .in_pulse                              (prbs_not_locked_cnt_clr_edge),
        .rstb_n                                (rx_rst_n),
        .clkb                                  (rx_pma_clkout));

vi_sync_pulse pulse_inj_err
(       // Outputs
        .out_pulse                             (prbs_inj_error),
        // Inputs
        .rsta_n                                (rst_n),
        .clka                                  (clk),
        .in_pulse                              (prbs_inj_error_edge),
        .rstb_n                                (tx_rst_n),
        //      .clkb                           (tx_pma_clkout));
        .clkb                                  (tx_pma_clk));

assign  debug[13:0]    =  {2'b00,
        pll_locked_219,
        pll_locked_425,
        pll_powerdown,          // 11
        rx_digitalreset,        // 10
        rx_analogreset,         // 9
        tx_digitalreset,        // 8
        tx_analogreset,         // 7
        tx_cal_busy,            // 6
        rx_cal_busy,            // 5
        rx_is_lockedtoref,      // 4
        rx_is_lockedtodata,     // 3
        1'b0, //pll_locked,             // 2
        rx_ready,               // 1
        tx_ready                // 0
        };

   //do not use the flopped version here, since this bit actually controlls
	 //clock mux
   assign {rx_set_locktoref,rx_set_locktodata} = oREG_CTL_CDRLOCKOVERRIDE == 0 ? (iSFP_LOS        ? 2'b10 : oREG_CTL_CDRLOCKMODE) :
                                                                                 oREG_CTL_CDRLOCKMODE;

endmodule

// Local Variables:
// verilog-library-directories:("../../../ext_lib" "../../../lib/serdes_pat_gen_chk/"  "../../fc8pma/rtl/ip/s5_afifo_32x40b/" "../../fc8pma/rtl/ip/s5_native_phy_8G/" "." "auto" "../../../../common/vi_lib" "../")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:


