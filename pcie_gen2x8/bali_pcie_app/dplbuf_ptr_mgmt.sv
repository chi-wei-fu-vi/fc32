/********************************CONFIDENTIAL****************************
* Copyright (c) 2011 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: $
* $Date: 2012-06-07 16:35:27 -0700 (Thu, 07 Jun 2012) $
* $Revision:  $
* Description:
* This module controls the DPL DMA BUFFER write pointer.
* The following conventions were established (based on FC-8)
* buffer size = last pfn - start pfn
* empty buffer = write pointer leads read pointer
* full buffer = write pointer equals read pointer AND when one empty buffer
*
* Upper level dependencies: bali_pcie_app.sv
* Lower level dependencies: none
*
* Revision History Notes:
* 2012/07/29 Tim - initial release
* 2012/08/21 Tim - Fixed bug related to pointer update occurs later in pipeline. (dplbuf_free == '1)
* 2013/05/09 Tim - Flopping operation to fix setup timing violation 
*                  (reduces 0.7ns from critical path to arbiter)
*
*
***************************************************************************/


module dplbuf_ptr_mgmt
(
  input               iRST,
  input               iCLK,
  input               iRST_PTR,                                   
  
  input               iDPLBUF_INC_WR_PTR,
  input  [31:0]       iDPLBUF_START_PFN,
  input  [31:0]       iDPLBUF_LAST_PFN,
  input  [31:0]       iDPLBUF_RD_PTR,
  
  output logic [31:0] oDPLBUF_WR_PTR,
  output logic [31:0] oDPLBUF_FREE,
  output logic        oDPLBUF_FULL
);

parameter BALI = 0;

  logic               inc_wr_ptr;
  logic [31:0]        start_pfn; 
  logic [31:0]        last_pfn;

  logic [31:0]        dplbuf_size;
  logic [31:0]        dplbuf_free;
  logic [31:0]        dplbuf_used;
  logic [31:0]        wr_ptr;
  logic [31:0]        rd_ptr;
  
  
///////////////////////////////////////////////////////////////////////////////
//
// Assign outputs
//
///////////////////////////////////////////////////////////////////////////////  
always_ff @(posedge iRST or posedge iCLK)
  if(iRST)
    oDPLBUF_WR_PTR <= '0;  
  else
    oDPLBUF_WR_PTR <= wr_ptr;  

generate 

/* lz : 3/30/2014
 * BALI project requires PCIe Gen3.  Gen3 usr clk is 250MHz.  An extra stage
 * flop is added to help w/ meeting timing.  Since the FPGA end of the data IF
 * is write only, extra latency in calculating the pointers makes the machine
 * more conservative.  This is a safe condition that will result in (slightly)
 * less efficient use of DPL buffer, but will not cause write-on-full.
 *
 * One can consider adding an extra parameter to bali_pcie_app.sv in the
 * future for GEN3 related changes only.  
 */

if (BALI) begin : bali_out_extr_flop
  always_ff @(posedge iRST or posedge iCLK)
    if(iRST)
	  begin
      oDPLBUF_FREE   <= 'h0;
      oDPLBUF_FULL   <= 'h0;
    end
	  else
	  begin
      oDPLBUF_FREE   <= dplbuf_free;
      oDPLBUF_FULL   <= ((dplbuf_free == 0) || (dplbuf_free == '1) ) ? 1'b1 : 1'b0;
    end
  // 2 states for full (both when all buffers occupied and also (size - 1)
end : bali_out_extr_flop

if (!BALI) begin : no_extr_flop
	assign oDPLBUF_FREE   = dplbuf_free;
	assign oDPLBUF_FULL   = ((dplbuf_free == 0) || (dplbuf_free == '1) ) ? 1'b1 : 1'b0;
end : no_extr_flop

endgenerate


///////////////////////////////////////////////////////////////////////////////
//
// INPUT FLOPS
//
///////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
  begin
    inc_wr_ptr  <= 1'b0;
    start_pfn   <= 32'b0; 
    last_pfn    <= 32'b0;    
    rd_ptr      <= 32'b0;
    dplbuf_size <= '0;
  end
  else
  begin
    inc_wr_ptr  <= iDPLBUF_INC_WR_PTR;
    start_pfn   <= iDPLBUF_START_PFN;
    last_pfn    <= iDPLBUF_LAST_PFN;  
    rd_ptr      <= iDPLBUF_RD_PTR;
    dplbuf_size <= (last_pfn - start_pfn); // tmb(5/9/2013)-flopping operation to fix setup timing violation (reduces 0.7ns from critical path to arbiter)
  end
end
 
 
///////////////////////////////////////////////////////////////////////////////
//
// dplbuf_used - calculate number of 4KB buffers currently used
//
///////////////////////////////////////////////////////////////////////////////
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
     dplbuf_used <= '0;
  else
  begin
    if (wr_ptr > rd_ptr) // write leads read
      dplbuf_used <= wr_ptr - rd_ptr - 1;
    else                 // write lags read
      dplbuf_used <= dplbuf_size - rd_ptr + wr_ptr;  // start ---- wr_ptr ----- rd_ptr ---- last
  end
end

assign dplbuf_free = dplbuf_size - dplbuf_used -1; // since tx_link_arbiter buffers 2x 4KB blocks need to subtract '1' available block to avoid DPL overflow.

///////////////////////////////////////////////////////////////////////////////
//
// DPL Buffer Write Ptr
//
///////////////////////////////////////////////////////////////////////////////
// Use iDPLBUF_INC_WR_PTR to increment wr_ptr instead of inc_wr_ptr so
// that dplbuf_used timing is preserved after it is flopped.
// As a result, oDPLBUF_WR_PTR is flopped and delayed as well.
always_ff @(posedge iRST or posedge iCLK)
begin
  if(iRST)
    wr_ptr <= '0;
  else
    if(iRST_PTR)
      wr_ptr <= start_pfn;
    else if(iDPLBUF_INC_WR_PTR)
      if(wr_ptr == last_pfn)
        wr_ptr <= start_pfn;
      else
        wr_ptr <= wr_ptr + 1;  
end

endmodule
