// This file is auto generated by auto_wire_reg.pl - revision 0.5
// Input file: /home/lzhou/proj/sandbox9/trunk/dominica_dal/design/pma/rtl/pma_1ch.sv
// Do not modify this file because it will be overwritten when it is auto generated again.
reg  [63:0]                         tx_pma_parallel_data_q;        // from pma_1ch.sv:201:      tx_pma_parallel_data_q[63:0] <= tx_pma_parallel_data[63:0];
reg  [63:0]                         tx_data;                       // from pma_1ch.sv:202:      tx_data[63:0]                <= (reg_ctl_txinvert_sync ^ cfg_tx_invert) ? ~tx_data_mux[63:0] : tx_data_mux[63:0];
reg  [63:0]                         rx_data;                       // from pma_1ch.sv:207:      rx_data[63:0]               <= rx_data_phy[63:0];
reg                                 prbs_error_cnt_clr_q;          // from pma_1ch.sv:486:       prbs_error_cnt_clr_q      <= ~rst_n ? 1'd0 : oREG_PRBSCTL_ERRCNTCLR;
reg                                 prbs_bit_cnt_clr_q;            // from pma_1ch.sv:487:       prbs_bit_cnt_clr_q        <= ~rst_n ? 1'd0 : oREG_PRBSCTL_RXCNTCLR;
reg                                 prbs_not_locked_cnt_clr_q;     // from pma_1ch.sv:488:       prbs_not_locked_cnt_clr_q <= ~rst_n ? 1'd0 : oREG_PRBSCTL_NOTLOCKEDCNTCLR;
reg                                 prbs_inj_error_q;              // from pma_1ch.sv:489:       prbs_inj_error_q          <= ~rst_n ? 1'd0 : oREG_PRBSCTL_INJERR;
wire                                prbs_error_cnt_clr_edge;       // from pma_1ch.sv:492:    assign prbs_error_cnt_clr_edge       = (~prbs_error_cnt_clr_q & oREG_PRBSCTL_ERRCNTCLR);
wire                                prbs_bit_cnt_clr_edge;         // from pma_1ch.sv:493:    assign prbs_bit_cnt_clr_edge         = (~prbs_bit_cnt_clr_q & oREG_PRBSCTL_RXCNTCLR);
wire                                prbs_not_locked_cnt_clr_edge;  // from pma_1ch.sv:494:    assign prbs_not_locked_cnt_clr_edge  = (~prbs_not_locked_cnt_clr_q & oREG_PRBSCTL_NOTLOCKEDCNTCLR);
wire                                prbs_inj_error_edge;           // from pma_1ch.sv:495:    assign prbs_inj_error_edge           = (~prbs_inj_error_q & oREG_PRBSCTL_INJERR);
wire                                rx_is_lockedtoref;             // from pma_1ch.sv:375:       .iREG_STATUS_RXLOCKEDTOREF        (rx_is_lockedtoref),
wire                                oREG_CTL_SERIALLPBKEN;         // from pma_1ch.sv:403:       .oREG_CTL_SERIALLPBKEN		(oREG_CTL_SERIALLPBKEN),
wire [63:0]                         tx_prbs;                       // from pma_1ch.sv:336:       .tx_prbs                          (tx_prbs[63:0]),
wire [15:0]                         prbs_error_cnt;                // from pma_1ch.sv:385:       .iREG_PRBSERRCNT                  (prbs_error_cnt[15:0]),
wire [47:0]                         prbs_bit_cnt;                  // from pma_1ch.sv:386:       .iREG_PRBSRXCNT                   (prbs_bit_cnt[47:0]),
wire [15:0]                         prbs_inj_err_cnt;              // from pma_1ch.sv:389:       .iREG_PRBSINJERRCNT		(prbs_inj_err_cnt[15:0]),
wire [31:0]                         prbs_not_locked_cnt;           // from pma_1ch.sv:387:       .iREG_PRBSNOTLOCKEDCNT            (prbs_not_locked_cnt[31:0]),
wire                                prbs_lock_state;               // from pma_1ch.sv:388:       .iREG_PRBSLOCK                    (prbs_lock_state),
wire [1:0]                          prbsctl_prbssel_rx_sync;       // from pma_1ch.sv:344:       .prbs_mode_rx                     (prbsctl_prbssel_rx_sync[1:0]),
wire [1:0]                          prbsctl_prbssel_tx_sync;       // from pma_1ch.sv:345:       .prbs_mode_tx                     (prbsctl_prbssel_tx_sync[1:0]),
wire                                prbs_error_cnt_clr;            // from pma_1ch.sv:510:       .out_pulse                        (prbs_error_cnt_clr),
wire                                prbs_error_cnt_clr_tx;         // from pma_1ch.sv:501:       .out_pulse                        (prbs_error_cnt_clr_tx),
wire                                prbs_bit_cnt_clr;              // from pma_1ch.sv:519:       .out_pulse                        (prbs_bit_cnt_clr),
wire                                prbs_not_locked_cnt_clr;       // from pma_1ch.sv:528:       .out_pulse                        (prbs_not_locked_cnt_clr),
wire                                prbs_inj_error;                // from pma_1ch.sv:537:       .out_pulse                        (prbs_inj_error),
wire                                oREG_CTL_RXINVERT;             // from pma_1ch.sv:397:       .oREG_CTL_RXINVERT		(oREG_CTL_RXINVERT),
wire                                oREG_CTL_TXINVERT;             // from pma_1ch.sv:398:       .oREG_CTL_TXINVERT		(oREG_CTL_TXINVERT),
wire                                oREG_CTL_EYEVCLEAR;            // from pma_1ch.sv:399:       .oREG_CTL_EYEVCLEAR		(oREG_CTL_EYEVCLEAR),
wire                                oREG_CTL_EYEHCLEAR;            // from pma_1ch.sv:400:       .oREG_CTL_EYEHCLEAR		(oREG_CTL_EYEHCLEAR),
wire                                oREG_CTL_TXMUXSEL;             // from pma_1ch.sv:401:       .oREG_CTL_TXMUXSEL		(oREG_CTL_TXMUXSEL),
wire [1:0]                          oREG_CTL_CDRLOCKMODE;          // from pma_1ch.sv:402:       .oREG_CTL_CDRLOCKMODE		(oREG_CTL_CDRLOCKMODE[1:0]),
wire                                oREG_CTL_RXRESET;              // from pma_1ch.sv:404:       .oREG_CTL_RXRESET			(oREG_CTL_RXRESET),
wire                                oREG_CTL_TXRESET;              // from pma_1ch.sv:405:       .oREG_CTL_TXRESET			(oREG_CTL_TXRESET),
wire                                oREG_PRBSCTL_NOTLOCKEDCNTCLR;  // from pma_1ch.sv:406:       .oREG_PRBSCTL_NOTLOCKEDCNTCLR	(oREG_PRBSCTL_NOTLOCKEDCNTCLR),
wire                                oREG_PRBSCTL_RXCNTCLR;         // from pma_1ch.sv:407:       .oREG_PRBSCTL_RXCNTCLR		(oREG_PRBSCTL_RXCNTCLR),
wire                                oREG_PRBSCTL_ERRCNTCLR;        // from pma_1ch.sv:408:       .oREG_PRBSCTL_ERRCNTCLR		(oREG_PRBSCTL_ERRCNTCLR),
wire                                oREG_PRBSCTL_INJERR;           // from pma_1ch.sv:409:       .oREG_PRBSCTL_INJERR		(oREG_PRBSCTL_INJERR),
wire [1:0]                          oREG_PRBSCTL_PRBSSEL;          // from pma_1ch.sv:410:       .oREG_PRBSCTL_PRBSSEL		(oREG_PRBSCTL_PRBSSEL[1:0]),
wire [63:0]                         oREG_SCRATCH;                  // from pma_1ch.sv:411:       .oREG_SCRATCH			(oREG_SCRATCH[63:0]));
