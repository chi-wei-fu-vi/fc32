/***************************************************************************
* Copyright (c) 2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: mtip_no_reg.v$
* $Author: gene.shen $
* $Date: 2013-09-03 09:16:26 -0700 (Tue, 03 Sep 2013) $
* $Revision: 3327 $
* Description: MoreThanIP Core excluding Register Interface
*
***************************************************************************/

module mtip_no_reg (

   mtip_debug,		    
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

output [63:0] mtip_debug;
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


//  Commands
//  -------- 

logic   ena_det;                                //  Reset Alignment
logic   ena_det_regclk;                         //  Reset Alignment

//  Configuration
//  -------------

logic   scrb_ena;                               //  Enable Scrambler
logic   scrb_ena_regclk;                        //  Enable Scrambler

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

wire    comma_det;                              //  Comma Aligned
wire    credit_reset_ack;                       //  Reset Credit Acknowledge
wire    reset_link_ack;                         //  Reset Node Link Acknowledge
wire    rdy_gen_ack;                            //  Acknowledge R_RDY Generation
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
          .rx_sav_section(8'h20),               // Receive Section Full - FIFO Status
          .rx_af_level(8'h08),                  // Receive Almost Full Threshold
          .rx_ae_level(8'h08),                  // Receive Almost Empty Threshold
          .tx_sav_section(8'h20),               // Transmit Section Full - MAC Tx Start
          .tx_septy_section(8'h20),             // Transmit Section Empty - FIFO Status
          .tx_af_level(8'h10),                  // Transmit Almost Full Threshold
          .tx_ae_level(8'h08),                  // Transmit Almost Empty Threshold
          .scrb_ena(scrb_ena),                  // Enable Scrambler
          .n_port(1'b0),                        // Port Type Configuration
          .sof_eof_fwd(1'b0),                   // Forward SOF / EOF Delimiters to FIFO
          .crc_fwd(1'b0),                       // Forward CRC to FIFO
          .frm_lgth(12'd2136),                  // Frame Max Length
          .event_time_out(32'h00001000),        // Port Time Out
          .init_timer_val(20'h00100),           // Init Timer Value
          .credit(16'h0),                       // Node Buffer Credit
          .bb_scn(16'h0),                       // Credit Recovery Modulo
          .ext_rdy_gen(1'b0),                   // R_RDY Generation from External Commands
          .tx_crc_err(tx_crc_err),
          .tx_frm_trmit(tx_frm_trmit),
          .tx_uflow_err(tx_uflow_err),
          .rx_crc_err(rx_crc_err),
          .rx_frm_discard(rx_frm_discard),      // Frame Discarded Indication
          .rx_length_err(rx_length_err),        // Length Error
          .rx_frm_rcv(rx_frm_rcv),              // Frame Receive
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
          .rdy_gen_reg(1'b0),                   // Generate R_RDY
          .rdy_gen_ack(rdy_gen_ack),            // Acknowledge R_RDY Generation
          .credit_reset(1'b0),                  // Reset Credit
          .credit_reset_ack(credit_reset_ack),  // Reset Credit Acknowledge
          .sw_reset_cmd(1'b0),                  // Software Reset Command
          .ena_det(ena_det),                    // Reset Alignment
          .comma_det(comma_det),
          .off_line(1'b0),                      // Put Node Off-Line
          .on_line(1'b1),                       // Put Node On-Line
          .reset_link(1'b0),                    // Reset Node Link
          .reset_link_ack(reset_link_ack),      // Reset Node Link Acknowledge
          .rx_class_val(rx_class_val),        
          .rx_class(rx_class),
          .rx_end_code_val(rx_end_code_val),
          .rx_end_code(rx_end_code),          
          .rx_primitive(rx_primitive),
          .rx_fc1_data(rx_fc1_data),
          .rx_fc1_kchn(rx_fc1_kchn),
          .rx_fc1_err(rx_fc1_err));          

// Command Config Register
always_ff @( posedge reg_clk or posedge reset_reg_clk )
    if ( reset_reg_clk ) begin
        ena_det_regclk <= 1'b1;
        scrb_ena_regclk <= 1'b0;
    end
    else if ( reg_wr & ( reg_addr == 8'h02 ) ) begin
        ena_det_regclk <= reg_data_in[10];
        scrb_ena_regclk <= reg_data_in[0];
    end

vi_sync_level #(
    .SIZE       ( 2         )
)
u_sync_level_ena_det_scrb_ena (
    .out_level          ( {ena_det, scrb_ena}               ),
    .clk                ( rx_clk                            ),
    .rst_n              ( ~reset_rx_clk                     ),
    .in_level           ( {ena_det_regclk, scrb_ena_regclk} )
);

assign reg_data_out = 32'b0;
assign reg_busy = 1'b0;
assign sd_loopback = 1'b0;
          
// Module outputs
assign led_link_online = node_on_line; 
assign led_link_sync   = sync_acqurd; 
assign current_credit  = current_credit_int;
assign rx_disp_err     = disp_err;
assign rx_char_err     = dec_error;

   assign mtip_debug[63:0] = {
			      15'h0,
			      rx_class_val,       // 48
			      rx_class[3:0],      // 47:44
			      rx_end_code_val,    // 43
			      rx_end_code[3:0],   // 42:39
			      rx_primitive[11:0], // 38:27
//			      rx_fc1_data[31:0],  // 
			      rx_fc1_kchn,        // 26
			      rx_fc1_err,         // 25
			      rx_disp_err,        // 24
			      rx_char_err,        // 23
			      led_link_sync,      // 22
			      led_link_online,    // 21
			      ff_tx_mod[1:0],     // 20:19
			      ff_rx_dsav,         // 18
			      ff_rx_sop,          // 17
			      ff_rx_eop,          // 16
			      ff_rx_err,          // 15
			      ff_rx_rdy,          // 14
			      ff_rx_dval,         // 13
			      comma_det,          // 12
			      rx_phy_los,         // 11
			      scrb_ena,           // 10
			      rx_crc_err,         // 9
			      rx_frm_discard,     // 8
			      rx_length_err,      // 7
			      rx_frm_rcv,         // 6
			      dec_error,          // 5
			      sync_acqurd,        // 4
			      node_off_line,      // 3
			      node_on_line,       // 2
			      node_fault,         // 1
			      node_recovery       // 0
			      };          

endmodule // module top_fc_w_host
