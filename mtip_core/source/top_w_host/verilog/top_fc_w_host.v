
`timescale 1 ns / 10 ps

//  *************************************************************************
//  File : top_fc_w_host
//  *************************************************************************
//  This program is controlled by a written license agreement.
//  Unauthorized reproduction or use is expressly prohibited. 
//  Copyright (c) 2009 Morethanip
//  An der Steinernen Brueke 1, 85757 Karlsfeld, Germany
//  info@morethanip.com
//  http://www.morethanip.com
//  *************************************************************************
//  Designed by : Francois Balay
//  info@morethanip.com
//  *************************************************************************
//  Decription : 2000/4000Mbps FC-FS Transport Top Level Structure
//  Version    : $Id: top_fc_w_host.v,v 1.7 2012/02/10 17:31:38 fb Exp $
//  *************************************************************************
/*
 *  Modifications:
 *   09/08/2011 DGroen - added the rx_fc1_kchn/err ports for use in detecting control characters
 *

*/

module top_fc_w_host (

   reset_rx_clk,
   reset_tx_clk,
   reset_reg_clk,
   reset_ff_rx_clk,
   reset_ff_tx_clk,
   rx_clk,
   tx_clk,
   rx_phy_data,
   rx_phy_los,
   rx_align_data,
   tx_phy_data,
   ff_rx_clk,
   ff_rx_data,
   ff_rx_sop,
   ff_rx_eop,
   ff_rx_mod,
   ff_rx_err,
   ff_rx_class,
   ff_rx_err_stat,
   ff_rx_rdy,
   ff_rx_dval,
   ff_rx_dsav,
   ff_tx_clk,
   ff_tx_data,
   ff_tx_sop,
   ff_tx_eop,
   ff_tx_mod,
   ff_tx_err,
   ff_tx_wren,
   ff_tx_class,
   ff_tx_end_code,
   ff_tx_crc_fwd,
   ff_tx_crc_chk,
   ff_tx_sof_eof,
   ff_tx_septy,
   ff_tx_rdy,
   ff_tx_ipg,
   sd_loopback,
   led_link_sync,
   led_link_online,
   rdy_gen,
   current_credit,
   rx_class_val,   
   rx_class,
   rx_end_code_val,
   rx_end_code,
   rx_primitive,
   rx_fc1_data,
   rx_fc1_kchn,
   rx_fc1_err,
   rx_disp_err,
   rx_char_err,
   reg_clk,
   reg_rd,
   reg_wr,
   reg_addr,
   reg_data_in,
   reg_data_out,
   reg_busy); 

`include "mtip_fc_pack_package.verilog"  

