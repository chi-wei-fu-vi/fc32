//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_pkg.sv $
// $Author: chi-wei.fu $
// $Date: 2017-03-29 08:50:57 -0700 (Wed, 29 Mar 2017) $
// $Revision: 14579 $
//**************************************************************************/

module fmac_credit_stats 
  (

    // ---------------------
    // fmac_efifo Interface
    // ---------------------

    input                       reg_link_up_cnt_en,         // link up event, pulsed - resets counter

    // ---------------------
    // registers
    // ---------------------

    input [2:0]                reg_fmac_vc_sel,             // ISL - not used right now
    input [31:0]                reg_fmac_credit_start,
    input                      reg_sof_cnt_en,              // from current channel
    input [1:0]                fmac_in_r_rdy,               // from paired channel


    // ---------------------
    // FMAC level
    // ---------------------

    input                      int_stats_latch_clr,        // pulsed - clear interval stat counters

    // ---------------------
    // fmac_rcv Interface
    // ---------------------

    output logic [15:0]	       reg_fmac_vc_id,
    output logic [31:0]         int_stats_mincr,
    output logic [31:0]         int_stats_maxcr,
    output logic [31:0]         int_stats_endcr,
    output logic [31:0]        int_stats_timecr,

    // ----------------
    // Reset & Clocks
    // ----------------
    input                        rst_n,                      // asynchronous core clock chip reset
    input                        clk                         // core clock, 212.5Mhz

   );

   //---------------
   // Declarations
   //---------------

   logic  			 vc_id_ld;
   logic [4:0] 			 count_up;

   // The credit_cntr is based on VC_ID's and needs to be loaded with the matching
   // VC_ID.  Generate a single pulse keyed off reset to perform the load in the
   // non ISL version of Bali

   always_ff @(posedge clk or negedge rst_n)
     count_up[4:0] <= ~rst_n ? 5'd0 :
		      (count_up[4:0]!= 5'h1F) ? (count_up[4:0]+5'd1) : count_up[4:0];

   assign vc_id_ld  = (count_up[4:0]==5'h1E);

    logic [15:0]	      reg_fmac_vc_id_r;
    logic [31:0]         int_stats_mincr_r;
    logic [31:0]         int_stats_maxcr_r;
    logic [31:0]         int_stats_endcr_r;
    logic [31:0]        int_stats_timecr_r;

		always @(posedge clk or negedge rst_n)
      if (!rst_n)
			begin
         reg_fmac_vc_id <= 'h0;
         int_stats_mincr <= 'h0;
         int_stats_maxcr <= 'h0;
         int_stats_endcr <= 'h0;
         int_stats_timecr <= 'h0;
			end
			else
			begin
         reg_fmac_vc_id <= reg_fmac_vc_id_r;
         int_stats_mincr <= int_stats_mincr_r;
         int_stats_maxcr <= int_stats_maxcr_r;
         int_stats_endcr <= int_stats_endcr_r;
         int_stats_timecr <= int_stats_timecr_r;
			end
		
   // This is a VC-based credit cntr module.  For non ISL version of Bali, the vc_rdy
   // ports are tied to r_rdy and we force VC_ID to always be 16'd1.  

   /*fmac_credit_cntr AUTO_TEMPLATE 
    (// Inputs
    .vc_id		({2{16'd1}}),
    .sof_vc_id		({16'd1}),
    .vc_id_ld		({1'b0,vc_id_ld}),
    .pair_vc_rdy_event	(fmac_in_r_rdy[]),
    ); */

   fmac_credit_cntr fmac_credit_cntr
     (/*AUTOINST*/
      // Outputs
      .int_stats_timecr			(int_stats_timecr_r[31:0]),
      .int_stats_mincr			(int_stats_mincr_r[31:0]),
      .int_stats_maxcr			(int_stats_maxcr_r[31:0]),
      .int_stats_endcr			(int_stats_endcr_r[31:0]),
      .reg_fmac_vc_id			(reg_fmac_vc_id_r[15:0]),
      // Inputs
      .reg_fmac_credit_start		(reg_fmac_credit_start[31:0]),
      .int_stats_latch_clr		(int_stats_latch_clr),
      .vc_id				({2{16'd1}}),		 // Templated
      .pair_vc_rdy_event		(fmac_in_r_rdy[1:0]),	 // Templated
      .vc_id_ld				({1'b0,vc_id_ld}),	 // Templated
      .reg_sof_cnt_en			(reg_sof_cnt_en),
      .sof_vc_id			({16'd1}),		 // Templated
      .reg_link_up_cnt_en		(reg_link_up_cnt_en),
      .rst_n				(rst_n),
      .clk				(clk));
       
   
   // **** ISL Features are not enabled in first version of Bali ****
   //
   // Brocade uses fixed channel virtual assignment. 
   // 
   // VCs=8 if no QOS
   //
   // VC
   // ---------------------
   // 0    class F frames (0xFFFFFD D_ID)
   // 1    reserved
   // 2-5  based on D_ID[9:8]
   // 6    class 3 multicast
   // 7    broadcast (0xFFFFFF D_ID)
   //
   // VCs=16 if QOS enabled
   //
   // VC
   // ---------------------
   // 0     class F frames (0xFFFFFD D_ID)
   // 1     reserved
   // 2-5   medium priority, based on D_ID
   // 6     class 3 multicast
   // 7     broadcast (0xFFFFFF D_ID)
   // 8-9   low priority, based on D_ID
   // 10-14 high priority, based on D_ID
   //
   //   generate
   //      for (gi=0; gi<12; gi=gi+1) begin : gen_fmac_credit_cntr
   //	 fmac_credit_cntr fmac_credit_cntr
   //	      (// Outputs
   //	       .int_stats_timecr	(int_stats_timecr[gi][31:0]),
   //	       .int_stats_mincr		(int_stats_mincr[gi][31:0]),
   //	       .int_stats_maxcr		(int_stats_maxcr[gi][31:0]),
   //	       .int_stats_endcr		(int_stats_endcr[gi][31:0]),
   //	       // Inputs
   //	       .reg_fmac_credit_start	(reg_fmac_credit_start[31:0]),
   //	       .int_stats_latch_clr	(int_stats_latch_clr),
   //	       .vc_id			(vc_id/*[1:0][15:0]*/),
   //	       .reg_vc_rdy_cnt_inc	(reg_vc_rdy_cnt_inc[1:0]),
   //	       .vc_id_ld		(vc_id_ld[1:0]),
   //	       .reg_sof_cnt_en		(reg_sof_cnt_en),
   //	       .sof_vc_id		(sof_vc_id[15:0]),
   //	       .reg_link_up_cnt_en	(reg_link_up_cnt_en),
   //	       .rst_n			(rst_n),
   //	       .clk			(clk));
   //      end
   //   endgenerate

endmodule

