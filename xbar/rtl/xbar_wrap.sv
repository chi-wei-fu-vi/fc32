/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author: gene.shen $
* $Date: 2013-12-17 10:13:03 -0800 (Tue, 17 Dec 2013) $
* $Revision: 4104 $
* $HeadURL: http://vi-bugs/svn/pld/trunk/dominica_dal/design/xbar/rtl/xbar_wrap.sv $
***********************************************************************************************************/

// auto_wire_reg ignore LITE
module xbar_wrap #(
  parameter LITE = 1,
  parameter REMOVE_XBAR = 1
) (

  // Inputs from PHYs
  input        [25:0]                         rx_data_val,
  input  logic [25:0][63:0]                   rx_data_in,                    //  40b receive data from PHY
  input        [25:0]                         rx_clk,                        //  per PHY rx clock
  input        [25:0]                         rx_rst_n,                      //  per PHY rx reset
  input                                       tx_clk,                        //  per PHY tx clock - this is now a single clock
  input        [25:0]                         tx_rst_n,                      //  per PHY tx reset

  // Inputs from txbist32b
  input        [39:0]                         txbist32b_data0,               //  10b data from traffic generator
  input        [39:0]                         txbist32b_data1,               //  10b data from traffic generator
  input                                       txbist32b_data_val0,           //  data0 is valid
  input                                       txbist32b_data_val1,           //  data0 is valid

  // Outputs
  output logic [25:0][63:0]                   xbar_tx_data,                  //  40b transmit data to PHY
  output       [25:0]                         xbar_tx_data_val,              //  transmit data is valid

  // Control Register Interface
  output       [63:0]                         cr_xbar_rd_data,               //  control register read data
  output                                      cr_xbar_rd_data_v,             //  control register read data valid
  input                                       cr_xbar_wr_en,                 //  control register write enable
  input                                       cr_xbar_rd_en,                 //  control register read enable
  input        [9:0]                          cr_xbar_addr,                  //  control register address
  input        [63:0]                         cr_xbar_wr_data,               //  control register write data

  // Clocks/Reset
  input                                       clk_txbist,                    //  txbist clock
  input                                       clk_xbar,                      //  xbar clock, 215Mhz
  input                                       rst_txbist_n,                  //  txbist reset
  input                                       rst_xbar_n,                    //  xbar reset
  output       logic [25:0]                   oREG_CTL_FARLOOPBACKEN 
    
);

  localparam USE_IN_FLOP = 0;


  genvar ii;
  genvar                            gi;

  wire   [25:0][39:0]                   tx_data_mux;
  wire   [25:0]                         tx_data_val_mux;
  wire   [25:0]                         clr_reg_overflow;
  wire   [25:0]                         clr_reg_underflow;
  wire   [12:0][3:0]                    cr_cfg_link;
  logic  [9:0]                          cr_xbar_addr_s;
  logic  [63:0]                         cr_xbar_wr_data_s;
  wire   [25:0][39:0]                   efifo_data_out;
  wire   [25:0]                         efifo_data_val;
  wire   [25:0]                         efifo_overflow;
  wire   [25:0]                         efifo_underflow;
  wire   [25:0]                         idle_delete_cnt_en;
  logic  [25:0]                         idle_delete_cnt_en_tosync;
  wire   [25:0]                         idle_insert_cnt_en;
  logic  [25:0]                         idle_insert_cnt_en_tosync;
  wire   [11:0]                         oREG_EFIFOCTL_EFIFOHIGHTHRESH;
  wire   [11:0]                         oREG_EFIFOCTL_EFIFOLOWTHRESH;
  wire   [11:0]                         oREG_EFIFOCTL_EFIFOREADTHRESH;
  wire   [63:0]                         oREG_SCRATCH;
  logic  [25:0]                         reg_overflow_sticky;
  logic  [25:0]                         reg_underflow_sticky;
  wire   [25:0][39:0]                   rx_align_data;
  logic  [25:0][39:0]                   rx_data_in_int;
  logic  [25:0]                         rx_data_val_to_efifo;
  logic  [25:0]                         rx_data_val_int;
  logic                                 cr_xbar_rd_en_s;
  logic                                 cr_xbar_wr_en_s;
  logic                                 oREG_CTL_SWRST;
  logic  [25:0]                         rst_xbar_rx_n;
  wire                                  oREG_CTL_IDLETYPE;
  wire                                  rst_xbar_tx_n;


  logic        [39:0]                         txbist32b_data0_sync;               //  10b data from traffic generator
  logic        [39:0]                         txbist32b_data1_sync;               //  10b data from traffic generator
  logic                                       txbist32b_data_val0_sync;           //  data0 is valid
  logic                                       txbist32b_data_val1_sync;           //  data0 is valid
  logic                                       bist0_empty, bist0_rd_en, bist0_val_r, bist0_val_rr;
  logic                                       bist1_empty, bist1_rd_en, bist1_val_r, bist1_val_rr;