input   reset_rx_clk;           	//  Asynchronous Reset - rx_clk Clock Domain
input   reset_tx_clk;           	//  Asynchronous Reset - tx_clk Clock Domain
input   reset_reg_clk;          	//  Asynchronous Reset - reg_clk Clock Domain
input   reset_ff_rx_clk;        	//  Asynchronous Reset - ff_rx_clk Clock Domain
input   reset_ff_tx_clk;        	//  Asynchronous Reset - ff_tx_clk Clock Domain
input   rx_clk;                 	//  Receive Line Clock
input   tx_clk;                 	//  Transmit Line Clock
input   [39:0] rx_phy_data;     	//  Non Aligned Receive PHY Data
input   rx_phy_los;             	//  Loss of Signal Indication
output  [39:0] rx_align_data;           //  Comma Aligned Serdes Data
output  [39:0] tx_phy_data;     	//  Transmit PHY Data
input   ff_rx_clk;              	//  Receive Local Clock
output  [31:0] ff_rx_data;      	//  Data Out
output  ff_rx_sop;              	//  Start of Packet
output  ff_rx_eop;              	//  End of Packet
output  [1:0] ff_rx_mod;        	//  Frame Modulo
output  ff_rx_err;              	//  Errored Packet Indication
output  [3:0] ff_rx_class;      	//  Frame Class
output  [7:0] ff_rx_err_stat;   	//  Errored Packet Status Word
input   ff_rx_rdy;              	//  Application Ready
output  ff_rx_dval;             	//  Data Valid
output  ff_rx_dsav;             	//  Data Available in Receive FIFO
input   ff_tx_clk;              	//  Transmit Local Clock	
input   [31:0] ff_tx_data;      	//  Receive Data
input   ff_tx_sop;              	//  Start of Packet
input   ff_tx_eop;              	//  End of Packet
input   [1:0] ff_tx_mod;        	//  Packet Modulo
input   ff_tx_err;              	//  Packet Error
input   ff_tx_wren;             	//  Link Layer FIFO Almost Full
input   [3:0] ff_tx_class;      	//  Frame Class
input   [3:0] ff_tx_end_code;   	//  Frame Terminasion Code
input   ff_tx_crc_fwd;          	//  Forward Frame with CRC from Application
input   ff_tx_crc_chk;          	//  Check CRC from Application
input   ff_tx_sof_eof;          	//  Enable Frame Transfer with EOF/SOF Fields
output  ff_tx_septy;            	//  Data Section Free in FIFO
output  ff_tx_rdy;              	//  FIFO Ready to Accept Data
input   [31:0] ff_tx_ipg;       	//  Transmit IPG
output  sd_loopback;            	//  SERDES Loopback Enable
output  led_link_sync;          	//  Link Synchronization Indication
output  led_link_online;        	//  Link in Active State Indication        
input   rdy_gen;                	//  Generate R_RDY Primitive
output  [15:0] current_credit;  	//  Current Credit
output  rx_class_val;                   //  Frame Class Valid
output  [3:0] rx_class;                 //  Frame Class for External Statistic
output  rx_end_code_val;                //  Frame End Code Valid 
output  [3:0] rx_end_code;              //  Frame End Code for External Statistic 
output  [11:0] rx_primitive;            //  Primitive Decoding Status
output  [31:0] rx_fc1_data;
output  rx_fc1_kchn;
output  rx_fc1_err;
output  rx_disp_err;                    //  Disparity Error
output  rx_char_err;                    //  Character Error
input   reg_clk;                	//  Register Clock
input   reg_rd;                 	//  Register Read Strobe
input   reg_wr;                 	//  Register Write Strobe
input   [9:2] reg_addr;         	//  Register Address
input   [31:0] reg_data_in;     	//  Write Data for Host Bus
output  [31:0] reg_data_out;    	//  Read Data to Host Bus
output  reg_busy;               	//  Interface Busy

wire    [39:0] rx_align_data;
wire    [39:0] tx_phy_data; 
wire    [31:0] ff_rx_data; 
wire    ff_rx_sop; 
wire    ff_rx_eop; 
wire    [1:0] ff_rx_mod; 
wire    ff_rx_err; 
wire    [3:0] ff_rx_class; 
wire    [7:0] ff_rx_err_stat; 
wire    ff_rx_dval; 
wire    ff_rx_dsav; 
wire    ff_tx_septy; 
wire    ff_tx_rdy; 
wire    sd_loopback;
wire    led_link_sync; 
wire    led_link_online; 
wire    [15:0] current_credit;
wire    rx_class_val;
wire    [3:0] rx_class; 
wire    rx_end_code_val; 
wire    [3:0] rx_end_code; 
wire    [11:0] rx_primitive;
wire    [31:0] rx_fc1_data;
wire           rx_fc1_kchn;
wire           rx_fc1_err;
wire    rx_disp_err;
wire    rx_char_err;
wire    [31:0] reg_data_out; 
wire    reg_busy; 

//  FIFO Thresholds
//  ---------------

wire    [ING_ADDR - 1:0] rx_section_full;       //  Receive Section Full - FIFO Status 
wire    [EG_ADDR - 1:0] tx_section_empty;       //  Transmit Section Empty - FIFO Status
wire    [EG_ADDR - 1:0] tx_section_full;        //  Transmit Section Full - MAC Tx Start
wire    [ING_ADDR - 1:0] rx_ae_level;           //  Receive Almost Empty Threshold
wire    [ING_ADDR - 1:0] rx_af_level;           //  Receive Almost Full Threshold 
wire    [EG_ADDR - 1:0] tx_ae_level;            //  Transmit Almost Empty Threshold 
wire    [EG_ADDR - 1:0] tx_af_level;            //  Transmit Almost Full Threshold                

//  Commands
//  -------- 

wire    ena_det;                                //  Reset Alignment
wire    comma_det;                              //  Comma Aligned
wire    credit_reset;                           //  Reset Credit
wire    credit_reset_ack;                       //  Reset Credit Acknowledge
wire    sw_reset_cmd;                           //  Software Reset Command
wire    off_line;                               //  Put Node Off-Line
wire    on_line;                                //  Put Node On-Line
wire    reset_link;                             //  Reset Node Link
wire    reset_link_ack;                         //  Reset Node Link Acknowledge
wire    rdy_gen_reg;                            //  Generate R_RDY
wire    rdy_gen_ack;                            //  Acknowledge R_RDY Generation

