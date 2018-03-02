module top_fc_w_fifo #(
  parameter                            CORE_VERSION                   = 1,            //  MorethanIP Core Version, // MorethanIP Core Version
  parameter                            CORE_REVISION                  = 1,            //  MorethanIP Core Revision, // MorethanIP Core Revision
  parameter                            CUST_VERSION                   = 1,            //  Customer Core Version, // Customer Core Version
  parameter                            EG_FIFO                        = 256 ,         //  Egress FIFO Depth, // Egress FIFO Depth
  parameter                            EG_ADDR                        = 8 ,           //  Egress FIFO Depth, // Egress FIFO Depth
  parameter                            ING_FIFO                       = 256 ,         //  Ingress FIFO Depth, // Ingress FIFO Depth
  parameter                            ING_ADDR                       = 8 ,           //  Egress FIFO Depth, // Egress FIFO Depth
  parameter                            ENA_32                         = 1             //  Enable 32-Bit Client Interface  // Enable 32-Bit Client Interface
) (
  input                                       reset_rx_clk,                  //   Asynchronous Reset - rx_clk Clock Domain
  input                                       reset_tx_clk,                  //   Asynchronous Reset - tx_clk Clock Domain
  input                                       reset_ff_rx_clk,               //   Asynchronous Reset - ff_rx_clk Clock Domain
  input                                       reset_ff_tx_clk,               //   Asynchronous Reset - ff_tx_clk Clock Domain
  input                                       rx_clk,                        //   Receive Line Clock
  input                                       tx_clk,                        //   Transmit Line Clock
  input        [39:0]                         rx_phy_data,                   //   Non Aligned Receive PHY Data
  input                                       rx_phy_los,                    //   Loss of Signal Indication
  output logic [39:0]                         tx_phy_data,                   //   Transmit PHY Data
  input                                       ff_rx_clk,                     //   Receive Local Clock
  output logic [31:0]                         ff_rx_data,                    //   Data Out
  output logic                                ff_rx_sop,                     //   Start of Packet
  output logic                                ff_rx_eop,                     //   End of Packet
  output logic [1:0]                          ff_rx_mod,                     //   Frame Modulo
  output logic                                ff_rx_err,                     //   Errored Packet Indication
  output logic [3:0]                          ff_rx_class,                   //   Frame Class
  output logic [7:0]                          ff_rx_err_stat,                //   Errored Packet Status Word
  input                                       ff_rx_rdy,                     //   Application Ready
  output logic                                ff_rx_dval,                    //   Data Valid
  output logic                                ff_rx_dsav,                    //   Data Available in Receive FIFO
  input                                       ff_tx_clk,                     //   Transmit Local Clock
  input        [31:0]                         ff_tx_data,                    //   Receive Data
  input                                       ff_tx_sop,                     //   Start of Packet
  input                                       ff_tx_eop,                     //   End of Packet
  input        [1:0]                          ff_tx_mod,                     //   Packet Modulo
  input                                       ff_tx_err,                     //   Packet Error
  input                                       ff_tx_wren,                    //   Link Layer FIFO Almost Full
  input        [3:0]                          ff_tx_class,                   //   Frame Class
  input        [3:0]                          ff_tx_end_code,                //   Frame Terminasion Code
  input                                       ff_tx_crc_fwd,                 //   Forward Frame with CRC from Application
  input                                       ff_tx_crc_chk,                 //   Check CRC from Application
  input                                       ff_tx_sof_eof,                 //   Enable Frame Transfer with EOF/SOF Fields
  output logic                                ff_tx_septy,                   //   Data Section Free in FIFO
  output logic                                ff_tx_rdy,                     //   FIFO Ready to Accept Data
  input        [31:0]                         ff_tx_ipg,                     //   Transmit IPG
  input        [ING_ADDR - 1:0]               rx_sav_section,                //   Section Threshold ff_rx_dsav and Start Data Transfers
  input        [ING_ADDR - 1:0]               rx_af_level,                   //   Almost Full Threshold
  input        [ING_ADDR - 1:0]               rx_ae_level,                   //   Almost Empty Threshold
  input        [EG_ADDR - 1:0]                tx_sav_section,                //   Section Threshold Used to Start Data Transfers
  input        [EG_ADDR - 1:0]                tx_septy_section,              //   Section Threshold Used to Genererate ff_tx_septy
  input        [EG_ADDR - 1:0]                tx_af_level,                   //   Almost Full Threshold
  input        [EG_ADDR - 1:0]                tx_ae_level,                   //   Almost Empty Threshold
  input                                       scrb_ena,                      //   Enable Scrambler
  input                                       n_port,                        //   Port Type Configuration
  input                                       sof_eof_fwd,                   //   Forward SOF / EOF Delimiters to FIFO
  input                                       crc_fwd,                       //   Forward CRC to FIFO
  input        [11:0]                         frm_lgth,                      //   Frame Max Length
  input        [31:0]                         event_time_out,                //   Port Time Out
  input        [19:0]                         init_timer_val,                //   Init Timer Value
  input        [15:0]                         credit,                        //   Node Buffer Credit
  input        [15:0]                         bb_scn,                        //   Credit Recovery Modulo
  input                                       ext_rdy_gen,                   //   R_RDY Generation from External Commands
  output logic                                tx_crc_err,                    //   CRC Error Indication
  output logic                                tx_frm_trmit,                  //   Frame Transmit
  output logic                                tx_uflow_err,                  //   Frame Transmitted with Underflow
  output logic                                rx_crc_err,                    //   CRC Error Indication
  output logic                                rx_frm_discard,                //   Frame Discarded Indication
  output logic                                rx_length_err,                 //   Length Error
  output logic                                rx_frm_rcv,                    //   Frame Receive
  output logic                                dec_error,                     //   10b Decoding Error Detected
  output logic                                frm_pat,                       //   K28.5 Detection Indication
  output logic                                disp_err,                      //   Disparity Error Detected
  output logic                                sync_acqurd,                   //   Synchronization Acquired
  output logic [15:0]                         current_credit,                //   Current Credit Value
  output logic                                rdy_deficit,                   //   R_RDY Primitive Deficit
  output logic                                frm_deficit,                   //   Frame Deficit
  output logic                                node_off_line,                 //   Node is Off-Line
  output logic                                node_on_line,                  //   Node is On-Line
  output logic                                node_fault,                    //   Node in Fault States
  output logic                                node_recovery,                 //   Node in Recovery States
  input                                       rdy_gen_reg,                   //   Generate R_RDY
  output logic                                rdy_gen_ack,                   //   Acknowledge R_RDY Generation
  input                                       rdy_gen,                       //   Generate R_RDY - External Command
  input                                       sw_reset_cmd,                  //   Software Reset Command
  input                                       credit_reset,                  //   Reset Credit
  output logic                                credit_reset_ack,              //   Reset Credit Acknowledge
  input                                       ena_det,                       //   Reset Alignment
  output logic                                comma_det,                     //   Comma Aligned
  input                                       off_line,                      //   Put Node Off-Line
  input                                       on_line,                       //   Put Node On-Line
  input                                       reset_link,                    //   Reset Node Link
  output logic                                reset_link_ack,                //   Reset Node Link Acknowledge
  output logic                                rx_class_val,                  //   Frame Class Valid
  output logic [3:0]                          rx_class,                      //   Frame Class for External Statistic
  output logic                                rx_end_code_val,               //   Frame End Code Valid
  output logic [3:0]                          rx_end_code,                   //   Frame End Code for External Statistic
  output logic [11:0]                         rx_primitive,                  //   Primitive Decoding Status
  output logic [39:0]                         rx_align_data,                 //   Comma Aligned Serdes Data
  output logic [31:0]                         rx_fc1_data,
  output logic                                rx_fc1_kchn,
  output logic                                rx_fc1_err 
);
  assign tx_phy_data       = 0;    //   Transmit PHY Data
  assign ff_rx_data        = 0;    //   Data Out
  assign ff_rx_sop         = 0;    //   Start of Packet
  assign ff_rx_eop         = 0;    //   End of Packet
  assign ff_rx_mod         = 0;    //   Frame Modulo
  assign ff_rx_err         = 0;    //   Errored Packet Indication
  assign ff_rx_class       = 0;    //   Frame Class
  assign ff_rx_err_stat    = 0;    //   Errored Packet Status Word
  assign ff_rx_dval        = 0;    //   Data Valid
  assign ff_rx_dsav        = 0;    //   Data Available in Receive FIFO
  assign ff_tx_septy       = 0;    //   Data Section Free in FIFO
  assign ff_tx_rdy         = 0;    //   FIFO Ready to Accept Data
  assign tx_crc_err        = 0;    //   CRC Error Indication
  assign tx_frm_trmit      = 0;    //   Frame Transmit
  assign tx_uflow_err      = 0;    //   Frame Transmitted with Underflow
  assign rx_crc_err        = 0;    //   CRC Error Indication
  assign rx_frm_discard    = 0;    //   Frame Discarded Indication
  assign rx_length_err     = 0;    //   Length Error
  assign rx_frm_rcv        = 0;    //   Frame Receive
  assign dec_error         = 0;    //   10b Decoding Error Detected
  assign frm_pat           = 0;    //   K28.5 Detection Indication
  assign disp_err          = 0;    //   Disparity Error Detected
  assign sync_acqurd       = 0;    //   Synchronization Acquired
  assign current_credit    = 0;    //   Current Credit Value
  assign rdy_deficit       = 0;    //   R_RDY Primitive Deficit
  assign frm_deficit       = 0;    //   Frame Deficit
  assign node_off_line     = 0;    //   Node is Off-Line
  assign node_on_line      = 0;    //   Node is On-Line
  assign node_fault        = 0;    //   Node in Fault States
  assign node_recovery     = 0;    //   Node in Recovery States
  assign rdy_gen_ack       = 0;    //   Acknowledge R_RDY Generation
  assign credit_reset_ack  = 0;    //   Reset Credit Acknowledge
  assign comma_det         = 0;    //   Comma Aligned
  assign reset_link_ack    = 0;    //   Reset Node Link Acknowledge
  assign rx_class_val      = 0;    //   Frame Class Valid
  assign rx_class          = 0;    //   Frame Class for External Statistic
  assign rx_end_code_val   = 0;    //   Frame End Code Valid
  assign rx_end_code       = 0;    //   Frame End Code for External Statistic
  assign rx_primitive      = 0;    //   Primitive Decoding Status
  assign rx_align_data     = 0;    //   Comma Aligned Serdes Data
  assign rx_fc1_data       = 0;
  assign rx_fc1_kchn       = 0;
  assign rx_fc1_err        = 0;
endmodule