/*synchronize bist data from BIST clock to PMA clock*/

wire  [1:0]           wr_rst_busy;
wire  [1:0]           full;
wire  [1:0][3:0]      rd_data_count;
wire  [1:0][3:0]      wr_data_count;
wire  [1:0]           rd_rst_busy;
s5_afifo_16_40b bist0_sync (
 . wr_rst_busy          ( wr_rst_busy[0]                                     ), // output
 . full                 ( full[0]                                            ), // output
 . rd_data_count        ( rd_data_count[0]                                   ), // output [3:0]
 . wr_data_count        ( wr_data_count[0]                                   ), // output [3:0]
 . rd_rst_busy          ( rd_rst_busy[0]                                     ), // output
 . rst                  ( ~rst_txbist_n                                      ), 
 . din                  ( txbist32b_data0                                    ), 
 . rd_clk               ( tx_clk                                             ), 
 . rd_en                ( bist0_rd_en                                        ), 
 . wr_clk               ( clk_txbist                                         ), 
 . wr_en                ( txbist32b_data_val0                                ), 
 . dout                 ( txbist32b_data0_sync                               ), 
 . empty                ( bist0_empty                                        )  
);


assign bist0_rd_en = !bist0_empty;

always @ (posedge clk_txbist or negedge rst_txbist_n)
  if (!rst_txbist_n)
  begin
		bist0_val_r <= 1'b0;
		bist0_val_rr <= 1'b0;
		txbist32b_data_val0_sync <= 1'b0;
  end
  else
	begin
		bist0_val_r <= bist0_rd_en;
		bist0_val_rr <= bist0_val_r;
		txbist32b_data_val0_sync <= bist0_val_rr;
	end



//wire                  wr_rst_busy;
//wire                  full;
//wire  [3:0]           rd_data_count;
//wire  [3:0]           wr_data_count;
//wire                  rd_rst_busy;
s5_afifo_16_40b bist1_sync (
 . wr_rst_busy          ( wr_rst_busy[1]                                     ), // output
 . full                 ( full[1]                                            ), // output
 . rd_data_count        ( rd_data_count[1]                                   ), // output [3:0]
 . wr_data_count        ( wr_data_count[1]                                   ), // output [3:0]
 . rd_rst_busy          ( rd_rst_busy[1]                                     ), // output
 . rst                  ( ~rst_txbist_n                                      ), 
 . din                  ( txbist32b_data1                                    ), 
 . rd_clk               ( tx_clk                                             ), 
 . rd_en                ( bist1_rd_en                                        ), 
 . wr_clk               ( clk_txbist                                         ), 
 . wr_en                ( txbist32b_data_val1                                ), 
 . dout                 ( txbist32b_data1_sync                               ), 
 . empty                ( bist1_empty                                        )  
);


assign bist1_rd_en = !bist1_empty;