//  Configuration
//  -------------

wire    scrb_ena;                               //  Enable Scrambler
wire    n_port;                                 //  Port Type Configuration
wire    sof_eof_fwd;                            //  Forward SOF / EOF Delimiters to FIFO
wire    crc_fwd;                                //  Forward CRC to FIFO         
wire    [31:0] event_time_out;                  //  Port Time Out
wire    [19:0] init_timer_val;                  //  Init Timer Value
wire    [15:0] credit;                          //  Node Buffer Credit
wire    [15:0] bb_scn;                          //  Credit Recovery Modulo                       		        
wire    [11:0] frm_lgth;                        //  Frame Max Length                       		        
wire    ext_rdy_gen;                            //  R_RDY Generation from External Commands                       		        

//  Counter Triggers
//  ----------------

wire    tx_crc_err;                             //  CRC Error Indication
wire    tx_frm_trmit;                           //  Frame Transmit      
wire    tx_uflow_err;                           //  Frame Transmitted with Underflow
wire    rx_crc_err;                             //  CRC Error Indication
wire    rx_frm_discard;                         //  Frame Discarded Indication
wire    rx_length_err;                          //  Length Error
wire    rx_frm_rcv;                             //  Frame Receive

//  Status
//  ------

wire    dec_error;                              //  10b Decoding Error Detected 
wire    frm_pat;                                //  K28.5 Detection Indication
wire    disp_err;                               //  Disparity Error Detected     
wire    sync_acqurd;                            //  Synchronization Acquired
wire    [15:0] current_credit_int;              //  Current Credit Value        
wire    rdy_deficit;                            //  R_RDY Primitive Deficit
wire    frm_deficit;                            //  Frame Deficit   
wire    node_off_line;                          //  Node is Off-Line
wire    node_on_line;                           //  Node is On-Line
wire    node_fault;                             //  Node in Fault States
wire    node_recovery;                          //  Node in Recovery States

top_fc_w_fifo U_FC (

          .reset_rx_clk(reset_rx_clk),
          .reset_tx_clk(reset_tx_clk),
          .reset_ff_rx_clk(reset_ff_rx_clk),
          .reset_ff_tx_clk(reset_ff_tx_clk),
          .rx_clk(rx_clk),
          .tx_clk(tx_clk),
          .rx_phy_data(rx_phy_data),
          .rx_phy_los(rx_phy_los),
          .rx_align_data(rx_align_data),
          .tx_phy_data(tx_phy_data),
          .ff_rx_clk(ff_rx_clk),
          .ff_rx_data(ff_rx_data),
          .ff_rx_sop(ff_rx_sop),
          .ff_rx_eop(ff_rx_eop),
          .ff_rx_mod(ff_rx_mod),
          .ff_rx_err(ff_rx_err),
          .ff_rx_class(ff_rx_class),
          .ff_rx_err_stat(ff_rx_err_stat),
          .ff_rx_rdy(ff_rx_rdy),
          .ff_rx_dval(ff_rx_dval),
          .ff_rx_dsav(ff_rx_dsav),
          .ff_tx_clk(ff_tx_clk),
          .ff_tx_data(ff_tx_data),
          .ff_tx_sop(ff_tx_sop),
          .ff_tx_eop(ff_tx_eop),
          .ff_tx_mod(ff_tx_mod),
          .ff_tx_err(ff_tx_err),
          .ff_tx_wren(ff_tx_wren),
          .ff_tx_class(ff_tx_class),
          .ff_tx_end_code(ff_tx_end_code),
          .ff_tx_crc_fwd(ff_tx_crc_fwd),
          .ff_tx_crc_chk(ff_tx_crc_chk),
          .ff_tx_sof_eof(ff_tx_sof_eof),
          .ff_tx_septy(ff_tx_septy),
          .ff_tx_rdy(ff_tx_rdy),
          .ff_tx_ipg(ff_tx_ipg),
          .rx_sav_section(rx_section_full),
          .rx_af_level(rx_af_level),
          .rx_ae_level(rx_ae_level),
          .tx_sav_section(tx_section_full),
          .tx_septy_section(tx_section_empty),
          .tx_af_level(tx_af_level),
          .tx_ae_level(tx_ae_level),
          .scrb_ena(scrb_ena),
          .n_port(n_port),
          .sof_eof_fwd(sof_eof_fwd),
          .crc_fwd(crc_fwd),
          .frm_lgth(frm_lgth),
          .event_time_out(event_time_out),
          .init_timer_val(init_timer_val),
          .credit(credit),
          .bb_scn(bb_scn),
          .ext_rdy_gen(ext_rdy_gen),
          .tx_crc_err(tx_crc_err),
          .tx_frm_trmit(tx_frm_trmit),
          .tx_uflow_err(tx_uflow_err),
          .rx_crc_err(rx_crc_err),
          .rx_frm_discard(rx_frm_discard),
          .rx_length_err(rx_length_err),
          .rx_frm_rcv(rx_frm_rcv),
          .dec_error(dec_error),
          .frm_pat(frm_pat),
          .disp_err(disp_err),
          .sync_acqurd(sync_acqurd),
          .current_credit(current_credit_int),
          .rdy_deficit(rdy_deficit),
          .frm_deficit(frm_deficit),
          .node_off_line(node_off_line),
          .node_on_line(node_on_line),
          .node_fault(node_fault),
          .node_recovery(node_recovery),
          .rdy_gen(rdy_gen),
          .rdy_gen_reg(rdy_gen_reg),
          .rdy_gen_ack(rdy_gen_ack),
          .credit_reset(credit_reset),
          .credit_reset_ack(credit_reset_ack),
          .sw_reset_cmd(sw_reset_cmd),
          .ena_det(ena_det),
          .comma_det(comma_det),
          .off_line(off_line),
          .on_line(on_line),
          .reset_link(reset_link),
          .reset_link_ack(reset_link_ack),
          .rx_class_val(rx_class_val),        
          .rx_class(rx_class),
          .rx_end_code_val(rx_end_code_val),
          .rx_end_code(rx_end_code),          
          .rx_primitive(rx_primitive),
          .rx_fc1_data(rx_fc1_data),
          .rx_fc1_kchn(rx_fc1_kchn),
          .rx_fc1_err(rx_fc1_err));          
          
