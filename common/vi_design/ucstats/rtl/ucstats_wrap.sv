/***********************************************************************************************************
* Copyright (c) 2012,2013 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Author: gene.shen $
* $Date: 2013-01-16 13:23:45 -0800 (Wed, 16 Jan 2013) $
* $Revision: 1076 $
* $HeadURL: http://vi-bugs/svn/pld/trunk/bali_dal/prototype/uc_stats/rtl/uc_stats.v $
* Description: Top level - UC Stats Module
***********************************************************************************************************/
 
module ucstats_wrap
  (
   
   // ----------------------
   // uC Interface
   // ----------------------

    input                io_uc_cs,                   // chip select.  Asserted to indicate UC operation is to this FPGA.  Negation
                                                     // after assertion indicates transaction should be terminate

    input [7:0]          io_uc_data_in,              // either address or data value driven by UC to initiate register access
   
    input                io_uc_valid,                // Strobe from UC to indicate data_in is valid.  Qualified with uc_cs to 
                                                     // determine if operation is for this FPGA.  
   
    input                io_uc_master,               // assertion indicates master owns data bus, negation indicates slave can 
                                                     // drive data bus
   
    input                io_uc_reset_n,              // asynchronous uC register transfer interface reset.  resets all UC related 
                                                     // state
   
    output [7:0]         io_uc_data_out,             // read data outbound to FPGA_DATA[7:0].  Qualified by uc_data_out_val
   
    output               io_uc_data_out_val,         // enable to drive uc_data_out.  Only asserted if uc_master is negated.  


   // ----------------------
   // Link Engine Interface
   // ----------------------
   
    input                le_ucstats_req,             // link engine request.  Level signal - held high until grant.  Once 
                                                     // granted, an additional request is a violation of protocol.  

    input [9:0]          le_ucstats_addr,            // Address of link engine UC Stat RAM read.  
                                                     //    [9:5]  5b : SFP selector
                                                     //    [4:0]  5b : double word address in the per SFP stat space.

    input                le_ucstats_done,            // link engine request done.  Pulsed one cycle to indicate link engine
                                                     // has completed fetching all stats for the SFP.   Always preceeded with a 
                                                     // REQ and GNT.  
   
    output reg [31:0]    ucstats_data,               // UC stat data.  Data is delayed 2 cycles from le_ucstats_addr.

    output reg           ucstats_gnt,                // link engine request grant.  Pulsed for one cycle in response to le_ucstat_req.
                                                     // to indicate the SFP stat RAM can be read.  

    input [9:0] 	 oLE_UCSTATS_MM_ADDR,	     // shadow stat RAM read address

    output [31:0] 	 iUCSTATS_MM_RD_DATA,        // shadow stat RAM read data
      

   // --------------------------
   // PCIE debug interface
   // --------------------------

    input [1:0] 	 pcie_enc_lane_act,	     // size of PCIE interface
    input [1:0] 	 pcie_current_speed,	     // speed of PCIE interface
    input [31:0] 	 pcie_misc_status,	     // misc PCIE debug status
    input [4:0] 	 pcie_ltssm,	             // PCIE LTSSM state
    input [63:0] 	 fpga_rev,	             // FPGA version
    output reg           ucstats_pcie_rst,           // pulsed one cycle to indicate PCIE reset request

   // --------------------------
   // Control Register Interface
   // --------------------------

    output [63:0]        cr_rd_data,                 // control register read data
    output               cr_rd_data_v,               // control register read data valid
    input                cr_wr_en,                   // control register write enable
    input                cr_rd_en,                   // control register read enable
    input [9:0]          cr_addr,                    // control register address
    input [63:0]         cr_wr_data,                 // control register write data


   // -------------------
   // Reset & Clocks
   // -------------------
   
    input                rst_n,
    input                clk
   
   );

