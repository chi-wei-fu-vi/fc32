//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_pkg.sv $
// $Author: chi-wei.fu $
// $Date: 2017-03-29 08:50:57 -0700 (Wed, 29 Mar 2017) $
// $Revision: 14579 $
//**************************************************************************/

module fmac_credit_cntr
  (
    // ----------------
    // Interval Stats
    // ----------------

    output logic [31:0]        int_stats_timecr,
    output logic [31:0]         int_stats_mincr,
    output logic [31:0]         int_stats_maxcr,
    output logic [31:0]         int_stats_endcr,

    // ---------------------
    // registers
    // ---------------------

    input [31:0]                reg_fmac_credit_start,
    output logic [15:0]        reg_fmac_vc_id,
   
    // ---------------------
    // Misc
    // ---------------------

    input                       int_stats_latch_clr,        // pulsed - clear or latch interval stat counters

    // ---------------------
    // fmac_efifo Interface
    // ---------------------

    input [1:0] [15:0]	        vc_id,                      // per slot, vc_id for r_rdy
    input [1:0]                 pair_vc_rdy_event,
    input [1:0]                 vc_id_ld,                   // per slot, load the vc_id flop with a new vc_id
    input		        reg_sof_cnt_en,
    input [15:0]	        sof_vc_id,                  // VC_ID of SOF frame
    input                       reg_link_up_cnt_en,         // link up event, pulsed - resets counter

    // ----------------
    // Reset & Clocks
    // ----------------
    input                        rst_n,                      // asynchronous core clock chip reset
    input                        clk                         // core clock, 212.5Mhz

   );

   //---------------
   // Declarations
   //---------------
   logic 			 sof_match, new_credit_start;
   logic [1:0] 			 vc_rdy_match;
   logic [31:0] 			 credit_ctr, min_credit_value, max_credit_value, last_credit_start;
   logic 			 credit_ctr_at_min, credit_ctr_at_max, credit_ctr_at_max_m1;
   logic [15:0] 		 vc_id_q;
   logic [31:0] 		 time_min_credit;
   

   //---------------
   // Overview
   //---------------
   // This module tracks credit values in a 10b counter.  The counter is
   // initialized to a starting value that is at the half way point.  SOFs
   // decrement the counter and R_RDYs/VC_RDYs increment the counter.  The
   // counter contains a VC_ID register which is loaded once with the
   // virtual channel ID.  Subsequent SOFs and VC_RDY's check against the
   // VC_ID to determine whether to update this counter.  In the case
   // virtual channels are not used, this counter module can be instantiated
   // to work without virtual channels.  The counter does not overflow or
   // underflow.  Certain events (link_up, new counter initialization value)
   // resets the counter back to a new starting value.

   //---------------
   // VC_ID
   //---------------
   // Load new vc_id.  This should only happen once - we don't expect multiple loads.  
   always_ff @(posedge clk or negedge rst_n)
     vc_id_q[15:0] <= ~rst_n      ? 16'd0 :
		      vc_id_ld[0] ? vc_id[0][15:0] :
		      vc_id_ld[1] ? vc_id[1][15:0] :
		      vc_id_q[15:0];

   assign sof_match        = (vc_id_q[15:0]==sof_vc_id[15:0]) & reg_sof_cnt_en;
   assign vc_rdy_match[0]  = (vc_id_q[15:0]==vc_id[0][15:0]) & pair_vc_rdy_event[0];
   assign vc_rdy_match[1]  = (vc_id_q[15:0]==vc_id[1][15:0]) & pair_vc_rdy_event[1];
   assign reg_fmac_vc_id[15:0] = vc_id_q[15:0];

   //---------------
   // Credit counter
   //---------------

   always_ff @( posedge clk or negedge rst_n) 
      last_credit_start[31:0] <= ~rst_n ? 32'd0 : reg_fmac_credit_start[31:0];
      
   assign new_credit_start  = (reg_fmac_credit_start[31:0]!=last_credit_start[31:0]);
   assign credit_ctr_at_min = (credit_ctr[31:0]==32'h0);
   assign credit_ctr_at_max = (credit_ctr[31:0]==32'hFFFFFFFF);
   assign credit_ctr_at_max_m1 = (credit_ctr[31:0]==32'hFFFFFFFE);

   // maintain credit cntr.  
   always_ff @(posedge clk or negedge rst_n) begin

      // reset value is not that important since we expect this register to be loaded
      if (~rst_n)
	credit_ctr[31:0] <= 32'h1000000;

      // reset the counter if a new value is detected in the fmac_credit_start register
      // or on a link-up event, or on load of a new vc_id
      else if (new_credit_start | reg_link_up_cnt_en | (|vc_id_ld[1:0])) 
	credit_ctr[31:0] <= reg_fmac_credit_start[31:0];

      else begin
	unique casez ({sof_match, vc_rdy_match[1:0], credit_ctr_at_min, credit_ctr_at_max, credit_ctr_at_max_m1})

	  // increment credit count on every VC_RDY that matches the vc_id.
	  // don't update on simultaneous sof or if the count is already at max
	  // handle cases where there are two VC_RDYs
	  6'b0_01_?_0_? : credit_ctr[31:0] <= (credit_ctr[31:0]+32'd1);
	  6'b0_10_?_0_? : credit_ctr[31:0] <= (credit_ctr[31:0]+32'd1);
	  6'b0_11_?_0_0 : credit_ctr[31:0] <= (credit_ctr[31:0]+32'd2);
	  6'b0_11_?_0_1 : credit_ctr[31:0] <= (credit_ctr[31:0]+32'd1);
	  6'b1_11_?_0_? : credit_ctr[31:0] <= (credit_ctr[31:0]+32'd1);

	  // decrement credit count on every new SOF that matches the vc_id.
	  // don't update on simultaneous vc_rdy or if the count is already at 0
	  6'b1_00_0_?_? : credit_ctr[31:0] <= (credit_ctr[31:0]-32'd1);

	  // simultaneous SOF and VC_RDY cases do not change the credit_ctr
	  // if the value is at max or min, we do not overflow/underflow
	  default       : credit_ctr[31:0] <= credit_ctr[31:0];

	endcase
      end
   end // always_ff @


   // ----------------
   // Interval Stats
   // ----------------

   always_ff @(posedge clk or negedge rst_n) begin
      int_stats_endcr[31:0]   <= ~rst_n              ? 32'h1000000 : 
				int_stats_latch_clr ? credit_ctr[31:0] : 
				int_stats_endcr[31:0];
      int_stats_timecr[31:0] <= ~rst_n              ? 32'd0 :
				int_stats_latch_clr ? time_min_credit[31:0] :
				int_stats_timecr[31:0];
      int_stats_mincr[31:0]   <= ~rst_n              ? 32'd0 :
				int_stats_latch_clr ? min_credit_value[31:0] :
				int_stats_mincr[31:0];
      int_stats_maxcr[31:0]   <= ~rst_n              ? 32'd0 :
				int_stats_latch_clr ? max_credit_value[31:0] :
				int_stats_maxcr[31:0];
   end

   // ------------------
   // Time at Min Credit
   // ------------------

   always_ff @(posedge clk or negedge rst_n) begin
     time_min_credit[31:0]  <= ~rst_n ? 32'd0 :
			       (int_stats_latch_clr | new_credit_start | reg_link_up_cnt_en) ? 32'd0 :
			       ((credit_ctr[31:0] == min_credit_value[31:0]) & (time_min_credit[31:0] != 32'hFFFF_FFFF)) ? time_min_credit[31:0]+32'd1 :
			       (credit_ctr[31:0] < min_credit_value[31:0]) ? 32'd1 :
			       time_min_credit[31:0];
      min_credit_value[31:0] <= ~rst_n ? 32'hFFFFFFFF :
			       (int_stats_latch_clr | new_credit_start | reg_link_up_cnt_en) ? 32'hFFFFFFFF :
			       (credit_ctr[31:0] < min_credit_value[31:0]) ? credit_ctr[31:0] :
			       min_credit_value[31:0];
   end // always_ff @

   // ------------------
   // Max Credit
   // ------------------

   always_ff @(posedge clk or negedge rst_n)
      max_credit_value[31:0] <= ~rst_n ? 32'h0 :
			       (int_stats_latch_clr | new_credit_start | reg_link_up_cnt_en) ? 32'h0 :
			       (credit_ctr[31:0] > max_credit_value[31:0]) ? credit_ctr[31:0] :
			       max_credit_value[31:0];
   
   // ------------------
   // Assertions
   // ------------------

   // synopsys translate_off

   // synopsys translate_on

endmodule