mac_control U_CTL (

          .rx_clk(rx_clk),
          .tx_clk(tx_clk),
          .reset_rx_clk(reset_rx_clk),
          .reset_tx_clk(reset_tx_clk),
          .reset_reg_clk(reset_reg_clk),
          .reg_clk(reg_clk),
          .rd(reg_rd),
          .wr(reg_wr),
          .sel(reg_addr),
          .data_in(reg_data_in),
          .data_out(reg_data_out),
          .busy(reg_busy),
          .rx_section_full(rx_section_full),
          .tx_section_empty(tx_section_empty),
          .tx_section_full(tx_section_full),
          .rx_ae_level(rx_ae_level),
          .rx_af_level(rx_af_level),
          .tx_ae_level(tx_ae_level),
          .tx_af_level(tx_af_level),
          .credit_reset(credit_reset),
          .credit_reset_ack(credit_reset_ack),
          .sw_reset_cmd(sw_reset_cmd),
          .off_line(off_line),
          .on_line(on_line),
          .reset_link(reset_link),
          .reset_link_ack(reset_link_ack),
          .reset_align(ena_det),
          .sd_loopback(sd_loopback),
          .rdy_gen_reg(rdy_gen_reg),
          .rdy_gen_ack(rdy_gen_ack),
          .scrb_ena(scrb_ena),
          .n_port(n_port),
          .sof_eof_fwd(sof_eof_fwd),
          .crc_fwd(crc_fwd),
          .event_time_out(event_time_out),
          .init_timer_val(init_timer_val),
          .credit(credit),
          .bb_scn(bb_scn),
          .frm_lgth(frm_lgth),
          .ext_rdy_gen(ext_rdy_gen),
          .tx_crc_err(tx_crc_err),
          .tx_frm_trmit(tx_frm_trmit),
          .tx_uflow_err(tx_uflow_err),
          .rx_crc_err(rx_crc_err),
          .rx_frm_discard(rx_frm_discard),
          .rx_length_err(rx_length_err),
          .rx_frm_rcv(rx_frm_rcv),
          .dec_error(dec_error),
          .align_status(comma_det),
          .frm_pat(frm_pat),
          .disp_err(disp_err),
          .sync_acqurd(sync_acqurd),
          .current_credit(current_credit_int),
          .rdy_deficit(rdy_deficit),
          .frm_deficit(frm_deficit),
          .node_off_line(node_off_line),
          .node_on_line(node_on_line),
          .node_fault(node_fault),
          .node_recovery(node_recovery));

assign led_link_online = node_on_line; 
assign led_link_sync   = sync_acqurd; 
assign current_credit  = current_credit_int;
assign rx_disp_err     = disp_err;
assign rx_char_err     = dec_error;

endmodule // module top_fc_w_host