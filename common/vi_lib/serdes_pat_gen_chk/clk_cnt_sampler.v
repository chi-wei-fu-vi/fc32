/********************************CONFIDENTIAL****************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: File_name.v$
* $Author: Author_Name$
* $Date: 2012-05-23 00:45:19 -0700 (Wed, 23 May 2012) $
* $Revision: 35 $
* Description:
*
* This module can be used to sample, for instance, the SERDES recovered clock
* to ensure the period/frequency is correct.  This is a diagnostic module
* whose outputs (oCLK_CNT) is intended to be read by a tool like dal_regs.py.
* If frequency of iCLK_SAMPLE is constant then oCLK_CNT will be constant.
*
* Upper level dependencies:
* Lower level dependencies:
*
* Revision History Notes:
*
* 05/22/2012 tmb - Initial release
* 05/02/2013 tmb - added sync_level (set_false_path)
* 05/30/2013 tmb - vi_sync_level replaces sync_level. set_false_path done in SDC now. 
*
***************************************************************************/

`timescale 1ns / 1ps


// Aside on how to choose: CNT_CMP_THRESH
// If say you were to set clk ctr such that 8G datarate will show 0x80_0000
// s/w readable register
// 0x80_0000 = 8388608 ticks = 39.476ms
// In 50MHz domain 39ms is: 1973790 ticks or 0x1E1E1E


module clk_cnt_sampler
#(
  parameter CNT_CMP_THRESH = 1973790
)
(
  input         iRST_50M,
  input         iRST_SAMPLE,
  input         iCLK_50M,
  input         iCLK_SAMPLE,

  output logic [23:0] oCLK_CNT
);

///////////////////////////////////////////////////////////////////////////////
//
// Signals
//
///////////////////////////////////////////////////////////////////////////////
logic [23:0] clk_cnt_latch;
logic [23:0] clk_ctr_sample;
logic [21:0] clk_ctr_50m;
logic        rst_pulse_50m;
logic        rst_pulse_sample;

///////////////////////////////////////////////////////////////////////////////
//
// Output
//
///////////////////////////////////////////////////////////////////////////////

vi_sync_level 
#(
 .SIZE (24)
  )
sync_level_inst
(
 .out_level  (oCLK_CNT),
 .clk        (iCLK_50M),  // destination clock domain.
 .rst_n      (~iRST_50M),
 .in_level   (clk_cnt_latch)
);
   

///////////////////////////////////////////////////////////////////////////////
//
// Counter in clock domain to be sampled
//
///////////////////////////////////////////////////////////////////////////////
always @(posedge iCLK_SAMPLE or posedge iRST_SAMPLE)
begin
  if(iRST_SAMPLE)
  begin
    clk_cnt_latch  <= '0;
    clk_ctr_sample <= '0;
  end
  else
  begin
    if(rst_pulse_sample)
    begin
      clk_cnt_latch <= clk_ctr_sample;
      clk_ctr_sample <= '0;
    end
    else
    begin
      clk_cnt_latch  <= clk_cnt_latch;
      clk_ctr_sample <= clk_ctr_sample + 1'b1;
    end
  end
end


///////////////////////////////////////////////////////////////////////////////
//
// Counter in 50M clock domain. Reset created in this domain.
//
///////////////////////////////////////////////////////////////////////////////
always @(posedge iCLK_50M or posedge iRST_50M)
begin
  if(iRST_50M)
  begin
    rst_pulse_50m <= 1'b0;
    clk_ctr_50m <= '0;
  end
  else
  begin
    rst_pulse_50m <= 1'b0; // default

    if(clk_ctr_50m == CNT_CMP_THRESH)
    begin
      rst_pulse_50m <= 1'b1;
      clk_ctr_50m = '0;
    end
    else
      clk_ctr_50m <= clk_ctr_50m + 1'b1;
  end
end


///////////////////////////////////////////////////////////////////////////////
//
// Pass reset from 50M to sampled clock domain
//
///////////////////////////////////////////////////////////////////////////////
vi_sync_pulse vi_sync_pulse_inst
(
  .rsta_n         (~iRST_50M),
  .clka           (iCLK_50M),
  .in_pulse       (rst_pulse_50m),
  .clkb           (iCLK_SAMPLE),
  .rstb_n         (~iRST_SAMPLE),
  .out_pulse      (rst_pulse_sample)
);


endmodule