always @ (posedge clk_txbist or negedge rst_txbist_n)
  if (!rst_txbist_n) 
  begin
    bist1_val_r <= 1'b0;
    bist1_val_rr <= 1'b0;
    txbist32b_data_val1_sync <= 1'b0;
  end
  else
  begin
    bist1_val_r <= bist1_rd_en;
    bist1_val_rr <= bist1_val_r;
    txbist32b_data_val1_sync <= bist1_val_rr;
  end






  generate 
    for (ii=0; ii<26; ii=ii+1) begin : din_flop
      if (USE_IN_FLOP == 1) begin: din_flop_enable
        always @(posedge rx_clk[ii] or negedge rx_rst_n[ii]) 
                if (!rx_rst_n[ii])
                      begin
                              rx_data_in_int[ii] <= {40{1'b0}};
                              rx_data_val_int[ii]<= 1'b0;
                      end
        else
                      begin
                              rx_data_in_int[ii] <= rx_data_in[ii][39:0];
                              rx_data_val_int[ii]<= rx_data_val[ii];
        end
      end: din_flop_enable
      else begin : din_flop_disable
        assign rx_data_in_int[ii] =  rx_data_in[ii][39:0];
        assign rx_data_val_int[ii] = rx_data_val[ii];
      end : din_flop_disable
    end : din_flop
  endgenerate




  // Aligner
  //----------------

  generate
     for (gi=0; gi<26; gi=gi+1) begin : gen_align
       xbar_align xbar_align_inst (
         . rx_data                                            ( rx_data_in_int[gi][39:0]                           ), // input [39:0]
         . rx_clk                                             ( rx_clk[gi]                                         ), // input
         . rx_rst_n                                           ( rx_rst_n[gi] & rst_xbar_rx_n[gi]                   ), // input
         . rx_align_data                                      ( rx_align_data[gi]                                  )  // output [39:0]
       );
     end: gen_align
  endgenerate
  

  //----------------
  // EFIFO
  //----------------
  // Used for far-end loopback support

  generate
     for (gi=0; gi<26; gi=gi+1) begin : gen_efifo
       xbar_efifo xbar_efifo (
         . tx_data_out                                        ( efifo_data_out[gi][39:0]                           ), // output [39:0]
         . tx_data_val                                        ( efifo_data_val[gi]                                 ), // output
         . efifo_overflow                                     ( efifo_overflow[gi]                                 ), // output
         . efifo_underflow                                    ( efifo_underflow[gi]                                ), // output
         . idle_insert_cnt_en                                 ( idle_insert_cnt_en_tosync[gi]                      ), // output
         . idle_delete_cnt_en                                 ( idle_delete_cnt_en_tosync[gi]                      ), // output
         . cr_efifo_idle_type                                 ( 1'b1                                               ), // input

				 /*LZ : it is overkill to have fine granularity for this logic.  The
					* resulting comparitor in the xbar_efifo/sm_rd_state next_state
					* decode becomes very large.
					* Since no one really configures this value, it is currently set to
					* a const.  If there is a need for configurability, consider using
					* larger granularity.  i.e. set lower order bits to '0
					*/
         . cr_efifo_low_thresh                                ( oREG_EFIFOCTL_EFIFOLOWTHRESH[9:0]                  ), // input [9:0]
         . cr_efifo_high_thresh                               ( oREG_EFIFOCTL_EFIFOHIGHTHRESH[9:0]                 ), // input [9:0]
         . cr_efifo_read_thresh                               ( oREG_EFIFOCTL_EFIFOREADTHRESH[9:0]                 ), // input [9:0]
         //. cr_efifo_low_thresh                                ( 10'h100                 ), // input [9:0]
         //. cr_efifo_high_thresh                               ( 10'h300                 ), // input [9:0]
         //. cr_efifo_read_thresh                               ( 10'h200                 ), // input [9:0]
         . rx_data_in                                         ( {2'd0,rx_align_data[gi]}                           ), // input [41:0]
         . rx_clk                                             ( rx_clk[gi]                                         ), // input
         . rx_data_val                                        ( rx_data_val_to_efifo[gi]                           ), // input
         . tx_clk                                             ( tx_clk                                             ), // input
         . tx_rst_n                                           ( tx_rst_n[gi]&rst_xbar_tx_n                         ), // input
         . rx_rst_n                                           ( rx_rst_n[gi]&rst_xbar_rx_n[gi]                     )  // input
       );
       vi_sync_pulse vi_sync_pulse_insert (
         . out_pulse                                          ( idle_insert_cnt_en[gi]                             ), // output
         . clka                                               ( tx_clk                                             ), // input
         . clkb                                               ( clk_xbar                                           ), // input
         . rsta_n                                             ( tx_rst_n[gi]                                       ), // input
         . rstb_n                                             ( rst_xbar_n                                         ), // input
         . in_pulse                                           ( idle_insert_cnt_en_tosync[gi]                      )  // input
       );
                // sync the deletes (tx_clk) into the xbar clock domain
       vi_sync_pulse vi_sync_pulse_delete (
         . out_pulse                                          ( idle_delete_cnt_en[gi]                             ), // output
         . clka                                               ( rx_clk[gi]                                         ), // input
         . clkb                                               ( clk_xbar                                           ), // input
         . rsta_n                                             ( rx_rst_n[gi]                                       ), // input
         . rstb_n                                             ( rst_xbar_n                                         ), // input
         . in_pulse                                           ( idle_delete_cnt_en_tosync[gi]                      )  // input
       );
     end : gen_efifo
  endgenerate

  assign rx_data_val_to_efifo[25:0] = (rx_data_val_int[25:0] | oREG_CTL_FARLOOPBACKEN[25:0]);

  //----------------
  // TX Rate Matcher
  //----------------

  

  generate
     for (gi=0; gi<13; gi=gi+1) begin : gen_tx_data_mux
        assign tx_data_mux[gi*2][39:0]       = oREG_CTL_FARLOOPBACKEN[gi*2]     ? efifo_data_out[gi*2][39:0]     : txbist32b_data0_sync[39:0];
        assign tx_data_val_mux[gi*2]         = oREG_CTL_FARLOOPBACKEN[gi*2]     ? efifo_data_val[gi*2]           : txbist32b_data_val0_sync;
        assign tx_data_mux[(gi*2)+1][39:0]   = oREG_CTL_FARLOOPBACKEN[(gi*2)+1] ? efifo_data_out[(gi*2)+1][39:0] : txbist32b_data1_sync[39:0];
        assign tx_data_val_mux[(gi*2)+1]     = oREG_CTL_FARLOOPBACKEN[(gi*2)+1] ? efifo_data_val[(gi*2)+1]       : txbist32b_data_val1_sync;
     end : gen_tx_data_mux
  endgenerate



  always @(posedge clk_xbar or negedge rst_xbar_n)
    if (!rst_xbar_n) 
       begin
         cr_xbar_wr_en_s <= 'h0;
         cr_xbar_rd_en_s <= 'h0;
         cr_xbar_addr_s  <= 'h0;
         cr_xbar_wr_data_s <= 'h0;
       end
       else
       begin
         cr_xbar_wr_en_s <= cr_xbar_wr_en;
         cr_xbar_rd_en_s <= cr_xbar_rd_en;
         cr_xbar_addr_s  <= cr_xbar_addr;
         cr_xbar_wr_data_s <= cr_xbar_wr_data;
       end

  generate
    for (gi=0; gi<13; gi=gi+1) begin : gen_tx_data_conn
      assign xbar_tx_data[gi*2]       = {24'h0, tx_data_mux[gi*2][39:0]};
      assign xbar_tx_data_val[gi*2]         = tx_data_val_mux[gi*2];
      assign xbar_tx_data[(gi*2)+1]   = {24'h0, tx_data_mux[(gi*2)+1][39:0]};
      assign xbar_tx_data_val[(gi*2)+1]     = tx_data_val_mux[(gi*2)+1];
    end
  endgenerate


  //------------------
  // Control Registers
  //------------------
logic [25:0] farendloop;

always @(posedge clk_xbar or negedge rst_xbar_n)
  if (!rst_xbar_n)
	begin
		oREG_CTL_FARLOOPBACKEN <= {26{1'b1}};
	end
	else 
	begin
		oREG_CTL_FARLOOPBACKEN <= farendloop;
	end

  xbar_regs #(
    . LITE                                               ( 0                                                  )
  ) xbar_regs_inst (
    . clk                                                ( clk_xbar                                           ), // input
    . rst_n                                              ( rst_xbar_n                                         ), // input
    . wr_en                                              ( cr_xbar_wr_en_s                                    ), // input
    . rd_en                                              ( cr_xbar_rd_en_s                                    ), // input
    . addr                                               ( cr_xbar_addr_s[9:0]                                ), // input [9:0]
    . wr_data                                            ( cr_xbar_wr_data_s[63:0]                            ), // input [63:0]
    . rd_data                                            ( cr_xbar_rd_data[63:0]                              ), // output [63:0]
    . rd_data_v                                          ( cr_xbar_rd_data_v                                  ), // output
    //. oREG__SCRATCH                                       ( oREG_SCRATCH                                       ), // output [63:0]
    . oREG_CTL_FARLOOPBACKEN                             ( farendloop[25:0]                       ), // output [25:0]
    . oREG_CTL_IDLETYPE                                  ( oREG_CTL_IDLETYPE                                  ), // output
    . oREG_CTL_SWRST                                     ( oREG_CTL_SWRST                                     ), // output
    . oREG_EFIFOCTL_EFIFOHIGHTHRESH                      ( oREG_EFIFOCTL_EFIFOHIGHTHRESH[11:0]                ), // output [11:0]
    . oREG_EFIFOCTL_EFIFOLOWTHRESH                       ( oREG_EFIFOCTL_EFIFOLOWTHRESH[11:0]                 ), // output [11:0]
    . oREG_EFIFOCTL_EFIFOREADTHRESH                      ( oREG_EFIFOCTL_EFIFOREADTHRESH[11:0]                ), // output [11:0]
    . oREG_CFG_LINK12CFG                                 ( cr_cfg_link[12]                                    ), // output [3:0]
    . oREG_CFG_LINK11CFG                                 ( cr_cfg_link[11]                                    ), // output [3:0]
    . oREG_CFG_LINK10CFG                                 ( cr_cfg_link[10]                                    ), // output [3:0]
    . oREG_CFG_LINK9CFG                                  ( cr_cfg_link[9]                                     ), // output [3:0]
    . oREG_CFG_LINK8CFG                                  ( cr_cfg_link[8]                                     ), // output [3:0]
    . oREG_CFG_LINK7CFG                                  ( cr_cfg_link[7]                                     ), // output [3:0]
    . oREG_CFG_LINK6CFG                                  ( cr_cfg_link[6]                                     ), // output [3:0]
    . oREG_CFG_LINK5CFG                                  ( cr_cfg_link[5]                                     ), // output [3:0]
    . oREG_CFG_LINK4CFG                                  ( cr_cfg_link[4]                                     ), // output [3:0]
    . oREG_CFG_LINK3CFG                                  ( cr_cfg_link[3]                                     ), // output [3:0]
    . oREG_CFG_LINK2CFG                                  ( cr_cfg_link[2]                                     ), // output [3:0]
    . oREG_CFG_LINK1CFG                                  ( cr_cfg_link[1]                                     ), // output [3:0]
    . oREG_CFG_LINK0CFG                                  ( cr_cfg_link[0]                                     ), // output [3:0]
    . iREG_LINK0IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[0]                              ), // input
    . iREG_LINK1IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[1]                              ), // input
    . iREG_LINK2IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[2]                              ), // input
    . iREG_LINK3IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[3]                              ), // input
    . iREG_LINK4IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[4]                              ), // input
    . iREG_LINK5IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[5]                              ), // input
    . iREG_LINK6IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[6]                              ), // input
    . iREG_LINK7IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[7]                              ), // input
    . iREG_LINK8IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[8]                              ), // input
    . iREG_LINK9IDLEINSERTCNT_EN                         ( idle_insert_cnt_en[9]                              ), // input
    . iREG_LINK10IDLEINSERTCNT_EN                        ( idle_insert_cnt_en[10]                             ), // input
    . iREG_LINK11IDLEINSERTCNT_EN                        ( idle_insert_cnt_en[11]                             ), // input
    . iREG_LINK12IDLEINSERTCNT_EN                        ( idle_insert_cnt_en[12]                             ), // input
    . iREG_LINK0IDLEDELETECNT_EN                         ( idle_delete_cnt_en[0]                              ), // input
    . iREG_LINK1IDLEDELETECNT_EN                         ( idle_delete_cnt_en[1]                              ), // input
    . iREG_LINK2IDLEDELETECNT_EN                         ( idle_delete_cnt_en[2]                              ), // input
    . iREG_LINK3IDLEDELETECNT_EN                         ( idle_delete_cnt_en[3]                              ), // input
    . iREG_LINK4IDLEDELETECNT_EN                         ( idle_delete_cnt_en[4]                              ), // input
    . iREG_LINK5IDLEDELETECNT_EN                         ( idle_delete_cnt_en[5]                              ), // input
    . iREG_LINK6IDLEDELETECNT_EN                         ( idle_delete_cnt_en[6]                              ), // input
    . iREG_LINK7IDLEDELETECNT_EN                         ( idle_delete_cnt_en[7]                              ), // input
    . iREG_LINK8IDLEDELETECNT_EN                         ( idle_delete_cnt_en[8]                              ), // input
    . iREG_LINK9IDLEDELETECNT_EN                         ( idle_delete_cnt_en[9]                              ), // input
    . iREG_LINK10IDLEDELETECNT_EN                        ( idle_delete_cnt_en[10]                             ), // input
    . iREG_LINK11IDLEDELETECNT_EN                        ( idle_delete_cnt_en[11]                             ), // input
    . iREG_LINK12IDLEDELETECNT_EN                        ( idle_delete_cnt_en[12]                             ), // input
    . iREG_EFIFOOVERFLOWSTATUS                           ( reg_overflow_sticky[25:0]                          ), // input [25:0]
    . iREG_EFIFOUNDERFLOWSTATUS                          ( reg_underflow_sticky[25:0]                         )  // input [25:0]
  );
  
  always_ff @(posedge clk_xbar or negedge rst_xbar_n) begin
     reg_overflow_sticky[25:0]  <= ~rst_xbar_n ? 26'd0      :
                                   clr_reg_overflow ? 26'd0 :
                                   (reg_overflow_sticky[25:0] | efifo_overflow);
     reg_underflow_sticky[25:0] <= ~rst_xbar_n ? 26'd0      :
                                   clr_reg_underflow ? 26'd0 :
                                   (reg_underflow_sticky[25:0] | efifo_underflow);
  end

  assign clr_reg_overflow  = (cr_xbar_wr_en & cr_xbar_addr[9:0]==10'd32);
  assign clr_reg_underflow = (cr_xbar_wr_en & cr_xbar_addr[9:0]==10'd33);
  
  // synchronize the SWRST into each RX clock domain

  generate
     for (gi=0; gi<26; gi=gi+1) begin : gen_rst_sync_xbar_rx
       vi_rst_sync_pulse rst_sync_pulse_xbar_rx (
         . rst_a_n                                            ( rst_xbar_n                                         ), // input
         . rst_b_n                                            ( rx_rst_n[gi]                                       ), // input
         . clk_a                                              ( clk_xbar                                           ), // input
         . clk_b                                              ( rx_clk[gi]                                         ), // input
         . rst_sync_n                                         ( ~oREG_CTL_SWRST                                    ), // input
         . rst_out_sync_n                                     ( rst_xbar_rx_n[gi]                                  )  // output
       );
     end : gen_rst_sync_xbar_rx
  endgenerate
  vi_rst_sync_async rst_sync_xbar_tx (
    . iRST_ASYNC_N                                       ( ~oREG_CTL_SWRST                                    ), // input
    . iCLK                                               ( tx_clk                                             ), // input
    . oRST_SYNC_N                                        ( rst_xbar_tx_n                                      )  // output
  );

endmodule 