`include "ucstats_wrap_autoreg.vh"
wire [31:0]                         stats_ram0_rd_data;
wire [31:0]                         stats_ram1_rd_data;
wire [7:0]                          tsdcalo_d;

   // ----------------------
   // Manual declarations
   // ----------------------
   
   
   // ----------------------
   // uC Request Interface
   // ----------------------

   // Flop the UC signals into the FPGA clock domain.  All asynchronous UC signals are captured in standard dual flop
   // synchornizers. 

   assign uc_rst_n = ~(~io_uc_reset_n | ~rst_n);

   vi_sync_level #(.SIZE(1)) sync_uc_cs 
     (.out_level (uc_cs_sync),
      .in_level  (io_uc_cs),
      .clk       (clk),
      .rst_n     (uc_rst_n));

   vi_sync_level #(.SIZE(8)) sync_uc_data 
     (.out_level (uc_data_sync[7:0]),
      .in_level  (io_uc_data_in[7:0]),
      .clk       (clk),
      .rst_n     (uc_rst_n));

   vi_sync_level #(.SIZE(1)) sync_uc_valid 
     (.out_level (uc_valid_sync),
      .in_level  (io_uc_valid),
      .clk       (clk),
      .rst_n     (uc_rst_n));

   vi_sync_level #(.SIZE(1))  sync_uc_master 
     (.out_level (uc_master_sync),
      .in_level  (io_uc_master),
      .clk       (clk),
      .rst_n     (uc_rst_n));

   // Debounce control signals just to make sure.  Current debounce module checks for two continuous cycles
   // of level transition

   vi_debounce debounce_uc_cs
     (.debounced (uc_cs_debounced),
      .in        (uc_cs_sync),
      .reset_n   (uc_rst_n),
      .clk       (clk));
   
   vi_debounce debounce_uc_valid
     (.debounced (uc_valid_debounced),
      .in        (uc_valid_sync),
      .reset_n   (uc_rst_n),
      .clk       (clk));
   
   vi_debounce debounce_uc_master
     (.debounced (uc_master_debounced),
      .in        (uc_master_sync),
      .reset_n   (uc_rst_n),
      .clk       (clk));

   // Edge detect on uc_valid

   always @(posedge clk or negedge uc_rst_n) 
      uc_valid_delay <= ~uc_rst_n ? 1'b0 : uc_valid_debounced;

   assign uc_valid_rising_edge  = (~uc_valid_delay &  uc_valid_debounced);
   assign uc_valid_falling_edge = ( uc_valid_delay & ~uc_valid_debounced);

   
   // --------------------------
   // UC request state machine
   // --------------------------
   // The UC interface state machine is responsible for sequencing UC read/write operations, and asserting
   // UC register interface output signals.  It also identifies early termination cases and resets itself
   // on CS negation.  This state machine is also responsible for initiating writes and reads from the UC 
   // into the SFP stat RAM. 

   localparam SM_UC_IDLE       = 5'h00;
   localparam SM_UC_ADDR0      = 5'h01;
   localparam SM_UC_ADDR1      = 5'h02;
   localparam SM_UC_ADDR_DEC   = 5'h03;
   localparam SM_UC_DATA0      = 5'h04;
   localparam SM_UC_DATA0_B    = 5'h05;
   localparam SM_UC_DATA1      = 5'h06;
   localparam SM_UC_DATA2      = 5'h07;
   localparam SM_UC_DATA3      = 5'h08;
   localparam SM_UC_WR_RAM     = 5'h09;
   localparam SM_UC_RD_RAM     = 5'h0A;
   localparam SM_UC_RD_MASTER  = 5'h0B;
   localparam SM_UC_RD_MASTER2 = 5'h0C;
   localparam SM_UC_RD_DRIVE0  = 5'h0D;
   localparam SM_UC_RD_DRIVE1  = 5'h0E;
   localparam SM_UC_RD_DRIVE2  = 5'h0F;
   localparam SM_UC_RD_DRIVE3  = 5'h10;
   localparam SM_UC_EARLY_DONE = 5'h11;
   localparam SM_UC_RD_DONE    = 5'h12;
   localparam SM_UC_DONE       = 5'h13;
   localparam SM_UC_INVALID_WR = 5'h14;
   localparam SM_UC_ERROR      = 5'h1F;
   
   always @(posedge clk or negedge uc_rst_n) begin
      if (~uc_rst_n)
        sm_uc_state[4:0] <= SM_UC_IDLE;
      else begin
         case (sm_uc_state[4:0])

           // while in idle UC state is held in reset
           SM_UC_IDLE :
             sm_uc_state[4:0] <= uc_cs_debounced      ? SM_UC_ADDR0      : SM_UC_IDLE;

           // Beat 0 - flop address 0 on edge
           SM_UC_ADDR0 :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_EARLY_DONE : 
                                 uc_valid_rising_edge ? SM_UC_ADDR1      : SM_UC_ADDR0;
           
           // Beat 1 - flop address 1 on edge
           SM_UC_ADDR1 :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_EARLY_DONE :
                                 uc_valid_rising_edge ? SM_UC_ADDR_DEC   : SM_UC_ADDR1;  

           // Address decode - check for invalid address 
           SM_UC_ADDR_DEC :
             sm_uc_state[4:0] <= ~uc_cs_debounced               ? SM_UC_EARLY_DONE :
                                 // in the write error case, we terminate the transaction and wait for CS negation
                                 (invalid_addr & uc_addr[15])   ? SM_UC_INVALID_WR :
                                 // in the read error case, skip the RAM read, data will be set to 0xDEADBEEF
                                 (invalid_addr & ~uc_addr[15])  ? SM_UC_RD_MASTER  : 
                                 // normal write case
                                 (~invalid_addr & uc_addr[15])  ? SM_UC_DATA0      :
                                 // defaults to read case
                                 SM_UC_RD_RAM;

           // WR : flop data 0 beat on edge
           SM_UC_DATA0 :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_EARLY_DONE : 
                                 uc_valid_rising_edge ? SM_UC_DATA1      : SM_UC_DATA0;
           
           // WR : flop data 0 beat on edge.  Only entered after an initial 4B of write
           //      data have been flopped.  Used to distinguish initial 4B flow from subsequent 4B flows
           SM_UC_DATA0_B :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_DONE       : 
                                 uc_valid_rising_edge ? SM_UC_DATA1      : SM_UC_DATA0_B;

           // WR : flop data 1 beat on edge
           SM_UC_DATA1 :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_EARLY_DONE : 
                                 uc_valid_rising_edge ? SM_UC_DATA2      : SM_UC_DATA1;

           // WR : flop data 2 beat on edge        
           SM_UC_DATA2 :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_EARLY_DONE : 
                                 uc_valid_rising_edge ? SM_UC_DATA3      : SM_UC_DATA2;

           // WR : flop data 3 beat on edge        
           SM_UC_DATA3 :
             sm_uc_state[4:0] <= ~uc_cs_debounced                           ? SM_UC_EARLY_DONE : 
                                 (uc_valid_rising_edge & ~uc_interval_done) ? SM_UC_WR_RAM  : 
                                 (uc_valid_rising_edge &  uc_interval_done) ? SM_UC_DATA0_B :
				 SM_UC_DATA3;
           
           // WR : update the RAM, 
           //      update the write address in case there's another write coming
           SM_UC_WR_RAM :
             sm_uc_state[4:0] <= SM_UC_DATA0_B;
                                 
           // RD : perform read
           SM_UC_RD_RAM :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_EARLY_DONE : SM_UC_RD_MASTER;
           
           // RD : wait for falling edge - this is a fix for a UC register transfer issue
	   //      to match expectations of driver and CPLD design.  Wait for the falling
	   //      edge before checking master to prevent a race.
           SM_UC_RD_MASTER :
             sm_uc_state[4:0] <= uc_valid_falling_edge ? SM_UC_RD_MASTER2 : SM_UC_RD_MASTER;
           
           // RD : wait for master to negate
           SM_UC_RD_MASTER2 :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_EARLY_DONE : 
                                 ~uc_master_debounced ? SM_UC_RD_DRIVE0  : SM_UC_RD_MASTER2;
           
           // RD : drive data 0 beat
           SM_UC_RD_DRIVE0 :
             sm_uc_state[4:0] <= ~uc_cs_debounced      ? SM_UC_EARLY_DONE : 
                                 uc_valid_falling_edge ? SM_UC_RD_DRIVE1  : SM_UC_RD_DRIVE0;
           
           // RD : drive data 1 beat
           SM_UC_RD_DRIVE1 :
             sm_uc_state[4:0] <= ~uc_cs_debounced      ? SM_UC_EARLY_DONE : 
                                 uc_valid_falling_edge ? SM_UC_RD_DRIVE2  : SM_UC_RD_DRIVE1;
           
           // RD : drive data 2 beat
           SM_UC_RD_DRIVE2 :
             sm_uc_state[4:0] <= ~uc_cs_debounced      ? SM_UC_EARLY_DONE : 
                                 uc_valid_falling_edge ? SM_UC_RD_DRIVE3  : SM_UC_RD_DRIVE2;
           
           // RD : drive data 3 beat
           SM_UC_RD_DRIVE3 :
             sm_uc_state[4:0] <= ~uc_cs_debounced      ? SM_UC_EARLY_DONE : 
                                 uc_valid_falling_edge ? SM_UC_RD_DONE    : SM_UC_RD_DRIVE3;

           // invalid write, wait for CS negation
           SM_UC_INVALID_WR :
             sm_uc_state[4:0] <= ~uc_cs_debounced    ? SM_UC_DONE        : SM_UC_INVALID_WR;

           // RD : read data has been transferred and accepted, wait for CS to negate before
           //      starting the next transaction
           SM_UC_RD_DONE :
             sm_uc_state[4:0] <= ~uc_cs_debounced     ? SM_UC_DONE       : SM_UC_RD_DONE;

           // early termination due to CS negation - logged
           SM_UC_EARLY_DONE :
             sm_uc_state[4:0] <= SM_UC_IDLE;

           // standard termination due to CS negation - logged
           SM_UC_DONE :
             sm_uc_state[4:0] <= SM_UC_IDLE;

           // should not reach here
           SM_UC_ERROR: 
             sm_uc_state[4:0] <= SM_UC_ERROR;

           default : 
             sm_uc_state[4:0] <= SM_UC_ERROR;

         endcase // case (sm_uc_state[4:0])
      end // else: !if(~uc_rst_n)
   end // always @ (posedge clk or negedge uc_rst_n)

   assign sm_uc_wr_ram       = (sm_uc_state[4:0]==SM_UC_WR_RAM);
   assign sm_uc_rd_ram       = (sm_uc_state[4:0]==SM_UC_RD_RAM);
   assign sm_uc_rd_drive0    = (sm_uc_state[4:0]==SM_UC_RD_DRIVE0);
   assign sm_uc_rd_drive1    = (sm_uc_state[4:0]==SM_UC_RD_DRIVE1);
   assign sm_uc_rd_drive2    = (sm_uc_state[4:0]==SM_UC_RD_DRIVE2);
   assign sm_uc_rd_drive3    = (sm_uc_state[4:0]==SM_UC_RD_DRIVE3);
   assign sm_uc_done         = (sm_uc_state[4:0]==SM_UC_DONE);
   assign sm_uc_early_done   = (sm_uc_state[4:0]==SM_UC_EARLY_DONE);

   always @(posedge clk or negedge uc_rst_n) 
      le_ucstats_req_q <= ~uc_rst_n ? 1'b0 : le_ucstats_req;

   // stat events 
   assign ucstats_uc_wr_event           = sm_uc_wr_ram;
   assign ucstats_uc_rd_event           = sm_uc_rd_ram;
   assign ucstats_uc_done_event         = sm_uc_done;
   assign ucstats_uc_early_done_event   = sm_uc_early_done;
   assign ucstats_le_req_event          = (le_ucstats_req & ~le_ucstats_req_q);
   assign ucstats_le_done_event         = le_ucstats_done;
   assign ucstats_uc_invalid_addr_event = invalid_addr & (sm_uc_state[4:0]==SM_UC_ADDR_DEC);
   assign ucstats_sm_uc_error           = (sm_uc_state[4:0]==SM_UC_ERROR);

   
   // ----------------------
   // UC Transfer State
   // ----------------------

   // Accumulate address - 8b chunks saved in a 16b register
   always @(posedge clk or negedge uc_rst_n) begin
      uc_addr[15:0] <= ~uc_rst_n                                              ? 16'd0 :
                       ((sm_uc_state[4:0]==SM_UC_ADDR0) & uc_valid_rising_edge) ? {uc_addr[15:8],uc_data_sync[7:0]} :
                       ((sm_uc_state[4:0]==SM_UC_ADDR1) & uc_valid_rising_edge) ? {uc_data_sync[7:0],uc_addr[7:0]}  : 
                       sm_uc_wr_ram                                             ? (uc_addr[15:0]+16'd1)  :               // auto-increment 
                       uc_addr[15:0];
   end

   // Accumulate data - 8b chunks saved in a 32b register
   always @(posedge clk or negedge uc_rst_n) begin
      uc_data[31:0] <= ~uc_rst_n       ? 32'd0 :
                       ( ((sm_uc_state[4:0]==SM_UC_DATA0) | (sm_uc_state[4:0]==SM_UC_DATA0_B)) & uc_valid_rising_edge) ? {uc_data[31:8],uc_data_sync[7:0]} :
                       ((sm_uc_state[4:0]==SM_UC_DATA1) & uc_valid_rising_edge) ? {uc_data[31:16],uc_data_sync[7:0],uc_data[7:0]}  :
                       ((sm_uc_state[4:0]==SM_UC_DATA2) & uc_valid_rising_edge) ? {uc_data[31:24],uc_data_sync[7:0],uc_data[15:0]} :
                       ((sm_uc_state[4:0]==SM_UC_DATA3) & uc_valid_rising_edge) ? {               uc_data_sync[7:0],uc_data[23:0]} : uc_data[31:0];
   end

   // interval done asserted when UC has completed one interval worth of writes.  Used to initiate update of bank selects. 
   assign uc_interval_done  = (uc_addr[15] & (uc_addr[11:10]==2'b01) & (uc_addr[9:0]==10'd1));

   // address range check
   assign invalid_addr      = ( (uc_addr[14:12]!=3'b000) |                                 // invalid fields
                                uc_addr[11] |                                              // invalid fields
                                ( (uc_addr[11:10]==2'b01) & (uc_addr[9:0]>10'h6)) );       // invalid address in FPGA space 
   
   // address decode
   assign addr_is_tempsense   = ((uc_addr[11:10]==2'b01) & (uc_addr[9:0]==10'h0));   
   assign addr_is_coolcode    = ((uc_addr[11:10]==2'b01) & (uc_addr[9:0]==10'h2));   
   assign addr_is_pcie_status = ((uc_addr[11:10]==2'b01) & (uc_addr[9:0]==10'h3));   
   assign addr_is_fpga_ver_0  = ((uc_addr[11:10]==2'b01) & (uc_addr[9:0]==10'h5));   
   assign addr_is_fpga_ver_1  = ((uc_addr[11:10]==2'b01) & (uc_addr[9:0]==10'h6));

   always_ff @(posedge clk or negedge uc_rst_n)
     ucstats_pcie_rst <= ~uc_rst_n ? 1'd0 : (uc_addr[15] & (uc_addr[11:10]==2'b01) & (uc_addr[9:0]==10'd4));

   // PCIE debug
   // --------------------------


   
   // ----------------------
   // SFP Stat RAM
   // ----------------------
   // Per SFP, stat values are saved in a RAM.  Each SFP stat block is 128B in size, organized 4B in
   // width.  There can be a total of 32 SFPs - for a total memory size of 128x32=4KB.  Reads are
   // requested by the link engine, and writes are performed through the UC register transfer interface.
   // Read and write operations are completely independent.  The SFP stat RAM is double buffered.  One
   // bank is allocated to the link engine (nominally for reads), and the other bank to the uController 
   // (for reads and writes).  When the uController has completed updating all SFP stats for one interval,
   // the current UC write bank is promoted for reads by the link engine.  While either agent is
   // performing reads or writes, the bank is locked and may not be switched.


wire   [2:0]       rsta_busy;
wire   [2:0]       rstb_busy;
s5_ram1w1r_1024x32b stats_ram0
     (// Outputs
 . rsta_busy            ( rsta_busy[0]                                       ), // output
 . rstb_busy            ( rstb_busy[0]                                       ), // output
 . doutb                ( stats_ram0_rd_data[31:0]                           ), // Inputs
 . rstb                 ( ~rst_n                                             ), 
 . clka                 ( clk                                                ), 
 . clkb                 ( clk                                                ), 
 . dina                 ( uc_data[31:0]                                      ), 
 . addrb                ( stats_ram0_rd_addr[9:0]                            ), 
 . addra                ( uc_addr[9:0]                                       ), 
 . wea                  ( stats_ram0_wr_en                                   )  
);

 

//wire                  rsta_busy;
//wire                  rstb_busy;
s5_ram1w1r_1024x32b stats_ram1
     (// Outputs
 . rsta_busy            ( rsta_busy[1]                                       ), // output
 . rstb_busy            ( rstb_busy[1]                                       ), // output
 . doutb                ( stats_ram1_rd_data[31:0]                           ), // Inputs
 . rstb                 ( ~rst_n                                             ), 
 . clka                 ( clk                                                ), 
 . clkb                 ( clk                                                ), 
 . dina                 ( uc_data[31:0]                                      ), 
 . addrb                ( stats_ram1_rd_addr[9:0]                            ), 
 . addra                ( uc_addr[9:0]                                       ), 
 . wea                  ( stats_ram1_wr_en                                   )  
);



   assign stats_ram0_wr_en = sm_uc_wr_ram & ~uc_wrbank_sel;
   assign stats_ram1_wr_en = sm_uc_wr_ram &  uc_wrbank_sel;

   // if uc_wrbank_sel=1, indicates UC is writing to bank 1.  Bank 0 should be read by LE
   assign stats_ram0_rd_addr[9:0] =  uc_wrbank_sel ? {le_ucstats_addr[9:0]} : uc_addr[9:0];
   // if uc_wrbank_sel=0, indicates UC is writing to bank 0.  Bank 1 should be read by LE
   assign stats_ram1_rd_addr[9:0] = ~uc_wrbank_sel ? {le_ucstats_addr[9:0]} : uc_addr[9:0];

   // flop PCIE interface signals into core clock domain
   
   vi_sync_level #(.SIZE(32)) sync_pcie_misc_status
     (.out_level (pcie_misc_status_sync[31:0]),
      .in_level  (pcie_misc_status[31:0]),
      .clk       (clk),
      .rst_n     (uc_rst_n));
   vi_sync_level #(.SIZE(2)) sync_pcie_enc_lane_act
     (.out_level (pcie_enc_lane_act_sync[1:0]),
      .in_level  (pcie_enc_lane_act[1:0]),
      .clk       (clk),
      .rst_n     (uc_rst_n));
   vi_sync_level #(.SIZE(2)) sync_pcie_current_speed
     (.out_level (pcie_current_speed_sync[1:0]),
      .in_level  (pcie_current_speed[1:0]),
      .clk       (clk),
      .rst_n     (uc_rst_n));
   vi_sync_level #(.SIZE(5)) sync_pcie_ltssm
     (.out_level (pcie_ltssm_sync[4:0]),
      .in_level  (pcie_ltssm[4:0]),
      .clk       (clk),
      .rst_n     (uc_rst_n));

   // PCIE_misc_status encoding
   // -------------------------------
   //  7'h0,                                                 // [31:25]
   //  heart_beat,                                           // [24]
   //  iRST_NPOR_n,                                          // [23]
   //  pcie_gen3x8_inst_hip_status_lane_act[3:0],            // [22:19]
   //  pcie_gen3x8_inst_hip_currentspeed_currentspeed[1:0],  // [18:17]
   //  rst_controller_reset_out_reset,                       // [16]
   //  oLTSSM[4:0],                                          // [15:11]
   //  oAPP_RST_n_STATUS,                                    // [10]
   //  pcie_gen3x8_inst_hip_status_dlup_exit,                // [9]
   //  pcie_gen3x8_inst_hip_status_hotrst_exit,              // [8]
   //  pcie_gen3x8_inst_hip_status_l2_exit,                  // [7]
   //  pcie_gen3x8_inst_hip_status_dlup,                     // [6]
   //  alt_xcvr_reconfig_0_reconfig_busy_reconfig_busy,      // [5]
   //  pcie_gen3x8_inst_hip_rst_reset_status,                // [4]
   //  pcie_gen3x8_inst_hip_rst_serdes_pll_locked,           // [3]
   //  apps_hip_rst_pld_core_ready,                          // [2]
   //  pcie_gen3x8_inst_hip_rst_pld_clk_inuse,               // [1]
   //  iPIN_PERST_n                                          // [0]

   // UC RAM read data
   always @(posedge clk or negedge uc_rst_n) begin
      data_to_uc[31:0] <= ~uc_rst_n                                         ? 32'd0 :
                          ((sm_uc_state[4:0]==SM_UC_ADDR_DEC) & invalid_addr) ? 32'hdeadbeef :
			  addr_is_coolcode                                    ? 32'hC001C0DE :
			  addr_is_tempsense                                   ? {24'h0,tsdcalo[7:0]} :
			  addr_is_pcie_status                                 ? {2'h0,
										 pcie_misc_status_sync[24:23],
										 pcie_misc_status_sync[16],
										 pcie_misc_status_sync[10:0],
										 2'h0,pcie_enc_lane_act_sync[1:0],
										 2'h0,pcie_current_speed_sync[1:0],
										 3'h0,pcie_ltssm_sync[4:0]} :
			  addr_is_fpga_ver_0                                  ? fpga_rev[31:0] :
			  addr_is_fpga_ver_1                                  ? fpga_rev[63:32] :
                          (sm_uc_rd_ram & uc_wrbank_sel)                      ? stats_ram1_rd_data[31:0] :
                          (sm_uc_rd_ram & ~uc_wrbank_sel)                     ? stats_ram0_rd_data[31:0] :
                          data_to_uc[31:0];
   end
   
   // LE RAM read data
   always @(posedge clk or negedge rst_n) begin
      ucstats_data[31:0] <= ~rst_n ? 32'd0 :
                            uc_wrbank_sel ? stats_ram0_rd_data[31:0] :
                            stats_ram1_rd_data[31:0];
   end
   
   // ----------------------
   // SFP Stat Shadow RAM
   // ----------------------
   // UC writes on shadowed and available for PCIE based register access
   

//wire                  rsta_busy;
//wire                  rstb_busy;
s5_ram1w1r_1024x32b stats_ram_regs
     (// Outputs
 . rsta_busy            ( rsta_busy[2]                                       ), // output
 . rstb_busy            ( rstb_busy[2]                                       ), // output
 . doutb                ( iUCSTATS_MM_RD_DATA[31:0]                          ), // Inputs
 . rstb                 ( ~rst_n                                             ), 
 . clka                 ( clk                                                ), 
 . clkb                 ( clk                                                ), 
 . dina                 ( uc_data[31:0]                                      ), 
 . addrb                ( oLE_UCSTATS_MM_ADDR[9:0]                           ), 
 . addra                ( uc_addr[9:0]                                       ), 
 . wea                  ( sm_uc_wr_ram                                       )  
);


//   // Link engine expects two cycle delay for data
//   always @(posedge clk or negedge reset_n)
//     iUCSTATS_MM_RD_DATA[31:0] <= ~reset_n ? 32'd0 : stats_ram_rd_data[31:0];
   
 
   // ----------------------
   // Drive UC Read Data
   // ----------------------

   // plan is to flop these signals at the I/O drivers
   assign io_uc_data_out_val  = (sm_uc_rd_drive0 | sm_uc_rd_drive1 | sm_uc_rd_drive2 | sm_uc_rd_drive3);
   assign io_uc_data_out[7:0] = sm_uc_rd_drive0 ? data_to_uc[7:0]   :
                                sm_uc_rd_drive1 ? data_to_uc[15:8]  :
                                sm_uc_rd_drive2 ? data_to_uc[23:16] : data_to_uc[31:24];


   // -------------------------------------
   // SFP Stat RAM rd/wr ptr state machine
   // -------------------------------------
   // This state machine tracks the read and write operations on the SFP stat RAM.  Once each reader or
   // writer has started its operation, the SFP bank select stays fixed until the read or write operation
   // completes - to prevent reading or writing from different collection intervals.  The basic goal is to
   // change bank selects once a complete interval write has completed.  If the bank select cannot change
   // (because of ongoing reads/writes), it is deferred until an idle period when the bank select can
   // be changed.  

   localparam SM_BANK_IDLE           = 3'h0;
   localparam SM_BANK_WRITING        = 3'h1;
   localparam SM_BANK_INTERVAL_DONE  = 3'h2;
   localparam SM_BANK_UPDATE         = 3'h3;
   localparam SM_BANK_ERROR          = 3'h7;

   always @(posedge clk or negedge uc_rst_n) begin
      if (~uc_rst_n)
        sm_bank_state[2:0] <= SM_BANK_IDLE;
      else begin
         case (sm_bank_state[2:0])

           // IDLE - no pending bank select change.  wait for next write
           SM_BANK_IDLE :
             sm_bank_state[2:0] <= sm_uc_wr_ram ? SM_BANK_WRITING : SM_BANK_IDLE;
           
           // WRITING : writing into SFP state.  Stay here until UC indicates write is done and
           //           has released the bank select lock
           SM_BANK_WRITING :
             sm_bank_state[2:0] <= uc_interval_done ? SM_BANK_INTERVAL_DONE : SM_BANK_WRITING;
           
           // INTERVAL_DONE : attempt to change bank select.  Hold-off if SFP read is ongoing.  
           //                 New write goes back to writing state.  
           SM_BANK_INTERVAL_DONE:
             sm_bank_state[2:0] <= le_reading    ? SM_BANK_INTERVAL_DONE :
                                   sm_uc_wr_ram  ? SM_BANK_WRITING : SM_BANK_UPDATE;

           SM_BANK_UPDATE: 
             sm_bank_state[2:0] <= SM_BANK_IDLE;

           SM_BANK_ERROR:
             sm_bank_state[2:0] <= SM_BANK_ERROR;

           default:
             sm_bank_state[2:0] <= SM_BANK_ERROR;

         endcase // case (sm_bank_state[2:0])
      end // else: !if(~uc_rst_n)
   end // always @ (posedge clk or negedge uc_rst_n)

   assign ucstats_sm_bank_error    = (sm_bank_state[2:0]==SM_BANK_ERROR);

   // uc_wrbank_sel indicates the bank UC is currently writing (0 = bank 0, 1 = bank 1)
   always @(posedge clk or negedge uc_rst_n) begin
      uc_wrbank_sel <= ~uc_rst_n    ? 1'b0 :
                       (sm_bank_state[2:0]==SM_BANK_UPDATE) ? ~uc_wrbank_sel :
                       uc_wrbank_sel;
   end
         
   // le_reading indicates there is an outstanding read.  
   always @(posedge clk or negedge uc_rst_n) begin
      le_reading_q <= ~uc_rst_n     ? 1'b0 :
                      le_ucstats_req  ? 1'b1 :
                      le_ucstats_done ? 1'b0 : le_reading_q;
   end
   assign le_reading = (le_reading_q | le_ucstats_req);

   // stat
   assign ucstats_collision_count_en    = ((sm_bank_state[2:0]==SM_BANK_INTERVAL_DONE) & le_reading);

   
   // ----------------------
   // Link Engine Request 
   // ----------------------

   always @(posedge clk or negedge rst_n) begin
      ucstats_gnt <= ~rst_n ? 1'd0  : le_ucstats_req;
   end
   

   // --------------------------
   // Control Registers
   // --------------------------

//   always @(posedge clk or negedge reset_n) begin
//      le_req_count[31:0]        <=  ~reset_n ? 32'd0 : 
//                                    (ucstats_le_req_event & (le_req_count[31:0]!=32'hffff_ffff)) ? le_req_count[31:0] + 32'd1:
//                                    le_req_count[31:0];
//      le_done_count[31:0]       <=  ~reset_n ? 32'd0 : 
//                                    (ucstats_le_done_event & (le_done_count[31:0]!=32'hffff_ffff)) ? le_done_count[31:0] + 32'd1:
//                                    le_done_count[31:0];
//      uc_rd_count[31:0]         <=  ~reset_n ? 32'd0 : 
//                                    (ucstats_uc_rd_event & (uc_rd_count[31:0]!=32'hffff_ffff)) ? uc_rd_count[31:0] + 32'd1:
//                                    uc_rd_count[31:0];
//      uc_wr_count[31:0]         <=  ~reset_n ? 32'd0 : 
//                                    (ucstats_uc_wr_event & (uc_wr_count[31:0]!=32'hffff_ffff)) ? uc_wr_count[31:0] + 32'd1:
//                                    uc_wr_count[31:0];
//      uc_done_count[31:0]       <=  ~reset_n ? 32'd0 : 
//                                    (ucstats_uc_done_event & (uc_done_count[31:0]!=32'hffff_ffff)) ? uc_done_count[31:0] + 32'd1:
//                                    uc_done_count[31:0];
//      uc_early_done_count[31:0] <=  ~reset_n ? 32'd0 : 
//                                    (ucstats_uc_early_done_event & (uc_early_done_count[31:0]!=32'hffff_ffff)) ? uc_early_done_count[31:0] + 32'd1:
//                                    uc_early_done_count[31:0];
//      uc_inv_addr_count[31:0]   <=  ~reset_n ? 32'd0 : 
//                                    (ucstats_uc_invalid_addr_event & (uc_inv_addr_count[31:0]!=32'hffff_ffff)) ? uc_inv_addr_count[31:0] + 32'd1:
//                                    uc_inv_addr_count[31:0];
//      uc_done_count[31:0]       <=  ~reset_n ? 32'd0 : 
//                                    (ucstats_uc_done_event & (uc_done_count[31:0]!=32'hffff_ffff)) ? uc_done_count[31:0] + 32'd1:
//                                    uc_done_count[31:0];
//   end // always @ (posedge clk or negedge reset_n)


   ucstats_regs ucstats_regs
     (// Outputs
      .rd_data				(cr_rd_data[63:0]),	 
      .rd_data_v			(cr_rd_data_v),		 
      .oREG_UCSTAT_CTL_TEMPSENSE_EN	(temp_sense_en),	 
      .oREG_UCSTAT_CTL_LE_EN		(cr_ctl_le_en),		 
      .oREG_UCSTAT_CTL_UC_EN		(cr_ctl_uc_en),		 
      // Inputs
      .clk				(clk),
      .rst_n				(rst_n),		 
      .wr_en				(cr_wr_en),		 
      .rd_en				(cr_rd_en),		 
      .addr				(cr_addr[9:0]),		 
      .wr_data				(cr_wr_data[63:0]),	 
      .iREG_UCSTAT_ADDR			(uc_addr[15:0]),
      .iREG_UCSTAT_DATA_IN		(uc_data[31:0]),
      .iREG_UCSTAT_DATA_OUT		(data_to_uc[31:0]),
      .iREG_UCSTAT_COLLISION_CYCLE_COUNT_EN(ucstats_collision_count_en),
      .iREG_UCSTAT_LE_REQ_COUNT_EN	(ucstats_le_req_event),
      .iREG_UCSTAT_LE_DONE_COUNT_EN	(ucstats_le_done_event),
      .iREG_UCSTAT_UC_RD_COUNT_EN	(ucstats_uc_rd_event),
      .iREG_UCSTAT_UC_WR_COUNT_EN	(ucstats_uc_wr_event),
      .iREG_UCSTAT_UC_DONE_COUNT_EN	(ucstats_uc_done_event),
      .iREG_UCSTAT_UC_EARLY_DONE_COUNT_EN(ucstats_uc_early_done_event),
      .iREG_UCSTAT_UC_INVALID_ADDR_COUNT_EN(ucstats_uc_invalid_addr_event),
      .iREG_UCSTAT_ERRORS_SM_BANK_ERROR	(ucstats_sm_bank_error), 
      .iREG_UCSTAT_ERRORS_SM_UC_ERROR	(ucstats_sm_uc_error),	 
      .iREG_UCSTAT_FPGA_TEMP_DONE	(tsdcaldone),		 
      .iREG_UCSTAT_FPGA_TEMP_TEMP	(tsdcalo[7:0])
      /*AUTOINST*/);
   


   // --------------------------
   // Temperature Sensor
   // --------------------------

   always @(posedge clk or negedge rst_n) begin
      temp_sense_timer[26:0] <= ~rst_n ? 27'd0 : (temp_sense_timer[26:0]+27'd1);
   end

   vi_sync_level #(.SIZE(1)) vi_sync_level_tsdcaldone
     (.out_level (tsdcaldone),
      .in_level  (tsdcaldone_d),
      .clk       (clk),
      .rst_n     (uc_rst_n));
   vi_sync_level #(.SIZE(1)) vi_sync_level_tsdcalo
     (.out_level (tsdcalo[7:0]),
      .in_level  (tsdcalo_d[7:0]),
      .clk       (clk),
      .rst_n     (uc_rst_n));

   // 4.7ns x 2^27 -> ~630ms
   assign temp_sense_clr = ~rst_n | (temp_sense_timer[26:0]>27'h7ff_fff0);
/*
   s5_alttemp_sense s5_alttemp_sense
     (// Outputs
      .tsdcaldone       (tsdcaldone_d),
      .tsdcalo          (tsdcalo_d[7:0]),
      // Inputs
      .ce               (temp_sense_en),
      .clk              (clk),
      .clr              (temp_sense_clr));
*/
   assign tsdcaldone_d = 0;
   assign tsdcalo_d = 0;

   // ----------------------
   // Assertions
   // ----------------------

   // synthesis translate_off

   // SFP Stat RAM:  UC write to bank that is being read.   
   assert_uc_write_to_wrong_sfp_bank : assert property 
   ( @(posedge clk) 
     disable iff (~rst_n)
     !$rose(le_reading & ( (stats_ram1_wr_en & (uc_wrbank_sel==0)) | (stats_ram0_wr_en & (uc_wrbank_sel==1)) ))  );
   
   // LE Interface : Link engine request while previous read is still ongoing
   assert_invalid_new_link_engine_read : assert property 
   ( @(posedge clk)
     disable iff (~rst_n)
     !$rose(le_reading_q & le_ucstats_req & ~le_ucstats_req_q));
   
   // LE Interface : le_ucstats_done asserted while we are *not* in reading state
   assert_invalid_le_ucstats_done : assert property 
   ( @(posedge clk)
     disable iff (~rst_n)
     !$rose(~le_reading & le_ucstats_done));
   
   // LE Interface : ucstats_gnt asserted while we are *not* in reading state
   assert_invalid_le_ucstats_gnt : assert property 
   ( @(posedge clk)
     disable iff (~rst_n)
     !$rose(~le_reading & ucstats_gnt));
   
   // UC Interface : Invalid FPGA drive conditions: UC is still master, no chip-select
   assert_invalid_uc_data_out_drive : assert property 
   ( @(posedge clk)
     disable iff (~rst_n)
     !$rose(io_uc_data_out_val & (io_uc_master | ~io_uc_cs)));

   // UC Interface : Early CS negation
   assert_unexpected_early_cs_negation : assert property 
   ( @(posedge clk)
     disable iff (~rst_n)
     !$rose(ucstats_uc_early_done_event));

   // UC state machine in error state
   assert_sm_uc_in_error_state : assert property 
   ( @(posedge clk)
     disable iff (~rst_n)
     !$rose(sm_uc_state[4:0]==SM_UC_ERROR));
   
   // bank state machine in error state
   assert_sm_bank_in_error_state : assert property 
   ( @(posedge clk)
     disable iff (~rst_n)
     !$rose(sm_bank_state[2:0]==SM_BANK_ERROR));

   // synthesis translate_on


endmodule
 
// Local Variables:
// verilog-library-directories:("." "../docs" "ip/" "auto")
// verilog-library-extensions:(".v" ".sv" ".h")
// End:
