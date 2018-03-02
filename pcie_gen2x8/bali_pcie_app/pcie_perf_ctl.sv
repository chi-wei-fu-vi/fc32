/********************************CONFIDENTIAL****************************
* Copyright (c) 2012 Virtual Instruments.
* 25 Metro Dr, STE#400, San Jose, CA 95110
* www.virtualinstruments.com
* $Archive: $
* $Author: jaedon.kim$
* $Date: $
* $Revision: $
* Description:
* This module generates control signals for pcie_perf_regs.
*
***************************************************************************/

module pcie_perf_ctl #(

parameter   PORTS        = 12,
parameter   PORT_WIDTH   = $clog2( PORTS )    )

(

   input clk,
   input rst_n,
   input iST_SOP,
   input iST_VAL,
   input [1:0] iST_EMPTY,
   input iST_RDY_N,
   input [PORTS-1:0] iDPLBUF_REQ,
   input [PORTS-1:0] iDPLBUF_GNT,
   input iBLK_DONE,
   input [PORT_WIDTH-1:0] iLINK_NUM,
   input iLATCH,

   input [PORTS-1:0][31:0] iPERF_REQ_TICKS,

   output oPERF_SOP_CTR,
   output logic [2:0] oPERF_BYTE_CTR,
   output oPERF_RDY_N,
   output [PORTS-1:0] oPERF_LINK_REQ,
   output logic [PORTS-1:0] oPERF_LINK_DONE,
   output [PORTS-1:0][31:0] oPERF_TICKS_MAX

);
import pcie_app_pkg::*;

   genvar ii;

   logic [PORTS-1:0][31:0] req_tic_max;

   assign oPERF_SOP_CTR = iST_SOP & iST_VAL;
   assign oPERF_RDY_N = iST_RDY_N;
   assign oPERF_LINK_REQ = (iDPLBUF_REQ) & ~(iDPLBUF_GNT);

generate
    for ( ii=0; ii<PORTS; ii++ ) begin: find_max_generate
        find_max u_find_max (
            .clk        (clk),
            .rst_n      (rst_n),
            .start      (iDPLBUF_REQ[ii]),
            .stop       (iDPLBUF_GNT[ii]),
            .rst_count  (iLATCH),
            .max_count  (oPERF_TICKS_MAX[ii])
        );
    end
endgenerate

   always @* begin
      oPERF_BYTE_CTR = 3'h0;
      case(iST_EMPTY)
        2'h0:oPERF_BYTE_CTR[2] = iST_VAL; // 32B
        2'h1:oPERF_BYTE_CTR[1] = iST_VAL; // 24B
        2'h2:oPERF_BYTE_CTR[0] = iST_VAL; // 16B
        default:oPERF_BYTE_CTR = 3'h0;
      endcase // case (iST_EMPTY)
   end

generate
    for ( ii=0; ii<PORTS; ii++ ) begin: perf_link_done_generate
        always_comb begin
            oPERF_LINK_DONE[ii] = iBLK_DONE & ( iLINK_NUM == ii );
        end
    end
endgenerate

generate
    for ( ii=0; ii<PORTS; ii++ ) begin: req_tic_max_generate
        always @(posedge clk)
            if (~rst_n)
                req_tic_max[ii]  <= 32'h0;
            else if ( iLATCH )
                req_tic_max[ii]  <= (req_tic_max[ii] < iPERF_REQ_TICKS[ii]) ? iPERF_REQ_TICKS[ii] : req_tic_max[ii];
    end
endgenerate

endmodule
