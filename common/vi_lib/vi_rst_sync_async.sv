//***************************************************************************
// Copyright (c) 2013,2014 Virtual Instruments.
// 25 Metro Dr, STE#400, San Jose, CA 95110
// www.virtualinstruments.com
// $HeadURL: http://vi-bugs/svn/pld/trunk/projects/bali/fmac/rtl/fmac_efifo.sv $
// $Author: leon.zhou $
// $Date: 2014-01-08 14:01:59 -0800 (Wed, 08 Jan 2014) $
// $Revision: 4163 $
//**************************************************************************/

/* This variation is different from the orignal in that this design is safer.
 *
 * The original desin has an asynchronous path between the input signal 
 * "iRST_ASYNC_N" and the output signal "oRST_SYNC_N".  Because these signals are
 * "false_path", they have no defined timing relationship.  The input to the
 * last flop will not pass the recovery (uTsu) or removal (uTh) time check.
 * The edge will fall into metastability.  Further, a short pulse on
 * iRST_ASYNC_N will cause glitches down the line.  This will cause system
 * failure.
 * 
 * This kind of undeterministic behavior is not desirable, because the
 * post-synthesis functional behavior is different from pre-synthesis
 * simulation.
 *
 * The revised version is an "synchronized asynchronous reset" design as per
 * http://www.altera.com/literature/hb/qts/qts_qii51006.pdf (page 11-25).
 * (Altera Recommended Design Practices)
 *
 * There is a slight modification that the output of the initial synchronizer
 * stage has additional "followers" to help time the reset signal into the
 * design.  These synchronizer followers isolate the asynchronous crossing
 * into the target clock domain such that BOTH the rising AND falling edges of
 * oRST_SYNC_N are synchronous to the clock edge.  The design in the
 * recommendation drives the falling edges asynchronously.
 *
 * This modification makes timing analysis easier, as it creates distance
 * between the async domain and the synchronous domain.  There is no issue
 * with missed input reset pulse should the sampling clock be not available at
 * the time of asychronous input reset (iRST_ASYNC_N) assertion.  This is
 * because the reset synchronizer stage (vi_async_rst) is reset asynchronously
 * by the reset input (iRST_ASYNC_N).  Thus even without a clock, the reset
 * event would have been detected.  The vi_async_rst module goes into an
 * "armed" state.  As soon as the clock becomes available, even if
 * iRST_ASYNC_N is no longer asserted, the synchronized reset output
 * (oRST_SYNC_N) will be asserted for 4 cycles.
 */


module vi_rst_sync_async
  (
   input        iRST_ASYNC_N,    // asynchronous reset input.  must be held until target
                                 // clock is stable
   input        iCLK,            // target clock domain
   output logic oRST_SYNC_N      // async assert, sync de-assert reset
   );

  logic rstn;

  vi_async_rst rst_sig_sync(
    .RST_ASYNC_N (iRST_ASYNC_N),
    .CLK         (iCLK),
    .RST_SYNC_N  (rstn)
  );


   logic       rst_meta_n;
   
	 always @(posedge iCLK) 
	 begin
     rst_meta_n  <= rstn;
     oRST_SYNC_N <= rst_meta_n;
   end           

endmodule
